name = "Collection And Patches[合集和补丁]"
description = [[
请勿订阅
]]
---- 本mod是众多mod贡献者的合集和修正,仅用于自用,请勿订阅,感谢mod贡献者的辛勤付出
----------------------------------------------------------------------
--修改自以下mod:
--1.黑色法杖（手动清理神器）2.小穹补丁(zymod) 3.全图定位 4.影藏管理员标志
--5.蘑菇农场增强 6.简单血量条 7.ShowMe 8.死亡不掉落 9.五格装备栏 10.二本垃圾箱
--11.掉落自动堆叠 12.最大堆叠个数限制 13.更多堆叠 14.帐篷耐久 15.木棚耐久
--16.木牌传送 17.死亡复活按钮 18.死亡复活指令 19.冰箱反鲜 20.快速工作 21.陷阱增强
--22.霓庭灯 23.兔子喷泉 24.智能小木牌 25.小房子种植 26.让每个人都可以使用烹饪锅
--27.额外装备栏plus+ 28.秘玥 29.消失咒 30.浅的工具包 31.反作弊mod
--32.删除默认人物RemoveDefaultCharacter 33.萝卜冰箱 34.large boats
--35.发光的瓶子 36.大背包新 37.禁用自定义人物 38.容器不掉路 39.箱子物品自动排序
--40.UI拖拽缩放 41.Heap of Foods 全汉化 42.访客掉落优化版 43.纯净辅助
--集合mod：
--1.常用mod集合
--2.萌新合集-服务端
----------------------------------------------------------------------

author = "EL"
version = "7.6.0.0"

folder_name = folder_name or "Collection And Patches[合集和补丁]"
if not folder_name:find("workshop-") then
    name = name .. "[dev]" .. "-" .. version
else
    name = name .. "-" .. version
end

icon = "modicon.tex"
icon_atlas = "modicon.xml"

-- 优先级
priority = -1e99
dont_starve_compatible = true
reign_of_giants_compatible = true
shipwrecked_compatible = false
-- 是否支持联机版本
dst_compatible = true
-- 所有客户都需要
all_clients_require_mod = true
-- 仅限客户端
client_only_mod = false
api_version = 10

-- 通用mod配置的方法
local function AddOption(name, label, hover, default_setting)
    if default_setting == true then
        return
        {
            name = name or "",
            label = label or "",
            hover = hover or "",
            options = {
                { description = "关闭(OFF)", data = false },
                { description = "开启(ON)", data = true, hover = "默认(DEFAULT)" },
            },
            default = true
        }
    else
        return
        {
            name = name or "",
            label = label or "",
            hover = hover or "",
            options = {
                { description = "关闭(OFF)", data = false, hover = "默认(DEFAULT)" },
                { description = "开启(ON)", data = true },
            },
            default = false
        }
    end
end
-- mod标头信息的方法
local function AddOptionHeader(header)
    return
    {
        name = "",
        label = header,
        options = {
            { description = "", data = 0 },
        },
        default = 0,
    }
end

local function AddConfigOption(name, label, hover, options, default)
    local config = {
        name = name or "",
        label = label or "",
        hover = hover or "",
        options = options or { { description = "", data = 0 } },
        default = default == nil and 0 or default
    }
    return config
end

local color_options = {
    { description = "Auto", data = -1, },
    { description = "0%", data = 0, },
    { description = "10%", data = 0.1, },
    { description = "20%", data = 0.2, },
    { description = "30%", data = 0.3, },
    { description = "40%", data = 0.4, },
    { description = "50%", data = 0.5, },
    { description = "60%", data = 0.6, },
    { description = "70%", data = 0.7, },
    { description = "80%", data = 0.8, },
    { description = "90%", data = 0.9, },
    { description = "100%", data = 1, },
}

local disappear_magic = {
    { description = "永久消失不见", data = -1, hover = "整个存档全程消失不见" },
    { description = "不限制", data = 0, hover = "不消失" },
    { description = "前20天消失不见", data = 20, hover = "20天后可以出现在世界上" },
    { description = "前30天消失不见", data = 30, hover = "30天后可以出现在世界上" },
    { description = "前50天消失不见", data = 50, hover = "50天后可以出现在世界上" },
    { description = "前100天消失不见", data = 100, hover = "100天后可以出现在世界上" },
    { description = "前200天消失不见", data = 200, hover = "200天后可以出现在世界上" },
    { description = "前300天消失不见", data = 300, hover = "300天后可以出现在世界上" },
    { description = "前500天消失不见", data = 500, hover = "500天后可以出现在世界上" },
    { description = "前1000天消失不见", data = 1000, hover = "1000天后可以出现在世界上" },
    { description = "前2000天消失不见", data = 2000, hover = "2000天后可以出现在世界上" },
    { description = "前3000天消失不见", data = 3000, hover = "3000天后可以出现在世界上" },
    { description = "前5000天消失不见", data = 5000, hover = "5000天后可以出现在世界上" },
    { description = "前10000天消失不见", data = 10000, hover = "10000天后可以出现在世界上" },
    { description = "前20000天消失不见", data = 20000, hover = "20000天后可以出现在世界上" },
    { description = "前30000天消失不见", data = 30000, hover = "30000天后可以出现在世界上" },
    { description = "前50000天消失不见", data = 50000, hover = "50000天后可以出现在世界上" },
}

local optionsYesNo = {
    { description = "是/Yes", data = true },
    { description = "否/No", data = false },
}

local optionsEnableDisable = {
    { description = "禁用/disable", data = true },
    { description = "不禁用/enable", data = false },
}
local KEY_F1 = 282
local KEY_F2 = 283
local KEY_F3 = 284
local KEY_F4 = 285
local KEY_F5 = 286
local KEY_F6 = 287
local KEY_F7 = 288
local KEY_F8 = 289
local KEY_F9 = 290
local KEY_F10 = 291
local KEY_F11 = 292
local KEY_F12 = 293

local MOUSEBUTTON_LEFT = 1000
local MOUSEBUTTON_RIGHT = 1001
local MOUSEBUTTON_MIDDLE = 1002
local MOUSEBUTTON_SCROLLUP = 1003
local MOUSEBUTTON_SCROLLDOWN = 1004
local MOUSEBUTTON_Button4 = 1005
local MOUSEBUTTON_Button5 = 1006

local INPUTS = {
    -- Mouse controls
    [1000] = "\238\132\128", --"Left Mouse Button",
    [1001] = "\238\132\129", --"Right Mouse Button",
    [1002] = "\238\132\130", --"Middle Mouse Button",
    [1003] = "\238\132\133", --"Mouse Scroll Up",
    [1004] = "\238\132\134", --"Mouse Scroll Down",
    [1005] = "\238\132\131", --"Mouse Button 4",
    [1006] = "\238\132\132" --"Mouse Button 5",
}

local MOD_name, author_name, description_text, Enable, Disable
local Cookpots_label, Cookpots_hover, Other_item_label, Other_item_hover, Professionalchef_label, Professionalchef_hover
local CookingSpeed_label, CookingSpeed_hove, SpeedNormal, SpeedFast, SpeedFaster, SpeedFastest, AutoCook_label, AutoCook_hover
local Light_area_label, Light_heal_label, Light_sunshine_label, Light_menacing_label, Light_poison_label, Light_Ember_label, Light_Icy_label

if locale == "zh" or locale == "zhr" then
    ----烹饪锅
    Enable = "启用"
    Disable = "禁用"
    Cookpots_label = "让所有人都可以使用烹饪锅"
    Cookpots_hover = "你可以让所有人都可以很方便制作烹饪锅,并携带它。\n如果你想让只有沃利能使用，那就关掉它。"
    Other_item_label = "更多的物品配方"
    Other_item_hover = "你想要制作研磨器和香料锅?"
    Professionalchef_label = "使用研磨器"
    Professionalchef_hover = "你必须启用它才能使用研磨器！！！"
    CookingSpeed_label = "烹饪速度"
    CookingSpeed_hove = "你可以改变烹饪速度..本来我是不推荐改变它的。"
    SpeedNormal = "正常"
    SpeedFast = "很快"
    SpeedFaster = "极快"
    SpeedFastest = "马上就好"

    AutoCook_label = "自动烹饪"
    AutoCook_hover = "关闭锅时，满足材料条件即可自动烹饪，默认关闭。\n我无法预估到其他意外的情况，所以我并不主动把它设为启用。"

    ----发光的瓶子
    Light_area_label = "发光范围大小 󰀏"
    Light_heal_label = "血量回复 󰀍"
    Light_sunshine_label = "回san效果 󰀓"
    Light_menacing_label = "红色警示 󰀉"
    Light_poison_label = "毒药伤害 󰀘"
    Light_Ember_label = "加热效果 󰀈"
    Light_Icy_label = "冷冻效果 󰀨"


else
    ----烹饪锅
    Enable = "Enable"
    Disable = "Disable"
    Cookpots_label = "PortableCookpot And Cookrepices"
    Cookpots_hover = "You can made More Cookrepices,And use it.By default anyone can make it.\nIf you only want warly to make it, disble setting."
    Other_item_label = "More item Recipe"
    Other_item_hover = "Did you want the Portableblender and portablespicer?"
    Professionalchef_label = "Use the portablespicer"
    Professionalchef_hover = "Yes，Your want to need more！All player can use Portablespicer!!!"
    CookingSpeed_label = "Cooking speed"
    CookingSpeed_hove = "You can change the cooking speed.. I don't recommend changing it."
    SpeedNormal = "Normal"
    SpeedFast = "Fast"
    SpeedFaster = "Faster"
    SpeedFastest = "Instantly Complete"

    AutoCook_label = "Automatic cooking"
    AutoCook_hover = "When you close the pot, when it satisfies the material conditions,It starts cooking automatically,Disble by default.\nI can't predict any other contingencies,So I don't actively set it on."
    ----发光的瓶子
    Light_area_label = "Light Area Size 󰀏"
    Light_heal_label = "Tincture Heal 󰀍"
    Light_sunshine_label = "Sunshine Bottle Efficiency 󰀓"
    Light_menacing_label = "Menacing Bottle Efficiency 󰀉"
    Light_poison_label = "Poison Bottle Damage 󰀘"
    Light_Ember_label = "Ember Bottle Efficiency 󰀈"
    Light_Icy_label = "Icy Bottle Efficiency 󰀨"

    Light_heal_label = "Tincture Heal 󰀍"
    Light_heal_label = "Tincture Heal 󰀍"
    Light_heal_label = "Tincture Heal 󰀍"
end

local options_for_slots_bg = {
    { description = "-20", data = -20 },
    { description = "-19", data = -19 },
    { description = "-18", data = -18 },
    { description = "-17", data = -17 },
    { description = "-16", data = -16 },
    { description = "-15", data = -15 },
    { description = "-14", data = -14 },
    { description = "-13", data = -13 },
    { description = "-12", data = -12 },
    { description = "-10", data = -11 },
    { description = "-10", data = -10 },
    { description = "-9", data = -9 },
    { description = "-8", data = -8 },
    { description = "-7", data = -7 },
    { description = "-6", data = -6 },
    { description = "-5", data = -5 },
    { description = "-4", data = -4 },
    { description = "-3", data = -3 },
    { description = "-2", data = -2 },
    { description = "-1", data = -1 },
    { description = "0", data = 0 },
    { description = "1", data = 1 },
    { description = "2", data = 2 },
    { description = "3", data = 3 },
    { description = "4", data = 4 },
    { description = "5", data = 5 },
    { description = "6", data = 6 },
    { description = "7", data = 7 },
    { description = "8", data = 8 },
    { description = "9", data = 9 },
    { description = "10", data = 10 },
    { description = "11", data = 11 },
    { description = "12", data = 12 },
    { description = "13", data = 13 },
    { description = "14", data = 14 },
    { description = "15", data = 15 },
    { description = "16", data = 16 },
    { description = "17", data = 17 },
    { description = "18", data = 18 },
    { description = "19", data = 19 },
    { description = "20", data = 20 },
}

------------------------------------
---自定义禁用角色 table start
------------------------------------
--自定义配置请修改：
--Please modify the custom configuration：
--这个是放你要添加的角色代码
--This is the role code you want to add
MOD_CHARACTERLIST = {
    "musha", --精灵公主
    "zanpartizanne", --雷法
    "white_bone", --白骨夫人
    "pigsy", --猪八戒
    "yangjian", --杨戬
    "myth_yutu", --玉兔
    "monkey_king", --孙悟空
    "neza", --哪吒
    "yama_commissioners", --黑白无常
    "madameweb", --盘丝娘娘
    "walani", --三合一walani
    "wilbur", --三合一wilbur
    "woodlegs", --三合一woodlegs
    "xuaner", --璇儿
    "sora", --小琼
    "elaina", --魔女之旅-伊蕾娜
    "amnesia", --魔女之旅-amnesia
    "kemomimi", --小狐狸
    "winky", --永不妥协老鼠人
    "wathom", --永不妥协沃托姆
    "wixie", --永不妥协wixie
    "yeyu", --夜雨
    "aria", --艾丽娅
    "abigail_williams", --奇幻降临阿比
    "jaye", --调酒师
    "whitney", --多肉植物-惠特妮
    "yuanzi", --乃木园子
    "wirlywings", --樱花林-樱桃妹
    "tiddlewade", --黑死病-医生
}
--自定义配置请修改：
--Please modify the custom configuration：
--这个是放你要添加的角色名称(无限制，只要你看得懂)
--This is the name of the role you want to add (unlimited, as long as you can understand)
MOD_CHARACTERNAMES = {
    "精灵公主musha", --精灵公主
    "雷法ZanPartizanne", --雷法
    "神话书说-白骨夫人Lady White Bone", --白骨夫人
    "神话书说-猪八戒Pigsy", --猪八戒
    "神话书说-杨戬Yang Jian", --杨戬
    "神话书说-玉兔Yu Tu", --玉兔
    "神话书说-孙悟空Monkey King", --孙悟空
    "神话书说-哪吒Neza", --哪吒
    "黑白无常yama_commissioners", --黑白无常
    "盘丝娘娘madameweb", --盘丝娘娘
    "三合一-瓦拉尼Walani", --三合一walani
    "三合一-威尔伯Wilbur", --三合一wilbur
    "三合一-木腿船长Woodlegs", --三合一woodlegs
    "璇儿XuanEr", --三合一woodlegs
    "小穹Sora", --小穹
    "伊蕾娜elaina", --魔女之旅-伊蕾娜
    "魔女之旅-amnesia", --魔女之旅-amnesia
    "小狐狸kemomimi", --小狐狸
    "永不妥协-老鼠人winky", --永不妥协老鼠人
    "永不妥协-沃托姆wathom", --永不妥协沃托姆
    "永不妥协-wixie", --永不妥协wixie
    "夜雨yeyu", --夜雨
    "艾丽娅aria", --艾丽娅
    "奇幻降临阿比abigail_williams", --奇幻降临阿比
    "调酒师jaye", --调酒师
    "多肉植物-惠特妮whitney", --多肉植物-惠特妮
    "乃木园子yuanzi", --乃木园子
    "樱花林-樱桃妹wirlywings", --樱花林-樱桃妹
    "黑死病-医生tiddlewade", --黑死病-医生
}

