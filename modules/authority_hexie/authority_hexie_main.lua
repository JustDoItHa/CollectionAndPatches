---此Mod由RedPig的小红猪防熊锁重做而来---
---By GuardAngelY---2017-01-11
---By 秋水、Flynn---2019-04-16
--GLOBAL.require "debugtools"
local _G = GLOBAL
local TheSim = _G.TheSim
local TheNet = _G.TheNet

local IsServer = TheNet:GetIsServer() or TheNet:IsDedicated()
local EQUIPSLOTS = _G.EQUIPSLOTS 

if IsServer then
    modimport("modules/authority_hexie/gd_global.lua")
    modimport("modules/authority_hexie/manager_players.lua")
    modimport("modules/authority_hexie/manager_walls.lua")
    modimport("modules/authority_hexie/manager_beefalos.lua")
    modimport("modules/authority_hexie/manager_others.lua")
    modimport("modules/authority_hexie/manager_permission.lua")
    --- modimport("modules/authority_hexie/manager_stacks.lua")
    modimport("modules/authority_hexie/manager_shelters.lua")
    --- modimport("modules/authority_hexie/manager_clean.lua")
    --- modimport("modules/authority_hexie/player_start.lua")
    -- modimport("modules/authority_hexie/gd_mods.lua")
    -- modimport("modules/authority_hexie/item_show.lua")
    modimport("modules/authority_hexie/gd_speech.lua")

    local test_mode = GetModConfigData("test_mode")
    local admin_option = GetModConfigData("admin_option")
    local is_allow_build_near = GetModConfigData("is_allow_build_near")
    local near_no_permission = GetModConfigData("near_no_permission")
    local cant_destroyby_monster = GetModConfigData("cant_destroyby_monster")

    --完整远古祭坛防拆毁
    local ancient_altar_no_destroy = GetModConfigData("ancient_altar_no_destroy")
    -- 防止玩家破坏野外猪人房兔人房
    local house_plain_nodestroy = GetModConfigData("house_plain_nodestroy")
	--防止完整蜘蛛巢穴拆毁
    local zhizhu_cuihui = GetModConfigData("zhizhu_cuihui")
    -- 掉落物品自动堆叠
    --local auto_stack = GetModConfigData("auto_stack")
    -- 物品范围权限
    local item_ScopePermission = 12

    -- 为重要地点实体添加tag 2020.4.3
    if near_no_permission == true then
		for k, v in pairs(config_item.item_clear_auto) do
			AddPrefabPostInit(
                v, 
                function(inst)
                    inst:AddTag("public_ent") 
                end           
            )
		end
	end

    --玩家下线或者跳世界强制掉落无权使用的背包
    AddComponentPostInit(
        "playerspawner",
        function(PlayerSpawner, inst)
            --玩家跳世界
            inst:ListenForEvent(
                "ms_playerdespawnandmigrate",
                function(inst, data)
                    player = data.player

                    --掉落
                    if player and player.components.inventory then
                        if player.components.inventory:EquipHasTag("backpack") then
                            equip_items =
                                FindEquipItems(
                                player,
                                function(m_inst)
                                    return m_inst:HasTag("backpack")
                                end
                            )

                            if #equip_items >= 1 then
                                for k, v in pairs(equip_items) do
                                    --无使用权限则掉落
                                    if CheckItemPermission(player, v, true) then
                                        return true
                                    else
                                        player.components.inventory:DropItem(v)
                                    end
                                end
                            end
                        end
                    end
                end
            )

            --玩家下线
            inst:ListenForEvent(
                "ms_playerdespawn",
                function(inst, player)
                    --player = data.player

                    --掉落
                    if player and player.components.inventory then
                        if player.components.inventory:EquipHasTag("backpack") then
                            equip_items =
                                FindEquipItems(
                                player,
                                function(m_inst)
                                    return m_inst:HasTag("backpack")
                                end
                            )

                            if #equip_items >= 1 then
                                for k, v in pairs(equip_items) do
                                    --无使用权限则掉落
                                    if CheckItemPermission(player, v, true) then
                                        return true
                                    else
                                        player.components.inventory:DropItem(v)
                                    end
                                end
                            end
                        end
                    end
                end
            )
        end
    )
    
    --用晾肉架
    local old_DRY = _G.ACTIONS.DRY.fn
    _G.ACTIONS.DRY.fn = function(act)
        testActPrint(act)
        --_G.dumptable(act, 1, 10)
        if _G.TheWorld.ismastersim == false then
            return old_DRY(act)
        end
        --print(act.doer.name.."--dry--"..GetItemOldName(act.target))

        act.doer:DoTaskInTime(
            0,
            function()
                SetItemPermission(act.target, nil, act.doer)
            end
        )
        return old_DRY(act)
    end

    --防采肉架上的肉干和蜂箱蜂蜜
    local old_HARVEST = _G.ACTIONS.HARVEST.fn
    _G.ACTIONS.HARVEST.fn = function(act)
        testActPrint(act)

        -- 有权限时直接处理
        if
            CheckItemPermission(act.doer, act.target, nil, true) or act.target.prefab == "cookpot" or
                act.target:HasTag("readyforharvest") or
                act.target:HasTag("rotten") or
                act.target:HasTag("withered")
         then --锅里的东西和已经长好/腐烂/枯萎的农作物
            return old_HARVEST(act)
        elseif
            act.target == nil or (act.target.ownerlist == nil and true or act.target.ownerlist.master == nil) or
                tablelength(act.target.ownerlist) == 0 or
                act.doer:HasTag("player") == false
         then
            -- 不存在权限则判断周围建筑物
            if CheckBuilderScopePermission(act.doer, act.target, GetSayMsg("buildings_get_cant")) then
                return old_HARVEST(act)
            end
        elseif act.doer:HasTag("player") then
            -- 主人不为自己并且物品受权限控制
            local doer_num = GetPlayerIndex(act.doer.userid)
            local master = act.target.ownerlist and GetPlayerById(act.target.ownerlist.master) or nil
            if master ~= nil then
                PlayerSay(act.doer, GetSayMsg("item_get_cant", master.name, GetItemOldName(act.target)))
                PlayerSay(master, GetSayMsg("item_get", act.doer.name, GetItemOldName(act.target), doer_num))
            else
                PlayerSay(act.doer, GetSayMsg("player_leaved", GetPlayerNameByOwnerlist(act.target.ownerlist)))
            end
        end

        return false
    end

    --能被允许所有人采摘的作物(自行编辑) 2020.2.1
    local allow_pick = {"reeds","flower_cave","flower_cave_double","flower_cave_triple","cave_banana_tree","cactus","oasis_cactus","wormlight_plant","lichen",} 

    --有权限才能采摘的作物(自行编辑) 2020.2.1
    local permission_pick = {}

    --防止玩家采别人东西(草/树枝/浆果/花)
    local old_PICK = _G.ACTIONS.PICK.fn
    _G.ACTIONS.PICK.fn = function(act)
        testActPrint(act)

        --上面表中的作物直接允许 2020.2.1
        if act.target and (table.contains(allow_pick, act.target.prefab) == true) then 
            return old_PICK(act)
        end

        if (act.target and string.find(act.target.prefab, "flower")) or (act.target and (table.contains(permission_pick, act.target.prefab) == true)) then 
            -- 有权限时直接处理
            if CheckItemPermission(act.doer, act.target) then
                return old_PICK(act)
            elseif
                act.target == nil or act.target.ownerlist == nil or tablelength(act.target.ownerlist) == 0 or
                    act.doer:HasTag("player") == false
             then
                -- 不存在权限则判断周围建筑物
                --if CheckBuilderScopePermission(act.doer, act.target, GetSayMsg("buildings_pick_cant")) then return old_PICK(act) end
                return old_PICK(act)
            elseif act.doer:HasTag("player") then
                -- 主人不为自己并且物品受权限控制
                local doer_num = GetPlayerIndex(act.doer.userid)
                local master = act.target.ownerlist and GetPlayerById(act.target.ownerlist.master) or nil
                if master ~= nil then
                    PlayerSay(act.doer, GetSayMsg("item_pick_cant", master.name, GetItemOldName(act.target)))
                    PlayerSay(master, GetSayMsg("item_pick", act.doer.name, GetItemOldName(act.target), doer_num))
                else
                    PlayerSay(act.doer, GetSayMsg("player_leaved", GetPlayerNameByOwnerlist(act.target.ownerlist)))
                end
            end

            return false
        end

        return old_PICK(act)
    end

    --防止玩家拿别人陷阱(狗牙/捕鸟器/蜜蜂地雷)
    local old_PICKUP = _G.ACTIONS.PICKUP.fn
    _G.ACTIONS.PICKUP.fn = function(act)
        testActPrint(act)

        --防偷(狗牙/捕鸟器/蜜蜂地雷) - 暂时只防狗牙被偷
        if act.target and (act.target.prefab == "trap_teeth") then
            -- 有权限时直接处理
            if CheckItemPermission(act.doer, act.target, true) then
                return old_PICKUP(act)
            elseif act.doer:HasTag("player") then
                -- 主人不为自己并且物品受权限控制
                local doer_num = GetPlayerIndex(act.doer.userid)
                local master = act.target.ownerlist and GetPlayerById(act.target.ownerlist.master) or nil
                if master ~= nil then
                    PlayerSay(act.doer, GetSayMsg("item_get_cant", master.name, GetItemOldName(act.target)))
                    PlayerSay(master, GetSayMsg("item_get", act.doer.name, GetItemOldName(act.target), doer_num))
                else
                    PlayerSay(act.doer, GetSayMsg("player_leaved", GetPlayerNameByOwnerlist(act.target.ownerlist)))
                end
            end

            return false
        end 

        return old_PICKUP(act)
    end

    --防止玩家重置别人陷阱(狗牙)
    local old_RESETMINE = _G.ACTIONS.RESETMINE.fn
    _G.ACTIONS.RESETMINE.fn = function(act)
        testActPrint(act)

        --防重置(狗牙)
        -- or act.target.prefab == "beemine" or act.target.prefab == "birdtrap"
        if act.target and (act.target.prefab == "trap_teeth") then
            -- 有权限时直接处理
            if CheckItemPermission(act.doer, act.target, true) then
                return old_RESETMINE(act)
            elseif act.doer:HasTag("player") then
                -- 主人不为自己并且物品受权限控制
                local doer_num = GetPlayerIndex(act.doer.userid)
                local master = act.target.ownerlist and GetPlayerById(act.target.ownerlist.master) or nil
                if master ~= nil then
                    PlayerSay(act.doer, GetSayMsg("permission_no", master.name, GetItemOldName(act.target)))
                    PlayerSay(master, GetSayMsg("item_use", act.doer.name, GetItemOldName(act.target), doer_num))
                else
                    PlayerSay(act.doer, GetSayMsg("player_leaved", GetPlayerNameByOwnerlist(act.target.ownerlist)))
                end
            end

            return false
        end

        return old_RESETMINE(act)
    end 

    -- 挖、铲、砸、砍的权限与防止怪物摧毁 2020.02.14
    AddComponentPostInit(
        "workable",
        function(Workable, inst) 
            local old_WorkedBy = Workable.WorkedBy 
            function Workable:WorkedBy(worker, numworks) 
                local workaction = inst.components.workable:GetWorkAction()       
                local doer_num = worker:HasTag("player") and GetPlayerIndex(worker.userid) or nil 
                local owner = inst.ownerlist and GetPlayerById(inst.ownerlist.master) or nil 

                -- 船沉了则摧毁船上的物品
                if worker ~= nil and worker.prefab == "boat" then 
                    old_WorkedBy(Workable, worker, numworks)
                -- 砍树的权限 
                elseif workaction ~= nil and workaction == _G.ACTIONS.CHOP then 
                    
                    -- 有权限则直接执行，没权限则判断周围属于同一个人的树桩和树的总量是否有达到4
                    if 
                        CheckItemPermission(worker, inst, true) 
                        or (inst.ownerlist ~= nil and Get_near_tree_num(inst) < 4) 
                        or not worker:HasTag("player") 
                        then 
                        old_WorkedBy(Workable, worker, numworks)                       
                    else
                        if owner ~= nil and doer_num ~= nil then 
                            PlayerSay(worker, GetSayMsg("trees_chop_cant", owner.name, GetItemOldName(inst)))
                            PlayerSay(owner, GetSayMsg("item_chop", worker.name, GetItemOldName(inst), doer_num)) 
                        else
                            PlayerSay(worker, GetSayMsg("trees_chop_cant")) 
                        end        
                    end
                    
                -- 开采的权限 
                elseif workaction ~= nil and workaction == _G.ACTIONS.MINE then 

                    -- 有权限则直接执行
                    if CheckItemPermission(worker, inst, true) then 
                          -- 检查野外蜘蛛房屋权限
                        if CheckShelterPermission(inst, worker) then
                            old_WorkedBy(Workable, worker, numworks) 
                        -- else
                        --     PlayerSay(worker, GetSayMsg("noadmin_hammer_cant", GetItemOldName(inst)))
                        end 
                    else                        
                        if owner ~= nil and doer_num ~= nil then 
                            PlayerSay(worker, GetSayMsg("item_pick_cant", owner.name, GetItemOldName(inst)))
                            PlayerSay(owner, GetSayMsg("item_pick", worker.name, GetItemOldName(inst), doer_num)) 
                        else
                            PlayerSay(worker, GetSayMsg("player_leaved")) 
                        end        
                    end

                -- 砸的权限 
                elseif workaction ~= nil and workaction == _G.ACTIONS.HAMMER then 

                    -- 怪物破坏
                    if not worker:HasTag("player") then 
                        -- 未开启防止怪物破环则怪物可直接破坏     
                        if not cant_destroyby_monster and not table.contains(walls_table, inst.prefab or "") then 
                            -- 检查野外房屋权限
                            if CheckShelterPermission(inst, worker) then
                                old_WorkedBy(Workable, worker, numworks) 
                            end
                        -- 墙未设置怪物不可摧毁则怪物可直接破坏
                        elseif table.contains(walls_table, inst.prefab or "") and CheckWallActionPermission(inst, 2) then 
                            old_WorkedBy(Workable, worker, numworks) 
                        end
                    -- 墙的权限另外处理 
                    elseif table.contains(walls_table, inst.prefab or "") then 
                        -- 墙未开启保护则直接可以砸
                        if CheckWallActionPermission(inst, 1) then 
                            old_WorkedBy(Workable, worker, numworks) 
                        -- 墙受保护则有权限才可砸，用砸的方式改变墙的高度
                        elseif 
                            CheckWallActionPermission(inst, 1) == false 
                            and string.find(inst.prefab, "wall_") 
                            and CheckItemPermission(worker, inst, true) 
                            and inst.ownerlist ~= nil 
                            then 
                            if inst.components.health:GetPercent() == 0 then 
                                old_WorkedBy(Workable, worker, numworks)
                            else
                                wall_height_change(inst) 
                            end 
                        elseif
                            CheckWallActionPermission(inst, 1) == false 
                            and string.find(inst.prefab, "fence")  
                            and CheckItemPermission(worker, inst, true) 
                            and inst.ownerlist ~= nil 
                            then 
                            old_WorkedBy(Workable, worker, numworks)
                        end
                    -- 有权限则直接执行 
                    elseif CheckItemPermission(worker, inst, true) then 
                        -- 检查野外房屋权限
                        if CheckShelterPermission(inst, worker) then
                            old_WorkedBy(Workable, worker, numworks) 
                        else
                            PlayerSay(worker, GetSayMsg("noadmin_hammer_cant", GetItemOldName(inst)))
                        end                    
                    else                        
                        if owner ~= nil and doer_num ~= nil then 
                            PlayerSay(worker, GetSayMsg("permission_no", owner.name))
                            PlayerSay(owner, GetSayMsg("item_smash", worker.name, GetItemOldName(inst), doer_num)) 
                        else
                            PlayerSay(worker, GetSayMsg("player_leaved")) 
                        end        
                    end

                -- 铲挖的权限 
                elseif workaction ~= nil and workaction == _G.ACTIONS.DIG then 

                    -- 有权限则直接执行，如果挖树桩没权限，则判断周围属于同一个人的树桩和树的总量是否有达到4;患病作物和种地上的种子直接处理 
                    if 
                        CheckItemPermission(worker, inst, true) 
                        or (inst and inst.components.diseaseable and inst.components.diseaseable:IsDiseased()) 
                        or (inst and inst:HasTag("notreadyforharvest")) 
                        then 
                        old_WorkedBy(Workable, worker, numworks) 
                    elseif inst:HasTag("stump") then 
                        if (worker:HasTag("player") and (inst.ownerlist ~= nil and Get_near_tree_num(inst) < 4)) or not worker:HasTag("player") then 
                            old_WorkedBy(Workable, worker, numworks) 
                        end                   
                    else
                        if owner ~= nil and doer_num ~= nil then 
                            PlayerSay(worker, GetSayMsg("trees_dig_cant", owner.name))
                            PlayerSay(owner, GetSayMsg("item_dig", worker.name, GetItemOldName(inst), doer_num)) 
                        else
                            PlayerSay(worker, GetSayMsg("trees_dig_cant")) 
                        end        
                    end

                else 
                    old_WorkedBy(Workable, worker, numworks) 
                end
            end
        end
    )

    --打开建筑容器函数
    local old_RUMMAGE = _G.ACTIONS.RUMMAGE.fn
    _G.ACTIONS.RUMMAGE.fn = function(act)
        testActPrint(act)
        --防装饰(圣诞树等)
        if
            act.target and
                (act.target.prefab == "winter_tree" or act.target.prefab == "winter_deciduoustree" or
                    act.target.prefab == "winter_twiggytree")
         then
            -- 有权限时直接处理
            if CheckItemPermission(act.doer, act.target) then
                return old_RUMMAGE(act)
            elseif
                act.target == nil or act.target.ownerlist == nil or tablelength(act.target.ownerlist) == 0 or
                    act.doer:HasTag("player") == false
             then
                -- 不存在权限则判断周围建筑物
                if CheckBuilderScopePermission(act.doer, act.target, GetSayMsg("tree_open_cant")) then
                    return old_RUMMAGE(act)
                end
            elseif act.doer:HasTag("player") then
                -- 主人不为自己并且物品受权限控制
                local doer_num = GetPlayerIndex(act.doer.userid)
                local master = act.target.ownerlist and GetPlayerById(act.target.ownerlist.master) or nil
                if master ~= nil then
                    PlayerSay(act.doer, GetSayMsg("tree_open_cant", master.name))
                    PlayerSay(master, GetSayMsg("item_open", act.doer.name, GetItemOldName(act.target), doer_num))
                else
                    PlayerSay(act.doer, GetSayMsg("player_leaved", GetPlayerNameByOwnerlist(act.target.ownerlist)))
                end
            end

            return false
        end

        return old_RUMMAGE(act)
    end

    --防止玩家作祟别人东西
    local old_HAUNT = _G.ACTIONS.HAUNT.fn
    _G.ACTIONS.HAUNT.fn = function(act)
        testActPrint(act)

        -- 有权限时直接处理
        if CheckItemPermission(act.doer, act.target, true) then
            return old_HAUNT(act)
        elseif act.doer:HasTag("player") then
            -- 主人不为自己并且物品受权限控制
            local doer_num = GetPlayerIndex(act.doer.userid)
            local master = act.target.ownerlist and GetPlayerById(act.target.ownerlist.master) or nil
            if master ~= nil then
                PlayerSay(act.doer, GetSayMsg("permission_no", master.name, GetItemOldName(act.target)))
                PlayerSay(master, GetSayMsg("item_haunt", act.doer.name, GetItemOldName(act.target), doer_num))
            else
                PlayerSay(act.doer, GetSayMsg("player_leaved", GetPlayerNameByOwnerlist(act.target.ownerlist)))
            end
        end

        return false
    end

    -- 防挖别人地皮 2020.02.10
    AddComponentPostInit(
        "terraformer",
        function(Terraformer, inst) 
            local old_Terraform = Terraformer.Terraform 
            function Terraformer:Terraform(pt, spawnturf) 
                -- 判断挖地皮的权限 
                local tool = inst 
                if tool.components.inventoryitem ~= nil then 
                    local tool_user = tool.components.inventoryitem.owner 
                end

                if _G.TheWorld.ismastersim == false then
                    return old_Terraform(Terraformer, pt, spawnturf) 
                end 

                if CheckBuilderScopePermission(tool_user, nil, GetSayMsg("buildings_dig_cant"),nil ,pt) == false then 
                    return false 
                end

                local ret = old_Terraform(Terraformer, pt, spawnturf) 
                --if ret then
                --    -- 地皮自动堆叠
                --    if auto_stack then
                --        auto_stack_fn(pt)
                --    end
                --end

                return ret 
            end
        end
    )

    --右键开锁控制
    local old_TURNON = _G.ACTIONS.TURNON.fn
    _G.ACTIONS.TURNON.fn = function(act)
        testActPrint(act)
        if _G.TheWorld.ismastersim == false then
            return old_TURNON(act)
        end

        if act.target then
            if act.target.prefab == "firesuppressor" then
                -- 有权限时直接处理
                if CheckItemPermission(act.doer, act.target, true) then
                    return old_TURNON(act)
                elseif act.doer:HasTag("player") then
                    -- 主人不为自己并且物品受权限控制
                    local doer_num = GetPlayerIndex(act.doer.userid)
                    local master = act.target.ownerlist and GetPlayerById(act.target.ownerlist.master) or nil
                    if master ~= nil then
                        PlayerSay(act.doer, GetSayMsg("permission_no", master.name, GetItemOldName(act.target)))
                        PlayerSay(master, GetSayMsg("item_use", act.doer.name, GetItemOldName(act.target), doer_num))
                    else
                        PlayerSay(act.doer, GetSayMsg("player_leaved", GetPlayerNameByOwnerlist(act.target.ownerlist)))
                    end
                end

                return false
            elseif
                (
                    act.target.prefab == "treasurechest" 
                    or act.target.prefab == "icebox" 
                    or act.target.prefab == "dragonflychest" 
                    or act.target.prefab == "cellar" 
                    --or act.target.prefab == "researchlab2"
                    or act.target.prefab == "chesterchest"
                    or act.target.prefab == "venus_icebox"
                )
             then
                if act.target.ownerlist ~= nil and act.target.ownerlist.master == act.doer.userid then
                    PlayerSay(act.doer, "已开锁！任何人都能打开")
                    return old_TURNON(act)
                else
                    PlayerSay(act.doer, "可惜，我不能给它上锁和开锁！")
                    return false
                end
            end
        end

        return old_TURNON(act)
    end

    --右键上锁控制
    local old_TURNOFF = _G.ACTIONS.TURNOFF.fn
    _G.ACTIONS.TURNOFF.fn = function(act)
        testActPrint(act)
        if _G.TheWorld.ismastersim == false then
            return old_TURNOFF(act)
        end

        if act.target then
            if act.target.prefab == "firesuppressor" then
                -- 有权限时直接处理
                if CheckItemPermission(act.doer, act.target, true) then
                    return old_TURNOFF(act)
                elseif act.doer:HasTag("player") then
                    -- 主人不为自己并且物品受权限控制
                    local doer_num = GetPlayerIndex(act.doer.userid)
                    local master = act.target.ownerlist and GetPlayerById(act.target.ownerlist.master) or nil
                    if master ~= nil then
                        PlayerSay(act.doer, GetSayMsg("permission_no", master.name, GetItemOldName(act.target)))
                        PlayerSay(master, GetSayMsg("item_use", act.doer.name, GetItemOldName(act.target), doer_num))
                    else
                        PlayerSay(act.doer, GetSayMsg("player_leaved", GetPlayerNameByOwnerlist(act.target.ownerlist)))
                    end
                end

                return false
            elseif
                act.target and
                    (
                        act.target.prefab == "treasurechest" 
                        or act.target.prefab == "icebox" 
                        or act.target.prefab == "dragonflychest" 
                        or act.target.prefab == "cellar" 
                        or act.target.prefab == "researchlab2" 
                        or act.target.prefab == "chesterchest"
                        or act.target.prefab == "venus_icebox"
                    )
             then
                if act.target.saved_ownerlist ~= nil and act.target.saved_ownerlist.master == act.doer.userid then
                    PlayerSay(act.doer, "已上锁！只有自己能打开")
                    return old_TURNOFF(act)
                else
                    PlayerSay(act.doer, "可惜，我不能给它上锁和开锁！")
                    return false
                end
            end
        end

        return old_TURNOFF(act)
    end

    --开关门
    local old_ACTIVATE = _G.ACTIONS.ACTIVATE.fn
    _G.ACTIONS.ACTIVATE.fn = function(act)
        testActPrint(act)

        -- 有权限时直接处理
        if
            CheckItemPermission(act.doer, act.target, true) or
                CheckWallActionPermission(act.target, 3)
         then
            return old_ACTIVATE(act)
        elseif act.doer:HasTag("player") then
            -- 主人不为自己并且物品受权限控制
            local doer_num = GetPlayerIndex(act.doer.userid)
            local master = act.target.ownerlist and GetPlayerById(act.target.ownerlist.master) or nil
            if master ~= nil then
                PlayerSay(act.doer, GetSayMsg("permission_no", master.name, GetItemOldName(act.target)))
                PlayerSay(master, GetSayMsg("item_use", act.doer.name, GetItemOldName(act.target), doer_num))
            else
                PlayerSay(act.doer, GetSayMsg("player_leaved", GetPlayerNameByOwnerlist(act.target.ownerlist)))
            end
        end

        return false
    end

    --危险的书
    local old_READ = _G.ACTIONS.READ.fn
    _G.ACTIONS.READ.fn = function(act)
        testActPrint(act, act.doer, act.target or act.invobject)

        local targ = act.target or act.invobject
        if targ ~= nil and (targ.prefab == "book_brimstone" or targ.prefab == "book_tentacles") then
            if
                not is_allow_build_near and
                    not (admin_option and act.doer.Network and act.doer.Network:IsServerAdmin() and test_mode == false)
             then
                if not CheckBuilderScopePermission(act.doer, targ, "我不能在别人建筑附近这么做，需要权限！", item_ScopePermission) then
                    return false
                end
            end
        end
        return old_READ(act)
    end

    --危险的道具
    local old_FAN = _G.ACTIONS.FAN.fn
    _G.ACTIONS.FAN.fn = function(act)
        testActPrint(act, act.doer, act.invobject)


        -- 幸运风扇  分解法杖
        if act.invobject and act.invobject.prefab == "perdfan" and act.invobject.prefab == "greenstaff" then
            if
                not is_allow_build_near and
                    not (admin_option and act.doer.Network and act.doer.Network:IsServerAdmin() and test_mode == false)
             then
                if not CheckBuilderScopePermission(act.doer, act.target, "我不能在别人建筑附近这么做，需要权限！", item_ScopePermission) then
                    return false
                end
            end
        end
        return old_FAN(act)
    end

    -- 瞬移的权限
    local old_BLINK = _G.ACTIONS.BLINK.fn
    _G.ACTIONS.BLINK.fn = function(act)
        testActPrint(act, act.doer, act.invobject)
        if
            not is_allow_build_near 
            and not (admin_option and act.doer.Network and act.doer.Network:IsServerAdmin() and test_mode == false)
            then
            if not CheckBuilderScopePermission(act.doer, act.target, "我不能在别人建筑附近这么做，需要权限！", item_ScopePermission) then
                return false
            end
        end
        return old_BLINK(act)
    end

    --防捕别人家的虫
    local old_NET = _G.ACTIONS.NET.fn
    _G.ACTIONS.NET.fn = function(act)
        testActPrint(act)

        -- 萤火虫
        if act.invobject.prefab == "fireflies" then
            if
                not is_allow_build_near and
                    not (admin_option and act.doer.Network and act.doer.Network:IsServerAdmin() and test_mode == false)
             then
                if
                    not CheckBuilderScopePermission(
                        act.doer,
                        act.target,
                        GetSayMsg("buildings_net_cant", act.doer.name, GetItemOldName(act.target)),
                        item_ScopePermission
                    )
                 then
                    return false
                end
            end
        end

        return old_NET(act)
    end

    --检测点燃动作是否有效
    local old_LIGHT = _G.ACTIONS.LIGHT.fn
    _G.ACTIONS.LIGHT.fn = function(act)
        testActPrint(act)

        -- 有权限时直接处理
        if CheckItemPermission(act.doer, act.target, true) then 
           --[[ if act.target.ownerlist ~= nil then 
                local doername = act.doer.name 
                local ownername = GetPlayerNameByOwnerlist(act.target.ownerlist)
                TheNet:Announce(doername .. "点燃了" .. 
                ownername .. "的" .. 
                act.target.prefab)
            end]]
            return old_LIGHT(act)
        elseif
            act.target == nil or act.target.ownerlist == nil or tablelength(act.target.ownerlist) == 0 or
                (cant_destroyby_monster and act.doer:HasTag("player") == false)
         then
            -- 不存在权限则判断周围建筑物
            if CheckBuilderScopePermission(act.doer, act.target, GetSayMsg("buildings_light_cant")) then
                return old_LIGHT(act)
            end
        elseif act.doer:HasTag("player") then
            -- 主人不为自己并且物品受权限控制
            local doer_num = GetPlayerIndex(act.doer.userid)
            local master = act.target.ownerlist and GetPlayerById(act.target.ownerlist.master) or nil
            if master ~= nil then
                PlayerSay(act.doer, GetSayMsg("item_light_cant", master.name))
                PlayerSay(master, GetSayMsg("item_light", act.doer.name, GetItemOldName(act.target), doer_num))
            else
                PlayerSay(act.doer, GetSayMsg("player_leaved", GetPlayerNameByOwnerlist(act.target.ownerlist)))
            end
        end

        return false
    end

    --防止玩家打开别人的容器
    AddComponentPostInit(
        "container",
        function(Container, target)
            local old_OpenFn = Container.Open
            function Container:Open(doer)
                testActPrint(nil, doer, target, "Open", "打开容器")

                -- 有权限时直接处理
                if CheckItemPermission(doer, target, true) or target.prefab == "cookpot" then
                    return old_OpenFn(self, doer)
                elseif doer:HasTag("player") then
                    -- 主人不为自己并且物品受权限控制
                    local doer_num = GetPlayerIndex(doer.userid)
                    local master = target.ownerlist and GetPlayerById(target.ownerlist.master) or nil
                    if master ~= nil then
                        PlayerSay(doer, GetSayMsg("permission_no", master.name, GetItemOldName(target)))
                        PlayerSay(master, GetSayMsg("item_open", doer.name, GetItemOldName(target), doer_num))
                    else
                        PlayerSay(doer, GetSayMsg("player_leaved", GetPlayerNameByOwnerlist(target.ownerlist)))
                    end
                end
            end
        end
    )

    -- 查看物品
    local old_LOOKAT = _G.ACTIONS.LOOKAT.fn
    _G.ACTIONS.LOOKAT.fn = function(act)
        testActPrint(act)

        if act.target and act.target.prefab == "beefalo" and act.target.ownerlist ~= nil then
            -- PlayerSay(act.doer, "这头牛的当前状态: \n" .. GetBeefaloInfoString(act.target, act.target.components.rideable:IsBeingRidden()))
            local colour = {0.6, 0.9, 0.8, 1}
            -- colour[1],colour[2],colour[3] = _G.HexToPercentColor("#E80607")
            PlayerColorSay(
                act.doer,
                "这头牛的当前状态: \n" .. GetBeefaloInfoString(act.target, act.target.components.rideable:IsBeingRidden()),
                colour
            )
            return true
        end

        return old_LOOKAT(act)
    end

    --防止玩家降别人的锚
    local old_LOWER_ANCHOR = _G.ACTIONS.LOWER_ANCHOR.fn
    _G.ACTIONS.LOWER_ANCHOR.fn = function(act)
        testActPrint(act)
        if act.target.components.anchor ~= nil then
            --有权限直接处理
            if CheckItemPermission(act.doer, act.target, true) then
                return old_LOWER_ANCHOR(act)
            elseif act.doer:HasTag("player") then
                --主人不为自己且物品受权限控制
                local doer_num = GetPlayerIndex(act.doer.userid)
                local master = act.target.ownerlist and GetPlayerById(act.target.ownerlist.master) or nil
                if master ~= nil then
                    PlayerSay(act.doer, GetSayMsg("permission_no", master.name, GetItemOldName(act.target)))
                    PlayerSay(master, GetSayMsg("item_use", act.doer.name, GetItemOldName(act.target), doer_num))
                else
                    PlayerSay(act.doer, GetSayMsg("player_leaved", GetPlayerNameByOwnerlist(act.target.ownerlist)))
                end
                return false 
            end
        end
    end

    --防止玩家升别人的锚
    local old_RAISE_ANCHOR = _G.ACTIONS.RAISE_ANCHOR.fn
    _G.ACTIONS.RAISE_ANCHOR.fn = function(act)
        testActPrint(act)
        if act.target.components.anchor ~= nil then
            --有权限直接处理
            if CheckItemPermission(act.doer, act.target, true) then
                return old_RAISE_ANCHOR(act)
            elseif act.doer:HasTag("player") then
                --主人不为自己且物品受权限控制
                local doer_num = GetPlayerIndex(act.doer.userid)
                local master = act.target.ownerlist and GetPlayerById(act.target.ownerlist.master) or nil
                if master ~= nil then
                    PlayerSay(act.doer, GetSayMsg("permission_no", master.name, GetItemOldName(act.target)))
                    PlayerSay(master, GetSayMsg("item_use", act.doer.name, GetItemOldName(act.target), doer_num))
                else
                    PlayerSay(act.doer, GetSayMsg("player_leaved", GetPlayerNameByOwnerlist(act.target.ownerlist)))
                end
                return false 
            end
        end
    end

    --防止玩家升别人的船帆
    local old_RAISE_SAIL = _G.ACTIONS.RAISE_SAIL.fn
    _G.ACTIONS.RAISE_SAIL.fn = function(act)
        testActPrint(act)
        if act.target.components.mast ~= nil then
            --有权限直接处理
            if CheckItemPermission(act.doer, act.target, true) then
                return old_RAISE_SAIL(act)
            elseif act.doer:HasTag("player") then
                --主人不为自己且物品受权限控制
                local doer_num = GetPlayerIndex(act.doer.userid)
                local master = act.target.ownerlist and GetPlayerById(act.target.ownerlist.master) or nil
                if master ~= nil then
                    PlayerSay(act.doer, GetSayMsg("permission_no", master.name, GetItemOldName(act.target)))
                    PlayerSay(master, GetSayMsg("item_use", act.doer.name, GetItemOldName(act.target), doer_num))
                else
                    PlayerSay(act.doer, GetSayMsg("player_leaved", GetPlayerNameByOwnerlist(act.target.ownerlist)))
                end
                return false 
            end
        end
    end

    --防止玩家降别人的船帆
    local old_LOWER_SAIL = _G.ACTIONS.LOWER_SAIL.fn
    _G.ACTIONS.LOWER_SAIL.fn = function(act)
        testActPrint(act)
        if act.target.components.mast ~= nil then
            --有权限直接处理
            if CheckItemPermission(act.doer, act.target, true) then
                return old_LOWER_SAIL(act)
            elseif act.doer:HasTag("player") then
                --主人不为自己且物品受权限控制
                local doer_num = GetPlayerIndex(act.doer.userid)
                local master = act.target.ownerlist and GetPlayerById(act.target.ownerlist.master) or nil
                if master ~= nil then
                    PlayerSay(act.doer, GetSayMsg("permission_no", master.name, GetItemOldName(act.target)))
                    PlayerSay(master, GetSayMsg("item_use", act.doer.name, GetItemOldName(act.target), doer_num))
                else
                    PlayerSay(act.doer, GetSayMsg("player_leaved", GetPlayerNameByOwnerlist(act.target.ownerlist)))
                end
                return false 
            end
        end
    end

    --防止玩家使用别人的舵
    local old_STEER_BOAT = _G.ACTIONS.STEER_BOAT.fn
    _G.ACTIONS.STEER_BOAT.fn = function(act)
        testActPrint(act)
        if act.target.components.steeringwheel ~= nil then
            --有权限直接处理
            if CheckItemPermission(act.doer, act.target, true) then
                return old_STEER_BOAT(act)
            elseif act.doer:HasTag("player") then
                --主人不为自己且物品受权限控制
                local doer_num = GetPlayerIndex(act.doer.userid)
                local master = act.target.ownerlist and GetPlayerById(act.target.ownerlist.master) or nil
                if master ~= nil then
                    PlayerSay(act.doer, GetSayMsg("permission_no", master.name, GetItemOldName(act.target)))
                    PlayerSay(master, GetSayMsg("item_use", act.doer.name, GetItemOldName(act.target), doer_num))
                else
                    PlayerSay(act.doer, GetSayMsg("player_leaved", GetPlayerNameByOwnerlist(act.target.ownerlist)))
                end
                return false 
            end
        end
    end

    -- 给船保存船的着火点 2020.3.30
    AddComponentPostInit(
        "hull",
        function(Hull, boat)
            local old_AttachEntityToBoat = Hull.AttachEntityToBoat 
            function Hull:AttachEntityToBoat(obj, offset_x, offset_z, parent_to_boat)
                old_AttachEntityToBoat(Hull, obj, offset_x, offset_z, parent_to_boat) 

                if parent_to_boat and obj.prefab == "burnable_locator_medium" then 
                    if boat.burnable_locators == nil then 
                        boat.burnable_locators = {} 
                    end
                    table.insert(boat.burnable_locators,obj)  	
                end
            end
        end
    )

    -- 船锚放下船无敌 2020.02.25
    AddComponentPostInit(
        "hullhealth",
        function(Hullhealth) 
            local old_OnCollide = Hullhealth.OnCollide 
            function Hullhealth:OnCollide(data) 
                local boat = self.inst 
                local total_anchor_drag = boat.components.boatphysics:GetTotalAnchorDrag()

                if total_anchor_drag > 0 then 
                    data.hit_dot_velocity = nil 
                    data.hit_dot_velocity = 0 
                end

                old_OnCollide(Hullhealth, data) 
            end
        end
    )

end
