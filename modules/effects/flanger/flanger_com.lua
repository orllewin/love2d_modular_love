require '/socket'

class('FlangerCom').extends()

function FlangerCom:init(modId)
	FlangerCom.super.init(self)
	
	self.param1 = 0.27
	self.param2 = 1.0
	self.param3 = -0.5
	
	self.enable = true
	self.volume = 0.75
	
	self.sourceModule = nil
	
	self.effectId = "flanger_effect_" .. modId
	self:updateEffect()
	
	self.outSocket = Socket(socket_send)
	self.inSocket = Socket(socket_receive, function(event) 
		self.listener(event)
		self.outSocket:emit(event)
	end)
end

function FlangerCom:isOn()
	return self.enable
end

function FlangerCom:toggle()
	self.enable = not self.enable

	if self.enable then
		self:updateEffect()
	else
		love.audio.setEffect(self.effectId, self.enable)
	end
	
	return self.enable
end

function FlangerCom:updateEffect()
	love.audio.setEffect(self.effectId, {
		type = 'flanger',
		rate = self.param1,
		depth = self.param2,
		feedback = self.param3
	})
end

--Param1
function FlangerCom:defaultParam1()
	return self.param1
end

function FlangerCom:normalisedDefaultParam1()
	return map(self.param1, 0.0, 10.0, 0.0, 1.0)
end

function FlangerCom:setNormalisedParam1(value)
	self.param1 = map(value, 0.0, 1.0, 0.0, 10.0)
	self:updateEffect()
	return self.param1
end

--Param2
function FlangerCom:defaultParam2()
	return self.param2
end

function FlangerCom:normalisedDefaultParam2()
	return self.param2
end

function FlangerCom:setNormalisedParam2(value)
	self.param2 = value
	self:updateEffect()
	return self.param2
end

--Param 3
function FlangerCom:defaultParam3()
	return self.param3
end

function FlangerCom:normalisedDefaultParam3()
	return map(self.param3, -1.0, 1.0, 0.0, 1.0)
end

function FlangerCom:setNormalisedParam3(value)
	self.param3 = value
	self:updateEffect()
	return self.param3
end

-- End of parameters
function FlangerCom:applyEffect(module)
	self.sourceModule = module
	local soundSources = self.sourceModule:soundSources()
	for i=1,#soundSources do
		local source = soundSources[i]
		source:setEffect(self.effectId, true)
	end
end

function FlangerCom:getAudioModId()
	return self.sourceModule.modId
end

function FlangerCom:setInCable(cable)
	self.inSocket:setCable(cable)
end

function FlangerCom:setOutCable(cable)
	self.outSocket:setCable(cable)
end

function FlangerCom:inConnected()
	return self.inSocket:connected()
end

function FlangerCom:outConnected()
	return self.outSocket:connected()
end