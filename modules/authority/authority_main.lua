GLOBAL.setmetatable(env, {__index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end})

-- 为了权限 顺带加的功能
-- if GetModConfigData("player_authority_HIDE_ADMIN") then
--     local net  = getmetatable(TheNet)
--     local oldGetClientTable = TheNet.GetClientTable
--     net.__index.GetClientTable = function(Net,...)
--         local function a(b)
--             return oldGetClientTable(b)
--         end
--         local c = a(Net,...)
--         if type(c) == "table" then
--             local d = {}
--             local host = nil
--             for _, value in pairs(c) do
--                 if value.performance == nil then
--                     if value.admin == true then
--                         value.admin = false
--                     end
--                     table.insert(d,value)
--                 else
--                     value.userid = ""  -- 权限控制需要
--                     host = value
--                 end
--             end
--             table.sort(d, function(a1, a2) -- 重新排序
--                 return a1.userid < a2.userid
--             end)
--             if host then
--                 table.insert(d, 1, host)
--             end
--             c = nil
--             return d
--         end
--         return c
--     end
-- end

------ 绑定动作  ----
local adduserid = GetModConfigData("player_authority_adduserid")
if adduserid then
    modimport("modules/authority/adduserid.lua")
end

-- if TheNet:GetIsClient() then return end --客机不执行下面的代码
if not (TheNet:GetIsServer() or TheNet:IsDedicated()) then return end

if GetModConfigData("player_authority_mod_tip") == true then
    local function DoVerifyModVersions(world, mods_to_verify)
        TheSim:VerifyModVersions(mods_to_verify)
    end
    GLOBAL.ModManager.StartVersionChecking = function ()
        local mods_to_verify = {}
        for i, mod_name in ipairs(ModManager:GetEnabledServerModNames()) do
            if mod_name:len() > 0 then
                local modinfo = KnownModIndex:GetModInfo(mod_name)
                if modinfo.all_clients_require_mod then
                    --print("adding mod to verify", mod_name)
                    table.insert(mods_to_verify, { name = mod_name, version = modinfo.version })
                end
            end
        end
        if #mods_to_verify > 0 then
            --Start mod version checking task
            TheWorld:DoTaskInTime(20, DoVerifyModVersions, 60, mods_to_verify)
        end
    end
end
if not GetModConfigData("player_authority_ON") then return end
local tool = require("tools/protector_tool")
GLOBAL.TUNING.PROTECTOR_DEPLOY_AREA = GetModConfigData("player_authority_PROTECTOR_DEPLOY_AREA")   --权限范围
GLOBAL.TUNING.UNPROTECTOR_AREA = GetModConfigData("player_authority_UNPROTECTOR_AREA")    --特殊地点无权限范围,及PROTECTOR_PLAYERS用户的清理范围
GLOBAL.TUNING.PROTECTOR_TIME = GetModConfigData("player_authority_PROTECTOR_TIME")        -- 游戏内天数
GLOBAL.TUNING.PROTECTOR_PLAYERS = {  -- #_clean 权限 及 不限制权限的玩家 Klei id    EX: KU_abcdef
	"KU_jXab3Dt4",
}
GLOBAL.TUNING.PROTECTOR_ITEMS = {    -- 无权限物品
    "critterlab",
    "pigking",
    "moonbase",
    "resurrectionstone",
    "oasislake",
    "lava_pond",
    "multiplayer_portal_moonrock",
    "multiplayer_portal",
    "multiplayer_portal_moonrock_constr",
    "toadstool_cap",
    "tentacle_pillar",
    "tentacle_pillar_hole", -- 大触手
    "beequeenhive",
    "klaus_sack",
    "beequeenhivegrown",
    "atrium_gate", --远古
    -- "ancient_altar",
    -- "ancient_altar_broken",
    "cave_exit",
    "cave_entrance",
    "cave_entrance_ruins",
    "cave_entrance_open",
    "statueglommer",
    -- "wormhole",
    -- "minotaur_spawner",
}

