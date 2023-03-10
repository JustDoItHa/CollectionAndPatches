--Assets=
--{
--    Asset("ATLAS", "images/inventoryimages/magiclantern_white.xml"),
--	Asset("ATLAS", "images/inventoryimages/magiclantern_red.xml"),
--	Asset("ATLAS", "images/inventoryimages/magiclantern_blue.xml"),
--	Asset("ATLAS", "images/inventoryimages/magiclantern_pink.xml"),
--	Asset("ATLAS", "images/inventoryimages/magiclantern_purple.xml"),
--	Asset("ATLAS", "images/inventoryimages/magiclantern_orange.xml"),
--	Asset("ATLAS", "images/inventoryimages/magiclantern_yellow.xml"),
--	Asset("ATLAS", "images/inventoryimages/magiclantern_green.xml"),
--}
table.insert(Assets, Asset("ATLAS", "images/inventoryimages/magiclantern_white.xml"))
table.insert(Assets, Asset("ATLAS", "images/inventoryimages/magiclantern_red.xml"))
table.insert(Assets, Asset("ATLAS", "images/inventoryimages/magiclantern_blue.xml"))
table.insert(Assets, Asset("ATLAS", "images/inventoryimages/magiclantern_pink.xml"))
table.insert(Assets, Asset("ATLAS", "images/inventoryimages/magiclantern_purple.xml"))
table.insert(Assets, Asset("ATLAS", "images/inventoryimages/magiclantern_orange.xml"))
table.insert(Assets, Asset("ATLAS", "images/inventoryimages/magiclantern_yellow.xml"))
table.insert(Assets, Asset("ATLAS", "images/inventoryimages/magiclantern_green.xml"))


--get value in config
TUNING.LIGHT_SIZE = GetModConfigData("light_area")
TUNING.TINCUTRE_HEAL = GetModConfigData("Light_heal")
TUNING.SUNSHINE = GetModConfigData("Light_sunshine")
TUNING.MENACING = GetModConfigData("Light_menacing")
TUNING.POISON = GetModConfigData("Light_poison")
TUNING.EMBER = GetModConfigData("Light_Ember")
TUNING.ICY = GetModConfigData("Light_Icy")
-- end get value in config
--
--PrefabFiles =
--{
--	"magiclanterns"
--}
table.insert(PrefabFiles, "magiclanterns")

STRINGS = GLOBAL.STRINGS
RECIPETABS = GLOBAL.RECIPETABS
Recipe = GLOBAL.Recipe
Ingredient = GLOBAL.Ingredient
TECH = GLOBAL.TECH

