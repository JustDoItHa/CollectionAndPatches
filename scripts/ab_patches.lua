local num = TUNING.STACK_SIZE_SMALLITEM or 40
AddComponentPostInit("stackable", function(self)
    local old_SetStackSize = self.SetStackSize
    self.SetStackSize = function(self, sz, ...)
        if self.inst.prefab == "abigail_williams_psionic_fragments" or self.inst.prefab == "abigail_williams_bowknot_wavepoint" then
            if sz > num then
                sz = num
            end
        end
        return old_SetStackSize and old_SetStackSize(self, sz, ...)
    end
end)

if TheNet:GetIsServer() then
    --抄自浅诗大佬
    local STACK_RADIUS = 15
    local function FindEntities(x, y, z)
        return TheSim:FindEntities(x, y, z, STACK_RADIUS, { "_stackable" },
                { "INLIMBO", "NOCLICK", "lootpump_oncatch", "lootpump_onflight" })
    end
    local function Put(inst, item)
        if item ~= inst and item.prefab == inst.prefab and item.skinname == inst.skinname then
            SpawnPrefab("sand_puff").Transform:SetPosition(item.Transform:GetWorldPosition())
            inst.components.stackable:Put(item)
        end
    end
    AddComponentPostInit("stackable", function(Stackable)
        local Get = Stackable.Get
        function Stackable:Get(...)
            local instance = Get(self, ...)
            if instance.xt_stack_task then
                instance.xt_stack_task:Cancel()
                instance.xt_stack_task = nil
            end
            return instance
        end
    end)
    AddPrefabPostInit("abigail_williams_psionic_fragments", function(inst)
        if inst.components.stackable == nil then
            return
        end
        inst.xt_stack_task = inst:DoTaskInTime(.5, function()
            if inst.components.stackable == nil or inst:IsInLimbo() or inst:HasTag("NOCLICK") then
                return
            end
            if inst:IsValid() and not inst.components.stackable:IsFull() then
                for _, item in ipairs(FindEntities(inst.Transform:GetWorldPosition())) do
                    if item:IsValid() and not item.components.stackable:IsFull() then
                        Put(inst, item)
                    end
                end
            end
        end)
    end)
    AddPrefabPostInit("abigail_williams_bowknot_wavepoint", function(inst)
        if inst.components.stackable == nil then
            return
        end
        inst.xt_stack_task = inst:DoTaskInTime(.5, function()
            if inst.components.stackable == nil or inst:IsInLimbo() or inst:HasTag("NOCLICK") then
                return
            end
            if inst:IsValid() and not inst.components.stackable:IsFull() then
                for _, item in ipairs(FindEntities(inst.Transform:GetWorldPosition())) do
                    if item:IsValid() and not item.components.stackable:IsFull() then
                        Put(inst, item)
                    end
                end
            end
        end)
    end)
    -- AddPrefabPostInitAny(function(inst)
    --     if inst:HasTag("smallcreature") or inst:HasTag("heavy") or inst:HasTag("trap") or inst:HasTag("NET_workable") then
    --         return
    --     end
    --     if inst.components.stackable == nil or inst:IsInLimbo() or inst:HasTag("NOCLICK") or inst.prefab == "bird_egg" or inst.prefab == "poop" then return end
    --     inst.xt_stack_task = inst:DoTaskInTime(.5, function()
    --         if inst.components.stackable == nil or inst:IsInLimbo() or inst:HasTag("NOCLICK") then return end
    --         if inst:IsValid() and not inst.components.stackable:IsFull() then
    --             for _, item in ipairs(FindEntities(inst.Transform:GetWorldPosition())) do
    --                 if item:IsValid() and not item.components.stackable:IsFull() then Put(inst, item) end
    --             end
    --         end
    --     end)
    -- end)
end

AddComponentPostInit("moisture", function(self)
    local oldDoDelta = self.DoDelta
    function self:DoDelta(...)
        if not self.inst:IsValid() then
            return
        end
        return oldDoDelta(self, ...)
    end
end)

