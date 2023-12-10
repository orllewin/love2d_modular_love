function inBounds(x, y, vX, vY, vWidth, vHeight)
	return x < vX + vWidth and x > vX and y > vY and y < vY + vHeight
end