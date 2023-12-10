require "mouse"
require "modules/clock/bang_indicator/bang_indicator_mod"
require "modules/clock/bubble_chamber/bubble_chamber_mod"
require "modules/clock/clock/clock_mod"
require "modules/clock/clock_delay/clock_delay_mod"
require "modules/clock/clock_divider/clock_divider_mod"
require "modules/core/keyboard/keyboard_mod"
require "modules/core/bifurcate2/bifurcate2_mod"
require "modules/core/bifurcate4/bifurcate4_mod"
require "modules/core/blackhole/blackhole_mod"
require "modules/effects/chorus/chorus_mod"
require "modules/effects/compressor/compressor_mod"
require "modules/effects/delay/delay_mod"
require "modules/effects/distortion/distortion_mod"
require "modules/effects/flanger/flanger_mod"
require "modules/effects/reverb/reverb_mod"
require "modules/effects/ring_modulator/ring_modulator_mod"
require "modules/sample_synth/sample_synth_mod"
require "modules/sequencers/generative_small/generative_small_mod"
require "modules/sequencers/generative_std/generative_std_mod"
require "modules/sequencers/timed_switch/timed_switch_mod"

class('ViewManager').extends()

local isSliding = false

function ViewManager:init()
	ViewManager.super.init()
	
	self.globalXOffset = 0
	self.globalYOffset = 0
	
	self.ghostStartModuleIndex = -1
	self.ghostEndModuleIndex = -1
	
	self.stepSize = 1
	
	self.midiKeyboardFocused = false
	self.midiKeyboard = nil
	self.copyModType = nil
	self.moveView = nil
	self.mouseCaptureView = nil
	self.mouseCaptureX = -1
	self.mouseCaptureY = -1
	
	self.modules = {}
	self.cables = {}
	self.mouse = Mouse()
end

function ViewManager:keyboardFocused()
	return self.midiKeyboardFocused
end

function ViewManager:keyboardPlay(key)
	if self.midiKeyboard ~= nil then
		self.midiKeyboard:playKey(key)
	end
end

function ViewManager:keyboardStop(key)
	if self.midiKeyboard ~= nil then
		self.midiKeyboard:stopKey(key)
	end
end

function ViewManager:addChild(x, y, child)
	
	local module = nil
	
	if child.id == "clock_mod" then
		module = ClockMod(x - self.globalXOffset, y - self.globalYOffset, nil)
	elseif child.id == "BangIndicatorMod" then
		module = BangIndicatorMod(x - self.globalXOffset, y - self.globalYOffset, nil)
	elseif child.id == "SampleSynthMod" then
		module = SampleSynthMod(x - self.globalXOffset, y - self.globalYOffset, nil)
	elseif child.id == "GenerativeSmallMod" then
		module = GenerativeSmallMod(x - self.globalXOffset, y - self.globalYOffset, nil)
	elseif child.id == "GenerativeStdMod" then
		module = GenerativeStdMod(x - self.globalXOffset, y - self.globalYOffset, nil)
	elseif child.id == "BubbleChamberMod" then
		module = BubbleChamberMod(x - self.globalXOffset, y - self.globalYOffset, nil)
	elseif child.id == "ClockDelayMod" then
		module = ClockDelayMod(x - self.globalXOffset, y - self.globalYOffset, nil)
	elseif child.id == "ClockDividerMod" then
		module = ClockDividerMod(x - self.globalXOffset, y - self.globalYOffset, nil)
	elseif child.id == "KeyboardMod" then
		module = KeyboardMod(x - self.globalXOffset, y - self.globalYOffset, nil)
	elseif child.id == "ChorusMod" then
		module = ChorusMod(x - self.globalXOffset, y - self.globalYOffset, nil)
	elseif child.id == "ReverbMod" then
		module = ReverbMod(x - self.globalXOffset, y - self.globalYOffset, nil)
	elseif child.id == "DelayMod" then
		module = DelayMod(x - self.globalXOffset, y - self.globalYOffset, nil)
	elseif child.id == "DistortionMod" then
		module = DistortionMod(x - self.globalXOffset, y - self.globalYOffset, nil)
	elseif child.id == "CompressorMod" then
		module = CompressorMod(x - self.globalXOffset, y - self.globalYOffset, nil)
	elseif child.id == "Bifurcate2Mod" then
		module = Bifurcate2Mod(x - self.globalXOffset, y - self.globalYOffset, nil)
	elseif child.id == "Bifurcate4Mod" then
		module = Bifurcate4Mod(x - self.globalXOffset, y - self.globalYOffset, nil)
	elseif child.id == "BlackholeMod" then
		module = BlackholeMod(x - self.globalXOffset, y - self.globalYOffset, nil)
	elseif child.id == "TimedSwitchMod" then
		module = TimedSwitchMod(x - self.globalXOffset, y - self.globalYOffset, nil)
	elseif child.id == "FlangerMod" then
		module = FlangerMod(x - self.globalXOffset, y - self.globalYOffset, nil)
	elseif child.id == "RingModulatorMod" then
		module = RingModulatorMod(x - self.globalXOffset, y - self.globalYOffset, nil)
	end
	
	if module ~= nil then
		self:add(module)
	end
