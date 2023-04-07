local _G = GLOBAL
local TheSim = _G.TheSim
local TheNet = _G.TheNet
local TheShard = _G.TheShard
local TheInput = _G.TheInput
local getmetatable = _G.getmetatable

local SpawnPrefab = _G.SpawnPrefab
local FindValidPositionByFan = _G.FindValidPositionByFan

local ACTIONS = _G.ACTIONS
local FRAMES = _G.FRAMES
local PI = _G.PI
local GROUND = _G.GROUND
-- local GROUND_FLOORING = _G.GROUND_FLOORING

-- 测试模式
local test_mode = GetModConfigData("test_mode")
-- 权限模式
local permission_mode = GetModConfigData("permission_mode")
-- 管理员是否不受权限控制
local admin_option = GetModConfigData("admin_option")
-- 防止怪物摧毁建筑
local cant_destroyby_monster = GetModConfigData("cant_destroyby_monster")
-- 农作物防挖范围
local firesuppressor_dig = GetModConfigData("firesuppressor_dig")
--远古犀牛是否允许拆家
local minotaur_destroy = GetModConfigData("minotaur_destroy")
-- 保存权限的物品
local permission_prefabs = {}
config_item = _G.require("authority_hexie_config_item")

-- 查找符合fn的装备栏物品
function FindEquipItems(player, fn)
    local items = {}
    local equipslots = player.components.inventory.equipslots

    for k, v in pairs(equipslots) do
        if fn(v) then
            table.insert(items, v)
        end
    end

    return items
end

-- 设置所有者名
function SetOwnerName(inst, master, permission_state)
    if inst ~= nil and inst:IsValid() then

        if inst.components.named == nil and not inst:HasTag("player") then
            inst:AddComponent("named")
        end

        local userid = inst.ownerlist ~= nil and inst.ownerlist.master or master
        if inst.components.named ~= nil then
            if userid ~= nil then
                local ownerName = GetPlayerNameByOwnerlist({ master = userid })
                if ownerName ~= nil then
                    if inst.oldName == nil then
                        inst.oldName = inst.name
                    end
                    if permission_state == false then
                        inst.components.named:SetName((inst.oldName or inst.name or "") .. "\n" .. GetSayMsg("item_master_to", ownerName) .. " --无权限")
                    elseif permission_state == nil or permission_state then
                        inst.components.named:SetName((inst.oldName or inst.name or "") .. "\n" .. GetSayMsg("item_master_to", ownerName))
                    end
                end
            else
                inst.components.named:SetName(nil)
            end
        end
    end
end

-- 设置物品名称
function SetItemAppendName(inst, appendName)
    if inst ~= nil and inst:IsValid() then
        if inst.components.named == nil then
            inst:AddComponent("named")
            inst.oldName = inst.name
        end

        if appendName ~= nil then
            if inst.oldName == nil then
                inst.oldName = inst.name
            end
            inst.components.named:SetName((inst.oldName or inst.name or "") .. "\n" .. appendName)
        else
            inst.components.named:SetName(nil)
        end
    end
end

-- 获取物品原始名称
function GetItemOldName(inst)
    return inst.oldName or inst.name
end

-- 设置有权限的物品防烧 2020.02.14
function SetItemPermissionDestroy(item, master)
    if item ~= nil and item:IsValid() and not item:HasTag("tree") then
        local userid = item.ownerlist ~= nil and item.ownerlist.master or master
        if userid ~= nil then
            RemoveBurnable(item)
        else
            AddBurnable(item)
        end
    end
end

-----权限保存与加载----
function SaveAndLoadChanged(inst)
    permission_prefabs[inst.prefab] = true

    if inst.components.named == nil and not inst:HasTag("player") then
        inst:AddComponent("named")
        inst.oldName = inst.name
    end

    local OldOnSave = inst.OnSave
    inst.OnSave = function(inst, data)
        if OldOnSave ~= nil then
            OldOnSave(inst, data)
        end
        if inst.ownerlist ~= nil then
            data.ownerlist = inst.ownerlist
        end
        if inst.saved_ownerlist ~= nil then
            data.saved_ownerlist = inst.saved_ownerlist
        end
    end

    local OldOnLoad = inst.OnLoad
    inst.OnLoad = function(inst, data)
        if OldOnLoad ~= nil then
            OldOnLoad(inst, data)
        end
        if data ~= nil then
            if data.ownerlist ~= nil then
                inst.ownerlist = data.ownerlist
                SetOwnerName(inst)
                SetItemPermissionDestroy(inst)
            end

            if data.saved_ownerlist ~= nil then
                inst.saved_ownerlist = data.saved_ownerlist
                SetOwnerName(inst, inst.saved_ownerlist.master)
                SetItemPermissionDestroy(inst, inst.saved_ownerlist.master)
            end
        end
    end
