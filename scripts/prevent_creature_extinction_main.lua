if not GLOBAL.TheNet:GetIsServer() then 
    return
end

local filename = GetModConfigData("respawnmechanism")
modimport(filename)