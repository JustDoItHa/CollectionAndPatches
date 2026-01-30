local Widget = require "widgets/widget"
local Text = require "widgets/text"
local Screen = require "widgets/screen"
local TEMPLATES = require "widgets/redux/templates"
local PopupDialogScreen = require "screens/redux/popupdialog"
local EpicHealthbar = require "widgets/epichealthbar"

local function RGBA(tint, alpha)
	return { r = tint[1] or 1, g = tint[2] or 1, b = tint[3] or 1, a = alpha or tint[4] or 1 }
end

local CapturePlayer = Class(Screen, function(self, capture)
	Screen._ctor(self, "CapturePlayer")

	self.capture = capture
	self.target = { prefab = "", epichealth = {}, HasTag = function(target, tag) return target.prefab:find(tag:lower()) end }
	self.index, self.max = 1, #capture.timeline
	self.errorfn = function(message) self:OnError(message) end
	self:BuildTimeline()

	local width = TheSim:GetScreenSize()
	self.progress = self:AddChild(Image("images/global.xml", "square.tex"))
	self.progress:SetHAnchor(ANCHOR_LEFT)
	self.progress:SetVAnchor(ANCHOR_BOTTOM)
	self.progress:SetHRegPoint(ANCHOR_RIGHT)
	self.progress:SetVRegPoint(ANCHOR_BOTTOM)
	self.progress:SetTint(0.8, 0.8, 0.8, 1)
	self.progress:SetUVScale(1.5, 1.5)
	self.progress:SetSize(width, 5)
	self.progress.SetTime = function(self, time) self:SetPosition(time / capture.length * width, 0) end

	if TUNING.EPICHEALTHBAR.CHROMAKEY then
		self.bg = self:AddChild(TEMPLATES.BackgroundTint(1, TUNING.EPICHEALTHBAR.CHROMAKEY))
	end
	self.root = self:AddChild(TEMPLATES.ScreenRoot())

	self.top_root = self:AddChild(Widget("top"))
	self.top_root:SetScaleMode(SCALEMODE_PROPORTIONAL)
	self.top_root:SetHAnchor(ANCHOR_MIDDLE)
	self.top_root:SetVAnchor(ANCHOR_TOP)
	self.top_root:SetMaxPropUpscale(MAX_HUD_SCALE)
	self.top_root = self.top_root:AddChild(Widget("top_scale_root"))
	self.top_root:SetScale(TheFrontEnd:GetHUDScale())

	EpicHealthbar.targets = {}
	self.player = self.top_root:AddChild(EpicHealthbar())
	self.player:SetClickable(false)
	self.player.meter_damage.IsSuspended = function() return self.player.suspended end
end)

function CapturePlayer:BuildTimeline()
	self.start = GetTime()
	self.timeline = {}
	local time = self.start
	for index, value in ipairs(self.capture.timeline) do
		if type(value) == "table" then
			self.timeline[index] = value
		else
			time = time + value
			self.timeline[index] = time
		end
	end
end

function CapturePlayer:HandleEvent(event)
	local key, value = unpack(event)
	if key == "target" then
		self.player.target = nil
		self.target.prefab = value
		self.player.target = self.target
	elseif key == "active" then
		if value then
			self.player:Appear()
		else
			self.player:Disappear()
		end
	else
		self.player[key] = value
	end
end

function CapturePlayer:OnUpdate(dt)
	self.time = math.min(self.capture.length, GetTime() - self.start)
	if self.progress.shown then
		self.progress:SetTime(self.time)
	end

	if self.wait then
		if self.wait > GetTime() then
			return
		else
			self.wait = nil
			self.index = self.index + 1
		end
	end

	while self.index < self.max do
		local value = self.timeline[self.index]
		if type(value) == "table" then
			xpcall(function() self:HandleEvent(value) end, self.errorfn)
			self.index = self.index + 1
		else
			self.wait = value
			return
		end
	end

	if self.progress.shown then
		self.progress:TintTo(RGBA(self.progress.tint), RGBA(self.progress.tint, 0), 0.4)
		self.progress.shown = false
	end
	if self.player.shown then
		self.player:Disappear()
	else
		self:Close()
	end
end

function CapturePlayer:Abort()
	self.wait = 0
	self.index = self.max
	self:OnUpdate(0)
end

function CapturePlayer:OnError(message)
	TheFrontEnd:PushScreen(PopupDialogScreen("Zoinks!", message,
			{
				{ text = "Report", cb = function() VisitURL("https://steamcommunity.com/workshop/filedetails/discussion/1185229307/1743343017616426562/") end },
				{ text = STRINGS.UI.BARTERSCREEN.OK, cb = function() TheFrontEnd:PopScreen() end },
			}))
	self:Abort()
end

function CapturePlayer:OnControl(control, down)
	if not down and (control == CONTROL_CANCEL or control == CONTROL_ACCEPT) then
		self:Abort()
		return true
	end
end

function CapturePlayer:Close(fn)
	TheFrontEnd:PopScreen(self)
end

function CapturePlayer:GetDebugString()
	local lines = {}
	for index = self.index, math.min(self.max, self.index + 20) do
		local key, value = "wait", self.capture.timeline[index]
		if type(value) == "table" then
			key, value = value[1], tostring(value[2])
		elseif index == self.index then
			value = self.wait
		end
		table.insert(lines, string.format("\t%s %s %s", index, key, value))
	end
	return table.concat(lines, "\n")
end

return CapturePlayer