-- luaguage  You can change it in your Dedicated Server :
local luaguage = true or GetModConfigData("player_authority_language")
GLOBAL.PROTECTOR = {
    UNPROTECTED = luaguage and "无权限保护的 " or "Unprorected ",
    MASTER = "\n" .. (luaguage and "主人：" or "Owner:"),
    PERMISSION1 = luaguage and "没有权限！！！" or "I can't do this within the authority of the owner.",
    PERMISSION2 = luaguage and "获得了 " or "Got ",
    PERMISSION3 = luaguage and " 的权限" or " english",
    PERMISSION4 = luaguage and "把权限给了 " or "english ",
    PERMISSION5 = luaguage and " 已经删除了你的权限" or " english",
    PERMISSION6 = luaguage and "删除了 " or "Deleted ",
    PERMISSION7 = luaguage and "已公开 " or " Opened ",
    PERMISSION8 = luaguage and "已关闭 " or " Closed ",
}

local function onbuilt(inst,data)
    if data and data.builder and data.pos then
        if tool.CanDo(data.pos,data.builder) then
            -- print(inst.name,"--onbuilt--",inst.prefab)
            tool.SetName(inst,data.builder.name,data.builder.userid)
        end
    end
end
--local function turnon(inst)
--    inst.components.machine.ison = true
--    if inst.components.protector then
--        inst.components.protector.isprotected = false
--    end
--end
--local function turnoff(inst)
--    inst.components.machine.ison = false
--    if inst.components.protector then
--        inst.components.protector.isprotected = true
--    end
--end
local function DoGameDataChanged(inst)
    if inst.components.protector.userid == nil  then
        inst:StopWatchingWorldState("cycles",DoGameDataChanged)
        return true
    end
    if inst.components.protector.protectortime == nil then
        inst.components.protector.userid = nil
        return true
    end
    local obj = TheNet:GetClientTable()
    if obj ~= nil then
        for _, player in pairs(obj) do
            if player.userid == inst.components.protector.userid then
                inst.components.protector.protectortime = 0
                return true
            end
        end
    end
    if inst.components.protector.protectortime < GLOBAL.TUNING.PROTECTOR_TIME then
        inst.components.protector.protectortime = inst.components.protector.protectortime + 1
    else
        inst.components.protector.protectortime = nil
        inst.components.protector.userid = nil
        if inst.components.named then
            inst.components.named:SetName(GLOBAL.PROTECTOR.UNPROTECTED .. (inst.components.named.name or inst.name))
        end
    end
end

