require '/socket'

class('DistortionCom').extends()

function DistortionCom:init(listener, modId)
	DistortionCom.super.init(self)
	
	self.gain = 0.2
	self.edge = 0.2
	self.param3 = 8000
	
	self.enable = true
	self.volume = 0.75
	
	self.sourceModule = nil
	
	self.effectId = "distortion_effect_" .. modId
	self:updateEffect()
	
	self.listener = listener
	self.outSocket = Socket(socket_send)
	self.inSocket = Socket(socket_receive, function(event) 
		self.listener(event)
		self.outSocket:emit(event)
	end)
end

function DistortionCom:isOn()
	return self.enable
end

function DistortionCom:toggle()
	self.enable = not self.enable

	if self.enable then
		self:updateEffect()
	else
		love.audio.setEffect(self.effectId, self.enable)
	end
	
	return self.enable
end

function DistortionCom:updateEffect()
	love.audio.setEffect(self.effectId, {
		type = 'distortion',
		volume = self.volume,
		gain = self.gain,
		edge = self.edge
	})
end

function DistortionCom:defaultEdge()
	return self.edge
end

function DistortionCom:normalisedDefaultEdge()
	return self.edge
end

function DistortionCom:setNormalisedEdge(value)
	self.edge = value
	self:updateEffect()
	return self.edge
end

--Gain
function DistortionCom:defaultGain()
	return self.gain
end

function DistortionCom:normalisedDefaultGain()
	return map(self.gain, 0.01, 1.0, 0.0, 1.0)
end

function DistortionCom:setNormalisedGain(value)
	self.gain = map(value, 0.0, 1.0, 0.01, 1.0)
	self:updateEffect()
	return self.gain
end

--Param 3
function DistortionCom:defaultParam3()
	return self.volume
end

function DistortionCom:normalisedDefaultParam3()
	return self.volume
end

function DistortionCom:setNormalisedParam3(value)
	self.volume = value
	self:updateEffect()
	return self.volume
end

-- End of parameters
function DistortionCom:applyEffect(module)
	self.sourceModule = module
	local soundSources = self.sourceModule:soundSources()
	for i=1,#soundSources do
		local source = soundSources[i]
		source:setEffect(self.effectId, true)
	end
end

function DistortionCom:getAudioModId()
	return self.sourceModule.modId
end

function DistortionCom:setInCable(cable)
	self.inSocket:setCable(cable)
end

function DistortionCom:setOutCable(cable)
	self.outSocket:setCable(cable)
end

function DistortionCom:inConnected()
	return self.inSocket:connected()
end

function DistortionCom:outConnected()
	return self.outSocket:connected()
end