end

-- 对物品权限进行保存和加载
function SavePermission(inst)
    local prefab = type(inst) == "string" and inst or inst.prefab
    AddPrefabPostInit(
            prefab,
            function(inst)
                SaveAndLoadChanged(inst)
            end
    )
end

-- 为所有自定义物品加上权限
AddPrefabPostInitAny(
        function(inst)

            --筛选出树苗,在树苗变成大树之前推送出事件
            if string.find(inst.prefab, "_sapling") then
                local function OnremoveFn(inst)
                    if inst.ownerlist ~= nil then
                        local x, y, z = inst.Transform:GetWorldPosition()
                        local master = inst.ownerlist.master
                        _G.TheWorld:PushEvent("tree_permission", { x = x, y = y, z = z, master = master }) --推送出树苗的位置和所有者,监听对象设置在manager_permission.lua中 2020.2.6
                    end
                end

                inst:ListenForEvent("onremove", OnremoveFn)
            end

            if
            _G.TheWorld.guard_authorization ~= nil and _G.TheWorld.guard_authorization.custom_prefabs ~= nil and
                    _G.TheWorld.guard_authorization.custom_prefabs[inst.prefab]
            then
                SaveAndLoadChanged(inst)
            end
        end
)

-- 检查物品是否有进行保存和加载权限
function IsPermission(inst)
    if type(inst) == "string" then
        return permission_prefabs[inst]
    else
        return permission_prefabs[inst.prefab]
    end
end

-- 说话
function PlayerSay(player, msg, delay, duration, noanim, force, nobroadcast, colour)
    if player ~= nil and player.components.talker then
        player:DoTaskInTime(
                delay or 0.01,
                function()
                    player.components.talker:Say(msg, duration or 2.5, noanim, force, nobroadcast, colour)
                end
        )
    end
end

-- 带颜色渲染的话
function PlayerColorSay(player, msg, colour, delay, duration)
    PlayerSay(player, msg, delay, duration, nil, nil, nil, colour)
end

-- 将坐标点对象拆分成x y z返回
function GetSplitPosition(pos)
    return pos.x, pos.y, pos.z
end

-- 放置物体到指定位置
function ItemSetPosition(doer, x, y, z, isDoerNotSetPos, isAnim)
    if not isDoerNotSetPos then
        if doer.Physics ~= nil then
            doer.Physics:Teleport(x, y, z)
        else
            doer.Transform:SetPosition(x, y, z)
        end
    end

    if doer.components.leader ~= nil then
        for follower, v in pairs(doer.components.leader.followers) do
            if isAnim == false then
                ItemSetPosition(follower, x, y, z, false)
            else
                ItemAnimSetPosition(follower, x, y, z, false, false)
            end
        end
    end
end

-- 放置物体到指定位置(动画)
function ItemAnimSetPosition(doer, x, y, z, isDoerNotSetPos, isEndAnim)
    if not isDoerNotSetPos then
        local doX, doY, doZ = doer.Transform:GetWorldPosition()
        if doX ~= nil then
            local start_fx = SpawnPrefab("spawn_fx_medium")
            if start_fx ~= nil then
                start_fx.Transform:SetPosition(doX, doY, doZ)
            end
        end
        if doX ~= nil and doer.components.colourtweener then
            local colour_r, colour_g, colour_b, alpha = doer.AnimState:GetMultColour()
            doer.components.colourtweener:StartTween(
                    { 0, 0, 0, 1 },
                    19 * FRAMES,
                    function()
                        if isEndAnim then
                            local end_fx = SpawnPrefab("spawn_fx_medium")
                            if end_fx ~= nil then
                                end_fx.Transform:SetPosition(x, y, z)
                            end
                        end
                        doer.AnimState:SetMultColour(colour_r, colour_g, colour_b, alpha)
                        ItemSetPosition(doer, x, y, z, isDoerNotSetPos, true)
                    end
            )
        else
            if isEndAnim then
                local end_fx = SpawnPrefab("spawn_fx_medium")
                if end_fx ~= nil then
                    end_fx.Transform:SetPosition(x, y, z)
                end
            end
            ItemSetPosition(doer, x, y, z, isDoerNotSetPos, true)
        end
    else
        ItemSetPosition(doer, x, y, z, isDoerNotSetPos, true)
    end
end

