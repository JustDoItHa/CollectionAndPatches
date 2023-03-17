--鸟的问题 原作者已经 修复
--for i, k in pairs(ModManager.mods) do
--    if k.modname == "workshop-2334209327" then
--        k.postinitfns["PrefabPostInit"]["crow"] = nil
--        k.postinitfns["PrefabPostInit"]["robin"] = nil
--        k.postinitfns["PrefabPostInit"]["robin_winter"] = nil
--        k.postinitfns["PrefabPostInit"]["puffin"] = nil
--    end
--end

--local function tumbleweedPostInit(inst)
--    local function onpickup(inst, picker)
--        local x, y, z = inst.Transform:GetWorldPosition()
--
--        inst:PushEvent("detachchild")
--
--
--        SpawnPrefab("tumbleweedbreakfx").Transform:SetPosition(x, y, z)
--        return true
--    end
--
--    if not _G.TheWorld.ismastersim then
--        return inst
--    end
--
--    inst.components.pickable.onpickedfn = onpickup
--end
--
--AddPrefabPostInit("tumbleweed", tumbleweedPostInit)

TUNING.KYNO_BREWINGRECIPECARD_CHANCE = 0

