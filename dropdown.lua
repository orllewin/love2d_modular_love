class('Dropdown').extends()

local rowHeight = 25
local ySpacer = 5

function Dropdown:init()
	Dropdown.super.init()
	
	self.showing = false
	
	self.items = {}

	self.itemIndex = 1
	self.x = 0
	self.y = 0
	self.width = 150
	self:calculateHeight()
end

function Dropdown:show(x, y, width, items, listener)
	self.x = x
	self.y = y
	self.width = width
	self.items = items
	self.listener = listener
	self:calculateHeight()
	self.showing = true
end

function Dropdown:dismiss()
	self.showing = false
	self.categoryIndex = -1
end

function Dropdown:isShowing()
	return self.showing
end

function Dropdown:click(x, y, gX, gY)
	local aX = math.abs(self.x - x)
	local aY = math.abs(self.y - y)
	local clickedIndex = math.floor( aY / rowHeight ) + 1

	if self.listener ~= nil then
		self.listener(clickedIndex)
	end
	
	self:dismiss()
end

function Dropdown:calculateHeight()
	self.height = 0
	
	if #self.items == 0 then
		return
	end
	
	self.height = #self.items * rowHeight
	
	if self.y + self.height > love.graphics.getHeight() then
		self.y = love.graphics.getHeight() - self.height - 10
	end
	
	if self.x + self.width > love.graphics.getWidth() then
		self.x = love.graphics.getWidth() - self.width
	end
	
	self.height = self.height + (ySpacer * 2)
	
	self.canvas = moduleCanvas(Colours.menuBackground, Colours.menuBorder, self.width, self.height, 7)
end

function Dropdown:contains(x, y, gX, gY)
	self:calculateHeight()
	local collision = inBounds(x, y, self.x, self.y, self.width, self.height)
	logger:log("Dropdown collision: " .. tostring(collision))
	return collision
end

function Dropdown:draw(xOffset, yOffset)
	if #self.items == 0 then
		return
	end
	
	if self.showing then
		love.graphics.draw(self.canvas, self.x, self.y)
		
		local mX, mY = love.mouse.getPosition()
		love.graphics.setColor(blackAlpha(0.05)) 
		local aY = math.abs(mY - self.y)
		local index = math.floor(aY/rowHeight)


		local childCount =  #self.items
		if index < childCount then
			love.graphics.rectangle('fill', self.x + 5, self.y + (index * rowHeight) + 4, self.width - 10, rowHeight + ySpacer - 5, 5)	
		end
		love.graphics.setColor(black())
		for i = 1, childCount do
			love.graphics.print(self.items[i].label, self.x + 10, ((self.y + ySpacer/2) + ((i-1) * rowHeight) + ySpacer))
		end

		
		love.graphics.setColor(white()) 
	end
end