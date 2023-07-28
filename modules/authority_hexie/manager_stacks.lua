local _G = GLOBAL
local TheNet = _G.TheNet
local TheSim = _G.TheSim
local SpawnPrefab = _G.SpawnPrefab
local IsServer = TheNet:GetIsServer() or TheNet:IsDedicated() 

local FOODTYPE = _G.FOODTYPE

-- 物品自动堆叠检测范围
local SEE_ITEM_STACK_DIST = 10

-- 掉落物品自动堆叠
local auto_stack = GetModConfigData("auto_stack")

if auto_stack and IsServer then
    local function AnimPut(item, target) 
        if
            target and target ~= item and target.prefab == item.prefab and item.components.stackable and
                not item.components.stackable:IsFull() and
                target.components.stackable and
                not target.components.stackable:IsFull()
         then
            local start_fx = SpawnPrefab("small_puff")
            start_fx.Transform:SetPosition(target.Transform:GetWorldPosition())
            start_fx.Transform:SetScale(.5, .5, .5)

            item.components.stackable:Put(target)
        end
    end 

    -- 自动堆叠函数(位置，堆叠目标物，堆叠检测半径) 2020.02.16
    function auto_stack_fn(pt, stackbase, radius) 
        local x,y,z = pt:Get() 
        local ents =
            TheSim:FindEntities(
            x,
            y,
            z,
            radius or SEE_ITEM_STACK_DIST,
            {"_inventoryitem"},
            {"INLIMBO", "NOCLICK", "catchable", "fire", "bee"} 
        )

        -- 如果没指定堆叠的目标物则从检测到的物品中选择目标
        if stackbase == nil then 
            for _, objBase in pairs(ents) do
                if
                    objBase:IsValid() and objBase.components.stackable and 
                        not objBase.components.stackable:IsFull() 
                    then
                    for _, obj in pairs(ents) do
                        if obj:IsValid() then 
                            AnimPut(objBase, obj)
                        end
                    end
                end
            end 
        -- 指定了目标(最好是指定了目标，不然周围无关的东西也会一起堆叠)
        else
            for _,obj in pairs(ents) do
                AnimPut(stackbase, obj)
            end
        end
    end

    -- 战利品掉落自动堆叠 2020.02.10 
    AddComponentPostInit(
        "lootdropper",
        function(LootDropper, inst) 
            local old_FlingItem = LootDropper.FlingItem
            function LootDropper:FlingItem(loot, pt) 
                old_FlingItem(LootDropper, loot, pt) 

                local pos = inst:GetPosition() 
                loot:DoTaskInTime(
                    0.5,
                    function(inst)
                        auto_stack_fn(pos, loot)  
                    end
                )
            end
        end
    )

    -- 石果自动堆叠 2020.02.7 
    AddPrefabPostInit(
        "rock_avocado_fruit",
        function(inst) 

            local old_on_mine = inst.components.workable.onwork 

            local function on_mine(inst, miner, workleft, workdone)

                local pos = miner:GetPosition()  --在miner被删除前保存其位置，比如火药

                old_on_mine(inst, miner, workleft, workdone) 

                _G.TheWorld:DoTaskInTime(
                0.5,
                function(inst_1)
                    auto_stack_fn(pos) 
                end)
            end

            inst.components.workable:SetOnWorkCallback(on_mine)
        end
    ) 

    -- 猪王、蚁狮等可交易NPC的交易物品堆叠 2020.02.10
    AddComponentPostInit(
        "trader",
        function(Trader, inst) 
            local old_AcceptGift = Trader.AcceptGift 
            function Trader:AcceptGift(giver, item, count) 
                local ret = old_AcceptGift(Trader, giver, item, count) 
                if ret then 
                    inst:DoTaskInTime(
                        3,
                        function(inst) 
                            local pos = inst:GetPosition() 
                            auto_stack_fn(pos) 
                        end
                    )
                end
                return ret 
            end
        end
    )

    -- 猪人的便便自动堆叠 2020.02.10
    local function poop_auto_stack(pig) 
        local old_OnEat = pig.components.eater.oneatfn 
        local function OnEat(pig, food) 
            foodtype = food.components.edible.foodtype
            old_OnEat(pig, food) 
            if foodtype == FOODTYPE.VEGGIE then 
                pos = pig:GetPosition() 
                auto_stack_fn(pos) 
            end
        end

        pig.components.eater:SetOnEatFn(OnEat)
    end

    AddPrefabPostInit(
        "pigman",
        function(inst)
            poop_auto_stack(inst) 
        end
    )

end
