local Widget = require "widgets/widget"
local Text = require "widgets/text"
local Image = require "widgets/image"
local UIAnim = require "widgets/uianim"

local easing = require "easing"

local SCALE = 0.875
local HIDDEN_Y = 55.55555 * SCALE
local SHOWN_Y = -49.48571 * SCALE
local HEADER_SIZE = 30.5
local HEADER_WIDTH = 300
local NUMBER_SIZE = 24.71875 / SCALE
local METER_WIDTH = 490
local METER_HEIGHT = 20
local SCISSOR_WIDTH = METER_WIDTH + 10
local SCISSOR_HEIGHT = METER_HEIGHT + 10
local MOVE_TIME = 0.4
local METER_TINT_TIME = 0.5
local METER_BURST_TIME = 2
local BURST_ATTACK_WINDOW = 0.4
local OUT_OF_DATE_COLOUR = { 243 / 255, 95 / 255, 121 / 255, 1 }
local OUT_OF_DATE_DURATION = 10
local TINY_DAMAGE = 10
local HUGE_DAMAGE = 200
local MIN_LIGHTNESS = 0.2
local MAX_LIGHTNESS = 0.36667
local HUE_THRESH = 12 / 360

local DROPS_SCALE = 2
local DROPS_PRESETS = {}
for x = -200, 200, 50 do
	table.insert(DROPS_PRESETS, { pos = Vector3(x, GetRandomWithVariance(90, 7.5)), time = math.random() })
end

local TARGET_BIAS = 0.6
local ENGAGED_DIST = 20
local DISENGAGED_DIST = 30
local FRUSTUM_BIAS = 10
local FRUSTUM_LIMIT = 80
local DANGER_DURATION = 10
local DANGER_FADEOUT = 0.2
local DANGER_COOLDOWN = 1.5

local function RGBA(tint, alpha)
	return { r = tint[1] or 1, g = tint[2] or 1, b = tint[3] or 1, a = alpha or tint[4] or 1 }
end

--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

local VerticalRoot = Class(Widget, Widget._ctor)

function VerticalRoot:MoveTo(start, dest, duration)
	self.moving = true
	self.start = start
	self.dest = dest
	self.duration = duration
	self.time = 0
	self.gety = start.y < dest.y and easing.inOutCubic or easing.outCubic
	self:SetPosition(start)
	self:StartUpdating()
end

function VerticalRoot:CancelMoveTo()
	self.moving = false
	self:StopUpdating()
end

function VerticalRoot:OnUpdate(dt)
	self.time = self.time + dt
	if self.time < self.duration then
		self:SetPosition(0, self.gety(self.time, self.start.y, self.dest.y - self.start.y, self.duration))
	else
		self:SetPosition(0, self.dest.y)
		self:CancelMoveTo()
	end
end

--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

local Meter = Class(UIAnim, function(self)
	UIAnim._ctor(self)

	self:SetScissor(SCISSOR_WIDTH / -2, SCISSOR_HEIGHT / -2, SCISSOR_WIDTH, SCISSOR_HEIGHT)

	self:GetAnimState():SetBank("quagmire_hangry_bar")
	self:GetAnimState():SetBuild("epichealthbar")
	self:GetAnimState():PlayAnimation("bar", true)
	self:GetAnimState():AnimateWhilePaused(false)
end)

function Meter:SetTint(r, g, b)
	self.tint = { r, g, b, 1 }
	self:GetAnimState():SetMultColour(r, g, b, 1)
end

--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

local MeterOverlay = Class(Image, function(self, blendmode, percent)
	Image._ctor(self, "images/global.xml", "square.tex")

	self:SetBlendMode(blendmode)
	self:SetUVScale(1.5, 1.5)
	if percent ~= nil then
		self:SetPercent(percent)
	end
end)

function MeterOverlay:TintTo(start, dest, duration, whendone, delay)
	self:CancelTintTo()
	if delay == nil then
		Image.TintTo(self, start, dest, duration, whendone)
	else
		self.arg = { start, dest, duration, whendone }
		self.time = -delay
		self:StartUpdating()
	end
end

function MeterOverlay:CancelTintTo()
	Image.CancelTintTo(self)
	if self.arg ~= nil then
		self.arg = nil
		self:StopUpdating()
	end
end

function MeterOverlay:OnUpdate(dt)
	self.time = self.time + dt
	if self.time > 0 then
		self:TintTo(unpack(self.arg))
	end
end

function MeterOverlay:SetScissor(start, dest)
	local meter_width = METER_WIDTH * (start - dest)
	local meter_x = METER_WIDTH * (dest - 0.5) + meter_width / 2
	self:SetSize(meter_width, METER_HEIGHT)
	self:SetPosition(meter_x, 0)
end

function MeterOverlay:SetPercent(percent)
	self:SetScissor(1, percent)
end

--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

local MeterResist = Class(Widget, function(self)
	Widget._ctor(self, "MeterResist")

	self:SetScissor(SCISSOR_WIDTH / -2, SCISSOR_HEIGHT / -2, SCISSOR_WIDTH, SCISSOR_HEIGHT)

	self.alpha = 0.6
	self.time = 0
	self.delay = 0.5
	self.intensity = 1
	self.frequency = 750
	self.minspeed = 0
	self.maxspeed = 30
	self.speed = 0
	self._speed = 1

	self.img = self:AddChild(MeterOverlay(BLENDMODE.AlphaAdditive))
	self.img:SetSize(METER_WIDTH, METER_WIDTH)
	self.img:SetRotation(45)
	self.img:SetEffect("shaders/overheat.ksh")
	self.img:SetEffectParams(self.time, self.intensity, self.frequency, self._speed)

	self:Hide()
end)

