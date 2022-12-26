for i, k in pairs(ModManager.mods) do
    if k.modname == "workshop-2334209327" then
        k.postinitfns["PrefabPostInit"]["crow"] = nil
        k.postinitfns["PrefabPostInit"]["robin"] = nil
        k.postinitfns["PrefabPostInit"]["robin_winter"] = nil
        k.postinitfns["PrefabPostInit"]["puffin"] = nil
    end
end