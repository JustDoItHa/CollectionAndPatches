-- get rid of any GLOBAL. prefix
GLOBAL.setmetatable(env, {
    __index = function(t, k)
        return GLOBAL.rawget(GLOBAL, k)
    end
})
modimport("scripts/apis.lua")
--PrefabFiles = {"globalmapicon_withname"}
table.insert(PrefabFiles, "globalmapicon_withname")
local ISDEDICATED = IsDedicated()
utils.player(function(inst)
    inst:AddTag("compassbearer")
    local mr = inst.components.maprevealable
    if mr then
        mr:SetIconPrefab("globalmapicon_withname")
        mr:AddRevealSource(inst, "compassbearer")
    end
end)
local global_name = "GLOBALPLAYERPOSITIONS"
local g = safeget(GLOBAL, global_name, {})
exposeToGlobal(global_name, g, false, true)
TUNING.PLAYERPOSITIONS_INTERVAL=GetConfig("compass_refresh_interval")
if ISDEDICATED then
    return
end
-- below for client, so that server doesn't hold any data.
local apis = {"uiapis", "playerposition"}
utils.mod(MapDict(apis, function(k, v)
    return "scripts/" .. v .. ".lua"
end))

local function OnMapDeactivated(MapWidget)
    for k, v in pairs(g) do
        v:disable()
    end
end

utils.prefab("globalmapicon_withname", function(inst)
    if not g[inst.GUID] then
        local pos = CreatePlayer(inst)
        g[inst.GUID] = pos
    end
end)

local function UpdatePosition()
    for k, v in pairs(g) do
        v:offset()
    end
end

local function OnMapActivated(self)
    for k, v in pairs(g) do
        v:enable()
    end
    -- tested that both MapScreen.OnUpdate and MapWidget.OnUpdate is capable. But MapWidget.Offset misses some cases.
    self.OnUpdate = MakeWrapper(self.OnUpdate, UpdatePosition)
end

--[[ Patch the Map Screen to disable the hovertext when getting closed, and add ping interface]] --
local function HackMapScreen(MapScreen)
    local OldOnBecomeInactive = MapScreen.OnBecomeInactive
    local OldOnBecomeActive = MapScreen.OnBecomeActive
    function MapScreen:OnBecomeInactive(...)
        OnMapDeactivated(MapScreen.minimap)
        OldOnBecomeInactive(self, ...)
    end
    function MapScreen:OnBecomeActive(...)
        OldOnBecomeActive(self, ...)
        OnMapActivated(MapScreen.minimap)
    end
end

utils.class("widgets/mapwidget", OnMapActivated)
utils.class("screens/mapscreen", HackMapScreen)
