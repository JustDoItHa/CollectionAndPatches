-- 使用的mod名称：快速工作
-- mod链接：https://steamcommunity.com/sharedfiles/filedetails/?id=1200745268
-- mod更新时间：2023 年 4 月 25 日
-- mod作者：柴阿文
local function ChangeAction(action, fn, name)
    if name then
        AddStategraphActionHandler(name, GLOBAL.ActionHandler(action, fn))
    else
        AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(action, fn))
        AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(action, fn))
    end
end

if GetModConfigData("Pick") then
    ChangeAction(GLOBAL.ACTIONS.PICK, "doshortaction")
    ChangeAction(GLOBAL.ACTIONS.PICK, function(inst, action)
        return action.target ~= nil and action.target.components.pickable ~= nil and "doshortaction" or nil
    end, "shadowmaxwell")
    ChangeAction(GLOBAL.ACTIONS.TAKEITEM, "doshortaction")
    ChangeAction(GLOBAL.ACTIONS.HARVEST, "doshortaction")
    ChangeAction(GLOBAL.ACTIONS.PICKUP, function(inst, action)
        return (inst.replica.rider ~= nil and inst.replica.rider:IsRiding() and
                (action.target ~= nil and action.target:HasTag("heavy") and "dodismountaction" or "doshortaction")) or
                "doshortaction"
    end)
end

if GetModConfigData("BuildRepair") then
    ChangeAction(GLOBAL.ACTIONS.BUILD, "doshortaction")
    ChangeAction(GLOBAL.ACTIONS.DECORATEVASE, "doshortaction")
    ChangeAction(GLOBAL.ACTIONS.DRAW, "doshortaction")
    ChangeAction(GLOBAL.ACTIONS.REPAIR, "doshortaction")
    ChangeAction(GLOBAL.ACTIONS.SEW, "doshortaction")
    ChangeAction(GLOBAL.ACTIONS.SMOTHER, "doshortaction")
    ChangeAction(GLOBAL.ACTIONS.MANUALEXTINGUISH, "doshortaction")
    ChangeAction(GLOBAL.ACTIONS.INSTALL, "doshortaction")
    ChangeAction(GLOBAL.ACTIONS.REPLATE, "doshortaction")
    ChangeAction(GLOBAL.ACTIONS.REPAIR_LEAK, "doshortaction")
    ChangeAction(GLOBAL.ACTIONS.OCEAN_TRAWLER_FIX, "doshortaction")
    ChangeAction(GLOBAL.ACTIONS.DISMANTLE, "doshortaction")
    ChangeAction(GLOBAL.ACTIONS.YOTB_SEW, "doshortaction")
    ChangeAction(GLOBAL.ACTIONS.BEDAZZLE, "doshortaction")
    ChangeAction(GLOBAL.ACTIONS.USE_HEAVY_OBSTACLE, "doshortaction")
    ChangeAction(GLOBAL.ACTIONS.DISMANTLE_POCKETWATCH, "doshortaction")
end

if GetModConfigData("HSHU") then
    ChangeAction(GLOBAL.ACTIONS.EAT, function(inst, action)
        if inst.sg:HasStateTag("busy") or inst:HasTag("busy") then
            return
        end
        local obj = action.target or action.invobject
        if obj == nil then
            return
        elseif obj:HasTag("soul") then
            return "quickeat"
        end
        for k, v in pairs(GLOBAL.FOODTYPE) do
            if obj:HasTag("edible_" .. v) then
                return "quickeat"
            end
        end
    end)
    ChangeAction(GLOBAL.ACTIONS.HEAL, "doshortaction")
    ChangeAction(GLOBAL.ACTIONS.TEACH, "doshortaction")
    ChangeAction(GLOBAL.ACTIONS.UPGRADE, "doshortaction")
    ChangeAction(GLOBAL.ACTIONS.ATTUNE, "doshortaction")
    ChangeAction(GLOBAL.ACTIONS.YOTB_UNLOCKSKIN, "doshortaction")
end

