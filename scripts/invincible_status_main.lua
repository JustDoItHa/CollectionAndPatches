-- Import the engine.
modimport("scripts/server_basic_setting/invincible_engine.lua")

-- Imports to keep the keyhandler from working while typing in chat.
Load "chatinputscreen"
Load "consolescreen"
Load "textedit"

local IsServer = GLOBAL.TheNet:GetIsServer()
local preservertb = {}

local function clientpausefn(inst)

    if inst.components.health == nil or inst.components.health:IsDead() then return end
    -- add

    --没暂停则暂停
    if inst.clientpause == false then

        --Check
        if inst.components.grogginess ~= nil and inst.components.grogginess:IsKnockedOut() ~= false then
            --c_announce("2")
            --inst.components.grogginess:ComeTo()
            if inst.components.talker ~= nil then
                inst.components.talker:Say("You can't hang up when you're sleeping")
            end
            return
        end
        inst:RemoveComponent("grogginess")
        if inst.components.freezable ~= nil and inst.components.freezable:IsFrozen() ~= false then
            --inst.components.freezable:Unfreeze()
            if inst.components.talker ~= nil then
                inst.components.talker:Say("You can't hang up when you're forzen")
            end
            return
        end

        inst.components.health:SetInvincible(true)
        if inst.components.playercontroller ~= nil then
            inst.components.playercontroller:Enable(false)
        end
        inst:AddTag("notarget")
        inst.AnimState:SetMultColour(1, 1, 1, .2)
        inst:AddTag("KEY_J_FOR_PERSONAL_PAUSE")

        --CHANGE
        if inst.components.preserver == nil then
            inst:AddComponent("preserver")
            inst.components.preserver:SetPerishRateMultiplier(0)
        end
        --inst.components.preserver:SetPerishRateMultiplier(TUNING.PERISH_SALTBOX_MULT)

        --TODO
        --cant sleep
        --if inst.components.sleeper ~= nil and inst.components.sleeper:IsAsleep() then
        --	inst.components.sleeper:WakeUp()
        --if inst.components.sleeper ~= nil then
        --c_announce("1")
        --	inst:RemoveComponent("sleeper")
        --end
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
        inst:RemoveTag("KEY_J_FOR_PERSONAL_PAUSE")
        --CHANGE
        if inst.components.preserver ~= nil then
            inst.components.preserver:SetPerishRateMultiplier(1)
            inst:RemoveComponent("preserver")
        end
        --can sleep
        --inst:AddComponent("sleeper")
        inst:AddComponent("grogginess")

        --recover preserver
        local function recover(v)
            if v and v.components.container ~= nil and v.components.preserver ~= nil then
                if preservertb[v.prefab] ~= nil then
                    if preservertb[v.prefab] ~= 1 then
                        v.components.preserver:SetPerishRateMultiplier(preservertb[v.prefab])
                    else
                        v.components.preserver:SetPerishRateMultiplier(1)
                        v:RemoveComponent("preserver")
                    end
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
    inst.components.clientpause_keyhandler:AddActionListener("clientpause", GLOBAL.KEY_J, "clientpauseaction")

    inst:DoPeriodicTask(240, function(inst)
        if inst.components.playercontroller and inst.components.playercontroller:IsEnabled() and inst:HasTag("KEY_J_FOR_PERSONAL_PAUSE") then
            SendModRPCToServer(MOD_RPC["clientpause"]["clientpauseaction"], inst)
        end
    end, 45)

end)

