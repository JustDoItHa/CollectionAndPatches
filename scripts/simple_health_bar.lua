local function _Qeim()
    return GLOBAL.TheSim:GetGameID() == "DST"
end
local function _XldX()
    return _Qeim() and GLOBAL.TheNet:GetIsClient()
end
local function _jARb()
    return _Qeim() and GLOBAL.TheNet:IsDedicated()
end
local function _nFmz()
    if _Qeim() then
        return GLOBAL.ThePlayer
    else
        return GLOBAL.GetPlayer()
    end
end
local function _3xtY()
    if _Qeim() then
        return GLOBAL.TheWorld
    else
        return GLOBAL.GetWorld()
    end
end
local function _y0FS(_mhgO)
    local _IgDh = nil
    for _mgAR, _7vHJ in pairs(GLOBAL.AllPlayers) do
        if _7vHJ.userid == _mhgO then
            _IgDh = _7vHJ
        end
    end
    return _IgDh
end
--PrefabFiles = { "dychealthbar", }
table.insert(PrefabFiles, "dychealthbar")
--Assets = {}
STRINGS = GLOBAL.STRINGS
RECIPETABS = GLOBAL.RECIPETABS
Recipe = GLOBAL.Recipe
Ingredient = GLOBAL.Ingredient
TECH = GLOBAL.TECH
TUNING = GLOBAL.TUNING
FRAMES = GLOBAL.FRAMES
SpawnPrefab = GLOBAL.SpawnPrefab
Vector3 = GLOBAL.Vector3
tostring = GLOBAL.tostring
tonumber = GLOBAL.tonumber
require = GLOBAL.require
TheSim = GLOBAL.TheSim
net_string = GLOBAL.net_string
net_float = GLOBAL.net_float
local _qMpK = function(_YcEB, _0pNR, _KGe0, _JA9Q)
    return { r = _YcEB or 0x1, g = _0pNR or 0x1, b = _KGe0 or 0x1, a = _JA9Q or 0x1, Get = function(_fyod)
        return _fyod.r, _fyod.g, _fyod.b, _fyod.a
    end, Set = function(_6KYh, _eFBI, _0TIW, _L54k, _MOXs)
        _6KYh.r = _eFBI or 0x1;
        _6KYh.g = _0TIW or 0x1;
        _6KYh.b = _L54k or 0x1;
        _6KYh.a = _MOXs or 0x1;
    end, }
end
local _DVHQ = { New = _qMpK, Red = _qMpK(0x1, 0x0, 0x0, 0x1), Green = _qMpK(0x0, 0x1, 0x0, 0x1), Blue = _qMpK(0x0, 0x0, 0x1, 0x1), White = _qMpK(0x1, 0x1, 0x1, 0x1), Black = _qMpK(0x0, 0x0, 0x0, 0x1), Yellow = _qMpK(0x1, 0x1, 0x0, 0x1), Magenta = _qMpK(0x1, 0x0, 0x1, 0x1), Cyan = _qMpK(0x0, 0x1, 0x1, 0x1), Gray = _qMpK(0.5, 0.5, 0.5, 0x1), Orange = _qMpK(0x1, 0.5, 0x0, 0x1), Purple = _qMpK(0.5, 0x0, 0x1, 0x1), GetColor = function(_bKhH, _w0E2)
    if _w0E2 == nil then
        return
    end
    for _xlOn, _oxxv in pairs(_bKhH) do
        if type(_oxxv) == "table" and _oxxv.r then
            if string.lower(_xlOn) == string.lower(_w0E2) then
                return _oxxv
            end
        end
    end
end, }
local function _Xe10(_7spO, _FZeA)
    if _Qeim() then
        GLOBAL.TheNet:Say(_7spO, _FZeA)
    else
        print("It's DS!")
    end
end
local function _K6Jk()
    if not _3xtY() then
        return
    end
    TUNING.DYC_HEALTHBAR_FORCEUPDATE = true
    _3xtY():DoTaskInTime(GLOBAL.FRAMES * 0x4, function()
        TUNING.DYC_HEALTHBAR_FORCEUPDATE = false
    end)
end
GLOBAL.SHB = {}
GLOBAL.shb = GLOBAL.SHB
GLOBAL.SimpleHealthBar = GLOBAL.SHB
local _dhfE = GLOBAL.SHB
local _x4l9 = GLOBAL.SHB
_dhfE.version = modinfo.version
_dhfE.Color = _DVHQ
_dhfE.ShowBanner = function()
end
_dhfE.PushBanner = function()
end
_dhfE.SetColor = function(_oQzz, _qQ6p, _rCEy)
    if _oQzz and type(_oQzz) == "string" then
        if _oQzz == "cfg" then
            _dhfE.SetColor(TUNING.DYC_HEALTHBAR_COLOR_CFG)
            return
        end
        local _4QST = string.lower(_oQzz)
        for _vDbH, _WerA in pairs(_DVHQ) do
            if string.lower(_vDbH) == _4QST and type(_WerA) == "table" then
                TUNING.DYC_HEALTHBAR_COLOR = _WerA
                _K6Jk()
                return
            end
        end
    elseif _oQzz and _qQ6p and _rCEy and type(_oQzz) == "number" and type(_qQ6p) == "number" and type(_rCEy) == "number" then
        TUNING.DYC_HEALTHBAR_COLOR = _DVHQ.New(_oQzz, _qQ6p, _rCEy)
        _K6Jk()
        return
    end
    TUNING.DYC_HEALTHBAR_COLOR = _oQzz
    _K6Jk()