if GetModConfigData("Farming") then
    GLOBAL.TUNING.FARM_PLOW_DRILLING_DURATION = 0.1
    ChangeAction(GLOBAL.ACTIONS.PLANTSOIL, "doshortaction")
    ChangeAction(GLOBAL.ACTIONS.ASSESSPLANTHAPPINESS, "doshortaction")
    local function Pour(inst, action)
        return action.invobject ~= nil and (action.invobject:HasTag("wateringcan") and "pour") or "doshortaction"
    end
    ChangeAction(GLOBAL.ACTIONS.POUR_WATER, Pour)
    ChangeAction(GLOBAL.ACTIONS.POUR_WATER_GROUNDTILE, Pour)
    ChangeAction(GLOBAL.ACTIONS.INTERACT_WITH, "doshortaction")
    ChangeAction(GLOBAL.ACTIONS.PLANTREGISTRY_RESEARCH, "doshortaction")
    ChangeAction(GLOBAL.ACTIONS.PLANTREGISTRY_RESEARCH_FAIL, "doshortaction")
    ChangeAction(GLOBAL.ACTIONS.WAX, "doshortaction")
    ChangeAction(GLOBAL.ACTIONS.ADVANCE_TREE_GROWTH, "doshortaction")
end

if GetModConfigData("RapidGrowth") and GetModConfigData("RapidGrowth") ~= 999 then
    local PlantDefs = require("prefabs/farm_plant_defs").PLANT_DEFS
    local WeedDefs = require("prefabs/weed_defs").WEED_DEFS
    local State = {
        seed = true,
        sprout = true,
        small = true,
        med = true
    }
    local function QuickGrow(prefab, isFarmPlant)
        AddPrefabPostInit(prefab, function(inst)
            if inst.components.growable and inst.components.growable.stages then
                local stages = GLOBAL.deepcopy(inst.components.growable.stages)
                for k, v in pairs(stages) do
                    if v.name and State[v.name] then
                        v.time = function(inst, stage_num, stage_data)
                            return 0
                        end
                    end
                end
                inst.components.growable.stages = stages
                if isFarmPlant and GetModConfigData("RapidGrowth") > 1 then
                    inst.force_oversized = true
                end
                inst.components.growable:StartGrowing()
                if isFarmPlant then
                    inst.components.growable:Pause()
                end
            end
        end)
    end
    for k, v in pairs(PlantDefs) do
        if v.prefab then
            QuickGrow(v.prefab, true)
        end
    end
    if GetModConfigData("RapidGrowth") == 1 then
        for k, v in pairs(WeedDefs) do
            if v.prefab then
                QuickGrow(v.prefab, false)
            end
        end
    end
end

if GetModConfigData("Animal") then
    ChangeAction(GLOBAL.ACTIONS.PET, "doshortaction")
    ChangeAction(GLOBAL.ACTIONS.FEED, "doshortaction")
    ChangeAction(GLOBAL.ACTIONS.MURDER, "doshortaction")
    ChangeAction(GLOBAL.ACTIONS.BRUSH, "doshortaction")
    ChangeAction(GLOBAL.ACTIONS.SHAVE, "doshortaction")
    ChangeAction(GLOBAL.ACTIONS.CHECKTRAP, "doshortaction")
    ChangeAction(GLOBAL.ACTIONS.SLAUGHTER, "doshortaction")
    ChangeAction(GLOBAL.ACTIONS.CARNIVALGAME_FEED, function(inst, action)
        return (inst.components.rider ~= nil and inst.components.rider:IsRiding() and "doshortaction") or
                "doequippedaction"
    end)
    ChangeAction(GLOBAL.ACTIONS.COMMUNEWITHSUMMONED, function(inst, action)
        return action.invobject ~= nil and action.invobject:HasTag("abigail_flower") and "commune_with_abigail" or
                "doshortaction"
    end)
    ChangeAction(GLOBAL.ACTIONS.USEITEMON, function(inst, action)
        if action.invobject == nil then
            return "doshortaction"
        elseif action.invobject:HasTag("bell") then
            return "use_beef_bell"
        else
            return "doshortaction"
        end
    end)
    ChangeAction(GLOBAL.ACTIONS.STOPUSINGITEM, "doshortaction")
    ChangeAction(GLOBAL.ACTIONS.RETURN_FOLLOWER, "doshortaction")
end

