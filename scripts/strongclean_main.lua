local TheNet = GLOBAL.TheNet
local lang = TheNet:GetDefaultServerLanguage()
local Vector3 = GLOBAL.Vector3
local io = GLOBAL.io

local checkingdays = GetModConfigData("checking_days")
local white_area = GetModConfigData("white_area")
local clean_mode = GetModConfigData("clean_mode")
local tumbleweed_maxnum = GetModConfigData("tumbleweed_maxnum")
local evergreen_maxnum = GetModConfigData("evergreen_maxnum")
local evergreen_sparse_maxnum = GetModConfigData("evergreen_sparse_maxnum")
local deciduoustree_maxnum = GetModConfigData("deciduoustree_maxnum")

local strong_clean_white_list_additional_l = GetModConfigData("strong_clean_white_list_additional_option")
local strong_clean_black_list_additional_l = GetModConfigData("strong_clean_black_list_additional_option")
local strong_clean_white_tag_list_additional_l = GetModConfigData("strong_clean_white_tag_list_additional_option")
--local strong_clean_black_tag_list_additional_l = GetModConfigData("strong_clean_black_tag_list_additional_option")
local strong_clean_half_white_list_additional_l = GetModConfigData("strong_clean_half_white_list_additional_option")
local strong_clean_strong_clean_list_additional_l = GetModConfigData("strong_clean_strong_clean_list_additional_option")

--local use_for_tumbleweed_l = GetModConfigData("use_for_tumbleweed") or false
local usage_scenario_l = GetModConfigData("usage_scenario") or false

if type(usage_scenario_l) ~= "number" then
    usage_scenario_l = 1
end
local whitelist = {}
local blacklist = {}
local whitetag = {}
local halfwhitelist = {}
local strongcleanlist = {}

local lightbulb = "󰀏"

------------白名单-------------------------
table.insert(whitelist, "book")--奶奶的书(关键词)
table.insert(whitelist, "mooneye") --月眼(关键词)
--table.insert(whitelist, "saddle") --鞍(关键词)
--table.insert(whitelist, "powcake") --芝士蛋糕(关键词)
table.insert(whitelist, "waxwelljournal") --老麦的书
--table.insert(whitelist, "fireflies") --萤火虫
table.insert(whitelist, "slurper") --啜食者
--table.insert(whitelist, "pumpkin_lantern") --南瓜灯
table.insert(whitelist, "bullkelp_beachedroot") --海带根
table.insert(whitelist, "driftwood_log")
---浮木桩
table.insert(whitelist, "panflute") --排箫
--table.insert(whitelist, "skeletonhat")  --骨盔
--table.insert(whitelist, "armorskeleton") --骨甲
--table.insert(whitelist, "thurible") --香炉
--table.insert(whitelist, "fossil_piece") --化石碎片
--table.insert(whitelist, "shadowheart") --心脏
--table.insert(whitelist, "amulet") --生命护符
--table.insert(whitelist, "reviver") --救赎之心
table.insert(whitelist, "heatrock") --暖石
--table.insert(whitelist, "dug_trap_starfish") --挖起的海星
table.insert(whitelist, "yellowstaff") --唤星法杖
table.insert(whitelist, "opalstaff") --喚月法杖
--table.insert(whitelist, "cane") --步行手杖
--table.insert(whitelist, "orangestaff") --瞬移手杖
table.insert(whitelist, "glommerfuel") --格罗姆燃料
table.insert(whitelist, "lureplantbulb") --食人花种子
--table.insert(whitelist, "tentaclespots") --触手皮
--table.insert(whitelist, "hivehat") --蜂王帽
--table.insert(whitelist, "tentaclespike") --狼牙棒
--table.insert(whitelist, "nightsword") --影刀
--table.insert(whitelist, "armor_sanity") --影甲
--table.insert(whitelist, "tacklecontainer") --钓具箱
--table.insert(whitelist, "supertacklecontainer") --超级钓具箱
table.insert(whitelist, "singingshell_octave") --贝壳钟(关键词 有3 4 5)
table.insert(whitelist, "atrium_light_moon") --阿比的灯柱
table.insert(whitelist, "nilxin_fox") --夜雨团子
table.insert(whitelist, "sora_pot")
table.insert(whitelist, "doydoy")
table.insert(whitelist, "doydoybaby")
table.insert(whitelist, "dubloon")
table.insert(whitelist, "ia_messagebottle")
table.insert(whitelist, "ia_messagebottleempty")

------------黑名单-------------------------
table.insert(blacklist, "twigs")--树枝
table.insert(blacklist, "cutgrass") --割下的草
table.insert(blacklist, "spoiled_food") --腐烂食物
table.insert(blacklist, "houndstooth") --狗牙
table.insert(blacklist, "stinger") --蜂刺
table.insert(blacklist, "bookinfo_myth") --天书
table.insert(blacklist, "shyerrytree1")
table.insert(blacklist, "shyerrytree2")
table.insert(blacklist, "shyerrytree3")
table.insert(blacklist, "shyerrytree4")
table.insert(blacklist, "redpouch_yot_catcoon")
table.insert(blacklist, "dummytarget")

