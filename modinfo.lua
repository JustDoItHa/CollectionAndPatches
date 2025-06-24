name = "Collection And Patches[合集和补丁]"
description = [[
不推荐订阅
]]
---- 本mod是众多mod贡献者的合集和修正,仅用于自用,不推荐订阅,
---- 球球了,本mod只是自己服务器跟几个朋友用
---- 请订阅原版mod,感谢mod贡献者的辛勤付出
----------------------------------------------------------------------
--修改自以下mod:
--1.黑色法杖（手动清理神器）2.小穹补丁(zymod) 3.全图定位 4.影藏管理员标志
--5.蘑菇农场增强 6.简单血量条 7.ShowMe 8.死亡不掉落 9.五格装备栏 10.二本垃圾箱
--11.掉落自动堆叠 12.最大堆叠个数限制 13.更多堆叠 14.帐篷耐久 15.木棚耐久
--16.木牌传送 and 木牌传送（皮肤版） 17.死亡复活按钮 18.死亡复活指令 19.冰箱反鲜 20.快速工作 21.陷阱增强
--22.霓庭灯 23.兔子喷泉 24.智能小木牌 25.小房子种植 26.让每个人都可以使用烹饪锅
--27.额外装备栏plus+ 28.秘玥 29.消失咒 30.浅的工具包 31.反作弊mod
--32.删除默认人物RemoveDefaultCharacter 33.萝卜冰箱 34.large boats
--35.发光的瓶子 36.大背包新 37.禁用自定义人物 38.容器不掉路 39.箱子物品自动排序
--40.UI拖拽缩放 41.Heap of Foods 全汉化 42.访客掉落优化版 43.纯净辅助
--44.超级便携大箱子 45.beefalo status bar 46.疼总的信息显示(就是偷来的,好看)
--47.史诗般血量条 48.为爽而虐-容器排序 49.鼠标滚轮调节堆叠 50.可升级箱子(已经抄过来用了)
--51.cat bag 52.wing pack 53.神秘强化炉 54.死亡累计升级版 55.More Crafting Details
--56.箱子容量+ 57.新月之魔典  58.一键挂机 59.寻路补丁 60.嫦娥
--集合mod：1
--1.常用mod集合
--2.萌新合集-服务端
----------------------------------------------------------------------

author = "EL"
version = "14.7.0.1"

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

server_filter_tags = { "CAP", "Collection And Patches", "合集和补丁" }


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

local tumbleweed_item_rates_options = {
    { description = "无", data = false, },
    { description = "10000", data = 10000, },
    { description = "1000", data = 1000, },
    { description = "100", data = 100, },
    { description = "10", data = 10, },
    { description = "5", data = 5, },
    { description = "2", data = 2, },
    { description = "1", data = 1, },
    { description = "0.5", data = 0.5, },
    { description = "0.2", data = 0.2, },
    { description = "0.1", data = 0.1, },
    { description = "0.05", data = 0.05, },
    { description = "0.01", data = 0.01, },
    { description = "0.01", data = 0.01, },
}
local tumbleweed_item_multiple_options = {
    { description = "无", data = false, },
    { description = "1000倍", data = 1000, },
    { description = "100倍", data = 100, },
    { description = "10倍", data = 10, },
    { description = "默认", data = 1, },
    { description = "0.1倍", data = 0.1, },
    { description = "0.01倍", data = 0.01, },
    { description = "0.001倍", data = 0.001, },
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
    { description = "是(Yes)", data = true },
    { description = "否(No)", data = false },
}

