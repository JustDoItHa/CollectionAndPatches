GLOBAL.setmetatable(env, { __index = function(t, k)
    return GLOBAL.rawget(GLOBAL, k)
end })

-- [TUNING]--------------------
--TUNING.ROOMCAR_BIGBAG_BAGSIZE = GetModConfigData("BAGSIZE")
--TUNING.ROOMCAR_BIGBAG_LANG = GetModConfigData("LANG")
----TUNING.ROOMCAR_BIGBAG_GIVE = GetModConfigData("GIVE")
--TUNING.ROOMCAR_BIGBAG_STACK = GetModConfigData("STACK")
--TUNING.ROOMCAR_BIGBAG_FRESH = GetModConfigData("FRESH")
--TUNING.ROOMCAR_BIGBAG_KEEPFRESH = GetModConfigData("KEEPFRESH")
--TUNING.ROOMCAR_BIGBAG_LIGHT = GetModConfigData("LIGHT")
--TUNING.ROOMCAR_BIGBAG_RECIPE = GetModConfigData("RECIPE")
--TUNING.ROOMCAR_BIGBAG_WALKSPEED = GetModConfigData("WALKSPEED")
--TUNING.ROOMCAR_BIGBAG_CONTAINERDRAG_SWITCH = GetModConfigData("CONTAINERDRAG_SWITCH")
--TUNING.ROOMCAR_BIGBAG_BAGINBAG = GetModConfigData("BAGINBAG")
--TUNING.ROOMCAR_BIGBAG_HEATROCKTEMPERATURE = GetModConfigData("HEATROCKTEMPERATURE")
--TUNING.ROOMCAR_BIGBAG_WATER = GetModConfigData("BIGBAGWATER")
--TUNING.ROOMCAR_BIGBAG_PICK = GetModConfigData("BIGBAGPICK")
--TUNING.NICE_BIGBAGSIZE = GetModConfigData("NICEBIGBAGSIZE")
table.insert(PrefabFiles, "bigbag")
table.insert(PrefabFiles, "gembigbag")
table.insert(PrefabFiles, "nicebigbag")


--------------------------------------------------------------------------------------------------------------------------
-- [Global Strings]
if TUNING.ROOMCAR_BIGBAG_LANG == 1 then
    GLOBAL.STRINGS.bigbag_BUTTON = "整理"
else
    GLOBAL.STRINGS.bigbag_BUTTON = "Sort"
end

--------------------
local Ingredient = GLOBAL.Ingredient
--------------------------------------------------------------------------------------------------------------------------
-- [Custom Recipe]
--------------------

local tec = GLOBAL.TECH.NONE
local RcpType = TUNING.ROOMCAR_BIGBAG_RECIPE

local RcpPlus = { Ingredient("purplegem", 3) }

local RcpVC = { Ingredient("cutgrass", 1) }
local RcpC = { Ingredient("pigskin", 5) }
local RcpN = { Ingredient("goldnugget", 10), Ingredient("pigskin", 10) }
local RcpE = { Ingredient("goldnugget", 20), Ingredient("pigskin", 10), Ingredient("nightmarefuel", 5) }
local RcpVE = { Ingredient("goldnugget", 40), Ingredient("pigskin", 10), Ingredient("nightmarefuel", 20) }
local RcpVVE = { Ingredient("goldnugget", 80),
                 Ingredient("pigskin", 40),
                 Ingredient("nightmarefuel", 80),
                 Ingredient("silk", 80),
                 Ingredient("bearger_fur", 5),
                 Ingredient("dragon_scales", 5),
                 Ingredient("goose_feather", 20),
                 Ingredient("minotaurhorn", 2) }

local rcp = RcpN

if RcpType == 1 then
    rcp = RcpVC
    tec = GLOBAL.TECH.NONE
elseif RcpType == 2 then
    rcp = RcpC
    tec = GLOBAL.TECH.SCIENCE_ONE
elseif RcpType == 3 then
    rcp = RcpN
    tec = GLOBAL.TECH.SCIENCE_TWO
elseif RcpType == 4 then
    rcp = RcpE
    tec = GLOBAL.TECH.MAGIC_ONE
elseif RcpType == 5 then
    rcp = RcpVE
    tec = GLOBAL.TECH.MAGIC_TWO
elseif RcpType == 6 then
    rcp = RcpVVE
    tec = GLOBAL.TECH.MAGIC_TWO
else
    rcp = RcpN
    tec = GLOBAL.TECH.SCIENCE_TWO
end

if TUNING.ROOMCAR_BIGBAG_FRESH and TUNING.ROOMCAR_BIGBAG_STACK then
    for _, v in ipairs(RcpPlus) do
        table.insert(rcp, v)
    end
end

local bigbag = AddRecipe2("bigbag", rcp,
        tec,
        { atlas = "images/inventoryimages/bigbag.xml", image = "bigbag.tex" },
        { "CONTAINERS" })

local redbigbag = AddRecipe2("redbigbag", -- name
        { Ingredient("bigbag", 1, "images/inventoryimages/bigbag.xml"), Ingredient("redgem", 10) }, -- ingredients Add more like so ,
        tec,
        { atlas = "images/inventoryimages/redbigbag.xml", image = "redbigbag.tex" },
        { "CONTAINERS" })

local bluebigbag = AddRecipe2("bluebigbag", -- name
        { Ingredient("bigbag", 1, "images/inventoryimages/bigbag.xml"), Ingredient("bluegem", 10) }, -- ingredients Add more like so ,
        tec,
        { atlas = "images/inventoryimages/bluebigbag.xml", image = "bluebigbag.tex" },
        { "CONTAINERS" })

local nicebigbag = AddRecipe2("nicebigbag",
        { Ingredient("goldnugget", 40),
          Ingredient("pigskin", 20),
          Ingredient("nightmarefuel", 40),
          Ingredient("silk", 40),
          Ingredient("bearger_fur", 2),
          Ingredient("dragon_scales", 2),
          Ingredient("goose_feather", 10),
          Ingredient("minotaurhorn", 1) },
        tec,
        { atlas = "images/inventoryimages/nicebigbag.xml", image = "nicebigbag.tex" },
        { "CONTAINERS" })
--------------------------------------------------------------------------------------------------------------------------
modimport("scripts/strings_bigbag.lua")
modimport("scripts/bigbag_rpc.lua")
modimport("scripts/bigbag_hook.lua")
modimport("scripts/bigbag_ui.lua")--UI、容器等

require("bigbag_debugcommands")--调试用指令


AddPrefabPostInit("redbigbag", function(inst)

    if not inst.components.insulator then
        inst:AddComponent("insulator")
        inst.components.insulator:SetWinter()
        inst.components.insulator:SetInsulation(500)
    end
end)
AddPrefabPostInit("bluebigbag", function(inst)

    if not inst.components.insulator then
        inst:AddComponent("insulator")
        inst.components.insulator:SetSummer()
        inst.components.insulator:SetInsulation(500)
    end
end) 