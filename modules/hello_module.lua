class('HelloModule').extends()

function HelloModule:init(x, y, colour)
	HelloModule.super.init()
	
	self.x = x
	self.y = y
	self.width = 100
	self.height = 130
	self.canvas = moduleCanvas(rgb(colour), rgb("#c8c8c8"), self.width, self.height, 7)
	moduleSocket(self.canvas, 14, 14)
	moduleSocket(self.canvas, 88, 14)
end

function HelloModule:visible(xOffset, yOffset)
	return true
end

function HelloModule:contains(x, y, gX, gY)
	local collision = inBounds(x, y, self.x + gX, self.y + gY, self.width, self.height)
	return collision
end

function HelloModule:tryConnectGhostOut(x, y, gX, gY)
	return self.x + gX + 88, self.y + gY + 14
end

function HelloModule:tryConnectGhostIn(x, y, gX, gY)
	return self.x + gX + 14, self.y + gY + 14
end

function HelloModule:update(deltaTime)
	
end

function HelloModule:draw(xOffset, yOffset)
	if self:visible(xOffset, yOffset) then
		love.graphics.draw(self.canvas, self.x + xOffset, self.y + yOffset)
	end
end