local _white = {1, 1, 1}
local _black = {0, 0, 0}

function rgb(hexColour)
			return {tonumber("0x"..hexColour:sub(2,3))/255, tonumber("0x"..hexColour:sub(4,5))/255, tonumber("0x"..hexColour:sub(6,7))/255, 1}
end

function rgba(hexColour)
			return {tonumber("0x"..hexColour:sub(2,3))/255, tonumber("0x"..hexColour:sub(4,5))/255, tonumber("0x"..hexColour:sub(6,7))/255, tonumber("0x"..hexColour:sub(8,9))/255}
end

function randomPastel()
	return {math.floor(math.random(100, 255))/255, math.floor(math.random(100, 255))/255, math.floor(math.random(100, 255))/255}
end

function randomPastelWithAlpha(alpha)
	return {math.floor(math.random(140, 255))/255, math.floor(math.random(140, 255))/255, math.floor(math.random(140, 255))/255, alpha}
end

function randomDarkPastel()
	return {math.floor(math.random(100, 255))/255, math.floor(math.random(100, 255))/255, math.floor(math.random(100, 255))/255}
end

function randomLightPastel()
	return {math.random(0.85, 1.0), math.random(0.85, 1.0), math.random(0.85, 1.0)}
end

function randomMolecule()
	return {math.random(0.75, 1.0), 0.2, 0.2, 0.4}
end

function randomBackgroundColour()
		return {0.3, 0.3, 0.3}
end

function white()
	return _white
end

function whiteAlpha(alpha)
	return {1, 1, 1, alpha}
end

function blackAlpha(alpha)
	return {0, 0, 0, alpha}
end

function black()
	return _black
end