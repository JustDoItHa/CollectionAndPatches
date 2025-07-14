--PrefabFiles = {
--	"blackstaff",
--}
--
table.insert(PrefabFiles, "blackstaff")

--Assets = {
--	Asset( "ATLAS", "images/blackstaff.xml" ),
--	Asset("IMAGE", "images/blackstaff.tex"),
--	Asset("ANIM", "anim/blackstaff.zip"),
--	Asset("ANIM", "anim/swap_blackstaff.zip"),
--}
table.insert(Assets, Asset("ATLAS", "images/blackstaff.xml" ))
table.insert(Assets, Asset("IMAGE", "images/blackstaff.tex"))
table.insert(Assets, Asset("ANIM", "anim/blackstaff.zip"))
table.insert(Assets, Asset("ANIM", "anim/swap_blackstaff.zip"))


local RECIPETABS = GLOBAL.RECIPETABS
local Recipe = GLOBAL.Recipe
local Ingredient = GLOBAL.Ingredient
local TECH = GLOBAL.TECH
--local TheWorld = GLOBAL.TheWorld
local ACTIONS = GLOBAL.ACTIONS
local FUELTYPE = GLOBAL.FUELTYPE
local SpawnPrefab = GLOBAL.SpawnPrefab
local require = GLOBAL.require
local STRINGS = GLOBAL.STRINGS

AddPrefabPostInit("blackstaff", function(inst)
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(10)
    inst.components.weapon:SetRange(1.5, 1.5)
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(300)
    inst.components.finiteuses:SetUses(300)
    inst.components.finiteuses:SetOnFinished(inst.Remove)
    inst:AddComponent("tool")
    if inst.components.equippable then
        inst.components.equippable.walkspeedmult = 1
    end
    -- local function onattack(weapon, attacker, target)
    -- if attacker then
    -- if attacker.components.health then
    -- attacker.components.health:DoDelta(0)
    -- end
    -- end
    -- if attacker then
    -- if attacker.components.sanity then
    -- attacker.components.sanity:DoDelta(0)
    -- end
    -- end
    -- end
    -- inst.components.weapon:SetOnAttack(onattack)
end)
if GetModConfigData("blackstaff_make") then
    AddRecipe2("blackstaff",
            { Ingredient("nightmarefuel", 1), Ingredient("twigs", 1) },
            TECH.NONE,
            { atlas = "images/blackstaff.xml", image = "blackstaff.tex" },
            { "TOOLS" }
    )
end

STRINGS.NAMES.BLACKSTAFF = "黑色法杖"
STRINGS.CHARACTERS.GENERIC.BLACKSTAFF = "黑色法杖"
STRINGS.RECIPE_BLACKSTAFF = "黑色法杖"
STRINGS.RECIPE_DESC.BLACKSTAFF = "手动清理垃圾"