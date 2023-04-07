local _G = GLOBAL
local TheSim = _G.TheSim
local TheNet = _G.TheNet

local IsServer = TheNet:GetIsServer() or TheNet:IsDedicated()
local GetTaskRemaining = _G.GetTaskRemaining

local Old_Networking_Say = _G.Networking_Say
local AllPlayers = _G.AllPlayers

-- 掉落物品自动堆叠
local command_stack = GetModConfigData("command_stack")
local SEE_ITEM_STACK_DIST = 30
if IsServer then

    -- 说话
    function PlayerSay(player, msg, delay, duration, noanim, force, nobroadcast,
                       colour)
        if player ~= nil and player.components.talker then
            player:DoTaskInTime(delay or 0.01, function()
                player.components.talker:Say(msg, duration or 2.5, noanim,
                        force, nobroadcast, colour)
            end)
        end
    end
    -- 查找玩家ID
    local function GetPlayerById(playerid)
        for _, v in ipairs(AllPlayers) do
            if v ~= nil and v.userid and v.userid == playerid then
                return v
            end
        end
        return nil
    end
    local function AnimPut(item, target)
        if target and target ~= item and target.prefab == item.prefab and item.components.stackable and not item.components.stackable:IsFull() and target.components.stackable and not target.components.stackable:IsFull() then
            local start_fx = SpawnPrefab("small_puff")
            start_fx.Transform:SetPosition(target.Transform:GetWorldPosition())
            start_fx.Transform:SetScale(.5, .5, .5)

            item.components.stackable:Put(target)
        end
    end
    local function CanStackInst(inst)
        return inst:IsValid() and inst.components.stackable and not inst.components.stackable:IsFull() and
                inst.components.health == nil and inst.components.mine == nil and -- 带血量的（小动物）和陷阱（有的人会装那类 mod）不堆叠
                inst.prefab ~= "fireflies" -- 萤火虫不参与堆叠

    end
    local function DoPut(inst, pt)
        -- 指定任意一个实体，堆叠附近所有可以堆叠的东西，不止会堆叠新的掉落
        if not (inst and inst:IsValid()) and pt == nil then
            return
        end

        local pos = pt or inst:GetPosition()
        local x, y, z = pos:Get()
        local ents = TheSim:FindEntities(x, y, z, SEE_ITEM_STACK_DIST, { "_inventoryitem" }, { "INLIMBO", "NOCLICK", "catchable", "fire" })
        for _, objBase in pairs(ents) do
            if CanStackInst(objBase) then
                for _, obj in pairs(ents) do
                    if obj:IsValid() then
                        AnimPut(objBase, obj)
                    end
                end
            end
        end
    end

    local function ToPut(inst, time, pt)
        inst:DoTaskInTime(time, DoPut, pt)
    end

    -- 获取指令处理
    _G.Networking_Say = function(guid, userid, name, prefab, message, colour,
                                 whisper, isemote, ...)
        Old_Networking_Say(guid, userid, name, prefab, message, colour, whisper,
                isemote, ...)
        local talker = GetPlayerById(userid)
        if string.lower(message) == "#stack" then
            if command_stack and talker then
                PlayerSay(talker, "堆叠!")
                local pos = talker:GetPosition()
                ToPut(talker, 0.5)
            else
                PlayerSay(talker, "宝宝哭了,没开自动堆叠")
            end
        end
    end
end
