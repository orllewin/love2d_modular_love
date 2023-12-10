require "modules/sample_synth/sample_synth_com"

class('SampleSynthMod').extends()

local modType = "SampleSynthMod"
local modSubtype = "audio"

local presets = {
	{
		id = "combi",
		label = "Combi",
		children = {
			{
				label = "Orl Combi 1",
				path = "samples/combi/orl_combi_1.wav"
			},
			{
				label = "Orl Combi 2",
				path = "samples/combi/orl_combi_2.wav"
			},
			{
				label = "Orl Combi 3",
				path = "samples/combi/orl_combi_3.wav"
			},
			{
				label = "Orl Combi 4",
				path = "samples/combi/orl_combi_4.wav"
			},
			{
				label = "Orl Combi 5",
				path = "samples/combi/orl_combi_5.wav"
			},
			{
				label = "Orl Combi 6",
				path = "samples/combi/orl_combi_6.wav"
			},
			{
				label = "Orl Combi 7",
				path = "samples/combi/orl_combi_7.wav"
			},
		}
	},
	{
		id = "pads_1",
		label = "Pads 1",
		children = {
			{
				label = "Airy",
				path = "samples/airy_pad.wav"
			},
			{
				label = "Alder",
				path = "samples/alder_pad.wav"
			},
			{
				label = "Alder2",
				path = "samples/pads/alder2.wav"
			},
			{
				label = "Amber",
				path = "samples/pads/amber.wav"
			},
			{
				label = "Bower Closes",
				path = "samples/bower_close.wav"
			},
			{
				label = "Celestial",
				path = "samples/celestial_pad.wav"
			},
			{
				label = "Celestial2",
				path = "samples/celestial_pad2.wav"
			},
			{
				label = "Digi Noise Choir",
				path = "samples/digi_noise_choir.wav"
			},
			{
				label = "Dreh Moment",
				path = "samples/pads/drehmoment.wav"
			},
			{
				label = "Dronarium",
				path = "samples/pads/dronarium.wav"
			},
			{
				label = "Eiswind",
				path = "samples/pads/eiswind.wav"
			},
			{
				label = "Ferrae",
				path = "samples/pads/ferrae.wav"
			},
			{
				label = "FM Cassini",
				samples = "samples/fm_bell.wav"
			},
			{
				label = "Hagelschlag",
				path = "samples/pads/hagelschlag.wav"
			},
		}
	},
	{
		id = "pads_2",
		label = "Pads 2",
		children = {
			{
				label = "Hintergrund",
				path = "samples/pads/hintergrund.wav"
			},
			{
				label = "Inside Angel",
				path = "samples/pads/inside_angel.wav"
			},
			{
				label = "Iridium",
				path = "samples/pads/iridium.wav"
			},
			{
				label = "Lab",
				path = "samples/pads/lab.wav"
			},
			{
				label = "Landregen",
				path = "samples/pads/landregen.wav"
			},
			{
				label = "Obj. Drone",
				path = "samples/pads/object_drone.wav"
			},
			{
				label = "Mindful",
				path = "samples/pads/mindful.wav"
			},
			{
				label = "Neutron",
				path = "samples/pads/neutron.wav"
			},
			{
				label = "Neutron II",
				path = "samples/pads/neutron2.wav"
			},
			{
				label = "Peerlon",
				path = "samples/pads/peerlon.wav"
			},
			{
				label = "Perception",
				path = "samples/perception_pad.wav"
			},
			{
				label = "Pitched Amb.",
				path = "samples/pads/pitched_amb.wav"
			},
			{
				label = "Radius",
				path = "samples/pads/radius.wav"
			},
			{
				label = "Sandman",
				path = "samples/sandman_pad.wav"
			},
			{
				label = "Schleifend",
				path = "samples/pads/schleifend.wav"
			},
		}
	},
	{
		id = "pads_3",
		label = "Pads 3",
		children = {
			{
				label = "Seashore",
				path = "samples/pads/seashore.wav"
			},
			{
				label = "Seitanband",
				path = "samples/pads/seitanband.wav"
			},
			{
				label = "Sitar Smooth",
				path = "samples/pads/sitar_smooth.wav"
			},
			{
				label = "Sitar S.track",
				path = "samples/sitar_soundtrack_pad.wav"
			},
			{
				label = "Sitar Space",
				path = "samples/pads/sitar_space.wav"
			},
			{
				label = "Sodium",
				path = "samples/pads/sodium.wav"
			},
			{
				label = "Sommernacht",
				path = "samples/pads/sommernacht.wav"
			},
			{
				label = "Spectrum",
				path = "samples/pads/spectrum.wav"
			},
			{
				label = "Starshower.wav",
				path = "samples/starshower_pad.wav"
			},
			{
				label = "Strahlend",
				path = "samples/pads/strahlend.wav"
			},
			{
				label = "Traum",
				path = "samples/pads/trsaum.wav"
			},
			{
				label = "Umbra",
				path = "samples/pads/umbra.wav"
			},
			{
				label = "Varianz 2",
				path = "samples/pads/varianz.wav"
			},
			{
				label = "Varianz",
				path = "samples/pads/varianz2.wav"
			},
			{
				label = "Ventricol",
				path = "samples/pads/ventricol.wav"
			},
		}
	},
	{
		id = "piano",
		label = "Piano",
		children = {
			{
				label = "EPiano Face",
				path = "samples/pianos/epiano_face.wav"
			},
			{
				label = "Dulcimatica",
				path = "samples/pianos/dulcimatica.wav"
			},
			{
				label = "E-Piano Basic",
				path = "samples/pianos/epiano_basic.wav"
			},
			{
				label = "E-Piano Cheap",
				path = "samples/pianos/epiano_cheap.wav"
			},
			{
				label = "E-Piano Face",
				path = "samples/pianos/epiano_face.wav"
			},
			{
				label = "E-Piano Float",
				path = "samples/pianos/epiano_float.wav"
			},
			{
				label = "E-Piano Rust",
				path = "samples/pianos/epiano_rust.wav"
			},
			{
				label = "Grand Reverb",
				path = "samples/piano/grand_reverb.wav"
			}
		}
	},
	{
		id = "bass",
		label = "Bass",
		children = {
			{
				label = "303",
				path = "samples/bass/303.wav"
			},
			{
				label = "Hopped",
				path = "samples/bass/hopped.wav"
			},
			{
				label = "New Old Sub",
				path = "samples/bass/new_old_sub.wav"
			},
			{
				label = "Upright",
				path = "samples/bass/upright.wav"
			},
		}
	},
	{
		id = "bells",
		label = "Bells",
		children = {
			{
				label = "Ambient Bell",
				path = "samples/ambient_bell.wav"
			},
			{
				label = "Analog Chime",
				path = "samples/analog_chime.wav"
			},
			{
				label = "Basic Bell",
				path = "samples/basic_bell.wav"
			},
			{
				label = "Brushed Bells",
				path = "samples/brushed_bells.wav"
			},
			{
				label = "Fear Gong",
				path = "samples/fear_gong.wav"
			},
			{
				label = "FM Bell",
				path = "samples/fm_bell.wav"
			},
			{
				label = "Island",
				path = "samples/island_bells.wav"
			},
			{
				label = "Obelisk",
				path = "samples/obelisk_bell.wav"
			},
			{
				label = "Outland Bells",
				path = "samples/outland_bells.wav"
			}
		}
	},
	{
		id = "wood",
		label = "Wood",
		children = {
			{
				label = "Bright Marimba",
				path = "samples/bright_marimba.wav"
			},
			{
				label = "Dhalia",
				path = "samples/wood/dhalia.wav"
			},
			{
				label = "Formbar",
				path = "samples/wood/formbar.wav"
			},
			{
				label = "Metallofon",
				path = "samples/wood/metallofon.wav"
			},
		}
	},
	{
		id = "plucked",
		label = "Plucked",
		children = {
			{
				label = "Flange Harp",
				path = "samples/flange_harp.wav"
			},
			{
				label = "Guzheng",
				path = "samples/guzheng.wav"
			},
			{
				label = "Key",
				path = "samples/pluck_key.wav"
			},
			{
				label = "Shamisen",
				path = "samples/shamisen.wav"
			},
			{
				label = "Cave",
				path = "samples/cave_pluck.wav"
			},
			{
				label = "Lift Delay",
				path = "samples/lift_delay.wav"
			},
			{
				label = "Palm Guitar",
				path = "samples/palm_guitar.wav"
			}
		}
	},
	{
		id = "strings",
		label = "Strings",
		children = {
			{
				label = "Cruiser",
				path = "samples/cruiser_Strings.wav"
			},
			{
				label = "Feedback",
				path = "samples/feeback_strings.wav"
			},
			{
				label = "Magnetic",
				path = "samples/magnetic_strings.wav"
			},
			{
				label = "MTron",
				path = "samples/mtron_strings.wav"
			},
			{
				label = "Off World",
				path = "samples/off_world_strings.wav"
			},
			{
				label = "Synthetic",
				path = "samples/synthetic_strings.wav"
			},
			{
				label = "Synth Choir",
				path = "samples/synth_choir_strings.wav"
			},
			{
				label = "Stellar",
				path = "samples/stellar_strings.wav"
			}
		}
	},
}

