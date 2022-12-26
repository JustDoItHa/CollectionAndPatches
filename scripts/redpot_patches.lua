GLOBAL.setmetatable(
    env,
    {
        __index = function(t, k)
            return GLOBAL.rawget(GLOBAL, k)
        end
    }
)

--烹饪锅，MOD本体
local Cookpots = GetModConfigData("Cookpots")
--更多的设置
local Other_item = GetModConfigData("Other_item")
--可以一起使用研磨器
local Professionalchef = GetModConfigData("Professionalchef")
--烹饪速度
local CookingSpeed = GetModConfigData("CookingSpeed")
--自动烹饪
local AutoCook = GetModConfigData("AutoCook")
local cooking = require("cooking")

--Recipe = Class(function(self, name, ingredients, tab, level, placer, min_spacing, nounlock, numtogive, builder_tag, atlas, image, testfn, product)
--Recipe item 配方

local function AddModRecipe(prefab, ingredients, tab, level, ...)
    return AddRecipe(prefab, ingredients, tab, level, nil, nil, nil, nil, nil)
end
---function 函数
local function CanUse(inst)
    if inst:HasTag("mastercookware") then
        inst:RemoveTag("mastercookware")
    end

    if not TheWorld.ismastersim then
        return
    end

    if inst.components.prototyper then
        inst.components.prototyper.restrictedtag = "player"
    end
end

local function CanUse_item(inst)
    if inst:HasTag("mastercookware") then
        inst:RemoveTag("mastercookware")
    end

    if not TheWorld.ismastersim then
        return
    end

    if inst.components.deployable then
        inst.components.deployable.restrictedtag = "player"
    end
end

local function NewOnClose(inst, doer)
    if not inst:HasTag("burnt") then
        if not inst.components.stewer:IsCooking() then
            inst.AnimState:PlayAnimation("idle_empty")
            inst.SoundEmitter:KillSound("snd")
        end
        inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_close")
    end

    if inst.components.stewer and inst.components.stewer:CanCook() then
        local ingredient_prefabs = {}

        for k, v in pairs(inst.components.container.slots) do
            table.insert(ingredient_prefabs, v.prefab)
        end

        local product = cooking.CalculateRecipe(inst.prefab, ingredient_prefabs)

        if product and product ~= "wetgoop" then
            inst.components.stewer:StartCooking(doer)
        end
    end
end

local function AutoCookpot(inst)
    if not TheWorld.ismastersim then
        return
    end

    if inst.components.container then
        inst.components.container.onclosefn = NewOnClose
    end
end

if AutoCook then
    AddPrefabPostInit("portablecookpot", AutoCookpot)
end

if Cookpots then
    AddModRecipe("portablecookpot_item", {Ingredient("goldnugget", 2), Ingredient("charcoal", 6), Ingredient("twigs", 6)}, RECIPETABS.FARM, TECH.NONE)
    AddPrefabPostInit("portablecookpot", CanUse)
    AddPrefabPostInit("portablecookpot_item", CanUse_item)
end

if Other_item then
    AddModRecipe("portableblender_item", {Ingredient("goldnugget", 2), Ingredient("transistor", 2), Ingredient("twigs", 4)}, RECIPETABS.FARM, TECH.NONE)
    AddPrefabPostInit("portableblender", CanUse)
    AddPrefabPostInit("portableblender_item", CanUse_item)

    AddModRecipe("portablespicer_item", {Ingredient("goldnugget", 2), Ingredient("cutstone", 3), Ingredient("twigs", 6)}, RECIPETABS.FARM, TECH.NONE)
    AddPrefabPostInit("portablespicer", CanUse)
    AddPrefabPostInit("portablespicer_item", CanUse_item)
end

--还要什么大厨成就，烹饪锅不香吗？
if CookingSpeed then
    AddPrefabPostInit(
        "portablecookpot",
        function(inst)
            if inst.components.stewer then
                inst.components.stewer.cooktimemult = TUNING.PORTABLE_COOK_POT_TIME_MULTIPLIER * CookingSpeed
            end
        end
    )
end

--All player can use Portablespicer
if Professionalchef then
    AddPlayerPostInit(
        function(inst)
            inst:AddTag("professionalchef")
        end
    )
end