if GetModConfigData("Others") then
    ChangeAction(GLOBAL.ACTIONS.USEKLAUSSACKKEY, "doshortaction")
    ChangeAction(GLOBAL.ACTIONS.ACTIVATE, "doshortaction")
    ChangeAction(GLOBAL.ACTIONS.FILL, "doshortaction")
    ChangeAction(GLOBAL.ACTIONS.RESETMINE, "doshortaction")
    ChangeAction(GLOBAL.ACTIONS.ABANDON, "doshortaction")
    ChangeAction(GLOBAL.ACTIONS.UNWRAP, "doshortaction")
    ChangeAction(GLOBAL.ACTIONS.TAPTREE, "doshortaction")
    ChangeAction(GLOBAL.ACTIONS.FILL_OCEAN, "doshortaction")
    ChangeAction(GLOBAL.ACTIONS.ERASE_PAPER, "doshortaction")
    ChangeAction(GLOBAL.ACTIONS.TELEPORT, "doshortaction")
    ChangeAction(GLOBAL.ACTIONS.CAST_POCKETWATCH, function(inst, action)
        return action.invobject ~= nil and
                (action.invobject:HasTag("recall_unmarked") and "doshortaction" or
                        action.invobject:HasTag("pocketwatch_warp_casting") and "pocketwatch_warpback_pre" or
                        action.invobject.prefab == "pocketwatch_portal" and "pocketwatch_openportal") or
                "pocketwatch_cast"
    end)
    ChangeAction(GLOBAL.ACTIONS.BREAK, "doshortaction")
    ChangeAction(GLOBAL.ACTIONS.ABANDON_QUEST, "doshortaction")
    ChangeAction(GLOBAL.ACTIONS.HIDEANSEEK_FIND, "doshortaction")
end

if GetModConfigData("ChopTimes") and GetModConfigData("ChopTimes") ~= 999 then

    local settingValue = GetModConfigData("ChopTimes")
    if settingValue == nil then
        settingValue = 999
    elseif settingValue == 0 then
        settingValue = 1
    else
        
    end
    GLOBAL.TUNING.EVERGREEN_CHOPS_SMALL = math.ceil(settingValue * GLOBAL.TUNING.EVERGREEN_CHOPS_SMALL)
    GLOBAL.TUNING.EVERGREEN_CHOPS_NORMAL = math.ceil(settingValue * GLOBAL.TUNING.EVERGREEN_CHOPS_NORMAL)
    GLOBAL.TUNING.EVERGREEN_CHOPS_TALL = math.ceil(settingValue * GLOBAL.TUNING.EVERGREEN_CHOPS_TALL)
    GLOBAL.TUNING.DECIDUOUS_CHOPS_SMALL = math.ceil(settingValue * GLOBAL.TUNING.DECIDUOUS_CHOPS_SMALL)
    GLOBAL.TUNING.DECIDUOUS_CHOPS_NORMAL = math.ceil(settingValue * GLOBAL.TUNING.DECIDUOUS_CHOPS_NORMAL)
    GLOBAL.TUNING.DECIDUOUS_CHOPS_TALL = math.ceil(settingValue * GLOBAL.TUNING.DECIDUOUS_CHOPS_TALL)
    GLOBAL.TUNING.DECIDUOUS_CHOPS_MONSTER = math.ceil(settingValue * GLOBAL.TUNING.DECIDUOUS_CHOPS_MONSTER)
    GLOBAL.TUNING.MUSHTREE_CHOPS_SMALL = math.ceil(settingValue * GLOBAL.TUNING.MUSHTREE_CHOPS_SMALL)
    GLOBAL.TUNING.MUSHTREE_CHOPS_MEDIUM = math.ceil(settingValue * GLOBAL.TUNING.MUSHTREE_CHOPS_MEDIUM)
    GLOBAL.TUNING.MUSHTREE_CHOPS_TALL = math.ceil(settingValue * GLOBAL.TUNING.MUSHTREE_CHOPS_TALL)
    GLOBAL.TUNING.WINTER_TREE_CHOP_SMALL = math.ceil(settingValue * GLOBAL.TUNING.WINTER_TREE_CHOP_SMALL)
    GLOBAL.TUNING.WINTER_TREE_CHOP_NORMAL = math.ceil(settingValue * GLOBAL.TUNING.WINTER_TREE_CHOP_NORMAL)
    GLOBAL.TUNING.WINTER_TREE_CHOP_TALL = math.ceil(settingValue * GLOBAL.TUNING.WINTER_TREE_CHOP_TALL)
    GLOBAL.TUNING.TOADSTOOL_MUSHROOMSPROUT_CHOPS = math.ceil(settingValue * GLOBAL.TUNING.TOADSTOOL_MUSHROOMSPROUT_CHOPS)
    GLOBAL.TUNING.TOADSTOOL_DARK_MUSHROOMSPROUT_CHOPS = math.ceil(settingValue * GLOBAL.TUNING.TOADSTOOL_DARK_MUSHROOMSPROUT_CHOPS)
    GLOBAL.TUNING.DRIFTWOOD_TREE_CHOPS = math.ceil(settingValue * GLOBAL.TUNING.DRIFTWOOD_TREE_CHOPS)
    GLOBAL.TUNING.DRIFTWOOD_SMALL_CHOPS = math.ceil(settingValue * GLOBAL.TUNING.DRIFTWOOD_SMALL_CHOPS)
    GLOBAL.TUNING.MOON_TREE_CHOPS_SMALL = math.ceil(settingValue * GLOBAL.TUNING.MOON_TREE_CHOPS_SMALL)
    GLOBAL.TUNING.MOON_TREE_CHOPS_NORMAL = math.ceil(settingValue * GLOBAL.TUNING.MOON_TREE_CHOPS_NORMAL)
    GLOBAL.TUNING.MOON_TREE_CHOPS_TALL = math.ceil(settingValue * GLOBAL.TUNING.MOON_TREE_CHOPS_TALL)
    local function QuickChop(inst)
        if inst.components.workable then
            inst.components.workable:SetWorkLeft(math.ceil(settingValue * inst.components.workable.workleft))
        end
    end
    AddPrefabPostInit("cave_banana_tree", QuickChop)
    AddPrefabPostInit("marsh_tree", QuickChop)
    AddPrefabPostInit("livingtree", QuickChop)
