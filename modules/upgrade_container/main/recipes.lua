local AddRecipe = require("utils/chestupgrade_recipe")

local ALL_RECIPES = {
	["treasurechest"] 	= {side = Ingredient("boards", 1)},
	["icebox"] 			= {side = Ingredient("cutstone", 1), row = {[1] = Ingredient("gears", 1)}},
	["saltbox"] 		= {side = Ingredient("saltrock", 1), center = Ingredient("bluegem", 1)},
	["dragonflychest"] 	= {side = Ingredient("boards", 1), lv = {3,4}},
	["fish_box"] 		= {side = Ingredient("rope", 1), lv = {5,4}},
	["bookstation"]		= {side = Ingredient("livinglog", 1), lv = {4,5}},
	["tacklecontainer"] = {side = Ingredient("cookiecuttershell", 1), lv = {3,2}},
	["supertacklecontainer"] 	= {side = Ingredient("cookiecuttershell", 1), lv = {3,5}},
	["shadow_container"] 		= {side = Ingredient("shadowheart", 1), lv = {3,4}, degrade = false},
	["ocean_trawler"]	= {all = Ingredient("malbatross_feather", 1), lv = {1,4}},
	["beargerfur_sack"] = {side = Ingredient("purebrilliance", 1), column = {[1] = Ingredient("bearger_fur", 1)}, lv = {2,3}},

	--backpack
	["backpack"]		= {page = {[1] = Ingredient("rope", 1)}, lv = {2,4}},
	["icepack"]			= {page = {[1] = Ingredient("transistor", 1)}, lv = {2,4}},
	["spicepack"]		= {page = {[1] = Ingredient("nitre", 1)}, lv = {2,3}},
	["krampus_sack"]	= {page = {[1] = Ingredient("rope", 1)}, lv = {2,7}},
	["catback"]         = {page = {[1] = Ingredient("opalpreciousgem", 1)}, lv = {2,7}},
	--["catbigback"]         = {page = {[1] = Ingredient("opalpreciousgem", 1)}, lv = {2,15}},
	["piggyback"]		= {page = {[1] = Ingredient("pigskin", 1)}, lv = {2,6}},
--	["seedpouch"] = "slurtle_shellpieces",
--	["candybag"] = "rope",
}

for prefab, params in pairs(ALL_RECIPES) do
	AddRecipe(prefab, params)
end