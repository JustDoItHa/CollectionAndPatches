modimport("modules/upgrade_container/main/mods_change.lua")

ChestUpgradePreInit()

TUNING.CHESTUPGRADE = {	--add to tuning so that they can be easily tuned
	MAX_LV			= GetModConfigData("MAX_LV"),
	MAX_PAGE		= GetModConfigData("PAGEABLE") and 10 or 1,

	DEGRADE_RATIO	= .5,						--math.min(GetModConfigData("DEGRADE_RATIO"), 1)
	DEGRADE_USE		= 1,						--GetModConfigData("DEGRADE_USE")

	SCALE_FACTOR	= GetModConfigData("SCALE_FACTOR"),
}

if GetModConfigData("BACKPACK") then
	TUNING.CHESTUPGRADE.MAXPACKUPGRADE = (GetModConfigData("BACKPACKPAGE") or 3) - 1
end

AddReplicableComponent("chestupgrade")

GLOBAL.ChestUpgrade = {}
GLOBAL.ChestUpgrade.AllUpgradeRecipes = {}

env.ChestUpgrade = GLOBAL.ChestUpgrade
env.AllUpgradeRecipes = ChestUpgrade.AllUpgradeRecipes

AllUpgradeRecipes.GetParams = function(allrecipes, prefab)
	local recipe = allrecipes[prefab]
	if recipe ~= nil then
		return recipe.GetParams ~= nil and recipe:GetParams()
	end
end

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
	CONTAINER = false,			--components/container
	CONTAINER_C = false,		--prefabs/container_classifier
	INVENTORY = false,			--prefabs/inventory_classifier
}

modimport("modules/upgrade_container/main/modules/inventorybar.lua")
modimport("modules/upgrade_container/main/modules/container.lua")
modimport("modules/upgrade_container/main/modules/container_classifier.lua")
modimport("modules/upgrade_container/main/modules/inventory_classifier.lua")
--modimport("main/modules/chestupgrade_replica.lua")

ChestUpgradePostInit()