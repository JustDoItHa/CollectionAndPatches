GLOBAL.setmetatable(env, { __index = function(t, k)
    return GLOBAL.rawget(GLOBAL, k)
end })

-- [TUNING]--------------------
--TUNING.ROOMCAR_BIGBAG_BAGSIZE = GetModConfigData("BAGSIZE")
--TUNING.ROOMCAR_BIGBAG_LANG = GetModConfigData("LANG")
----TUNING.ROOMCAR_BIGBAG_GIVE = GetModConfigData("GIVE")
--TUNING.ROOMCAR_BIGBAG_STACK = GetModConfigData("STACK")
--TUNING.ROOMCAR_BIGBAG_FRESH = GetModConfigData("FRESH")
--TUNING.ROOMCAR_BIGBAG_KEEPFRESH = GetModConfigData("KEEPFRESH")
--TUNING.ROOMCAR_BIGBAG_LIGHT = GetModConfigData("LIGHT")
--TUNING.ROOMCAR_BIGBAG_RECIPE = GetModConfigData("RECIPE")
--TUNING.ROOMCAR_BIGBAG_WALKSPEED = GetModConfigData("WALKSPEED")
--TUNING.ROOMCAR_BIGBAG_CONTAINERDRAG_SWITCH = GetModConfigData("CONTAINERDRAG_SWITCH")
--TUNING.ROOMCAR_BIGBAG_BAGINBAG = GetModConfigData("BAGINBAG")
--TUNING.ROOMCAR_BIGBAG_HEATROCKTEMPERATURE = GetModConfigData("HEATROCKTEMPERATURE")
--TUNING.ROOMCAR_BIGBAG_WATER = GetModConfigData("BIGBAGWATER")
--TUNING.ROOMCAR_BIGBAG_PICK = GetModConfigData("BIGBAGPICK")
--TUNING.NICE_BIGBAGSIZE = GetModConfigData("NICEBIGBAGSIZE")
table.insert(PrefabFiles, "bigbag")
table.insert(PrefabFiles, "gembigbag")
table.insert(PrefabFiles, "nicebigbag")
table.insert(PrefabFiles, "catbigbag")
table.insert(PrefabFiles, "catback")
table.insert(PrefabFiles, "lifelight")

--大背包
--[[Asset("ANIM", "anim/swap_bigbag.zip"),
Asset("ANIM", "anim/ui_bigbag_3x8.zip"),
Asset("ANIM", "anim/ui_bigbag_4x8.zip"),
--Asset("ANIM", "anim/bigbag_ui_8x6.zip"),
--Asset("ANIM", "anim/bigbag_ui_8x8.zip"),

Asset("IMAGE", "images/inventoryimages/bigbag.tex"),
Asset("ATLAS", "images/inventoryimages/bigbag.xml"),

Asset("IMAGE", "minimap/bigbag.tex"),
Asset("ATLAS", "minimap/bigbag.xml"),

--Asset("IMAGE", "images/bigbagbg.tex"),
--Asset("ATLAS", "images/bigbagbg.xml"),

Asset("IMAGE", "images/bigbagbg_8x8.tex"),
Asset("ATLAS", "images/bigbagbg_8x8.xml"),

Asset("IMAGE", "images/bigbagbg_8x6.tex"),
Asset("ATLAS", "images/bigbagbg_8x6.xml"),]]
table.insert(Assets, Asset("ANIM", "anim/swap_bigbag.zip"))
table.insert(Assets, Asset("ANIM", "anim/ui_bigbag_3x8.zip"))
table.insert(Assets, Asset("ANIM", "anim/ui_bigbag_4x8.zip"))
--table.insert(Assets, Asset("ANIM", "anim/bigbag_ui_8x6.zip"))
--table.insert(Assets, Asset("ANIM", "anim/bigbag_ui_8x8.zip"))

table.insert(Assets, Asset("IMAGE", "images/inventoryimages/bigbag.tex"))
table.insert(Assets, Asset("ATLAS", "images/inventoryimages/bigbag.xml"))

table.insert(Assets, Asset("IMAGE", "images/inventoryimages/catback.tex"))
table.insert(Assets, Asset("ATLAS", "images/inventoryimages/catback.xml"))

