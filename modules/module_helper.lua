require "views/rectangle"

function moduleCanvas(colour, borderColour, width, height, borderRadius)	
	local canvas = love.graphics.newCanvas(width, height)
	love.graphics.setCanvas(canvas)
	love.graphics.push()
	love.graphics.setColor(colour) 	
	love.graphics.rectangle('fill', 0, 0, width, height, borderRadius)	
	love.graphics.setColor(borderColour)  
	love.graphics.setDefaultFilter("nearest", "nearest")
	love.graphics.setLineWidth(0.5)	
	love.graphics.rectangle('line', 1, 1, width - 1, height - 1, borderRadius)	
	love.graphics.pop()
	love.graphics.setCanvas()
	love.graphics.setColor(white()) 
	love.graphics.setDefaultFilter("linear", "linear")
	return canvas
end

function moduleSocket(canvas, x, y, colour)
	love.graphics.setCanvas(canvas)
	love.graphics.push()
	
	love.graphics.setLineWidth(1.5)
	if colour == nil then
		love.graphics.setColor(rgb("#666666"))
	else
		love.graphics.setColor(colour)
	end
	 
	love.graphics.circle('line', x, y, 9)
	
	love.graphics.circle('fill', x, y, 5)
	love.graphics.pop()
	love.graphics.setCanvas()
	love.graphics.setLineWidth(1)
	love.graphics.setColor(white()) 
end

function moduleIcon(canvas, path)
	love.graphics.setCanvas(canvas)
	local icon = love.graphics.newImage(path)
	love.graphics.draw(icon, 5, 5)
	love.graphics.setCanvas()
end