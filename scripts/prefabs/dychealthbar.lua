local _tBsO = require "widgets/followtext"
local _z3w0 = { Asset("ATLAS", "images/dyc_white.xml"), Asset("IMAGE", "images/dyc_white.tex"), Asset("ATLAS", "images/dyc_shb_icon.xml"), Asset("IMAGE", "images/dyc_shb_icon.tex"), Asset("ATLAS", "images/dyc_button_close.xml"), Asset("IMAGE", "images/dyc_button_close.tex"), Asset("ATLAS", "images/dycghb_claw.xml"), Asset("IMAGE", "images/dycghb_claw.tex"), Asset("ATLAS", "images/dycghb_shadow.xml"), Asset("IMAGE", "images/dycghb_shadow.tex"), Asset("ATLAS", "images/dycghb_shadow_i.xml"), Asset("IMAGE", "images/dycghb_shadow_i.tex"), Asset("ATLAS", "images/dycghb_round.xml"), Asset("IMAGE", "images/dycghb_round.tex"), Asset("ATLAS", "images/dycghb_panel.xml"), Asset("IMAGE", "images/dycghb_panel.tex"), Asset("ATLAS", "images/dycghb_pixel.xml"), Asset("IMAGE", "images/dycghb_pixel.tex"), Asset("ATLAS", "images/dycghb_pixel_i.xml"), Asset("IMAGE", "images/dycghb_pixel_i.tex"), Asset("ATLAS", "images/dycghb_buckhorn.xml"), Asset("IMAGE", "images/dycghb_buckhorn.tex"), Asset("ATLAS", "images/dycghb_victorian.xml"), Asset("IMAGE", "images/dycghb_victorian.tex"), Asset("ATLAS", "images/dycghb_victorian_i.xml"), Asset("IMAGE", "images/dycghb_victorian_i.tex"), }
local _7PKa = {}
local _wuH7 = SimpleHealthBar
local _kJO7 = SimpleHealthBar.Color
local _iRjQ = SimpleHealthBar.lib.TableRemoveValue
local function _XtUU()
    return TheSim:GetGameID() == "DST"
end
local function _OSVB()
    return _XtUU() and not TheWorld.ismastersim
end
local function _E7Km()
    return PLATFORM == "WIN32_STEAM" or PLATFORM == "OSX_STEAM" or PLATFORM == "LINUX_STEAM"
end
local function _qOob()
    if _XtUU() then
        return ThePlayer
    else
        return GetPlayer()
    end
end
local function _wvbi(_YdTY)
    local _WqNB = _qOob()
    if _WqNB == _YdTY then
        return true
    end
    if not _WqNB or not _WqNB:IsValid() or not _YdTY:IsValid() then
        return false
    end
    local _ZPsL = _WqNB:GetPosition():Dist(_YdTY:GetPosition())
    return _ZPsL <= _wuH7.hbMaxDist
end
local function _rL1g(_jMlp)
    if TheSim.GetCameraPos ~= nil then
        local _3jFz = Vector3(TheSim:GetCameraPos())
        return _3jFz:Dist(_jMlp:GetPosition())
    else
        local _UuRF = TheCamera.pitch * DEGREES
        local _uMKW = TheCamera.heading * DEGREES
        local _Qb2U = math.cos(_UuRF)
        local _J58y = math.cos(_uMKW)
        local _euMZ = math.sin(_uMKW)
        local _O85P = -_Qb2U * _J58y
        local _Xh2U = -math.sin(_UuRF)
        local _kVoO = -_Qb2U * _euMZ
        local _HudB, zoffs = 0x0, 0x0
        if TheCamera.currentscreenxoffset ~= 0x0 then
            local _Jigm = 0x2 * TheCamera.currentscreenxoffset / RESOLUTION_Y
            local _eF5p = 1.03
            local _ShGn = math.tan(TheCamera.fov * .5 * DEGREES) * TheCamera.distance * _eF5p
            _HudB = -_Jigm * _euMZ * _ShGn
            zoffs = _Jigm * _J58y * _ShGn
        end
        local _OWkJ = Vector3(TheCamera.currentpos.x - _O85P * TheCamera.distance + _HudB, TheCamera.currentpos.y - _Xh2U * TheCamera.distance, TheCamera.currentpos.z - _kVoO * TheCamera.distance + zoffs)
        return _OWkJ:Dist(_jMlp:GetPosition())
    end
