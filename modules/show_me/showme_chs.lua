MY_STRINGS_OVERRIDE =
{
	{ armor = "防御: " }, --A
	{ aggro = "攻击: " }, --B
	{ cookpot = "正在烹饪: " }, --C (Crock Pot)
	{ dmg = "伤害: " }, --D
	{ electric = "电力: " }, --E --electric power
	{ food = "食物: "},
	{ S2 = "现在是夏天" }, --G
	{ health= "生命: " }, --H --for food
	{ warm = "保暖: " }, --I --winter insulation
	{ kill = "击杀: " }, --J	 --for Canibalism 18 mod
	{ kills = "击杀数: " }, --K  --for Canibalism 18 mod
	{ loyal = "忠诚:" }, --L  --pigman and bunnyman
	{ S4 = "现在是秋天" }, --M
	{ remaining_days = "剩余天数: " }, --N
	{ owner = "跟随者: " }, --O --support of various mods
	{ perish = "距离腐烂: " }, --P -- Spoil in N days.
	{ hunger= "饥饿: " }, --Q
	{ range = "范围: " }, --R  --for range weapon or for mobs
	{ sanity= "精神: " }, --S
	{ thickness = "厚度: " }, --T
	{ units_of = "单位" }, --U
	{ resist = "抵抗: " }, --V --against sleep darts, ice staff etc
	{ waterproof = "防水: " }, --W
	{ heal = "生命: " }, --X
	{ fishes = "鱼数量: " }, --Y	 --in a pond
	{ fish = "鱼: " }, --Z
	{ sec = "剩余时间(秒): " },  --([)for cooking in Crock Pot
	{ love = "喜爱: " }, --(~)
	{ summer = "隔热: " }, --(])summer insulation
	{ absorb = "伤害吸收: " }, --(^)
	{ S3 = "现在是春天" }, --(_)
	{ temperature = "温度: " }, --a
	{ hp= "生命值: " }, --for characters
	{ armor_character = "基础防御: " },
	{ sanity_character = "基础精神: " }, --S
	{ fuel = "燃料: " }, --F --for firepit
	{ speed = "移速: " },
	{ uses_of = "次可使用,总次数" },
	{ obedience = "顺从: " },
	{ S1 = "现在是冬天" },
	{ dmg_character = "基础伤害: " },
	{ power="造成伤害: "},-- 通常意味着武器的强度而不是物理伤害
	{ cooldown="冷却: "},
	{ domest = "驯服: " }, -- "Domestication:"
	{ will_die = "剩余: " }, --将在 N 天后死亡（关于宠物或动物）。
	{ will_dry = "剩余: " },
	{ dmg_bonus = "伤害: " }, -- 伤害：+X（表示伤害修正，不是基础伤害）
	{ crop = "" }, --未用，它只是信息类型的关键。 信息 - “物品：百分比”
	{ grow_in = "距离成长: " }, --About grass etc
	{ perish_product = " " }, --一般用在包裹，例如：定义为：已暂停，则显示 剩余天数:已暂停 0.4天
	{ just_time = " " }, --只是信息类型的关键。 信息 - [时间]
	{ timer = "预计: " },
	{ trade_gold = "价值金块: " },
	{ trade_rock = "价值石头: " },
	{ durability = "耐久度: " },
	{ strength = "攻击力: " },
	{ aoe = "群伤: " },
	{ is_admin = "这是管理员\n他不在游戏中\n所以不要在意他" }, --(@)
	{ food_temperature = "食物温度: " },
	{ precipitationrate = "世界雨: " },
	{ wetness = "世界湿润: " },
	{ growable = "成长: " },
	{ sanityaura = "精神: " },
	{ fresh = "达到最新鲜"}, --用于食物返鲜显示
	{ frigde = "冰箱"}, --For icebox etc
	{ food_memory = "效果"},
	{ buff = "增益"},
	{ effectiveness = "效率: "},
	{ force = "动力: "}, --船桨
	{ repairer = "修理: "},
	{ stress = "养分流失: "}, --农作物压力，定义通俗术语，因为养分都流失那么多了怎能巨大化
	{ stress_tag = " " },
	{ other_tag = " " }, --其他的TAGS
	{ harvest = "收获: " },
	{ children = "生物: " },
	{ basedmg = "位面伤害: " },
	{ basearmor = "位面防御: " },
	{ friendlevels = "好感度: " },
	--Thirst mod
	{ water = "水: " },
	{ salt = "盐: " },
	{ sip = "一口: " },
	{ watergainspeed = "水分增加速度: " },
	{ water_poisoned = "中毒了！" },
	--棱镜
	{ pollinated = "受粉: " },
	{ sickness = "疾病: " },
	{ infested = "侵害: " },
	-- 使用86，余22
}
--print("Show Me MY_STRINGS =",#MY_STRINGS); --73 now. Must be less than 94

SHOWME_STRINGS = {
	loyal = "臣服", --忠诚度
	of = "属于 ", -- X of Y (reserved)
	units_1 = "1 单位",
	units_many = " 单位",
	uses_1 = "1 次可使用,总次数 ",
	uses_many = " 次可使用,总次数 ", --X uses of Y, where X > 1
	days = " 天", --N天坏掉。
	temperature = "温度", -- 在食物信息中使用
	paused = "已暂停", --例如作物晚间暂停成长
	stopped = '已停止', --例如昨晚冬季停止成长
	already_fresh = "最大的新鲜度",
	cheat_fresh = "保鲜返鲜", --容器有返鲜功能存储食物的返回显示
	onpickup = " 采摘时", --对于花
	lack_of = '缺乏 ', -- 例如 缺乏肥料
	_in = ' 大约 ', -- X秒后的东西
	jieduan = "阶段", chixu = " 持续", pvp = "对你是: ", norot = "永久保鲜", hot = "变质速度 +", weak = "变质速度 +", cold = "保鲜倍率 +", refresh = "返鲜速度 +", xiaolv = "效率", fangyu = "防御", gongji = "攻击", fangshui = "防水", gandian = "感电攻击", faguang = "发光", huifu = "生命恢复",
}
--食物信息名称定义，例如【1 单位 veggie】，定义后显示【1单位 蔬菜】
FOOD_TAGS = {
	veggie = "蔬菜", fruit = "水果", monster = "怪物肉", sweetener = "糖类", meat = "肉类", fish = "鱼类", magic = "魔法", egg = "蛋类", decoration = "鳞翅", dairy = "乳制品", fat = "油脂", inedible = "枝条", frozen = "冰", ice = "冰", seed = "种子", seeds = "种子", mogu = "蘑菇", petals_legion = "花瓣", foliage = "蕨叶", rice = "米", insectoid = "昆虫", gourd = "葫芦", gel = "黏液", jellyfish = "水母", odoy_salt = "盐", ndnr_soybean = "大豆",
	--Waiter 101
	fungus = "菌类", mushrooms = "蘑菇", poultry = "禽肉", wings = "翅膀", seafood = "海鲜", nut = "坚果", cactus = "仙人掌", starch = "淀粉", grapes = "葡萄", citrus = "柑橘", tuber = "块茎", shellfish = "贝类",
	--BEEFALO MILK and CHEESE mod
	rawmilk = "鲜奶",
	--Camp Cuisine: Re-Lunched
	bulb = "荧光果", spices = "香料", challa = "哈拉面包", flour = "面粉",
	--Chocolate
	cacao_cooked = "可可",
}
--给显示预计:xxx定义名称，例如显示【预计:wall_cd 00:30】，定义名称后显示：【沙墙冷却 00:30】
INTERNAL_TIMERS = {
	--蚁狮Antlion
	wall_cd = "沙墙冷却", rage = '距离发怒', nextrepair = '进行恢复', eat_cd = "修复",
	--乌贼squid
	ink_cooldown = "喷墨冷却", gobble_cooldown = "吞食", --还有：大白鲨
	--中庭for atrium_gate
	destabilizing = "生物重生", destabilizedelay = "大门破坏", cooldown = "召唤冷却",
	--蜂后蜂巢beequeenhive
	hivegrowth1 = "第1阶段", hivegrowth2 = "第2阶段", hivegrowth = "第3阶段", shorthivegrowth = "蜂巢恢复", hiveregen = "蜂蜜再生", firsthivegrowth = "首次增长",
	--蜂后beequeen
	spawnguards_cd = "召唤蜜蜂", focustarget_cd = "号令冲撞",
	--帝王蟹crabking
	spell_cooldown = "咒语冷却", claw_regen_delay1 = "爪子 1", claw_regen_delay2 = "爪子 2", claw_regen_delay3 = "爪子 3", claw_regen_delay4 = "爪子 4", claw_regen_delay5 = "爪子 5", claw_regen_delay6 = "爪子 6", claw_regen_delay7 = "爪子 7", claw_regen_delay8 = "爪子 8", claw_regen_delay9 = "爪子 9", claw_regen_delay10 = "爪子 10", claw_regen_delay11 = "爪子 11", claw_regen_delay12 = "爪子 12", claw_regen_delay13 = "爪子 13", claw_regen_delay14 = "爪子 14", regen_crabking = "恢复", casting_timer = "施法预计", gem_shine = "映射宝石", clawsummon_cooldown = "爪召唤冷却", claw_regen_timer = "唤爪", seastacksummon_cooldown = "沸腾海域", fix_timer = "修复中", heal_cooldown = "修复冷却",
	--树木, 幽灵ghostly_elixirs.lua
	decay = "消失",
	--草蜥蜴grassgekko
	morphing = "生成", growTail = "长草",
	--飞荧光果lightflier_flower.lua, flower_cave.lua
	recharge = "蓄能", turnoff = "释放能量", Pickable_RegenTime = "再生",
	--鱼人王mermking.lua
	hungrytalk_increase_cooldown = "饥饿的对话增加",  hungrytalk_cooldown = "饥饿的谈话",
	--裸鼹鼠蝙蝠molebat.lua
	resetnap = "睡觉", cleannest_timer = "打扫蝠窝", resetallysummon = "召唤同伴", rememberinitiallocation = "标记位置",
	--海象营地的计时器名称：Timer names for warlus_camp:
	walrus = "海象刷新", little_walrus = "小海象刷新", icehound = "冰狗刷新",
	--寄居蟹hermitcrab.lua:
	speak_time = "发牢骚", complain_time = "诉说", salad = "花沙拉", bottledelay = "扔瓶子", fishingtime = "钓鱼",
	--hermit_grannied plus GUID -- 该词条会动态添加GUID，无法翻译
	--老麦影分身
	obliviate = "契约", --会在该时间后消失，定义为契约会更好
	--旺达, oceanwhirlportal
	closeportal = "传送关闭", closewhirlportal = "传送关闭",
	--邪天翁malbatross.lua:
	sleeping_relocate = "迁移", divetask = "潜水", disengage = "脱离", satiated = "抓鱼", splashdelay = "扑通",
	--蛤蟆toadstool.lua:
	sporebomb_cd = "孢子云", mushroombomb_cd = "蘑菇炸弹", mushroomsprout_cd = "蘑菇树", pound_cd = "蛤蟆蹲", channeltick = "施法等待", channel = "施法",
	--蘑菇toadstool_cap.lua
	darktimer = "中毒", respawndark = "毒菇重生", respawn = "重生",
	--海草waterplant.lua:
	resetcloud = "喷洒花粉", equipweapon = "装备武器",
	--waveyjones.lua:
	laughter = "笑声", reactiondelay = "反应延迟", respawndelay = "重生等待", trappedtimer = "禁锢",
	--熊灌bearger
	GroundPound = "熊抱", Yawn = "给爷睡",
	--克劳斯klaus
	chomp_cd = "撕咬", command_cd = "号令冰火",
	--大白鲨Shark, Shark Boi
	getdistance = "获取距离", minleaptime = "飞跃", calmtime = "冷静", targetboatdelay = "目标", standing_dive_cd = "跃起潜水", torpedo_cd = "旋转鱼蕾",
	--gobble_cooldown --duplicate
	--远古箱子sacred_chest.lua
	localoffering = "合成中", localoffering_pst = "提供（pst）",
	--复活的骷髅stalker.lua
	snare_cd = "画地为牢", spikes_cd = "万箭穿心", channelers_cd = "不动如山", minions_cd = "五谷丰登", mindcontrol_cd = "诛邪！",
	--无眼鹿deer.lua
	growantler = "鹿角生长", deercast_cd = "施法冷却",
	--沙拉蝾螈fruit_dragon.lua
	fire_cd = "冒火冷却", panicing = "败走",
	--月台moonbase.lua
	moonchargepre = "感应启动中", mooncharge = "完成转化", mooncharge2 = "打通通道", mooncharge3 = "吸取月能", fullmoonstartdelay = "启动等待",
	--龙蝇dragon fly
	regen_dragonfly = "再生", groundpound_cd = "怒火",
	--天体英雄
	hitsound_cd = "翻滚", roll_cooldown = "震地", summon_cooldown = "精神虚影", summon_cd = "精神虚影", spin_cd = "旋转攻击", spike_cd = "玻璃尖刺", traps_cd = "启迪陷阱", finish_pulse = "完成脉冲", trap_lifetime = "陷阱持续", pulse = "脉冲", runaway_blocker = "逃离",
	--远古守护
	forceleapattack = "跃击", forcebelch = "吐墨", rammed = "撞击", endstun = "结束眩晕", leapattack_cooldown = "弹跳攻击",
	--其他Others:
	repair = "修理", --尘蛾巢穴dustmothden
	dontfacetime = "不正视", --人鱼merm.lua
	--childspawner_regentime = "重生",
	growth = "生长", --盐堆saltstack.lua
	lordfruitfly_spawntime = "果蝇", -- farmin_manager.lua
	facetime = "正视", --mermbrain.lua
	regenover = "恢复", --药膏、肥包tillweedsalve.lua, compostwrap.lua, forgetmelots.lua, healthregenbuff.lua
	make_debris = "产生杂物", --杂草抵御weed_defs.lua
	spread = "蔓延", --杂草植物weed_plants.lua
	expire = "持续", --天体探测仪archive_resonator.lua
	drilling = "松土", --耕地机farm_plow.lua
	composting = "生成肥料", --堆肥桶compostingbin.lua
	HatchTimer = "孵化", --鹿鸭蛋mooseegg.lua
	lifespan = "剩余", --海鱼oceanfish.lua
	offeringcooldown = "采摘冷却", --火鸡perd.lua
	rock_ice_change = "冰变化", updatestage = "冰变化", --冰山rock_ice.lua
	lifetime = "生存", --schoolherd.lua
	disperse = "退散", --睡眠云、孢子云sleepcloud.lua, sporecloud.lua, waterplant_pollen.lua, chum_aoe.lua
	extinguish = "距离消失", --唤星stafflight.lua
	transform_cd = "变大冷却", --伯尼bernie_active.lua, bernie_big.lua, bernie_inactive.lua
	taunt_cd = "呵~弱者", --伯尼嘲讽bernie
	buffover = "Buff", --食物BUFF（例如冬季盛宴）foodbuffs.lua, wintersfeastbuff.lua, halloweenpotion_buffs.lua
	resettoss = "跳跃冷却", --一角鲸gnarwail.lua
	revive = "再生", --犬堆hound_corpse.lua
	toot = "释放", --天体裂隙moon_fissure.lua
	training = "训练", --gym.lua (component)
	salt = "舔盐", --saltlicker.lua (component)
	foodspoil = "距离死亡", --陷阱trap.lua (component)
	--巨鹿deerclops
	laserbeam_cd = "激光", auratime = "绝对零度", uppercuttime = "蓄力爪", Freeze = "千里冰封",
	--鹿鸭moose
	DisarmCooldown = "震吼", SuperHop = "跳跃", WantsToLayEgg = "下蛋", TornadoAttack = "召唤旋风",
	explode = "爆炸", --孢子炸弹sporebomb.lua
	selfdestruct = "自爆", --熔岩虫stalker_minions.lua, lavae.lua
	self_combustion = "持续", --漂浮灯笼miniboatlantern.lua
	despawn_timer = "契约", --召唤猪猪pigelitefighter.lua
	rotting = "枯萎", --农作物plant_normal.lua
	grow = "种苗", --树、石果planted_tree.lua, rock_avocado_fruit.lua
	remove = "消除", --fishschoolspawnblocker.lua
	Spawner_SpawnDelay = "生成", --pighouse
	blink = "闪烁", flamethrower_cd = "极寒冰焰", ash = "燃尽",
	infest_cd = "感染冷却",
	disappear = "消失", errode = "消失",
	--机器人扫描仪
	toplightflash_tick = "正在扫描", onsucceeded_flashtick = "完成捕获", onsucceeded_timeout = "捕获冷却", chargeregenupdate = "电量增加", ANNOUNCE_WX_SCANNER_NEW_FOUND = "宣布新发现",
	--植物人契约
	finish_transformed_life = "契约",
	--水中木群落
	lookforfish = "出巡", eat_cooldown = "抓鱼冷却", investigating = "巡视中", enriched_cooldown = "养分吸收", shed = "脱落", facetarget = "对视", flotsamgenerator_sink = "沉没", cocoon_regrow_check = "虫茧再生", regrow_oceantreenut = "无花果种子再生",
	-- 月亮码头
	startportalevent = "事件启动", fireportalevent = "事件发生中", spawnportalloot_tick = "生成物品", right_of_passage = "通行证生效", hit = "攻击",
	--泰拉
	summon_delay = "正在召唤", warning = "预警", spawneyes_cd = "生成小眼", leash_cd = "施展法术", charge_cd = "冲撞",
	--暗影与月亮阵营
	targetswitched = "目标切换", attack_cooldown = "攻击冷却", idletimer = "柱立时间", try_crystals = "正在扩张",trynextstage = "下一阶段", seedmiasma = "溶合暗影", close = "裂隙关闭", jump_cooldown = "跳跃攻击", chase_tick = "分裂", finish_spawn = "完成生成", start_explosion = "爆炸", spawn_delay = "生成延迟", start_ball_growing = "膨胀", stalk_cd = "缓行", roar_cd = "咆哮", loot_spawn_cd = "再次生成",
	--神话
	growup = "成长", light = "灯光剩余", peach = "桃子剩余", blackbear = "黑风刷新", despawn = "消失", flyaway = "飞走", goaway = "离开", cd = "冷却", myth_nian_timer = "年兽", nian_leave = "年兽占据", bomb_cd = "腐败云", bombboom = "腐败云引爆", nian_noclose = "不打烊", nian_killed = "商品打折", timeover = "契约", yj_spear_elec = "充能",
	TreeDance = "树舞", --大小生物
	--海难
	startsink = "沉没", go_home_delay = "回家", SPIKE = "长刺", Run = "撕咬", --run似乎是攻击行为
	--不妥协
	regrow = "再生", passedby = "经过", infest =  "蛀虫", vomit_time = "呕吐", unelectrify = "放电", electrify = "充电中", scoutingparty = "侦察队", stumptime = "距离变异", pounce = "猛扑", mortar = "吐丝", RockThrow = "投掷", glassshards = "碎片攻击", summoncrystals = "召唤水晶", defusetime = "破碎", natural_death = "距离死亡", remoss = "蚜虫", podreset = "种荚恢复", refill = "重新填充", SpitCooldown = "投掷",--海象,蜘蛛女王
	--棱镜
	axeuppercut_cd = "斧头上挥", heavyhack_cd = "重劈", callforlightning_cd = "雷电招来", rangesplash_cd = "飞电/突击", flashwhirl_cd = "闪电旋风", dehydration = "脱水腐烂", birddeath = "玄鸟重生", birth = "破壳", state1 = "孵化 1 阶", state2 = "孵化 2 阶", state3 = "孵化 3 阶", taunt = "魔音绕梁", caw = "花寄语", flap = "羽乱舞", flap_pre = "羽乱舞pre", eye = "同目同心", revolt = "反抗热涌", moonsurge = "月耀涌动", fallenleaf = "掉落", swallow = "吞食", lure = "诱捕",
	--富贵(定时器名称太长了, 占用太多行, 放弃)
	evergreenpluckabletimer = "采摘冷却", beehivepluckabletimer = "蜂蜜再生", beequeenhivegrownpluckabletimer = "偷取图纸冷却",
}
INTERNAL_STAGES = {
	--所有的树:
	short = "小", normal = "中", tall = "大", old = "枯萎",
	--蜘蛛巢:
	small = "小", med = "中", large = "满阶", queen = "分离",
	--石果:
	stage_1 = "没果子", stage_2 = "再等等", stage_3 = "成熟", stage_4 = "裂开",
	--杂项植物:
	--small --duplicate
	--med --duplicate
	full = "成熟", bolting = "???", empty = "空枝",
	--农场植物:
	seed = "种子", sprout = "发芽", rotten = "距离反生",
	--小高脚鸟
	--small --duplicate
	--tall  --duplicate
	--小牛:
	baby = "幼牛", toddler = "小牛", teen = "青年", grown = "成年",
	--神话
	blooming = "开花", fruitful = "硕果累累",
}

STRESS_TAGS = { --https://dontstarve.fandom.com/wiki/Farm_Plant
	nutrients = "缺乏肥料", moisture = "缺少水分", killjoys = "附近有影响生长物", family = "缺少家族", season = "不适应这季节", overcrowding = "过于拥挤", happiness = "不开心",
	withered = "已枯萎",
}

OTHER_TAGS = {	--拿不到的数值先写死吧
	onemanband = "照顾农作物\n演奏可使猪人/兔人跟随",
	amulet = "作祟可复活",
	book_birds = "召唤鸟类",
	book_brimstone = "召唤数道闪电",
	book_gardening = "范围: 30\n催熟范围内植物",
	book_silviculture = "范围: 30\n让植物生长到最大阶段",
	book_sleep = "范围: 30\n催眠生物",
	wx78_music = "照顾附近农作物",
	wx78_movespeed2 = "之后每个增幅约 60%",
	wx78_heat = "提供增温及增温光环",
	wx78_moisture = "干燥加快: 10%",
	wx78_cold = "提供降温及降温光环",
	wx78module_taser = "提供防雷保护\n提供感电攻击BUFF",
	wx78module_nightvision = "提供夜视能力",
	wx78module_light = "提供发光光环",
	slingshot_frame_bone = "弹药框 +1",
	slingshot_frame_gems = "弹药框 +1\n炮击特效弹药群体范围 3.5",
	slingshot_frame_wagpunk_0 = "蓄力伤害 1~2 倍\n蓄力位面伤害 1~2 倍\n蓄力子弹速度 1~1.25 倍",
	slingshot_handle_voidcloth = "风帽加强绝望石、纯粹恐惧弹药\n伤害 +10%\n位面伤害 +5\n群聚恐怖 +2次",

	--万圣节
	halloweenpotion_health = "生命恢复 +1/秒, 持续 60 秒",
	halloweenpotion_sanity = "精神恢复 +1/秒, 持续 60 秒",
	--大力士
	wolfgang_whistle = "范围: 6 地皮\n随从获得9.5秒双倍伤害\n玩家获得 5 精神增益",
	--弹珠
	slingshotammo_freeze = "冻结目标",
	slingshotammo_poop = "让目标失去仇恨",
	slingshotammo_thulecite = "暗影触手召唤概率 50%",	--math.random() < 0.5
	--棱镜
	lileaves = "-30% 对方攻击力",
	rosorns = "无视对方护甲",
	--海难
	shark_teethhat = "船上精神 +6.6/分钟",
	brainjellyhat = "免科技制作",
	gashat = "防气体毒气",
	armorseashell = "防物理中毒",
}

OTHER_TITLES = {	--%s 是获取官方tuning.lua的对应值，如果模组不是通过tuning修改值可能会导致显示不正确
	spice_salt = "食物血量 +%s",
	maxhealth = "最大生命值 +%s",
	maxsanity = "最大精神值 +%s",
	maxhunger = "最大饥饿值 +%s",
	wx78_hot_cold = "食物腐烂速度: %s",
	wx78_cold3 = "潮湿高于 %s 产生冰块",
	ghost_atkf = "护盾伤害: %s",
	hungerslow = "饥饿减缓: %s",
	healthpertick = "生命恢复: +%s",
	ghost_atk = "获得夜间伤害, 持续 %s 天",
	ghost_shd = "护盾时长增至 1 秒, 持续 %s 天",
	ghost_sd = "移速 +%s, 持续 %s 天",
	batbat = "攻击吸血 %s, 精神 %s",
	book_hlt = "催熟 %s 株作物",
	ruins_bat = "暗影触手几率: %s",
	ruinshat = "保护罩几率: %s",
	bs_dy = "武器耐久减缓 %s",
	bs_hp = "攻击生命恢复 +%s/次 (薇格弗德 %s)",
	bs_san = "攻击精神恢复 +%s/次",
	bs_desan = "负面精神效果 -%s",
	bs_fire = "受火焰伤害减 -%s",
	bs_it = "嘲讽范围内敌人",
	bs_ip = "范围内敌人恐慌 %s 秒",
	bs_shadow = "对月亮阵营生物伤害 +%s",
	bs_shadow2 = "受到暗影阵营生物伤害 %s",
	bs_lunar = "对暗影阵营生物伤害 +%s",
	bs_lunar2 = "受到月亮阵营生物伤害 %s",
	hpotion_bravery = "抵抗砍树和开宝箱产生蝙蝠, 持续 %s 天",
	sammo_slow = "目标移速 %s, 持续 %s 秒",
	resist = "对位面抵抗: ",
	dmgresist = "拥有位面抵抗",
	point = " 点",
	grow_in = "距离成长：",
	grow_time = "@成长时间：",
	energytime = "能量剩余: ",
	seednum = "正在转化: ",
	fruitnum = "已转化: ",
	second = " 秒",
	_in = " 大约 ",
	will_other = "剩余: ",
	fueled = "耐久: ",
	moisture = "剩余水分: ",
	nutrients = "肥料: ",
	nutrients_1 = "催长剂: ",
	nutrients_2 = "堆肥: ",
	nutrients_3 = "粪肥: ",
	capacity = "容量: ",
	siv_mask = "储存: ",
	siv_light = "光耀: ",
	siv_health = "生命: ",
	ot_fuel = "燃料: ",
	ot_fuelval = "燃料值: ",
	lg_moon = "镶嵌: ",
	sammo_honey = "目标移速 %s",
	ot_pickable = "采摘次数: ",
	mpl_hit = "位面加深 %s/击，持续 %s 秒",
	shf_hit = "群聚恐怖 %s/次，共 %s 次",
	slingshot_range = "弹弓范围: +%s",
	ammo_speed = "子弹速度: +%s",
	slingshot_speed = "%s 概率不消耗子弹",
	critterhunger = "饥饿剩余: ",

	beerpowerpower = "不灵电力: ",
	waterpowerpower = "不灵水量: ",
	gaspowerpower = "不灵气体: ",
}
-- local doc_data={
-- ["stresspoints"] = "养分流失",
-- ["nutrients"]    = "缺乏营养",
-- ["moisture"]     = "缺少水分",
-- ["family"]       = "缺少家族",
-- ["overcrowding"] = "过于拥挤",
-- ["killjoys"]     = "附近有影响生长物",
-- ["happiness"]    = "不开心",
-- ["season"]       = "不适应这季节",
-- }


MY_DATA.uses_of.fn = function(arr)
	--return "可使用次数 " .. arr.param[1] .. "\n总使用次数 " .. arr.param[2]
	return "耐久: " .. arr.param[1] .. " / " .. arr.param[2]
end

UpdateNewLanguage()