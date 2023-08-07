local upgradable_container = 
{
--	[""] = {side = "", center = ""},
	["treasurechest"] 	= {},
	["icebox"] 			= {},
	["saltbox"] 		= {},
	["dragonflychest"] 	= {lv = {3, 4}},
	["fish_box"] 		= {lv = {5, 4}},
	["bookstation"]		= {lv = {4, 5}},
	["tacklecontainer"] = {lv = {3, 2}},
	["supertacklecontainer"] = {lv = {3, 5}},
	["shadow_container"]	 = {lv = {3, 4}, skiptemp = true}
	--["ocean_trawler"]	= {all = {"malbatross_feather", 1}},
}

--GLOBAL.ChestUpgrade.AllUpgradeRecipes = upgradable_container

if UNCMODE then
	upgradable_container.dragonflychest.lv = {5,5}
end

--------------------------------------------------
--RETURNITEM: return some resource when deconstruct
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

--DEBUG_IIC: put enough ingrdients into the container
local function onopen(inst)
	local container = inst.components.container
	if not container:IsEmpty() or container.opencount > 1 then return end

	local x, y = inst.components.chestupgrade:GetLv()
	if x < TUNING.CHESTUPGRADE.MAX_LV and y < TUNING.CHESTUPGRADE.MAX_LV then
		local checktable = inst.components.chestupgrade:CreateCheckTable()
		for slot, ingr in pairs(checktable) do
			if ingr then
				local prefab = ingr.type or ingr[1]
				local amount = ingr.amount or ingr[2] or 1
				if prefab ~= nil then
					local item = GLOBAL.SpawnPrefab(prefab)
					local stackable = item.components.stackable
					if stackable then
						stackable:SetStackSize(amount)
					end
					container:GiveItem(item, slot)
				end
			end
		end

	else
		local side = AllUpgradeRecipes[inst.prefab].side
		if side == nil then return end
		local numslots = x * y
		for slot = 1, numslots do
			local item = GLOBAL.SpawnPrefab(side.type)
			local stackable = item.components.stackable
			if stackable then
				stackable:SetStackSize(side.amount)
			end
			container:GiveItem(item, slot)
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
		inst:ListenForEvent("onopen", onopen)
	end
end

--------------------------------------------------
--local ChestUpgrade = GLOBAL.ChestUpgrade
--local AllUpgradeRecipes = ChestUpgrade.AllUpgradeRecipes
local degradable = GetModConfigData("DEGRADABLE")
for prefab, prop in pairs(upgradable_container) do
	if GetModConfigData("C_"..prefab:upper()) or (prefab == "supertacklecontainer" and GetModConfigData("C_TACKLECONTAINER")) then
		local recipe = AllUpgradeRecipes[prefab]
		local para = recipe.params
		if para == nil then
			print("[Upgradeable Chest]: Invalid params", prefab)
			return
		end

		local x, y = GLOBAL.unpack(prop.lv or recipe.lv or {3,3})

		ChestUpgrade.AddUpgradable(prefab, x, y)
		ChestUpgrade.CustomUI(prefab)
		ChestUpgrade.SetCommonCloseFn(prefab, para, degradable)
		if not prop.skiptemp then
			ChestUpgrade.SetTempContainable(prefab, para)
		end

		AddPrefabPostInit(prefab, SomeOtherFunctions)
	end
end

--------------------------------------------------
--"ocean trawler"
--local ot_para = {all = Ingredient("malbatross_feather", 1)}
--UpgradeRecipe("ocean_trawler", ot_para)
local ot_para = AllUpgradeRecipes["ocean_trawler"]
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
	ChestUpgrade.AddUpgradable("ocean_trawler", 1, 4)
	--ChestUpgrade.CustomUI("ocean_trawler", false)
	ChestUpgrade.SetOnCloseFn("ocean_trawler", ot_fn, degradable)
	ChestUpgrade.SetTempContainable("ocean_trawler", ot_para.all)
end
