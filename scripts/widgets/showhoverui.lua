local ZG = {}
ZG[73]  = "RED"
ZG[47]  = "温度变化"
ZG[37]  = "206"
ZG[23]  = "1.4"
ZG[104] = "tex_w"
ZG[110] = "y"
ZG[1]   = "widgets/widget"
ZG[34]  = "保暖"
ZG[26]  = "80"
ZG[28]  = "30"
ZG[77]  = "image21"
ZG[70]  = "TOMATO"
ZG[29]  = "装备加速"
ZG[108] = "inst"
ZG[85]  = "image12"
ZG[43]  = "10"
ZG[48]  = "剩余天数"
ZG[63]  = "CHOCOLATE"
ZG[92]  = "strdata"
ZG[97]  = "OTHERYELLOW"
ZG[66]  = "TEAL"
ZG[102] = "atlas"
ZG[6]   = "widgets/image"
ZG[93]  = "invimage"
ZG[3]   = "widgets/text"
ZG[5]   = "widgets/spinner"
ZG[65]  = "CORAL"
ZG[78]  = "origw"
ZG[10]  = "makeback"
ZG[88]  = "back"
ZG[22]  = "0.5"
ZG[86]  = "image13"
ZG[90]  = "maxh"
ZG[35]  = "隔热"
ZG[103] = "image"
ZG[95]  = "showtext"
ZG[52]  = "防雨"
ZG[9]   = "1"
ZG[69]  = "PURPLE"
ZG[105] = "shown"
ZG[44]  = "特殊效果"
ZG[40]  = "价值"
ZG[64]  = "BLUE"
ZG[54]  = "回复精神"
ZG[8]   = "255"
ZG[91]  = "maxw"
ZG[31]  = "128"
ZG[81]  = "image31"
ZG[59]  = "34"
ZG[17]  = "12.tex"
ZG[2]   = "widgets/uianim"
ZG[30]  = "等级"
ZG[20]  = "3"
ZG[4]   = "widgets/redux/templates"
ZG[24]  = "1.5"
ZG[18]  = "13.tex"
ZG[36]  = "65"
ZG[56]  = "生物"
ZG[50]  = "防御"
ZG[96]  = "YELLOW"
ZG[14]  = "22.tex"
ZG[99]  = "str"
ZG[109] = "x"
ZG[62]  = "GREEN"
ZG[16]  = "23.tex"
ZG[76]  = "image11"
ZG[15]  = "0.7"
ZG[79]  = "image22"
ZG[75]  = "_ctor"
ZG[39]  = "工具"
ZG[45]  = "新鲜度"
ZG[72]  = "BURLYWOOD"
ZG[83]  = "origh"
ZG[84]  = "image33"
ZG[87]  = "SetSize"
ZG[13]  = "21.tex"
ZG[51]  = "耐久"
ZG[53]  = "叠加"
ZG[94]  = "imagebg"
ZG[71]  = "TAN"
ZG[11]  = "images/text_teng_hoverer.xml"
ZG[49]  = "伤害"
ZG[98]  = "MEDIUMPURPLE"
ZG[32]  = "所有者"
ZG[101] = "inv_image_bg"
ZG[100] = "im"
ZG[58]  = ": "
ZG[25]  = "test_showhoverui"
ZG[74]  = "GOLDENROD"
ZG[55]  = "治疗血量"
ZG[7]   = "0"
ZG[12]  = "11.tex"
ZG[19]  = "2"
ZG[42]  = "204"
ZG[68]  = "ORANGE"
ZG[89]  = "textsty"
ZG[60]  = "function"
ZG[41]  = "245"
ZG[107] = "tex_h"
ZG[46]  = "食材属性"
ZG[80]  = "image23"
ZG[61]  = "6"
ZG[106] = "max"
ZG[57]  = "40"
ZG[82]  = "image32"
ZG[21]  = "2.5"
ZG[33]  = "主人"
ZG[38]  = "4"
ZG[27]  = "24"
ZG[67]  = "LAVENDER"
local widget_l = require("widgets/widget")
local q = require("widgets/uianim")
local kP7O5 = require("widgets/text")
local lqT = require("widgets/redux/templates")
local mP3mlD = require("widgets/spinner")
local image_l = require("widgets/image")