end
local _HPUV = SimpleHealthBar.ds("kti!")
local _zbSn = SimpleHealthBar.ds("~qk|wzqiv")
local _UZM4 = SimpleHealthBar.ds("xq\"mt")
local _Xomp = SimpleHealthBar.ds("j}kspwzv")
local _2GZ6 = SimpleHealthBar.ds("{pilw!")
local _oAUi = "images/dyc_white.xml"
local _dP7Q = "dyc_white.tex"
local _LOgx = -0x2d
local _LOh2 = 0x3c
local _KscH = { ["heart"] = { c1 = "♡", c2 = "♥", }, ["circle"] = { c1 = "○", c2 = "●", }, ["square"] = { c1 = "□", c2 = "■", }, ["diamond"] = { c1 = "◇", c2 = "◆", }, ["star"] = { c1 = "☆", c2 = "★", }, ["square2"] = { c1 = "░", c2 = "▓", }, ["basic"] = { c1 = "=", c2 = "#", numCoeff = 1.6, }, ["hidden"] = { c1 = " ", c2 = " ", }, ["chinese"] = { c1 = "口", c2 = "回", }, ["standard"] = { c1 = " ", c2 = " ", graphic = { basic = { atlas = "images/dyc_white.xml", texture = "dyc_white.tex", }, }, }, ["simple"] = { c1 = " ", c2 = " ", graphic = { bg = { atlas = "images/ui.xml", texture = "bg_plain.tex", color = _kJO7(0.3, 0.3, 0.3) }, bar = { atlas = "images/ui.xml", texture = "bg_plain.tex", margin = { x1 = 0x0, x2 = 0x0, y1 = 0x0, y2 = 0x0, }, }, basic = { atlas = "images/dyc_white.xml", texture = "dyc_white.tex", }, }, }, [_HPUV] = { c1 = " ", c2 = " ", graphic = { basic = { atlas = "images/dyc_white.xml", texture = "dyc_white.tex", }, bgSkn = { mode = "slice13", atlas = "images/dycghb_" .. _HPUV .. ".xml", texname = "dycghb_" .. _HPUV, texScale = 0x3e7, margin = { x1 = -0.75, x2 = -0.75, y1 = -0.225, y2 = -0.225, fixed = false }, }, barSkn = { mode = "slice33", atlas = "images/dycghb_round.xml", texname = "dycghb_round", texScale = 0x1, margin = { x1 = 0.015, x2 = 0.015, y1 = 0.06, y2 = 0.06, fixed = false }, }, }, }, [_zbSn] = { c1 = " ", c2 = " ", graphic = { basic = { atlas = "images/dyc_white.xml", texture = "dyc_white.tex", }, bgSkn = { mode = "slice13", atlas = "images/dycghb_" .. _zbSn .. ".xml", texname = "dycghb_" .. _zbSn, texScale = 0x3e7, margin = { x1 = -1.7, x2 = -1.7, y1 = -0.45, y2 = -0.55, fixed = false }, }, barSkn = { mode = "slice33", atlas = "images/dycghb_" .. _zbSn .. "_i.xml", texname = "dycghb_" .. _zbSn .. "_i", texScale = 0.25, margin = { x1 = 0.03, x2 = 0.03, y1 = 0.15, y2 = 0.15, fixed = false }, }, }, }, [_Xomp] = { c1 = " ", c2 = " ", graphic = { basic = { atlas = "images/dyc_white.xml", texture = "dyc_white.tex", }, bgSkn = { mode = "slice13", atlas = "images/dycghb_" .. _Xomp .. ".xml", texname = "dycghb_" .. _Xomp, texScale = 0x3e7, margin = { x1 = -1.2, x2 = -1.2, y1 = -0.43, y2 = -0.48, fixed = false }, }, bar = { atlas = "images/ui.xml", texture = "bg_plain.tex", margin = { x1 = 0x0, x2 = 0x0, y1 = 0x0, y2 = 0x0, fixed = false }, }, }, }, [_UZM4] = { c1 = " ", c2 = " ", graphic = { basic = { atlas = "images/dyc_white.xml", texture = "dyc_white.tex", }, bgSkn = { mode = "slice13", atlas = "images/dycghb_" .. _UZM4 .. ".xml", texname = "dycghb_" .. _UZM4, texScale = 0x3e7, margin = { x1 = -1.1, x2 = -0.4, y1 = -0.365, y2 = -0.285, fixed = false }, }, barSkn = { mode = "slice13", atlas = "images/dycghb_" .. _UZM4 .. "_i.xml", texname = "dycghb_" .. _UZM4 .. "_i", texScale = 0x3e7, margin = { x1 = -1.1, x2 = -0.4, y1 = -0.365, y2 = -0.285, fixed = false }, vmargin = { x1 = 0.675, x2 = -0.075, y1 = 0.1, y2 = 0.13, fixed = false }, }, hrUseBarColor = true, }, }, [_2GZ6] = { c1 = " ", c2 = " ", graphic = { basic = { atlas = "images/dyc_white.xml", texture = "dyc_white.tex", }, bgSkn = { mode = "slice33", atlas = "images/dycghb_" .. _2GZ6 .. ".xml", texname = "dycghb_" .. _2GZ6, texScale = 0.5, margin = { x1 = -0xb, x2 = -0xb, y1 = -0x9, y2 = -0xb, fixed = true }, }, barSkn = { mode = "slice33", atlas = "images/dycghb_" .. _2GZ6 .. "_i.xml", texname = "dycghb_" .. _2GZ6 .. "_i", texScale = 0.3, }, }, }, }
local _z3Bp = { { prefab = "shadowtentacle", width = 0.5, height = 0x2, }, { prefab = "mean_flytrap", width = 0.9, height = 2.3, }, { prefab = "thunderbird", width = 0.85, height = 2.05, }, { prefab = "glowfly", width = 0.6, height = 0x2, }, { prefab = "peagawk", width = 0.85, height = 2.1, }, { prefab = "krampus", width = 0x1, height = 3.75, }, { prefab = "nightmarebeak", width = 0x1, height = 4.5, }, { prefab = "terrorbeak", width = 0x1, height = 4.5, }, { prefab = "spiderqueen", width = 0x2, height = 4.5, }, { prefab = "warg", width = 1.7, height = 0x5, }, { prefab = "pumpkin_lantern", width = 0.7, height = 1.5, }, { prefab = "jellyfish_planted", width = 0.7, height = 1.5, }, { prefab = "babybeefalo", width = 0x1, height = 2.2, }, { prefab = "beeguard", width = 0.65, height = 0x2, }, { prefab = "shadow_rook", width = 1.8, height = 3.5, }, { prefab = "shadow_bishop", width = 0.9, height = 3.2, }, { prefab = "walrus", width = 1.1, height = 3.2, }, { prefab = "teenbird", width = 1.0, height = 3.6, }, { tag = "player", width = 0x1, height = 2.65, }, { tag = "ancient_hulk", width = 1.85, height = 4.5, }, { tag = "antqueen", width = 2.4, height = 0x8, }, { tag = "ro_bin", width = 0.9, height = 2.8, }, { tag = "gnat", width = 0.75, height = 0x3, }, { tag = "spear_trap", width = 0.75, height = 0x3, }, { tag = "hangingvine", width = 0.85, height = 0x4, }, { tag = "weevole", width = 0.6, height = 1.2, }, { tag = "flytrap", width = 0x1, height = 3.4, }, { tag = "vampirebat", width = 0x1, height = 0x3, }, { tag = "pangolden", width = 1.4, height = 3.8, }, { tag = "spider_monkey", width = 1.6, height = 0x4, }, { tag = "hippopotamoose", width = 1.35, height = 3.1, }, { tag = "piko", width = 0.5, height = 0x1, }, { tag = "pog", width = 0.85, height = 0x2, }, { tag = "ant", width = 0.8, height = 2.3, }, { tag = "scorpion", width = 0.85, height = 0x2, }, { tag = "dungbeetle", width = 0.8, height = 2.3, }, { tag = "civilized", width = 0x1, height = 3.2, }, { tag = "koalefant", width = 1.7, height = 0x4, }, { tag = "spat", width = 1.5, height = 3.5, }, { tag = "lavae", width = 0.8, height = 1.5, }, { tag = "glommer", width = 0.9, height = 2.9, }, { tag = "deer", width = 0x1, height = 3.1, }, { tag = "snake", width = 0.85, height = 1.7, }, { tag = "eyeturret", width = 0x1, height = 4.5, }, { tag = "primeape", width = 0.85, height = 1.5, }, { tag = "monkey", width = 0.85, height = 1.5, }, { tag = "ox", width = 1.5, height = 3.75, }, { tag = "beefalo", width = 1.5, height = 3.75, }, { tag = "kraken", width = 0x2, height = 5.5, }, { tag = "nightmarecreature", width = 1.25, height = 3.5, }, { tag = "bishop", width = 0x1, height = 0x4, }, { tag = "rook", width = 1.25, height = 0x4, }, { tag = "knight", width = 0x1, height = 0x3, }, { tag = "bat", width = 0.8, height = 0x3, }, { tag = "minotaur", width = 1.75, height = 4.5, }, { tag = "packim", width = 0.9, height = 3.75, }, { tag = "stungray", width = 0.9, height = 3.75, }, { tag = "ghost", width = 0.9, height = 3.75, }, { tag = "tallbird", width = 1.25, height = 0x5, }, { tag = "chester", width = 0.85, height = 1.5, }, { tag = "hutch", width = 0.85, height = 1.5, }, { tag = "wall", width = 0.5, height = 1.5, }, { tag = "largecreature", width = 0x2, height = 7.2, }, { tag = "insect", width = 0.5, height = 1.6, }, { tag = "smallcreature", width = 0.85, height = 1.5, }, }
local function _3aCD(_5rvh)
    if _5rvh < 0x0 then
        _5rvh = 0x0
    elseif _5rvh > 0x1 then
        _5rvh = 0x1
    end
    return _5rvh
