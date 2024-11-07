local Widget = require "widgets/widget"
local Text = require "widgets/text"
local Screen = require "widgets/screen"
local TEMPLATES = require "widgets/redux/templates"
local PopupDialogScreen = require "screens/redux/popupdialog"
local CapturePlayer = require "screens/epiccaptureplayer"

local WIDTH = 600
local HEIGHT = 400
local ROW_WIDTH = WIDTH
local ROW_HEIGHT = 45

local CaptureBrowser = Class(Screen, function(self, data, slot)
	Screen._ctor(self, "CaptureBrowser")

	self.data = data
	self.slot = slot

	self:SetScaleMode(SCALEMODE_PROPORTIONAL)
	self:SetHAnchor(ANCHOR_MIDDLE)
	self:SetVAnchor(ANCHOR_MIDDLE)

	self.bg = self:AddChild(TEMPLATES.BackgroundTint())

	local captures = {}
	for i, v in ipairs(data:Get()) do
		table.insert(captures, 1, v)
	end

	self.window = self:AddChild(TEMPLATES.RectangleWindow(WIDTH, HEIGHT, string.format("All Captures (%s)", #captures),
	{
		{ text = "Delete All", cb = function() self:DeleteAll() end },
		{ text = "Chromakey", cb = function() self:ToggleChromakey() end },
		{ text = STRINGS.UI.MODSSCREEN.BACK, cb = function() self:Close() end },
    }))

	self.captures = self.window:AddChild(TEMPLATES.ScrollingGrid(captures,
    {
        scroll_context = { screen = self },
        widget_width  = ROW_WIDTH,
        widget_height = ROW_HEIGHT,
        num_visible_rows = HEIGHT / ROW_HEIGHT - 2,
        num_columns = 1,
        item_ctor_fn = function(...) return self:MakeCaptureWidget(...) end,
        apply_fn = function(...) self:UpdateCaptureWidget(...) end,
        scrollbar_offset = 20,
        scrollbar_height_offset = -60,
    }))
	self.captures:SetPosition(self.captures:CanScroll() and -15 or 0, -20)
end)

function CaptureBrowser:DeleteAll()
	TheFrontEnd:PushScreen(PopupDialogScreen("Delete All?", "This action is irreversible.",
	{
		{ text = "Confirm",	cb = function() TheFrontEnd:PopScreen() self.data:Erase() self:Close() end },
		{ text = "Cancel",	cb = function() TheFrontEnd:PopScreen() end },
	}))
end

function CaptureBrowser:ToggleChromakey()
	local function select(value)
		TUNING.EPICHEALTHBAR.CHROMAKEY = value
		TheFrontEnd:PopScreen()
	end

	TheFrontEnd:PushScreen(PopupDialogScreen("Edit Chromakey Color", "You can set custom color with this tuning variable:\nTUNING.EPICHEALTHBAR.CHROMAKEY",
	{
		{ text = "Grey",	cb = function() select({ 0.5, 0.5, 0.5 }) end },
		{ text = "Green",	cb = function() select({ 0, 1, 0 }) end },
		{ text = "Blue",	cb = function() select({ 0, 0, 1 }) end },
		{ text = "None",	cb = function() select(false) end },
	}))
end

function CaptureBrowser:MakeCaptureWidget(context, index)
	local widget = TEMPLATES.ListItemBackground(ROW_WIDTH, ROW_HEIGHT - 10, function() end)
	widget.move_on_click = true

	widget.name = widget:AddChild(Text(CHATFONT, 22, nil, UICOLOURS.GOLD_UNIMPORTANT))
    widget.name:SetHAlign(ANCHOR_LEFT)
    widget.name:SetRegionSize(ROW_WIDTH - 50, ROW_HEIGHT)

	widget.length = widget:AddChild(Text(CHATFONT, 22, nil, UICOLOURS.GOLD_UNIMPORTANT))
    widget.length:SetHAlign(ANCHOR_RIGHT)
    widget.length:SetRegionSize(ROW_WIDTH - 50, ROW_HEIGHT)

	return widget
end

function CaptureBrowser:GetCaptureName(data)
	return string.format("Day %s - %s", data.day or "???", data.name or "Unknown")
end

function CaptureBrowser:GetCaptureLength(data)
	return data.length and Tykvesh.Timer(data.length)
end

function CaptureBrowser:ShowPlayer(data)
	TheFrontEnd:PushScreen(CapturePlayer(data))
end

function CaptureBrowser:UpdateCaptureWidget(context, widget, data, index)
	if data ~= nil then
		widget.name:SetTruncatedString(self:GetCaptureName(data), nil, 55, true)
		widget.length:SetString(self:GetCaptureLength(data))
		widget:SetOnClick(function() self:ShowPlayer(data) end)
		widget:Show()
	else
		widget:Hide()
	end
end

function CaptureBrowser:OnControl(control, down)
    if Screen.OnControl(self, control, down) then
		return true
	elseif not down and control == CONTROL_CANCEL then
		self:Close()
	    return true
    end
end

function CaptureBrowser:Close()
    TheFrontEnd:PopScreen()
end

return CaptureBrowser