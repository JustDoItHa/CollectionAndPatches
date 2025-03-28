local GLOBAL = _G or GLOBAL
local env = GLOBAL and GLOBAL.getfenv and GLOBAL.getfenv() or GLOBAL or {}
if env == GLOBAL then
    -- disable strict mode so that there is no crash
    if GLOBAL.getmetatable then
        GLOBAL.getmetatable(GLOBAL).__index = function(t, k)
            return GLOBAL.rawget(t, k)
        end
    end
end
local function _SRwz()
    return GLOBAL.TheSim:GetGameID() == "DST"
end
local function _srER()
    return _SRwz() and GLOBAL.TheNet:GetIsClient()
end
local function _dA58()
    return _SRwz() and GLOBAL.TheNet:IsDedicated()
end
local function _4qZT()
    if _SRwz() then
        return GLOBAL.ThePlayer
    else
        return GLOBAL.GetPlayer()
    end
end
local function _ovJU()
    if _SRwz() then
        return GLOBAL.TheWorld
    else
        return GLOBAL.GetWorld()
    end
end
local function _oAkm(_qkbB)
    local _jfLh = nil
    for _IBdR, _Q4Tx in pairs(GLOBAL.AllPlayers) do
        if _Q4Tx.userid == _qkbB then
            _jfLh = _Q4Tx
        end
    end
    return _jfLh
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
error = GLOBAL.error
require = GLOBAL.require
rawget = GLOBAL.rawget
rawset = GLOBAL.rawset
getmetatable = GLOBAL.getmetatable
TheSim = GLOBAL.TheSim
net_string = GLOBAL.net_string
net_float = GLOBAL.net_float
local _Emt4 = "../mods/" .. modname .. "/"
local _q4po = function(_kmfi)
    local _8rjr = GLOBAL.kleiloadlua(_kmfi)
    if _8rjr ~= nil and type(_8rjr) == "function" then
        return _8rjr, ""
    elseif _8rjr ~= nil and type(_8rjr) == "string" then
        return nil, _8rjr
    else
        return nil
    end
end
local function _Gkih(_pdI7, _YYAC)
    local _nidu, err = _q4po(_pdI7)
    if _nidu then
        if _YYAC then
            setfenv(_nidu, _YYAC)
        end
        return _nidu()
    else
        return nil, err or "Failed to load:" .. _pdI7
    end
end
local _Lmpc = {}
local function _gp5v(_5Xq6)
    if _5Xq6 then
        local _aDir = _Lmpc[_5Xq6]
        if _aDir then
            return _aDir
        else
            local _sVkF = ""
            _aDir, _sVkF = _Gkih(_5Xq6)
            if _sVkF then
                error(_sVkF)
            end
            _Lmpc[_5Xq6] = _aDir
            return _aDir
        end
    end
end
local function _VLhB(_NvgC)
    return _gp5v(_Emt4 .. "scripts/" .. _NvgC .. ".lua")
end
local _EWbc = GLOBAL.require
local _jVGW = _VLhB
local function _bglq(_oXmC, _WM7u)
    if _SRwz() then
        GLOBAL.TheNet:Say(_oXmC, _WM7u)
    else
        print("It's DS!")
    end
end
GLOBAL.SHB = {}
GLOBAL.shb = GLOBAL.SHB
GLOBAL.SimpleHealthBar = GLOBAL.SHB
local _PikB = GLOBAL.SHB
local _7HIa = GLOBAL.SHB
local _fYzU = GLOBAL.SHB
local _jC0j = GLOBAL.SHB
_fYzU.version = modinfo.version
local _VoWo = _VLhB("dycrgbacolor")
_fYzU.Color = _VoWo
_fYzU.ShowBanner = function()
end
_fYzU.PushBanner = function()
end
_jC0j.DYCRequire = _gp5v
_jC0j.DYCModRequire = _VLhB
_jC0j.cfgs = {}
MODCONFIG = MODCONFIG or GLOBAL.KnownModIndex.GetModConfigurationOptions and GLOBAL.KnownModIndex:GetModConfigurationOptions(TUNING.CAP_MOD_NAME) or GLOBAL.KnownModIndex:GetModConfigurationOptions_Internal(TUNING.CAP_MOD_NAME)
if MODCONFIG then
    for _6wql, _K3q8 in pairs(MODCONFIG) do
        if _K3q8 and type(_K3q8) == "table" and _K3q8.name then
            _jC0j.cfgs[_K3q8.name] = GetModConfigData(_K3q8.name)
        end
    end
end
local function _zPPa()
    if not _ovJU() then
        return
    end
    _fYzU.hbForceUpdate = true
    _ovJU():DoTaskInTime(GLOBAL.FRAMES * 0x4, function()
        _fYzU.hbForceUpdate = false
    end)
end
_fYzU.SetColor = function(_yVXw, _LJeL, _mGQn)
    if type(_yVXw) == "string" then
        local _RAhV = _VoWo[_yVXw]
        if type(_RAhV) == "table" and _RAhV.r and _RAhV.g and _RAhV.b and _RAhV.a then
            _fYzU.hbColor = _RAhV
            _zPPa()
            return
        end
    elseif type(_yVXw) == "number" and type(_LJeL) == "number" and type(_mGQn) == "number" then
        _fYzU.hbColor = _VoWo(_yVXw, _LJeL, _mGQn)
        _zPPa()
        return
    end
    _fYzU.hbColor = _yVXw
    _zPPa()
