local unknown = "???"
local function SetName(inst, target)
    if inst and inst:IsValid() and target and target:IsValid() then
        inst.playername:set(target.name or target:GetDisplayName() or unknown)
    end
end
local function UpdatePosition(inst, target)
    local x, y, z = target.Transform:GetWorldPosition()
    if inst._x ~= x or inst._z ~= z then
        inst._x = x
        inst._z = z
        inst.Transform:SetPosition(x, 0, z)
    end
end

local function TrackEntity(inst, target, restriction, icon)
    if restriction ~= nil then
        inst.MiniMapEntity:SetRestriction(restriction)
    end
    if icon ~= nil then
        inst.MiniMapEntity:SetIcon(icon)
    elseif target.MiniMapEntity ~= nil then
        inst.MiniMapEntity:CopyIcon(target.MiniMapEntity)
    else
        inst.MiniMapEntity:SetIcon(target.prefab .. ".png")
    end
    SetName(inst, target)
    target:ListenForEvent("playeractivated", function()
        SetName(inst, target)
    end)
    inst:DoTaskInTime(1, function()
        SetName(inst, target)
    end)
    inst:ListenForEvent("onremove", function()
        inst:Remove()
    end, target)
    inst:DoPeriodicTask(TUNING.PLAYERPOSITIONS_INTERVAL or 0.1, UpdatePosition, nil, target)
    UpdatePosition(inst, target)
end
local function fn()
    local inst = Prefabs.globalmapicon.fn()
    if inst.TrackEntity then
        inst.TrackEntity = TrackEntity
    end
    -- inst.MiniMapEntity:SetIsProxy(false)
    inst.playername = net_string(inst.GUID, "playername", "playernamedirty")
    inst.playername:set("")
    if not TheNet:IsDedicated() then
        inst.OnNameChange = function(inst)
            -- print("name changed to " .. inst.playername:value())
            if GLOBALPLAYERPOSITIONS[inst.GUID] then
                GLOBALPLAYERPOSITIONS[inst.GUID]:setname(inst.playername:value())
            end
        end
        inst:ListenForEvent("playernamedirty", inst.OnNameChange)
        inst:ListenForEvent("onremove", function(inst)
            if GLOBALPLAYERPOSITIONS[inst.GUID] then
                GLOBALPLAYERPOSITIONS[inst.GUID]:destroy()
                GLOBALPLAYERPOSITIONS[inst.GUID] = nil
            end
        end)
    end
    return inst
end

return Prefab("globalmapicon_withname", fn)
