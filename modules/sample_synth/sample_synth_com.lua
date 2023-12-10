require '/socket'

class('SampleSynthCom').extends()

function SampleSynthCom:init(listener)
	SampleSynthCom.super.init(self)
	
	self.sampleA = love.audio.newSource("samples/pianos/epiano_face.wav", "static")
	self.sampleB = love.audio.newSource("samples/pianos/epiano_face.wav", "static")
	
	self.normalisedGain = 0.66
	
	-- love.audio.setEffect("effectA", {
	-- 	type = 'reverb',
	-- 	decaytime = 4
	-- })
	-- 
	-- love.audio.setEffect("effectB", {
	-- 	type = 'reverb',
	-- 	decaytime = 4
	-- })
	-- 
	-- local successA = self.sampleA:setEffect("effectA", true)
	-- local successB = self.sampleB:setEffect("effectB", true)
	
	self:setGain(self.normalisedGain)
	
	self.midi = Midi()
	
	self.listener = listener
	self.outSocket = Socket(socket_send)
	self.inSocket = Socket(socket_receive, function(event) 
		self.listener(event)
		
		if event:getValue() < 0 then
			self:stopNote()
		else
			self:playNote(event:getValue())
		end
	end)
end

function SampleSynthCom:soundSources()
	return {
		self.sampleA,
		self.sampleB
	}
end

function SampleSynthCom:setGain(value)
	self.normalisedGain = value
	self.sampleA:setVolume(self.normalisedGain)
	self.sampleB:setVolume(self.normalisedGain)
end

function SampleSynthCom:setSample(path)
	self.sampleA = love.audio.newSource(path, "static")
	self.sampleB = love.audio.newSource(path, "static")
	local successA = self.sampleA:setEffect("effectA", true)
	local successB = self.sampleB:setEffect("effectB", true)
end

function SampleSynthCom:setSamplePath(path)
	self.sampleA = love.audio.newSource(path, "static")
	self.sampleB = love.audio.newSource(path, "static")
	local successA = self.sampleA:setEffect("effectA", true)
	local successB = self.sampleB:setEffect("effectB", true)
end

function SampleSynthCom:stopNote()
	if self.sampleA:isPlaying() then
		self.sampleA:stop()
	end
	
	if self.sampleB:isPlaying() then
		self.sampleB:stop()
	end
end

function SampleSynthCom:playNote(midiNote)
	if self.sampleA:isPlaying() and not self.sampleB:isPlaying()  then
		self:playNoteB(midiNote)
	elseif self.sampleB:isPlaying() and not self.sampleA:isPlaying()  then
		self:playNoteA(midiNote)
	else
		if math.random() < 0.5 then
			self.sampleA:stop()
			self:playNoteA(midiNote)
		else
			self.sampleB:stop()
			self:playNoteB(midiNote)
		end
	end
end

function SampleSynthCom:playNoteA(midiNote)
	local pitch = self.midi:normalisedNote(midiNote)
	if pitch > 0 then
		self.sampleA:setPitch(pitch)
		self.sampleA:play()
	end
end

function SampleSynthCom:playNoteB(midiNote)
	local pitch = self.midi:normalisedNote(midiNote)
	if pitch > 0 then
		self.sampleB:setPitch(pitch)
		self.sampleB:play()
	end
end

function SampleSynthCom:setInCable(cable)
	self.inSocket:setCable(cable)
end

function SampleSynthCom:setOutCable(cable)
	self.outSocket:setCable(cable)
end

function SampleSynthCom:inConnected()
	return self.inSocket:connected()
end

function SampleSynthCom:outConnected()
	return self.outSocket:connected()
end