local optionsEnableDisable = {
    { description = "禁用(disable)", data = true },
    { description = "启用(enable)", data = false },
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

local Enable, Disable
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

local Language_cn = (locale == "zh" or locale == "zht" or locale == "zhr") and true or false;

local config = {
    template = function()
        return {
            name = "",
            label = "",
            hover = "",
            options = {
                {
                    description = "",
                    hover = "",
                    data = "0"
                }
            },
            default = "0"
        }
    end,
    addBlockLabel = function(label)
        return {
            name = "",
            label = label or "",
            hover = "",
            options = {
                {
                    description = "",
                    hover = "",
                    data = "0"
                }
            },
            default = "0"
        }
    end,
    option = function(description, data, hover)
        return {
            description = description or "",
            data = data,
            hover = hover or ""
        };
    end,
    OPEN = Language_cn and "开启" or "Open",
    CLOSE = Language_cn and "关闭" or "Close",
}
local option = config.option;

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

local mod_restart_cd_options = {
    { description = "无", data = 0, hover = "无限使用" },
    { description = "1", data = 1, hover = "1 分钟" },
    { description = "2", data = 2, hover = "2 分钟" },
    { description = "4", data = 4, hover = "4 分钟" },
    { description = "8", data = 8, hover = "8 分钟" },
    { description = "12", data = 12, hover = "12 分钟(一天半)" },
    { description = "2天", data = 16, hover = "16 分钟(2天)" },
    { description = "3天", data = 24, hover = "24 分钟(3天)" },
    { description = "4天", data = 32, hover = "32 分钟(4天)" },
}

local light_bottle_options = {
    { description = "0.1", data = 0.1 },
    { description = "0.5", data = 0.5 },
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
    "xxx3", --芮塔
    "kurumi", --时崎狂三
    "kochosei", --蝴蝶精阴阳师
    "xxx_wuma", --雾码
    "yuki", --傲雪
    "lg_fanglingche", --方灵澈
    "lg_lilingyi", --李伶仪
    "elena", --伊蕾娜-松饼版
    "wonderwhy", --Ancient Dreams - ACT II
    "houxiaosheng", --神话：傲来神仙境
    "taizhen", --太真
    "ccs", -- 魔法少女小樱
    "binglinger", -- 冰凌儿
    "mcw", -- 冰川镜华
    "diana", -- 嘉然
    "bella", -- 贝拉
    "avava", -- 向晚
    "eileen", -- 乃琳

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
    "芮塔-xxx3",
    "时岐狂三-kurumi",
    "蝴蝶精-阴阳师kochosei",
    "雾码-xxx_wuma",
    "傲雪-yuki",
    "方灵澈-lg_fanglingche", --海洋传说
    "李伶仪-lg_lilingyi", --李伶仪海洋传说
    "伊蕾娜-松饼版-elena", --伊蕾娜-松饼版
    "远古梦境-wonderwhy", --Ancient Dreams - ACT II
    "傲来神仙境-houxiaosheng", --神话：傲来神仙境
    "太真-taizhen", --太真
    "魔法少女小樱-ccs", -- 魔法少女小樱
    "冰凌儿-binglinger", -- 冰凌儿
    "冰川镜华-mcw", -- 冰川镜华
    "枝江嘉然-diana", -- 枝江嘉然
    "枝江贝拉-bella", -- 枝江贝拉
    "枝江向晚-avava", -- 枝江向晚
    "枝江乃琳-eileen", -- 枝江乃琳
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

local corlors = { "绿色", "深褐色", "远峰蓝", "玫红", "蓝绿色", "淡紫色", "橙色", "紫色", "番茄红", "棕黄色", "象牙白", "红色", "金色", "黑色", "白色", "黄色", "蓝色", }

local show_info_edge_color_options = {}
for k = 1, #corlors do
    show_info_edge_color_options[k] = { description = corlors[k], data = k }
end

local character_word_forbidden = {
    ["210101"] = { "aria", "elaina", "yuki", "kurumi", "xxx3", "xxx_wuma", },
    ["210102"] = { "aria", "elaina", "yuki", "kurumi", "xxx3", "xxx_wuma", },
}

local sleeping_buff_hp_options = {
    { description = "-50%", data = 0.5 },
    { description = "系统默认", data = false },
    { description = "2x", data = 2 },
    { description = "3x", data = 3 },
    { description = "4x", data = 4 },
    { description = "5x", data = 5 },
    { description = "6x", data = 6 },
    { description = "8x", data = 8 },
    { description = "10x", data = 10 },
    { description = "20x", data = 20 },
    { description = "30x", data = 30 },
    { description = "50x", data = 50 },
    { description = "80x", data = 80 },
    { description = "100x", data = 100 },
    { description = "无限", data = "Infinite", hover = "无限耐久" },
    --{description = "系统默认", data = false},
}
local clean_num_options = {
    { description = "No(不检查数量)", data = false, hover = "" },
    { description = "50", data = 50, hover = "" },
    { description = "100", data = 100, hover = "" },
    { description = "120", data = 120, hover = "" },
    { description = "150", data = 150, hover = "" },
    { description = "200", data = 200, hover = "" },
    { description = "300", data = 300, hover = "" },
    { description = "500", data = 500, hover = "" },
    { description = "1000", data = 1000, hover = "" },
}
local strong_clean_white_list_additional = {}
local strong_clean_black_list_additional = {}
local strong_clean_white_tag_list_additional = {}
--local strong_clean_black_tag_list_additional = {}
local strong_clean_half_white_list_additional = {}
local strong_clean_strong_clean_list_additional = {}

local prevent_creature_extinction_count_option = {}

for i = 0, 10 do
    prevent_creature_extinction_count_option[#prevent_creature_extinction_count_option + 1] = {
        description = i,
        data = i,
    }
end
configuration_options = {
    AddOptionHeader("基础配置"),
    --TheNet:SetDefaultMaxPlayers(16)
    AddConfigOption("max_player_num", "服务器人数上限", "设置服务器的最大人数", {
        { description = "不在这里设置", data = 0 },
        { description = "1", data = 1 }, { description = "2", data = 2 }, { description = "3", data = 3 }, { description = "4", data = 4 }, { description = "5", data = 5 }, { description = "6", data = 6 }, { description = "7", data = 7 }, { description = "8", data = 8 }, { description = "9", data = 9 }, { description = "10", data = 10 },
        { description = "11", data = 11 }, { description = "12", data = 12 }, { description = "13", data = 13 }, { description = "14", data = 14 }, { description = "15", data = 15 }, { description = "16", data = 16 }, { description = "17", data = 17 }, { description = "18", data = 18 }, { description = "19", data = 19 }, { description = "20", data = 20 },
        { description = "21", data = 21 }, { description = "22", data = 22 }, { description = "23", data = 23 }, { description = "24", data = 24 }, { description = "25", data = 25 }, { description = "26", data = 26 }, { description = "27", data = 27 }, { description = "28", data = 28 }, { description = "29", data = 29 }, { description = "30", data = 30 },
        { description = "31", data = 31 }, { description = "32", data = 32 }, { description = "36", data = 36 }, { description = "42", data = 42 }, { description = "48", data = 48 }, { description = "64", data = 64 }, { description = "72", data = 72 },
        { description = "128", data = 128, hover = "你是认真的么..." }, { description = "256", data = 256, hover = "你是认真的么..." }, { description = "512", data = 512, hover = "你是认真的么..." }, { description = "1024", data = 1024, hover = "你是认真的么..." },
    }, 0),
    AddOption("hide_admin_switch", "隐藏管理员-开关", "是否隐藏管理员标志", false),

    AddConfigOption("no_rollback", "禁止『发起投票->回滚世界』", "", { { description = "禁止投票回滚", data = true, hover = "不能发起投票回滚世界" },
                                                                     { description = "不禁止投票回滚", data = false, hover = "可以发起投票回滚世界" }, }, true),
    AddConfigOption("no_regenerate", "禁止『发起投票->重置世界』", "", { { description = "禁止投票重置", data = true, hover = "不可以发起投票重置世界" },
                                                                       { description = "不禁止投票重置", data = false, hover = "可以发起投票重置世界" }, }, true),
    AddOption("invincible_status_switch", "J键无敌挂机-开关", "", false),
    AddConfigOption("optimiseAnnouncement", "优化重复宣告导致的刷屏", "统一文本宣告只会在设定值内显示一次", { { description = "关闭", data = 0 },
                                                                                                              { description = "1s内", data = 1 },
                                                                                                              { description = "5s内", data = 5 },
                                                                                                              { description = "10s内", data = 10 },
                                                                                                              { description = "20s内", data = 20 }, }, 5),
    AddOption("SpyBundle", "包裹监控", "设置对包裹相关的监控。", true),
    AddOption("SpyOther", "全能监控", "设置玩家与生物相关的监控。", true),
    AddOption("command_stack", "堆叠指令", "玩家聊天输入#stack堆叠附近的物品。", true),
    AddOption("change_stack_num_by_mousewheel_switch", "物品数量鼠标滚轮控制", "可以通过滚轮调整拿起的可堆叠物品的数量", true),
    AddOption("clean_garbage", "二本垃圾箱", "对二本科技右键会有4个小格子，将不想用的物品放入点击清理可直接删除", true),
    AddConfigOption("auto_stack_range", "掉落自动堆叠", "设置掉落物自动堆叠的范围，设为0关闭自动堆叠", { { description = "关闭", data = 0 }, { description = "10", data = 10 }, { description = "20", data = 20 }, { description = "30", data = 30, hover = "默认" }, { description = "40", data = 40 }, { description = "50", data = 50 }, { description = "60", data = 60 }, { description = "70", data = 70 }, { description = "80", data = 80 }, { description = "90", data = 90 }, { description = "100", data = 100 }, }, 30),

    AddOptionHeader("堆叠修改"),
    AddOption("cap_stack_size_switch", "总开关", "是否开启堆叠修改", false),
    AddConfigOption("cap_stack_size", "物品堆叠数量", "设置物品堆叠数量", { { description = "关闭", data = 0 }, { description = "40", data = 40 }, { description = "63", data = 63, hover = "最佳堆叠上限" }, { description = "99", data = 99, hover = "默认，两位数堆叠上限" }, { description = "128", data = 128 }, { description = "200", data = 200 }, { description = "255", data = 255 }, { description = "300", data = 300 }, { description = "400", data = 400 }, { description = "500", data = 500 }, { description = "666", data = 666 }, { description = "888", data = 888 }, { description = "999", data = 999 },  { description = "1000", data = 1000 },}, 40),
    AddConfigOption("cap_soul_stack_size", "灵魂堆叠数量", "设置灵魂堆叠数量", { { description = "关闭", data = 0 }, { description = "40", data = 40 }, { description = "63", data = 63, hover = "最佳堆叠上限" }, { description = "99", data = 99, hover = "默认，两位数堆叠上限" }, { description = "128", data = 128 }, { description = "200", data = 200 }, { description = "255", data = 255 }, { description = "300", data = 300 }, { description = "400", data = 400 }, { description = "500", data = 500 }, { description = "666", data = 666 }, { description = "888", data = 888 }, { description = "999", data = 999 },  { description = "1000", data = 1000 },}, 40),
    AddOptionHeader("更多堆叠及细项(堆叠修改总开关需打开)"),
    AddOption("cap_stack_more", "更多可堆叠", "使鸟、兔子、地鼠、鱼等生物变得可堆叠", true),

    -- 分别为：配置名（modmain中配置用）,中文显示名,英文显示名,默认是否开启,中文备注提示,英文备注提示
    -- 若没有备注提示，则后两项可以不用写。也可以只写中文备注，不写英文备注。但是若是需要写英文备注，则中文备注必填
    AddOption("stack_more_rabbit", "兔子","Rabbit",  true),
    AddOption("stack_more_mole", "鼹鼠", "Mole", true),
    AddOption("stack_more_bird", "鸟类", "Bird", true),
    AddOption("stack_more_crow", "月盲乌鸦", "月盲乌鸦", true),
    AddOption("stack_more_fish", "鱼类", "Fish", true),
    AddOption("stack_more_spider", "各类蜘蛛", "Spider", true),
    AddOption("stack_more_eyeturret", "眼球炮塔", "Eyeturret", true),
    AddOption("stack_more_tallbirdegg", "高脚鸟蛋", "Tallbirdegg\n如果需要孵化高鸟蛋，需要关闭堆叠\nIf you need to hatch tall eggs, you need to close the stack", true),
    AddOption("stack_more_lavae_egg", "岩浆虫卵", "Lavae egg\n如果需要孵化岩浆虫卵，需要关闭堆叠\nIf you need to hatch lavae eggs, you need to close the stack", true),
    AddOption("stack_more_shadowheart", "暗影心房", "Shadow heart", true),
    AddOption("stack_more_minotaurhorn", "犀牛角", "Minotaurhorn", true),
    AddOption("stack_more_glommerwings", "格罗姆翅膀", "Glommerwings", true),
    AddOption("stack_more_moonrockidol", "月岩雕像,告密的心", "Moonrockidol and Reviver", true),
    AddOption("stack_more_horn", "牛角和独角鲸角", "Horn\n注意：只能作为材料堆叠，如需作为工具，请关闭选项\nNote: TURN OFF WHEN USE IT AS TOOL", false),
    AddOption("stack_more_security_pulse_cage", "火花柜和约束静电", "Security Pulse Cage and Full Cage",true),
    AddOption("stack_more_deer_antler","鹿角和克劳斯钥匙","Deer Antler and Klaussackkey",true),
    AddOption("stack_more_chestupgrade_stacksize","箱子升级组件","箱子升级组件",true),
    AddOption("stack_more_shell","贝壳钟","贝壳钟",true),
    AddOption("stack_more_wally","厨师炊具","厨师炊具",true),
    AddOption("stack_more_winona","女工的投石机和聚光灯","女工的投石机和聚光灯",true),
    AddOption("stack_more_mooneye","月眼","月眼",true),
    AddOption("stack_more_boat_stuff","船上用品","船上用品",true),
    AddOption("stack_more_ancienttree_stuff","惊喜种子","惊喜种子",true),

    --addConfig("sketch1", "常用草图","Sketch", true),
    --AddOption("stack_more_myth_lotusleaf", "荷叶和月饼(神话书说)", "Lotusleaf and Mooncake", true),
    --AddOption("stack_more_blank_certificate", "空白勋章(能力勋章)", "Blank certificate", true),
    --AddOption("stack_more_lg_choufish_inv", "小丑鱼(海洋传说)", "Uglyfish", true),
    --AddOption("stack_more_aip_leaf_note", "树叶笔记(额外物品包)", "Aip leaf note", true),
    --AddOption("stack_more_foliageath", "青枝绿叶（棱镜）", "Foliageath", true),
    --AddOption("stack_more_miao_packbox", "超级打包盒（超级打包盒）", "Miao packbox\n需单个使用，整组使用会整组消耗", true),
    AddOption("cap_stack_mod", "mod物品堆叠", "一些mod物品可堆叠", false),
    AddOption("stack_more_reskin_tool", "其他自用", "For self use",false),


}
---死亡次数累计
configuration_options[#configuration_options + 1] = AddOptionHeader("死亡次数累计")
configuration_options[#configuration_options + 1] = AddOption("death_counter_switch", "死亡次数累计", "显示死亡次数累计", false)
configuration_options[#configuration_options + 1] = AddOption("death_counter_show_title", "是否显示头标", "", false)

---防止生物灭绝
local l_prevent_creature_extinction = (Language_cn ~= true)
configuration_options[#configuration_options + 1] = AddOptionHeader("防止生物灭绝")
configuration_options[#configuration_options + 1] = AddOption("prevent_creature_extinction_switch", "总开关", "是否开启防止生物灭绝", false)
configuration_options[#configuration_options + 1] = AddConfigOption("respawnmechanism", l_prevent_creature_extinction and "Respawn Mechanism" or "重生机制", l_prevent_creature_extinction and "Choose respawn near the death spot or randomly" or "选择在死亡点附近重生或随机重生", { { description = l_prevent_creature_extinction and "Near" or "附近", data = "scripts/respawnnear.lua", hover = "" },
                                                                                                                                                                                                                                                                                       { description = l_prevent_creature_extinction and "Randomly" or "随机", data = "scripts/respawnrandom.lua", hover = "" }, }, "scripts/respawnnear.lua")
configuration_options[#configuration_options + 1] = AddConfigOption("respawntime", l_prevent_creature_extinction and "Respawn Time" or "重生时间", l_prevent_creature_extinction and "This option only works when you choose respawn near the death spot." or "该选项仅在选择在死亡点附近重生时有效。", { { description = l_prevent_creature_extinction and "1  day" or "1  天", data = 1, hover = "" },
                                                                                                                                                                                                                                                                                                         { description = l_prevent_creature_extinction and "2  days" or "2  天", data = 2, hover = "" },
                                                                                                                                                                                                                                                                                                         { description = l_prevent_creature_extinction and "3  days" or "3  天", data = 3, hover = "" },
                                                                                                                                                                                                                                                                                                         { description = l_prevent_creature_extinction and "4  days" or "4  天", data = 4, hover = "" },
                                                                                                                                                                                                                                                                                                         { description = l_prevent_creature_extinction and "5  days" or "5  天", data = 5, hover = "" },
                                                                                                                                                                                                                                                                                                         { description = l_prevent_creature_extinction and "6  days" or "6  天", data = 6, hover = "" },
                                                                                                                                                                                                                                                                                                         { description = l_prevent_creature_extinction and "7  days" or "7  天", data = 7, hover = "" },
                                                                                                                                                                                                                                                                                                         { description = l_prevent_creature_extinction and "8  days" or "8  天", data = 8, hover = "" },
                                                                                                                                                                                                                                                                                                         { description = l_prevent_creature_extinction and "9  days" or "9  天", data = 9, hover = "" },
                                                                                                                                                                                                                                                                                                         { description = l_prevent_creature_extinction and "10 days" or "10 天", data = 10, hover = "" },
                                                                                                                                                                                                                                                                                                         { description = l_prevent_creature_extinction and "15 days" or "15 天", data = 15, hover = "" },
                                                                                                                                                                                                                                                                                                         { description = l_prevent_creature_extinction and "20 days" or "20 天", data = 20, hover = "" }, }, 5)
configuration_options[#configuration_options + 1] = AddConfigOption("leastnum_beefalo", l_prevent_creature_extinction and "Least Num of Beefalo" or "皮弗娄牛数量下限", "", prevent_creature_extinction_count_option, 2)
configuration_options[#configuration_options + 1] = AddConfigOption("leastnum_lightninggoat", l_prevent_creature_extinction and "Least Num of Lightning Goat" or "伏特羊数量下限", "", prevent_creature_extinction_count_option, 2)
configuration_options[#configuration_options + 1] = AddConfigOption("leastnum_spiderden", l_prevent_creature_extinction and "Least Num of Spider Den" or "蜘蛛巢数量下限", "", prevent_creature_extinction_count_option, 2)
configuration_options[#configuration_options + 1] = AddConfigOption("leastnum_catcoonden", l_prevent_creature_extinction and "Least Num of Catcoon Den" or "空洞树桩量下限", "", prevent_creature_extinction_count_option, 2)
configuration_options[#configuration_options + 1] = AddConfigOption("leastnum_beehive", l_prevent_creature_extinction and "Least Num of Bee Hive" or "蜂窝数量下限", "", prevent_creature_extinction_count_option, 2)
configuration_options[#configuration_options + 1] = AddConfigOption("leastnum_knight", l_prevent_creature_extinction and "Least Num of Knight" or "发条骑士数量下限", "", prevent_creature_extinction_count_option, 2)
configuration_options[#configuration_options + 1] = AddConfigOption("leastnum_rocky", l_prevent_creature_extinction and "Least Num of Rock Lobster" or "石虾数量下限", "", prevent_creature_extinction_count_option, 2)
configuration_options[#configuration_options + 1] = AddConfigOption("leastnum_slurtlehole", l_prevent_creature_extinction and "Least Num of Slurtle Mound" or "蛞蝓龟窝数量下限", "", prevent_creature_extinction_count_option, 2)

---睡眠设备调整
configuration_options[#configuration_options + 1] = AddOptionHeader("睡眠设备调整")
configuration_options[#configuration_options + 1] = AddOption("sleeping_buff_switch", "总开关", "是否开启睡眠设备相关的调整", false)
--configuration_options[#configuration_options + 1] = AddConfigOption("tent_uses", "帐篷耐久", "改帐篷耐久", { { description = "关闭", data = 15 }, { description = "10", data = 10 }, { description = "20", data = 20 }, { description = "30", data = 30 }, { description = "40", data = 40 }, { description = "50", data = 50 }, { description = "100", data = 100 }, { description = "200", data = 200 }, { description = "500", data = 500, hover = "默认" }, { description = "9999", data = 9999 }, }, 500)
--configuration_options[#configuration_options + 1] = AddConfigOption("siesta_canopy_uses", "木棚耐久", "改木棚耐久", { { description = "关闭", data = 16 }, { description = "10", data = 10 }, { description = "20", data = 20 }, { description = "30", data = 30 }, { description = "40", data = 40 }, { description = "50", data = 50 }, { description = "100", data = 100 }, { description = "200", data = 200 }, { description = "500", data = 500, hover = "默认" }, { description = "9999", data = 9999 }, }, 500)
configuration_options[#configuration_options + 1] = AddConfigOption("sleeping_buff_uses", "帐篷耐久", "改帐篷耐久", sleeping_buff_hp_options, false)
configuration_options[#configuration_options + 1] = AddConfigOption("sleeping_buff_uses2", "木棚耐久", "改木棚耐久", sleeping_buff_hp_options, false)
configuration_options[#configuration_options + 1] = AddConfigOption("sleeping_buff_uses3", "便携帐篷耐久", "便携帐篷耐久", sleeping_buff_hp_options, false)
configuration_options[#configuration_options + 1] = AddConfigOption("sleeping_buff_uses4", "毛皮铺盖耐久", "毛皮铺盖耐久", sleeping_buff_hp_options, false)
configuration_options[#configuration_options + 1] = AddConfigOption("sleeping_buff_t_smup", "黑血恢复", "睡觉是否可以黑血恢复", optionsYesNo, true)
configuration_options[#configuration_options + 1] = AddConfigOption("sleeping_buff_t_smhf", "恢复速度", "睡觉是回血速度", { { description = "-2", data = 0.1 }, { description = "-1.5", data = 0.5 }, { description = "关闭", data = false }, { description = "1.25", data = 1.25 }, { description = "1.5", data = 1.5 }, { description = "1.75", data = 1.75 }, { description = "2", data = 2 }, { description = "2.5", data = 2.5 }, { description = "3", data = 3 }, { description = "3.5", data = 3.5 }, { description = "4", data = 4 }, { description = "5", data = 5 }, { description = "6", data = 6 }, }, 3)

---死亡不掉落配置
configuration_options[#configuration_options + 1] = AddOptionHeader("死亡不掉落配置")
configuration_options[#configuration_options + 1] = AddOption("dont_drop", "是否开启死亡不掉落", "死亡不掉落物品总开关", false)
configuration_options[#configuration_options + 1] = AddConfigOption("rendiao", "本体掉落最大数量", "角色物品栏最大的掉落数量", { { description = "不掉落", data = 0, hover = "" }, { description = "1", data = 1, hover = "" }, { description = "2", data = 2, hover = "" }, { description = "3", data = 3, hover = "" }, { description = "4", data = 4, hover = "" }, { description = "5", data = 5, hover = "" }, { description = "6", data = 6, hover = "" }, { description = "7", data = 7, hover = "" }, { description = "8", data = 8, hover = "" }, { description = "9", data = 9, hover = "" } }, 0)
configuration_options[#configuration_options + 1] = AddConfigOption("baodiao", "背包掉落", "背包掉落的最大数量", { { description = "不掉落", data = 0, hover = "" }, { description = "1", data = 1, hover = "" }, { description = "2", data = 2, hover = "" }, { description = "3", data = 3, hover = "" }, { description = "4", data = 4, hover = "" }, { description = "5", data = 5, hover = "" }, { description = "6", data = 6, hover = "" }, { description = "7", data = 7, hover = "" }, { description = "8", data = 8, hover = "" }, { description = "9", data = 9, hover = "" } }, 0)
configuration_options[#configuration_options + 1] = AddOption("zbdiao", "装备掉落", "死亡掉落装备 \n 防止一些未知bug.", false)
configuration_options[#configuration_options + 1] = AddOption("amudiao", "生命护符掉落", "死亡掉落生命护符", true)
configuration_options[#configuration_options + 1] = AddConfigOption("nillots", "置空一个物品栏", "死亡置空一个物品栏，用于给心脏", { { description = "On(开启)", data = 0, hover = "" }, { description = "Off(关闭)", data = 1, hover = "" } }, 0)
configuration_options[#configuration_options + 1] = AddOption("drown_drop", "落水掉落", "落水掉落东西", true)

---额外装备栏设置
configuration_options[#configuration_options + 1] = AddOptionHeader("额外装备栏设置")
configuration_options[#configuration_options + 1] = AddOption("extra_equip_slots", "额外装备栏设置总开关", "五格装备栏总开关", true)
--configuration_options[#configuration_options + 1] = AddConfigOption("render_strategy","渲染策略(Render Strategy)","同时装备护符和身体部位装备时，您希望渲染哪一个贴图？(When equip both amulet and body equipment, which do you want to render?)",{ { description = "默认(default)", data = "none", hover = "渲染最后装备的那个(Render the last equipment)" }, { description = "护符(amulet)", data = "neck", hover = "渲染护符贴图(Render amulet)" }, { description = "身体(body)", data = "body", hover = "渲染身体部位装备贴图(Render body equipment)" }, },"none")
configuration_options[#configuration_options + 1] = AddConfigOption("slots_num", "额外物品栏格子(Extra Item Slots)", "您想要多少额外的物品栏格子？(How many extra item slots do you want?)",
        { { description = "-10", data = -10 }, { description = "-5", data = -5 }, { description = "-4", data = -4 }, { description = "-3", data = -3 }, { description = "-2", data = -2 }, { description = "-1", data = -1 },
          { description = "默认(default)", data = 0 }, { description = "+1", data = 1 }, { description = "+2", data = 2 }, { description = "+3", data = 3 }, { description = "+4", data = 4 }, { description = "+5", data = 5 }, { description = "+10", data = 10 },
          { description = "+15", data = 15, hover = "可能会导致UI溢出(Maybe cause UI overflow)" }, { description = "+20", data = 20, hover = "可能会导致UI溢出(Maybe cause UI overflow)" }, }, 0)
configuration_options[#configuration_options + 1] = AddOption("backpack_slot", "额外背包格子(Extra Backpack Slot)", "你想要一个额外的背包格子吗？(Do you want an extra backpack slot?)", true)
configuration_options[#configuration_options + 1] = AddOption("amulet_slot", "额外护符格子(Extra Amulet Slot)", "你想要一个额外的护符格子吗？(Do you want an extra amulet slot?)", true)
configuration_options[#configuration_options + 1] = AddOption("compass_slot", "额外指南针格子(Extra Compass Slot)", "你想要一个额外的指南针格子吗？(Do you want an extra compass slot?)", false)
configuration_options[#configuration_options + 1] = AddOption("drop_hand_item_when_heavy", "负重时卸下手部装备(Drop Handitem)", "背起重物时，是否让你的手部装备被卸下？(Remove handitem when you carry heavy?)", true)
configuration_options[#configuration_options + 1] = AddOption("show_compass", "显示指南针(Show Compass)", "装备指南针时是否显示贴图(Show compass when equipped?)", true)
configuration_options[#configuration_options + 1] = AddOption("chesspiece_fix", "搬雕像渲染修复(Chesspiece Fix)", "修复可能出现的渲染错误(Fix some render problems)", true)
--configuration_options[#configuration_options + 1] = AddConfigOption("drop_bp_if_heavy","搬运重物时使用的格子","搬运重物时，您想使用哪个格子？",{ {description = "背包格子", data = true}, {description = "身体格子", data = false}, },false)
configuration_options[#configuration_options + 1] = AddConfigOption("slots_bg_length_adapter", "物品栏背景长度调整", "每大一点就会长一点点，每小一点就会短一点点", options_for_slots_bg, 0)
configuration_options[#configuration_options + 1] = AddConfigOption("slots_bg_length_adapter_no_bg", "去除物品栏背景", "去除物品栏背景", { { description = "去除", data = true }, { description = "不去除", data = false }, }, false)

---木牌传送设置
configuration_options[#configuration_options + 1] = AddOptionHeader("木牌传送设置")
configuration_options[#configuration_options + 1] = AddOption("fast_travel", "木牌传送-总开关", "设置是否开启木牌传送", false)

configuration_options[#configuration_options + 1] = AddOption("HomesignEnable", "原版木牌可传送", "设置原版木牌是否可传送", true)
configuration_options[#configuration_options + 1] = AddOption("NewWoodTravelSignEnable", "制作新的传送木牌", "设置可否制作新的传送木牌", false)
configuration_options[#configuration_options + 1] = AddConfigOption("set_wait_second", "设置等待时长", "修改传送时等待的时长（秒）", { { description = "直接传送", data = 0 }, { description = "1秒", data = 1 }, { description = "3秒", data = 3 }, { description = "5秒", data = 5, hover = "默认" }, }, 0)
configuration_options[#configuration_options + 1] = AddConfigOption("Hunger_Cost", "饥饿消耗", "修改传送时饥饿消耗倍率", { { description = "无消耗", data = 0 }, { description = "X0.25", data = 0.25 }, { description = "X1.0", data = 1 }, { description = "X2.0", data = 2 }, { description = "X4.0", data = 4 }, { description = "X8.0", data = 8 } }, 1)
configuration_options[#configuration_options + 1] = AddConfigOption("Sanity_Cost", "精神消耗", "修改传送时精神消耗倍率", { { description = "无消耗", data = 0 }, { description = "X0.25", data = 0.25 }, { description = "X1.0", data = 1 }, { description = "X2.0", data = 2 }, { description = "X4.0", data = 4 }, { description = "X8.0", data = 8 } }, 1)
configuration_options[#configuration_options + 1] = AddConfigOption("Ownership", "权限修改", "所有权限制?", { { description = "启用", data = true }, { description = "不可用", data = false } }, false)

---死亡复活按钮
configuration_options[#configuration_options + 1] = AddOptionHeader("死亡复活按钮设置")
configuration_options[#configuration_options + 1] = AddOption("death_resurrection_button", "死亡复活按钮-总开关", "设置是否开启死亡复活按钮", false)
configuration_options[#configuration_options + 1] = AddConfigOption("CD", "设置冷却时间", "", { { description = "0分钟", hover = "无CD", data = 0 }, { description = "1分钟", hover = "游戏中一天为8分钟", data = 60 }, { description = "2分钟", hover = "游戏中一天为8分钟", data = 120 }, { description = "4分钟", hover = "游戏中一天为8分钟", data = 240 }, { description = "8分钟", hover = "游戏中一天为8分钟", data = 480 }, { description = "12分钟", hover = "游戏中一天为8分钟", data = 720 }, { description = "2天", hover = "游戏中一天为8分钟", data = 960 }, { description = "3天", hover = "游戏中一天为8分钟", data = 1440 }, { description = "4天", hover = "游戏中一天为8分钟", data = 1920 } }, 0)
configuration_options[#configuration_options + 1] = AddConfigOption("Health_Penalty", "血量上限惩罚设置", "俗称黑血", { { description = "0%", hover = "无惩罚", data = 0 }, { description = "5%", hover = "5%", data = 0.05 }, { description = "15%", hover = "15%", data = 0.15 }, { description = "25%", hover = "25%", data = 0.25 }, { description = "35%", hover = "35%", data = 0.35 }, { description = "45%", hover = "45%", data = 0.45 }, { description = "55%", hover = "55%", data = 0.55 }, { description = "65%", hover = "65%", data = 0.65 }, { description = "75%", hover = "75%", data = 0.75 } }, 0)
configuration_options[#configuration_options + 1] = AddConfigOption("UI", "按钮位置", "", { { description = "中心点", hover = "中心点", data = "center" }, { description = "中心偏下", hover = "中心偏下", data = "center_offset_down" }, { description = "正上方", hover = "正上方", data = "right_above" }, { description = "左上角", hover = "左上角", data = "upper_left" }, { description = "左下角", hover = "左下角", data = "lower_left" } }, "center_offset_down")

---死亡复活重生指令
configuration_options[#configuration_options + 1] = AddOptionHeader("死亡复活重生指令设置")
configuration_options[#configuration_options + 1] = AddOption("restart_set", "死亡复活重生指令-总开关", "设置是否开启重生功能", false)
configuration_options[#configuration_options + 1] = AddOption("MOD_RESTART_ALLOW_RESTART", "重生", "", false)
configuration_options[#configuration_options + 1] = AddOption("MOD_RESTART_ALLOW_RESURRECT", "复活", "", true)
configuration_options[#configuration_options + 1] = AddOption("MOD_RESTART_ALLOW_KILL", "自杀", "", false)
configuration_options[#configuration_options + 1] = AddConfigOption("MOD_RESTART_CD_RESTART", "重生冷却(分)", "重生的冷却时间.", mod_restart_cd_options, 0)
configuration_options[#configuration_options + 1] = AddConfigOption("MOD_RESTART_CD_RESURRECT", "复活冷却(分)", "复活的冷却时间.", mod_restart_cd_options, 0)
configuration_options[#configuration_options + 1] = AddConfigOption("MOD_RESTART_CD_KILL", "自杀冷却(分)", "自杀的冷却时间.", mod_restart_cd_options, 0)
configuration_options[#configuration_options + 1] = AddConfigOption("MOD_RESTART_CD_BONUS", "冷却调整", "冷却时间随使用次数不断增加.", { { description = "关", data = 0, hover = "固定的冷却时间" },
                                                                                                                                         { description = "10%", data = 0.1, hover = "每次使用后增加(基础值的)10%" },
                                                                                                                                         { description = "20%", data = 0.2, hover = "每次使用后增加(基础值的)20%" },
                                                                                                                                         { description = "30%", data = 0.3, hover = "每次使用后增加(基础值的)30%" },
                                                                                                                                         { description = "40%", data = 0.4, hover = "每次使用后增加(基础值的)40%" },
                                                                                                                                         { description = "50%", data = 0.5, hover = "每次使用后增加(基础值的)50%" },
                                                                                                                                         { description = "100%", data = 1, hover = "每次使用后增加(基础值的)100%" },
                                                                                                                                         { description = "150%", data = 1.5, hover = "每次使用后增加(基础值的)150%" },
                                                                                                                                         { description = "200%", data = 2, hover = "每次使用后增加(基础值的)200%" }, }, 0)
configuration_options[#configuration_options + 1] = AddConfigOption("MOD_RESTART_CD_MAX", "最大冷却(分)", "开启冷却调整后累计可达到的最大冷却时间.", { { description = "无", data = 0, hover = "冷却无上限" },
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
                                                                                                                                                       { description = "180", data = 180, hover = "180 分钟" }, }, 0)
configuration_options[#configuration_options + 1] = AddConfigOption("MOD_RESTART_FORCE_DROP_MODE", "强制掉落道具", "重生是否强制掉落道具.", { { description = "默认", data = 0, hover = "默认" }, { description = "掉落", data = 1, hover = "重生强制掉落道具" }, { description = "不掉落", data = 2, hover = "重生强制不掉落道具" }, }, 1)
configuration_options[#configuration_options + 1] = AddConfigOption("MOD_RESTART_MAP_SAVE", "保留地图", "使用重生指令是否保留探索过的地图.", { { description = "开启(On)", data = 1, hover = "重生将会记住地图" },
                                                                                                                                               { description = "关闭(Off)", data = 2, hover = "重生失去所有地图的记忆" }, }, 1)
configuration_options[#configuration_options + 1] = AddConfigOption("MOD_RESTART_RESURRECT_HEALTH", "复活血量", "使用复活指令后恢复的血量.", { { description = "默认", data = 0, hover = "游戏默认\n(只剩 50 点血量)" },
                                                                                                                                               { description = "递减", data = 1, hover = "每次复活恢复的血量不断减少\n(最少为 40% 的血量)" },
                                                                                                                                               { description = "随机", data = 2, hover = "复活随机恢复血量\n(随机血量范围: 10% ~ 100%)" },
                                                                                                                                               { description = "100%", data = 100, hover = "固定恢复 100% 的血量" },
                                                                                                                                               { description = "90%", data = 90, hover = "固定恢复 90% 的血量" },
                                                                                                                                               { description = "80%", data = 80, hover = "固定恢复 80% 的血量" },
                                                                                                                                               { description = "70%", data = 70, hover = "固定恢复 70% 的血量" },
                                                                                                                                               { description = "60%", data = 60, hover = "固定恢复 60% 的血量" },
                                                                                                                                               { description = "50%", data = 50, hover = "固定恢复 50% 的血量" }, }, 80)
configuration_options[#configuration_options + 1] = AddConfigOption("MOD_RESTART_TRIGGER_MODE", "触发模式", "公聊或者私聊触发指令.", { { description = "公&私聊", data = 1 }, { description = "仅公聊", data = 2 }, { description = "仅私聊", data = 3 }, }, 1)
---智能小木牌
configuration_options[#configuration_options + 1] = AddOptionHeader("智能小木牌")
configuration_options[#configuration_options + 1] = AddOption("smart_minisign_switch", "智能小木牌-总开关", "设置是否开启智能小木牌", false)
configuration_options[#configuration_options + 1] = AddOption("Icebox", "冰箱(Icebox)", "Minisign for icebox/允许冰箱添加小木牌", false)
configuration_options[#configuration_options + 1] = AddOption("ChangeSkin", "换肤功能(ChangeSkin)", "Minisign can change skin\n允许小木牌切换皮肤", true)
configuration_options[#configuration_options + 1] = AddOption("DragonflyChest", "龙鳞宝箱(DragonflyChest)", "Minisign for DragonflyChest\n允许龙鳞箱子添加小木牌", false)
configuration_options[#configuration_options + 1] = AddOption("SaltBox", "盐盒(SaltBox)", "Minisign for SaltBox\n允许盐箱添加小木牌", false)
configuration_options[#configuration_options + 1] = AddOption("BundleItems", "包裹物品显示(BundleItems)", "Show the item in bundle/显示包裹里面的物品", false)
configuration_options[#configuration_options + 1] = AddOption("Digornot", "小木牌挖除(CanbeDug)", "Can be Dug/是否可以被挖", false)
---原版通用容器返鲜设置
configuration_options[#configuration_options + 1] = AddOptionHeader("原版通用容器返鲜设置")
configuration_options[#configuration_options + 1] = AddOption("common_container_preserve", "冰箱返鲜-总开关", "设置是否开原版通用容器返鲜功能", false)
configuration_options[#configuration_options + 1] = AddConfigOption("icebox_freeze", "腐烂速度", "", { { description = "正常腐烂", data = "0.5" },
                                                                                                       { description = "缓慢腐烂", data = "0.3" },
                                                                                                       { description = "保鲜", data = "0" },
                                                                                                       { description = "反鲜", data = "-5" }, }, "-5")
configuration_options[#configuration_options + 1] = AddConfigOption("krampus_sack_ice", "小偷包保鲜", "", { { description = "开启", data = true, hover = "小偷包保鲜,保鲜度同冰箱" },
                                                                                                            { description = "关闭", data = false }, }, false)
configuration_options[#configuration_options + 1] = AddConfigOption("backpack_ice", "背包保鲜", "", { { description = "开启", data = true, hover = "背包包保鲜,保鲜度同冰箱" },
                                                                                                      { description = "关闭", data = false }, }, false)
configuration_options[#configuration_options + 1] = AddConfigOption("piggyback_ice", "小猪包保鲜", "", { { description = "开启", data = true, hover = "小猪包保鲜,保鲜度同冰箱" },
                                                                                                         { description = "关闭", data = false }, }, false)
configuration_options[#configuration_options + 1] = AddConfigOption("saltlicker", "盐盒", "", { { description = "正常腐烂", data = 0.25 },
                                                                                                { description = "保鲜", data = 0 },
                                                                                                { description = "反鲜", data = -5 }, }, 0.25)
configuration_options[#configuration_options + 1] = AddConfigOption("mushroom_frige", "蘑菇灯保鲜", "", { { description = "正常腐烂", data = 0.25 },
                                                                                                          { description = "保鲜", data = 0 } }, 0)
configuration_options[#configuration_options + 1] = AddConfigOption("cage_frige", "骨灰盒保鲜", "", { { description = "开启", data = true, hover = "骨灰盒保鲜,保鲜度同冰箱" },
                                                                                                      { description = "关闭", data = false }, }, false)
configuration_options[#configuration_options + 1] = AddConfigOption("buyuqi_preserver", "捕鱼器保鲜", "", { { description = "开启", data = true, hover = "捕鱼器捕到鱼不会坏" },
                                                                                                            { description = "关闭", data = false }, }, false)

---快速工作设置
configuration_options[#configuration_options + 1] = AddOptionHeader("快速工作设置")
configuration_options[#configuration_options + 1] = AddOption("quick_work", "快速工作-总开关", "设置是否开启快速工作功能", false)
configuration_options[#configuration_options + 1] = AddOption("Pick", "采集类", "采集、捡起、收获", true)
configuration_options[#configuration_options + 1] = AddOption("BuildRepair", "建造修复类", "建造、装饰、绘画、修复、缝补、灭火", true)
configuration_options[#configuration_options + 1] = AddOption("HSHU", "三围升级类", "食用、治疗、学习、升级", true)

configuration_options[#configuration_options + 1] = AddOption("Farming", "农耕", "Drilling, Plant, Assess Happiness, Talk To, Research, Wax, Apply", true)

configuration_options[#configuration_options + 1] = AddConfigOption("RapidGrowth", "成长速率", "成长时间", {
    { description = "Only Farm Plant", data = 0 },
    { description = "Farm Plant And Weed", data = 1 },
    { description = "Only Farm Plant(Oversized)", data = 2 },
    { description = "Farm Plant(Oversized) And Weed", data = 3 },
    { description = "Off", data = 999 } }, 0)
configuration_options[#configuration_options + 1] = AddOption("Animal", "动物类", "抚摸、喂食、杀害、刷毛、刮毛", true)
configuration_options[#configuration_options + 1] = AddOption("Others", "其他动作", "其他动作加快", true)

configuration_options[#configuration_options + 1] = AddConfigOption("ChopTimes", "砍伐速率", "设置砍倒树木速率", { { description = "立刻", data = 0, hover = "默认" },
                                                                                                                    { description = "0.25x", data = 0.25 },
                                                                                                                    { description = "0.5x", data = 0.5 },
                                                                                                                    { description = "2x", data = 2 },
                                                                                                                    { description = "关闭", data = 999 }, }, 0)
configuration_options[#configuration_options + 1] = AddConfigOption("MineTime", "开采速率", "设置敲开矿物岩石速率", { { description = "立刻", data = 0, hover = "默认" },
                                                                                                                      { description = "0.25x", data = 0.25 },
                                                                                                                      { description = "0.5x", data = 0.5 },
                                                                                                                      { description = "2x", data = 2 },
                                                                                                                      { description = "关闭", data = 999 }, }, 0)
configuration_options[#configuration_options + 1] = AddOption("Cooking", "Cooking", "做饭调味", true)
configuration_options[#configuration_options + 1] = AddConfigOption("CookTime", "烹饪时间", "按照你设定的时间煮好食物", { { description = "立刻完成", data = 0 },
                                                                                                                          { description = "0.25x", data = 0.25, hover = "四分之一速度" },
                                                                                                                          { description = "0.5x", data = 0.5 },
                                                                                                                          { description = "1x", data = 1, hover = "不改变" },
                                                                                                                          { description = "2x", data = 2, hover = "2倍速度" }, }, 0)


configuration_options[#configuration_options + 1] = AddConfigOption("FishTime", "钓鱼时间", "钓鱼时鱼按你设置的时间上钩", { { description = "立刻上钩", data = 0, hover = "默认" },
                                                                                                                            { description = "5 秒", data = 5 },
                                                                                                                            { description = "关闭", data = 999 }, }, 0)
configuration_options[#configuration_options + 1] = AddConfigOption("QuickDry", "晾晒速率", "晾晒速率", { { description = "立刻", data = 0, hover = "默认" },
                                                                                                                      { description = "0.25x", data = 0.25 },
                                                                                                                      { description = "0.5x", data = 0.5 },
                                                                                                                      { description = "2x", data = 2 },
                                                                                                                      { description = "关闭", data = 999 }, }, 0)


---陷阱增强
configuration_options[#configuration_options + 1] = AddOptionHeader("陷阱增强")
configuration_options[#configuration_options + 1] = AddOption("trap_enhance", "陷阱增强-总开关", "设置是否开启陷阱增强功能", false)
configuration_options[#configuration_options + 1] = AddOption("stack", "狗牙陷阱可堆叠", "狗牙陷阱可堆叠", true)
configuration_options[#configuration_options + 1] = AddConfigOption("trap_uses", "狗牙陷阱耐久修改", "", { { description = "无修改(默认10次)", data = 0, hover = "默认" },
                                                                                                           { description = "2倍", data = 16 },
                                                                                                           { description = "8倍", data = 64 },
                                                                                                           { description = "32倍", data = 256 },
                                                                                                           { description = "无限", data = 9999999 }, }, 0)
configuration_options[#configuration_options + 1] = AddConfigOption("trap_teeth_damage", "狗牙陷阱伤害修改", "尽量不要修改哦，小心丧失游戏乐趣~", { { description = "无修改(默认60)", data = 0, hover = "默认" },
                                                                                                                                                   { description = "2倍(120)", data = 120 },
                                                                                                                                                   { description = "4倍(240)", data = 240 },
                                                                                                                                                   { description = "8倍(480)", data = 480 },
                                                                                                                                                   { description = "999", data = 999 }, }, 0)
configuration_options[#configuration_options + 1] = AddConfigOption("radius", "狗牙陷阱攻击范围", "", { { description = "无变化", data = 1 },
                                                                                                        { description = "2倍", data = 2 },
                                                                                                        { description = "3倍", data = 3 },
                                                                                                        { description = "4倍", data = 4 },
                                                                                                        { description = "8倍", data = 8 }, }, 1)
configuration_options[#configuration_options + 1] = AddConfigOption("reset", "狗牙陷阱自动重置", "", { { description = "是", data = 1 },
                                                                                                       { description = "否", data = 0 }, }, 1)
configuration_options[#configuration_options + 1] = AddConfigOption("time", "狗牙陷阱自动重置时间", "", { { description = "0.2秒", data = 0.2 },
                                                                                                          { description = "0.5秒", data = 0.5 },
                                                                                                          { description = "1秒", data = 1 },
                                                                                                          { description = "2秒", data = 2 },
                                                                                                          { description = "3秒", data = 3 },
                                                                                                          { description = "4秒", data = 4 }, }, 2)

configuration_options[#configuration_options + 1] = AddOptionHeader(" ")
configuration_options[#configuration_options + 1] = AddOption("stack_j", "荆棘陷阱可堆叠", "荆棘陷阱可堆叠", true)
configuration_options[#configuration_options + 1] = AddConfigOption("trap_uses_j", "荆棘陷阱耐久修改", "", { { description = "无修改(默认10次)", data = 0, hover = "默认" },
                                                                                                             { description = "2倍", data = 16 },
                                                                                                             { description = "8倍", data = 64 },
                                                                                                             { description = "32倍", data = 256 },
                                                                                                             { description = "无限", data = 9999999 }, }, 0)
configuration_options[#configuration_options + 1] = AddConfigOption("trap_bramble_damage", "荆棘陷阱伤害修改", "尽量不要修改哦，小心丧失游戏乐趣~", { { description = "无修改(默认40)", data = 0, hover = "默认" },
                                                                                                                                                     { description = "2倍(80)", data = 80 },
                                                                                                                                                     { description = "4倍(160)", data = 160 },
                                                                                                                                                     { description = "8倍(320)", data = 320 },
                                                                                                                                                     { description = "999", data = 999 }, }, 0)
configuration_options[#configuration_options + 1] = AddConfigOption("radius_j", "荆棘陷阱攻击范围", "", { { description = "无变化", data = 1 },
                                                                                                          { description = "2倍", data = 2 },
                                                                                                          { description = "3倍", data = 3 },
                                                                                                          { description = "4倍", data = 4 },
                                                                                                          { description = "8倍", data = 8 }, }, 1)
configuration_options[#configuration_options + 1] = AddConfigOption("reset_j", "荆棘陷阱自动重置", "", { { description = "是", data = 1 }, { description = "否", data = 0 }, }, 1)
configuration_options[#configuration_options + 1] = AddConfigOption("time_j", "荆棘陷阱自动重置时间", "", { { description = "0.2秒", data = 0.2 },
                                                                                                            { description = "0.5秒", data = 0.5 },
                                                                                                            { description = "1秒", data = 1 },
                                                                                                            { description = "2秒", data = 2 },
                                                                                                            { description = "3秒", data = 3 },
                                                                                                            { description = "4秒", data = 4 }, }, 2)

configuration_options[#configuration_options + 1] = AddOptionHeader(" ")
configuration_options[#configuration_options + 1] = AddOption("attack_player_h", "海星陷阱不攻击玩家", "设置海信陷阱是否攻击玩家", false)
configuration_options[#configuration_options + 1] = AddConfigOption("trap_starfish_damage", "海星陷阱伤害修改", "尽量不要修改哦，小心丧失游戏乐趣~", { { description = "无修改(默认60)", data = 0, hover = "默认" },
                                                                                                                                                      { description = "2倍(120)", data = 120 },
                                                                                                                                                      { description = "4倍(240)", data = 240 },
                                                                                                                                                      { description = "8倍(480)", data = 480 },
                                                                                                                                                      { description = "999", data = 999 }, }, 0)
configuration_options[#configuration_options + 1] = AddConfigOption("radius_h", "海星陷阱攻击范围", "", { { description = "无变化", data = 0 },
                                                                                                          { description = "2倍", data = 2.8 },
                                                                                                          { description = "3倍", data = 4.2 },
                                                                                                          { description = "4倍", data = 5.6 },
                                                                                                          { description = "8倍", data = 11.2 }, }, 0)
configuration_options[#configuration_options + 1] = AddConfigOption("reset_h", "海星陷阱重置时间", "", { { description = "无变化", data = 0 },
                                                                                                         { description = "0.2秒", data = 0.2 },
                                                                                                         { description = "0.5秒", data = 0.5 },
                                                                                                         { description = "1秒", data = 1 },
                                                                                                         { description = "2秒", data = 2 },
                                                                                                         { description = "3秒", data = 3 },
                                                                                                         { description = "5秒", data = 4 }, }, 0)

---Show me
configuration_options[#configuration_options + 1] = AddOptionHeader("Show me")
configuration_options[#configuration_options + 1] = AddOption("show_me_switch", "show me-开关", "是否开启show me", false)
configuration_options[#configuration_options + 1] = AddConfigOption("show_me_lang", "语言(Language)", "", { { description = "Auto(自动)", data = "auto", hover = "Detect Language Pack(检测语言包)" },
                                                                                                            { description = "en(英语)", data = "en", hover = "English(英语)" },
                                                                                                            { description = "ru(俄语)", data = "ru", hover = "Russian(俄语)" },
                                                                                                            { description = "chs(简体中文)", data = "chs", hover = "Simplified Chinese(简体中文)" },
                                                                                                            { description = "cht(繁体中文)", data = "cht", hover = "Traditional Chinese(繁体中文)" },
                                                                                                            { description = "br(葡萄牙语)", data = "br", hover = "Brazilian Portuguese(葡萄牙语)" },
                                                                                                            { description = "pl(波兰语)", data = "pl", hover = "Polish(波兰语)" },
                                                                                                            { description = "kr(韩语)", data = "kr", hover = "Korean(韩语)" },
                                                                                                            { description = "es(西班牙语)", data = "es", hover = "Spanish(西班牙语)" }, }, "auto")
--[[AddConfigOption("message_style", "Style", "", {
    {description = "Isolation ->", data = 1},
    {description = "isolation ->", data = 2},
    {description = "Isol ->", data = 3},
    {description = "isol ->", data = 4},
    {description = "<- Warm", data = 5},
    {description = "<- warm", data = 6},
},1),]]
configuration_options[#configuration_options + 1] = AddConfigOption("food_style", "食物信息显示风格(Food Style)", "", { { description = "默认(undefined)", data = 0, hover = "Default is \"long\"\n默认是 \"详细\"" },
                                                                                                                        { description = "详细(long)", data = 1, hover = "Hunger: +12.5 / Sanity: -10 / Health: +3\n饥饿: +12.5 / 精神: -10 / 生命: +3" },
                                                                                                                        { description = "简洁(short)", data = 2, hover = "+12.5 / -10 / +3" }, }, 0)
configuration_options[#configuration_options + 1] = AddConfigOption("food_order", "食物属性显示顺序(Food Properties Order)", "", { { description = "默认(undefined)", data = 0, hover = "Default if \"interface\"\n默认是 \"标准\"" },
                                                                                                                                   { description = "标准(Interface)", data = 1, hover = "Hunger / Sanity / Health\n饥饿 / 精神 / 生命" },
                                                                                                                                   { description = "自定(Wikia)", data = 2, hover = "Health / Hunger / Sanity\n生命 / 饥饿 / 精神" }, }, 0)
configuration_options[#configuration_options + 1] = AddConfigOption("food_estimation", "过期时间(Estimate Stale Status)", "Should we estimate the stale status?(要不要估算过期时间)", { { description = "默认(Undefined)", data = -1, hover = "Yes, and users may override this option.(是)" },
                                                                                                                                                                                        { description = "否(No)", data = 0, hover = "No, but users may override this option.(否)" },
                                                                                                                                                                                        { description = "是(Yes)", data = 1, hover = "Yes, but users may override this option.(是)" }, }, -1)
configuration_options[#configuration_options + 1] = AddConfigOption("show_food_units", "显示食物的食物属性单位(Show Food Units)", "For example, units of meat, units of veggie etc.\n(例如肉度，菜度)", { { description = "默认(undefined)", data = -1, hover = "Yes, and users may override this option.(是)" },
                                                                                                                                                                                                         { description = "否(No)", data = 0, hover = "No, but users may override this option.(否)" },
                                                                                                                                                                                                         { description = "是(Yes)", data = 1, hover = "Yes, but users may override this option.(是)" },
                                                                                                                                                                                                         { description = "禁止(Forbidden)", data = 2, hover = "Server won't send food info to clients and their settings will not matter.\n服务端不会发送属性信息给客户端" }, }, -1)
configuration_options[#configuration_options + 1] = AddConfigOption("show_uses", "显示工具用途(Show Tools Uses)", "", { { description = "默认(undefined)", data = -1, hover = "Yes, and users may override this option.(是)" },
                                                                                                                        { description = "否(No)", data = 0, hover = "No, but users may override this option.(否)" },
                                                                                                                        { description = "是(Yes)", data = 1, hover = "Yes, but users may override this option.(是)" },
                                                                                                                        { description = "禁止(Forbidden)", data = 2, hover = "Server won't send this info to the clients and their settings will not matter.\n服务端不会发送属性信息给客户端" }, }, -1)

configuration_options[#configuration_options + 1] = AddConfigOption("show_nutrients", "显示肥料值", "", {{description = "关闭", data = false, hover = ""},
                                                                                                   	{description = "详细", data = 1, hover = "催长剂: 8 / 堆肥: 8 / 粪肥: 32"},
                                                                                                   	{description = "简洁", data = 2, hover = "肥料: 8 / 8 / 32"},}, 1)



configuration_options[#configuration_options + 1] = AddConfigOption("display_hp", "显示血量(Display HP)", "", { { description = "Auto(自动)", data = -1, hover = "Depends on installed mods.(取决于安装的模组)" },
                                                                                                                { description = "No(否)", data = 0, hover = "No, but users may override this option.(否，但用户可以覆盖此选项。)" },
                                                                                                                { description = "Yes(是)", data = 1, hover = "Yes, but users may override this option.(是，但用户可以覆盖此选项。)" },
                                                                                                                { description = "Forbidden(禁止)", data = 2, hover = "Server won't send this info to the clients and their settings will not matter.(服务端将不会发送属性信息给客户端)" }, }, -1)
configuration_options[#configuration_options + 1] = AddConfigOption("show_fueled", "穿戴装备天数", "", {{description = "关闭", data = false, hover = "不显示"},
                                                                                                 	{description = "时间", data = 1, hover = "耐久: 1:19"},
                                                                                                 	{description = "天数", data = 2, hover = "耐久: 6.8 天"},
                                                                                                 	{description = "两者", data = 3, hover = "耐久: 3:59 ( 0.5 天 )"},}, 3)
configuration_options[#configuration_options + 1] = AddConfigOption("show_fuel", "物品燃料值", "", {{description = "关闭", data = false, hover = "关闭后火堆的燃烧效率也将隐藏"},
                                                                                              	{description = "开启", data = true, hover = "燃料值: 0:30"},}, true)

configuration_options[#configuration_options + 1] = AddConfigOption("show_planar_resist", "显示位面抵抗", "在显示工具、武器攻击附加显示位面抵抗造成的伤害", {{description = "关闭", data = false, hover = "关闭后生物上显示“拥有位面抵抗”也将隐藏"},
                                                                                                                               		{description = "开启", data = true, hover = "攻击力: 68 ( 位抗: 41.3 )"},}, true)

configuration_options[#configuration_options + 1] = AddOption("T_crop", "农作物状态显示", "例如缺肥料、水分、家族、有杂草等，成长计时不受影响", true)
--AddConfigOption("naughtiness", "顽皮值", "", {
--    { description = "禁用", data = 0 },
--    { description = "", data = 1 },
--    { description = "", data = 2 },
--}, 0),
configuration_options[#configuration_options + 1] = AddConfigOption("show_buddle_item", "显示捆绑包物(品show bundle item)", "", { { description = "显示(YES)", data = 1 }, { description = "不显示(NO)", data = 0 }, }, 1)
configuration_options[#configuration_options + 1] = AddConfigOption("item_info_mod", "兼容item info模组(compatible with item info)", "如果打开，Show me将不显示与item info相同的信息", { { description = "关闭(OFF)", data = 0 }, { description = "开启(ON)", data = 1 }, }, 0)

---容器拥有物品高亮显示
configuration_options[#configuration_options + 1] = AddOptionHeader("容器拥有物品高亮显示")
configuration_options[#configuration_options + 1] = AddOption("container_high_light_switch", "总开关", "容器拥有物品高亮显示总开关", false)
configuration_options[#configuration_options + 1] = AddConfigOption("chestR", "参数-红(Red)", "This is red component of highlighted chests color.\n默认绿色，如果红绿蓝都设置为0%或100%，箱子就没有颜色", color_options, -1)
configuration_options[#configuration_options + 1] = AddConfigOption("chestG", "参数-绿(Green)", "This is green component of highlighted chests color.\n默认绿色，如果红绿蓝都设置为0%或100%，箱子就没有颜色", color_options, -1)
configuration_options[#configuration_options + 1] = AddConfigOption("chestB", "参数-蓝(Blue)", "This is blue component of highlighted chests color.\n默认绿色，如果红绿蓝都设置为0%或100%，箱子就没有颜色", color_options, -1)
---信息显示
configuration_options[#configuration_options + 1] = AddOptionHeader("信息显示")
configuration_options[#configuration_options + 1] = AddOption("cap_show_info_switch", "总开关", "物体信息详情显示总开关，开启此则show me不生效", false)
configuration_options[#configuration_options + 1] = AddConfigOption("showanim", "显示物品动画信息", "", { { description = "显示", data = true }, { description = "不显示", data = false }, }, false)
configuration_options[#configuration_options + 1] = AddConfigOption("showtype", "显示边框颜色", "", show_info_edge_color_options, 1)
configuration_options[#configuration_options + 1] = AddConfigOption("show_info_bg", "显示背景", "", { { description = "显示", data = true, hover = "会显示背景及边框" }, { description = "不显示", data = false, hover = "不会显示背景及边框" }, }, false)
---全图定位
configuration_options[#configuration_options + 1] = AddOptionHeader("全图定位")
configuration_options[#configuration_options + 1] = AddOption("global_position_switch", "全图定位-开关", "是否开启全图定位", false)
configuration_options[#configuration_options + 1] = AddConfigOption("GLOBAL_POSITION_LANG", "语言(language)", "选择你想要使用的语言.", { {description = "English(英语)", data = "en", hover = ""}, {description = "中文(Chinese)", data = "zh", hover = ""}, {description = "自动", data = "auto", hover = "根据游戏语言自动设置"},}, "auto")
configuration_options[#configuration_options + 1] = AddConfigOption("SHOWPLAYERSOPTIONS", "玩家指示器(Player Indicators)", "The arrow things that show players past the edge of the screen.", { { description = "Always", data = 3 }, { description = "Scoreboard", data = 2 }, { description = "Never", data = 1 }, }, 2)
configuration_options[#configuration_options + 1] = AddConfigOption("SHOWPLAYERICONS", "玩家图标(Player Icons)", "The player icons on the map.", { { description = "显示(Show)", data = true }, { description = "隐藏(Hide)", data = false }, }, true)
configuration_options[#configuration_options + 1] = AddConfigOption("FIREOPTIONS", "火堆指示器(Show Fires)", "Show fires with indicators like players." .. "\nThey will smoke when they are visible this way.", { { description = "Always", data = 1 }, { description = "Charcoal", data = 2 }, { description = "Disabled", data = 3 }, }, 2)
configuration_options[#configuration_options + 1] = AddConfigOption("SHOWFIREICONS", "火堆图标(Fire Icons)", "Show fires globally on the map (this will only work if fires are set to show)." .. "\nThey will smoke when they are visible this way.", { { description = "显示(Show)", data = true }, { description = "隐藏(Hide)", data = false }, }, true)
configuration_options[#configuration_options + 1] = AddOption("SHAREMINIMAPPROGRESS", "共享地图(Share Map)", "Share map exploration between players. This will only work if" .. "\n'Player Indicators' and 'Player Icons' are not both disabled.", true)
configuration_options[#configuration_options + 1] = AddOption("REMOVE_GHOST_ICONS", "移除残影", "玩家移动过快，跟随玩家的伯尼或者皮弗娄牛会在地图上留下残影，开启本选项来消除残影.", true)
configuration_options[#configuration_options + 1] = AddOption("STOPSAVEMAPEXPLORER", "减少卡顿", "实验性功能，尝试减少上下洞穴时的卡顿。通过修改人物存档来实现，我不确定这是否安全.", true)
configuration_options[#configuration_options + 1] = AddConfigOption("UPDADTEFREQUENCY", "共享地图时间间隔", "共享地图的时间间隔, 增加该间隔可能可以减少服务器的负担.", { {description = "5", data = 5}, {description = "2", data = 2}, {description = "0.5", data = 0.5},}, 5)
configuration_options[#configuration_options + 1] = AddOption("OVERRIDEMODE", "荒野覆盖(Wilderness Override)", "If enabled, it will use the other options you set in Wilderness mode." .. "\nOtherwise, it will not show players, but all fires will smoke and be visible.", false)
configuration_options[#configuration_options + 1] = AddOption("ENABLEPINGS", "点位标记(Pings)", "Whether to allow players to ping (alt+click) the map.", true)
--configuration_options[#configuration_options + 1] = AddOption("map_on_Cartography", "在制图桌上共享地图", "", false)

---指南针
configuration_options[#configuration_options + 1] = AddOptionHeader("指南针")
configuration_options[#configuration_options + 1] = AddOption("compass_switch", "总开关", "建议全图定位只开ping,然后开启本功能,优化全图定位的后期卡顿", false)
configuration_options[#configuration_options + 1] = AddConfigOption("compass_refresh_interval", "刷新间隔", "", { { description = "0", data = 0 }, { description = "0.1", data = 0.1 }, { description = "0.2", data = 0.2 }, { description = "0.5", data = 0.5 }, { description = "1", data = 1 }, { description = "2", data = 2 }, { description = "5", data = 5 } }, 0.2)
---蘑菇农场
configuration_options[#configuration_options + 1] = AddOptionHeader("蘑菇农场")
configuration_options[#configuration_options + 1] = AddOption("improve_mushroom_planters_switch", "蘑菇农场增强-开关", "是否开启蘑菇农场增强", false)
configuration_options[#configuration_options + 1] = AddConfigOption("max_harvests", "Maximum Fertilization(最大收获数量)", "Maximum amount of fertilizer value the planter can store. Living logs restore this many harvests.", { { description = "Unlimited", data = -1, hover = "Default, but never decrease" }, { description = "Default", data = 0, hover = "4 unless modded" }, { description = "8", data = 8, hover = "8 harvests" }, { description = "16", data = 16, hover = "16 harvests" }, { description = "32", data = 32, hover = "32 harvests" }, }, 0)
configuration_options[#configuration_options + 1] = AddConfigOption("easy_fert", "Allow Fertilizers(允许使用肥料)", "If fertilizers can be used in place of living logs", { { description = "No", data = false, hover = "Living logs only" }, { description = "Yes", data = true, hover = "Fertilizes by the sum of all nutrients divided by 8" }, }, false)
configuration_options[#configuration_options + 1] = AddConfigOption("snow_grow", "Grow When Snow-covered(被雪覆盖是否允许生长)", "Whether to continue growing in winter or pause growth until snow melts", { { description = "No", data = false, hover = "Pause growth" }, { description = "Yes", data = true, hover = "Keep growing" }, }, false)
configuration_options[#configuration_options + 1] = AddConfigOption("moon_ok", "Allow Moon Shrooms(月亮蘑菇可种植)", "Should planters accept moon shrooms? Doesn't effect lunar spores.", { { description = "No", data = false, hover = "Don't accept moon shrooms" }, { description = "Yes", data = true, hover = "Accept moon shrooms" }, }, true)
configuration_options[#configuration_options + 1] = AddConfigOption("moon_spore", "Catchable Lunar Spores(可捕捉月孢子)", "Lunar spores can be caught with a bug net and used in a planter. What could go wrong?", { { description = "No", data = false, hover = "Spores just explode, as usual" }, { description = "Yes", data = true, hover = "Spores can be caught and planted" }, }, false)
---龙鳞冰炉
configuration_options[#configuration_options + 1] = AddOptionHeader("龙鳞冰炉")
configuration_options[#configuration_options + 1] = AddOption("ice_furnace_switch", "龙鳞冰炉制作-开关", "是否可以制作龙鳞冰炉", false)
configuration_options[#configuration_options + 1] = AddConfigOption("lang", "Language/语言", "The language you prefer to display the information related to Ice Furnaces" .. "\n你想要的用来显示冰炉相关信息的语言", { { description = "English", data = true, hover = "Information related to Ice Furnaces will be displayed in English" }, { description = "中文", data = false, hover = "将用中文来显示龙鳞冰炉的相关信息" }, }, false)

configuration_options[#configuration_options + 1] = AddConfigOption("temp", "Heat Control/调温", "Whether the Ice Furnace automatically adjust the heat" .. "\n冰炉是否自动调温", { { description = "Yes/是", data = true, hover = "The Ice Furnace does not cause undercooling/冰炉不会导致过冷" }, { description = "No/否", data = false, hover = "The Ice Furnace keeps the strongest heat/冰炉保持最低温" }, }, false)

configuration_options[#configuration_options + 1] = AddConfigOption("light_range", "Light Range/光照范围", "The light range of Ice Furnaces" .. "\n龙鳞冰炉的光照范围", { { description = "Default/默认", data = 1, hover = "1 unit of light range\n1个单位的光照范围" },
                                                                                                                                                                          { description = "2.5", data = 2.5, hover = "2.5 units of light range\n2.5个单位的光照范围" },
                                                                                                                                                                          { description = "5", data = 5, hover = "5 units of light range\n5个单位的光照范围" },
                                                                                                                                                                          { description = "7.5", data = 7.5, hover = "7.5 units of light range\n7.5个单位的光照范围" },
                                                                                                                                                                          { description = "10", data = 10, hover = "10 units of light range\n10个单位的光照范围" }, }, 1)

configuration_options[#configuration_options + 1] = AddConfigOption("container_slot", "Number of slots/容器格数", "The size of the container" .. "\n容器的空间大小", { { description = "None/无容器", data = 0, hover = "No container for Ice Furnaces\n冰炉不具备容器功能" },
                                                                                                                                                                       { description = "3 x 1", data = 3, hover = "Container contains 3 slots\n容器拥有3格空间" },
                                                                                                                                                                       { description = "3 x 2", data = 6, hover = "Container contains 6 slots\n容器拥有6格空间" },
                                                                                                                                                                       { description = "3 x 3", data = 9, hover = "Container contains 9 slots\n容器拥有9格空间" },
                                                                                                                                                                       { description = "3 x 4", data = 12, hover = "Container contains 12 slots\n容器拥有12格空间" },
                                                                                                                                                                       { description = "3 x 5", data = 15, hover = "Container contains 15 slots\n容器拥有15格空间" }, }, 3)

configuration_options[#configuration_options + 1] = AddConfigOption("fresh_rate", "Preservation Rate/保存速率", "The preservation rate of the container" .. "\n龙鳞冰炉的保鲜能力", { { description = "Default/默认", data = 1, hover = "Ice furnaces do not provide preservation effect\n冰炉不提供保鲜效果" },
                                                                                                                                                                                      { description = "0.5", data = 0.5, hover = "Items inside spoil 2 times slower\n2倍保鲜" },
                                                                                                                                                                                      { description = "0.25", data = 0.25, hover = "Items inside spoil 4 times slower\n4倍保鲜" },
                                                                                                                                                                                      { description = "0", data = 0, hover = "Items inside do not spoil\n永久保鲜" },
                                                                                                                                                                                      { description = "-0.25", data = -0.25, hover = "Items inside restore freshness at a rate of 0.25\n0.25倍反鲜" },
                                                                                                                                                                                      { description = "-0.5", data = -0.5, hover = "Items inside restore freshness at a rate of 0.5\n0.5倍反鲜" },
                                                                                                                                                                                      { description = "-1", data = -1, hover = "Items inside restore freshness at a rate of 1\n一倍反鲜" },
                                                                                                                                                                                      { description = "-2", data = -2, hover = "Items inside restore freshness at a rate of 2\n两倍反鲜" },
                                                                                                                                                                                      { description = "-4", data = -4, hover = "Items inside restore freshness at a rate of 4\n四倍反鲜" }, }, 0)

configuration_options[#configuration_options + 1] = AddConfigOption("produce_ice", "Ice Production Interval/产冰间隔", "The frequency of the ice production" .. "\n冰炉生产冰的频率", { { description = "5s", data = 5, hover = "Produce one piece of ice every 5 seconds\n每5秒生产一块冰" },
                                                                                                                                                                                        { description = "15s", data = 15, hover = "Produce one piece of ice every 15 seconds\n每15秒生产一块冰" },
                                                                                                                                                                                        { description = "30s", data = 30, hover = "Produce one piece of ice every 30 seconds\n每30秒生产一块冰" },
                                                                                                                                                                                        { description = "60s", data = 60, hover = "Produce one piece of ice every 60 seconds\n每60秒生产一块冰" },
                                                                                                                                                                                        { description = "120s", data = 120, hover = "Produce one piece of ice every 120 seconds\n每120秒生产一块冰" },
                                                                                                                                                                                        { description = "240s", data = 240, hover = "Produce one piece of ice every 240 seconds\n每240秒生产一块冰" },
                                                                                                                                                                                        { description = "480s", data = 480, hover = "Produce one piece of ice every 480 seconds\n每480秒生产一块冰" },
                                                                                                                                                                                        { description = "No Ice/不生产", data = 99999, hover = "No Ice Production\n不生产冰" }, }, 240)

configuration_options[#configuration_options + 1] = AddConfigOption("way_to_obtain", "Way to Obtain/获得途径", "The way to obtain Ice Furnaces" .. "\n获得龙鳞冰炉的途径", { { description = "Staff/法杖", data = 1, hover = "Get Ice Furnaces by consuming Ice Staffs/通过消耗冰冻法杖获得冰炉" },
                                                                                                                                                                             { description = "Switch/切换", data = 2, hover = "Get Ice Furnaces by switching Scaled Furnaces/将火炉切换为冰炉" },
                                                                                                                                                                             { description = "Blueprint/蓝图", data = 3, hover = "Build Ice Furnaces by learning blueprint/通过学习蓝图来建造冰炉" }, }, 1)

---小穹补丁
configuration_options[#configuration_options + 1] = AddOptionHeader("小穹补丁")
configuration_options[#configuration_options + 1] = AddOption("sora_patches_switch", "小穹补丁-总开关", "是否开启小穹补丁", false)
configuration_options[#configuration_options + 1] = AddConfigOption("soraRemoveDeathExpByLevel", "减免死亡惩罚", "穹一定等级后死亡不掉落经验", { { description = "不改变", data = -1 },
                                                                                                                                                 { description = "1级", data = 1 },
                                                                                                                                                 { description = "5级", data = 5 },
                                                                                                                                                 { description = "10级", data = 10 },
                                                                                                                                                 { description = "15级", data = 15 },
                                                                                                                                                 { description = "20级", data = 20 },
                                                                                                                                                 { description = "25级", data = 25 },
                                                                                                                                                 { description = "30级", data = 30 }, }, 20)

configuration_options[#configuration_options + 1] = AddConfigOption("soraRemoveRollExpByLevel", "减免换人惩罚", "穹一定等级后换人不掉落经验", { { description = "不改变", data = -1 },
                                                                                                                                                { description = "1级", data = 1 },
                                                                                                                                                { description = "5级", data = 5 },
                                                                                                                                                { description = "10级", data = 10 },
                                                                                                                                                { description = "15级", data = 15 },
                                                                                                                                                { description = "20级", data = 20 },
                                                                                                                                                { description = "25级", data = 25 },
                                                                                                                                                { description = "30级", data = 30 }, }, 20)
--configuration_options[#configuration_options + 1] = AddConfigOption("soraExp", "去除经验惩罚", "升级更容易", optionsYesNo, true)
configuration_options[#configuration_options + 1] = AddConfigOption("soraHealDeath", "愈还原", "鞭尸\n是：还原 否：不改变", optionsYesNo, false)

configuration_options[#configuration_options + 1] = AddConfigOption("soraRepairerToPhilosopherStoneLimit", "限制缝纫包修贤者宝石", "", { { description = "不改变", data = 0 },
                                                                                                                                         { description = "修0.5%", data = 0.005 },
                                                                                                                                         { description = "修1%", data = 0.01 },
                                                                                                                                         { description = "修2%", data = 0.02 },
                                                                                                                                         { description = "修5%", data = 0.05 },
                                                                                                                                         { description = "修10%", data = 0.1 },
                                                                                                                                         { description = "修20%", data = 0.2 }, }, 0.01)
configuration_options[#configuration_options + 1] = AddConfigOption("soraFastMaker", "制作速度更快", "装备荣誉勋章或穹与巧手勋章可以提高制作速度！穹30级进一步提高。\n是：提高 否：不提高", optionsYesNo, true)
configuration_options[#configuration_options + 1] = AddConfigOption("soraDoubleMaker", "一定等级解锁双倍制作", "平行世界里偷不算偷！", { { description = "不改变", data = -1 },
                                                                                                                                        { description = "一开始", data = 0 },
                                                                                                                                        { description = "5级", data = 5 },
                                                                                                                                        { description = "10级", data = 10 },
                                                                                                                                        { description = "15级", data = 15 },
                                                                                                                                        { description = "20级", data = 20 },
                                                                                                                                        { description = "25级", data = 25 },
                                                                                                                                        { description = "30级", data = 30 },
                                                                                                                                        { description = "50级", data = 50 },
                                                                                                                                        { description = "100级", data = 100 }, }, 30)
configuration_options[#configuration_options + 1] = AddConfigOption("soraPackLimit", "限制打包", "禁止穹打包一些独有的东西，比如猪王等", optionsYesNo, true)
configuration_options[#configuration_options + 1] = AddConfigOption("soraPackFL", "打包风铃草", "初始自动打包风铃\n是：打包 否：不打包，全图找", optionsYesNo, true)
--configuration_options[#configuration_options + 1] = AddConfigOption("sorafl_select", "风铃草自选", "绑定风铃草时可以自选装备(小穹mod)", optionsYesNo, false)
--configuration_options[#configuration_options + 1] = AddConfigOption("sora_level_broke_through", "小穹突破等级上限", "小穹不只是30级了可以玩到100级咯", optionsYesNo, false)
---魔女之旅补丁
configuration_options[#configuration_options + 1] = AddOptionHeader("魔女之旅补丁")
configuration_options[#configuration_options + 1] = AddOption("elaina_patches_switch", "魔女补丁总开关", "是否开启魔女补丁", false)
configuration_options[#configuration_options + 1] = AddOption("elaina_additional_skin_switch", "魔女额外皮肤", "是否开启魔女额外皮肤", false)
configuration_options[#configuration_options + 1] = AddConfigOption("ban_brooch", "禁用专属胸针", "禁用伊蕾娜专属胸针(都乖乖舔老师去)", optionsYesNo, false)
configuration_options[#configuration_options + 1] = AddConfigOption("ban_most_brooch", "禁用最强胸针", "禁用伊蕾娜的最强胸针", optionsYesNo, false)
configuration_options[#configuration_options + 1] = AddConfigOption("elaina_start_monv_favorite_limit", "送老师好感物品上限", "单个物品好感上限，防止开挂！！舔老师过快", { { description = "不限制", data = -1, },
                                                                                                                                                                         { description = "5", data = 5, },
                                                                                                                                                                         { description = "10", data = 10, },
                                                                                                                                                                         { description = "12", data = 12, },
                                                                                                                                                                         { description = "20", data = 20, },
                                                                                                                                                                         { description = "30", data = 30, },
                                                                                                                                                                         { description = "40", data = 40, },
                                                                                                                                                                         { description = "50", data = 50, },
                                                                                                                                                                         { description = "100", data = 100, },
                                                                                                                                                                         { description = "200", data = 200, },
                                                                                                                                                                         { description = "300", data = 300, },
                                                                                                                                                                         { description = "500", data = 500, } }, 50)
---夜雨空心补丁
configuration_options[#configuration_options + 1] = AddOptionHeader("夜雨空心补丁")
configuration_options[#configuration_options + 1] = AddOption("yeyu_nilxin_patches_switch", "夜雨空心补丁总开关", "是否开启夜雨空心补丁", false)
configuration_options[#configuration_options + 1] = AddConfigOption("yeyu_ruqin", "夜雨空心入侵调整", "入侵生物一段时间消失 地图范围外消失 防止小房子周围刷", { { description = "否", data = false },
                                                                                                                                                                { description = "不消失", data = -1, hover = "地图范围外仍然消失" },
                                                                                                                                                                { description = "马上消失 主世界可用", data = 0, hover = "建议主世界设置" },
                                                                                                                                                                { description = "1天", data = 1 },
                                                                                                                                                                { description = "1.5天", data = 1.5 },
                                                                                                                                                                { description = "2天", data = 2, },
                                                                                                                                                                { description = "3天", data = 3, }, }, -1)
configuration_options[#configuration_options + 1] = AddOption("yeyu_nilxin_pack_limit", "夜雨空心打包限制", "是否限制打包物品(共物品不允许打包)", false)
configuration_options[#configuration_options + 1] = AddOption("xiuxian_patches", "夜雨空心 修仙额外", "限制了一些修仙武器可以放入魔杖", false)
configuration_options[#configuration_options + 1] = AddConfigOption("yeyu_nilxin_jump_distance_limit", "夜雨心空跳跃限制", "限制夜雨心空的跳跃距离", { { description = "不限制", data = -1, },
                                                                                                                                                       { description = "原地跳(哈哈)", data = 0, },
                                                                                                                                                       { description = "20码", data = 20, },
                                                                                                                                                       { description = "50码", data = 50, },
                                                                                                                                                       { description = "70码", data = 70, },
                                                                                                                                                       { description = "100码", data = 100, },
                                                                                                                                                       { description = "500码", data = 500, },
                                                                                                                                                       { description = "1000码", data = 1000, },
                                                                                                                                                       { description = "2000码", data = 2000, }, }, -1)

configuration_options[#configuration_options + 1] = AddConfigOption("yeyu_nilxin_sea", "夜雨心空填海造海", "夜雨心空填海造海", { { description = "不限制", data = -1, },
                                                                                                                                 { description = "大门洞穴附近无法造海", data = 0, },
                                                                                                                                 { description = "大门洞穴和有structure标签附近无法造海", data = 1, } }, 0)

--configuration_options[#configuration_options + 1] = AddOption("everyone_is_yeyu_nilxin", "人人都是夜雨", "每个角色都可以使用当夜雨", false),
configuration_options[#configuration_options + 1] = AddOption("yeyu_nilxin_island_generate_no", "不生成夜雨岛", "给无资源档使用", false)
---奇幻降临补丁
configuration_options[#configuration_options + 1] = AddOptionHeader("奇幻降临补丁")
configuration_options[#configuration_options + 1] = AddOption("ab_patches_switch", "总开关", "是否开启奇幻降临补丁", false)
configuration_options[#configuration_options + 1] = AddConfigOption("ab_t", "限制阿比日记超能权限", "限制世界多少天后可以使用", disappear_magic, 0)
configuration_options[#configuration_options + 1] = AddConfigOption("ab_ty", "限制阿比桃源", "限制世界多少天后可以使用", disappear_magic, 0)
configuration_options[#configuration_options + 1] = AddOption("ab_knot_drop_limit", "纽结：降临-掉落数量限制", "限制奇幻降临扭结碎片的掉落最大值及自动堆叠", false)
configuration_options[#configuration_options + 1] = AddOption("ab_packer_limit", "阿比打包限制", "禁止打包一些公用物品", true)
configuration_options[#configuration_options + 1] = AddConfigOption("ab_bobbin_c_cd_setting", "彩虹宝石创造物品CD", "彩虹宝石创造物品CD", {
    { description = "基本无CD", data = 1, hover = "可以用彩虹宝石开始创造模式啦" },
    { description = "2分钟", data = 120 },
    { description = "4分钟(半天)", data = 240 },
    { description = "1天", data = 480 },
    { description = "2天", data = 960 },
    { description = "原MOD默认", data = 1000 },
    { description = "3天", data = 1440 },
    { description = "5天", data = 2400 },
    { description = "10天", data = 4800, hover = "本mod默认" },
    { description = "20天", data = 9600 },
    { description = "30天", data = 14400 },
    { description = "50天", data = 24000 },
    { description = "100天", data = 48000 },
    { description = "200天", data = 96000 },
    { description = "500天", data = 240000 },
    { description = "1000天", data = 480000 },
    { description = "一个档只能用一次", data = 31454400, hover = "基本一个档只能用一次" }
}, 4800)
configuration_options[#configuration_options + 1] = AddConfigOption("ab_heisewuhui_optimize", "黑色舞会优化版", "稍微修改黑色舞会机制", { { description = "默", data = 0, hover = "『事件禁止』：休闲模式" },
                                                                                                                                          { description = "启", data = 1, hover = "『事件开始』：一阶段" },
                                                                                                                                          { description = "中", data = 2, hover = "『事件扩展』：一*二阶段" },
                                                                                                                                          { description = "终", data = 3, hover = "『事件全满』：一*二*三阶段" }, }, 0)

---乃木园子补丁
configuration_options[#configuration_options + 1] = AddOptionHeader("乃木园子补丁")
configuration_options[#configuration_options + 1] = AddOption("yuanzi_patches_switch", "总开关", "是否开启乃木园子补丁", false)
configuration_options[#configuration_options + 1] = AddOption("divinetree_no_health", "神树真无敌", "神树无敌啦，再也不担心被狗咬啦", false)

---水晶领主(aria)补丁
configuration_options[#configuration_options + 1] = AddOptionHeader("水晶领主(aria)补丁")
configuration_options[#configuration_options + 1] = AddOption("aria_patches_switch", "总开关", "是否开启水晶领主", false)
configuration_options[#configuration_options + 1] = AddOption("turn_off_aria_transfer_replicate_function", "转换站复制功能关闭", "移除制作站复制功能", true)
configuration_options[#configuration_options + 1] = AddOption("aria_magiccore_can_make", "魔法核心制作", "可以在制作栏制作魔法核心\n需要研究所五级", true)

---璇儿补丁
configuration_options[#configuration_options + 1] = AddOptionHeader("璇儿补丁")
configuration_options[#configuration_options + 1] = AddOption("xuaner_patches_switch", "总开关", "是否开启璇儿补丁", false)
configuration_options[#configuration_options + 1] = AddOption("xuaner_packer_limit_switch", "璇儿打包限制", "禁止打包一些公用物品", true)

---时崎狂三补丁
configuration_options[#configuration_options + 1] = AddOptionHeader("时崎狂三补丁")
configuration_options[#configuration_options + 1] = AddOption("kurumi_patches_switch", "总开关", "是否开启时崎狂三补丁", false)
configuration_options[#configuration_options + 1] = AddOption("kurumi_packer_limit_switch", "狂三打包限制", "禁止打包一些公用物品", true)

---魔法少女小樱补丁
configuration_options[#configuration_options + 1] = AddOptionHeader("魔法少女小樱补丁")
configuration_options[#configuration_options + 1] = AddOption("ccs_patches_switch", "总开关", "是否开启魔法少女小樱补丁", false)
configuration_options[#configuration_options + 1] = AddOption("ccs_packer_limit_switch", "魔法少女小樱打包限制", "禁止打包一些公用物品", true)

---冰川镜华补丁
configuration_options[#configuration_options + 1] = AddOptionHeader("冰川镜华补丁")
configuration_options[#configuration_options + 1] = AddOption("mcw_patches_switch", "总开关", "是否开启冰川镜华补丁", false)
configuration_options[#configuration_options + 1] = AddOption("mcw_packer_limit_switch", "冰川镜华打包限制", "禁止打包一些公用物品", true)

---98K补丁(955048205)
configuration_options[#configuration_options + 1] = AddOptionHeader("98K补丁(955048205)")
configuration_options[#configuration_options + 1] = AddOption("m_98K_patches_switch", "总开关", "是否开启98K补丁", false)
configuration_options[#configuration_options + 1] = AddConfigOption("m_98k_RIFLE_DMG_R_multi", "RIFLE_DMG_R伤害倍率", "", { { description = "默认", data = 1 },
                                                                                                                            { description = "2倍", data = 2 },
                                                                                                                            { description = "5倍", data = 5 },
                                                                                                                            { description = "10倍", data = 10 },
                                                                                                                            { description = "100倍", data = 100 },
                                                                                                                            { description = "200倍", data = 200 },
                                                                                                                            { description = "500倍", data = 500 }, }, 1)
configuration_options[#configuration_options + 1] = AddConfigOption("m_98k_RIFLE_DMG_M_multi", "RIFLE_DMG_M伤害倍率", "", { { description = "默认", data = 1 },
                                                                                                                            { description = "2倍", data = 2 },
                                                                                                                            { description = "5倍", data = 5 },
                                                                                                                            { description = "10倍", data = 10 },
                                                                                                                            { description = "100倍", data = 100 },
                                                                                                                            { description = "200倍", data = 200 },
                                                                                                                            { description = "500倍", data = 500 }, }, 1)
configuration_options[#configuration_options + 1] = AddConfigOption("m_98k_BAYONET_DMG_2_multi", "BAYONET_DMG_2伤害倍率", "", { { description = "默认", data = 1 },
                                                                                                                                { description = "2倍", data = 2 },
                                                                                                                                { description = "5倍", data = 5 },
                                                                                                                                { description = "10倍", data = 10 },
                                                                                                                                { description = "100倍", data = 100 },
                                                                                                                                { description = "200倍", data = 200 },
                                                                                                                                { description = "500倍", data = 500 }, }, 1)
configuration_options[#configuration_options + 1] = AddConfigOption("m_98k_BAYONET_DMG_1_multi", "BAYONET_DMG_1伤害倍率", "", { { description = "默认", data = 1 },
                                                                                                                                { description = "2倍", data = 2 },
                                                                                                                                { description = "5倍", data = 5 },
                                                                                                                                { description = "10倍", data = 10 },
                                                                                                                                { description = "100倍", data = 100 },
                                                                                                                                { description = "200倍", data = 200 },
                                                                                                                                { description = "500倍", data = 500 }, }, 1)

---神话书说
configuration_options[#configuration_options + 1] = AddOptionHeader("神话书说补丁")
configuration_options[#configuration_options + 1] = AddOption("myth_patches_switch", "神话书说补丁-总开关", "是否开启神话书说补丁", false)
configuration_options[#configuration_options + 1] = AddConfigOption("timeleft_tips", "BOSS刷新提醒", "", { { description = "不提醒", data = 1 },
                                                                                                           { description = "自动提醒", data = 2 },
                                                                                                           { description = "热键提醒", data = 3 } }, 2)
configuration_options[#configuration_options + 1] = AddConfigOption("tip_key", "提醒热键", "", { { description = "F1", data = KEY_F1 }, { description = "F2", data = KEY_F2 }, { description = "F3", data = KEY_F3 }, { description = "F4", data = KEY_F4 }, { description = "F5", data = KEY_F5 }, { description = "F6", data = KEY_F6 }, { description = "F7", data = KEY_F7 }, { description = "F8", data = KEY_F8 }, { description = "F9", data = KEY_F9 }, { description = "F10", data = KEY_F10 }, { description = "F11", data = KEY_F11 }, { description = "F12", data = KEY_F12 } }, KEY_F8)
configuration_options[#configuration_options + 1] = AddConfigOption("blackbear_respawn", "黑熊重生时间", "", { { description = "默认", data = 20 }, { description = "较多", data = 10 }, { description = "大量", data = 5 }, { description = "小强", data = 1 } }, 20)
configuration_options[#configuration_options + 1] = AddConfigOption("rhino_respawn", "犀牛三大王重生时间", "", { { description = "默认", data = 50 }, { description = "较多", data = 10 }, { description = "大量", data = 5 }, { description = "小强", data = 1 } }, 50)
configuration_options[#configuration_options + 1] = AddConfigOption("regen_myth_forg_respawn", "金蛤蟆重生时间", "", { { description = "默认", data = 20 }, { description = "较多", data = 10 }, { description = "大量", data = 5 }, { description = "小强", data = 1 } }, 20)
configuration_options[#configuration_options + 1] = AddConfigOption("laozi_trade_num", "太上老君单人可交易次数", "", { { description = "1次(默认)", data = 1 }, { description = "2次", data = 2 }, { description = "3次", data = 3 }, { description = "4次", data = 4 }, { description = "5次", data = 5 }, { description = "6次", data = 6 } }, 1)
configuration_options[#configuration_options + 1] = AddConfigOption("granary_not_rot", "谷仓保鲜", "", { { description = "关闭(OFF)", data = false }, { description = "开启(ON)", data = true } }, true)
configuration_options[#configuration_options + 1] = AddConfigOption("granary_save_fruit", "谷仓可放水果", "", { { description = "关闭(OFF)", data = false }, { description = "开启(ON)", data = true } }, true)
configuration_options[#configuration_options + 1] = AddConfigOption("mythBlackBearRockClearTime", "黑熊岩石清理", "一定时间后清理黑熊出来的岩石", { { description = "不清理", data = -1 },
                                                                                                                                                    { description = "4分后清理", data = 4 * 60 },
                                                                                                                                                    { description = "8分后清理", data = 8 * 60 },
                                                                                                                                                    { description = "16分后清理", data = 16 * 60 },
                                                                                                                                                    { description = "32分后清理", data = 32 * 60 }, }, 4 * 60)
configuration_options[#configuration_options + 1] = AddConfigOption("mythFlyingSpeedMultiplier", "腾云术附带移动加成", "腾云术附带部分移动速度加成", { { description = "不附带", data = 0 },
                                                                                                                                                       { description = "附带25%", data = 0.25 },
                                                                                                                                                       { description = "附带50%", data = 0.5 },
                                                                                                                                                       { description = "附带75%", data = 0.75 },
                                                                                                                                                       { description = "附带100%", data = 1 },
                                                                                                                                                       { description = "附带150%", data = 1.5 },
                                                                                                                                                       { description = "附带200%", data = 2 }, }, 1)

---怠惰科技补丁
configuration_options[#configuration_options + 1] = AddOptionHeader("怠惰科技补丁")
configuration_options[#configuration_options + 1] = AddOption("lazy_technology_patches_switch", "怠惰科技补丁-开关", "怠惰科技补丁", false)
configuration_options[#configuration_options + 1] = AddConfigOption("lazyTechKJKLimit", "锟斤拷限制", "进行进一步限制", { { description = "不限制", data = false },
                                                                                                                          { description = "仅对可装备的物品有效", data = "equipment" },
                                                                                                                          { description = "仅对武器和衣物有效", data = "weaponAndClothing" },
                                                                                                                          { description = "仅对衣物有效", data = "clothing" },
                                                                                                                          { description = "仅对武器有效", data = "weapon" },
                                                                                                                          { description = "全部禁止", data = "null" }, }, "weaponAndClothing")

configuration_options[#configuration_options + 1] = AddConfigOption("lazyTechHDSelectOptimize", "火堆检测优化", "现在会检查是否有怠惰火堆改装的箱子烧可燃物", { { description = "不优化", data = false }, { description = "优化", data = true }, }, true)
---小房子补丁
configuration_options[#configuration_options + 1] = AddOptionHeader("小房子补丁")
configuration_options[#configuration_options + 1] = AddOption("sweet_house_patches_switch", "小房子可种植", "是否允许小房子可种植", false)

---神话:傲来神仙境补丁
configuration_options[#configuration_options + 1] = AddOptionHeader("神话:傲来神仙境补丁")
configuration_options[#configuration_options + 1] = AddOption("aolai_myth_patches_switch", "总开关", "", false)
configuration_options[#configuration_options + 1] = AddOption("chest_spring_myth_make_recipe_change", "春季箱子制作配方更改", "制作材料更难一些", true)
configuration_options[#configuration_options + 1] = AddOption("chest_summer_myth_make_recipe_change", "夏季箱子制作配方更改", "制作材料更难一些", true)
configuration_options[#configuration_options + 1] = AddOption("chest_autumn_myth_make_recipe_change", "秋季箱子制作配方更改", "制作材料更难一些", true)
configuration_options[#configuration_options + 1] = AddOption("chest_winter_myth_make_recipe_change", "冬季箱子制作配方更改", "制作材料更难一些", true)
configuration_options[#configuration_options + 1] = AddConfigOption("four_seasons_chest_place_interval", "四季箱子间距", "箱子占地大小", { { description = "不设置", data = false },
                                                                                                                                           { description = "很近", data = 1 },
                                                                                                                                           { description = "近", data = 2 },
                                                                                                                                           { description = "远", data = 3 },
                                                                                                                                           { description = "很远", data = 4 } }, 1)

---人人都可以用红锅补丁
configuration_options[#configuration_options + 1] = AddOptionHeader("红锅补丁")
configuration_options[#configuration_options + 1] = AddOption("red_pot_for_everyone_switch", "烹饪锅补丁开关", "任何人都可以使用烹饪锅？", false)
configuration_options[#configuration_options + 1] = AddOption("Cookpots", Cookpots_label, Cookpots_hover, optionsYesNo, true)
configuration_options[#configuration_options + 1] = AddOption("Other_item", Other_item_label, Other_item_hover, optionsYesNo, false)
configuration_options[#configuration_options + 1] = AddOption("Professionalchef", Professionalchef_label, Professionalchef_hover, optionsYesNo, false)
configuration_options[#configuration_options + 1] = AddConfigOption("CookingSpeed", CookingSpeed_label, CookingSpeed_hove, { { description = SpeedNormal, data = false },
                                                                                                                             { description = SpeedFast, data = 0.5 },
                                                                                                                             { description = SpeedFaster, data = 0.25 },
                                                                                                                             { description = SpeedFastest, data = 0.01 } }, false)

configuration_options[#configuration_options + 1] = AddOption("AutoCook", AutoCook_label, AutoCook_hover, optionsYesNo, false)

---风滚草补丁
configuration_options[#configuration_options + 1] = AddOptionHeader("风滚草补丁")
configuration_options[#configuration_options + 1] = AddOption("interesting_tumbleweed_switch", "总开关", "", false)
configuration_options[#configuration_options + 1] = AddOption("tumbleweed_prevent_error_patch_switch", "风滚草防错补丁", "防止一些有关风滚草的mod的问题", true)
configuration_options[#configuration_options + 1] = AddConfigOption("tumbleweed_item_rates", "开出MOD物品几率", "花样风滚草可以开出其他MOD物品几率", tumbleweed_item_rates_options, 1)
configuration_options[#configuration_options + 1] = AddConfigOption("cap_item_multiple", "本MOD物品倍率", "本MOD物品权重=基础权重*几率*倍率", tumbleweed_item_multiple_options, 1)
configuration_options[#configuration_options + 1] = AddOption("tumbleweed_add_more_item_switch", "风滚草开出更多物品", "风滚草开出更多物品", false)
configuration_options[#configuration_options + 1] = AddConfigOption("tumbleweed_item_multiple", "开出更多物品倍率", "更多物品权重=基础权重*几率*更多物品倍率", tumbleweed_item_multiple_options, 1)
---樱花林补丁
configuration_options[#configuration_options + 1] = AddOptionHeader("樱花林补丁")
configuration_options[#configuration_options + 1] = AddOption("cherry_forest_patch_switch", "总开关", "", false)
configuration_options[#configuration_options + 1] = AddOption("cherry_plant_transfer_to_default", "植物与原版植物互转", "", false)

---能力勋章补丁
configuration_options[#configuration_options + 1] = AddOptionHeader("能力勋章补丁")
configuration_options[#configuration_options + 1] = AddOption("medal_patch_switch", "总开关", "", false)
configuration_options[#configuration_options + 1] = AddOption("medal_book_read_only_once", "能力勋章相关书籍只能读一次", "", false)

---码头套装增强
configuration_options[#configuration_options + 1] = AddOptionHeader("码头套装增强")
configuration_options[#configuration_options + 1] = AddOption("dock_kit_enhance_switch", "码头套装增强开关", "码头套装增强", false)
configuration_options[#configuration_options + 1] = AddConfigOption("DockKitNum", "码头套装制作数", "设置 制作码头套装时会得到的数量。", { { description = "2个", data = 2 },
                                                                                                                                          { description = "4个(官方)", data = 4 }, { description = "6个", data = 6 }, { description = "8个", data = 8 }, { description = "10个", data = 10 }, { description = "12个", data = 12 },
                                                                                                                                          { description = "16个(默认)", data = 16 }, { description = "20个", data = 20 } }, 16)
configuration_options[#configuration_options + 1] = AddOption("DockTileBreak", "码头地皮不连环崩坏", "设置 码头地皮不会连环崩坏。", true)
configuration_options[#configuration_options + 1] = AddOption("DockKitAreaSea", "码头套装放置不限浅海", "设置 码头套装能在任何水域放置。", true)
configuration_options[#configuration_options + 1] = AddOption("DockKitAreaCave", "码头套装放置洞穴深渊", "设置 码头套装能在洞穴深渊放置。", true)

---大小船只
configuration_options[#configuration_options + 1] = AddOptionHeader("船只相关")
configuration_options[#configuration_options + 1] = AddOption("new_boats_size_switch", "新不同大小船只开关", "是否可以创建不同大小船只", false)
configuration_options[#configuration_options + 1] = AddOption("ALLOWSKINS", "使用皮肤(Allow skins)", "创建船只是否允许使用皮肤(Allows players to craft boats with skins.)", true)

---发光的瓶子
configuration_options[#configuration_options + 1] = AddOptionHeader("发光的瓶子")
configuration_options[#configuration_options + 1] = AddOption("light_bottle_switch", "制作发光的瓶子总开关", "是否可以制作发光的瓶子", false)
configuration_options[#configuration_options + 1] = AddConfigOption("light_bottle_lang", "语言(Language)", "", { { description = "English", data = "en", hover = "English" }, { description = "简体中文", data = "chs", hover = "简体中文" }, }, "chs")
configuration_options[#configuration_options + 1] = AddConfigOption("light_area", Light_area_label, "", light_bottle_options, 10)
configuration_options[#configuration_options + 1] = AddConfigOption("Light_heal", Light_heal_label, "", light_bottle_options, 5)
configuration_options[#configuration_options + 1] = AddConfigOption("Light_sunshine", Light_sunshine_label, "", light_bottle_options, 1)
configuration_options[#configuration_options + 1] = AddConfigOption("Light_menacing", Light_menacing_label, "", light_bottle_options, 1)
configuration_options[#configuration_options + 1] = AddConfigOption("Light_poison", Light_poison_label, "", light_bottle_options, 15)
configuration_options[#configuration_options + 1] = AddConfigOption("Light_Ember", Light_Ember_label, "", light_bottle_options, 1)
configuration_options[#configuration_options + 1] = AddConfigOption("Light_Icy", Light_Icy_label, "", light_bottle_options, 1)

---超大容量背包
configuration_options[#configuration_options + 1] = AddOptionHeader("超大容量背包")
configuration_options[#configuration_options + 1] = AddOption("bigbag_switch", "制作大背包开关", "是否可以制作超大背包", false)
configuration_options[#configuration_options + 1] = AddConfigOption("BIG_BAG_LANG", "Language (语言)", "Change display language.", { { description = "English", data = 0, }, { description = "简体中文", data = 1, }, }, 1)
configuration_options[#configuration_options + 1] = AddConfigOption("BAGSIZE", "Size of bag(背包大小)", "Size of bag", { { description = "8x3", data = 4, }, { description = "8x4", data = 1, }, { description = "8x6", data = 2, }, { description = "8x8", data = 3, }, }, 1)
configuration_options[#configuration_options + 1] = AddConfigOption("NICEBIGBAGSIZE", "Size of haversack(挎包大小)", "Choose your size of haversack.", { { description = "8x3", data = 1, },
                                                                                                                                                         { description = "8x4", data = 2, }, }, 2)
configuration_options[#configuration_options + 1] = AddConfigOption("CATBIGBAGSIZE", "Size of catback(猫包大小)", "Choose your size of catback.", { { description = "8x3", data = 1, },
                                                                                                                                                    { description = "8x4", data = 2, },
                                                                                                                                                    { description = "8x6", data = 3, },
                                                                                                                                                    { description = "8x8", data = 4, }, }, 2)
configuration_options[#configuration_options + 1] = AddOption("KEEPFRESH", "KeepFresh (保鲜)", "Keep the food fresh.", false)
configuration_options[#configuration_options + 1] = AddOption("LIGHT", "Light (保命微光)", "Let the bag give off light.", false)
configuration_options[#configuration_options + 1] = AddOption("BIGBAGWATER", "Rainproof(防雨)", "Protect you from the rain.", false)
configuration_options[#configuration_options + 1] = AddOption("BIGBAGPICK", "Fastpickup(快采)", "Let you pick up items quickly.", false)
configuration_options[#configuration_options + 1] = AddOption("HEATROCKTEMPERATURE", "HeatrockTemp(暖石升降温)", "Change the heatrock's temperature automatically.", false)
configuration_options[#configuration_options + 1] = AddConfigOption("WALKSPEED", "Walk Speed (移速)", "Walk speed while taking this bag.", { { description = "Much Slower(超慢)", data = 0.5, },
                                                                                                                                             { description = "Slower(慢)", data = 0.75, },
                                                                                                                                             { description = "No Change(不变)", data = 1, },
                                                                                                                                             { description = "Faster(快)", data = 1.25, },
                                                                                                                                             { description = "Much Faster(超快)", data = 1.5, }, }, 1)
configuration_options[#configuration_options + 1] = AddOption("BIG_BAG_STACK", "Full Stack (自动堆满)", "Get full stack when reopen the bag.(放一个重新打开会变堆叠满个数哦，慎用)", false)
configuration_options[#configuration_options + 1] = AddOption("BIG_BAG_FRESH", "ReFresh (恢复新鲜)", "ReFresh food and tools when reopen the bag.", false)
--configuration_options[#configuration_options + 1] = AddOption("GIVE", "Give Items (获得物品)", "!!! SEVER ONLY !!!  Give Items Directly If Can't Build Something. !!! SEVER ONLY !!!", false)
configuration_options[#configuration_options + 1] = AddConfigOption("RECIPE", "Recipe (耗材)", "Recipe cost.", { { description = "Very Cheap(超便宜)", data = 1, },
                                                                                                                 { description = "Cheap(便宜)", data = 2, },
                                                                                                                 { description = "Normal(正常)", data = 3, },
                                                                                                                 { description = "Expensive(贵)", data = 4, },
                                                                                                                 { description = "More Expensive(更贵)", data = 5, },
                                                                                                                 { description = "super Expensive(超贵)", data = 6, }, }, 6)
configuration_options[#configuration_options + 1] = AddOption("BIG_BAG_EFFECTED_BY_OTHER_MODS", "制作是否受其他mod影响", "开启会根据服务器开不同mod的变化而变化", true)
configuration_options[#configuration_options + 1] = AddOption("BIG_BAG_ONLY_IN_TUMBLEWEED", "只能在风滚草中开出来", "制作栏制作不了，只能在风滚草中开出来", false)
configuration_options[#configuration_options + 1] = AddOption("BIG_BAG_CAN_GET_MENU", "获取方式开放", "限制级\n开启：普通玩家可以获得 关闭：普通玩家获取不到", true)

configuration_options[#configuration_options + 1] = AddConfigOption("CONTAINERDRAG_SWITCH", "BigBag Drag(背包拖拽)", "After opening, you can drag the bigbag's UI", { { description = "Close(关闭)", data = false, hover = "关闭容器拖拽" },
                                                                                                                                                                      { description = "Open(F1开启)", data = "KEY_F1", hover = "默认按住F1拖动" },
                                                                                                                                                                      { description = "F2", data = "KEY_F2", hover = "按住F2拖动" },
                                                                                                                                                                      { description = "F3", data = "KEY_F3", hover = "按住F3拖动" },
                                                                                                                                                                      { description = "F4", data = "KEY_F4", hover = "按住F4拖动" },
                                                                                                                                                                      { description = "F5", data = "KEY_F5", hover = "按住F5拖动" },
                                                                                                                                                                      { description = "F6", data = "KEY_F6", hover = "按住F6拖动" },
                                                                                                                                                                      { description = "F7", data = "KEY_F7", hover = "按住F7拖动" },
                                                                                                                                                                      { description = "F8", data = "KEY_F8", hover = "按住F8拖动" },
                                                                                                                                                                      { description = "F9", data = "KEY_F9", hover = "按住F9拖动" }, }, "KEY_F1")

--configuration_options[#configuration_options + 1] = AddConfigOption("EASYSWITCH", "Easy switch(快捷开关)", "After opening, you can open the bigbag quickly", { { description = "Close", data = false, hover = "关闭快捷开关" }, { description = "O", data = "KEY_O", hover = "使用快捷键O" }, { description = "0", data = "KEY_0", hover = "使用快捷键0" }, { description = "F1", data = "KEY_F1", hover = "使用快捷键F1" }, { description = "F2", data = "KEY_F2", hover = "使用快捷键F2" }, { description = "F3", data = "KEY_F3", hover = "使用快捷键F3" }, { description = "F4", data = "KEY_F4", hover = "使用快捷键F4" }, { description = "F5", data = "KEY_F5", hover = "使用快捷键F5" }, { description = "F6", data = "KEY_F6", hover = "使用快捷键F6" }, { description = "F7", data = "KEY_F7", hover = "使用快捷键F7" }, { description = "F8", data = "KEY_F8", hover = "使用快捷键F8" }, { description = "F9", data = "KEY_F9", hover = "使用快捷键F9" }, }, "KEY_O")
configuration_options[#configuration_options + 1] = AddOption("BAGINBAG", "Bag in bag(包中包)", "Bag in bag", false)

---翅膀背包
configuration_options[#configuration_options + 1] = AddOptionHeader("翅膀背包")
configuration_options[#configuration_options + 1] = AddOption("wingpack_switch", "制作翅膀背包开关", "是否可以制作翅膀背包", false)
configuration_options[#configuration_options + 1] = AddOption("wingpack_equip_slot", "放在额外背包栏", "开始则放在额外背包栏\n关闭放在身体栏", false)

---海上箱子
configuration_options[#configuration_options + 1] = AddOptionHeader("超大容量便携箱子")
configuration_options[#configuration_options + 1] = AddOption("bigbox_switch", "制作超大容量便携箱子开关", "是否可以制作超大容量便携箱子", false)
configuration_options[#configuration_options + 1] = AddOption("BIGBOX_ONLY_IN_TUMBLEWEED", "只能在风滚草中开出来", "制作栏制作不了，只能在风滚草中开出来", false)

configuration_options[#configuration_options + 1] = AddConfigOption("container_removable", Language_cn and "容器 UI 可以移动" or "The container UI can be moved", "警告：万万不可和同类功能的模组一起开启！！！\n如果有同类模组请关闭该选项。",
        { option(Language_cn and "开启" or "Open", true, ""),
          option(Language_cn and "关闭" or "Close", false, ""), }, false)
configuration_options[#configuration_options + 1] = AddConfigOption("SET_HUGE_BOX_PRESERVER_VALUE", Language_cn and "设置保鲜效果" or "Set fresh-keeping effect", "",
        { option(Language_cn and "关闭" or "Close", -1, ""),
          option("0.5", 0.5, Language_cn and "冰箱的保鲜效果" or "The preservation effect of refrigerator"),
          option("0.25", 0.25, Language_cn and "盐盒的保鲜效果" or "The preservation effect of salt box"),
          option("0.1", 0.1, Language_cn and "冰箱保鲜效果的5倍" or "Five times as effective as a refrigerator"),
          option("0", 0, Language_cn and "永久保鲜" or "Permanent preservation"),
          option("-0.5", -0.5, Language_cn and "返鲜。参考：锡鱼罐返鲜效果为-0.333" or "Return fresh. Reference: Fresh return effect of tin fish can is -0.333"),
          option("-4", -4, Language_cn and "返鲜。参考：锡鱼罐返鲜效果为-0.333" or "Return fresh. Reference: Fresh return effect of tin fish can is -0.333"),
          option("-16", -16, Language_cn and "返鲜。参考：锡鱼罐返鲜效果为-0.333" or "Return fresh. Reference: Fresh return effect of tin fish can is -0.333"),
        }, -1)
configuration_options[#configuration_options + 1] = AddOptionHeader("月亮控制书籍")
configuration_options[#configuration_options + 1] = AddOption("add_moon_book_switch", "月亮控制相关书籍开关", "是否可以制作月亮控制相关书籍", false)
configuration_options[#configuration_options + 1] = AddConfigOption("moon_book_language", "语言/Language", "", { { description = "中文", data = "zhs", hover = "" }, { description = "English", data = "en", hover = "" } }, "zhs")
configuration_options[#configuration_options + 1] = AddOption("add_moon_book_new", "增加新月书", "", true)
configuration_options[#configuration_options + 1] = AddOption("add_moon_book_half", "增加半月书", "", true)

---嫦娥mod物品包
configuration_options[#configuration_options + 1] = AddOptionHeader("嫦娥mod物品包")
configuration_options[#configuration_options + 1] = AddOption("mod_change_part_switch", "制作嫦娥mod物品", "制作嫦娥mod物品", false)

---限制级物品列表
CAP_REMOVE_SOMETHING_LIST_CONFIG = {
    { "remove_ancienttree_seed", "惊喜种子(原版)", "限制惊喜种子(原版)及其产物可用的时间！", disappear_magic, 0 },
    { "remove_ancienttree_nightvision", "阴郁之棘(原版)", "限制阴郁之棘(原版)及其产物可用的时间！", disappear_magic, 0 },

    { "remove_myth_qxj", "神话的七星剑", "让神话的七星剑消失！", disappear_magic, -1 },
    { "remove_myth_bigpeach", "神话的大蟠桃", "让神话的大蟠桃消失！", disappear_magic, 0 },
    { "remove_aria_tower", "aria的领主之怒", "让aria的领主之怒消失！", disappear_magic, 0 },
    { "remove_aria_transfer", "aria的晶能转换站", "让aria的晶能转换站消失！", disappear_magic, 0 },
    { "remove_aria_blackhole", "aria的深空黑点", "让aria的深空黑点消失！", disappear_magic, 0 },
    { "remove_aria_medal_alter", "aria的暴君勋章", "让aria的暴君勋章消失！", disappear_magic, 0 },
    { "remove_elaina_bq", "伊蕾娜的释槐留仙裙", "让伊蕾娜的释槐留仙裙消失！", disappear_magic, -1 },
    { "remove_saya_potions_happiness", "魔女的创造模式药水", "让魔女的创造模式药水消失！", disappear_magic, -1 },
    { "remove_abigail_williams_black_gold", "阿比盖尔威廉姆斯的暗金", "让阿比盖尔威廉姆斯的暗金消失！", disappear_magic, -1 },
    { "remove_abigail_williams_psionic_bobbin_c", "阿比盖尔威廉姆斯的彩虹线轴", "让阿比盖尔威廉姆斯的彩虹线轴消失！", disappear_magic, 0 },
    { "remove_abigail_williams_ab_lnhx", "阿比盖尔威廉姆斯的灵能核心", "让阿比盖尔威廉姆斯的灵能核心消失！", disappear_magic, -1 },
    { "remove_abigail_williams_starry_bush", "阿比盖尔威廉姆斯的星空矿从", "让阿比盖尔威廉姆斯的星空矿从消失！", disappear_magic, -1 },
    { "remove_abigail_williams_atrium_light_moon", "阿比盖尔威廉姆斯的月之灯柱", "让阿比盖尔威廉姆斯的月之灯柱消失！", disappear_magic, 0 },
    { "remove_abigail_williams_bonestew", "阿比盖尔威廉姆斯的无限炖肉汤", "让阿比盖尔威廉姆斯的无限炖肉汤消失！", disappear_magic, 0 },
    { "remove_abigail_williams_ab_wilsontorch", "阿比盖尔威廉姆斯的疯狂的科学家火炬", "让阿比盖尔威廉姆斯的疯狂的科学家火炬消失！", disappear_magic, 0 },
    { "remove_abigail_williams_traveler_armor", "阿比盖尔威廉姆斯的侠客服I", "让阿比盖尔威廉姆斯的侠客服I消失！", disappear_magic, -1 },
    { "remove_abigail_williams_traveler_armor_2", "阿比盖尔威廉姆斯的疯狂的侠客服II", "让阿比盖尔威廉姆斯的疯狂的侠客服II消失！", disappear_magic, -1 },
    { "remove_abigail_williams_traveler_armor_3", "阿比盖尔威廉姆斯的侠客服III", "让阿比盖尔威廉姆斯的侠客服III消失！", disappear_magic, -1 },
    { "remove_abigail_williams_sword", "阿比盖尔威廉姆斯的侠客剑I", "让阿比盖尔威廉姆斯的疯狂的侠客剑I消失！", disappear_magic, -1 },
    { "remove_abigail_williams_sword_a", "阿比盖尔威廉姆斯的疯狂的侠客剑II", "让阿比盖尔威廉姆斯的疯狂的侠客剑II消失！", disappear_magic, -1 },
    { "remove_abigail_williams_sword_b", "阿比盖尔威廉姆斯的疯狂的侠客剑III", "让阿比盖尔威廉姆斯的疯狂的侠客剑III消失！", disappear_magic, -1 },
    { "remove_abigail_williams_psionic_bobbin_2_3_4", "阿比盖尔威廉姆斯的编织：多重", "让阿比盖尔威廉姆斯的编织：多重(二、三、四)消失！", disappear_magic, -1 },
    { "remove_nilxin_fox", "夜雨心空的金团子", "让夜雨心空的金团子消失！(防止召唤很多卡服)！", disappear_magic, 0 },
    { "remove_nilxin_yyxk1", "夜雨心空的红尾巴", "让夜雨心空的红尾巴消失！", disappear_magic, 0 },
    { "remove_yyxk_auto_recipe", "夜雨心空的聚合之仪", "让夜雨心空的聚合之仪消失！", disappear_magic, 0 },
    { "remove_yyxk_auto_destroystructure", "夜雨心空的解构之仪", "让夜雨心空的解构之仪消失！", disappear_magic, 0 },
    { "remove_yyxk_item_togetherup0", "夜雨心空的采集箱子", "让夜雨心空的采集箱子消失！", disappear_magic, -1 },
    { "remove_yyxk_shadowflower_alterguardian", "夜雨心空的影天体", "让夜雨心空的影天体消失！", disappear_magic, 0 },
    { "remove_yyxk_lunarthrall_plant", "夜雨心空的影花A型", "让夜雨心空的影花A型消失！", disappear_magic, 0 },
    { "remove_kemomimi_book_fs", "小狐狸的丰收书", "让小狐狸的丰收书消失！(防止刷资源卡服)！", disappear_magic, 0 },
    { "remove_kemomimi_magic_coin_colour", "小狐狸的彩虹召唤币", "让小狐狸的彩虹召唤币！(防止召唤很多卡服)！", disappear_magic, 0 },
    { "remove_kemomimi_build_pig", "小狐狸的战斗大师", "让小狐狸的战斗大师消失", disappear_magic, 0 },
    { "remove_kemomimi_boss_ds_zh", "小狐狸的蛇莓", "让小狐狸的蛇莓消失", disappear_magic, -1 },
    { "remove_monster_book", "能力勋章的怪物图鉴", "让怪物图鉴消失！(大量刷boss卡服)", disappear_magic, 0 },
    { "remove_medal_spacetime_devourer", "能力勋章的时空吞噬者", "让时空吞噬者消失！", disappear_magic, 0 },
    { "remove_hclr_kjk", "怠惰科技的锟斤拷", "让怠惰科技的锟斤拷消失", disappear_magic, -1 },
    { "老鼠", "不妥协的老鼠", "让不妥协的老鼠消失", disappear_magic, -1 },
    { "恐怖剧钳", "不妥协的恐怖剧钳", "让不妥协的恐怖剧钳消失", disappear_magic, -1 },
    { "圣诞节日", "取消圣诞掉落", "让原版圣诞乱七八糟的食品消失", disappear_magic, -1 },
    { "remove_halloween_candy", "取消万圣节糖果掉落", "让原版万圣节糖果消失", disappear_magic, -1 },
    { "青蛙", "青蛙", "让原版的青蛙消失", disappear_magic, 0 },
    { "鸟粪", "鸟粪", "让原版的鸟粪食品消失", disappear_magic, 0 },
    { "月乌鸦", "月乌鸦", "让天体英雄任务中的乌鸦消失", disappear_magic, 0 },
    { "远古蜈蚣", "远古蜈蚣", "让地下档案室远古蜈蚣消失", disappear_magic, 0 },
    { "remove_tiddle_decay", "黑死病的鼠疫球", "让黑死病的鼠疫球消失", disappear_magic, -1 },
    --{"remove_heap_of_food_bird", "Heap Of food的鸟", "Heap Of food的鸟消失(防崩溃)", disappear_magic, -1},
    { "remove_krm_broom", "时崎狂三的赝造魔女(复制)", "平衡", disappear_magic, -1 },
    { "remove_krm_bullet10", "时崎狂三的十之弹:解锁科技", "十之弹:解锁科技解锁伊蕾娜科技", disappear_magic, 200 },
    { "remove_krm_spirit_crystal", "时崎狂三的二亚的灵结晶", "可开启创造模式", disappear_magic, 300 },
    { "remove_krm_book", "时崎狂三的嗫眚篇帙", "随机效果", disappear_magic, 300 },
    { "remove_taizhen_personal_fanhao", "太真专属番号", "限制太真的专属番号", disappear_magic, -1 },
    { "remove_xukongyijie_taila_baoshishu", "虚空异界(泰拉)宝石/树", "限制泰拉的宝石/树", disappear_magic, -1 },
    { "remove_xukongyijie_taila_other", "虚空异界(泰拉)其他", "限制泰拉的其他物品", disappear_magic, -1 },
    { "remove_zhijiang_medals", "枝江往事徽章", "限制枝江的徽章", disappear_magic, -1 },
    { "remove_zhijiang_other", "枝江往事其他", "限制枝江的其他物品", disappear_magic, -1 },
    { "remove_fairytales_other", "童话世界其他", "限制童话世界的其他物品", disappear_magic, -1 },
}

configuration_options[#configuration_options + 1] = AddOptionHeader("物品/生物禁用")
configuration_options[#configuration_options + 1] = AddOption("remove_something", "物品禁用", "是否开启物品禁用", false)
for i = 1, #CAP_REMOVE_SOMETHING_LIST_CONFIG do
    configuration_options[#configuration_options + 1] = AddConfigOption(CAP_REMOVE_SOMETHING_LIST_CONFIG[i][1], CAP_REMOVE_SOMETHING_LIST_CONFIG[i][2], CAP_REMOVE_SOMETHING_LIST_CONFIG[i][3], CAP_REMOVE_SOMETHING_LIST_CONFIG[i][4], CAP_REMOVE_SOMETHING_LIST_CONFIG[i][5])
end

---内容PLUS
configuration_options[#configuration_options + 1] = AddOptionHeader("内容PLUS")
configuration_options[#configuration_options + 1] = AddOption("remove_boss_taunted", "移除boss间的仇恨", "让boss之间不要相互伤害", false)
configuration_options[#configuration_options + 1] = AddOption("boss_prop_more_drop_switch", "boss掉落概率增多", "是否开启boss掉落增多", false)
configuration_options[#configuration_options + 1] = AddOption("reward_for_survival", "玩家存活激励", "是否开启玩家存活天数奖励制度", false)
configuration_options[#configuration_options + 1] = AddOption("blackstaff_make", "黑色法杖-开关", "是否可制作黑色法杖\n用于手动清理垃圾", true)
configuration_options[#configuration_options + 1] = AddOption("baka_lamp", "霓庭灯、虹庭灯", "是否允许制作霓庭灯、虹庭灯\n永亮光源", false)
configuration_options[#configuration_options + 1] = AddOption("rabbit_house", "兔子喷泉", "是否允许建造兔子喷泉\n漂亮建筑", false)
configuration_options[#configuration_options + 1] = AddOption("venus_icebox_switches", "萝卜冰箱", "是否允许建造萝卜冰箱\n前4格永久保鲜", false)

---填海造陆道具
configuration_options[#configuration_options + 1] = AddOptionHeader("填海造陆道具")
configuration_options[#configuration_options + 1] = AddOption("canal_plow", "填海造海道具", "是否可以使用填海造海道具", false)
configuration_options[#configuration_options + 1] = AddConfigOption("DEPLOY_RULE", "使用位置限制(Deployment location restrictions)", [[填海造海道具是否只能放于海岸线
        Canal plow can only be placed on only the coastline or anywhere reachable]], { { description = "只能放于海岸线 Coastline", data = true }, { description = "任何地方 Anywhere", data = false } }, true)

---随机蓝图
configuration_options[#configuration_options + 1] = AddOptionHeader("随机蓝图")
configuration_options[#configuration_options + 1] = AddOption("random_blueprint_drop", "随机蓝图掉落开关", "是否开启随机蓝图掉落", false)
configuration_options[#configuration_options + 1] = AddConfigOption("drop_multiplying", "蓝图掉落倍率", "",
        { { description = "极低(0.1)", data = 0.1 },
          { description = "很低(0.25)", data = 0.25 },
          { description = "低(0.5)", data = 0.5 },
          { description = "较低(0.75)", data = 75 },
          { description = "默认(1.0)", data = 1 },
          { description = "较高(1.25)", data = 1.25 },
          { description = "高(1.5)", data = 1.5 },
          { description = "很高(2)", data = 2 },
          { description = "极高(3)", data = 3 }, }, 1)
---强力清理
configuration_options[#configuration_options + 1] = AddOptionHeader("强力清理")
configuration_options[#configuration_options + 1] = AddOption("strong_leaner_switch", "强力清理", "是否开强力清理", false)
configuration_options[#configuration_options + 1] = AddConfigOption("checking_days", "清理检测时间间隔(Checking Days)", "清理时间间隔-天(Checking Period)",
        { { description = "1", data = 1, hover = "" },
          { description = "2", data = 2, hover = "" },
          { description = "3", data = 3, hover = "" },
          { description = "5", data = 5, hover = "" },
          { description = "10", data = 10, hover = "" },
          { description = "20", data = 20, hover = "" },
          { description = "30", data = 30, hover = "" },
          { description = "40", data = 40, hover = "" },
          { description = "50", data = 50, hover = "" },
          { description = "100", data = 100, hover = "" },
          { description = "200", data = 200, hover = "" },
          { description = "500", data = 500, hover = "" },
          { description = "800", data = 800, hover = "" },
          { description = "1000", data = 1000, hover = "" },
          { description = "1500", data = 1500, hover = "" },
          { description = "2000", data = 2000, hover = "" },
        }, 2)
configuration_options[#configuration_options + 1] = AddConfigOption("usage_scenario", "使用场景", "普通档：普通的黑白名单模式\n风滚草档：加强清理，清除开出来的怪物等\n超强清理档：可能卡服的统统清理",
        { { description = "普通档", data = 1, hover = "" },
          { description = "海钓或风滚草档", data = 2, hover = "" },
          { description = "海钓或风滚草建家档", data = 3, hover = "" },
          { description = "超强清理档", data = 4, hover = "" },
        }, 1)
configuration_options[#configuration_options + 1] = AddConfigOption("clean_mode", "清理模式(Clean Mode)", "白名单模式或者黑名单模式(Whitelist mode or Blacklist mode)", {
    { description = "Whitelist", data = 0, hover = "" },
    { description = "Blacklist", data = 1, hover = "" }, }, 0)
configuration_options[#configuration_options + 1] = AddConfigOption("white_area", "White Area(白名单区域)", "茶几附近的物品不清理(Things near the tables will not be removed)", optionsYesNo, true)
configuration_options[#configuration_options + 1] = AddConfigOption("strong_clean_white_list_additional_option", "白名单列表补充", "配置中添加物品列表",
        { { description = "不额外补充名单", data = false }, { description = "自由配置", data = strong_clean_white_list_additional } }, false)
configuration_options[#configuration_options + 1] = AddConfigOption("strong_clean_black_list_additional_option", "黑名单列表补充", "配置中添加物品列表",
        { { description = "不额外补充名单", data = false }, { description = "自由配置", data = strong_clean_black_list_additional } }, false)
configuration_options[#configuration_options + 1] = AddConfigOption("strong_clean_white_tag_list_additional_option", "白名单标签补充", "配置中添加物品列表",
        { { description = "不额外补充名单", data = false }, { description = "自由配置", data = strong_clean_white_tag_list_additional } }, false)
--configuration_options[#configuration_options + 1] = AddConfigOption("strong_clean_black_tag_list_additional_option", "黑名单标签补充", "配置中添加物品列表",
--        { { description = "不额外补充名单", data = false }, { description = "自由配置", data = strong_clean_black_tag_list_additional } }, false)
configuration_options[#configuration_options + 1] = AddConfigOption("strong_clean_half_white_list_additional_option", "白名单半清理补充", "配置中添加物品列表",
        { { description = "不额外补充名单", data = false }, { description = "自由配置", data = strong_clean_half_white_list_additional } }, false)
configuration_options[#configuration_options + 1] = AddConfigOption("strong_clean_strong_clean_list_additional_option", "强力清理列表补充", "配置中添加物品列表",
        { { description = "不额外补充名单", data = false }, { description = "自由配置", data = strong_clean_strong_clean_list_additional } }, false)

configuration_options[#configuration_options + 1] = AddConfigOption("tumbleweed_maxnum", "风滚草清理(Tumbleweed Clean)", "超过配置数目风滚草被清理", clean_num_options, 100)
configuration_options[#configuration_options + 1] = AddConfigOption("evergreen_maxnum", "常青树清理(evergreen Clean)", "超过配置数目常青树被清理", clean_num_options, 1000)
configuration_options[#configuration_options + 1] = AddConfigOption("evergreen_sparse_maxnum", "无松果常青树清理(evergreen sparse Clean)", "超过配置数目常无松果常青树被清理", clean_num_options, 1000)
configuration_options[#configuration_options + 1] = AddConfigOption("deciduoustree_maxnum", "桦树清理(deciduoustree Clean)", "超过配置数目桦树被清理", clean_num_options, 1000)
configuration_options[#configuration_options + 1] = AddConfigOption("boat_clean", "船只清理(Boat Clean)", "特定游戏内天数不使用的船只被清理(Destroy boats that were not used for a specific days.)", {
    { description = "No", data = false, hover = "" },
    { description = "游戏内180天(180 days in game)", data = 180, hover = "" },
    { description = "游戏内360天(360 days in game)", data = 360, hover = "" },
    { description = "游戏内540天(540 days in game)", data = 540, hover = "" },
    { description = "游戏内720天(720 days in game)", data = 720, hover = "" }, }, false)

configuration_options[#configuration_options + 1] = AddOptionHeader("反作弊")
configuration_options[#configuration_options + 1] = AddOption("anti_cheat_switch", "开启反作弊", "是否开启反作弊功能", false)
configuration_options[#configuration_options + 1] = AddConfigOption("camera", "检测鹰眼", "该功能尚在测试", {
    { description = "关闭该功能", data = 0, hover = "什么也不做" },
    { description = "禁用鹰眼", data = 1, hover = "对于鹰眼的玩家自动将视野调整到正常范围,大视野可以用,但是鹰眼就过分了" },
    { description = "检测鹰眼 ", data = 2, hover = "检测鹰眼的玩家并使其退出游戏" } }, 0)
configuration_options[#configuration_options + 1] = AddConfigOption("nightvision", "检测夜视", "该功能尚在测试", {
    { description = "关闭该功能", data = 0, hover = "什么也不做" },
    { description = "禁用夜视", data = 1, hover = "可以使大部分客户端夜视模组失效,可能存在未知问题" },
    { description = "检测夜视", data = 2, hover = "检测夜视玩家并使其退出游戏" } }, 0)
configuration_options[#configuration_options + 1] = AddConfigOption("checkmode", "白名单模式", "开启白名单模式", {
    { description = "是", data = true, hover = "只允许开启列表中的MOD" },
    { description = "否", data = false, hover = "不允许开启列表中的MOD" } }, false)
configuration_options[#configuration_options + 1] = { name = "whitemods", description = "白名单列表.", default = {} }
configuration_options[#configuration_options + 1] = { name = "blockmods", description = "黑名单名单列表.", default = {} }

---血量条
configuration_options[#configuration_options + 1] = AddOptionHeader("血量条显示")
configuration_options[#configuration_options + 1] = AddOption("simple_health_bar_switch", "1.简单血量条-开关", "是否显示简单血量条", false)
configuration_options[#configuration_options + 1] = AddOption("epic_health_bar_switch", "2.史诗级血量条-开关", "是否显示史诗级血量条\n此选项开启简单血量条不生效", false)
local LOCALE = {
    EN = {
        NAME = name,
        HEADER_SERVER = "(.a)Server",
        HEADER_CLIENT = "(.b).Client",
        DISABLED = "Disabled",
        ENABLED = "Enabled",
        NOEPIC = "Mob Health",
        NOEPIC_HOVER = "Displays health of non-boss entities.",
        NOEPIC_DISABLED = "Show bosses only",
        NOEPIC_ENABLED = "Show mob health",
        FRAME_PHASES = "Combat Phases",
        FRAME_PHASES_HOVER = "Separates bars of applicable bosses by phases.",
        FRAME_PHASES_DISABLED = "Hide phases",
        FRAME_PHASES_ENABLED = "Show phases",
        DAMAGE_NUMBERS = "Damage Numbers",
        DAMAGE_NUMBERS_HOVER = "Displays received damage or healing with popup numbers.",
        DAMAGE_NUMBERS_DISABLED = "Hide numbers",
        DAMAGE_NUMBERS_ENABLED = "Show numbers",
        DAMAGE_RESISTANCE = "Damage Resistance",
        DAMAGE_RESISTANCE_HOVER = "Displays a special effect when the boss receives\nless damage due to its defenses.",
        DAMAGE_RESISTANCE_DISABLED = "Hide resistance",
        DAMAGE_RESISTANCE_ENABLED = "Show resistance",
        WETNESS_METER = "Wetness",
        WETNESS_METER_HOVER = "Displays a special effect when the boss becomes wet.",
        WETNESS_METER_DISABLED = "Hide wetness",
        WETNESS_METER_ENABLED = "Show wetness",
        HORIZONTAL_OFFSET = "Horizontal Offset",
        HORIZONTAL_OFFSET_HOVER = "Shifts the bar away from the center.",
        HORIZONTAL_OFFSET_LEFT = "%s units to the left",
        HORIZONTAL_OFFSET_NONE = "No offset",
        HORIZONTAL_OFFSET_RIGHT = "%s units to the right",
        NONOEPIC = "Hide Mob Health",
        NONOEPIC_HOVER = "Shows only bosses even if mob health is enabled.",
        NONOEPIC_DISABLED = "Follow server settings",
        NONOEPIC_ENABLED = "Override server settings",
    },

    PT = {
        NAME = "Barra de Vida Épica",
        HEADER_SERVER = "(.a).Servidor",
        HEADER_CLIENT = "(.b).Cliente",
        DISABLED = "Desativado",
        ENABLED = "Ativado",
        NOEPIC = "Vida do Mob",
        NOEPIC_HOVER = "Mostrar vida de entidades não chefes.",
        NOEPIC_DISABLED = "Mostrar apenas chefes",
        NOEPIC_ENABLED = "Mostrar vida do mob",
        FRAME_PHASES = "Fases do Combate",
        FRAME_PHASES_HOVER = "Separar barras de chefes aplicáveis por fases.",
        FRAME_PHASES_DISABLED = "Ocultar fases",
        FRAME_PHASES_ENABLED = "Mostrar fases",
        DAMAGE_NUMBERS = "Números de dano",
        DAMAGE_NUMBERS_HOVER = "Mostrar dano recebido ou curado com números.",
        DAMAGE_NUMBERS_DISABLED = "Esconder números",
        DAMAGE_NUMBERS_ENABLED = "Mostrar números",
        DAMAGE_RESISTANCE = "Resistência a Dano",
        DAMAGE_RESISTANCE_HOVER = "Mostra um efeito especial quando o chefe recebe\nmenos dano de acordo com suas defesas.",
        DAMAGE_RESISTANCE_DISABLED = "Esconder resistência",
        DAMAGE_RESISTANCE_ENABLED = "Mostrar resistência",
        WETNESS_METER = "Quão molhado está",
        WETNESS_METER_HOVER = "Mostra um efeito especial quando o chefe fica molhado.",
        WETNESS_METER_DISABLED = "Esconder molhadeira",
        WETNESS_METER_ENABLED = "Mostrar molhadeira",
        HORIZONTAL_OFFSET = "Centralização Horizontal",
        HORIZONTAL_OFFSET_HOVER = "Move a barra para longe do centro.",
        HORIZONTAL_OFFSET_LEFT = "%s de unidades para a esquerda",
        HORIZONTAL_OFFSET_NONE = "Sem centralização",
        HORIZONTAL_OFFSET_RIGHT = "%s de unidades para a direita",
        NONOEPIC = "Esconder Vida do Mob",
        NONOEPIC_HOVER = "Mostrar apenas chefes mesmo se a vida de mobs estiver ativada.",
        NONOEPIC_DISABLED = "Seguir configurações do servidor",
        NONOEPIC_ENABLED = "Sobrepor configurações do servidor",
    },

    RU = {
        NAME = name,
        HEADER_SERVER = "(.a).Сервер",
        HEADER_CLIENT = "(.b).Клиент",
        DISABLED = "Отключено",
        ENABLED = "Включено",
        NOEPIC = "Здоровье мобов",
        NOEPIC_HOVER = "Показывает здоровье существ не являющихся боссами.",
        NOEPIC_DISABLED = "Показывать только боссов",
        NOEPIC_ENABLED = "Показывать всех мобов",
        FRAME_PHASES = "Фазы боя",
        FRAME_PHASES_HOVER = "Разделяет полоски применимых боссов по фазам.",
        FRAME_PHASES_DISABLED = "Не показывать фазы",
        FRAME_PHASES_ENABLED = "Показывать фазы",
        DAMAGE_NUMBERS = "Цифры урона",
        DAMAGE_NUMBERS_HOVER = "Показывает полученный урон или исцеление отдельными цифрами.",
        DAMAGE_NUMBERS_DISABLED = "Не показывать цифры",
        DAMAGE_NUMBERS_ENABLED = "Показывать цифры",
        DAMAGE_RESISTANCE = "Сопротивление урону",
        DAMAGE_RESISTANCE_HOVER = "Показывает специальный эффект когда босс получает\nменьше урона из-за своей защиты.",
        DAMAGE_RESISTANCE_DISABLED = "Не показывать сопротивление",
        DAMAGE_RESISTANCE_ENABLED = "Показывать сопротивление",
        WETNESS_METER = "Влажность",
        WETNESS_METER_HOVER = "Показывает специальный эффект когда босс становится мокрым.",
        WETNESS_METER_DISABLED = "Не показывать влажность",
        WETNESS_METER_ENABLED = "Показывать влажность",
        HORIZONTAL_OFFSET = "Горизонтальное смещение",
        HORIZONTAL_OFFSET_HOVER = "Сдвигает полоску от центра экрана.",
        HORIZONTAL_OFFSET_LEFT = "%s единиц налево",
        HORIZONTAL_OFFSET_NONE = "Без смещения",
        HORIZONTAL_OFFSET_RIGHT = "%s единиц направо",
        NONOEPIC = "Скрывать здоровье мобов",
        NONOEPIC_HOVER = "Показывает только боссов даже если здоровье мобов включено.",
        NONOEPIC_DISABLED = "Следовать настройкам сервера",
        NONOEPIC_ENABLED = "Игнорировать настройки сервера",
    },

    ZH = {
        NAME = name,
        HEADER_SERVER = "(.a)服务器",
        HEADER_CLIENT = "(.b)客户端",
        DISABLED = "关闭",
        ENABLED = "开启",
        NOEPIC = "所有生物的血量条",
        NOEPIC_HOVER = "显示非boss的血量条",
        NOEPIC_DISABLED = "仅显示boss的血量条",
        NOEPIC_ENABLED = "显示所有生物的血量条",
        FRAME_PHASES = "战斗机制阶段",
        FRAME_PHASES_HOVER = "按阶段显示boss血量条",
        FRAME_PHASES_DISABLED = "隐藏阶段",
        FRAME_PHASES_ENABLED = "显示阶段",
        DAMAGE_NUMBERS = "显示伤害&治疗量",
        DAMAGE_NUMBERS_HOVER = "以弹出数值的方式显示受到的伤害和治疗",
        DAMAGE_NUMBERS_DISABLED = "隐藏数值",
        DAMAGE_NUMBERS_ENABLED = "显示数值",
        DAMAGE_RESISTANCE = "抗损伤性",
        DAMAGE_RESISTANCE_HOVER = "显示抗损伤效果",
        DAMAGE_RESISTANCE_DISABLED = "隐藏抵抗",
        DAMAGE_RESISTANCE_ENABLED = "显示抵抗",
        WETNESS_METER = "潮湿度",
        WETNESS_METER_HOVER = "显示湿度效果",
        WETNESS_METER_DISABLED = "隐藏潮湿度",
        WETNESS_METER_ENABLED = "显示潮湿度",
        HORIZONTAL_OFFSET = "血量条X轴偏移",
        HORIZONTAL_OFFSET_HOVER = "将血量条进行X轴偏移",
        HORIZONTAL_OFFSET_LEFT = "往左调整 %s",
        HORIZONTAL_OFFSET_NONE = "无偏移",
        HORIZONTAL_OFFSET_RIGHT = "往右调整 %s",
        NONOEPIC = "只显示boss血量",
        NONOEPIC_HOVER = "即使服务器启用了所有怪物血量，也只显示BOSS",
        NONOEPIC_DISABLED = "遵循服务器设置",
        NONOEPIC_ENABLED = "覆盖服务器设置",
    },
}

LOCALE.BR = LOCALE.PT
LOCALE.CH = LOCALE.ZH

local function MakeHeader(label, client)
    return { name = "", label = label, options = { { description = "", data = "" } }, default = "", client = client }
end
local function GetToggleOptions(name)
    return
    {
        { description = STRINGS.DISABLED, data = false, hover = STRINGS[name .. "_DISABLED"] },
        { description = STRINGS.ENABLED, data = true, hover = STRINGS[name .. "_ENABLED"] },
    }
end

local function MakeOption(name, options, default, client)
    return
    {
        name = name,
        label = STRINGS[name],
        hover = STRINGS[name .. "_HOVER"],
        options = options or GetToggleOptions(name),
        default = default or false,
        client = client,
    }
end
function SetLocale(locale)
    STRINGS = locale ~= nil and LOCALE[locale:upper():sub(0, 2)] or LOCALE.EN

    name = STRINGS.NAME or name

    local HORIZONTAL_OFFSET_OPTIONS = {}
    for i = -200, 200, 25 do
        if i < 0 then
            HORIZONTAL_OFFSET_OPTIONS[#HORIZONTAL_OFFSET_OPTIONS + 1] = { description = "" .. i, data = i, hover = STRINGS.HORIZONTAL_OFFSET_LEFT:format(-i) }
        elseif i == 0 then
            HORIZONTAL_OFFSET_OPTIONS[#HORIZONTAL_OFFSET_OPTIONS + 1] = { description = STRINGS.DISABLED, data = 0, hover = STRINGS.HORIZONTAL_OFFSET_NONE }
        else
            HORIZONTAL_OFFSET_OPTIONS[#HORIZONTAL_OFFSET_OPTIONS + 1] = { description = "" .. i, data = i, hover = STRINGS.HORIZONTAL_OFFSET_RIGHT:format(i) }
        end
    end
    configuration_options[#configuration_options + 1] = MakeHeader(STRINGS.HEADER_SERVER)
    configuration_options[#configuration_options + 1] = MakeOption("NOEPIC", nil, false)
    configuration_options[#configuration_options + 1] = MakeHeader(STRINGS.HEADER_CLIENT, true)
    configuration_options[#configuration_options + 1] = MakeOption("FRAME_PHASES", nil, true, true)
    configuration_options[#configuration_options + 1] = MakeOption("DAMAGE_NUMBERS", nil, true, true)
    configuration_options[#configuration_options + 1] = MakeOption("DAMAGE_RESISTANCE", nil, true, true)
    configuration_options[#configuration_options + 1] = MakeOption("WETNESS_METER", nil, false, true)
    configuration_options[#configuration_options + 1] = MakeOption("HORIZONTAL_OFFSET", HORIZONTAL_OFFSET_OPTIONS, 0, true)
    configuration_options[#configuration_options + 1] = MakeOption("NONOEPIC", nil, false, true)

end
SetLocale(locale)

function SetLocaleMod(env)
    if env.TheNet:IsDedicated() then
        return
    end

    local locale = env.LanguageTranslator.defaultlang or env.TheNet:GetLanguageCode()
    if env.type(locale) == "string" then
        SetLocale(locale, env)
    end

    if env.IsInFrontEnd() then
        return
    end

    if STRINGS.COMMANDS then
        for name, alias in env.pairs(STRINGS.COMMANDS) do
            local data = env.require("usercommands").GetCommandFromName(name)
            data.displayname = alias
            data.aliases[#data.aliases + 1] = alias
            env.AddUserCommand(name, data)
        end
    end
    if STRINGS.LOADING_TIPS then
        local tab = { username = env.TheNet:GetLocalUserName() }
        for id, tip in env.pairs(STRINGS.LOADING_TIPS) do
            local category = "LOADING_SCREEN_" .. id:match("%a+") .. "_TIPS"
            local key = "EPICHEALTHBAR" .. (id:match("%d+") or "")
            env.AddLoadingTip(env.STRINGS.UI[category], key, env.subfmt(tip, tab))
        end
    end
end
---纯净辅助
configuration_options[#configuration_options + 1] = AddOptionHeader("微小游戏体验提升")
configuration_options[#configuration_options + 1] = AddOption("little_modify_for_pure_switch", "总开关", "一些提升纯净档的微小功能", false)
configuration_options[#configuration_options + 1] = AddOption("show_bundle_content_switch", "显示包裹内的东西(慎用)", "可以看到打包内的东西，提升一点体验，只会显示包裹内前四个东西", false)
configuration_options[#configuration_options + 1] = AddOption("smart_unwrap_bundle_switch", "拆包裹进入物品栏", "拆开包裹会进物品栏或箱子而不是掉落在地上", false)
configuration_options[#configuration_options + 1] = AddOption("combinable_equipment_switch", "装备耐久合并", "同类装备可以互相合并耐久", false)
configuration_options[#configuration_options + 1] = AddOption("naming_for_watches_switch", "旺达表可以命名", "旺达的溯源表和裂缝表可以用羽毛笔命名", false)
configuration_options[#configuration_options + 1] = AddOption("glommer_statue_repairable_switch", "格罗姆雕像可修复", "可以用大理石修复格罗姆雕像", false)
configuration_options[#configuration_options + 1] = AddOption("block_pooping_switch", "橡胶塞堵住牛屁股", "橡胶塞可以堵住牛屁股使其不拉屎", false)
configuration_options[#configuration_options + 1] = AddOption("faster_trading_switch", "猪王快速交易", "和猪王快速交易,有格子的那种", false)
configuration_options[#configuration_options + 1] = AddOption("faster_trading_for_multi_switch", "快速交易", "猪王、鸟笼、蚁狮都可快速交易\n前一个选项开启，此选项不生效", false)
configuration_options[#configuration_options + 1] = AddOption("limit_ripening_plant_switch", "限制催熟频率", "放置催熟过快导致的刷卡服务器", false)
configuration_options[#configuration_options + 1] = AddConfigOption("ripening_plant_frequency", "催熟频率", "设置催熟的频率\n每阶段都限制", { { description = "不限制", data = 0 }, { description = "10秒", data = 10 }, { description = "20秒", data = 20 }, { description = "30秒", data = 30 }, { description = "1分钟", data = 60 }, { description = "2分钟", data = 120 }, { description = "4分钟", data = 240 }, { description = "1天", data = 480 }, { description = "2天", data = 960 }, { description = "不允许催熟", data = 999999 } }, 60)
configuration_options[#configuration_options + 1] = AddOption("more_crafting_details_switch", "制作栏显示更多信息", "制作前就能显示部分信息", false)
configuration_options[#configuration_options + 1] = AddConfigOption("CREATURE_DIE_TIME", "亮茄死亡时间", "亮茄死亡时间\n time of Deadly Brightshade death", { { description = "关闭", data = false, hover = "原版设定" },
                                                                                                                                                              { description = "马上死", data = 0, hover = "immediately" },
                                                                                                                                                              { description = "10秒", data = 10, hover = "10sec" },
                                                                                                                                                              { description = "1分钟", data = 60, hover = "1min" },
                                                                                                                                                              { description = "2分钟", data = 60 * 2, hover = "2min" },
                                                                                                                                                              { description = "3分钟", data = 60 * 3, hover = "3min" },
                                                                                                                                                              { description = "5分钟", data = 60 * 5, hover = "5min" },
                                                                                                                                                              { description = "一天（8分钟）", data = 60 * 8, hover = "1d(8min)" },
                                                                                                                                                              { description = "两天（16分钟）", data = 60 * 16, hover = "2d(16min)" },
                                                                                                                                                              { description = "三天（24分钟）", data = 60 * 24, hover = "3d(24min)" },
                                                                                                                                                              { description = "四天（32分钟）", data = 60 * 32, hover = "4d(32min)" },
                                                                                                                                                              { description = "五天（40分钟）", data = 60 * 40, hover = "5d(40min)" },
                                                                                                                                                              { description = "六天（48分钟）", data = 60 * 48, hover = "6d(48min)" },
                                                                                                                                                              { description = "七天（56分钟）", data = 60 * 56, hover = "7d(56min)" },
                                                                                                                                                              { description = "八天（64分钟）", data = 60 * 64, hover = "8d(64min)" },
                                                                                                                                                              { description = "九天（72分钟）", data = 60 * 72, hover = "9d(72min)" },
                                                                                                                                                              { description = "十天（80分钟）", data = 60 * 80, hover = "10d(80min)" }, }, false)
local beefalo_status_bar_colors = { { name = "ORANGE", description = "Orange(橘色)" }, { name = "ORANGE_ALT", description = "Orange Alt(橘色高亮)" }, { name = "BLUE", description = "Blue(蓝色)" }, { name = "BLUE_ALT", description = "Blue Alt(蓝色高亮)" }, { name = "PURPLE", description = "Purple(紫色)" }, { name = "PURPLE_ALT", description = "Purple Alt(紫色高亮)" }, { name = "RED", description = "Red(红色)" }, { name = "RED_ALT", description = "Red Alt(红色高亮)" }, { name = "GREEN", description = "Green(绿色)" }, { name = "GREEN_ALT", description = "Green Alt(绿色高亮)" }, { name = "WHITE", description = "White(白色)" }, { name = "YELLOW", description = "Yellow(白色高亮)" } }

local function GenerateCommonOptions(start, count, step, default, prefix, suffix)
    local options = {}
    local current = start
    local suffix_l = suffix or ""
    for i = 1, count do
        local prefix_l = prefix and (current > 0 and "+" or "") or ""
        options[i] = { description = prefix_l .. current .. suffix_l, data = current }
        if current == default then
            options[i].hover = "Default"
        end
        current = current + step
    end
    return options
end

local function GenerateMultiplierOptions()
    local options = {}
    for i = 1, 20 do
        if i ~= 1 then
            options[i] = { description = "x" .. i, data = i }
        else
            options[i] = { description = "None", data = i, hover = "Default" }
        end
    end
    return options
end

local function GenerateColorOptions(default)
    local colorOptions = {}
    for i = 1, #beefalo_status_bar_colors do
        colorOptions[i] = { description = beefalo_status_bar_colors[i].description, data = beefalo_status_bar_colors[i].name }
        if default == beefalo_status_bar_colors[i].name then
            colorOptions[i].hover = "Default"
        end
    end
    return colorOptions
end

local offsets = GenerateCommonOptions(-200, 81, 5, 0, true)
local fineOffsets = GenerateCommonOptions(-50, 101, 1, 0, true)
local offsetMultipliers = GenerateMultiplierOptions()
configuration_options[#configuration_options + 1] = AddOptionHeader("驯牛状态显示")
configuration_options[#configuration_options + 1] = AddOption("beefalo_status_bar_switch", "总开关", "是否开启驯牛状态显示", false)
configuration_options[#configuration_options + 1] = AddOption("ShowByDefault", "驯牛状态自动显示(Show Automatically)", "驯牛状态栏自动显示\nShow the status bar automatically when you mount a beefalo.", true)
configuration_options[#configuration_options + 1] = AddConfigOption("ToggleKey", "驯牛显示快捷键(Toggle Key)", "Press this key (when mounted) to toggle the status bar.\nToggling will override \"Show Automatically\" for the current shard session.",
        { { description = "T", data = "KEY_T" },
          { description = "O", data = "KEY_O" },
          { description = "P", data = "KEY_P" },
          { description = "G", data = "KEY_G" },
          { description = "H", data = "KEY_H" },
          { description = "Z", data = "KEY_Z" },
          { description = "X", data = "KEY_X" },
          { description = "C", data = "KEY_C" },
          { description = "V", data = "KEY_V", hover = "Default" },
          { description = "B", data = "KEY_B" } }, "KEY_V")
configuration_options[#configuration_options + 1] = AddOption("EnableSounds", "声音(Sounds)", "开关显示有声音\nPlay a sound when showing or hiding the status bar.", false)

configuration_options[#configuration_options + 1] = {
    name = "ClientConfig",
    label = "客户端偏好设置(Prefer Client Configuration)",
    hover = "开启的话服务端配置会忽略\nWhen enabled, server configuration will be ignored.\nConfigurations from this screen will be used on every server you join or host.",
    options = {
        { description = "关闭(Disabled)", data = false, hover = "Default" },
        { description = "开启(Enabled)", data = true }
    },
    default = false,
    client = true
}
configuration_options[#configuration_options + 1] = AddConfigOption("Theme", "主题(Theme)", "切换状态栏的主题\nChange the theme of the badges.",
        { { description = "熔炉主题(The Forge)", data = "TheForge", hover = "熔炉主题(The Forge)" },
          { description = "默认主题(Default Theme)", data = "Default", hover = "默认\nUses the default game theme. Compatible with most HUD reskin mods." }
        }, "TheForge")

configuration_options[#configuration_options + 1] = AddConfigOption("Scale", "放缩(Scale)", "放缩\nControls the scale (size) of the badges.",
        {
            { description = "0.5", data = 0.5 },
            { description = "0.6", data = 0.6 },
            { description = "0.7", data = 0.7 },
            { description = "0.8", data = 0.8 },
            { description = "0.9", data = 0.9 },
            { description = "1", data = 1.0, hover = "Default" },
            { description = "1.1", data = 1.1 },
            { description = "1.2", data = 1.2 },
            { description = "1.3", data = 1.3 },
            { description = "1.4", data = 1.4 },
            { description = "1.5", data = 1.5 },
            { description = "1.6", data = 1.6 },
            { description = "1.7", data = 1.7 },
            { description = "1.8", data = 1.8 },
            { description = "1.9", data = 1.9 },
            { description = "2.0", data = 2.0 }
        }, 1.0)

configuration_options[#configuration_options + 1] = AddConfigOption("HungerThreshold", "饥饿阈值(Hunger Badge Threshold)", "饥饿触发状态栏\nA beefalo needs to have at least this amount of hunger to activate the badge.",
        GenerateCommonOptions(5, 30, 5, 10, false), 10)
configuration_options[#configuration_options + 1] = AddConfigOption("HEALTH_BADGE_CLEAR_BG", "背景(Health Badge Background)", "检测：亮度和透明度设置不生效\n标准：亮度和透明度设置可以生效\nDistinct: Uses a distinct background. Brightness and opacity will not apply.\nStandard: Uses a standard background. Brightness and opacity will apply.",
        { { description = "检测(Distinct)", data = false, hover = "Default" },
          { description = "标准(Standard)", data = true } }, false)
configuration_options[#configuration_options + 1] = AddConfigOption("BADGE_BG_BRIGHTNESS", "背景亮度(Background Brightness)", "控制显示亮度\nControls the background brightness of the badges.",
        GenerateCommonOptions(5, 21, 5, 60, false, "%"), 60)
configuration_options[#configuration_options + 1] = AddConfigOption("BADGE_BG_OPACITY", "背景透明度(Background Opacity)", "控制透明度\nControls the background opacity (transparency) of the badges.\n100% - No transparency, 0% - Fully transparent.",
        GenerateCommonOptions(0, 21, 5, 100, false, "%"), 100)
configuration_options[#configuration_options + 1] = AddConfigOption("GapModifier", "间隙修改(Gap Modifier)", "控制空白间隙\nControls the empty space between the badges.\n Negative values - less space, positive values - more space.",
        GenerateCommonOptions(-15, 46, 1, 0, true), 0)

configuration_options[#configuration_options + 1] = AddConfigOption("COLOR_DOMESTICATION_ORNERY", "驯养-生气-颜色[Domestication (Ornery)]", "Domestication badge color for Ornery beefalo.",
        GenerateColorOptions("ORANGE"), "ORANGE")
configuration_options[#configuration_options + 1] = AddConfigOption("COLOR_DOMESTICATION_RIDER", "驯养-骑-颜色[Domestication (Rider)]", "Domestication badge color for Rider beefalo.",
        GenerateColorOptions("BLUE"), "BLUE")
configuration_options[#configuration_options + 1] = AddConfigOption("COLOR_DOMESTICATION_PUDGY", "驯养-肥胖-颜色[Domestication (Pudgy)]", "Domestication badge color for Pudgy beefalo.",
        GenerateColorOptions("PURPLE"), "PURPLE")
configuration_options[#configuration_options + 1] = AddConfigOption("COLOR_DOMESTICATION_DEFAULT", "驯养-默认-颜色[Domestication (Default)]", "Domestication badge color for Default beefalo.",
        GenerateColorOptions("WHITE"), "WHITE")
configuration_options[#configuration_options + 1] = AddConfigOption("COLOR_OBEDIENCE", "服从-颜色(Obedience)", "Obedience badge color.",
        GenerateColorOptions("RED"), "RED")
configuration_options[#configuration_options + 1] = AddConfigOption("COLOR_TIMER", "骑计时器-颜色(Ride Timer)", "Ride Timer badge color.",
        GenerateColorOptions("GREEN"), "GREEN")
configuration_options[#configuration_options + 1] = AddConfigOption("OffsetX", "位置偏移X(X Offset (Horizontal))", "负数左移正数右移\nNegative values - move left, positive values - move right.",
        offsets, 0)
configuration_options[#configuration_options + 1] = AddConfigOption("OffsetXMult", "位置偏移X倍数(X Offset Multiplier)", "X偏移倍数\nMultiplier for the \"X Offset\" setting.\nHas no effect on the \"Fine Tune\" setting.",
        offsetMultipliers, 1)
configuration_options[#configuration_options + 1] = AddConfigOption("OffsetXFine", "位置偏移X精调(X Offset Fine Tune)", "X精调\nFine tune X Offset",
        fineOffsets, 0)
configuration_options[#configuration_options + 1] = AddConfigOption("OffsetY", "位置偏移Y(Y Offset (Vertical))", "负数下移正数上移\nNegative values - move down, positive values - move up.",
        offsets, 0)
configuration_options[#configuration_options + 1] = AddConfigOption("OffsetYMult", "位置偏移Y倍数(Y Offset Multiplier)", "X偏移倍数\nMultiplier for the \"Y Offset\" setting.\nHas no effect on the \"Fine Tune\" setting.",
        offsetMultipliers, 1)
configuration_options[#configuration_options + 1] = AddConfigOption("OffsetYFine", "位置偏移Y精调(Y Offset Fine Tune)", "X精调\nFine tune Y Offset",
        fineOffsets, 0)

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
--移到公用池
--configuration_options[#configuration_options + 1] = AddOption("player_authority_stack", "#stack指令", "输入指令自动堆叠玩家范围内的物品", true)
configuration_options[#configuration_options + 1] = AddOption("player_authority_SaveInfo", "主世界换人保留全部数据", "支持#restart，其它世界换人不保留数据", true)
configuration_options[#configuration_options + 1] = AddOption("player_authority_adduserid", "装备绑定", "使用暗影之心绑定", true)
configuration_options[#configuration_options + 1] = AddOption("player_authority_canburnable", "有权限建筑防止一切物品的恶意燃烧", "目前在测试阶段，只有火把能点燃建筑", false)

---河蟹防熊，与上面防熊不可同时开
configuration_options[#configuration_options + 1] = AddOptionHeader("河蟹防熊锁")
configuration_options[#configuration_options + 1] = AddOption("authority_hexie_switch", "总开关", "河蟹防熊锁", false)
configuration_options[#configuration_options + 1] = AddConfigOption("test_mode", "测试模式", "",
        {
            { description = "是", data = true, hover = "开启测试模式" },
            { description = "否", data = false, hover = "关闭测试模式" } }, false)
configuration_options[#configuration_options + 1] = AddConfigOption("permission_mode", "权限保护模式", "",
        { { description = "是", data = true, hover = "开启防熊相关权限验证功能" },
          { description = "否", data = false, hover = "关闭防熊相关权限验证功能\n(关闭后所有有权限的物品失去保护)" } }, true)
configuration_options[#configuration_options + 1] = AddConfigOption("authority_hexie_language", "选择语言风格", "",
        { { description = "正常版", data = "normal", hover = "正常" },
          { description = "红猪欢乐版", data = "redpig_fun", hover = "欢乐" } }, "normal")
--configuration_options[#configuration_options + 1] = AddConfigOption("give_start_item", "是否给玩家初始物品", "", { {description = "是", data = true, hover = "给予玩家一些有利于当前环境生存的初始物品"}, {description = "否", data = false, hover = "否"} }, false)
configuration_options[#configuration_options + 1] = AddConfigOption("door_lock", "木门增强", "",
        { { description = "有权限控制", data = "111", hover = "木门有权限的玩家才能砸和打开，免疫怪物伤害" },
          { description = "有权限控制2", data = "101", hover = "木门有权限的玩家才能砸和打开，怪物可摧毁" },
          { description = "部分权限控制", data = "110", hover = "木门有权限的玩家才能砸，任何玩家都能打开，免疫怪物伤害" },
          { description = "部分权限控制2", data = "100", hover = "木门有权限的玩家才能砸，任何玩家都能打开，怪物可摧毁" },
          { description = "无权限控制", data = "010", hover = "木门任何玩家都能砸和打开，免疫怪物伤害" },
          { description = "关闭", data = "000", hover = "关闭" } }, "000")
configuration_options[#configuration_options + 1] = AddConfigOption("fence_lock", "木栅栏增强", "",
        { { description = "有权限控制", data = "111", hover = "木栅栏有权限的玩家才能砸，免疫怪物伤害" },
          { description = "有权限控制2", data = "101", hover = "木栅栏有权限的玩家才能砸，怪物可摧毁" },
          { description = "关闭", data = "000", hover = "关闭" } }, "000")
configuration_options[#configuration_options + 1] = AddConfigOption("wall_hay_lock", "草墙增强", "",
        { { description = "有权限控制", data = "111", hover = "草墙有权限的玩家才能砸，免疫怪物伤害" },
          { description = "有权限控制2", data = "101", hover = "草墙有权限的玩家才能砸，怪物可摧毁" },
          { description = "关闭", data = "000", hover = "关闭" } }, "000")
configuration_options[#configuration_options + 1] = AddConfigOption("wall_wood_lock", "木墙增强", "",
        { { description = "有权限控制", data = "111", hover = "木墙有权限的玩家才能砸，免疫怪物伤害" },
          { description = "有权限控制2", data = "101", hover = "木墙有权限的玩家才能砸，怪物可摧毁" },
          { description = "关闭", data = "000", hover = "关闭" } }, "000")
configuration_options[#configuration_options + 1] = AddConfigOption("wall_stone_lock", "石墙增强", "",
        { { description = "有权限控制", data = "111", hover = "石墙有权限的玩家才能砸，免疫怪物伤害" },
          { description = "有权限控制2", data = "101", hover = "石墙有权限的玩家才能砸，怪物可摧毁" },
          { description = "关闭", data = "000", hover = "关闭" } }, "000")
configuration_options[#configuration_options + 1] = AddConfigOption("wall_ruins_lock", "铥矿墙增强", "",
        { { description = "有权限控制", data = "111", hover = "铥矿墙有权限的玩家才能砸，免疫怪物伤害" },
          { description = "有权限控制2", data = "101", hover = "铥矿墙有权限的玩家才能砸，怪物可摧毁" },
          { description = "关闭", data = "000", hover = "关闭" } }, "000")
configuration_options[#configuration_options + 1] = AddConfigOption("wall_moonrock_lock", "月石墙增强", "",
        { { description = "有权限控制", data = "111", hover = "月石墙有权限的玩家才能砸，免疫怪物伤害" },
          { description = "有权限控制2", data = "101", hover = "月石墙有权限的玩家才能砸，怪物可摧毁" },
          { description = "关闭", data = "000", hover = "关闭" } }, "000")
configuration_options[#configuration_options + 1] = AddConfigOption("cant_destroyby_monster", "防止怪物摧毁建筑", "",
        { { description = "开启", data = true, hover = "开启，门和墙体为单独设置" },
          { description = "关闭", data = false, hover = "为了更全面的游戏体验，建议关闭，门和墙体为单独设置" } }, false)
configuration_options[#configuration_options + 1] = AddConfigOption("firesuppressor_dig", "防止农作物被挖范围", "",
        { { description = "50码", data = 50 },
          { description = "40码", data = 40 },
          { description = "30码", data = 30, hover = "农作物与自己建筑之间的距离" },
          { description = "25码", data = 25 },
          { description = "20码", data = 20 },
          { description = "15码", data = 15 },
          { description = "10码", data = 10 },
          { description = "5码", data = 5 },
          { description = "关闭", data = -1 } }, 30)
configuration_options[#configuration_options + 1] = AddConfigOption("near_no_permission", "重要地点附近建造的东西无权限", "",
        { { description = "开启", data = true, hover = "猪王、出生门等地点附近建造的东西没有权限" },
          { description = "关闭", data = false } }, true)
configuration_options[#configuration_options + 1] = AddConfigOption("is_allow_build_near", "防止别人造违规建筑", "",
        { { description = "开启", data = false, hover = "不允许未授权的玩家在自己家附近造建筑" },
          { description = "关闭", data = true } }, true)
configuration_options[#configuration_options + 1] = AddConfigOption("admin_option", "管理员受权限控制", "",
        { { description = "受", data = false, hover = "服务器管理员受权限控制" },
          { description = "不受", data = true, hover = "服务器管理员不受权限控制" } }, true)
configuration_options[#configuration_options + 1] = AddConfigOption("remove_owner_time", "玩家离线自动解锁的时间", "",
        { { description = "40分钟", data = 2400 },
          { description = "1小时", data = 3600 },
          { description = "3小时", data = 10800 },
          { description = "9小时", data = 32400 },
          { description = "24小时", data = 86400 },
          { description = "3天", data = 259200 },
          { description = "7天", data = 604800 },
          { description = "14天", data = 1209600 },
          { description = "永远不解锁", data = "never", hover = "玩家离开游戏后，其所有物的自动解锁时间" } }, "never")
configuration_options[#configuration_options + 1] = AddConfigOption("spread_fire", "火焰蔓延半径", "",
        { { description = "不蔓延", data = 0 },
          { description = "一半半径", data = 1, hover = "游戏中火焰的蔓延范围，防止大火烧山" },
          { description = "正常半径", data = 2 } }, 1)
configuration_options[#configuration_options + 1] = AddConfigOption("beefalo_power", "牛增强", "",
        { { description = "开启", data = true, hover = "防止服从度大于0的牛抖落鞍或主人，并且当牛有主人时防御增强" },
          { description = "关闭", data = false } }, false)
--移入公共指令池
--configuration_options[#configuration_options + 1] = AddConfigOption("auto_stack", "掉落自动堆叠", "", { {description = "开启", data = true, hover = "猪王/喂鸟/挖矿/砍树等掉落物品自动堆叠"}, {description = "关闭", data = false} }, true)
configuration_options[#configuration_options + 1] = AddConfigOption("minotaur_regenerate", "远古犀牛刷新时间", "",
        { { description = "10天", data = 10, hover = "远古犀牛死亡10天后刷新" },
          { description = "20天", data = 20, hover = "远古犀牛死亡20天后刷新" },
          { description = "30天", data = 30, hover = "远古犀牛死亡30天后刷新" },
          { description = "40天", data = 40, hover = "远古犀牛死亡40天后刷新" },
          { description = "50天", data = 50, hover = "远古犀牛死亡50天后刷新" },
          { description = "60天", data = 60, hover = "远古犀牛死亡60天后刷新" },
          { description = "70天", data = 70, hover = "远古犀牛死亡70天后刷新" },
          { description = "80天", data = 80, hover = "远古犀牛死亡80天后刷新" },
          { description = "90天", data = 90, hover = "远古犀牛死亡90天后刷新" },
          { description = "100天", data = 100, hover = "远古犀牛死亡100天后刷新" },
          { description = "关闭", data = -1 } }, 30)
configuration_options[#configuration_options + 1] = AddConfigOption("minotaur_destroy", "远古犀牛可拆毁建筑", "",
        { { description = "开启", data = true, hover = "在开启防止怪物摧毁建筑时允许犀牛拆毁建筑,建筑不包括墙类" },
          { description = "关闭", data = false } }, false)
configuration_options[#configuration_options + 1] = AddConfigOption("ancient_altar_no_destroy", "远古祭坛防止拆毁", "",
        { { description = "开启", data = true, hover = "防止远古祭坛被玩家破坏" },
          { description = "关闭", data = false } }, false)
configuration_options[#configuration_options + 1] = AddConfigOption("house_plain_nodestroy", "野外猪人兔人鱼人房防拆毁", "",
        { { description = "开启", data = true, hover = "防止野外猪人兔人房被玩家破坏" },
          { description = "关闭", data = false } }, false)
configuration_options[#configuration_options + 1] = AddConfigOption("zhizhu_cuihui", "地下蜘蛛巢穴防拆毁", "",
        { { description = "开启", data = true, hover = "防止蜘蛛巢被玩家破坏" },
          { description = "关闭", data = false } }, false)
--[[
configuration_options[#configuration_options + 1] = AddConfigOption("clean_level", "清理级别", "",
        { {description = "非常高", data = 1, hover = "贫瘠"},
            {description = "高", data = 2, hover = "略微贫瘠"},
            {description = "中", data = 3, hover = "普通"},
            {description = "低", data = 4, hover = "略微富饶"},
            {description = "非常低", data = 5, hover = "富饶"},
            {description = "关闭", data = -1} }, -1)
configuration_options[#configuration_options + 1] = AddConfigOption("clean_period", "清理周期", "此选项只有在开启[清理级别]选项后有效",
        { {description = "非常短", data = 1, hover = "1天"},
            {description = "短", data = 5, hover = "5天"},
            {description = "普通", data = 10, hover = "10天"},
            {description = "长", data = 15, hover = "15天"},
            {description = "非常长", data = 20, hover = "20天"} }, 10)

-- 自定义物品清理
configuration_options[#configuration_options + 1] = {
    name = "clean_custom",
    -- 配置为 名称:数量
    -- 如 bearger:1|deerclops:1
    default = ""
}
]]

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
configuration_options[#configuration_options + 1] = AddConfigOption("START_COIN_IN_SIMPLE_ECONOMY", "简单经济学启动资金", "",
        { { description = "不额外赠送", data = false, hover = "None" },
          { description = "100", data = 100 },
          { description = "200", data = 200 },
          { description = "300", data = 300 },
          { description = "500", data = 500 },
          { description = "800", data = 800 },
          { description = "1000", data = 1000 },
          { description = "2000", data = 2000 },
          { description = "3000", data = 3000 },
          { description = "5000", data = 5000 },
          { description = "8000", data = 8000 },
          { description = "1W", data = 10000 },
          { description = "2W", data = 20000 },
          { description = "3W", data = 30000 },
          { description = "5W", data = 50000 },
          { description = "8W", data = 80000 },
          { description = "10W", data = 100000 },
          { description = "20W", data = 200000 },
          { description = "30W", data = 300000 },
          { description = "50W", data = 500000 },
          { description = "80W", data = 800000 },
          { description = "100W", data = 1000000 },
          { description = "200W", data = 2000000 },
          { description = "300W", data = 3000000 },
          { description = "500W", data = 5000000 },
          { description = "800W", data = 8000000 },
          { description = "1000W", data = 10000000 },
        }, false)

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
    { name = "squidamulet", label = "鱿鱼的庇护", default = 0 },
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
configuration_options[#configuration_options + 1] = AddOption("ui_button_badge_craftmenu", "制作栏支持", "制作栏可以拖拽镜像", true)
configuration_options[#configuration_options + 1] = AddOption("ui_button_badge_remember", "记住UI改动", "", false)
configuration_options[#configuration_options + 1] = AddOption("ui_button_badge_tooltip", "显示提示文本", "", true)

---Beta功能
configuration_options[#configuration_options + 1] = AddOptionHeader("Beta功能(非必要可选择关闭)")
configuration_options[#configuration_options + 1] = AddOption("beta_function_switch", "总开关", "是否开启Beta的一些功能", true)

--configuration_options[#configuration_options + 1] = AddOption("medal_ab_drrn_patches_switch", "装备栏优化", "对于开 阿比 度日如年 玩家物品栏 勋章栏异常的权宜之计", true)
--configuration_options[#configuration_options + 1] = AddOption("repeat_death_fix", "鞭尸修复", "修复鞭尸怪物(理论上应该也能阻止玩家被鞭尸)", true)
configuration_options[#configuration_options + 1] = AddOption("container_open_dont_drop_switch", "容器打开不掉落", "打开需要掉落的容器不再掉落", false)
configuration_options[#configuration_options + 1] = AddOption("container_sort_switch", "容器物品排序", "容器/箱子里面的物品自动排序\n妈妈再也不担心箱子乱七八糟了", false)
configuration_options[#configuration_options + 1] = AddConfigOption("container_organize_preference", "容器整理", "可以整理物品栏和背包哦", { { description = "默认", data = true },
                                                                                                                                             { description = "禁用", data = false },
                                                                                                                                             { description = "部分", data = -1 },
                                                                                                                                             { description = "全部开启", data = -2 }, }, true)
--configuration_options[#configuration_options + 1] = AddOption("fix_tags_overflow_switch", "标签溢出问题", "修复标签溢出问题", true)
configuration_options[#configuration_options + 1] = AddConfigOption("fix_tags_overflow_switch", "标签溢出问题", "修复标签溢出问题",
        { { description = "关闭", data = false }, { description = "更多标签-方式1", data = 1 }, { description = "标签优化-方式2", data = 2 } }, 1)

configuration_options[#configuration_options + 1] = AddOption("give_item_optimize_switch", "拾取优化", "自动寻找打开的容器进行放入", false)
configuration_options[#configuration_options + 1] = AddOption("fix_heap_of_food_switch", "修复HeapOfFood问题", "修复HeapOfFood问题", false)
configuration_options[#configuration_options + 1] = AddOption("fix_migration_data_lost_switch", "修复跳世界数据丢失问题", "修复跳世界数据丢失导致重选人物问题", true)
--configuration_options[#configuration_options + 1] = AddOption("fix_medal_conflict_with_other_mod_switch", "修复勋章跟其他mod一些冲突", "修复勋章跟其他mod一些冲突", true)
configuration_options[#configuration_options + 1] = AddOption("blueprint_error_fix_switch", "蓝图问题修复", "世界蓝图可能存在的问题", true)
configuration_options[#configuration_options + 1] = AddOption("heap_of_food_chs_language_switch", "HeapOfFood汉化(简中)", "HeapOfFood汉化(简中)", false)
configuration_options[#configuration_options + 1] = AddOption("vtf_chs_language_switch", "情人节主题物品汉化(简中)", "情人节主题物品汉化(简中)", false)
configuration_options[#configuration_options + 1] = AddOption("htf_chs_language_switch", "万圣节主题物品汉化(简中)", "万圣节主题物品汉化(简中)", false)
configuration_options[#configuration_options + 1] = AddOption("dont_starve_dehydrated_chs_language_switch", "新喝水系统汉化(简中)", "新喝水系统汉化(简中)", false)
configuration_options[#configuration_options + 1] = AddOption("the_lamb_chs_language_switch", "the lamb(咩咩教主)汉化", "the lamb(咩咩教主)汉化(简中)", false)
--configuration_options[#configuration_options + 1] = AddOption("the_lamb_bug_fix_switch", "the lamb(咩咩教主)问题修复", "the lamb(咩咩教主)问题修复", false)
configuration_options[#configuration_options + 1] = AddOption("world_time_speed_to_normal", "世界时间流速自动归位", "一定程度阻止玩家企图篡改世界时间流速", false)
configuration_options[#configuration_options + 1] = AddOption("smarter_find_road_switch", "寻路补丁", "优化跟随物的寻路AI", false)

--取消世界同步
configuration_options[#configuration_options + 1] = AddOptionHeader("取消从世界与主世界部分同步")
configuration_options[#configuration_options + 1] = AddOption("cancel_sync_cycles_with_master_switch", "取消世界季节时间阶段种类同步", "不同世界享有不同季节时钟，日/暮/夜独立", false)
configuration_options[#configuration_options + 1] = AddOption("time_sync_with_master", "时间同步", "开启:与主世界天数一致\n 关闭:独立的天数计量", true)
configuration_options[#configuration_options + 1] = AddOptionHeader("单世界特殊设置")
configuration_options[#configuration_options + 1] = AddOption("word_migrate_drop_sync_switch", "世界物品不可带出", "开启后，世界种的物品只能带进不能带出", false)
--character_word_forbidden
configuration_options[#configuration_options + 1] = AddConfigOption("character_word_forbidden_option", "禁止一些角色进入某个世界", "防止重选角色发生\n特殊服务器使用，一般选择关闭",
        { { description = "关闭", data = false }, { description = "自由配置", data = character_word_forbidden } }, false)

-----------------------------------可升级容器内容---------------------------------------------
configuration_options[#configuration_options + 1] = AddOptionHeader("")
configuration_options[#configuration_options + 1] = AddOptionHeader("可升级容器")
configuration_options[#configuration_options + 1] = AddOption("upgrade_container_switch", "总开关", "是否开启可升级容器", false)

local lang = locale
if locale == "zht" then
    lang = "zh"
elseif locale == "br" then
    lang = "pt"
end

local function AddOptionShort(data, description, hover)
    return { description = description, data = data, hover = hover }
end
local BoolOptTrans = {
    ["en"] = {
        AddOptionShort(false, "no"),
        AddOptionShort(true, "yes"),
    },
    ["zh"] = {
        AddOptionShort(false, "否"),
        AddOptionShort(true, "是"),
    },
    ["pt"] = {
        AddOptionShort(false, "Não"),
        AddOptionShort(true, "Sim"),
    },
}
local BoolOpt = BoolOptTrans[lang] or BoolOptTrans["en"]
local function AddHoverBoolOpt(hovertrue, hoverfalse)
    local optfalse = hoverfalse and AddOptionShort(false, BoolOpt[1].description, hoverfalse) or BoolOpt[1]
    local opttrue = hovertrue and AddOptionShort(true, BoolOpt[2].description, hovertrue) or BoolOpt[2]
    return { optfalse, opttrue }
end

local function AddNewConfig(name, label, default, options, hover, client)
    configuration_options[#configuration_options + 1] = { name = name, label = label, hover = hover, options = options, default = default, client = client }
end

--local function isTable(arg)
--    return arg[1] ~= nil
--end

if lang == "zh" then
    AddNewConfig("MAX_LV", "等级上限", 9,
            {
                AddOptionShort(3, "直到3x3", "为什么你用这个模组"),
                AddOptionShort(5, "直到5x5", "可以升级 1 次"),
                AddOptionShort(7, "直到7x7", "可以升级 2 次"),
                AddOptionShort(9, "直到9x9", "可以升级 3 次"),
                AddOptionShort(11, "直到11x11", "可以升级 4 次"),
                AddOptionShort(13, "直到13x13", "可以升级 5 次"),
                AddOptionShort(63, "无限", "想挑战上限？接受挑战"), })

    configuration_options[#configuration_options + 1] = AddOptionHeader("进阶选项:")

    AddNewConfig("UPG_MODE", "升级模式", 1,
            {
                AddOptionShort(1, "普通模式", "升级材料放最外圈储存格"),
                AddOptionShort(2, "复杂模式", "升级材料放最右列 / 最下行储存格以进行横向 / 纵向升级"),
                AddOptionShort(3, "混合模式", "我全都要"),
            }, "变更升级模式")
    AddNewConfig("PAGEABLE", "翻页升级", false,
            AddHoverBoolOpt("满级以后，把升级材料放满第 1 页"),
            "让箱子可翻页的升级")
    AddNewConfig("BACKPACK", "背包可升级", false,
            AddHoverBoolOpt("把升级材料放满第 1 页"))
    AddNewConfig("CHANGESIZE", "改变大小", false, BoolOpt, "根据箱子等级改变箱子大小")

    configuration_options[#configuration_options + 1] = AddOptionHeader("可升级的容器:")

    AddNewConfig("C_TREASURECHEST", "Chest", true, AddHoverBoolOpt("1 木板到每一个最外层储存格"))
    AddNewConfig("C_ICEBOX", "冰箱", true, AddHoverBoolOpt("1 齿轮到每一个最上层储存格，1 石砖到其他最外层储存格"))
    AddNewConfig("C_SALTBOX", "盐盒", true, AddHoverBoolOpt("1 盐晶到每一个最外层储存格，1 蓝宝石到最中间储存格"))
    AddNewConfig("C_DRAGONFLYCHEST", "龙鳞宝箱", true, AddHoverBoolOpt("1 木板到每一个最外层储存格"))
    AddNewConfig("C_FISH_BOX", "锡鱼罐", true, AddHoverBoolOpt("1 绳子到每一个最外层储存格"))
    AddNewConfig("C_BOOKSTATION", "书架", false, AddHoverBoolOpt("1 活木到每一个最外层储存格"))
    AddNewConfig("C_TACKLECONTAINER", "钓具箱", false, AddHoverBoolOpt("1 饼干切割机壳到每一个最外层储存格"), "钓具箱 和 超级钓具箱")
    AddNewConfig("C_OCEAN_TRAWLER", "拖网捕鱼器", false, AddHoverBoolOpt("1 邪天翁羽毛到每一个储存格"))
    AddNewConfig("C_SHADOW_CONTAINER", "魔术师的容器", true, AddHoverBoolOpt("1 暗影之心到每一个最外层储存格"), "魔术师的礼帽, 魔术师的盒子, 暗影切斯特")
    AddNewConfig("C_BEARGERFUR_SACK", "极地熊獾桶", true, AddHoverBoolOpt("1 熊皮到每一个最左储存格，1 纯粹辉煌到每一个最外层储存格"), "1 熊皮到每一个最左储存格，1 纯粹辉煌到每一个最外层储存格")
    configuration_options[#configuration_options + 1] = AddOptionHeader("UI设置:")
    AddNewConfig("SHOWGUIDE", "显示升级需求", 2,
            {
                AddOptionShort(0, "永不"),
                AddOptionShort(1, "一直"),
                AddOptionShort(2, "当空", "当箱子为空时显示"),
                AddOptionShort(3, "自动", "当你进行一次升级后，永久关闭显示"),
            }, "为你显示升级所需物品\n不会显示 行/列升级（混合模式） 的需求", true)
    AddNewConfig("SEARCHBAR", "搜索栏", true, BoolOpt, "双击背景显示/隐藏搜索栏", true)
    AddNewConfig("SHOWALLPAGE", "显示所有页数", false, BoolOpt, "(测试中)打开箱子时显示所有页数", true)
    AddNewConfig("UI_WIDGETPOS", "位置", true,
            {
                AddOptionShort(false, "上面", "原版的位置, 人物上方"),
                AddOptionShort(true, "左面", "在人物左边"),
            }, nil, true)
    AddNewConfig("DRAGGABLE", "局部显示组件", false,
            {
                AddOptionShort(false, "关闭"),
                AddOptionShort(3, "3x3", "显示3x3的数量"),
                AddOptionShort(4, "4x4", "显示4x4的数量"),
                AddOptionShort(5, "5x5(建议)", "显示5x5的数量"),
                AddOptionShort(6, "6x6", "显示6x6的数量"),
                AddOptionShort(7, "7x7", "显示7x7的数量"),
            }, nil, true)
    AddNewConfig("PACKSTYLE", "背包样式", true,
            {
                AddOptionShort(false, "合并"),
                AddOptionShort(true, "整页"), }, "\"融合\"背包样式\n只在\"背包可升级\"选项开启时有效", true)
    AddNewConfig("OVERFLOW", "智能分页", true, BoolOpt, "\"融合\" 背包样式\n把溢出的格子挪到下一页", true)
    AddNewConfig("UI_ICEBOX", "冰箱UI左移", true, BoolOpt, "UI左移使UI不会遮挡烹饪锅", true)
    AddNewConfig("DROPALL", "\"清空\"按钮", false, BoolOpt, "一个能把箱子里所有物品扔到地上的按钮", true)
    AddNewConfig("SORTITEM", "\"整理\"按钮", false, BoolOpt, "一个能帮你整理内容物的按钮\n按我的使用习惯做的，未必适合所有人", true)
    AddNewConfig("UI_BGIMAGE", "隐藏UI背景", false, BoolOpt, nil, true)

    configuration_options[#configuration_options + 1] = AddOptionHeader("其他功能:")
    AddNewConfig("EXPENSIVE_BACKPACK", "Expensive Backpack", false,
            AddHoverBoolOpt(
                    "item to all slots for 1 page upgrade",
                    "item to 1st page for 1 page upgrade"
            )
    )
    AddNewConfig("SCALE_FACTOR", "大小比例", 3,
            {
                AddOptionShort(1, "2", "1:2, ie. 6x6箱子2倍大(半径)"),
                AddOptionShort(2, "1.5", "1:1.5, ie. 6x6箱子1.5倍大(半径)"),
                AddOptionShort(3, "1.33", "1:1.33, ie. 6x6箱子1.33倍大(半径)"),
                AddOptionShort(4, "1.25", "1:1.25, ie. 6x6箱子1.25倍大(半径)"),
                AddOptionShort(5, "1.2"),
                AddOptionShort(6, "1.16"),
                AddOptionShort(10, "1.1")
            }, "改变箱子大小的比例\n只在\"改变大小\"选项开启时有效")
    AddNewConfig("BACKPACKPAGE", "背包最大页数", 3,
            {
                AddOptionShort(1, "1"),
                AddOptionShort(2, "2"),
                AddOptionShort(3, "3"),
                AddOptionShort(4, "4"),
                AddOptionShort(5, "5"),
                AddOptionShort(6, "6"),
                AddOptionShort(7, "7"),
                AddOptionShort(8, "8"),
                AddOptionShort(9, "9"),
                AddOptionShort(10, "10"),
                AddOptionShort(11, "11"),
                AddOptionShort(12, "12"),
                AddOptionShort(13, "13"),
                AddOptionShort(14, "14"),
                AddOptionShort(15, "15"), })
    AddNewConfig("ALLCANUPG", "(测试中)全容器升级", false, AddHoverBoolOpt("制作该容器所需材料中消耗最大的材料到每一格最外圈储存格"), "让大部分模组容器也能升级\n不建议用经常玩的档进行测试")
    AddNewConfig("DEGRADABLE", "可降级", true, BoolOpt, "箱子可降级\n放一个锤子进空箱子")
    AddNewConfig("INSIGHT", "Insight资讯", true, BoolOpt, "模组: Insight 会为你显示更多资讯")
    AddNewConfig("UNCOM_MODE", "永不妥协", false, BoolOpt, "调整与 模组: Uncompomising Mode(永不妥协) 同时使用时的设定")
    AddNewConfig("KRAMPUS_ONLY", "仅坎普斯背包", false, BoolOpt, "*禁止* 所有其他背包升级, 除了坎普斯背包\n坎普斯背包升级需求改为 蜡纸 到第 1 页每个格子")
    AddNewConfig("RETURNITEM", "拆除返还材料", false, BoolOpt, "测试中\n拆除时返还升级材料")

    configuration_options[#configuration_options + 1] = AddOptionHeader("除错模式:")
    AddNewConfig("DEBUG_MAXLV", "满级", false, BoolOpt, "容器在建造的时候就已经满级")
    AddNewConfig("DEBUG_IIC", "自带升级材料", false, BoolOpt, "容器在建造时自带升级材料和锤子")
else
    AddNewConfig("MAX_LV", "Max upgrade", 9,
            {
                AddOptionShort(3, "up to 3x3", "why do you use this mod"),
                AddOptionShort(5, "up to 5x5", "able to upgrade 1 times"),
                AddOptionShort(7, "up to 7x7", "able to upgrade 2 times"),
                AddOptionShort(9, "up to 9x9", "able to upgrade 3 times"),
                AddOptionShort(11, "up to 11x11", "able to upgrade 4 times"),
                AddOptionShort(13, "up to 13x13", "able to upgrade 5 times"),
                AddOptionShort(63, "infinite", "to test the limits and break through? challenge accepted!"),
            })

    configuration_options[#configuration_options + 1] = AddOptionHeader("Advanced Options:")

    AddNewConfig("UPG_MODE", "Upgrade Mode", 1,
            {
                AddOptionShort(1, "normal mode", "put upgrade items on the outermost slots"),
                AddOptionShort(2, "expensive mode", "put upgrade items to the right or to the bottom for upgrade"),
                AddOptionShort(3, "complex mode", "both of the modes"),
            }, "Change the upgrading mode")
    AddNewConfig("PAGEABLE", "Pageable Upgrade", false,
            AddHoverBoolOpt("After the chest is in max level, put the upgrade items to all the slots in 1st page"),
            "Make the Chest Pageable")
    AddNewConfig("BACKPACK", "Backpack Upgrade-able", false,
            AddHoverBoolOpt("put items into every slots of the backpack"))
    AddNewConfig("CHANGESIZE", "Change Size", false, BoolOpt, "Change the chest size scale to its level")

    configuration_options[#configuration_options + 1] = AddOptionHeader("Upgradeable Containers:")
    AddNewConfig("C_TREASURECHEST", "Chest", true, AddHoverBoolOpt("1 boards in each outermost slots"))
    AddNewConfig("C_ICEBOX", "Ice Box", true, AddHoverBoolOpt("1 gears in each top-most slots, 1 cut stone in each other outermost slots"))
    AddNewConfig("C_SALTBOX", "Salt Box", true, AddHoverBoolOpt("1 salt crystal in each outermost slots, and 1 blue gem in the center-most slot"))
    AddNewConfig("C_DRAGONFLYCHEST", "Dragonfly Chest", true, AddHoverBoolOpt("1 boards in each outermost slots"))
    AddNewConfig("C_FISH_BOX", "Fish Box", true, AddHoverBoolOpt("1 rope in each outermost slots"))
    AddNewConfig("C_BOOKSTATION", "Bookcase", false, AddHoverBoolOpt("1 living log in each outermost slots"))
    AddNewConfig("C_TACKLECONTAINER", "Tackle Box", false, AddHoverBoolOpt("1 cookie cutter shell in each outermost slots"), "tackle box and super tackle box")
    AddNewConfig("C_OCEAN_TRAWLER", "Ocean Trawler", false, AddHoverBoolOpt("1 malbatross feather in each slots"))
    AddNewConfig("C_SHADOW_CONTAINER", "Magician's Containers", true, AddHoverBoolOpt("1 shadow heart in each outermost slots"), "Magician's Hat, Magician's Box, Shadow Chester")
    AddNewConfig("C_BEARGERFUR_SACK", "Polar Bearger Bin", true, AddHoverBoolOpt("1 thick fur in each left-most slots, 1 pure brilliance in other outermost slots"))

    configuration_options[#configuration_options + 1] = AddOptionHeader("Widget UI Settings:")
    AddNewConfig("SHOWGUIDE", "Shows Guide", 3,
            {
                AddOptionShort(0, "never"),
                AddOptionShort(1, "always"),
                AddOptionShort(2, "when empty", "Show guide when the chest is empty"),
                AddOptionShort(3, "auto", "Turn the guide off after you upgrade the chest once."),
            }, "Show you the upgrade requirement\nWon't show for Column/Row Upgrade(expensive mode)", true)
    AddNewConfig("SEARCHBAR", "Search UI", true, BoolOpt, "double click the background to open/close the search UI", true)
    AddNewConfig("SHOWALLPAGE", "Show All Page", false, BoolOpt, "(testing)show all page when you open your container", true)
    AddNewConfig("UI_WIDGETPOS", "Widget Position", true,
            {
                AddOptionShort(false, "top", "unchange, above the character"),
                AddOptionShort(true, "left", "next to the character"),
            }, nil, true)
    AddNewConfig("DRAGGABLE", "Partial Display", false,
            {
                AddOptionShort(false, "disable(default)"),
                AddOptionShort(3, "3x3", "show 3x3 slots"),
                AddOptionShort(4, "4x4", "show 4x4 slots"),
                AddOptionShort(5, "5x5(suggest)", "show 5x5 slots"),
                AddOptionShort(6, "6x6", "show 6x6 slots"),
                AddOptionShort(7, "7x7", "show 7x7 slots"),
            }, nil, true)
    AddNewConfig("PACKSTYLE", "Backpack Layout", true,
            {
                AddOptionShort(false, "combine"),
                AddOptionShort(true, "single"),
            }, "\"Integrated\" backpack layout\nActivate only if \"Backpack Upgrade-able\" option on", true)
    AddNewConfig("OVERFLOW", "Backpack Page Fusion", true, BoolOpt, "\"Integrated\" backpack layout\nShow slots in same page until the inventory bar is full", true)
    AddNewConfig("UI_ICEBOX", "Ice Box Leftward", true, BoolOpt, "shift the ui of ice box leftward so that it won't block your cooker", true)
    AddNewConfig("DROPALL", "\"Drop All\" Button", false, BoolOpt, "a button allow you dropping the entire content to the ground", true)
    AddNewConfig("SORTITEM", "\"Sort Item\" Button", false, BoolOpt, "a button allow you sorting the content quickly\nMy sorting style. You may not like it.", true)
    AddNewConfig("UI_BGIMAGE", "Hide Background Image", false, BoolOpt, nil, true)

    configuration_options[#configuration_options + 1] = AddOptionHeader("Other Functions:")
    AddNewConfig("SCALE_FACTOR", "Size Factor", 3,
            {
                AddOptionShort(1, "2", "Size of 6x6 chest is 2 times to the 3x3"),
                AddOptionShort(2, "1.5", "Size of 6x6 chest is 1.5 times to the 3x3"),
                AddOptionShort(3, "1.33", "Size of 6x6 chest is 1.33 times to the 3x3"),
                AddOptionShort(4, "1.25", "Size of 6x6 chest is 1.25 times to the 3x3"),
                AddOptionShort(5, "1.2"),
                AddOptionShort(6, "1.16"),
                AddOptionShort(10, "1.1")
            }, "The scale for upgraded chest(in radius)\nActivate only if \"Change Size\" option on.")
    AddNewConfig("BACKPACKPAGE", "Backpack Max Page", 3,
            {
                AddOptionShort(1, "1", "Why will you turn backpack upgrade on"),
                AddOptionShort(2, "2"),
                AddOptionShort(3, "3"),
                AddOptionShort(4, "4"),
                AddOptionShort(5, "5"),
                AddOptionShort(6, "6"),
                AddOptionShort(7, "7"),
                AddOptionShort(8, "8"),
                AddOptionShort(9, "9"),
                AddOptionShort(10, "10"),
                AddOptionShort(11, "11"),
                AddOptionShort(12, "12"),
                AddOptionShort(13, "13"),
                AddOptionShort(14, "14"),
                AddOptionShort(15, "15"), })
    AddNewConfig("ALLCANUPG", "(testing)All Upgrade-able", false, AddHoverBoolOpt("item consumed the most when crafting to each outermost slots"), "Allow most of the modded containers upgradable")
    AddNewConfig("DEGRADABLE", "Downgrade-able", true, BoolOpt, "Enable downgrading the chest\nPut a hammer in the empty container")
    AddNewConfig("INSIGHT", "Insight", true, BoolOpt,
            "Mod: Insight will shows the detailed info for chest level"
    )
    AddNewConfig("UNCOM_MODE", "Uncompomising Mode", false, BoolOpt, "Adjust some setting when use with Mod: Uncompomising Mode")
    AddNewConfig("KRAMPUS_ONLY", "Krampus Sack Only", false, BoolOpt, "*DISABLE* all other backpack' upgrade, except Krampus Sack\nwax paper to all slots in first page for upgrading Krampus Sack")
    AddNewConfig("RETURNITEM", "Deconstruct Return Items", false, BoolOpt, "Testing function\nReturn items when decontrution")

    configuration_options[#configuration_options + 1] = AddOptionHeader("DEBUG:")
    AddNewConfig("DEBUG_MAXLV", "Max Level", false, BoolOpt, "Containers are in max lv once builded")
    AddNewConfig("DEBUG_IIC", "Item in Container", false, BoolOpt, "Put upgrade material and hammer into container once builded")
end

----------------------------
--------------------------- 神秘强化炉-----------------------------
configuration_options[#configuration_options + 1] = AddOptionHeader("神秘强化炉")
configuration_options[#configuration_options + 1] = AddOption("wb_strengthen_switch", "总开关", "是否开启神秘强化炉", false)
configuration_options[#configuration_options + 1] = AddConfigOption("wb_strengthen_weapon_base", "强化武器伤害强度", "",
        { { description = "拾之无味", hover = "附魔13级近战武器伤害大约为181.01", data = 2 },
          { description = "意气风发", hover = "附魔13级近战武器伤害大约为452.54", data = 5 },
          { description = "傲视群雄", hover = "附魔13级近战武器伤害大约为724.07", data = 8 },
          { description = "天下第一", hover = "附魔13级近战武器伤害大约为995.60", data = 11 },
          { description = "神挡杀神", hover = "附魔13级近战武器伤害大约为1267.13", data = 14 },
          { description = "天亦可灭", hover = "附魔13级近战武器伤害大约为1538.66", data = 17 } }, 8)

configuration_options[#configuration_options + 1] = AddOption("wb_strengthen_increase", "启用附魔", "是否开启附魔功能", true)

---小众容器修改
configuration_options[#configuration_options + 1] = AddOptionHeader("小众容器修改")
configuration_options[#configuration_options + 1] = AddOption("niche_container_modification_switch", "总开关", "小众容器修改总开关", false)
configuration_options[#configuration_options + 1] = AddConfigOption("package_container_modification", "捆绑包装", "捆绑包装的容量大小更改\n捆绑包装，以及礼物包装",
        { { description = "关闭", data = false, hover = "不启用" },
          { description = "6格", data = 6, hover = "捆绑包装6格容量" },
          { description = "10格", data = 10, hover = "捆绑包装10格容量" },
          { description = "12格", data = 12, hover = "捆绑包装12格容量" },
          { description = "14格", data = 14, hover = "捆绑包装14格容量（格子相对紧凑！）" },
          { description = "19格", data = 19, hover = "捆绑包装19格容量（不太美观！！）" }, }, false)
configuration_options[#configuration_options + 1] = AddConfigOption("package_open_modification", "捆绑物资-打开", "捆绑物资的打开更改为打开容器，不是直接拆开",
        { { description = "关闭", data = false, hover = "不启用" },
          { description = "打开-不保鲜", data = 1, hover = "捆绑物资打开时容器内的物品无保鲜，会减少保质期（指打开状态的那段时间）" },
          { description = "打开-保鲜", data = 2, hover = "捆绑物资打开时容器内的物品不会减少保质期（指打开状态的那段时间）" }, }, false)

configuration_options[#configuration_options + 1] = AddConfigOption("gift_package_container_modification", "礼物-打开", "礼物的打开更改为打开容器，不是直接拆开",
        { { description = "关闭", data = false, hover = "不启用" },
          { description = "打开容器", data = 1, hover = "礼物打开状态时间内物品是否保鲜取决于 捆绑物资-打开 的选项" }, }, false)
configuration_options[#configuration_options + 1] = AddConfigOption("shirenhua", "食人花-打开", "食人花顶端没有挂东西时可右键打开容器，容量一般默认是15格\n右键取走物品的优先级高于打开容器，可攻击食人花或眼球草或右键取走物品后右键打开容器",
        { { description = "关闭", data = false, hover = "不启用" },
          { description = "15格", data = 15, hover = "添加可打开的15格容器容量" },
          { description = "20格", data = 20, hover = "添加可打开的20格容器容量(当人为放入位置在15格后的物品关闭时将掉落下来)" }, }, false)
