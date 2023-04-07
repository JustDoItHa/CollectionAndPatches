local Badge = require "widgets/badge"
local UIAnim = require "widgets/uianim"
local Image = require "widgets/image"


local BeefaloBadge = Class(Badge, function(self, config, tint, iconbuild, circular_meter, use_clear_bg)
    Badge._ctor(self, nil, nil, tint, iconbuild, circular_meter, use_clear_bg)
    
    self:SetScale(0.9)
    self:SetPercent(100 / 100, 100)
    
    self.num:SetScale(0.9)

    if config.theme == "TheForge" then
        self.forgeFrame = self.underNumber:AddChild(UIAnim())
        self.forgeFrame:GetAnimState():SetBank("lavaarena_health")
        self.forgeFrame:GetAnimState():SetBuild("lavaarena_health")
        -- Can't find a better way to display the frame only.
        self.forgeFrame:GetAnimState():PlayAnimation("anim")
        self.forgeFrame:GetAnimState():Hide("heart")
        self.forgeFrame:GetAnimState():Hide("bg")
        self.forgeFrame:GetAnimState():Hide("bg_texture")
        self.forgeFrame:SetScale(0.46) -- 0.45 pixel perfect with the default frame.
        
        if self.circleframe ~= nil then self.circleframe:GetAnimState():Hide("frame") end
    end

    if not iconbuild then
        self.icon = self.underNumber:AddChild(Image())
        self.icon:SetScale(0.55)
    end
    
    -- It's not really brightness, but it will do.
    if use_clear_bg and self.backing ~= nil then
        self.backing:GetAnimState():SetMultColour(unpack({config.brightness, config.brightness, config.brightness, config.opacity}))
    end
    
end)

function BeefaloBadge:SetPercent(val, max, displayValue)
    val = val or self.percent
    max = max or 100
    displayValue = displayValue or tostring(math.ceil(val * max))
    
    if self.circular_meter ~= nil then
        self.circular_meter:GetAnimState():SetPercent("meter", val)
    else
        self.anim:GetAnimState():SetPercent("anim", 1 - val)
        if self.circleframe ~= nil then
            self.circleframe:GetAnimState():SetPercent("frame", 1 - val)
        end
    end
    
    self.num:SetString(displayValue)
    
    self.percent = val
end

return BeefaloBadge
