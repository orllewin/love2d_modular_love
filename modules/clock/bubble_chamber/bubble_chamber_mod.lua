require "coracle/vector"
require "modules/clock/bubble_chamber/bubble_chamber_com"

class('BubbleChamberMod').extends()

local modType = "BubbleChamberMod"
local modSubtype = "clock_router"

function BubbleChamberMod:init(x, y, modId)
	BubbleChamberMod.super.init()
	
	if modId == nil then
		self.modId = "BubbleChamberMod-" .. os.time() .. "_" .. math.random()
	else
		self.modId = modId
	end

	self.molecules = {}
	
	self.width = 100
	self.boxHeight = 100
	self.height = 156
	
	self.velocity = 1.0
	
	table.insert(self.molecules, {
		location = Vector(math.random(20, self.width - 20), math.random(20, self.boxHeight - 20)),
		direction = Vector(math.random(), math.random()),
		velocity = self.velocity,
		colour = randomDarkPastel()
	})
	
	self.modType = modType
		
	self.isFocused = true
	
	self.component = BubbleChamberCom()
	
	self.x = x - self.width/2
	self.y = y - 15
	
	self.isFocusedCanvas = moduleCanvas(Colours.focusColour, Colours.focusColour, self.width + 3, self.height + 3, 7)
	
	self.socketOutVector = Vector(self.width - 12, self.height - 32)
	
	self.moleculeCountEncoder = Encoder(8, 110, 12, 0.1, encoderColour, Colours.white, function(value) 
		local moleculeCount = math.floor(value * 10)
		for k,v in pairs(self.molecules) do self.molecules[k]=nil end
		if moleculeCount > 0 then
			for i=1, moleculeCount do
				table.insert(self.molecules, {
					location = Vector(math.random(20, self.width - 20), math.random(20, self.boxHeight - 20)),
					direction = Vector(math.random(), math.random()),
					velocity = self.velocity,
					colour = randomMolecule()
				})
			end
			
			self:redrawCanvas()
		end
	end)
	
	self.velocityEncoder = Encoder(43, 110, 12, 0.5, encoderColour, Colours.white, function(value) 
		self.velocity = map(value, 0.0, 1.0, 0.1, 3.0)
		self:redrawCanvas()
	end)

	self:redrawCanvas()
	self.moleculeCountEncoder:canvasDraw(self.canvas)
	self.velocityEncoder:canvasDraw(self.canvas)
end

function BubbleChamberMod:redrawCanvas()
	self.canvas = moduleCanvas(Colours.defaultModBackground, Colours.defaultModBorder, self.width, self.height, 7)
	
	love.graphics.setCanvas(self.canvas)
	love.graphics.push()
	
	love.graphics.setLineWidth(1)
	love.graphics.setColor(rgb("#888888")) 
	love.graphics.line(5, self.boxHeight, self.width - 5, self.boxHeight)
	
	love.graphics.setColor(Colours.black) 
	love.graphics.printf("Count", tinyFont, 21 - 30, 140, 60, 'center')
	love.graphics.printf("Velocity", tinyFont, 56 - 30, 140, 60, 'center')

	love.graphics.pop()
	love.graphics.setCanvas()
	love.graphics.setLineWidth(1)
	love.graphics.setColor(white()) 
	
	moduleSocket(self.canvas, self.socketOutVector.x, self.socketOutVector.y)
	
	if self.moleculeCountEncoder ~= nil then
		self.moleculeCountEncoder:canvasDraw(self.canvas)
	end
	if self.velocityEncoder ~= nil then
		self.velocityEncoder:canvasDraw(self.canvas)
	end
end

function BangIndicatorMod:move(dX, dY, inCables, outCables)
	self.x = self.x + dX
	self.y = self.y + dY
	
	if self.component:outConnected() then
		self.outCable:repositionStart(dX, dY)
	end
end

function BubbleChamberMod:canScroll() 
	return true
end

function BubbleChamberMod:scroll(oX, oY, dX, dY, gX, gY)
	if oX < (self.x + gX + self.width/3) then
		self.moleculeCountEncoder:delta(dY)
	else
		self.velocityEncoder:delta(dY)
	end
end 

function BubbleChamberMod:visible(xOffset, yOffset)
	return true
end

function BubbleChamberMod:focus()
	self.isFocused = true
end

function BubbleChamberMod:unfocus()
	self.isFocused = false
end

function BubbleChamberMod:contains(x, y, gX, gY)
	local collision = inBounds(x, y, self.x + gX, self.y + gY, self.width, self.height)
	return collision
end

function BubbleChamberMod:setOutCable(cable)
	self.outCable = cable
	self.component:setOutCable(cable)
end

function BubbleChamberMod:tryConnectGhostOut(x, y, gX, gY, ghostCable)
	if self.component:outConnected() then
		return false
	else
		ghostCable:setStart(self.x + self.socketOutVector.x + gX, self.y + self.socketOutVector.y + gY)
		ghostCable:setGhostSendConnected()
		return true
	end
end

function BubbleChamberMod:tryConnectGhostIn(x, y, gX, gY, ghostCable)
	return false
end

function BubbleChamberMod:update(deltaTime)
	if self.indicatorOn then
		self.onElapsed = self.onElapsed + deltaTime
		if self.onElapsed > 0.25 then
			self.indicatorOn = false
			self.onElapsed = 0
		end
	end
end

function BubbleChamberMod:draw(xOffset, yOffset)
	if self:visible(xOffset, yOffset) then
		if showLabels then
			love.graphics.printf("Bubble Chamber", self.x + (self.width/2) + xOffset - 70, self.y + yOffset - 20, 140, 'center')
		end
		if self.isFocused then
			love.graphics.draw(self.isFocusedCanvas, self.x + xOffset - 1, self.y + yOffset - 1)
		end
		
		love.graphics.draw(self.canvas, self.x + xOffset, self.y + yOffset)
		
		
		for i=1,#self.molecules do
			local molecule = self.molecules[i]
			love.graphics.setColor(molecule.colour)
			molecule.location.x = molecule.location.x + (self.velocity * molecule.direction.x)
			molecule.location.y = molecule.location.y + (self.velocity * molecule.direction.y)
			if molecule.location.x >= (self.width) - 5 then
				molecule.direction.x = molecule.direction.x * -1
				self.component:emit()
			elseif molecule.location.x <= 0 + 5 then
				molecule.direction.x = molecule.direction.x * -1
				self.component:emit()
			end
			
			if molecule.location.y >= (self.boxHeight) - 5 then
				molecule.direction.y = molecule.direction.y * -1
				self.component:emit()
			elseif molecule.location.y <= 0 + 5 then
				molecule.direction.y = molecule.direction.y * -1
				self.component:emit()
			end
			love.graphics.circle('fill', self.x + xOffset + molecule.location.x, self.y + yOffset + molecule.location.y, 6)
		 end
		 love.graphics.setColor(white())
	end
end

