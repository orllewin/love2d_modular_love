require '/socket'

class('BangIndicatorCom').extends()


function BangIndicatorCom:init(listener)
	BangIndicatorCom.super.init(self)
	
	self.listener = listener
	self.outSocket = Socket(socket_send)
	self.inSocket = Socket(socket_receive, function(event) 
		self.listener(event)
		self.outSocket:emit(event)
	end)
end

function BangIndicatorCom:setInCable(cable)
	self.inSocket:setCable(cable)
end

function BangIndicatorCom:setOutCable(cable)
	self.outSocket:setCable(cable)
end

function BangIndicatorCom:inConnected()
	return self.inSocket:connected()
end

function BangIndicatorCom:outConnected()
	return self.outSocket:connected()
end