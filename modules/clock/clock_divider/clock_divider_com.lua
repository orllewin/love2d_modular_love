require '/socket'

class('ClockDividerCom').extends()

function ClockDividerCom:init(inListener, outlistener)
	ClockDividerCom.super.init(self)
	
	self.inListener = inListener
	self.outListener = outlistener
	
	self.allowEvent = true
	
	self.outSocket = Socket(socket_send)
	self.inSocket = Socket(socket_receive, function(event) 
		self.inListener(event)		
		if self.allowEvent then
			self.allowEvent = false
			self.outListener(event)
			self.outSocket:emit(event)
		else
			self.allowEvent = true
		end
	end)
end

function ClockDividerCom:setInCable(cable)
	self.inSocket:setCable(cable)
end

function ClockDividerCom:setOutCable(cable)
	self.outSocket:setCable(cable)
end

function ClockDividerCom:inConnected()
	return self.inSocket:connected()
end

function ClockDividerCom:outConnected()
	return self.outSocket:connected()
end