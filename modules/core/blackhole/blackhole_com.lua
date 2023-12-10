require '/socket'

class('BlackholeCom').extends()


function BlackholeCom:init(listener, outListener)
	BlackholeCom.super.init(self)
	
	self.gravity = 0
	
	self.listener = listener
	self.outListener = outListener
	self.outSocket = Socket(socket_send)
	self.inSocket = Socket(socket_receive, function(event) 
		self.listener(event)
		if math.random() > self.gravity then
			self.outListener()
			self.outSocket:emit(event)
		end
	end)
end

function BlackholeCom:setGravity(value)
	self.gravity = value
end

function BlackholeCom:setInCable(cable)
	self.inSocket:setCable(cable)
end

function BlackholeCom:setOutCable(cable)
	self.outSocket:setCable(cable)
end

function BlackholeCom:inConnected()
	return self.inSocket:connected()
end

function BlackholeCom:outConnected()
	return self.outSocket:connected()
end