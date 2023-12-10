require '/socket'

class('ClockDelayCom').extends()

local clockDelayLabels = {
	"Off",
	"1/1",
	"1/2",
	"1/4",
	"1/8",
	"1/16",
	"1/32",
	"1/64",
}

local random = math.random


function ClockDelayCom:init(inListener, outlistener)
	ClockDelayCom.super.init(self)
	
	self.clockDelayIndex = 1
	
	self.bpm = 60
	
	self.clockDelay = false
	self.delaySeconds = 0.25
	self.chance = 0.5
	
	self.inListener = inListener
	self.outListener = outlistener
	
	self.outSocket = Socket(socket_send)
	self.inSocket = Socket(socket_receive, function(event) 
		self.inListener(event)		
		if random() < self.chance then
			--do delay
			self.elapsedSeconds = 0
			self.bpm = event:getValue()
			self:calculateDelaySeconds()
			self.clockDelay = true
		else
			--no delay
			self:emitBang()
		end
	end)
end

function ClockDelayCom:emitBang()
	self.clockDelay = false
	local event = Event(event_bang, self.bpm)
	self.outListener(event)
	self.outSocket:emit(event)
end

function ClockDelayCom:calculateDelaySeconds()
	if self.clockDelayIndex == 2 then
		--1/1 step
		self.delaySeconds = (60/self.bpm)
	elseif self.clockDelayIndex == 3 then
		--1/2 step
		self.delaySeconds = (60/self.bpm)/2
	elseif self.clockDelayIndex == 4 then
		--1/4 step
		self.delaySeconds = (60/self.bpm)/4
	elseif self.clockDelayIndex == 5 then
		--1/8 step
		self.delaySeconds = (60/self.bpm)/8
	elseif self.clockDelayIndex == 6 then
		--1/16 step
		self.delaySeconds = (60/self.bpm)/16
	elseif self.clockDelayIndex == 7 then
		--1/32 step
		self.delaySeconds = (60/self.bpm)/32
	elseif self.clockDelayIndex == 8 then
		--1/32 step
		self.delaySeconds = (60/self.bpm)/64
	end
end

function ClockDelayCom:setChance(value)
	self.chance = value
end

function ClockDelayCom:setClockDelay(value)
	self.clockDelayIndex = math.floor(map(value, 0.0, 1.0, 1, 8))
	return clockDelayLabels[self.clockDelayIndex]
end

function ClockDelayCom:update(deltaTime)
	if self.clockDelay then
		self.elapsedSeconds = self.elapsedSeconds + deltaTime
		if self.elapsedSeconds >= self.delaySeconds then
			self:emitBang()
		end
	end
end

function ClockDelayCom:setInCable(cable)
	self.inSocket:setCable(cable)
end

function ClockDelayCom:setOutCable(cable)
	self.outSocket:setCable(cable)
end

function ClockDelayCom:inConnected()
	return self.inSocket:connected()
end

function ClockDelayCom:outConnected()
	return self.outSocket:connected()
end