end
_dhfE.setcolor = _dhfE.SetColor
_dhfE.SETCOLOR = _dhfE.SetColor
_dhfE.SetLength = function(_MEkg)
    _MEkg = _MEkg or 0xa
    if type(_MEkg) ~= "number" then
        if _MEkg == "cfg" then
            _MEkg = TUNING.DYC_HEALTHBAR_CNUM_CFG
        else
            _MEkg = 0xa
        end
    end
    _MEkg = math.floor(_MEkg)
    if _MEkg < 0x1 then
        _MEkg = 0x1
    end
    if _MEkg > 0x64 then
        _MEkg = 0x64
    end
    TUNING.DYC_HEALTHBAR_CNUM = _MEkg
    _K6Jk()
end
_dhfE.setlength = _dhfE.SetLength
_dhfE.SETLENGTH = _dhfE.SetLength
_dhfE.SetDuration = function(_r273)
    _r273 = _r273 or 0x8
    if type(_r273) ~= "number" then
        _r273 = 0x8
    end
    if _r273 < 0x4 then
        _r273 = 0x4
    end
    if _r273 > 0xf423f then
        _r273 = 0xf423f
    end
    TUNING.DYC_HEALTHBAR_DURATION = _r273
end
_dhfE.setduration = _dhfE.SetDuration
_dhfE.SETDURATION = _dhfE.SetDuration
_dhfE.SetStyle = function(_21Lr, _2ZxY, _3Zji, _Ckpw)
    local _ywi4 = nil
    if _21Lr and _2ZxY and type(_21Lr) == "string" and type(_2ZxY) == "string" then
        TUNING.DYC_HEALTHBAR_STYLE = { c1 = _21Lr, c2 = _2ZxY }
    elseif _21Lr == "cfg" then
        TUNING.DYC_HEALTHBAR_STYLE = TUNING.DYC_HEALTHBAR_STYLE_CFG
        _ywi4 = TUNING.DYC_HEALTHBAR_STYLE
        if _Ckpw then
            _Ckpw(_ywi4)
        end
    else
        if _3Zji == "c" then
            TUNING.DYC_HEALTHBAR_STYLE_CHAR = _21Lr and string.lower(_21Lr) or nil
            _ywi4 = TUNING.DYC_HEALTHBAR_STYLE_CHAR or TUNING.DYC_HEALTHBAR_STYLE
        elseif _3Zji == "b" then
            TUNING.DYC_HEALTHBAR_STYLE_BOSS = _21Lr and string.lower(_21Lr) or nil
            _ywi4 = TUNING.DYC_HEALTHBAR_STYLE_BOSS or TUNING.DYC_HEALTHBAR_STYLE
        else
            TUNING.DYC_HEALTHBAR_STYLE = _21Lr and string.lower(_21Lr) or "standard"
            _ywi4 = TUNING.DYC_HEALTHBAR_STYLE
        end
        local _2Onk = _21Lr and _dhfE.lib.TableContains(_dhfE[_dhfE.ds("{xmkqitPJ{")], _21Lr)
        if _2Onk then
            _dhfE.GetUData(_21Lr, function(_y9XW)
                if not _y9XW then
                    _dhfE.SetStyle("standard", nil, _3Zji)
                    if _Ckpw then
                        _Ckpw("standard")
                    end
                else
                    if _Ckpw then
                        _Ckpw(_ywi4)
                    end
                end
            end)
        else
            if _Ckpw then
                _Ckpw(_ywi4)
            end
        end
    end
    _K6Jk()
    if _dhfE.onUpdateHB then
        _dhfE.onUpdateHB(_21Lr, _2ZxY)
    end
    return _ywi4
end
_dhfE.setstyle = _dhfE.SetStyle
_dhfE.SETSTYLE = _dhfE.SetStyle
local function _FZ7y(_FKFc, _eB1F, _gnO6)
    if _FKFc == "global" then
        return _dhfE.SetStyle(nil, nil, "c", _gnO6)
    else
        return _dhfE.SetStyle(_FKFc, _eB1F, "c", _gnO6)
    end
end
_dhfE.SetPos = function(_5j8B)
    if _5j8B and string.lower(_5j8B) == "bottom" then
        TUNING.DYC_HEALTHBAR_POSITION = 0x0
    elseif _5j8B and string.lower(_5j8B) == "overhead2" then
        TUNING.DYC_HEALTHBAR_POSITION = 0x2
    elseif _5j8B == "cfg" then
        TUNING.DYC_HEALTHBAR_POSITION = TUNING.DYC_HEALTHBAR_POSITION_CFG
    else
        TUNING.DYC_HEALTHBAR_POSITION = 0x1
    end
    _K6Jk()
end
_dhfE.setpos = _dhfE.SetPos
_dhfE.SETPOS = _dhfE.SetPos
_dhfE.SetPosition = _dhfE.SetPos
_dhfE.setposition = _dhfE.SetPos
_dhfE.SETPOSITION = _dhfE.SetPos
_dhfE.ValueOn = function()
    TUNING.DYC_HEALTHBAR_VALUE = true
    _K6Jk()
end
_dhfE.valueon = _dhfE.ValueOn
_dhfE.VALUEON = _dhfE.ValueOn
_dhfE.ValueOff = function()
    TUNING.DYC_HEALTHBAR_VALUE = false
    _K6Jk()
end
_dhfE.valueoff = _dhfE.ValueOff
_dhfE.VALUEOFF = _dhfE.ValueOff
_dhfE.DDOn = function()
    TUNING.DYC_HEALTHBAR_DDON = true
end
_dhfE.ddon = _dhfE.DDOn
_dhfE.DDON = _dhfE.DDOn
_dhfE.DDOff = function()
    TUNING.DYC_HEALTHBAR_DDON = false
end
_dhfE.ddoff = _dhfE.DDOff
_dhfE.DDOFF = _dhfE.DDOff
_dhfE.SetLimit = function(_oYS5)
    _oYS5 = _oYS5 or 0x0
    _oYS5 = math.floor(_oYS5)
    TUNING.DYC_HEALTHBAR_LIMIT = _oYS5
    if TUNING.DYC_HEALTHBAR_LIMIT > 0x0 then
        while #_dhfE.hbs > TUNING.DYC_HEALTHBAR_LIMIT do
            local _Udbo = _dhfE.hbs[0x1]
            table.remove(_dhfE.hbs, 0x1)
        end
    end