------------白名单标签-------------------------
--table.insert(whitetag, "smallcreature")--鸟、兔子、鼹鼠
table.insert(whitetag, "irreplaceable")--可疑的大理石、远古钥匙、眼骨、星空、天体灵球、格罗姆花
table.insert(whitetag, "heavy")--雕像
--table.insert(whitetag, "backpack")--背包、小猪包、小偷包
--table.insert(whitetag, "bundle")--包裹、礼物
table.insert(whitetag, "deerantler")--鹿角
--table.insert(whitetag, "trap")--陷阱、狗牙陷阱、海星
table.insert(whitetag, "personal_possession") --猴子宝藏

------------半白名单标签-------------------------
table.insert(halfwhitelist, "tentaclespike") --狼牙棒
table.insert(halfwhitelist, "nightsword") --影刀
table.insert(halfwhitelist, "armor_sanity") --影甲

------------强力清理名单：无视白名单，直接清理-------------------------
table.insert(strongcleanlist, "bookinfo_myth") --天书
table.insert(strongcleanlist, "redpouch_yot_catcoon") --猫年红包，太多卡服


if usage_scenario_l == 1 then
    ------------白名单-------------------------
    table.insert(whitelist, "saddle") --鞍(关键词)
    table.insert(whitelist, "powcake") --芝士蛋糕(关键词)
    table.insert(whitelist, "fireflies") --萤火虫
    table.insert(whitelist, "pumpkin_lantern") --南瓜灯
    table.insert(whitelist, "skeletonhat")  --骨盔
    table.insert(whitelist, "armorskeleton") --骨甲
    table.insert(whitelist, "thurible") --香炉
    table.insert(whitelist, "fossil_piece") --化石碎片
    table.insert(whitelist, "shadowheart") --心脏
    table.insert(whitelist, "amulet") --生命护符
    table.insert(whitelist, "reviver") --救赎之心
    table.insert(whitelist, "dug_trap_starfish") --挖起的海星
    table.insert(whitelist, "cane") --步行手杖
    table.insert(whitelist, "orangestaff") --瞬移手杖
    table.insert(whitelist, "tentaclespots") --触手皮
    table.insert(whitelist, "hivehat") --蜂王帽
    table.insert(whitelist, "tentaclespike") --狼牙棒
    table.insert(whitelist, "nightsword") --影刀
    table.insert(whitelist, "armor_sanity") --影甲
    table.insert(whitelist, "tacklecontainer") --钓具箱
    table.insert(whitelist, "supertacklecontainer") --超级钓具箱

    ------------黑名单-------------------------

    ------------白名单标签-------------------------
    table.insert(whitetag, "smallcreature")--鸟、兔子、鼹鼠
    table.insert(whitetag, "backpack")--背包、小猪包、小偷包
    table.insert(whitetag, "bundle")--包裹、礼物
    table.insert(whitetag, "trap")--陷阱、狗牙陷阱、海星

    ------------半白名单标签-------------------------


    ------------强力清理名单：无视白名单，直接清理-------------------------

end

