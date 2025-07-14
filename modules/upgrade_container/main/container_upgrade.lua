local chests = {
	"treasurechest",
	"icebox",
	"saltbox",
	"dragonflychest",
	"fish_box",
	"bookstation",
	"tacklecontainer",
	"supertacklecontainer",
	"shadow_container",
	"beargerfur_sack",
	"battlesong_container",
}

for _, prefab in pairs(chests) do
	if GetModConfigData("C_"..prefab:upper()) or (prefab == "supertacklecontainer" and GetModConfigData("C_TACKLECONTAINER")) then
		local recipe = AllUpgradeRecipes[prefab]
		ChestUpgrade.ChestSetUp(prefab, recipe.params, recipe.lv)
	end
end

------------------------------------------------
local packs = {
	"backpack",
	"icepack",
	"spicepack",
	"krampus_sack",
	"catback",
	"piggyback",
}

if GetModConfigData("KRAMPUS_ONLY") then
	local prefab = "krampus_sack"
	local recipe = AllUpgradeRecipes[prefab]
	recipe.params.page = {[1] = Ingredient("waxpaper", 1)}
	ChestUpgrade.PackSetUp(prefab, recipe.params, recipe.lv)

elseif GetModConfigData("BACKPACK") then
	for _, prefab in pairs(packs) do
		local recipe = AllUpgradeRecipes[prefab]
		ChestUpgrade.PackSetUp(prefab, recipe.params, recipe.lv)
	end
end

------------------------------------------------
local critters = {
	"chester",
	"hutch",
	--"wobybig",
	--"wobysmall",
}

if GetModConfigData("C_CHESTER") then
	for _, prefab in pairs(critters) do
		local recipe = AllUpgradeRecipes[prefab]
		ChestUpgrade.ChestSetUp(prefab, recipe.params, recipe.lv)
	end
end

------------------------------------------------
local util = require("utils/chestupgrade_util")

local special = {}
--"ocean_trawler"
if GetModConfigData("C_OCEAN_TRAWLER") then
	local OTRecipe = AllUpgradeRecipes["ocean_trawler"]
	local function OTOnClose(inst, data)
		local container = inst.components.container
		if container.opencount ~= 0 then return end

		local chestupgrade = inst.components.chestupgrade
		local x, y, z = chestupgrade:GetLv()

		if x < 3 then
			chestupgrade:SpecialUpgrade(OTRecipe.params, data.doer, {x = 1})
		end

		if TUNING.CAP_DEGRADABLE then
			util.DegradeByHammer(inst, data)
		end
	end

	util.MakeTempContainable("ocean_trawler", OTRecipe.params)

	special["ocean_trawler"] = function(inst)
		if not GLOBAL.TheWorld.ismastersim then return end

		util.MakeUpgradeable(inst, OTRecipe.lv)

		if GetModConfigData("RETURNITEM") then
			util.Deconstruct(inst)
		end

		if GetModConfigData("CHANGESIZE") then
			local scale = GLOBAL.Vector3(inst.Transform:GetScale())
			if scale == GLOBAL.Vector3(1,1,1) then
				scale = nil
			end
			util.ChangeSize(inst, scale)
		end

		inst:ListenForEvent("onclose", OTOnClose)
	end
end

--"krampus_sack" special
if GetModConfigData("BACKPACK") then
	local KSSpecialParams = {page = {[1] = Ingredient("waxpaper", 1)}}
	local function KSSpOnClose(inst, data)
		local container = inst.components.container
		if container.opencount == 0 then

			local chestupgrade = inst.components.chestupgrade
			local x, y, z = chestupgrade:GetLv()

			if z < TUNING.CHESTUPGRADE.MAXPACKPAGE + 4 then
				chestupgrade:SpecialUpgrade(KSSpecialParams, data.doer, {z = 1})
			end
		end
	end

	special["krampus_sack"] = function(inst)
		if not GLOBAL.TheWorld.ismastersim then return end

		inst:ListenForEvent("onclose", KSSpOnClose)
	end
end

for prefab, fn in pairs(special) do
	AddPrefabPostInit(prefab, fn)
end