require "modules/clock/clock_divider/clock_divider_com"

class('ClockDividerMod').extends()

local modType = "ClockDividerMod"
local modSubtype = "clock_router"

local arrow = love.graphics.newImage("images/clock_divider_icon.png")

function ClockDividerMod:init(x, y, modId)
	ClockDividerMod.super.init()
	
	if modId == nil then
		self.modId = "ClockDividerMod-" .. os.time() .. "_" .. math.random()
	else
		self.modId = modId
	end
	
	self.modType = modType
	
	self.inIndicatorOn = false
	self.inIndicatorElapsed = 0
	self.outIndicatorOn = false
	self.outIndicatorElapsed = 0
	
	self.isFocused = true
	
	self.component = ClockDividerCom(function() 
		--in 
		self.inIndicatorOn = true
		self.inIndicatorElapsed = 0
	end, function() 
		--out
		self.outIndicatorOn = true
		self.outIndicatorElapsed = 0
	end)

	self.width = 110
	self.height = 55
	
	self.chanceLabel = "50%"
	self.clockDelayLabel = "Off"
	
	self.rndColour = randomPastel()
	
	self.x = x - self.width/2
	self.y = y - 15
	
	self.isFocusedCanvas = moduleCanvas(Colours.focusColour, Colours.focusColour, self.width + 3, self.height + 3, 7)
	self.canvas = moduleCanvas(Colours.defaultModBackground, Colours.defaultModBorder, self.width, self.height, 7)
	
	self.socketInVector = Vector(16, self.height - 16)
	moduleSocket(self.canvas, self.socketInVector.x, self.socketInVector.y)
	
	self.socketOutVector = Vector(self.width - 16, self.height - 16)
	moduleSocket(self.canvas, self.socketOutVector.x, self.socketOutVector.y)
		
	self:redrawCanvas()
end

function ClockDividerMod:redrawCanvas()
	self.canvas = moduleCanvas(Colours.defaultModBackground, Colours.defaultModBorder, self.width, self.height, 7)
		
	moduleSocket(self.canvas, self.socketInVector.x, self.socketInVector.y)
	moduleSocket(self.canvas, self.socketOutVector.x, self.socketOutVector.y)
	
	love.graphics.setCanvas(self.canvas)
	love.graphics.push()
	love.graphics.setColor(Colours.black) 
		
	love.graphics.draw( arrow, 22, 10)
	
	love.graphics.pop()
	
	love.graphics.setCanvas()
	love.graphics.setColor(rgb("#ffffff")) 
end

function ClockDividerMod:canScroll() 
	return true
end

function ClockDividerMod:scroll(oX, oY, dX, dY, gX, gY)
	if oX < (self.x + gX + self.width/2) then
		self.clockDelayEncoder:delta(dY)
		self.clockDelayEncoder:canvasDraw(self.canvas)
	else
		self.delayChanceEncoder:delta(dY)
		self.delayChanceEncoder:canvasDraw(self.canvas)
	end
end 

function ClockDividerMod:move(dX, dY, inCables, outCables)
	self.x = self.x + dX
	self.y = self.y + dY
	
	if self.component:inConnected() then
		self.inCable:repositionEnd(dX, dY)
	end
	
	if self.component:outConnected() then
		self.outCable:repositionStart(dX, dY)
	end
end

function ClockDividerMod:visible(xOffset, yOffset)
	return true
end

function ClockDividerMod:focus()
	self.isFocused = true
end

function ClockDividerMod:unfocus()
	self.isFocused = false
end

function ClockDividerMod:contains(x, y, gX, gY)
	local collision = inBounds(x, y, self.x + gX, self.y + gY, self.width, self.height)
	return collision
end

function ClockDividerMod:setInCable(cable)
	self.component:setInCable(cable)
	self.inCable = cable
end

function ClockDividerMod:setOutCable(cable)
	self.component:setOutCable(cable)
	self.outCable = cable
end

function ClockDividerMod:tryConnectGhostOut(x, y, gX, gY, ghostCable)
	if self.component:outConnected() then
		return false
	else
		ghostCable:setStart(self.x + self.socketOutVector.x + gX, self.y + self.socketOutVector.y + gY)
		ghostCable:setGhostSendConnected()
		return true
	end
end

function ClockDividerMod:tryConnectGhostIn(x, y, gX, gY, ghostCable)
	if self.component:inConnected() then
		return false
	else
		ghostCable:setEnd(self.x + self.socketInVector.x + gX, self.y + self.socketInVector.y + gY)
		ghostCable:setGhostReceiveConnected()
		return true
	end
end

function ClockDividerMod:update(deltaTime)
	
end

function ClockDividerMod:update(deltaTime)	
	if self.inIndicatorOn then
		self.inIndicatorElapsed = self.inIndicatorElapsed + deltaTime
		if self.inIndicatorElapsed > 0.25 then
			self.inIndicatorOn = false
			self.inIndicatorElapsed = 0
		end
	end
	
	if self.outIndicatorOn then
		self.outIndicatorElapsed = self.outIndicatorElapsed + deltaTime
		if self.outIndicatorElapsed > 0.25 then
			self.outIndicatorOn = false
			self.outIndicatorElapsed = 0
		end
	end
end

function ClockDividerMod:draw(xOffset, yOffset)
	if self:visible(xOffset, yOffset) then
		if showLabels then
			love.graphics.printf("Clock Divider", self.x + (self.width/2) + xOffset - 50, self.y + yOffset - 20, 100, 'center')
		end
		if self.isFocused then
			love.graphics.draw(self.isFocusedCanvas, self.x + xOffset - 1, self.y + yOffset - 1)
		end
		love.graphics.draw(self.canvas, self.x + xOffset, self.y + yOffset)
		if self.inIndicatorOn then
			love.graphics.setColor(Colours.darkGrey)
			love.graphics.circle('fill', self.x + xOffset + 35, self.y + yOffset + self.height - 16, 6)
			love.graphics.setColor(white())
		end
		
		if self.outIndicatorOn then
			love.graphics.setColor(Colours.darkGrey)
			love.graphics.circle('fill', self.x + xOffset + self.width - 35, self.y + yOffset + self.height - 16, 6)
			love.graphics.setColor(white())
		end
	end
end