end

-- Returns a table of sound sources - modules may have more than one
function ViewManager:getSoundSources(modId)
	for i=1,#self.modules do
		local module = self.modules[i]
		if module.modId == modId then
			if module.soundSource ~= nil then
				return module:soundSources()
			end
			
			break
		end
	end
	
	return nil
end

function ViewManager:getOffset()
	return self.globalXOffset, self.globalYOffset
end

function ViewManager:setConfig(config)
	self.config = config
end

function ViewManager:add(view)
	table.insert(self.modules, view)
end

function ViewManager:clickDown(x, y)
	local handled = false
	for i=1,#self.modules do
		local view = self.modules[i]
		if view.clickDown ~= nil then
			if view:contains(x, y) then
				view:clickDown()
				handled = true
				
				if view.slide ~= nil then
					isSliding = true
				end
				break
			end
		end
	end
	return handled
end
-- 
-- function ViewManager:mousemoved(x, y, dx, dy, istouch)
-- 	 if isSliding == true then
-- 		if self.hoverView.slide ~= nil then self.hoverView:slide(x, y) end
-- 	else
-- 		if self:hoverClickable(x, y) then
-- 			self.mouse:hoverClickable()
-- 		else
-- 			self.mouse:reset()
-- 		end
-- 	end
-- end

function ViewManager:hoverClickable(x, y)
	local isHover = false
	for i=1,#self.modules do
		local view = self.modules[i]
			if view.clickUp ~= nil and view:contains(x, y) then
				self.hoverView = view
				isHover = true
				break
		end
	end
	
	return isHover
end

function ViewManager:tryPasteModule(x, y)
	if self.copyModType ~= nil then
		self:addChild(x, y, {
			id = self.copyModType
		})
	end
end

function ViewManager:tryCopyModule(x, y, onCopy)
	for i=1,#self.modules do
		local view = self.modules[i]
		if view.contains ~= nil and view:contains(x, y, self.globalXOffset, self.globalYOffset) then
			self.copyModType = view.modType
			onCopy("Copy: " .. self.copyModType)
		else
			--NOOP
		end
	end
end

function ViewManager:tryConnectGhostOut(ghostCable, x, y)
	for i=1,#self.modules do
		local view = self.modules[i]
		if view.contains ~= nil and view:contains(x, y, self.globalXOffset, self.globalYOffset) and view.tryConnectGhostOut ~= nil then
			local connectGhostOut = view:tryConnectGhostOut(x, y, self.globalXOffset, self.globalYOffset, ghostCable)
			if connectGhostOut then
				self.ghostStartModuleIndex = i
			end
			return connectGhostOut
		end
	end
	
	return false
end

function ViewManager:tryConnectGhostIn(ghostCable, x, y)
	for i=1,#self.modules do
		local view = self.modules[i]
			if view.contains ~= nil and view:contains(x, y, self.globalXOffset, self.globalYOffset) and view.tryConnectGhostIn ~= nil then
				local connectGhostIn = view:tryConnectGhostIn(x, y, self.globalXOffset, self.globalYOffset, ghostCable)
				if connectGhostIn then
					self.ghostEndModuleIndex = i
				end
				return connectGhostIn
		end
	end
	
	return false
end

function ViewManager:reifyGhost(concreteCable, x, y)
	local startModule = self.modules[self.ghostStartModuleIndex]
	concreteCable:setStartModId(startModule.modId)
	startModule:setOutCable(concreteCable)
	
	local endModule = self.modules[self.ghostEndModuleIndex]
	concreteCable:setEndModId(endModule.modId)
	endModule:setInCable(concreteCable)
	if concreteCable:getHostAudioModId() ~= nil and endModule.addToAudioSource ~= nil then
		local hostAudioMod = self:findModule(concreteCable:getHostAudioModId())
		logger:log("Adding effect to audio host: " .. concreteCable:getHostAudioModId())
		endModule:addToAudioSource(hostAudioMod)
	end
	table.insert(self.cables, concreteCable)
end

function ViewManager:findModule(modId)
	for i=1,#self.modules do
		local module = self.modules[i]
		if module.modId == modId then
			return module
		end
	end
	
	return nil
end



function ViewManager:tryGetCable(x, y)
	for i=1,#self.modules do
		local view = self.modules[i]
			if view.contains ~= nil and view:contains(x, y, self.globalXOffset, self.globalYOffset) and view.tryConnectGhostOut ~= nil then
				return view:tryConnectGhostOut(x, y, self.globalXOffset, self.globalYOffset)
		end
	end
	
	return -1, -1
end

