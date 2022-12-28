GLOBAL.setmetatable(env, { __index = function(t, k)
    return GLOBAL.rawget(GLOBAL, k)
end })--全局变量

--PrefabFiles = {
--	"venus_icebox",--萝卜冰箱
--}
table.insert(PrefabFiles, "venus_icebox")
--Assets = {
--	--萝卜冰箱音效
--	Asset( "SOUND" , "sound/malibag.fsb" ),
--	Asset( "SOUNDPACKAGE" , "sound/malibag.fev" ),
--
--	--萝卜冰箱
--	Asset("IMAGE", "images/inventoryimages/venus_icebox.tex"),
--	Asset("ATLAS", "images/inventoryimages/venus_icebox.xml"),
--	Asset( "IMAGE", "images/map_icons/venus_icebox.tex" ),
--	Asset( "ATLAS", "images/map_icons/venus_icebox.xml" ),
--
--}
table.insert(Assets, Asset("SOUND", "sound/malibag.fsb"))
table.insert(Assets, Asset("SOUNDPACKAGE", "sound/malibag.fev"))

table.insert(Assets, Asset("IMAGE", "images/inventoryimages/venus_icebox.tex"))
table.insert(Assets, Asset("ATLAS", "images/inventoryimages/venus_icebox.xml"))
table.insert(Assets, Asset("IMAGE", "images/map_icons/venus_icebox.tex"))
table.insert(Assets, Asset("ATLAS", "images/map_icons/venus_icebox.xml"))

local STRINGS = GLOBAL.STRINGS
local require = GLOBAL.require
local FOODTYPE = GLOBAL.FOODTYPE
local FOODGROUP = GLOBAL.FOODGROUP
local Vector3 = GLOBAL.Vector3
local containers = require("containers")
local TECH = GLOBAL.TECH
local TheWorld = GLOBAL.TheWorld--地图

AddMinimapAtlas("images/map_icons/venus_icebox.xml")

STRINGS.NAMES.VENUS_ICEBOX = "萝卜冰箱"
STRINGS.RECIPE_DESC.VENUS_ICEBOX = "16格大小，前4格永久保鲜"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.VENUS_ICEBOX = "这很萝卜"

AddRecipe2("venus_icebox",
        { Ingredient("carrot", 5), Ingredient("gears", 2), Ingredient("cutstone", 5), },
        TECH.SCIENCE_TWO,
        { placer = "venus_icebox_placer", min_spacing = 1, atlas = "images/inventoryimages/venus_icebox.xml", image = "venus_icebox.tex" },
        { "CONTAINERS", "COOKING", "GARDENING" })

local params = {}

local containers_widgetsetup = containers.widgetsetup or function()
    return true
end

function containers.widgetsetup(container, prefab, data, ...)
    local tt = prefab or container.inst.prefab
    if tt == "venus_icebox" then
        local t = params[tt]
        if t ~= nil then
            for k, v in pairs(t) do
                container[k] = v
            end
            container:SetNumSlots(container.widget.slotpos ~= nil and #container.widget.slotpos or 0)
        end
    else
        return containers_widgetsetup(container, prefab, data, ...)
    end
end

params.venus_icebox = {
    widget = {
        slotpos = {},
        animbank = "ui_chester_shadow_3x4",
        animbuild = "UI_Musha_4x4",
        pos = Vector3(-15, 200, 0),
        side_align_tip = 160,
    },
    type = "chest",
}
for y = 3, 0, -1 do
    for x = 0, 3 do
        table.insert(params.venus_icebox.widget.slotpos, Vector3(75 * x - 78, 75 * y - 130, 0))
    end
end

function params.venus_icebox.itemtestfn(container, item, slot)
    if item:HasTag("icebox_valid") then
        return true
    end

    --Perishable
    if not (item:HasTag("fresh") or item:HasTag("stale") or item:HasTag("spoiled")) then
        return false
    end

    --Edible
    for k, v in pairs(FOODTYPE) do
        if item:HasTag("edible_" .. v) then
            return true
        end
    end

    return false
end

for k, v in pairs(params) do
    containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, v.widget.slotpos ~= nil and #v.widget.slotpos or 0)
end




