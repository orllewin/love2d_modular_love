require "modules/clock/clock/clock_com"
require "views/encoder"

class('ClockMod').extends()

local modType = "ClockMod"
local modSubtype = "clock_router"

function ClockMod:init(x, y, modId)
	ClockMod.super.init()
	
	if modId == nil then
		self.modId = "ClockMod-" .. os.time() .. "_" .. math.random()
	else
		self.modId = modId
	end
	
	self.modType = modType
	
	self.component = ClockCom(function() 
		
	end)

	self.width = 70
	self.height = 120
	
	self.isFocused = true
	
	self.x = x - self.width/2
	self.y = y - 15
	
	self.canvas = moduleCanvas(Colours.clockModBackground, Colours.defaultModBorder, self.width, self.height, 7)
	
	self.encoder = Encoder(20, 10, 14, 0.5, encoderColour, Colours.white, function(value) 
		self.component:tempoChange(value)
	end)
	self.encoder:canvasDraw(self.canvas)
	
	self.isFocusedCanvas = moduleCanvas(Colours.focusColour, Colours.focusColour, self.width + 3, self.height + 3, 7)
	
	local qW = self.width/4
	self.socketOutAVector = Vector(qW, 60)
	moduleSocket(self.canvas, self.socketOutAVector.x, self.socketOutAVector.y)
	
	self.socketOutBVector = Vector(qW * 3, 60)
	moduleSocket(self.canvas, self.socketOutBVector.x, self.socketOutBVector.y)
	
	self.socketOutCVector = Vector(qW, 100)
	moduleSocket(self.canvas, self.socketOutCVector.x, self.socketOutCVector.y)
	
	self.socketOutDVector = Vector(qW * 3, 100)
	moduleSocket(self.canvas, self.socketOutDVector.x, self.socketOutDVector.y)
end

function ClockMod:visible(xOffset, yOffset)
	return true
end

function ClockMod:canScroll() 
	return true
end

function ClockMod:scroll(oX, oY, dX, dY)
	self.encoder:deltaXY(dX, dY)
	self.encoder:canvasDraw(self.canvas)
end 

function BangIndicatorMod:move(dX, dY, inCables, outCables)
	self.x = self.x + dX
	self.y = self.y + dY
		
	if self.component:aConnected() then
		self.outACable:repositionStart(dX, dY)
	end
	
	if self.component:bConnected() then
		self.outBCable:repositionStart(dX, dY)
	end
	
	if self.component:cConnected() then
		self.outCCable:repositionStart(dX, dY)
	end
	
	if self.component:dConnected() then
		self.outDCable:repositionStart(dX, dY)
	end
end

function ClockMod:focus()
	self.isFocused = true
end

function ClockMod:unfocus()
	self.isFocused = false
end

function ClockMod:contains(x, y, gX, gY)
	if gX == nil then
		logger:log("nil gX")
		return
	end
	local collision = inBounds(x, y, self.x + gX, self.y + gY, self.width, self.height)
	return collision
end

function ClockMod:setOutCable(patchCable)
	if self.component:aConnected() ~= true then
		self.outACable = patchCable
		self.component:setOutACable(patchCable:getCable())
	elseif self.component:bConnected() ~= true then
		self.outBCable = patchCable
		self.component:setOutBCable(patchCable:getCable())
	elseif self.component:cConnected() ~= true then
		self.outCCable = patchCable
		self.component:setOutCCable(patchCable:getCable())
	elseif self.component:dConnected() ~= true then
		self.outCCable = patchCable
		self.component:setOutDCable(patchCable:getCable())
	end
end

function ClockMod:tryConnectGhostOut(x, y, gX, gY, ghostCable)
	if self.component:aConnected() ~= true then
		ghostCable:setStart(self.x + self.socketOutAVector.x + gX, self.y + self.socketOutAVector.y + gY)
		ghostCable:setGhostSendConnected()
		logger:log("Ghost y = " .. ghostCable:getStartY())
		return true
	elseif self.component:bConnected() ~= true then
		ghostCable:setStart(self.x + self.socketOutBVector.x + gX, self.y + self.socketOutBVector.y + gY)
		ghostCable:setGhostSendConnected()
		logger:log("Ghost y = " .. ghostCable:getStartY())
		return true
	elseif self.component:cConnected() ~= true then
		ghostCable:setStart(self.x + self.socketOutCVector.x + gX, self.y + self.socketOutCVector.y + gY)
		ghostCable:setGhostSendConnected()
		logger:log("Ghost y = " .. ghostCable:getStartY())
		return true
	elseif self.component:dConnected() ~= true then
		ghostCable:setStart(self.x + self.socketOutDVector.x + gX, self.y + self.socketOutDVector.y + gY)
		ghostCable:setGhostSendConnected()
		logger:log("Ghost y = " .. ghostCable:getStartY())
		return true
	else
		return false
	end
end

function ClockMod:tryConnectGhostIn(x, y, gX, gY)
	return false
end

function ClockMod:update(deltaTime)
	self.component:update(deltaTime)
end

function ClockMod:draw(xOffset, yOffset)
	if self:visible(xOffset, yOffset) then
		if showLabels then
			love.graphics.printf("Clock", self.x + (self.width/2) + xOffset - 50, self.y + yOffset - 20, 100, 'center')
		end
		if self.isFocused then
			love.graphics.draw(self.isFocusedCanvas, self.x + xOffset - 1, self.y + yOffset - 1)
		end
		love.graphics.draw(self.canvas, self.x + xOffset, self.y + yOffset)

	end
end