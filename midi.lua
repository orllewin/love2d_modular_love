require 'coracle/math'

class('Midi').extends()

local floor = math.floor
local fmod = math.fmod

local baseFrequency = 65.4 --C2

local SCALES = {
	{label = "Major", intervals = {0, 2, 4, 5, 7, 9, 11}},
	{label = "Minor", intervals = {0, 2, 3, 5, 7, 8, 10}},
	{label = "Dorian", intervals = {0, 2, 3, 5, 7, 9, 10}},
	{label = "Phrygian", intervals = {0, 1, 3, 5, 7, 8, 10}},
	{label = "Lydian", intervals = {0, 2, 4, 6, 7, 9, 11}},
	{label = "Mixolydian", intervals = {0, 2, 4, 5, 7, 9, 10}},
	{label = "Locrian", intervals = {0, 1, 3, 5, 6, 8, 10}},
	{label = "Pentatonic Maj", intervals = {0, 2, 4, 7, 9}},
	{label = "Pentatonic Min", intervals = {0, 3, 5, 7, 10}},
	{label = "Blues", intervals = {0, 3, 5, 6, 7, 10}},
	{label = "Harmonic Maj", intervals = {0, 2, 4, 5, 7, 8, 11}},
	{label = "Lydian Minor", intervals = {0, 2, 4, 6, 7, 8, 10}},
	{label = "Persian", intervals = {0, 1, 4, 5, 6, 8, 11}},
}

--[[
	
https://newt.phys.unsw.edu.au/jw/notes.html
	
A0    C1                   C2                   C3                   C4
 22    25 27    30 32 34    37 39    42 44 46    49 51    54 56 58
21 23 24 26 28 29 31 33 35 36 38 40 41 43 45 47 48 50 52 53 55 57 59 60

--]]

--note midi starts at 0 - so array is ZERO INDEXED
-- https://www.inspiredacoustics.com/en/MIDI_note_numbers_and_center_frequencies
local noteLabels = {
	"C-1",		--0
	"C#",		--1
	"D",		--2
	"Eb",		--3
	"E",		--4
	"F",		--5
	"F#",		--6
	"G",		--7
	"Ab",		--8
	"A",		--9
	"Bb",		--10
	"B",		--11
	"C0",		--12 
	"C#",		--13
	"D",		--14
	"Eb",		--15
	"E",		--16
	"F",		--17
	"F#",		--18
	"G",		--19
	"Ab", 	--20
	"A0",		--21
	"Bb0",	--22
	"B0",		--23
	"C1",		--24 0.125
	"C#1",	--25
	"D1",		--26
	"Eb1",	--27
	"E1",		--28
	"F1",		--29
	"F#1",	--30
	"G1",		--31
	"Ab1",	--32
	"A1",		--33
	"Bb1",	--34
	"B1",		--35
	"C2",		--36 0.25
	"C#2",	--37
	"D2",		--38
	"Eb2",	--39
	"E2",		--40
	"F2",		--41
	"F#2",	--42
	"G2",		--43
	"Ab2",	--44
	"A2",		--45
	"Bb2", 	--46
	"B2",		--47
	"C3",		--48 0.5
	"C#3",	--49
	"D3",		--50
	"Eb3", 	--51
	"E3",		--52
	"F3",		--53
	"F#3",	--54
	"G3",		--55
	"Ab3",	--56
	"A3",		--57
	"Bb3",	--58
	"B3",		--59
	"C4",   --60 1.0
	"C#4",  --61 
	"D4",		--62
	"Eb",		--63
	"E4",		--64 
	"F4", 	--65
	"F#4", 	--66
	"G4", 	--67
	"Ab4", 	--68
	"A4", 	--69
	"Bb4", 	--70
	"B4", 	--71 	 
	"C5", 	--72 2.0
	"C#5", 	--73
	"D5", 	--74
	"Eb5", 	--75
	"E5", 	--76
	"F5", 	--77
	"F#5", 	--78
	"G5", 	--79
	"Ab5", 	--80
	"A5", 	--81
	"Bb5", 	--82
	"B5", 	--83
	"C6", 	--84 4.0
	"C#6", 	--85
	"D6", 	--86
	"Eb6", 	--87
	"E6", 	--88
	"F6", 	--89
	"F#6", 	--90
	"G6",		--91
	"Ab6",	--92
	"A6",		--93
	"Bb6",	--94
	"B6",		--95
	"C7",		--96 8.0
	"C#7",	--97
	"D7",		--98
	"Eb7",	--99
	"E7",		--100
	"F7", 	--101
	"F#7", 	--102
	"G7", 	--103
	"Ab7", 	--104
	"A7", 	--105
	"Bb7", 	--106
	"B7", 	--107
	"C8", 	--108 16.0
	"C#8", 	--109
	"D8", 	--110
	"Eb8", 	--111
	"E8", 	--112
	"F8", 	--113
	"F#8", 	--114
	"G8", 	--115
	"Ab8", 	--116
	"A8", 	--117
	"Bb8", 	--118
	"B8", 	--119
	"C9", 	--120
	"C#9", 	--121
	"D9", 	--122
	"Eb9", 	--123
	"E9", 	--124
	"F9", 	--125
	"F#9", 	--126
	"G9", 	--127 32.0
}