MeterResist.OnShow = MeterResist.StartUpdating
MeterResist.OnHide = MeterResist.StopUpdating

function MeterResist:ShowResist(tint, resist)
	self.speed = Lerp(self.minspeed, self.maxspeed, resist)
	self.img:SetTint(tint[1], tint[2], tint[3], self.alpha)
	self.img:TintTo(RGBA(self.img.tint), RGBA(tint, 0), METER_BURST_TIME, nil, self.delay)
	self:Show()
end

function MeterResist:OnUpdate(dt)
	if self.img.tint[4] > 0 then
		self.time = self.time + self.speed * dt
		self.img:SetEffectParams(self.time, self.intensity, self.frequency, self._speed)
	else
		self:Hide()
	end
end

--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

local MeterDamage = Class(MeterOverlay, function(self)
	MeterOverlay._ctor(self, BLENDMODE.AlphaBlended)

	self.alpha = 0.8
	self.time = 0
	self.delay = 0.2
	self.minduration = 0.3
	self.maxduration = 1
	self.duration = 0

	self:Hide()
end)

MeterDamage.OnShow = MeterDamage.StartUpdating

function MeterDamage:OnHide()
	self.target = nil
	self:StopUpdating()
end

function MeterDamage:SetTint(r, g, b)
	Image.SetTint(self, r, g, b, self.alpha)
end

function MeterDamage:ShowBurst(start, dest, target)
	local reset = not self.shown or not target
	if target ~= nil then
		self.target = target
	end
	if reset then
		self.start = start
	end
	if reset or self.time <= 0 then
		self.time = -self.delay
	end
	self:Show()
	self:SetPercent(dest)
end

function MeterDamage:SetPercent(percent)
	if self.shown then
		if self.time <= 0 then
			self.dest = percent
			self.duration = Lerp(self.minduration, self.maxduration, self.start - self.dest)
		end
		self.percent = percent
		self:Refresh()
	end
end

function MeterDamage:Refresh()
	local time = Clamp(self.time, 0, self.duration)
	local current = easing.outCubic(time, self.start, self.dest - self.start, self.duration)
	if current > self.percent then
		self:SetScissor(current, self.percent)
	else
		self:Hide()
	end
end

function MeterDamage:OnUpdate(dt)
	if self.time <= 0 and self.target ~= nil and self.target.epichealth:IsBeingAttacked() then
		return
	end
	self.time = self.time + dt
	if self.time <= 0 then
		return
	elseif self.time < self.duration then
		self:Refresh()
	elseif self.dest > self.percent then
		self:ShowBurst(self.dest, self.percent)
	else
		self:Hide()
	end
end

--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

local MeterDrops = Class(Widget, function(self)
	Widget._ctor(self, "MeterDrops")

	self.width = METER_WIDTH / DROPS_SCALE
	self.height = METER_HEIGHT / DROPS_SCALE
	self.hiddentint = { 0, 0, 0, 0 }

	self:SetScale(DROPS_SCALE)
	self:SetScissor(self.width / -2, self.height / -2, self.width, self.height)

	self:Hide()
end)

function MeterDrops:ShowDrops(wet, instant, tint)
	if instant then
		self:CancelTintTo()
		if wet then
			self:Show()
			self:SetTint(tint[1], tint[2], tint[3], 1)
		else
			self:Hide()
		end
	elseif wet then
		self:Show()
		self:SetTint(unpack(self.tint))
		self:TintTo(RGBA(self.tint), RGBA(tint, 1), METER_TINT_TIME)
	elseif self.shown then
		self:TintTo(RGBA(self.tint), RGBA(self.hiddentint), METER_TINT_TIME, function() self:Hide() end)
	end
end

function MeterDrops:SetTint(r, g, b, a)
	self.tint = { r, g, b, a }
	for anim in pairs(self.children) do
		anim:GetAnimState():SetMultColour(1, 1, 1, a)
		anim:GetAnimState():SetAddColour(r, g, b, 1)
	end
end

function MeterDrops:OnShow()
	if next(self.children) == nil then
		for i, v in ipairs(DROPS_PRESETS) do
			local anim = self:AddChild(UIAnim())
			anim:SetScale(IsNumberEven(i) and 0.37 or -0.37, 0.37)
			anim:SetPosition(v.pos)
			anim:GetAnimState():SetBuild("paddle_over")
			anim:GetAnimState():SetBank("paddle_over")
			anim:GetAnimState():PlayAnimation("over", true)
			anim:GetAnimState():SetTime(anim:GetAnimState():GetCurrentAnimationLength() * v.time)
			anim:GetAnimState():AnimateWhilePaused(false)
		end
	end
end

function MeterDrops:OnHide()
	self:KillAllChildren()
	self:SetTint(unpack(self.hiddentint))
end

function MeterDrops:SetPercent(percent)
	self:SetScissor(self.width * (percent - 0.5), self.height / -2, self.width * (1 - percent), self.height)
end

--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

local PopupNumberFX = Class(Text, function(self, size, value, colour)
	Text._ctor(self, SMALLNUMBERFONT, size, value, colour)

	self.duration = 0.4

	self:TintTo(RGBA(colour), RGBA(colour, 0), self.duration)
	self:ScaleTo(1, 0, self.duration, function() self:Kill() end)
end)

PopupNumberFX.SetTint = PopupNumberFX.SetColour

