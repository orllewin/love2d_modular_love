require "modules/core/bifurcate4/bifurcate4_com"

class('Bifurcate4Mod').extends()

local modType = "Bifurcate4Mod"
local modSubtype = "clock_router"

local arrow = love.graphics.newImage("images/bifurcate2_arrows.png")

function Bifurcate4Mod:init(x, y, modId)
	Bifurcate4Mod.super.init()
	
	if modId == nil then
		self.modId = "Bifurcate4Mod-" .. os.time() .. "_" .. math.random()
	else
		self.modId = modId
	end
	
	self.modType = modType
	
	self.indicatorOn = false
	self.onElapsed = 0
	
	self.isFocused = true
	
	self.component = Bifurcate4Com(function() 
		self.indicatorOn = true
		self.onElapsed = 0
	end)

	self.width = 70
	self.height = 100
		
	self.x = x - self.width/2
	self.y = y - 15
	
	self.isFocusedCanvas = moduleCanvas(Colours.focusColour, Colours.focusColour, self.width + 3, self.height + 3, 7)
	self.canvas = moduleCanvas(Colours.defaultModBackground, Colours.defaultModBorder, self.width, self.height, 7)
	
	self.socketInVector = Vector(self.width/2, 16)
	moduleSocket(self.canvas, self.socketInVector.x, self.socketInVector.y)
	
	self.socketOutAVector = Vector(16, self.height - 46)
	moduleSocket(self.canvas, self.socketOutAVector.x, self.socketOutAVector.y)
	
	self.socketOutBVector = Vector(self.width - 16, self.height - 46)
	moduleSocket(self.canvas, self.socketOutBVector.x, self.socketOutBVector.y)
	
	self.socketOutCVector = Vector(16, self.height - 16)
	moduleSocket(self.canvas, self.socketOutCVector.x, self.socketOutCVector.y)
	
	self.socketOutDVector = Vector(self.width - 16, self.height - 16)
	moduleSocket(self.canvas, self.socketOutDVector.x, self.socketOutDVector.y)
	
	love.graphics.setCanvas(self.canvas)
	love.graphics.push()
	love.graphics.setColor(Colours.black) 
	love.graphics.draw(arrow, 22, 26)
	love.graphics.draw(arrow, 22, 55)
	love.graphics.pop()
	
	love.graphics.setCanvas()
	love.graphics.setColor(rgb("#ffffff")) 
end

function Bifurcate4Mod:move(dX, dY, inCables, outCables)
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
	
	if self.component:outCConnected() then
		self.outCCable:repositionStart(dX, dY)
	end
	
	if self.component:outDConnected() then
		self.outDCable:repositionStart(dX, dY)
	end
end

function Bifurcate4Mod:visible(xOffset, yOffset)
	return true
end

function Bifurcate4Mod:focus()
	self.isFocused = true
end

function Bifurcate4Mod:unfocus()
	self.isFocused = false
end

function Bifurcate4Mod:contains(x, y, gX, gY)
	local collision = inBounds(x, y, self.x + gX, self.y + gY, self.width, self.height)
	return collision
end

function Bifurcate4Mod:setInCable(cable)
	self.inCable = cable
	self.component:setInCable(cable)
end

function Bifurcate4Mod:setOutCable(cable)
	if self.component:outAConnected() == false then
		self.outACable = cable
		self.component:setOutACable(cable)
	elseif self.component:outBConnected() == false then
		self.outBCable = cable
		self.component:setOutBCable(cable)
	elseif self.component:outCConnected() == false then
		self.outCCable = cable
		self.component:setOutCCable(cable)
	elseif self.component:outDConnected() == false then
		self.outDCable = cable
		self.component:setOutDCable(cable)
	end

end

function Bifurcate4Mod:tryConnectGhostOut(x, y, gX, gY, ghostCable)
	if self.component:outAConnected() == false then
		ghostCable:setStart(self.x + self.socketOutAVector.x + gX, self.y + self.socketOutAVector.y + gY)
		ghostCable:setGhostSendConnected()
		return true
	elseif self.component:outBConnected() == false then
		ghostCable:setStart(self.x + self.socketOutBVector.x + gX, self.y + self.socketOutBVector.y + gY)
		ghostCable:setGhostSendConnected()
		return true
	elseif self.component:outCConnected() == false then
		ghostCable:setStart(self.x + self.socketOutCVector.x + gX, self.y + self.socketOutCVector.y + gY)
		ghostCable:setGhostSendConnected()
		return true
	elseif self.component:outDConnected() == false then
		ghostCable:setStart(self.x + self.socketOutDVector.x + gX, self.y + self.socketOutDVector.y + gY)
		ghostCable:setGhostSendConnected()
		return true
	end
	
	return false
end

function Bifurcate4Mod:tryConnectGhostIn(x, y, gX, gY, ghostCable)
	if self.component:inConnected() then
		return false
	else
		ghostCable:setEnd(self.x + self.socketInVector.x + gX, self.y + self.socketInVector.y + gY)
		ghostCable:setGhostReceiveConnected()
		return true
	end
end

function Bifurcate4Mod:update(deltaTime)
	if self.indicatorOn then
		self.onElapsed = self.onElapsed + deltaTime
		if self.onElapsed > 0.25 then
			self.indicatorOn = false
			self.onElapsed = 0
		end
	end
end

function Bifurcate4Mod:draw(xOffset, yOffset)
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

