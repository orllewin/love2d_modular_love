require "modules/sequencers/generative_std/generative_std_com"

class('GenerativeStdMod').extends()

local modType = "GenerativeStdMod"
local modSubtype = "midi"

function GenerativeStdMod:init(x, y, modId)
	GenerativeStdMod.super.init()
	
	if modId == nil then
		self.modId = "GenerativeStdMod-" .. os.time() .. "_" .. math.random()
	else
		self.modId = modId
	end
	
	self.modType = modType
	

	self.isFocused = true
	
	self.component = GenerativeStdCom(function() 
	end)

	self.width = 110
	self.height = 185
	
	self.x = x - self.width/2
	self.y = y - 15
	
	self.isFocusedCanvas = moduleCanvas(Colours.focusColour, Colours.focusColour, self.width + 3, self.height + 3, 7)
	
	self.socketInVector = Vector(16, self.height - 16)
	self.socketOutVector = Vector(self.width - 16, self.height - 16)
	
	self.keyIndex = 1
	self.clockDelayLabel = "Off"
	self.blackholeLabel = "25N"
	self.keyLabel = "C"
	self.scaleLabel = "Pentatonic Maj"
	
	self.clockDelayEncoder = Encoder(8, 20, 12, 0.0, encoderColour, Colours.white, function(value) 
		local clockDelayLabel = self.component:setClockDelay(value)
		if clockDelayLabel ~= self.clockDelayLabel then
			self.clockDelayLabel = clockDelayLabel
			self:redrawCanvas()
		end
	end)
	
	
	self.blackholeEncoder = Encoder(43, 20, 12, 0.0, encoderColour, Colours.white, function(value) 
		self.component:setBlackholeGravity(value)
		local blackholeLabel = "" .. (math.floor(value * 100)) .. "N" 
		if blackholeLabel ~= self.blackholeLabel then
			self.blackholeLabel = blackholeLabel
			self:redrawCanvas()
		end
	end)
	
	local encoderY2 = 86
	self.keyEncoder = Encoder(8, encoderY2, 12, 0.0, encoderColour, Colours.white, function(value) 
		local keyLabel = self.component:setKey(value)
		if keyLabel ~= nil then
			if keyLabel ~= self.keyLabel then
				self.keyLabel = keyLabel
				self:redrawCanvas()
			end
		end
	end)
	
	self.lowEncoder = Encoder(43, encoderY2, 12, 0.25, encoderColour, Colours.white, function(value) 
		self.component:setLowNoteNormal(value)
	end)
	
	self.highEncoder = Encoder(78, encoderY2, 12, 0.66, encoderColour, Colours.white, function(value) 
		self.component:setHighNoteNormal(value)
	end)

	self:redrawCanvas()
	
end

function GenerativeStdMod:redrawCanvas()
	self.canvas = moduleCanvas(Colours.defaultModBackground, Colours.defaultModBorder, self.width, self.height, 7)
	
	if self.clockDelayEncoder ~= nil then
		self.clockDelayEncoder:canvasDraw(self.canvas)
	end
	
	if self.blackholeEncoder ~= nil then
		self.blackholeEncoder:canvasDraw(self.canvas)
	end
	
	if self.keyEncoder ~= nil then
		self.keyEncoder:canvasDraw(self.canvas)
	end
	
	if self.lowEncoder ~= nil then
		self.lowEncoder:canvasDraw(self.canvas)
	end
	
	if self.highEncoder ~= nil then
		self.highEncoder:canvasDraw(self.canvas)
	end
	
	moduleSocket(self.canvas, self.socketInVector.x, self.socketInVector.y)
	moduleSocket(self.canvas, self.socketOutVector.x, self.socketOutVector.y)
	
	love.graphics.setCanvas(self.canvas)
	love.graphics.push()
	love.graphics.setColor(Colours.black) 
	
	love.graphics.printf(self.clockDelayLabel, smallFont, 21 - 30, 3, 60, 'center')
	love.graphics.printf("Delay", tinyFont, 21 - 30, 48, 60, 'center')
	
	love.graphics.printf(self.blackholeLabel, smallFont, 56 - 30, 3, 60, 'center')
	love.graphics.printf("Gravity", tinyFont, 56 - 30, 48, 60, 'center')
	
	love.graphics.setColor(rgb("#aaaaaa")) 
	love.graphics.line(7, 66, self.width - 7, 66)
	
	love.graphics.setColor(black()) 
	
	love.graphics.printf(self.keyLabel, smallFont, 21 - 30, 70, 60, 'center')
	
	local r2y = 113
	love.graphics.printf("Key", tinyFont, 21 - 30, r2y, 60, 'center')
	love.graphics.printf("Low", tinyFont, 56 - 30, r2y, 60, 'center')
	love.graphics.printf("High", tinyFont, 91 - 30, r2y, 60, 'center')
	
	--draw scale
	love.graphics.rectangle('line', 5, 130, self.width - 10, 24, 3)	
	love.graphics.printf(self.scaleLabel, smallFont, self.width/2 - 50, 135, 100, 'center')
	
	love.graphics.pop()
	
	love.graphics.setCanvas()
	love.graphics.setColor(rgb("#ffffff")) 