local PopupNumber = Class(Widget, function(self, value, damaged, data)
	Widget._ctor(self, "PopupNumber")

	self.size = (data.burst or not damaged) and not data.huge and 42 or 44
	self.value = math.max(0.1, RoundBiasedUp(value, value < 1 and 1 or 0))

	self.alpha = 1
	self.colour = data.colour
	self.stimuli = data.stimuli
	if data.burst then
		self.colour = {}
		for i, v in ipairs(data.colour) do
			self.colour[i] = GetRandomWithVariance(v, 0.03)
		end
	end
	if data.stimuli == "electric" then
		self.colour1 = shallowcopy(self.colour)
		self.colour2 = self:AddColour(TUNING.EPICHEALTHBAR.ELECTRIC_ADDCOLOUR2)
		self.colour3 = self:AddColour(TUNING.EPICHEALTHBAR.ELECTRIC_ADDCOLOUR3)
		self.colour = data.wet and self:AddColour(TUNING.EPICHEALTHBAR.ELECTRIC_ADDCOLOUR1) or self.colour2
	end

	self.trail = data.burst
	self.pop = data.burst or data.huge or not damaged
	self.xoffs = GetRandomWithVariance(0, data.burst and 16 or 4)
	self.yoffs = GetRandomWithVariance(0, 10)
	self.dir = self.xoffs < 0 and -1 or 1
	self.rise = 8
	self.drop = damaged and 24 or -8
	self.speed = 68
	self.timescale = Clamp((damaged and 1000 or 100) / value, 0.3, 1)

	if data.burst then
		self.rise = GetRandomWithVariance(0, self.rise)
		self.drop = GetRandomMinMax(0, self.drop)
		self.speed = GetRandomMinMax(self.speed, 2 * self.speed)
	elseif data.huge then
		self.speed = GetRandomMinMax(self.speed, 1.5 * self.speed)
	end

	self.progress = 0
	self.xoffs2 = 0
	self.yoffs2 = 0
	self.fxroot = data.fxroot

	self.text = self:AddChild(Text(NUMBERFONT, self.size, self.value, self.colour))

	self:StartUpdating()
	self:OnUpdate(1 / 60)
end)

function PopupNumber:AddColour(addcolour)
	local colour = { [4] = self.alpha }
	for i, v in ipairs(addcolour) do
		if self.colour[i] + v > 1.1 then
			colour[i] = self.colour[i] - v / 2
		else
			colour[i] = self.colour[i] + v
		end
	end
	return colour
end

function PopupNumber:FastForward()
	if not self.killed then
		self.killed = true

		local colour = self.text.colour
		self.text.SetTint = self.text.SetColour
		self.text:TintTo(RGBA(colour), RGBA(colour, 0), 0.2, function() self:Kill() end)
	end
end

function PopupNumber:OnUpdate(dt)
	if self.progress < 1 then
		self.progress = math.min(1, self.progress + dt * 8)

		local k = 1 - math.min(1, self.progress / 0.75)
		k = k * k
		if not self.killed then
			self.alpha = 1 - k * k
			self.text:SetColour(self.colour[1], self.colour[2], self.colour[3], self.alpha)
		end

		k = 1 - self.progress
		k = k * k
		k = 1 - k * k
		self.xoffs2 = self.xoffs2 + dt * self.dir * self.speed
		self.yoffs2 = k * self.rise

		if self.pop then
			self:SetScale(2 - k)
		end
	elseif self.progress < 2 then
		dt = dt * self.timescale

		self.progress = math.min(2, self.progress + dt * 3)

		local k = math.max(0, self.progress - 1.1) / 0.9
		if not self.killed then
			if self.stimuli == "electric" then
				if self.progress <= 1.5 then
					local time = self.progress % 0.5
					if time <= 0.3 then
						self.colour = self.colour1
					elseif time <= 0.4 then
						self.colour = self.colour2
					else
						self.colour = self.colour3
					end
				else
					self.colour = self.colour1
				end
			end

			self.alpha = 1 - k * k
			self.text:SetColour(self.colour[1], self.colour[2], self.colour[3], self.alpha)
		end

		k = self.progress - 1
		self.xoffs2 = self.xoffs2 + dt * self.dir * self.speed
		self.yoffs2 = self.rise - self.drop * k * k
	else
		self:Kill()
		return
	end

	self.text:SetPosition(self.xoffs + self.xoffs2, self.yoffs + self.yoffs2)

	if self.trail and not self.killed and self.alpha > 0.5 then
		local colour = { self.colour[1], self.colour[2], self.colour[3], self.alpha / 2.5 }
		local fx = self.fxroot:AddChild(PopupNumberFX(self.size, self.value, colour))
		fx:SetPosition(self:GetPosition() + self.text:GetPosition())
	end
end

--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

local function hue(r, g, b)
	if type(r) == "table" then
		r, g, b = unpack(r)
	end
	local max = math.max(r, g, b)
	local min = math.min(r, g, b)
	local h = nil
	if max == min then
		return h
	elseif max == r then
		h = (g - b) / (max - min)
	elseif max == g then
		h = (b - r) / (max - min) + 2
	else
		h = (r - g) / (max - min) + 4
	end
	return h / 6 % 1
end

local function huediff(a, b)
	a = hue(a)
	b = hue(b)
	if a == nil or b == nil then
		return math.huge
	else
		return math.abs((a - b + 0.5) % 1 - 0.5)
	end
end

local function numberformat(value)
	local value, count = math.max(0, math.ceil(value))
	repeat value, count = string.gsub(value, "^(-?%d+)(%d%d%d)", "%1,%2") until count == 0
	return value
end