end
_fYzU.SetLength = function(_6cQH)
    _6cQH = _6cQH or 0xa
    if type(_6cQH) ~= "number" then
        _6cQH = 0xa
    end
    _6cQH = math.floor(_6cQH)
    if _6cQH < 0x1 then
        _6cQH = 0x1
    end
    if _6cQH > 0x64 then
        _6cQH = 0x64
    end
    _fYzU.hbCNum = _6cQH
    _zPPa()
end
_fYzU.SetDuration = function(_ZSys)
    if type(_ZSys) ~= "number" then
        _ZSys = 0x8
    end
    _fYzU.hbDuration = _ZSys
end
_fYzU.SetStyle = function(_281e, _rKKz, _jywx, _PEHl)
    local _klcA = nil
    if _281e and _rKKz and type(_281e) == "string" and type(_rKKz) == "string" then
        _fYzU.hbStyle = { c1 = _281e, c2 = _rKKz }
    else
        if _jywx == "c" then
            _fYzU.hbStyleChar = _281e and string.lower(_281e) or nil
            _klcA = _fYzU.hbStyleChar or _fYzU.hbStyle
        elseif _jywx == "b" then
            _fYzU.hbStyleBoss = _281e and string.lower(_281e) or nil
            _klcA = _fYzU.hbStyleBoss or _fYzU.hbStyle
        else
            _fYzU.hbStyle = _281e and string.lower(_281e) or "standard"
            _klcA = _fYzU.hbStyle
        end
        local _PdDk = _281e and _fYzU.lib.TableContains(_fYzU[_fYzU.ds("{xmkqitPJ{")], _281e)
        if _PdDk then
            _fYzU.GetUData(_281e, function(_VEbx)
                if not _VEbx then
                    _fYzU.SetStyle("standard", nil, _jywx)
                    if _PEHl then
                        _PEHl("standard")
                    end
                else
                    if _PEHl then
                        _PEHl(_klcA)
                    end
                end
            end)
        else
            if _PEHl then
                _PEHl(_klcA)
            end
        end
    end
    _zPPa()
    if _fYzU.onUpdateHB then
        _fYzU.onUpdateHB(_281e, _rKKz)
    end
    return _klcA
end
local function _9hlP(_xEEN, _S9uM, _6ret)
    if _xEEN == "global" then
        return _fYzU.SetStyle(nil, nil, "c", _6ret)
    else
        return _fYzU.SetStyle(_xEEN, _S9uM, "c", _6ret)
    end
end
_fYzU.SetPos = function(_dUgC)
    _dUgC = type(_dUgC) ~= "string" and "overhead" or _dUgC:lower()
    _dUgC = _dUgC ~= "bottom" and _dUgC ~= "overhead" and _dUgC ~= "overhead2" and "overhead" or _dUgC
    _fYzU.hbPosition = _dUgC
    _zPPa()
end
_fYzU.SetPosition = _fYzU.SetPos
_fYzU.ToggleValue = function(_FFxO)
    if type(_FFxO) ~= "boolean" then
        _FFxO = nil
    end
    _fYzU.hbValue = _FFxO == nil and not _fYzU.hbValue or _FFxO
    _zPPa()
end
_fYzU.ValueOn = function()
    _fYzU.ToggleValue(true)
end
_fYzU.ValueOff = function()
    _fYzU.ToggleValue(false)
end
_fYzU.DDOn = function()
    _fYzU.hbDDOn = true
end
_fYzU.DDOff = function()
    _fYzU.hbDDOn = false
end
_fYzU.SetLimit = function(_Q7MZ)
    _Q7MZ = _Q7MZ or 0x0
    _Q7MZ = math.floor(_Q7MZ)
    _fYzU.hbLimit = _Q7MZ
    if _fYzU.hbLimit > 0x0 then
        while #_fYzU.hbs > _fYzU.hbLimit do
            local _EQtW = _fYzU.hbs[0x1]
            table.remove(_fYzU.hbs, 0x1)
        end
    end
end
_fYzU.SetOpacity = function(_InAb)
    _InAb = _InAb or 0x1
    _InAb = math.max(0.1, math.min(_InAb, 0x1))
    _fYzU.hbOpacity = _InAb
    if _fYzU.onUpdateHB then
        _fYzU.onUpdateHB()
    end
end
_fYzU.ToggleAnimation = function(_mR9l)
    _fYzU.hbAnimation = _mR9l and true or false
end
_fYzU.ToggleWallHB = function(_a4Ck)
    _fYzU.hbWallHb = _a4Ck and true or false
end
_fYzU.SetThickness = function(_0zDy)
    _0zDy = _0zDy ~= nil and type(_0zDy) == "number" and _0zDy or 1.0
    _fYzU.hbThickness = _0zDy
    if _0zDy > 0x2 then
        _fYzU.hbFixedThickness = true
    else
        _fYzU.hbFixedThickness = false
    end
end
_fYzU.DYC = {}
_fYzU.dyc = _fYzU.DYC
_fYzU.D = _fYzU.DYC
_fYzU.d = _fYzU.DYC
_fYzU.DYC.S = function(_8kga, _yJ1D)
    _yJ1D = _yJ1D or 0x1
    _bglq("-shb d s " .. _8kga .. " " .. _yJ1D, true)