local color_enum = {
    PLAYERCOLOURS["GREEN"],
    PLAYERCOLOURS["CHOCOLATE"],
    PLAYERCOLOURS["BLUE"],
    PLAYERCOLOURS["CORAL"],
    PLAYERCOLOURS["TEAL"],
    PLAYERCOLOURS["LAVENDER"],
    PLAYERCOLOURS["ORANGE"],
    PLAYERCOLOURS["PURPLE"],
    PLAYERCOLOURS["TOMATO"],
    PLAYERCOLOURS["TAN"],
    PLAYERCOLOURS["BURLYWOOD"],
    PLAYERCOLOURS["RED"],
    PLAYERCOLOURS["GOLDENROD"],
    { tonumber(ZG[7]) / tonumber(ZG[8]), tonumber(ZG[7]) / tonumber(ZG[8]), tonumber(ZG[7]) / tonumber(ZG[8]), tonumber("1") },
    { tonumber(ZG[8]) / tonumber(ZG[8]), tonumber(ZG[8]) / tonumber(ZG[8]), tonumber(ZG[8]) / tonumber(ZG[8]), tonumber("1") },
    { tonumber(ZG[8]) / tonumber(ZG[8]), tonumber(ZG[8]) / tonumber(ZG[8]), tonumber(ZG[7]) / tonumber(ZG[8]), tonumber("1") },
    { tonumber(ZG[7]) / tonumber(ZG[8]), tonumber(ZG[7]) / tonumber(ZG[8]), tonumber(ZG[8]) / tonumber(ZG[8]), tonumber("1") }
}
local a = Class(widget_l, function(self, iD1IUx, JLCOx_ak, hPQ)
    local R1FIoQI = color_enum[hPQ or tonumber("1")]
    widget_l["_ctor"](self, "makeback")
    self["image11"] = self:AddChild(image_l("images/text_teng_hoverer.xml", ZG[12]))
    self["image11"]:SetTint(unpack(R1FIoQI))
    self["image21"] = self:AddChild(image_l("images/text_teng_hoverer.xml", ZG[13]))
    self["image21"]:SetTint(unpack(R1FIoQI))
    local NsoTwDs, HGli = self["image21"]:GetSize()
    self["image21"]["origw"] = NsoTwDs;
    self["image22"] = self:AddChild(image_l("images/text_teng_hoverer.xml", ZG[14]))
    self["image22"]:SetTint(tonumber("0.7"), tonumber("0.7"), tonumber("0.7"), tonumber("0.7"))
    self["image23"] = self:AddChild(image_l("images/text_teng_hoverer.xml", ZG[16]))
    self["image23"]:SetTint(unpack(R1FIoQI))
    local NsoTwDs, HGli = self["image23"]:GetSize()
    self["image23"]["origw"] = NsoTwDs;
    self["image31"] = self:AddChild(image_l("images/text_teng_hoverer.xml", ZG[12]))
    self["image31"]:SetTint(unpack(R1FIoQI))
    local NsoTwDs, HGli = self["image31"]:GetSize()
    self["image31"]:SetSize(NsoTwDs, -HGli)
    self["image32"] = self:AddChild(image_l("images/text_teng_hoverer.xml", ZG[17]))
    self["image32"]:SetTint(unpack(R1FIoQI))
    local NsoTwDs, HGli = self["image32"]:GetSize()
    self["image32"][ZG[83]] = HGli;
    self["image33"] = self:AddChild(image_l("images/text_teng_hoverer.xml", ZG[18]))
    self["image33"]:SetTint(unpack(R1FIoQI))
    local NsoTwDs, HGli = self["image33"]:GetSize()
    self["image33"]:SetSize(NsoTwDs, -HGli)
    self["image12"] = self:AddChild(image_l("images/text_teng_hoverer.xml", ZG[17]))
    self["image12"]:SetTint(unpack(R1FIoQI))
    local NsoTwDs, HGli = self["image12"]:GetSize()
    self["image12"][ZG[83]] = HGli;
    self["image13"] = self:AddChild(image_l("images/text_teng_hoverer.xml", ZG[18]))
    self["image13"]:SetTint(unpack(R1FIoQI))
    self["SetSize"] = function(qW0lRiD1, iD1IUx, JLCOx_ak)
        qW0lRiD1["image31"]:SetPosition(-iD1IUx / tonumber("2") - tonumber("1"), JLCOx_ak / tonumber("2") - tonumber(ZG[20]))
        qW0lRiD1["image32"]:SetSize(iD1IUx, -qW0lRiD1["image32"][ZG[83]])
        qW0lRiD1["image32"]:SetPosition(tonumber(ZG[7]), JLCOx_ak / tonumber("2") - tonumber(ZG[21]))
        qW0lRiD1["image33"]:SetPosition(iD1IUx / tonumber("2") - tonumber(ZG[22]), JLCOx_ak / tonumber("2") - tonumber(ZG[20]))
        qW0lRiD1["image11"]:SetPosition(-iD1IUx / tonumber("2") - tonumber("1"), -JLCOx_ak / tonumber("2") + tonumber(ZG[23]))
        qW0lRiD1["image12"]:SetSize(iD1IUx, qW0lRiD1["image12"][ZG[83]])
        qW0lRiD1["image12"]:SetPosition(tonumber(ZG[7]), -JLCOx_ak / tonumber("2") + tonumber("1"))
        qW0lRiD1["image13"]:SetPosition(iD1IUx / tonumber("2") - tonumber(ZG[22]), -JLCOx_ak / tonumber("2") + tonumber(ZG[24]))
        qW0lRiD1["image21"]:SetSize(qW0lRiD1["image21"]["origw"], JLCOx_ak - tonumber("2"))
        qW0lRiD1["image21"]:SetPosition(-iD1IUx / tonumber("2") - tonumber("2"), tonumber(ZG[7]))
        qW0lRiD1["image22"]:SetSize(iD1IUx, -JLCOx_ak)
        qW0lRiD1["image22"]:SetPosition(tonumber(ZG[7]), tonumber(ZG[7]) - tonumber("1"))
        qW0lRiD1["image23"]:SetSize(qW0lRiD1["image23"]["origw"], JLCOx_ak - tonumber("2"))
        qW0lRiD1["image23"]:SetPosition(iD1IUx / tonumber("2"), tonumber(ZG[7]))
    end;
    self:SetSize(iD1IUx, JLCOx_ak)
end)
local wqU76o = Class(widget_l, function(self, owner)
    widget_l["_ctor"](self, "test_showhoverui")
    if TUNING.CAP_SHOW_INFO_BG then
        self["back"] = self:AddChild(a(tonumber("80"), tonumber("80"), owner))
        self["back"]:SetScale(tonumber("1"))
        self["back"]:MoveToBack()
        self["back"]:SetClickable(false)
    end
    self["textsty"] = self:AddChild(kP7O5(DEFAULTFONT, tonumber(ZG[27])))
    self["textsty"]:Hide()
    self[ZG[90]] = tonumber(ZG[7])
    self[ZG[91]] = tonumber(ZG[7])
    self[ZG[92]] = {}
    self[ZG[93]] = self:AddChild(image_l())
    self[ZG[93]][ZG[94]] = self[ZG[93]]:AddChild(image_l())
    self[ZG[93]][ZG[94]]:SetClickable(false)
    self[ZG[93]][ZG[94]]:MoveToBack()
    self[ZG[93]]:Hide()
    for NUhYw6R4 = tonumber("1"), tonumber(ZG[28]) do
        self[ZG[92]][NUhYw6R4] = self:AddChild(kP7O5(DEFAULTFONT, NUhYw6R4 == tonumber("1") and tonumber(ZG[28]) or tonumber(ZG[27])))
        self[ZG[92]][NUhYw6R4]:SetHAlign(ANCHOR_LEFT)
        self[ZG[92]][NUhYw6R4]:Hide()
        self[ZG[92]][NUhYw6R4][ZG[95]] = self[ZG[92]][NUhYw6R4]:AddChild(kP7O5(DEFAULTFONT, tonumber(ZG[27])))
        self[ZG[92]][NUhYw6R4][ZG[95]]:SetHAlign(ANCHOR_LEFT)
        self[ZG[92]][NUhYw6R4][ZG[95]]:Hide()
    end
end)
local LB1Z = { [ZG[29]] = PLAYERCOLOURS["CHOCOLATE"], [ZG[30]] = { tonumber(ZG[8]) / tonumber(ZG[8]), tonumber(ZG[7]) / tonumber(ZG[8]), tonumber(ZG[31]) / tonumber(ZG[8]), tonumber("1") }, [ZG[32]] = PLAYERCOLOURS["CORAL"], [ZG[33]] = PLAYERCOLOURS["CORAL"], [ZG[34]] = PLAYERCOLOURS[ZG[96]], [ZG[35]] = { tonumber(ZG[36]) / tonumber(ZG[8]), tonumber(ZG[37]) / tonumber(ZG[8]), tonumber(ZG[38]) / tonumber(ZG[8]), tonumber("1") }, [ZG[39]] = PLAYERCOLOURS["ORANGE"], [ZG[40]] = { tonumber(ZG[41]) / tonumber(ZG[8]), tonumber(ZG[42]) / tonumber(ZG[8]), tonumber(ZG[43]) / tonumber(ZG[8]), tonumber("1") }, [ZG[44]] = PLAYERCOLOURS["GOLDENROD"], [ZG[45]] = PLAYERCOLOURS["GREEN"], [ZG[46]] = PLAYERCOLOURS["BLUE"], [ZG[47]] = PLAYERCOLOURS[ZG[97]], [ZG[48]] = PLAYERCOLOURS[ZG[98]], [ZG[49]] = PLAYERCOLOURS["RED"], [ZG[50]] = PLAYERCOLOURS["RED"], [ZG[51]] = PLAYERCOLOURS[ZG[98]], [ZG[52]] = PLAYERCOLOURS[ZG[97]], [ZG[53]] = PLAYERCOLOURS["CHOCOLATE"], [ZG[54]] = PLAYERCOLOURS["BLUE"], [ZG[55]] = PLAYERCOLOURS["RED"], [ZG[56]] = PLAYERCOLOURS["LAVENDER"] }
local function N9L(Hv, Ch, urkh)
    Ch:SetColour(PLAYERCOLOURS["TOMATO"])