---container
AddPrefabPostInitAny(function(inst)
    if (inst.components.pickable ~= nil or (inst.components.health ~= nil and inst.components.locomotor == nil) and inst.components.inventoryitem == nil)
     or inst.components.workable ~= nil or inst.components.follower ~= nil or inst.components.container ~= nil
    then
        inst:AddComponent("protector")
--[[
        inst:DoTaskInTime(.3, function ()
            if inst.components.protector and inst.components.protector.username ~= nil and inst.overridname then
                local old_name = inst.displaynamefn
                inst.displaynamefn = function ()
                    if inst.components.protector.userid ~= nil then
                        return (old_name ~= nil and old_name or inst.nameoverride)..GLOBAL.PROTECTOR.MASTER..inst.components.protector.username
                    end
                    return GLOBAL.PROTECTOR.UNPROTECTED..(old_name ~= nil and old_name or inst.nameoverride)..GLOBAL.PROTECTOR.MASTER..inst.components.protector.username
                end
            end
        end)
        if not TheWorld.ismastersim then
            return inst
        end
]]
        if inst.components.named == nil then
            inst:AddComponent("named")
        end

        -- 放置物 建造时设置名字
        if inst.prefab ~= nil then
            if GLOBAL.AllRecipes[inst.prefab] ~= nil then
                inst:ListenForEvent("onbuilt", onbuilt)
                if inst.components.pickable ~= nil and inst.components.prototyper ~= nil then
                    local function picked(inst,data)
                        if data and data.picker and data.loot then
                            if data.picker:HasTag("player") then
                                tool.SetName(data.loot,data.picker.name,data.picker.userid)
                            end
                        end
                    end
                    inst:ListenForEvent("picked", picked)
                end
            elseif inst.components.workable ~= nil and inst.components.workable.action == GLOBAL.ACTIONS.HAMMER then
                for k, v in pairs(GLOBAL.AllRecipes) do
                    if v.product == inst.prefab then
                        -- print("find")
                        inst:ListenForEvent("onbuilt", onbuilt)
                        break
                    end
                end
            end
        end
        --容器开关
        -- if inst.components.container ~= nil and inst:HasTag("structure") then
        --     if inst.components.machine == nil then
        --         inst:AddComponent("machine")
        --         inst.components.machine.cooldowntime = 1
        --         inst.components.machine.turnonfn = turnon
        --         inst.components.machine.turnofffn = turnoff
        --     end
        -- end
        inst:DoTaskInTime(.3,function ()
            -- 生长保存
            if inst.components.protector and inst.components.protector.userid ~= nil and (string.find(inst.prefab, "sapling") or string.find(inst.prefab, "bush") or string.find(inst.prefab, "winter") or inst:HasTag("flower")) and inst.components.deployable == nil and inst.components.inventoryitem == nil then
                inst:ListenForEvent("onremove",  function()
                    tool.ReSetName(inst)
                end)
            end
            if inst.prefab == "rock_ice" then -- 冰川
                if inst.components.timer and inst.components.protector and inst.components.protector.userid ~= nil then
                    if inst.components.timer:TimerExists("rock_ice_change") then
                        inst.components.timer:StopTimer("rock_ice_change")
                    end
                    local function StopTimer(inst)
                        inst:DoTaskInTime(.1,function ()
                            if inst.components.timer then
                                if inst.components.timer:TimerExists("rock_ice_change") then
                                    inst.components.timer:StopTimer("rock_ice_change")
                                end
                            end
                        end)
                    end
                    inst:WatchWorldState("cycles", StopTimer)
                end
            end
            -- 计时
            if GLOBAL.TUNING.PROTECTOR_TIME ~= 0 and inst.components.protector and inst.components.protector.userid ~= nil then
                inst:WatchWorldState("cycles", DoGameDataChanged)
            end
            --岩石宠物 --
            if inst.components.follower ~= nil and inst.components.protector then
                inst.components.protector.username = " "
                local leader = inst.components.follower.leader
                if leader and leader:HasTag("player") then
                    inst.components.protector.userid = leader.userid
                    inst.components.protector.username = leader.name
                    inst.components.protector.protectortime = 0
                    if inst.components.named and inst.components.named.name == nil then
                        inst.components.named:SetName(((inst.nameoverride ~= nil and STRINGS.NAMES[string.upper(inst.nameoverride)]) or inst.name) .. (leader.name ~= nil and (GLOBAL.PROTECTOR.MASTER .. leader.name) or ""))
                    end
                end
            end
        end)
        inst:DoTaskInTime(10,function ()
            if inst.components.protector and inst.components.protector.userid == nil and inst.components.protector.username == nil then
                inst:RemoveComponent("protector")
            end
        end)
    end
end)

AddComponentPostInit("deployable", function(self)
    local oldfn = self.Deploy
    self.Deploy = function (self, pt, deployer, ...)
        if not self:CanDeploy(pt, nil, deployer, ...) then
            return
        end
        -- local isplant = self.inst:HasTag("deployedplant")
        -- if not isplant then
        deployer:PushEvent("deployitem_pt", { pos = pt, prefabname = self.inst.prefab })
        -- end
        return oldfn(self, pt, deployer, ...)
    end
end)

-- 小妾 格罗姆等宠物权限监听
AddComponentPostInit("follower", function(self)
    local oldfn = self.SetLeader
    self.SetLeader = function (self, inst, ...)
        if inst ~= nil and inst._protector == nil and inst.components.inventoryitem ~= nil then
            inst._protector = true
            local container = inst.components.inventoryitem.owner
            if container and container:HasTag("player") then
                if self.inst.components.protector then
                    -- print("onputininventory",container.userid)
                    self.inst.components.protector.userid = container.userid
                end
            end
            inst:ListenForEvent("onputininventory", function (inst,owner)
                if owner and owner:HasTag("player") then
                    -- print("onputininventory")
                    if self.inst.components.protector then
                        self.inst.components.protector.userid = owner.userid
                    end
                else
                    if self.inst.components.protector then
                        self.inst.components.protector.userid = nil
                    end
                end
            end)
            inst:ListenForEvent("ondropped", function (inst)
                if self.inst.components.protector then
                    self.inst.components.protector.userid = nil
                end
            end)
        end
        oldfn(self, inst, ...)
    end
end)

