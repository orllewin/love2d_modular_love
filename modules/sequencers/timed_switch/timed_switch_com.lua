require '/socket'

class('TimedSwitchCom').extends()

local openSocket1 = 1
local openSocket2 = 2

function TimedSwitchCom:init(listener, changeListener)
	TimedSwitchCom.super.init(self)
		
	self.ticks = 0
	self.switchTicks = 8
	
	self.openSocket = openSocket1
	
	self.listener = listener
	self.changeListener = changeListener
	self.outASocket = Socket(socket_send)
	self.outBSocket = Socket(socket_send)
	self.inSocket = Socket(socket_receive, function(event) 		
		self.ticks = self.ticks + 1
		
		if self.ticks == self.switchTicks then
			if self.openSocket == openSocket1 then
				self.openSocket = openSocket2
				self.changeListener()
			elseif self.openSocket == openSocket2 then
				self.openSocket = openSocket1 
				self.changeListener()
			end
			
			self.ticks = 0
		end
		
		if self.openSocket == openSocket1 then
			self.listener(event)
			self.outASocket:emit(event)
		elseif self.openSocket == openSocket2 then
			self.listener(event)
			self.outBSocket:emit(event)
		end

	end)
end

function TimedSwitchCom:setTicks(ticks)
	self.ticks = 0
	self.switchTicks = ticks
end

function TimedSwitchCom:getOpenSocket()
	return self.openSocket
end

function TimedSwitchCom:toggle()
	if self.openSocket == openSocket1 then
		self.openSocket = openSocket2
		self.changeListener()
	elseif self.openSocket == openSocket2 then
		self.openSocket = openSocket1 
		self.changeListener()
	end
end

function TimedSwitchCom:setInCable(cable)
	self.inSocket:setCable(cable)
end

function TimedSwitchCom:setOutACable(cable)
	self.outASocket:setCable(cable)
end

function TimedSwitchCom:setOutBCable(cable)
	self.outBSocket:setCable(cable)
end

function TimedSwitchCom:inConnected()
	return self.inSocket:connected()
end

function TimedSwitchCom:outAConnected()
	return self.outASocket:connected()
end

function TimedSwitchCom:outBConnected()
	return self.outBSocket:connected()
end