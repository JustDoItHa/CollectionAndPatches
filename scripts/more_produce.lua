local STRINGS = GLOBAL.STRINGS
local require = GLOBAL.require
local TECH = GLOBAL.TECH
local RECIPETABS = GLOBAL.RECIPETABS
local _G = GLOBAL
local Ingredient = GLOBAL.Ingredient
local AllRecipes = GLOBAL.AllRecipes
local Recipe = GLOBAL.Recipe

if GetModConfigData("baka_lamp") then
    table.insert(PrefabFiles, "baka_lamp_post")
    table.insert(PrefabFiles, "baka_lamp_short")
    -------------霓庭灯--------------------------
    STRINGS.NAMES.BAKA_LAMP_POST = "霓庭灯"
    STRINGS.RECIPE_DESC.BAKA_LAMP_POST = "萤火虫提供能源"
    STRINGS.CHARACTERS.GENERIC.DESCRIBE.BAKA_LAMP_POST = "夜深了我还为你不能睡"

    AddRecipe2("baka_lamp_post", { Ingredient("fireflies", 10),
                                   Ingredient("log", 20),
                                   Ingredient("flint", 20) },
            TECH.SCIENCE_TWO,
            { placer = "baka_lamp_post_placer", min_spacing = 1, atlas = "images/inventoryimages/lamp_post.xml", image = "lamp_post.tex" },
            { "LIGHT" })
    -------------虹庭灯--------------------------
    STRINGS.NAMES.BAKA_LAMP_SHORT = "虹庭灯"
    STRINGS.RECIPE_DESC.BAKA_LAMP_SHORT = "珍珠般的漂亮华灯"
    STRINGS.CHARACTERS.GENERIC.DESCRIBE.BAKA_LAMP_SHORT = "妈妈再也不用担心我晚上怕黑了"

    AddRecipe2("baka_lamp_short", { Ingredient("fireflies", 10),
                                    Ingredient("log", 20),
                                    Ingredient("flint", 20) },
            TECH.SCIENCE_TWO,
            { placer = "baka_lamp_short_placer", min_spacing = 1, atlas = "images/inventoryimages/lamp_short.xml", image = "lamp_short.tex" },
            { "LIGHT" })
end

if GetModConfigData("rabbit_house") then
    table.insert(PrefabFiles, "change_fountain")
    -------------兔子喷泉--------------------------
    STRINGS.NAMES.CHANGE_FOUNTAIN = "兔子喷泉"
    STRINGS.CHARACTERS.GENERIC.DESCRIBE.CHANGE_FOUNTAIN = "多么漂亮的喷泉啊！"

    local change_fountain = AddRecipe2("change_fountain",
            { Ingredient("goldnugget", 40), Ingredient("flint", 20), Ingredient("manrabbit_tail", 20) },
            TECH.SCIENCE_ONE,
            { placer = "change_fountain_placer", min_spacing = 3, atlas = "images/inventoryimages/change_fountain.xml", image = "change_fountain.tex" },
            { "STRUCTURES" })

    local change_fountain_sortkey = AllRecipes["rabbithouse"]["sortkey"]
    change_fountain.sortkey = change_fountain_sortkey + 0.1
end