class('Mouse').extends()

local pointer = 1
local hand = 2

function Mouse:init()
	Mouse.super.init()
	
	self.mode = pointer
	self.handCursor = love.mouse.getSystemCursor("hand")
end

function Mouse:hoverClickable()
	if self.mode ~= hand then
		self.mode = hand
		love.mouse.setCursor(self.handCursor)
	end
end

function Mouse:reset()
	if self.mode ~= pointer then
		self.mode = pointer
		love.mouse.setCursor()
	end
end