--摘自风铃服务器活动mod
ONLINENAME = "系统通知"

if TheNet:GetIsServer() then
    OnlineDB = CreateMainDB("FLOnline", 300, 1)
    OnlineDB:InitRoot("Info") -- 玩家信息 
    OnlineDB:InitRoot("WorldName") -- 玩家信息 
    --[[id = {id = ,
        name = ,
        worldid = ,
        prefab = 
        ]]
    function GetPlayerInfo(userid, def)
        return OnlineDB:Get("Info", userid, def or {})
    end
    function SetPlayerInfo(userid, val)
        return OnlineDB:Set("Info", userid, val)
    end

    function GetPlayerTime(userid, def)
        return OnlineDB:Get("Games", userid, def or {})
    end
    function SetPlayerTime(userid, val)
        return OnlineDB:Set("Games", userid, val)
    end
    function GetPlayerCDK(userid, def)
        return OnlineDB:Get("CDKS", userid, def or {})
    end
    function SetPlayerCDK(userid, val)
        return OnlineDB:Set("CDKS", userid, val)
    end

    OnlineDB:InitRoot("Games") -- 玩家游玩时长

    OnlineDB:InitRoot("playerSave", 3)

    AddPrefabPostInit("world", function(inst)
        if TheWorld.ismastershard then
            -- 监听玩家重生之后 判定有保存得信息 给他覆盖回去
            inst:ListenForEvent("ms_newplayerspawned", function(world, player)
                print("playernewspawn", player, player.name, player.userid, player.skinname)
                if player and player.userid and player:IsValid() then
                    local skinname = player.skinname
                    local save = OnlineDB:Get("playerSave", player.userid)
                    if save then -- 有存档那么覆盖！
                        if save.forrereoll then
                            if player.LoadForReroll ~= nil then
                                player:LoadForReroll(save)
                            end
                        else
                            player:SetPersistData(save.data, {})
                            -- if save.data.save_maps ~= nil and player.player_classified ~= nil and
                            --     player.player_classified.MapExplorer ~= nil then
                            --     player.player_classified.MapExplorer:LearnAllMaps(save.data.save_maps)
                            -- end
                        end
                    end
                    player.skinname = skinname
                end
            end)
        end
        inst.sendtomasttask = CreateTaskList()
        TheWorld:DoPeriodicTask(1, function()
            TheWorld.sendtomasttask:PopTask()
        end)

        inst:WatchWorldState("cycles", function()
            inst:DoTaskInTime(30 + math.random() + math.random(1, 10), function()
                for k, v in pairs(AllPlayers) do
                    if v and v.SendSaveToMaster then
                        v:SendSaveToMaster()
                    end
                end
            end)
        end)
        inst:ListenForEvent("ms_playerdespawnanddelete",
            function(inst, player) -- 重选人 -如果是正常出发 那么需要移除保存的内容咯
                if player and player.userid then
                    local id = player.userid
                    local data = player:SaveForReroll()
                    data.forrereoll = 1
                    local re1, re2 = OnlineDB:PushEvent("playersave", {
                        type = "remove",
                        id = id,
                        save = data
                    }, 1)
                end
            end)
    end)

    local old_SerializeUserSession = GLOBAL.SerializeUserSession
    GLOBAL.SerializeUserSession = function(player, isnewspawn, ...) -- 跳世界 序列化存档的时候存一份
        if not isnewspawn and player ~= nil and player.userid ~= nil and player.userid:len() > 0 and player.migration and
            player.SendSaveToMaster then
            player:SendSaveToMaster()
        end
        return old_SerializeUserSession(player, isnewspawn, ...)
    end

    OnlineDB:ListenForEvent("playersave", function(id, data)
        if data then
            if data.type == "save" and data.id then
                print("接受到玩家数据", "save", data.id)
                OnlineDB:Set("playerSave", data.id, data.save)
                -- 没什么卵用
                -- local save = DataDumper(data.save,nil,true) 
                -- local metadataStr = DataDumper({prefab = data.save.prefab}) 
                -- TheNet:SerializeUserSession(data.id, save, false, nil, metadataStr)
            elseif data.type == "remove" and data.id then
                print("接受到玩家数据", "remove", data.id)
                OnlineDB:Set("playerSave", data.id, data.save)
            end
        end
    end)

    local function SendSaveToMaster(inst)
        local save = inst:GetSaveRecord()
        local id = inst.userid
        local name = inst.name
        -- local maps = inst.player_classified ~= nil and inst.player_classified.MapExplorer ~= nil and
        --                  inst.player_classified.MapExplorer:RecordAllMaps() or nil
        -- save.data.save_maps = maps
        local function func()
                print("推送玩家数据", name, id)
                OnlineDB:PushEvent("playersave", {
                    type = "save",
                    id = id,
                    save = save
                }, 1)
        end
        TheWorld.sendtomasttask:PushTask(func,"")
    end
    AddPlayerPostInit(function(inst)
        if not TheWorld.ismastersim then
            return inst
        end
        inst.SendSaveToMaster = SendSaveToMaster
    end)

    AddPrefabPostInit("world", function(inst)
        SerDB.OnlineDB = OnlineDB

        inst.components.OnlineDB = SerDB.OnlineDB
        SerDB.OnlineDB.inst = inst

        -- inst:ListenForEvent("ms_playerdespawnandmigrate",function (inst,data) end)      --跳世界  不需要处理 因为目标世界会发送上线
        inst:ListenForEvent("ms_playerdespawnanddelete", function(i, doer)
            local id = doer.userid
            print("ms_playerdespawnanddelete", id)
            if id and id:match("[OKR]U_") then
                local info = {
                    id = id,
                    name = doer.name,
                    worldid = -2,
                    prefab = "选择人物中"
                }
                SetPlayerInfo(id, info)
            end
        end) -- 重新选人
        inst:ListenForEvent("ms_playerdisconnected", function(i, data)
            local doer = data.player
            if not doer then
                return
            end

            local id = doer.userid
            if id and id:match("[OKR]U_") then
                local info = {
                    id = id,
                    name = doer.name,
                    worldid = -1,
                    prefab = doer.prefab
                }
                SetPlayerInfo(id, info)
            end
        end) -- 玩家下线

        inst:ListenForEvent("ms_playerjoined", function(i, doer)
            local id = doer.userid
            doer:DoTaskInTime(10, function()
                local newdata = {}
                local all = OnlineDB:GetRoot("WorldName")
                for k, v in pairs(all) do
                    table.insert(newdata, {
                        id = k,
                        name = v
                    })
                end
                local db = GetClientDB("FLOnline", id, true)
                if db then
                    db:PushEvent("worldset", {
                        world = newdata
                    })
                end
            end)
            if id and id:match("[OKR]U_") then
                local info = {
                    id = id,
                    name = doer.name,
                    worldid = TheShard:GetShardId(),
                    prefab = doer.prefab
                }
                SetPlayerInfo(id, info)
            end
        end)
    end)
    local function GameOK(inst)
        inst.gametime = 30
    end
    local function GameCheck(inst)
        inst.flisgame = true
        -- 坐标检查
        -- 动作检查 
        local rang = inst:GetDistanceSqToPoint(inst.lastpos)
        inst.lastpos = inst:GetPosition()
        if rang > 1 then
            inst.gametime = math.min(inst.gametime + 1, 30)
        else
            inst.gametime = math.max(inst.gametime - 1, -5)
        end
        if inst.gametime < 5 then
            inst.flisgame = false
        else
            inst.flisgame = true
        end
    end
    OnlineDB:ListenForEvent("TimeUpdate", NextFrame(function(id, data)
        if data.userid and data.prefab and data.name then
            local info = GetPlayerInfo(data.userid)
            if not info.id then
                return
            end
            local time = GetPlayerTime(data.userid)
            if not time[data.prefab] then
                time[data.prefab] = {}
            end
            time[data.prefab].time = ((time[data.prefab].time) or 0) + 1
            SetPlayerTime(data.userid, time)
        end
    end))


    AddPlayerPostInit(function(inst)
        inst.flisgame = true
        inst.gametime = 30
        inst.lastpos = Point(0, 0, 0)
        inst:ListenForEvent("builditem", GameOK)
        inst:ListenForEvent("buildstructure", GameOK)
        inst:ListenForEvent("tilling", GameOK)
        inst:ListenForEvent("killed", GameOK)
        inst:ListenForEvent("cookitem", GameOK)
        inst:ListenForEvent("working", GameOK)
        inst:ListenForEvent("repair", GameOK)
        inst:ListenForEvent("fishingcollect", GameOK)
        inst:ListenForEvent("deployitem", GameOK)
        inst:ListenForEvent("picksomething", GameOK)
        inst:ListenForEvent("harvestsomething", GameOK)
        inst:DoPeriodicTask(1, GameCheck)
        inst:DoPeriodicTask(60, TimeUpdate)
    end)

    OnlineDB:ListenForEvent("msgto", function(id, data, event)
        if data and data.userid and data.msg then
            local user = UserToPlayer(data.userid)
            if user then
                local db = GetClientDB("FLOwner", data.userid, true)
                if db then
                    db:PushEvent("msg", {
                        msg = data.msg
                    })
                end
            end
        end
    end)

    OnlineDB:ListenForEvent("WorldNameUpdate", function()
        local newdata = {}
        local all = OnlineDB:GetRoot("WorldName")
        for k, v in pairs(all) do
            table.insert(newdata, {
                id = k,
                name = v
            })
        end
        for k, v in pairs(AllPlayers) do
            local db = GetClientDB("FLOnline", v.userid, true)
            if db then
                db:PushEvent("worldset", {
                    world = newdata
                })
            end
        end
    end)

    function EditedWorldName(id, wid, name)
        if not (wid and name) then
            return false, "参数不正确"
        end
        if not (TUNING.MWP and TUNING.MWP.WORLDS) then
            return false, "未开启多层世界选择器"
        end
        OnlineDB:PushEvent("WorldNameUpdate")
        OnlineDB:Set("WorldName", wid, name)
        return false, "设置成功"
    end

    function NewCDK(id, name, cdk, src)
        local doer = UserToPlayer(id)
        if not (name and cdk and src) then
            return false, "格式不对"
        end
        local a = SpawnPrefab("flcdk")
        a.data = {
            name = name,
            cdk = cdk,
            src = src
        }
        doer.components.inventory:GiveItem(a, nil, doer:GetPosition())
        return true, "生成成功"
    end
end

function GetPlayerOnLineInfo(userid)
    local one = {}
    one.name = ""

    one.userid = userid
    one.prefab = "选择人物中"
    one.online = "离线"
    local info = GetPlayerInfo(userid, {})
    if info.prefab then
        one.prefab = info.prefab
        one.name = info.name
        one.online = info.worldid
        if one.online == -1 then
            one.online = "离线"
        end
        if one.online == -2 then
            one.online = ""
        end
    end
    local p = UserToPlayer(userid)
    if p then
        one.name = p.name
        one.userid = userid
        one.prefab = p.prefab
        one.online = GetWorldName(TheShard:GetShardId())
    end
    return one
end

local temp = CreateClientDBTemple("FLOnline", 300, 1)
temp:InitRoot("Info") -- 发送回来的信息 
temp:InitRoot("World") -- 发送回来的信息 
temp.serverfn = function(ns, db, userid)
    db:ListenForEvent("Admin", function(id, data, event) -- 获取信息用 
        if type(data) ~= "table" then
            return
        end
        local cmd = data.cmd
        if type(cmd) ~= "string" then
            return
        end
        if not IsSuperAdmin(id) then
            return
        end
        if cmd == "WorldName" then
            local x, y = EditedWorldName(id, data.wid, data.name)
            db:PushEvent("msg", {
                msg = y
            })
            return
        end
        if cmd == "NewCDK" then
            local x, y = NewCDK(id, data.name, data.cdk, data.src)
            db:PushEvent("msg", {
                msg = y
            })
            return
        end
    end)
    db:ListenForEvent("UpdateInfo", function(id, data, event) -- 获取信息用 
        if type(data) ~= "table" then
            return
        end
        local cmd = data.cmd
        if type(cmd) ~= "string" then
            return
        end
    end)

end
local contolui = nil
temp.clientfn = function(ns, db, userid)
    ODB = db -- 用于客户端取数据
    CliDB.OWNCDB = ODB
    db:ListenForEvent("msg", function(id, data, event)
        if data and data.msg then
            PushConfirmPopupDialog(ONLINENAME, data.msg)
        end
    end)
    db:ListenForEvent("worldset", function(id, data, event)
        if TUNING.MWP and TUNING.MWP.WORLDS then
            for k, v in pairs(data.world) do
                if TUNING.MWP.WORLDS[v.id] then
                    TUNING.MWP.WORLDS[v.id].name = v.name
                end
            end
            TheWorld.worldname = TUNING.MWP.WORLDS[TheWorld.worldid].name
            if contolui and contolui.world_name and contolui:IsVisible() then
                contolui.world_name:SetText(TheWorld.worldname or "??????", false, {-1, -1})
            end
        end
    end)
end