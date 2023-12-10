require "modules/effects/compressor/compressor_com"

class('CompressorMod').extends()

local modType = "CompressorMod"
local modSubtype = "audio"

local pedal = love.graphics.newImage("images/pedal_rubber.png")

function CompressorMod:init(x, y, modId)
	CompressorMod.super.init()
	
	if modId == nil then
		self.modId = "CompressorMod-" .. os.time() .. "_" .. math.random()
	else
		self.modId = modId
	end
	
	self.modType = modType
	
	self.indicatorOn = false
	self.onElapsed = 0
	
	self.isFocused = true
	
	self.component = CompressorCom(function() 
		
	end, self.modId)

	self.width = 100
	self.height = 165
		
	self.x = x - self.width/2
	self.y = y - 15
	
	self.socketInVector = Vector(16, 16)
	self.socketOutVector = Vector(self.width - 16, 16)
	
	self.isFocusedCanvas = moduleCanvas(Colours.focusColour, Colours.focusColour, self.width + 3, self.height + 3, 7)
	
	self.levelLabel = "" .. round(self.component:defaultVolume(), 2)
	self.normalisedVolume = self.component:normalisedDefaultVolume()
	self.volumeEncoder = Encoder(self.width/2 - 12, 40, 12, self.normalisedVolume, encoderColour, Colours.white, function(value) 
		local levelLabel = "" .. round(self.component:setNormalisedVolume(value), 2)
		if levelLabel ~= self.levelLabel then
			self.levelLabel = levelLabel
			self:redrawCanvas()
		end
	end)
		
	self:redrawCanvas()
end



function CompressorMod:redrawCanvas()
	self.canvas = moduleCanvas(Colours.compressorPedalBackground, Colours.defaultModBorder, self.width, self.height, 7)
	
	if self.volumeEncoder ~= nil then
		self.volumeEncoder:canvasDraw(self.canvas)
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
	love.graphics.printf(self.levelLabel, smallFont, self.width/2 - 30, 26, 60, 'center')
	love.graphics.printf("Level", tinyFont, self.width/2 - 30, 68, 60, 'center')
	
	love.graphics.pop()
	love.graphics.setCanvas()
	love.graphics.setColor(rgb("#ffffff")) 
	
	moduleSocket(self.canvas, self.socketOutVector.x, self.socketOutVector.y, Colours.black)
	moduleSocket(self.canvas, self.socketInVector.x, self.socketInVector.y, Colours.black)
end

function CompressorMod:click(x, y, gX, gY)
	if y > (self.y + gY + 85) then
		self.component:toggle()
		self:redrawCanvas()
		return true
	else
		return false
	end
end

function CompressorMod:canScroll() 
	return true
end

function CompressorMod:scroll(oX, oY, dX, dY, gX, gY)
	if oY < (self.y + gY + 85) then
		self.volumeEncoder:deltaXY(dX, dY)
		self.volumeEncoder:canvasDraw(self.canvas)
	end
end 

function CompressorMod:move(dX, dY)
	self.x = self.x + dX
	self.y = self.y + dY
end

function CompressorMod:visible(xOffset, yOffset)
	return true
end

function CompressorMod:focus()
	self.isFocused = true
end

function CompressorMod:unfocus()
	self.isFocused = false
end

function CompressorMod:contains(x, y, gX, gY)
	local collision = inBounds(x, y, self.x + gX, self.y + gY, self.width, self.height)
	return collision
end

function CompressorMod:setInCable(cable)
	self.component:setInCable(cable)
end

function CompressorMod:addToAudioSource(audioMod)
	self.component:applyEffect(audioMod)
end

function CompressorMod:setOutCable(cable)
	cable:setHostAudioModId(self.component:getAudioModId())
	self.component:setOutCable(cable)
end

function CompressorMod:tryConnectGhostOut(x, y, gX, gY, ghostCable)
	if self.component:outConnected() then
		return false
	else
		ghostCable:setStart(self.x + self.socketOutVector.x + gX, self.y + self.socketOutVector.y + gY)
		ghostCable:setGhostSendConnected()
		return true
	end
end

function CompressorMod:tryConnectGhostIn(x, y, gX, gY, ghostCable)
	if self.component:inConnected() then
		return false
	else
		ghostCable:setEnd(self.x + self.socketInVector.x + gX, self.y + self.socketInVector.y + gY)
		ghostCable:setGhostReceiveConnected()
		return true
	end
end

function CompressorMod:update(deltaTime)
	if self.indicatorOn then
		self.onElapsed = self.onElapsed + deltaTime
		if self.onElapsed > 0.25 then
			self.indicatorOn = false
			self.onElapsed = 0
		end
	end
end

function CompressorMod:draw(xOffset, yOffset)
	if self:visible(xOffset, yOffset) then
		if showLabels then
			love.graphics.printf("Compressor", self.x + (self.width/2) + xOffset - 50, self.y + yOffset - 20, 100, 'center')
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