local cleanmaxnum = { --世界保留数量最大值 堆叠物判断懒得写了 目前按组判断 所以别加可堆叠和可以拿起来的物品

    tumbleweed = { max = checknumber(tumbleweed_maxnum) and tumbleweed_maxnum or -1 },
    evergreen = { max = checknumber(evergreen_maxnum) and evergreen_maxnum or -1 },
    evergreen_sparse = { max = checknumber(evergreen_sparse_maxnum) and evergreen_sparse_maxnum or -1 },
    deciduoustree = { max = checknumber(deciduoustree_maxnum) and deciduoustree_maxnum or -1 },
    shyerrytree1 = { max = 3 }, --颤栗树
    shyerrytree2 = { max = 2 }, --
    shyerrytree3 = { max = 2 }, --
    shyerrytree4 = { max = 3 }, --
    kyno_adai_spider_monkey = { max = 10 }, --
    kyno_adai_wargfant = { max = 10 }, --
    kyno_adai_merm = { max = 20 }, --
    moonrockseed = { max = 1 },
    atrium_key = { max = 1 },

}
if usage_scenario_l == 2 or usage_scenario_l == 3 or usage_scenario_l == 4 then
    -- table.insert(strongcleanlist, "tumbleweed")--风滚草
    --table.insert(strongcleanlist, "alterguardian_phase1")--天体英雄形态1
    --table.insert(strongcleanlist, "alterguardian_phase2")--天体英雄形态2
    --table.insert(strongcleanlist, "alterguardian_phase3")--天体英雄形态3
    table.insert(strongcleanlist, "alterguardian_phase3dead")--被击败的天体英雄
    table.insert(strongcleanlist, "dustmothden")--尘蛾的窝
    table.insert(strongcleanlist, "dustmoth")--尘蛾的窝
    table.insert(strongcleanlist, "minotaurchest") --华丽的箱子
    --table.insert(strongcleanlist, "moonrockseed") --天体宝珠
    table.insert(strongcleanlist, "moon_altar_glass") --天体祭坛底座
    table.insert(strongcleanlist, "moon_altar_seed") --天体祭坛宝珠
    table.insert(strongcleanlist, "moon_altar_idol") --天体祭坛雕像
    table.insert(strongcleanlist, "moon_altar_crown") --天体贡品
    table.insert(strongcleanlist, "moon_altar_icon") --天体圣殿象征
    table.insert(strongcleanlist, "moon_altar_ward") --天体圣殿卫戍
    table.insert(strongcleanlist, "resurrectionstone") --复活台
    --table.insert(strongcleanlist, "gift")
    table.insert(strongcleanlist, "mokuangshi")


    --
    --table.insert(strongcleanlist, "tacklecontainer")--钓具箱
    --table.insert(strongcleanlist, "supertacklecontainer")--超级钓具箱

    --table.insert(strongcleanlist, "killerbee")
    --table.insert(strongcleanlist, "robin")--红鸟
    table.insert(strongcleanlist, "crow")--乌鸦
    table.insert(strongcleanlist, "butterfly")--蝴蝶
    table.insert(strongcleanlist, "spider")--蜘蛛
    table.insert(strongcleanlist, "killerbee")--杀人蜂
    table.insert(strongcleanlist, "frog")--青蛙
    --table.insert(strongcleanlist, "bee")--蜜蜂
    table.insert(strongcleanlist, "mosquito")--蚊子
    table.insert(strongcleanlist, "rabbit")--兔子
    --table.insert(strongcleanlist, "mole")--鼹鼠
    table.insert(strongcleanlist, "perd")--火鸡
    table.insert(strongcleanlist, "grassgekko")--草蜥蜴
    table.insert(strongcleanlist, "buzzard")--秃鹫
    table.insert(strongcleanlist, "catcoon")--浣猫
    --table.insert(strongcleanlist, "fireflies")--萤火虫
    --table.insert(strongcleanlist, "carrat")--胡萝卜鼠
    table.insert(strongcleanlist, "pondfish")--淡水鱼
    table.insert(strongcleanlist, "moonbutterfly")-- 月蛾
    table.insert(strongcleanlist, "robin_winter")--雪雀
    table.insert(strongcleanlist, "lightflier")--荧光虫
    table.insert(strongcleanlist, "pondeel")--活鳗鱼
    table.insert(strongcleanlist, "canary")--金丝雀
    table.insert(strongcleanlist, "bird_mutant")--月盲乌鸦
    table.insert(strongcleanlist, "bird_mutant_spitter")--奇行鸟


    table.insert(strongcleanlist, "hound")--猎狗
    table.insert(strongcleanlist, "bat")--蝙蝠
    --table.insert(strongcleanlist, "pigman")--猪人
    table.insert(strongcleanlist, "crawlinghorror")--暗影爬行怪
    table.insert(strongcleanlist, "spider_moon")--月岛蜘蛛
    table.insert(strongcleanlist, "spider_hider")--洞穴蜘蛛
    table.insert(strongcleanlist, "spider_spitter")--喷吐蜘蛛
    table.insert(strongcleanlist, "spider_dropper")--悬挂蜘蛛
    table.insert(strongcleanlist, "firehound")--火狗
    table.insert(strongcleanlist, "fruitfly")--果蝇
    table.insert(strongcleanlist, "icehound")--冰狗
    table.insert(strongcleanlist, "spider_warrior")--蜘蛛战士
    table.insert(strongcleanlist, "merm")--鱼人
    table.insert(strongcleanlist, "terrorbeak")--尖嘴暗影怪
    table.insert(strongcleanlist, "slurtle")--尖壳蜗牛
    table.insert(strongcleanlist, "penguin")--企鹅
    table.insert(strongcleanlist, "pigguard")--猪人守卫
    table.insert(strongcleanlist, "mutatedhound")--僵尸狗
    table.insert(strongcleanlist, "koalefant_summer")--夏象
    table.insert(strongcleanlist, "squid")--鱿鱼
    table.insert(strongcleanlist, "molebat")--鼹鼠蝙蝠
    --table.insert(strongcleanlist, "beefalo")--牛
    table.insert(strongcleanlist, "bunnyman")--兔人
    table.insert(strongcleanlist, "tallbird")--高鸟
    --table.insert(strongcleanlist, "monkey")--猴子
    table.insert(strongcleanlist, "rocky")--石虾
    table.insert(strongcleanlist, "krampus")--坎普斯
    table.insert(strongcleanlist, "deer")--无眼鹿
    table.insert(strongcleanlist, "snurtle")--圆壳蜗牛
    table.insert(strongcleanlist, "tentacle")--触手
    table.insert(strongcleanlist, "worm")--洞穴蠕虫
    table.insert(strongcleanlist, "mutated_penguin")--月岛企鹅
    table.insert(strongcleanlist, "knight")--发条骑士
    table.insert(strongcleanlist, "bishop")--发条主教
    table.insert(strongcleanlist, "mushgnome")--蘑菇地精
    --table.insert(strongcleanlist, "lightninggoat")--闪电羊
    table.insert(strongcleanlist, "koalefant_winter")--冬象
    table.insert(strongcleanlist, "mermguard")--鱼人守卫
    table.insert(strongcleanlist, "fruitdragon")--沙拉蝾螈
    table.insert(strongcleanlist, "rook")--发条战车
    table.insert(strongcleanlist, "mossling")--小鸭
    table.insert(strongcleanlist, "walrus")--海象
    table.insert(strongcleanlist, "knight_nightmare")--破损的发条骑士
    table.insert(strongcleanlist, "bishop_nightmare")--破损的发条主教
    --table.insert(strongcleanlist, "oceanfish_medium_1_inv")--泥鱼
    --table.insert(strongcleanlist, "oceanfish_medium_2_inv")--斑鱼
    --table.insert(strongcleanlist, "oceanfish_medium_3_inv")--浮夸狮子鱼
    --table.insert(strongcleanlist, "oceanfish_medium_4_inv")--黑鲶鱼
    --table.insert(strongcleanlist, "oceanfish_small_2_inv")--针鼻喷墨鱼
    --table.insert(strongcleanlist, "oceanfish_small_1_inv")--小孔雀鱼
    --table.insert(strongcleanlist, "oceanfish_small_3_inv")--小饵鱼
    --table.insert(strongcleanlist, "oceanfish_small_4_inv")--三文鱼苗
    --table.insert(strongcleanlist, "oceanfish_medium_5_inv")--玉米鳕鱼
    --table.insert(strongcleanlist, "oceanfish_small_5_inv")--爆米花鱼
    --table.insert(strongcleanlist, "wobster_sheller_land")--龙虾
    table.insert(strongcleanlist, "little_walrus")--小海象
    table.insert(strongcleanlist, "rook_nightmare")--破损的发条战车
    --table.insert(strongcleanlist, "wobster_moonglass_land")--月光龙虾
    --table.insert(strongcleanlist, "oceanfish_medium_6_inv")--花锦鲤
    --table.insert(strongcleanlist, "oceanfish_medium_7_inv")--金锦鲤

    table.insert(strongcleanlist, "spiderqueen")--蜘蛛女王
    table.insert(strongcleanlist, "leif")--树精
    table.insert(strongcleanlist, "leif_sparse")--稀有树精
    table.insert(strongcleanlist, "lordfruitfly")--果蝇王
    table.insert(strongcleanlist, "warg")--座狼
    table.insert(strongcleanlist, "spat")--钢羊
    table.insert(strongcleanlist, "deer_red")--红宝石鹿
    table.insert(strongcleanlist, "deer_blue")--蓝宝石鹿
    table.insert(strongcleanlist, "moose")--鹿鸭
    table.insert(strongcleanlist, "deerclops")--巨鹿
    table.insert(strongcleanlist, "bearger")--熊大
    table.insert(strongcleanlist, "shadow_rook")--暗影战车
    table.insert(strongcleanlist, "shadow_knight")--暗影骑士
    table.insert(strongcleanlist, "shadow_bishop")--暗影主教
    --table.insert(strongcleanlist, "oceanfish_medium_8_inv")--冰鲷鱼
    --table.insert(strongcleanlist, "oceanfish_small_6_inv")--比目鱼
    --table.insert(strongcleanlist, "oceanfish_small_7_inv")--花朵金枪鱼
    --table.insert(strongcleanlist, "oceanfish_small_8_inv")--炽热太阳鱼
    --table.insert(strongcleanlist, "dragonfly")--龙蝇
    table.insert(strongcleanlist, "beequeen")--蜂后
    table.insert(strongcleanlist, "klaus")--克劳斯
    --table.insert(strongcleanlist, "antlion")--蚁狮
    table.insert(strongcleanlist, "malbatross")--邪天翁
    table.insert(strongcleanlist, "stalker")--召唤之骨
    table.insert(strongcleanlist, "stalker_forest")--森林召唤之骨
    table.insert(strongcleanlist, "minotaur")--远古守护者
    table.insert(strongcleanlist, "toadstool")--蘑菇蛤
    table.insert(strongcleanlist, "stalker_atrium")--暗影编制者

    table.insert(strongcleanlist, "twinofterror1_mini")--恐怖之眼
    table.insert(strongcleanlist, "eyeofterror")--恐怖之眼
    table.insert(strongcleanlist, "twinofterror1")--恐怖之眼
    table.insert(strongcleanlist, "twinofterror2")--恐怖之眼

    table.insert(strongcleanlist, "alterguardian_phase1")--天体英雄1阶段
    table.insert(strongcleanlist, "alterguardian_phase2")--天体英雄2阶段
    table.insert(strongcleanlist, "alterguardian_phase3")--天体英雄3阶段
    table.insert(strongcleanlist, "alterguardian_phase1_lunarrift")--天体仇灵
    table.insert(strongcleanlist, "alterguardian_phase4_lunarrift")--天体后裔


    table.insert(strongcleanlist, "fossil_stalker") --奇异的骨架
    table.insert(strongcleanlist, "daywalker") --梦魇疯猪
    table.insert(strongcleanlist, "daywalker2") --拾荒疯猪
    table.insert(strongcleanlist, "mutatedwarg") --附身座狼
    table.insert(strongcleanlist, "mutatedbearger") --装甲熊
    table.insert(strongcleanlist, "mutateddeerclops") --晶体独眼巨鹿
    table.insert(strongcleanlist, "prime_mate") --大副
    table.insert(strongcleanlist, "powder_monkey") --火药猴
    table.insert(strongcleanlist, "gelblob") --恶液
    table.insert(strongcleanlist, "lunarthrall_plant") --致命亮茄
    table.insert(strongcleanlist, "ruinsnightmare") --潜伏梦魇
    table.insert(strongcleanlist, "clayhound") --粘土猎犬
    table.insert(strongcleanlist, "claywarg") --粘土座狼
    table.insert(strongcleanlist, "eyeofterror_mini") --可疑窥视者
    table.insert(strongcleanlist, "sharkboi") --大霜鲨
    table.insert(strongcleanlist, "shadowthrall_hands") --墨荒之手
    table.insert(strongcleanlist, "shadowthrall_horns") --墨荒之角
    table.insert(strongcleanlist, "shadowthrall_wings") --墨荒之翼
    table.insert(strongcleanlist, "shadowthrall_mouth") --墨荒-狞笑
    table.insert(strongcleanlist, "crabking_mob") --蟹卫
    table.insert(strongcleanlist, "crabking_mob_knight") --蟹骑士
    table.insert(strongcleanlist, "warglet") --青年座狼

