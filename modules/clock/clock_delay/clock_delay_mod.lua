require "modules/clock/clock_delay/clock_delay_com"

class('ClockDelayMod').extends()

local modType = "ClockDelayMod"
local modSubtype = "clock_router"

local arrow = love.graphics.newImage("images/clock_delay_arrow.png")

function ClockDelayMod:init(x, y, modId)
	ClockDelayMod.super.init()
	
	if modId == nil then
		self.modId = "ClockDelayMod-" .. os.time() .. "_" .. math.random()
	else
		self.modId = modId
	end
	
	self.modType = modType
	
	self.inIndicatorOn = false
	self.inIndicatorElapsed = 0
	self.outIndicatorOn = false
	self.outIndicatorElapsed = 0
	
	self.isFocused = true
	
	self.component = ClockDelayCom(function() 
		--in 
		self.inIndicatorOn = true
		self.inIndicatorElapsed = 0
	end, function() 
		--out
		self.outIndicatorOn = true
		self.outIndicatorElapsed = 0
	end)

	self.width = 110
	self.height = 90
	
	self.chanceLabel = "50%"
	self.clockDelayLabel = "Off"
	
	self.rndColour = randomPastel()
	
	self.x = x - self.width/2
	self.y = y - 15
	
	self.isFocusedCanvas = moduleCanvas(Colours.focusColour, Colours.focusColour, self.width + 3, self.height + 3, 7)

	self.socketInVector = Vector(16, self.height - 16)
	self.socketOutVector = Vector(self.width - 16, self.height - 16)

	
	self.clockDelayEncoder = Encoder(8, 20, 12, 0.0, encoderColour, Colours.white, function(value) 
		local clockDelayLabel = self.component:setClockDelay(value)
		if clockDelayLabel ~= self.clockDelayLabel then
			self.clockDelayLabel = clockDelayLabel
			self:redrawCanvas()
		end
	end)
	
	
	self.delayChanceEncoder = Encoder(78, 20, 12, 0.0, encoderColour, Colours.white, function(value) 
		self.component:setChance(value)
		local chanceLabel = "" .. (math.floor(value * 100)) .. "%" 
		if chanceLabel ~= self.chanceLabel then
			self.chanceLabel = chanceLabel
			self:redrawCanvas()
		end
	end)
	
	self:redrawCanvas()
end

function ClockDelayMod:redrawCanvas()
	self.canvas = moduleCanvas(Colours.defaultModBackground, Colours.defaultModBorder, self.width, self.height, 7)
	
	if self.clockDelayEncoder ~= nil then
		self.clockDelayEncoder:canvasDraw(self.canvas)
	end
	
	if self.delayChanceEncoder ~= nil then
		self.delayChanceEncoder:canvasDraw(self.canvas)
	end
	
	moduleSocket(self.canvas, self.socketInVector.x, self.socketInVector.y)
	moduleSocket(self.canvas, self.socketOutVector.x, self.socketOutVector.y)
	
	love.graphics.setCanvas(self.canvas)
	love.graphics.push()
	love.graphics.setColor(Colours.black) 
	
	love.graphics.printf(self.clockDelayLabel, smallFont, 21 - 30, 3, 60, 'center')
	love.graphics.printf("Delay", tinyFont, 21 - 30, 48, 60, 'center')
	
	love.graphics.printf(self.chanceLabel, smallFont, 92 - 30, 3, 60, 'center')
	love.graphics.printf("Chance", tinyFont, 88 - 30, 48, 60, 'center')
	
	love.graphics.draw( arrow, 43, self.height - 22)
	
	love.graphics.pop()
	
	love.graphics.setCanvas()
	love.graphics.setColor(rgb("#ffffff")) 
end

function ClockDelayMod:canScroll() 
	return true
end

function ClockDelayMod:scroll(oX, oY, dX, dY, gX, gY)
	if oX < (self.x + gX + self.width/2) then
		self.clockDelayEncoder:deltaXY(dX, dY)
		self.clockDelayEncoder:canvasDraw(self.canvas)
	else
		self.delayChanceEncoder:deltaXY(dX, dY)
		self.delayChanceEncoder:canvasDraw(self.canvas)
	end
end 

function ClockDelayMod:move(dX, dY, inCables, outCables)
	self.x = self.x + dX
	self.y = self.y + dY
	
	if self.component:inConnected() then
		self.inCable:repositionEnd(dX, dY)
	end
	
	if self.component:outConnected() then
		self.outCable:repositionStart(dX, dY)
	end
end

function ClockDelayMod:visible(xOffset, yOffset)
	return true
end

function ClockDelayMod:focus()
	self.isFocused = true
end

function ClockDelayMod:unfocus()
	self.isFocused = false
end

function ClockDelayMod:contains(x, y, gX, gY)
	local collision = inBounds(x, y, self.x + gX, self.y + gY, self.width, self.height)
	return collision
end

function ClockDelayMod:setInCable(cable)
	self.component:setInCable(cable)
	self.inCable = cable
end

function ClockDelayMod:setOutCable(cable)
	self.component:setOutCable(cable)
	self.outCable = cable
end

function ClockDelayMod:tryConnectGhostOut(x, y, gX, gY, ghostCable)
	if self.component:outConnected() then
		return false
	else
		ghostCable:setStart(self.x + self.socketOutVector.x + gX, self.y + self.socketOutVector.y + gY)
		ghostCable:setGhostSendConnected()
		return true
	end
end

function ClockDelayMod:tryConnectGhostIn(x, y, gX, gY, ghostCable)
	if self.component:inConnected() then
		return false
	else
		ghostCable:setEnd(self.x + self.socketInVector.x + gX, self.y + self.socketInVector.y + gY)
		ghostCable:setGhostReceiveConnected()
		return true
	end
end

function ClockDelayMod:update(deltaTime)
	
end

function ClockDelayMod:update(deltaTime)
	self.component:update(deltaTime)
	
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

function ClockDelayMod:draw(xOffset, yOffset)
	if self:visible(xOffset, yOffset) then
		if showLabels then
			love.graphics.printf("Clock Delay", self.x + (self.width/2) + xOffset - 50, self.y + yOffset - 20, 100, 'center')
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