--RECIPE STRINGS
local lang_setting = GetModConfigData("light_bottle_lang")
if lang_setting == "chs" then
	STRINGS.NAMES.MAGICLANTERN_WHITE = "???????????????"
	STRINGS.RECIPE_DESC.MAGICLANTERN_WHITE = "???????????????."

	STRINGS.NAMES.MAGICLANTERN_RED = "????????????"
	STRINGS.RECIPE_DESC.MAGICLANTERN_RED = "???????????????????????????."

	STRINGS.NAMES.MAGICLANTERN_BLUE = "????????????"
	STRINGS.RECIPE_DESC.MAGICLANTERN_BLUE = "????????????."

	STRINGS.NAMES.MAGICLANTERN_PINK = "???????????????"
	STRINGS.RECIPE_DESC.MAGICLANTERN_PINK = "??????????????????."

	STRINGS.NAMES.MAGICLANTERN_PURPLE = "????????????"
	STRINGS.RECIPE_DESC.MAGICLANTERN_PURPLE = "????????????????????????."

	STRINGS.NAMES.MAGICLANTERN_ORANGE = "????????????"
	STRINGS.RECIPE_DESC.MAGICLANTERN_ORANGE = "????????????????????????."

	STRINGS.NAMES.MAGICLANTERN_YELLOW = "????????????"
	STRINGS.RECIPE_DESC.MAGICLANTERN_YELLOW = "???????????????."

	STRINGS.NAMES.MAGICLANTERN_GREEN = "???????????????"
	STRINGS.RECIPE_DESC.MAGICLANTERN_GREEN = "?????????????????????."

	--STRINGS
	--Wilson/generic
	STRINGS.CHARACTERS.GENERIC.DESCRIBE.MAGICLANTERN_WHITE = "????????????."
	STRINGS.CHARACTERS.GENERIC.DESCRIBE.MAGICLANTERN_RED = "?????????????????????."
	STRINGS.CHARACTERS.GENERIC.DESCRIBE.MAGICLANTERN_BLUE = "????????????..."
	STRINGS.CHARACTERS.GENERIC.DESCRIBE.MAGICLANTERN_PINK = "????????????."
	STRINGS.CHARACTERS.GENERIC.DESCRIBE.MAGICLANTERN_PURPLE = "???????????????????????????."
	STRINGS.CHARACTERS.GENERIC.DESCRIBE.MAGICLANTERN_ORANGE = "????????????."
	STRINGS.CHARACTERS.GENERIC.DESCRIBE.MAGICLANTERN_YELLOW = "???????????????."
	STRINGS.CHARACTERS.GENERIC.DESCRIBE.MAGICLANTERN_GREEN = "??????????????????..."

	--Woodie
	STRINGS.CHARACTERS.WOODIE.DESCRIBE.MAGICLANTERN_WHITE = "???????????????."
	STRINGS.CHARACTERS.WOODIE.DESCRIBE.MAGICLANTERN_RED = "???????????????."
	STRINGS.CHARACTERS.WOODIE.DESCRIBE.MAGICLANTERN_BLUE = "????????????, ???????"
	STRINGS.CHARACTERS.WOODIE.DESCRIBE.MAGICLANTERN_PINK = "?????????????????????!."
	STRINGS.CHARACTERS.WOODIE.DESCRIBE.MAGICLANTERN_PURPLE = "???????????????????????????."
	STRINGS.CHARACTERS.WOODIE.DESCRIBE.MAGICLANTERN_ORANGE = "?????????????????????!"
	STRINGS.CHARACTERS.WOODIE.DESCRIBE.MAGICLANTERN_YELLOW = "????????????????????????."
	STRINGS.CHARACTERS.WOODIE.DESCRIBE.MAGICLANTERN_GREEN = "??????????????????, ???????"

	--Waxwell/Maxwell
	STRINGS.CHARACTERS.WAXWELL.DESCRIBE.MAGICLANTERN_WHITE = "????????????????????????."
	STRINGS.CHARACTERS.WAXWELL.DESCRIBE.MAGICLANTERN_RED = "???????????????."
	STRINGS.CHARACTERS.WAXWELL.DESCRIBE.MAGICLANTERN_BLUE = "???????????????."
	STRINGS.CHARACTERS.WAXWELL.DESCRIBE.MAGICLANTERN_PINK = "?????????????????????..."
	STRINGS.CHARACTERS.WAXWELL.DESCRIBE.MAGICLANTERN_PURPLE = "????????????????????????,????????????????"
	STRINGS.CHARACTERS.WAXWELL.DESCRIBE.MAGICLANTERN_ORANGE = "??????????????????."
	STRINGS.CHARACTERS.WAXWELL.DESCRIBE.MAGICLANTERN_YELLOW = "??????????????????."
	STRINGS.CHARACTERS.WAXWELL.DESCRIBE.MAGICLANTERN_GREEN = "?????????..."

	--Wolfgang
	STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.MAGICLANTERN_WHITE = "?????????!"
	STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.MAGICLANTERN_RED = "????????????."
	STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.MAGICLANTERN_BLUE = "(????????????),?????????!"
	STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.MAGICLANTERN_PINK = "???????????????????????????."
	STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.MAGICLANTERN_PURPLE = "????????????,?????????,????????????!"
	STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.MAGICLANTERN_ORANGE = "??????."
	STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.MAGICLANTERN_YELLOW = "????????????????????????!"
	STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.MAGICLANTERN_GREEN = "??????????????????."

	--WX78
	STRINGS.CHARACTERS.WX78.DESCRIBE.MAGICLANTERN_WHITE = "??????????????????"
	STRINGS.CHARACTERS.WX78.DESCRIBE.MAGICLANTERN_RED = "??????????????????!"
	STRINGS.CHARACTERS.WX78.DESCRIBE.MAGICLANTERN_BLUE = "????????????????????????"
	STRINGS.CHARACTERS.WX78.DESCRIBE.MAGICLANTERN_PINK = "?????????????????????"
	STRINGS.CHARACTERS.WX78.DESCRIBE.MAGICLANTERN_PURPLE = "????????????????????????"
	STRINGS.CHARACTERS.WX78.DESCRIBE.MAGICLANTERN_ORANGE = "??????????????????"
	STRINGS.CHARACTERS.WX78.DESCRIBE.MAGICLANTERN_YELLOW = "????????????????????????"
	STRINGS.CHARACTERS.WX78.DESCRIBE.MAGICLANTERN_GREEN = "???????????????????????????"

	--Willow
	STRINGS.CHARACTERS.WILLOW.DESCRIBE.MAGICLANTERN_WHITE = "???????????????????????????."
	STRINGS.CHARACTERS.WILLOW.DESCRIBE.MAGICLANTERN_RED = "???????????????."
	STRINGS.CHARACTERS.WILLOW.DESCRIBE.MAGICLANTERN_BLUE = "??????????????????."
	STRINGS.CHARACTERS.WILLOW.DESCRIBE.MAGICLANTERN_PINK = "???????????????????????????."
	STRINGS.CHARACTERS.WILLOW.DESCRIBE.MAGICLANTERN_PURPLE = "???????????????."
	STRINGS.CHARACTERS.WILLOW.DESCRIBE.MAGICLANTERN_ORANGE = "????????????????????????!"
	STRINGS.CHARACTERS.WILLOW.DESCRIBE.MAGICLANTERN_YELLOW = "???????????????."
	STRINGS.CHARACTERS.WILLOW.DESCRIBE.MAGICLANTERN_GREEN = "????????????????????????."

	--Wendy
	STRINGS.CHARACTERS.WENDY.DESCRIBE.MAGICLANTERN_WHITE = "?????????????????????."
	STRINGS.CHARACTERS.WENDY.DESCRIBE.MAGICLANTERN_RED = "????????????????????????."
	STRINGS.CHARACTERS.WENDY.DESCRIBE.MAGICLANTERN_BLUE = "?????????????????????"
	STRINGS.CHARACTERS.WENDY.DESCRIBE.MAGICLANTERN_PINK = "???????????????!"
	STRINGS.CHARACTERS.WENDY.DESCRIBE.MAGICLANTERN_PURPLE = "???????????????????????????????????????."
	STRINGS.CHARACTERS.WENDY.DESCRIBE.MAGICLANTERN_ORANGE = "????????????."
	STRINGS.CHARACTERS.WENDY.DESCRIBE.MAGICLANTERN_YELLOW = "????????????????????????."
	STRINGS.CHARACTERS.WENDY.DESCRIBE.MAGICLANTERN_GREEN = "??????????????????."

	--Wickerbottom
	STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.MAGICLANTERN_WHITE = "A simple light."
	STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.MAGICLANTERN_RED = "Magic is merely science we can't yet explain."
	STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.MAGICLANTERN_BLUE = "An inverse use of thermal energy."
	STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.MAGICLANTERN_PINK = "I wonder if this has any recreational application?"
	STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.MAGICLANTERN_PURPLE = "I should study its regenerative properties."
	STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.MAGICLANTERN_ORANGE = "An interesting use of thermal energy."
	STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.MAGICLANTERN_YELLOW = "Did this treatment pass clinical studies?"
	STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.MAGICLANTERN_GREEN = "It shows signs of toxicity."

	--Webber
	STRINGS.CHARACTERS.WEBBER.DESCRIBE.MAGICLANTERN_WHITE = "??????????????????."
	STRINGS.CHARACTERS.WEBBER.DESCRIBE.MAGICLANTERN_RED = "?????????????????????"
	STRINGS.CHARACTERS.WEBBER.DESCRIBE.MAGICLANTERN_BLUE = "??????????????????????????????."
	STRINGS.CHARACTERS.WEBBER.DESCRIBE.MAGICLANTERN_PINK = "???????????????????"
	STRINGS.CHARACTERS.WEBBER.DESCRIBE.MAGICLANTERN_PURPLE = "???????????????!"
	STRINGS.CHARACTERS.WEBBER.DESCRIBE.MAGICLANTERN_ORANGE = "???????????????!"
	STRINGS.CHARACTERS.WEBBER.DESCRIBE.MAGICLANTERN_YELLOW = "???????????????????????????."
	STRINGS.CHARACTERS.WEBBER.DESCRIBE.MAGICLANTERN_GREEN = "???!"

	--Wathgrithr/Wigfrid
	STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.MAGICLANTERN_WHITE = "???????????????????????????????????????!"
	STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.MAGICLANTERN_RED = "????????????????????????????????????."
	STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.MAGICLANTERN_BLUE = "???????????????????????????."
	STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.MAGICLANTERN_PINK = "???????????????!"
	STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.MAGICLANTERN_PURPLE = "???????????????."
	STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.MAGICLANTERN_ORANGE = "?????????????????????."
	STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.MAGICLANTERN_YELLOW = "?????????????????????."
	STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.MAGICLANTERN_GREEN = "??????????????????????????????!"