------------------ 保留数据 ---------------------
if TheShard:GetShardId() == "1" or TheShard:GetShardId() == "0" then
    AddPrefabPostInit("world", function(inst)
        inst.save_info = {}
        inst:ListenForEvent("ms_newplayerspawned", function(inst, player)
            if inst.save_info[player.userid] ~= nil then
                if player.Protector_Load ~= nil then
                    player:Protector_Load(inst.save_info[player.userid])
                end
                inst.save_info[player.userid] = nil
            end
        end)
        inst:ListenForEvent("ms_playerdespawnanddelete", function(inst, player)
            inst.save_info[player.userid] = player.Protector_Save ~= nil and player:Protector_Save() or nil
        end)
    end)
end

local function can_destroy(inst)
    if inst.components.protector and inst.components.protector.userid ~= nil then
        -- 落叶树，常青树，带树枝树,墙
        if inst:HasTag("deciduoustree") or inst:HasTag("evergreens") or (inst:HasTag("renewable") and inst:HasTag("tree")) or inst:HasTag("wall")then
            return true
        end
        return false
    end
    return true
end

local components = {
    "inventory",
    "hunger",
    "sanity",
    "health",
    "moisture",
    "skinner",
    "rider",
    "temperature",
    "touchstonetracker",
}

local function coms(com)
    for _, v in pairs(components) do
        if com == v then return true end
    end
end

local persist = {
    "inlimbo",
    "ShowWardrobePopUp",
    "player_classified",
    "persists",
    "Light",
    "_isrezattuned",
    "Transform",
    "HUD",
    "sg",
    "MiniMapEntity",
    "ghostenabled",
    "GUID",
    "Network",
    "LightWatcher",
    "spawntime",
    "userid",
    "name",
    "prefab",
    "AnimState",
    "isplayer",
    "_sharksoundparam",
    "SoundEmitter",
    "Physics",
    "entity",
    "DynamicShadow",
    "soundsname",
    "components",
}

local function pers(per)
    for _, v in pairs(persist) do
        if per == v then return true end
    end
end

local function Save_Info(inst)
    -- local data ,refs = inst:GetPersistData()
    if  GetModConfigData("player_authority_SaveInfo") then
        local data = {}
        for k,v in pairs(inst.components) do
            if v.OnSave and not coms(k) then
                local t, refs = v:OnSave()
                if type(t) == "table" then
                    if t and next(t) and not data then
                        data = {}
                    end
                    if t and data then
                        data[k] = t
                    end
                end
            end
        end
        -- 除组件外建议手动保存
        for k,v in pairs(inst) do
            -- 保存大部分数据
            -- if not pers(k) and type(v) ~= "table" and type(v) ~= "function" and data[k] == nil then
            -- 	-- print("Save_Info---k:",k,"v:",v)
            --     data[k] = inst[k]
            -- end
            -- 保存少量数据
            if (type(v) == "boolean" or type(v) == "number") and not pers(k) and data[k] == nil then
                data[k] = inst[k]
            end
        end
        return data
    else
        local data = {
            playermanager = inst.components.playermanager ~= nil and inst.components.playermanager:OnSave() or nil,
        }
        return next(data) ~= nil and data or nil
    end
end

local function Load_Info(inst, data)
    -- inst:SetPersistData(data)
    if GetModConfigData("SaveInfo") then
        if data ~= nil then
            for k, v in pairs(data) do
                local cmp = inst.components[k]
                if cmp ~= nil and cmp.OnLoad ~= nil then
                    cmp:OnLoad(v)
                elseif data[k] ~= nil and inst[k] ~= nil then
                    inst[k] = data[k]
                end
            end
        end
    else
        if data.playermanager ~= nil and inst.components.playermanager ~= nil then
            inst.components.playermanager:OnLoad(data.playermanager)
        end
    end
end

AddPlayerPostInit(function(inst)
    inst.Protector_Save = Save_Info --换人保存
    inst.Protector_Load = Load_Info

------------------ end 保留数据 -------------------

    inst:AddComponent("playermanager")
    inst:ListenForEvent("deployitem_pt",function (inst,data)
        if data and data.pos then
            tool.ReSetName(nil, inst, data.pos)
        end
    end)
    if #inst.components.playermanager.link_userid == 0 then
        inst:DoTaskInTime(2,function () --需要延迟设置玩家id
            inst.components.playermanager:AddPlayer(inst.userid)
        end)
    end
end)