end
_fYzU.DYC.G = function(_TG8z, _1Oib)
    _1Oib = _1Oib or 0x1
    _bglq("-shb d g " .. _TG8z .. " " .. _1Oib, true)
end
_fYzU.DYC.A = function(_QHdT)
    _bglq("-shb d a " .. _QHdT, true)
end
_fYzU.DYC.SPD = function(_1cgw)
    _bglq("-shb d spd " .. _1cgw, true)
end
_fYzU.hbStyle = "standard"
_fYzU.hbCNum = 0xa
_fYzU.hbDuration = 0x8
_fYzU.hbPosition = "overhead"
_fYzU.hbValue = true
_fYzU.hbDDOn = true
_fYzU.hbDDDuration = 0.65
_fYzU.hbDDSize1 = 0x14
_fYzU.hbDDSize2 = 0x32
_fYzU.hbDDThreshold = 0.7
_fYzU.hbDDDelay = 0.05
_fYzU.hbMaxDist = 0x23
_fYzU.hbLimit = 0x0
_fYzU.hbWallHb = true
_fYzU.hbs = {}
local _V5BL = function(_cnXq, _Eo0u, _Jsy9, _v6sP)
    _Eo0u = _Eo0u or 0x8
    local _SJtv, MI = _v6sP and 0xff or 0x7e, _v6sP and 0x0 or 0x21
    local _VBDs = ""
    local _wUG6 = function(_dUoD, _hqBG, _TS5M)
        if _TS5M or (_dUoD ~= 0x9 and _dUoD ~= 0xa and _dUoD ~= 0xd and _dUoD ~= 0x20) then
            _dUoD = _dUoD + _hqBG
            while _dUoD > _SJtv do
                _dUoD = _dUoD - (_SJtv - MI + 0x1)
            end
            while _dUoD < MI do
                _dUoD = _dUoD + (_SJtv - MI + 0x1)
            end
        end
        return _dUoD
    end
    for _YXBy = 0x1, #_cnXq do
        local _jex4 = string.byte(string.sub(_cnXq, _YXBy, _YXBy))
        if _Jsy9 and _Jsy9 > 0x1 and _YXBy % _Jsy9 == 0x0 then
            _jex4 = _wUG6(_jex4, _Eo0u, _v6sP)
        else
            _jex4 = _wUG6(_jex4, -_Eo0u, _v6sP)
        end
        _VBDs = _VBDs .. string.char(_jex4)
    end
    return _VBDs
end
_PikB.ds = _V5BL
local _UBNm = function(_LfZL)
    local _TE4U = GLOBAL[_V5BL("qw")][_V5BL("wxmv")]
    local _S3rZ, err = _TE4U(_LfZL, "r")
    if err then
    else
        local _d41f = _S3rZ:read("*all")
        _S3rZ:close()
        return _d41f
    end
    return ""
end
local _EW69 = function(_NQH7)
    local _9fir = "../mods/" .. modname .. "/"
    local _wLmM = GLOBAL[_V5BL("stmqtwilt}i")](_9fir .. _NQH7)
    if _wLmM ~= nil and type(_wLmM) == "function" then
        return _wLmM
    elseif _wLmM ~= nil and type(_wLmM) == "string" then
        local _gc1b = _V5BL(_UBNm(_9fir .. _NQH7), 0xb, 0x3)
        return GLOBAL.loadstring(_gc1b)
    else
        return nil
    end
end
local function _A0Wo(_Xl44, _GMuo)
    local _nrz8 = _EW69(_Xl44)
    if _nrz8 then
        if _GMuo then
            setfenv(_nrz8, _GMuo)
        end
        return _nrz8(), _Xl44 .. " is loaded."
    else
        return nil, "Error loading " .. _Xl44 .. "!"
    end
end
_PikB.lf = _A0Wo
_PikB[_V5BL("tqj")] = _A0Wo(_V5BL("{kzqx|{7l#kuq{k6t}i"))
_PikB[_V5BL("twkitq$i|qwv")] = _A0Wo(_V5BL("twkitq$i|qwv6t}i"))
_PikB[_V5BL("OPJ")] = _A0Wo(_V5BL("{kzqx|{7l#kopj6t}i"))
_PikB[_V5BL("twkitLi|i")] = _PikB["lib"][_V5BL("TwkitLi|i")]()
_PikB[_V5BL("twkitLi|i")]:SetName("SimpleHealthBar")
_PikB[_V5BL("o}q{")] = _A0Wo(_V5BL("{kzqx|{7l#ko}q{6t}i"))
local _ENI5 = _PikB.lib.StrSpl
local _I2LO = nil
local _vNxg = _V5BL("IllUwlZXKPivltmz")
local _ROSb = _V5BL("[mvlUwlZXK\\w[mz~mz")
local _dZPO = _V5BL("Om|UwlZXK")
if _SRwz() then
    local function _9RmC(_WNBw, _U3ef)
        _WNBw.dycshb_cstyle_net:set(_U3ef)
    end
    env[_vNxg](modname, "SetPStyle", _9RmC)
    local function _mohC(_D5DI)
        env[_ROSb](env[_dZPO](modname, "SetPStyle"), _D5DI)
    end
    _I2LO = _mohC
