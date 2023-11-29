-- Import the engine.
modimport("scripts/invincible_status/engine.lua")

-- Imports to keep the keyhandler from working while typing in chat.
Load "chatinputscreen"
Load "consolescreen"
Load "textedit"

local IsServer = GLOBAL.TheNet:GetIsServer()

local function clientpausefn(inst)

    if inst.components.health == nil or inst.components.health:IsDead() then return end

    --没暂停则暂停
    if inst.clientpause == false then
        inst.components.health:SetInvincible(true)
        if inst.components.playercontroller ~= nil then
            inst.components.playercontroller:Enable(false)
        end
        inst:AddTag("notarget")
        inst.AnimState:SetMultColour(1,1,1,.2)
        inst.clientpause = true
    else
        inst.components.health:SetInvincible(false)
        if inst.components.playercontroller ~= nil then
            inst.components.playercontroller:Enable(true)
        end
        inst:RemoveTag("notarget")
        inst.AnimState:SetMultColour(1,1,1,1)
        inst.clientpause = false
    end

end
AddModRPCHandler("clientpause", "clientpauseaction", clientpausefn)

AddPlayerPostInit(function(inst)

    inst.clientpause = false
    inst:AddComponent("clientpause_keyhandler")
    inst.components.clientpause_keyhandler:AddActionListener("clientpause", GLOBAL.KEY_P, "clientpauseaction")

end)