local function GetPlayerById(playerid)
    for k, v in ipairs(GLOBAL.AllPlayers) do
        if v ~= nil and v.userid and v.userid == playerid then
            return v
        end
    end
    return nil
end

local function CheckAdminId(id)
    for _, adminid in pairs(GLOBAL.TUNING.PROTECTOR_PLAYERS) do
        if id == adminid then
            return true
        end
    end
    return false
end

local OldNetworking_Say = GLOBAL.Networking_Say ---利用不同世界都能得到玩家说的话来对不在同一个世界的人进行添加权限
GLOBAL.Networking_Say = function(guid, userid, name, prefab, message, colour, whisper, isemote)-- guid 是当前世界实体id 在其他世界为0，表示不存在
    local master = GetPlayerById(userid)  -- 得到玩家   AllPlayers 当前世界的玩家，不等于服务器所有玩家
    if string.sub(message,1,1) == "#" then
        local cmd = string.sub(message,1,4)
        local nums = {}
        if master then
            if string.lower(message) == "#_clean" and CheckAdminId(master.userid) then
                local x, y, z= master.Transform:GetWorldPosition()
                local ents = TheSim:FindEntities(x, y, z, GLOBAL.TUNING.UNPROTECTOR_AREA, { "protected" }, { "INLIMBO" })
                for _, ent in pairs(ents) do
                    if ent.components.protector and ent.components.protector.userid ~= nil and not CheckAdminId(ent.components.protector.userid) then
                        if ent.components.named then
                            ent.components.named:SetName(GLOBAL.PROTECTOR.UNPROTECTED ..(ent.components.named.name and ent.components.named.name or ""))
                        end
                        ent.components.protector.userid = nil
                    end
                end
            end
            if string.lower(message) == "#stack" and GetModConfigData("stack") == true then
                local pt = master:GetPosition()
                tool.AutoStack(pt)
                return OldNetworking_Say(guid, userid, name, prefab, message, colour, whisper, isemote)
            end
        end
        if message:len() < 5 then return OldNetworking_Say(guid, userid, name, prefab, message, colour, whisper, isemote) end
        -- 是否有字符串
        for num in string.gmatch(string.sub(message,5,-1), "%S+") do
            if not tonumber(num) then return OldNetworking_Say(guid, userid, name, prefab, message, colour, whisper, isemote) end
            table.insert(nums, num)
        end

        -- 去重
        local transTbl = {}
        for _, v in pairs(nums) do
            transTbl[v] = true
        end
        local finalTbl = {}
        for k, v in pairs(transTbl) do
            table.insert(finalTbl, tonumber(k))
        end

        -- 二次判断
        local IsDedicated = 0
        if TheNet:GetClientTable() == nil then return OldNetworking_Say(guid, userid, name, prefab, message, colour, whisper, isemote) end
        if TheNet:GetClientTable()[1] and TheNet:GetClientTable()[1].performance ~= nil then
            IsDedicated = 1
        end
        for _,v in pairs(finalTbl) do
            local n = v
            if n <= 0 then
                -- print("输入数字小于等于零")
                return OldNetworking_Say(guid, userid, name, prefab, message, colour, whisper, isemote)
            elseif  TheNet:GetClientTable() ~= nil and n > #TheNet:GetClientTable() - IsDedicated then
                -- print("输入数字大于玩家数量")
                return OldNetworking_Say(guid, userid, name, prefab, message, colour, whisper, isemote)
            elseif TheNet:GetClientTable() ~= nil then--n == GetPlayerNumById(master.userid)
                for k,ply in pairs(TheNet:GetClientTable()) do
                    if ply.userid == userid and n + IsDedicated == k then
                        -- print("自己")
                        return OldNetworking_Say(guid, userid, name, prefab, message, colour, whisper, isemote)
                    end
                end
            end
        end

        local str = ""
        local player = nil
        if cmd == "#add" then
            for _,v in pairs(finalTbl) do
                for k,a in pairs(TheNet:GetClientTable()) do -- 从Tab中查找该玩家是否在当前世界
                    -- print(string.format("%s[%d] (%s) %s <%s>", a.admin and "*" or " ", index, a.userid, a.name, a.prefab))
                    -- print("k--v",k,v)
                    if v == k - IsDedicated then
                        player = GetPlayerById(a.userid)
                        if a.name then
                            str = a.name.." "..str
                            break
                        end
                    end
                end
                if player and player.components then
                    -- print("player",player.name)
                    if player.components.playermanager and player.components.playermanager:AddPlayer(userid)then
                        -- str = player.name.." "..str
                        -- success = true
                        player:DoTaskInTime(.01, function ()
                            if player and player.components then -- 延迟还要再进行判断
                                player.components.talker:Say(GLOBAL.PROTECTOR.PERMISSION2 .. name .. GLOBAL.PROTECTOR.PERMISSION3)
                            end
                        end)
                    end
                end
            end
            if str:len() > 1 and master then
                master:DoTaskInTime(.01, function ()
                    master.components.talker:Say(GLOBAL.PROTECTOR.PERMISSION4..str)
                end)
            end
            return OldNetworking_Say(guid, userid, name, prefab, message, colour, whisper, isemote)
        end
        if cmd == "#del" then
            for _,v in pairs(finalTbl) do
                for k,a in pairs(TheNet:GetClientTable()) do
                    if v == k - IsDedicated then
                        player = GetPlayerById(a.userid)
                        if a.name then
                            str = a.name.." "..str
                            break
                        end
                    end
                end
                if player and player.components then
                    if player.components.playermanager and player.components.playermanager:DelPlayer(userid) then
                        player:DoTaskInTime(.01, function ()
                            if player and player.components then
                                player.components.talker:Say(name .. GLOBAL.PROTECTOR.PERMISSION5)
                            end
                        end)
                    end
                end
            end
            if str:len() > 1 and master then
                master:DoTaskInTime(.01, function ()
                    master.components.talker:Say(GLOBAL.PROTECTOR.PERMISSION6..str..GLOBAL.PROTECTOR.PERMISSION3)
                end)
            end
            return OldNetworking_Say(guid, userid, name, prefab, message, colour, whisper, isemote)
        end
    end
    return OldNetworking_Say(guid, userid, name, prefab, message, colour, whisper, isemote)
