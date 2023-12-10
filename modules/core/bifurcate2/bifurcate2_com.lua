require '/socket'

class('Bifurcate2Com').extends()


function Bifurcate2Com:init(listener)
	Bifurcate2Com.super.init(self)
	
	self.listener = listener
	self.outASocket = Socket(socket_send)
	self.outBSocket = Socket(socket_send)
	self.inSocket = Socket(socket_receive, function(event) 
		self.listener(event)
		self.outASocket:emit(event)
		self.outBSocket:emit(event)
	end)
end

function Bifurcate2Com:setInCable(cable)
	self.inSocket:setCable(cable)
end

function Bifurcate2Com:setOutACable(cable)
	self.outASocket:setCable(cable)
end

function Bifurcate2Com:setOutBCable(cable)
	self.outBSocket:setCable(cable)
end

function Bifurcate2Com:inConnected()
	return self.inSocket:connected()
end

function Bifurcate2Com:outAConnected()
	return self.outASocket:connected()
end

function Bifurcate2Com:outBConnected()
	return self.outBSocket:connected()
end