end
local function _7ovh(_4LST, _dcLg)
    local _Toti = _qOob()
    local _guPJ = _dcLg or (_4LST and _Toti == _4LST and _wuH7.hbStyleChar) or (_4LST and _4LST["dycshb_cstyle_net"] and _4LST["dycshb_cstyle_net"]:value()) or (_4LST and _4LST:HasTag("epic") and _wuH7.hbStyleBoss) or _wuH7.hbStyle
    if type(_guPJ) == "table" and _guPJ.c1 and _guPJ.c2 then
        return _guPJ
    end
    return _KscH[_guPJ] or _KscH["standard"]
end
SimpleHealthBar.GetHBStyle = _7ovh
local function _ErGv(_8Fpc, _mDVu, _t8Ax)
    local _ta78 = _qOob()
    local _JsEx = _7ovh(_t8Ax)
    local _rvFP = _JsEx.c1
    local _RuwL = _JsEx.c2
    local _MVNQ = _wuH7.hbCNum * (_JsEx.numCoeff or 0x1)
    local _Raiz = ""
    if _wuH7.hbPosition == "bottom" then
        _Raiz = "  \n  \n  \n  \n"
    end
    local _wQHJ = _8Fpc / _mDVu
    for _qrWU = 0x1, _MVNQ do
        if _wQHJ == 0x0 or (_qrWU ~= 0x1 and _qrWU * 1.0 / _MVNQ > _wQHJ) then
            _Raiz = _Raiz .. _rvFP
        else
            _Raiz = _Raiz .. _RuwL
        end
    end
    return _Raiz