end
---------------------------- All Action-------------------------------
local function check(prefab)
    for key, value in pairs(GLOBAL.TUNING.PROTECTOR_ITEMS) do
        if prefab.prefab == value then
            return true
        end
    end
end
local function doer_is_near_outof_area(doer)
    local x,y,z = doer.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities( x, y, z, GLOBAL.TUNING.UNPROTECTOR_AREA, nil, { "INLIMBO" })
    for k, v in pairs(ents) do
        if check(v) then
            return true
        end
    end
end
local CanDoActions = {
    "ATTACK",
    "EAT",
    "LOOKAT",
    "COOK",
    -- "BUILD",
    "EQUIP",
    "UNEQUIP",
    --"TURNON",
    -- "PICKUP",
    "DROP",
    --"TURNOFF",
    "DESTINATION_UI",
    "DESTINATION",
}
local function checAction(act)
    for _, action in pairs(CanDoActions) do
        if action == act then
            return false
        end
    end
    return true
end
local old_attackfn = GLOBAL.ACTIONS.ATTACK.fn
GLOBAL.ACTIONS.ATTACK.fn = function (act)
    local target = act.target or act.invobject
    local doer = act.doer
    if target ~= nil and doer ~= nil and doer:HasTag("player") then
        if target.components.protector ~= nil then
            if target.components.protector.userid ~= nil then
                if doer_is_near_outof_area(doer) then
                    return old_attackfn(act)
                end
                if tool.CheckPlayer(doer) then
                    return old_attackfn(act)
                end
                local link_id = doer.components.playermanager.link_userid
                for _ ,v in pairs(link_id) do
                    if v == target.components.protector.userid then
                        return old_attackfn(act)
                    end
                end
                if doer.components.talker then
                    doer:DoTaskInTime(0.01,function()
                        doer.components.talker:Say(GLOBAL.PROTECTOR.PERMISSION1)
                    end)
                end
                return false
            end
        end
    end
    return old_attackfn(act)