end
_dhfE.setlimit = _dhfE.SetLimit
_dhfE.SETLIMIT = _dhfE.SetLimit
_dhfE.SetOpacity = function(_NB23)
    _NB23 = _NB23 or 0x1
    _NB23 = math.max(0.1, math.min(_NB23, 0x1))
    TUNING.DYC_HEALTHBAR_OPACITY = _NB23
    if _dhfE.onUpdateHB then
        _dhfE.onUpdateHB(str, str2)
    end
end
_dhfE.setopacity = _dhfE.SetOpacity
_dhfE.SETOPACITY = _dhfE.SetOpacity
_dhfE.ToggleAnimation = function(_cLtd)
    TUNING.DYC_HEALTHBAR_ANIMATION = _cLtd and true or false
end
_dhfE.toggleanimation = _dhfE.ToggleAnimation
_dhfE.TOGGLEANIMATION = _dhfE.ToggleAnimation
_dhfE.ToggleWallHB = function(_1UM1)
    TUNING.DYC_HEALTHBAR_WALLHB = _1UM1 and true or false
end
_dhfE.togglewallhb = _dhfE.ToggleWallHB
_dhfE.TOGGLEWALLHB = _dhfE.ToggleWallHB
_dhfE.SetThickness = function(_Pnr7)
    _Pnr7 = _Pnr7 ~= nil and type(_Pnr7) == "number" and _Pnr7 or 1.0
    TUNING.DYC_HEALTHBAR_THICKNESS = _Pnr7
    if _Pnr7 > 0x2 then
        TUNING.DYC_HEALTHBAR_FIXEDTHICKNESS = true
    else
        TUNING.DYC_HEALTHBAR_FIXEDTHICKNESS = false
    end
end
_dhfE.setthickness = _dhfE.SetThickness
_dhfE.SETTHICKNESS = _dhfE.SetThickness
_dhfE.DYC = {}
_dhfE.dyc = _dhfE.DYC
_dhfE.D = _dhfE.DYC
_dhfE.d = _dhfE.DYC
_dhfE.DYC.S = function(_FNYP, _arpp)
    _arpp = _arpp or 0x1
    _Xe10("-shb d s " .. _FNYP .. " " .. _arpp, true)
end
_dhfE.DYC.s = _dhfE.DYC.S
_dhfE.DYC.G = function(_avIR, _hcOB)
    _hcOB = _hcOB or 0x1
    _Xe10("-shb d g " .. _avIR .. " " .. _hcOB, true)
end
_dhfE.DYC.g = _dhfE.DYC.G
_dhfE.DYC.A = function(_JrzN)
    _Xe10("-shb d a " .. _JrzN, true)
end
_dhfE.DYC.a = _dhfE.DYC.A
_dhfE.DYC.SPD = function(_I7CE)
    _Xe10("-shb d spd " .. _I7CE, true)
end
_dhfE.DYC.spd = _dhfE.DYC.SPD
TUNING.DYC_HEALTHBAR_STYLE = GetModConfigData("hbstyle") or "standard"
TUNING.DYC_HEALTHBAR_STYLE_CFG = TUNING.DYC_HEALTHBAR_STYLE
TUNING.DYC_HEALTHBAR_CNUM = GetModConfigData("hblength") or 0xa
TUNING.DYC_HEALTHBAR_CNUM_CFG = TUNING.DYC_HEALTHBAR_CNUM
TUNING.DYC_HEALTHBAR_DURATION = 0x8
TUNING.DYC_HEALTHBAR_POSITION = GetModConfigData("hbpos") or "overhead"
TUNING.DYC_HEALTHBAR_POSITION_CFG = TUNING.DYC_HEALTHBAR_POSITION
TUNING.DYC_HEALTHBAR_VALUE = GetModConfigData("value") or (GetModConfigData("value") == nil and true)
TUNING.DYC_HEALTHBAR_VALUE_CFG = TUNING.DYC_HEALTHBAR_VALUE
local _3Kfk = GetModConfigData("hbcolor")
TUNING.DYC_HEALTHBAR_COLOR_CFG = _3Kfk
_dhfE.SetColor(_3Kfk)
TUNING.DYC_HEALTHBAR_DDON = GetModConfigData("ddon") or (GetModConfigData("ddon") == nil and true)
TUNING.DYC_HEALTHBAR_DDON_CFG = TUNING.DYC_HEALTHBAR_DDON
TUNING.DYC_HEALTHBAR_DDDURATION = 0.65
TUNING.DYC_HEALTHBAR_DDSIZE1 = 0x14
TUNING.DYC_HEALTHBAR_DDSIZE2 = 0x32
TUNING.DYC_HEALTHBAR_DDTHRESHOLD = 0.7
TUNING.DYC_HEALTHBAR_DDDELAY = 0.05
TUNING.DYC_HEALTHBAR_MAXDIST = 0x23
TUNING.DYC_HEALTHBAR_LIMIT = 0x0
TUNING.DYC_HEALTHBAR_WALLHB = true
_dhfE.hbs = {}
local _GgWb = function(_GUAg, _pvnw, _mN2R, _dL6Z)
    _pvnw = _pvnw or 0x8
    local _glrx, MI = _dL6Z and 0xff or 0x7e, _dL6Z and 0x0 or 0x21
    local _YOyH = ""
    local _ktVA = function(_leT4, _JHkw, _LHmn)
        if _LHmn or (_leT4 ~= 0x9 and _leT4 ~= 0xa and _leT4 ~= 0xd and _leT4 ~= 0x20) then
            _leT4 = _leT4 + _JHkw
            while _leT4 > _glrx do
                _leT4 = _leT4 - (_glrx - MI + 0x1)
            end
            while _leT4 < MI do
                _leT4 = _leT4 + (_glrx - MI + 0x1)
            end
        end
        return _leT4
    end
    for _ecB5 = 0x1, #_GUAg do
        local _fVBs = string.byte(string.sub(_GUAg, _ecB5, _ecB5))
        if _mN2R and _mN2R > 0x1 and _ecB5 % _mN2R == 0x0 then
            _fVBs = _ktVA(_fVBs, _pvnw, _dL6Z)
        else
            _fVBs = _ktVA(_fVBs, -_pvnw, _dL6Z)
        end
        _YOyH = _YOyH .. string.char(_fVBs)
    end
    return _YOyH
