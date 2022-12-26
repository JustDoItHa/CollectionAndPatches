local num = TUNING.STACK_SIZE_SMALLITEM or 40
AddComponentPostInit("stackable", function(self)
    local old_SetStackSize = self.SetStackSize
    self.SetStackSize = function(self, sz,...)
        if self.inst.prefab == "abigail_williams_psionic_fragments" or self.inst.prefab == "abigail_williams_bowknot_wavepoint" then
            if sz > num then
                sz = num
            end
        end
        return old_SetStackSize and old_SetStackSize(self, sz,...)
    end
end)

if  TheNet:GetIsServer() then--抄自浅诗大佬
    local STACK_RADIUS = 15
    local function FindEntities(x, y, z)
        return TheSim:FindEntities(x, y, z, STACK_RADIUS, {"_stackable"},
        {"INLIMBO", "NOCLICK", "lootpump_oncatch", "lootpump_onflight"})
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
        if inst.components.stackable == nil then return end
        inst.xt_stack_task = inst:DoTaskInTime(.5, function()
            if inst.components.stackable == nil or inst:IsInLimbo() or inst:HasTag("NOCLICK") then return end
            if inst:IsValid() and not inst.components.stackable:IsFull() then
                for _, item in ipairs(FindEntities(inst.Transform:GetWorldPosition())) do
                    if item:IsValid() and not item.components.stackable:IsFull() then Put(inst, item) end
                end
            end
        end)
    end)
    AddPrefabPostInit("abigail_williams_bowknot_wavepoint", function(inst)
        if inst.components.stackable == nil then return end
        inst.xt_stack_task = inst:DoTaskInTime(.5, function()
            if inst.components.stackable == nil or inst:IsInLimbo() or inst:HasTag("NOCLICK") then return end
            if inst:IsValid() and not inst.components.stackable:IsFull() then
                for _, item in ipairs(FindEntities(inst.Transform:GetWorldPosition())) do
                    if item:IsValid() and not item.components.stackable:IsFull() then Put(inst, item) end
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