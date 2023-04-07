local old_TemperatureChange
local old_heatrock_fn

local function new_TemperatureChange(inst, data)
    inst.components.fueled = {
        GetPercent = function() return 1 end,
        SetPercent = function() end,
    }
    old_TemperatureChange(inst, data)
    inst.components.fueled = nil
end

local function new_heatrock_fn(inst)
    if GLOBAL.TheWorld.ismastersim then
        inst:RemoveComponent("fueled")

        local function switchListenerFns(t)
            local listeners = t["temperaturedelta"]
            local listener_fns = listeners[inst]
            old_TemperatureChange = listener_fns[1]
            listener_fns[1] = new_TemperatureChange
        end

        switchListenerFns(inst.event_listeners)
        switchListenerFns(inst.event_listening)
    end
end

AddPrefabPostInit("heatrock", new_heatrock_fn)