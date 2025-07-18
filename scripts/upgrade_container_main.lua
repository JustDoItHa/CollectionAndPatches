modimport("modules/upgrade_container/main/mods_change.lua")

ChestUpgradePreInit()

TUNING.CHESTUPGRADE = {	--add to tuning so that they can be easily tuned
	MAX_LV			= GetModConfigData("MAX_LV"),
	MAX_PAGE		= GetModConfigData("PAGEABLE") and 10 or 1,

	DEGRADE_RATIO	= .5,						--math.min(GetModConfigData("DEGRADE_RATIO"), 1)
	DEGRADE_USE		= 1,						--GetModConfigData("DEGRADE_USE")

	SCALE_FACTOR	= GetModConfigData("SCALE_FACTOR"),

	MAXPACKSIZE		= GetModConfigData("BACKPACK") and GetModConfigData("BACKPACKSIZE") or 0,
	MAXPACKPAGE 	= GetModConfigData("BACKPACK") and GetModConfigData("BACKPACKPAGE") or 1,
}

AddReplicableComponent("chestupgrade")

GLOBAL.ChestUpgrade = {}
GLOBAL.ChestUpgrade.AllUpgradeRecipes = {}

env.ChestUpgrade = GLOBAL.ChestUpgrade
env.AllUpgradeRecipes = ChestUpgrade.AllUpgradeRecipes

AllUpgradeRecipes.GetParams = function(allrecipes, prefab)
	local recipe = allrecipes[prefab]
	if recipe ~= nil and recipe.GetParams ~= nil then
		return recipe:GetParams()
	end
end

local containers = require("containers")

local chestmaxlv = (TUNING.CHESTUPGRADE.MAX_LV + 1) * (TUNING.CHESTUPGRADE.MAX_LV + 2) * TUNING.CHESTUPGRADE.MAX_PAGE
local packmaxlv = (TUNING.CHESTUPGRADE.MAXPACKSIZE * 2 + 3) * (TUNING.CHESTUPGRADE.MAXPACKSIZE * 2 + 8) * TUNING.CHESTUPGRADE.MAXPACKPAGE
containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, chestmaxlv, GetModConfigData("BACKPACK") and packmaxlv or 0)

modimport("modules/upgrade_container/main/strings.lua")
modimport("modules/upgrade_container/main/setup.lua")
modimport("modules/upgrade_container/main/recipes.lua")
modimport("modules/upgrade_container/main/container_upgrade.lua")
modimport("modules/upgrade_container/main/rpcs.lua")

if GetModConfigData("ALLCANUPG") then
	modimport("modules/upgrade_container/main/allupgable.lua")
end

modimport("modules/upgrade_container/main/widgets/container.lua")
modimport("modules/upgrade_container/main/widgets/inventorybar.lua")

--custom change
GLOBAL.ChestUpgrade.DISABLERS = {
	INV = false,				--widgets/inventorybar
	CONTAINER = GetModConfigData("COMPATIBLE_MODE"),--false,			--components/container
	INVENTORY = GetModConfigData("COMPATIBLE_MODE"),--false,			--prefabs/inventory_classifier
}

modimport("modules/upgrade_container/main/modules/inventorybar.lua")
modimport("modules/upgrade_container/main/modules/container.lua")
--modimport("modules/upgrade_container/main/modules/container_classifier.lua")
modimport("modules/upgrade_container/main/modules/inventory_classifier.lua")


ChestUpgradePostInit()