end
local function _Y6Zg(_wQam)
    if not _wQam then
        return 0x1
    end
    for _XjdN, _9Ju2 in pairs(_z3Bp) do
        if _9Ju2.width and (_wQam.prefab == _9Ju2.prefab or (_9Ju2.tag and _wQam:HasTag(_9Ju2.tag))) then
            return _9Ju2.width
        end
    end
    return 0x1
end
local function _hkRI(_vTPs)
    if not _vTPs then
        return 2.65
    end
    for _1HM3, _U4g9 in pairs(_z3Bp) do
        if _U4g9.height and (_vTPs.prefab == _U4g9.prefab or (_U4g9.tag and _vTPs:HasTag(_U4g9.tag))) then
            return _U4g9.height
        end
    end
    return 2.65
end
local function _IU1V(_Fqo6)
    _Fqo6 = _Fqo6 or {}
    local _VA3I = _Fqo6.owner
    local _6EzW = _Fqo6.info or _wuH7.hbColor
    local _vPCg = _Fqo6.hpp
    local _Joze = _qOob()
    if type(_6EzW) == "table" and _6EzW.Get then
        return _6EzW:Get()
    elseif type(_6EzW) == "table" and _6EzW.r and _6EzW.g and _6EzW.b then
        return _6EzW.r, _6EzW.g, _6EzW.b, _6EzW.a or 0x1
    elseif type(_6EzW) == "string" and (_6EzW == "dynamic_dark" or _6EzW == "dark") and _vPCg then
        local _qGoZ, g = _3aCD((0x1 - _vPCg) * 0x2), _3aCD(_vPCg * 0x2)
        return _qGoZ * 0.7, g * 0.5, 0x0, 0x1
    elseif type(_6EzW) == "string" and (_6EzW == "dynamic_hostility" or _6EzW == "hostility" or _6EzW == "dynamic2") then
        if _VA3I and _VA3I == _Joze then
            return 0.15, 0.55, 0.7, 0x1
        end
        if _VA3I and _VA3I.components.combat then
            local _dgB2 = _VA3I.components.combat.defaultdamage
            if _VA3I.components.combat.target == _Joze and not _VA3I:HasTag("chester") and _dgB2 and type(_dgB2) == "number" and _dgB2 > 0x0 then
                return 0.8, 0x0, 0x0, 0x1
            end
        end
        if _VA3I and _VA3I.replica and _VA3I.replica.combat and _VA3I.replica.combat.GetTarget then
            if _VA3I.replica.combat:GetTarget() == _Joze then
                return 0.8, 0x0, 0x0, 0x1
            end
        end
        if _VA3I and _VA3I.components.follower then
            if _VA3I.components.follower.leader == _Joze then
                return 0.1, 0.7, 0.2, 0x1
            end
        end
        if _VA3I and _VA3I.replica and _VA3I.replica.follower and _VA3I.replica.follower.GetLeader then
            if _VA3I.replica.follower:GetLeader() == _Joze then
                return 0.1, 0.7, 0.2, 0x1
            end
        end
        if _VA3I and _VA3I:HasTag("hostile") then
            return 0.8, 0.5, 0.1, 0x1
        end
        if _VA3I and _VA3I:HasTag("monster") then
            return 0.7, 0.7, 0.1, 0x1
        end
        if _VA3I and (_VA3I:HasTag("chester") or _VA3I:HasTag("companion")) then
            return 0.1, 0.7, 0.2, 0x1
        end
        if _VA3I and _VA3I:HasTag("player") then
            return 0x75 / 0xff, 0x1b / 0xff, 0xc6 / 0xff, 0x1
        end
        return 0.7, 0.7, 0.7, 0x1
    elseif type(_6EzW) == "string" and type(SimpleHealthBar.Color[_6EzW]) == "table" then
        return SimpleHealthBar.Color[_6EzW]:Get()
    elseif _vPCg then
        local _cefo, g = _3aCD((0x1 - _vPCg) * 0x2), _3aCD(_vPCg * 0x2)
        return _cefo, g, 0x0, 0x1
    end
    return 0x1, 0x1, 0x1, 0x1
end
SimpleHealthBar.GetEntHBColor = _IU1V
local function _SIx0(_5VW4)
    return _5VW4:HasTag("wall") or _5VW4:HasTag("spear_trap") or (_5VW4.prefab and _5VW4.prefab == "shadowtentacle")
