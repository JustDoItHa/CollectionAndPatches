
local TheStatusBar = nil


-- Utilities

-- prefabs/beefalo.lua -- The Eye of the Storm
local function CalculateBuckDelay(inst)
    local domestication = inst.components.domesticatable ~= nil and inst.components.domesticatable:GetDomestication() or 0
    local moodmult = inst:GetIsInMood(inst) and TUNING.BEEFALO_BUCK_TIME_MOOD_MULT or 1
    local beardmult = (inst.components.beard ~= nil and inst.components.beard.bits == 0) and TUNING.BEEFALO_BUCK_TIME_NUDE_MULT or 1
    local domesticmult = inst.components.domesticatable:IsDomesticated() and 1 or TUNING.BEEFALO_BUCK_TIME_UNDOMESTICATED_MULT
    local basedelay = GLOBAL.Remap(domestication, 0, 1, TUNING.BEEFALO_MIN_BUCK_TIME, TUNING.BEEFALO_MAX_BUCK_TIME)

    return basedelay * moodmult * beardmult * domesticmult
end

local function RGBA (R, G, B, A)
    return {R / 255, G / 255, B / 255, A or 1}
end


-- Server handlers


local function OnMount(rider, data)
    local mount = data.target
    if mount and mount.prefab == "beefalo" then
        local mountData = {
            health = mount.replica.health:GetCurrent(),
            maxHealth = mount.replica.health:Max(),
            domestication = mount.components.domesticatable:GetDomestication() * 100,
            tendency = mount.tendency,
            obedience = mount.components.domesticatable:GetObedience() * 100,
            buckDelay = CalculateBuckDelay(mount),
            hunger = mount.replica.hunger:GetCurrent(),
            maxHunger = mount.replica.hunger:Max(),
            saddleUses = rider.replica.rider:GetSaddle().components.finiteuses:GetUses()
        }

        rider.player_classified.beefaloData:set(GLOBAL.json.encode(mountData))
        rider:ListenForEvent("healthdelta", rider.player_classified.OnBeefaloHealthDelta, mount)
        rider:ListenForEvent("domesticationdelta", rider.player_classified.OnBeefaloDomesticationDelta, mount)
        rider:ListenForEvent("obediencedelta", rider.player_classified.OnBeefaloObedienceDelta, mount)
        rider:ListenForEvent("hungerdelta", rider.player_classified.OnBeefaloHungerDelta, mount)
    end
end

local function OnDismount(rider, data)
    local mount = data.target
    if mount and mount.prefab == "beefalo" then
        rider.player_classified.beefaloData:set("dismount")
        rider:RemoveEventCallback("healthdelta", rider.player_classified.OnBeefaloHealthDelta, mount)
        rider:RemoveEventCallback("domesticationdelta", rider.player_classified.OnBeefaloDomesticationDelta, mount)
        rider:RemoveEventCallback("obediencedelta", rider.player_classified.OnBeefaloObedienceDelta, mount)
        rider:RemoveEventCallback("hungerdelta", rider.player_classified.OnBeefaloHungerDelta, mount)
    end
end


-- Client handlers

local function OnDataDirty(inst)
    local rawData = inst.beefaloData:value()
    if rawData ~= "dismount" then
        TheStatusBar:Activate(GLOBAL.json.decode(rawData))
    else
        TheStatusBar:Deactivate()
    end
end

local function OnHealthDeltaDirty(inst) 
    TheStatusBar:UpdateHealth(inst.beefaloHealth:value())
end

local function OnDomesticationDeltaDirty(inst)
    local data = GLOBAL.json.decode(inst.beefaloDomestication:value())
    TheStatusBar:UpdateDomestication(data.domestication, data.tendency)
end

local function OnObedienceDeltaDirty(inst) 
    TheStatusBar:UpdateObedience(inst.beefaloObedience:value())
end

local function OnHungerDeltaDirty(inst)
    TheStatusBar:UpdateHunger(inst.beefaloHunger:value())
end

local function RegisterClientNetListeners(owner)
    owner.player_classified:ListenForEvent("beefaloDataDirty", OnDataDirty)
    owner.player_classified:ListenForEvent("beefaloHealthDirty", OnHealthDeltaDirty)
    owner.player_classified:ListenForEvent("beefaloDomesticationDirty", OnDomesticationDeltaDirty)
    owner.player_classified:ListenForEvent("beefaloObedienceDirty", OnObedienceDeltaDirty)
    owner.player_classified:ListenForEvent("beefaloHungerDirty", OnHungerDeltaDirty)
end


-- Network setup

AddPrefabPostInit("player_classified", function(inst)
    inst.beefaloData = GLOBAL.net_string(inst.GUID, "beefaloData", "beefaloDataDirty")
    inst.beefaloHealth = GLOBAL.net_ushortint(inst.GUID, "beefaloHealth", "beefaloHealthDirty")
    inst.beefaloDomestication = GLOBAL.net_string(inst.GUID, "beefaloDomestication", "beefaloDomesticationDirty")
    inst.beefaloObedience = GLOBAL.net_byte(inst.GUID, "beefaloObedience", "beefaloObedienceDirty")
    inst.beefaloHunger = GLOBAL.net_ushortint(inst.GUID, "beefaloHunger", "beefaloHungerDirty")
    
    if GLOBAL.TheWorld.ismastersim then

        inst.OnBeefaloHealthDelta = function(beefalo, data)
            inst.beefaloHealth:set(beefalo.replica.health:GetCurrent())
        end
        
        inst.OnBeefaloDomesticationDelta = function(beefalo, data)
            local domestData = {domestication = beefalo.components.domesticatable:GetDomestication() * 100, tendency = beefalo.tendency}
            inst.beefaloDomestication:set(GLOBAL.json.encode(domestData))
        end
        
        inst.OnBeefaloObedienceDelta = function(beefalo, data)
            inst.beefaloObedience:set(beefalo.components.domesticatable:GetObedience() * 100)
        end
        
        inst.OnBeefaloHungerDelta = function(beefalo, data)
            inst.beefaloHunger:set(beefalo.replica.hunger:GetCurrent())
        end
        

        inst:DoTaskInTime(0.1, function()
            local parent = inst.entity:GetParent()
            -- Events from components/rider.lua
            inst:ListenForEvent("mounted", OnMount, parent)
            inst:ListenForEvent("dismounted", OnDismount, parent)
        end)

    end
end)


