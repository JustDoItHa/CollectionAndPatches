if not GLOBAL.TheNet:GetIsServer() then 
    return
end

print("Mod Load: respawnnear.lua")

local Vector3 = GLOBAL.Vector3
local SpawnPrefab = GLOBAL.SpawnPrefab

local repsawn_time = GetModConfigData("respawntime") * 480

local respawn_list = {
    "beefalo",
    "lightninggoat",
    "spiderden",
    "catcoonden",
    "knight",
    "rocky",
    "slurtlehole",
}

local leastnum = {}
for k,v in pairs(respawn_list) do
    leastnum[v] = GetModConfigData("leastnum_"..v)
end

for k,v in pairs(respawn_list) do
    local function PushDeathEvent(inst)
        inst:ListenForEvent("onremove", function(inst)
            local current_num = GLOBAL.c_countprefabs(v, true)
            if current_num < leastnum[v] then
                local pos = Vector3(inst.Transform:GetWorldPosition())
                GLOBAL.TheWorld:PushEvent(v.."_death", {name = v, pos = pos})
            end
        end)
    end
    AddPrefabPostInit(v, PushDeathEvent)
end

local function OnRecieveDeathEvent(inst)
    inst:AddComponent("timer")

    if inst.spawnlist == nil then
        inst.spawnlist = {}
    end

    for k,v in pairs(respawn_list) do
        inst:ListenForEvent(v.."_death", function(inst,data)
            table.insert(inst.spawnlist, data)
            local i = 0
            while inst.components.timer:TimerExists(v.."_"..i)
            do
                i = i + 1
            end
            inst.components.timer:StartTimer(v.."_"..i, repsawn_time)
            print("StartTimer", v.."_"..i)
        end, GLOBAL.TheWorld)
    end

    local function ontimerdone(inst, data)
        for k,v in pairs(inst.spawnlist) do
            if v.name == string.split(data.name, "_")[1] then
                local pos = v.pos
                local result_pos = GLOBAL.FindNearbyLand(pos, 15) or pos
                local tryspawn = SpawnPrefab(v.name)
                tryspawn.Transform:SetPosition(result_pos:Get())
                print(v.name, 'spawned at', result_pos.x, result_pos.z)
                --GLOBAL.dumptable(inst.spawnlist)
                table.remove(inst.spawnlist, k)
                --GLOBAL.dumptable(inst.spawnlist)
                break
            end
        end
    end

    inst:ListenForEvent("timerdone", ontimerdone)

    local on_onsave = inst.OnSave
    local old_onload = inst.OnLoad

    inst.OnSave = function(inst2, data2)
        if old_onsave then
            old_onsave(inst2, data2)
        end
        data2.spawnlist = inst.spawnlist
    end

    inst.OnLoad = function(inst2, data2)
        if old_onload then
            old_onload(inst2, data2)
        end
        inst2.spawnlist = data2 ~= nil and data2.spawnlist or {}
    end

end

AddPrefabPostInit("world", OnRecieveDeathEvent)