local time = GetModConfigData("CREATURE_DIE_TIME")
if time then
    local function OnTimerDone(inst)
        if inst.components.health then
            inst.components.health:Kill()
        end
    end

    local function Die_in_time(inst)
        if inst.components.timer then
            inst.components.timer:StartTimer("TimeToDie", time)
        end
        inst:ListenForEvent("timerdone", OnTimerDone)
    end
    AddPrefabPostInit("lunarthrall_plant", Die_in_time)
end


