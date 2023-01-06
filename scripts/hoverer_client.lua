local Are7xU = td1madao_sv()
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
yxjl[11] = Are7xU({ 49 })
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
print(Are7xU({ 49 }))
print("-------")

Are7xU = yxjl;

require("constants")
local ZG = require("widgets/text")
local Vu0cCAf = require("widgets/widget")
local q = require("widgets/redux/templates")
local kP7O5 = require("widgets/spinner")
local lqT = require("widgets/nineslice")
local show_hover_ui = require("widgets/showhoverui")
local PrPyxMK = tonumber("10")
local tczrIB = tonumber("0")
local function a(N9L, hDc_M)
    local qW0lRiD1 = TD1MADAO_NIL_STR;
    local iD1IUx = false;
    if N9L ~= nil and N9L:IsValid() then
        local JLCOx_ak = N9L:GetAdjective()
        if JLCOx_ak ~= nil then
            qW0lRiD1 = JLCOx_ak .. yxjl[10]
        end ;
        qW0lRiD1 = qW0lRiD1 .. N9L:GetDisplayName()
        if qW0lRiD1 ~= TD1MADAO_NIL_STR then
            local iy = string[yxjl[26]](qW0lRiD1, yxjl[11])
            for m6SCS0, NUhYw6R4 in ipairs(iy) do
                table[yxjl[27]](hDc_M, { NUhYw6R4 })
            end
        end ;
        local hPQ = TD1MADAO_NIL_STR;
        local R1FIoQI = ThePlayer;
        local NsoTwDs = R1FIoQI[yxjl[28]][yxjl[29]]
        local HGli = R1FIoQI[yxjl[30]][yxjl[31]]:GetActiveItem()
        if HGli == nil then
            if not (N9L[yxjl[30]][yxjl[32]] ~= nil and N9L[yxjl[30]][yxjl[32]]:IsEquipped()) then
                if TheInput:IsControlPressed(CONTROL_FORCE_INSPECT) then
                    hPQ = hPQ .. TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_PRIMARY) .. yxjl[12] .. STRINGS[yxjl[33]]
                    iD1IUx = true;
                    qW0lRiD1 = qW0lRiD1 .. yxjl[11] .. TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_PRIMARY) .. yxjl[12] .. STRINGS[yxjl[33]]
                elseif TheInput:IsControlPressed(CONTROL_FORCE_TRADE) and not N9L[yxjl[30]][yxjl[34]]:CanOnlyGoInPocket() then
                    if next(R1FIoQI[yxjl[30]][yxjl[31]]:GetOpenContainers()) ~= nil then
                        iD1IUx = true;
                        hPQ = hPQ .. TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_PRIMARY) .. yxjl[12] .. ((TheInput:IsControlPressed(CONTROL_FORCE_STACK) and N9L[yxjl[30]][yxjl[35]] ~= nil) and (STRINGS[yxjl[36]] .. yxjl[10] .. STRINGS[yxjl[37]]) or STRINGS[yxjl[37]])
                        qW0lRiD1 = qW0lRiD1 .. yxjl[11] .. TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_PRIMARY) .. yxjl[12] .. ((TheInput:IsControlPressed(CONTROL_FORCE_STACK) and N9L[yxjl[30]][yxjl[35]] ~= nil) and (STRINGS[yxjl[36]] .. yxjl[10] .. STRINGS[yxjl[37]]) or STRINGS[yxjl[37]])
                    end
                elseif TheInput:IsControlPressed(CONTROL_FORCE_STACK) and N9L[yxjl[30]][yxjl[35]] ~= nil then
                    iD1IUx = true;
                    hPQ = hPQ .. TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_PRIMARY) .. yxjl[12] .. STRINGS[yxjl[36]]
                    qW0lRiD1 = qW0lRiD1 .. yxjl[11] .. TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_PRIMARY) .. yxjl[12] .. STRINGS[yxjl[36]]
                end
            end ;
            local Hv = NsoTwDs:GetInventoryActions(N9L)
            if #Hv > tonumber("0") then
                hPQ = hPQ .. (iD1IUx and yxjl[10] or TD1MADAO_NIL_STR) .. TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_SECONDARY) .. yxjl[12] .. Hv[tonumber("1")]:GetActionString()
                qW0lRiD1 = qW0lRiD1 .. yxjl[11] .. TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_SECONDARY) .. yxjl[12] .. Hv[tonumber("1")]:GetActionString()
            end
        elseif HGli:IsValid() then
            if not (N9L[yxjl[30]][yxjl[32]] ~= nil and N9L[yxjl[30]][yxjl[32]]:IsEquipped()) then
                if HGli[yxjl[30]][yxjl[35]] ~= nil and HGli[yxjl[38]] == N9L[yxjl[38]] and HGli[yxjl[39]]:GetSkinBuild() == N9L[yxjl[39]]:GetSkinBuild() then
                    iD1IUx = true;
                    hPQ = hPQ .. TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_PRIMARY) .. yxjl[12] .. STRINGS[yxjl[40]][yxjl[41]][yxjl[42]]
                    qW0lRiD1 = qW0lRiD1 .. yxjl[11] .. TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_PRIMARY) .. yxjl[12] .. STRINGS[yxjl[40]][yxjl[41]][yxjl[42]]
                else
                    iD1IUx = true;
                    hPQ = hPQ .. TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_PRIMARY) .. yxjl[12] .. STRINGS[yxjl[40]][yxjl[41]][yxjl[43]]
                    qW0lRiD1 = qW0lRiD1 .. yxjl[11] .. TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_PRIMARY) .. yxjl[12] .. STRINGS[yxjl[40]][yxjl[41]][yxjl[43]]
                end
            end
            local Ch = NsoTwDs:GetUseItemActions(N9L, HGli, true)
            if #Ch > tonumber("0") then
                hPQ = hPQ .. (iD1IUx and yxjl[10] or TD1MADAO_NIL_STR) .. TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_SECONDARY) .. yxjl[12] .. Ch[tonumber("1")]:GetActionString()
                qW0lRiD1 = qW0lRiD1 .. yxjl[11] .. TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_SECONDARY) .. yxjl[12] .. Ch[tonumber("1")]:GetActionString()
            end
        end ;
        if hPQ ~= TD1MADAO_NIL_STR then
            table[yxjl[27]](hDc_M, tonumber(yxjl[14]), { hPQ })
        end
    end ;
    return qW0lRiD1
