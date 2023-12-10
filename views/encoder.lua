class('Encoder').extends()

function Encoder:init(x, y, r, value, bgColour, fgColour, listener)
	Encoder.super.init()
	
	self.x = x
	self.y = y
	self.r = r
	self.width = r * 2
	self.height = r * 2
	self.value = value
	self.bgColour = bgColour
	self.fgColour = fgColour
	self.listener = listener
		
	self:redrawCanvas()
	
end

function Encoder:canvasDraw(canvas)
	love.graphics.setCanvas(canvas)
	love.graphics.push()
	love.graphics.draw(self.canvas, self.x, self.y)
	love.graphics.pop()
	love.graphics.setCanvas()
	love.graphics.setColor(Colours.white) 
end

function Encoder:redrawCanvas()
	self.canvas = love.graphics.newCanvas(self.width, self.height)
	love.graphics.setCanvas(self.canvas)
	love.graphics.push()
	
	love.graphics.translate(self.r, self.r)
	love.graphics.rotate(map(self.value, 0.0, 1.0, 0.0, 4.71239) - 1.5708)
	love.graphics.translate(-self.r, -self.r)
	
	love.graphics.setColor(self.bgColour) 
	love.graphics.circle('fill', self.r, self.r, self.r)
	
	love.graphics.setColor(self.fgColour) 
	love.graphics.setLineWidth(4)
	love.graphics.line(4, 4, self.r, self.r)

	love.graphics.pop()

	love.graphics.setCanvas()
	love.graphics.setLineWidth(1)
	love.graphics.setColor(Colours.white) 
	if self.listener ~= nil then self.listener(self.value) end
end

function Encoder:getCanvas()
	return self.canvas
end

function Encoder:deltaXY(dX, dY)
	if math.abs(dX) > math.abs(dY) then
		self:delta(dX * -1)
	else
		self:delta(dY)
	end
end

function Encoder:delta(change)
	if change > 0 then
		self:dec(change)
	elseif change < 0 then
		self:inc(change)
	end
end

function Encoder:inc()
	self.value = self.value + 0.025
	if self.value > 1.0 then self.value = 1.0 end
	self:redrawCanvas()
end

function Encoder:dec()
	self.value = self.value - 0.025
	if self.value < 0.0 then self.value = 0.0 end
	self:redrawCanvas()
end