GLOBAL.setmetatable(env, { __index = function(t, k)
    return GLOBAL.rawget(GLOBAL, k)
end })
------------------------------------------------------------------------------------------------以下是催熟修改
local ripening_frequency_local = 60

local specie_plant_ripening_frequency ={
    --["草"] = 10,
    grass = 60,
}

if TUNING.RIPENING_PLANT_FREQUENCY == nil then
    TUNING.RIPENING_PLANT_FREQUENCY = 60
end

if TUNING.RIPENING_PLANT_FREQUENCY <= 0 then
    return
else
    ripening_frequency_local = TUNING.RIPENING_PLANT_FREQUENCY
end

AddComponentPostInit("pickable", function(self, inst)
    local Old_FinishGrowing = self.FinishGrowing
    self.FinishGrowing = function(...)
        if not self.inst.cap_grow then
            return
        end
        local grow = Old_FinishGrowing(...)
        if grow then
            self.inst.cap_grow = true
            if self.inst.AnimState ~= nil then
                self.inst.AnimState:SetMultColour(0.3, 0.3, 0.3, 1)
            end
            self.inst:DoTaskInTime(specie_plant_ripening_frequency[self.inst.prefab] or ripening_frequency_local, function(inst)
                self.inst.cap_grow = nil
                if self.inst.AnimState ~= nil then
                    self.inst.AnimState:SetMultColour(1, 1, 1, 1)
                end
            end)
        end
        return grow
    end
end)

AddComponentPostInit("growable", function(self, inst)

    self.inst:DoTaskInTime(0, function(inst)
        if inst.components.growable == nil then
            return
        end
        local Old_DoGrowth = inst.components.growable.DoGrowth
        inst.components.growable.DoGrowth = function(...)
            if inst.cap_grow then
                return
            end
            local normal_grow = inst.components.growable.targettime and inst.components.growable.targettime > GetTime()
            local grow = Old_DoGrowth(...)
            if grow and normal_grow then
                inst.cap_grow = true
                if inst.AnimState ~= nil then
                    inst.AnimState:SetMultColour(0.3, 0.3, 0.3, 1)
                end
                inst:DoTaskInTime(specie_plant_ripening_frequency[self.inst.prefab] or ripening_frequency_local, function(inst)
                    inst.cap_grow = nil
                    if inst.AnimState ~= nil then
                        inst.AnimState:SetMultColour(1, 1, 1, 1)
                    end
                end)
            end
            return grow
        end
    end)

end)


AddComponentPostInit("crop", function(self, inst)
    -- 大概是旧版农场 目前感觉没啥用 看需要取消注释
    local Old_DoGrow = self.DoGrow
    self.DoGrow = function(self, dt, nowither, ...)
        if self.inst.cap_grow then
            return
        end
        local dt = math.min(inst.components.crop.rate and 1 / inst.components.crop.rate or TUNING.TOTAL_DAY_TIME, dt)
        local grow = Old_DoGrow(self, dt, nowither, ...)
        if grow then
            self.inst.cap_grow = true
            if self.inst.AnimState ~= nil then
                self.inst.AnimState:SetMultColour(0.3, 0.3, 0.3, 1)
            end
            self.inst:DoTaskInTime(specie_plant_ripening_frequency[self.inst.prefab] or ripening_frequency_local, function(inst)
                self.inst.cap_grow = nil
                if self.inst.AnimState ~= nil then
                    self.inst.AnimState:SetMultColour(1, 1, 1, 1)
                end
            end)
        end
        return grow
    end
end)