-- Configuration and settings

local colors = {
    ORANGE = RGBA(145, 55, 30),
    ORANGE_ALT = RGBA(186, 72, 41),
    BLUE = RGBA(33, 69, 69),
    BLUE_ALT = RGBA(15, 120, 120),
    PURPLE = RGBA(100, 40, 80),
    PURPLE_ALT = RGBA(115, 30, 80),
    RED = RGBA(115, 30, 30),
    RED_ALT = RGBA(150, 25, 25),
    GREEN = RGBA(33, 69, 48),
    GREEN_ALT = RGBA(20, 125, 65),
    WHITE = RGBA(180, 180, 180),
    YELLOW = RGBA(195, 165, 15)
}

local clientConfig = GetModConfigData("ClientConfig", true)

local badgeColors = {
    ORNERY = colors[GetModConfigData("COLOR_DOMESTICATION_ORNERY", clientConfig)],
    RIDER = colors[GetModConfigData("COLOR_DOMESTICATION_RIDER", clientConfig)],
    PUDGY = colors[GetModConfigData("COLOR_DOMESTICATION_PUDGY", clientConfig)],
    DEFAULT = colors[GetModConfigData("COLOR_DOMESTICATION_DEFAULT", clientConfig)],
    OBEDIENCE = colors[GetModConfigData("COLOR_OBEDIENCE", clientConfig)],
    TIMER = colors[GetModConfigData("COLOR_TIMER", clientConfig)]
}

local offsets = {
    -- Offsets X
    offsetX = GetModConfigData("OffsetX", clientConfig),
    offsetXMult = GetModConfigData("OffsetXMult", clientConfig),
    offsetXFine = GetModConfigData("OffsetXFine", clientConfig),
    -- Offsets Y
    offsetY = GetModConfigData("OffsetY", clientConfig),
    offsetYMult = GetModConfigData("OffsetYMult", clientConfig),
    offsetYFine = GetModConfigData("OffsetYFine", clientConfig)
}

local scale = GetModConfigData("Scale", clientConfig)
local scaleOffset = 1 + (scale - 1) / 3


local config = {
    showByDefault = GetModConfigData("ShowByDefault", clientConfig),
    enableSounds = GetModConfigData("EnableSounds", clientConfig),

    theme = GetModConfigData("Theme", clientConfig),
    hungerThreshold = GetModConfigData("HungerThreshold", clientConfig),
    healthClearBG = GetModConfigData("HEALTH_BADGE_CLEAR_BG", clientConfig),
    bgBrightness = GetModConfigData("BADGE_BG_BRIGHTNESS", clientConfig) / 100,
    bgOpacity = GetModConfigData("BADGE_BG_OPACITY", clientConfig) / 100,
    gapModifier = GetModConfigData("GapModifier", clientConfig),
    scale = scale,
    colors = colors,
    badgeColors = badgeColors,
    
    basePositionX = (offsets.offsetX * offsets.offsetXMult) + offsets.offsetXFine,
    basePositionY = (95 * scaleOffset) + (offsets.offsetY * offsets.offsetYMult) + offsets.offsetYFine,

    rootPositionX = 0,
    rootPositionY = 0,
    rootPositionYHidden = -130 / scaleOffset
}


-- Widget setup

AddClassPostConstruct("widgets/controls", function (self, owner)
    local BeefaloStatusBar = require "widgets/beefaloStatusBar"
    self.BeefaloStatusBar = self.bottom_root:AddChild(BeefaloStatusBar(owner, config))
    self.BeefaloStatusBar:MoveToBack()
    TheStatusBar = self.BeefaloStatusBar

    self.owner:DoTaskInTime(0.1, RegisterClientNetListeners)
end)

-- Reposition for integrated backpack
local InventoryBar = require "widgets/inventorybar"
local DefaultRebuild = InventoryBar.Rebuild
function InventoryBar:Rebuild(...)
    -- This also runs once when you load in, even with separated backpack (probably triggered from Inventory:AttachClassified()).
	DefaultRebuild(self, ...)
    TheStatusBar:Reposition()
end


GLOBAL.TheInput:AddKeyDownHandler(GLOBAL[GetModConfigData("ToggleKey", clientConfig)], function ()
    local activeScreen = GLOBAL.TheFrontEnd:GetActiveScreen()
    if GLOBAL.ThePlayer and activeScreen and activeScreen.name == "HUD" and TheStatusBar and TheStatusBar.mounted then
        if TheStatusBar.isHidden then
            TheStatusBar.config.showByDefault = true
            TheStatusBar:SlideIn(0.3)
        else
            TheStatusBar.config.showByDefault = false
            TheStatusBar:SlideOut()
        end
    end
end)