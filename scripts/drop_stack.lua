--浅的工具包写法
local STACK_RADIUS = GetModConfigData("auto_stack_range")

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
AddPrefabPostInitAny(function(inst)
    if inst:HasTag("smallcreature") or inst:HasTag("heavy") or inst:HasTag("trap") or inst:HasTag("NET_workable") then
        return
    end
    if inst.components.stackable == nil or inst:IsInLimbo() or inst:HasTag("NOCLICK") then
        return
    end
    inst.xt_stack_task = inst:DoTaskInTime(.5, function()
        local x, y, z = inst.Transform:GetWorldPosition()
        if inst.prefab == "poop" and (TheSim:CountEntities(x, y, z, 30, { "beefalo", "koalefant" }) > 0 or TheSim:CountEntities(x, y, z, 30, { "koalefant" }) > 0) then
            return
        end
        if inst.prefab == "bird_egg" and TheSim:CountEntities(x, y, z, 12, { "penguin" }) > 0 then
            return
        end
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


---------------------------------------------------------------------------------------
---- 使用的mod名称：Auto Stack Pro
---- mod链接：https://steamcommunity.com/sharedfiles/filedetails/?id=2115943953
---- mod更新时间：2022.02.02 上午 3:23
---- mod作者：孤独的根号三
--local _G = GLOBAL
--GLOBAL.setmetatable(env, {__index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end})
--local TheNet = _G.TheNet
--local TheSim = _G.TheSim
--local SpawnPrefab = _G.SpawnPrefab
--local IsServer = TheNet:GetIsServer() or TheNet:IsDedicated()
--local FRAMES = 0.5
--local FOODTYPE = _G.FOODTYPE
--
---- 物品自动堆叠检测范围
--local SEE_ITEM_STACK_DIST = GetModConfigData("auto_stack_range")
---- 猪王/喂鸟/石果/挖矿/砍树等掉落物品自动堆叠
--local auto_stack = true
---- 默认向新的物品堆叠
--local auto_stack_target = true
--
--
--local function _DoTaskInTime(inst,time,x,y,z,prefabs,ents)
--    inst:DoTaskInTime(time, function(inst)
--        local entities = TheSim:FindEntities(x, y, z,
--            SEE_ITEM_STACK_DIST,
--            { "_stackable","_inventoryitem" },
--            { "INLIMBO", "NOCLICK", "catchable", "fire" })
--        for key, value in pairs(entities) do
--            if value and value:IsValid()
--            and table.contains( prefabs, value.prefab)
--            and not table.contains(ents, value) then
--                value:PushEvent('on_loot_dropped', {dropper = inst})
--            end
--        end
--    end)
--end
--
--local function AnimPut(item, target)
--    if target and target:IsValid() and target ~= item and target.prefab == item.prefab and item.components.stackable
--    and not item.components.stackable:IsFull() and target.components.stackable and not target.components.stackable:IsFull() then
--        local start_fx = SpawnPrefab("small_puff")
--        if auto_stack_target then
--            start_fx.Transform:SetPosition(target.Transform:GetWorldPosition())
--            item.components.stackable:Put(target)
--        else
--            start_fx.Transform:SetPosition(item.Transform:GetWorldPosition())
--            target.components.stackable:Put(item)
--        end
--        start_fx.Transform:SetScale(.5, .5, .5)
--    end
--end
--
--AddPrefabPostInitAny(function(inst)
--	if inst.components.stackable == nil or inst.components.inventoryitem == nil then return end
--	inst:ListenForEvent('on_loot_dropped', function(inst)
--		inst:DoTaskInTime(.5, function(inst)
--			if inst and inst:IsValid() and not inst.components.stackable:IsFull() then
--                local x, y, z = inst:GetPosition():Get()
--                local entities = TheSim:FindEntities(x, y, z, SEE_ITEM_STACK_DIST, { "_stackable","_inventoryitem" }, { "INLIMBO", "NOCLICK", "catchable", "fire" })
--                for key, value in pairs(entities) do
--                    AnimPut(inst,value)
--				end
--			end
--		end)
--	end)
--end)
--
--if auto_stack and IsServer then
--    local LootDropper = _G.require("components/lootdropper")
--    local old_FlingItem = LootDropper.FlingItem
--	-- 掉落物品自动堆叠
--	function LootDropper:FlingItem(loot, pt, bouncedcb)
--        if loot ~= nil and loot:IsValid() then
--            if self.inst:IsValid() or pt ~= nil then
--                old_FlingItem(self, loot, pt, bouncedcb)
--
--                loot:DoTaskInTime(0.5, function(inst)
--                    if inst:IsValid() then
--                        local pos = inst:GetPosition()
--                        local x, y, z = pos:Get()
--                        local ents = TheSim:FindEntities(x, y, z, SEE_ITEM_STACK_DIST, { "_stackable","_inventoryitem" }, { "INLIMBO", "NOCLICK", "catchable", "fire" })
--                        for _,obj in pairs(ents) do
--                            AnimPut(loot, obj)
--                        end
--                    end
--                end)
--            end
--        end
--	end
--
--    --鱼人王给予物品自动堆叠
--    AddPrefabPostInit("mermking", function(inst)
--        local old_onaccept = inst.components.trader.onaccept
--        inst.components.trader.onaccept = function(inst, giver, item)
--            if old_onaccept ~= nil then old_onaccept(inst, giver, item) end
--
--            inst:DoTaskInTime(2, function(inst)
--                local pos = inst:GetPosition()
--                local x, y, z = pos:Get()
--                local ents = TheSim:FindEntities(x, y, z, SEE_ITEM_STACK_DIST, { "_inventoryitem" }, { "INLIMBO", "NOCLICK", "catchable", "fire" })
--                for _,objBase in pairs(ents) do
--                    -- objBase.replica.inventoryitem.classified ~= nil
--                    if objBase:IsValid() and objBase.components.stackable and not objBase.components.stackable:IsFull() then
--                        for _,obj in pairs(ents) do
--                            if obj:IsValid() then
--                                AnimPut(objBase, obj)
--                            end
--                        end
--                    end
--                end
--            end)
--        end
--    end)
--
--    -- 猪王给予物品自动堆叠
--    AddPrefabPostInit("pigking", function(inst)
--        local old_onaccept = inst.components.trader.onaccept
--        inst.components.trader.onaccept = function(inst, giver, item)
--            if old_onaccept ~= nil then old_onaccept(inst, giver, item) end
--
--            inst:DoTaskInTime(2, function(inst)
--                local pos = inst:GetPosition()
--                local x, y, z = pos:Get()
--                local ents = TheSim:FindEntities(x, y, z, SEE_ITEM_STACK_DIST, { "_stackable","_inventoryitem" }, { "INLIMBO", "NOCLICK", "catchable", "fire" })
--                for _,objBase in pairs(ents) do
--                    -- objBase.replica.inventoryitem.classified ~= nil
--                    if objBase:IsValid() and objBase.components.stackable and not objBase.components.stackable:IsFull() then
--                        for _,obj in pairs(ents) do
--                            if obj:IsValid() then
--                                AnimPut(objBase, obj)
--                            end
--                        end
--                    end
--                end
--            end)
--        end
--    end)
--
--    -- 石果自动堆叠
--    AddPrefabPostInit('rock_avocado_fruit', function(inst)
--        if inst.components.workable == nil then return end
--        local old_onwork = inst.components.workable.onwork
--        inst.components.workable.onwork = function(inst, worker, workleft, numworks)
--            if old_onwork then
--                --local x, y, z = inst.Transform:GetWorldPosition()
--                local x, y, z = inst:GetPosition():Get()
--                old_onwork(inst, worker, workleft, numworks)
--                inst:DoTaskInTime(0.5, function(inst)
--                    local entities = TheSim:FindEntities(x, y, z, SEE_ITEM_STACK_DIST, { "_stackable","_inventoryitem" }, { "INLIMBO", "NOCLICK", "catchable", "fire" })
--                    for key, value in pairs(entities) do
--                        if value and value:IsValid() and table.contains( {'rock_avocado_fruit_ripe', 'rock_avocado_fruit_sprout', 'rocks'}, value.prefab) and not table.contains(ents, value) then
--                            value:PushEvent('on_loot_dropped', {dropper = inst})
--                        end
--                    end
--                end)
--            end
--        end
--    end)
--    -- 疯猪的屎自动堆叠
--    local function OnEat(inst, food)
--        if food.components.edible ~= nil then
--            if food.components.edible.foodtype == FOODTYPE.VEGGIE then
--                local poop = SpawnPrefab("poop")
--                local pos = inst:GetPosition()
--                local x, y, z = pos:Get()
--                poop.Transform:SetPosition(inst.Transform:GetWorldPosition())
--                local ents = TheSim:FindEntities(x, y, z, SEE_ITEM_STACK_DIST, { "_stackable","_inventoryitem" }, { "INLIMBO", "NOCLICK", "catchable", "fire" })
--                for _,obj in pairs(ents) do
--                    AnimPut(poop, obj)
--                end
--            elseif food.components.edible.foodtype == FOODTYPE.MEAT and
--                inst.components.werebeast ~= nil and
--                not inst.components.werebeast:IsInWereState() and
--                food.components.edible:GetHealth(inst) < 0 then
--                inst.components.werebeast:TriggerDelta(1)
--            end
--        end
--    end
--
--    AddPrefabPostInit("pigman", function(inst)
--        inst.components.eater:SetOnEatFn(OnEat)
--	end)
--
--    AddPrefabPostInit("pigguard", function(inst)
--        inst.components.eater:SetOnEatFn(OnEat)
--    end)
--
--    AddComponentPostInit('beard', function(self, inst)
--        local old_shave = self.Shave
--        self.Shave = function(self, who, withwhat)
--            local x, y, z = inst.Transform:GetWorldPosition()
--            local ents = TheSim:FindEntities(x, y, z, SEE_ITEM_STACK_DIST, { "_stackable","_inventoryitem" }, { "INLIMBO", "NOCLICK", "catchable", "fire" })
--            local bool = old_shave(self, who, withwhat)
--            if bool and self.prize then
--                _DoTaskInTime(inst,0.5,x,y,z, {self.prize},ents)
--            end
--            return bool
--        end
--    end)
--    AddComponentPostInit('terraformer', function(self, inst)
--        local GroundTiles = require("worldtiledefs")
--        local old_terraform = self.Terraform
--        self.Terraform = function(self, pt)
--            local x, y, z = inst.Transform:GetWorldPosition()
--            local ents = TheSim:FindEntities(x, y, z, SEE_ITEM_STACK_DIST, { "_stackable","_inventoryitem" }, { "INLIMBO", "NOCLICK", "catchable", "fire" })
--            local original_tile_type = TheWorld.Map:GetTileAtPoint(pt:Get())
--            local bool = old_terraform(self, pt)
--            if bool then
--                local spawnturf = GroundTiles.turf[original_tile_type]
--                if spawnturf ~= nil then
--                    _DoTaskInTime(inst,0.5,x,y,z,{'turf_' .. spawnturf.name},ents)
--                end
--            end
--            return bool
--        end
--    end)
--end