-- 获取物体周围一个随机范围内有效的地形
function GetFanValidPoint(position, minRadiu, maxRadiu, attempts)
    local theta = math.random() * 2 * PI
    local radius = math.random(minRadiu or 8, maxRadiu or 15)
    local attempts = attempts or 30
    local result_offset = FindValidPositionByFan(
            theta,
            radius,
            attempts,
            function(offset)
                if position == nil or position.x == nil or position.y == nil or position.z == nil then
                    return false
                end
                local run_point = position + offset
                if run_point == nil or run_point.x == nil or run_point.y == nil or run_point.z == nil then
                    return false
                end
                local tile = _G.TheWorld.Map:GetTileAtPoint(run_point.x, run_point.y, run_point.z)
                if tile == GROUND.IMPASSABLE or tile == GROUND.INVALID or tile >= GROUND.UNDERGROUND then
                    return false
                end
                return true
            end
    )
    if result_offset ~= nil then
        local pos = position + result_offset
        return pos
    end
end

-- 检查是否为朋友
function CheckFriend(masterId, guestId)
    -- if type(master) == "string" then
    -- 	master = GetPlayerById(master)
    -- end
    -- return master and master.friends[guestId]
    if masterId == nil or guestId == nil then
        return false
    end

    -- _G.TheWorld.guard_authorization ~= nil and _G.TheWorld.guard_authorization[masterId] ~= nil
    --return _G.TheWorld.guard_authorization[masterId].friends and _G.TheWorld.guard_authorization[masterId].friends[guestId]
    return _G.TheWorld.guard_authorization ~= nil and _G.TheWorld.guard_authorization[masterId] ~= nil and
            _G.TheWorld.guard_authorization[masterId].friends and
            _G.TheWorld.guard_authorization[masterId].friends[guestId]
end

-- 设置物体权限
function SetItemPermission(item, player, forer)
    -- 处理mod物品等
    if not IsPermission(item) and _G.TheWorld.guard_authorization ~= nil and item.prefab ~= nil then
        if _G.TheWorld.guard_authorization.custom_prefabs == nil then
            _G.TheWorld.guard_authorization.custom_prefabs = {}
        end

        _G.TheWorld.guard_authorization.custom_prefabs[item.prefab] = true
        for _, v in pairs(_G.Ents) do
            if v.prefab == item.prefab then
                SaveAndLoadChanged(v)
            end
        end
    end

    --item.ownerlist = { friends = {} }
    if item.ownerlist == nil then
        item.ownerlist = {}
    else
        item.saved_ownerlist = nil
    end
    --item.saveTaglist = {}
    if player ~= nil or forer == nil then
        item.ownerlist.master = type(player) == "string" and player or (player ~= nil and player.userid or nil)
        SetOwnerName(item)
        SetItemPermissionDestroy(item)
        --TheNet:Announce(player.name .. "为" .. item.prefab .."设置了权限")
    end
    if forer ~= nil then
        item.ownerlist.forer = type(forer) == "string" and forer or forer.userid
    end
end

-- 获取物品主人
function GetItemLeader(item)
    --如果有主人,取主人的权限，如果是投石机则直接返回item（防止投石机误伤墙体用）
    if item ~= nil and item.prefab == "winona_catapult" then
        return item
    elseif item ~= nil then
        if
        item.components.follower ~= nil and item.components.follower.leader ~= nil and
                item.components.follower.leader:HasTag("player")
        then
            return item.components.follower.leader
        elseif item.ownerlist ~= nil and item.ownerlist.master ~= nil then
            return GetPlayerById(item.ownerlist.master) or item
        end
    end

    return item
end

-- 判断权限 
function CheckPermission(ownerlist, guest, isForer)
    -- 关闭权限验证且是玩家的行为则直接返回true 2020.02.19
    if permission_mode == false and guest:HasTag("player") then
        return true
    end
    -- 目标没有权限直接返回true
    if ownerlist == nil or ownerlist.master == nil then
        return true
    end
    local guestId = type(guest) == "string" and guest or (guest and guest.userid or nil)
    -- 主人为自己时直接返回true
    if
    guestId and
            (ownerlist.master == guestId or CheckFriend(ownerlist.master, guestId) or
                    (isForer and ownerlist.forer == guestId))
    then
        return true
    end

    return false
end