else
	STRINGS.NAMES.MAGICLANTERN_WHITE = "Glowing Bottle"
	STRINGS.RECIPE_DESC.MAGICLANTERN_WHITE = "To light your way."

	STRINGS.NAMES.MAGICLANTERN_RED = "Menacing Bottle"
	STRINGS.RECIPE_DESC.MAGICLANTERN_RED = "An ancient power."

	STRINGS.NAMES.MAGICLANTERN_BLUE = "Icy Bottle"
	STRINGS.RECIPE_DESC.MAGICLANTERN_BLUE = "A calming light."

	STRINGS.NAMES.MAGICLANTERN_PINK = "Peace Bottle"
	STRINGS.RECIPE_DESC.MAGICLANTERN_PINK = "Sunset in a bottle."

	STRINGS.NAMES.MAGICLANTERN_PURPLE = "Tincture Bottle"
	STRINGS.RECIPE_DESC.MAGICLANTERN_PURPLE = "A mystic glow."

	STRINGS.NAMES.MAGICLANTERN_ORANGE = "Ember Bottle"
	STRINGS.RECIPE_DESC.MAGICLANTERN_ORANGE = "Like a dying fire."

	STRINGS.NAMES.MAGICLANTERN_YELLOW = "Sunshine Bottle"
	STRINGS.RECIPE_DESC.MAGICLANTERN_YELLOW = "To light the night."

	STRINGS.NAMES.MAGICLANTERN_GREEN = "Poison Bottle"
	STRINGS.RECIPE_DESC.MAGICLANTERN_GREEN = "A sickly glow."

	--STRINGS
	--Wilson/generic
	STRINGS.CHARACTERS.GENERIC.DESCRIBE.MAGICLANTERN_WHITE = "It glows."
	STRINGS.CHARACTERS.GENERIC.DESCRIBE.MAGICLANTERN_RED = "Red means danger."
	STRINGS.CHARACTERS.GENERIC.DESCRIBE.MAGICLANTERN_BLUE = "It's strange..."
	STRINGS.CHARACTERS.GENERIC.DESCRIBE.MAGICLANTERN_PINK = "It's pretty."
	STRINGS.CHARACTERS.GENERIC.DESCRIBE.MAGICLANTERN_PURPLE = "There's power here."
	STRINGS.CHARACTERS.GENERIC.DESCRIBE.MAGICLANTERN_ORANGE = "It's warm."
	STRINGS.CHARACTERS.GENERIC.DESCRIBE.MAGICLANTERN_YELLOW = "A light in the dark."
	STRINGS.CHARACTERS.GENERIC.DESCRIBE.MAGICLANTERN_GREEN = "It looks sickly..."

	--Woodie
	STRINGS.CHARACTERS.WOODIE.DESCRIBE.MAGICLANTERN_WHITE = "It lights the way."
	STRINGS.CHARACTERS.WOODIE.DESCRIBE.MAGICLANTERN_RED = "I don't trust it."
	STRINGS.CHARACTERS.WOODIE.DESCRIBE.MAGICLANTERN_BLUE = "A bit nippy, eh?"
	STRINGS.CHARACTERS.WOODIE.DESCRIBE.MAGICLANTERN_PINK = "That'll stop the kerfuffle."
	STRINGS.CHARACTERS.WOODIE.DESCRIBE.MAGICLANTERN_PURPLE = "It'll get me well again."
	STRINGS.CHARACTERS.WOODIE.DESCRIBE.MAGICLANTERN_ORANGE = "That's toastie for sure!"
	STRINGS.CHARACTERS.WOODIE.DESCRIBE.MAGICLANTERN_YELLOW = "As nice as a summer day."
	STRINGS.CHARACTERS.WOODIE.DESCRIBE.MAGICLANTERN_GREEN = "That'll teach 'em, eh?"

	--Waxwell/Maxwell
	STRINGS.CHARACTERS.WAXWELL.DESCRIBE.MAGICLANTERN_WHITE = "This should keep her at bay."
	STRINGS.CHARACTERS.WAXWELL.DESCRIBE.MAGICLANTERN_RED = "A dangerous thing."
	STRINGS.CHARACTERS.WAXWELL.DESCRIBE.MAGICLANTERN_BLUE = "A piece of winter."
	STRINGS.CHARACTERS.WAXWELL.DESCRIBE.MAGICLANTERN_PINK = "Keep your enemies close..."
	STRINGS.CHARACTERS.WAXWELL.DESCRIBE.MAGICLANTERN_PURPLE = "It gives me life, at what cost?"
	STRINGS.CHARACTERS.WAXWELL.DESCRIBE.MAGICLANTERN_ORANGE = "A fire inside."
	STRINGS.CHARACTERS.WAXWELL.DESCRIBE.MAGICLANTERN_YELLOW = "Quite a dapper light."
	STRINGS.CHARACTERS.WAXWELL.DESCRIBE.MAGICLANTERN_GREEN = "It's toxic."

	--Wolfgang
	STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.MAGICLANTERN_WHITE = "Shiny!"
	STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.MAGICLANTERN_RED = "It scary."
	STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.MAGICLANTERN_BLUE = "Brr, chilly!"
	STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.MAGICLANTERN_PINK = "It make a friend."
	STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.MAGICLANTERN_PURPLE = "I strong!"
	STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.MAGICLANTERN_ORANGE = "It warm."
	STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.MAGICLANTERN_YELLOW = "Wolfgang is not afraid!"
	STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.MAGICLANTERN_GREEN = "I should not drink."

	--WX78
	STRINGS.CHARACTERS.WX78.DESCRIBE.MAGICLANTERN_WHITE = "IT GLOWS IN THE DARK"
	STRINGS.CHARACTERS.WX78.DESCRIBE.MAGICLANTERN_RED = "PROXIMITY WARNING: DANGER"
	STRINGS.CHARACTERS.WX78.DESCRIBE.MAGICLANTERN_BLUE = "IT COOLS MY CIRCUITS"
	STRINGS.CHARACTERS.WX78.DESCRIBE.MAGICLANTERN_PINK = "SUBJECT CREATES A COMBAT ERROR"
	STRINGS.CHARACTERS.WX78.DESCRIBE.MAGICLANTERN_PURPLE = "POSITIVE NOCTURAL FEEDBACK LOOP"
	STRINGS.CHARACTERS.WX78.DESCRIBE.MAGICLANTERN_ORANGE = "MONITORING SYSTEM TEMPERATURE"
	STRINGS.CHARACTERS.WX78.DESCRIBE.MAGICLANTERN_YELLOW = "SYSTEM OPTIMIZATION IN PROGRESS"
	STRINGS.CHARACTERS.WX78.DESCRIBE.MAGICLANTERN_GREEN = "IT CORRODES ORGANIC LIFEFORMS"

	--Willow
	STRINGS.CHARACTERS.WILLOW.DESCRIBE.MAGICLANTERN_WHITE = "I like my lighter better."
	STRINGS.CHARACTERS.WILLOW.DESCRIBE.MAGICLANTERN_RED = "I don't like it."
	STRINGS.CHARACTERS.WILLOW.DESCRIBE.MAGICLANTERN_BLUE = "A frosted light."
	STRINGS.CHARACTERS.WILLOW.DESCRIBE.MAGICLANTERN_PINK = "It banks the fires of combat."
	STRINGS.CHARACTERS.WILLOW.DESCRIBE.MAGICLANTERN_PURPLE = "It heals the hurts."
	STRINGS.CHARACTERS.WILLOW.DESCRIBE.MAGICLANTERN_ORANGE = "The fire should be free!"
	STRINGS.CHARACTERS.WILLOW.DESCRIBE.MAGICLANTERN_YELLOW = "Keeps the nightmares away."
	STRINGS.CHARACTERS.WILLOW.DESCRIBE.MAGICLANTERN_GREEN = "It's sick, like my dreams."

	--Wendy
	STRINGS.CHARACTERS.WENDY.DESCRIBE.MAGICLANTERN_WHITE = "Like a candle in the night."
	STRINGS.CHARACTERS.WENDY.DESCRIBE.MAGICLANTERN_RED = "It's cursed, stay back."
	STRINGS.CHARACTERS.WENDY.DESCRIBE.MAGICLANTERN_BLUE = "I feel an icy grip."
	STRINGS.CHARACTERS.WENDY.DESCRIBE.MAGICLANTERN_PINK = "It makes me want to play!"
	STRINGS.CHARACTERS.WENDY.DESCRIBE.MAGICLANTERN_PURPLE = "I can feel my strength returning."
	STRINGS.CHARACTERS.WENDY.DESCRIBE.MAGICLANTERN_ORANGE = "Warm and cosy."
	STRINGS.CHARACTERS.WENDY.DESCRIBE.MAGICLANTERN_YELLOW = "There goes my melancholia."
	STRINGS.CHARACTERS.WENDY.DESCRIBE.MAGICLANTERN_GREEN = "It festers the blood."

	--Wickerbottom
	STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.MAGICLANTERN_WHITE = "A simple light."
	STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.MAGICLANTERN_RED = "Magic is merely science we can't yet explain."
	STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.MAGICLANTERN_BLUE = "An inverse use of thermal energy."
	STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.MAGICLANTERN_PINK = "I wonder if this has any recreational application?"
	STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.MAGICLANTERN_PURPLE = "I should study its regenerative properties."
	STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.MAGICLANTERN_ORANGE = "An interesting use of thermal energy."
	STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.MAGICLANTERN_YELLOW = "Did this treatment pass clinical studies?"
	STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.MAGICLANTERN_GREEN = "It shows signs of toxicity."

	--Webber
	STRINGS.CHARACTERS.WEBBER.DESCRIBE.MAGICLANTERN_WHITE = "A night light."
	STRINGS.CHARACTERS.WEBBER.DESCRIBE.MAGICLANTERN_RED = "We don't like it!"
	STRINGS.CHARACTERS.WEBBER.DESCRIBE.MAGICLANTERN_BLUE = "Our fingers and toes are cold."
	STRINGS.CHARACTERS.WEBBER.DESCRIBE.MAGICLANTERN_PINK = "Maybe they want to play?"
	STRINGS.CHARACTERS.WEBBER.DESCRIBE.MAGICLANTERN_PURPLE = "Better than eating vegetables!"
	STRINGS.CHARACTERS.WEBBER.DESCRIBE.MAGICLANTERN_ORANGE = "Warm and snuggly!"
	STRINGS.CHARACTERS.WEBBER.DESCRIBE.MAGICLANTERN_YELLOW = "It makes us feel better."
	STRINGS.CHARACTERS.WEBBER.DESCRIBE.MAGICLANTERN_GREEN = "Yuck!"

	--Wathgrithr/Wigfrid
	STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.MAGICLANTERN_WHITE = "To better see my night time foes!"
	STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.MAGICLANTERN_RED = "I must see the evil to slay it."
	STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.MAGICLANTERN_BLUE = "I shall call it Skadi's brew."
	STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.MAGICLANTERN_PINK = "A coward maker!"
	STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.MAGICLANTERN_PURPLE = "Eir protect me."
	STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.MAGICLANTERN_ORANGE = "A blessing from Sol herself."
	STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.MAGICLANTERN_YELLOW = "A soft summer light."
	STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.MAGICLANTERN_GREEN = "A slow death to my foes!"

