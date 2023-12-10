require "modules/core/blackhole/blackhole_com"

class('BlackholeMod').extends()

local modType = "BlackholeMod"
local modSubtype = "clock_router"

local orbitRadius = 6

function BlackholeMod:init(x, y, modId)
	BlackholeMod.super.init()
	
	if modId == nil then
		self.modId = "BlackholeMod-" .. os.time() .. "_" .. math.random()
	else
		self.modId = modId
	end
	
	self.modType = modType
	
	self.indicatorOn = false
	self.onElapsed = 0
	
	self.outIndicatorOn = false
	self.outElapsed = 0
	self.orbitColour = Colours.white
	
	self.isFocused = true
	
	self.component = BlackholeCom(function() 
		self.indicatorOn = true
		self.onElapsed = 0
	end, function() 
		local theta = math.random() * 2 * 3.1415926
		self.outIndicatorX = (self.width/2) + 20 * math.cos(theta)
		self.outIndicatorY = (self.height/2) + 20 * math.sin(theta) - 12
		self.orbitColour = randomPastel()
		self.outIndicatorOn = true
		self.outElapsed = 0
	end)

	self.width = 80
	self.height = 80
		
	self.x = x - self.width/2
	self.y = y - 15
	
	self.isFocusedCanvas = moduleCanvas(Colours.focusColour, Colours.focusColour, self.width + 3, self.height + 3, 7)
	
	self.blackholeEncoder = Encoder(self.width/2 - 12, self.height/2 - 24, 12, 0.0, encoderColour, Colours.white, function(value) 
		self.component:setGravity(value)
		
	end)
	
	
	self.socketInVector = Vector(16, self.height - 16)
	self.socketOutVector = Vector(self.width - 16, self.height - 16)
	
	
	self:redrawCanvas()
end

function BlackholeMod:redrawCanvas()
	self.canvas = moduleCanvas({0.2, 0.2, 0.2}, Colours.defaultModBorder, self.width, self.height, 7)
		
	love.graphics.setCanvas(self.canvas)
	love.graphics.push()
	love.graphics.setColor({1, 1, 1, 0.6}) 
	love.graphics.circle('line', self.width/2, self.height/2 - 12, 20)
	love.graphics.pop()
	love.graphics.setCanvas()
	love.graphics.setColor(rgb("#ffffff")) 
	
	moduleSocket(self.canvas, self.socketInVector.x, self.socketInVector.y, {1, 1, 1, 0.6})
	moduleSocket(self.canvas, self.socketOutVector.x, self.socketOutVector.y, {1, 1, 1, 0.6})
	
	if self.blackholeEncoder ~= nil then
		self.blackholeEncoder:canvasDraw(self.canvas)
	end
end

function BlackholeMod:canScroll() 
	return true
end

function BlackholeMod:scroll(oX, oY, dX, dY, gX, gY)
		self.blackholeEncoder:deltaXY(dX, dY)
		self.blackholeEncoder:canvasDraw(self.canvas)
end 

function BlackholeMod:move(dX, dY, inCables, outCables)
	self.x = self.x + dX
	self.y = self.y + dY
	
	if self.component:inConnected() then
		self.inCable:repositionEnd(dX, dY)
	end
	
	if self.component:outConnected() then
		self.outCable:repositionStart(dX, dY)
	end
end

function BlackholeMod:visible(xOffset, yOffset)
	return true
end

function BlackholeMod:focus()
	self.isFocused = true
end

function BlackholeMod:unfocus()
	self.isFocused = false
end

function BlackholeMod:contains(x, y, gX, gY)
	local collision = inBounds(x, y, self.x + gX, self.y + gY, self.width, self.height)
	return collision
end

function BlackholeMod:setInCable(cable)
	self.inCable = cable
	self.component:setInCable(cable)
end

function BlackholeMod:setOutCable(cable)
		self.outCable = cable
		self.component:setOutCable(cable)
end

function BlackholeMod:tryConnectGhostOut(x, y, gX, gY, ghostCable)
	if self.component:outConnected() then
		return false
	else
		ghostCable:setStart(self.x + self.socketOutVector.x + gX, self.y + self.socketOutVector.y + gY)
		ghostCable:setGhostSendConnected()
		return true
	end
end

function BlackholeMod:tryConnectGhostIn(x, y, gX, gY, ghostCable)
	if self.component:inConnected() then
		return false
	else
		ghostCable:setEnd(self.x + self.socketInVector.x + gX, self.y + self.socketInVector.y + gY)
		ghostCable:setGhostReceiveConnected()
		return true
	end
end

function BlackholeMod:update(deltaTime)
	if self.indicatorOn then
		self.onElapsed = self.onElapsed + deltaTime
		if self.onElapsed > 0.25 then
			self.indicatorOn = false
			self.onElapsed = 0
		end
	end
	
	if self.outIndicatorOn then
		self.outElapsed = self.outElapsed + deltaTime
		if self.outElapsed > 0.25 then
			self.outIndicatorOn = false
			self.outElapsed = 0
		end
	end
end

function BlackholeMod:draw(xOffset, yOffset)
	if self:visible(xOffset, yOffset) then
		if showLabels then
			love.graphics.printf("Blackhole", self.x + (self.width/2) + xOffset - 50, self.y + yOffset - 20, 100, 'center')
		end
		if self.isFocused then
			love.graphics.draw(self.isFocusedCanvas, self.x + xOffset - 1, self.y + yOffset - 1)
		end
		love.graphics.draw(self.canvas, self.x + xOffset, self.y + yOffset)
		if self.indicatorOn then
			love.graphics.setColor(Colours.darkGrey)
			love.graphics.circle('fill', self.x + xOffset + 16, self.y + yOffset + self.height - 16, 6)
			love.graphics.setColor(white())
		end
		
		if self.outIndicatorOn then
			love.graphics.setColor(self.orbitColour)
			love.graphics.circle('fill', self.x + xOffset + self.outIndicatorX, self.y + yOffset + self.outIndicatorY, orbitRadius)
			love.graphics.setColor(white())
		end
	end
end