local function timeclamp(root, key, dt)
	if root[key] ~= nil then
		local time = root[key] - dt
		if time > 0 then
			root[key] = time
			return true
		else
			root[key] = nil
		end
	end
	return false
end

local function ondanger(self, danger, olddanger)
	if danger ~= olddanger then
		if danger ~= nil and olddanger ~= nil then
			self.dangercooldown = not danger and DANGER_COOLDOWN or nil
		else
			self.dangercooldown = nil
		end
	end
end

local function ontarget(self, target, oldtarget)
	if target ~= nil and target ~= oldtarget then
		self.outdatedtimeleft = nil
		self._name = nil
		self.build = nil
		self.wet = nil
		self.stimuli = nil
		self.lastwasdamagedtime = nil
		self.percent = nil
		self.maxhealth = nil
		self.currenthealth = nil
		self.theme = self:GetTuningValue("THEMES", target) or TUNING.EPICHEALTHBAR.METER_COLOUR
		self.introduration = self:GetIntroTimeLeft(target)
		self.introtimeleft = self.introduration

		for root in pairs(self.popuproot.children) do
			for popupnumber in pairs(root.children) do
				if popupnumber.FastForward ~= nil then
					popupnumber:FastForward()
				else
					break
				end
			end
		end
	end
end

local function onname(self, name, oldname)
	if name ~= nil and name ~= oldname then
		self.name_text:SetTruncatedString(tostring(name), HEADER_WIDTH, nil, true)
		self:ResetHeader()
	end
end

local function onwet(self, wet, oldwet)
	if wet ~= nil and wet ~= oldwet then
		local wet = wet and TUNING.EPICHEALTHBAR.WETNESS_METER
		local instant = oldwet == nil
		self.meter_drops:ShowDrops(wet, instant, self.metertint)
		self.meter_bg_drops:ShowDrops(wet, instant, self.bgtint)
	end
end

local function onbuild(self, build, oldbuild)
	if build ~= nil and build ~= oldbuild then
		local theme = shallowcopy(self.theme[build:upper()] or self.theme.GENERIC or self.theme)

		theme[4] = 1

		self.metertint = theme

		local lightness = (theme[1] + theme[2] + theme[3]) / 3
		if lightness >= MIN_LIGHTNESS then
			self.bgtint = TUNING.EPICHEALTHBAR.BACKGROUND_COLOUR1
			self.resisttint = theme

			if lightness >= MAX_LIGHTNESS then
				self.popuptint = theme
			else
				local mult = Remap(lightness, MIN_LIGHTNESS, MAX_LIGHTNESS, MAX_LIGHTNESS / MIN_LIGHTNESS, 1)
				self.popuptint = {}
				for i, v in ipairs(theme) do
					self.popuptint[i] = v * mult
				end
			end

			local damagetint = TUNING.EPICHEALTHBAR.DAMAGE_COLOUR1
			if huediff(theme, damagetint) < HUE_THRESH then
				damagetint = TUNING.EPICHEALTHBAR.DAMAGE_COLOUR2
			end
			self.damagetint = damagetint
		else
			self.bgtint = TUNING.EPICHEALTHBAR.BACKGROUND_COLOUR2
			self.resisttint = TUNING.EPICHEALTHBAR.DAMAGE_COLOUR1
			self.popuptint = TUNING.EPICHEALTHBAR.DAMAGE_COLOUR1
			self.damagetint = TUNING.EPICHEALTHBAR.DAMAGE_COLOUR1
		end

		if oldbuild == nil then
			self.meter:CancelTintTo()
			self.meter:SetTint(unpack(self.metertint))
			self.meter_bg:CancelTintTo()
			self.meter_bg:SetTint(unpack(self.bgtint))
			self.meter_damage:CancelTintTo()
			self.meter_damage:SetTint(unpack(self.damagetint))
		else
			self.meter:TintTo(RGBA(self.meter.tint), RGBA(self.metertint), METER_TINT_TIME)
			self.meter_bg:TintTo(RGBA(self.meter_bg.tint), RGBA(self.bgtint), METER_TINT_TIME)
			self.meter_damage:TintTo(RGBA(self.meter_damage.tint), RGBA(self.damagetint), METER_TINT_TIME)
			if self.wet then
				onwet(self, self.wet, not self.wet)
			end
		end
	end
end

local function onlastwasdamagedtime(self, lastwasdamagedtime, oldlastwasdamagedtime)
	if lastwasdamagedtime ~= oldlastwasdamagedtime then
		self.burst = lastwasdamagedtime ~= nil
			and oldlastwasdamagedtime ~= nil
			and lastwasdamagedtime - oldlastwasdamagedtime <= BURST_ATTACK_WINDOW
			or self.target.epichealth:IsGroupAttacked()
	end
end

local function onpercent(self, percent, oldpercent)
	if percent ~= nil and percent ~= oldpercent then
		self.meter_bg:SetPercent(percent)
		self.meter_bg_drops:SetPercent(percent)

		if oldpercent == nil then
			self.meter_resist:Hide()
			self.meter_damage:Hide()
			self.meter_burst:Hide()
		elseif oldpercent > percent then
			self.meter_damage:ShowBurst(oldpercent, percent, self.target)
		else
			self.meter_damage:SetPercent(percent)
			self:ShowBurst(oldpercent, percent)
		end
	end
end

local function onmaxhealth(self, maxhealth, oldmaxhealth)
	if maxhealth ~= nil and maxhealth ~= oldmaxhealth then
		self.maxhealth_text:SetString(numberformat(maxhealth))

		self:RebuildPhases()

		if oldmaxhealth ~= nil then
			if maxhealth > oldmaxhealth then
				self:ShowBurst(0, 1)
			else
				self:ShowBurst(1, 0)
			end
		end
	end
