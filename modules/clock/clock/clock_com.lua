require '/socket'

class('ClockCom').extends()

local defaultBPM = 120

function ClockCom:init(listener)
	ClockCom.super.init(self)
	
	self.listener = listener
	self.outSocketA = Socket(socket_send)
	self.outSocketB = Socket(socket_send)
	self.outSocketC = Socket(socket_send)
	self.outSocketD = Socket(socket_send)
	
	self.bpm = defaultBPM
	
	self:updateParams()
end

function ClockCom:tempoChange(value)
	self.bpm = math.floor(map(value, 0.0, 1.0, 10, 200))
	self:updateParams()
end

function ClockCom:updateParams()
	self.stepSizeSeconds = (60/self.bpm)
	self.elapsedSeconds = 0
end

function ClockCom:update(deltaTime)
	self.elapsedSeconds = self.elapsedSeconds + deltaTime
	if self.elapsedSeconds >= self.stepSizeSeconds then
		self:bang()
		self.elapsedSeconds = 0
	end
end

function ClockCom:bang()	
	if self.outSocketA:connected() then
		self.outSocketA:emit(Event(event_bang, self.bpm))
	end
	if self.outSocketB:connected() then
		self.outSocketB:emit(Event(event_bang, self.bpm))
	end
	if self.outSocketC:connected() then
		self.outSocketC:emit(Event(event_bang, self.bpm))
	end
	if self.outSocketD:connected() then
		self.outSocketD:emit(Event(event_bang, self.bpm))
	end
	if self.listener ~= nil then self.listener() end
end

function ClockCom:stop()
	--todo
end

function ClockCom:getBPM()
	return self.bpm
end

function ClockCom:setOutACable(cable)
	self.outSocketA:setCable(cable)
end

function ClockCom:setOutBCable(cable)
	self.outSocketB:setCable(cable)
end

function ClockCom:setOutCCable(cable)
	self.outSocketC:setCable(cable)
end

function ClockCom:setOutDCable(cable)
	self.outSocketD:setCable(cable)
end

function ClockCom:aConnected()
	return self.outSocketA:connected()
end

function ClockCom:bConnected()
	return self.outSocketB:connected()
end

function ClockCom:cConnected()
	return self.outSocketC:connected()
end

function ClockCom:dConnected()
	return self.outSocketD:connected()
end

function ClockCom:unplug(cableId)
	if self:aConnected() and self.outSocketA:getCableId() == cableId then
		self.outSocketA:unplug()
	end
	
	if self:bConnected() and self.outSocketB:getCableId() == cableId then
		self.outSocketB:unplug()
	end
	
	if self:cConnected() and self.outSocketC:getCableId() == cableId then
		self.outSocketC:unplug()
	end
	
	if self:dConnected() and self.outSocketD:getCableId() == cableId then
		self.outSocketD:unplug()
	end
end

function ClockCom:unplugA()
	self.outSocketA:setCable(nil)
end

function ClockCom:unplugB()
	self.outSocketB:setCable(nil)
end

function ClockCom:unplugC()
	self.outSocketC:setCable(nil)
end

function ClockCom:unplugD()
	self.outSocketD:setCable(nil)
end

function ClockCom:setBPM(bpm)

end