function SampleSynthMod:init(x, y, modId)
	SampleSynthMod.super.init()
	
	if modId == nil then
		self.modId = "SampleSynthMod-" .. os.time() .. "_" .. math.random()
	else
		self.modId = modId
	end
	
	self.modType = modType
		
	self.isFocused = true
	
	self.categoryIndex = 1
	self.sampleIndex = 1
	
	self.component = SampleSynthCom(function() 

	end)

	self.width = 110
	self.height = 140
	
	self.x = x - self.width/2
	self.y = y - 15
	
	self.isFocusedCanvas = moduleCanvas(Colours.focusColour, Colours.focusColour, self.width + 3, self.height + 3, 7)
	
	self.socketInVector = Vector(16, self.height - 16)
	self.socketOutVector = Vector(self.width - 16, self.height - 16)
	
	self.gainEncoder = Encoder(self.width - 28, 8, 12, 0.66, encoderColour, Colours.white, function(value) 
		self.component:setGain(value)
		self:redrawCanvas()
	end)


	
	self:redrawCanvas()
end

function SampleSynthMod:redrawCanvas()
	self.canvas = moduleCanvas(Colours.defaultModBackground, Colours.defaultModBorder, self.width, self.height, 7)
	
	love.graphics.setCanvas(self.canvas)
	love.graphics.push()
	
	love.graphics.setColor(black()) 
	love.graphics.setLineWidth(1)	
	
	--draw synth category
	love.graphics.rectangle('line', 5, 53, self.width - 10, 24, 3)	
	local categoryName = presets[self.categoryIndex].label
	love.graphics.printf(categoryName, smallFont, self.width/2 - 50, 58, 100, 'center')
	
	--draw synth title
	love.graphics.rectangle('line', 5, 83, self.width - 10, 24, 3)	
	local sampleName = presets[self.categoryIndex].children[self.sampleIndex].label
	love.graphics.printf(sampleName, smallFont, self.width/2 - 50, 88, 100, 'center')
	
	love.graphics.printf("Gain", tinyFont, 93 - 30, 35, 60, 'center')

	love.graphics.pop()
	love.graphics.setCanvas()
	love.graphics.setColor(white()) 
	
	moduleSocket(self.canvas, self.socketInVector.x, self.socketInVector.y)
	moduleSocket(self.canvas, self.socketOutVector.x, self.socketOutVector.y)
	
	if self.gainEncoder ~= nil then
		self.gainEncoder:canvasDraw(self.canvas)
	end