end

local function oncurrenthealth(self, currenthealth, oldcurrenthealth)
	if currenthealth ~= nil and currenthealth ~= oldcurrenthealth then
		self.currenthealth_text:SetString(numberformat(currenthealth))

		if oldcurrenthealth ~= nil and TUNING.EPICHEALTHBAR.DAMAGE_NUMBERS then
			if currenthealth ~= 0 then
				local delta = currenthealth - oldcurrenthealth
				self:ShowPopupNumber(math.abs(delta), delta < 0)
			elseif oldcurrenthealth > 0 then
				self:ShowPopupNumber(math.ceil(oldcurrenthealth), true)
			end
		end
	end
end

local function onoutdatedtimeleft(self, outdatedtimeleft, oldoutdatedtimeleft)
	if outdatedtimeleft ~= oldoutdatedtimeleft then
		local time = outdatedtimeleft or 0
		local percent = time / OUT_OF_DATE_DURATION

		onwet(self, false)
		onpercent(self, percent)
		onmaxhealth(self, time)
		oncurrenthealth(self, time)

		if oldoutdatedtimeleft == nil then
			self.meter:SetTint(unpack(OUT_OF_DATE_COLOUR))
			self.meter_bg:SetTint(unpack(TUNING.EPICHEALTHBAR.BACKGROUND_COLOUR1))
		end
		self.meter_resist:ShowResist(OUT_OF_DATE_COLOUR, -1)
	end
end

local function onintrotimeleft(self, introtimeleft, oldintrotimeleft)
	if self.percent ~= nil and self.currenthealth ~= nil then
		if introtimeleft ~= nil then
			if self.target ~= nil and self.target.epichealth.invincible then
				local time = self.introduration - introtimeleft
				local progress = easing.inOutCubic(time, 0, 1, self.introduration)

				onpercent(self, progress * self.percent)
				oncurrenthealth(self, progress * self.currenthealth)
			else
				self.introtimeleft = nil
			end
		elseif oldintrotimeleft ~= nil then
			onpercent(self, self.percent)
			oncurrenthealth(self, self.currenthealth)
		end
	end
end

local function OnTriggeredEvent(self, data)
	if data ~= nil and data.name ~= nil then
		self.triggeredevents[data.name] = data.duration or DANGER_DURATION
		if self.trigger ~= nil and not self:IsEventSource(self.trigger, data.name) then
			self._eventaliases[self.trigger.prefab] = data.name
		end
	end
end

local function OnEpicTargetResisted(self, data)
	if self:TargetIs(data.target) and TUNING.EPICHEALTHBAR.DAMAGE_RESISTANCE then
		self.meter_resist:ShowResist(self.resisttint, data.resist)
	end
end

local function OnEnableDynamicMusic(self, enable)
	self.dangerdisabled = not enable
end

local EpicHealthbar = Class(Widget, function(self, owner, version)
	Widget._ctor(self, "EpicHealthbar")

	self.owner = owner
	self.version = version
	self.triggeredevents = {}
	self._eventaliases = {}
	self._eventtriggers = {}

	self.root = self:AddChild(VerticalRoot("root"))
	self.root:SetScale(SCALE)
	self.root:SetPosition(0, HIDDEN_Y)

	local mouseover = self.root:AddChild(Image("images/ui.xml", "blank.tex"))
	mouseover:SetSize(350, 40)
	mouseover:SetPosition(0, 30)
	mouseover = self.root:AddChild(Image(mouseover.atlas, mouseover.texture))
	mouseover:SetSize(SCISSOR_WIDTH, SCISSOR_HEIGHT)
	mouseover = self.root:AddChild(Image(mouseover.atlas, mouseover.texture))
	mouseover:SetSize(110, 90)

	self.barroot = self.root:AddChild(Widget("barroot"))
	self.barroot:SetClickable(false)

	self.meter = self.barroot:AddChild(Meter())

	self.meter_resist = self.barroot:AddChild(MeterResist())

	self.meter_drops = self.barroot:AddChild(MeterDrops())

	self.meter_burst = self.barroot:AddChild(MeterOverlay(BLENDMODE.AlphaBlended))
	self.meter_burst:Hide()

	self.meter_bg = self.barroot:AddChild(MeterOverlay(BLENDMODE.Disabled, 1))

	self.meter_bg_drops = self.barroot:AddChild(MeterDrops())

	self.meter_damage = self.barroot:AddChild(MeterDamage())

	self.meter_highlight = self.barroot:AddChild(MeterOverlay(BLENDMODE.Additive, 0))
	self.meter_highlight:SetTint(1, 1, 1, 0.15)
	self.meter_highlight:Hide()

	self.meter_fg = self.barroot:AddChild(Image("images/hud/epichealthbar.xml", "meter_fg.tex"))
	self.meter_fg:SetSize(METER_WIDTH, METER_HEIGHT)

	self.frame = self.barroot:AddChild(Image("images/hud/epichealthbar.xml", "frame.tex"))
	self.frame:SetPosition(0, -2)
	self.frame:SetTint(unpack(TUNING.EPICHEALTHBAR.FRAME_COLOUR))

	self.frame_phases = self.barroot:AddChild(Widget("frame_phases"))
	self.frame_phases:SetPosition(0, 0.5)

	self.name_text = self.barroot:AddChild(Text(TALKINGFONT, HEADER_SIZE))
	self.name_text:SetPosition(1, 28)

	self.currenthealth_text = self.barroot:AddChild(Text(NUMBERFONT, NUMBER_SIZE))
	self.currenthealth_text:SetPosition(1.5, -29)

	self.maxhealth_text = self.barroot:AddChild(Text(self.currenthealth_text.font, self.currenthealth_text.size))
	self.maxhealth_text:SetPosition(self.currenthealth_text:GetPosition())
	self.maxhealth_text:Hide()

	self.popuproot = self:AddChild(Widget("popuproot"))
	self.popuproot:SetScale(SCALE)
	self.popuproot:SetClickable(false)

	self.popupfxroot = self.popuproot:AddChild(Widget("popupfxroot"))
	self.tinydamageroot = self.popuproot:AddChild(Widget("tinydamageroot"))
	self.damageroot = self.popuproot:AddChild(Widget("damageroot"))
	self.hugedamageroot = self.popuproot:AddChild(Widget("hugedamageroot"))

	self:Hide()

	self.inst:ListenForEvent("newepictarget", function(owner, target) self:StartUpdating() end, owner)
	self.inst:ListenForEvent("triggeredevent", function(owner, data) OnTriggeredEvent(self, data) end, owner)
	self.inst:ListenForEvent("epictargetresisted", function(owner, data) OnEpicTargetResisted(self, data) end, owner)
	self.inst:ListenForEvent("enabledynamicmusic", function(world, enable) OnEnableDynamicMusic(self, enable) end, TheWorld)

	if self:HasTargets() then
		self:StartUpdating()
	end
end,
{
	danger = ondanger,
	target = ontarget,
	_name = onname,
	build = onbuild,
	wet = onwet,
	lastwasdamagedtime = onlastwasdamagedtime,
	percent = onpercent,
	maxhealth = onmaxhealth,
	currenthealth = oncurrenthealth,
	outdatedtimeleft = onoutdatedtimeleft,
	introtimeleft = onintrotimeleft,
})

