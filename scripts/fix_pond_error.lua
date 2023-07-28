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

-- local UpvalueHacker = require("tools/upvaluehacker") --Rezecib's upvalue hacker

-- local function DespawnNitreFormations(inst)
--     if inst.nitreformation_ents ~= nil then
--         for i, v in ipairs(inst.nitreformation_ents) do
--             if v:IsValid() then
--                 v:Remove()
--             end
--         end

--         inst.nitreformation_ents = nil
--     end

--     inst.nitreformations = nil
-- end

-- local function SetBackToNormal_Cave_fix(inst)
--     inst.AnimState:PushAnimation("splash_cave", true)
--     inst.AnimState:PushAnimation("idle_cave", true)
--     inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/small")

--     if inst.components.workable then
--         inst.components.workable:SetWorkable(false)
--     end

--     inst.components.childspawner:StartSpawning()
--     inst.components.fishable:Unfreeze()

--     inst.components.watersource.available = true

--     DespawnNitreFormations(inst)
-- end

-- --AddPrefabPostInit("pond", function(inst)
-- --    UpvalueHacker.SetUpvalue(inst.OnLoad, SetBackToNormal_Cave_fix, "SetBackToNormal_Cave")
-- --end)
-- --AddPrefabPostInit("pond_mos", function(inst)
-- --    --UpvalueHacker.SetUpvalue(inst.OnLoad, SetBackToNormal_Cave_fix, "SetBackToNormal_Cave")
-- --end)
-- AddPrefabPostInit("pond_cave", function(inst)
--     if inst and inst.components and inst.components.acidlevel and inst.components.acidlevel.onstopisacidrainingfn then
--         UpvalueHacker.SetUpvalue(inst.components.acidlevel.onstopisacidrainingfn, SetBackToNormal_Cave_fix, "SetBackToNormal_Cave")
--         --if inst.components.workable then
--         --    inst:AddComponent("workable")
--         --end
--     end

-- end)

-- 神话 兼容 原版洞穴池塘 酸雨硝化 设定：洞穴池塘未硝化 有莲花则不会硝化 但洞穴池塘硝化后可以主动种植莲花(出现硝化池塘且有莲花)此时对池塘动作以挖掘硝石优先 挖掘硝石完毕可以铲掉莲花

local upvaluehelper = require "utils/upvaluehelp_cap"
if TheNet:GetIsServer() then

    local Old_RegisterPrefabs = ModManager.RegisterPrefabs
    local function NewRegisterPrefabs(...)
        if GLOBAL.Prefabs["pond_cave"] then
            local OnAcidLevelDelta_Cave = upvaluehelper.Get(GLOBAL.Prefabs["pond_cave"].fn,"OnAcidLevelDelta_Cave")
            if OnAcidLevelDelta_Cave then
                local function newfn(inst, data, ...)
                    if data == nil or inst.components.myth_lotus_grower and inst.components.myth_lotus_grower.crops ~= nil and data.oldpercent < data.newpercent then
                        return
                    end
                    OnAcidLevelDelta_Cave(inst, data, ...)
                end
                local params = upvaluehelper.Set(GLOBAL.Prefabs["pond_cave"].fn,"OnAcidLevelDelta_Cave",newfn)
            end
        end

        Old_RegisterPrefabs(...)
    end
    ModManager.RegisterPrefabs=NewRegisterPrefabs

    local myth_lotus_grower = require("components/myth_lotus_grower")
    local old_myth_lotus_grower_ctor = myth_lotus_grower._ctor

    myth_lotus_grower._ctor = function(self, inst, ...)

        local _ = rawget(self, "_")
        if _ then
            local old_oncrops = _["crops"] and _["crops"][2] 
            if old_oncrops then
                -- local dig_up = upvaluehelper.Get(old_oncrops, "dig_up")

                if inst.prefab == "pond_cave" and inst.components.workable.onfinish then
                    local old_fishable = inst.components.workable.onfinish
                    inst.components.workable.onfinish = function(inst, miner, ...)
                        if inst.components.fishable and inst.components.fishable.frozen then
                            old_fishable(inst, miner, ...)
                            if inst.components.myth_lotus_grower and inst.components.myth_lotus_grower.crops ~= nil then 
                                inst.components.workable:SetWorkAction(ACTIONS.DIG)
                                inst.components.workable:SetWorkLeft(1)
                            end
                        else
                            if inst.components.myth_lotus_grower then
                                inst.components.myth_lotus_grower:DoDigCrop()
                            end
                            -- if dig_up then dig_up(inst, miner, ...) end
                        end
                    end
                end

                _["crops"][2] = function(self,crops)
                    if self.inst.prefab == "pond_cave" then
                        if crops ~= nil then
                            self.inst:RemoveTag("can_plant_lotus")
                            if not self.inst.components.workable then
                                self.inst:AddComponent("workable")
                            end
                            if not (inst.components.fishable and inst.components.fishable.frozen) then
                                self.inst.components.workable:SetWorkAction(ACTIONS.DIG)
                                self.inst.components.workable:SetWorkLeft(1)
                            end
                        else
                            self.inst.components.workable:SetWorkAction(ACTIONS.MINE)
                            self.inst.components.workable:SetWorkLeft(TUNING.ACIDRAIN_BOULDER_WORK)
                            local available = inst.components.fishable and inst.components.fishable.frozen or false
                            self.inst.components.workable:SetWorkable(available)
                            self.inst:AddTag("can_plant_lotus")
                        end

                    else
                        old_oncrops(self,crops)
                    end
                    
                end
            end
        end

        -- addsetter(self, "crops", )
        old_myth_lotus_grower_ctor(self, inst, ...)
    end
end