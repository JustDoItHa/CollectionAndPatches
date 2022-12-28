----------------------------------------------------------------
--env与GLOBAL
--下行代码只代表查值时自动查global，增加global的变量或者修改global的变量时还是需要带"GLOBAL."
GLOBAL.setmetatable(
        env,
        {
            __index = function(t, k)
                return GLOBAL.rawget(GLOBAL, k)
            end
        }
)
----------------------------------------------------------------
---备注:本mod这里已经是在show me前面执行了 此处移到modmain.lua中
----兼容showme
----如果他优先级比我高，这一段生效
--for _, mod in pairs(ModManager.mods) do --遍历已开启的mod
--    --因为showme的modmain的全局变量里有 SHOWME_STRINGS 所以有这个变量的应该就是showme
--    if mod and mod.SHOWME_STRINGS then
--        --箱子的寻物已经加上去了
--        mod.postinitfns.PrefabPostInit._big_box = mod.postinitfns.PrefabPostInit.treasurechest
--        mod.postinitfns.PrefabPostInit._big_box_chest = mod.postinitfns.PrefabPostInit.treasurechest
--    end
--end
----如果他优先级比我低，那下面这一段生效
--TUNING.MONITOR_CHESTS = TUNING.MONITOR_CHESTS or {}
--TUNING.MONITOR_CHESTS._big_box = true
--TUNING.MONITOR_CHESTS._big_box_chest = true

----------------------------------------------------------------

--PrefabFiles = {
--    "_big_box" --超级大盒子
--}
table.insert(PrefabFiles, "_big_box")

--Assets = {}

--TUNING._BIGBOXUILOCATION_V = GetModConfigData("_big_box_ui_location_vertical")
--TUNING._BIGBOXUILOCATION_H = GetModConfigData("_big_box_ui_location_horizontal")
--
--TUNING._SET_PRESERVER_BIG_BOX = GetModConfigData("_set_preserver_big_box") --超级大箱子保鲜设置

STRINGS.NAMES._BIG_BOX = "便携式超级大箱子" --物体在游戏中显示的名字
STRINGS.CHARACTERS.GENERIC.DESCRIBE._BIG_BOX = "超级大箱子！" --物体的检查描述
STRINGS.RECIPE_DESC._BIG_BOX = "便携式超级大箱子，我在哪里，哪里就是家" --物体的制作栏描述

STRINGS.NAMES._BIG_BOX_CHEST = "便携式超级大箱子（用锤子）" --物体在游戏中显示的名字
STRINGS.CHARACTERS.GENERIC.DESCRIBE._BIG_BOX_CHEST = "地上便携式超级大箱子！" --物体的检查描述
STRINGS.RECIPE_DESC._BIG_BOX_CHEST = "便携式超级大箱子，我在哪里，哪里就是家" --物体的制作栏描述

modimport("scripts/_big_box_ui.lua")

local recipes_sets = {
    {
        --超级大箱子
        name = "_big_box", --Prefab名
        ingredients = {
            Ingredient("opalpreciousgem", 1), --彩虹宝石
            -- Ingredient("jellybean", 6), --彩虹糖豆
            Ingredient("boards", 80), --木板
            Ingredient("cutstone", 80), --石砖
            Ingredient("goldnugget", 80),
            Ingredient("pigskin", 40),
            Ingredient("nightmarefuel", 80),
            Ingredient("silk", 80),
            Ingredient("bearger_fur", 5),
            Ingredient("dragon_scales", 5),
            Ingredient("goose_feather", 20),
            Ingredient("minotaurhorn", 2)
        },
        tab = RECIPETABS.SURVIVAL,
        level = TECH.NONE, --科技等级
        placer = { no_deconstruction = true }, --
        min_spacing = nil, --最小间隔，默认
        nounlock = nil, --是否可以离开制作台制作，nil则可以离开制作台。
        numtogive = nil, --制作数量，若填nil则为制作1个。
        builder_tag = nil, --制作者需要拥有的Tag（标签），填nil则所有人都可以做
        atlas = "images/inventoryimages2.xml", --制作栏图片文档路径
        image = "sunkenchest.tex" --制作栏图片文件名，当名字与Prefab名相同时，可省略。
        -- testfn = , --自定义检测函数，需要满足该函数才能制作物品，不常用。
    }
}

--自定义可制作物品
for _, v in ipairs(recipes_sets) do
    -- print("modmain.lua开始自定义可制作物品")
    AddRecipe2(v.name, -- name
            v.ingredients, -- ingredients Add more like so ,
            v.level,
            { atlas = v.atlas, image = v.image },
            { "CONTAINERS" })
end

local _big_box = GetValidRecipe("_big_box")
_big_box.sortkey = -1000
