require '/socket'
require 'midi'

class('KeyboardCom').extends()

local whiteNotes = {0, 2, 4, 5, 7, 9, 11, 12, 14, 16, 17, 19, 21, 23, 24, 26, 28, 29, 31, 33, 35}
local blackNotes = {1, 3, -1, 6, 8, 10, -1, 13, 15, -1, 18, 20, 22, -1, 25, 27, -1, 30, 32, 34}

function KeyboardCom:init(listener)
	KeyboardCom.super.init(self)
	
	self.midi = Midi()
	self.octave = 2
	
	self.listener = listener
	self.outSocket = Socket(socket_send)
end

function KeyboardCom:playKey(key, shift, listener)
	local shiftUp = 0
	if shift then
		shiftUp = 7
	end
	if key == '-' then
		if self.octave > 1 then self.octave = self.octave - 1 end
	elseif key == '=' then
		if self.octave < 5 then self.octave = self.octave + 1 end
	elseif key == 'a' then
		self:playWhiteNote(1 + shiftUp)
		listener(true, 1 + shiftUp)
	elseif key == 's' then
		self:playWhiteNote(2 + shiftUp)
		listener(true, 2 + shiftUp)
	elseif key == 'd' then
		self:playWhiteNote(3 + shiftUp)
		listener(true, 3 + shiftUp)
	elseif key == 'f' then
		self:playWhiteNote(4 + shiftUp)
		listener(true, 4 + shiftUp)
	elseif key == 'g' then
		self:playWhiteNote(5 + shiftUp)
		listener(true, 5 + shiftUp)
	elseif key == 'h' then
		self:playWhiteNote(6 + shiftUp)
		listener(true, 6 + shiftUp)
	elseif key == 'j' then
		self:playWhiteNote(7 + shiftUp)
		listener(true, 7 + shiftUp)
	elseif key == 'k' then
		self:playWhiteNote(8 + shiftUp)
		listener(true, 8 + shiftUp)
	elseif key == 'l' then
		self:playWhiteNote(9 + shiftUp)
		listener(true, 9 + shiftUp)
	elseif key == ';' then
		self:playWhiteNote(10 + shiftUp)
		listener(true, 10 + shiftUp)
	elseif key == '\'' then
		self:playWhiteNote(11 + shiftUp)
		listener(true, 11 + shiftUp)
	elseif key == '\\' then
		self:playWhiteNote(12 + shiftUp)
		listener(true, 12 + shiftUp)
	elseif key == 'w' then
		self:playBlackNote(1 + shiftUp)
		listener(false, 1 + shiftUp)
	elseif key == 'e' then
		self:playBlackNote(2 + shiftUp)
		listener(false, 2 + shiftUp)
	elseif key == 't' then
		self:playBlackNote(4 + shiftUp)
		listener(false, 4 + shiftUp)
	elseif key == 'y' then
		self:playBlackNote(5 + shiftUp)
		listener(false, 5 + shiftUp)
	elseif key == 'u' then
		self:playBlackNote(6 + shiftUp)
		listener(false, 6 + shiftUp)
	elseif key == 'o' then
		self:playBlackNote(8 + shiftUp)
		listener(false, 8 + shiftUp)
	elseif key == 'p' then
		self:playBlackNote(9 + shiftUp)
		listener(false, 9 + shiftUp)
	end	
end

function KeyboardCom:stopKey(keycode)
	self:emitNote(-1)
end

function KeyboardCom:noteOff()
	if self.outSocket:connected() then
		self.outSocket:emit(Event(event_value, -1))
	end
end

function KeyboardCom:playBlackNote(index)
	if self.outSocket:connected() then
		if index > 0 and index <= #blackNotes then
			local midiNote = (self.octave * 12) + blackNotes[index]
			if blackNotes[index] ~= -1 then
				logger:log("> "  .. self.midi:noteNumberToLabelNoOctave(midiNote))
				self.outSocket:emit(Event(event_value, midiNote))
			end
		end
	end 
end

function KeyboardCom:playWhiteNote(index)
	if self.outSocket:connected() then
		local midiNote = (self.octave * 12) + whiteNotes[index]
		logger:log("> " .. self.midi:noteNumberToLabelNoOctave(midiNote))
		self.outSocket:emit(Event(event_value, midiNote))
	end 
end

function KeyboardCom:emitNote(midiNote)
	self.outSocket:emit(Event(event_value, midiNote))
end

function KeyboardCom:setOutCable(cable)
	self.outSocket:setCable(cable)
end

function KeyboardCom:outConnected()
	return self.outSocket:connected()
end