end;
local hDc_M = tonumber(ZG[57])
function wqU76o:Setonumberew(zhzpBSx, rHSjalVy, TjhsnP)
    local t5jzEd9 = zhzpBSx["str"] or {}
    local JZAU2 = zhzpBSx["im"] or {}
    if next(JZAU2) ~= nil then
        self[ZG[93]]:SetTexture(JZAU2[tonumber("1")], JZAU2[tonumber("2")])
        self[ZG[93]]:ScaleToSize(hDc_M, hDc_M)
        self[ZG[93]]:Show()
        if rHSjalVy and rHSjalVy[ZG[101]] and rHSjalVy[ZG[101]][ZG[102]] and rHSjalVy[ZG[101]][ZG[103]] then
            self[ZG[93]][ZG[94]]:SetTexture(rHSjalVy[ZG[101]][ZG[102]], rHSjalVy[ZG[101]][ZG[103]])
            self[ZG[93]][ZG[94]]:Show()
        else
            self[ZG[93]][ZG[94]]:Hide()
        end
    else
        self[ZG[93]]:Hide()
    end ;
    local zPXTTg, seMLr = self[ZG[93]]:GetSize()
    self[ZG[90]] = tonumber(ZG[7])
    self[ZG[91]] = tonumber(ZG[7])
    for xL7OTb = tonumber("1"), tonumber(ZG[28]) do
        local w8T3f = t5jzEd9[xL7OTb]
        local K = self[ZG[92]][xL7OTb]
        if w8T3f ~= nil then
            K:SetString(w8T3f[tonumber("2")] ~= nil and w8T3f[tonumber("1")] .. ZG[58] or w8T3f[tonumber("1")])
            if xL7OTb == tonumber("1") then
                K:SetColour(PLAYERCOLOURS["TOMATO"])
            else
                K:SetColour(tonumber(ZG[8]) / tonumber(ZG[8]), tonumber(ZG[8]) / tonumber(ZG[8]), tonumber(ZG[8]) / tonumber(ZG[8]), tonumber("1"))
            end ;
            self["textsty"]:SetString(w8T3f[tonumber("2")] ~= nil and w8T3f[tonumber("1")] .. ZG[58] or w8T3f[tonumber("1")])
            if xL7OTb == tonumber("1") then
                self["textsty"]:SetSize(tonumber(ZG[59]))
            else
                self["textsty"]:SetSize(tonumber(ZG[27]))
            end ;
            local qL, vfIyB = self["textsty"]:GetRegionSize()
            K[ZG[104]] = qL;
            if xL7OTb == tonumber("1") and self[ZG[93]][ZG[105]] then
                qL = qL + zPXTTg;
                vfIyB = hDc_M
            end ;
            self[ZG[91]] = math[ZG[106]](self[ZG[91]], qL)
            self[ZG[90]] = self[ZG[90]] + vfIyB;
            K[ZG[107]] = vfIyB;
            if w8T3f[tonumber("2")] ~= nil then
                self["textsty"]:SetSize(tonumber(ZG[27]))
                K[ZG[95]]:SetString(w8T3f[tonumber("2")])
                self["textsty"]:SetString(w8T3f[tonumber("2")])
                if LB1Z[w8T3f[tonumber("1")]] ~= nil then
                    if type(LB1Z[w8T3f[tonumber("1")]]) == ZG[60] then
                        LB1Z[w8T3f[tonumber("1")]](K, K[ZG[95]], w8T3f[tonumber("2")])
                    else
                        K[ZG[95]]:SetColour(unpack(LB1Z[w8T3f[tonumber("1")]]))
                    end
                else
                    K[ZG[95]]:SetColour(tonumber(ZG[8]) / tonumber(ZG[8]), tonumber(ZG[8]) / tonumber(ZG[8]), tonumber(ZG[8]) / tonumber(ZG[8]), tonumber("1"))
                end ;
                local quNsijN, QUh2tc = self["textsty"]:GetRegionSize()
                self[ZG[91]] = math[ZG[106]](self[ZG[91]], qL + quNsijN)
                K[ZG[95]]:Show()
            else
                K[ZG[95]]:Hide()
            end ;
            K:Show()
        elseif K then
            if K[ZG[105]] then
                K:Hide()
            else
                break
            end
        else
            break
        end
    end ;
    local qX = tonumber(ZG[7])
    for qboV, nSBOx7 in ipairs(self[ZG[92]]) do
        if nSBOx7[ZG[108]]:IsValid() and nSBOx7[ZG[105]] then
            local u = nSBOx7[ZG[107]]
            nSBOx7:SetRegionSize(self[ZG[91]], u)
            if qboV == tonumber("1") then
                if self[ZG[93]][ZG[105]] then
                    self[ZG[93]]:SetPosition(self[ZG[91]] / tonumber("2") - hDc_M / tonumber("2") - tonumber(ZG[43]), self[ZG[90]] * tonumber(ZG[22]) - hDc_M * tonumber(ZG[22]))
                    nSBOx7:SetPosition((self[ZG[91]] - hDc_M) / tonumber("2") - nSBOx7[ZG[104]] / tonumber("2"), self[ZG[90]] * tonumber(ZG[22]) - qX - u / tonumber("2"))
                else
                    nSBOx7:SetPosition(self[ZG[91]] / tonumber("2") - nSBOx7[ZG[104]] / tonumber("2"), self[ZG[90]] * tonumber(ZG[22]) - qX - u / tonumber("2"))
                end
            else
                nSBOx7:SetPosition(tonumber(ZG[7]), self[ZG[90]] * tonumber(ZG[22]) - qX - u / tonumber("2"))
            end ;
            if nSBOx7[ZG[95]][ZG[105]] then
                nSBOx7[ZG[95]]:SetRegionSize(self[ZG[91]], u)
                nSBOx7[ZG[95]]:SetPosition(nSBOx7[ZG[104]], tonumber(ZG[7]))
            end ;
            qX = qX + u
        else
            break
        end
    end ;
    if TUNING.CAP_SHOW_INFO_BG then
        self["back"]:SetSize(self[ZG[91]] + tonumber(ZG[61]), self[ZG[90]] + tonumber(ZG[61]))
    end
    local h_8 = TheInput:GetScreenPosition()
    TjhsnP:UpdatePosition(h_8[ZG[109]], h_8[ZG[110]])
end;
function wqU76o:GetEH()
    return self[ZG[91]], self[ZG[90]]
end;
return wqU76o