function EpicHealthbar:OnGainFocus()
	self:ResetHeader()
	self.currenthealth_text:Hide()
	self.maxhealth_text:Show()
	self.meter_highlight:Show()
end

function EpicHealthbar:OnLoseFocus()
	self:ResetHeader()
	self.currenthealth_text:Show()
	self.maxhealth_text:Hide()
	self.meter_highlight:Hide()
end

function EpicHealthbar:ResetHeader()
	if self.updatetext == nil then
		self.name_text:Show()
	elseif self.focus or self.target == nil then
		self.name_text:Hide()
		self.updatetext:Show()
	else
		self.name_text:Show()
		self.updatetext:Hide()
	end
end

function EpicHealthbar:MakeOutdated()
	if self.updateicon ~= nil then
		return
	end

	self.updateicon = self.barroot:AddChild(Image("images/frontend.xml", "circle_red.tex"))
	self.updateicon:SetScale(0.65)
	self.updateicon:MoveTo(Vector3(160, 60), Vector3(160, 30), MOVE_TIME)
	self.updateicon.icon = self.updateicon:AddChild(Image("images/button_icons.xml", "update.tex"))
	self.updateicon.icon:SetScale(0.15)
	self.updateicon.icon:SetPosition(-1, 0)

	local string = Tykvesh.Browse(STRINGS, "UI", "MAINSCREEN", "MOTD_NEW_UPDATE")
	if string ~= nil then
		self.updatetext = self.barroot:AddChild(Text(BODYTEXTFONT, HEADER_SIZE * 1.05, nil, OUT_OF_DATE_COLOUR))
		self.updatetext:SetTruncatedString(string:sub(0, string:find("\n")), HEADER_WIDTH, nil, true)
		self.updatetext:SetPosition(0, 32)
		self:ResetHeader()

		if not (self.active or TheNet:GetServerLANOnly()) then
			local PersistentData = require "utils/persistentdata"
			local OutdatedVersion = PersistentData("epichealthbar_version")

			if OutdatedVersion:Get() ~= self.version then
				OutdatedVersion:Set(self.version)

				self.outdatedtimeleft = OUT_OF_DATE_DURATION
				self:StartUpdating()
			end
		end
	end
end

function EpicHealthbar:RebuildPhases()
	self.frame_phases:KillAllChildren()

	if self.target ~= nil and TUNING.EPICHEALTHBAR.FRAME_PHASES then
		local phases = self:GetTuningValue("PHASES", self.target)
		if phases ~= nil then
			for i, v in ipairs(phases) do
				local phase = self.frame_phases:AddChild(Image(self.frame.atlas, "phase.tex"))
				phase:SetPosition(METER_WIDTH / -2 - 1.5 + (METER_WIDTH + 1) * v, 0)
				phase:SetTint(unpack(self.frame.tint))
			end
		end
	end
end

function EpicHealthbar:GetEffectTint(damaged, override)
	return (not damaged and TUNING.EPICHEALTHBAR.HEAL_COLOUR)
		or (self.stimuli == "fire" and TUNING.EPICHEALTHBAR.FIRE_COLOUR)
		or (override or TUNING.EPICHEALTHBAR.DAMAGE_COLOUR1)
end

function EpicHealthbar:ShowBurst(start, dest)
	local tint = self:GetEffectTint(start > dest, self.damagetint)
	self.meter_burst:SetScissor(start, dest)
	self.meter_burst:SetTint(tint[1], tint[2], tint[3], 0.8)
	self.meter_burst:TintTo(RGBA(self.meter_burst.tint), RGBA(tint, 0), METER_BURST_TIME, function() self.meter_burst:Hide() end)
	self.meter_burst:Show()
end

