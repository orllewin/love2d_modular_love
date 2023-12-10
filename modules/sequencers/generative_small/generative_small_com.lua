require '/socket'
require '/midi'

class('GenerativeSmallCom').extends()

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

local random = math.random

function GenerativeSmallCom:init(listener)
	GenerativeSmallCom.super.init(self)
	
	self.lowNormal = 0.25
	self.highNormal = 0.66
	self.keyIndex = 1
	self.scaleIndex = 8
	self.midi = Midi()
	
	self.notes = self.midi:generateScaleFromIndexes(self.keyIndex, self.scaleIndex)
	
	self.startNoteIndex = 1
	self.endNoteIndex = #self.notes
	
	self:updateNoteIndexes()
	
	self.listener = listener
	self.outSocket = Socket(socket_send)
	self.inSocket = Socket(socket_receive, function(event) 
		self:generateNoteAndEmit()
	end)
end

function GenerativeSmallCom:setScaleIndex(index)
	self.scaleIndex = index
	self.notes = self.midi:generateScaleFromIndexes(self.keyIndex, self.scaleIndex)
	self:updateNoteIndexes()
end

function GenerativeSmallCom:setKey(value)
	self.keyIndex = math.floor(map(value, 0.0, 1.0, 1, #keys))
	self.notes = self.midi:generateScaleFromIndexes(self.keyIndex, self.scaleIndex)
	self:updateNoteIndexes()
	return keys[self.keyIndex]
end

function GenerativeSmallCom:updateNoteIndexes()
	self.startNoteIndex = math.floor(map(self.lowNormal, 0.0, 1.0, 1, #self.notes))
	self.endNoteIndex = math.floor(map(self.highNormal, 0.0, 1.0, 1, #self.notes))
end

function GenerativeSmallCom:setLowNoteNormal(value)
	self.lowNormal = value
	self:updateNoteIndexes()
end

function GenerativeSmallCom:setHighNoteNormal(value)
	self.highNormal = value
	self:updateNoteIndexes()
end

function GenerativeSmallCom:getScales()
	return self.midi:getScales()
end

function GenerativeSmallCom:generateNoteAndEmit()
	self.listener(event)
	local noteIndex = math.floor(random(self.startNoteIndex, self.endNoteIndex))
	local midiNote = self.notes[noteIndex]
	local noteEvent = Event(event_value, midiNote)
	self.outSocket:emit(noteEvent)
end

function GenerativeSmallCom:update(deltaTime)
	if self.clockDelay then
		self.elapsedSeconds = self.elapsedSeconds + deltaTime
		if self.elapsedSeconds >= self.delaySeconds then
			self:generateNoteAndEmit()
		end
	end
end

function GenerativeSmallCom:setClockDelay(value)
	self.clockDelayIndex = math.floor(map(value, 0.0, 1.0, 1, 8))
	return clockDelayLabels[self.clockDelayIndex]
end

function GenerativeSmallCom:setInCable(cable)
	self.inSocket:setCable(cable)
end

function GenerativeSmallCom:setOutCable(cable)
	self.outSocket:setCable(cable)
end

function GenerativeSmallCom:inConnected()
	return self.inSocket:connected()
end

function GenerativeSmallCom:outConnected()
	return self.outSocket:connected()
end