end
local function _0hwx(_iZIf)
    local _B9zt = nil
    if not _iZIf.dychbowner then
        _iZIf.dychbowner = _iZIf.entity:GetParent()
        if not _iZIf.dychbowner then
            _iZIf:Remove()
            return
        end
        _iZIf.dychbowner.dychealthbar = _iZIf
    end
    _B9zt = _iZIf.dychbowner
    if _XtUU() or _wuH7.hbPosition == "bottom" then
        _iZIf.dychbtext = _iZIf.dychbowner:SpawnChild("dyc_healthbarchild")
    else
        _iZIf.dychbtext = _iZIf:SpawnChild("dyc_healthbarchild")
    end
    _iZIf:EnableText(false)
    _iZIf.dychbtext:EnableText(false)
    _iZIf.SetHBHeight = function(_vWF8, _bz2O)
        if _wuH7.hbPosition == "bottom" then
            _bz2O = 0x0
        end
        if _XtUU() then
            _vWF8:SetOffset(0x0, _bz2O, 0x0)
            _vWF8.dychbtext:SetOffset(0x0, _bz2O, 0x0)
        else
            _vWF8.dychbheight = _bz2O * 1.5
        end
    end
    _iZIf.dychbheightconst = _hkRI(_iZIf.dychbowner)
    _iZIf:SetHBHeight(_iZIf.dychbheightconst)
    _iZIf.SetHBSize = function(_9aG2, _ykeW)
        local _rLlY = math.max(0x1, (0xd - _wuH7.hbCNum) / 0x5) * 0xf * _ykeW
        _9aG2:SetFontSize(_rLlY)
        _9aG2.dychbtext:SetFontSize(0x14 * _ykeW)
        local _BFoj = _9aG2.graphicHealthbar
        if _BFoj then
            if not _wuH7.hbFixedThickness then
                local _k1Qn = _wuH7.hbThickness or 0x1
                _BFoj:SetHBSize(0x78 * _wuH7.hbCNum / 0xa, 0x12 * _k1Qn)
                _BFoj:SetHBScale(_ykeW)
            else
                local _IvAc = _wuH7.hbThickness or 0x12
                _BFoj:SetHBSize(0x78 * _wuH7.hbCNum / 0xa * _ykeW, _IvAc)
            end
        end
    end
    _iZIf:SetHBSize(_Y6Zg(_iZIf.dychbowner))
    if _iZIf.graphicHealthbar then
        local _OW35 = _iZIf.graphicHealthbar
        _OW35:SetTarget(_B9zt)
        local _dyZG = _7ovh(_B9zt).graphic
        if _dyZG then
            _OW35:SetData(_dyZG)
            _OW35:SetOpacity(_wuH7.hbOpacity or _dyZG.opacity or 0.8)
            _OW35:SetHBScale()
        end
        if _dyZG and not _OW35.shown then
            local _3h4Z = not _wuH7.hbWallHb and _OW35.target and _SIx0(_OW35.target)
            if not _3h4Z then
                _OW35:Show()
            end
        end
        if _wuH7.hbAnimation then
            if _B9zt:HasTag("largecreature") then
                _OW35:AnimateIn(0x2)
            else
                _OW35:AnimateIn(0x8)
            end
        end
    end
    _iZIf.dycHbStarted = true
end
SimpleHealthBar[SimpleHealthBar.ds("wv]xli|mPJ")] = function()
    for _KD87, _VVX0 in pairs(SimpleHealthBar.GHB.ghbs) do
        local _YL10 = _7ovh(_VVX0.target).graphic
        local _IvYk = _wuH7.hbWallHb ~= true and _VVX0.target and _VVX0.target:HasTag("wall")
        if _YL10 and not _IvYk and not _VVX0.shown then
            _VVX0:Show()
        elseif (not _YL10 or _IvYk) and _VVX0.shown then
            _VVX0:Hide()
        end
        if _YL10 then
            _VVX0:SetData(_YL10)
            _VVX0:SetOpacity(_wuH7.hbOpacity or _YL10.opacity or 0.8)
            _VVX0:SetHBScale()
        end
    end
end
local function _SOgN(_KDnM)
    local _rjT3 = CreateEntity()
    _rjT3.entity:AddTransform()
    _rjT3:AddTag("FX")
    _rjT3:AddTag("NOCLICK")
    _rjT3:AddTag("notarget")
    local _WO4u = not _KDnM
    local _KyIQ = _rjT3.entity:AddLabel()
    _KyIQ:SetFont(NUMBERFONT)
    _KyIQ:SetFontSize(0x1c)
    _KyIQ:SetColour(0x1, 0x1, 0x1)
    _KyIQ:SetText(" ")
    _KyIQ:Enable(true)
    _rjT3.text = _KyIQ
    _rjT3.SetFontSize = function(_2TCW, _HKnd)
        _2TCW.text:SetFontSize(_HKnd)
    end
    _rjT3.SetOffset = function(_4cxR, _JPYo, _arpg, _qvPL)
        _4cxR.text:SetWorldOffset(_JPYo, _arpg, _qvPL)
    end
    _rjT3.SetText = function(_b4dk, _QHqj)
        _b4dk.text:SetText(_QHqj)
    end
    _rjT3.EnableText = function(_Xir9, _luf9)
        _Xir9.text:Enable(_luf9)
    end
    local _qkSo = _rjT3.Remove
    _rjT3.persists = false
    _rjT3.InitHB = _0hwx
    return _rjT3