--table.insert(Assets, Asset("IMAGE", "minimap/bigbag.tex"))
--table.insert(Assets, Asset("ATLAS", "minimap/bigbag.xml"))
table.insert(Assets, Asset("IMAGE", "images/minimap/bigbag.tex"))
table.insert(Assets, Asset("ATLAS", "images/minimap/bigbag.xml"))
table.insert(Assets, Asset("IMAGE", "images/minimap/bluebigbag.tex"))
table.insert(Assets, Asset("ATLAS", "images/minimap/bluebigbag.xml"))
table.insert(Assets, Asset("IMAGE", "images/minimap/redbigbag.tex"))
table.insert(Assets, Asset("ATLAS", "images/minimap/redbigbag.xml"))

table.insert(Assets, Asset("IMAGE", "images/minimap/nicebigbag.tex"))
table.insert(Assets, Asset("ATLAS", "images/minimap/nicebigbag.xml"))

table.insert(Assets, Asset("IMAGE", "images/minimap/catback.tex"))
table.insert(Assets, Asset("ATLAS", "images/minimap/catback.xml"))

--table.insert(Assets, Asset("IMAGE", "images/bigbagbg.tex"))
--table.insert(Assets, Asset("ATLAS", "images/bigbagbg.xml"))

table.insert(Assets, Asset("IMAGE", "images/bigbagbg_8x8.tex"))
table.insert(Assets, Asset("ATLAS", "images/bigbagbg_8x8.xml"))

table.insert(Assets, Asset("IMAGE", "images/bigbagbg_8x6.tex"))
table.insert(Assets, Asset("ATLAS", "images/bigbagbg_8x6.xml"))


-- [Miniap Icon]--------------------
AddMinimapAtlas("images/minimap/bigbag.xml")
AddMinimapAtlas("images/minimap/bluebigbag.xml")
AddMinimapAtlas("images/minimap/redbigbag.xml")
AddMinimapAtlas("images/minimap/nicebigbag.xml")
AddMinimapAtlas("images/minimap/catback.xml")

--------------------------------------------------------------------------------------------------------------------------
-- [Global Strings]
if TUNING.ROOMCAR_BIGBAG_LANG == 1 then
    GLOBAL.STRINGS.bigbag_BUTTON = "整理"
else
    GLOBAL.STRINGS.bigbag_BUTTON = "Sort"
end

--------------------
local Ingredient = GLOBAL.Ingredient
--------------------------------------------------------------------------------------------------------------------------
-- [Custom Recipe]
--------------------

local tec = GLOBAL.TECH.NONE
local RcpType = TUNING.ROOMCAR_BIGBAG_RECIPE

local RcpPlus = { Ingredient("purplegem", 3) }

local RcpVC = { Ingredient("cutgrass", 1) }
local RcpC = { Ingredient("pigskin", 5) }
local RcpN = { Ingredient("goldnugget", 10), Ingredient("pigskin", 10) }
local RcpE = { Ingredient("goldnugget", 20), Ingredient("pigskin", 10), Ingredient("nightmarefuel", 5) }
local RcpVE = { Ingredient("goldnugget", 40), Ingredient("pigskin", 10), Ingredient("nightmarefuel", 20) }
local RcpVVE = { Ingredient("goldnugget", 80),
                 Ingredient("pigskin", 40),
                 Ingredient("nightmarefuel", 80),
                 Ingredient("silk", 80),
                 Ingredient("bearger_fur", 5),
                 Ingredient("dragon_scales", 5),
                 Ingredient("goose_feather", 20),
                 Ingredient("minotaurhorn", 2) }

local rcp = RcpN

if RcpType == 1 then
    rcp = RcpVC
    tec = GLOBAL.TECH.NONE
elseif RcpType == 2 then
    rcp = RcpC
    tec = GLOBAL.TECH.SCIENCE_ONE
elseif RcpType == 3 then
    rcp = RcpN
    tec = GLOBAL.TECH.SCIENCE_TWO
elseif RcpType == 4 then
    rcp = RcpE
    tec = GLOBAL.TECH.MAGIC_ONE
