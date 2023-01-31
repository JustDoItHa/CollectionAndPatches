require("constants")
local Text = require "widgets/text"
local Widget = require "widgets/widget"

local YOFFSETUP = 50
local YOFFSETDOWN = 80
local XOFFSET = 10
local OFFSET_TO_TEXT= 10

local SHOW_DELAY = 0 -- 10

local MapHoverText = Class(Widget, function(self)
    Widget._ctor(self, "HoverText")
    self.isFE = false
    self:SetClickable(false)

    self.default_text_pos = Vector3(0, 0, 0)
    self.text = self:AddChild(Text(UIFONT, 30))
    self.text:SetPosition(self.default_text_pos)

    self.lastStr = ""
    self.disabled = true
    self.strFrames = 0
end)

function MapHoverText:UpdatePosition(x, y)
    local scale = self:GetScale()

    local scr_w, scr_h = TheSim:GetScreenSize()

    local w = 0
    local h = 0

    if self.text and self.str then
        local w0, h0 = self.text:GetRegionSize()
        w = math.max(w, w0)
        h = math.max(h, h0)
    end
    if self.secondarytext and self.secondarystr then
        local w1, h1 = self.secondarytext:GetRegionSize()
        w = math.max(w, w1)
        h = math.max(h, h1)
    end

    w = w * scale.x
    h = h * scale.y

    x = math.max(x, w / 2 + XOFFSET)
    x = math.min(x, scr_w - w / 2 - XOFFSET)

    y = math.max(y, h / 2 + YOFFSETDOWN * scale.y)
    y = math.min(y, scr_h - h / 2 - YOFFSETUP * scale.y)

    self:SetPosition(x, y+OFFSET_TO_TEXT, 0)
end

function MapHoverText:GetString(...)
    return self.text:GetString(...)
end

function MapHoverText:SetString(...)
    if self.disabled then
        return
    end
    return self.text:SetString(...)
end

function MapHoverText:SetColour(...)
    -- {r,g,b,a}
    return self.text:SetColour(...)
end
function MapHoverText:Disable()
    self.disabled = true
    self.str = {self:GetString()}
    self.text:SetString("")
end
function MapHoverText:Enable()
    self.disabled = false
end
return MapHoverText
