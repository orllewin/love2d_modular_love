class('Logger').extends()

function Logger:init()
	Logger.super.init()
	
	self.visible = false
	
	self.logs = {}
end

function Logger:log(message)
	if #self.logs > 35 then
		table.remove(self.logs, 1)
	end
	
	table.insert(self.logs, message)
end

function Logger:update(deltaTime)
	--noop
end

function Logger:toggleVisibility()
	self.visible = not self.visible
end

function Logger:draw(xOffset, yOffset)
	if self.visible then
		love.graphics.setColor(blackAlpha(0.5)) 
		love.graphics.rectangle('fill', 0, 0, 200, ((#self.logs + 1) * 16) + 10)
		
		love.graphics.setColor(white()) 
		for i=1,#self.logs do
			love.graphics.print( self.logs[i], 10, i * 16 )
		end
	end
end