elseif RcpType == 5 then
    rcp = RcpVE
    tec = GLOBAL.TECH.MAGIC_TWO
elseif RcpType == 6 then
    rcp = RcpVVE
    tec = GLOBAL.TECH.MAGIC_TWO
else
    rcp = RcpN
    tec = GLOBAL.TECH.SCIENCE_TWO
end

if TUNING.ROOMCAR_BIGBAG_FRESH and TUNING.ROOMCAR_BIGBAG_STACK then
    for _, v in ipairs(RcpPlus) do
        table.insert(rcp, v)
    end
end

local RcpVE_MODs = {}
if TUNING.QIONG_ENABLE then
    table.insert(RcpVE_MODs, Ingredient("sorahat", 1, "images/inventoryimages/sorahat.xml"))
    table.insert(RcpVE_MODs, Ingredient("sorahealing", 1, "images/inventoryimages/sorahealing.xml"))
    table.insert(RcpVE_MODs, Ingredient("soramagic", 1, "images/inventoryimages/soramagic.xml"))
    table.insert(RcpVE_MODs, Ingredient("soratele", 1, "images/inventoryimages/soratele.xml"))
    table.insert(RcpVE_MODs, Ingredient("sorapick", 1, "images/inventoryimages/sorapick.xml"))
    table.insert(RcpVE_MODs, Ingredient("soraclothes", 1, "images/inventoryimages/soraclothes.xml"))
    table.insert(RcpVE_MODs, Ingredient("sorabowknot", 1, "images/inventoryimages/sorabowknot.xml"))
    table.insert(RcpVE_MODs, Ingredient("sora2pack", 10, "images/inventoryimages/sora2pack.xml"))
end
if TUNING.ELAINA_ENABLE then
    table.insert(RcpVE_MODs, Ingredient("elaina_bundlewrap", 10, "images/inventoryimages/elaina_bundlewrap.xml"))
end
if TUNING.YEYU_NILXIN_ENABLE then
    table.insert(RcpVE_MODs, Ingredient("yyxk_gift", 20, "images/inventoryimages.xml", nil, "giftwrap.tex"))
    table.insert(RcpVE_MODs, Ingredient("yyxk_bukas", 1, "images/nilxin_inventoryimages.xml", nil, "yyxk_buka_item.tex"))
end
if TUNING.QIHUANJIANGLIN_ENABLE then
    table.insert(RcpVE_MODs, Ingredient("ab_lnhx", 1, "images/inventoryimages/ab_lnhx.xml"))
end
if TUNING.ARIA_ENABLE then
    table.insert(RcpVE_MODs, Ingredient("aria_fantasycore", 1, "images/inventoryimages/aria_fantasycore.xml"))
end

