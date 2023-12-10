require "modules/clock/bang_indicator/bang_indicator_com"

class('BangIndicatorMod').extends()

local modType = "BangIndicatorMod"
local modSubtype = "clock_router"

function BangIndicatorMod:init(x, y, modId)
	BangIndicatorMod.super.init()
	
	if modId == nil then
		self.modId = "BangIndicatorMod-" .. os.time() .. "_" .. math.random()
	else
		self.modId = modId
	end
	
	self.modType = modType
	
	self.indicatorOn = false
	self.onElapsed = 0
	
	self.isFocused = true
	
	self.component = BangIndicatorCom(function() 
		self.indicatorOn = true
		self.onElapsed = 0
	end)

	self.width = 80
	self.height = 32
		
	self.x = x - self.width/2
	self.y = y - 15
	
	self.isFocusedCanvas = moduleCanvas(Colours.focusColour, Colours.focusColour, self.width + 3, self.height + 3, 7)
	self.canvas = moduleCanvas(Colours.defaultModBackground, Colours.defaultModBorder, self.width, self.height, 7)
	
	self.socketInVector = Vector(16, 16)
	moduleSocket(self.canvas, self.socketInVector.x, self.socketInVector.y)
	
	self.socketOutVector = Vector(self.width - 16, 16)
	moduleSocket(self.canvas, self.socketOutVector.x, self.socketOutVector.y)
end

function BangIndicatorMod:move(dX, dY, inCables, outCables)
	self.x = self.x + dX
	self.y = self.y + dY
	
	if self.component:inConnected() then
		self.inCable:repositionEnd(dX, dY)
	end
	
	if self.component:outConnected() then
		self.outCable:repositionStart(dX, dY)
	end
end

function BangIndicatorMod:visible(xOffset, yOffset)
	return true
end

function BangIndicatorMod:focus()
	self.isFocused = true
end

function BangIndicatorMod:unfocus()
	self.isFocused = false
end

function BangIndicatorMod:contains(x, y, gX, gY)
	local collision = inBounds(x, y, self.x + gX, self.y + gY, self.width, self.height)
	return collision
end

function BangIndicatorMod:setInCable(cable)
	self.inCable = cable
	self.component:setInCable(cable)
end

function BangIndicatorMod:setOutCable(cable)
	self.outCable = cable
	self.component:setOutCable(cable)
end

function BangIndicatorMod:tryConnectGhostOut(x, y, gX, gY, ghostCable)
	if self.component:outConnected() then
		return false
	else
		ghostCable:setStart(self.x + self.socketOutVector.x + gX, self.y + self.socketOutVector.y + gY)
		ghostCable:setGhostSendConnected()
		return true
	end
end

function BangIndicatorMod:tryConnectGhostIn(x, y, gX, gY, ghostCable)
	if self.component:inConnected() then
		return false
	else
		ghostCable:setEnd(self.x + self.socketInVector.x + gX, self.y + self.socketInVector.y + gY)
		ghostCable:setGhostReceiveConnected()
		return true
	end
end

function BangIndicatorMod:update(deltaTime)
	if self.indicatorOn then
		self.onElapsed = self.onElapsed + deltaTime
		if self.onElapsed > 0.25 then
			self.indicatorOn = false
			self.onElapsed = 0
		end
	end
end

function BangIndicatorMod:draw(xOffset, yOffset)
	if self:visible(xOffset, yOffset) then
		if showLabels then
			love.graphics.printf("Bang Indicator", self.x + (self.width/2) + xOffset - 50, self.y + yOffset - 20, 100, 'center')
		end
		if self.isFocused then
			love.graphics.draw(self.isFocusedCanvas, self.x + xOffset - 1, self.y + yOffset - 1)
		end
		love.graphics.draw(self.canvas, self.x + xOffset, self.y + yOffset)
		if self.indicatorOn then
			love.graphics.setColor(Colours.darkGrey)
			love.graphics.circle('fill', self.x + xOffset + (self.width/2), self.y + yOffset + 16, 6)
			love.graphics.setColor(white())
		end
	end
end

