require "modules/effects/chorus/chorus_com"

class('ChorusMod').extends()

local modType = "ChorusMod"
local modSubtype = "clock_router"

local pedal = love.graphics.newImage("images/pedal_rubber.png")

function ChorusMod:init(x, y, modId)
	ChorusMod.super.init()
	
	if modId == nil then
		self.modId = "ChorusMod-" .. os.time() .. "_" .. math.random()
	else
		self.modId = modId
	end
	
	self.modType = modType
	
	self.indicatorOn = false
	self.onElapsed = 0
	
	self.isFocused = true
	
	self.component = ChorusCom(function() 
		
	end, self.modId)

	self.width = 100
	self.height = 165
		
	self.x = x - self.width/2
	self.y = y - 15
	
	self.socketInVector = Vector(16, 16)
	self.socketOutVector = Vector(self.width - 16, 16)
	
	self.isFocusedCanvas = moduleCanvas(Colours.focusColour, Colours.focusColour, self.width + 3, self.height + 3, 7)
		
	self.rateLabel = "" .. round(self.component:defaultRate(), 2) .. "Hz"
	self.normalisedRate = self.component:normalisedDefaultRate()
	self.rateEncoder = Encoder(self.width/2 - 36, 40, 12, self.normalisedRate, encoderColour, Colours.white, function(value) 
		local rateLabel = "" .. round(self.component:setNormalisedRate(value), 2) .. "Hz"
		if rateLabel ~= self.rateLabel then
			self.rateLabel = rateLabel
			self:redrawCanvas()
		end
	end)
	
	self.depthLabel = "" .. round(self.component:defaultDepth(), 2)
	self.normalisedDepth = self.component:normalisedDefaultDepth()
	self.depthEncoder = Encoder(self.width/2 + 12, 40, 12, self.normalisedDepth, encoderColour, Colours.white, function(value) 
		local depthLabel = "" .. round(self.component:setNormalisedDepth(value), 2)
		if depthLabel ~= self.depthLabel then
			self.depthLabel = depthLabel
			self:redrawCanvas()
		end
	end)

	self:redrawCanvas()
end

function ChorusMod:redrawCanvas()
	self.canvas = moduleCanvas(Colours.chorusPedalBackground, Colours.defaultModBorder, self.width, self.height, 7)
	
	if self.rateEncoder ~= nil then
		self.rateEncoder:canvasDraw(self.canvas)
	end
	
	if self.depthEncoder ~= nil then
		self.depthEncoder:canvasDraw(self.canvas)
	end
	
	love.graphics.setCanvas(self.canvas)
	love.graphics.push()
	love.graphics.draw(pedal, 5, 85)
	
	if self.component:isOn() then
		love.graphics.setColor(Colours.pedalOn) 
		love.graphics.circle('fill', self.width/2, 16, 5)
	else
		love.graphics.setColor(Colours.pedalOff) 
		love.graphics.circle('fill', self.width/2, 16, 5)
	end
	
	love.graphics.setColor(Colours.black) 
	
	--rate - left
	love.graphics.printf(self.rateLabel, smallFont, 28 - 30, 26, 60, 'center')
	love.graphics.printf("Rate", tinyFont, 26 - 30, 68, 60, 'center')
	
	--depth - right
	love.graphics.printf(self.depthLabel, smallFont, 75 - 30, 26, 60, 'center')
	love.graphics.printf("Depth", tinyFont, 75 - 30, 68, 60, 'center')
	
	love.graphics.pop()
	love.graphics.setCanvas()
	love.graphics.setColor(rgb("#ffffff")) 
	
	moduleSocket(self.canvas, self.socketOutVector.x, self.socketOutVector.y, Colours.black)
	moduleSocket(self.canvas, self.socketInVector.x, self.socketInVector.y, Colours.black)
end

function ChorusMod:click(x, y, gX, gY)
	if y > (self.y + gY + 85) then
		self.component:toggle()
		self:redrawCanvas()
		return true
	else
		return false
	end
end

function ChorusMod:canScroll() 
	return true
end

function ChorusMod:scroll(oX, oY, dX, dY, gX, gY)
	if oY < (self.y + gY + 80) then
		if oX < (self.x + gX + self.width/2) then
			--left
			self.rateEncoder:deltaXY(dX, dY)
			self.rateEncoder:canvasDraw(self.canvas)
		else
			--right
			self.depthEncoder:deltaXY(dX, dY)
			self.depthEncoder:canvasDraw(self.canvas)
		end
	end
end 

function ChorusMod:move(dX, dY)
	self.x = self.x + dX
	self.y = self.y + dY
end

function ChorusMod:visible(xOffset, yOffset)
	return true
end

function ChorusMod:focus()
	self.isFocused = true
end

function ChorusMod:unfocus()
	self.isFocused = false
end

function ChorusMod:contains(x, y, gX, gY)
	local collision = inBounds(x, y, self.x + gX, self.y + gY, self.width, self.height)
	return collision
end

function ChorusMod:setInCable(cable)
	self.component:setInCable(cable)
end

function ChorusMod:addToAudioSource(audioMod)
	self.component:applyEffect(audioMod)
end

function ChorusMod:setOutCable(cable)
	cable:setHostAudioModId(self.component:getAudioModId())
	self.component:setOutCable(cable)
end

function ChorusMod:tryConnectGhostOut(x, y, gX, gY, ghostCable)
	if self.component:outConnected() then
		return false
	else
		ghostCable:setStart(self.x + self.socketOutVector.x + gX, self.y + self.socketOutVector.y + gY)
		ghostCable:setGhostSendConnected()
		return true
	end
end

function ChorusMod:tryConnectGhostIn(x, y, gX, gY, ghostCable)
	if self.component:inConnected() then
		return false
	else
		ghostCable:setEnd(self.x + self.socketInVector.x + gX, self.y + self.socketInVector.y + gY)
		ghostCable:setGhostReceiveConnected()
		return true
	end
end

function ChorusMod:update(deltaTime)
	if self.indicatorOn then
		self.onElapsed = self.onElapsed + deltaTime
		if self.onElapsed > 0.25 then
			self.indicatorOn = false
			self.onElapsed = 0
		end
	end
end

function ChorusMod:draw(xOffset, yOffset)
	if self:visible(xOffset, yOffset) then
		if showLabels then
			love.graphics.printf("Chorus", self.x + (self.width/2) + xOffset - 50, self.y + yOffset - 20, 100, 'center')
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

