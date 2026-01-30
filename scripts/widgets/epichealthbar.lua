local Widget = require "widgets/widget"
local Text = require "widgets/text"
local Image = require "widgets/image"
local UIAnim = require "widgets/uianim"

local easing = require "easing"
local PersistentData = require "utils/persistentdata"

local SCALE = 0.875
local HIDDEN_Y = 55.55555 * SCALE
local SHOWN_Y = -49.48571 * SCALE
local NUMBER_SIZE = 24.71875 / SCALE
local METER_WIDTH = 490
local METER_HEIGHT = 20
local MOVE_TIME = 0.4
local METER_TINT_TIME = 0.5
local METER_BURST_TIME = 2
local DROPS_PRESETS = {}
for x = -200, 200, 50 do
	table.insert(DROPS_PRESETS, { pos = Vector3(x, GetRandomWithVariance(90, 7.5)), time = math.random() })
end

local TARGET_BIAS = 0.6
local ENGAGED_DIST = 20
local DISENGAGED_DIST = 30
local DANGER_DURATION = 10
local DANGER_FADEOUT = 0.2
local DANGER_COOLDOWN = 1.5
local FOCUS_DURATION = 6

local ATTACK_RANGE = 12
local ATTACK_TIMEOUT = 2
local ATTACK_TAGS = { "attack" }

local function RGBA(tint, alpha)
	return { r = tint[1] or 1, g = tint[2] or 1, b = tint[3] or 1, a = alpha or tint[4] or 1 }
end

local function GetScissor()
	local size = TUNING.EPICHEALTHBAR.FRAME_COLOUR[4] < 1 and -0.5 or 10
	local width, height = METER_WIDTH + size, METER_HEIGHT + size
	return width / -2, height / -2, width, height
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

	self:SetScissor(GetScissor())

	self:GetAnimState():SetBank("quagmire_hangry_bar")
	self:GetAnimState():SetBuild("quagmire_hangry_bar")
	self:GetAnimState():SetSaturation(0)
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

	self:SetScissor(GetScissor())

	self.alpha = 0.75
	self.time = 0
	self.delay = 0.5
	self.intensity = 1
	self.frequency = 750
	self.minspeed = 5
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

local MeterDamage = Class(MeterOverlay, function(self, widget)
	MeterOverlay._ctor(self, BLENDMODE.AlphaBlended)

	self.widget = widget
	self.alpha = 0.8
	self.time = 0
	self.delay = 0.2
	self.minduration = 0.25
	self.maxduration = 1
	self.duration = 0

	self:Hide()
end)

MeterDamage.OnShow = MeterDamage.StartUpdating
MeterDamage.OnHide = MeterDamage.StopUpdating

function MeterDamage:SetTint(r, g, b)
	Image.SetTint(self, r, g, b, self.alpha)
end

function MeterDamage:ShowBurst(start, dest, reset)
	if not reset then
		reset = not self.shown
		self.lastwasdamagedtime = GetTime()
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

function MeterDamage:GetPlayerCount()
	local count = 0
	for i, v in ipairs(AllPlayers) do
		if self.widget:IsAttackedBy(self.widget.target, v) then
			count = count + 1
		end
	end
	local act = self.widget.owner.bufferedaction
	if act ~= nil and act.ispreviewing and act.target == self.widget.target and act.action == ACTIONS.ATTACK then
		count = math.max(1, count)
	end
	return count
end

function MeterDamage:IsSuspended()
	return self.time <= 0
			and self.widget:IsValid()
			and self.lastwasdamagedtime ~= nil
			and GetTime() - self.lastwasdamagedtime <= ATTACK_TIMEOUT
			and self:GetPlayerCount() == 1
end

function MeterDamage:OnUpdate(dt)
	if not self:IsSuspended() then
		self.time = self.time + dt
	end
	if self.time <= 0 then
		return
	elseif self.time < self.duration then
		self:Refresh()
	elseif self.dest > self.percent then
		self:ShowBurst(self.dest, self.percent, true)
	else
		self:Hide()
	end
end

--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

