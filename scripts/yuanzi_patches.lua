
if GetModConfigData("divinetree_no_health") then
    AddPrefabPostInit("divinetree",function(inst)                -- 神树，真无敌
        if inst.components.health then
            inst:RemoveComponent("health")
        end
    end)
end