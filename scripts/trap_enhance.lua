-- 使用的mod名称：Trap Teeth Enhance
-- mod链接：https://steamcommunity.com/sharedfiles/filedetails/?id=2771698903
-- mod更新时间：2019.10.25 下午 11:04
-- mod作者：suqf

-- 使用的mod名称：友好海星
-- mod链接：https://steamcommunity.com/sharedfiles/filedetails/?id=1848385443
-- mod更新时间：2019.09.01 下午 6:39
-- mod作者：辣椒小皇纸

-- 更改范围：仅保留汉化、添加陷阱伤害、耐久、海星陷阱攻击范围
TUNING = GLOBAL.TUNING
IsServer = GLOBAL.TheNet:GetIsServer()

-- 牙齿陷阱耐久
if GetModConfigData("trap_uses") > 0 then
    TUNING.TRAP_TEETH_USES = GetModConfigData("trap_uses")
end
-- 牙齿陷阱伤害
if GetModConfigData("trap_teeth_damage") > 0 then
    TUNING.TRAP_TEETH_DAMAGE = GetModConfigData("trap_teeth_damage")
end
-- 牙齿陷阱可堆叠
if GetModConfigData("stack") and IsServer then
    function stackable(inst)
       if(inst.components.stackable == nil) then
          inst:AddComponent("stackable")
       end
       inst.components.inventoryitem:SetOnDroppedFn(function(inst)
            if inst.components.perishable then
                inst.components.perishable:StopPerishing()
            end
            if inst.sg then
                inst.sg:GoToState("stunned")
            end
            if inst.components.stackable then
                while inst.components.stackable:StackSize() > 1 do
                    local item = inst.components.stackable:Get()
                    if item then
                        if item.components.inventoryitem then
                            item.components.inventoryitem:OnDropped()
                        end
                        item.Physics:Teleport(inst.Transform:GetWorldPosition() )
                    end
                end
             end
        end)
    end
    AddPrefabPostInit("trap_teeth", stackable)
end

if IsServer then
    AddPrefabPostInit("trap_teeth", function(inst)

        -- 狗牙陷阱攻击范围
        inst.components.mine:SetRadius(TUNING.TRAP_TEETH_RADIUS * GetModConfigData("radius"))

        -- 自动重置
        if GetModConfigData("reset") then
            local onexplode = inst.components.mine.onexplode
            inst.components.mine:SetOnExplodeFn(function(inst, target)
                onexplode(inst, target)
                if inst.components.mine then
                    inst:DoTaskInTime(GetModConfigData("time"), function() inst.components.mine:Reset() end )
                end
            end)
        end
    end)
end
----------------------------------------------------------------------------------------------

-- 荆棘陷阱耐久
if GetModConfigData("trap_uses_j") > 0 then
    TUNING.TRAP_BRAMBLE_USES = GetModConfigData("trap_uses_j")
end
-- 荆棘陷阱伤害
if GetModConfigData("trap_bramble_damage") > 0 then
    TUNING.TRAP_BRAMBLE_DAMAGE = GetModConfigData("trap_bramble_damage")
end
-- 荆棘陷阱可堆叠
if GetModConfigData("stack_j") and IsServer then
    function stackable(inst)
       if(inst.components.stackable == nil) then
          inst:AddComponent("stackable")
       end
       inst.components.inventoryitem:SetOnDroppedFn(function(inst)
            if inst.components.perishable then
                inst.components.perishable:StopPerishing()
            end
            if inst.sg then
                inst.sg:GoToState("stunned")
            end
            if inst.components.stackable then
                while inst.components.stackable:StackSize() > 1 do
                    local item = inst.components.stackable:Get()
                    if item then
                        if item.components.inventoryitem then
                            item.components.inventoryitem:OnDropped()
                        end
                        item.Physics:Teleport(inst.Transform:GetWorldPosition() )
                    end
                end
             end
        end)
    end
    AddPrefabPostInit("trap_bramble", stackable)
end

if IsServer then
    AddPrefabPostInit("trap_bramble", function(inst)

        -- 荆棘陷阱攻击范围
        inst.components.mine:SetRadius(TUNING.TRAP_BRAMBLE_RADIUS * GetModConfigData("radius_j"))

        -- 自动重置
        if GetModConfigData("reset_j") then
            local onexplode = inst.components.mine.onexplode
            inst.components.mine:SetOnExplodeFn(function(inst, target)
                onexplode(inst, target)
                if inst.components.mine then
                    inst:DoTaskInTime(GetModConfigData("time_j"), function() inst.components.mine:Reset() end )
                end
            end)
        end
    end)
end

----------------------------------------------------------------------------------------------

local assert = GLOBAL.assert
local debug = GLOBAL.debug

local UpvalueHacker = {}

-- 海星陷阱不攻击玩家
if GetModConfigData("attack_player_h") then
    AddPrefabPostInit("trap_starfish", function(inst)
        if inst.components.mine then
            inst.components.mine:SetAlignment("player")
        end

        local function GetUpvalueHelper(fn, name)
            local i = 1
            while debug.getupvalue(fn, i) and debug.getupvalue(fn, i) ~= name do
                i = i + 1
            end
            local name, value = debug.getupvalue(fn, i)
            return value, i
        end

        UpvalueHacker.GetUpvalue = function(fn, ...)
            local prv, i, prv_var = nil, nil, "(the starting point)"
            for j,var in ipairs({...}) do
                assert(type(fn) == "function", "We were looking for "..var..", but the value before it, "
                    ..prv_var..", wasn't a function (it was a "..type(fn)
                    .."). Here's the full chain: "..table.concat({"(the starting point)", ...}, ", "))
                prv = fn
                prv_var = var
                fn, i = GetUpvalueHelper(fn, var)
            end
            return fn, i, prv
        end

        UpvalueHacker.SetUpvalue = function(start_fn, new_fn, ...)
            local _fn, _fn_i, scope_fn = UpvalueHacker.GetUpvalue(start_fn, ...)
            debug.setupvalue(scope_fn, _fn_i, new_fn)
        end
        
        -- 修复不攻击猪人、鱼人、兔人等
        local mine_test_tags = { "monster", "animal", "pig", "merm" }
        AddPrefabPostInit("world", function(inst)
            UpvalueHacker.SetUpvalue(GLOBAL.Prefabs.trap_starfish.fn, mine_test_tags, "on_explode", "do_snap", "mine_test_tags")
        end)
    end)
end

-- 海星陷阱伤害
if GetModConfigData("trap_starfish_damage") > 0 then
    TUNING.STARFISH_TRAP_DAMAGE = GetModConfigData("trap_starfish_damage")
end
-- 海星陷阱攻击范围
if GetModConfigData("radius_h") > 0 then
    TUNING.STARFISH_TRAP_RADIUS = GetModConfigData("radius_h")
end
-- 海星陷阱重置时间
if GetModConfigData("reset_h") > 0 then
    GLOBAL.TUNING.STARFISH_TRAP_NOTDAY_RESET =
        {
            BASE = GetModConfigData("reset_h"),
            VARIANCE = 2,
        }
end