--[[
local function TumbleweedPostinit(inst)
    if inst.loot == nil or IsTableEmpty(inst.loot) then
        inst.loot = {}
    end
    if inst.lootaggro == nil then
        inst.lootaggro = false
    end
end

AddPrefabPostInit("tumbleweed", TumbleweedPostinit)]]