end

--- 不建家
if usage_scenario_l == 2 then
    table.insert(strongcleanlist, "asparagus_oversized")
    table.insert(strongcleanlist, "carrot_oversized")
    table.insert(strongcleanlist, "corn_oversized")
    table.insert(strongcleanlist, "eggplant_oversized")
    table.insert(strongcleanlist, "garlic_oversized")
    table.insert(strongcleanlist, "onion_oversized")
    table.insert(strongcleanlist, "pepper_oversized")
    table.insert(strongcleanlist, "potato_oversized")
    table.insert(strongcleanlist, "pumpkin_oversized")
    table.insert(strongcleanlist, "tomato_oversized")
    table.insert(strongcleanlist, "dragonfruit_oversized")
    table.insert(strongcleanlist, "durian_oversized")
    table.insert(strongcleanlist, "pomegranate_oversized")
    table.insert(strongcleanlist, "watermelon_oversized")

    table.insert(strongcleanlist, "asparagus_oversized_rotten")
    table.insert(strongcleanlist, "carrot_oversized_rotten")
    table.insert(strongcleanlist, "corn_oversized_rotten")
    table.insert(strongcleanlist, "eggplant_oversized_rotten")
    table.insert(strongcleanlist, "garlic_oversized_rotten")
    table.insert(strongcleanlist, "onion_oversized_rotten")
    table.insert(strongcleanlist, "pepper_oversized_rotten")
    table.insert(strongcleanlist, "potato_oversized_rotten")
    table.insert(strongcleanlist, "pumpkin_oversized_rotten")
    table.insert(strongcleanlist, "tomato_oversized_rotten")
    table.insert(strongcleanlist, "dragonfruit_oversized_rotten")
    table.insert(strongcleanlist, "durian_oversized_rotten")
    table.insert(strongcleanlist, "pomegranate_oversized_rotten")
    table.insert(strongcleanlist, "watermelon_oversized_rotten")