local forbidItem = {
    "一大袋金币",
    "coin_bundle_big",
    "_big_box",
    "_big_box_chest",
    "huge_box",
    "bigbag",
    "bluebigbag",
    "redbigbag",
    "nicebigbag",
    "cherryruins_resonator_item",
    "cherryruins_resonator_item_completed",
    "cherryruins_resonator",
    "wb_strengthen_bindpaper",
    "wb_strengthen_bindpaper_bundle",
    "wb_strengthen_bindpaper_container",
    "wb_strengthen_bindpaper_container",
    "wb_strengthen_cleanpaer",
    "wb_strengthen_increase_1_levelpaper",
    "wb_strengthen_increase_2_levelpaper",
    "wb_strengthen_increase_3_levelpaper",
    "wb_strengthen_increase_4_levelpaper",
    "wb_strengthen_increase_5_levelpaper",
    "wb_strengthen_increase_6_levelpaper",
    "wb_strengthen_increase_7_levelpaper",
    "wb_strengthen_increase_8_levelpaper",
    "wb_strengthen_increase_9_levelpaper",
    "wb_strengthen_increase_10_levelpaper",
    "wb_strengthen_increase_11_levelpaper",
    "wb_strengthen_increase_12_levelpaper",
    "wb_strengthen_strengthen_1_levelpaper",
    "wb_strengthen_strengthen_2_levelpaper",
    "wb_strengthen_strengthen_3_levelpaper",
    "wb_strengthen_strengthen_4_levelpaper",
    "wb_strengthen_strengthen_5_levelpaper",
    "wb_strengthen_strengthen_6_levelpaper",
    "wb_strengthen_strengthen_7_levelpaper",
    "wb_strengthen_strengthen_8_levelpaper",
    "wb_strengthen_strengthen_9_levelpaper",
    "wb_strengthen_strengthen_10_levelpaper",
    "wb_strengthen_strengthen_11_levelpaper",
    "wb_strengthen_strengthen_12_levelpaper",
    "wb_strengthen_increase_next_levelpaper",
    "wb_strengthen_increase_protectpaper",
    "wb_strengthen_strengthen_protectpaper",
    "wb_strengthen_strengthen_food",
    "wb_strengthen_increase_food",
    "myth_plant_infantree_trunk",
}

AddModRPCHandler("ab_recipelist", "ab_recipelist", function(inst, recipename, isproduct, id)
    if IsEntityDeadOrGhost(inst, true) then
        return
    end
    if checknumber(recipename) and recipename == 1 and checkstring(isproduct) and TUNING.AB_CHAONENGQUANXIAN then
        if inst.using_traveler_log and inst.using_traveler_log:IsValid() and inst.using_traveler_log.components.ab_recipelist and
                inst.using_traveler_log.components.ab_recipelist.inventoryitems["abigail_williams_black_gold"] and inst.using_traveler_log.components.ab_recipelist.inventoryitems["abigail_williams_black_gold"] > 0 then
            local new = SpawnPrefab(isproduct)
            local pt = inst:GetPosition()

            local itemForbidden = false
            for k, v in pairs(forbidItem) do
                if isproduct == v then
                    itemForbidden = true
                    break
                end
            end

            if new then
                if not itemForbidden then
                    if new.components.inventoryitem then
                        inst.components.inventory:GiveItem(new, nil, pt)
                    elseif new.Transform then
                        new.Transform:SetPosition(pt:Get())
                    end
                    inst.using_traveler_log.components.ab_recipelist.inventoryitems["abigail_williams_black_gold"] = inst.using_traveler_log.components.ab_recipelist.inventoryitems["abigail_williams_black_gold"] - 1
                else
                    inst.components.talker:Say("这东西不能用这个方式获得哦！")
                end
            else
                inst.components.talker:Say("无效得物品")
            end
            return
        end
        if inst.components.inventory:Has("abigail_williams_black_gold", 1) then
            local new = SpawnPrefab(isproduct)
            local pt = inst:GetPosition()

            local itemForbidden = false
            for k, v in pairs(forbidItem) do
                if isproduct == v then
                    itemForbidden = true
                    break
                end
            end

            if new then
                if not itemForbidden then
                    if new.components.inventoryitem then
                        inst.components.inventory:GiveItem(new, nil, pt)
                    elseif new.Transform then
                        new.Transform:SetPosition(pt:Get())
                    end
                    inst.components.inventory:ConsumeByName("abigail_williams_black_gold", 1)
                else
                    inst.components.talker:Say("这东西不能用这个方式获得哦！")
                end
            else
                inst.components.talker:Say("无效得物品")
            end
            return
        end
        inst.components.talker:Say("缺少材料暗金")
    elseif checknumber(recipename) and recipename == 2 and checkstring(isproduct) and checknumber(id) then
        if inst.using_traveler_log and inst.using_traveler_log:IsValid() then
            inst.using_traveler_log.components.ab_recipelist:ty(isproduct, id == 1, inst)
        end
    elseif inst.using_traveler_log and inst.using_traveler_log:IsValid() and checkstring(recipename)
            and checkbool(isproduct) and inst.using_traveler_log.components.ab_recipelist then
        inst.using_traveler_log.components.ab_recipelist:Build(recipename, inst, isproduct)
    end
end)