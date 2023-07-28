-- 使用的mod名称：西米冰箱
-- mod链接：https://steamcommunity.com/sharedfiles/filedetails/?id=1247040097
-- mod更新时间：2020.10.12 上午 2:10
-- mod作者：Destiny

local krampus_sack_ice = GetModConfigData("krampus_sack_ice")
local backpack_ice = GetModConfigData("backpack_ice")
local piggyback_ice = GetModConfigData("piggyback_ice")
local cage_fridge = GetModConfigData("cage_frige")

TUNING.PERISH_FRIDGE_MULT = GetModConfigData("icebox_freeze")

TUNING.PERISH_SALTBOX_MULT = GetModConfigData("saltlicker")

TUNING.PERISH_MUSHROOM_LIGHT_MULT = GetModConfigData("mushroom_frige")
if cage_fridge then 
	AddPrefabPostInit("sisturn", function (inst)
		inst:AddTag("fridge")
		inst:AddTag("nocool")
	end)
end
if krampus_sack_ice then
		AddPrefabPostInit("krampus_sack", function (inst)
			inst:AddTag("fridge")
			inst:AddTag("nocool")
		end)
end

if backpack_ice then
		AddPrefabPostInit("backpack", function (inst)
			inst:AddTag("fridge")
			inst:AddTag("nocool")
		end)
end

if piggyback_ice then
		AddPrefabPostInit("piggyback", function (inst)
			inst:AddTag("fridge")
			inst:AddTag("nocool")
		end)
end