end
--local old_turnonfn = GLOBAL.ACTIONS.TURNON.fn
--GLOBAL.ACTIONS.TURNON.fn = function(act)
--    local doer = act.doer
--    local target = act.target or act.invobject
--    if doer ~= nil and doer:HasTag("player") and target ~= nil then
--        if target.components.protector and target.components.protector.userid ~= nil then
--            if target.components.protector.userid == doer.userid and not doer_is_near_outof_area(target) then
--                doer:DoTaskInTime(0.01,function()
--                    doer.components.talker:Say(GLOBAL.PROTECTOR.PERMISSION7 .. (target.nameoverride ~= nil and STRINGS.NAMES[string.upper(target.nameoverride)] or target.name))
--                end)
--                return old_turnonfn(act)
--            elseif not doer_is_near_outof_area(target) then
--                doer:DoTaskInTime(0.01,function()
--                    doer.components.talker:Say(GLOBAL.PROTECTOR.PERMISSION1)
--                end)
--            end
--            return false
--        end
--    end
--    return old_turnonfn(act)
--end
--local old_turnofffn = GLOBAL.ACTIONS.TURNOFF.fn
--GLOBAL.ACTIONS.TURNOFF.fn = function(act)
--    local doer = act.doer
--    local target = act.target or act.invobject
--    if doer ~= nil and doer:HasTag("player") and target ~= nil then
--        if target.components.protector and target.components.protector.userid ~= nil then
--            if target.components.protector.userid == doer.userid and not doer_is_near_outof_area(target) then
--                doer:DoTaskInTime(0.01,function()
--                    doer.components.talker:Say(GLOBAL.PROTECTOR.PERMISSION8 ..(target.nameoverride ~= nil and STRINGS.NAMES[string.upper(target.nameoverride)] or target.name))
--                end)
--                return old_turnofffn(act)
--            elseif not doer_is_near_outof_area(target) then
--                doer:DoTaskInTime(0.01,function()
--                    doer.components.talker:Say(GLOBAL.PROTECTOR.PERMISSION1)
--                end)
--                return false
--            end
--        end
--    end
--    return old_turnofffn(act)
--end

if GetModConfigData("player_authority_canburnable") then
    -- 给点燃动作添加一个执行者
    GLOBAL.ACTIONS.LIGHT.fn = function(act)
        if act.invobject ~= nil and act.invobject.components.lighter ~= nil then
            if act.doer ~= nil then
                act.doer:PushEvent("onstartedfire", { target = act.target })
                act.invobject.components.lighter:Light(act.target, act.doer)
                return true
            end
            act.invobject.components.lighter:Light(act.target)
            return true
        end
    end
    AddComponentPostInit("lighter", function(self)
        self.Light = function (self, target, doer)
            if target.components.burnable ~= nil and not ((target:HasTag("fueldepleted") and not target:HasTag("burnableignorefuel")) or target:HasTag("INLIMBO")) then
                target.components.burnable:Ignite(nil, nil, doer)
                if self.onlight ~= nil then
                    self.onlight(self.inst, target)
                end
            end
        end
    end)
    AddComponentPostInit("burnable", function(self)
        -- 进入绝对防火状态 除了用火把点燃
        local OldIgniten = self.Ignite
        self.Ignite = function (self, immediate, source, doer, ...)
            if (doer == nil or not (doer and doer:HasTag("player"))) and not can_destroy(self.inst) then
                if not (self.burning or self.inst:HasTag("fireimmune")) then
                    self:StopSmoldering()
                    -- print("野火烧不尽，春风吹又生!!!!!!!!!!!!!!!!!!!!!!!!!!!")
                    return
                end
            else
                OldIgniten(self, immediate, source, doer, ...)
            end
        end
    end)
end