end
---------------------------------------

AddRecipe("magiclantern_white",
{
	Ingredient("marble", 2),
	Ingredient("fireflies", 2),
	Ingredient("nitre", 2),
},
	RECIPETABS.LIGHT, TECH.MAGIC_TWO, "magiclantern_white_placer", 0.5, nil, nil, nil,
"images/inventoryimages/magiclantern_white.xml", "magiclantern_white.tex")

AddRecipe("magiclantern_red",
{
	Ingredient("red_cap", 2),
	Ingredient("fireflies", 2),
	Ingredient("redgem", 1),
},
	RECIPETABS.LIGHT, TECH.MAGIC_TWO, "magiclantern_red_placer", 0.5, nil, nil, nil,
"images/inventoryimages/magiclantern_red.xml", "magiclantern_red.tex")

AddRecipe("magiclantern_blue",
{
	Ingredient("blue_cap", 2),
	Ingredient("fireflies", 2),
	Ingredient("bluegem", 1),
},
	RECIPETABS.LIGHT, TECH.MAGIC_TWO, "magiclantern_blue_placer", 0.5, nil, nil, nil,
"images/inventoryimages/magiclantern_blue.xml", "magiclantern_blue.tex")

AddRecipe("magiclantern_pink",
{
	Ingredient("lureplantbulb", 2),
	Ingredient("fireflies", 2),
	Ingredient("spidergland", 2),
},
	RECIPETABS.LIGHT, TECH.MAGIC_TWO, "magiclantern_pink_placer", 0.5, nil, nil, nil,
"images/inventoryimages/magiclantern_pink.xml", "magiclantern_pink.tex")