end

function SampleSynthMod:move(dX, dY)
	self.x = self.x + dX
	self.y = self.y + dY
end

function SampleSynthMod:canScroll() 
	return true
end

function SampleSynthMod:scroll(oX, oY, dX, dY, gX, gY)
	if oY < (self.y + gY + 53) then
		self.gainEncoder:delta(dY)
		self.gainEncoder:canvasDraw(self.canvas)
	end
end 

function SampleSynthMod:click(x, y, gX, gY)
	if y > (self.y + gY + 53) and y < (self.y + gY + 78) then
		dropdown:show(self.x + gX, self.y + 30 + gY, self.width, presets, function(index) 
			if index ~= self.categoryIndex then
				self.categoryIndex = index
				self.sampleIndex = 1
				self.component:setSamplePath(presets[self.categoryIndex].children[self.sampleIndex].path)
				self:redrawCanvas()
			end
		end)
		return true
	elseif y > (self.y + gY + 83) and y < (self.y + gY + 108) then
		dropdown:show(self.x + gX, self.y + 83 + gY, self.width, presets[self.categoryIndex].children, function(index) 
			self.sampleIndex = index
			self.component:setSamplePath(presets[self.categoryIndex].children[self.sampleIndex].path)
			self:redrawCanvas()
		end)
		return true
	end
	
	return false
end

function SampleSynthMod:visible(xOffset, yOffset)
	return true
end

function SampleSynthMod:focus()
	self.isFocused = true
end

function SampleSynthMod:unfocus()
	self.isFocused = false
end

function SampleSynthMod:contains(x, y, gX, gY)
	local collision = inBounds(x, y, self.x + gX, self.y + gY, self.width, self.height)
	return collision
end

function SampleSynthMod:setInCable(cable)
	self.component:setInCable(cable)
end

function SampleSynthMod:setOutCable(cable)
	cable:setHostAudioModId(self.modId)
	self.component:setOutCable(cable)
end

function SampleSynthMod:soundSources()
	return self.component:soundSources()
end

function SampleSynthMod:tryConnectGhostOut(x, y, gX, gY, ghostCable)
	if self.component:outConnected() then
		return false
	else
		ghostCable:setStart(self.x + self.socketOutVector.x + gX, self.y + self.socketOutVector.y + gY)
		ghostCable:setGhostSendConnected()
		return true
	end
end

function SampleSynthMod:tryConnectGhostIn(x, y, gX, gY, ghostCable)
	if self.component:inConnected() then
		return false
	else
		ghostCable:setEnd(self.x + self.socketInVector.x + gX, self.y + self.socketInVector.y + gY)
		ghostCable:setGhostReceiveConnected()
		return true
	end
end

function SampleSynthMod:update(deltaTime)
	--noop
end

function SampleSynthMod:draw(xOffset, yOffset)
	if self:visible(xOffset, yOffset) then
		if showLabels then
			love.graphics.printf("Sample Synth", self.x + (self.width/2) + xOffset - 50, self.y + yOffset - 20, 100, 'center')
		end
		if self.isFocused then
			love.graphics.draw(self.isFocusedCanvas, self.x + xOffset - 1, self.y + yOffset - 1)
		end
		love.graphics.draw(self.canvas, self.x + xOffset, self.y + yOffset)
	end
end

