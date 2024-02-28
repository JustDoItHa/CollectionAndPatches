-- Import the engine.
modimport("scripts/invincible_status/engine.lua")

-- Imports to keep the keyhandler from working while typing in chat.
Load "chatinputscreen"
Load "consolescreen"
Load "textedit"

local IsServer = GLOBAL.TheNet:GetIsServer()
local preservertb = {}

local function clientpausefn(inst)

    if inst.components.health == nil or inst.components.health:IsDead() then
        return
    end

    --没暂停则暂停
    if inst.clientpause == false then
        inst.components.health:SetInvincible(true)
        if inst.components.playercontroller ~= nil then
            inst.components.playercontroller:Enable(false)
        end
        inst:AddTag("notarget")
        inst.AnimState:SetMultColour(1, 1, 1, .2)
        inst:AddTag("KEY_P_FOR_PERSONAL_PAUSE")

        --CHANGE
        if inst.components.preserver == nil then
            inst:AddComponent("preserver")
            inst.components.preserver:SetPerishRateMultiplier(0)
        end
        --inst.components.preserver:SetPerishRateMultiplier(TUNING.PERISH_SALTBOX_MULT)

        --TODO

        --save preserver
        local function save(v)
            if v and v.components.container ~= nil then
                if v.components.preserver ~= nil then
                    preservertb[v.prefab] = v.components.preserver:GetPerishRateMultiplier()
                    --c_announce(v.components.preserver:GetPerishRateMultiplier())
                else
                    preservertb[v.prefab] = 1
                    --c_announce(1)
                end
            end
        end

        inst.components.inventory:ForEachItem(save)

        --change preserver
        local function change(v)
            if v and v.components.container ~= nil then
                if v.components.preserver ~= nil then
                    v.components.preserver:SetPerishRateMultiplier(0)
                else
                    v:AddComponent("preserver")
                    v.components.preserver:SetPerishRateMultiplier(0)
                end
            end
        end

        inst.components.inventory:ForEachItem(change)

        inst.clientpause = true
    else
        inst.components.health:SetInvincible(false)
        if inst.components.playercontroller ~= nil then
            inst.components.playercontroller:Enable(true)
        end
        inst:RemoveTag("notarget")
        inst.AnimState:SetMultColour(1, 1, 1, 1)
        inst:RemoveTag("KEY_P_FOR_PERSONAL_PAUSE")
        --CHANGE
        if inst.components.preserver ~= nil then
            inst.components.preserver:SetPerishRateMultiplier(1)
            inst:RemoveComponent("preserver")
        end

        --recover preserver
        local function recover(v)
            if v and v.components.container ~= nil and v.components.preserver then
                if preservertb[v.prefab] ~= 1 then
                    v.components.preserver:SetPerishRateMultiplier(preservertb[v.prefab])
                else
                    v.components.preserver:SetPerishRateMultiplier(1)
                    v:RemoveComponent("preserver")
                end
            end
        end

        inst.components.inventory:ForEachItem(recover)

        inst.clientpause = false
    end

end
AddModRPCHandler("clientpause", "clientpauseaction", clientpausefn)

AddPlayerPostInit(function(inst)

    inst.clientpause = false
    inst:AddComponent("clientpause_keyhandler")
    inst.components.clientpause_keyhandler:AddActionListener("clientpause", GLOBAL.KEY_P, "clientpauseaction")

    inst:DoPeriodicTask(240, function(inst)
        if inst.components.playercontroller and inst.components.playercontroller:IsEnabled() and inst:HasTag("KEY_P_FOR_PERSONAL_PAUSE") then
            SendModRPCToServer(MOD_RPC["clientpause"]["clientpauseaction"], inst)
        end
    end, 45)

end)

