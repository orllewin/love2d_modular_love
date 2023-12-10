require '/socket'

class('DelayCom').extends()

function DelayCom:init(listener, modId)
	DelayCom.super.init(self)
		
	self.param1 = 0.1
	self.param1Min = 0
	self.param1Max = 0.207
	
	self.param2 = 0.1
	self.param2Min = 0
	self.param2Max = 0.404
	
	self.param3 = 0.5
	self.param3Min = 0.0
	self.param3Max = 1.0
	
	self.enable = true
	self.volume = 0.75
	
	self.sourceModule = nil
	
	self.effectId = "delay_effect_" .. modId
	self:updateEffect()
	
	self.listener = listener
	self.outSocket = Socket(socket_send)
	self.inSocket = Socket(socket_receive, function(event) 
		self.listener(event)
		self.outSocket:emit(event)
	end)
end

function DelayCom:isOn()
	return self.enable
end

function DelayCom:toggle()
	self.enable = not self.enable
	
	if self.enable then
		self:updateEffect()
	else
		love.audio.setEffect(self.effectId, self.enable)
	end
	
	return self.enable
end

function DelayCom:updateEffect()
	love.audio.setEffect(self.effectId, {
		type = 'echo',
		volume = self.volume,
		delay = self.param1,
		tapdelay = self.param2,
		feedback = self.param3
	})
end

--Param 1
function DelayCom:defaultParam1()
	return self.param1
end

function DelayCom:normalisedDefaultParam1()
	return map(self.param1, self.param1Min, self.param1Max, 0.0, 1.0)
end

function DelayCom:setNormalisedParam1(value)
	self.param1 = map(value, 0.0, 1.0, self.param1Min, self.param1Max)
	self:updateEffect()
	return self.param1
end

--Param 2
function DelayCom:defaultParam2()
	return self.param2
end

function DelayCom:normalisedDefaultParam2()
	return map(self.param2, self.param2Min, self.param2Max, 0.0, 1.0)
end

function DelayCom:setNormalisedParam2(value)
	self.param2 = map(value, 0.0, 1.0, self.param2Min, self.param2Max)
	self:updateEffect()
	return self.param2
end

--Param 3
function DelayCom:defaultParam3()
	return self.param3
end

function DelayCom:normalisedDefaultParam3()
	return map(self.param3, self.param3Min, self.param3Max, 0.0, 1.0)
end

function DelayCom:setNormalisedParam3(value)
	self.param3 = map(value, 0.0, 1.0, self.param3Min, self.param3Max)
	self:updateEffect()
	return self.param3
end

-- End of parameters
function DelayCom:applyEffect(module)
	self.sourceModule = module
	local soundSources = self.sourceModule:soundSources()
	for i=1,#soundSources do
		local source = soundSources[i]
		source:setEffect(self.effectId, true)
	end
end

function DelayCom:getAudioModId()
	return self.sourceModule.modId
end

function DelayCom:setInCable(cable)
	self.inSocket:setCable(cable)
end

function DelayCom:setOutCable(cable)
	self.outSocket:setCable(cable)
end

function DelayCom:inConnected()
	return self.inSocket:connected()
end

function DelayCom:outConnected()
	return self.outSocket:connected()
end