end
if usage_scenario_l == 4 then
    --table.insert(strongcleanlist, "watermelon_oversized_rotten")
end

if strong_clean_white_list_additional_l and type(strong_clean_white_list_additional_l) == "table" then
    for k, v in pairs(strong_clean_white_list_additional_l) do
        table.insert(whitelist, v)
    end
end

if strong_clean_black_list_additional_l and type(strong_clean_black_list_additional_l) == "table" then
    for k, v in pairs(strong_clean_black_list_additional_l) do
        table.insert(blacklist, v)
    end
end
if strong_clean_white_tag_list_additional_l and type(strong_clean_white_tag_list_additional_l) == "table" then
    for k, v in pairs(strong_clean_white_tag_list_additional_l) do
        table.insert(whitetag, v)
    end
end
--if strong_clean_black_tag_list_additional_l and type(strong_clean_black_tag_list_additional_l) == "table" then
--    for k, v in pairs(strong_clean_black_tag_list_additional_l) do
--        table.insert(blacktag, v)
--    end
--end
if strong_clean_half_white_list_additional_l and type(strong_clean_half_white_list_additional_l) == "table" then
    for k, v in pairs(strong_clean_half_white_list_additional_l) do
        table.insert(halfwhitelist, v)
    end
end
if strong_clean_strong_clean_list_additional_l and type(strong_clean_strong_clean_list_additional_l) == "table" then
    for k, v in pairs(strong_clean_strong_clean_list_additional_l) do
        table.insert(strongcleanlist, v)
    end
end

if clean_mode == 0 then
    local readtxt, err = io.open(MODROOT .. "/modules/strongclean/whitelist.txt", "r")
    if not err then
        for line in readtxt:lines() do
            line = string.sub(line, 1, -2)
            table.insert(whitelist, line)
            print('Whitelist Add:', line)
        end
    end
