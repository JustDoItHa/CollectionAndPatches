GLOBAL.setmetatable(env, { __index = function(t, k)
    return GLOBAL.rawget(GLOBAL, k)
end })


--local upvaluehelper = require "utils/upvaluehelp_cap"
--local pond_prefab_file = require "prefabs/pond"
--local zslist = upvaluehelper.Get(pond_prefab_file.SetBackToNormal_Cave, "zslist")
--
--
--AddPrefabPostInit("pond", function(inst)
--    UpvalueHacker.SetUpvalue(inst.components.workable, updatelevel, "updatelevel")
--
--end)
--

local UpvalueHacker = require("tools/upvaluehacker") --Rezecib's upvalue hacker

local function SetBackToNormal_Cave_fix(inst)
    inst.AnimState:PushAnimation("splash_cave", true)
    inst.AnimState:PushAnimation("idle_cave", true)
    inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/small")

    if inst.components.workable then
        inst.components.workable:SetWorkable(false)
    end

    inst.components.childspawner:StartSpawning()
    inst.components.fishable:Unfreeze()

    inst.components.watersource.available = true

    DespawnNitreFormations(inst)
end

--AddPrefabPostInit("pond", function(inst)
--    UpvalueHacker.SetUpvalue(inst.OnLoad, SetBackToNormal_Cave_fix, "SetBackToNormal_Cave")
--end)
--AddPrefabPostInit("pond_mos", function(inst)
--    --UpvalueHacker.SetUpvalue(inst.OnLoad, SetBackToNormal_Cave_fix, "SetBackToNormal_Cave")
--end)
AddPrefabPostInit("pond_cave", function(inst)
    if inst and inst.components and inst.components.acidlevel and inst.components.acidlevel.onstopisacidrainingfn then
        UpvalueHacker.SetUpvalue(inst.components.acidlevel.onstopisacidrainingfn, SetBackToNormal_Cave_fix, "SetBackToNormal_Cave")
        --if inst.components.workable then
        --    inst:AddComponent("workable")
        --end
    end

end)