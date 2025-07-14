--PrefabFiles = {
--   "deathed_num"
--}
GLOBAL.setmetatable(env, { __index = function(t, k)
	return GLOBAL.rawget(GLOBAL, k)
end })
local _G = GLOBAL

table.insert(PrefabFiles, "deathed_num")

GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})
AddPlayerPostInit(function(inst)
	if GLOBAL.TheWorld.ismastersim then
		inst:AddComponent("siwangjishu")
	end
end)

AddClientModRPCHandler( "siwangjishu", "siwangjishu", function(value)  --ThePlayer.components.health:Kill()
	if GLOBAL.ThePlayer ~= nil and value then
		GLOBAL.TheNet:Say(value)
	end
end)

AddPlayerPostInit(function(inst)
    inst._deathed_num = net_ushortint(inst.GUID, "deathed_num", "deathed_num_diraty")  --c_removeall("deerclops")
    inst._deathed_num:set(0)
end)
--print(ThePlayer._deathed_num:value())
--UpdatePlayerListing