else
    local readtxt, err = io.open(MODROOT .. "/modules/strongclean/blacklist.txt", "r")
    if not err then
        for line in readtxt:lines() do
            line = string.sub(line, 1, -2)
            table.insert(blacklist, line)
            print('Blacklist Add:', line)
        end
    end
end

local readtxt2, err2 = io.open(MODROOT .. "/modules/strongclean/strongcleanlist.txt", "r")
if not err2 then
    for line in readtxt2:lines() do
        line = string.sub(line, 1, -2)
        table.insert(strongcleanlist, line)
        print('Strongcleanlist Add:', line)
    end
end

local function isWhitelist(name)
    for k, v in pairs(whitelist) do
        if string.find(name, v) then
            return true
        end
    end
    return false
end

--是否是X判定
local function isX(name, X)
    if name == nil then
        return false
    end
    if not name then
        return false
    end
    if type(name) ~= "string" then
        return false
    end
    if name == X then
        return true
    end
    return false
end

--是否在强力清理名单中
local function isStrongcleanlist(name)
    if name == nil then
        return false
    end
    if not name then
        return false
    end
    if type(name) ~= "string" then
        return false
    end
    for k, v in pairs(strongcleanlist) do
        if name == v then
            return true
        end
    end
    return false
end

local function isBlacklist(name)
    for k, v in pairs(blacklist) do
        if string.find(name, v) then
            return true
        end
    end
    return false
end

local function isWhiteTag(fabs)
    for k, v in pairs(whitetag) do
        if fabs:HasTag(v) then
            return true
        end
    end
    return false
end

local function isHalfWhitelist(fabs)
    for k, v in pairs(halfwhitelist) do
        if string.find(fabs.prefab, v) then
            if fabs.components.finiteuses then
                if fabs.components.finiteuses:GetPercent() < 1 then
                    return true
                end
            end
        end
    end
end

local function isFloat(fabs)
    if fabs.components.floater then
        if fabs.components.floater:IsFloating() and fabs.prefab ~= "driftwood_log" then
            return true
        end
    end
    return false
end

local function WhiteArea(inst)
    local pos = Vector3(inst.Transform:GetWorldPosition())
    entity_list = TheSim:FindEntities(pos.x, pos.y, pos.z, 4)
    if white_area then
        for i, entity in pairs(entity_list) do
            if entity.prefab == "endtable" or entity.prefab == "pirate_stash" then
                -- 茶几 猴子宝藏
                return false
            end
        end
        return true
    else
        for i, entity in pairs(entity_list) do
            if entity.prefab == "pirate_stash" then
                -- 猴子宝藏
                return false
            end
        end
        return true
    end
end

local Removesign = {}

local function Positioncheck(v)
    local x, y, z = v.Transform:GetWorldPosition()
    if Removesign[v] and Removesign[v].x == math.floor(x) and Removesign[v].y == math.floor(y) then
        return true
    else
        v:RemoveTag("RemoveCountOne")
        return false
    end
end

local function DoRemoveX(X)
    local list = {}
    if not GLOBAL.TheShard:IsSecondary() then
        if lang == "zh" then
            TheNet:Announce(lightbulb .. "开始清理" .. lightbulb)
        else
            TheNet:Announce(lightbulb .. "Server Cleaning begin" .. lightbulb)
        end
    end
    for k, v in pairs(GLOBAL.Ents) do
        -- 下面是修改部分，添加了风滚草的清理，同样加标志定时清理
        if type(v.prefab) == "string" then
            if isX(v.prefab, X) then
                v:Remove()
                local numm = list[v.name .. "  " .. v.prefab]
                if numm == nil then
                    list[v.name .. "  " .. v.prefab] = 1
                else
                    numm = numm + 1
                    list[v.name .. "  " .. v.prefab] = numm
                end
            end
        end
    end

    --如果list为空就不宣告
    if GLOBAL.next(list) ~= nil then
        for k, v in pairs(list) do
            print("wiped", v, k)
            if not GLOBAL.TheShard:IsSecondary() then
                if lang == "zh" then
                    TheNet:Announce(lightbulb .. "清理发现 " .. v .. " 组/个 " .. k .. lightbulb)
                else
                    TheNet:Announce(lightbulb .. "find " .. v .. k .. lightbulb)
                end
            end
        end
        print("Wiping Done!")
        if not GLOBAL.TheShard:IsSecondary() then
            if lang == "zh" then
                TheNet:Announce(lightbulb .. "服务器清理完毕" .. lightbulb)
            else
                TheNet:Announce(lightbulb .. "Server Cleaning Done" .. lightbulb)
            end
        end
    end
end

