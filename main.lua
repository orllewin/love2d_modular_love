require "object"
require "colour"
require "colours"
require 'dropdown'
require 'event'
require 'logger'
require 'menu'
require 'socket'
require "patch_cable"
require "modules/module_helper"
require "view_utils"
require "views/line"
require "view_manager"

love.graphics.setDefaultFilter("linear", "linear")
love.graphics.setLineStyle("rough")

local font = love.graphics.newFont("sf_pro.ttf", 14)
love.graphics.setFont(font)

smallFont = love.graphics.newFont("sf_pro.ttf", 11)
tinyFont = love.graphics.newFont("sf_pro.ttf", 9)

local viewManager = ViewManager()
local menu = Menu()
dropdown = Dropdown()
logger = Logger()

print("ModularLöve")

audioEffectsSupported = love.audio.isEffectsSupported()
logger:log("Has audio effects: " .. tostring(audioEffectsSupported))

local ghostCable = PatchCable(true, "GHOST")

local commandDown = false
local mouseDown = false--todo - move to view manager
local controlLock = false
local moveMod = false
showLabels = false

local ghostCableStartX = -1
local ghostCableStartY = -1
local ghostCableEndX = -1
local ghostCableEndY = -1
local ghostVisible = false
--local backgroundColour = rgb("#a4b097")
 math.randomseed(os.time())
local backgroundColour = randomBackgroundColour()
--local backgroundColour = rgb("#ffffff")
encoderColour = Colours.defaultEncoder

function love.load()
	logger:log("love.load()")
end

function love.update(deltaTime)
	viewManager:updateViews(deltaTime)
end

function love.draw()
	love.graphics.setBackgroundColor(backgroundColour)
	if love.keyboard.isDown("up") then
		viewManager:down()
	end
	if love.keyboard.isDown("down") then
		viewManager:up()
	end
	if love.keyboard.isDown("left") then
		viewManager:right()
	end
	if love.keyboard.isDown("right") then
		viewManager:left()
	end
	viewManager:drawViews()
	
	if ghostVisible then
		local mouseX, mouseY = love.mouse.getPosition()
		love.graphics.line(ghostCableStartX, ghostCableStartY, mouseX, mouseY)
	end
	
	menu:draw(viewManager:getOffset())
	dropdown:draw(viewManager:getOffset())
	logger:draw()
end

function love.keypressed(key, scancode, isrepeat)
	if key ~= 'c' and viewManager:keyboardFocused() then
		viewManager:keyboardPlay(key)
		return
	end
	if key == 'c' then
		if commandDown then
			--copy module
			local mX, mY = love.mouse.getPosition()
			viewManager:tryCopyModule(mX, mY, function(message) 
				logger:log(message)
			end)
		else
			--cable handling
			ghostVisible = viewManager:tryConnectGhostOut(ghostCable, love.mouse.getPosition())
			if ghostVisible then
				logger:log("Ghost cable active")
				ghostCableStartX = ghostCable:getStartX()
				ghostCableStartY = ghostCable:getStartY()
			else
				ghostCableStartX = -1
				ghostCableStartY = -1
			end
		end
	elseif key == 'v' then	
		if commandDown then
			local mX, mY = love.mouse.getPosition()
			viewManager:tryPasteModule(mX, mY)
		end
	elseif key == 'l' then
		logger:toggleVisibility()
	elseif key == 'm' then
		local mX, mY = love.mouse.getPosition()
		moveMod = viewManager:captureMoveMod(mX, mY)
		logger:log("Move mod: " .. tostring(moveMod))
	elseif key == 'lgui' then
		commandDown = true
	elseif key == 'k' then
		showLabels = not showLabels 
	elseif key == 'b' then
		backgroundColour = randomBackgroundColour()
	elseif key == 'e' then
		encoderColour = randomDarkPastel()
	end
end

function love.keyreleased(key)
	if key ~= 'c' and viewManager:keyboardFocused() then
		viewManager:keyboardStop(key)
		return
	end
	if key == 'c' and ghostVisible then
		ghostVisible = false
		--local ghostCableEndX, ghostCableEndY = viewManager:tryDropCable(love.mouse.getPosition())
		ghostDropSuccess = viewManager:tryConnectGhostIn(ghostCable, love.mouse.getPosition())
		if ghostDropSuccess then
			ghostCableEndX = ghostCable:getEndX()
			ghostCableEndY = ghostCable:getEndY()
	
			logger:log("Add patch cable")	
			local newCable = PatchCable()
			local gX, gY = viewManager:getOffset() 
			
			newCable:setStart(ghostCableStartX - gX, ghostCableStartY - gY, ghostCable:getStartModId())
			newCable:setEnd(ghostCableEndX - gX, ghostCableEndY - gY, ghostCable:getEndModId())
									
			viewManager:reifyGhost(newCable)

		end
	elseif key == 'lgui' then
		commandDown = false
	elseif key == 'm' then
		logger:log("moveMod off")
		moveMod = false
	end
end

function love.mousepressed(x, y, button)
	if button == 1 then 
		local mX, mY = love.mouse.getPosition()
		local gX, gY = viewManager:getOffset()
		if menu:isShowing() then
			if menu:contains(mX, mY, gX, gY) then
				menu:click(mX, mY, gX, gY, function(child) 
					viewManager:addChild(x, y, child)
				end)
			else
				tryModuleClick(mX, mY)
			end
		elseif dropdown:isShowing() then
			if dropdown:contains(mX, mY, gX, gY) then
				dropdown:click(mX, mY, gX, gY)
			else
				tryModuleClick(mX, mY)
			end
		else
			tryModuleClick(mX, mY)
		end
	end
	if button == 2 then
		showMenu()
	end
end

function tryModuleClick(x, y)
	local moduleClicked = viewManager:clickModule(x, y)
	if moduleClicked == false then
		controlLock = viewManager:captureMouseMove(x, y)
		dropdown:dismiss()
		mouseDown = true
	end
	menu:dismiss()
	
end

function showMenu()
	logger:log("showMenu()")
	local mouseX, mouseY = love.mouse.getPosition()
	menu:show(mouseX, mouseY)
end

function love.wheelmoved(x, y)
	local amount = 6
	if love.keyboard.isDown("lshift") then
		amount = 12
	end
	if y < 0 then
		viewManager:upBy(amount * (y * -1))
	elseif y > 0 then
		viewManager:downBy(amount * y)
	end
	if x < 0 then
		viewManager:rightBy(amount * (x * -1))
	elseif x > 0 then
		viewManager:leftBy(amount * x)
	end
end

function love.mousemoved(x, y, dx, dy, istouch)
	if controlLock then
		viewManager:tryMoveControl(x, y, dx, dy)
	elseif moveMod then
		viewManager:tryMoveMod(dx, dy)
	elseif mouseDown == true then
		viewManager:move(dx, dy)
		menu:dismiss()
	else
		viewManager:tryFocus(x, y)
	end
end

function love.mousereleased(x, y, button)
	if button == 1 then 
		mouseDown = false
		controlLock = false
	end
end