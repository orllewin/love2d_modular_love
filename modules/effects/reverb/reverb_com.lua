require '/socket'

class('ReverbCom').extends()


function ReverbCom:init(listener, modId)
	ReverbCom.super.init(self)
	
	self.decayTime = 4
	self.density = 1.0
	self.diffusion = 1.0
	
	self.enable = true
	self.volume = 0.75
	
	self.sourceModule = nil
	
	self.effectId = "reverb_effect_" .. modId
	self:updateEffect()
	
	self.listener = listener
	self.outSocket = Socket(socket_send)
	self.inSocket = Socket(socket_receive, function(event) 
		self.listener(event)
		self.outSocket:emit(event)
	end)
end

function ReverbCom:isOn()
	return self.enable
end

function ReverbCom:toggle()
	self.enable = not self.enable

	if self.enable then
		self:updateEffect()
	else
		love.audio.setEffect(self.effectId, self.enable)
	end
	
	return self.enable
end


function ReverbCom:updateEffect()
	love.audio.setEffect(self.effectId, {
		type = 'reverb',
		decaytime = self.decayTime,
		density = self.density,
		diffusion = self.diffusion
	})
end

--Density
function ReverbCom:defaultDensity()
	return self.density
end

function ReverbCom:normalisedDefaultDensity()
	return self.density
end

function ReverbCom:setNormalisedDensity(value)
	self.density = value
	self:updateEffect()
	return self.density
end

--Diffusion
function ReverbCom:defaultDiffusion()
	return self.diffusion
end

function ReverbCom:normalisedDefaultDiffusion()
	return self.diffusion
end

function ReverbCom:setNormalisedDiffusion(value)
	self.diffusion = value
	self:updateEffect()
	return self.diffusion
end

--Decay Time
function ReverbCom:defaultDecayTime()
	return self.decayTime
end

function ReverbCom:normalisedDefaultDecayTime()
	return map(self.decayTime, 0.1, 20.0, 0.0, 1.0)
end

function ReverbCom:setNormalisedDecayTime(value)
	self.decayTime = map(value, 0.0, 1.0, 0.1, 20.0)
	self:updateEffect()
	return self.decayTime
end

-- End of parameters

function ReverbCom:applyEffect(module)
	self.sourceModule = module
	
	local soundSources = self.sourceModule:soundSources()
	for i=1,#soundSources do
		local source = soundSources[i]
		source:setEffect(self.effectId, true)
	end
end

function ReverbCom:getAudioModId()
	return self.sourceModule.modId
end

function ReverbCom:setInCable(cable)
	self.inSocket:setCable(cable)
end

function ReverbCom:setOutCable(cable)
	self.outSocket:setCable(cable)
end

function ReverbCom:inConnected()
	return self.inSocket:connected()
end

function ReverbCom:outConnected()
	return self.outSocket:connected()
end