local function DoRemove()
    local list = {}
    local Removesign_c = {}
    if not GLOBAL.TheShard:IsSecondary() then
        if lang == "zh" then
            TheNet:Announce(lightbulb .. "开始清理" .. lightbulb)
        else
            TheNet:Announce(lightbulb .. "Server Cleaning begin" .. lightbulb)
        end
    end
    for k, v in pairs(GLOBAL.Ents) do
        if type(v.prefab) == "string" then
            if v.components and v.components.inventoryitem and v.components.inventoryitem.owner == nil then
                if (clean_mode == 0 and not isWhitelist(v.prefab) and not isWhiteTag(v))
                        or (clean_mode == 1 and isBlacklist(v.prefab))
                        or isHalfWhitelist(v) or isFloat(v) then
                    if WhiteArea(v) then
                        if v:HasTag("RemoveCountOne") and Positioncheck(v) then
                            v:Remove()
                            local numm = list[v.name .. "  " .. v.prefab]
                            if numm == nil then
                                list[v.name .. "  " .. v.prefab] = 1
                            else
                                numm = numm + 1
                                list[v.name .. "  " .. v.prefab] = numm
                            end
                        else
                            v:AddTag("RemoveCountOne")
                            local x, y, z = v.Transform:GetWorldPosition()
                            Removesign_c[v] = { x = math.floor(x), y = math.floor(y) }
                        end
                    end
                end
            end
        end
    end
    Removesign = Removesign_c
    --如果list为空就不宣告
    if GLOBAL.next(list) ~= nil then
        for k, v in pairs(list) do
            print("wiped", v, k)
            if not GLOBAL.TheShard:IsSecondary() then
                if lang == "zh" then
                    TheNet:Announce(lightbulb .. "清理发现 " .. v .. " 组/个 " .. k .. lightbulb)
                else
                    TheNet:Announce(lightbulb .. "find " .. v .. k .. lightbulb)
                end
            end
        end
        print("Wiping Done!")
        if not GLOBAL.TheShard:IsSecondary() then
            if lang == "zh" then
                TheNet:Announce(lightbulb .. "服务器清理完毕" .. lightbulb)
            else
                TheNet:Announce(lightbulb .. "Server Cleaning Done" .. lightbulb)
            end
        end
    end
end

local function DoStrongRemove()
    local list = {}
    for k, v in pairs(GLOBAL.Ents) do
        -- 下面是修改部分，添加了风滚草的清理，同样加标志定时清理
        if type(v.prefab) == "string" then
            if isStrongcleanlist(v.prefab) then
                if v.components.inventoryitem == nil or (v.components.inventoryitem and v.components.inventoryitem.owner == nil) then
                    if v:HasTag("RemoveCountOne") then
                        v:Remove()
                        local numm = list[v.name .. "  " .. v.prefab]
                        if numm == nil then
                            list[v.name .. "  " .. v.prefab] = 1
                        else
                            numm = numm + 1
                            list[v.name .. "  " .. v.prefab] = numm
                        end
                    else
                        v:AddTag("RemoveCountOne")
                    end
                end
            end
        end
    end

    --如果list为空就不宣告
    if GLOBAL.next(list) ~= nil then
        for k, v in pairs(list) do
            print("wiped", v, k)
            if not GLOBAL.TheShard:IsSecondary() then
                if lang == "zh" then
                    TheNet:Announce(lightbulb .. "强力清理了 " .. v .. " 组/个 " .. k .. lightbulb)
                else
                    TheNet:Announce(lightbulb .. "find " .. v .. k .. lightbulb)
                end
            end
        end
        print("Wiping Done!")
        if not GLOBAL.TheShard:IsSecondary() then
            if lang == "zh" then
                TheNet:Announce(lightbulb .. "服务器清理完毕" .. lightbulb)
            else
                TheNet:Announce(lightbulb .. "Server Cleaning Done" .. lightbulb)
            end
        end
    end
end

