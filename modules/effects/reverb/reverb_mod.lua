require "modules/effects/reverb/reverb_com"

class('ReverbMod').extends()

local modType = "ReverbMod"
local modSubtype = "clock_router"

local pedal = love.graphics.newImage("images/pedal_rubber.png")

function ReverbMod:init(x, y, modId)
	ReverbMod.super.init()
	
	if modId == nil then
		self.modId = "ReverbMod-" .. os.time() .. "_" .. math.random()
	else
		self.modId = modId
	end
	
	self.modType = modType
	
	self.indicatorOn = false
	self.onElapsed = 0
	
	self.isFocused = true
	
	self.component = ReverbCom(function() 
		self.indicatorOn = true
		self.onElapsed = 0
	end, self.modId)

	self.width = 100
	self.height = 165
		
	self.x = x - self.width/2
	self.y = y - 15
	
	self.socketInVector = Vector(16, 16)
	self.socketOutVector = Vector(self.width - 16, 16)
	
	self.isFocusedCanvas = moduleCanvas(Colours.focusColour, Colours.focusColour, self.width + 3, self.height + 3, 7)
		
	self.densityLabel = "" .. round(self.component:defaultDensity(), 2)
	self.normalisedDensity = self.component:normalisedDefaultDensity()
	self.densityEncoder = Encoder(6, 40, 12, self.normalisedDensity, encoderColour, Colours.white, function(value) 
		local densityLabel = "" .. round(self.component:setNormalisedDensity(value), 2)
		if densityLabel ~= self.densityLabel then
			self.densityLabel = densityLabel
			self:redrawCanvas()
		end
	end)
	
	self.decayTimeLabel = "" .. round(self.component:defaultDecayTime(), 1) .. "s"
	self.normalisedDecayTime = self.component:normalisedDefaultDecayTime()
	self.decayTimeEncoder = Encoder(self.width/2 - 12, 40, 12, self.normalisedDecayTime, encoderColour, Colours.white, function(value) 
		local decayTimeLabel = "" .. round(self.component:setNormalisedDecayTime(value), 1) .. "s"
		if decayTimeLabel ~= self.decayTimeLabel then
			self.decayTimeLabel = decayTimeLabel
			self:redrawCanvas()
		end
	end)
	
	self.diffusionLabel = "" .. round(self.component:defaultDiffusion(), 2)
	self.normalisedDiffusion = self.component:normalisedDefaultDiffusion()
	self.diffusionEncoder = Encoder(70, 40, 12, self.normalisedDiffusion, encoderColour, Colours.white, function(value)
		local diffusionLabel = "" .. round(self.component:setNormalisedDiffusion(value), 2)
		if diffusionLabel ~= self.diffusionLabel then
			self.diffusionLabel = diffusionLabel
			self:redrawCanvas()
		end
	end)
	
	self:redrawCanvas()
end

function ReverbMod:redrawCanvas()
	self.canvas = moduleCanvas(Colours.defaultModBackground, Colours.defaultModBorder, self.width, self.height, 7)
	if self.decayTimeEncoder ~= nil then
		self.decayTimeEncoder:canvasDraw(self.canvas)
	end
	
	if self.densityEncoder ~= nil then
		self.densityEncoder:canvasDraw(self.canvas)
	end
	
	if self.diffusionEncoder ~= nil then
		self.diffusionEncoder:canvasDraw(self.canvas)
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
	
	--Density - left
	love.graphics.printf(self.densityLabel, smallFont, 18 - 30, 26, 60, 'center')
	love.graphics.printf("Dens.", tinyFont, 18 - 30, 68, 60, 'center')
	
	--Decay Time - middle
	love.graphics.printf(self.decayTimeLabel, smallFont, self.width/2 - 30, 26, 60, 'center')
	love.graphics.printf("Decay", tinyFont, self.width/2 - 30, 68, 60, 'center')
	
	--Diffusion - right
	love.graphics.printf(self.diffusionLabel, smallFont, 84 - 30, 26, 60, 'center')
	love.graphics.printf("Diff.", tinyFont, 84 - 30, 68, 60, 'center')
	
	love.graphics.pop()
	love.graphics.setCanvas()
	love.graphics.setColor(rgb("#ffffff")) 
	
	moduleSocket(self.canvas, self.socketOutVector.x, self.socketOutVector.y, Colours.black)
	moduleSocket(self.canvas, self.socketInVector.x, self.socketInVector.y, Colours.black)
end

function ReverbMod:click(x, y, gX, gY)
	if y > (self.y + gY + 85) then
		self.component:toggle()
		self:redrawCanvas()
		return true
	else
		return false
	end
end

function ReverbMod:canScroll() 
	return true
end

function ReverbMod:scroll(oX, oY, dX, dY, gX, gY)
	if oY < (self.y + gY + 80) then
		if oX > (self.x + gX + self.width/3) and oX < (self.x + gX + (self.width/3 * 2)) then
			--middle
			self.decayTimeEncoder:deltaXY(dX, dY)
			self.decayTimeEncoder:canvasDraw(self.canvas)
		elseif oX < (self.x + gX + self.width/3) then
			--left
			self.densityEncoder:deltaXY(dX, dY)
			self.densityEncoder:canvasDraw(self.canvas)
		else
			--right
			self.diffusionEncoder:deltaXY(dX, dY)
			self.diffusionEncoder:canvasDraw(self.canvas)
		end
	end
end 


function ReverbMod:move(dX, dY)
	self.x = self.x + dX
	self.y = self.y + dY
end

function ReverbMod:visible(xOffset, yOffset)
	return true
end

function ReverbMod:focus()
	self.isFocused = true
end

function ReverbMod:unfocus()
	self.isFocused = false
end

function ReverbMod:contains(x, y, gX, gY)
	local collision = inBounds(x, y, self.x + gX, self.y + gY, self.width, self.height)
	return collision
end

function ReverbMod:setInCable(cable)
	self.component:setInCable(cable)
end

function ReverbMod:addToAudioSource(audioMod)
	self.component:applyEffect(audioMod)
end

function ReverbMod:setOutCable(cable)
	cable:setHostAudioModId(self.component:getAudioModId())
	self.component:setOutCable(cable)
end

function ReverbMod:tryConnectGhostOut(x, y, gX, gY, ghostCable)
	if self.component:outConnected() then
		return false
	else
		ghostCable:setStart(self.x + self.socketOutVector.x + gX, self.y + self.socketOutVector.y + gY)
		ghostCable:setGhostSendConnected()
		return true
	end
end

function ReverbMod:tryConnectGhostIn(x, y, gX, gY, ghostCable)
	if self.component:inConnected() then
		return false
	else
		ghostCable:setEnd(self.x + self.socketInVector.x + gX, self.y + self.socketInVector.y + gY)
		ghostCable:setGhostReceiveConnected()
		return true
	end
end

function ReverbMod:update(deltaTime)
	if self.indicatorOn then
		self.onElapsed = self.onElapsed + deltaTime
		if self.onElapsed > 0.25 then
			self.indicatorOn = false
			self.onElapsed = 0
		end
	end
end

function ReverbMod:draw(xOffset, yOffset)
	if self:visible(xOffset, yOffset) then
		if showLabels then
			love.graphics.printf("Reverb", self.x + (self.width/2) + xOffset - 50, self.y + yOffset - 20, 100, 'center')
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