if not GetModConfigData("BIG_BAG_ONLY_IN_TUMBLEWEED") then
    if GetModConfigData("BIG_BAG_EFFECTED_BY_OTHER_MODS") and #RcpVE_MODs > 0 then
        local bigbag = AddRecipe2("bigbag_n", RcpVE_MODs,
                tec,
                { no_deconstruction = true, atlas = "images/inventoryimages/bigbag.xml", image = "bigbag.tex", product = "bigbag" },
                { "CONTAINERS" })

        local redbigbag = AddRecipe2("redbigbag_n", -- name
                { Ingredient("bigbag", 1, "images/inventoryimages/bigbag.xml"), Ingredient("redgem", 10) }, -- ingredients Add more like so ,
                tec,
                { no_deconstruction = true, atlas = "images/inventoryimages/redbigbag.xml", image = "redbigbag.tex", product = "redbigbag" },
                { "CONTAINERS" })

        local bluebigbag = AddRecipe2("bluebigbag_n", -- name
                { Ingredient("bigbag", 1, "images/inventoryimages/bigbag.xml"), Ingredient("bluegem", 10) }, -- ingredients Add more like so ,
                tec,
                { no_deconstruction = true, atlas = "images/inventoryimages/bluebigbag.xml", image = "bluebigbag.tex", product = "bluebigbag" },
                { "CONTAINERS" })

        local nicebigbag = AddRecipe2("nicebigbag_n",
                RcpVE_MODs,
                tec,
                { no_deconstruction = true, atlas = "images/inventoryimages/nicebigbag.xml", image = "nicebigbag.tex", product = "nicebigbag" },
                { "CONTAINERS" })

        local catbigbag = AddRecipe2("catbigbag_n", -- name
                RcpVE_MODs,
                tec,
                { no_deconstruction = true, atlas = "images/inventoryimages/catback.xml", image = "catback.tex", product = "catbigbag" },
                { "CONTAINERS" })

        local catback = AddRecipe2("catback_n", -- name
                RcpVE_MODs,
                tec,
                { no_deconstruction = true, atlas = "images/inventoryimages/catback.xml", image = "catback.tex", product = "catback" },
                { "CONTAINERS" })
    else
        local bigbag = AddRecipe2("bigbag", rcp,
                tec,
                { atlas = "images/inventoryimages/bigbag.xml", image = "bigbag.tex" },
                { "CONTAINERS" })

        local redbigbag = AddRecipe2("redbigbag", -- name
                { Ingredient("bigbag", 1, "images/inventoryimages/bigbag.xml"), Ingredient("redgem", 10) }, -- ingredients Add more like so ,
                tec,
                { atlas = "images/inventoryimages/redbigbag.xml", image = "redbigbag.tex" },
                { "CONTAINERS" })

        local bluebigbag = AddRecipe2("bluebigbag", -- name
                { Ingredient("bigbag", 1, "images/inventoryimages/bigbag.xml"), Ingredient("bluegem", 10) }, -- ingredients Add more like so ,
                tec,
                { atlas = "images/inventoryimages/bluebigbag.xml", image = "bluebigbag.tex" },
                { "CONTAINERS" })

        local nicebigbag = AddRecipe2("nicebigbag",
                { Ingredient("goldnugget", 40),
                  Ingredient("pigskin", 20),
                  Ingredient("nightmarefuel", 40),
                  Ingredient("silk", 40),
                  Ingredient("bearger_fur", 2),
                  Ingredient("dragon_scales", 2),
                  Ingredient("goose_feather", 10),
                  Ingredient("minotaurhorn", 1) },
                tec,
                { atlas = "images/inventoryimages/nicebigbag.xml", image = "nicebigbag.tex" },
                { "CONTAINERS" })

        local catbigbag = AddRecipe2("catbigbag", -- name
                { Ingredient("goldnugget", 80),
                  Ingredient("pigskin", 40),
                  Ingredient("nightmarefuel", 80),
                  Ingredient("silk", 80),
                  Ingredient("bearger_fur", 10),
                  Ingredient("dragon_scales", 10),
                  Ingredient("goose_feather", 20),
                  Ingredient("minotaurhorn", 2) },
                tec,
                { atlas = "images/inventoryimages/catback.xml", image = "catback.tex" },
                { "CONTAINERS" })

        local catback = AddRecipe2("catback", -- name
                { Ingredient("goldnugget", 20),
                  Ingredient("pigskin", 10),
                  Ingredient("nightmarefuel", 20),
                  Ingredient("silk", 20),
                  Ingredient("bearger_fur", 2),
                  Ingredient("dragon_scales", 2),
                  Ingredient("goose_feather", 3),
                  Ingredient("minotaurhorn", 1) },
                tec,
                { atlas = "images/inventoryimages/catback.xml", image = "catback.tex" },
                { "CONTAINERS" })
    end
end

--------------------------------------------------------------------------------------------------------------------------
modimport("scripts/strings_bigbag.lua")
modimport("scripts/bigbag_rpc.lua")
modimport("scripts/bigbag_hook.lua")
modimport("scripts/bigbag_ui.lua")--UI、容器等

require("bigbag_debugcommands")--调试用指令


AddPrefabPostInit("redbigbag", function(inst)

    if not inst.components.insulator then
        inst:AddComponent("insulator")
        inst.components.insulator:SetWinter()
        inst.components.insulator:SetInsulation(500)
    end
end)
AddPrefabPostInit("bluebigbag", function(inst)
    if not inst.components.insulator then
        inst:AddComponent("insulator")
        inst.components.insulator:SetSummer()
        inst.components.insulator:SetInsulation(500)
    end
end)