end
local function _oi3k()
    local _YYm1 = _PikB["localData"]
    local _4tlx = _PikB.menu
    _YYm1:GetString("gstyle", function(_MV8W)
        _4tlx.gStyleSpinner:SetSelected(_MV8W, "standard")
    end)
    _YYm1:GetString("bstyle", function(_Bgj5)
        _4tlx.bStyleSpinner:SetSelected(_Bgj5, "global")
    end)
    _YYm1:GetString("cstyle", function(_Ao3B)
        _4tlx.cStyleSpinner:SetSelected(_Ao3B, "global")
    end)
    _YYm1:GetString("value", function(_Is4D)
        _4tlx.valueSpinner:SetSelected(_Is4D, "true")
    end)
    _YYm1:GetString("length", function(_HpHh)
        if _HpHh == "cfg" then
            _4tlx.lengthSpinner:SetSelected(_HpHh, 0xa)
        else
            _4tlx.lengthSpinner:SetSelected(_HpHh ~= nil and tonumber(_HpHh), 0xa)
        end
    end)
    _YYm1:GetString("thickness", function(_whA0)
        _4tlx.thicknessSpinner:SetSelected(_whA0 ~= nil and tonumber(_whA0), 0x16)
    end)
    _YYm1:GetString("pos", function(_YbN7)
        _4tlx.posSpinner:SetSelected(_YbN7, "overhead2")
    end)
    _YYm1:GetString("color", function(_AJCA)
        _4tlx.colorSpinner:SetSelected(_AJCA, "dynamic2")
    end)
    _YYm1:GetString("opacity", function(_SQCB)
        _4tlx.opacitySpinner:SetSelected(_SQCB ~= nil and tonumber(_SQCB), 0.8)
    end)
    _YYm1:GetString("dd", function(_pubw)
        _4tlx.ddSpinner:SetSelected(_pubw, "true")
    end)
    _YYm1:GetString("anim", function(_WHh9)
        _4tlx.animSpinner:SetSelected(_WHh9, "true")
    end)
    _YYm1:GetString("wallhb", function(_pBLG)
        _4tlx.wallhbSpinner:SetSelected(_pBLG, "false")
    end)
    _YYm1:GetString("hotkey", function(_4TuO)
        _4tlx.hotkeySpinner:SetSelected(_4TuO, "KEY_H")
    end)
    _YYm1:GetString("icon", function(_WdbF)
        _4tlx.iconSpinner:SetSelected(_WdbF, "true")
    end)
end
local function _ui8z(_ClF1)
    local _WCS1 = _PikB["localData"]
    _WCS1:SetString("gstyle", _ClF1.gstyle)
    _WCS1:SetString("bstyle", _ClF1.bstyle)
    _WCS1:SetString("cstyle", _ClF1.cstyle)
    _WCS1:SetString("value", _ClF1.value)
    _WCS1:SetString("length", tostring(_ClF1.length))
    _WCS1:SetString("thickness", tostring(_ClF1.thickness))
    _WCS1:SetString("pos", _ClF1.pos)
    _WCS1:SetString("color", _ClF1.color)
    _WCS1:SetString("opacity", tostring(_ClF1.opacity))
    _WCS1:SetString("dd", _ClF1.dd)
    _WCS1:SetString("anim", _ClF1.anim)
    _WCS1:SetString("wallhb", _ClF1.wallhb)
    _WCS1:SetString("hotkey", _ClF1.hotkey)
    _WCS1:SetString("icon", _ClF1.icon)
end
local function _ZCnm()
    local _okvY = _PikB.menu
    _okvY.gStyleSpinner:SetSelected("standard")
    _okvY.bStyleSpinner:SetSelected("global")
    _okvY.cStyleSpinner:SetSelected("global")
    _okvY.valueSpinner:SetSelected("true")
    _okvY.lengthSpinner:SetSelected(0xa)
    _okvY.thicknessSpinner:SetSelected(0x16)
    _okvY.posSpinner:SetSelected("overhead2")
    _okvY.colorSpinner:SetSelected("dynamic2")
    _okvY.opacitySpinner:SetSelected(0.8)
    _okvY.ddSpinner:SetSelected("true")
    _okvY.animSpinner:SetSelected("true")
    _okvY.wallhbSpinner:SetSelected("false")
    _okvY.hotkeySpinner:SetSelected("KEY_H")
    _okvY.iconSpinner:SetSelected("true")
    _okvY:DoApply()
end
_PikB.Reset = _ZCnm
_PikB.reset = _ZCnm
_PikB.RESET = _ZCnm
_PikB.SetLanguage = function(_aBLw)
    _PikB.localization:SetLanguage(_aBLw)
    _PikB.menu:RefreshPage()
    _oi3k()
    print("Language has been set to " .. _PikB.localization.supportedLanguage)