end
local function _Wcuh(_0Qts)
    if not _qOob() or not _qOob().HUD then
        return
    end
    local _jBAG = _7ovh().graphic
    local _d0UN = _qOob().HUD.overlayroot:AddChild(SimpleHealthBar.GHB(_jBAG or { basic = { atlas = _oAUi, texture = _dP7Q, } }))
    _d0UN:MoveToBack()
    _d0UN:Hide()
    _d0UN:SetFontSize(0x20)
    _d0UN:SetYOffSet(_LOgx, true)
    _d0UN:SetTextColor(0x1, 0x1, 0x1, 0x1)
    _d0UN:SetOpacity(_wuH7.hbOpacity or (_jBAG and _jBAG.opacity) or 0.8)
    _d0UN:SetStyle("textoverbar")
    _d0UN.preUpdateFn = function(_Hdxx)
        if _7ovh(_d0UN.target).graphic and _Hdxx > 0x0 and _d0UN.target and _wuH7.hbPosition == "overhead" then
            local _Wn4B = 0x1e / _rL1g(_d0UN.target)
            _d0UN:SetYOffSet(_0Qts.dychbheightconst * _LOh2 * _Wn4B)
            _d0UN:SetStyle("textoverbar")
            if _d0UN.fontSize ~= 0x20 then
                _d0UN:SetFontSize(0x20)
            end
        elseif _7ovh(_d0UN.target).graphic and _Hdxx > 0x0 and _d0UN.target and _wuH7.hbPosition == "overhead2" then
            local _xYcQ = 0x1e / _rL1g(_d0UN.target)
            _d0UN:SetYOffSet(_0Qts.dychbheightconst * _LOh2 * _xYcQ)
            _d0UN:SetStyle("")
            if _d0UN.fontSize ~= 0x18 then
                _d0UN:SetFontSize(0x18)
            end
        elseif _7ovh(_d0UN.target).graphic and _Hdxx > 0x0 and _d0UN.target and _wuH7.hbPosition == "bottom" then
            _d0UN:SetYOffSet(_LOgx, true)
            _d0UN:SetStyle("textoverbar")
            if _d0UN.fontSize ~= 0x20 then
                _d0UN:SetFontSize(0x20)
            end
        end
    end
    _0Qts.graphicHealthbar = _d0UN
end
local function _lq0g(_NBZ9)
    table.insert(SimpleHealthBar.hbs, _NBZ9)
    if _wuH7.hbLimit > 0x0 and #SimpleHealthBar.hbs > _wuH7.hbLimit then
        local _J6t9 = SimpleHealthBar.hbs[0x1]
        table.remove(SimpleHealthBar.hbs, 0x1)
    end
