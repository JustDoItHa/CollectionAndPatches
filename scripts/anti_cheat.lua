local _G = GLOBAL
local KnownModIndex = _G.KnownModIndex
local DEGREES = _G.DEGREES
local RESOLUTION_Y = _G.RESOLUTION_Y
local TheSim = _G.TheSim
local TheWorld = _G.TheWorld
local TheNet = _G.TheNet
local CheckCamera = GetModConfigData("camera")
local CheckVision = GetModConfigData("nightvision")
local ExWhitemods = GetModConfigData("whitemods")
local ExBlockmods = GetModConfigData("blockmods")
local CheckMode = GetModConfigData("checkmode")
local BlockModsId = { "workshop-1838267046" }
local WhiteModsId = {
    "workshop-1365141672", -- too many items plus
    "workshop-1835465557",
    "workshop-2784715091",
    "workshop-343753877",
    "workshop-2773348050",
    "workshop-2485714729",
    "workshop-376333686",
    "workshop-2438350724",
    "workshop-351325790",
    "workshop-352373173",
    "workshop-2325441848",
    "workshop-2753482847"
}
local ClientEnabledMods = {}
-- local AllMods = KnownModIndex:GetModsToLoad()
-- 错误提示
local ErrorMessage = {
    TIP = "[反作弊提示您]:",
    MODINFO = "Mod名称: %s   Mod文件夹: %s \n",
    specialtips = "若您想要继续玩下去,请先关闭那些mod\n",
    wtips = "由于服主已开启白名单模式,您启用了白名单以外的mod,\n若您想要继续玩下去,请先关闭那些mod,或者联系服主\n",
    btips = "\n由于侦测到您开启了作弊类mod,\n若您想要继续玩下去,请先关闭那些mod,\n"
}
local function AddExtraMods()
    -- 自定义的白名单列表
    if ExWhitemods then
        for _, v in pairs(ExWhitemods) do
            table.insert(WhiteModsId, v)
        end
    end
    -- 自定义的黑名单列表
    if ExBlockmods then
        for _, v in pairs(ExBlockmods) do
            table.insert(BlockModsId, v)
        end
    end
    -- 客户端启用的mod列表
    for _, mod_name in pairs(KnownModIndex:GetModsToLoad()) do
        if KnownModIndex:GetModInfo(mod_name).client_only_mod then
            table.insert(ClientEnabledMods, mod_name)
        end
    end
end

local function CheckModName(mod_name)
    if CheckMode == true then
        for _, v in pairs(WhiteModsId) do
            if v == mod_name then
                return true
            end
        end
        return false
    else
        for _, v in pairs(BlockModsId) do
            if v == mod_name then
                return true
            end
        end
        return false
    end
end
local function IsTargetMod(mod_name)
    return CheckModName(mod_name)
end
local function SpecialCheck()
    local str = ""
    local has_btmod = false
    if CheckCamera == 2 then
        if _G.TheCamera.maxdist > 150 then
            str = str ..
                    "警告：检测到视野不正常，您可能开启了大视野类mod.\n"
            has_btmod = true
        end
    end

    if CheckVision == 2 then
        if _G.ThePlayer.components.playervision.forcenightvision == true and
                _G.ThePlayer.replica.inventory:EquipHasTag("nightvision") == false and
                not _G.ThePlayer:HasTag("wereplayer") then
            str = str ..
                    "警告：检测到人物视力不正常，您可能开启了夜视类mod.\n"
            has_btmod = true
        end
    end
    return str, has_btmod
end
local function breakgame(inst)
    inst:DoTaskInTime(5, function()
        _G.DoRestart(true)
    end)
end
local function RealCheck(inst)
    local errormessage = ErrorMessage.TIP
    local special_str, has_btmod = SpecialCheck()
    if has_btmod then
        errormessage = errormessage .. special_str .. ErrorMessage.specialtips
        _G.ThePlayer.components.talker:Say(errormessage, 10)
        -- print(errormessage)
        breakgame(inst)
    end
end
local function ExecuteBtMods(inst)
    local EnabledBtMods = {}
    -- mod_name是存放mod的文件夹名字，例如 workshop-1200745268
    -- modinfo是mod的具体信息，具体引用有 modinfo.name,modinfo.version,modinfo.api_version
    for k, mod_name in ipairs(ClientEnabledMods) do
        local modinfo = KnownModIndex:GetModInfo(mod_name)
        local modinfo_name = modinfo and modinfo.name
        -- print("检查Mods",mod_name,modinfo)
        if IsTargetMod(mod_name) ~= CheckMode then
            table.insert(EnabledBtMods,
                    { mod_name = mod_name, modinfo_name = modinfo_name })
        end
        if #EnabledBtMods > 0 then
            local errormessage = ErrorMessage.TIP
            if CheckMode then
                errormessage = errormessage .. ErrorMessage.wtips

            else
                errormessage = errormessage .. ErrorMessage.btips
            end

            for k, v in pairs(EnabledBtMods) do
                local mod_name = v.mod_name
                local modinfo_name = v.modinfo_name
                local modstring = string.format(ErrorMessage.MODINFO,
                        modinfo_name, mod_name)
                errormessage = errormessage .. modstring
            end
            -- GLOBAL.assert(nil,errormessage)
            _G.ThePlayer.components.talker:Say(errormessage, 10)
            -- print(errormessage)
            breakgame(inst)

        end
    end