function EpicHealthbar:ShowPopupNumber(value, damaged)
	local huge = value >= HUGE_DAMAGE
	local parent = damaged and not huge and (value <= TINY_DAMAGE and self.tinydamageroot or self.damageroot) or self.hugedamageroot
	local pos = Vector3(METER_WIDTH * (self.percent - 0.5), self:GetHeight())
	local popupnumber = parent:AddChild(PopupNumber(value, damaged,
	{
		colour = self:GetEffectTint(damaged, self.popuptint),
		burst = damaged and self.burst,
		huge = huge,
		stimuli = damaged and self.stimuli or nil,
		wet = self.wet,
		fxroot = self.popupfxroot,
	}))
	if self:IsMoving() then
		popupnumber:MoveTo(pos, Vector3(pos.x, SHOWN_Y), MOVE_TIME)
	else
		popupnumber:SetPosition(pos)
	end
end

function EpicHealthbar:GetHeight()
	return self.root:GetPosition().y
end

function EpicHealthbar:IsMoving()
	return self.root.moving
end

function EpicHealthbar:IsTimeout()
	return self.timeleft == nil
end

function EpicHealthbar:HasTargets()
	return next(self.targets) ~= nil
end

function EpicHealthbar:TargetIs(target)
	return self.target == target
end

function EpicHealthbar:IsPriorityTarget(target)
	return self.target == target or self.target == nil
end

function EpicHealthbar:Appear()
	if not self.active then
		self.active = true
		self.root:MoveTo(self.root:GetPosition(), Vector3(0, SHOWN_Y), MOVE_TIME)
		self:Show()
	end
end

function EpicHealthbar:Disappear()
	if self.active then
		self.active = false
		self.root:MoveTo(self.root:GetPosition(), Vector3(0, HIDDEN_Y), MOVE_TIME)
	end

	if self.shown and not self:IsMoving() then
		for root in pairs(self.popuproot.children) do
			if next(root.children) ~= nil then
				return self:OnHide()
			end
		end
		self:Hide()
	end

	if not self.shown and not self:HasTargets() then
		self.triggeredevents = {}
		self.timeleft = nil
		self.danger = nil
		self.highlight = nil
		self:StopUpdating()
	end
end

EpicHealthbar.OnShow = EpicHealthbar.MoveToFront

function EpicHealthbar:OnHide()
	self.target = nil
end

function EpicHealthbar:IsInIntro(target)
	if target.epichealth.invincible and self:IsPriorityTarget(target) then
		local intros = self:GetTuningValue("INTROS", target)
		if intros ~= nil then
			for i, v in ipairs(intros) do
				if target.AnimState:IsCurrentAnimation(v) then
					return true
				end
			end
		end
	end
	return false
end

function EpicHealthbar:GetIntroTimeLeft(target)
	if self:IsInIntro(target) then
		return target.AnimState:GetCurrentAnimationLength() - target.AnimState:GetCurrentAnimationTime()
	end
end

function EpicHealthbar:IsEventSource(target, name)
	return target.prefab == name
		or target:HasTag(name)
		or self._eventaliases[target.prefab] == name
end

function EpicHealthbar:GetMusicTimeLeft(target, ignoretest)
	if target.epichealth:IsPlayingMusic() and (ignoretest or not self.dangerdisabled) then
		for name, time in pairs(self.triggeredevents) do
			if self:IsEventSource(target, name) then
				return time
			end
		end
	end
end

function EpicHealthbar:PushMusic(target)
	if self.dangercooldown == nil and not self.dangerdisabled and not TUNING.EPICHEALTHBAR.NOEPIC then
		self.dangercooldown = FRAMES

		if not target.epichealth:IsPlayingMusic() then
			if self._startdanger ~= false and (self.danger or self:IsNear(target, DISENGAGED_DIST)) then
				if self._startdanger == nil then
					local listeners = Tykvesh.Browse(TheWorld, "event_listening", "attacked", self.owner)
					if listeners ~= nil then
						for i, v in ipairs(listeners) do
							if Tykvesh.GetUpvalue(v, "StartDanger") then
								self._startdanger = v
								break
							end
						end
					end
				end

				self._startdanger = pcall(self._startdanger, self.owner, { attacker = target }) and self._startdanger
			end
		elseif self._eventtriggers[target.prefab] ~= false and not (target._playingmusic and self:GetMusicTimeLeft(target, true)) then
			self.trigger = target

			target._playingmusic = true

			if target._musictask ~= nil then
				self._eventtriggers[target.prefab] = pcall(target._musictask.fn, unpack(target._musictask.arg or {}))
			elseif self._eventtriggers[target.prefab] ~= true then
				local fn = self._eventtriggers[target.prefab]

				if fn == nil then
					fn = Tykvesh.GetUpvalue(Prefabs[target.prefab].fn, "PushMusic")

					if fn == nil then
						local name, upvalue = debug.getupvalue(Prefabs[target.prefab].fn, 1)
						if type(upvalue) == "function" then
							fn = Tykvesh.GetUpvalue(upvalue, "PushMusic")
						end
					end
				end

				self._eventtriggers[target.prefab] = pcall(fn, target) and fn
			end

			self.trigger = nil

			if target._playingmusic == false
				and target.epichealth.maxfrustumdist ~= FRUSTUM_LIMIT
				and target.entity:FrustumCheck() then

				local old = target.epichealth.maxfrustumdist or 0
				local new = TheCamera.currentpos:Dist(target:GetPosition()) + FRUSTUM_BIAS
				target.epichealth.maxfrustumdist = Clamp(new, old, FRUSTUM_LIMIT)
			end
		end
	end