local function AutoDoRemove()
    local list = {}
    local countList = {}
    local Removesign_c = {}
    if not GLOBAL.TheShard:IsSecondary() then
        if lang == "zh" then
            TheNet:Announce(lightbulb .. "开始清理" .. lightbulb)
        else
            TheNet:Announce(lightbulb .. "Server Cleaning begin" .. lightbulb)
        end
    end
    local ents_copy = {}
    local ents_num = 0
    for k, v in pairs(Ents) do
        table.insert(ents_copy, v)
        ents_num = ents_num + 1
    end
    if ents_num < 1 then
        return
    end
    for k, v in pairs(ents_copy) do

        local max_clean = false
        local v_prefab = v.prefab
        if type(v_prefab) == "string" then
            if v_prefab and cleanmaxnum[v_prefab] then
                if countList[v_prefab] == nil then
                    countList[v_prefab] = 1
                else
                    countList[v_prefab] = countList[v_prefab] + 1
                    if cleanmaxnum[v_prefab].max < countList[v_prefab] and cleanmaxnum[v_prefab].max >= 0 then
                        max_clean = true
                    end
                end
            end
            local strong_clean = isStrongcleanlist(v_prefab)
            local inventoryitem_v = v.components.inventoryitem and v.components.inventoryitem.owner == nil
            if v and v:IsValid() and (inventoryitem_v or strong_clean or max_clean) then
                if (clean_mode == 0 and not isWhitelist(v_prefab) and not isWhiteTag(v))
                        or (clean_mode == 1 and isBlacklist(v_prefab))
                        or isHalfWhitelist(v) or isFloat(v) or strong_clean or max_clean then
                    if v and v:IsValid() and WhiteArea(v) then
                        if v and v:IsValid() and ((v:HasTag("RemoveCountOne") and (Positioncheck(v) or strong_clean)) or max_clean) then
                            v:Remove()
                            local numm = list[v.name .. "  " .. v_prefab]
                            if numm == nil then
                                list[v.name .. "  " .. v_prefab] = 1
                            else
                                numm = numm + 1
                                list[v.name .. "  " .. v_prefab] = numm
                            end
                            Sleep(math.min(0.01, 60 / ents_num))
                        else
                            v:AddTag("RemoveCountOne")
                            if not strong_clean then
                                local x, y, z = v.Transform:GetWorldPosition()
                                Removesign_c[v] = { x = math.floor(x), y = math.floor(y) }
                            end
                        end
                    end
                end
            end
        end

    end
    Removesign = Removesign_c
    --如果list为空就不宣告
    if GLOBAL.next(list) ~= nil then
        for k, v in pairs(list) do
            print("wiped", v, k)
            if not GLOBAL.TheShard:IsSecondary() then
                if lang == "zh" then
                    TheNet:Announce(lightbulb .. "清理发现 " .. v .. " 组/个 " .. k .. lightbulb)
                else
                    TheNet:Announce(lightbulb .. "find " .. v .. k .. lightbulb)
                end
            end
        end
        print("Wiping Done!")
        if not GLOBAL.TheShard:IsSecondary() then
            if lang == "zh" then
                TheNet:Announce(lightbulb .. "服务器清理完毕" .. lightbulb)
            else
                TheNet:Announce(lightbulb .. "Server Cleaning Done" .. lightbulb)
            end
        end
    end
end

-- local function WorldPeriodicRemove(inst)
--  if not GLOBAL.TheWorld:HasTag("cave") and GLOBAL.TheWorld.ismastersim then
--         inst:DoTaskInTime(.5, function(inst)
--          inst:ListenForEvent("cycleschanged", function()
--              local count_days = GLOBAL.TheWorld.state.cycles / checkingdays
--              if math.floor(count_days) == count_days then --默认每20天检查一次
--                     local do_remove = StartThread(function() DoRemove() end)
--                     local do_sremove = StartThread(function() DoStrongRemove() end)
--              end
--          end)
--         end)
--  end
-- end

-- local function CavePeriodicRemove(inst)
--  if GLOBAL.TheWorld:HasTag("cave") and GLOBAL.TheWorld.ismastersim then
--         inst:DoTaskInTime(.5, function(inst)
--          inst:ListenForEvent("cycleschanged", function()
--              local count_days = GLOBAL.TheWorld.state.cycles / checkingdays
--              if math.floor(count_days) == count_days then --默认每20天检查一次
--                     local do_remove = StartThread(function() DoRemove() end)
--                     local do_sremove = StartThread(function() DoStrongRemove() end)
--              end
--          end)
--         end)
--  end
-- end

-- AddPrefabPostInit("forest", WorldPeriodicRemove)
-- AddPrefabPostInit("cave", CavePeriodicRemove)

local function WorldRemove(inst)
    if GLOBAL.TheWorld.ismastersim then
        inst:DoTaskInTime(.5, function(inst)
            inst:ListenForEvent("cycleschanged", function()
                local count_days = GLOBAL.TheWorld.state.cycles / checkingdays
                if math.floor(count_days) == count_days then
                    --默认每20天检查一次
                    local do_remove = StartThread(AutoDoRemove)
                end
            end)
        end)
    end
end

AddPrefabPostInit("world", WorldRemove)

--添加手动清理的功能
GLOBAL.DoRemove = DoRemove
GLOBAL.CLX = DoRemoveX
GLOBAL.DoStrongRemove = DoStrongRemove

--For Boat

if GetModConfigData("boat_clean") then

    local boat_delete_time = GetModConfigData("boat_clean") * 480

    local function starttimer(inst)
        local players = inst.components.walkableplatform:GetEntitiesOnPlatform({ "player" }, nil)
        if #players == 0 then
            inst.components.timer:StartTimer("boatRemoval", boat_delete_time)
            --print("计时器：开始")
        end
    end

    local function stoptimer(inst, obj)
        if obj and obj:HasTag("player") then
            inst.components.timer:StopTimer("boatRemoval")
            --print("计时器：结束")
        end
    end

    local function ontimerdone(inst)
        local players = inst.components.walkableplatform:GetEntitiesOnPlatform({ "player" }, nil)
        if #players == 0 then
            inst:Remove()
            print("计时器：删除船")
        end
    end

    local function BoatAutoRemove(inst)
        if not GLOBAL.TheWorld.ismastersim then
            return inst
        end
        inst:AddComponent("timer")
        inst:ListenForEvent("obj_got_on_platform", stoptimer)
        inst:ListenForEvent("obj_got_off_platform", starttimer)
        inst.components.timer:StartTimer("boatRemoval", boat_delete_time)
        inst:ListenForEvent("timerdone", ontimerdone)
    end

    AddPrefabPostInit("boat", BoatAutoRemove)

end