end

if GetModConfigData("MineTimes") and GetModConfigData("MineTimes") ~= 999 then

    local settingValue = GetModConfigData("MineTimes")
    if settingValue == nil then
        settingValue = 999
    elseif settingValue == 0 then
        settingValue = 1
    else

    end
    GLOBAL.TUNING.ICE_MINE = math.ceil(settingValue *GLOBAL.TUNING.ICE_MINE)
    GLOBAL.TUNING.ROCKS_MINE = math.ceil(settingValue *GLOBAL.TUNING.ROCKS_MINE)
    GLOBAL.TUNING.ROCKS_MINE_MED = math.ceil(settingValue *GLOBAL.TUNING.ROCKS_MINE_MED)
    GLOBAL.TUNING.ROCKS_MINE_LOW = math.ceil(settingValue *GLOBAL.TUNING.ROCKS_MINE_LOW)
    local function QuickMine(inst)
        if inst.components.workable then
            inst.components.workable:SetWorkLeft(math.ceil(settingValue *inst.components.workable.workleft))
        end
    end
    AddPrefabPostInit("archive_props", QuickMine)
    AddPrefabPostInit("marblepillar", QuickMine)
    AddPrefabPostInit("statue_marble", QuickMine)
    AddPrefabPostInit("statueharp", QuickMine)
    AddPrefabPostInit("statueharp_hedgespawner", QuickMine)
    AddPrefabPostInit("statuemaxwell", QuickMine)
    AddPrefabPostInit("ruins_statue_head", QuickMine)
    AddPrefabPostInit("ruins_statue_head_nogem", QuickMine)
    AddPrefabPostInit("ruins_statue_mage", QuickMine)
    AddPrefabPostInit("ruins_statue_mage_nogem", QuickMine)
    GLOBAL.TUNING.MARBLETREE_MINE = math.ceil(settingValue *GLOBAL.TUNING.MARBLETREE_MINE)
    GLOBAL.TUNING.MARBLESHRUB_MINE_SMALL = math.ceil(settingValue *GLOBAL.TUNING.MARBLESHRUB_MINE_SMALL)
    GLOBAL.TUNING.MARBLESHRUB_MINE_NORMAL = math.ceil(settingValue *GLOBAL.TUNING.MARBLESHRUB_MINE_NORMAL)
    GLOBAL.TUNING.MARBLESHRUB_MINE_TALL = math.ceil(settingValue *GLOBAL.TUNING.MARBLESHRUB_MINE_TALL)
    GLOBAL.TUNING.PETRIFIED_TREE_SMALL = math.ceil(settingValue *GLOBAL.TUNING.PETRIFIED_TREE_SMALL)
    GLOBAL.TUNING.PETRIFIED_TREE_NORMAL = math.ceil(settingValue *GLOBAL.TUNING.PETRIFIED_TREE_NORMAL)
    GLOBAL.TUNING.PETRIFIED_TREE_TALL = math.ceil(settingValue *GLOBAL.TUNING.PETRIFIED_TREE_TALL)
    GLOBAL.TUNING.GARGOYLE_MINE = math.ceil(settingValue *GLOBAL.TUNING.GARGOYLE_MINE)
    GLOBAL.TUNING.GARGOYLE_MINE_LOW = math.ceil(settingValue *GLOBAL.TUNING.GARGOYLE_MINE_LOW)
    GLOBAL.TUNING.CAVEIN_BOULDER_MINE = math.ceil(settingValue *GLOBAL.TUNING.CAVEIN_BOULDER_MINE)
    GLOBAL.TUNING.SPILAGMITE_SPAWNER = math.ceil(settingValue *GLOBAL.TUNING.SPILAGMITE_SPAWNER)
    GLOBAL.TUNING.SPILAGMITE_ROCK = math.ceil(settingValue *GLOBAL.TUNING.SPILAGMITE_ROCK)
    GLOBAL.TUNING.SCULPTURE_COVERED_WORK = math.ceil(settingValue *GLOBAL.TUNING.SCULPTURE_COVERED_WORK)
    GLOBAL.TUNING.SEASTACK_MINE = math.ceil(settingValue *GLOBAL.TUNING.SEASTACK_MINE)
    GLOBAL.TUNING.SHELL_CLUSTER_MINE = math.ceil(settingValue *GLOBAL.TUNING.SHELL_CLUSTER_MINE)
    GLOBAL.TUNING.MOONALTAR_ROCKS_MINE = math.ceil(settingValue *GLOBAL.TUNING.MOONALTAR_ROCKS_MINE)
    GLOBAL.TUNING.SALTSTACK_WORK_REQUIRED = math.ceil(settingValue *GLOBAL.TUNING.SALTSTACK_WORK_REQUIRED)
