require "modules/effects/delay/delay_com"

class('DelayMod').extends()

local modType = "DelayMod"
local modSubtype = "audio"

local pedal = love.graphics.newImage("images/pedal_rubber.png")

function DelayMod:init(x, y, modId)
	DelayMod.super.init()
	
	if modId == nil then
		self.modId = "DelayMod-" .. os.time() .. "_" .. math.random()
	else
		self.modId = modId
	end
	
	self.modType = modType
	
	self.indicatorOn = false
	self.onElapsed = 0
	
	self.isFocused = true
	
	self.component = DelayCom(function() 
		
	end, self.modId)

	self.width = 100
	self.height = 165
		
	self.x = x - self.width/2
	self.y = y - 15
	
	self.socketInVector = Vector(16, 16)
	self.socketOutVector = Vector(self.width - 16, 16)
	
	self.isFocusedCanvas = moduleCanvas(Colours.focusColour, Colours.focusColour, self.width + 3, self.height + 3, 7)
		
	self.param1Label = "" .. round(self.component:defaultParam1(), 2)
	self.normalisedParam1 = self.component:normalisedDefaultParam1()
	self.param1Encoder = Encoder(6, 40, 12, self.normalisedParam1, encoderColour, Colours.white, function(value) 
		local param1Label = "" .. round(self.component:setNormalisedParam1(value), 2)
		if param1Label ~= self.param1Label then
			self.param1Label = param1Label
			self:redrawCanvas()
		end
	end)
	
	self.param2Label = "" .. round(self.component:defaultParam2(), 2)
	self.normalisedParam2 = self.component:normalisedDefaultParam2()
	self.param2Encoder = Encoder(self.width/2 - 12, 40, 12, self.normalisedParam2, encoderColour, Colours.white, function(value) 
		local param2Label = "" .. round(self.component:setNormalisedParam2(value), 2)
		if param2Label ~= self.param2Label then
			self.param2Label = param2Label
			self:redrawCanvas()
		end
	end)
	
	self.param3Label = "" .. round(self.component:defaultParam3(), 2)
	self.normalisedParam3 = self.component:normalisedDefaultParam3()
	self.param3Encoder = Encoder(70, 40, 12, self.normalisedParam3, encoderColour, Colours.white, function(value) 
		local param3Label = "" .. round(self.component:setNormalisedParam3(value), 2)
		if param3Label ~= self.param3Label then
			self.param3Label = param3Label
			self:redrawCanvas()
		end
	end)

	self:redrawCanvas()
end

function DelayMod:redrawCanvas()
	self.canvas = moduleCanvas(Colours.delayPedalBackground, Colours.defaultModBorder, self.width, self.height, 7)
	
	if self.param1Encoder ~= nil then
		self.param1Encoder:canvasDraw(self.canvas)
	end
	
	if self.param2Encoder ~= nil then
		self.param2Encoder:canvasDraw(self.canvas)
	end
	
	if self.param3Encoder ~= nil then
		self.param3Encoder:canvasDraw(self.canvas)
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
	love.graphics.printf(self.param1Label, smallFont, 18 - 30, 26, 60, 'center')
	love.graphics.printf("Delay", tinyFont, 18 - 30, 68, 60, 'center')
	
	--depth - right
	love.graphics.printf(self.param2Label, smallFont, self.width/2 - 30, 26, 60, 'center')
	love.graphics.printf("Tap", tinyFont, self.width/2 - 30, 68, 60, 'center')
	
	--param 3
	love.graphics.printf(self.param3Label, smallFont, 84 - 30, 26, 60, 'center')
	love.graphics.printf("F.back", tinyFont, 84 - 30, 68, 60, 'center')
	
	love.graphics.pop()
	love.graphics.setCanvas()
	love.graphics.setColor(rgb("#ffffff")) 
	
	moduleSocket(self.canvas, self.socketOutVector.x, self.socketOutVector.y)
	moduleSocket(self.canvas, self.socketInVector.x, self.socketInVector.y)
end

function DelayMod:click(x, y, gX, gY)
	if y > (self.y + gY + 85) then
		self.component:toggle()
		self:redrawCanvas()
		return true
	else
		return false
	end
end

function DelayMod:canScroll() 
	return true
end

function DelayMod:scroll(oX, oY, dX, dY, gX, gY)
	if oY < (self.y + gY + 80) then
		if oX > (self.x + gX + self.width/3) and oX < (self.x + gX + (self.width/3 * 2)) then
			--middle
			self.param2Encoder:deltaXY(dX, dY)
			self.param2Encoder:canvasDraw(self.canvas)

		elseif oX < (self.x + gX + self.width/3) then
			--left
			self.param1Encoder:deltaXY(dX, dY)
			self.param1Encoder:canvasDraw(self.canvas)
		else
			--right
			self.param3Encoder:deltaXY(dX, dY)
			self.param3Encoder:canvasDraw(self.canvas)
		end
	end
end 


function DelayMod:move(dX, dY)
	self.x = self.x + dX
	self.y = self.y + dY
end

function DelayMod:visible(xOffset, yOffset)
	return true
end

function DelayMod:focus()
	self.isFocused = true
end

function DelayMod:unfocus()
	self.isFocused = false
end

function DelayMod:contains(x, y, gX, gY)
	local collision = inBounds(x, y, self.x + gX, self.y + gY, self.width, self.height)
	return collision
end

function DelayMod:setInCable(cable)
	self.component:setInCable(cable)
end

function DelayMod:addToAudioSource(audioMod)
	self.component:applyEffect(audioMod)
end

function DelayMod:setOutCable(cable)
	cable:setHostAudioModId(self.component:getAudioModId())
	self.component:setOutCable(cable)
end

function DelayMod:tryConnectGhostOut(x, y, gX, gY, ghostCable)
	if self.component:outConnected() then
		return false
	else
		ghostCable:setStart(self.x + self.socketOutVector.x + gX, self.y + self.socketOutVector.y + gY)
		ghostCable:setGhostSendConnected()
		return true
	end
end

function DelayMod:tryConnectGhostIn(x, y, gX, gY, ghostCable)
	if self.component:inConnected() then
		return false
	else
		ghostCable:setEnd(self.x + self.socketInVector.x + gX, self.y + self.socketInVector.y + gY)
		ghostCable:setGhostReceiveConnected()
		return true
	end
end

function DelayMod:update(deltaTime)
	if self.indicatorOn then
		self.onElapsed = self.onElapsed + deltaTime
		if self.onElapsed > 0.25 then
			self.indicatorOn = false
			self.onElapsed = 0
		end
	end
end

function DelayMod:draw(xOffset, yOffset)
	if self:visible(xOffset, yOffset) then
		if showLabels then
			love.graphics.printf("Delay", self.x + (self.width/2) + xOffset - 50, self.y + yOffset - 20, 100, 'center')
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

