require "modules/sequencers/timed_switch/timed_switch_com"

class('TimedSwitchMod').extends()

local modType = "TimedSwitchMod"
local modSubtype = "clock_router"

local pedal = love.graphics.newImage("images/pedal_rubber_small.png")

local measures = {
	{
		label = "m. 1",
		ticks = 4
	},
	{
		label = "m. 2",
		ticks = 8
	},
	{
		label = "m. 4",
		ticks = 16
	},
	{
		label = "m. 8",
		ticks = 32
	},
	{
		label = "m. 16",
		ticks = 64
	},
	{
		label = "m. 32",
		ticks = 128
	},
	{
		label = "m. 64",
		ticks = 256
	}
}

function TimedSwitchMod:init(x, y, modId)
	TimedSwitchMod.super.init()
	
	if modId == nil then
		self.modId = "TimedSwitchMod-" .. os.time() .. "_" .. math.random()
	else
		self.modId = modId
	end
	
	self.modType = modType
	
	self.indicatorOn = false
	self.onElapsed = 0
	
	self.isFocused = true
	
	self.component = TimedSwitchCom(function() 
		
	end, function() 
		--switch changed - redraw
		self:redrawCanvas()
	end)
	
	self.measureLabel = "m. 2"

	self.width = 100
	self.height = 100
		
	self.x = x - self.width/2
	self.y = y - 15
	
	self.socketInVector = Vector(16, self.height * 0.3333)
	self.socketOutAVector = Vector(self.width - 16, 16)
	self.socketOutBVector = Vector(self.width - 16, 43)
	
	self.isFocusedCanvas = moduleCanvas(Colours.focusColour, Colours.focusColour, self.width + 3, self.height + 3, 7)
		
	
	self:redrawCanvas()
end

function TimedSwitchMod:redrawCanvas()
	self.canvas = moduleCanvas({0.93, 0.87, 0.99}, Colours.defaultModBorder, self.width, self.height, 7)
	
	moduleSocket(self.canvas, self.socketInVector.x, self.socketInVector.y, Colours.black)
	moduleSocket(self.canvas, self.socketOutAVector.x, self.socketOutAVector.y, Colours.black)
	moduleSocket(self.canvas, self.socketOutBVector.x, self.socketOutBVector.y, Colours.black)
	
	love.graphics.setCanvas(self.canvas)
	love.graphics.push()
	love.graphics.draw(pedal, 5, 57)

	if self.component:getOpenSocket() == 1 then
		love.graphics.setColor(Colours.pedalOn) 
		love.graphics.circle('fill', self.socketOutAVector.x, self.socketOutAVector.y, 5)
		love.graphics.setColor(Colours.pedalOff) 
		love.graphics.circle('fill', self.socketOutBVector.x, self.socketOutBVector.y, 5)
	else
		love.graphics.setColor(Colours.pedalOn) 
		love.graphics.circle('fill', self.socketOutBVector.x, self.socketOutBVector.y, 5)
		love.graphics.setColor(Colours.pedalOff) 
		love.graphics.circle('fill', self.socketOutAVector.x, self.socketOutAVector.y, 5)
	end
	
	love.graphics.setColor(black()) 
	love.graphics.setLineWidth(1)	
	
	--draw synth category
	love.graphics.rectangle('line', 30, 20, self.width - 60, 24, 3)	
	love.graphics.printf(self.measureLabel, smallFont, self.width/2 - 50, 25, 100, 'center')
	
	love.graphics.pop()
	love.graphics.setCanvas()
	
	love.graphics.setColor(Colours.white) 
end

function TimedSwitchMod:click(x, y, gX, gY)
	if y > (self.y + gY + self.width/2) then
		self.component:toggle()
		self:redrawCanvas()
		return true
	else
		dropdown:show(self.x + gX, self.y + 30 + gY, self.width, measures, function(index) 
			self.component:setTicks(measures[index].ticks)
			self.measureLabel = measures[index].label
			self:redrawCanvas()
		end)
		return true
	end
end

function TimedSwitchMod:canScroll() 
	return true
end

function TimedSwitchMod:scroll(oX, oY, dX, dY, gX, gY)
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

function TimedSwitchMod:move(dX, dY)
	self.x = self.x + dX
	self.y = self.y + dY
end

function TimedSwitchMod:visible(xOffset, yOffset)
	return true
end

function TimedSwitchMod:focus()
	self.isFocused = true
end

function TimedSwitchMod:unfocus()
	self.isFocused = false
end

function TimedSwitchMod:contains(x, y, gX, gY)
	local collision = inBounds(x, y, self.x + gX, self.y + gY, self.width, self.height)
	return collision
end

function TimedSwitchMod:setInCable(cable)
	self.component:setInCable(cable)
end

function TimedSwitchMod:setOutCable(cable)
	if self.component:outAConnected() == false then
 		self.component:setOutACable(cable)
	elseif self.component:outBConnected() == false then
		self.component:setOutBCable(cable)
	end
end

function TimedSwitchMod:tryConnectGhostOut(x, y, gX, gY, ghostCable)
	if self.component:outAConnected() == false then
		ghostCable:setStart(self.x + self.socketOutAVector.x + gX, self.y + self.socketOutAVector.y + gY)
		ghostCable:setGhostSendConnected()
		return true
	elseif self.component:outBConnected() == false then
		ghostCable:setStart(self.x + self.socketOutBVector.x + gX, self.y + self.socketOutBVector.y + gY)
		ghostCable:setGhostSendConnected()
		return true
	end
	
	return false
end

function TimedSwitchMod:tryConnectGhostIn(x, y, gX, gY, ghostCable)
	if self.component:inConnected() then
		return false
	else
		ghostCable:setEnd(self.x + self.socketInVector.x + gX, self.y + self.socketInVector.y + gY)
		ghostCable:setGhostReceiveConnected()
		return true
	end
end

function TimedSwitchMod:update(deltaTime)
	if self.indicatorOn then
		self.onElapsed = self.onElapsed + deltaTime
		if self.onElapsed > 0.25 then
			self.indicatorOn = false
			self.onElapsed = 0
		end
	end
end

function TimedSwitchMod:draw(xOffset, yOffset)
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
			
		end
		
		love.graphics.setColor(white())
	end
end