end

function EpicHealthbar:GetDistance(target)
	return self.playerpos:Dist(target:GetPosition())
end

function EpicHealthbar:IsNear(target, dist)
	return self:GetDistance(target) <= dist
end

function EpicHealthbar:GetTuningValue(type, target)
	return FunctionOrValue(TUNING.EPICHEALTHBAR[type][target.prefab:upper()], target)
end

function EpicHealthbar:IsBusy(target)
	if target:HasTag("attack") then
		return false
	elseif target:HasTag("flight") then
		return target:HasTag("busy")
	elseif target:HasTag("noattack") then
		return (target.epichealth.invincible and not self:IsInIntro(target))
			or target:HasTag("NOCLICK")
			or not target:HasTag("locomotor")
	end
	return false
end

function EpicHealthbar:IsValidTarget(target)
	return self.targets[target]
		and (target:HasTag("epic") or TUNING.EPICHEALTHBAR.NOEPIC and not target:HasTag("INLIMBO"))
		and (target.epichealth.currenthealth > 0 and target.epichealth.maxhealth > (TUNING.EPICHEALTHBAR.NOEPIC and TINY_DAMAGE or HUGE_DAMAGE))
		and (target.replica.health ~= nil and not target.replica.health:IsDead())
		and target.replica.combat ~= nil
		and not self:IsBusy(target)
end

function EpicHealthbar:ProximityCheck(target)
	return self.highlight == target
		or target.entity:FrustumCheck()
		or (not target.epichealth:IsPlayingMusic() and self:TargetIs(target) and self:IsNear(target, DISENGAGED_DIST))
		or (target.epichealth.maxfrustumdist ~= nil and self:IsNear(target, target.epichealth.maxfrustumdist))
end

function EpicHealthbar:IsEngagedTarget(target)
	if not self:IsValidTarget(target) then
		return false
	elseif target._isengaged ~= nil and not target._isengaged:value() then
		return false
	elseif self:GetMusicTimeLeft(target, true) then
		return true
	end
	return self:ProximityCheck(target)
		and (self.danger or CanEntitySeeTarget(self.owner, target))
		and target.epichealth:TestForCombat()
end

function EpicHealthbar:GetNextTarget()
	if self:IsEngagedTarget(self.highlight) then
		return self.highlight
	elseif self.owner.replica.combat ~= nil and not self.owner:HasTag("playerghost") then
		local target = self.owner.replica.combat:GetTarget()
		if self:IsEngagedTarget(target) then
			return target
		end

		local act = self.owner:GetBufferedAction()
		if act ~= nil and act.action == ACTIONS.ATTACK and self:IsEngagedTarget(act.target) then
			return act.target
		end

		if self.owner.player_classified ~= nil then
			local target = self.owner.player_classified.lastcombattarget:value()
			local range = self.owner.replica.combat:GetAttackRangeWithWeapon() + TARGET_BIAS
			if self:IsEngagedTarget(target) and self:IsNear(target, range) then
				return target
			end
		end
	end

	local mindist = ENGAGED_DIST
	local closest = nil

	for target in pairs(self.targets) do
		if self:IsEngagedTarget(target) then
			local dist = self:GetDistance(target)
			local physdist = dist - target:GetPhysicsRadius(0)
			if physdist <= mindist or closest == nil
				and (target.epichealth:IsPlayingMusic() and not self.dangerdisabled
				or dist <= DISENGAGED_DIST and target.entity:FrustumCheck()) then

				mindist = physdist - TARGET_BIAS
				closest = target
			end
		end
	end

	if closest ~= nil then
		return closest
	elseif self:IsEngagedTarget(self.target) then
		return self.target
	end
end

function EpicHealthbar:OnUpdate(dt)
	self.refresh = false
	self.paused = TheNet:IsServerPaused()
	self.danger = TheFocalPoint.SoundEmitter:PlayingSound("danger")

	if not self.paused then
		timeclamp(self, "timeleft", dt)
		timeclamp(self, "dangercooldown", dt)
		for name in pairs(self.triggeredevents) do
			timeclamp(self.triggeredevents, name, dt)
		end
	end

	if self:HasTargets() then
		self.playerpos = self.owner:GetPosition()
		if self.owner.components.playercontroller ~= nil then
			self.highlight = self.owner.components.playercontroller.highlight_guy
		end

		local target = self:GetNextTarget()
		if target ~= nil then
			if self:IsPriorityTarget(target) or self:IsValidTarget(self.target) then
				self.target = target
				self.refresh = true
			end
			self:PushMusic(target)
			self.timeleft = (self:GetMusicTimeLeft(target) or DANGER_DURATION) + DANGER_FADEOUT
		end

		if self.target ~= nil and self.target:IsValid() then
			local epichealth = self.target.epichealth
			self._name = self.target:GetBasicDisplayName()
			self.build = self.target.AnimState:GetBuild()
			self.wet = self.target:GetIsWet()
			self.stimuli = epichealth.stimuli
			self.lastwasdamagedtime = epichealth.lastwasdamagedtime
			self.percent = math.max(0, epichealth.currenthealth / epichealth.maxhealth)
			self.maxhealth = epichealth.maxhealth
			self.currenthealth = epichealth.currenthealth
			if not self.paused then
				timeclamp(self, "introtimeleft", dt)
			end
		end
	end

	if self.refresh or timeclamp(self, "outdatedtimeleft", dt) then
		self:Appear()
	elseif not self:IsTimeout() and self:IsValidTarget(self.target) then
		self:Appear()
	else
		self:Disappear()
	end
end

return EpicHealthbar