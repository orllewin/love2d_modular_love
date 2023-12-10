require '/socket'

class('ChorusCom').extends()

function ChorusCom:init(listener, modId)
	ChorusCom.super.init(self)
	
	self.rate = 1.1 
	self.depth = 0.1
	
	self.sourceModule = nil
	
	self.enable = true
	self.volume = 0.75
	
	self.effectId = "chorus_effect_" .. modId
	self:updateEffect()
	
	self.listener = listener
	self.outSocket = Socket(socket_send)
	self.inSocket = Socket(socket_receive, function(event) 
		self.listener(event)
		self.outSocket:emit(event)
	end)
end

function ChorusCom:toggle()
	self.enable = not self.enable
	self:updateEffect()
	return self.enable
end

function ChorusCom:isOn()
	return self.enable
end

function ChorusCom:updateEffect()
	local volume = self.volume
	if self.enable == false then
		volume = 0
	end
	love.audio.setEffect(self.effectId, {
		type = 'chorus',
		volume = volume,
		rate = self.rate,
		depth = self.depth
	})
end

function ChorusCom:defaultRate()
	return self.rate
end

function ChorusCom:normalisedDefaultRate()
	return map(self.rate, 0.0, 3.0, 0.0, 1.0)
end

function ChorusCom:setNormalisedRate(value)
	self.rate = map(value, 0.0, 1.0, 0.0, 3.0)
	self:updateEffect()
	return self.rate
end

--Depth
function ChorusCom:defaultDepth()
	return self.depth
end

function ChorusCom:normalisedDefaultDepth()
	return self.depth
end

function ChorusCom:setNormalisedDepth(value)
	self.depth = value
	self:updateEffect()
	return self.depth
end

-- End of parameters
function ChorusCom:applyEffect(module)
	self.sourceModule = module
	local soundSources = self.sourceModule:soundSources()
	for i=1,#soundSources do
		local source = soundSources[i]
		source:setEffect(self.effectId, true)
	end
end

function ChorusCom:getAudioModId()
	return self.sourceModule.modId
end

function ChorusCom:setInCable(cable)
	self.inSocket:setCable(cable)
end

function ChorusCom:setOutCable(cable)
	self.outSocket:setCable(cable)
end

function ChorusCom:inConnected()
	return self.inSocket:connected()
end

function ChorusCom:outConnected()
	return self.outSocket:connected()
end