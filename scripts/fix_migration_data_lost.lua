GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})
----------------------------------------------------------------------------------------尝试 解决玩家 跳世界 后 目标世界未保存 崩溃后 玩家丢档问题
AddShardModRPCHandler("null_migration", "session", function(worldid, userid)
    TheWorld:DoTaskInTime(5,function()
        local user_session = TheNet:GetUserSessionFile(TheWorld.meta.session_identifier, userid)
        if user_session == nil then return end
        local start = string.find(user_session, "/", -15)
        local num = string.sub(user_session,start+1,#user_session)
        if tonumber(num) == TheNet:GetCurrentSnapshot() and num-1>1 then
            TheNet:DeserializeUserSession(user_session, function(success, str)
                if success and str ~= nil and #str > 0 then
                    TheSim:SetPersistentString(string.sub(user_session,1,start)..string.format("%0"..#num.."d",num-1), str, false)
                    local user = {}
                    TheSim:GetPersistentString(TheWorld.meta.session_identifier , function(get, user_table)
                        if get and user_table then
                            local status, user_table = RunInSandbox(user_table)
                            if status and user_table ~= nil and GetTableSize(user_table) > 0 then user = user_table end
                        end
                    end)
                    if user[num - 1] == nil then user[num - 1] = {} end
                    table.insert(user[num - 1], userid)
                    TheSim:SetPersistentString("session/"..TheWorld.meta.session_identifier.."/userdata", DataDumper(user, nil, true) , false)
                end
            end)
        end
    end)
end)


local old_StartMigration = TheShard.StartMigration
getmetatable(TheShard).__index["StartMigration"] = function(self, userid, worldid, ...)
    old_StartMigration(self, userid, worldid, ...)
    SendModRPCToShard(GetShardModRPC("null_migration","session"), worldid, userid)
end

local old_TruncateSnapshots = TheNet.TruncateSnapshots
getmetatable(TheNet).__index["TruncateSnapshots"] = function(self, ...)

    old_TruncateSnapshots(self, ...)
    local user = {}
    TheSim:GetPersistentString("session/"..TheWorld.meta.session_identifier.."/userdata", function(get, user_table)
        if get and user_table then
            local status, user_table = RunInSandbox(user_table)
            if status and user_table ~= nil and GetTableSize(user_table) > 0 then user = user_table end
        end
    end)

    if user[TheNet:GetCurrentSnapshot()] then
        local userdata
        local userdatastr
        for _,v in pairs(user[TheNet:GetCurrentSnapshot()]) do
            TheSim:GetPersistentString(TheNet:GetUserSessionFile(TheWorld.meta.session_identifier, v) , function(get, user_datastr)
                if get and user_datastr then
                    local status, user_data = RunInSandbox(user_datastr)
                    if status and user_data ~= nil and GetTableSize(user_data) > 0 and user_data.prefab then
                        userdatastr = user_datastr userdata = user_data
                    end
                end
            end)
            if userdatastr then
                TheNet:SerializeUserSession(v, userdatastr, false, nil, DataDumper({character = userdata.prefab,}, nil, BRANCH ~= "dev"))
                userdatastr = nil userdata = nil
            end
        end
    end
    print("-----fixuser_session:"..TheNet:GetCurrentSnapshot())
    dumptable(userdata)

end

