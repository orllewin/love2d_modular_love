require '/socket'

class('CompressorCom').extends()

function CompressorCom:init(listener, modId)
	CompressorCom.super.init(self)
	
	self.enable = true
	self.volume = 0.75
	
	self.sourceModule = nil
	
	self.effectId = "compressor_effect_" .. modId
	self:updateEffect()
	
	self.listener = listener
	self.outSocket = Socket(socket_send)
	self.inSocket = Socket(socket_receive, function(event) 
		self.listener(event)
		self.outSocket:emit(event)
	end)
end

function CompressorCom:defaultVolume()
	return self.volume
end

function CompressorCom:normalisedDefaultVolume()
	return self.volume
end

function CompressorCom:setNormalisedVolume(value)
	self.volume = value
	self:updateEffect()
	return self.volume
end

function CompressorCom:updateEffect()
	love.audio.setEffect(self.effectId, {
		type = 'compressor',
		volume = self.volume
	})
end

function CompressorCom:isOn()
	return self.enable
end

function CompressorCom:toggle()
	self.enable = not self.enable

	if self.enable then
		self:updateEffect()
	else
		love.audio.setEffect(self.effectId, self.enable)
	end
	
	return self.enable
end

-- End of parameters
function CompressorCom:applyEffect(module)
	self.sourceModule = module
	local soundSources = self.sourceModule:soundSources()
	for i=1,#soundSources do
		local source = soundSources[i]
		source:setEffect(self.effectId, true)
	end
end

function CompressorCom:getAudioModId()
	return self.sourceModule.modId
end

function CompressorCom:setInCable(cable)
	self.inSocket:setCable(cable)
end

function CompressorCom:setOutCable(cable)
	self.outSocket:setCable(cable)
end

function CompressorCom:inConnected()
	return self.inSocket:connected()
end

function CompressorCom:outConnected()
	return self.outSocket:connected()
end