--------------------------------------------------------------------------------------------------------------------------
--[[如果想在风滚草中添加你想加的资源，可在mod中加入下面代码
TUNING.TUMBLEWEED_RESOURCES_EXPAND=TUNING.TUMBLEWEED_RESOURCES_EXPAND or {}
TUNING.TUMBLEWEED_RESOURCES_EXPAND.xxx_resources={--xxx_resources由你自己命名，尽量不要和别人的重复，可加多条不同类型资源
	resourcesList={
		--资源列表，可加多条，每条之间用英文逗号隔开
		{chance=1,--权重(必填)
		item="xxx",--掉落物(选填，item和pickfn最好至少填一个)
		aggro=true,--是否仇视玩家(选填，一般是生成生物的时候用)
		announce=true,--开出道具是否发公告(选填，默认false)
		season=1,--是否属于季节性掉落(选填，填了后在相应的季节会有概率加成，春1夏2秋4冬8，可填季节数字之和表示多个季节，比如：春夏=3,夏秋=6,春夏秋冬=15)
		specialtag="featherhat",--装备特殊加成(选填，填装备名或者该装备拥有的某一个标签，填了后玩家穿戴相应的装备开这个道具会有概率加成)
		pickfn=function(inst,picker) print("123") end--开到后触发的函数(选填，请务必保证函数能正常执行，优先级大于item，有了pickfn就不会生成item了)
		},
		{chance=1,item="xxx2"}
	},
	multiple=1,--倍率(选填，不填默认为1)
	weightClass="goodMin",--权重等级(选填，填了后掉率会随玩家幸运值变化,不填掉率不会随幸运值浮动)
	--权重等级说明，good代表有益资源，幸运度越高掉率越高；bad代表有害资源(比如怪物)，幸运度越低掉率越高
	--goodMin:普通有益资源，掉率浮动较小
	--goodMid:高级有益资源，掉率浮动适中
	--goodMax:稀有有益资源，掉率浮动较大
	--badMin:普通有害资源，掉率浮动较小
	--badMid:高级有害资源，掉率浮动适中
	--badMax:稀有有害资源，掉率浮动较大
}
]]--
local tumbleweed_item_rates_l = GetModConfigData("tumbleweed_item_rates")
if GetModConfigData("interesting_tumbleweed_switch") and type(tumbleweed_item_rates_l) == "number" and tumbleweed_item_rates_l > 0 and TUNING.INTERESTING_TUMBLEWEED_ENABLE then
    TUNING.TUMBLEWEED_RESOURCES_EXPAND = TUNING.TUMBLEWEED_RESOURCES_EXPAND or {}
    TUNING.TUMBLEWEED_RESOURCES_EXPAND.catback_resources = {--xxx_resources由你自己命名，尽量不要和别人的重复，可加多条不同类型资源
        resourcesList = {
            --资源列表，可加多条，每条之间用英文逗号隔开
            { chance = tumbleweed_item_rates_l * 0.2, --权重(必填)
              item = "catback", --掉落物(选填，item和pickfn最好至少填一个)
              aggro = false, --是否仇视玩家(选填，一般是生成生物的时候用)
              announce = true, --开出道具是否发公告(选填，默认false)
              season = 15, --是否属于季节性掉落(选填，填了后在相应的季节会有概率加成，春1夏2秋4冬8，可填季节数字之和表示多个季节，比如：春夏=3,夏秋=6,春夏秋冬=15)
                --specialtag="featherhat",--装备特殊加成(选填，填装备名或者该装备拥有的某一个标签，填了后玩家穿戴相应的装备开这个道具会有概率加成)
                --pickfn=function(inst,picker) end--开到后触发的函数(选填，请务必保证函数能正常执行，优先级大于item，有了pickfn就不会生成item了)
            },
            { chance = 1, item = "cutgrass" }
        },
        multiple = 1, --倍率(选填，不填默认为1)
        weightClass = "goodMax", --权重等级(选填，填了后掉率会随玩家幸运值变化,不填掉率不会随幸运值浮动)
    }
end
