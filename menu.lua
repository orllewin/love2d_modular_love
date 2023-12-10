class('Menu').extends()

local rowHeight = 25
local ySpacer = 5

function Menu:init()
	Menu.super.init()
	
	self.showing = false
	
	self.items = {
		{
			label = "Clock",
			type = "category",
			children = {
				{
					label = "Clock",
					id = "clock_mod"
				},
				{
					label = "Bang Indicator",
					id = "BangIndicatorMod"
				},
				{
					label = "Bubble Chamber",
					id = "BubbleChamberMod"
				},
				{
					label = "Delay",
					id = "ClockDelayMod"
				},
				{
					label = "Divider",
					id = "ClockDividerMod"
				}
			}
		},
		{
			label = "Core",
			type = "category",
			children = {
				{
					label = "Midi Keyboard",
					id = "KeyboardMod"
				},
				{
					label = "Pedal",
					id = "pedal"
				},
				{
					label = "Random",
					id = "random"
				},
				{
					label = "Oscillator",
					id = "oscillator"
				},
				{
					label = "Bifurcate x2",
					id = "Bifurcate2Mod"
				},
				{
					label = "Bifurcate x4",
					id = "Bifurcate4Mod"
				},
				{
					label = "Blackhole",
					id = "BlackholeMod"
				},
				{
					label = "Print/Log",
					id = "print"
				},
			}
		},
		{
			label = "Effects",
			type = "effects",
			children = {
				{
					label = "Chorus",
					id = "ChorusMod"
				},
				{
					label = "Compressor",
					id = "CompressorMod"
				},
				{
					label = "Delay",
					id = "DelayMod"
				},
				{
					label = "Distortion",
					id = "DistortionMod"
				},
				{
					label = "Flanger",
					id = "FlangerMod"
				},
				{
					label = "Reverb",
					id = "ReverbMod"
				},
				{
					label = "Ring Modulator",
					id = "RingModulatorMod"
				},
			}
		},
		{
			label = "Sequencing",
			type = "category",
			children = {
				{
					label = "Generative Small",
					id = "GenerativeSmallMod"
				},
				{
					label = "Generative Std",
					id = "GenerativeStdMod"
				},
				{
					label = "Timed Switch",
					id = "TimedSwitchMod"
				},
			}
		},
		{
			label = "Sample Synth",
			type = "mod",
			id = "SampleSynthMod"
		}
	}
	
	self.categoryIndex = -1
	self.itemIndex = -1
	self.x = 0
	self.y = 0
	self.width = 150
	self:calculateHeight()
end

function Menu:show(x, y)
	self.x = x
	self.y = y
	self.categoryIndex = -1
	self:calculateHeight()
	self.showing = true
end

function Menu:dismiss()
	self.showing = false
	self.categoryIndex = -1
end

function Menu:isShowing()
	return self.showing
end

function Menu:click(x, y, gX, gY, onChild)
	local aX = math.abs(self.x - x)
	local aY = math.abs(self.y - y)
	local clickedIndex = math.floor( aY / rowHeight ) + 1

	if self.categoryIndex == -1 then
		if self.items[clickedIndex].type ~= nil and self.items[clickedIndex].type == "mod" then
			if onChild ~= nil then
				onChild(self.items[clickedIndex])
			end
			
			self:dismiss()
		else
			self.categoryIndex = clickedIndex
			self:calculateHeight()
		end
	else
		logger:log("child click: " .. clickedIndex)
	
		if onChild ~= nil then
			onChild(self.items[self.categoryIndex].children[clickedIndex])
		end
		
		self:dismiss()
	end 
end

function Menu:calculateHeight()
	self.height = 0
	if self.categoryIndex == -1 then
		self.height = #self.items * rowHeight
	else
		self.height = #self.items[self.categoryIndex].children * rowHeight
	end
	
	if self.y + self.height > love.graphics.getHeight() then
		self.y = love.graphics.getHeight() - self.height
	end
	
	if self.x + self.width > love.graphics.getWidth() then
		self.x = love.graphics.getWidth() - self.width
	end
	
	self.height = self.height + (ySpacer * 2)
	
	self.canvas = moduleCanvas(Colours.menuBackground, Colours.menuBorder, self.width, self.height, 7)
end

function Menu:contains(x, y, gX, gY)
	self:calculateHeight()
	local collision = inBounds(x, y, self.x, self.y, self.width, self.height)
	logger:log("menu collision: " .. tostring(collision))
	return collision
end

function Menu:draw(xOffset, yOffset)
	if self.showing then
		love.graphics.draw(self.canvas, self.x, self.y)
		
		local mX, mY = love.mouse.getPosition()
		love.graphics.setColor(blackAlpha(0.05)) 
		local aY = math.abs(mY - self.y)
		local index = math.floor(aY/rowHeight)

		if self.categoryIndex == -1 then
			if index < #self.items then
				love.graphics.rectangle('fill', self.x + 5, self.y + (index * rowHeight) + 4, self.width - 10, rowHeight + ySpacer - 5, 5)	
			end
			love.graphics.setColor(black())
			for i=1,#self.items do
				love.graphics.print(self.items[i].label, self.x + 10, ((self.y + ySpacer/2) + ((i-1) * rowHeight) + ySpacer))
			end
		else
			local childCount =  #self.items[self.categoryIndex].children
			if index < childCount then
				love.graphics.rectangle('fill', self.x + 5, self.y + (index * rowHeight) + 4, self.width - 10, rowHeight + ySpacer - 5, 5)	
			end
			love.graphics.setColor(black())
			for i = 1, childCount do
				love.graphics.print(self.items[self.categoryIndex].children[i].label, self.x + 10, ((self.y + ySpacer/2) + ((i-1) * rowHeight) + ySpacer))
			end
		end
		
		love.graphics.setColor(white()) 
	end
end