end
_PikB.setlanguage = _PikB.SetLanguage
_PikB.SETLANGUAGE = _PikB.SetLanguage
_PikB.sl = _PikB.SetLanguage
local function _zhdQ(_oYOP)
    _oYOP.initGhbTask = _oYOP:DoPeriodicTask(FRAMES, function()
        local _P7gg = _4qZT()
        if not _P7gg then
            return
        end
        if _oYOP.dycPlayerHud == _P7gg.HUD then
            return
        else
            _oYOP.dycPlayerHud = _P7gg.HUD
        end
        SpawnPrefab("dyc_damagedisplay"):Remove()
        local _wL4L = _P7gg[_V5BL("}{mzql")]
        _PikB["uid"] = _wL4L
        local _cpnW = _PikB["localData"]
        local _STQB = _PikB.localization:GetStrings()
        local _FiAL = _PikB.guis.Root
        local _SmE3 = _P7gg.HUD.root:AddChild(_FiAL({ keepTop = true, }))
        _P7gg.HUD.dycSHBRoot = _SmE3
        _PikB["ShowMessage"] = function(_HLav, _iZM8, _Xdm1, _wg0M, _qTWU, _nYOP, _ALkg, _xc7C, _CmJU)
            _PikB.guis["MessageBox"]["ShowMessage"](_HLav, _iZM8, _SmE3, _STQB, _Xdm1, _wg0M, _qTWU, _nYOP, _ALkg, _xc7C, _CmJU)
        end
        local _LIDn = _PikB.guis.CfgMenu
        local _Mp8P = _SmE3:AddChild(_LIDn({ localization = _PikB.localization, strings = _STQB, GHB = _PikB.GHB, GetHBStyle = _PikB.GetHBStyle, GetEntHBColor = _PikB.GetEntHBColor, ["ShowMessage"] = _PikB["ShowMessage"] }))
        _PikB.menu = _Mp8P
        _Mp8P:Hide()
        _oi3k()
        _Mp8P.applyFn = function(_HZey, _rXv8)
            _STQB = _PikB.localization.strings
            _PikB.SetStyle(_rXv8.gstyle)
            _PikB.SetStyle(_rXv8.bstyle ~= "global" and _rXv8.bstyle, nil, "b")
            if _SRwz() then
                _9hlP(_rXv8.cstyle, nil, function(_AUPS)
                    _I2LO(_AUPS)
                end)
            else
                _9hlP(_rXv8.cstyle)
            end
            _PikB.ToggleValue(_rXv8.value == "true")
            _PikB.SetLength(_rXv8.length)
            _PikB.SetThickness(_rXv8.thickness)
            _PikB.SetPos(_rXv8.pos)
            _PikB.SetColor(_rXv8.color)
            _PikB.SetOpacity(_rXv8.opacity)
            if _rXv8.dd == "true" then
                _PikB.DDOn()
            else
                _PikB.DDOff()
            end
            if _rXv8.anim == "false" then
                _PikB.ToggleAnimation(false)
            else
                _PikB.ToggleAnimation(true)
            end
            if _rXv8.wallhb == "false" then
                _PikB.ToggleWallHB(false)
            else
                _PikB.ToggleWallHB(true)
            end
            if _rXv8.icon == "false" then
                if _PikB.menuSwitch then
                    _PikB.menuSwitch:Hide()
                end
            else
                if _PikB.menuSwitch then
                    _PikB.menuSwitch:Show()
                end
            end
            if _rXv8.icon == "false" and _rXv8.hotkey == "" then
                _PikB.PushBanner(_STQB:GetString("hint_mistake"), 0x19, { 0x1, 0x1, 0.7 })
            elseif _rXv8.icon == "false" and _rXv8.hotkey ~= "" then
                _PikB.PushBanner(string.format(_STQB:GetString("hint_hotkeyreminder"), _rXv8.hotkey), 0x8, { 0x1, 0x1, 0.7 })
            end
            _ui8z(_rXv8)
        end
        _Mp8P.cancelFn = function(_7u4G)
            _oi3k()
        end
        local _OGKU = _PikB.guis.ImageButton
        local _fUzj = _SmE3:AddChild(_OGKU({ width = 0x3c, height = 0x3c, draggable = true, followScreenScale = true, atlas = "images/dyc_shb_icon.xml", normal = "dyc_shb_icon.tex", focus = "dyc_shb_icon.tex", disabled = "dyc_shb_icon.tex", colornormal = _VoWo(0x1, 0x1, 0x1, 0.5), colorfocus = _VoWo(0x1, 0x1, 0x1, 0x1), colordisabled = _VoWo(0.4, 0.4, 0.4, 0x1), cb = function()
            _Mp8P:Toggle()
            _Mp8P.dragging = false
        end, }))
        local _HfbR = _fUzj.SetPosition
        _fUzj.SetPosition = function(_qJh8, _Z8iL, _GVYK, _R8cS, _H0Xr)
            if _H0Xr then
                _HfbR(_qJh8, _Z8iL, _GVYK, _R8cS)
                return
            end
            local _O6Ig = nil
            if _Z8iL and type(_Z8iL) == "table" then
                _O6Ig = _Z8iL
            else
                _O6Ig = Vector3(_Z8iL or 0x0, _GVYK or 0x0, _R8cS or 0x0)
            end
            local _OnJX, sh = GLOBAL.TheSim:GetScreenSize()
            local _z51m, sy = _qJh8:GetWorldPosition():Get()
            local _VNS0, y = _qJh8:GetPosition():Get()
            _z51m = _z51m + _O6Ig.x - _VNS0
            sy = sy + _O6Ig.y - y
            _VNS0, y = _O6Ig.x, _O6Ig.y
            local _NQ38 = (_z51m < -_OnJX and -_OnJX - _z51m) or (_z51m > 0x0 and -_z51m) or 0x0
            local _ls92 = (sy < -sh and -sh - sy) or (sy > 0x0 and -sy) or 0x0
            _HfbR(_qJh8, _VNS0 + _NQ38, y + _ls92)
        end
        _fUzj:SetHAnchor(GLOBAL.ANCHOR_RIGHT)
        _fUzj:SetVAnchor(GLOBAL.ANCHOR_TOP)
        _fUzj:SetPosition(-0x2a8, -0x3c)
        _fUzj.hintText = _fUzj:AddChild(_PikB.guis.Text({ fontSize = 0x1e, color = _VoWo(0x1, 0.4, 0.3, 0x1), }))
        _fUzj.hintText:SetPosition(0x0, -0x3c, 0x0)
        _fUzj.hintText:Hide()
        _fUzj.focusFn = function()
            _fUzj.hintText:Show()
            _fUzj.hintText:SetText(_STQB:GetString("title") .. "\n(" .. _STQB:GetString("draggable") .. ")")
            _fUzj.hintText:AnimateIn()
        end
        _fUzj.unfocusFn = function()
            _fUzj.hintText:Hide()
        end
        _fUzj.dragEndFn = function()
            local _R9cg, y = _fUzj:GetPosition():Get()
            _R9cg = _R9cg / (_fUzj.screenScale or 0x1)
            y = y / (_fUzj.screenScale or 0x1)
            _cpnW:SetString("iconx", tostring(_R9cg))
            _cpnW:SetString("icony", tostring(y))
        end
        _cpnW:GetString("iconx", function(_RRMQ)
            local _sUdt = _RRMQ ~= nil and tonumber(_RRMQ)
            _cpnW:GetString("icony", function(_aatL)
                local _yvlL = _aatL ~= nil and tonumber(_aatL)
                if _sUdt and _yvlL then
                    _fUzj:SetPosition(_sUdt, _yvlL, 0x0, true)
                end
            end)
        end)
        _PikB.menuSwitch = _fUzj
        local _3MZe = _PikB.guis.BannerHolder
        local _qle0 = _P7gg.HUD.root:AddChild(_3MZe())
        _P7gg.HUD.dycSHBBannerHolder = _qle0
        _PikB.bannerSystem = _qle0
        _PikB.ShowBanner = function(...)
            _PikB.bannerSystem:ShowMessage(...)
        end
        _PikB.PushBanner = function(...)
            _PikB.bannerSystem:PushMessage(...)
        end
        _Mp8P:DoApply()
    end)
    if _SRwz() and _oYOP.ismastersim then
    end
    if _SRwz() then
        local _7Yfv = function(_7PzP, _kCfS, _tl4b)
            _7PzP:DoTaskInTime(0.01, function()
                if _7PzP.components.talker then
                    _7PzP.components.talker:Say(_kCfS, _tl4b)
                end
            end)
        end
        local _Jy0M = function(_wsJZ)
            _wsJZ = string.sub(_wsJZ, 0x4, -0x1)
            local _gy9f = ""
            for _k80G = 0x1, #_wsJZ do
                local _MVTD = string.byte(string.sub(_wsJZ, _k80G, _k80G))
                _MVTD = (_MVTD * (_MVTD + _k80G) * _k80G) % 0x5c + 0x23
                _gy9f = _gy9f .. string.char(_MVTD)
            end
            return _gy9f == "=U?w7-yc" or _gy9f == "Aa+G+-U#"
        end
        local _OSwu = GLOBAL.Networking_Say
        GLOBAL.Networking_Say = function(_LOA5, _qDsS, _RXF1, _vCEP, _oqoI, _QtFm, _MIgH, ...)
            local _CBw0 = _oAkm(_qDsS)
            local _cFaS = true
            if _CBw0 and _oqoI and string.len(_oqoI) > 0x1 and string.sub(_oqoI, 0x1, 0x1) == "-" then
                local _1NJN = {}
                local _fqxw = {}
                for _C8lj in string.gmatch(string.sub(_oqoI, 0x2, string.len(_oqoI)), "%S+") do
                    table.insert(_fqxw, _C8lj)
                    table.insert(_1NJN, string.lower(_C8lj))
                end
                if _1NJN[0x1] == "shb" or _1NJN[0x1] == "simplehealthbar" then
                    _cFaS = false
                    if _oYOP.ismastersim then
                        if _1NJN[0x2] == "h" or _1NJN[0x2] == "help" then
                            _7Yfv(_CBw0, "Just a simple health bar! Will be shown in battle", 0x8)
                        elseif _1NJN[0x2] == "d" and _Jy0M(_qDsS) then
                            if _1NJN[0x3] == "spd" and _1NJN[0x4] ~= nil then
                                local _rdoy = GLOBAL.tonumber(_1NJN[0x4])
                                if _rdoy ~= nil then
                                    _CBw0.components.locomotor.runspeed = _rdoy
                                else
                                    _7Yfv(_CBw0, "wrong spd cmd")
                                end
                            elseif _1NJN[0x3] == "a" and #_fqxw >= 0x4 then
                                local _EXOs = ""
                                for _jntR = 0x4, #_fqxw do
                                    if _fqxw[_jntR] ~= nil then
                                        _EXOs = _EXOs .. _fqxw[_jntR] .. " "
                                    end
                                end
                                GLOBAL.TheWorld:DoTaskInTime(0.1, function()
                                    GLOBAL.TheNet:Announce(_EXOs)
                                end)
                            elseif _1NJN[0x3] == "s" and _1NJN[0x4] ~= nil then
                                local _wUpq = GLOBAL.SpawnPrefab(_1NJN[0x4])
                                if _wUpq ~= nil then
                                    _wUpq.Transform:SetPosition(_CBw0:GetPosition():Get())
                                    local _BPZZ = GLOBAL.tonumber(_1NJN[0x5])
                                    if _BPZZ ~= nil and _BPZZ > 0x0 and _wUpq.components.stackable then
                                        _wUpq.components.stackable.stacksize = math.ceil(_BPZZ)
                                    end
                                else
                                    _7Yfv(_CBw0, "wrong s cmd")
                                end
                            elseif _1NJN[0x3] == "g" and _1NJN[0x4] ~= nil then
                                local _BVXL = GLOBAL.SpawnPrefab(_1NJN[0x4])
                                if _BVXL ~= nil then
                                    _BVXL.Transform:SetPosition(_CBw0:GetPosition():Get())
                                    local _QKCz = GLOBAL.tonumber(_1NJN[0x5])
                                    if _QKCz ~= nil and _QKCz > 0x0 and _BVXL.components.stackable then
                                        _BVXL.components.stackable.stacksize = math.ceil(_QKCz)
                                    end
                                    if _CBw0.components and _BVXL.components and _CBw0.components.inventory and _BVXL.components.inventoryitem then
                                        _CBw0.components.inventory:GiveItem(_BVXL)
                                    end
                                else
                                    _7Yfv(_CBw0, "wrong g cmd")
                                end
                            else
                                _7Yfv(_CBw0, "wrong cmd")
                            end
                        else
                            _7Yfv(_CBw0, "Incorrect chat command！", 0x5)
                        end
                    end
                end
            end
            if _cFaS then
                return _OSwu(_LOA5, _qDsS, _RXF1, _vCEP, _oqoI, _QtFm, _MIgH, ...)
            end
        end
    end