DST_CHARACTERLIST = {
    "wilson", --威尔逊
    "willow", --薇洛
    "wolfgang", --大力士
    "wendy", --温蒂
    "wx78", --机器人
    "wickerbottom", --维克巴顿 老奶奶
    "woodie", --伍迪
    "wes", --韦斯 气球小子
    "waxwell", --麦斯威尔
    "wathgrithr", --维格弗德
    "webber", --韦伯 蜘蛛人
    "winona", --薇诺娜 女工
    "warly", --沃利
    --DLC chars: 要联网才能选的人物
    "wortox", --沃括克斯 恶魔人
    "wormwood", --树人
    "wurt", --鱼人
    "walter", --少先队
    "wanda", --旺达
}
DST_CHARACTERNAMES = {
    "威尔逊wilson", --威尔逊
    "薇洛willow", --薇洛
    "大力士wolfgang", --大力士
    "温蒂wendy", --温蒂
    "机器人wx78", --机器人
    "老奶奶wickerbottom", --维克巴顿 老奶奶
    "伍迪woodie", --伍迪
    "韦斯wes", --韦斯 气球小子
    "麦斯威尔waxwell", --麦斯威尔
    "维格弗德wathgrithr", --维格弗德
    "韦伯webber", --韦伯 蜘蛛人
    "薇诺娜winona", --薇诺娜 女工
    "沃利warly", --沃利
    --DLC chars: 要联网才能选的人物
    "沃括克斯wortox", --沃括克斯 恶魔人
    "树人wormwood", --树人
    "鱼人wurt", --鱼人
    "少先队walter", --少先队
    "旺达wanda", --旺达
}

------------------------------------
---自定义禁用角色 table end
------------------------------------


local choice_visitortime = {}
for i = 1, 14 do
    choice_visitortime[i] = { description = i * 5, data = i * 5 }
end

local choice_lighttime = {}
for i = 1, 15 do
    choice_lighttime[i] = { description = i * 2, data = i * 2 }
end