end
local function _o7av()
    local _SU5u = _SOgN()
    if _XtUU() then
        _SU5u.entity:AddNetwork()
    end
    _SU5u:SetFontSize(0xf)
    if _XtUU() then
        _SU5u.dychpini = -0x1
        _SU5u.dychp = 0x0
        _SU5u.dychp_net = net_float(_SU5u.GUID, "dyc_healthbar.hp", "dychpdirty")
        _SU5u:ListenForEvent("dychpdirty", function(_JCCn)
            local _WuCI = _JCCn.dychp_net:value()
            if _JCCn.dychpini == -0x1 then
                _JCCn.dychpini = _WuCI
                if not _wuH7.hbDDOn then
                    _JCCn.dychpini = -0x2
                end
            end
            if _wuH7.hbDDOn then
                if _JCCn.dychbowner and _wvbi(_JCCn.dychbowner) then
                    local _i2Tb = SpawnPrefab("dyc_damagedisplay")
                    if _JCCn.dychpini > 0x0 then
                        _i2Tb:DamageDisplay(_JCCn.dychbowner, { hpOld = _JCCn.dychpini, hpNewDefault = _WuCI })
                        _JCCn.dychpini = -0x2
                    else
                        _i2Tb:DamageDisplay(_JCCn.dychbowner, { hpNewDefault = _WuCI })
                    end
                end
            end
            _JCCn.dychp = _WuCI
        end)
        _SU5u.dychpmax = 0x0
        _SU5u.dychpmax_net = net_float(_SU5u.GUID, "dyc_healthbar.hpmax", "dychpmaxdirty")
        _SU5u:ListenForEvent("dychpmaxdirty", function(_NMh3)
            _NMh3.dychpmax = _NMh3.dychpmax_net:value()
        end)
    end
    local _Lt3M = -0x1
    local _bVdK = -0x1
    local _TxiY = 0x0
    local _mITM = true
    local _3RhT = false
    _SU5u.dycHbStarted = false
    _SU5u.OnRemoveEntity = function(_YNts)
        if _XtUU() and _YNts.dychbowner and _wuH7.hbDDOn and _wvbi(_YNts.dychbowner) then
            local _8r1R = SpawnPrefab("dyc_damagedisplay")
            _8r1R:DamageDisplay(_YNts.dychbowner, { hpNewDefault = _YNts.dychp })
        end
        _YNts.Label:SetText(" ")
        if _YNts.dychbowner then
            _YNts.dychbowner.dychealthbar = nil
        end
        if _YNts.dychbtext then
            _YNts.dychbtext:Remove()
        end
        if _YNts.dychbtask then
            _YNts.dychbtask:Cancel()
        end
        if _YNts.graphicHealthbar then
            if _wuH7.hbAnimation then
                _YNts.graphicHealthbar:AnimateOut(0x6)
            else
                _YNts.graphicHealthbar:Kill()
            end
        end
        _iRjQ(SimpleHealthBar.hbs, _YNts)
    end
    function _SU5u:DYCHBSetTimer(_mswL)
        _TxiY = _mswL
        _3RhT = true
    end
    _Wcuh(_SU5u)
    _lq0g(_SU5u)
    _SU5u.dychbtask = _SU5u:DoPeriodicTask(FRAMES, function()
        if not _SU5u.dycHbStarted then
            return
        end
        local _ZhUy = _SU5u.dychbowner
        if not _ZhUy then
            return
        end
        local _1ttX = _SU5u.dychbattacker
        local _y1Ez = nil
        if not _OSVB() then
            _y1Ez = _ZhUy.components.health
        else
            _y1Ez = _ZhUy.replica.health
        end
        local _mNvJ = _wuH7.hbDuration
        if not _ZhUy:IsValid() or _ZhUy.inlimbo or _ZhUy:HasTag("playerghost") or (not _XtUU() and not _wvbi(_ZhUy)) or (_OSVB() and not _ZhUy:HasTag("player")) or _y1Ez == nil or _y1Ez:IsDead() or (_mNvJ > 0x0 and _TxiY >= _mNvJ) then
            if not _OSVB() then
                _SU5u:Remove()
                return
            end
        end
        if _ZhUy.dychealthbar ~= _SU5u then
            _SU5u:Remove()
            return
        end
        if not _ZhUy:IsValid() then
            return
        end
        local _jhi6 = 0x0
        local _Eyf7 = 0x0
        if not _XtUU() then
            _jhi6 = _y1Ez.currenthealth
            _Eyf7 = _y1Ez.maxhealth
        else
            _jhi6 = _SU5u.dychp
            _Eyf7 = _SU5u.dychpmax
        end
        if _y1Ez ~= nil and (_wuH7.hbForceUpdate == true or _Lt3M ~= _jhi6 or _bVdK ~= _Eyf7 or _3RhT) then
            _3RhT = false
            _Lt3M = _jhi6
            _bVdK = _Eyf7
            local _aKNT = not _wuH7.hbWallHb and _ZhUy and _ZhUy:HasTag("wall")
            if _aKNT then
                _SU5u:EnableText(false)
                _SU5u.dychbtext:EnableText(false)
            else
                _SU5u:EnableText(true)
                _SU5u.dychbtext:EnableText(true)
            end
            _SU5u:SetText(_ErGv(_Lt3M, _bVdK, _ZhUy))
            if _wuH7.hbValue and not _7ovh(_ZhUy).graphic then
                if _wuH7.hbPosition ~= "bottom" then
                    _SU5u.dychbtext:SetText(string.format(" %d/%d\n   ", _Lt3M, _bVdK))
                else
                    _SU5u.dychbtext:SetText(string.format("  \n  \n %d/%d\n   ", _Lt3M, _bVdK))
                end
            else
                _SU5u.dychbtext:SetText("")
            end
            if _SU5u.SetHBHeight and _SU5u.dychbheightconst then
                _SU5u:SetHBHeight(_SU5u.dychbheightconst)
            end
            local _4wyA = _Lt3M / _bVdK
            _SU5u.text:SetColour(_IU1V({ owner = _ZhUy, hpp = _4wyA, }))
            if _SU5u.graphicHealthbar then
                local _aH8f = _SU5u.graphicHealthbar
                local _XuUJ = _7ovh(_ZhUy).graphic
                if _XuUJ then
                    _aH8f.showValue = _wuH7.hbValue
                    _aH8f:SetValue(_Lt3M, _bVdK, _mITM)
                    _aH8f:SetBarColor(_IU1V({ owner = _ZhUy, hpp = _4wyA, }))
                end
            end
            _mITM = false
        end
        local _xtu6 = true
        local _j3gu = nil
        if not _OSVB() then
            _j3gu = _ZhUy.components.combat
        else
            _j3gu = _ZhUy.replica.combat
        end
        if _j3gu and _j3gu.target then
            _xtu6 = false
        else
            if _1ttX and _1ttX:IsValid() then
                local _5rHe = nil
                local _kAgB = nil
                if not _OSVB() then
                    _5rHe = _1ttX.components.health
                    _kAgB = _1ttX.components.combat
                else
                    _5rHe = _1ttX.replica.health
                    _kAgB = _1ttX.replica.combat
                end
                if _5rHe and not _5rHe:IsDead() and _kAgB and _kAgB.target == _ZhUy then
                    _xtu6 = false
                end
            end
        end
        if _xtu6 then
            _TxiY = _TxiY + FRAMES
        else
            _TxiY = 0x0
        end
        if _XtUU() or _wuH7.hbPosition == "bottom" then
        else
            local _cWxr = _ZhUy:GetPosition()
            _cWxr.y = _SU5u.dychbheight or 0x0
            _SU5u.Transform:SetPosition(_cWxr:Get())
        end
    end)
    if _OSVB() then
        _SU5u:DoTaskInTime(0x0, function()
            _SU5u:InitHB()
        end)
    end
    return _SU5u
