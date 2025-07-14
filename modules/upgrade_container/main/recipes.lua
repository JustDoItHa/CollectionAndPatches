local AddRecipe = require("utils/chestupgrade_recipe")

local function MakePackRecipe(prefab, amount, lv)
	if GetModConfigData("EXPENSIVE_BACKPACK") then
		return {all = Ingredient(prefab, amount), lv = lv}
	else
		return {page = {[1] = Ingredient(prefab, amount)}, lv = lv}
	end
end

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
	["battlesong_container"] 	= {side = Ingredient("boards", 1), lv = {2,4}},

	--backpack
	["backpack"]		= MakePackRecipe("rope", 1, {2,4}),		--{page = {[1] = Ingredient("rope", 1)}, lv = {2,4}},
	["icepack"]			= MakePackRecipe("transistor", 1, {2,4}),--{page = {[1] = Ingredient("transistor", 1)}, lv = {2,4}},
	["spicepack"]		= MakePackRecipe("nitre", 1, {2,3}),		--{page = {[1] = Ingredient("nitre", 1)}, lv = {2,3}},
	["krampus_sack"]	= MakePackRecipe("rope", 1, {2,7}),		--{page = {[1] = Ingredient("rope", 1)}, lv = {2,7}},
	["catback"]         = {page = {[1] = Ingredient("opalpreciousgem", 1)}, lv = {2,7}},
	["piggyback"]		= MakePackRecipe("pigskin", 1, {2,6}),	--{page = {[1] = Ingredient("pigskin", 1)}, lv = {2,6}},
	--	["seedpouch"] = "slurtle_shellpieces",
	--	["candybag"] = "rope",

	--critter
	["chester"]			= {side = Ingredient("dragon_scales", 1)},
	["hutch"]			= {side = Ingredient("shroom_skin", 1)},
	--	["wobybig"]			= {},
	--	["wobysmall"]		= {},
}

for prefab, params in pairs(ALL_RECIPES) do
	AddRecipe(prefab, params)
end