--[[

	An event travels from one end of a cable to another.
	A bang is a trigger
	Voltage is a change in some value

]]--

class('Event').extends()

event_value = 255
event_bang = 256
event_min = -127
event_max = 127


function Event:init(type, value)
	Event.super.init(self)
	self.type = type
	self.value = value
end

function Event:getType()
	return self.type
end

function Event:getValue()
	return self.value
end