end

if GetModConfigData("Cooking") then
    ChangeAction(GLOBAL.ACTIONS.COOK, "doshortaction")
    ChangeAction(GLOBAL.ACTIONS.SALT, "doshortaction")
end

if GetModConfigData("CookingTime") and GetModConfigData("CookingTime") ~= 999 then
    GLOBAL.TUNING.BASE_COOK_TIME = GetModConfigData("CookingTime") * GLOBAL.TUNING.BASE_COOK_TIME
end

if GetModConfigData("FishTime") and GetModConfigData("FishTime") ~= 999 then
    local function QuickFishing(inst)
        if inst.components.fishingrod then
            inst.components.fishingrod:SetWaitTimes(GetModConfigData("FishTime"), GetModConfigData("FishTime"))
        end
    end
    AddPrefabPostInit("fishingrod", QuickFishing)
end

if GetModConfigData("DryTime") and GetModConfigData("DryTime") ~= 999 then

    if GetModConfigData("DryTime") == 0 then
        GLOBAL.TUNING.DRY_FAST = 0.1
        GLOBAL.TUNING.DRY_MED = 0.1
        GLOBAL.TUNING.DRY_SUPERFAST = 0.1
        GLOBAL.TUNING.DRY_VERYFAST = 0.1
    else
        GLOBAL.TUNING.DRY_FAST = GetModConfigData("DryTime") * GLOBAL.TUNING.DRY_FAST
        GLOBAL.TUNING.DRY_MED = GetModConfigData("DryTime") * GLOBAL.TUNING.DRY_MED
        GLOBAL.TUNING.DRY_SUPERFAST = GetModConfigData("DryTime") * GLOBAL.TUNING.DRY_SUPERFAST
        GLOBAL.TUNING.DRY_VERYFAST = GetModConfigData("DryTime") * GLOBAL.TUNING.DRY_VERYFAST
    end
end