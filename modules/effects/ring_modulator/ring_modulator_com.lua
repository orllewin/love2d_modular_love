require '/socket'

class('RingModulatorCom').extends()

function RingModulatorCom:init(modId)
	RingModulatorCom.super.init(self)
	
	self.param1 = 440
	self.param2 = 800
	
	self.enable = true
	self.volume = 0.75
	
	self.sourceModule = nil
	
	self.effectId = "ring_mod_effect_" .. modId
	self:updateEffect()
	
	self.outSocket = Socket(socket_send)
	self.inSocket = Socket(socket_receive, function(event) 
		self.listener(event)
		self.outSocket:emit(event)
	end)
end

function RingModulatorCom:isOn()
	return self.enable
end

function RingModulatorCom:toggle()
	self.enable = not self.enable

	if self.enable then
		self:updateEffect()
	else
		love.audio.setEffect(self.effectId, self.enable)
	end
	
	return self.enable
end

function RingModulatorCom:updateEffect()
	love.audio.setEffect(self.effectId, {
		type = 'ringmodulator',
		frequency = self.param1,
		highcut = self.param2
	})
end

--Param1
function RingModulatorCom:defaultParam1()
	return self.param1
end

function RingModulatorCom:normalisedDefaultParam1()
	return map(self.param1, 0.0, 8000.0, 0.0, 1.0)
end

function RingModulatorCom:setNormalisedParam1(value)
	self.param1 = map(value, 0.0, 1.0, 0.0, 8000.00)
	self:updateEffect()
	return self.param1
end

--Param2
function RingModulatorCom:defaultParam2()
	return self.param2
end

function RingModulatorCom:normalisedDefaultParam2()
	return map(self.param2, 0.0, 24000.0, 0.0, 1.0)
end

function RingModulatorCom:setNormalisedParam2(value)
	self.param2 = map(value, 0.0, 1.0, 0.0, 24000.00)
	self:updateEffect()
	return self.param2
end

-- End of parameters
function RingModulatorCom:applyEffect(module)
	self.sourceModule = module
	local soundSources = self.sourceModule:soundSources()
	for i=1,#soundSources do
		local source = soundSources[i]
		source:setEffect(self.effectId, true)
	end
end

function RingModulatorCom:getAudioModId()
	return self.sourceModule.modId
end

function RingModulatorCom:setInCable(cable)
	self.inSocket:setCable(cable)
end

function RingModulatorCom:setOutCable(cable)
	self.outSocket:setCable(cable)
end

function RingModulatorCom:inConnected()
	return self.inSocket:connected()
end

function RingModulatorCom:outConnected()
	return self.outSocket:connected()
end