end;
local show_edge_color = GetModConfigData("showtype") or tonumber("1")
local function LB1Z(hoverer)
    local zhzpBSx = require("widgets/image")
    hoverer["showui"] = hoverer:AddChild(show_hover_ui(show_edge_color))
    hoverer["target"] = nil;
    hoverer["lastchecktime"] = tonumber("0")
    hoverer["othertarget"] = false;
    hoverer["text"]:SetSize(tonumber("24"))
    hoverer["secondarytext"]:SetSize(tonumber("24"))
    hoverer["inst"]:ListenForEvent("hoverdirtychange", function(t5jzEd9, JZAU2) hoverer["othertarget"] = false end, hoverer["owner"])
    function hoverer:OnUpdate()
        if hoverer["owner"][yxjl[28]][yxjl[52]] == nil or not hoverer["owner"][yxjl[28]][yxjl[52]]:UsingMouse() then
            if hoverer[yxjl[53]] then
                hoverer:Hide()
            end ;
            return
        elseif not hoverer[yxjl[53]] then
            if not hoverer[yxjl[54]] then
                hoverer:Show()
            else
                return
            end
        end ;
        local under_mouse = TheInput:GetHUDEntityUnderMouse()
        local seMLr = false;
        if under_mouse ~= nil then
            under_mouse = under_mouse[yxjl[55]] ~= nil and under_mouse[yxjl[55]][yxjl[56]] ~= nil and under_mouse[yxjl[55]][yxjl[56]][yxjl[57]]
            seMLr = true
        else
            under_mouse = TheInput:GetWorldEntityUnderMouse()
        end ;
        if under_mouse ~= nil and (under_mouse ~= hoverer["target"] or GetTime() - hoverer["lastchecktime"] > tonumber("1")) then
            if under_mouse ~= hoverer["target"] then
                hoverer["othertarget"] = true
            end ;
            hoverer["target"] = under_mouse;
            hoverer["lastchecktime"] = GetTime()
            SendModRPCToServer(MOD_RPC[modname][modname], under_mouse)
        end ;
        local qX = nil;
        local h_8 = nil;
        local xL7OTb = false;
        local w8T3f = nil;
        local K = TD1MADAO_NIL_STR;
        local qL = {}
        if seMLr and under_mouse and under_mouse[yxjl[30]] and under_mouse[yxjl[30]][yxjl[34]] ~= nil then
            w8T3f = under_mouse;
            qX = a(under_mouse, qL)
        else
            if not hoverer[yxjl[58]] then
                qX = hoverer["owner"][yxjl[41]][yxjl[59]]:GetTooltip() or hoverer["owner"][yxjl[28]][yxjl[52]]:GetHoverTextOverride()
                hoverer["text"]:SetPosition(hoverer["owner"][yxjl[41]][yxjl[59]]:GetTooltipPos() or hoverer[yxjl[60]])
                if hoverer["owner"][yxjl[41]][yxjl[59]]:GetTooltip() ~= nil then
                    h_8 = hoverer["owner"][yxjl[41]][yxjl[59]]:GetTooltipColour()
                end
            else
                qX = hoverer["owner"]:GetTooltip()
                hoverer["text"]:SetPosition(hoverer["owner"]:GetTooltipPos() or hoverer[yxjl[60]])
            end
        end ;
        local vfIyB = nil;
        local quNsijN = nil
        if qX == nil and not hoverer[yxjl[58]] and hoverer["owner"]:IsActionsVisible() then
            quNsijN = hoverer["owner"][yxjl[28]][yxjl[52]]:GetLeftMouseAction()
            if quNsijN ~= nil then
                local u;
                if quNsijN["target"] and quNsijN["target"][yxjl[30]] and quNsijN["target"][yxjl[30]][yxjl[34]] ~= nil then
                    w8T3f = quNsijN["target"]
                end ;
                qX, u = quNsijN:GetActionString()
                if quNsijN[yxjl[61]][yxjl[62]] then
                    qX = TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_PRIMARY) .. yxjl[10] .. qX
                end ;
                if qX then
                    K = K .. STRINGS[yxjl[63]] .. yxjl[12] .. qX
                end ;
                if not u and quNsijN["target"] ~= nil and quNsijN["target"] ~= quNsijN[yxjl[64]] then
                    qX = TD1MADAO_NIL_STR;
                    local Ki1 = quNsijN["target"]:GetDisplayName()
                    if Ki1 ~= nil then
                        local zz1QI = quNsijN["target"]:GetAdjective()
                        local kFTAh = zz1QI ~= nil and (zz1QI .. yxjl[10] .. Ki1) or Ki1;
                        if kFTAh ~= TD1MADAO_NIL_STR then
                            local LBf = string[yxjl[26]](kFTAh, yxjl[11])
                            for dijn4Ph, CO1 in ipairs(LBf) do
                                table[yxjl[27]](qL, { CO1 })
                            end
                        end ;
                        qX = qX .. yxjl[10] .. (kFTAh)
                        if quNsijN["target"][yxjl[28]][yxjl[65]] ~= nil and quNsijN["target"][yxjl[28]][yxjl[65]][yxjl[66]] and quNsijN["target"][yxjl[38]] ~= nil then
                            ProfileStatsSet(quNsijN["target"][yxjl[38]] .. yxjl[19], true)
                        end
                    end
                end
            end ;
            local qboV = hoverer["owner"][yxjl[28]][yxjl[52]]:IsAOETargeting()
            local nSBOx7 = hoverer["owner"][yxjl[28]][yxjl[52]]:GetRightMouseAction()
            if nSBOx7 ~= nil then
                if nSBOx7[yxjl[61]][yxjl[67]] then
                    vfIyB = nSBOx7:GetActionString() .. yxjl[10] .. TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_SECONDARY)
                elseif nSBOx7[yxjl[61]] ~= ACTIONS[yxjl[68]] then
                    vfIyB = TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_SECONDARY) .. yxjl[12] .. nSBOx7:GetActionString()
                elseif qboV and qX == nil then
                    qX = nSBOx7:GetActionString()
                    xL7OTb = true
                end
            end ;
            if qboV and vfIyB == nil then
                vfIyB = TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_SECONDARY) .. yxjl[12] .. STRINGS[yxjl[40]][yxjl[41]][yxjl[69]]
                xL7OTb = true
            end
        end ;
        if vfIyB ~= nil and vfIyB ~= TD1MADAO_NIL_STR then
            K = K .. (#(K) > tonumber("0") and yxjl[10] or TD1MADAO_NIL_STR) .. vfIyB;
            hoverer["secondarytext"]:SetString(vfIyB)
            hoverer["secondarytext"]:Show()
        else
            hoverer["secondarytext"]:Hide()
        end ;
        if qX == nil then
            hoverer["text"]:Hide()
            hoverer["showui"]:Hide()
        elseif hoverer[yxjl[70]] ~= hoverer[yxjl[71]] then
            hoverer[yxjl[71]] = hoverer[yxjl[70]]
            hoverer[yxjl[72]] = tczrIB
        else
            hoverer[yxjl[72]] = hoverer[yxjl[72]] - tonumber("1")
            if hoverer[yxjl[72]] <= tonumber("0") then
                if under_mouse ~= nil and not xL7OTb then
                    if not hoverer["othertarget"] then
                        local RlZo = hoverer["owner"][yxjl[73]] and hoverer["owner"][yxjl[73]][yxjl[74]]:value() or TD1MADAO_NIL_STR;
                        local SUn = { str = {}, im = {} }
                        if RlZo ~= TD1MADAO_NIL_STR then
                            SUn = json[yxjl[75]](RlZo)
                        end ;
                        local Ib4 = false;
                        for fjV1G2, Do in ipairs(qL) do
                            Ib4 = true;
                            table[yxjl[27]](SUn[yxjl[70]], fjV1G2, Do)
                        end ;
                        if K ~= TD1MADAO_NIL_STR then
                            table[yxjl[27]](SUn[yxjl[70]], Ib4 and tonumber(yxjl[14]) or tonumber("1"), { K })
                        end ;
                        hoverer["showui"]:Show()
                        hoverer["showui"]:Setonumberew(SUn, w8T3f, hoverer)
                    else
                        hoverer["showui"]:Hide()
                    end ;
                    hoverer["text"]:Hide()
                    hoverer["secondarytext"]:Hide()
                else
                    hoverer["text"]:SetString(qX)
                    hoverer["showui"]:Hide()
                    hoverer["text"]:Show()
                end
            end
        end ;
        local QUh2tc = hoverer[yxjl[70]] ~= qX or hoverer[yxjl[76]] ~= vfIyB;
        hoverer[yxjl[70]] = qX;
        hoverer[yxjl[76]] = vfIyB;
        if QUh2tc then
            local _ = TheInput:GetScreenPosition()
            hoverer:UpdatePosition(_[yxjl[77]], _[yxjl[78]])
        end
    end;
    local rHSjalVy = -tonumber(yxjl[20])
    local TjhsnP = tonumber(yxjl[21])
    function hoverer:UpdatePosition(TqYJ4, DI)
        local b = hoverer:GetScale()
        local E, KMw7_i1s = TheSim:GetScreenSize()
        local CQi = tonumber("0")
        local nHlJ = tonumber("0")
        if hoverer["showui"]:IsVisible() and hoverer["showui"][yxjl[53]] then
            local lw4Q7kbl, IN = hoverer["showui"]:GetEH()
            CQi = math["max"](CQi, lw4Q7kbl)
            nHlJ = math["max"](nHlJ, IN)
            CQi = CQi * b[yxjl[77]] * tonumber(yxjl[22])
            nHlJ = nHlJ * b[yxjl[78]] * tonumber(yxjl[22])
            hoverer:SetPosition(math[yxjl[80]](TqYJ4, CQi + tonumber(yxjl[23]), E - CQi - tonumber(yxjl[23])), math[yxjl[80]](DI, DI + nHlJ + TjhsnP * b[yxjl[78]], KMw7_i1s - nHlJ - rHSjalVy * b[yxjl[78]]), tonumber("0"))
        else
            if hoverer["text"] ~= nil and hoverer[yxjl[70]] ~= nil then
                local QYf1, RfsnisO = hoverer["text"]:GetRegionSize()
                CQi = math["max"](CQi, QYf1)
                nHlJ = math["max"](nHlJ, RfsnisO)
            end ;
            if hoverer["secondarytext"] ~= nil and hoverer[yxjl[76]] ~= nil then
                local lvW2ga, T7RKP = hoverer["secondarytext"]:GetRegionSize()
                CQi = math["max"](CQi, lvW2ga)
                nHlJ = math["max"](nHlJ, T7RKP)
            end ;
            CQi = CQi * b[yxjl[77]] * tonumber(yxjl[22])
            nHlJ = nHlJ * b[yxjl[78]] * tonumber(yxjl[22])
            hoverer:SetPosition(math[yxjl[80]](TqYJ4, CQi + PrPyxMK, E - CQi - PrPyxMK), math[yxjl[80]](DI, nHlJ - tonumber(yxjl[24]) * b[yxjl[78]], KMw7_i1s - nHlJ - rHSjalVy * b[yxjl[78]]), tonumber("0"))
        end
    end
end;
AddClassPostConstruct("widgets/hoverer", LB1Z)