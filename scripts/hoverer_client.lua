require("constants")
local ZG = require("widgets/text")
local Vu0cCAf = require("widgets/widget")
local q = require("widgets/redux/templates")
local kP7O5 = require("widgets/spinner")
local lqT = require("widgets/nineslice")
local show_hover_ui = require("widgets/showhoverui")
local NUM_TEN = tonumber("10")
local NUM_ZERO = tonumber("0")
local function a(inst, data_table)
    local show_info_str_tt = SHOW_INFO_NIL_STR;
    local iD1IUx = false;
    if inst ~= nil and inst:IsValid() then
        local adjectiveStr = inst:GetAdjective()
        if adjectiveStr ~= nil then
            show_info_str_tt = adjectiveStr .. " "
        end ;
        show_info_str_tt = show_info_str_tt .. inst:GetDisplayName()
        if show_info_str_tt ~= SHOW_INFO_NIL_STR then
            local iy = string.split(show_info_str_tt, "\n")
            for k, v in ipairs(iy) do
                table.insert(data_table, { v })
            end
        end ;
        local hPQ = SHOW_INFO_NIL_STR;
        local thePlayer_l = ThePlayer;
        local player_action_picker = thePlayer_l["components"]["playeractionpicker"]
        local player_active_item = thePlayer_l["replica"]["inventory"]:GetActiveItem()
        if player_active_item == nil then
            if not (inst["replica"]["equippable"] ~= nil and inst["replica"]["equippable"]:IsEquipped()) then
                if TheInput:IsControlPressed(CONTROL_FORCE_INSPECT) then
                    hPQ = hPQ .. TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_PRIMARY) .. ": " .. STRINGS["INSPECTMOD"]
                    iD1IUx = true;
                    show_info_str_tt = show_info_str_tt .. "\n" .. TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_PRIMARY) .. ": " .. STRINGS["INSPECTMOD"]
                elseif TheInput:IsControlPressed(CONTROL_FORCE_TRADE) and not inst["replica"]["inventoryitem"]:CanOnlyGoInPocket() then
                    if next(thePlayer_l["replica"]["inventory"]:GetOpenContainers()) ~= nil then
                        iD1IUx = true;
                        hPQ = hPQ .. TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_PRIMARY) .. ": " .. ((TheInput:IsControlPressed(CONTROL_FORCE_STACK) and inst["replica"]["stackable"] ~= nil) and (STRINGS["STACKMOD"] .. " " .. STRINGS["TRADEMOD"]) or STRINGS["TRADEMOD"])
                        show_info_str_tt = show_info_str_tt .. "\n" .. TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_PRIMARY) .. ": " .. ((TheInput:IsControlPressed(CONTROL_FORCE_STACK) and inst["replica"]["stackable"] ~= nil) and (STRINGS["STACKMOD"] .. " " .. STRINGS["TRADEMOD"]) or STRINGS["TRADEMOD"])
                    end
                elseif TheInput:IsControlPressed(CONTROL_FORCE_STACK) and inst["replica"]["stackable"] ~= nil then
                    iD1IUx = true;
                    hPQ = hPQ .. TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_PRIMARY) .. ": " .. STRINGS["STACKMOD"]
                    show_info_str_tt = show_info_str_tt .. "\n" .. TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_PRIMARY) .. ": " .. STRINGS["STACKMOD"]
                end
            end ;
            local Hv = player_action_picker:GetInventoryActions(inst)
            if #Hv > tonumber("0") then
                hPQ = hPQ .. (iD1IUx and " " or SHOW_INFO_NIL_STR) .. TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_SECONDARY) .. ": " .. Hv[tonumber("1")]:GetActionString()
                show_info_str_tt = show_info_str_tt .. "\n" .. TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_SECONDARY) .. ": " .. Hv[tonumber("1")]:GetActionString()
            end
        elseif player_active_item:IsValid() then
            if not (inst.replica.equippable ~= nil and inst.replica.equippable:IsEquipped()) then
                if player_active_item["replica"]["stackable"] ~= nil and player_active_item["prefab"] == inst["prefab"] and player_active_item["AnimState"]:GetSkinBuild() == inst["AnimState"]:GetSkinBuild() then
                    iD1IUx = true;
                    hPQ = hPQ .. TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_PRIMARY) .. ": " .. STRINGS["UI"]["HUD"]["PUT"]
                    show_info_str_tt = show_info_str_tt .. "\n" .. TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_PRIMARY) .. ": " .. STRINGS["UI"]["HUD"]["PUT"]
                else
                    iD1IUx = true;
                    hPQ = hPQ .. TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_PRIMARY) .. ": " .. STRINGS["UI"]["HUD"]["SWAP"]
                    show_info_str_tt = show_info_str_tt .. "\n" .. TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_PRIMARY) .. ": " .. STRINGS["UI"]["HUD"]["SWAP"]
                end
            end
            local Ch = player_action_picker:GetUseItemActions(inst, player_active_item, true)
            if #Ch > tonumber("0") then
                hPQ = hPQ .. (iD1IUx and " " or SHOW_INFO_NIL_STR) .. TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_SECONDARY) .. ": " .. Ch[tonumber("1")]:GetActionString()
                show_info_str_tt = show_info_str_tt .. "\n" .. TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_SECONDARY) .. ": " .. Ch[tonumber("1")]:GetActionString()
            end
        end ;
        if hPQ ~= SHOW_INFO_NIL_STR then
            table["insert"](data_table, tonumber("2"), { hPQ })
        end
    end ;
    return show_info_str_tt
