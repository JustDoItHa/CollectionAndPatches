local upvaluehelper = require "utils/upvaluehelp_cap"
local moonbeastspawner = require "components/moonbeastspawner"
local DoSpawn = upvaluehelper.Get(moonbeastspawner.Start, "DoSpawn")
if DoSpawn then
    local function new_DoSpawn(inst, self, ...)
        if inst:IsAsleep() and not IsLandTile(TheWorld.Map:GetTileAtPoint(inst:GetPosition():Get())) and inst.components.workable then
            inst.components.workable:Destroy(inst)
            return
        end
        DoSpawn(inst, self, ...)
    end
    local params = upvaluehelper.Set(moonbeastspawner.Start,"DoSpawn", new_DoSpawn)
end