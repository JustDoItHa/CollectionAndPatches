GLOBAL.setmetatable(env, { __index = function(t, k)
    return GLOBAL.rawget(GLOBAL, k)
end })

AllPlayers = AllPlayers or GLOBAL.AllPlayers
AllRecipes = AllRecipes or GLOBAL.AllRecipes
local upvaluehelper = require "utils/upvaluehelp_cap"
local blueprint_p_file = require "prefabs/blueprint"

local function CanBlueprintRandomRecipe(recipe)
    if recipe.nounlock or recipe.builder_tag ~= nil then
        --Exclude crafting station and character specific
        return false
    end
    local hastech = false
    for k, v in pairs(recipe.level) do
        if v >= 10 then
            --Exclude TECH.LOST
            return false
        elseif v > 0 then
            hastech = true
        end
    end
    --Exclude TECH.NONE
    return hastech
end

local function fn(is_rare)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("blueprint")
    inst.AnimState:SetBuild("blueprint")
    inst.AnimState:PlayAnimation("idle")

    --Sneak these into pristine state for optimization
    inst:AddTag("_named")

    inst:SetPrefabName("blueprint")

    MakeInventoryFloatable(inst, "med", nil, 0.75)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.is_rare = is_rare

    --Remove these tags so that they can be added properly when replicating components below
    inst:RemoveTag("_named")

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:ChangeImageName("blueprint")

    inst:AddComponent("erasablepaper")

    inst:AddComponent("named")
    inst:AddComponent("teacher")
    inst.components.teacher.onteach = OnTeach

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL

    if not is_rare then
        MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
        MakeSmallPropagator(inst)
    else
        inst.AnimState:SetBank("blueprint_rare")
        inst.AnimState:SetBuild("blueprint_rare")
        inst.components.inventoryitem:ChangeImageName("blueprint_rare")
    end

    MakeHauntableLaunch(inst)
    AddHauntableCustomReaction(inst, OnHaunt, true, false, true)

    inst.OnLoad = onload
    inst.OnSave = onsave

    return inst
end

local function MakeAnyBlueprint_local()
    local inst = fn()

    if not TheWorld.ismastersim then
        return inst
    end

    local unknownrecipes = {}
    local knownrecipes = {}
    local allplayers = AllPlayers
    for k, v in pairs(AllRecipes) do
        if IsRecipeValid(v.name) and CanBlueprintRandomRecipe(v) then
            local known = false
            for i, player in ipairs(allplayers) do
                if player.components.builder:KnowsRecipe(v) or
                        not player.components.builder:CanLearn(v.name) then
                    known = true
                    break
                end
            end
            table.insert(known and knownrecipes or unknownrecipes, v)
        end
    end

    inst.recipetouse = (#unknownrecipes > 0 and unknownrecipes[math.random(#unknownrecipes)].name) or
            (#knownrecipes > 0 and knownrecipes[math.random(#knownrecipes)].name) or
            "unknown"
    local test_name = STRINGS.NAMES[string.upper(inst.recipetouse)]

    if test_name == nil then
        return inst
    end

    inst.components.teacher:SetRecipe(inst.recipetouse)
    inst.components.named:SetName(STRINGS.NAMES[string.upper(inst.recipetouse)] .. " " .. STRINGS.NAMES.BLUEPRINT)
    return inst
end

local params = upvaluehelper.Set(blueprint_p_file.fn, "MakeAnyBlueprint", MakeAnyBlueprint_local)
