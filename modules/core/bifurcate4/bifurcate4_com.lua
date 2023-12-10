require '/socket'

class('Bifurcate4Com').extends()


function Bifurcate4Com:init(listener)
	Bifurcate4Com.super.init(self)
	
	self.listener = listener
	self.outASocket = Socket(socket_send)
	self.outBSocket = Socket(socket_send)
	self.outCSocket = Socket(socket_send)
	self.outDSocket = Socket(socket_send)
	self.inSocket = Socket(socket_receive, function(event) 
		self.listener(event)
		self.outASocket:emit(event)
		self.outBSocket:emit(event)
	end)
end

function Bifurcate4Com:setInCable(cable)
	self.inSocket:setCable(cable)
end

function Bifurcate4Com:setOutACable(cable)
	self.outASocket:setCable(cable)
end

function Bifurcate4Com:setOutBCable(cable)
	self.outBSocket:setCable(cable)
end

function Bifurcate4Com:setOutCCable(cable)
	self.outCSocket:setCable(cable)
end

function Bifurcate4Com:setOutDCable(cable)
	self.outDSocket:setCable(cable)
end

function Bifurcate4Com:inConnected()
	return self.inSocket:connected()
end

function Bifurcate4Com:outAConnected()
	return self.outASocket:connected()
end

function Bifurcate4Com:outBConnected()
	return self.outBSocket:connected()
end

function Bifurcate4Com:outCConnected()
	return self.outCSocket:connected()
end

function Bifurcate4Com:outDConnected()
	return self.outDSocket:connected()
end