-- 判断物品权限
function CheckItemPermission(player, target, isNoMaster, isForer)
    -- 主机直接返回true
    if _G.TheWorld.ismastersim == false then
        return true
    end
    -- 玩家不存在或目标不存在直接返回true
    if player == nil or target == nil then
        return true
    end
    -- 管理员直接返回true
    if admin_option and player.Network and player.Network:IsServerAdmin() and test_mode == false then
        return true
    end
    if target.ownerlist ~= nil and tablelength(target.ownerlist) > 0 then
        --主人为自己时直接返回true
        -- if player.userid and (target.ownerlist.master == player.userid or CheckFriend(target.ownerlist.master, player.userid) or target.ownerlist.forer == player.userid) then
        -- 	return true
        -- end

        -- 有权限则返回true
        if CheckPermission(target.ownerlist, player, isForer) then
            return true
        end
    else
        return isNoMaster ~= nil and isNoMaster or false
    end

    return false
end

-- 检查区域内相同主人的树和树桩的数量，达到4个就返回 2020.02.12 
function Get_near_tree_num(inst)
    local x, y, z = inst:GetPosition():Get()
    local tree_num = 0
    local ents = TheSim:FindEntities(x, y, z, 12, nil, { "INLIMBO" }, { "tree", "stump" }, { "player" })
    for _, findobj in pairs(ents) do
        if findobj ~= nil and findobj.ownerlist ~= nil and findobj.ownerlist.master == inst.ownerlist.master then
            tree_num = tree_num + 1
            if tree_num >= 4 then
                return tree_num
            end
        end
    end

    return tree_num
end

-- 判断周围是否有公共设施
function IsNearPublicEnt(pos)
    local ents = {}
    local x, y, z = pos.x, pos.y, pos.z
    ents = TheSim:FindEntities(x, y, z, 12, { "public_ent" })
    if #ents >= 1 then
        return true
    end

    return false
end

-- 判断建筑范围内权限
function CheckBuilderScopePermission(player, item, msg, scopePermission, pos)
    -- 关闭权限验证则直接返回true
    if permission_mode == false then
        return true
    end
    if scopePermission == nil then
        scopePermission = firesuppressor_dig
    end

    --主人不为自己时，判断周围有无别人的建筑群，如果有则不可执行，否则可执行
    if scopePermission > 0 then
        local ents = {}
        local x, y, z
        if pos ~= nil then
            x, y, z = GetSplitPosition(pos)
        else
            x, y, z = (item and item or player).Transform:GetWorldPosition()
        end
        ents = TheSim:FindEntities(x, y, z, scopePermission, nil, nil, { "structure", "wall" })
        local mystructure_num = 0
        local structure_num = 0
        if player and player.userid then

            -- 管理员直接返回true
            if admin_option and player.Network and player.Network:IsServerAdmin() and test_mode == false then
                return true
            end

            for _, obj in pairs(ents) do
                --print("找到["..obj.name.."]")
                if obj and obj.ownerlist then
                    if obj:HasTag("structure") or obj:HasTag("wall") then
                        --print("找到["..obj.name.."]它属于:"..obj.ownerlist.master)
                        if obj.ownerlist.master == player.userid or CheckFriend(obj.ownerlist.master, player.userid) then
                            mystructure_num = mystructure_num + 1
                        else
                            --if obj and obj.ownerlist and obj:HasTag("structure") and player and player.userid and (obj:HasTag("userid_"..player.userid) == false) then
                            structure_num = structure_num + 1
                        end
                    end
                end
            end
        end

        if structure_num >= 2 and structure_num > mystructure_num then
            PlayerSay(player, msg)
            return false
        end
    end

    return true
end

-- 移除指定文件监听方法并返回原始Fn
function RemoveEventCallbackEx(inst, event, filepath, source)
    source = source or inst
    local old_event_key, old_event = nil, nil

    -- 移除指定监听方法
    if
    source.event_listeners ~= nil and source.event_listeners[event] ~= nil and
            source.event_listeners[event][inst] ~= nil
    then
        --print("find event begin")
        for i, fn in ipairs(source.event_listeners[event][inst]) do
            local info = _G.debug.getinfo(fn, "LnS")
            if string.find(info.source, filepath) then
                old_event_key = i
                old_event = fn
                break
                --print(string.format("      %s = function - %s", i, info.source..":"..tostring(info.linedefined)))
            end
        end
        --print("find event end")
    end

    -- 移除指定监听方法
    if
    old_event ~= nil and source.event_listeners ~= nil and source.event_listeners[event] ~= nil and
            source.event_listeners[event][inst] ~= nil
    then
        inst:RemoveEventCallback(event, old_event, source)
    end

    return old_event
end