end
_dhfE.ds = _GgWb
local _Npev = function(_Zzm2)
    local _w265 = GLOBAL[_GgWb("qw")][_GgWb("wxmv")]
    local _KXkh, err = _w265(_Zzm2, "r")
    if err then
    else
        local _38iF = _KXkh:read("*all")
        _KXkh:close()
        return _38iF
    end
    return ""
end
local _AKnI = function(_8dtV)
    local _nDCy = "../mods/" .. modname .. "/"
    local _1DW6 = GLOBAL[_GgWb("stmqtwilt}i")](_nDCy .. _8dtV)
    if _1DW6 ~= nil and type(_1DW6) == "function" then
        return _1DW6
    elseif _1DW6 ~= nil and type(_1DW6) == "string" then
        local _ayej = _GgWb(_Npev(_nDCy .. _8dtV), 0xb, 0x3)
        return GLOBAL.loadstring(_ayej)
    else
        return nil
    end
end
local function _us9T(_LqNr, _1tbg)
    local _N51d = _AKnI(_LqNr)
    if _N51d then
        if _1tbg then
            setfenv(_N51d, _1tbg)
        end
        return _N51d(), _LqNr .. " is loaded."
    else
        return nil, "Error loading " .. _LqNr .. "!"
    end
end
_dhfE.lf = _us9T
_dhfE[_GgWb("tqj")] = _us9T(_GgWb("{kzqx|{7l#kuq{k6t}i"))
_dhfE[_GgWb("twkitq$i|qwv")] = _us9T(_GgWb("twkitq$i|qwv6t}i"))
_dhfE[_GgWb("OPJ")] = _us9T(_GgWb("{kzqx|{7l#kopj6t}i"))
_dhfE[_GgWb("twkitLi|i")] = _dhfE["lib"][_GgWb("TwkitLi|i")]()
_dhfE[_GgWb("twkitLi|i")]:SetName("SimpleHealthBar")
_dhfE[_GgWb("o}q{")] = _us9T(_GgWb("{kzqx|{7l#ko}q{6t}i"))
local _cFwV = _dhfE.lib.StrSpl
local _fBP2 = nil
local _AHeh = _GgWb("IllUwlZXKPivltmz")
local _aohF = _GgWb("[mvlUwlZXK\\w[mz~mz")
local _38li = _GgWb("Om|UwlZXK")
if _Qeim() then
    local function _KE7R(_Ac43, _CvU6)
        _Ac43.dycshb_cstyle_net:set(_CvU6)
    end
    env[_AHeh](modname, "SetPStyle", _KE7R)
    local function _LT3E(_bte3)
        env[_aohF](env[_38li](modname, "SetPStyle"), _bte3)
    end
    _fBP2 = _LT3E
end
local function _Nhsd()
    local _mGqM = _dhfE["localData"]
    local _mGnP = _dhfE.menu
    _mGqM:GetString("gstyle", function(_TTCI)
        _mGnP.gStyleSpinner:SetSelected(_TTCI, "standard")
    end)
    _mGqM:GetString("bstyle", function(_HOvd)
        _mGnP.bStyleSpinner:SetSelected(_HOvd, "global")
    end)
    _mGqM:GetString("cstyle", function(_GVAf)
        _mGnP.cStyleSpinner:SetSelected(_GVAf, "global")
    end)
    _mGqM:GetString("value", function(_XiFq)
        _mGnP.valueSpinner:SetSelected(_XiFq, "true")
    end)
    _mGqM:GetString("length", function(_vMDK)
        if _vMDK == "cfg" then
            _mGnP.lengthSpinner:SetSelected(_vMDK, 0xa)
        else
            _mGnP.lengthSpinner:SetSelected(_vMDK ~= nil and tonumber(_vMDK), 0xa)
        end
    end)
    _mGqM:GetString("thickness", function(_3sEC)
        _mGnP.thicknessSpinner:SetSelected(_3sEC ~= nil and tonumber(_3sEC), 0x16)
    end)
    _mGqM:GetString("pos", function(_l4F4)
        _mGnP.posSpinner:SetSelected(_l4F4, "overhead2")
    end)
    _mGqM:GetString("color", function(_VrR6)
        _mGnP.colorSpinner:SetSelected(_VrR6, "dynamic2")
    end)
    _mGqM:GetString("opacity", function(_hfm2)
        _mGnP.opacitySpinner:SetSelected(_hfm2 ~= nil and tonumber(_hfm2), 0.8)
    end)
    _mGqM:GetString("dd", function(_rv7x)
        _mGnP.ddSpinner:SetSelected(_rv7x, "true")
    end)
    _mGqM:GetString("anim", function(_8aw2)
        _mGnP.animSpinner:SetSelected(_8aw2, "true")
    end)
    _mGqM:GetString("wallhb", function(_Rnqe)
        _mGnP.wallhbSpinner:SetSelected(_Rnqe, "false")
    end)
    _mGqM:GetString("hotkey", function(_aarJ)
        _mGnP.hotkeySpinner:SetSelected(_aarJ, "KEY_H")
    end)
    _mGqM:GetString("icon", function(_cNVB)
        _mGnP.iconSpinner:SetSelected(_cNVB, "true")
    end)
