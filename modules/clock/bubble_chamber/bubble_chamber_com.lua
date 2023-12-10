require '/socket'

class('BubbleChamberCom').extends()

function BubbleChamberCom:init()
	BubbleChamberCom.super.init(self)
	self.outSocket = Socket(socket_send)
end

function BubbleChamberCom:emit()
	self.outSocket:emit(Event(event_bang, 120))
end

function BubbleChamberCom:setOutCable(cable)
	self.outSocket:setCable(cable)
end

function BubbleChamberCom:outConnected()
	return self.outSocket:connected()
end