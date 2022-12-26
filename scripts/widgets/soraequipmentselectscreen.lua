local Screen = require "widgets/screen"
local Widget = require "widgets/widget"
local ImageButton = require "widgets/imagebutton"
local EquipmentSelector = Class(Screen, function(self, owner,sora_fl)
    self.owner = owner
    self.sora_fl = sora_fl
    Screen._ctor(self, "SoraEquipmentSelector")
    local black = self:AddChild(ImageButton("images/global.xml", "square.tex"))
    black.image:SetVRegPoint(ANCHOR_MIDDLE)
    black.image:SetHRegPoint(ANCHOR_MIDDLE)
    black.image:SetVAnchor(ANCHOR_MIDDLE)
    black.image:SetHAnchor(ANCHOR_MIDDLE)
    black.image:SetScaleMode(SCALEMODE_FILLSCREEN)
    black.image:SetTint(0,0,0,0)
    black:SetOnClick(function()
            SendModRPCToServer(MOD_RPC["SoraPatch"]["SoraEQSelect"],self.sora_fl,nil)
            TheFrontEnd:PopScreen()
        end)
	local root = self:AddChild(Widget("root"))
	root:SetScaleMode(SCALEMODE_PROPORTIONAL)
    root:SetHAnchor(ANCHOR_MIDDLE)
    root:SetVAnchor(ANCHOR_MIDDLE)
	root:SetPosition(0,0)

    local equipments = {"soraclothes","sorahat","sorapick","soramagic","sorahealing","soratele"}
    for i = 1, #equipments, 1 do
    local x= 120*math.cos(2*i*math.pi/#equipments)
    local y= 120*math.sin(2*i*math.pi/#equipments)+40
        local eq = root:AddChild(ImageButton("images/inventoryimages/"..equipments[i].. ".xml",equipments[i]..".tex"))
        eq:SetPosition(x,y)
        eq:SetScale(0.7,0.7)
        eq:SetOnClick(function ()
            TheFrontEnd:PopScreen()
            SendModRPCToServer(MOD_RPC["SoraPatch"]["SoraEQSelect"],self.sora_fl,equipments[i])
        end)
    end
    local sorabowknot = root:AddChild(ImageButton("images/inventoryimages/sorabowknot.xml","sorabowknot.tex"))
    sorabowknot:SetPosition(0,40)
    sorabowknot:SetScale(0.7,0.7)
    sorabowknot:SetOnClick(function ()
        TheFrontEnd:PopScreen()
        SendModRPCToServer(MOD_RPC["SoraPatch"]["SoraEQSelect"],self.sora_fl,"sorabowknot")
    end)
end)

function EquipmentSelector:OnDestroy()

	EquipmentSelector._base.OnDestroy(self)
end

function EquipmentSelector:OnBecomeInactive()
    EquipmentSelector._base.OnBecomeInactive(self)
end

function EquipmentSelector:OnBecomeActive()
    EquipmentSelector._base.OnBecomeActive(self)
end

function EquipmentSelector:OnControl(control, down)
    if EquipmentSelector._base.OnControl(self, control, down) then return true end

    if not down and (control == CONTROL_MAP or control == CONTROL_CANCEL) then
		TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
        TheFrontEnd:PopScreen()
        return true
    end

	return false
end

return EquipmentSelector