local core = {"C", "C#", "D", "E♭", "E", "F", "F#", "G", "A♭", "A", "B♭", "B"}
local rootNotes = {
	24,-- C
	25,-- C♯/D♭
	26,-- D
	27,-- D♯/E♭
	28,-- E
	29,-- F
	30,-- F♯/G♭
	31,-- G
	32,-- G#/A♭
	33,-- A
	34,-- A#/B♭
	35,-- B
}

function Midi:init()
	Midi.super.init(self)
end

--	return CONCERT_PITCH_HZ * std::pow(2.0f, ((midiNote - 69.0f) / 12.0f)); // where CONCERT_PITCH_HZ is the global pitch in hz of midiNote 69, usually 440.0
	
function Midi:normalisedNote(midiNote)
	-- all samples are C1 by default == 1.0
	-- so C2 == 2.0
	--C0 to C9
	--local ratio = baseFrequency * (((midiNote - 24.0) / 12.0) ^ 2)
	
	local ratio = 2^(((midiNote + 12)-60)/12)
	return ratio
end

function Midi:getScales()
	return SCALES
end

function Midi:noteNumberToLabel(number)
	local octave = floor(number/12) - 1
	local index = fmod(number, 12) + 1 
	return core[index] .. octave
end

function Midi:noteNumberToLabelNoOctave(number)
	local octave = floor(number/12) - 1
	local index = fmod(number, 12) + 1 
	return core[index]
end

function Midi:coreNotes()
	return core	
end

function Midi:getNotes2(startMidiNote, scaleLabel)
	local notes = self:generateScale(startMidiNote, scaleLabel)
	return notes
end

function Midi:generateScaleFromIndexes(noteIndex, scaleIndex)
	local rootMidiNote = 11 + noteIndex
	local scaleName = SCALES[scaleIndex].label
	return self:generateScale(rootMidiNote, scaleName)
end

function Midi:generateScale(startMidiNote, scaleName)	
	local scale = nil
	for i=1, #SCALES do
		if SCALES[i].label == scaleName then
			scale = SCALES[i]
			break
		end
	end
		
	local growingScale = {unpack(scale.intervals)}
	for i=1,#growingScale do
		growingScale[i] = growingScale[i] + startMidiNote - 12
	end
	self:printScale(scaleName, growingScale)
	print("XXXXXXXX")
	self:growKey(growingScale)
	self:printScale(scaleName, growingScale)
	return growingScale
end

function Midi:printScale(name, midiNotes)
	print("PRINT SCALE: name")
	for i=1, #midiNotes do
		local midiNote =  midiNotes[i]
		print("" .. midiNote .. ": " .. noteLabels[midiNote+1])
	end
end

function Midi:growKey(notes)
	local scaleSize = #notes
	local hiNote = notes[scaleSize]
	local offset = scaleSize - 1
	while(hiNote <= 127) do
		 for scaleNote = 1, scaleSize do
			 local sourceNote = notes[(#notes - offset)]
			 local newNote = sourceNote + 12
			 hiNote = newNote
			 if hiNote > 127 then break end
			 table.insert(notes, newNote)
		 end
	end
end