local MeterDrops = Class(Widget, function(self)
	Widget._ctor(self, "MeterDrops")

	self.scale = 2
	self.width = METER_WIDTH / self.scale
	self.height = METER_HEIGHT / self.scale
	self.hiddentint = { 0, 0, 0, 0 }

	self:SetScale(self.scale)
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
		local scale = 0.37
		for i, v in ipairs(DROPS_PRESETS) do
			local dir = IsNumberEven(i) and 1 or -1
			local anim = self:AddChild(UIAnim())
			anim:SetScale(scale * dir, scale)
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

local PopupNumber = Class(Widget, function(self, value, damaged, data)
	Widget._ctor(self, "PopupNumber")

	self.thresh = damaged and 200 or 100
	self.huge = value >= self.thresh
	self.burst = data.level ~= nil or not damaged
	self.colour = data.colour

	self.xoffs = GetRandomWithVariance(0, self.burst and 12 or 4)
	self.yoffs = GetRandomWithVariance(data.pos and 40 or 0, 10)
	self.dir = self.xoffs < 0 and -1 or 1
	self.rise = 8
	self.drop = damaged and 24 or -8
	self.speed = 68
	self.dtmod = Clamp(self.thresh / value, 0.3, 1)

	if data.pos then
		self.pos = data.pos
		self:SetScaleMode(SCALEMODE_PROPORTIONAL)
	elseif data.level then
		self.colour = self:MixColour(0.015 * data.level)
		self.speed = GetRandomMinMax(self.speed, 1.25 ^ data.level * self.speed)
	elseif self.huge then
		self.speed = GetRandomMinMax(self.speed, 1.5 * self.speed)
	end
	if data.stimuli == "electric" then
		self.colour1 = shallowcopy(self.colour)
		self.colour2 = self:AddColour(TUNING.EPICHEALTHBAR.ELECTRIC_ADDCOLOUR2)
		self.colour3 = self:AddColour(TUNING.EPICHEALTHBAR.ELECTRIC_ADDCOLOUR3)
		self.colour = data.wet and self:AddColour(TUNING.EPICHEALTHBAR.ELECTRIC_ADDCOLOUR1) or self.colour2
	end

	self.progress = 0
	self.xoffs2 = 0
	self.yoffs2 = 0

	self.text = self:AddChild(Text(NUMBERFONT, self:GetSize(value), self:RoundDown(value), self.colour))

	self:StartUpdating()
	self:OnUpdate(FRAMES / 2)
end)

function PopupNumber:GetSize(value)
	if self.pos then
		return Tykvesh.ClampRemap(value, 100, 400, 32, 40)
	else
		return self.burst and not self.huge and 42 or 44
	end
end

function PopupNumber:RoundDown(value)
	local mult = 10 ^ (value < 1 and 1 or 0)
	if not self.pos then
		value = value + 0.001
	end
	return math.max(0.1, math.floor(value * mult) / mult)
end

function PopupNumber:MixColour(variance)
	local colour = shallowcopy(self.colour)
	for i, v in ipairs(colour) do
		colour[i] = GetRandomWithVariance(v, variance)
	end
	return colour
end

function PopupNumber:AddColour(addcolour)
	local colour = shallowcopy(self.colour)
	for i, v in ipairs(addcolour) do
		if colour[i] + v < 1.1 then
			colour[i] = colour[i] + v
		else
			colour[i] = colour[i] - v / 2
		end
	end
	return colour
end

function PopupNumber:RefreshColour()
	if self.colour1 ~= nil then
		self.text.colour = self.progress < 1.3 and self.colour1
				or self.progress < 1.4 and self.colour2
				or self.progress < 1.5 and self.colour3
				or self.colour1
	end
end

function PopupNumber:FastForward()
	if not self.decay then
		self.decay = true
		self.text.SetTint = self.text.SetColour
		self.text:TintTo(RGBA(self.text.colour), RGBA(self.colour, 0), 0.2, function() self:Kill() end)
	end
end

function PopupNumber:OnUpdate(dt)
	if self.progress < 1 then
		self.progress = math.min(1, self.progress + dt * 8)

		if not self.decay then
			self.text:UpdateAlpha(1 - (1 - math.min(1, self.progress / 0.75)) ^ 4)
		end

		local k = 1 - (1 - self.progress) ^ 4
		self.yoffs2 = self.rise * k

		if self.burst or self.huge then
			self:SetScale(2 - k)
		end
	elseif self.progress < 2 then
		dt = dt * self.dtmod
		self.progress = math.min(2, self.progress + dt * 3)

		if not self.decay then
			self:RefreshColour()
			self.text:UpdateAlpha(1 - (math.max(0, self.progress - 1.1) / 0.9) ^ 2)
		end

		local k = (self.progress - 1) ^ 2
		self.yoffs2 = self.rise - self.drop * k
	else
		return self:Kill()
	end

	if self.pos ~= nil then
		self:SetPosition(TheSim:GetScreenPos(self.pos:Get()))
	end
	self.xoffs2 = self.xoffs2 + self.dir * self.speed * dt
	self.text:SetPosition(self.xoffs + self.xoffs2, self.yoffs + self.yoffs2)
end

--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

local ImageButton = require "widgets/imagebutton"

local MiniButton = Class(ImageButton, function(self, icon, red)
	ImageButton._ctor(self, "images/button_icons.xml", "circle.tex")

	self.scale = 0.65
	self.scale_on_focus = false
	self:SetScale(self.scale)
	self:SetTooltipPos(0, -30)

	self.hover_overlay = self.image:AddChild(Image(self.atlas, self.image_normal))
	self.hover_overlay:SetBlendMode(BLENDMODE.Additive)
	self.hover_overlay:SetTint(1, 1, 1, 0.125)
	self.hover_overlay:Hide()

	self.icon = self.image:AddChild(Image(self.atlas, icon))
	self.icon:SetScale(0.11)
	self.icon:SetPosition(-1.5, 3)

	if red then
		self:SetTextures("images/frontend.xml", "circle_red.tex")
	else
		self:SetImageNormalColour(TUNING.EPICHEALTHBAR.BUTTON_COLOUR)
		self:SetImageFocusColour(TUNING.EPICHEALTHBAR.BUTTON_COLOUR)
		self:SetImageSelectedColour(GREY)
	end
end)

function MiniButton:Show()
	self.shown = true
	self:SetScale(self.scale)
end

function MiniButton:Hide()
	self.shown = false
	self:SetScale(self.forced and self.scale or 0)
end

function MiniButton:Enable(enabled)
	if self.selected == enabled then
		if enabled then
			self:Unselect()
		else
			self:Select()
		end
	end
end

function MiniButton:SetForced(forced)
	self.forced = forced or nil
	if self.shown then
		self:Show()
	else
		self:Hide()
	end
end

function MiniButton:MakeFlash(flash)
	if flash then
		if self.flash == nil then
			self.flash = self:AddChild(UIAnim())
			self.flash:GetAnimState():SetBank("cookbook_newrecipe")
			self.flash:GetAnimState():SetBuild("cookbook_newrecipe")
			self.flash:GetAnimState():PlayAnimation("anim", true)
			self.flash:SetPosition(12, 12)
			self.flash:SetScale(0.75)
			self.flash:SetClickable(false)
			self:SetOnGainFocus(function() self.flash:SetScale(0) end)
		end
		self:SetForced(true)
		self.flash:Show()
	elseif self.flash ~= nil then
		self:SetForced(false)
		self.flash:Hide()
	end
end

--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

local ModConfigurationScreen = require "screens/redux/modconfigurationscreen"

local ConfigurationScreen = Class(ModConfigurationScreen, function(self, widget)
	ModConfigurationScreen._ctor(self, widget.modname, true)
	SetAutopaused(true)

	self:MakeDirty(false)

	self.inst:ListenForEvent("attacked", function(inst)
		self:MakeDirty(false)
		self:Cancel()
	end, widget.owner)

	self.inst:ListenForEvent("success", function(inst, settings)
		for i, v in ipairs(settings) do
			if TUNING.EPICHEALTHBAR[v.name] ~= nil then
				TUNING.EPICHEALTHBAR[v.name] = v.saved
			end
		end
		widget:LoadConfigurationOptions()
	end)
end)

function ConfigurationScreen:OnDestroy()
	SetAutopaused(false)
	self._base.OnDestroy(self)
end

function ConfigurationScreen:MakeServerReadOnly()
	for _, option in ipairs(self.config or {}) do
		if not option.client and #option.options > 1 then
			local data = TUNING.EPICHEALTHBAR[option.name]
			if data == nil then
				data = option.default
			end
			local options_locked = nil
			for i, v in ipairs(option.options) do
				if v.data == data then
					options_locked = { v }
					break
				end
			end
			for i, v in ipairs(self.options) do
				if v.options == option.options then
					v.options = options_locked or v.options
					v.default = data
					v.value = data
					break
				end
			end
		end
	end
end

function ConfigurationScreen:IsDefaultSettings()
	if self.started_default == nil then
		self:MakeServerReadOnly()
	end
	return self._base.IsDefaultSettings(self)
end

function ConfigurationScreen:Apply()
	if self:IsDirty() then
		self.inst:PushEvent("success", self:CollectSettings())
	end
	self._base.Apply(self)
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

local function ondanger(self, danger, olddanger)
	if danger ~= olddanger then
		if danger ~= nil and olddanger ~= nil and not danger then
			self:StartTimer("nodanger", DANGER_COOLDOWN)
		else
			self:StopTimer("nodanger")
		end
	end
end

local function onspectator(self, spectator, oldspectator)
	if spectator ~= oldspectator then
		ondanger(self, spectator, oldspectator)
		self.camera:MakeFlash(spectator and self.data:Get("camera") == nil)
		self:RefreshMenu()
	end
end

local function ontarget(self, target, oldtarget)
	if target ~= nil and target ~= oldtarget then
		self._name = nil
		self.build = nil
		self.wet = nil
		self.stimuli = nil
		self.percent = nil
		self.maxhealth = nil
		self.currenthealth = nil
		self.introduration = self:GetIntroTimeLeft(target)
		self:StartTimer("introtimeleft", self.introduration)
		self:KillPopupNumbers()
	end
end

local function onname(self, name, oldname)
	if name ~= oldname then
		self.name_text:SetString(name)
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
		local theme = self:GetTuningValue("THEMES", self.target) or TUNING.EPICHEALTHBAR.METER_COLOUR
		theme = shallowcopy(theme[build:upper()] or theme.GENERIC or theme)
		theme[4] = 1

		self.metertint = theme

		local brightness = math.max(theme[1], theme[2], theme[3])
		if brightness > TUNING.EPICHEALTHBAR.DARK_THRESH then
			self.bgtint = TUNING.EPICHEALTHBAR.BACKGROUND_COLOUR1
			self.resisttint = theme

			if brightness >= TUNING.EPICHEALTHBAR.POPUP_BRIGHTNESS then
				self.popuptint = theme
			else
				local mult = TUNING.EPICHEALTHBAR.POPUP_BRIGHTNESS / brightness
				self.popuptint = {}
				for i, v in ipairs(theme) do
					self.popuptint[i] = v * mult
				end
			end

			local damagetint = TUNING.EPICHEALTHBAR.DAMAGE_COLOUR1
			if huediff(theme, damagetint) < TUNING.EPICHEALTHBAR.HUE_THRESH then
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
			self:RefreshDrops()
		end
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
			self.meter_damage:ShowBurst(oldpercent, percent)
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
			self.stimuli = "health"
		end
	end
end

local function oncurrenthealth(self, currenthealth, oldcurrenthealth)
	if currenthealth ~= nil and currenthealth ~= oldcurrenthealth then
		self.currenthealth_text:SetString(numberformat(currenthealth))

		if oldcurrenthealth ~= nil and TUNING.EPICHEALTHBAR.DAMAGE_NUMBERS then
			if self.stimuli == "health" or self:TimerExists("introtimeleft") then
				--skip popups for max health and during intros
			elseif currenthealth ~= 0 then
				local delta = currenthealth - oldcurrenthealth
				self:ShowPopupNumber(math.abs(delta), delta < 0)
			elseif oldcurrenthealth > 0 then
				self:ShowPopupNumber(math.ceil(oldcurrenthealth), true)
			end
		end
	end
end

local function onintrotimeleft(self, introtimeleft, oldintrotimeleft)
	if self.percent ~= nil and self.currenthealth ~= nil then
		if introtimeleft ~= nil then
			if self.target ~= nil and self.target:HasTag("noattack") then
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
		self:StartTimer("notrigger", DANGER_COOLDOWN)
		self.triggeredevents[data.name] = data.duration or DANGER_DURATION
		self.triggeredlevel = data.level
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

local function OnGlobalPopupNumber(self, data)
	if not TUNING.EPICHEALTHBAR.DAMAGE_NUMBERS then
		return
	elseif data.stimuli == "redirected" and self.lastpopupnumber ~= nil then
		self.lastpopupnumber.pos = data.pos
		self.lastpopupnumber:OnUpdate(0)
	elseif data.target.entity:FrustumCheck() and CanEntitySeeTarget(self.owner, data.target) then
		data.colour = self.GetEffectTint(data, data.damaged)
		data.wet = data.target:GetIsWet()
		self.lastpopupnumber = self.owner.HUD:AddChild(PopupNumber(data.value, data.damaged, data)) --popupstats_root
	end
end

local function OnEnableDynamicMusic(self, enable)
	self.dangerdisabled = not enable
end

local EpicHealthbar = Class(Widget, function(self, owner, modinfo, modname)
	Widget._ctor(self, "EpicHealthbar")

	self.owner = owner
	self.modinfo = modinfo
	self.modname = modname
	self.data = PersistentData(self.name)
	self.timers = {}
	self.triggeredevents = {}
	self._eventaliases = {}
	self._eventtriggers = {}

	self.root = self:AddChild(VerticalRoot("root"))
	self.root:SetScale(SCALE)
	self.root:SetPosition(0, HIDDEN_Y)

	local mouseover = self.root:AddChild(Image("images/ui.xml", "blank.tex"))
	mouseover:SetSize(450, 40)
	mouseover:SetPosition(0, 30)
	mouseover = self.root:AddChild(Image(mouseover.atlas, mouseover.texture))
	mouseover:SetSize(110, 90)
	mouseover = self.root:AddChild(Image(mouseover.atlas, mouseover.texture))
	mouseover:SetSize(METER_WIDTH + 10, METER_HEIGHT + 10)
	mouseover:SetOnGainFocus(function() self:ShowMaxHealth() end)
	mouseover:SetOnLoseFocus(function() self:HideMaxHealth() end)

	self.barroot = self.root:AddChild(Widget("barroot"))
	self.barroot:SetClickable(false)

	self.meter = self.barroot:AddChild(Meter())

	self.meter_resist = self.barroot:AddChild(MeterResist())

	self.meter_drops = self.barroot:AddChild(MeterDrops())

	self.meter_burst = self.barroot:AddChild(MeterOverlay(BLENDMODE.AlphaBlended))
	self.meter_burst:Hide()

	self.meter_bg = self.barroot:AddChild(MeterOverlay(BLENDMODE.Disabled, 1))

	self.meter_bg_drops = self.barroot:AddChild(MeterDrops())

	self.meter_damage = self.barroot:AddChild(MeterDamage(self))

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

	self.name_text = self.barroot:AddChild(Text(TALKINGFONT, 30.5))
	self.name_text:SetPosition(1, 28)
	self.name_text:SetRegionSize(345, 45)

	self.currenthealth_text = self.barroot:AddChild(Text(NUMBERFONT, NUMBER_SIZE))
	self.currenthealth_text:SetPosition(1.5, -29)

	self.maxhealth_text = self.barroot:AddChild(Text(NUMBERFONT, NUMBER_SIZE))
	self.maxhealth_text:SetPosition(self.currenthealth_text:GetPosition())
	self.maxhealth_text:Hide()

	self.menu = self.root:AddChild(Widget("menu"))
	self.menu:SetPosition(METER_WIDTH / 2 * 0.75, 30)

	self.camera = self.menu:AddChild(MiniButton("movie.tex"))
	self.camera:SetOnClick(function() self:ToggleCamera() end)
	self.camera:Hide()

	self.config = self.menu:AddChild(MiniButton("configure_mod.tex"))
	self.config:SetOnClick(function() self:ShowConfigurationScreen() end)
	self.config:SetTooltip(STRINGS.UI.MODSSCREEN.CONFIGUREMOD)
	self.config:SetPosition(30, 0)
	self.config:Hide()

	self.popuproot = self:AddChild(Widget("popuproot"))
	self.popuproot:SetScale(SCALE)
	self.popuproot:SetClickable(false)

	self.damageroot = self.popuproot:AddChild(Widget("damageroot"))
	self.healroot = self.popuproot:AddChild(Widget("healroot"))

	self:Hide()

	self.inst:ListenForEvent("newepictarget", function(owner, target) self:StartUpdating() end, owner)
	self.inst:ListenForEvent("triggeredevent", function(owner, data) OnTriggeredEvent(self, data) end, owner)
	self.inst:ListenForEvent("epictargetresisted", function(owner, data) OnEpicTargetResisted(self, data) end, owner)
	self.inst:ListenForEvent("enabledynamicmusic", function(world, enable) OnEnableDynamicMusic(self, enable) end, TheWorld)

	if TUNING.EPICHEALTHBAR.CAPTURE then
		self:MakeCaptureMode()
	elseif TUNING.EPICHEALTHBAR.GLOBAL_NUMBERS then
		self.popuproot:Hide()
		self.inst:ListenForEvent("epicpopupnumber", function(owner, data) OnGlobalPopupNumber(self, data) end, owner)
	end
	if self:HasTargets() then
		self:StartUpdating()
	end
end,
		{
			danger = ondanger,
			spectator = onspectator,
			target = ontarget,
			_name = onname,
			build = onbuild,
			wet = onwet,
			percent = onpercent,
			maxhealth = onmaxhealth,
			currenthealth = oncurrenthealth,
			introtimeleft = onintrotimeleft,
		})

function EpicHealthbar:ShowMaxHealth()
	self.currenthealth_text:Hide()
	self.maxhealth_text:Show()
	self.meter_highlight:Show()
end

function EpicHealthbar:HideMaxHealth()
	self.currenthealth_text:Show()
	self.maxhealth_text:Hide()
	self.meter_highlight:Hide()
end

function EpicHealthbar:OnGainFocus()
	if not self:IsTimeout() then
		if self:CanFocusCamera() then
			self.camera:Show()
		end
		if self.modinfo.configuration_options ~= nil then
			self.config:Show()
		end
	end
end

function EpicHealthbar:OnLoseFocus()
	self.camera:Hide()
	self.config:Hide()
end

function EpicHealthbar:MakeCaptureMode()
	self:SetScale(0)

	if not TheNet:GetIsServerAdmin() then return end

	local SavedCaptures = PersistentData("epichealthbar_captures", true)

	local function addsetter(t, k, fn)
		local _ = rawget(t, "_")
		local p = _[k]
		if p == nil then
			_[k] = { t[k], fn }
			rawset(t, k, nil)
		else
			Tykvesh.Parallel(p, 2, fn)
		end
	end

	local capture = nil
	local lastupdate = nil

	addsetter(self, "timeleft", function(self, timeleft)
		if timeleft ~= nil then
			if capture == nil then
				capture = { session = TheWorld.meta.session_identifier, day = math.ceil(TheWorld.state.cycles + TheWorld.state.time), start = GetTime(), timeline = {} }
				lastupdate = capture.start

				if self.captureicon == nil then
					self.captureicon = self.owner.HUD.controls.bottomright_root:AddChild(Image("images/button_icons.xml", "movie.tex"))
					self.captureicon:SetScale(0.15)
					self.captureicon:SetPosition(-60, 60)
					self.captureicon:SetClickable(false)
				end
				self.captureicon:TintTo(RGBA(WHITE, 5), RGBA(WHITE, 0), 3, function() self.captureicon:Hide() end)
				self.captureicon:Show()
			end
		elseif capture ~= nil then
			local names = {}
			for index, event in ipairs(capture.timeline) do
				if type(event) == "table" and event[1] == "_name" and not table.contains(names, event[2]) then
					table.insert(names, event[2])
				end
			end
			capture.name = table.concat(names, ", ")
			capture.length = lastupdate - capture.start
			capture.start = nil

			local captures = SavedCaptures:Get()
			table.insert(captures, capture)
			SavedCaptures:Set(captures)

			capture = nil
		end
	end)

	self.inst:ListenForEvent("onremove", function() self:StopCapture() end)

	if EpicHealthbar._simreset ~= true then
		EpicHealthbar._simreset = true

		Tykvesh.Parallel(_G, "SimReset", function(params)
			local widget = Tykvesh.Browse(ThePlayer, "HUD", "controls", "epichealthbar")
			if widget ~= nil then
				widget:StopCapture()
			end
		end)
	end

	local function addevent(key, value)
		if capture ~= nil then
			local time = GetTime()
			if lastupdate ~= time then
				table.insert(capture.timeline, time - lastupdate)
				lastupdate = time
			end
			table.insert(capture.timeline, { key, value })
		end
	end

	addsetter(self, "target", function(self, target, oldtarget)
		if target ~= nil and target ~= oldtarget then
			addevent("target", target.prefab)
		end
	end)

	Tykvesh.Sequence(self.meter_damage, "IsSuspended", function(suspended)
		self.suspended = suspended
	end)

	local setters =
	{
		"_name",
		"build",
		"wet",
		"stimuli",
		"burst",
		"percent",
		"maxhealth",
		"currenthealth",
		"active",
		"suspended",
	}

	for _, key in ipairs(setters) do
		addsetter(self, key, function(self, value, oldvalue)
			if value ~= oldvalue then
				addevent(key, value)
			end
		end)
	end
end

function EpicHealthbar:StopCapture()
	if self.active then
		self.active = false
		self:StopTimer("timeleft")
	end
end

function EpicHealthbar:ShowConfigurationScreen()
	if self.modinfo.configuration_options ~= nil then
		TheFrontEnd:PushScreen(ConfigurationScreen(self))
	end
end

function EpicHealthbar:LoadConfigurationOptions()
	self:SetPosition(TUNING.EPICHEALTHBAR.HORIZONTAL_OFFSET, 0)
	self:RebuildPhases()
	self:RefreshDrops()
	self:OnShow()
end

function EpicHealthbar:RebuildPhases()
	self.frame_phases:KillAllChildren()

	if self.target ~= nil and TUNING.EPICHEALTHBAR.FRAME_PHASES then
		local phases = self:GetTuningValue("PHASES", self.target)
		if phases ~= nil then
			for i, v in ipairs(phases) do
				local phase = self.frame_phases:AddChild(Image(self.frame.atlas, "phase.tex"))
				phase:SetPosition(METER_WIDTH * (v - 0.5), 0)
				phase:SetTint(unpack(self.frame.tint))
			end
		end
	end
end

function EpicHealthbar:RefreshDrops()
	if self.wet then
		onwet(self, true, false)
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
	local parent = damaged and self.damageroot or self.healroot
	local pos = Vector3(METER_WIDTH * (self.percent - 0.5), self:GetHeight())
	local level = nil
	for popupnumber in pairs(parent.children) do
		if popupnumber.progress < 1.75 then
			level = (level or 0) + 1
		end
	end
	local popupnumber = parent:AddChild(PopupNumber(value, damaged,
			{
				level = level and math.min(5, level),
				colour = self:GetEffectTint(damaged, self.popuptint),
				stimuli = damaged and self.stimuli or nil,
				wet = self.wet,
			}))
	if self:IsMoving() then
		popupnumber:MoveTo(pos, Vector3(pos.x, SHOWN_Y), MOVE_TIME)
	else
		popupnumber:SetPosition(pos)
	end
end

function EpicHealthbar:HasPopupNumbers()
	for root in pairs(self.popuproot.children) do
		if next(root.children) ~= nil then
			return true
		end
	end
	return false
end

function EpicHealthbar:KillPopupNumbers()
	for root in pairs(self.popuproot.children) do
		for popupnumber in pairs(root.children) do
			popupnumber:FastForward()
		end
	end
end

function EpicHealthbar:GetHeight()
	return select(2, self.root:GetPositionXYZ())
end

function EpicHealthbar:IsMoving()
	return self.root.moving
end

function EpicHealthbar:IsTimeout()
	return self.timeleft == nil
end

function EpicHealthbar:IsEpic()
	return not TUNING.EPICHEALTHBAR.GLOBAL or TUNING.EPICHEALTHBAR.TAG == "EPIC"
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

function EpicHealthbar:IsValid()
	return self:IsValidTarget(self.target)
end

function EpicHealthbar:Appear()
	if not self.active then
		self.active = true
		self.root:MoveTo(self.root:GetPosition(), Vector3(0, SHOWN_Y), MOVE_TIME)
		self:Show()
	end

	if self.focus then
		self:RefreshMenu()
	end
end

function EpicHealthbar:Disappear()
	if self.active then
		self.active = false
		self.root:MoveTo(self.root:GetPosition(), Vector3(0, HIDDEN_Y), MOVE_TIME)
	end

	if self.shown and not self:IsMoving() then
		if self:HasPopupNumbers() then
			return self:OnHide()
		end
		self:Hide()
	end

	if not self.shown and not self:HasTargets() then
		self.triggeredevents = {}
		self.danger = nil
		self.highlight = nil
		self:StopTimer("timeleft")
		self:StopUpdating()
	end
end

function EpicHealthbar:OnShow()
	if self.data:Get("camera") then
		self:FocusCamera(true)
	end
	if self:TimerExists("introtimeleft") then
		self:UpdateTimer("introtimeleft", 0)
	end
	self:MoveToFront()
end

function EpicHealthbar:OnHide()
	self.target = nil
	self:StopTimer("notarget")
end

function EpicHealthbar:IsInIntro(target)
	if target:HasTag("noattack") and self:IsPriorityTarget(target) then
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
	if not self.active and self:IsInIntro(target) then
		return target.AnimState:GetCurrentAnimationLength() - target.AnimState:GetCurrentAnimationTime()
	end
end

function EpicHealthbar:IsPlayingMusic(target)
	return target._playingmusic ~= nil or target._musictask ~= nil
end

function EpicHealthbar:IsEventSource(target, name)
	return target.prefab == name
			or target:HasTag(name)
			or self._eventaliases[target.prefab] == name
end

function EpicHealthbar:GetMusicTimeLeft(target, force)
	if self:IsPlayingMusic(target) then
		if not force and (self.dangerdisabled or target.epichealth.overridefrustum) then
			return nil
		end
		for name, time in pairs(self.triggeredevents) do
			if self:IsEventSource(target, name) then
				return time
			end
		end
		if force and target._playingmusic ~= false and next(self.triggeredevents) ~= nil then
			return self:PushMusic(target, force)
		end
	end
end

function EpicHealthbar:PushMusic(target, force)
	if not self:TimerExists("nodanger") and not self.dangerdisabled and self:IsEpic() or force then
		self:StartTimer("nodanger", DANGER_FADEOUT)

		if not self:IsPlayingMusic(target) then
			if self._startdanger ~= false and (self.danger or self:IsNear(target, DISENGAGED_DIST)) then
				if self._startdanger == nil then
					for i, fn in ipairs(Tykvesh.Browse(TheWorld, "event_listening", "attacked", self.owner) or {}) do
						if Tykvesh.GetUpvalue(fn, "StartDanger") then
							self._startdanger = fn
							break
						end
					end
				end

				self._startdanger = pcall(self._startdanger, self.owner, { attacker = target }) and self._startdanger
			end
		elseif not self:TimerExists("notrigger") or force then
			local value = self._eventtriggers[target.prefab]
			if value == false then
				return
			end

			local _playingmusic = target._playingmusic
			if type(_playingmusic) == "boolean" then
				target._playingmusic = target
			end
			self.trigger = target

			if target._musictask ~= nil then
				self._eventtriggers[target.prefab] = pcall(target._musictask.fn, target)
			elseif value ~= true then
				if value == nil then
					value = Tykvesh.GetUpvalue(Prefabs[target.prefab].fn, "PushMusic")

					if value == nil and target.pendingtasks ~= nil then
						for task in pairs(target.pendingtasks) do
							if task.period == 1 and task.limit == nil and GetTableSize(task.arg) == 1 then
								local function __index(t, k)
									if k == "_playingmusic" then
										value = task.fn
									end
									return self.owner[k]
								end
								pcall(task.fn, setmetatable({}, { __index = __index, __newindex = __index }))
								break
							end
						end
					end
				end

				self._eventtriggers[target.prefab] = pcall(value, target) and value
			end

			if target._playingmusic == target then
				target._playingmusic = _playingmusic
			end
			self.trigger = nil

			if force then
				return self.triggeredevents[self._eventaliases[target.prefab]]
			elseif self.spectator then
				if self.danger then
					self.owner:PushEvent("triggeredevent", { level = self.triggeredlevel })
				end
			elseif target.epichealth.overridefrustum ~= true and target._playingmusic == false and target.entity:FrustumCheck() then
				target.epichealth.overridefrustum = true
			end
		end
	end
end

function EpicHealthbar:GetIsSpectator()
	for i = 1, 4 do
		if self.owner.AnimState:IsCurrentAnimation("emote_loop_sit" .. i) then
			return true
		end
	end
	return self.owner:HasAnyTag("hiding", "sitting_on_chair", "debugnoattack")
			and (self.spectator or not self.owner:HasTag("busy"))
end

function EpicHealthbar:RefreshMenu()
	if not self.camera.shown or self.owner:HasTag("busy") then
		return
	elseif TheFocalPoint.components.focalpoint:IsFocusBlocked(self.inst) or TheFocalPoint ~= TheCamera.target then
		self.camera:Enable(false)
		self.camera:SetTooltip(self:GetLocalizedString("CAMERA_BUTTON_BUSY", "Not Available!"))
	elseif self.spectator then
		self.camera:Enable(true)
		self.camera:SetTooltip(self:GetLocalizedString("CAMERA_BUTTON_ALT", "Toggle Spectator Camera"))
	elseif self.target ~= nil and not self:IsNear(self.target, TUNING.EPICHEALTHBAR.CAMERA_FOCUS_MIN) then
		self.camera:Enable(false)
		self.camera:SetTooltip(self:GetLocalizedString("CAMERA_BUTTON_FAR", "Too Far!"))
	else
		self.camera:Enable(true)
		self.camera:SetTooltip(self:GetLocalizedString("CAMERA_BUTTON", "Toggle Combat Camera"))
	end
end

function EpicHealthbar:ToggleCamera(enable)
	if enable == nil then
		enable = not self.data:Get("camera")
	end
	self.data:Set("camera", enable)
	self:FocusCamera(enable)
end

function EpicHealthbar:FocusCamera(enable)
	if TheFocalPoint == nil then
		return
	elseif enable and self:IsEpic() and not TUNING.EPICHEALTHBAR.CAPTURE then
		TheFocalPoint.components.focalpoint:StartFocusSource(self.inst, "FIXED", self.owner, TUNING.EPICHEALTHBAR.CAMERA_FOCUS_MIN, TUNING.EPICHEALTHBAR.CAMERA_FOCUS_MAX, TUNING.EPICHEALTHBAR.CAMERA_PRIORITY, { ActiveFn = function(params) self.camerafocus = setmetatable({}, { __mode = "k" }); params.nofocus, params.count = 0, 0 end, UpdateFn = function(...) self:UpdateFocus(...) end })
	else
		TheFocalPoint.components.focalpoint:StopFocusSource(self.inst)
	end
end

function EpicHealthbar:PushFocus(target, time)
	if self.camerafocus ~= nil then
		self.camerafocus[target] = time
		return time
	end
end

function EpicHealthbar:HasFocus(target)
	return self.camerafocus ~= nil and self.camerafocus[target]
end

function EpicHealthbar:CanFocusTarget(target, dist)
	if self:TargetIs(target) then
		return (self:IsNear(target, dist) or self.spectator)
				and self:PushFocus(target, self.active and FOCUS_DURATION or nil)
	elseif not (self:IsNear(target, dist) and self:IsValidTarget(target)) then
		return false
	elseif self:InCombat(target) and self.active then
		return self:PushFocus(target, FOCUS_DURATION)
	end
	return self:HasFocus(target)
end

function EpicHealthbar:CanFocusPlayer(player, dist, targets)
	if player == self.owner then
		return false
	elseif not (self:IsNear(player, dist) and self:IsValidPlayer(player)) then
		return false
	elseif targets[player.replica.combat:GetTarget()] then
		return self:PushFocus(player, DANGER_DURATION)
	end
	for target, other in pairs(targets) do
		if other == player then
			return self:PushFocus(player, DANGER_DURATION)
		end
	end
	return self:HasFocus(player)
end

function EpicHealthbar:HasDebuff(target, name)
	if target.components.debuffable ~= nil then
		return target.components.debuffable:HasDebuff(name)
	end
	local pos = target:GetPosition()
	for i, v in ipairs(TheSim:FindEntities(pos.x, 0, pos.z, 5)) do
		if v.prefab == name and v.entity:GetParent() == target then
			return true
		end
	end
	return false
end

function EpicHealthbar:CanFocusCamera()
	return self:IsValidPlayer(self.owner)
			and self.owner.HUD.controls.craftingandinventoryshown
			and not self:HasDebuff(self.owner, "sporebomb")
			and self:IsEpic()
end

function EpicHealthbar:UpdateFocus(dt, params)
	if self.owner.components.playercontroller ~= nil then
		if not self:CanFocusCamera() then
			params.nofocus = 0.1
		elseif params.nofocus and not self.owner:HasTag("busy") then
			self.UpdateTimer(params, "nofocus", dt)
		end
		for target in pairs(self.camerafocus) do
			self.UpdateTimer(self.camerafocus, target, dt)
		end
	end

	local offset = Vector3(0, 1.5, 0)
	local count = 0

	if not params.nofocus then
		local anchor = TheFocalPoint:GetPosition()
		local targets = {}

		for target in pairs(self.targets) do
			if self:CanFocusTarget(target, params.minrange) then
				local pos = target:GetPosition()
				offset.x = offset.x + pos.x - anchor.x
				offset.z = offset.z + pos.z - anchor.z
				targets[target] = target.replica.combat ~= nil and target.replica.combat:GetTarget() or true
				count = count + 1
			end
		end

		if count > 0 then
			if self.spectator then
				for i, v in ipairs(AllPlayers) do
					if self:CanFocusPlayer(v, params.minrange, targets) then
						local pos = v:GetPosition()
						offset.x = offset.x + pos.x - anchor.x
						offset.z = offset.z + pos.z - anchor.z
						count = count + 1
					end
				end
			end

			offset.x = offset.x / count
			offset.z = offset.z / count

			local dist = offset:Length()
			local percent = self.spectator and 1 or 0
			if self.spectator then
				offset.y = 3
				if dist > params.maxrange then
					percent = params.maxrange / dist
				end
			elseif dist < params.minrange then
				percent = Tykvesh.ClampRemap(dist, params.minrange / 2, params.minrange, 0.5, 0)
			end

			offset.x = offset.x * percent
			offset.z = offset.z * percent
		end
	end

	if params.count ~= count or params.spectator ~= self.spectator then
		params.count = count
		params.spectator = self.spectator
		params.easing = (params.fade or params.nofocus) and easing.outCubic or easing.inOutCubic
		params.fade = Vector3(TheCamera.targetoffset:Get())
	elseif not params.fade and TheCamera.targetoffset:Dist(offset) > 1 then
		params.easing = easing.outCubic
		params.fade = Vector3(TheCamera.targetoffset:Get())
	end

	if params.fade then
		local fade = params.fade
		fade.duration = fade.duration or Lerp(0.5, 2, fade:Dist(offset) / params.maxrange)
		fade.time = (fade.time or 0) + dt
		if fade.time < fade.duration then
			local progress = params.easing(fade.time, 0, 1, fade.duration)
			offset.x = Lerp(fade.x, offset.x, progress)
			offset.y = Lerp(fade.y, offset.y, progress)
			offset.z = Lerp(fade.z, offset.z, progress)
		else
			params.fade = nil
		end
	elseif not self.active and count <= 0 then
		return self:FocusCamera(false)
	end

	TheCamera:SetOffset(offset)
end

function EpicHealthbar:GetDistance(target)
	return TheCamera.targetpos:Dist(target:GetPosition())
end

function EpicHealthbar:IsNear(target, dist)
	return self:GetDistance(target) <= dist
end

function EpicHealthbar:IsAttackedBy(target, attacker)
	return target ~= attacker
			and attacker.replica.combat ~= nil
			and attacker.replica.combat:GetTarget() == target
end

function EpicHealthbar:IsAttackedByGroup(target)
	local count = 0
	for other in pairs(self.targets) do
		if self:IsAttackedBy(target, other) then
			count = count + 1
		end
	end
	return count > 1
end

function EpicHealthbar:NearAttacker(target)
	for i, v in ipairs(AllPlayers) do
		if self:IsAttackedBy(target, v) then
			return true
		end
	end
	for other in pairs(self.targets) do
		if self:IsAttackedBy(target, other) then
			return true
		end
	end
	local pos = target:GetPosition()
	for i, v in ipairs(TheSim:FindEntities(pos.x, 0, pos.z, ATTACK_RANGE, ATTACK_TAGS)) do
		if self:IsAttackedBy(target, v) then
			return true
		end
	end
	return false
end

function EpicHealthbar:GetTuningValue(type, target)
	local key = string.upper(target.prefab)
	local value = FunctionOrValue(TUNING.EPICHEALTHBAR[type][key], target)
	if value ~= nil then
		return value
	elseif type ~= "PHASES" then
		for key, value in pairs(TUNING.EPICHEALTHBAR[type]) do
			if target:HasTag(key) then
				return value
			end
		end
	end
end

function EpicHealthbar:GetLocalizedString(type, default)
	return Tykvesh.Browse(self.modinfo, "STRINGS", type) or default
end

function EpicHealthbar:GetPercent(target)
	return target.epichealth.currenthealth / target.epichealth.maxhealth
end

function EpicHealthbar:GetDisplayName(target)
	return target.components.talker ~= nil and STRINGS.NAMES[target.prefab:upper()]
			or target:GetBasicDisplayName()
end

function EpicHealthbar:IsBusy(target)
	if target.IsEpic ~= nil then
		return not target:IsEpic()
	elseif target:HasTag("nonlethal") and not target:HasTag("hostile") then
		return true
	elseif target:HasTag("attack") or self:IsInIntro(target) then
		return false
	elseif target:HasTag("flight") then
		return target:HasTag("busy")
	elseif target:HasTag("noattack") then
		return target.epichealth.invincible
				or target:HasTag("NOCLICK")
				or not target:HasTag("locomotor")
	end
	return target:HasTags("INLIMBO", "locomotor")
end

function EpicHealthbar:IsValidTarget(target)
	return self.targets[target]
			and target:HasTag(TUNING.EPICHEALTHBAR.TAG)
			and target.epichealth.maxhealth >= (self:IsEpic() and 1000 or 100)
			and target.epichealth.currenthealth > 0
			and target.replica.combat ~= nil
			and not IsEntityDead(target, true)
			and not self:IsBusy(target)
end

function EpicHealthbar:IsValidPlayer(player)
	return player.replica.combat ~= nil and not IsEntityDeadOrGhost(player, true)
			and (player.player_classified ~= nil or player ~= self.owner)
end

function EpicHealthbar:ProximityCheck(target)
	if self.highlight == target then
		return true
	elseif not self.danger and not CanEntitySeeTarget(self.owner, target) then
		return false
	end
	return target.entity:FrustumCheck()
			or (not self:IsPlayingMusic(target) and self:TargetIs(target) and self:IsNear(target, DISENGAGED_DIST))
			or (target.epichealth.overridefrustum and self:IsNear(target, 80))
end

function EpicHealthbar:InCombat(target)
	return target.epichealth.lastwasdamagedtime ~= nil and target.epichealth.lastwasdamagedtime >= GetTime()
			or target.replica.combat:IsValidTarget(target.replica.combat:GetTarget())
			or target:HasTag("fire") --and target:HasActionComponent("burnable")
			or target.AnimState ~= nil and target.AnimState:IsSymbolOverridden("swap_frozen") and target.AnimState:GetAddColour() > 0
			or self:NearAttacker(target)
end

function EpicHealthbar:IsEngagedTarget(target)
	if not self:IsValidTarget(target) then
		return false
	elseif target._isengaged ~= nil and not target._isengaged:value() then
		return false
	elseif self:GetMusicTimeLeft(target, true) then
		return true
	end
	return self:ProximityCheck(target) and self:InCombat(target)
end

function EpicHealthbar:GetNextTarget()
	if self:IsEngagedTarget(self.highlight) then
		return self.highlight
	elseif self:IsValidPlayer(self.owner) then
		local target = self.owner.replica.combat:GetTarget()
		if self:IsEngagedTarget(target) then
			return target
		end

		local act = self.owner:GetBufferedAction()
		if act ~= nil and act.action == ACTIONS.ATTACK and self:IsEngagedTarget(act.target) then
			return act.target
		end

		local target = self.owner.player_classified.lastcombattarget:value()
		if self:IsEngagedTarget(target) then
			local range = self.owner.replica.combat:GetAttackRangeWithWeapon() + TARGET_BIAS
			if self:IsNear(target, range) then
				return target
			end
		end
	end

	if not self:TimerExists("notarget") and not self:HasPopupNumbers() then
		local next = nil
		local mindist = ENGAGED_DIST

		for target in pairs(self.targets) do
			if self:IsEngagedTarget(target) then
				local dist = self:GetDistance(target)
				local physdist = dist - target:GetPhysicsRadius(0)
				if physdist <= mindist
						or not next and self:IsPlayingMusic(target)
						or not next and dist <= DISENGAGED_DIST and target.entity:FrustumCheck() then

					next = target
					mindist = physdist - TARGET_BIAS
				end
			end
		end

		if next ~= nil then
			local target = next.replica.combat:GetTarget()
			if self:IsEngagedTarget(target) then
				if self:IsAttackedByGroup(target) then
					next = target
				elseif target:HasTag("attack") ~= next:HasTag("attack") then
					next = target:HasTag("attack") and next or target
				elseif self:GetPercent(target) < self:GetPercent(next) then
					next = target
				end
			end
			if not self:TargetIs(next) then
				self:StartTimer("notarget", ATTACK_TIMEOUT)
			end
			return next
		end
	end

	if self:IsEngagedTarget(self.target) then
		return self.target
	end
end

function EpicHealthbar:TimerExists(name)
	return self.timers[name] ~= nil
end

function EpicHealthbar:StartTimer(name, time)
	self[name] = time
	self.timers[name] = time
end

EpicHealthbar.StopTimer = EpicHealthbar.StartTimer

function EpicHealthbar:UpdateTimer(name, dt)
	local time = (self[name] or 0) - dt
	if time <= 0 then
		time = nil
	end
	self[name] = time
	if self.timers ~= nil then
		self.timers[name] = time
	end
end

function EpicHealthbar:OnUpdate(dt)
	self.refresh = self.update_text ~= nil
	self.danger = TheFocalPoint.SoundEmitter:PlayingSound("danger")

	if not TheNet:IsServerPaused() or self.refresh then
		for name in pairs(self.timers) do
			self:UpdateTimer(name, dt)
		end
		for name in pairs(self.triggeredevents) do
			self.UpdateTimer(self.triggeredevents, name, dt)
		end
	end

	if self:HasTargets() then
		self.spectator = self:GetIsSpectator()
		if self.owner.components.playercontroller ~= nil then
			self.highlight = self.owner.components.playercontroller.highlight_guy
		end

		local target = self:GetNextTarget()
		if target ~= nil then
			self:PushMusic(target)
			self:StartTimer("timeleft", (self:GetMusicTimeLeft(target) or DANGER_DURATION) + DANGER_FADEOUT)
			if self:IsPriorityTarget(target) or self:IsValid() then
				self.target = target
				self.refresh = true
			end
		end
		target = self.target
		if target ~= nil and target:IsValid() then
			local health = target.epichealth
			self._name = self:GetDisplayName(target)
			self.build = target.AnimState ~= nil and target.AnimState:GetBuild() or target.prefab
			self.wet = target:GetIsWet()
			self.stimuli = health.stimuli
			self.percent = math.max(0, health.currenthealth / health.maxhealth)
			self.maxhealth = health.maxhealth
			self.currenthealth = health.currenthealth
		end
	end

	if self.refresh then
		self:Appear()
	elseif self:IsTimeout() then
		self:Disappear()
	elseif self:IsValid() then
		self:Appear()
	elseif self.meter_damage.shown and self:IsEpic() then
		self:Appear()
	else
		self:Disappear()
	end
end

function EpicHealthbar:GetDebugString()
	local lines = { "targets: " .. GetTableSize(self.targets) }

	local function dump(type, fmt)
		if GetTableSize(self[type]) > 0 then
			table.insert(lines, type .. ":")
			for k, v in pairs(self[type]) do
				table.insert(lines, fmt:format(tostring(k), tostring(v)))
			end
		end
	end

	if self.target then
		table.insert(lines, "target: " .. tostring(self.target))
		table.insert(lines, string.format("\thealth: %.2f / %.2f", self.currenthealth, self.maxhealth))
		table.insert(lines, "\tstimuli: " .. tostring(self.stimuli))
		table.insert(lines, "\tmusic: " .. tostring(self.target._playingmusic))

		if self.build then
			table.insert(lines, "theme: " .. self.build)
			for _, type in ipairs({ "metertint", "resisttint", "popuptint", "damagetint", "bgtint" }) do
				table.insert(lines, string.format("\t%s: %.2f, %.2f, %.2f", type, unpack(self[type])))
			end
		end

		dump("camerafocus",	"\t%s: %.2f")
	end

	dump("timers",			"\t%s: %.2f")
	dump("triggeredevents",	"\t%s: %.2f")
	dump("_eventaliases",	"\t%s -> %s")
	dump("_eventtriggers",	"\t%s: %s")

	table.insert(lines, self.data:GetDebugString())

	return table.concat(lines, "\n")
end

return EpicHealthbar