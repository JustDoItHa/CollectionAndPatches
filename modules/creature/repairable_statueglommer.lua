if TUNING.FUNCTIONAL_MEDAL_ENABLE then
    GLOBAL.CONSTRUCTION_PLANS["statueglommer"]={ Ingredient("marble", 3),Ingredient("opalpreciousgem", 1)}
else
    GLOBAL.CONSTRUCTION_PLANS["statueglommer"]={ Ingredient("marble", 3),Ingredient("moonrocknugget", 1)}
end

local function OnConstructed(inst, doer)
    local concluded = true
    for i, v in ipairs(CONSTRUCTION_PLANS[inst.prefab] or {}) do
        if inst.components.constructionsite:GetMaterialCount(v.type) < v.amount then
            concluded = false
            break
        end
    end
    if concluded then
        SpawnPrefab("lucy_ground_transform_fx").Transform:SetPosition(inst.Transform:GetWorldPosition())
        ReplacePrefab(inst, "statueglommer")
    end
end

if TheNet:GetIsServer() then
    AddPrefabPostInit("statueglommer",function (inst)
        inst:AddComponent("constructionsite")
        inst.components.constructionsite:SetConstructionPrefab("construction_container")
        inst.components.constructionsite:SetOnConstructedFn(OnConstructed)
    end)
end