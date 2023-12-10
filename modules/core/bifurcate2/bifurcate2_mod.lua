require "modules/core/bifurcate2/bifurcate2_com"

class('Bifurcate2Mod').extends()

local modType = "Bifurcate2Mod"
local modSubtype = "clock_router"

local arrow = love.graphics.newImage("images/bifurcate2_arrows.png")

function Bifurcate2Mod:init(x, y, modId)
	Bifurcate2Mod.super.init()
	
	if modId == nil then
		self.modId = "Bifurcate2Mod-" .. os.time() .. "_" .. math.random()
	else
		self.modId = modId
	end
	
	self.modType = modType
	
	self.indicatorOn = false
	self.onElapsed = 0
	
	self.isFocused = true
	
	self.component = Bifurcate2Com(function() 
		self.indicatorOn = true
		self.onElapsed = 0
	end)

	self.width = 70
	self.height = 70
		
	self.x = x - self.width/2
	self.y = y - 15
	
	self.isFocusedCanvas = moduleCanvas(Colours.focusColour, Colours.focusColour, self.width + 3, self.height + 3, 7)
	self.canvas = moduleCanvas(Colours.defaultModBackground, Colours.defaultModBorder, self.width, self.height, 7)
	
	self.socketInVector = Vector(self.width/2, 16)
	moduleSocket(self.canvas, self.socketInVector.x, self.socketInVector.y)
	
	self.socketOutAVector = Vector(16, self.height - 16)
	moduleSocket(self.canvas, self.socketOutAVector.x, self.socketOutAVector.y)
	
	self.socketOutBVector = Vector(self.width - 16, self.height - 16)
	moduleSocket(self.canvas, self.socketOutBVector.x, self.socketOutBVector.y)
	
	love.graphics.setCanvas(self.canvas)
	love.graphics.push()
	love.graphics.setColor(Colours.black) 
	love.graphics.draw( arrow, 22, 26)
	love.graphics.pop()
	
	love.graphics.setCanvas()
	love.graphics.setColor(rgb("#ffffff")) 
end

function Bifurcate2Mod:move(dX, dY, inCables, outCables)
	self.x = self.x + dX
	self.y = self.y + dY
	
	if self.component:inConnected() then
		self.inCable:repositionEnd(dX, dY)
	end
	
	if self.component:outAConnected() then
		self.outACable:repositionStart(dX, dY)
	end
	
	if self.component:outBConnected() then
		self.outBCable:repositionStart(dX, dY)
	end
end

function Bifurcate2Mod:visible(xOffset, yOffset)
	return true
end

function Bifurcate2Mod:focus()
	self.isFocused = true
end

function Bifurcate2Mod:unfocus()
	self.isFocused = false
end

function Bifurcate2Mod:contains(x, y, gX, gY)
	local collision = inBounds(x, y, self.x + gX, self.y + gY, self.width, self.height)
	return collision
end

function Bifurcate2Mod:setInCable(cable)
	self.inCable = cable
	self.component:setInCable(cable)
end

function Bifurcate2Mod:setOutCable(cable)
	if self.component:outAConnected() then
		self.outBCable = cable
		self.component:setOutBCable(cable)
	else
		self.outACable = cable
	self.component:setOutACable(cable)
	end

end

function Bifurcate2Mod:tryConnectGhostOut(x, y, gX, gY, ghostCable)
	if self.component:outAConnected() and self.component:outBConnected() then
		return false
	elseif self.component:outAConnected() then
		ghostCable:setStart(self.x + self.socketOutBVector.x + gX, self.y + self.socketOutBVector.y + gY)
		ghostCable:setGhostSendConnected()
		return true
	else
		ghostCable:setStart(self.x + self.socketOutAVector.x + gX, self.y + self.socketOutAVector.y + gY)
		ghostCable:setGhostSendConnected()
		return true
	end
end

function Bifurcate2Mod:tryConnectGhostIn(x, y, gX, gY, ghostCable)
	if self.component:inConnected() then
		return false
	else
		ghostCable:setEnd(self.x + self.socketInVector.x + gX, self.y + self.socketInVector.y + gY)
		ghostCable:setGhostReceiveConnected()
		return true
	end
end

function Bifurcate2Mod:update(deltaTime)
	if self.indicatorOn then
		self.onElapsed = self.onElapsed + deltaTime
		if self.onElapsed > 0.25 then
			self.indicatorOn = false
			self.onElapsed = 0
		end
	end
end

function Bifurcate2Mod:draw(xOffset, yOffset)
	if self:visible(xOffset, yOffset) then
		if showLabels then
			love.graphics.printf("Bifurcate 2", self.x + (self.width/2) + xOffset - 50, self.y + yOffset - 20, 100, 'center')
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

