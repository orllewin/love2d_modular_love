class('Line').extends()

function Line:init(x1, y1, x2, y2, colour)
	Line.super.init()
	
	self.x1 = x1
	self.y1 = y1
	
	self.visible = true
	
	--cache
	local r, g, b, a = love.graphics.getColor()
	local activeCanvas = love.graphics.getCanvas()
	
	self.canvas = love.graphics.newCanvas(math.max(1, x2 - x1), math.max(1, y2 - y1))
	love.graphics.setCanvas(self.canvas)
	love.graphics.push()
	love.graphics.setColor(rgb(colour)) 
	love.graphics.line(0, 0, self.canvas:getWidth(), self.canvas:getHeight())
	love.graphics.pop()
	
	--reset to previous state
	love.graphics.setCanvas(activeCanvas)
	love.graphics.setColor(r, g, b, a) 
	
end

function Line:show()
	self.visible = true
end

function Line:hide()
	self.visible = false
end

function Line:update(deltaTime)
	
end

function Line:draw(xOffset, yOffset)
	if self.visible then
		love.graphics.draw(self.canvas, self.x1 + xOffset, self.y1 + yOffset)
	end
end