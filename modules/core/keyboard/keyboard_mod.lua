require "modules/core/keyboard/keyboard_com"

class('KeyboardMod').extends()

local modType = "KeyboardMod"
local modSubtype = "clock_router"

local keyboard = love.graphics.newImage("images/midi_keyboard.png")

function KeyboardMod:init(x, y, modId)
	KeyboardMod.super.init()
	
	if modId == nil then
		self.modId = "KeyboardMod-" .. os.time() .. "_" .. math.random()
	else
		self.modId = modId
	end
	
	self.modType = modType
	
	self.indicatorOn = false
	self.onElapsed = 0
	
	self.isFocused = true
	
	self.component = KeyboardCom(function() 

	end)
	
	self.indicators = {}

	self.width = 460
	self.height = 100
		
	self.x = x - self.width/2
	self.y = y - 15
	
	self.isFocusedCanvas = moduleCanvas(Colours.focusColour, Colours.focusColour, self.width + 3, self.height + 3, 7)
	
	self.socketOutVector = Vector(self.width - 16, 16)
	self:redrawCanvas()
	
end

function KeyboardMod:redrawCanvas()
	self.canvas = moduleCanvas(Colours.defaultModBackground, Colours.defaultModBorder, self.width, self.height, 7)
	
	love.graphics.setCanvas(self.canvas)
	love.graphics.push()
	
	love.graphics.draw(keyboard, 5, 10)
	love.graphics.pop()
	love.graphics.setCanvas()
	love.graphics.setLineWidth(1)
	love.graphics.setColor(white()) 
	
	
	moduleSocket(self.canvas, self.socketOutVector.x, self.socketOutVector.y)	
end

function KeyboardMod:playKey(keycode)
	self.component:playKey(keycode, love.keyboard.isDown('lshift'), function(white, index) 
		table.insert(self.indicators, {
			white = white,
			elapsed = 0,
			index = index,
			opacity = 1
		})
	end)
end

function KeyboardMod:stopKey(keycode)
	--self.component:stopKey(keycode)
end

function KeyboardMod:click(x, y, gX, gY)
	if x > (self.x + gX + 5) and x < (self.x + gX + self.width - 10) then

		local min = 5
		local max = 426
		local rX = x - gX - self.x
		local rY = y - gY - self.y

		if rX > min and rX < max then
			rX = rX - min
			if rY < 58 then
				--BLACK NOTE
				local blackNoteIndex = math.floor(map(rX + 10, 0, 400, 1, 21)) - 1
				self.component:playBlackNote(blackNoteIndex)
			else
				--WHITE NOTE
				local whiteNoteIndex = math.floor(map(rX, 0, 400, 1, 21))
				self.component:playWhiteNote(whiteNoteIndex)
			end
		end
		
		return true
	else
		return false
	end
end

function KeyboardMod:move(dX, dY)
	self.x = self.x + dX
	self.y = self.y + dY
end

function KeyboardMod:visible(xOffset, yOffset)
	return true
end

function KeyboardMod:focus()
	self.isFocused = true
end

function KeyboardMod:unfocus()
	self.isFocused = false
end

function KeyboardMod:contains(x, y, gX, gY)
	local collision = inBounds(x, y, self.x + gX, self.y + gY, self.width, self.height)
	return collision
end

function KeyboardMod:setInCable(cable)
	self.component:setInCable(cable)
end

function KeyboardMod:setOutCable(cable)
	self.component:setOutCable(cable)
end

function KeyboardMod:tryConnectGhostOut(x, y, gX, gY, ghostCable)
	if self.component:outConnected() then
		return false
	else
		ghostCable:setStart(self.x + self.socketOutVector.x + gX, self.y + self.socketOutVector.y + gY)
		ghostCable:setGhostSendConnected()
		return true
	end
end

function KeyboardMod:tryConnectGhostIn(x, y, gX, gY, ghostCable)
	if self.component:inConnected() then
		return false
	else
		ghostCable:setEnd(self.x + self.socketInVector.x + gX, self.y + self.socketInVector.y + gY)
		ghostCable:setGhostReceiveConnected()
		return true
	end
end

function KeyboardMod:update(deltaTime)	
	for i=#self.indicators, 1, -1 do
		self.indicators[i].elapsed = self.indicators[i].elapsed + deltaTime
		self.indicators[i].opacity = self.indicators[i].opacity - 0.005
		if self.indicators[i].elapsed > 1.75 then
			table.remove(self.indicators, i)
		end
	end
end

function KeyboardMod:draw(xOffset, yOffset)
	if self:visible(xOffset, yOffset) then
		if showLabels then
			love.graphics.printf("Keyboard", self.x + (self.width/2) + xOffset - 50, self.y + yOffset - 20, 100, 'center')
		end
		if self.isFocused then
			love.graphics.draw(self.isFocusedCanvas, self.x + xOffset - 1, self.y + yOffset - 1)
		end
		love.graphics.draw(self.canvas, self.x + xOffset, self.y + yOffset)
		
		for i=#self.indicators,1, -1 do
			local indicator = self.indicators[i]
			
			if indicator.white then
				love.graphics.setColor({0.35, 0.7, 0.55, indicator.opacity}) 
				love.graphics.circle('fill', self.x + xOffset + indicator.index * 20 - 3, self.y + yOffset + 78, 6)
			else
				love.graphics.setColor({0.8, 0.8, 0.8, indicator.opacity}) 
				love.graphics.circle('fill', self.x + xOffset + 9 + indicator.index * 20 - 3, self.y + yOffset + 48, 6)
			end
		end
		love.graphics.setColor(white()) 
	end
end