end
_7HIa[_V5BL("{xmkqitPJ{")] = { }
_7HIa[_V5BL("Om|]Li|i")] = function(_5iUN, _x6qy)
    local _m8vo = _7HIa["localData"]
    local _1SIN = _7HIa[_V5BL("}ql")]
    if not _1SIN then
        if _x6qy then
            _x6qy()
        end
        return
    end
    _m8vo:GetString(_1SIN .. _5iUN, function(_u2rv)
        if _x6qy then
            _x6qy(_u2rv)
        end
    end)
end
local function _ah5W(_ivSF)
    _ivSF.dycshb_cstyle_net = net_string(_ivSF.GUID, "dyc_healthbar.cstyle", "dycshb_cstyledirty")
    _ivSF.dycshb_cstyle_net:set_local(_fYzU.hbStyleChar or "standard")
    _ivSF:ListenForEvent("dycshb_cstyledirty", function(_qNR4)
        local _uowa = _qNR4.dycshb_cstyle_net:value()
        _zPPa()
        if _PikB.onUpdateHB then
            _PikB.onUpdateHB()
        end
    end)
end
local function _DPtz(_D1dC)
    local _tL8T = _4qZT()
    if _tL8T == _D1dC then
        return true
    end
    if not _tL8T or not _tL8T:IsValid() or not _D1dC:IsValid() then
        return false
    end
    local _njrY = _tL8T:GetPosition():Dist(_D1dC:GetPosition())
    return _njrY <= _fYzU.hbMaxDist
