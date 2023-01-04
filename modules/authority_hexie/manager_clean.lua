local _G = GLOBAL
local TheNet = _G.TheNet

local IsServer = TheNet:GetIsServer() or TheNet:IsDedicated()

local TUNING = _G.TUNING

local clean_level = _G.tonumber(GetModConfigData("clean_level"))
local clean_period = _G.tonumber(GetModConfigData("clean_period"))
local clean_custom = GetModConfigData("clean_custom")

if IsServer then
    -- 需要清理的物品
    -- @permission 标识为true时表示仅清理无权限的物品
    -- @stack      标识为true时表示仅清理无堆叠的物品
    -- @reclean    标识为数字,表示超过第n次清理时物品还存在则强制清理(第一次找到物品并未清理的计数为1)
    local function GetLevelPrefabs(level)
        local levelPrefabs = {
            ------------------------ 生物 ------------------------
            hound = {max = 10 * level}, -- 狗
            firehound = {max = 10 * level}, -- 火狗
            spider_warrior = {max = 10 * level}, -- 蜘蛛战士
            spider = {max = 10 * level}, -- 蜘蛛
            spiderqueen = {max = 5 * level}, -- 蜘蛛女王
            flies = {max = 10 * level}, -- 苍蝇
            mosquito = {max = 10 * level}, -- 蚊子
            bee = {max = 10 * level}, -- 蜜蜂
            killerbee = {max = 10 * level}, -- 杀人蜂
            --mole            = { max = 20 * level },   -- 鼹鼠
            frog = {max = 10 * level}, -- 青蛙
            grassgekko = {max = 20 * level}, -- 草蜥蜴
            beefalo = {max = 20 * level}, -- 牛
            babybeefalo = {max = 20 * level}, -- 小牛
            lightninggoat = {max = 20 * level}, -- 山羊
            deer = {max = 20 * level}, -- 圣诞鹿
            bunnyman = {max = 10 * level}, -- 兔人
            snurtle = {max = 10 * level}, -- 蜗牛
            pigman = {max = 10 * level}, -- 猪人
            rocky = {max = 10 * level}, -- 石虾
            --leif            = { max = 2 * level },    -- 树精
            --spat            = { max = 1 * level },    -- 钢羊
            --warg            = { max = 1 * level },    -- 座狼
            mooseegg = {max = 1 * level}, -- 春鸭巢
            --moose           = { max = 1 * level },    -- 春鸭
            --bearger         = { max = 1 * level },    -- 熊
            --deerclops       = { max = 1 * level },    -- 巨鹿
            tentacle = {max = 100 * level}, -- 触手
            butterfly = {max = 10 * level}, -- 蝴蝶
            rabbit = {max = 20 * level}, -- 兔子
            ------------------------ 地面物体 ------------------------
            grass = {max = 200 * level, permission = true}, -- 草
            sapling = {max = 200 * level, permission = true}, -- 树苗
            berrybush = {max = 200 * level, permission = true}, -- 浆果丛
            berrybush2 = {max = 200 * level, permission = true}, -- 分叉浆果丛
            berrybush_juicy = {max = 100 * level, permission = true}, -- 多汁浆果丛
            flower = {max = 100 * level, permission = true}, -- 花
            acorn_sapling = {max = 100 * level, permission = true}, -- 桦树苗
            pinecone_sapling = {max = 100 * level, permission = true}, -- 松树苗
            pinecone_sapling = {max = 100 * level, permission = true}, -- 松树苗
            twiggy_nut_sapling = {max = 100 * level, permission = true}, -- 树枝树苗
            lumpy_sapling = {max = 100 * level, permission = true}, -- 常青树苗
            deciduoustree = {max = 100 * level, permission = true}, -- 桦树
            evergreen = {max = 100 * level, permission = true}, -- 松树
            evergreen_sparse = {max = 200 * level, permission = true}, -- 常青树
            twiggytree = {max = 100 * level, permission = true}, -- 树枝树
            marsh_tree = {max = 100 * level, permission = true}, -- 针刺树
            rock_petrified_tree = {max = 0 * level}, -- 石化树
            skeleton_player = {max = 5 * level}, -- 玩家尸体
            spiderden = {max = 2 * level}, -- 1级蜘蛛巢
            spiderden_2 = {max = 2 * level}, -- 2级蜘蛛巢
            spiderden_3 = {max = 2 * level}, -- 3级蜘蛛巢
            burntground = {max = 0 * level}, -- 陨石痕跡
            seastack = {max = 0 * level}, -- 海蚀柱
            antlion_sinkhole = {max = 0 * level}, -- 蚁狮地陷
            cavein_boulder = {max = 0 * level}, -- 蚁狮地下落石
            molehill = {max = 30 * level}, -- 鼹鼠洞
            wetpouch = {max = 0 * level}, -- 袋子
            fertilizer = {max = 0 * level}, -- 大便桶
            ------------------------ 可拾取物品 ------------------------
            seeds = {max = 0 * level}, -- 种子
            log = {max = 0 * level, stack = true, reclean = 3}, -- 木头
            cutgrass = {max = 0 * level, stack = true, reclean = 3}, -- 草
            twigs = {max = 0 * level, stack = true, reclean = 3}, -- 树枝
            charcoal = {max = 0 * level, reclean = 1}, -- 碳
            rocks = {max = 0 * level, stack = true, reclean = 3}, -- 石头
            nitre = {max = 0 * level, stack = true, reclean = 3}, -- 硝石
            flint = {max = 0 * level, stack = true, reclean = 3}, -- 燧石
            marble = {max = 0 * level, stack = true, reclean = 3}, -- 大理石
            beardhair = {max = 0 * level, stack = true, reclean = 3}, -- 胡子
            cutreeds = {max = 0 * level, stack = true, reclean = 3}, -- 芦苇
            poop = {max = 0 * level, stack = true, reclean = 3}, -- 屎
            guano = {max = 0 * level}, -- 鸟屎
            manrabbit_tail = {max = 0 * level, stack = true, reclean = 3}, -- 兔毛
            lavae_egg = {max = 0, reclean = 1}, -- 岩浆虫卵
            silk = {max = 0, reclean = 1}, -- 蜘蛛丝
            spidergland = {max = 0 * level, stack = true, reclean = 1}, -- 蜘蛛腺体
            stinger = {max = 0 * level, stack = true, reclean = 1}, -- 蜂刺
            houndstooth = {max = 0 * level, stack = true, reclean = 1}, -- 犬牙
            mosquitosack = {max = 0 * level, stack = true, reclean = 1}, -- 蚊子血袋
            glommerfuel = {max = 0 * level, stack = true, reclean = 1}, -- 格罗姆粘液
            slurtleslime = {max = 0 * level}, -- 蜗牛粘液
            slurtle_shellpieces = {max = 0 * level}, -- 蜗牛壳碎片
            phlegm = {max = 0 * level}, -- 痰
            spoiled_food = {max = 0 * level, stack = true, reclean = 3}, -- 腐烂食物
            boards = {max = 0 * level, stack = true, reclean = 3}, -- 木板
            cutstone = {max = 0 * level, stack = true, reclean = 3}, -- 石砖
            rope = {max = 0 * level, stack = true, reclean = 3}, -- 草绳
            pinecone = {max = 0 * level, stack = true, reclean = 3}, -- 松果
            acorn = {max = 0 * level, stack = true, reclean = 3}, -- 桦树果
            twiggy_nut = {max = 0 * level, stack = true, reclean = 3}, -- 多枝树果
            furtuft = {max = 0 * level, stack = true, reclean = 3}, -- 毛簇
            slurper_pelt = {max = 0 * level, stack = true, reclean = 3}, -- 吞噬者皮
            goose_feather = {max = 0 * level, stack = true, reclean = 3}, -- 鹅毛
            rottenegg = {max = 0 * level}, -- 烂鸡蛋
            feather_crow = {max = 0 * level, stack = true, reclean = 3}, -- 黑色羽毛
            feather_robin = {max = 0 * level, stack = true, reclean = 3}, -- 红色羽毛
            feather_robin_winter = {max = 0 * level, stack = true, reclean = 3}, -- 蓝色羽毛
            feather_canary = {max = 0 * level, stack = true, reclean = 3}, -- 金色羽毛
            beefalowool = {max = 0 * level, stack = true, reclean = 3}, -- 牛毛
            pig_token = {max = 0 * level}, -- 金腰带
            hivehat = {max = 0 * level}, -- 蜂王头盔
            armorskeleton = {max = 2 * level}, -- 白骨盔甲
            skeletonhat = {max = 2 * level}, -- 白骨头盔
            thurible = {max = 2 * level}, -- 暗影香炉
            spoiled_fish = {max = 0 * level, stack = true, reclean = 3}, -- 变质的鱼
            spoiled_fish_small = {max = 0 * level, stack = true, reclean = 3}, -- 变质小鱼
            zyzs = {max = 0 * level, stack = true, reclean = 2}, -- 变质小鱼
            zyjb = {max = 0 * level, stack = true, reclean = 2}, -- 变质小鱼
            ------------------------ 工具 ------------------------
            blueprint = {max = 0 * level}, -- 蓝图
            axe = {max = 0 * level}, -- 斧子
            torch = {max = 0 * level}, -- 火炬
            pickaxe = {max = 0 * level}, -- 镐子
            shovel = {max = 0 * level}, -- 铲子
            razor = {max = 0 * level}, -- 剃刀
            pitchfork = {max = 0 * level}, -- 草叉
            bugnet = {max = 0 * level}, -- 捕虫网
            fishingrod = {max = 0 * level}, -- 魚竿
            spear = {max = 0 * level}, -- 矛
            blowdart_sleep = {max = 0 * level}, -- 催眠吹箭
            blowdart_fire = {max = 0 * level}, -- 燃烧吹箭
            blowdart_pipe = {max = 0 * level}, -- 吹箭
            blowdart_yellow = {max = 0 * level}, -- 电磁吹箭
            strawhat = {max = 0 * level}, -- 草帽
            armorgrass = {max = 0 * level}, -- 草甲
            earmuffshat = {max = 0 * level}, -- 兔耳罩
            winterhat = {max = 0 * level}, -- 寒冬帽
            catcoonhat = {max = 0 * level}, -- 浣熊猫帽子
            spiderhat = {max = 0 * level}, -- 蜘蛛帽子
            balloon = {max = 30 * level}, -- 小丑气球
            trap = {max = 30 * level}, -- 动物陷阱
            birdtrap = {max = 30 * level}, -- 鸟陷阱
            compass = {max = 0 * level}, -- 指南針
            tentaclespike = {max = 3 * level}, -- 触手棒
            candybag = {max = 0 * level}, -- 糖果袋
            ------------------------ 图纸 ------------------------
            red_mushroomhat_blueprint = {max = 0 * level}, -- 红蘑菇帽子
            green_mushroomhat_blueprint = {max = 0 * level}, -- 绿蘑菇帽子
            blue_mushroomhat_blueprint = {max = 0 * level}, -- 蓝蘑菇帽子
            mushroom_light_blueprint = {max = 0 * level}, -- 萤菇灯
            mushroom_light2_blueprint = {max = 0 * level}, -- 炽菇灯
            dragonflyfurnace_blueprint = {max = 0 * level}, -- 龙鳞火炉
            townportal_blueprint = {max = 0 * level}, -- 懒惰逃亡者
            bundlewrap_blueprint = {max = 0 * level}, -- 捆绑包裹
            goggleshat_blueprint = {max = 0 * level}, -- 时髦帽子
            deserthat_blueprint = {max = 0 * level}, -- 沙漠风镜
            succulent_potted_blueprint = {max = 0 * level}, -- 盆栽蓝图
            ------------------------ 雕塑图纸 ------------------------
            chesspiece_muse_sketch = {max = 0 * level , stack = true, reclean = 1}, -- 王后图纸
            chesspiece_formal_sketch = {max = 0 * level, stack = true, reclean = 1}, -- 国王图纸
            chesspiece_pawn_sketch = {max = 0 * level, stack = true, reclean = 1}, -- 士兵图纸
            tacklesketch = {max = 0 * level}, -- 渔具草
            chesspiece_crabking_sketch = {max = 0, reclean = 1}, -- 蜜蜂
            chesspiece_malbatross_sketch = {max = 0, reclean = 1}, -- 士兵图纸
            chesspiece_claywarg_sketch = {max = 0, reclean = 1},
            chesspiece_moosegoose_sketch = {max = 0, reclean = 1},
            chesspiece_dragonfly_sketch = {max = 0, reclean = 1},
            chesspiece_bearger_sketch = {max = 0, reclean = 1},
            chesspiece_deerclops_sketch = {max = 0, reclean = 1},
            chesspiece_crabking_sketch = {max = 0, reclean = 1},
            chesspiece_malbatross_sketch = {max = 0, reclean = 1},
            chesspiece_antlion_sketch = {max = 0, reclean = 1},
            chesspiece_beequeen_sketch = {max = 0, reclean = 1},
            chesspiece_klaus_sketch = {max = 0, reclean = 1},
            chesspiece_stalker_sketch = {max = 0, reclean = 1},
            chesspiece_toadstool_sketch = {max = 0, reclean = 1},
            chesspiece_knight_sketch = {max = 0, reclean = 1},
            chesspiece_bishop_sketch = {max = 0, reclean = 1},
            chesspiece_rook_sketch = {max = 0, reclean = 1},
            chesspiece_formal_sketch = {max = 0, reclean = 1},
            chesspiece_muse_sketch = {max = 0, reclean = 1},
            chesspiece_pawn_sketch = {max = 0, reclean = 1},
            chesspiece_anchor_sketch = {max = 0, reclean = 1},
            chesspiece_butterfly_sketch = {max = 0, reclean = 1},
            chesspiece_moon_sketch = {max = 0, reclean = 1},
            chesspiece_claywarg_sketch = {max = 0, reclean = 1},
            chesspiece_clayhound_sketch = {max = 0, reclean = 1},
            chesspiece_carrat_sketch = {max = 0, reclean = 1},
            expbean = {max = 0, reclean = 1},  ---经验豆
            lucky_goldnugget = {max = 0, reclean = 1}, -----元宝
            ------------------------ 冬季盛宴物品 ------------------------
            winter_food1 = {max = 0 * level}, -- 小姜饼
            winter_food2 = {max = 0 * level}, -- 糖曲奇饼
            winter_food3 = {max = 0 * level}, -- 拐杖糖
            winter_food4 = {max = 0 * level}, -- 永远的水果蛋糕
            winter_food5 = {max = 0 * level}, -- 巧克力树洞蛋糕
            winter_food6 = {max = 0 * level}, -- 李子布丁
            winter_food7 = {max = 0 * level}, -- 苹果酒
            winter_food8 = {max = 0 * level}, -- 热可可
            winter_food9 = {max = 0 * level}, -- 美味的蛋酒
            winter_ornament_plain1 = {max = 0 * level}, -- 圆形节日灯泡（不发光）1
            winter_ornament_plain2 = {max = 0 * level}, -- 圆形节日灯泡（不发光）2
            winter_ornament_plain3 = {max = 0 * level}, -- 圆形节日灯泡（不发光）3
            winter_ornament_plain4 = {max = 0 * level}, -- 圆形节日灯泡（不发光）4
            winter_ornament_plain5 = {max = 0 * level}, -- 圆形节日灯泡（不发光）5
            winter_ornament_plain6 = {max = 0 * level}, -- 圆形节日灯泡（不发光）6
            winter_ornament_plain7 = {max = 0 * level}, -- 圆形节日灯泡（不发光）7
            winter_ornament_plain8 = {max = 0 * level}, -- 圆形节日灯泡（不发光）8
            winter_ornament_plain9 = {max = 0 * level}, -- 圆形节日灯泡（不发光）9
            winter_ornament_plain10 = {max = 0 * level}, -- 圆形节日灯泡（不发光）10
            winter_ornament_plain11 = {max = 0 * level}, -- 圆形节日灯泡（不发光）11
            winter_ornament_plain12 = {max = 0 * level}, -- 圆形节日灯泡（不发光）12
            winter_ornament_fancy1 = {max = 0 * level}, -- 圣诞小玩意1
            winter_ornament_fancy2 = {max = 0 * level}, -- 圣诞小玩意2
            winter_ornament_fancy3 = {max = 0 * level}, -- 圣诞小玩意3
            winter_ornament_fancy4 = {max = 0 * level}, -- 圣诞小玩意4
            winter_ornament_fancy5 = {max = 0 * level}, -- 圣诞小玩意5
            winter_ornament_fancy6 = {max = 0 * level}, -- 圣诞小玩意6
            winter_ornament_fancy7 = {max = 0 * level}, -- 圣诞小玩意7
            winter_ornament_fancy8 = {max = 0 * level}, -- 圣诞小玩意8
            winter_ornament_boss_bearger = {max = 0 * level}, -- 华丽的装饰-熊獾
            winter_ornament_boss_deerclops = {max = 0 * level}, -- 华丽的装饰-巨鹿
            winter_ornament_boss_moose = {max = 0 * level}, -- 华丽的装饰-春鹅
            winter_ornament_boss_dragonfly = {max = 0 * level}, -- 华丽的装饰-龙蝇
            winter_ornament_boss_beequeen = {max = 0 * level}, -- 华丽的装饰-蜂后
            winter_ornament_boss_toadstool = {max = 0 * level}, -- 华丽的装饰-蛤蟆
            winter_ornament_boss_antlion = {max = 0 * level}, -- 华丽的装饰-蚁狮
            winter_ornament_boss_fuelweaver = {max = 0 * level}, -- 华丽的装饰-远古编织者
            winter_ornament_boss_klaus = {max = 0 * level}, -- 华丽的装饰-克劳斯
            winter_ornament_boss_krampus = {max = 0 * level}, -- 华丽的装饰-坎普斯
            winter_ornament_boss_noeyered = {max = 0 * level}, -- 华丽的装饰-红宝石鹿
            winter_ornament_boss_noeyeblue = {max = 0 * level}, -- 华丽的装饰-蓝宝石鹿
            winter_ornament_festivalevents1 = {max = 0 * level}, -- 雄伟的熔炉猪战士饰品
            winter_ornament_festivalevents2 = {max = 0 * level}, -- 犀牛兄弟饰品
            winter_ornament_festivalevents3 = {max = 0 * level}, -- 地狱独眼巨猪饰品
            winter_ornament_festivalevents4 = {max = 0 * level}, -- 姆西饰品
            winter_ornament_festivalevents5 = {max = 0 * level}, -- 比利饰品
            ------------------------ 万圣夜物品 ------------------------
            trinket_1 = {max = 5 * level}, -- 融化的大理石
            trinket_2 = {max = 5 * level}, -- 假卡祖笛
            trinket_3 = {max = 5 * level}, -- 戈尔迪乌姆之结
            trinket_4 = {max = 5 * level}, -- 地精玩偶
            trinket_5 = {max = 5 * level}, -- 小型火箭飞船
            trinket_6 = {max = 5 * level}, -- 破烂电线
            trinket_7 = {max = 5 * level}, -- 球与奖杯
            trinket_8 = {max = 5 * level}, -- 硬化橡胶塞
            trinket_9 = {max = 5 * level}, -- 不匹配的纽扣
            trinket_10 = {max = 5 * level}, -- 二手假牙
            trinket_11 = {max = 5 * level}, -- 半躺机器人
            trinket_12 = {max = 5 * level}, -- 干瘪触手
            trinket_13 = {max = 5 * level}, -- 地精
            trinket_14 = {max = 5 * level}, -- 漏水的茶杯
            trinket_15 = {max = 2 * level}, -- 白色主教
            trinket_16 = {max = 2 * level}, -- 黑色主教
            trinket_17 = {max = 5 * level}, -- 弯曲的叉勺
            trinket_18 = {max = 5 * level}, -- 玩具木马
            trinket_19 = {max = 5 * level}, -- 陀螺
            trinket_20 = {max = 5 * level}, -- 挠痒器
            trinket_21 = {max = 5 * level}, -- 敲打锤
            trinket_22 = {max = 5 * level}, -- 不耐磨的毛线
            trinket_23 = {max = 5 * level}, -- 蹄脚
            trinket_24 = {max = 5 * level}, -- 幸运猫罐
            trinket_25 = {max = 5 * level}, -- 空气清新剂
            trinket_26 = {max = 5 * level}, -- 土豆杯
            trinket_27 = {max = 1 * level}, -- 钢丝绳
            trinket_28 = {max = 1 * level}, -- 白色战车
            trinket_29 = {max = 1 * level}, -- 黑色战车
            trinket_30 = {max = 1 * level}, -- 白色骑士
            trinket_31 = {max = 1 * level}, -- 黑色骑士
            trinket_32 = {max = 5 * level}, -- 方晶锆球
            trinket_33 = {max = 5 * level}, -- 蜘蛛指环
            trinket_34 = {max = 5 * level}, -- 猴爪
            trinket_35 = {max = 5 * level}, -- 容量瓶
            trinket_36 = {max = 5 * level}, -- 假牙
            trinket_37 = {max = 5 * level}, -- 断桩
            trinket_38 = {max = 5 * level}, -- 双筒望远镜
            trinket_39 = {max = 5 * level}, -- 单只手套
            trinket_40 = {max = 5 * level}, -- 蜗牛秤
            trinket_41 = {max = 5 * level}, -- 黏液罐
            trinket_42 = {max = 5 * level}, -- 玩具眼镜蛇
            trinket_43 = {max = 5 * level}, -- 鳄鱼玩具
            trinket_44 = {max = 5 * level}, -- 破碎的玻璃罐
            trinket_45 = {max = 5 * level}, -- 奇怪的收音机
            trinket_46 = {max = 5 * level}, -- 损坏的吹风机
            halloweencandy_1 = {max = 0 * level}, -- 糖果苹果
            halloweencandy_2 = {max = 0 * level}, -- 糖果玉米
            halloweencandy_3 = {max = 0 * level}, -- 不太甜的玉米
            halloweencandy_4 = {max = 0 * level}, -- 粘液蜘蛛
            halloweencandy_5 = {max = 0 * level}, -- 浣猫糖果
            halloweencandy_6 = {max = 0 * level}, -- 葡萄干
            halloweencandy_7 = {max = 0 * level}, -- 葡萄干
            halloweencandy_8 = {max = 0 * level}, -- 鬼魂波普
            halloweencandy_9 = {max = 0 * level}, -- 果冻虫
            halloweencandy_10 = {max = 0 * level}, -- 触须棒棒糖
            halloweencandy_11 = {max = 0 * level}, -- 巧克力猪
            halloweencandy_12 = {max = 0 * level}, -- 糖果虱
            halloweencandy_13 = {max = 0 * level}, -- 无敌硬糖
            halloweencandy_14 = {max = 0 * level}, -- 熔岩椒
            halloween_ornament_1 = {max = 0 * level}, -- 幽灵装饰
            halloween_ornament_2 = {max = 0 * level}, -- 蝙蝠装饰
            halloween_ornament_3 = {max = 0 * level}, -- 蜘蛛装饰
            halloween_ornament_4 = {max = 0 * level}, -- 触手装饰
            halloween_ornament_5 = {max = 0 * level}, -- 悬垂蜘蛛装饰
            halloween_ornament_6 = {max = 0 * level}, -- 乌鸦装饰
            ------------------------ 火鸡年 ------------------------
            perdfan = {max = 0 * level}, -- 幸运扇
            redlantern = {max = 0 * level}, -- 红灯笼
            firecrackers = {max = 0 * level}, -- 红色爆竹
            houndwhistle = {max = 0 * level}, -- 幸运哨子
            dragonbodyhat = {max = 0 * level}, -- 幸运兽躯体
            dragonheadhat = {max = 0 * level}, -- 幸运兽脑袋
            dragontailhat = {max = 0 * level}, -- 幸运兽尾巴
            xuantie  				= { max = 0, reclean = 3 },
            xtsp  					= { max = 0, reclean = 3 },
            livinglog = {max = 0, stack = true, reclean = 3},
            marble = {max = 0, reclean = 3},
            moonrocknugget = {max = 0, reclean = 3},
            thulecite = {max = 0, stack = true, reclean = 3},
            thulecite_pieces = {max = 0, stack = true, reclean = 3}, --- 铥矿石碎片
            redgem  				= { max = 0,  reclean = 1   },  --- 红宝石
            bluegem  				= { max = 0,  reclean = 1   },  --- 蓝宝石
            purplegem  				= { max = 0, reclean = 1   },  --- 紫宝石
            greengem  				= { max = 0,  reclean = 1   },  --- 绿宝石
            orangegem  				= { max = 0, reclean = 1    },  --- 橙宝石
            yellowgem  				= { max = 0, reclean = 1    },  --- 黄宝石
            opalpreciousgem  		= { max = 0, reclean = 1    },  --- 彩色宝石
            rope = {max = 0, stack = true, reclean = 3}, --- 绳子
            boards = {max = 0, stack = true, reclean = 3}, --- 木板
            cutstone = {max = 0, stack = true, reclean = 3}, --- 石砖
            papyrus = {max = 0, stack = true, reclean = 3}, --- 莎草纸
            nightmarefuel = {max = 0, stack = true, reclean = 3}, --- 噩梦燃料 ：
            beeswax = {max = 0, stack = true, reclean = 3}, --- 蜂蜡
            pigskin = {max = 0, stack = true, reclean = 3}, --- 猪皮
            coontail = {max = 0, stack = true, reclean = 3}, --- 猫尾
            walrus_tusk = {max = 0, stack = true, reclean = 3}, --- 海象牙
            tentaclespots = {max = 0, stack = true, reclean = 3}, --- 触手皮     ：：：：：：：
            dragon_scales = {max = 10, stack = true, reclean = 3}, --- 鳞片
            bearger_fur = {max = 10, stack = true, reclean = 3}, --- 厚皮毛
            deerclops_eyeball = {max = 10, stack = true, reclean = 3}, --- 巨鹿眼球
            shroom_skin = {max = 0, stack = true, reclean = 3}, --- 毒蕈皮
            fossil_piece = {max = 0, stack = true, reclean = 3}, --- 化石碎片
            boneshard = {max = 0, stack = true, reclean = 3}, --- 骨片
            waterballoon = {max = 0, stack = true, reclean = 3}, --- 水球
            spidereggsack = {max = 0, stack = true, reclean = 1}, --- 蜘蛛卵
            xxsq = {max = 5, stack = true, reclean = 2}, --- xxsq
            drumstick = {max = 0, reclean = 1}, --- 鹅掉落物
            minotaurhorn = {max = 10, reclean = 3}, --- 远古守护者角
            glommerwings = {max = 0, reclean = 3}, --- 格罗门翅膀
            glommerflower = {max = 0, reclean = 3}, --- 格罗门花
            deer_antler = {max = 0, reclean = 1}, --- 鹿茸
            klaussackkey = {max = 0, reclean = 1}, --- 克劳斯钥匙
            horn = {max = 0, reclean = 1}, --- 牛角  ：：：：：：：（吹好的，可以装饰自己的窝~）：
            goldenaxe = {max = 0, reclean = 1}, --- 金斧头
            goldenpickaxe = {max = 0, reclean = 1}, --- 黄金鹤嘴锄   ：：
            goldenshovel = {max = 0, reclean = 1}, --- 黄金铁铲
            multitool_axe_pickaxe = {max = 0, reclean = 1}, --- 镐斧
            pumpkin_lantern = {max = 5, reclean = 1}, --- 南瓜灯
            featherfan = {max = 0, reclean = 1}, --- 鹅毛扇
            krampus_sack = {max = 0, reclean = 0}, --- 坎普斯背包
            spear_wathgrithr = {max = 0, reclean = 1}, --- 瓦丝格雷斯矛  ：：：：：
            bedroll_furry = {max = 0, reclean = 1}, --- 毛皮铺盖
            footballhat = {max = 0, reclean = 1}, --- 猪皮头盔
            beehat = {max = 0, reclean = 1}, --- 养蜂人的帽子 ：：：：：
            walrushat = {max = 0, reclean = 1}, --- 贝雷帽
            armorwood = {max = 0, reclean = 1}, --- 木盔甲
            armormarble = {max = 0, reclean = 1}, --- 大理石盔甲
            --------------------能力勋章--------------------------
            down_filled_coat = {max = 0, reclean = 1},
            immortal_fruit = {max = 0, reclean = 1},
            immortal_gem = {max = 0, reclean = 1},
            multivariate_certificate = {max = 0, reclean = 1},
            chef_certificate = {max = 0, reclean = 1},
            headchef_certificate = {max = 0, reclean = 1},
            wisdom_test_certificate = {max = 0, reclean = 1},
            wisdom_certificate = {max = 0, reclean = 1},
            handy_test_certificate = {max = 0, reclean = 1},
            handy_certificate = {max = 0, reclean = 1},
            plant_certificate = {max = 0, reclean = 1},
            transplant_certificate = {max = 0, reclean = 1},
            harvest_certificate = {max = 0, reclean = 1},
            friendly_certificate = {max = 0, reclean = 1},
            smallchop_certificate = {max = 0, reclean = 1},
            mediumchop_certificate = {max = 0, reclean = 1},
            largechop_certificate = {max = 0, reclean = 1},
            smallminer_certificate = {max = 0, reclean = 1},
            mediumminer_certificate = {max = 0, reclean = 1},
            largeminer_certificate = {max = 0, reclean = 1},
            blank_certificate = {max = 0, reclean = 1},
            ommateum_certificate = {max = 0, reclean = 1},
            inherit_certificate = {max = 0, reclean = 1},
            justice_certificate = {max = 0, reclean = 1},
            arrest_certificate = {max = 0, reclean = 1},
            speed_certificate = {max = 0, reclean = 1},
            treadwater_certificate = {max = 0, reclean = 1},
            tentacle_certificate = {max = 0, reclean = 1},
            valkyrie_test_certificate = {max = 0, reclean = 1},
            valkyrie_certificate = {max = 0, reclean = 1},
            merm_certificate = {max = 0, reclean = 1},
            immortal_book = {max = 0, reclean = 1},
            monster_book = {max = 0, reclean = 1},
            unsolved_book = {max = 0, reclean = 1},
            autotrap_book = {max = 0, reclean = 1},
            naughty_certificate = {max = 0, reclean = 1},
            spider_certificate = {max = 0, reclean = 1},
            devour_staff = {max = 0, reclean = 1},
            immortal_staff = {max = 0, reclean = 1},
            bathingfire_certificate = {max = 0, reclean = 1},
            silence_certificate = {max = 0, reclean = 1},
            bottled_soul = {max = 0, reclean = 1},
            bottled_moonlight = {max = 0, reclean = 1},
            hat_blue_crystal = {max = 0, reclean = 1},
            devour_soul_certificate = {max = 0, reclean = 1},
            down_filled_coat_certificate = {max = 0, reclean = 1},
            blue_crystal_certificate = {max = 0, reclean = 1},
            smallfishing_certificate = {max = 0, reclean = 1},
            mediumfishing_certificate = {max = 0, reclean = 1},
            largefishing_certificate = {max = 0, reclean = 1},
            armor_blue_crystal = {max = 0, reclean = 1},
            armor_medal_obsidian = {max = 0, reclean = 1},
            sanityrock_fragment = {max = 0, reclean = 1},
            sanityrock_mace = {max = 0, reclean = 1},
            ---------------------------修仙物品--------------------------
            --xxsq  					= { max = 5, reclean = 3   },  --- xxsq
            bookinfo_myth = {max = 0, reclean = 1},  --天书
            wb_strengthen_strengthen_protectpaper = {max = 0, reclean = 1},
            wb_strengthen_strengthen_7_levelpaper = {max = 0, reclean = 1}, --{ "+7强化卷轴", "莫得灵魂的强化", "非酋福利" },
            wb_strengthen_strengthen_8_levelpaper = {max = 0, reclean = 1},--{ "+8强化卷轴", "莫得灵魂的强化", "非酋福利" },
            wb_strengthen_strengthen_9_levelpaper = {max = 0, reclean = 1},--{ "+9强化卷轴", "莫得灵魂的强化", "非酋福利" },
            wb_strengthen_strengthen_10_levelpaper = {max = 0, reclean = 1},--{ "+10强化卷轴", "莫得灵魂的强化", "非酋福利" },
            wb_strengthen_strengthen_11_levelpaper= {max = 0, reclean = 1},--{ "+11强化卷轴", "莫得灵魂的强化", "非酋福利" },
            wb_strengthen_strengthen_12_levelpaper = {max = 0, reclean = 1},--{ "+12强化卷轴", "莫得灵魂的强化", "非酋福利" },
            wb_strengthen_increase_7_levelpaper = {max = 0, reclean = 1},--{ "+7附魔卷轴", "莫得灵魂的附魔", "非酋福利" },
            wb_strengthen_increase_8_levelpaper = {max = 0, reclean = 1},--{ "+8附魔卷轴", "莫得灵魂的附魔", "非酋福利" },
            wb_strengthen_increase_9_levelpaper = {max = 0, reclean = 1},--{ "+9附魔卷轴", "莫得灵魂的附魔", "非酋福利" },
            wb_strengthen_increase_10_levelpaper = {max = 0, reclean = 1},--{ "+10附魔卷轴", "莫得灵魂的附魔", "非酋福利" },
            wb_strengthen_increase_11_levelpaper = {max = 0, reclean = 1},--{ "+11附魔卷轴", "莫得灵魂的附魔", "非酋福利" },
            wb_strengthen_increase_12_levelpaper = {max = 0, reclean = 1},--{ "+12附魔卷轴", "莫得灵魂的附魔", "非酋福利" },
            wb_strengthen_clearpaper = {max = 0, reclean = 1},--{ "净化卷轴", "真的有人会用这玩意嘛", "忘掉一切" },
            wb_strengthen_bindpaper ={max = 0, reclean = 1},--{ "契约卷轴", "契约卷轴", "一起来签订签约吧" },
            wb_strengthen_strengthen_protectpaper = {max = 0, reclean = 1},--{ "强化保护卷", "没它我可不敢强化", "不慌！装备还在！" },
            wb_strengthen_increase_protectpaper = {max = 0, reclean = 1},--{ "附魔保护卷", "没它我可不敢附魔", "不慌！装备还在！" },
            wb_strengthen_strengthen_food = {max = 0, reclean = 1},--{ "强化秘药", "有了它我觉得我又行了！", "提升强化成功率" },
            wb_strengthen_increase_food = {max = 0, reclean = 1},--{ "附魔秘药", "有了它我觉得我又行了！", "提升附魔成功率" },
            wb_handsskill_paper = {max = 0, reclean = 1},--{ "魔法卷轴（???）", "拾之无味，弃之可惜", "赋予装备技能" },
            hat_adai = {max = 0, reclean = 3}, --- 阿呆眼镜
            hat_dalishi = {max = 0, reclean = 3}, --- 大力士眼镜
            hat_cat = {max = 0, reclean = 3}, --- 粉红色眼镜
            panflute = {max = 1, reclean = 3}, --- 排箫
            backpack = {max = 0, reclean = 0}, --- 背包
            wharang_foxhat = {max = 0, reclean = 3}, --------- 狐狸面具
            chesspiece_antlion_sketch = {max = 0, reclean = 3}, --------- 蚁狮雕像
            chesspiece_beequeen_sketch = {max = 0, reclean = 3}, --------- 蜂后雕像
            chesspiece_dragonfly_sketch = {max = 0, reclean = 3}, --------- 龙鹰雕像
            oceanfishingbobber_goose_tacklesketch = {max = 0, reclean = 3},
            --------- 鹿鹅掉落
            chesspiece_toadstool_sketch = {max = 0, reclean = 3},
            --------- 蛤蟆雕像
            red_cap = {max = 0, reclean = 3},
            --------- 红帽子
            blue_cap = {max = 0, reclean = 3},
            --------- 蓝帽子
            green_cap = {max = 0, reclean = 3},
            --------- 绿帽子
            hat_tuer = {max = 0, reclean = 3},
            --------- 猪猪帽子
            deerhat = {max = 0, reclean = 3},
            --------- 鹿帽子
            zoroswordmouth = {max = 3, reclean = 0},
            --------- 道一文字
            zorosheath = {max = 3, reclean = 0},
            --------- 刀鞘
            atrium_key = {max = 0, reclean = 3},
            --------- 远古钥匙
            slurtlehat = {max = 0, reclean = 3},
            --------- 蜗牛头盔
            yellowstaff = {max = 0, reclean = 3},
            --------- 星星杖
            --opalstaff					= { max = 10, reclean = 3  },--------- 月杖
            armor_sanity = {max = 0, reclean = 3},
            --------- 影甲
            wathgrithrhat = {max = 0, reclean = 3},
            --------- 女士头盔
            ruinshat = {max = 0, reclean = 3},
            ---------远古王冠
            minerhat = {max = 0, reclean = 3},
            ---------矿工帽子
            armorsnurtleshell = {max = 0, reclean = 3},
            ---------蜗牛壳
            armorruins = {max = 0, reclean = 3},
            ---------铥矿甲
            fimbul_axe = {max = 0, reclean = 3},
            ---------布莱斧头
            tourmalinecore = {max = 0, reclean = 3},
            ---------电气石
            backcub = {max = 0, reclean = 3},
            ---------靠背熊
            merm_scales = {max = 0, reclean = 3},
            ---------鱼鳞
            shadowheart = {max = 3, reclean = 3},
            ---------心脏
            pill_bottle_gourd_bb = {max = 0, reclean = 3},
            ---------丹药葫芦
            pill_bottle_gourd = {max = 0, reclean = 3},
            ---------丹药葫芦
            kam_lan_cassock = {max = 0, reclean = 3},
            ---------袈裟
            kam_lan_cassock_blueprint = {max = 0, reclean = 3},
            ---------袈裟蓝图
            cassock = {max = 0, reclean = 3},
            ---------袈裟
            honeycomb = {max = 0, reclean = 1},
            ---------蜂巢
            honey = {max = 0, reclean = 3},
            ---------蜂蜜
            lureplantbulb = {max = 0, reclean = 3},
            ---------食人花种子
            cbdz0 = {max = 0, reclean = 3},
            ---------神话羽翼
            cbdz1 = {max = 0, reclean = 3},
            ---------神话羽翼
            cbdz2 = {max = 0, reclean = 3},
            ---------神话羽翼
            cbdz3 = {max = 0, reclean = 3},
            ---------神话羽翼
            cbdz4 = {max = 0, reclean = 3},
            ---------神话羽翼
            cbdz5 = {max = 0, reclean = 3},
            ---------神话羽翼
            cbdz6 = {max = 0, reclean = 3},
            ---------神话羽翼
            cbdz7 = {max = 0, reclean = 3},
            ---------神话羽翼
            cbdz8 = {max = 0, reclean = 3},
            ---------神话羽翼
            nightmare_timepiece = {max = 0, reclean = 3},
            ---------远古徽章
            purple_gourd = {max = 3, reclean = 3},
            ---------紫金葫芦
            rock1 = {max = 0, reclean = 3},
            ---------铥矿甲 rock mushtree
            rock2 = {max = 0, reclean = 3},
            ---------铥矿甲 rock mushtree
            rock_flintless = {max = 0, reclean = 3},
            ---------铥矿甲 rock mushtree
            rock_flintless_med = {max = 0, reclean = 3},
            ---------铥矿甲 rock mushtree
            rock_flintless_low = {max = 0, reclean = 3},
            ---------铥矿甲 rock mushtree
            --mushtree					= { max = 0, reclean = 3   },---------铥矿甲 rock  stalagmite_full
            stalagmite_full = {max = 0, reclean = 3},
            ---------铥矿甲 rock
            stalagmite_med = {max = 0, reclean = 3},
            ---------铥矿甲 rock
            stalagmite_low = {max = 0, reclean = 3},
            ---------铥矿甲 rock
            stalagmite = {max = 0, reclean = 3},
            ---------铥矿甲 rock
            stalagmite_tall = {max = 0, reclean = 3},
            ---------铥矿甲 rock
            stalagmite_tall_full = {max = 0, reclean = 3},
            ---------铥矿甲 rock
            stalagmite_tall_med = {max = 0, reclean = 3},
            ---------铥矿甲 rock
            stalagmite_tall_low = {max = 0, reclean = 3},
            ---------铥矿甲 rock  rock_ice
            rock_ice = {max = 30, reclean = 3},
            ---------铥矿甲 rock
            mushtree_small = {max = 0, reclean = 3},
            mushtree_medium = {max = 0, reclean = 3},
            mushtree_tall = {max = 0, reclean = 3},
            green_mushroom = {max = 40, reclean = 3},
            red_mushroom = {max = 40, reclean = 3},
            blue_mushroom = {max = 40, reclean = 3},
            cave_fern = {max = 30, reclean = 3}, ---蕨类植物
            lichen = {max = 30, reclean = 3},
            ---苔藓
            carrot_planted = {max = 30, reclean = 3}, ----地上胡萝卜
            flower_cave = {max = 30, reclean = 3}, ----荧光果
            flower_cave_double = {max = 30, reclean = 3},
            flower_cave_triple = {max = 30, reclean = 3},
            flower = {max = 30, reclean = 3}, ----花
            mermhouse = {max = 30, reclean = 3, permission = true},
            ---------鱼人房
            rabbithole = {max = 30, reclean = 3, permission = true},
            ---------兔子穴
            rabbithouse = {max = 30, reclean = 3, permission = true},
            ---------兔子穴
            beebox = {max = 30, reclean = 3, permission = true},
            ---------蜂巢建筑
            pighouse = {max = 30, reclean = 3, permission = true},
            ---------蜂巢建筑 rock_avocado_fruit
            rock_avocado_fruit = {max = 0, reclean = 3},
            ---------石果 moonglass
            moonglass = {max = 0, reclean = 3},
            ---------月亮碎片
            --nightmare_timepiece			= { max = 0, reclean = 3 },--------远古徽章
            singingshell_octave3 = {max = 0, reclean = 3},
            ---------贝壳3
            singingshell_octave4 = {max = 0, reclean = 3},
            ---------贝壳3
            singingshell_octave5 = {max = 0, reclean = 3},
            ---------贝壳3
            oceanfishinglure_hermit_rain = {max = 0, reclean = 3},
            ---------贝壳3
            oceanfishinglure_hermit_snow = {max = 0, reclean = 3},
            ---------贝壳3
            oceanfishinglure_hermit_drowsy = {max = 0, reclean = 3},
            ---------贝壳3
            oceanfishinglure_hermit_heavy = {max = 0, reclean = 3},
            ---------贝壳3
            book_myth = {max = 1, reclean = 3},
            ---------无字天书
            wintersfeastfuel = {max = 0, reclean = 3},
            ---------节日欢愉
            dug_rock_avocado_bush = {max = 30, reclean = 3, permission = true}, -- 是果树苗
            rock_avocado_fruit = {max = 10, reclean = 3, permission = true}, -- 石果
            rock_avocado_bush = {max = 100, reclean = 3, permission = true} -- 是果树
        }

        return levelPrefabs
    end

    -- 自定义清理
    local function GetCustomPrefabs(prefabs, base_max_prefabs)
        if base_max_prefabs == nil then
            base_max_prefabs = GetLevelPrefabs(clean_level)
        end

        if type(prefabs) == "string" then
            for prefab, num in string.gmatch(prefabs, "([%w_]+):(%w+)") do
                num = _G.tonumber(num)
                print("[防熊锁]自定义清理", prefab, num)
                base_max_prefabs[prefab] = num and {max = num} or nil
            end
        end

        return base_max_prefabs
    end
    local max_prefabs = GetCustomPrefabs(clean_custom)

    local function IsInInventory(inst)
        return inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner ~= nil
    end

    local function RemoveItem(inst)
        if inst.components.health ~= nil and not inst:HasTag("wall") then
            if inst.components.lootdropper ~= nil then
                inst.components.lootdropper.DropLoot = function(pt)
                end
            end
            inst.components.health:SetPercent(0)
        else
            inst:Remove()
        end
    end

    local function Clean(inst, level)
        TheNet:Announce(GetSayMsg("cleaning", formServerName))
        print("[防熊锁]开始清理...")
        local this_max_prefabs = level and GetCustomPrefabs(clean_custom, GetLevelPrefabs(level)) or max_prefabs
        local countList = {}
        local countPer = {}
        local thisPrefab = nil

        for _, v in pairs(_G.Ents) do
            if v.prefab ~= nil then
                repeat
                    thisPrefab = v.prefab
                    if this_max_prefabs[thisPrefab] ~= nil then
                        if v.reclean == nil then
                            v.reclean = 1
                        else
                            v.reclean = v.reclean + 1
                        end

                        local bNotClean = true
                        if this_max_prefabs[thisPrefab].reclean ~= nil then
                            bNotClean = this_max_prefabs[thisPrefab].reclean > v.reclean
                        end

                        if
                            this_max_prefabs[thisPrefab].stack and bNotClean and v.components and v.components.stackable and
                                v.components.stackable:StackSize() > 1
                         then
                            break
                        end

                        if this_max_prefabs[thisPrefab].permission then
                            if countPer[thisPrefab] == nil then
                                countPer[thisPrefab] = {}
                            end
                            countPer[thisPrefab][#countPer[thisPrefab] + 1] = {
                                v,
                                (v.ownerlist ~= nil or v.saved_ownerlist ~= nil) and bNotClean and 1 or 0
                            }
                            break
                        end
                    else
                        break
                    end

                    -- 不可见物品(在包裹内等)
                    if v.inlimbo then
                        break
                    end

                    -- 在包裹内物品
                    --if IsInInventory(v) then break end

                    if countList[thisPrefab] == nil then
                        countList[thisPrefab] = {name = v.name, count = 1, currentcount = 1}
                    else
                        countList[thisPrefab].count = countList[thisPrefab].count + 1
                        countList[thisPrefab].currentcount = countList[thisPrefab].currentcount + 1
                    end

                    if this_max_prefabs[thisPrefab].max >= countList[thisPrefab].count then
                        break
                    end

                    if
                        (v.components.hunger ~= nil and v.components.hunger.current > 0) or
                            (v.components.domesticatable ~= nil and v.components.domesticatable.domestication > 0)
                     then
                        break
                    end

                    RemoveItem(v)
                    countList[thisPrefab].currentcount = countList[thisPrefab].currentcount - 1
                until true
            end
        end

        -- 需要判断权限的物体单独清理
        for k, v in pairs(countPer) do
            if #v > this_max_prefabs[k].max then
                table.sort(
                    v,
                    function(a, b)
                        return a[2] < b[2]
                    end
                )
                countList[k] = {name = v[1][1].name, count = #v, currentcount = #v}
                repeat
                    local itemObj = table.remove(v, 1)
                    if itemObj[2] == 0 then
                        RemoveItem(itemObj[1])
                        countList[k].currentcount = #v
                    else
                        break
                    end
                until this_max_prefabs[k].max >= #v
            end
        end

        for k, v in pairs(this_max_prefabs) do
            if countList[k] ~= nil and countList[k].count > v.max then
                print(
                    string.format(
                        "[防熊锁]清理   %s(%s)   %d   %d   %d",
                        countList[k].name,
                        k,
                        countList[k].count,
                        countList[k].count - countList[k].currentcount,
                        countList[k].currentcount
                    )
                )
            end
        end
    end

    local function CleanDelay(inst, time, level)
        TheNet:Announce(GetSayMsg("clean_warning", formServerName, time))
        inst:DoTaskInTime(time, Clean, level)
    end

    if clean_level ~= -1 then
        AddPrefabPostInit(
            "world",
            function(inst)
                if clean_period > 0 then
                    inst:DoPeriodicTask(
                        clean_period * TUNING.TOTAL_DAY_TIME,
                        CleanDelay,
                        clean_period * TUNING.TOTAL_DAY_TIME,
                        60
                    )
                end
            end
        )
    end

    -- 控制台命令
    _G.hx_clean = function(time, level)
        time = _G.tonumber(time)
        level = level and _G.tonumber(level) or (clean_level == -1 and 3 or nil)
        print("[防熊锁]手动清理", "hx_clean", time, level)
        if time ~= nil and time > 0 then
            CleanDelay(_G.TheWorld, time, level)
        else
            Clean(_G.TheWorld, level)
        end
    end

    _G.hx_clean_lv = function(level)
        level = _G.tonumber(level)
        print("[防熊锁]设置清理级别", level)
        if level ~= nil then
            clean_level = level
            max_prefabs = GetCustomPrefabs(clean_custom)
        end
    end

    _G.hx_clean_custom = function(custom_prefabs)
        clean_custom = custom_prefabs
        print("[防熊锁]设置自定义清理物品", custom_prefabs)
        max_prefabs = GetCustomPrefabs(clean_custom, max_prefabs)
    end

    _G.hx_clean_list = function()
        print("[防熊锁]待清理物品当前总数")
        local countList = {}
        local thisPrefab = nil

        for _, v in pairs(_G.Ents) do
            if v.prefab ~= nil then
                thisPrefab = v.prefab
                if max_prefabs[thisPrefab] ~= nil and not v.inlimbo then
                    if countList[thisPrefab] == nil then
                        countList[thisPrefab] = {name = v.name, count = 1, currentcount = 1}
                    else
                        countList[thisPrefab].count = countList[thisPrefab].count + 1
                    end
                end
            end
        end

        for k, v in pairs(max_prefabs) do
            if countList[k] ~= nil then
                print("[防熊锁]", countList[k].name .. "(" .. k .. ")", countList[k].count)
            end
        end
    end
end