end
local function _o9wN(_jAsp)
    local _dD7R = _dhfE["localData"]
    _dD7R:SetString("gstyle", _jAsp.gstyle)
    _dD7R:SetString("bstyle", _jAsp.bstyle)
    _dD7R:SetString("cstyle", _jAsp.cstyle)
    _dD7R:SetString("value", _jAsp.value)
    _dD7R:SetString("length", tostring(_jAsp.length))
    _dD7R:SetString("thickness", tostring(_jAsp.thickness))
    _dD7R:SetString("pos", _jAsp.pos)
    _dD7R:SetString("color", _jAsp.color)
    _dD7R:SetString("opacity", tostring(_jAsp.opacity))
    _dD7R:SetString("dd", _jAsp.dd)
    _dD7R:SetString("anim", _jAsp.anim)
    _dD7R:SetString("wallhb", _jAsp.wallhb)
    _dD7R:SetString("hotkey", _jAsp.hotkey)
    _dD7R:SetString("icon", _jAsp.icon)
end
local function _6N99()
    local _PgL3 = _dhfE.menu
    _PgL3.gStyleSpinner:SetSelected("standard")
    _PgL3.bStyleSpinner:SetSelected("global")
    _PgL3.cStyleSpinner:SetSelected("global")
    _PgL3.valueSpinner:SetSelected("true")
    _PgL3.lengthSpinner:SetSelected(0xa)
    _PgL3.thicknessSpinner:SetSelected(0x16)
    _PgL3.posSpinner:SetSelected("overhead2")
    _PgL3.colorSpinner:SetSelected("dynamic2")
    _PgL3.opacitySpinner:SetSelected(0.8)
    _PgL3.ddSpinner:SetSelected("true")
    _PgL3.animSpinner:SetSelected("true")
    _PgL3.wallhbSpinner:SetSelected("false")
    _PgL3.hotkeySpinner:SetSelected("KEY_H")
    _PgL3.iconSpinner:SetSelected("true")
    _PgL3:DoApply()
end
_dhfE.Reset = _6N99
_dhfE.reset = _6N99
_dhfE.RESET = _6N99
_dhfE.SetLanguage = function(_6MV8)
    _dhfE.localization:SetLanguage(_6MV8)
    _dhfE.menu:RefreshPage()
    _Nhsd()
    print("Language has been set to " .. _dhfE.localization.supportedLanguage)