--移除可燃烧属性 2020.3.30
function RemoveBurnable(inst)
    -- 移除船的可燃属性 2020.3.20
    if inst.prefab == "boat" and not inst.gd_lightremoved then
        local burnable_locators = inst.burnable_locators
        for k, v in pairs(burnable_locators) do
            v:RemoveComponent("burnable")
        end

        inst.gd_lightremoved = true
        -- 其他东西的可燃性
    elseif inst and not inst.gd_lightremoved and inst.components.burnable ~= nil then
        inst.gd_lightremoved = true
        if inst:HasTag("canlight") then
            inst.canlight = true
            inst:RemoveTag("canlight")
        end
        if inst:HasTag("nolight") then
            inst.nolight = true
        else
            inst:AddTag("nolight")
        end
        --薇诺娜的电池有“inst.components.fueled”，为了使条件成立故加入“inst.components.circuitnode”来一起判断
        if inst.components.fueled == nil or inst.components.circuitnode then
            if inst:HasTag("fireimmune") then
                inst.fireimmune = true
            else
                inst:AddTag("fireimmune")
            end
        end
    end
end

-- 添加可燃烧属性
function AddBurnable(inst)
    if inst and inst.gd_lightremoved and inst.components.burnable ~= nil then
        inst.gd_lightremoved = nil
        if inst.canlight then
            inst:AddTag("canlight")
        end
        if not inst.nolight then
            inst:RemoveTag("nolight")
        end
        if not inst.fireimmune then
            inst:RemoveTag("fireimmune")
        end
    end
end

function strFindInTable(str, T)
    for k, v in ipairs(T) do
        if string.find(str, v) then
            return true
        end
    end
    return false
end

function FindTableValueIndex(tb, value)
    for k, v in ipairs(tb) do
        if v == value then
            return n
        end
    end
end

function tablelength(T)
    local count = 0
    for _ in pairs(T) do
        count = count + 1
    end
    return count
end

function print_lua_table(lua_table, indent)
    indent = indent or 0
    for k, v in pairs(lua_table) do
        if type(k) == "string" then
            k = string.format("%q", k)
        end
        local szSuffix = ""
        if type(v) == "table" then
            szSuffix = "{"
        end
        local szPrefix = string.rep("	", indent)
        formatting = szPrefix .. "[" .. tostring(k) .. "]" .. " = " .. szSuffix
        if type(v) == "table" then
            print(formatting)
            print_lua_table(v, indent + 1)
            print(szPrefix .. "},")
        else
            local szValue = ""
            if type(v) == "string" then
                szValue = string.format("%q", v)
            else
                szValue = tostring(v)
            end
            print(formatting .. szValue .. ",")
        end
    end
end

function testActPrint(act, doer, target, actName, actDes)
    if test_mode then
        if act ~= nil then
            if doer == nil then
                doer = act.doer
            end

            if target == nil then
                target = act.target
            end

            if act.action ~= nil and act.action ~= nil then
                if actName == nil then
                    actName = act.action.id
                end

                if actDes == nil then
                    actDes = act:GetActionString()
                end
            end
        end

        if actName == nil then
            actName = "[未知操作id]"
        end

        if actDes == nil then
            actDes = "[未知操作]"
        end

        print(
                (doer and doer.name .. "(" .. doer.prefab .. ")" or "[未知]") ..
                        "--" ..
                        actName ..
                        "--" ..
                        (target and
                                (target.prefab and GetItemOldName(target) .. "(" .. target.prefab .. ")" or "[无效的类名]") ..
                                        ("--" ..
                                                actDes ..
                                                "--ownerlist:" ..
                                                tostring(target.ownerlist) ..
                                                " ownerlist数量:" ..
                                                (target.ownerlist and tablelength(target.ownerlist) or "[无效的对象]")) or
                                "target对象不存在")
        )
        --print("["..(doer and doer.userid and doer.userid or "无效的ID").."]HasTag:"..(doer and doer.userid and target and tostring(target:HasTag("userid_"..doer.userid)) or "false"))
        print(
                "[" ..
                        (doer and doer.userid and doer.userid or "无效的ID") ..
                        "]HasTag:" ..
                        (doer and doer.userid and target and tostring(CheckItemPermission(doer, target)) or "false")
        )
        print("IsPlayer:" .. tostring(doer and doer:HasTag("player")))
    end
end

if test_mode then
    print("打印TheSim函数")
    for k, v in pairs(getmetatable(TheSim).__index) do
        print(k, v)
    end

    print("打印TheNet函数")
    for k, v in pairs(getmetatable(TheNet).__index) do
        print(k, v)
    end

    print("打印TheShard函数")
    for k, v in pairs(getmetatable(TheShard).__index) do
        print(k, v)
    end

    print("打印TheInput函数")
    for k, v in pairs(getmetatable(TheInput).__index) do
        print(k, v)
    end
end