end

function GenerativeStdMod:canScroll() 
	return true
end

function GenerativeStdMod:click(x, y, gX, gY)
	if y > (self.y + gY + 128) then
		dropdown:show(self.x + gX, self.y + 120 + gY, self.width, self.component:getScales(), function(index) 
			self.scaleLabel = self.component:getScales()[index].label
			self.component:setScaleIndex(index)
			self:redrawCanvas()
		end)
		return true
	end
	
	return false
end

function GenerativeStdMod:move(dX, dY)
	self.x = self.x + dX
	self.y = self.y + dY
end

function GenerativeStdMod:scroll(oX, oY, dX, dY, gX, gY)
	if oY < (self.y + gY + 66) then
		--top row
		if oX < (self.x + gX + self.width/3) then
			self.clockDelayEncoder:deltaXY(dX, dY)
			self.clockDelayEncoder:canvasDraw(self.canvas)
		elseif oX < (self.x + gX + (self.width/3 * 2)) then
			self.blackholeEncoder:deltaXY(dX, dY)
			self.blackholeEncoder:canvasDraw(self.canvas)
		end
	elseif oY < (self.y + gY + 120) then
		--middle row
		if oX < (self.x + gX + self.width/3) then
			self.keyEncoder:deltaXY(dX, dY)
			self.keyEncoder:canvasDraw(self.canvas)
		elseif oX < (self.x + gX + (self.width/3 * 2)) then
			self.lowEncoder:deltaXY(dX, dY)
			self.lowEncoder:canvasDraw(self.canvas)
		else
			self.highEncoder:deltaXY(dX, dY)
			self.highEncoder:canvasDraw(self.canvas)
		end
	end
end 

function GenerativeStdMod:visible(xOffset, yOffset)
	return true
end

function GenerativeStdMod:focus()
	self.isFocused = true
end

function GenerativeStdMod:unfocus()
	self.isFocused = false
end

function GenerativeStdMod:contains(x, y, gX, gY)
	local collision = inBounds(x, y, self.x + gX, self.y + gY, self.width, self.height)
	return collision
end

function GenerativeStdMod:setInCable(cable)
	self.component:setInCable(cable)
end

function GenerativeStdMod:setOutCable(cable)
	self.component:setOutCable(cable)
end

function GenerativeStdMod:tryConnectGhostOut(x, y, gX, gY, ghostCable)
	if self.component:outConnected() then
		return false
	else
		ghostCable:setStart(self.x + self.socketOutVector.x + gX, self.y + self.socketOutVector.y + gY)
		ghostCable:setGhostSendConnected()
		return true
	end
end

function GenerativeStdMod:tryConnectGhostIn(x, y, gX, gY, ghostCable)
	if self.component:inConnected() then
		return false
	else
		ghostCable:setEnd(self.x + self.socketInVector.x + gX, self.y + self.socketInVector.y + gY)
		ghostCable:setGhostReceiveConnected()
		return true
	end
end

function GenerativeStdMod:update(deltaTime)
	self.component:update(deltaTime)
end

function GenerativeStdMod:draw(xOffset, yOffset)
	if self:visible(xOffset, yOffset) then
		if showLabels then
			love.graphics.printf("Generative", self.x + (self.width/2) + xOffset - 50, self.y + yOffset - 20, 100, 'center')
		end
		if self.isFocused then
			love.graphics.draw(self.isFocusedCanvas, self.x + xOffset - 1, self.y + yOffset - 1)
		end
		love.graphics.draw(self.canvas, self.x + xOffset, self.y + yOffset)
	end
end