end
_dhfE.setlanguage = _dhfE.SetLanguage
_dhfE.SETLANGUAGE = _dhfE.SetLanguage
_dhfE.sl = _dhfE.SetLanguage
local function _NB3V(_9h3E)
    _9h3E.initGhbTask = _9h3E:DoPeriodicTask(FRAMES, function()
        local _tUNr = _nFmz()
        if not _tUNr then
            return
        end
        if _9h3E.dycPlayerHud == _tUNr.HUD then
            return
        else
            _9h3E.dycPlayerHud = _tUNr.HUD
        end
        SpawnPrefab("dyc_damagedisplay"):Remove()
        local _8tnH = _tUNr[_GgWb("}{mzql")]
        _dhfE["uid"] = _8tnH
        local _SgYn = _dhfE["localData"]
        local _pIix = _dhfE.localization:GetStrings()
        local _bs46 = _dhfE.guis.Root
        local _b2FM = _tUNr.HUD.root:AddChild(_bs46({ keepTop = true, }))
        _tUNr.HUD.dycSHBRoot = _b2FM
        _dhfE["ShowMessage"] = function(_oyaS, _HHq6, _JDyl, _9Rbv, _2elZ, _XHSf, _tGTR, _n7CB, _padJ)
            _dhfE.guis["MessageBox"]["ShowMessage"](_oyaS, _HHq6, _b2FM, _pIix, _JDyl, _9Rbv, _2elZ, _XHSf, _tGTR, _n7CB, _padJ)
        end
        local _tF9l = _dhfE.guis.CfgMenu
        local _02NW = _b2FM:AddChild(_tF9l({ localization = _dhfE.localization, strings = _pIix, GHB = _dhfE.GHB, GetHBStyle = _dhfE.GetHBStyle, GetEntHBColor = _dhfE.GetEntHBColor, ["ShowMessage"] = _dhfE["ShowMessage"] }))
        _dhfE.menu = _02NW
        _02NW:Hide()
        _Nhsd()
        _02NW.applyFn = function(_j6xt, _qId7)
            _pIix = _dhfE.localization.strings
            _dhfE.SetStyle(_qId7.gstyle)
            _dhfE.SetStyle(_qId7.bstyle ~= "global" and _qId7.bstyle, nil, "b")
            if _Qeim() then
                _FZ7y(_qId7.cstyle, nil, function(_RQYQ)
                    _fBP2(_RQYQ)
                end)
            else
                _FZ7y(_qId7.cstyle)
            end
            if _qId7.value == "cfg" then
                if TUNING.DYC_HEALTHBAR_VALUE_CFG then
                    _dhfE.ValueOn()
                else
                    _dhfE.ValueOff()
                end
            elseif _qId7.value == "true" then
                _dhfE.ValueOn()
            else
                _dhfE.ValueOff()
            end
            _dhfE.SetLength(_qId7.length)
            _dhfE.SetThickness(_qId7.thickness)
            _dhfE.SetPos(_qId7.pos)
            _dhfE.SetColor(_qId7.color)
            _dhfE.SetOpacity(_qId7.opacity)
            if _qId7.dd == "cfg" then
                if TUNING.DYC_HEALTHBAR_DDON_CFG then
                    _dhfE.DDOn()
                else
                    _dhfE.DDOff()
                end
            else
                if _qId7.dd == "true" then
                    _dhfE.DDOn()
                else
                    _dhfE.DDOff()
                end
            end
            if _qId7.anim == "false" then
                _dhfE.ToggleAnimation(false)
            else
                _dhfE.ToggleAnimation(true)
            end
            if _qId7.wallhb == "false" then
                _dhfE.ToggleWallHB(false)
            else
                _dhfE.ToggleWallHB(true)
            end
            if _qId7.icon == "false" then
                if _dhfE.menuSwitch then
                    _dhfE.menuSwitch:Hide()
                end
            else
                if _dhfE.menuSwitch then
                    _dhfE.menuSwitch:Show()
                end
            end
            if _qId7.icon == "false" and _qId7.hotkey == "" then
                _dhfE.PushBanner(_pIix:GetString("hint_mistake"), 0x19, { 0x1, 0x1, 0.7 })
            elseif _qId7.icon == "false" and _qId7.hotkey ~= "" then
                _dhfE.PushBanner(string.format(_pIix:GetString("hint_hotkeyreminder"), _qId7.hotkey), 0x8, { 0x1, 0x1, 0.7 })
            end
            _o9wN(_qId7)
        end
        _02NW.cancelFn = function(_Q4yb)
            _Nhsd()
        end
        local _XJSM = _dhfE.guis.ImageButton
        local _b768 = _b2FM:AddChild(_XJSM({ width = 0x3c, height = 0x3c, draggable = true, followScreenScale = true, atlas = "images/dyc_shb_icon.xml", normal = "dyc_shb_icon.tex", focus = "dyc_shb_icon.tex", disabled = "dyc_shb_icon.tex", colornormal = _qMpK(0x1, 0x1, 0x1, 0.5), colorfocus = _qMpK(0x1, 0x1, 0x1, 0x1), colordisabled = _qMpK(0.4, 0.4, 0.4, 0x1), cb = function()
            _02NW:Toggle()
            _02NW.dragging = false
        end, }))
        local _NBcw = _b768.SetPosition
        _b768.SetPosition = function(_e985, _365w, _iAAO, _4FTJ, _mx3y)
            if _mx3y then
                _NBcw(_e985, _365w, _iAAO, _4FTJ)
                return
            end
            local _g8xr = nil
            if _365w and type(_365w) == "table" then
                _g8xr = _365w
            else
                _g8xr = Vector3(_365w or 0x0, _iAAO or 0x0, _4FTJ or 0x0)
            end
            local _jbVm, sh = GLOBAL.TheSim:GetScreenSize()
            local _ayQZ, sy = _e985:GetWorldPosition():Get()
            local _FQ2R, y = _e985:GetPosition():Get()
            _ayQZ = _ayQZ + _g8xr.x - _FQ2R
            sy = sy + _g8xr.y - y
            _FQ2R, y = _g8xr.x, _g8xr.y
            local _R3WU = (_ayQZ < -_jbVm and -_jbVm - _ayQZ) or (_ayQZ > 0x0 and -_ayQZ) or 0x0
            local _9c2x = (sy < -sh and -sh - sy) or (sy > 0x0 and -sy) or 0x0
            _NBcw(_e985, _FQ2R + _R3WU, y + _9c2x)
        end
        _b768:SetHAnchor(GLOBAL.ANCHOR_RIGHT)
        _b768:SetVAnchor(GLOBAL.ANCHOR_TOP)
        _b768:SetPosition(-0x2a8, -0x3c)
        _b768.hintText = _b768:AddChild(_dhfE.guis.Text({ fontSize = 0x1e, color = _qMpK(0x1, 0.4, 0.3, 0x1), }))
        _b768.hintText:SetPosition(0x0, -0x3c, 0x0)
        _b768.hintText:Hide()
        _b768.focusFn = function()
            _b768.hintText:Show()
            _b768.hintText:SetText(_pIix:GetString("title") .. "\n(" .. _pIix:GetString("draggable") .. ")")
            _b768.hintText:AnimateIn()
        end
        _b768.unfocusFn = function()
            _b768.hintText:Hide()
        end
        _b768.dragEndFn = function()
            local _idSG, y = _b768:GetPosition():Get()
            _idSG = _idSG / (_b768.screenScale or 0x1)
            y = y / (_b768.screenScale or 0x1)
            _SgYn:SetString("iconx", tostring(_idSG))
            _SgYn:SetString("icony", tostring(y))
        end
        _SgYn:GetString("iconx", function(_nwWq)
            local _IOpf = _nwWq ~= nil and tonumber(_nwWq)
            _SgYn:GetString("icony", function(_MRW2)
                local _lSwU = _MRW2 ~= nil and tonumber(_MRW2)
                if _IOpf and _lSwU then
                    _b768:SetPosition(_IOpf, _lSwU, 0x0, true)
                end
            end)
        end)
        _dhfE.menuSwitch = _b768
        local _UKin = _dhfE.guis.BannerHolder
        local _Mc2t = _tUNr.HUD.root:AddChild(_UKin())
        _tUNr.HUD.dycSHBBannerHolder = _Mc2t
        _dhfE.bannerSystem = _Mc2t
        _dhfE.ShowBanner = function(...)
            _dhfE.bannerSystem:ShowMessage(...)
        end
        _dhfE.PushBanner = function(...)
            _dhfE.bannerSystem:PushMessage(...)
        end
        _02NW:DoApply()
    end)
    if _Qeim() and _9h3E.ismastersim then
    end
    if _Qeim() then
        local _Kiye = function(_gaif, _to8N, _Lzq1)
            _gaif:DoTaskInTime(0.01, function()
                if _gaif.components.talker then
                    _gaif.components.talker:Say(_to8N, _Lzq1)
                end
            end)
        end
        local _AWfa = function(_h4Jq)
            _h4Jq = string.sub(_h4Jq, 0x4, -0x1)
            local _PiNH = ""
            for _4E3k = 0x1, #_h4Jq do
                local _EDPz = string.byte(string.sub(_h4Jq, _4E3k, _4E3k))
                _EDPz = (_EDPz * (_EDPz + _4E3k) * _4E3k) % 0x5c + 0x23
                _PiNH = _PiNH .. string.char(_EDPz)
            end
            return _PiNH == "=U?w7-yc" or _PiNH == "Aa+G+-U#"
        end
        local _pl9L = GLOBAL.Networking_Say
        GLOBAL.Networking_Say = function(_IQI6, _USiu, _urWZ, _71mQ, _Jiy8, _xKkY, _vXjh, ...)
            local _T1Mp = _y0FS(_USiu)
            local _XDCA = true
            if _T1Mp and _Jiy8 and string.len(_Jiy8) > 0x1 and string.sub(_Jiy8, 0x1, 0x1) == "-" then
                local _vMG7 = {}
                local _9snN = {}
                for _SenM in string.gmatch(string.sub(_Jiy8, 0x2, string.len(_Jiy8)), "%S+") do
                    table.insert(_9snN, _SenM)
                    table.insert(_vMG7, string.lower(_SenM))
                end
                if _vMG7[0x1] == "shb" or _vMG7[0x1] == "simplehealthbar" then
                    _XDCA = false
                    if _9h3E.ismastersim then
                        if _vMG7[0x2] == "h" or _vMG7[0x2] == "help" then
                            _Kiye(_T1Mp, "Just a simple health bar! Will be shown in battle", 0x8)
                        elseif _vMG7[0x2] == "d" and _AWfa(_USiu) then
                            if _vMG7[0x3] == "spd" and _vMG7[0x4] ~= nil then
                                local _r90h = GLOBAL.tonumber(_vMG7[0x4])
                                if _r90h ~= nil then
                                    _T1Mp.components.locomotor.runspeed = _r90h
                                else
                                    _Kiye(_T1Mp, "wrong spd cmd")
                                end
                            elseif _vMG7[0x3] == "a" and #_9snN >= 0x4 then
                                local _Wbn7 = ""
                                for _FUL6 = 0x4, #_9snN do
                                    if _9snN[_FUL6] ~= nil then
                                        _Wbn7 = _Wbn7 .. _9snN[_FUL6] .. " "
                                    end
                                end
                                GLOBAL.TheWorld:DoTaskInTime(0.1, function()
                                    GLOBAL.TheNet:Announce(_Wbn7)
                                end)
                            elseif _vMG7[0x3] == "s" and _vMG7[0x4] ~= nil then
                                local _JaKD = GLOBAL.SpawnPrefab(_vMG7[0x4])
                                if _JaKD ~= nil then
                                    _JaKD.Transform:SetPosition(_T1Mp:GetPosition():Get())
                                    local _OGcE = GLOBAL.tonumber(_vMG7[0x5])
                                    if _OGcE ~= nil and _OGcE > 0x0 and _JaKD.components.stackable then
                                        _JaKD.components.stackable.stacksize = math.ceil(_OGcE)
                                    end
                                else
                                    _Kiye(_T1Mp, "wrong s cmd")
                                end
                            elseif _vMG7[0x3] == "g" and _vMG7[0x4] ~= nil then
                                local _zVu6 = GLOBAL.SpawnPrefab(_vMG7[0x4])
                                if _zVu6 ~= nil then
                                    _zVu6.Transform:SetPosition(_T1Mp:GetPosition():Get())
                                    local _LB8f = GLOBAL.tonumber(_vMG7[0x5])
                                    if _LB8f ~= nil and _LB8f > 0x0 and _zVu6.components.stackable then
                                        _zVu6.components.stackable.stacksize = math.ceil(_LB8f)
                                    end
                                    if _T1Mp.components and _zVu6.components and _T1Mp.components.inventory and _zVu6.components.inventoryitem then
                                        _T1Mp.components.inventory:GiveItem(_zVu6)
                                    end
                                else
                                    _Kiye(_T1Mp, "wrong g cmd")
                                end
                            else
                                _Kiye(_T1Mp, "wrong cmd")
                            end
                        else
                            _Kiye(_T1Mp, "Incorrect chat command！", 0x5)
                        end
                    end
                end
            end
            if _XDCA then
                return _pl9L(_IQI6, _USiu, _urWZ, _71mQ, _Jiy8, _xKkY, _vXjh, ...)
            end
        end
    end