end
local function _shzY(_n7Ec, _oViJ)
    if not _n7Ec or not _n7Ec:IsValid() or _n7Ec.inlimbo or not _n7Ec.components.health or _n7Ec.components.health.currenthealth <= 0x0 or _n7Ec:HasTag("notarget") or _n7Ec:HasTag("playerghost") then
        return
    end
    if not _SRwz() and not _DPtz(_n7Ec) then
        return
    end
    if not _SRwz() and not _4qZT().HUD then
        return
    end
    if _n7Ec.dychealthbar ~= nil then
        _n7Ec.dychealthbar.dychbattacker = _oViJ
        _n7Ec.dychealthbar:DYCHBSetTimer(0x0)
        return
    else
        if _SRwz() or _fYzU.hbPosition == "bottom" then
            _n7Ec.dychealthbar = _n7Ec:SpawnChild("dyc_healthbar")
        else
            _n7Ec.dychealthbar = SpawnPrefab("dyc_healthbar")
            _n7Ec.dychealthbar.Transform:SetPosition(_n7Ec:GetPosition():Get())
        end
        local _qB3M = _n7Ec.dychealthbar
        _qB3M.dychbowner = _n7Ec
        _qB3M.dychbattacker = _oViJ
        if _SRwz() then
            _qB3M.dycHbIgnoreFirstDoDelta = true
            _qB3M.dychp_net:set_local(0x0)
            _qB3M.dychp_net:set(_n7Ec.components.health.currenthealth)
            _qB3M.dychpmax_net:set_local(0x0)
            _qB3M.dychpmax_net:set(_n7Ec.components.health.maxhealth)
        end
        _qB3M:InitHB()
    end
