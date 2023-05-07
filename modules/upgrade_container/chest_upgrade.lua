local upgradable_container = 
{
--	[""] = {side = "", center = ""},
	["treasurechest"] 	= {side = {"boards", 1}},
	["icebox"] 			= {side = {"cutstone", 1}, row = {[1] = {"gears", 1}}},
	["saltbox"] 		= {side = {"saltrock", 1}, center = {"bluegem", 1}},
	["dragonflychest"] 	= {side = {"boards", 1}, lv = {3, 4}},
	["fish_box"] 		= {side = {"rope", 1}, lv = {5, 4}},
	["bookstation"]		= {side = {"livinglog", 1}, lv = {4, 5}},
	["tacklecontainer"] = {side = {"cookiecuttershell", 1}, lv = {3, 2}},
	["supertacklecontainer"] = {side = {"cookiecuttershell", 1}, lv = {3, 5}},
	["shadow_container"]	 = {side = {"shadowheart", 1}, lv = {3, 4}, skiptemp = true}
	--["ocean_trawler"]	= {all = {"malbatross_feather", 1}},
}

GLOBAL.ChestUpgrade.AllUpgradeRecipes = upgradable_container

--------------------------------------------------
--return some resource when deconstruct
local function ondeconstruct(staff, item)
	return function(inst, data)
		if staff or data.workleft <= 0 then
			local x, y, z = inst.Transform:GetWorldPosition()
			local lv_x, lv_y = inst.components.chestupgrade:GetLv()
			local itemback = (staff and math.floor((lv_x - 2) * (lv_y - 2) - 1))
							or math.floor((lv_x - 2) * (lv_y - 2) / 2)
			if itemback < 1 then return end
			local prefab, amount
			if type(item) == "table" then 
				prefab = item[1]
				amount = item[2]
			elseif type(item) == "string" then
				prefab = item
				amount = 1
			elseif prefab ~= nil then
				prefab = item.type
				amount = item.amount
			else
				return
			end
			for i = 1, itemback do
				for j = 1, amount do
					GLOBAL.SpawnPrefab(prefab).Transform:SetPosition(x + math.random() * 2 - 1, y, z + math.random() * 2 - 1)
				end
			end
		end
	end
end

-------------------------------------------------
local function SomeOtherFunctions(inst)
	if not GLOBAL.TheWorld.ismastersim then return end
	--return item after hammered or deconstructed
	if GetModConfigData("RETURNITEM") then
		local item = upgradable_container[inst.prefab].side
		inst:ListenForEvent("worked", ondeconstruct(false, item))
		inst:ListenForEvent("ondeconstructstructure", ondeconstruct(true, item))
	end

	--DEBUG MODE
	if GetModConfigData("DEBUG_MAXLV") then
		inst.components.chestupgrade:SetChestLv(TUNING.CHESTUPGRADE.MAX_LV, TUNING.CHESTUPGRADE.MAX_LV, TUNING.CHESTUPGRADE.MAX_PAGE)
	end

	if GetModConfigData("DEBUG_IIC") then
		for para, data in pairs(upgradable_container[inst.prefab]) do
			local n = 1
			local prefab = data[1]
			if para == "side" then
				n = 5
			elseif inst.prefab == "icebox" then
				prefab = "gears"
			end
			for m = 1, n do
				local item = GLOBAL.SpawnPrefab(prefab)
				local stackable = item.components.stackable
				stackable:SetStackSize(stackable.maxsize)
				inst.components.container:GiveItem(item)
			end
		end
	end
end

--------------------------------------------------
local ChestUpgrade = GLOBAL.ChestUpgrade
local degradable = GetModConfigData("DEGRADABLE")
for prefab, para in pairs(upgradable_container) do
	if GetModConfigData("C_"..prefab:upper()) or (prefab == "supertacklecontainer" and GetModConfigData("C_TACKLECONTAINER")) then
		local x, y = GLOBAL.unpack(para.lv or {3,3})

		ChestUpgrade.AddUpgradable(prefab, x, y)
		ChestUpgrade.CustomUI(prefab)
		ChestUpgrade.SetCommonCloseFn(prefab, para, degradable)
		if not para.skiptemp then
			ChestUpgrade.SetTempContainable(prefab, para)
		end

		AddPrefabPostInit(prefab, SomeOtherFunctions)
	end
end

--------------------------------------------------
--"ocean trawler"
local ot_para = {all = {"malbatross_feather", 1}}
GLOBAL.ChestUpgrade.AllUpgradeRecipes["ocean_trawler"] = ot_para
local function ot_fn(inst, data)
	local container = inst.components.container
	if container.opencount ~= 0 then return end

	local chestupgrade = inst.components.chestupgrade
	local x, y, z = chestupgrade:GetLv()

	if x < 3 then
		chestupgrade:SpecialUpgrade(ot_para, data.doer, {x = 1})
	end
end

if GetModConfigData("C_OCEAN_TRAWLER") then
	ChestUpgrade.CustomUI("ocean_trawler", false)
	ChestUpgrade.AddUpgradable("ocean_trawler", 1, 4)
	ChestUpgrade.SetOnCloseFn("ocean_trawler", ot_fn, degradable)
	ChestUpgrade.SetTempContainable("ocean_trawler", ot_para.all)
end