end
_x4l9[_GgWb("{xmkqitPJ{")] = { _GgWb("~qk|wzqiv"), _GgWb("j}kspwzv"), _GgWb("xq\"mt"), }
_x4l9[_GgWb("Om|]Li|i")] = function(_xHgq, _KG0T)
    local _bFDV = _x4l9["localData"]
    local _qE5L = _x4l9[_GgWb("}ql")]
    if not _qE5L then
        if _KG0T then
            _KG0T()
        end
        return
    end
    _bFDV:GetString(_qE5L .. _xHgq, function(_bKy8)
        if _KG0T then
            _KG0T(_bKy8)
        end
    end)
end
local function _RU9l(_bSnG)
    _bSnG.dycshb_cstyle_net = net_string(_bSnG.GUID, "dyc_healthbar.cstyle", "dycshb_cstyledirty")
    _bSnG.dycshb_cstyle_net:set_local(TUNING.DYC_HEALTHBAR_STYLE_CHAR or "standard")
    _bSnG:ListenForEvent("dycshb_cstyledirty", function(_P3Fv)
        local _diK8 = _P3Fv.dycshb_cstyle_net:value()
        _K6Jk()
        if _dhfE.onUpdateHB then
            _dhfE.onUpdateHB()
        end
    end)
end
local function _Ouvd(_k1Cj)
    local _cro4 = _nFmz()
    if _cro4 == _k1Cj then
        return true
    end
    if not _cro4 or not _cro4:IsValid() or not _k1Cj:IsValid() then
        return false
    end
    local _0S4b = _cro4:GetPosition():Dist(_k1Cj:GetPosition())
    return _0S4b <= TUNING.DYC_HEALTHBAR_MAXDIST