function ViewManager:tryDropCable(x, y)
	for i=1,#self.modules do
		local view = self.modules[i]
			if view.contains ~= nil and view:contains(x, y, self.globalXOffset, self.globalYOffset) and view.tryConnectGhostIn ~= nil then
				return view:tryConnectGhostIn(x, y, self.globalXOffset, self.globalYOffset)
		end
	end
	
	return -1, -1
end

function ViewManager:move(deltaX, deltaY)
	self.globalXOffset = self.globalXOffset + deltaX
	self.globalYOffset = self.globalYOffset + deltaY
end

function ViewManager:left()
	self.globalXOffset = self.globalXOffset - self.stepSize
end

function ViewManager:right()
	self.globalXOffset = self.globalXOffset + self.stepSize
end

function ViewManager:up()
	self.globalYOffset = self.globalYOffset - self.stepSize
end

function ViewManager:down()
	self.globalYOffset = self.globalYOffset + self.stepSize
end

function ViewManager:upBy(amount)
	self.globalYOffset = self.globalYOffset - amount
end

function ViewManager:downBy(amount)
	self.globalYOffset = self.globalYOffset + amount
end

function ViewManager:leftBy(amount)
	self.globalXOffset = self.globalXOffset - amount
end

function ViewManager:rightBy(amount)
	self.globalXOffset = self.globalXOffset + amount
end

function ViewManager:clickModule(x, y)
	for i=1,#self.modules do
		local view = self.modules[i]
		if view.focus ~= nil then
			if view:contains(x, y, self.globalXOffset, self.globalYOffset) then
				if view.click ~= nil then
					local clickHandled = view:click(x, y, self.globalXOffset, self.globalYOffset)
					return clickHandled
				end
				break
			end
		end
	end
	
	return false
end

function ViewManager:captureMouseMove(x, y)
	
	for i=1,#self.modules do
		local view = self.modules[i]
		if view.focus ~= nil then
			if view:contains(x, y, self.globalXOffset, self.globalYOffset) then
				if view.canScroll and view:canScroll() then
					self.mouseCaptureView = view
					self.mouseCaptureX = x
					self.mouseCaptureY = y
					return true
				end
				break
			end
		end
	end
	
	return false
end

function ViewManager:captureMoveMod(x, y)
	for i=1,#self.modules do
		local view = self.modules[i]
		if view:contains(x, y, self.globalXOffset, self.globalYOffset) then
			logger:log("Found move view")
			self.moveView = view
			return true
		end
	end
	return false
end

function ViewManager:tryMoveMod(dX, dY)
	if self.moveView ~= nil and self.moveView.move ~= nil then
		self.moveView:move(dX, dY, function(inCables)
			if inCables ~= nil and #inCables > 0 then
				--todo - get cables and update end points by delta x and y
				for i=1,#inCables do
					
				end
			end
		end, function(outCables)
			if outCables ~= nil and #outCables > 0 then
				--todo - get cables and update start points by delta x and y
			end
		end)
	end
end

function ViewManager:tryMoveControl(x, y, dX, dY)
	if self.mouseCaptureView ~= nil and self.mouseCaptureView.scroll ~= nil then
		self.mouseCaptureView:scroll(self.mouseCaptureX, self.mouseCaptureY, dX, dY, self.globalXOffset, self.globalYOffset)
	end
end

function ViewManager:noCollision(x, y)
	local noCollide = true
	for i=1,#self.modules do
		local view = self.modules[i]
		if view.focus ~= nil then
			if view:contains(x, y, self.globalXOffset, self.globalYOffset) then
				noCollide = false
				break
			end
		end
	end
	return noCollide
end

function ViewManager:tryFocus(x, y, dx, dy)
	local handled = false
	for i=1,#self.modules do
		local view = self.modules[i]
		if view.focus ~= nil then
			if view:contains(x, y, self.globalXOffset, self.globalYOffset) then
				view:focus()
				handled = true
				if view.modType == "KeyboardMod" then
					self.midiKeyboardFocused = true
					self.midiKeyboard = view
				end
				break
			else
				--views that have focus must have unfocus
				view:unfocus()
				if view.modType == "KeyboardMod" then
					self.midiKeyboardFocused = false
					self.midiKeyboard = nil
				end
			end
		end
	end
	return handled
end


function ViewManager:clickUp(x, y)
	if isSliding == true then
		isSliding = false
	end
	
	local handled = false
	for i=1,#self.modules do
		local view = self.modules[i]
		if view.clickUp ~= nil then
			if view:contains(x, y) then
				view:clickUp()
				handled = true
				break
			end
		end
	end
	return handled
end

function ViewManager:updateViews(deltaTime)
	for i=1,#self.modules do
		if self.modules[i].update == nil then
			logger:log("" .. self.modules[i].modId .. " has no update method")
		else
			self.modules[i]:update(deltaTime)
		end
	end
end

function ViewManager:drawViews()
	for i=1,#self.modules do
		self.modules[i]:draw(self.globalXOffset, self.globalYOffset)
	end
	for i=1,#self.cables do
		self.cables[i]:draw(self.globalXOffset, self.globalYOffset)
	end
end