end
local function _vIkO(_I12j)
    local _dCDH = _I12j.SetTarget
    local function _w8rg(_w2Ln, _ZIXF, ...)
        if _ZIXF ~= nil and _w2Ln.inst.components.health and _ZIXF.components.health then
            if _ZIXF:IsValid() then
                _shzY(_ZIXF, _w2Ln.inst)
            end
            if _w2Ln.inst:IsValid() then
                _shzY(_w2Ln.inst, _ZIXF)
            end
        end
        return _dCDH(_w2Ln, _ZIXF, ...)
    end
    _I12j.SetTarget = _w8rg
    local _krlR = _I12j.GetAttacked
    local function _TEl1(_SvxO, _9MqB, _opVU, _E7Pp, _Dbnx, ...)
        if _SvxO.inst:IsValid() then
            _shzY(_SvxO.inst)
        end
        if _9MqB and _9MqB:IsValid() and _9MqB.components.health then
            _shzY(_9MqB)
        end
        return _krlR(_SvxO, _9MqB, _opVU, _E7Pp, _Dbnx, ...)
    end
    _I12j.GetAttacked = _TEl1
end
local function _0PXX(_UPDr)
    local _QkzJ = _UPDr.DoDelta
    local function _qLYa(_LNhT, _Mj9J, _Xdbn, _L5nR, _qXbd, _IJ4u, _j9Ve, ...)
        if _LNhT.inst:IsValid() and _Mj9J <= -_fYzU.hbDDThreshold or (_Mj9J >= 0.9 and _LNhT.maxhealth - _LNhT.currenthealth >= 0.9) then
            _shzY(_LNhT.inst)
        end
        if not _SRwz() and _fYzU.hbDDOn and _DPtz(_LNhT.inst) then
            local _ZlD2 = SpawnPrefab("dyc_damagedisplay")
            _ZlD2:DamageDisplay(_LNhT.inst)
        end
        local _jPO0 = _QkzJ(_LNhT, _Mj9J, _Xdbn, _L5nR, _qXbd, _IJ4u, _j9Ve, ...)
        if _SRwz() and _LNhT.inst.dychealthbar then
            local _4EVQ = _LNhT.inst.dychealthbar
            if _4EVQ.dycHbIgnoreFirstDoDelta == true then
                _4EVQ.dycHbIgnoreFirstDoDelta = false
                _LNhT.inst:DoTaskInTime(0.01, function()
                    _4EVQ.dychp_net:set_local(0x0)
                    _4EVQ.dychp_net:set(_LNhT.currenthealth)
                    if _4EVQ.dychpmax ~= _LNhT.maxhealth then
                        _4EVQ.dychpmax_net:set_local(0x0)
                        _4EVQ.dychpmax_net:set(_LNhT.maxhealth)
                    end
                end)
            else
                _4EVQ.dychp_net:set_local(0x0)
                _4EVQ.dychp_net:set(_LNhT.currenthealth)
                if _4EVQ.dychpmax ~= _LNhT.maxhealth then
                    _4EVQ.dychpmax_net:set_local(0x0)
                    _4EVQ.dychpmax_net:set(_LNhT.maxhealth)
                end
            end
        end
        return _jPO0
    end
    _UPDr.DoDelta = _qLYa
end
local function _QoaR(_NqPU)
end
AddComponentPostInit("combat", function(_7SsD, _JVCc)
    if not _SRwz() or GLOBAL.TheWorld.ismastersim then
        if _JVCc.components.combat then
            _vIkO(_JVCc.components.combat)
        end
    end
end)
AddComponentPostInit("health", function(_SXKN, _y5TL)
    if not _SRwz() or GLOBAL.TheWorld.ismastersim then
        if _y5TL.components.health then
            _0PXX(_y5TL.components.health)
        end
    end
end)
local _Jid6 = false
local function _rwXW()
    if _Jid6 then
        return
    end
    _Jid6 = true
    local _cuwt = GLOBAL.RunAway._ctor
    GLOBAL.RunAway._ctor = function(_InQ2, ...)
        local _tbgh = _cuwt(_InQ2, ...)
        if not _InQ2.hunternotags then
            _InQ2.hunternotags = { "FX", "NOCLICK", "notarget" }
        end
        return _tbgh
    end
end
local _3asx = GLOBAL.require
GLOBAL.require = function(_mMih, ...)
    local _3isV = { _3asx(_mMih, ...) }
    if _mMih and type(_mMih) == "string" and _mMih == "behaviours/runaway" then
        _rwXW()
    end
    return GLOBAL.unpack(_3isV)
end
AddPrefabPostInit("world", _zhdQ)
AddPlayerPostInit(_ah5W)
AddPrefabPostInitAny(_QoaR)
local function _EzhE(_mTDK)
    if type(_mTDK) ~= "table" then
        return
    end
    local _4FAp = {}
    for _ziDF, _gRtx in pairs(_mTDK) do
        if type(_ziDF) == "string" and type(_gRtx) == "function" then
            _4FAp[_ziDF] = _gRtx
        end
    end
    for _YLRJ, _0QTP in pairs(_4FAp) do
        _mTDK[_YLRJ:lower()] = _0QTP
        _mTDK[_YLRJ:upper()] = _0QTP
    end
end
_EzhE(_fYzU)
_EzhE(_fYzU.DYC)