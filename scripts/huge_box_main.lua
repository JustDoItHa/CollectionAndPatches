---
--- @author zsh in 2023/1/11 3:27
---


GLOBAL.setmetatable(env, { __index = function(_, k)
    return GLOBAL.rawget(GLOBAL, k);
end });

local API = require("huge_box.API");

-- --[[ Show Me ]]
for _, mod in pairs(ModManager.mods) do
    if mod and mod.SHOWME_STRINGS then
        mod.postinitfns.PrefabPostInit._big_box = mod.postinitfns.PrefabPostInit.treasurechest
        mod.postinitfns.PrefabPostInit._big_box_chest = mod.postinitfns.PrefabPostInit.treasurechest
    end
end

--TUNING.MONITOR_CHESTS = TUNING.MONITOR_CHESTS or {}
--TUNING.MONITOR_CHESTS._big_box = true
--TUNING.MONITOR_CHESTS._big_box_chest = true

--PrefabFiles = {
--    "huge_box"
--}
table.insert(PrefabFiles, "huge_box")


--Assets = {
--    Asset("ANIM", "anim/big_box_ui_120.zip"),
--
--    Asset("IMAGE", "images/DLC0002/inventoryimages.tex"),
--    Asset("ATLAS", "images/DLC0002/inventoryimages.xml"),
--
--    Asset("IMAGE", "images/inventoryitems/huge_box/open.tex"),
--    Asset("ATLAS", "images/inventoryitems/huge_box/open.xml"),
--
--    Asset("IMAGE", "images/inventoryitems/huge_box/close.tex"),
--    Asset("ATLAS", "images/inventoryitems/huge_box/close.xml")
--}

table.insert(Assets, Asset("ANIM", "anim/big_box_ui_120.zip"))

table.insert(Assets, Asset("IMAGE", "images/DLC0002/inventoryimages.tex"))
table.insert(Assets, Asset("ATLAS", "images/DLC0002/inventoryimages.xml"))

table.insert(Assets, Asset("IMAGE", "images/inventoryimages/huge_box/open.tex"))
table.insert(Assets, Asset("ATLAS", "images/inventoryimages/huge_box/open.xml"))

table.insert(Assets, Asset("IMAGE", "images/inventoryimages/huge_box/close.tex"))
table.insert(Assets, Asset("ATLAS", "images/inventoryimages/huge_box/close.xml"))



local minimap = {
    -- DLC0002
    "images/DLC0002/inventoryimages.xml"
}

for _, v in ipairs(minimap) do
    AddMinimapAtlas(v);
    table.insert(Assets, Asset("ATLAS", v));
end

TUNING.HUGE_BOX = {
    SET_HUGE_BOX_PRESERVER_VALUE = env.GetModConfigData("SET_HUGE_BOX_PRESERVER_VALUE");
};

local locale = LOC.GetLocaleCode();
local L = (locale == "zh" or locale == "zht" or locale == "zhr") and true or false;

-----------------------------------------------------------------------------------------
STRINGS.NAMES._BIG_BOX = L and "????????????????????" or "Sea box ?? Building";
STRINGS.CHARACTERS.GENERIC.DESCRIBE._BIG_BOX = "?????????????????????????????????????????????";
STRINGS.RECIPE_DESC._BIG_BOX = L and "?????????????????????" or "Take home with you!";

STRINGS.NAMES._BIG_BOX_CHEST = L and "????????????????????" or "Sea case ?? Portable";
STRINGS.CHARACTERS.GENERIC.DESCRIBE._BIG_BOX_CHEST = "?????????????????????????????????????????????";
STRINGS.RECIPE_DESC._BIG_BOX_CHEST = L and "?????????????????????" or "Take home with you!";

-----------------------------------------------------------------------------------------
local Recipes = {};

Recipes[#Recipes + 1] = {
    CanMake = true,
    name = "_big_box_chest",
    ingredients = {
        Ingredient("opalpreciousgem", 1),
        Ingredient("goldnugget", 80),
        Ingredient("pigskin", 40),
        Ingredient("nightmarefuel", 80),
        Ingredient("silk", 80),
        Ingredient("bearger_fur", 5),
        Ingredient("dragon_scales", 5),
        Ingredient("goose_feather", 20),
        Ingredient("minotaurhorn", 2)
    },
    tech = TECH.NONE,
    config = {
        --placer = "huge_box_placer",
        --min_spacing = 2.5,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "images/DLC0002/inventoryimages.xml",
        image = "waterchest.tex"
    },
    filters = {
        "CONTAINERS"
    }
};

for _, v in pairs(Recipes) do
    if v.CanMake ~= false then
        env.AddRecipe2(v.name, v.ingredients, v.tech, v.config, v.filters);
    end
end

-----------------------------------------------------------------------------------------

local custom_actions = {
    ["HUGE_BOX_HAMMER"] = {
        execute = true,
        id = "HUGE_BOX_HAMMER",
        str = "????????????",
        fn = function(act)
            local target, doer = act.target, act.doer;
            if target and doer and target.onhammered then
                target.onhammered(target, doer);
                return true;
            end
        end,
        state = "domediumaction"
    }
}

local component_actions = {
    {
        actiontype = "SCENE",
        component = "huge_box_cmp",
        tests = {
            {
                execute = custom_actions["HUGE_BOX_HAMMER"].execute,
                id = "HUGE_BOX_HAMMER",
                testfn = function(inst, doer, actions, right)
                    return inst and inst:HasTag("huge_box") and right;
                end
            }
        }
    }
}

local old_actions = {}

API.addCustomActions(env, custom_actions, component_actions);
API.modifyOldActions(env, old_actions);

-----------------------------------------------------------------------------------------

if env.GetModConfigData("container_removable") then
    modimport("modmain/huge_box/AUXmods/container_removable.lua");
end