configuration_options = {
    AddOptionHeader(""),
    {
        --TheNet:SetDefaultMaxPlayers(16)
        name = "max_player_num",
        label = "服务器人数上限",
        hover = "设置服务器的最大人数",
        options = {
            { description = "不在这里设置", data = 0 },
            { description = "1", data = 1 },
            { description = "2", data = 2 },
            { description = "3", data = 3 },
            { description = "4", data = 4 },
            { description = "5", data = 5 },
            { description = "6", data = 6 },
            { description = "7", data = 7 },
            { description = "8", data = 8 },
            { description = "9", data = 9 },
            { description = "10", data = 10 },
            { description = "11", data = 11 },
            { description = "12", data = 12 },
            { description = "13", data = 13 },
            { description = "14", data = 14 },
            { description = "15", data = 15 },
            { description = "16", data = 16 },
            { description = "17", data = 17 },
            { description = "18", data = 18 },
            { description = "19", data = 19 },
            { description = "20", data = 20 },
            { description = "21", data = 21 },
            { description = "22", data = 22 },
            { description = "23", data = 23 },
            { description = "24", data = 24 },
            { description = "25", data = 25 },
            { description = "26", data = 26 },
            { description = "27", data = 27 },
            { description = "28", data = 28 },
            { description = "29", data = 29 },
            { description = "30", data = 30 },
            { description = "31", data = 31 },
            { description = "32", data = 32 },
            { description = "36", data = 36 },
            { description = "42", data = 42 },
            { description = "48", data = 48 },
            { description = "64", data = 64 },
            { description = "72", data = 72 },
            { description = "128", data = 128, hover = "你是认真的么..." },
            { description = "256", data = 256, hover = "你是认真的么..." },
            { description = "512", data = 512, hover = "你是认真的么..." },
            { description = "1024", data = 1024, hover = "你是认真的么..." },
        },
        default = 0
    },
    AddOption("clean_garbage", "二本垃圾箱", "对二本科技右键会有4个小格子，将不想用的物品放入点击清理可直接删除", true),
    {
        name = "auto_stack_range",
        label = "掉落自动堆叠",
        hover = "设置掉落物自动堆叠的范围，设为0关闭自动堆叠",
        options = {
            { description = "关闭", data = 0 },
            { description = "10", data = 10 },
            { description = "20", data = 20 },
            { description = "30", data = 30, hover = "默认" },
            { description = "40", data = 40 },
            { description = "50", data = 50 },
            { description = "60", data = 60 },
            { description = "70", data = 70 },
            { description = "80", data = 80 },
            { description = "90", data = 90 },
            { description = "100", data = 100 },
        },
        default = 30,
    },
    {
        name = "stack_size",
        label = "物品堆叠数量",
        hover = "设置物品堆叠数量",
        options = {
            { description = "关闭", data = 0 },
            { description = "40", data = 40 },
            { description = "63", data = 63, hover = "最佳堆叠上限" },
            { description = "99", data = 99, hover = "默认，两位数堆叠上限" },
            { description = "128", data = 128 },
            { description = "255", data = 200 },
            { description = "255", data = 255 },
            { description = "255", data = 300 },
            { description = "255", data = 400 },
            { description = "500", data = 500 },
            { description = "666", data = 666 },
            { description = "888", data = 888 },
            { description = "999", data = 999 },
        },
        default = 40
    },
    AddOption("stack_more", "更多可堆叠", "使鸟、兔子、地鼠、鱼等生物变得可堆叠", true),
    {
        name = "tent_uses",
        label = "帐篷耐久",
        hover = "改帐篷耐久",
        options = {
            { description = "关闭", data = 15 },
            { description = "10", data = 10 },
            { description = "20", data = 10 },
            { description = "30", data = 10 },
            { description = "40", data = 10 },
            { description = "50", data = 50 },
            { description = "100", data = 100 },
            { description = "200", data = 200 },
            { description = "500", data = 500, hover = "默认" },
            { description = "9999", data = 9999 },
        },
        default = 500
    },
    {
        name = "siesta_canopy_uses",
        label = "木棚耐久",
        hover = "改木棚耐久",
        options = {
            { description = "关闭", data = 16 },
            { description = "10", data = 10 },
            { description = "20", data = 20 },
            { description = "30", data = 30 },
            { description = "40", data = 40 },
            { description = "50", data = 50 },
            { description = "100", data = 100 },
            { description = "200", data = 200 },
            { description = "500", data = 500, hover = "默认" },
            { description = "9999", data = 9999 },
        },
        default = 500
    },
    AddOptionHeader("死亡不掉落配置"),
    AddOption("dont_drop", "是否开启死亡掉落", "死亡不掉落物品总开关", false),
    {
        name = "rendiao",
        label = "本体掉落最大数量",
        hover = "角色物品栏最大的掉落数量",
        options = {
            { description = "不掉落", data = 0, hover = "" },
            { description = "1", data = 1, hover = "" },
            { description = "2", data = 2, hover = "" },
            { description = "3", data = 3, hover = "" },
            { description = "4", data = 4, hover = "" },
            { description = "5", data = 5, hover = "" },
            { description = "6", data = 6, hover = "" },
            { description = "7", data = 7, hover = "" },
            { description = "8", data = 8, hover = "" },
            { description = "9", data = 9, hover = "" }
        },
        default = 0,
    },
    {
        name = "baodiao",
        label = "背包掉落",
        hover = "背包掉落的最大数量",
        options = {
            { description = "不掉落", data = 0, hover = "" },
            { description = "1", data = 1, hover = "" },
            { description = "2", data = 2, hover = "" },
            { description = "3", data = 3, hover = "" },
            { description = "4", data = 4, hover = "" },
            { description = "5", data = 5, hover = "" },
            { description = "6", data = 6, hover = "" },
            { description = "7", data = 7, hover = "" },
            { description = "8", data = 8, hover = "" },
            { description = "9", data = 9, hover = "" }
        },
        default = 0,
    },
    {
        name = "zbdiao",
        label = "装备掉落",
        hover = "死亡掉落装备 \n 防止一些未知bug.",
        options = {
            { description = "On", data = true, hover = "" },
            { description = "Off", data = false, hover = "" }
        },
        default = false,
    },
    {
        name = "amudiao",
        label = "生命护符掉落",
        hover = "死亡掉落生命护符",
        options = {
            { description = "On", data = true, hover = "" },
            { description = "Off", data = false, hover = "" }
        },
        default = true,
    },
    {
        name = "nillots",
        label = "置空一个物品栏",
        hover = "死亡置空一个物品栏，用于给心脏",
        options = {
            { description = "On", data = 0, hover = "" },
            { description = "Off", data = 1, hover = "" }
        },
        default = 0,
    },
    AddOption("drown_drop", "落水掉落", "落水掉落东西", true),
    AddOptionHeader("五格装备栏设置"),
    AddOption("extra_equip_slots", "五格装备栏", "五格装备栏总开关", true),
    -- {
    --     name = "render_strategy",
    --     label = "渲染策略(Render Strategy)",
    --     hover = "同时装备护符和身体部位装备时，您希望渲染哪一个贴图？(When equip both amulet and body equipment, which do you want to render?)",
    --     options = {
    --         { description = "默认(default)", data = "none", hover = "渲染最后装备的那个(Render the last equipment)" },
    --         { description = "护符(amulet)", data = "neck", hover = "渲染护符贴图(Render amulet)" },
    --         { description = "身体(body)", data = "body", hover = "渲染身体部位装备贴图(Render body equipment)" },
    --     },
    --     default = "none",
    -- },
    {
        name = "slots_num",
        label = "额外物品栏格子(Extra Item Slots)",
        hover = "您想要多少额外的物品栏格子？(How many extra item slots do you want?)",
        options = {
            { description = "-10", data = -10 },
            { description = "-5", data = -5 },
            { description = "-4", data = -4 },
            { description = "-3", data = -3 },
            { description = "-2", data = -2 },
            { description = "-1", data = -1 },
            { description = "默认(default)", data = 0 },
            { description = "+1", data = 1 },
            { description = "+2", data = 2 },
            { description = "+3", data = 3 },
            { description = "+4", data = 4 },
            { description = "+5", data = 5 },
            { description = "+10", data = 10 },
            { description = "+15", data = 15, hover = "可能会导致UI溢出(Maybe cause UI overflow)" },
            { description = "+20", data = 20, hover = "可能会导致UI溢出(Maybe cause UI overflow)" },
        },
        default = 0,
    },
    {
        name = "backpack_slot",
        label = "额外背包格子(Extra Backpack Slot)",
        hover = "你想要一个额外的背包格子吗？(Do you want an extra backpack slot?)",
        options = {
            { description = "否(no)", data = false },
            { description = "是(yes)", data = true },
        },
        default = true,
    },
    {
        name = "amulet_slot",
        label = "额外护符格子(Extra Amulet Slot)",
        hover = "你想要一个额外的护符格子吗？(Do you want an extra amulet slot?)",
        options = {
            { description = "否(no)", data = false },
            { description = "是(yes)", data = true },
        },
        default = true,
    },
    {
        name = "compass_slot",
        label = "额外指南针格子(Extra Compass Slot)",
        hover = "你想要一个额外的指南针格子吗？(Do you want an extra compass slot?)",
        options = {
            { description = "否(no)", data = false },
            { description = "是(yes)", data = true },
        },
        default = false,
    },
    {
        name = "drop_hand_item_when_heavy",
        label = "负重时卸下手部装备(Drop Handitem)",
        hover = "背起重物时，是否让你的手部装备被卸下？(Remove handitem when you carry heavy?)",
        options = {
            { description = "否(no)", data = false },
            { description = "是(yes)", data = true },
        },
        default = true,
    },
    {
        name = "show_compass",
        label = "显示指南针(Show Compass)",
        hover = "装备指南针时是否显示贴图(Show compass when equipped?)",
        options = {
            { description = "否(no)", data = false },
            { description = "是(yes)", data = true },
        },
        default = true,
    },
    {
        name = "chesspiece_fix",
        label = "搬雕像渲染修复(Chesspiece Fix)",
        hover = "修复可能出现的渲染错误(Fix some render problems)",
        options = {
            { description = "否(no)", data = false },
            { description = "是(yes)", data = true },
        },
        default = true,
    },
    --[[{
        name = "drop_bp_if_heavy",
        label = "搬运重物时使用的格子",
        hover = "搬运重物时，您想使用哪个格子？",
        options =
        {
            {description = "背包格子", data = true},
            {description = "身体格子", data = false},
        },
        default = false,
    },]]--

    --slots_bg_length_adapter
    {
        name = "slots_bg_length_adapter",
        label = "物品栏背景长度调整",
        hover = "每大一点就会长一点点，每小一点就会短一点点",
        options = options_for_slots_bg,
        default = 0,
    },
    {
        name = "slots_bg_length_adapter_no_bg",
        label = "去除物品栏背景",
        hover = "去除物品栏背景",
        options = {
            { description = "去除", data = true },
            { description = "不去除", data = false },
        },
        default = false,
    },

    AddOptionHeader("木牌传送设置"),
    AddOption("fast_travel", "木牌传送-总开关", "设置是否开启木牌传送", true),
    {
        name = "set_wait_second",
        label = "设置等待时长",
        hover = "修改传送时等待的时长（秒）",
        options = {
            { description = "直接传送", data = 0 },
            { description = "1秒", data = 1 },
            { description = "3秒", data = 3 },
            { description = "5秒", data = 5, hover = "默认" },
        },
        default = 0
    },
    {
        name = "Hunger_Cost",
        label = "饥饿消耗",
        hover = "修改传送时饥饿消耗倍率",
        options = {
            { description = "无消耗", data = 0 },
            { description = "X0.25", data = 0.25 },
            { description = "X1.0", data = 1 }, { description = "X2.0", data = 2 },
            { description = "X4.0", data = 4 }, { description = "X8.0", data = 8 }
        },
        default = 1
    },
    {
        name = "Sanity_Cost",
        label = "精神消耗",
        hover = "修改传送时精神消耗倍率",
        options = {
            { description = "无消耗", data = 0 },
            { description = "X0.25", data = 0.25 },
            { description = "X1.0", data = 1 }, { description = "X2.0", data = 2 },
            { description = "X4.0", data = 4 }, { description = "X8.0", data = 8 }
        },
        default = 1
    },
    {
        name = "Ownership",
        label = "权限修改",
        hover = "所有权限制?",
        options = {
            { description = "启用", data = true },
            { description = "不可用", data = false }
        },
        default = false
    },
    AddOptionHeader("死亡复活按钮设置"),
    AddOption("death_resurrection_button", "死亡复活按钮-总开关", "设置是否开启死亡复活按钮", true),
    {
        name = "CD",
        label = "设置冷却时间",
        hover = "",
        options = {
            { description = "0分钟", hover = "无CD", data = 0 },
            { description = "1分钟", hover = "游戏中一天为8分钟", data = 60 },
            { description = "2分钟", hover = "游戏中一天为8分钟", data = 120 },
            { description = "4分钟", hover = "游戏中一天为8分钟", data = 240 },
            { description = "8分钟", hover = "游戏中一天为8分钟", data = 480 },
            { description = "12分钟", hover = "游戏中一天为8分钟", data = 720 },
            { description = "2天", hover = "游戏中一天为8分钟", data = 960 },
            { description = "3天", hover = "游戏中一天为8分钟", data = 1440 },
            { description = "4天", hover = "游戏中一天为8分钟", data = 1920 }
        },
        default = 0
    },
    {
        name = "Health_Penalty",
        label = "血量上限惩罚设置",
        hover = "俗称黑血",
        options = {
            { description = "0%", hover = "无惩罚", data = 0 },
            { description = "5%", hover = "5%", data = 0.05 },
            { description = "15%", hover = "15%", data = 0.15 },
            { description = "25%", hover = "25%", data = 0.25 },
            { description = "35%", hover = "35%", data = 0.35 },
            { description = "45%", hover = "45%", data = 0.45 },
            { description = "55%", hover = "55%", data = 0.55 },
            { description = "65%", hover = "65%", data = 0.65 },
            { description = "75%", hover = "75%", data = 0.75 }
        },
        default = 0
    },
    {
        name = "UI",
        label = "按钮位置",
        hover = "",
        options = {
            { description = "中心点", hover = "中心点", data = "center" },
            { description = "中心偏下", hover = "中心偏下", data = "center_offset_down" },
            { description = "正上方", hover = "正上方", data = "right_above" },
            { description = "左上角", hover = "左上角", data = "upper_left" },
            { description = "左下角", hover = "左下角", data = "lower_left" }
        },
        default = "right_above"
    },
    AddOptionHeader("重生设置"),
    AddOption("restart_set", "重生-总开关", "设置是否开启重生功能", true),
    {
        name = "MOD_RESTART_ALLOW_RESTART",
        label = "重生",
        options = {
            { description = "开", data = true },
            { description = "关", data = false },
        },
        default = true,
    },
    {
        name = "MOD_RESTART_ALLOW_RESURRECT",
        label = "复活",
        options = {
            { description = "开", data = true },
            { description = "关", data = false },
        },
        default = true,
    },
    {
        name = "MOD_RESTART_ALLOW_KILL",
        label = "自杀",
        options = {
            { description = "开", data = true },
            { description = "关", data = false },
        },
        default = true,
    },
    {
        name = "MOD_RESTART_CD_RESTART",
        label = "重生冷却(分)",
        hover = "重生的冷却时间.",
        options = {
            { description = "无", data = 0, hover = "无限使用" },
            { description = "1", data = 1, hover = "1 分钟" },
            { description = "2", data = 2, hover = "2 分钟" },
            { description = "4", data = 4, hover = "4 分钟" },
            { description = "8", data = 8, hover = "8 分钟" },
            { description = "12", data = 12, hover = "12 分钟(一天半)" },
            { description = "2天", data = 16, hover = "16 分钟(2天)" },
            { description = "3天", data = 24, hover = "24 分钟(3天)" },
            { description = "4天", data = 32, hover = "32 分钟(4天)" },
        },
        default = 0,
    },
    {
        name = "MOD_RESTART_CD_RESURRECT",
        label = "复活冷却(分)",
        hover = "复活的冷却时间.",
        options = {
            { description = "无", data = 0, hover = "无限使用" },
            { description = "1", data = 1, hover = "1 分钟" },
            { description = "2", data = 2, hover = "2 分钟" },
            { description = "4", data = 4, hover = "4 分钟" },
            { description = "8", data = 8, hover = "8 分钟" },
            { description = "12", data = 12, hover = "12 分钟(一天半)" },
            { description = "2天", data = 16, hover = "16 分钟(2天)" },
            { description = "3天", data = 24, hover = "24 分钟(3天)" },
            { description = "4天", data = 32, hover = "32 分钟(4天)" },
        },
        default = 0,
    },
    {
        name = "MOD_RESTART_CD_KILL",
        label = "自杀冷却(分)",
        hover = "自杀的冷却时间.",
        options = {
            { description = "无", data = 0, hover = "无限使用" },
            { description = "1", data = 1, hover = "1 分钟" },
            { description = "2", data = 2, hover = "2 分钟" },
            { description = "4", data = 4, hover = "4 分钟" },
            { description = "8", data = 8, hover = "8 分钟" },
            { description = "12", data = 12, hover = "12 分钟(一天半)" },
            { description = "2天", data = 16, hover = "16 分钟(2天)" },
            { description = "3天", data = 24, hover = "24 分钟(3天)" },
            { description = "4天", data = 32, hover = "32 分钟(4天)" },
        },
        default = 0,
    },
    {
        name = "MOD_RESTART_CD_BONUS",
        label = "冷却调整",
        hover = "冷却时间随使用次数不断增加.",
        options = {
            { description = "关", data = 0, hover = "固定的冷却时间" },
            { description = "10%", data = 0.1, hover = "每次使用后增加(基础值的)10%" },
            { description = "20%", data = 0.2, hover = "每次使用后增加(基础值的)20%" },
            { description = "30%", data = 0.3, hover = "每次使用后增加(基础值的)30%" },
            { description = "40%", data = 0.4, hover = "每次使用后增加(基础值的)40%" },
            { description = "50%", data = 0.5, hover = "每次使用后增加(基础值的)50%" },
            { description = "100%", data = 1, hover = "每次使用后增加(基础值的)100%" },
            { description = "150%", data = 1.5, hover = "每次使用后增加(基础值的)150%" },
            { description = "200%", data = 2, hover = "每次使用后增加(基础值的)200%" },
        },
        default = 0,
    },
    {
        name = "MOD_RESTART_CD_MAX",
        label = "最大冷却(分)",
        hover = "开启冷却调整后累计可达到的最大冷却时间.",
        options = {
            { description = "无", data = 0, hover = "冷却无上限" },
            { description = "10", data = 10, hover = "10 分钟" },
            { description = "15", data = 15, hover = "15 分钟" },
            { description = "20", data = 20, hover = "20 分钟" },
            { description = "25", data = 25, hover = "25 分钟" },
            { description = "30", data = 30, hover = "30 分钟" },
            { description = "45", data = 45, hover = "45 分钟" },
            { description = "60", data = 60, hover = "60 分钟" },
            { description = "75", data = 75, hover = "75 分钟" },
            { description = "90", data = 90, hover = "90 分钟" },
            { description = "105", data = 105, hover = "105 分钟" },
            { description = "120", data = 120, hover = "120 分钟" },
            { description = "180", data = 180, hover = "180 分钟" },
        },
        default = 0,
    },
    {
        name = "MOD_RESTART_FORCE_DROP_MODE",
        label = "强制掉落道具",
        hover = "重生是否强制掉落道具.",
        options = {
            { description = "默认", data = 0, hover = "默认" },
            { description = "掉落", data = 1, hover = "重生强制掉落道具" },
            { description = "不掉落", data = 2, hover = "重生强制不掉落道具" },
        },
        default = 1,
    },
    {
        name = "MOD_RESTART_MAP_SAVE",
        label = "保留地图",
        hover = "使用重生指令是否保留探索过的地图.",
        options = {
            { description = "开", data = 1, hover = "重生将会记住地图" },
            { description = "关", data = 2, hover = "重生失去所有地图的记忆" },
        },
        default = 1,
    },
    {
        name = "MOD_RESTART_RESURRECT_HEALTH",
        label = "复活血量",
        hover = "使用复活指令后恢复的血量.",
        options = {
            { description = "默认", data = 0, hover = "游戏默认\n(只剩 50 点血量)" },
            { description = "递减", data = 1, hover = "每次复活恢复的血量不断减少\n(最少为 40% 的血量)" },
            { description = "随机", data = 2, hover = "复活随机恢复血量\n(随机血量范围: 10% ~ 100%)" },
            { description = "100%", data = 100, hover = "固定恢复 100% 的血量" },
            { description = "90%", data = 90, hover = "固定恢复 90% 的血量" },
            { description = "80%", data = 80, hover = "固定恢复 80% 的血量" },
            { description = "70%", data = 70, hover = "固定恢复 70% 的血量" },
            { description = "60%", data = 60, hover = "固定恢复 60% 的血量" },
            { description = "50%", data = 50, hover = "固定恢复 50% 的血量" },
        },
        default = 80,
    },
    {
        name = "MOD_RESTART_TRIGGER_MODE",
        label = "触发模式",
        hover = "公聊或者私聊触发指令.",
        options = {
            { description = "公&私聊", data = 1 },
            { description = "仅公聊", data = 2 },
            { description = "仅私聊", data = 3 },
        },
        default = 1,
    },
    AddOptionHeader("智能小木牌"),
    AddOption("smart_minisign_switch", "智能小木牌-总开关", "设置是否开启智能小木牌", true),
    {
        name = "Icebox",
        label = "Icebox/冰箱",
        hover = "Minisign for icebox/允许冰箱添加小木牌",
        options = {
            { description = "No(关闭)", data = false },
            { description = "Yes(打开)", data = true },
        },
        default = false,
    },
    {
        name = "ChangeSkin",
        label = "ChangeSkin/换肤功能",
        hover = "Minisign can change skin/允许小木牌切换皮肤",
        options = {
            { description = "Yes(是)", data = true },
            { description = "No(否)", data = false },
        },
        default = true,
    },
    {
        name = "DragonflyChest",
        label = "DragonflyChest/龙鳞宝箱",
        hover = "Minisign for DragonflyChest/允许龙鳞箱子添加小木牌",
        options = {
            { description = "No(关闭)", data = false },
            { description = "Yes(打开)", data = true },
        },
        default = false,
    },
    {
        name = "SaltBox",
        label = "SaltBox/盐盒",
        hover = "Minisign for SaltBox/允许盐箱添加小木牌",
        options = {
            { description = "No(关闭)", data = false },
            { description = "Yes(打开)", data = true },
        },
        default = false,
    },
    {
        name = "BundleItems",
        label = "BundleItems/包裹物品显示",
        hover = "Show the item in bundle/显示包裹里面的物品",
        options = {
            { description = "No(关闭)", data = false },
            { description = "Yes(打开)", data = true },
        },
        default = false,
    },
    {
        name = "Digornot",
        label = "CanbeDug/小木牌挖除",
        hover = "Can be Dug/是否可以被挖",
        options = {
            { description = "No(关闭)", data = false },
            { description = "Yes(打开)", data = true },
        },
        default = false,
    },
    AddOptionHeader("冰箱返鲜设置"),
    AddOption("better_icebox", "冰箱返鲜-总开关", "设置是否开冰箱返现功能", true),
    {
        name = "icebox_freeze",
        label = "腐烂速度",
        options = {
            { description = "正常腐烂", data = "0.5" },
            { description = "缓慢腐烂", data = "0.3" },
            { description = "保鲜", data = "0" },
            { description = "反鲜", data = "-5" },

        },
        default = "-5",
    },
    {
        name = "krampus_sack_ice",
        label = "小偷包保鲜",
        options = {
            { description = "开启", data = true, hover = "小偷包保鲜,保鲜度同冰箱" },
            { description = "关闭", data = false },
        },
        default = false,
    },
    {
        name = "backpack_ice",
        label = "背包保鲜",
        options = {
            { description = "开启", data = true, hover = "背包包保鲜,保鲜度同冰箱" },
            { description = "关闭", data = false },
        },
        default = false,
    },
    {
        name = "piggyback_ice",
        label = "小猪包保鲜",
        options = {
            { description = "开启", data = true, hover = "小猪包保鲜,保鲜度同冰箱" },
            { description = "关闭", data = false },
        },
        default = false,
    },
    {
        name = "saltlicker",
        label = "盐盒",
        options = {
            { description = "正常腐烂", data = 0.25 },
            { description = "保鲜", data = 0 },
            { description = "反鲜", data = -5 },
        },
        default = 0.25
    },
    {
        name = "mushroom_frige",
        label = "蘑菇灯保鲜",
        options = {
            { description = "正常腐烂", data = 0.25 },
            { description = "保鲜", data = 0 }
        },
        default = 0
    },
    {
        name = "cage_frige",
        label = "骨灰盒保鲜",
        options = {
            { description = "开启", data = true, hover = "骨灰盒保鲜,保鲜度同冰箱" },
            { description = "关闭", data = false },
        },
        default = false
    },
    AddOptionHeader("快速工作设置"),
    AddOption("quick_work", "快速工作-总开关", "设置是否开启快速工作功能", true),
    AddOption("Pick", "采集类", "采集、捡起、收获", true),
    AddOption("BuildRepair", "建造修复类", "建造、装饰、绘画、修复、缝补、灭火", true),
    AddOption("HSHU", "三围升级类", "食用、治疗、学习、升级", true),
    AddOption("Animal", "动物类", "抚摸、喂食、杀害、刷毛、刮毛", true),
    AddOption("Others", "其他动作", "其他动作加快", true),
    AddOption("QuickDry", "晾肉秒干", "肉一挂上晾肉架就风干", false),
    {
        name = "CookTime",
        label = "烹饪时间",
        hover = "按照你设定的时间煮好食物",
        options = {
            { description = "立刻完成", data = 0 },
            { description = "只开启快速烤制", data = 998, hover = "默认" },
            { description = "15 秒", data = 15 },
            { description = "30 秒", data = 30 },
            { description = "关闭", data = 999 },
        },
        default = 998,
    },
    {
        name = "FishTime",
        label = "钓鱼时间",
        hover = "钓鱼时鱼按你设置的时间上钩",
        options = {
            { description = "立刻上钩", data = 0, hover = "默认" },
            { description = "5 秒", data = 5 },
            { description = "关闭", data = 999 },
        },
        default = 0,
    },
    {
        name = "QuickGrow",
        label = "作物秒熟",
        hover = "农场种植种子成熟时间调整",
        options = {
            { description = "开启", data = 0 },
            { description = "只开启冬天正常生长", data = 1 },
            { description = "关闭", data = 999, hover = "默认" },
        },
        default = 999,
    },
    {
        name = "ChopTime",
        label = "砍伐次数",
        hover = "设置砍倒树木的次数",
        options = {
            { description = "1 次", data = 1, hover = "默认" },
            { description = "4 次", data = 4 },
            { description = "关闭", data = 999 },
        },
        default = 1,
    },
    {
        name = "MineTime",
        label = "开采次数",
        hover = "设置敲开矿物岩石的次数",
        options = {
            { description = "1 次", data = 1 },
            { description = "4 次", data = 4 },
            { description = "关闭", data = 999, hover = "默认" },
        },
        default = 999,
    },
    AddOptionHeader("陷阱增强"),
    AddOption("trap_enhance", "陷阱增强-总开关", "设置是否开启陷阱增强功能", false),
    AddOption("stack", "狗牙陷阱可堆叠", "狗牙陷阱可堆叠", true),
    {
        name = "trap_uses",
        label = "狗牙陷阱耐久修改",
        options = {
            { description = "无修改(默认10次)", data = 0, hover = "默认" },
            { description = "2倍", data = 16 },
            { description = "8倍", data = 64 },
            { description = "32倍", data = 256 },
            { description = "无限", data = 9999999 },
        },
        default = 0,
    },
    {
        name = "trap_teeth_damage",
        label = "狗牙陷阱伤害修改",
        hover = "尽量不要修改哦，小心丧失游戏乐趣~",
        options = {
            { description = "无修改(默认60)", data = 0, hover = "默认" },
            { description = "2倍(120)", data = 120 },
            { description = "4倍(240)", data = 240 },
            { description = "8倍(480)", data = 480 },
            { description = "999", data = 999 },
        },
        default = 0,
    },
    {
        name = "radius",
        label = "狗牙陷阱攻击范围",
        options = {
            { description = "无变化", data = 1 },
            { description = "2倍", data = 2 },
            { description = "3倍", data = 3 },
            { description = "4倍", data = 4 },
            { description = "8倍", data = 8 },
        },
        default = 1,
    },
    {
        name = "reset",
        label = "狗牙陷阱自动重置",
        options = {
            { description = "是", data = 1 },
            { description = "否", data = 0 },
        },
        default = 1,
    },
    {
        name = "time",
        label = "狗牙陷阱自动重置时间",
        options = {
            { description = "0.2秒", data = 0.2 },
            { description = "0.5秒", data = 0.5 },
            { description = "1秒", data = 1 },
            { description = "2秒", data = 2 },
            { description = "3秒", data = 3 },
            { description = "4秒", data = 4 },
        },
        default = 2,
    },
    AddOptionHeader(" "),
    AddOption("stack_j", "荆棘陷阱可堆叠", "荆棘陷阱可堆叠", true),
    {
        name = "trap_uses_j",
        label = "荆棘陷阱耐久修改",
        options = {
            { description = "无修改(默认10次)", data = 0, hover = "默认" },
            { description = "2倍", data = 16 },
            { description = "8倍", data = 64 },
            { description = "32倍", data = 256 },
            { description = "无限", data = 9999999 },
        },
        default = 0,
    },
    {
        name = "trap_bramble_damage",
        label = "荆棘陷阱伤害修改",
        hover = "尽量不要修改哦，小心丧失游戏乐趣~",
        options = {
            { description = "无修改(默认40)", data = 0, hover = "默认" },
            { description = "2倍(80)", data = 80 },
            { description = "4倍(160)", data = 160 },
            { description = "8倍(320)", data = 320 },
            { description = "999", data = 999 },
        },
        default = 0,
    },
    {
        name = "radius_j",
        label = "荆棘陷阱攻击范围",
        options = {
            { description = "无变化", data = 1 },
            { description = "2倍", data = 2 },
            { description = "3倍", data = 3 },
            { description = "4倍", data = 4 },
            { description = "8倍", data = 8 },
        },
        default = 1,
    },
    {
        name = "reset_j",
        label = "荆棘陷阱自动重置",
        options = {
            { description = "是", data = 1 },
            { description = "否", data = 0 },
        },
        default = 1,
    },
    {
        name = "time_j",
        label = "荆棘陷阱自动重置时间",
        options = {
            { description = "0.2秒", data = 0.2 },
            { description = "0.5秒", data = 0.5 },
            { description = "1秒", data = 1 },
            { description = "2秒", data = 2 },
            { description = "3秒", data = 3 },
            { description = "4秒", data = 4 },
        },
        default = 2,
    },
    AddOptionHeader(" "),
    AddOption("attack_player_h", "海星陷阱不攻击玩家", "设置海信陷阱是否攻击玩家", false),
    {
        name = "trap_starfish_damage",
        label = "海星陷阱伤害修改",
        hover = "尽量不要修改哦，小心丧失游戏乐趣~",
        options = {
            { description = "无修改(默认60)", data = 0, hover = "默认" },
            { description = "2倍(120)", data = 120 },
            { description = "4倍(240)", data = 240 },
            { description = "8倍(480)", data = 480 },
            { description = "999", data = 999 },
        },
        default = 0,
    },
    {
        name = "radius_h",
        label = "海星陷阱攻击范围",
        options = {
            { description = "无变化", data = 0 },
            { description = "2倍", data = 2.8 },
            { description = "3倍", data = 4.2 },
            { description = "4倍", data = 5.6 },
            { description = "8倍", data = 11.2 },
        },
        default = 0,
    },
    {
        name = "reset_h",
        label = "海星陷阱重置时间",
        options = {
            { description = "无变化", data = 0 },
            { description = "0.2秒", data = 0.2 },
            { description = "0.5秒", data = 0.5 },
            { description = "1秒", data = 1 },
            { description = "2秒", data = 2 },
            { description = "3秒", data = 3 },
            { description = "5秒", data = 4 },
        },
        default = 0,
    },
    AddOptionHeader("Show me"),
    AddOption("show_me_switch", "show me-开关", "是否开启show me", true),
    --[[{
		name = "message_style",
		label = "Style",
		options =
		{
			{description = "Isolation ->", data = 1},
			{description = "isolation ->", data = 2},
			{description = "Isol ->", data = 3},
			{description = "isol ->", data = 4},
			{description = "<- Warm", data = 5},
			{description = "<- warm", data = 6},
		},
		default = 1,
	},--]]
    {
        name = "food_style",
        label = "Food Style(食物信息显示风格)",
        options = {
            { description = "undefined", data = 0, hover = "Default is \"long\"" },
            { description = "long", data = 1, hover = "Hunger: +12.5 / Sanity: -10 / Health: +3" },
            { description = "short", data = 2, hover = "+12.5 / -10 / +3" },
        },
        default = 0,
    },
    {
        name = "food_order",
        label = "Food Properties Order(食物属性显示顺序)",
        options = {
            { description = "Indefined", data = 0, hover = "Default if \"interface\"" },
            { description = "Interface", data = 1, hover = "Hunger / Sanity / Health" },
            { description = "Wikia", data = 2, hover = "Health / Hunger / Sanity" },
        },
        default = 0,
    },
    {
        name = "food_estimation",
        label = "Estimate Stale Status(过期时间)",
        hover = "Should we estimate the stale status?(要不要估算过期时间)",
        options = {
            { description = "Undefined", data = -1, hover = "Yes, and users may override this option." },
            { description = "No", data = 0, hover = "No, but users may override this option." },
            { description = "Yes", data = 1, hover = "Yes, but users may override this option." },
        },
        default = -1,
    },
    {
        name = "show_food_units",
        label = "Show Food Units(显示食物的食物属性单位)",
        hover = "For example, units of meat, units of veggie etc.\n(例如肉度，菜度)",
        options = {
            { description = "Undefined", data = -1, hover = "Yes, and users may override this option." },
            { description = "No", data = 0, hover = "No, but users may override this option." },
            { description = "Yes", data = 1, hover = "Yes, but users may override this option." },
            { description = "Forbidden", data = 2, hover = "Server won't send food info to clients and their settings will not matter." },
        },
        default = -1,
    },
    {
        name = "show_uses",
        label = "Show Tools Uses(显示工具用途)",
        hover = "",
        options = {
            { description = "Undefined", data = -1, hover = "Yes, and users may override this option." },
            { description = "No", data = 0, hover = "No, but users may override this option." },
            { description = "Yes", data = 1, hover = "Yes, but users may override this option." },
            { description = "Forbidden", data = 2, hover = "Server won't send this info to the clients and their settings will not matter." },
        },
        default = -1,
    },
    {
        name = "show_me_lang",
        label = "Language(语言)",
        --hover = "",
        options = {
            { description = "Auto", data = "auto", hover = "Detect Language Pack" },
            { description = "en", data = "en", hover = "English" },
            { description = "ru", data = "ru", hover = "Russian" },
            { description = "chs", data = "chs", hover = "Simplified Chinese" },
            { description = "cht", data = "cht", hover = "Traditional Chinese" },
            { description = "br", data = "br", hover = "Brazilian Portuguese" },
            { description = "pl", data = "pl", hover = "Polish" },
            { description = "kr", data = "kr", hover = "Korean" },
            { description = "es", data = "es", hover = "Spanish" },
        },
        default = "auto",
    },
    {
        name = "display_hp",
        label = "Display HP(显示血量)",
        --hover = "",
        options = {
            { description = "Auto", data = -1, hover = "Depends on installed mods." },
            { description = "No", data = 0, hover = "No, but users may override this option." },
            { description = "Yes", data = 1, hover = "Yes, but users may override this option." },
            { description = "Forbidden", data = 2, hover = "Server won't send this info to the clients and their settings will not matter." },
        },
        default = -1,
    },
    {
        name = "chestR",
        label = "Chest Col--Red(高亮颜色-红)",
        hover = "This is red component of highlighted chests color.",
        options = color_options,
        default = -1,
    },
    {
        name = "chestG",
        label = "Chest Col--Green(高亮颜色-绿)",
        hover = "This is green component of highlighted chests color.",
        options = color_options,
        default = -1,
    },
    {
        name = "chestB",
        label = "Chest Col--Blue(高亮颜色-蓝)",
        hover = "This is blue component of highlighted chests color.",
        options = color_options,
        default = -1,
    },
    AddOptionHeader("全图定位"),
    AddOption("global_position_switch", "全图定位-开关", "是否开启全图定位", true),
    {
        name = "SHOWPLAYERSOPTIONS",
        label = "Player Indicators(玩家指示器)",
        hover = "The arrow things that show players past the edge of the screen.",
        options = {
            { description = "Always", data = 3 },
            { description = "Scoreboard", data = 2 },
            { description = "Never", data = 1 },
        },
        default = 2,
    },
    {
        name = "SHOWPLAYERICONS",
        label = "Player Icons(玩家图标)",
        hover = "The player icons on the map.",
        options = {
            { description = "Show", data = true },
            { description = "Hide", data = false },
        },
        default = true,
    },
    {
        name = "FIREOPTIONS",
        label = "Show Fires(火堆指示器)",
        hover = "Show fires with indicators like players." ..
                "\nThey will smoke when they are visible this way.",
        options = {
            { description = "Always", data = 1 },
            { description = "Charcoal", data = 2 },
            { description = "Disabled", data = 3 },
        },
        default = 2,
    },
    {
        name = "SHOWFIREICONS",
        label = "Fire Icons(火堆图标)",
        hover = "Show fires globally on the map (this will only work if fires are set to show)." ..
                "\nThey will smoke when they are visible this way.",
        options = {
            { description = "Show", data = true },
            { description = "Hide", data = false },
        },
        default = true,
    },
    {
        name = "SHAREMINIMAPPROGRESS",
        label = "Share Map(共享地图)",
        hover = "Share map exploration between players. This will only work if" ..
                "\n'Player Indicators' and 'Player Icons' are not both disabled.",
        options = {
            { description = "Enabled", data = true },
            { description = "Disabled", data = false },
        },
        default = true,
    },
    {
        name = "OVERRIDEMODE",
        label = "Wilderness Override(荒野覆盖)",
        hover = "If enabled, it will use the other options you set in Wilderness mode." ..
                "\nOtherwise, it will not show players, but all fires will smoke and be visible.",
        options = {
            { description = "Enabled", data = true },
            { description = "Disabled", data = false },
        },
        default = false,
    },
    {
        name = "ENABLEPINGS",
        label = "Pings(点位标记)",
        hover = "Whether to allow players to ping (alt+click) the map.",
        options = {
            { description = "Enabled", data = true },
            { description = "Disabled", data = false },
        },
        default = true,
    },
    AddOptionHeader("蘑菇农场"),
    AddOption("improve_mushroom_planters_switch", "蘑菇农场增强-开关", "是否开启蘑菇农场增强", true),
    {
        name = "max_harvests",
        label = "Maximum Fertilization(最大收获数量)",
        hover = "Maximum amount of fertilizer value the planter can store. Living logs restore this many harvests.",
        options = {
            { description = "Unlimited", data = -1, hover = "Default, but never decrease" },
            { description = "Default", data = 0, hover = "4 unless modded" },
            { description = "8", data = 8, hover = "8 harvests" },
            { description = "16", data = 16, hover = "16 harvests" },
            { description = "32", data = 32, hover = "32 harvests" },
        },
        default = 0,
    },
    {
        name = "easy_fert",
        label = "Allow Fertilizers(允许使用肥料)",
        hover = "If fertilizers can be used in place of living logs",
        options = {
            { description = "No", data = false, hover = "Living logs only" },
            { description = "Yes", data = true, hover = "Fertilizes by the sum of all nutrients divided by 8" },
        },
        default = false,
    },
    {
        name = "snow_grow",
        label = "Grow When Snow-covered(被雪覆盖是否允许生长)",
        hover = "Whether to continue growing in winter or pause growth until snow melts",
        options = {
            { description = "No", data = false, hover = "Pause growth" },
            { description = "Yes", data = true, hover = "Keep growing" },
        },
        default = false,
    },
    {
        name = "moon_ok",
        label = "Allow Moon Shrooms(月亮蘑菇可种植)",
        hover = "Should planters accept moon shrooms? Doesn't effect lunar spores.",
        options = {
            { description = "No", data = false, hover = "Don't accept moon shrooms" },
            { description = "Yes", data = true, hover = "Accept moon shrooms" },
        },
        default = true,
    },
    {
        name = "moon_spore",
        label = "Catchable Lunar Spores(可捕捉月孢子)",
        hover = "Lunar spores can be caught with a bug net and used in a planter. What could go wrong?",
        options = {
            { description = "No", data = false, hover = "Spores just explode, as usual" },
            { description = "Yes", data = true, hover = "Spores can be caught and planted" },
        },
        default = false,
    },
    AddOptionHeader("龙鳞冰炉"),
    AddOption("ice_furnace_switch", "龙鳞冰炉制作-开关", "是否可以制作龙鳞冰炉", false),
    {
        name = "lang",
        label = "Language/语言",
        hover = "The language you prefer to display the information related to Ice Furnaces" .. "\n你想要的用来显示冰炉相关信息的语言",
        options = {
            { description = "English", data = true, hover = "Information related to Ice Furnaces will be displayed in English" },
            { description = "中文", data = false, hover = "将用中文来显示龙鳞冰炉的相关信息" },
        },
        default = false,
    },
    {
        name = "temp",
        label = "Heat Control/调温",
        hover = "Whether the Ice Furnace automatically adjust the heat" .. "\n冰炉是否自动调温",
        options = {
            { description = "Yes/是", data = true, hover = "The Ice Furnace does not cause undercooling/冰炉不会导致过冷" },
            { description = "No/否", data = false, hover = "The Ice Furnace keeps the strongest heat/冰炉保持最低温" },
        },
        default = false,
    },
    {
        name = "light_range",
        label = "Light Range/光照范围",
        hover = "The light range of Ice Furnaces" .. "\n龙鳞冰炉的光照范围",
        options = {
            { description = "Default/默认", data = 1, hover = "1 unit of light range/1个单位的光照范围" },
            { description = "2.5", data = 2.5, hover = "2.5 units of light range/2.5个单位的光照范围" },
            { description = "5", data = 5, hover = "5 units of light range/5个单位的光照范围" },
            { description = "7.5", data = 7.5, hover = "7.5 units of light range/7.5个单位的光照范围" },
            { description = "10", data = 10, hover = "10 units of light range/10个单位的光照范围" },
        },
        default = 1,
    },
    {
        name = "container_slot",
        label = "Number of slots/容器格数",
        hover = "The size of the container" .. "\n容器的空间大小",
        options = {
            { description = "None/无容器", data = 0, hover = "No container for Ice Furnaces/冰炉不具备容器功能" },
            { description = "3 x 1", data = 3, hover = "Container contains 3 slots/容器拥有3格空间" },
            { description = "3 x 2", data = 6, hover = "Container contains 6 slots/容器拥有6格空间" },
            { description = "3 x 3", data = 9, hover = "Container contains 9 slots/容器拥有9格空间" },
            { description = "3 x 4", data = 12, hover = "Container contains 12 slots/容器拥有12格空间" },
            { description = "3 x 5", data = 15, hover = "Container contains 15 slots/容器拥有15格空间" },
        },
        default = 3,
    },
    {
        name = "fresh_rate",
        label = "Preservation Rate/保存速率",
        hover = "The preservation rate of the container" .. "\n龙鳞冰炉的保鲜能力",
        options = {
            { description = "Default/默认", data = 1, hover = "Ice furnaces do not provide preservation effect/冰炉不提供保鲜效果" },
            { description = "0.5", data = 0.5, hover = "Items inside spoil 2 times slower/2倍保鲜" },
            { description = "0.25", data = 0.25, hover = "Items inside spoil 4 times slower/4倍保鲜" },
            { description = "0", data = 0, hover = "Items inside do not spoil/永久保鲜" },
            { description = "-0.25", data = -0.25, hover = "Items inside restore freshness at a rate of 0.25/0.25倍反鲜" },
            { description = "-0.5", data = -0.5, hover = "Items inside restore freshness at a rate of 0.5/0.5倍反鲜" },
            { description = "-1", data = -1, hover = "Items inside restore freshness at a rate of 1/一倍反鲜" },
            { description = "-2", data = -2, hover = "Items inside restore freshness at a rate of 2/两倍反鲜" },
            { description = "-4", data = -4, hover = "Items inside restore freshness at a rate of 4/四倍反鲜" },
        },
        default = 0,
    },
    {
        name = "produce_ice",
        label = "Ice Production Interval/产冰间隔",
        hover = "The frequency of the ice production" .. "\n冰炉生产冰的频率",
        options = {
            { description = "5s", data = 5, hover = "Produce one piece of ice every 5 seconds/每5秒生产一块冰" },
            { description = "15s", data = 15, hover = "Produce one piece of ice every 15 seconds/每15秒生产一块冰" },
            { description = "30s", data = 30, hover = "Produce one piece of ice every 30 seconds/每30秒生产一块冰" },
            { description = "60s", data = 60, hover = "Produce one piece of ice every 60 seconds/每60秒生产一块冰" },
            { description = "120s", data = 120, hover = "Produce one piece of ice every 120 seconds/每120秒生产一块冰" },
            { description = "240s", data = 240, hover = "Produce one piece of ice every 240 seconds/每240秒生产一块冰" },
            { description = "480s", data = 480, hover = "Produce one piece of ice every 480 seconds/每480秒生产一块冰" },
            { description = "No Ice/不生产", data = 99999, hover = "No Ice Production/不生产冰" },
        },
        default = 240,
    },
    {
        name = "way_to_obtain",
        label = "Way to Obtain/获得途径",
        hover = "The way to obtain Ice Furnaces" .. "\n获得龙鳞冰炉的途径",
        options = {
            { description = "Staff/法杖", data = 1, hover = "Get Ice Furnaces by consuming Ice Staffs/通过消耗冰冻法杖获得冰炉" },
            { description = "Switch/切换", data = 2, hover = "Get Ice Furnaces by switching Scaled Furnaces/将火炉切换为冰炉" },
            { description = "Blueprint/蓝图", data = 3, hover = "Build Ice Furnaces by learning blueprint/通过学习蓝图来建造冰炉" },

        },
        default = 1,
    },
    AddOptionHeader("小穹补丁"),
    --AddOption("bellflower_pack_start", "打包风铃草-开关", "小穹是否自带打包风铃草", true),
    --AddOption("limit_sorapacker", "小穹打包纸限制-开关", "小穹禁止打包一些公共物品", true),
    AddOption("sora_patches_switch", "小穹补丁-总开关", "是否开启小穹补丁", false),
    {
        name = "soraRemoveDeathExpByLevel",
        label = "减免死亡惩罚",
        hover = "穹一定等级后死亡不掉落经验",
        options = {
            { description = "不改变", data = -1 },
            { description = "1级", data = 1 },
            { description = "5级", data = 5 },
            { description = "10级", data = 10 },
            { description = "15级", data = 15 },
            { description = "20级", data = 20 },
            { description = "25级", data = 25 },
            { description = "30级", data = 30 },
        },
        default = 20
    },
    {
        name = "soraRemoveRollExpByLevel",
        label = "减免换人惩罚",
        hover = "穹一定等级后换人不掉落经验",
        options = {
            { description = "不改变", data = -1 },
            { description = "1级", data = 1 },
            { description = "5级", data = 5 },
            { description = "10级", data = 10 },
            { description = "15级", data = 15 },
            { description = "20级", data = 20 },
            { description = "25级", data = 25 },
            { description = "30级", data = 30 },
        },
        default = 20
    },
    {
        name = "soraHealDeath",
        label = "愈还原",
        hover = "鞭尸",
        options = {
            { description = "不改变", data = false },
            { description = "还原", data = true },
        },
        default = false
    },
    {
        name = "soraRepairerToPhilosopherStoneLimit",
        label = "限制缝纫包修贤者宝石",
        hover = "",
        options = {
            { description = "不改变", data = 0 },
            { description = "修0.5%", data = 0.005 },
            { description = "修1%", data = 0.01 },
            { description = "修2%", data = 0.02 },
            { description = "修5%", data = 0.05 },
            { description = "修10%", data = 0.1 },
            { description = "修20%", data = 0.2 },
        },
        default = 0.01
    },
    {
        name = "soraFastMaker",
        label = "制作速度更快！",
        hover = "装备荣誉勋章或穹与巧手勋章可以提高制作速度！穹30级进一步提高。",
        options = {
            { description = "不改变", data = false },
            { description = "提高", data = true },
        },
        default = true
    },
    {
        name = "soraDoubleMaker",
        label = "一定等级解锁双倍制作",
        hover = "平行世界里偷不算偷！",
        options = {
            { description = "不改变", data = -1 },
            { description = "一开始", data = 0 },
            { description = "5级", data = 5 },
            { description = "10级", data = 10 },
            { description = "15级", data = 15 },
            { description = "20级", data = 20 },
            { description = "25级", data = 25 },
            { description = "30级", data = 30 },
        },
        default = 30
    },
    {
        name = "soraPackLimit",
        label = "限制打包",
        hover = "禁止穹打包一些独有的东西，比如猪王等。",
        options = {
            { description = "限制", data = true },
            { description = "不限制", data = false },
        },
        default = true
    },
    {
        name = "soraPackFL",
        label = "打包风铃草",
        hover = "初始自动打包风铃",
        options = {
            { description = "打包", data = true },
            { description = "不打包", data = false },
        },
        default = true
    },
    {
        name = "sorafl_select",
        label = "风铃草自选",
        hover = "绑定风铃草时可以自选装备(小穹mod)",
        options = {
            { description = "是", data = true },
            { description = "否", data = false },
        },
        default = false,
    },
    AddOptionHeader("魔女之旅补丁"),
    AddOption("elaina_patches_switch", "魔女补丁总开关", "是否开启魔女补丁", false),
    AddOption("elaina_additional_skin_switch", "魔女额外皮肤", "是否开启魔女额外皮肤", false),
    {
        name = "ban_brooch",
        label = "禁用专属胸针",
        hover = "禁用伊蕾娜专属胸针(都乖乖舔老师去)",
        options = {
            { description = "是", data = true },
            { description = "否", data = false },
        },
        default = false,
    },
    {
        name = "ban_most_brooch",
        label = "禁用最强胸针",
        hover = "禁用伊蕾娜的最强胸针",
        options = {
            { description = "是", data = true },
            { description = "否", data = false },
        },
        default = false,
    },

    AddOptionHeader("夜雨空心补丁"),
    AddOption("yeyu_nilxin_patches_switch", "夜雨空心补丁总开关", "是否开启夜雨空心补丁", false),
    {
        name = "yeyu_ruqin",
        label = "夜雨空心入侵",
        hover = "入侵生物一段时间消失 地图范围外消失 防止小房子周围刷",
        options = {
            { description = "否", data = false },
            { description = "不消失", data = -1, hover = "地图范围外仍然消失" },
            { description = "马上消失 主世界可用", data = 0, hover = "建议主世界设置" },
            { description = "1天", data = 1 },
            { description = "1.5天", data = 1.5 },
            { description = "2天", data = 2, },
            { description = "3天", data = 3, },
        },
        default = -1,
    },
    AddOption("yeyu_nilxin_pack_limit", "夜雨空心打包", "限制", false),
    AddOption("xiuxian_patches", "夜雨空心 修仙额外", "限制了一些修仙武器可以放入魔杖", false),
    {
        name = "yeyu_nilxin_jump_distance_limit",
        label = "夜雨心空跳跃限制",
        hover = "限制夜雨心空的跳跃距离",
        options = {
            { description = "不限制", data = -1, },
            { description = "原地跳(哈哈)", data = 0, },
            { description = "100码", data = 100, },
            { description = "500码", data = 500, },
            { description = "1000码", data = 1000, },
            { description = "2000码", data = 2000, },
            { description = "3000码", data = 3000, },
            { description = "4000码", data = 4000, },
            { description = "5000码", data = 5000, },
        },
        default = -1,
    },
    AddOptionHeader("奇幻降临补丁"),
    {
        name = "ab_patches_switch",
        label = "奇幻降临补丁",
        hover = "限制奇幻降临扭结碎片的掉落最大值及自动堆叠",
        options = {
            { description = "是", data = true },
            { description = "否", data = false },
        },
        default = false,
    },
    -- AddOptionHeader("璇儿补丁"),
    -- {
    --     name = "xuaner_patch",
    --     label = "璇儿补丁",
    --     hover = "无死亡惩罚",
    --     options =
    --     {
    --         {description = "是", data = true},
    --         {description = "否", data = false},
    --     },
    --     default = true,
    -- },
    AddOptionHeader("神话书说补丁"),
    AddOption("myth_patches_switch", "神话书说补丁-总开关", "是否开启神话书说补丁", true),
    {
        name = "timeleft_tips",
        label = "BOSS刷新提醒",
        hover = "",
        options = { {
                        description = "不提醒",
                        data = 1
                    }, {
                        description = "自动提醒",
                        data = 2
                    }, {
                        description = "热键提醒",
                        data = 3
                    } },
        default = 2
    },
    {
        name = "tip_key",
        label = "提醒热键",
        hover = "",
        options = { {
                        description = "F1",
                        data = KEY_F1
                    }, {
                        description = "F2",
                        data = KEY_F2
                    }, {
                        description = "F3",
                        data = KEY_F3
                    }, {
                        description = "F4",
                        data = KEY_F4
                    }, {
                        description = "F5",
                        data = KEY_F5
                    }, {
                        description = "F6",
                        data = KEY_F6
                    }, {
                        description = "F7",
                        data = KEY_F7
                    }, {
                        description = "F8",
                        data = KEY_F8
                    }, {
                        description = "F9",
                        data = KEY_F9
                    }, {
                        description = "F10",
                        data = KEY_F10
                    }, {
                        description = "F11",
                        data = KEY_F11
                    } },
        default = KEY_F8
    },
    {
        name = "blackbear_respawn",
        label = "黑熊重生时间",
        hover = "",
        options = { {
                        description = "默认",
                        data = 20
                    }, {
                        description = "较多",
                        data = 10
                    }, {
                        description = "大量",
                        data = 5
                    }, {
                        description = "小强",
                        data = 1
                    } },
        default = 20
    },
    {
        name = "rhino_respawn",
        label = "犀牛三大王重生时间",
        hover = "",
        options = { {
                        description = "默认",
                        data = 50
                    }, {
                        description = "较多",
                        data = 10
                    }, {
                        description = "大量",
                        data = 5
                    }, {
                        description = "小强",
                        data = 1
                    } },
        default = 50
    },
    {
        name = "regen_myth_forg_respawn",
        label = "金蛤蟆重生时间",
        hover = "",
        options = { {
                        description = "默认",
                        data = 20
                    }, {
                        description = "较多",
                        data = 10
                    }, {
                        description = "大量",
                        data = 5
                    }, {
                        description = "小强",
                        data = 1
                    } },
        default = 20
    },
    {
        name = "laozi_trade_num",
        label = "太上老君单人可交易次数",
        hover = "",
        options = { {
                        description = "1次(默认)",
                        data = 1
                    }, {
                        description = "2次",
                        data = 2
                    }, {
                        description = "3次",
                        data = 3
                    }, {
                        description = "4次",
                        data = 4
                    }, {
                        description = "5次",
                        data = 5
                    }, {
                        description = "6次",
                        data = 6
                    } },
        default = 1
    },
    {
        name = "granary_not_rot",
        label = "谷仓保鲜",
        hover = "",
        options = { {
                        description = "OFF",
                        data = false
                    }, {
                        description = "ON",
                        data = true
                    } },
        default = true
    },
    {
        name = "granary_save_fruit",
        label = "谷仓可放水果",
        hover = "",
        options = { {
                        description = "OFF",
                        data = false
                    }, {
                        description = "ON",
                        data = true
                    } },
        default = true
    },
    {
        name = "mythBlackBearRockClearTime",
        label = "黑熊岩石清理",
        hover = "一定时间后清理黑熊出来的岩石",
        options = {
            { description = "不清理", data = -1 },
            { description = "4分后清理", data = 4 * 60 },
            { description = "8分后清理", data = 8 * 60 },
            { description = "16分后清理", data = 16 * 60 },
            { description = "32分后清理", data = 32 * 60 },
        },
        default = 4 * 60,
    },
    {
        name = "mythFlyingSpeedMultiplier",
        label = "腾云术附带移动加成",
        hover = "腾云术附带部分移动速度加成",
        options = {
            { description = "不附带", data = 0 },
            { description = "附带25%", data = 0.25 },
            { description = "附带50%", data = 0.5 },
            { description = "附带75%", data = 0.75 },
            { description = "附带100%", data = 1 },
            { description = "附带150%", data = 1.5 },
            { description = "附带200%", data = 2 },
        },
        default = 1,
    },
    AddOptionHeader("怠惰科技补丁"),
    AddOption("lazy_technology_patches_switch", "怠惰科技补丁-开关", "怠惰科技补丁", false),
    {
        name = "lazyTechKJKLimit",
        label = "锟斤拷限制",
        hover = "进行进一步限制",
        options = {
            { description = "不限制", data = false },
            { description = "仅对可装备的物品有效", data = "equipment" },
            { description = "仅对武器和衣物有效", data = "weaponAndClothing" },
            { description = "仅对衣物有效", data = "clothing" },
            { description = "仅对武器有效", data = "weapon" },
            { description = "全部禁止", data = "null" },
        },
        default = "weaponAndClothing"
    },
    {
        name = "lazyTechHDSelectOptimize",
        label = "火堆检测优化",
        hover = "现在会检查是否有怠惰火堆改装的箱子烧可燃物",
        options = {
            { description = "不优化", data = false },
            { description = "优化", data = true },
        },
        default = true
    },
    AddOptionHeader("小房子补丁"),
    AddOption("sweet_house_patches_switch", "小房子可种植", "是否允许小房子可种植", false),


    AddOptionHeader("红锅补丁"),
    AddOption("red_pot_for_everyone_switch", "烹饪锅补丁开关", "任何人都可以使用烹饪锅？", false),
    AddOption("Cookpots", Cookpots_label, Cookpots_hover, Switch, true),
    AddOption("Other_item", Other_item_label, Other_item_hover, Switch, false),
    AddOption("Professionalchef", Professionalchef_label, Professionalchef_hover, Switch, false),
    {
        name = "CookingSpeed",
        label = CookingSpeed_label,
        hover = CookingSpeed_hove,
        options = {
            { description = SpeedNormal, data = false },
            { description = SpeedFast, data = 0.5 },
            { description = SpeedFaster, data = 0.25 },
            { description = SpeedFastest, data = 0.01 }
        },
        default = false
    },
    AddOption("AutoCook", AutoCook_label, AutoCook_hover, Switch, false),
    AddOptionHeader("码头套装增强"),
    AddOption("dock_kit_enhance_switch", "码头套装增强开关", "码头套装增强", true),
    {
        name = "DockKitNum",
        label = "码头套装制作数",
        hover = "设置 制作码头套装时会得到的数量。",
        options = {
            { description = "2个", data = 2 },
            { description = "4个(官方)", data = 4 },
            { description = "6个", data = 6 },
            { description = "8个", data = 8 },
            { description = "10个", data = 10 },
            { description = "12个", data = 12 },
            { description = "16个(默认)", data = 16 },
            { description = "20个", data = 20 }
        },
        default = 16
    },
    AddOption("DockTileBreak", "码头地皮不连环崩坏", "设置 码头地皮不会连环崩坏。", true),
    AddOption("DockKitAreaSea", "码头套装放置不限浅海", "设置 码头套装能在任何水域放置。", true),
    AddOption("DockKitAreaCave", "码头套装放置洞穴深渊", "设置 码头套装能在洞穴深渊放置。", true),
    AddOptionHeader("船只相关"),
    AddOption("new_boats_size_switch", "新不同大小船只开关", "是否可以创建不同大小船只", false),
    {
        name = "ALLOWSKINS",
        label = "使用皮肤(Allow skins)",
        hover = "创建船只是否允许使用皮肤(Allows players to craft boats with skins.)",
        options = {
            { description = "Enable", data = true },
            { description = "Disable", data = false },
        },
        default = true,
    },
    AddOptionHeader("发光的瓶子"),
    AddOption("light_bottle_switch", "制作发光的瓶子总开关", "是否可以制作发光的瓶子", false),
    {
        name = "light_bottle_lang",
        label = "Language(语言)",
        --hover = "",
        options = {
            { description = "English", data = "en", hover = "English" },
            { description = "简体中文", data = "chs", hover = "简体中文" },
        },
        default = "chs",
    },
    { name = "light_area",
      label = Light_area_label,
      options = {
          { description = "0.5", data = 0.5 },
          { description = "1", data = 1 },
          { description = "1.5", data = 1.5 },
          { description = "2", data = 2 },
          { description = "2.5", data = 2.5 },
          { description = "3", data = 3 },
          { description = "3.5", data = 3.5 },
          { description = "4", data = 4 },
          { description = "4.5", data = 4.5 },
          { description = "5", data = 5 },
          { description = "5.5", data = 5.5 },
          { description = "6", data = 6 },
          { description = "6.5", data = 6.5 },
          { description = "7", data = 7 },
          { description = "7.5", data = 7.5 },
          { description = "8", data = 8 },
          { description = "8.5", data = 8.5 },
          { description = "9", data = 9 },
          { description = "9.5", data = 9.5 },
          { description = "10", data = 10 },
          { description = "15", data = 15 },
          { description = "20", data = 20 },
          { description = "25", data = 25 },
          { description = "30", data = 30 },
      },
      default = 10,
    },
    { name = "Light_heal",
      label = Light_heal_label,
      options = {
          { description = "1", data = 1 },
          { description = "2", data = 2 },
          { description = "3", data = 3 },
          { description = "4", data = 4 },
          { description = "5", data = 5 },
          { description = "6", data = 6 },
          { description = "7", data = 7 },
          { description = "8", data = 8 },
          { description = "9", data = 9 },
          { description = "10", data = 10 },
          { description = "15", data = 15 },
          { description = "20", data = 20 },
      },
      default = 5,
    },
    { name = "Light_sunshine",
      label = Light_sunshine_label,
      options = {
          { description = "1", data = 1 },
          { description = "2 time", data = 2 },
          { description = "3 time", data = 3 },
          { description = "4 time", data = 4 },
          { description = "5 time", data = 5 },
          { description = "6 time", data = 6 },
          { description = "7 time", data = 7 },
          { description = "8 time", data = 8 },
          { description = "9 time", data = 9 },
          { description = "10 time", data = 10 },
          { description = "15 time", data = 15 },
          { description = "20 time", data = 20 },
          { description = "25 time", data = 25 },
          { description = "30 time", data = 30 },
      },
      default = 1,
    },
    { name = "Light_menacing",
      label = Light_menacing_label,
      options = {
          { description = "1", data = 1 },
          { description = "2 time", data = 2 },
          { description = "3 time", data = 3 },
          { description = "4 time", data = 4 },
          { description = "5 time", data = 5 },
          { description = "6 time", data = 6 },
          { description = "7 time", data = 7 },
          { description = "8 time", data = 8 },
          { description = "9 time", data = 9 },
          { description = "10 time", data = 10 },
          { description = "15 time", data = 15 },
          { description = "20 time", data = 20 },
          { description = "25 time", data = 25 },
          { description = "30 time", data = 30 },
      },
      default = 1,
    },
    { name = "Light_poison",
      label = Light_poison_label,
      options = {
          { description = "1", data = 1 },
          { description = "2", data = 2 },
          { description = "3", data = 3 },
          { description = "4", data = 4 },
          { description = "5", data = 5 },
          { description = "6", data = 6 },
          { description = "7", data = 7 },
          { description = "8", data = 8 },
          { description = "9", data = 9 },
          { description = "10", data = 10 },
          { description = "15", data = 15 },
          { description = "20", data = 20 },
          { description = "25", data = 25 },
          { description = "30", data = 30 },
          { description = "35", data = 35 },
          { description = "40", data = 40 },
          { description = "45", data = 45 },
          { description = "50", data = 50 },
      },
      default = 15,
    },
    { name = "Light_Ember",
      label = Light_Ember_label,
      options = {
          { description = "0.25 time", data = 0.25 },
          { description = "0.5 time", data = 0.5 },
          { description = "1 time", data = 1 },
          { description = "2 time", data = 2 },
          { description = "3 time", data = 3 },
          { description = "4 time", data = 4 },
          { description = "5 time", data = 5 },
          { description = "6 time", data = 6 },
          { description = "7 time", data = 7 },
          { description = "8 time", data = 8 },
          { description = "9 time", data = 9 },
          { description = "10 time", data = 10 },
          { description = "15 time", data = 15 },
          { description = "20 time", data = 20 },
          { description = "25 time", data = 25 },
          { description = "30 time", data = 30 },
      },
      default = 1,
    },
    { name = "Light_Icy",
      label = Light_Icy_label,
      options = {
          { description = "0.25 time", data = 0.25 },
          { description = "0.5 time", data = 0.5 },
          { description = "1 time", data = 1 },
          { description = "2 time", data = 2 },
          { description = "3 time", data = 3 },
          { description = "4 time", data = 4 },
          { description = "5 time", data = 5 },
          { description = "6 time", data = 6 },
          { description = "7 time", data = 7 },
          { description = "8 time", data = 8 },
          { description = "9 time", data = 9 },
          { description = "10 time", data = 10 },
          { description = "15 time", data = 15 },
          { description = "20 time", data = 20 },
          { description = "25 time", data = 25 },
          { description = "30 time", data = 30 },
      },
      default = 1,
    },

    AddOptionHeader("超大容量背包"),
    AddOption("bigbag_switch", "制作大背包开关", "是否可以制作超大背包", false),
    AddConfigOption("BIG_BAG_LANG", "Language (语言)", "Change display language.", { { description = "English", data = 0, }, { description = "简体中文", data = 1, }, }, 1),
    AddConfigOption("BAGSIZE", "Size of bag(背包大小)", "Size of bag", { { description = "8x3", data = 4, }, { description = "8x4", data = 1, }, { description = "8x6", data = 2, }, { description = "8x8", data = 3, }, }, 1),
    AddConfigOption("NICEBIGBAGSIZE", "Size of haversack(挎包大小)", "Choose your size of haversack.",
            {
                { description = "8x3", data = 1, },
                { description = "8x4", data = 2, },
            }, 2),
    AddOption("KEEPFRESH", "KeepFresh (保鲜)", "Keep the food fresh.", false),
    AddOption("LIGHT", "Light (保命微光)", "Let the bag give off light.", false),
    AddOption("BIGBAGWATER", "Rainproof(防雨)", "Protect you from the rain.", false),
    AddOption("BIGBAGPICK", "Fastpickup(快采)", "Let you pick up items quickly.", false),
    AddOption("HEATROCKTEMPERATURE", "HeatrockTemp(暖石升降温)", "Change the heatrock's temperature automatically.", false),
    AddConfigOption("WALKSPEED", "Walk Speed (移速)", "Walk speed while taking this bag.",
            { { description = "Much Slower(超慢)", data = 0.5, },
              { description = "Slower(慢)", data = 0.75, },
              { description = "No Change(不变)", data = 1, },
              { description = "Faster(快)", data = 1.25, },
              { description = "Much Faster(超快)", data = 1.5, }, }, 1),
    AddOption("BIG_BAG_STACK", "Full Stack (自动堆满)", "Get full stack when reopen the bag.(放一个重新打开会变堆叠满个数哦，慎用)", false),
    AddOption("BIG_BAG_FRESH", "ReFresh (恢复新鲜)", "ReFresh food and tools when reopen the bag.", false),
    --AddOption("GIVE", "Give Items (获得物品)", "!!! SEVER ONLY !!!  Give Items Directly If Can't Build Something. !!! SEVER ONLY !!!", false),
    AddConfigOption("RECIPE", "Recipe (耗材)", "Recipe cost.",
            { { description = "Very Cheap(超便宜)", data = 1, },
              { description = "Cheap(便宜)", data = 2, },
              { description = "Normal(正常)", data = 3, },
              { description = "Expensive(贵)", data = 4, },
              { description = "More Expensive(更贵)", data = 5, },
              { description = "super Expensive(超贵)", data = 6, }, }, 6),
    AddConfigOption("CONTAINERDRAG_SWITCH", "BigBag Drag(背包拖拽)", "After opening, you can drag the bigbag's UI",
            { { description = "Close(关闭)", data = false, hover = "关闭容器拖拽" },
              { description = "Open(F1开启)", data = "KEY_F1", hover = "默认按住F1拖动" },
              { description = "F2", data = "KEY_F2", hover = "按住F2拖动" },
              { description = "F3", data = "KEY_F3", hover = "按住F3拖动" },
              { description = "F4", data = "KEY_F4", hover = "按住F4拖动" },
              { description = "F5", data = "KEY_F5", hover = "按住F5拖动" },
              { description = "F6", data = "KEY_F6", hover = "按住F6拖动" },
              { description = "F7", data = "KEY_F7", hover = "按住F7拖动" },
              { description = "F8", data = "KEY_F8", hover = "按住F8拖动" },
              { description = "F9", data = "KEY_F9", hover = "按住F9拖动" }, }, "KEY_F1"),
    --AddConfigOption("EASYSWITCH", "Easy switch(快捷开关)", "After opening, you can open the bigbag quickly",
    --        { { description = "Close", data = false, hover = "关闭快捷开关" },
    --          { description = "O", data = "KEY_O", hover = "使用快捷键O" },
    --          { description = "0", data = "KEY_0", hover = "使用快捷键0" },
    --          { description = "F1", data = "KEY_F1", hover = "使用快捷键F1" },
    --          { description = "F2", data = "KEY_F2", hover = "使用快捷键F2" },
    --          { description = "F3", data = "KEY_F3", hover = "使用快捷键F3" },
    --          { description = "F4", data = "KEY_F4", hover = "使用快捷键F4" },
    --          { description = "F5", data = "KEY_F5", hover = "使用快捷键F5" },
    --          { description = "F6", data = "KEY_F6", hover = "使用快捷键F6" },
    --          { description = "F7", data = "KEY_F7", hover = "使用快捷键F7" },
    --          { description = "F8", data = "KEY_F8", hover = "使用快捷键F8" },
    --          { description = "F9", data = "KEY_F9", hover = "使用快捷键F9" }, }, "KEY_O"),
    AddOption("BAGINBAG", "Bag in bag(包中包)", "Bag in bag", false),


    AddOptionHeader("物品/生物禁用"),
    AddOption("remove_something", "物品禁用", "是否开启物品禁用", false),
    AddConfigOption("remove_myth_mooncake", "神话的月饼", "让神话的月饼消失！", disappear_magic, -1),
    AddConfigOption("remove_myth_qxj", "神话的七星剑", "让神话的七星剑消失！", disappear_magic, -1),
    AddConfigOption("remove_myth_bigpeach", "神话的大蟠桃", "让神话的大蟠桃消失！", disappear_magic, 0),
    AddConfigOption("remove_aria_tower", "aria的领主之怒", "让aria的领主之怒消失！", disappear_magic, 0),
    AddConfigOption("remove_aria_transfer", "aria的晶能转换站", "让aria的晶能转换站消失！", disappear_magic, 0),
    AddConfigOption("remove_aria_blackhole", "aria的深空黑点", "让aria的深空黑点消失！", disappear_magic, 0),
    AddConfigOption("remove_abigail_williams_black_gold", "阿比盖尔威廉姆斯的暗金", "让阿比盖尔威廉姆斯的暗金消失！", disappear_magic, -1),
    AddConfigOption("remove_abigail_williams_atrium_light_moon", "阿比盖尔威廉姆斯的月之灯柱", "让阿比盖尔威廉姆斯的月之灯柱消失！", disappear_magic, 0),
    AddConfigOption("remove_abigail_williams_bonestew", "阿比盖尔威廉姆斯的无限炖肉汤", "让阿比盖尔威廉姆斯的无限炖肉汤消失！", disappear_magic, 0),
    AddConfigOption("remove_abigail_williams_ab_wilsontorch", "阿比盖尔威廉姆斯的疯狂的科学家火炬", "让阿比盖尔威廉姆斯的疯狂的科学家火炬消失！", disappear_magic, 0),
    AddConfigOption("remove_abigail_williams_traveler_armor", "阿比盖尔威廉姆斯的侠客服I", "让阿比盖尔威廉姆斯的侠客服I消失！", disappear_magic, -1),
    AddConfigOption("remove_abigail_williams_traveler_armor_2", "阿比盖尔威廉姆斯的疯狂的侠客服II", "让阿比盖尔威廉姆斯的疯狂的侠客服II消失！", disappear_magic, -1),
    AddConfigOption("remove_abigail_williams_traveler_armor_3", "阿比盖尔威廉姆斯的侠客服III", "让阿比盖尔威廉姆斯的侠客服III消失！", disappear_magic, -1),
    AddConfigOption("remove_abigail_williams_sword", "阿比盖尔威廉姆斯的侠客剑I", "让阿比盖尔威廉姆斯的疯狂的侠客剑I消失！", disappear_magic, -1),
    AddConfigOption("remove_abigail_williams_sword_a", "阿比盖尔威廉姆斯的疯狂的侠客剑II", "让阿比盖尔威廉姆斯的疯狂的侠客剑II消失！", disappear_magic, -1),
    AddConfigOption("remove_abigail_williams_sword_b", "阿比盖尔威廉姆斯的疯狂的侠客剑III", "让阿比盖尔威廉姆斯的疯狂的侠客剑III消失！", disappear_magic, -1),
    AddConfigOption("remove_nilxin_fox", "夜雨心空的金团子", "让夜雨心空的金团子消失！(防止召唤很多卡服)！", disappear_magic, 0),
    AddConfigOption("remove_nilxin_yyxk1", "夜雨心空的红尾巴", "让夜雨心空的红尾巴消失！", disappear_magic, 0),
    AddConfigOption("remove_yyxk_auto_recipe", "夜雨心空的聚合之仪", "让夜雨心空的聚合之仪消失！", disappear_magic, 0),
    AddConfigOption("remove_yyxk_auto_destroystructure", "夜雨心空的解构之仪", "让夜雨心空的解构之仪消失！", disappear_magic, 0),
    AddConfigOption("remove_kemomimi_book_fs", "小狐狸的丰收书", "让小狐狸的丰收书消失！(防止刷资源卡服)！", disappear_magic, 0),
    AddConfigOption("remove_kemomimi_magic_coin_colour", "小狐狸的彩虹召唤币", "让小狐狸的彩虹召唤币！(防止召唤很多卡服)！", disappear_magic, 0),
    AddConfigOption("remove_kemomimi_build_pig", "小狐狸的战斗大师", "让小狐狸的战斗大师消失", disappear_magic, 0),
    AddConfigOption("remove_monster_book", "能力勋章的怪物图鉴", "让怪物图鉴消失！(大量刷boss卡服)", disappear_magic, 0),
    AddConfigOption("remove_hclr_kjk", "怠惰科技的锟斤拷", "让怠惰科技的锟斤拷消失", disappear_magic, -1),
    AddConfigOption("老鼠", "不妥协的老鼠", "让不妥协的老鼠消失", disappear_magic, -1),
    AddConfigOption("恐怖剧钳", "不妥协的恐怖剧钳", "让不妥协的恐怖剧钳消失", disappear_magic, -1),
    AddConfigOption("圣诞节日", "取消圣诞掉落", "让原版圣诞乱七八糟的食品消失", disappear_magic, -1),
    AddConfigOption("remove_halloween_candy", "取消万圣节糖果掉落", "让原版万圣节糖果消失", disappear_magic, -1),
    AddConfigOption("青蛙", "青蛙", "让原版的青蛙消失", disappear_magic, 0),
    AddConfigOption("鸟粪", "鸟粪", "让原版的鸟粪食品消失", disappear_magic, 0),
    AddConfigOption("月乌鸦", "月乌鸦", "让天体英雄任务中的乌鸦消失", disappear_magic, 0),
    AddConfigOption("远古蜈蚣", "远古蜈蚣", "让地下档案室远古蜈蚣消失", disappear_magic, 0),
    AddConfigOption("remove_tiddle_decay", "黑死病的鼠疫球", "让黑死病的鼠疫球消失", disappear_magic, -1),
    --AddConfigOption("remove_heap_of_food_bird", "Heap Of food的鸟", "Heap Of food的鸟消失(防崩溃)", disappear_magic, -1),

    AddOptionHeader("内容PLUS"),
    AddOption("hide_admin_switch", "隐藏管理员-开关", "是否隐藏管理员标志", false),
    {
        name = "no_rollback",
        label = "禁止『发起投票->回滚世界』",
        options = {
            { description = "禁止投票回滚", data = true, hover = "不能发起投票回滚世界" },
            { description = "不禁止投票回滚", data = false, hover = "可以发起投票回滚世界" },
        },
        default = true,
    },
    {
        name = "no_regenerate",
        label = "禁止『发起投票->重置世界』",
        options = {
            { description = "禁止投票重置", data = true, hover = "不可以发起投票重置世界" },
            { description = "不禁止投票重置", data = false, hover = "可以发起投票重置世界" },
        },
        default = true,
    },
    AddConfigOption("optimiseAnnouncement", "优化重复宣告导致的刷屏", "统一文本宣告只会在设定值内显示一次",
            { { description = "关闭", data = 0 },
              { description = "1s内", data = 1 },
              { description = "5s内", data = 5 },
              { description = "10s内", data = 10 },
              { description = "20s内", data = 20 },
            }, 5),
    AddOption("SpyBundle", "包裹监控", "设置 对包裹相关的监控。", true),
    AddOption("SpyOther", "全能监控", "设置 玩家与生物相关的监控。", true),
    AddOption("remove_boss_taunted", "移除boss间的仇恨", "让boss之间不要相互伤害", false),
    AddOption("boss_prop_more_drop_switch", "boss掉落概率增多", "是否开启boss掉落增多", false),
    AddOption("reward_for_survival", "玩家存活激励", "是否开启玩家存活天数奖励制度", false),
    AddOption("blackstaff_make", "黑色法杖-开关", "是否可制作黑色法杖\n用于手动清理垃圾", true),
    AddOption("simple_health_bar_switch", "简单血量条-开关", "是否显示简单血量条", true),
    AddOption("baka_lamp", "霓庭灯、虹庭灯", "是否允许制作霓庭灯、虹庭灯\n永亮光源", false),
    AddOption("rabbit_house", "兔子喷泉", "是否允许建造兔子喷泉\n漂亮建筑", false),
    AddOption("venus_icebox_switches", "萝卜冰箱", "是否允许建造萝卜冰箱\n前4格永久保鲜", false),
    AddOptionHeader(""),
    AddOption("canal_plow", "填海造海道具", "是否可以使用填海造海道具", false),
    {
        name = "DEPLOY_RULE",
        label = "使用位置限制(Deployment location restrictions)",
        hover = [[填海造海道具是否只能放于海岸线
        Canal plow can only be placed on only the coastline or anywhere reachable]],
        options = {
            {
                description = "只能放于海岸线 Coastline",
                data = true
            }, {
                description = "任何地方 Anywhere",
                data = false
            }
        },
        default = true
    },
    AddOptionHeader(""),
    AddOption("random_blueprint_drop", "随机蓝图掉落开关", "是否开启随机蓝图掉落", false),
    AddConfigOption("drop_multiplying", "蓝图掉落倍率", "",
            { { description = "极低(0.1)", data = 0.1 },
              { description = "很低(0.25)", data = 0.25 },
              { description = "低(0.5)", data = 0.5 },
              { description = "较低(0.75)", data = 75 },
              { description = "默认(1.0)", data = 1 },
              { description = "较高(1.25)", data = 1.25 },
              { description = "高(1.5)", data = 1.5 },
              { description = "很高(2)", data = 2 },
              { description = "极高(3)", data = 3 }, }, 1),

    AddOptionHeader("强力清理"),
    AddOption("strong_leaner_switch", "强力清理", "是否开强力清理", false),
    {
        name = "checking_days",
        label = "Checking Days(清理间隔)",
        hover = "Checking Period(清理时间间隔)",
        options = {
            { description = "1", data = 1, hover = "" },
            { description = "2", data = 2, hover = "" },
            { description = "3", data = 3, hover = "" },
            { description = "5", data = 5, hover = "" },
            { description = "10", data = 10, hover = "" },
            { description = "20", data = 20, hover = "" },
            { description = "30", data = 30, hover = "" },
            { description = "40", data = 40, hover = "" },
            { description = "50", data = 50, hover = "" },
        },
        default = 2,
    },
    {
        name = "clean_mode",
        label = "Clean Mode(清理模式)",
        hover = "Whitelist mode or Blacklist mode(白名单模式或者黑名单模式)",
        options = {
            { description = "Whitelist", data = 0, hover = "" },
            { description = "Blacklist", data = 1, hover = "" },
        },
        default = 0,
    },
    {
        name = "white_area",
        label = "White Area(清理白名单区域)",
        hover = "Things near the tables will not be removed(茶几附近的物品不清理)",
        options = {
            { description = "Yes", data = true, hover = "" },
            { description = "No", data = false, hover = "" },
        },
        default = true,
    },
    {
        name = "tumbleweed_maxnum",
        label = "Tumbleweed Clean(风滚草清理)",
        hover = "超过配置数目风滚草被清理",
        options = {
            -- { description = "No", data = false, hover = "" },
            { description = "50", data = 50, hover = "" },
            { description = "100", data = 100, hover = "" },
            { description = "120", data = 120, hover = "" },
            { description = "150", data = 150, hover = "" },
            { description = "200", data = 200, hover = "" },
        },
        default = 100,
    },
    {
        name = "boat_clean",
        label = "Boat Clean(船只清理)",
        hover = "Destroy boats that were not used for a specific days.(特定游戏内天数不使用的船只被清理)",
        options = {
            { description = "No", data = false, hover = "" },
            { description = "180 days in game(180天)", data = 180, hover = "" },
            { description = "360 days in game(360天)", data = 360, hover = "" },
            { description = "540 days in game(540天)", data = 540, hover = "" },
            { description = "720 days in game(720天)", data = 720, hover = "" },
        },
        default = false,
    },
    {
        name = "use_for_tumbleweed",
        label = "Use For Tumbleweed(花样风滚草档使用)",
        hover = "Would clean tumbleweed,alterguardian,et.(花样风滚草会清理开出的天体等.)",
        options = {
            { description = "Yes", data = true, hover = "" },
            { description = "No", data = false, hover = "" },
        },
        default = false,
    },
    AddOptionHeader("反作弊"),
    AddOption("anti_cheat_switch", "开启反作弊", "是否开启反作弊功能", false),
    {
        name = "camera",
        label = "检测鹰眼",
        hover = "该功能尚在测试",
        options = {
            {
                description = "关闭该功能",
                data = 0,
                hover = "什么也不做"
            }, {
                description = "禁用鹰眼",
                data = 1,
                hover = "对于鹰眼的玩家自动将视野调整到正常范围,大视野可以用,但是鹰眼就过分了"
            }, {
                description = "检测鹰眼 ",
                data = 2,
                hover = "检测鹰眼的玩家并使其退出游戏"
            }

        },
        default = 0
    }, {
        name = "nightvision",
        label = "检测夜视",
        hover = "该功能尚在测试",
        options = {
            {
                description = "关闭该功能",
                data = 0,
                hover = "什么也不做"
            }, {
                description = "禁用夜视",
                data = 1,
                hover = "可以使大部分客户端夜视模组失效,可能存在未知问题"
            }, {
                description = "检测夜视",
                data = 2,
                hover = "检测夜视玩家并使其退出游戏"
            }
        },
        default = 0
    }, {
        name = "checkmode",
        label = "白名单模式",
        hover = "开启白名单模式",
        options = {
            {
                description = "是",
                data = true,
                hover = "只允许开启列表中的MOD"
            },
            {
                description = "否",
                data = false,
                hover = "不允许开启列表中的MOD"
            }
        },
        default = false
    }, { name = "whitemods", description = "白名单列表.", default = {} },
    { name = "blockmods", description = "黑名单名单列表.", default = {} },
}
---纯净辅助
configuration_options[#configuration_options + 1] = AddOptionHeader("微小游戏体验提升")
configuration_options[#configuration_options + 1] = AddOption("little_modify_for_pure_switch", "总开关", "一些提升纯净档的微小功能", false)
configuration_options[#configuration_options + 1] = AddOption("show_bundle_content_switch", "显示包裹内的东西", "可以看到打包内的东西，提升一点体验", false)
configuration_options[#configuration_options + 1] = AddOption("smart_unwrap_bundle_switch", "拆包裹进入物品栏", "拆开包裹会进物品栏或箱子而不是掉落在地上", false)
configuration_options[#configuration_options + 1] = AddOption("combinable_equipment_switch", "装备耐久合并", "同类装备可以互相合并耐久", false)
configuration_options[#configuration_options + 1] = AddOption("naming_for_watches_switch", "旺达表可以命名", "旺达的溯源表和裂缝表可以用羽毛笔命名", false)
configuration_options[#configuration_options + 1] = AddOption("glommer_statue_repairable_switch", "格罗姆雕像可修复", "可以用大理石修复格罗姆雕像", false)
configuration_options[#configuration_options + 1] = AddOption("block_pooping_switch", "橡胶塞堵住牛屁股", "橡胶塞可以堵住牛屁股使其不拉屎", false)
configuration_options[#configuration_options + 1] = AddOption("faster_trading_switch", "快速交易", "和猪王快速交易", false)

---权限/防熊
configuration_options[#configuration_options + 1] = AddOptionHeader("玩家物品权限/防熊")
configuration_options[#configuration_options + 1] = AddOption("player_authority_switch", "总开关", "是否开启玩家物品权限/防熊功能", false)
--configuration_options[#configuration_options + 1] = AddOption("player_authority_HIDE_ADMIN", "完全隐藏管理员标志", "该功能可能会导致一些需要管理员权限才能使用的mod失效", false)
configuration_options[#configuration_options + 1] = AddOption("player_authority_mod_tip", "禁止服务器mod更新提示公告", "服务器不再提示mod更新", false)
configuration_options[#configuration_options + 1] = AddOption("player_authority_ON", "开启权限管理", "", true)
--configuration_options[#configuration_options + 1] = AddOption("player_authority_language", "语言（language）", "", true) --ture 中文 false英文
configuration_options[#configuration_options + 1] = AddConfigOption("player_authority_PROTECTOR_DEPLOY_AREA", "权限范围", "在该范围内没有权限的玩家无法做大部分动作，尽量设置小范围",
        { { description = "2", data = 2 },
          { description = "5", data = 5 },
          { description = "10", data = 10 },
          { description = "15", data = 15 },
          { description = "20", data = 20 },
          { description = "25", data = 25 },
          { description = "30", data = 30 }, }, 10)
configuration_options[#configuration_options + 1] = AddConfigOption("player_authority_UNPROTECTOR_AREA", "特殊地点无权限范围", "重要地点如：隐士之家，门，洞口，猪王，Boss刷新等公共位置\n(该范围同等于#_clean指令范围)",
        { { description = "10", data = 10 },
          { description = "15", data = 15 },
          { description = "20", data = 20 },
          { description = "25", data = 25 }, }, 10)
configuration_options[#configuration_options + 1] = AddConfigOption("player_authority_PROTECTOR_TIME", "玩家离线权限解除天数", "以游戏世界天数为准,实际一天24小时等于游戏180天",
        { { description = "90", data = 90 },
          { description = "180", data = 180 },
          { description = "270", data = 270 },
          { description = "360", data = 360 },
          { description = "不限制", data = 0 }, }, 180)
configuration_options[#configuration_options + 1] = AddOption("player_authority_stack", "#stack指令", "输入指令自动堆叠玩家范围内的物品", true)
configuration_options[#configuration_options + 1] = AddOption("player_authority_SaveInfo", "主世界换人保留全部数据", "支持#restart，其它世界换人不保留数据", true)
configuration_options[#configuration_options + 1] = AddOption("player_authority_adduserid", "装备绑定", "使用暗影之心绑定", true)
configuration_options[#configuration_options + 1] = AddOption("player_authority_canburnable", "有权限建筑防止一切物品的恶意燃烧", "目前在测试阶段，只有火把能点燃建筑", false)

---访客掉落
configuration_options[#configuration_options + 1] = AddOptionHeader("访客掉落优化版")
configuration_options[#configuration_options + 1] = AddOption("passer_by_switch", "总开关", "访客掉落优化版", false)
configuration_options[#configuration_options + 1] = AddConfigOption("droppos", "访客物品掉落地点", "访客物品掉落地点",
        { { description = "原地", data = "none" },
          { description = "猪王", data = "pigking" },
          { description = "月台", data = "moonbase" },
          { description = "出生点", data = "portal" }, }, "moonbase")
configuration_options[#configuration_options + 1] = AddConfigOption("visitortime", "访客几天之后可以升级为成员", "访客几天之后可以升级为成员", choice_visitortime, 15)
configuration_options[#configuration_options + 1] = AddConfigOption("lighttime", "访客几天后可以进行危险操作", "访客几天后可以进行危险操作", choice_lighttime, 10)
configuration_options[#configuration_options + 1] = AddOption("showtitle", "显示头衔", "是否显示头衔", false)
configuration_options[#configuration_options + 1] = AddOption("can_light_sapling", "访客是否可以烧树苗", "", false)
configuration_options[#configuration_options + 1] = AddOption("can_light_grass", "访客是否可以烧种下的草", "", false)
configuration_options[#configuration_options + 1] = AddOption("onstart_resource", "访客冬天开局送温暖", "", true)
configuration_options[#configuration_options + 1] = AddOption("show_bundle_owner", "显示包裹所有者", "", true)

---角色禁选
configuration_options[#configuration_options + 1] = AddOptionHeader("自定义角色禁用")
configuration_options[#configuration_options + 1] = AddOption("remove_character_switch", "总开关", "是否开启禁用角色功能", false)
configuration_options[#configuration_options + 1] = AddConfigOption("cheat_admin_for_character", "Cheater Admin/角色管理员", "管理员是否可以使用禁用角色?\nCan admins use original disabled roles?", optionsYesNo, true)
configuration_options[#configuration_options + 1] = AddOptionHeader("(1):原版角色")
configuration_options[#configuration_options + 1] = AddOption("allclosure", "禁用所有原版角色", "是否开启禁用所有原版角色", false)
for i = 1, #DST_CHARACTERLIST do
    configuration_options[#configuration_options + 1] = AddConfigOption(DST_CHARACTERLIST[i], DST_CHARACTERNAMES[i], "Disable this character?\n是否禁用该角色", optionsEnableDisable, true)
end
configuration_options[#configuration_options + 1] = AddOptionHeader("(2):mod角色")
for i = 1, #MOD_CHARACTERLIST do
    configuration_options[#configuration_options + 1] = AddConfigOption(MOD_CHARACTERLIST[i], MOD_CHARACTERNAMES[i], "Disable this character?\n是否禁用该角色", optionsEnableDisable, false)
end

configuration_options[#configuration_options + 1] = AddOptionHeader("开局礼包")
configuration_options[#configuration_options + 1] = AddOption("self_define_start_switch", "开局包总开关", "是否启用开局包", false)
configuration_options[#configuration_options + 1] = AddOption("ANNOUNCE_TIP", "提示", "开局是否显示提示", false)
configuration_options[#configuration_options + 1] = AddConfigOption("PACKS_CD", "开局礼包间隔（天）", "",
        { { description = "None", data = 0 },
          { description = "1", data = 1 },
          { description = "2", data = 2 },
          { description = "3", data = 3 },
          { description = "4", data = 4 },
          { description = "5", data = 5 },
          { description = "10", data = 10 },
          { description = "每天", data = -1 }, }, 10)
configuration_options[#configuration_options + 1] = AddOption("RESOURCE_BALANCE", "资源平衡", "资源平衡", false)
configuration_options[#configuration_options + 1] = AddConfigOption("PACKS_CHARACTER", "角色包", "",
        { { description = "None", data = 0, hover = "None" },
          { description = "清淡", data = 1, hover = "火炬，长矛，原创人物的背包。" },
          { description = "核心", data = 2, hover = "原始人物的核心包。" },
          { description = "基础", data = 3, hover = "完整的原始包" },
          { description = "更多蓝图", data = 4, hover = "所有角色的更多蓝图" },
          { description = "富裕", data = 5, hover = "非常富" }, }, 0)
configuration_options[#configuration_options + 1] = AddConfigOption("PACKS_BUILD", "制造包", "任意无消耗制作",
        { { description = "None", data = 0 },
          { description = "1", data = 1 },
          { description = "3", data = 3 },
          { description = "5", data = 5 },
          { description = "10", data = 10 },
          { description = "20", data = 20 }, }, 0)
configuration_options[#configuration_options + 1] = AddOption("PACKS_SEASON", "季节包", "季节包", false)
configuration_options[#configuration_options + 1] = AddConfigOption("PACKS_BUFF", "BUFF (min)", "",
        { { description = "None", data = 0 },
          { description = "0.5", data = 0.5 },
          { description = "1", data = 1 },
          { description = "2", data = 2 },
          { description = "3", data = 3 },
          { description = "5", data = 5 }, }, 1)
configuration_options[#configuration_options + 1] = AddConfigOption("PACKS_SCIENCE", "解锁科学", "",
        { { description = "None", data = 0, hover = "None" },
          { description = "一本", data = 1, hover = "科学机器" },
          { description = "二本", data = 2, hover = "炼金机器" },
          { description = "三本", data = 3, hover = "魔法科技" },
          { description = "暗影", data = 4, hover = "暗影科技" },
          { description = "远古", data = 5, hover = "远古科技" }, }, 0)

configuration_options[#configuration_options + 1] = AddConfigOption("PACKS_BACKPACK", "赠送背包", "",
        { { description = "None", data = 0, hover = "None" },
          { description = "背包", data = 1, hover = "Backpack" },
          { description = "猪猪包", data = 2, hover = "Piggyback" },
          { description = "冰包", data = 3, hover = "Icepack" },
          { description = "小偷袋", data = 4, hover = "Krampus Sack" }, }, 0)

default_number = {
    0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, 40, 50, 99, 100, 500
}
resource_number = {}
for i = 1, #default_number do
    resource_number[i] = {
        description = default_number[i],
        data = default_number[i],
    }
end

resource_prefab = {
    { name = "axe", label = "斧子", default = 0 },
    { name = "pickaxe", label = "锄头", default = 0 },
    { name = "shovel", label = "铲子", default = 0 },
    { name = "torch", label = "火炬", default = 0 },
    { name = "spear", label = "长矛", default = 0 },
    { name = "footballhat", label = "头盔", default = 0 },
    { name = "armorwood", label = "原木套装", default = 0 },
    { name = "umbrella", label = "伞", default = 0 },
    { name = "amulet", label = "生命护身符", default = 0 },
    { name = "cane", label = "手杖", default = 0 },
    { name = "heatrock", label = "热石", default = 0 },
    { name = "compass", label = "指南针", default = 0 },
    { name = "dragonpie", label = "火龙果派", default = 2 },
    { name = "meat_dried", label = "风干肉", default = 2 },
    { name = "ice", label = "冰", default = 0 },
    { name = "bandage", label = "蜂蜜膏", default = 0 },
    { name = "acorn", label = "桦木果", default = 0 },
    { name = "log", label = "原木", default = 0 },
    { name = "twigs", label = "树枝", default = 5 },
    { name = "cutgrass", label = "草", default = 5 },
    { name = "cutreeds", label = "芦苇", default = 0 },
    { name = "poop", label = "便便", default = 0 },
    { name = "rocks", label = "岩石", default = 0 },
    { name = "flint", label = "打火石", default = 3 },
    { name = "nitre", label = "硝石", default = 0 },
    { name = "goldnugget", label = "金块", default = 0 },
    { name = "pigskin", label = "猪皮", default = 0 },
    { name = "silk", label = "丝", default = 0 },
    { name = "gears", label = "齿轮", default = 0 },
    { name = "archive_lockbox", label = "蒸馏的知识", default = 0 },
    { name = "siving_derivant_item", label = "棱镜:未中下的子圭--型岩", default = 0 },
    { name = "cutted_orchidbush", label = "棱镜:兰草种籽", default = 0 },
    { name = "cutted_lilybush", label = "棱镜:蹄莲芽丛", default = 0 },
    { name = "cutted_rosebush", label = "棱镜:蔷薇折枝", default = 0 },
}

for i = 1, #resource_prefab do
    configuration_options[#configuration_options + 1] = AddConfigOption(resource_prefab[i].name, resource_prefab[i].label, "", resource_number, resource_prefab[i].default)
end
---内置UI拖拽功能
configuration_options[#configuration_options + 1] = AddOptionHeader("UI拖拽缩放")
configuration_options[#configuration_options + 1] = AddOption("ui_button_badge_draggable_switch", "总开关", "是否开启UI拖拽缩放", false)
configuration_options[#configuration_options + 1] = AddConfigOption("ui_button_badge_drag_button", "拖拽按键(鼠标)", "按键触发功能优先级参考选项顺序",
        { { description = INPUTS[MOUSEBUTTON_LEFT], data = MOUSEBUTTON_LEFT },
          { description = INPUTS[MOUSEBUTTON_RIGHT], data = MOUSEBUTTON_RIGHT },
          { description = INPUTS[MOUSEBUTTON_MIDDLE], data = MOUSEBUTTON_MIDDLE },
          { description = INPUTS[MOUSEBUTTON_Button4], data = MOUSEBUTTON_Button4 },
          { description = INPUTS[MOUSEBUTTON_Button5], data = MOUSEBUTTON_Button5 }
            -- {description = "否", data = -1}
        }, MOUSEBUTTON_LEFT)
configuration_options[#configuration_options + 1] = AddConfigOption("ui_button_badge_reset_button", "复原按键(鼠标)", "",
        { { description = INPUTS[MOUSEBUTTON_LEFT], data = MOUSEBUTTON_LEFT },
          { description = INPUTS[MOUSEBUTTON_RIGHT], data = MOUSEBUTTON_RIGHT },
          { description = INPUTS[MOUSEBUTTON_MIDDLE], data = MOUSEBUTTON_MIDDLE },
          { description = INPUTS[MOUSEBUTTON_Button4], data = MOUSEBUTTON_Button4 },
          { description = INPUTS[MOUSEBUTTON_Button5], data = MOUSEBUTTON_Button5 }
            -- {description = "否", data = -1}
        }, MOUSEBUTTON_RIGHT)
configuration_options[#configuration_options + 1] = AddConfigOption("ui_button_badge_zoomout_button", "放大按键(鼠标)", "",
        { { description = INPUTS[MOUSEBUTTON_SCROLLUP], data = MOUSEBUTTON_SCROLLUP },
          { description = INPUTS[MOUSEBUTTON_SCROLLDOWN], data = MOUSEBUTTON_SCROLLDOWN },
          { description = INPUTS[MOUSEBUTTON_Button4], data = MOUSEBUTTON_Button4 },
          { description = INPUTS[MOUSEBUTTON_Button5], data = MOUSEBUTTON_Button5 },
          { description = "否", data = -1 } }, MOUSEBUTTON_SCROLLUP)
configuration_options[#configuration_options + 1] = AddConfigOption("ui_button_badge_zoomin_button", "缩小按键(鼠标)", "",
        { { description = INPUTS[MOUSEBUTTON_SCROLLUP], data = MOUSEBUTTON_SCROLLUP },
          { description = INPUTS[MOUSEBUTTON_SCROLLDOWN], data = MOUSEBUTTON_SCROLLDOWN },
          { description = INPUTS[MOUSEBUTTON_Button4], data = MOUSEBUTTON_Button4 },
          { description = INPUTS[MOUSEBUTTON_Button5], data = MOUSEBUTTON_Button5 },
          { description = "否", data = -1 } }, MOUSEBUTTON_SCROLLDOWN)
--configuration_options[#configuration_options + 1] = AddOption("ui_button_badge_craftingmenu", "制作栏支持", "", false)
configuration_options[#configuration_options + 1] = AddOption("ui_button_badge_mirrorflip", "镜像UI支持", "使用复原按键，目前仅支持WX-78电表，每次复原时切换一次镜像", false)
configuration_options[#configuration_options + 1] = AddOption("ui_button_badge_ui_more", "更多UI支持", "在右上角UI白名单基础上，动态识别更多右上角UI进行支持", true)
configuration_options[#configuration_options + 1] = AddOption("ui_button_badge_container", "容器UI支持", "能力勋章的容器拖拽开启时自动关闭该功能", true)
configuration_options[#configuration_options + 1] = AddOption("ui_button_badge_remember", "记住UI改动", "能力勋章的容器拖拽开启时自动关闭该功能", false)
configuration_options[#configuration_options + 1] = AddOption("ui_button_badge_tooltip", "显示提示文本", "能力勋章的容器拖拽开启时自动关闭该功能", true)

---Beta功能
configuration_options[#configuration_options + 1] = AddOptionHeader("Beta功能(非必要可选择关闭)")
configuration_options[#configuration_options + 1] = AddOption("beta_function_switch", "总开关", "是否开启Beta的一些功能", true)

--configuration_options[#configuration_options + 1] = AddOption("medal_ab_drrn_patches_switch", "装备栏优化", "对于开 阿比 度日如年 玩家物品栏 勋章栏异常的权宜之计", true)
--configuration_options[#configuration_options + 1] = AddOption("repeat_death_fix", "鞭尸修复", "修复鞭尸怪物(理论上应该也能阻止玩家被鞭尸)", true)
configuration_options[#configuration_options + 1] = AddOption("container_open_dont_drop_switch", "容器打开不掉落", "打开需要掉落的容器不再掉落", false)
configuration_options[#configuration_options + 1] = AddOption("container_sort_switch", "容器物品排序", "容器/箱子里面的物品自动排序\n妈妈再也不担心箱子乱七八糟了", false)
configuration_options[#configuration_options + 1] = AddOption("fix_tags_overflow_switch", "标签溢出问题", "修复标签溢出问题", true)
configuration_options[#configuration_options + 1] = AddOption("give_item_optimize_switch", "拾取优化", "自动寻找打开的容器进行放入", false)
configuration_options[#configuration_options + 1] = AddOption("fix_heap_of_food_switch", "修复HeapOfFood问题", "修复HeapOfFood问题", false)
configuration_options[#configuration_options + 1] = AddOption("heap_of_food_chs_language_switch", "HeapOfFood汉化(简中)", "HeapOfFood汉化(简中)", false)
configuration_options[#configuration_options + 1] = AddOption("vtf_chs_language_switch", "情人节主题物品汉化(简中)", "情人节主题物品汉化(简中)", false)
configuration_options[#configuration_options + 1] = AddOption("htf_chs_language_switch", "万圣节主题物品汉化(简中)", "万圣节主题物品汉化(简中)", false)

--取消世界同步
configuration_options[#configuration_options + 1] = AddOptionHeader("")
configuration_options[#configuration_options + 1] = AddOption("cancel_sync_cycles_with_master_switch", "取消世界季节时间阶段种类同步", "不同世界享有不同季节时钟，日/暮/夜独立", false)
configuration_options[#configuration_options + 1] = AddOption("time_sync_with_master", "时间同步", "开启:与主世界天数一致\n 关闭:独立的天数计量", true)