end
local function _PK3b(_CdzO, _OqWY, _wIIl)
    if not _CdzO:IsValid() or not _OqWY:IsValid() or _OqWY.dycddcd == true then
        _CdzO:Remove()
        return
    end
    _OqWY.dycddcd = true
    local _diYh = nil
    if not _OSVB() then
        _diYh = _OqWY.components.health
    else
        _diYh = _OqWY.replica.health
    end
    _CdzO.Transform:SetPosition((_OqWY:GetPosition() + Vector3(0x0, _hkRI(_OqWY) * 0.65, 0x0)):Get())
    local _DtYM = (_wIIl and _wIIl.hpOld) or (not _XtUU() and _OqWY.components.health.currenthealth) or (_OqWY.dychealthbar and _OqWY.dychealthbar.dychp) or (_diYh and _diYh:IsDead() and 0x0) or (_wIIl and _wIIl.hpOldDefault) or 0x0
    local _ZtqK = false
    local _AHda = math.random() * 0x168
    local _7D4X = _wuH7.hbDDDuration / 0x2
    local _ztEg = 0x1
    local _EBPP = 0x2
    local _FSSL = 0x2 * _EBPP / _7D4X / _7D4X
    local _15y4 = 0x0
    local _8qXw = _ztEg / _7D4X
    local _Vrmi = math.sqrt(0x2 * _FSSL * _EBPP)
    local _WYoh = _7D4X * 0x2
    local _mV12 = false
    local _OUVU = _wuH7.hbDDDelay
    local _NSMc = 0x0
    _CdzO.dycddtask = _CdzO:DoPeriodicTask(FRAMES, function()
        if not _CdzO:IsValid() or not _OqWY:IsValid() then
            _CdzO.dycddtask:Cancel()
            _CdzO:Remove()
            return
        end
        _NSMc = _NSMc + FRAMES
        _15y4 = _NSMc - _OUVU
        if _NSMc > _OUVU then
            if _ZtqK == false then
                _OqWY.dycddcd = false
                local _Nigg = (_wIIl and _wIIl.hpNew) or (not _XtUU() and _OqWY.components.health.currenthealth) or (_OqWY.dychealthbar and _OqWY.dychealthbar.dychp) or (_diYh and _diYh:IsDead() and 0x0) or (_wIIl and _wIIl.hpNewDefault) or 0x0
                local _LPTE = _Nigg - _DtYM
                local _jjcQ = math.abs(_LPTE)
                if _jjcQ < _wuH7.hbDDThreshold then
                    _CdzO.dycddtask:Cancel()
                    _CdzO:Remove()
                    return
                else
                    _ZtqK = true
                    _CdzO.Label:Enable(true)
                    local _QHbi = ""
                    if _LPTE > 0x0 then
                        _CdzO.Label:SetColour(0x0, 0x1, 0x0)
                        _QHbi = "+"
                    else
                        _CdzO.Label:SetColour(0x1, 0x0, 0x0)
                        _mV12 = true
                    end
                    if _jjcQ < 0x1 then
                        _CdzO.Label:SetText(_QHbi .. string.format("%.2f", _LPTE))
                    elseif _jjcQ < 0x64 then
                        _CdzO.Label:SetText(_QHbi .. string.format("%.1f", _LPTE))
                    else
                        _CdzO.Label:SetText(_QHbi .. string.format("%d", _LPTE))
                    end
                end
            end
            local _hwtQ = _CdzO:GetPosition()
            local _nICU = Vector3(_8qXw * FRAMES * math.cos(_AHda), _Vrmi * FRAMES, _8qXw * FRAMES * math.sin(_AHda))
            _CdzO.Transform:SetPosition(_hwtQ.x + _nICU.x, _hwtQ.y + _nICU.y, _hwtQ.z + _nICU.z)
            _Vrmi = _Vrmi - _FSSL * FRAMES
            local _0Z7g = (0x1 - math.abs(_15y4 / _7D4X - 0x1)) * (_wuH7.hbDDSize2 - _wuH7.hbDDSize1) + _wuH7.hbDDSize1
            _CdzO.Label:SetFontSize(_0Z7g)
            if _mV12 then
                local _kNqq = 0x1 - _3aCD(_15y4 / _7D4X - 0.5)
                _CdzO.Label:SetColour(0x1, _kNqq, _kNqq)
            end
            if _15y4 >= _WYoh then
                _CdzO.dycddtask:Cancel()
                _CdzO:Remove()
            end
        end
    end)
end
local function _NVTM()
    local _kfGh = _SOgN(true)
    _kfGh.Label:SetFontSize(_wuH7.hbDDSize1)
    _kfGh.Label:Enable(false)
    _kfGh.InitHB = nil
    _kfGh.DamageDisplay = _PK3b
    return _kfGh
end
return Prefab("common/dyc_damagedisplay", _NVTM, _z3w0, _7PKa), Prefab("common/dyc_healthbarchild", _SOgN, _z3w0, _7PKa), Prefab("common/dyc_healthbar", _o7av, _z3w0, _7PKa)