AddRecipe("magiclantern_purple",
{
	Ingredient("eggplant", 2),
	Ingredient("fireflies", 2),
	Ingredient("purplegem", 1),
},
	RECIPETABS.LIGHT, TECH.MAGIC_THREE, "magiclantern_purple_placer", 0.5, nil, nil, nil,
"images/inventoryimages/magiclantern_purple.xml", "magiclantern_purple.tex")

AddRecipe("magiclantern_orange",
{
	Ingredient("carrot", 2),
	Ingredient("fireflies", 2),
	Ingredient("orangegem", 1),
},
	RECIPETABS.LIGHT, TECH.MAGIC_THREE, "magiclantern_orange_placer", 0.5, nil, nil, nil,
"images/inventoryimages/magiclantern_orange.xml", "magiclantern_orange.tex")

AddRecipe("magiclantern_yellow",
{
	Ingredient("honey", 2),
	Ingredient("fireflies", 2),
	Ingredient("yellowgem", 1),
},
	RECIPETABS.LIGHT, TECH.MAGIC_THREE, "magiclantern_yellow_placer", 0.5, nil, nil, nil,
"images/inventoryimages/magiclantern_yellow.xml", "magiclantern_yellow.tex")

AddRecipe("magiclantern_green",
{
	Ingredient("green_cap", 2),
	Ingredient("fireflies", 2),
	Ingredient("greengem", 1),
},
	RECIPETABS.LIGHT, TECH.MAGIC_THREE, "magiclantern_green_placer", 0.5, nil, nil, nil,
"images/inventoryimages/magiclantern_green.xml", "magiclantern_green.tex")