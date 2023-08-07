local packs_params = {
	--["backpack"] = "rope",
	--背包-彩虹宝石
	["backpack"] = "opalpreciousgem",
    --保鲜背包-电子元件
	["icepack"] = "transistor",
	--厨师包-硝石
	["spicepack"] = "nitre",
	--小偷包-彩虹宝石
	["krampus_sack"] = "opalpreciousgem",
	["catback"] = "opalpreciousgem",
	--["catbigbag"] = "opalpreciousgem",
	--["krampus_sack"] = "rope",
	--小猪包-猪皮
	["piggyback"] = "pigskin",
--	["seedpouch"] = "slurtle_shellpieces",
--	["candybag"] = "rope",
}
--------------------------------------------------
--------------------------------------------------
local function GetPackUpgData(prefab, x, y, z)
	local data = {slot = {}}
	local item = packs_params[prefab]
	if prefab == "special" then
		item = "waxpaper"
	end
	for i = 1, x * y do
		table.insert(data.slot, {item, 1})
	end
	return data
end

local function OnPackClose(inst, data)
	local container = inst.components.container
	if container.opencount == 0 then
		local chestupgrade = inst.components.chestupgrade
		local x, y, z = chestupgrade:GetLv()

		if z < (chestupgrade.baselv.z + TUNING.CHESTUPGRADE.MAXPACKUPGRADE) then
			chestupgrade:SpecialUpgrade(GetPackUpgData(inst.prefab, x, y, z), data.doer, {z = 1})
		end

		--we can upgrade krampus_sack twice if we use waxpaper for first upgrade. ie. 9 pages with total 126 slots
		if inst.prefab == "krampus_sack" and z < (TUNING.CHESTUPGRADE.MAXPACKUPGRADE + 4) then
			chestupgrade:SpecialUpgrade(GetPackUpgData("special", x, y, z), data.doer, {z = 4})
		end

		if inst.prefab == "catback" and z < (TUNING.CHESTUPGRADE.MAXPACKUPGRADE + 4) then
			chestupgrade:SpecialUpgrade(GetPackUpgData("special", x, y, z), data.doer, {z = 4})
		end
	end
end

local function PackPostInit(inst)
	if not GLOBAL.TheWorld.ismastersim then return end
	local y = (inst.components.container ~= nil and inst.components.container:GetNumSlots() / 2) or 4
	inst:AddComponent("chestupgrade")
	inst.components.chestupgrade:SetBaseLv(2, y)

	inst:ListenForEvent("onclose", OnPackClose)
end

for k, v in pairs(packs_params) do
	AddPrefabPostInit(k, PackPostInit)
	--GLOBAL.ChestUpgrade.AllUpgradeRecipes[k] = GetPackUpgData(prefab, x, y, z)
end

--------------------------------------------------