local _G = GLOBAL
local TheNet = _G.TheNet
local SpawnPrefab = _G.SpawnPrefab
local IsServer = TheNet:GetIsServer() or TheNet:IsDedicated()

local test_mode = GetModConfigData("test_mode")
local admin_option = GetModConfigData("admin_option")
local is_allow_build_near = GetModConfigData("is_allow_build_near")
local near_no_permission = GetModConfigData("near_no_permission")

if IsServer then
    -------------------------- 为安置物（包括作物）加上权限 2021.9.24 --------------------------------------------

    -- 移植作物的数量限制

    --移植作物表
    local plant_deployable_limit_list = {
        dug_grass = "grass",
        dug_berrybush = "berrybush",
        dug_berrybush2 = "berrybush2",
        dug_berrybush_juicy = "berrybush_juicy",
        dug_sapling = "sapling",
		dug_rock_avocado_bush = "rock_avocado_bush"
    }
    local plant_limit_list = {
        grass = 30,
        berrybush = 30,
        berrybush2 = 30,
        berrybush_juicy = 30,
        sapling = 30,
		rock_avocado_bush = 30
    }

    local weak_metatable = {__mode = "k"}

    -- 添加到数量记录表
    local function AddEntToTable(inst)
        local prefab = inst.prefab

        local userid = inst.ownerlist and inst.ownerlist.master

        if plant_limit_list[prefab] and userid then
            -- 记录表
            local stats = _G.TheWorld.__hx_structure_stats or {}

            local user_stats = stats[userid] or {}
            local item_stats = user_stats[prefab] or _G.setmetatable({}, weak_metatable)

            item_stats[inst] = true

            user_stats[prefab] = item_stats
            stats[userid] = user_stats
            _G.TheWorld.__hx_structure_stats = stats
        end
    end

    -- 获取某放置物的数量
    local function GetLimitEntCount(userid, prefab)
        local stats = _G.TheWorld.__hx_structure_stats
        local user_stats = stats and stats[userid]
        local item_stats = user_stats and user_stats[prefab]
        if item_stats == nil then
            return 0
        end
        local sum = 0

        local keys = table.getkeys(item_stats)
        for i, item in ipairs(keys) do
            if item.IsValid and item:IsValid() then
                sum = sum + 1
            else
                item_stats[item] = nil
            end
        end

        return sum
    end

    -- 世界启动时统计已有数量
    AddSimPostInit(
        function(Sim)
            for k, v in pairs(_G.Ents) do
                AddEntToTable(v)
            end
        end
    )

    AddComponentPostInit(
        "deployable",
        function(Deployable)
            local old_Deploy = Deployable.Deploy

            function Deployable:Deploy(pt, deployer, ...)
                if _G.TheWorld.ismastersim == false then
                    return old_Deploy
                end

                local permission_state = _G.TheWorld.guard_authorization[deployer.userid].permission_state -- 玩家的权限状态

                -- 判断安置的权限
                -- 当玩家开启权限模式时才才检查权限范围
                if permission_state then
                    if not is_allow_build_near and not (admin_option and deployer.Network and deployer.Network:IsServerAdmin() and test_mode == false) then
                        if not CheckBuilderScopePermission(deployer, nil, "离别人建筑太近了，我做不到，需要权限！", item_ScopePermission, pt) then
                            return false
                        end
                    end
                end

                --受数量限制的放置
                local inst = self.inst
                local deployable_prefab = inst.prefab
                local target_prefab = plant_deployable_limit_list[deployable_prefab]
                local max_count = plant_limit_list[target_prefab]
                if target_prefab then
                    --判断数量
                    local count = GetLimitEntCount(deployer.userid, target_prefab)
                    if count > max_count then
                        PlayerSay(deployer, ("%s 种植数量已超过 %s, 不能再种了"):format(inst:GetDisplayName(), max_count))
                        return false
                    else
                        PlayerSay(deployer, ("%s 种植数量最多 %s, 还可种 %s 个"):format(inst:GetDisplayName(), max_count, max_count - count))
                    end
                end

                -- 加安置物的权限
                local ret = old_Deploy(Deployable, pt, deployer, ...)
                if ret then
                    --
                    if not inst:HasTag("deployedplant") then
                        local act_pos = pt
                        local prefab = inst.prefab

                        local x, y, z = GetSplitPosition(act_pos)
                        -- 处理墙的坐标
                        if string.find(prefab, "wall_") or string.find(inst.prefab, "fence_") then
                            x = math.floor(x) + .5
                            z = math.floor(z) + .5
                        end
                        -- 安置物为小木牌
                        if string.find(inst.prefab, "minisign") then
                            -- 其他的安置物(不包括作物)
                            local ents = TheSim:FindEntities(x, y, z, 3, nil, {"INLIMBO"}, {"backpack", "sign"}, {"player"})
                            for _, findobj in pairs(ents) do
                                if findobj ~= nil and findobj.ownerlist == nil then
                                    --testActPrint(nil, deployer, findobj, "deploy", "安置物设置权限")
                                    if permission_state == false or (near_no_permission and IsNearPublicEnt(pt)) then
                                        SetOwnerName(findobj, deployer.userid, false)
                                    else
                                        SetItemPermission(findobj, deployer)
                                    end
                                end
                            end
                        else
                            local ents = TheSim:FindEntities(x, y, z, 1, nil, {"INLIMBO"}, nil, {"player"})
                            for _, findobj in pairs(ents) do
                                if findobj ~= nil and findobj.ownerlist == nil then
                                    --testActPrint(nil, deployer, findobj, "deploy", "安置物设置权限")
                                    if permission_state == false or (near_no_permission and IsNearPublicEnt(pt)) then
                                        SetOwnerName(findobj, deployer.userid, false)
                                    else
                                        SetItemPermission(findobj, deployer)
                                    end
                                end
                            end
                        end
                    end
                end

                return ret
            end
        end
    )

    -------------------------- 为树苗变的树和安置的作物加上权限 --------------------------------------------

    --世界收到推送事件后给树加权限,被监听对象在gd_global.lua中 2020.2.3
    AddPrefabPostInit(
        "world",
        function(world)
            --树的权限
            world:ListenForEvent(
                "tree_permission",
                function(inst, data)
                    world:DoTaskInTime(
                        0.1,
                        function()
                            --延迟一会等树生成
                            local x, y, z = data.x, data.y, data.z
                            local ents = TheSim:FindEntities(x, y, z, 1, nil, {"INLIMBO"}, nil, {"player"})
                            for _, findobj in pairs(ents) do
                                if findobj ~= nil and findobj.ownerlist == nil and findobj.components.inventoryitem == nil then
                                    SetItemPermission(findobj, data.master)
                                end
                            end
                        end
                    )
                end
            )

            --作物的权限
            world:ListenForEvent(
                "itemplanted",
                function(inst, data)
                    local x, y, z = data.pos.x, data.pos.y, data.pos.z
                    local deployer = data.doer
                    local permission_state = _G.TheWorld.guard_authorization[deployer.userid].permission_state

                    local ents = TheSim:FindEntities(x, y, z, 1, nil, {"INLIMBO"}, nil, {"player"})
                    for _, findobj in pairs(ents) do
                        if findobj ~= nil and findobj.ownerlist == nil then
                            --testActPrint(nil, deployer, findobj, "deploy", "安置物设置权限")
                            if permission_state == false or (near_no_permission and IsNearPublicEnt(data.pos)) then
                                SetOwnerName(findobj, deployer.userid, false)
                            else
                                SetItemPermission(findobj, deployer)
                            end
                            --将需要限制数量的放置物，添加到数量统计
                            AddEntToTable(findobj)
                        end
                    end
                end
            )
        end
    )

    -------------------------- 为光源添加所有者,防止作祟 --------------------------------------------

    AddComponentPostInit(
        "spellcaster",
        function(SpellCaster, inst)
            -- 判断使用法杖的权限
            local old_CanCast = SpellCaster.CanCast
            function SpellCaster:CanCast(doer, target, pos)
                local caster = doer
                local staff = inst

                -- 对点使用的法杖(唤星者那样的)
                if staff.components.spellcaster.canuseonpoint == true then
                    -- 对目标使用的法杖(传送魔杖那样的)
                    if (CheckItemPermission(caster, target, true) and CheckBuilderScopePermission(caster, nil, GetSayMsg("buildings_spell_cant"), 6, pos) and CheckBuilderScopePermission(caster, nil, GetSayMsg("buildings_spell_cant"), 6, nil)) == false then
                        return false
                    end
                elseif staff.components.spellcaster.canuseontargets == true then
                    if (CheckItemPermission(caster, target, true) and CheckBuilderScopePermission(caster, target, GetSayMsg("buildings_spell_cant"), 6) and CheckBuilderScopePermission(caster, nil, GetSayMsg("buildings_spell_cant"), 6, nil)) == false then
                        PlayerSay(caster, GetSayMsg("buildings_spell_cant"))
                        return false
                    end
                end

                return old_CanCast(SpellCaster, doer, target, pos)
            end

            -- 给光源加权限
            local old_CastSpell = SpellCaster.CastSpell
            function SpellCaster:CastSpell(target, pos)
                old_CastSpell(SpellCaster, target, pos)

                local caster = SpellCaster.inst.components.inventoryitem.owner
                if caster ~= nil and pos ~= nil then
                    local x, y, z = pos:Get()
                    local ents = TheSim:FindEntities(x, y, z, 1, nil, {"INLIMBO"}, nil, {"player"})
                    for _, findobj in pairs(ents) do
                        if findobj ~= nil and findobj.ownerlist == nil then
                            if string.find(findobj.prefab or "", "light") then
                                SetItemPermission(findobj, caster)
                            end
                        end
                    end
                end
            end
        end
    )

    ---------------------------------  重写玩家建造方法  ---------------------------------

    -- 判断建造权限
    AddComponentPostInit(
        "builder",
        function(Builder, inst)
            local old_DoBuild = Builder.DoBuild
            function Builder:DoBuild(recname, pt, rotation, skin)
                if _G.TheWorld.ismastersim == false then
                    return old_DoBuild(Builder, recname, pt, rotation, skin)
                end

                if inst:HasTag("player") then
                    local player = inst
                    local permission_state = _G.TheWorld.guard_authorization[player.userid].permission_state
                    player.build_pos = pt

                    if not table.contains(config_item.cant_build_near_buildings, recname) or permission_state == false then --非建筑或者玩家关闭了自身的权限模式则直接可以建造
                        return old_DoBuild(Builder, recname, pt, rotation, skin)
                    end

                    if not is_allow_build_near then
                        if not CheckBuilderScopePermission(player, nil, "离别人建筑太近了，不能建造，需要权限！", item_ScopePermission, pt) then
                            return false
                        end
                    end
                end

                return old_DoBuild(Builder, recname, pt, rotation, skin)
            end
        end
    )

    -- 重写玩家建造方法
    AddPlayerPostInit(
        function(player)
            if player.components.builder ~= nil then
                -- 建造新的物品，为每个建造的新物品都添加权限
                local old_onBuild = player.components.builder.onBuild
                player.components.builder.onBuild = function(doer, prod)
                    testActPrint(nil, doer, prod, "OnBuild", "建造")
                    local permission_state = _G.TheWorld.guard_authorization[doer.userid].permission_state

                    if old_onBuild ~= nil then
                        old_onBuild(doer, prod)
                    end

                    -- 仓库物品除了背包以外都不需要加Tag
                    if prod and (not prod.components.inventoryitem or prod.components.container) and (permission_state == false or (near_no_permission and IsNearPublicEnt(doer.build_pos))) then
                        SetOwnerName(prod, doer.userid, false)
                    elseif prod and (not prod.components.inventoryitem or prod.components.container) then
                        SetItemPermission(prod, doer)
                    end
                end
            end
        end
    )

    --------------------------右键开解锁--------------------------------------------
    local rightLockTable = {
        "researchlab2", -- 二本
        "chesterchest", -- 切斯特箱子
        "venus_icebox", -- 萝卜冰箱
        "treasurechest",
        "icebox",
        "cellar",
        "dragonflychest",
        "storeroom",-- 地窖
    }

    local function addRightLock(inst)
        local function turnon(inst)
            inst.on = true
            --print("箱子开锁--------------")
            --让物品对所有人可用
            inst.saved_ownerlist = inst.ownerlist
            inst.ownerlist = nil
            inst.components.machine.ison = true
        end

        local function turnoff(inst)
            inst.on = false
            --print("箱子上锁--------------")
            --让物品只有自己能打开
            if inst.saved_ownerlist ~= nil then
                inst.ownerlist = inst.saved_ownerlist
                inst.saved_ownerlist = nil
            end
            -- --移除该物品所有的tag（包括自己的）
            -- if inst.saveTaglist ~= nil then
            -- 	for owner_userid,_ in pairs(inst.saveTaglist) do
            -- 		--print("removeTag----------userid_"..owner_userid)
            -- 		inst:RemoveTag("userid_"..owner_userid)
            -- 	end
            -- 	inst.saveTaglist = nil
            -- end
            -- --只添加自己的tag
            -- if inst.ownerlist ~= nil then
            -- 	for owner_userid,_ in pairs(inst.ownerlist) do
            -- 		inst:AddTag("userid_"..owner_userid)
            -- 		inst.saveTaglist = {}
            -- 		inst.saveTaglist[owner_userid] = 1
            -- 	end
            -- end
            inst.components.machine.ison = false
        end

        if inst.prefab then
            inst:AddComponent("machine")
            inst.components.machine.cooldowntime = 1
            inst.components.machine.turnonfn = turnon
            inst.components.machine.turnofffn = turnoff
        end
    end

    for k, name in pairs(rightLockTable) do
        AddPrefabPostInit(name, addRightLock)
    end

    -----权限保存与加载----
    for k, v in pairs(_G.AllRecipes) do
        local recipename = v.name
        SavePermission(recipename)
    end

    for key, value in pairs(config_item.save_state_table) do
        SavePermission(value)
    end

    for key, value in pairs(config_item.deploys_cant_table) do
        SavePermission(key)
    end

    for key, value in pairs(config_item.winter_trees_table) do
        SavePermission(key)
    end
end
