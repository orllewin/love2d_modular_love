require '/socket'
require '/midi'

class('GenerativeStdCom').extends()

local keys = {
	"C",
	"C#",
	"D",
	"E♭",
	"E",
	"F",
	"F#",
	"G",
	"A♭",
	"A",
	"B♭",
	"B"
}

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

function GenerativeStdCom:init(listener)
	GenerativeStdCom.super.init(self)
	
	self.lowNormal = 0.25
	self.highNormal = 0.66
	self.keyIndex = 1
	self.scaleIndex = 8
	self.midi = Midi()
	
	self.notes = self.midi:generateScaleFromIndexes(self.keyIndex, self.scaleIndex)
	
	self.startNoteIndex = 1
	self.endNoteIndex = #self.notes
	
	self:updateNoteIndexes()
	
	self.clockDelayIndex = 1
	
	self.bpm = 60
	
	self.clockDelay = false
	self.delaySeconds = 0.25
	self.gravity = 0
	
	self.listener = listener
	self.outSocket = Socket(socket_send)
	self.inSocket = Socket(socket_receive, function(event) 
		if random() < self.gravity then
			return
		end
		if self.clockDelayIndex == 1 then
			--delay
			self:generateNoteAndEmit()
		else
			--possible delay
			if random() > 0.75 then
				--do delay
				self.elapsedSeconds = 0
				self.bpm = event:getValue()
				--todo- calculate delay decimal seconds
				self:calculateDelaySeconds()
				self.clockDelay = true
			else
				--no delay
				self:generateNoteAndEmit()
			end
		end
	end)
end

function GenerativeStdCom:setScaleIndex(index)
	self.scaleIndex = index
	self.notes = self.midi:generateScaleFromIndexes(self.keyIndex, self.scaleIndex)
	self:updateNoteIndexes()
end

function GenerativeStdCom:setKey(value)
	self.keyIndex = math.floor(map(value, 0.0, 1.0, 1, #keys))
	self.notes = self.midi:generateScaleFromIndexes(self.keyIndex, self.scaleIndex)
	self:updateNoteIndexes()
	return keys[self.keyIndex]
end

function GenerativeStdCom:updateNoteIndexes()
	self.startNoteIndex = math.floor(map(self.lowNormal, 0.0, 1.0, 1, #self.notes))
	self.endNoteIndex = math.floor(map(self.highNormal, 0.0, 1.0, 1, #self.notes))
end

function GenerativeStdCom:setLowNoteNormal(value)
	self.lowNormal = value
	self:updateNoteIndexes()
end

function GenerativeStdCom:setHighNoteNormal(value)
	self.highNormal = value
	self:updateNoteIndexes()
end

function GenerativeStdCom:setBlackholeGravity(value)
	self.gravity = value
end

function GenerativeStdCom:calculateDelaySeconds()
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

function GenerativeStdCom:getScales()
	return self.midi:getScales()
end

function GenerativeStdCom:generateNoteAndEmit()
	self.clockDelay = false
	self.listener(event)
	local noteIndex = math.floor(random(self.startNoteIndex, self.endNoteIndex))
	local midiNote = self.notes[noteIndex]
	local noteEvent = Event(event_value, midiNote)
	self.outSocket:emit(noteEvent)
end

function GenerativeStdCom:update(deltaTime)
	if self.clockDelay then
		self.elapsedSeconds = self.elapsedSeconds + deltaTime
		if self.elapsedSeconds >= self.delaySeconds then
			self:generateNoteAndEmit()
		end
	end
end

function GenerativeStdCom:setClockDelay(value)
	self.clockDelayIndex = math.floor(map(value, 0.0, 1.0, 1, 8))
	return clockDelayLabels[self.clockDelayIndex]
end

function GenerativeStdCom:setInCable(cable)
	self.inSocket:setCable(cable)
end

function GenerativeStdCom:setOutCable(cable)
	self.outSocket:setCable(cable)
end

function GenerativeStdCom:inConnected()
	return self.inSocket:connected()
end

function GenerativeStdCom:outConnected()
	return self.outSocket:connected()
end