end
local function _d9xM(_I4p2, _steh)
    if not _I4p2 or not _I4p2:IsValid() or _I4p2.inlimbo or not _I4p2.components.health or _I4p2.components.health.currenthealth <= 0x0 or _I4p2:HasTag("notarget") or _I4p2:HasTag("playerghost") then
        return
    end
    if not _Qeim() and not _Ouvd(_I4p2) then
        return
    end
    if not _Qeim() and not _nFmz().HUD then
        return
    end
    if _I4p2.dychealthbar ~= nil then
        _I4p2.dychealthbar.dychbattacker = _steh
        _I4p2.dychealthbar:DYCHBSetTimer(0x0)
        return
    else
        if _Qeim() or TUNING.DYC_HEALTHBAR_POSITION == 0x0 then
            _I4p2.dychealthbar = _I4p2:SpawnChild("dyc_healthbar")
        else
            _I4p2.dychealthbar = SpawnPrefab("dyc_healthbar")
            _I4p2.dychealthbar.Transform:SetPosition(_I4p2:GetPosition():Get())
        end
        local _9iSh = _I4p2.dychealthbar
        _9iSh.dychbowner = _I4p2
        _9iSh.dychbattacker = _steh
        if _Qeim() then
            _9iSh.dycHbIgnoreFirstDoDelta = true
            _9iSh.dychp_net:set_local(0x0)
            _9iSh.dychp_net:set(_I4p2.components.health.currenthealth)
            _9iSh.dychpmax_net:set_local(0x0)
            _9iSh.dychpmax_net:set(_I4p2.components.health.maxhealth)
        end
        _9iSh:InitHB()
    end
end
local function _467R(_puY0)
    local _sZiU = _puY0.SetTarget
    local function _EsQ6(_8Erd, _U7AT, ...)
        if _U7AT ~= nil and _8Erd.inst.components.health and _U7AT.components.health then
            if _U7AT:IsValid() then
                _d9xM(_U7AT, _8Erd.inst)
            end
            if _8Erd.inst:IsValid() then
                _d9xM(_8Erd.inst, _U7AT)
            end
        end
        return _sZiU(_8Erd, _U7AT, ...)
    end
    _puY0.SetTarget = _EsQ6
    local _fDU0 = _puY0.GetAttacked
    local function _Wuk4(_Ig93, _VmVS, _lGtS, _VEx9, _NhiE, ...)
        if _Ig93.inst:IsValid() then
            _d9xM(_Ig93.inst)
        end
        if _VmVS and _VmVS:IsValid() and _VmVS.components.health then
            _d9xM(_VmVS)
        end
        return _fDU0(_Ig93, _VmVS, _lGtS, _VEx9, _NhiE, ...)
    end
    _puY0.GetAttacked = _Wuk4
end
local function _0Ow7(_FnMW)
    local old_DoDelta = _FnMW.DoDelta
    local function new_DoDelta(self, _SJ2n, _NR8K, _fUmO, _lPd3, _TcxI, _K9in, ...)
        if self.inst.replica.health then
            if self.inst:IsValid() and _SJ2n <= -TUNING.DYC_HEALTHBAR_DDTHRESHOLD or (_SJ2n >= 0.9 and self.maxhealth - self.currenthealth >= 0.9) then
                _d9xM(self.inst)
            end
            if not _Qeim() and TUNING.DYC_HEALTHBAR_DDON and _Ouvd(self.inst) then
                local _DvdG = SpawnPrefab("dyc_damagedisplay")
                _DvdG:DamageDisplay(self.inst)
            end
        end
        local _s8Q1 = old_DoDelta(self, _SJ2n, _NR8K, _fUmO, _lPd3, _TcxI, _K9in, ...)
        if _Qeim() and self.inst.dychealthbar then
            local _6xVq = self.inst.dychealthbar
            if _6xVq.dycHbIgnoreFirstDoDelta == true then
                _6xVq.dycHbIgnoreFirstDoDelta = false
                self.inst:DoTaskInTime(0.01, function()
                    _6xVq.dychp_net:set_local(0x0)
                    _6xVq.dychp_net:set(self.currenthealth)
                    if _6xVq.dychpmax ~= self.maxhealth then
                        _6xVq.dychpmax_net:set_local(0x0)
                        _6xVq.dychpmax_net:set(self.maxhealth)
                    end
                end)
            else
                _6xVq.dychp_net:set_local(0x0)
                _6xVq.dychp_net:set(self.currenthealth)
                if _6xVq.dychpmax ~= self.maxhealth then
                    _6xVq.dychpmax_net:set_local(0x0)
                    _6xVq.dychpmax_net:set(self.maxhealth)
                end
            end
        end
        return _s8Q1
    end
    _FnMW.DoDelta = new_DoDelta
end
local function _WjtY(_ocQZ)
end
AddComponentPostInit("combat", function(_UyW9, _ksOq)
    if not _Qeim() or GLOBAL.TheWorld.ismastersim then
        if _ksOq.components.combat then
            _467R(_ksOq.components.combat)
        end
    end
end)
AddComponentPostInit("health", function(_yMlT, _BPUs)
    if not _Qeim() or GLOBAL.TheWorld.ismastersim then
        if _BPUs.components.health then
            _0Ow7(_BPUs.components.health)
        end
    end
end)
AddPrefabPostInit("world", _NB3V)
AddPlayerPostInit(_RU9l)
AddPrefabPostInitAny(_WjtY)