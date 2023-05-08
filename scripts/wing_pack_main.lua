--PrefabFiles = {
--	"bat_wings",
--	"dragonfly_wings",
--	"white_wings",
--}
table.insert(PrefabFiles, "bat_wings")
table.insert(PrefabFiles, "dragonfly_wings")
table.insert(PrefabFiles, "white_wings")



-- Load in some assets globally
--Assets = {
--	Asset("ATLAS", "images/inventoryimages/bat_wings.xml"),
--    Asset("IMAGE", "images/inventoryimages/bat_wings.tex"),
--	Asset("ATLAS", "images/inventoryimages/dragonfly_wings.xml"),
--    Asset("IMAGE", "images/inventoryimages/dragonfly_wings.tex"),
--	Asset("ATLAS", "images/inventoryimages/white_wings.xml"),
--    Asset("IMAGE", "images/inventoryimages/white_wings.tex"),
--}

table.insert(Assets, Asset("ATLAS", "images/inventoryimages/wingpack/bat_wings.xml"))
table.insert(Assets, Asset("IMAGE", "images/inventoryimages/wingpack/bat_wings.tex"))
table.insert(Assets, Asset("ATLAS", "images/inventoryimages/wingpack/dragonfly_wings.xml"))
table.insert(Assets, Asset("IMAGE", "images/inventoryimages/wingpack/dragonfly_wings.tex"))
table.insert(Assets, Asset("ATLAS", "images/inventoryimages/wingpack/white_wings.xml"))
table.insert(Assets, Asset("IMAGE", "images/inventoryimages/wingpack/white_wings.tex"))


-- Load our item icon XMLs into the Minimap!
AddMinimapAtlas("images/inventoryimages/wingpack/bat_wings.xml")
AddMinimapAtlas("images/inventoryimages/wingpack/dragonfly_wings.xml")
AddMinimapAtlas("images/inventoryimages/wingpack/white_wings.xml")



-- Declare global variables
local require = GLOBAL.require
local STRINGS = GLOBAL.STRINGS
local Ingredient = GLOBAL.Ingredient
local RECIPETABS = GLOBAL.RECIPETABS
local TECH = GLOBAL.TECH 
local TheWorld = GLOBAL.TheWorld



-- Custom strings!
--STRINGS.NAMES.BAT_WINGS = "Bat Wings"
--STRINGS.RECIPE_DESC.BAT_WINGS = "blend in with the bats"
--STRINGS.CHARACTERS.GENERIC.DESCRIBE.BAT_WINGS = "i'll be the talk of the bellfrey."
--STRINGS.NAMES.DRAGONFLY_WINGS = "Iridescent Wings"
--STRINGS.RECIPE_DESC.DRAGONFLY_WINGS = "keeps air moving with buzzing wings"
--STRINGS.CHARACTERS.GENERIC.DESCRIBE.DRAGONFLY_WINGS = "Now the heat wont bug me."
--STRINGS.NAMES.WHITE_WINGS = "Winter Wings"
--STRINGS.RECIPE_DESC.WHITE_WINGS = "stay warm and cozy with winter plumage"
--STRINGS.CHARACTERS.GENERIC.DESCRIBE.WHITE_WINGS = "I suppose flying South isn't an option."
STRINGS.NAMES.BAT_WINGS = "蝙蝠神翼"
STRINGS.RECIPE_DESC.BAT_WINGS = "被蝙蝠咬了后变异的嘛？"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.BAT_WINGS = "我拥有特殊的能力！！！"
STRINGS.NAMES.DRAGONFLY_WINGS = "五彩斑斓的翅膀"
STRINGS.RECIPE_DESC.DRAGONFLY_WINGS = "用嗡嗡作响的翅膀保持空气流动。"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.DRAGONFLY_WINGS = "现在炎热会远离我."
STRINGS.NAMES.WHITE_WINGS = "炽热神翼"
STRINGS.RECIPE_DESC.WHITE_WINGS = "保持温暖和舒适"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WHITE_WINGS = "向南飞并不是一个很好的选择."


AddPrefabPostInit("batbat", function(inst)
	inst:AddTag("batbuff")
end)

function backpackpostinit(inst)
   if not GLOBAL.TheWorld.ismastersim then
		return inst
	end  
	if GetModConfigData("wingpack_equip_slot") == true then
		inst.components.equippable.equipslot = GLOBAL.EQUIPSLOTS.BACK
	end
	
end
AddPrefabPostInit("bat_wings", backpackpostinit)
AddPrefabPostInit("dragonfly_wings", backpackpostinit)
AddPrefabPostInit("white_wings", backpackpostinit)




-- Custom recipes!
--[[

Default tech levels (science level you need to craft the item):
TECH.NONE
TECH.SCIENCE_ONE
TECH.SCIENCE_TWO
TECH.SCIENCE_THREE
TECH.MAGIC_TWO
TECH.MAGIC_THREE
]]

--AddRecipe("bat_wings",
--{ Ingredient("batwing", 12), Ingredient("boneshard", 1), Ingredient("twigs", 8)},
--RECIPETABS.SURVIVAL,
--TECH.SCIENCE_TWO,
--nil,
--nil,
--nil,
--nil,
--nil, -- <- Custom character tag would go here if you wanted only that character to craft your item
--"images/inventoryimages/bat_wings.xml")
local tec = GLOBAL.TECH.NONE
AddRecipe2("bat_wings", -- name
		{ Ingredient("batwing", 12), Ingredient("boneshard", 1), Ingredient("twigs", 8)},
		tec,
		{ atlas = "images/inventoryimages/wingpack/bat_wings.xml", image = "bat_wings.tex" },
		{ "CONTAINERS" })

--AddRecipe("dragonfly_wings",
--{ Ingredient("silk", 3), Ingredient("royal_jelly", 1), Ingredient("glommerwings", 2)},
--RECIPETABS.SURVIVAL,
--TECH.SCIENCE_TWO,
--nil,
--nil,
--nil,
--nil,
--nil, -- <- Custom character tag would go here if you wanted only that character to craft your item
--"images/inventoryimages/dragonfly_wings.xml")
AddRecipe2("dragonfly_wings", -- name
		{ Ingredient("silk", 3), Ingredient("royal_jelly", 1), Ingredient("glommerwings", 2)},
		tec,
		{ atlas = "images/inventoryimages/wingpack/dragonfly_wings.xml", image = "dragonfly_wings.tex" },
		{ "CONTAINERS" })

--
--AddRecipe("white_wings",
--{ Ingredient("goose_feather", 2), Ingredient("rope", 1), Ingredient("feather_robin_winter", 4)},
--RECIPETABS.LIGHT,
--TECH.SCIENCE_TWO,
--nil,
--nil,
--nil,
--nil,
--nil, -- <- Custom character tag would go here if you wanted only that character to craft your item
--"images/inventoryimages/white_wings.xml")
AddRecipe2("white_wings", -- name
		{ Ingredient("goose_feather", 2), Ingredient("rope", 1), Ingredient("feather_robin_winter", 4)},
		tec,
		{ atlas = "images/inventoryimages/wingpack/white_wings.xml", image = "white_wings.tex" },
		{ "CONTAINERS" })