for k, action in pairs(GLOBAL.ACTIONS) do
    if checAction(k) == true then
        local old_fn = action.fn
        if old_fn then
            action.fn = function(act)
                local doer = act.doer
                local target = act.target or act.invobject
                local inject = act.invobject
                local pt = act:GetActionPoint()
                local recipe = act.recipe
                -- local rot = act.rotation
                if doer ~= nil and doer:HasTag("player") then
                    -- print(k,"action",act,"doer",doer,"target",target,"pt",pt,"inject",inject)
                    if doer_is_near_outof_area(doer) then
                        if string.find(k, "PLANT") then
                            tool.ReSetName(nil, doer,pt)
                        end
                        return old_fn(act)
                    end
                    if tool.CheckPlayer(doer) then
                        if string.find(k, "PLANT") then
                            tool.ReSetName(nil, doer,pt)
                        end
                        return old_fn(act)
                    end
                    if target ~= nil then
                        if target.components.protector ~= nil and target.components.protector.userid ~= nil then
                            local ACT = k
                            if target.components.protector.isprotected == false and ACT == "BUMMAGE" then
                                return old_fn(act)
                            end
                            local link_id = doer.components.playermanager.link_userid
                            for _ ,v in pairs(link_id) do
                                if v == target.components.protector.userid then
                                    return old_fn(act)
                                end
                            end
                            if doer.components.talker then
                                doer:DoTaskInTime(0.01,function()
                                    doer.components.talker:Say(GLOBAL.PROTECTOR.PERMISSION1)
                                    if doer.sg ~= nil then
                                        doer.sg:GoToState("idle")
                                    end
                                end)
                            end
                            return false
                        end
                        return old_fn(act)
                    end
                    if recipe and GetValidRecipe(recipe) then
                        local product = SpawnPrefab(GetValidRecipe(recipe).product)
                        if product ~= nil then
                            if product.components.inventoryitem ~= nil then
                                product:Remove()
                                return old_fn(act)
                            end
                            product:Remove()
                        end
                    end
                    if tool.CanDo(pt, doer, target) then
                        if string.find(k, "PLANT") then
                            tool.ReSetName(target, doer,pt)
                        end
                        return old_fn(act)
                    else
                        if doer.components.talker then
                            doer:DoTaskInTime(0.01,function()
                                doer.components.talker:Say(GLOBAL.PROTECTOR.PERMISSION1)
                                if doer.sg ~= nil then
                                    doer.sg:GoToState("idle")
                                end
                            end)
                        end
                        return false
                    end
                end
                return old_fn(act)
            end
        end
    end
end

-- 淦：法杖传送动作要手动加！！！！
AddComponentPostInit("blinkstaff", function(self)
    local oldBlink = self.Blink
    self.Blink = function (self, pt, caster, ...)
        if pt ~= nil and caster ~= nil and caster:HasTag("player") then
            if doer_is_near_outof_area(caster) then
                return oldBlink(self, pt, caster)
            end
            if tool.CheckPlayer(caster) then
                return oldBlink(self, pt, caster)
            end
            if not tool.CanDo(pt, caster) then
                caster:DoTaskInTime(.1, function ()
                    caster.components.talker:Say(GLOBAL.PROTECTOR.PERMISSION1)
                    if caster.sg ~= nil then
                        caster.sg:GoToState("idle")
                    end
                end)
                return false
            end
        end
        return oldBlink(self, pt, caster, ...)
    end
end)
---------------------------End All Action------------------------------


-----------------------------防破坏-------------------------------------
AddComponentPostInit("workable", function(self)
    local oldWorkedBy = self.WorkedBy
    self.WorkedBy = function (self, worker, ...)
        if worker ~= nil and not (worker:HasTag("player") or worker:HasTag("boat")) and not can_destroy(self.inst) then
            return
        end
        oldWorkedBy(self, worker, ...)
    end
end)
--燃烧
AddComponentPostInit("burnable", function(self)
    local Oldfn = self.StartWildfire
    self.StartWildfire = function (self, ...)
        if not can_destroy(self.inst) then
            -- print("野火烧不尽，春风吹又生!!!!!!!!!!!!!!!!!!!!!!!!!!!")
        else
            Oldfn(self, ...)
        end
    end
end)
-- 改一下巨鹿脑子,让它不再攻击有权限的建筑
AddBrainPostInit("deerclopsbrain", function(self)
    if self.bt.root.children[3] ~= nil and self.bt.root.children[3].getactionfn ~= nil then
        self.bt.root.children[3].getactionfn = function(inst)
            if inst.components.knownlocations:GetLocation("targetbase") then
                local target = FindEntity(inst, 80, function(item)  -- 范围大一点
                        if item.components.workable and item:HasTag("structure")
                                and item.components.workable.action == ACTIONS.HAMMER
                                and item:IsOnValidGround()
                                and not(item.components.protector ~= nil and item.components.protector.userid ~= nil)then
                            return true
                        end
                    end, nil, "wall")
                if target then
                    return BufferedAction(inst, target, ACTIONS.HAMMER)
                end
            end
        end
    end
end)
----------------------------END 防破坏-------------------------------------