end

local function Checkinit(inst)
    AddExtraMods()
    inst:DoTaskInTime(6, function()
        ExecuteBtMods(inst)
    end) -- 校验mod
    if CheckVision == 2 or CheckCamera == 2 then
        inst:DoPeriodicTask(10, function()
            -- 10秒检查一次,
            RealCheck(inst)
        end)
    end
end

AddPlayerPostInit(function(inst)
    BlockModsId = { "workshop-1838267046" }
    WhiteModsId = { "workshop-1365141672", -- too many items plus
                    "workshop-1835465557",
                    "workshop-2784715091",
                    "workshop-343753877",
                    "workshop-2773348050",
                    "workshop-2485714729",
                    "workshop-376333686",
                    "workshop-2438350724",
                    "workshop-351325790",
                    "workshop-352373173",
                    "workshop-2325441848",
                    "workshop-2753482847" }
    ClientEnabledMods = {}
    if not _G.TheNet:IsDedicated() then
        Checkinit(inst)
    end
end)

if CheckCamera == 1 then

    local cramera = require("cameras/followcamera")

    cramera.Apply = function(self)
        -- dir
        --  self.fov=35
        --  self.maxdist = 50

        if self.fov > 35 then
            self.fov = 35
        end
        if self.maxdist > 150 then
            if TheWorld ~= nil and TheWorld:HasTag("cave") then
                self.maxdist = 100
            else
                self.maxdist = 150
            end
        end
        if self.distancetarget > 150 then
            self.distancetarget = 32
        end

        local pitch = self.pitch * DEGREES
        local heading = self.heading * DEGREES
        local cos_pitch = math.cos(pitch)
        local cos_heading = math.cos(heading)
        local sin_heading = math.sin(heading)
        local dx = -cos_pitch * cos_heading
        local dy = -math.sin(pitch)
        local dz = -cos_pitch * sin_heading

        -- screen horizontal offset
        local xoffs, zoffs = 0, 0
        if self.currentscreenxoffset ~= 0 then
            -- FOV is relative to screen height
            -- hoffs is in units of screen heights
            -- convert hoffs to xoffs and zoffs in world space
            local hoffs = 2 * self.currentscreenxoffset / RESOLUTION_Y
            local magic_number = 1.03 -- plz... halp.. if u can figure out what this rly should be
            local screen_heights = math.tan(self.fov * .5 * DEGREES) *
                    self.distance * magic_number
            xoffs = -hoffs * sin_heading * screen_heights
            zoffs = hoffs * cos_heading * screen_heights
        end

        -- pos
        TheSim:SetCameraPos(self.currentpos.x - dx * self.distance + xoffs,
                self.currentpos.y - dy * self.distance,
                self.currentpos.z - dz * self.distance + zoffs)
        TheSim:SetCameraDir(dx, dy, dz)

        -- right
        local right = (self.heading + 90) * DEGREES
        local rx = math.cos(right)
        local ry = 0
        local rz = math.sin(right)

        -- up
        local ux = dy * rz - dz * ry
        local uy = dz * rx - dx * rz
        local uz = dx * ry - dy * rx

        TheSim:SetCameraUp(ux, uy, uz)
        TheSim:SetCameraFOV(self.fov)

        -- listen dist
        local listendist = -.1 * self.distance
        TheSim:SetListener(dx * listendist + self.currentpos.x,
                dy * listendist + self.currentpos.y,
                dz * listendist + self.currentpos.z, dx, dy, dz, ux,
                uy, uz)
    end
end

if CheckVision == 1 then
    AddComponentPostInit("playervision", function(self)
        -- ThePlayer.components.playervision:ForceNightVision(true)
        self.railnightversion = _G.net_bool(self.inst.GUID, "railnightversion",
                "ForceNightVision")
        self.ForceNightVision = function(self, force)

            if TheNet:GetIsClient() then
                force = self.railnightversion:value()
            else
                if force == nil then
                    force = false
                end
                self.railnightversion:set(force)
            end
            if not self.forcenightvision ~= not force then
                self.forcenightvision = force == true
                if not self.nightvision then
                    self:UpdateCCTable()
                    self.inst:PushEvent("nightvision", self.forcenightvision)
                end
            end
        end

    end)
end