end;
local show_edge_color = GetModConfigData("showtype") or tonumber("1")
local function hover_client_func(self)
    local image_widgets_l = require("widgets/image")
    self.showui = self:AddChild(show_hover_ui(show_edge_color))
    self.target = nil;
    self.lastchecktime = tonumber("0")
    self.othertarget = false;
    self.text:SetSize(tonumber("24"))
    self.secondarytext:SetSize(tonumber("24"))
    self.inst:ListenForEvent("hoverdirtychange", function(inst, data)
        self["othertarget"] = false
    end, self["owner"])
    function self:OnUpdate()
        if self["owner"]["components"]["playercontroller"] == nil or not self["owner"]["components"]["playercontroller"]:UsingMouse() then
            if self["shown"] then
                self:Hide()
            end ;
            return
        elseif not self["shown"] then
            if not self["forcehide"] then
                self:Show()
            else
                return
            end
        end ;
        local under_mouse = TheInput:GetHUDEntityUnderMouse()
        local seMLr = false;
        if under_mouse ~= nil then
            under_mouse = under_mouse["widget"] ~= nil and under_mouse["widget"]["parent"] ~= nil and under_mouse["widget"]["parent"]["item"]
            seMLr = true
        else
            under_mouse = TheInput:GetWorldEntityUnderMouse()
        end ;
        if under_mouse ~= nil and (under_mouse ~= self["target"] or GetTime() - self["lastchecktime"] > tonumber("1")) then
            if under_mouse ~= self["target"] then
                self["othertarget"] = true
            end ;
            self["target"] = under_mouse;
            self["lastchecktime"] = GetTime()
            SendModRPCToServer(MOD_RPC[modname][modname], under_mouse)
        end ;
        local tooltip_info = nil;
        local tooltip_color = nil;
        local xL7OTb = false;
        local w8T3f = nil;
        local K = SHOW_INFO_NIL_STR;
        local show_data_table_l = {}
        if seMLr and under_mouse and under_mouse["replica"] and under_mouse["replica"]["inventoryitem"] ~= nil then
            w8T3f = under_mouse;
            tooltip_info = a(under_mouse, show_data_table_l)
        else
            if not self["isFE"] then
                tooltip_info = self.owner.HUD.controls:GetTooltip() or self.owner.components.playercontroller:GetHoverTextOverride()
                self["text"]:SetPosition(self["owner"]["HUD"]["controls"]:GetTooltipPos() or self["default_text_pos"])
                if self["owner"]["HUD"]["controls"]:GetTooltip() ~= nil then
                    tooltip_color = self["owner"]["HUD"]["controls"]:GetTooltipColour()
                end
            else
                tooltip_info = self["owner"]:GetTooltip()
                self["text"]:SetPosition(self["owner"]:GetTooltipPos() or self["default_text_pos"])
            end
        end ;
        local vfIyB = nil;
        local mouse_action_l = nil
        if tooltip_info == nil and not self["isFE"] and self["owner"]:IsActionsVisible() then
            mouse_action_l = self["owner"]["components"]["playercontroller"]:GetLeftMouseAction()
            if mouse_action_l ~= nil then
                local u;
                if mouse_action_l["target"] and mouse_action_l["target"]["replica"] and mouse_action_l["target"]["replica"]["inventoryitem"] ~= nil then
                    w8T3f = mouse_action_l["target"]
                end ;
                tooltip_info, u = mouse_action_l:GetActionString()
                if mouse_action_l["action"]["show_primary_input_left"] then
                    tooltip_info = TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_PRIMARY) .. " " .. tooltip_info
                end ;
                if tooltip_info then
                    K = K .. STRINGS["LMB"] .. ": " .. tooltip_info
                end ;
                if not u and mouse_action_l["target"] ~= nil and mouse_action_l["target"] ~= mouse_action_l["doer"] then
                    tooltip_info = SHOW_INFO_NIL_STR;
                    local Ki1 = mouse_action_l["target"]:GetDisplayName()
                    if Ki1 ~= nil then
                        local zz1QI = mouse_action_l["target"]:GetAdjective()
                        local kFTAh = zz1QI ~= nil and (zz1QI .. " " .. Ki1) or Ki1;
                        if kFTAh ~= SHOW_INFO_NIL_STR then
                            local LBf = string.split(kFTAh, "\n")
                            for dijn4Ph, CO1 in ipairs(LBf) do
                                table["insert"](show_data_table_l, { CO1 })
                            end
                        end ;
                        tooltip_info = tooltip_info .. " " .. (kFTAh)
                        if mouse_action_l["target"]["components"]["inspectable"] ~= nil and mouse_action_l["target"]["components"]["inspectable"]["recordview"] and mouse_action_l["target"]["prefab"] ~= nil then
                            ProfileStatsSet(mouse_action_l["target"]["prefab"] .. "_seen", true)
                        end
                    end
                end
            end ;
            local qboV = nil
            local nSBOx7 = nil
            if self["owner"]["components"]["playercontroller"] ~= nil then
                qboV = self["owner"]["components"]["playercontroller"]:IsAOETargeting()
                nSBOx7 = self["owner"]["components"]["playercontroller"]:GetRightMouseAction()
            end

            if nSBOx7 ~= nil then
                if nSBOx7["action"]["show_secondary_input_right"] then
                    vfIyB = nSBOx7:GetActionString() .. " " .. TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_SECONDARY)
                elseif nSBOx7["action"] ~= ACTIONS["CASTAOE"] then
                    vfIyB = TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_SECONDARY) .. ": " .. nSBOx7:GetActionString()
                elseif qboV and tooltip_info == nil then
                    tooltip_info = nSBOx7:GetActionString()
                    xL7OTb = true
                end
            end ;
            if qboV and vfIyB == nil then
                vfIyB = TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_SECONDARY) .. ": " .. STRINGS["UI"]["HUD"]["CANCEL"]
                xL7OTb = true
            end
        end ;
        if vfIyB ~= nil and vfIyB ~= SHOW_INFO_NIL_STR then
            K = K .. (#(K) > tonumber("0") and " " or SHOW_INFO_NIL_STR) .. vfIyB;
            self["secondarytext"]:SetString(vfIyB)
            self["secondarytext"]:Show()
        else
            self["secondarytext"]:Hide()
        end ;
        if tooltip_info == nil then
            self["text"]:Hide()
            self["showui"]:Hide()
        elseif self["str"] ~= self["lastStr"] then
            self["lastStr"] = self["str"]
            self["strFrames"] = NUM_ZERO
        else
            self["strFrames"] = self["strFrames"] - tonumber("1")
            if self["strFrames"] <= tonumber("0") then
                if under_mouse ~= nil and not xL7OTb then
                    if not self["othertarget"] then
                        local hoverertext_value_l = self["owner"]["player_classified"] and self["owner"]["player_classified"]["hoverertext"]:value() or SHOW_INFO_NIL_STR;
                        local SUn = { str = {}, im = {} }
                        if hoverertext_value_l ~= SHOW_INFO_NIL_STR then
                            SUn = json["decode"](hoverertext_value_l)
                        end ;
                        local Ib4 = false;
                        for k, v in ipairs(show_data_table_l) do
                            Ib4 = true;
                            table["insert"](SUn["str"], k, v)
                        end ;
                        if K ~= SHOW_INFO_NIL_STR then
                            table["insert"](SUn["str"], Ib4 and tonumber("2") or tonumber("1"), { K })
                        end ;
                        local additional_info = self["text"]:GetString()
                        if (additional_info ~= nil and additional_info ~= "") then
                            table["insert"](SUn["str"], 1, "附加: "..additional_info)
                        end

                        self["showui"]:Show()
                        self["showui"]:Setonumberew(SUn, w8T3f, self)
                    else
                        self["showui"]:Hide()
                    end ;
                    self["text"]:Hide()
                    self["secondarytext"]:Hide()
                else
                    self["text"]:SetString(tooltip_info)
                    self["showui"]:Hide()
                    self["text"]:Show()
                end
            end
        end ;
        local QUh2tc = self["str"] ~= tooltip_info or self["secondarystr"] ~= vfIyB;
        self["str"] = tooltip_info;
        self["secondarystr"] = vfIyB;
        if QUh2tc then
            local _ = TheInput:GetScreenPosition()
            self:UpdatePosition(_["x"], _["y"])
        end
    end;
    local rHSjalVy = -tonumber("80")
    local TjhsnP = tonumber("20")
    function self:UpdatePosition(TqYJ4, DI)
        local b = self:GetScale()
        local E, KMw7_i1s = TheSim:GetScreenSize()
        local CQi = tonumber("0")
        local nHlJ = tonumber("0")
        if self["showui"]:IsVisible() and self["showui"]["shown"] then
            local lw4Q7kbl, IN = self["showui"]:GetEH()
            CQi = math["max"](CQi, lw4Q7kbl)
            nHlJ = math["max"](nHlJ, IN)
            CQi = CQi * b["x"] * tonumber("0.5")
            nHlJ = nHlJ * b["y"] * tonumber("0.5")
            self:SetPosition(math["clamp"](TqYJ4, CQi + tonumber("30"), E - CQi - tonumber("30")), math["clamp"](DI, DI + nHlJ + TjhsnP * b["y"], KMw7_i1s - nHlJ - rHSjalVy * b["y"]), tonumber("0"))
        else
            if self["text"] ~= nil and self["str"] ~= nil then
                local QYf1, RfsnisO = self["text"]:GetRegionSize()
                CQi = math["max"](CQi, QYf1)
                nHlJ = math["max"](nHlJ, RfsnisO)
            end ;
            if self["secondarytext"] ~= nil and self["secondarystr"] ~= nil then
                local lvW2ga, T7RKP = self["secondarytext"]:GetRegionSize()
                CQi = math["max"](CQi, lvW2ga)
                nHlJ = math["max"](nHlJ, T7RKP)
            end ;
            CQi = CQi * b["x"] * tonumber("0.5")
            nHlJ = nHlJ * b["y"] * tonumber("0.5")
            self:SetPosition(math["clamp"](TqYJ4, CQi + NUM_TEN, E - CQi - NUM_TEN), math["clamp"](DI, nHlJ - tonumber("50") * b["y"], KMw7_i1s - nHlJ - rHSjalVy * b["y"]), tonumber("0"))
        end
    end
end;
AddClassPostConstruct("widgets/hoverer", hover_client_func)


--[[
local yxjl = {}
yxjl[4] = "widgets/redux/templates"
yxjl[51] = "owner"
yxjl[61] = "action"
yxjl[25] = "widgets/hoverer"
yxjl[49] = "secondarytext"
yxjl[30] = "replica"
yxjl[80] = "clamp"
yxjl[10] = " "
yxjl[78] = "y"
yxjl[44] = "showui"
yxjl[31] = "inventory"
yxjl[3] = "widgets/widget"
yxjl[18] = "hoverdirtychange"
yxjl[75] = "decode"
yxjl[58] = "isFE"
yxjl[20] = "80"
yxjl[27] = "insert"
yxjl[23] = "30"
yxjl[67] = "show_secondary_input_right"
yxjl[43] = "SWAP"
yxjl[70] = "str"
yxjl[73] = "player_classified"
yxjl[62] = "show_primary_input_left"
yxjl[35] = "stackable"
yxjl[66] = "recordview"
yxjl[24] = "50"
yxjl[50] = "inst"
yxjl[77] = "x"
yxjl[57] = "item"
yxjl[42] = "PUT"
yxjl[8] = "10"
yxjl[60] = "default_text_pos"
yxjl[32] = "equippable"
yxjl[33] = "INSPECTMOD"
yxjl[65] = "inspectable"
yxjl[40] = "UI"
yxjl[46] = "lastchecktime"
yxjl[16] = "widgets/image"
yxjl[38] = "prefab"
yxjl[68] = "CASTAOE"
yxjl[2] = "widgets/text"
yxjl[5] = "widgets/spinner"
yxjl[7] = "widgets/showhoverui"
yxjl[28] = "components"
yxjl[39] = "AnimState"
yxjl[74] = "hoverertext"
yxjl[64] = "doer"
yxjl[12] = ": "
yxjl[22] = "0.5"
yxjl[36] = "STACKMOD"
yxjl[71] = "lastStr"
yxjl[48] = "text"
yxjl[55] = "widget"
yxjl[72] = "strFrames"
yxjl[15] = "showtype"
yxjl[21] = "20"
yxjl[9] = "0"
yxjl[11] = "\n"
yxjl[13] = "1"
yxjl[53] = "shown"
yxjl[14] = "2"
yxjl[29] = "playeractionpicker"
yxjl[63] = "LMB"
yxjl[52] = "playercontroller"
yxjl[54] = "forcehide"
yxjl[45] = "target"
yxjl[56] = "parent"
yxjl[69] = "CANCEL"
yxjl[41] = "HUD"
yxjl[59] = "controls"
yxjl[6] = "widgets/nineslice"
yxjl[37] = "TRADEMOD"
yxjl[1] = "constants"
yxjl[34] = "inventoryitem"
yxjl[76] = "secondarystr"
yxjl[79] = "max"
yxjl[19] = "_seen"
yxjl[47] = "othertarget"
yxjl[26] = "split"
yxjl[17] = "24"
print("-------")
print("\n")
print("-------")
]]