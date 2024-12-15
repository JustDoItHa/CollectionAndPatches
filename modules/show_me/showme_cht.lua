MY_STRINGS_OVERRIDE =
{
	armor = "傷害吸收: " , --A --Armor of the item.
	aggro = "攻擊力: " , --B --Score of griefing
	cookpot = "正在烹煮: " , --C (Crock Pot)
	dmg = "傷害: " , --D
	electric = "電力: " , --E --electric power
	food = "食物: ",
	S2="現在是夏天," , --G
	health= "生命: " , --H --for food
	warm = "凍結抗性: " , --I --winter insulation
	kill = "擊殺: " , --J  --for Canibalism 18 mod (if character murder only once)
	kills = "擊殺數: " , --K  --for Canibalism 18 mod (shows count of kills)
	loyal = "忠誠: " , --L  --pigman and bunnyman
	S4="現在是秋天," , --M
	remaining_days = "剩餘天數: " , --N
	owner = "跟隨者: " , --O --support of various mods
	perish = "距離腐爛: " , --P -- Spoil in N days.
	hunger= "飢餓: " , --Q
	range = "範圍: " , --R  --for range weapon or for mobs
	sanity= "理智: " , --S
	thickness = "厚度: " , --T --It's about thickness of the ice of a pond
	units_of = "單位" , --U
	resist = "抵抗: " , --V --against sleep darts, ice staff etc
	waterproof = "潮濕抗性: " , --W --Resistance against water
	heal = "治療: " , --X --How much health will be restored by some medic pack
	fishes = "魚數量: " , --Y  --Count fishes in a pond
	fish = "魚: " , --Z --Count fishes in a pond if there is only 1 fish
	sec= "剩餘時間(秒): " ,  --for cooking in Crock Pot
	love = "喜愛: " ,
	summer = "過熱抗性: " , --summer insulation
	absorb = "傷害吸收: " , --Absorb damage
	S3="現在是春天," , --
	temperature = "溫度: " ,
	hp= "生命值: " , --for characters
	armor_character = "防禦: " , --Armor of the creature or player.
	sanity_character = "理智: " , --S
	fuel = "燃料: " , --F --for firepit
	speed = "移速: " , --Bonus of the speed (percent)
	uses_of = "次可使用, 總次數" ,
	obedience = "服從: " ,
	S1="現在是冬天," ,
	dmg_character = "攻擊力: " ,
	power = "造成傷害: ", --P
	cooldown="冷卻: ",
	domest = "馴化: ", -- "Domestication:"
	will_die = "剩餘: ", -- will die in N days (saying about pet or animal).
	will_dry = "剩餘: ", --
	dmg_bonus = "傷害乘數: ", -- Damage: +X (means damage modifier, not base damage)
	crop = "", --Not used. It's just a key for info type. Info - "Product: percent"
	grow_in = "成長: ", -- About grass etc
	perish_product = "", --Just a key for info type. Info - "Product: time in days"
	just_time = "", --Just a key for info type. Info - [time]
	timer = "預計: ",
	trade_gold = '價值金塊: ',
	trade_rock = '價值石頭: ',
	durability = '耐久度: ',
	strength = '攻擊力: ',
	aoe = "群傷: ",
	is_admin = "這是管理員！\n他不進行遊戲，\n所以不要在意他。" ,
	food_temperature = "食物溫度: ",
	precipitationrate = "世界雨: ",
	wetness = "世界濕潤: ",
	growable = "成長: ",
	sanityaura = "理智: ",
	fresh = "達到最新鮮",
	frigde = "冰箱",
	food_memory = "效果",
	buff = "增益",
	effectiveness = "實效: ",
	force = "動力: ",
	repairer = "修理: ",
	stress = "養分流失: ",
	stress_tag = " ",
	other_tag = " ",
	harvest="收穫: ",
	children="生物: ",
	basedmg = "位面傷害: ",
	basearmor = "位面防禦: ",
	--Thirst mod
	water = "水: ",
	salt = "鹽: ",
	sip = "一口: ",
	watergainspeed = "水分增加速度: ",
	water_poisoned = "中毒了!",
	--棱镜
	pollinated = "受粉: ",
	sickness = "疾病: ",
	infested = "侵害: ",
}

SHOWME_STRINGS = {
	loyal = "臣服", --for very loyal pigman with loyalty over 9000
	of = " 屬於 ", -- X of Y (reserved)
	units_1 = "1 單位",
	units_many = " 單位",
	uses_1 = "1 次可使用, 總次數 ", --#overide#
	uses_many = " 次可使用, 總次數 ", --#overide# X uses of Y, where X > 1
	days = " 天", --Spoil in N days.
	temperature = "溫度",
	paused = "已暫停",
	stopped = '已停止',
	already_fresh = "最大的新鮮度",
	cheat_fresh = "保鮮返鮮",
	onpickup = " 采摘时", --for flowers
	lack_of = '缺乏 ', -- e.g. Lack of nutrients
	_in = ' 大約 ', -- something in X seconds
	jieduan = "階段", chixu = " 持續", pvp = "對你是: ", norot = "永久保鮮", hot = "變質速度 +", weak = "變質速度 +", cold = "保鮮倍率 +", refresh = "返鮮速度 +", xiaolv = "效率", fangyu = "防禦", gongji = "攻擊", fangshui = "防水", gandian = "感電攻擊", faguang = "發光", huifu = "生命恢復",
}

--Food tags are in genitive case.
--For example: "0.5 units of fruit"
FOOD_TAGS = { --"dried" and "precook" are excluded.
	veggie = "蔬菜", fruit = "水果", monster = "怪物肉", sweetener = "糖類", meat = "肉類", fish = "魚類", magic = "魔法", egg = "蛋類", decoration = "鱗翅", dairy = "乳製品", fat = "油脂", inedible = "枝條", frozen = "冰", ice = "冰", seed = "種子", mogu = "蘑菇", petals_legion = "花瓣", foliage = "蕨葉", rice = "米", insectoid = "昆蟲", gourd = "葫蘆", gel = "黏液", jellyfish = "水母", odoy_salt = "盐", ndnr_soybean = "大豆",
	--Waiter 101
	fungus = "菌類", mushrooms = "蘑菇", poultry = "禽肉", wings = "翅膀", seafood = "海鮮", nut = "堅果", cactus = "仙人掌", starch = "澱粉", grapes = "葡萄", citrus = "柑橘", tuber = "塊莖", shellfish = "貝類",
	--BEEFALO MILK and CHEESE mod
	rawmilk = "鮮奶",
	--Camp Cuisine: Re-Lunched
	bulb = "螢光果", spices = "香料", challa = "哈拉麵包", flour = "麵粉",
	--Chocolate
	cacao_cooked == "可可",
}

INTERNAL_TIMERS = {
	--蚁狮Antlion
	wall_cd = "沙牆冷卻", rage = '距離發怒', nextrepair = '進行治愈', eat_cd = "修復",
	--乌贼squid
	ink_cooldown = "噴墨冷卻", gobble_cooldown = "吞食", --also: for shark
	-- 中庭for atrium_gate
	destabilizing = "生物重生", destabilizedelay = "大門破壞", cooldown = "召喚冷卻",
	-- 蜂后蜂巢beequeenhive
	hivegrowth1 = "第1階段", hivegrowth2 = "第2階段", hivegrowth = "第3階段", shorthivegrowth = "蜂巢恢復", hiveregen = "蜂蜜再生", firsthivegrowth = "首次增長",
	--蜂后beequeen
	spawnguards_cd = "召喚蜜蜂", focustarget_cd = "號令衝撞",
	-- 帝王蟹crabking
	spell_cooldown = "咒語冷卻", claw_regen_delay1 = "爪子 1", claw_regen_delay2 = "爪子 2", claw_regen_delay3 = "爪子 3", claw_regen_delay4 = "爪子 4", claw_regen_delay5 = "爪子 5", claw_regen_delay6 = "爪子 6", claw_regen_delay7 = "爪子 7", claw_regen_delay8 = "爪子 8", claw_regen_delay9 = "爪子 9", claw_regen_delay10 = "爪子 10", claw_regen_delay11 = "爪子 11", claw_regen_delay12 = "爪子 12", claw_regen_delay13 = "爪子 13", claw_regen_delay14 = "爪子 14", regen_crabking = "治愈", casting_timer = "施法預計", gem_shine = "映射寶石", clawsummon_cooldown = "爪召喚冷卻", claw_regen_timer = "喚爪", seastacksummon_cooldown = "沸騰海域", fix_timer = "修復中", heal_cooldown = "修復冷卻",
	--树木, 幽灵ghostly_elixirs.lua
	decay = "消失",
	--草蜥蜴grassgekko
	morphing = "生成",  morphrelay = "傳達", morphdelay = "生成延遲", growTail = "長草",
	--飞荧光果lightflier_flower.lua, flower_cave.lua
	recharge = "蓄能", turnoff = "釋放能量", Pickable_RegenTime = "再生",
	--鱼人王mermking.lua
	hungrytalk_increase_cooldown = "饑餓的對話增加", hungrytalk_cooldown = "饑餓的談話",
	--裸鼹鼠蝙蝠molebat.lua
	resetnap = "睡覺", cleannest_timer = "打掃蝠窩", resetallysummon = "召喚同伴", rememberinitiallocation = "標記位置",
	--海象营地的计时器名称：Timer names for warlus_camp:
    walrus = "海象刷新", little_walrus = "小海象刷新", icehound = "冰狗刷新",
	--寄居蟹hermitcrab.lua:
	speak_time = "發牢騷", complain_time = "抱怨", salad = "花沙拉", bottledelay = "扔瓶子", fishingtime = "釣魚",
	--hermit_grannied plus GUID -- 该词条会动态添加GUID，无法翻译
	--老麦影分身
	obliviate = "契約", --会在该时间后消失，定义为契约会更好
	--旺达, oceanwhirlportal
	closeportal = "傳送關閉", closewhirlportal = "傳送關閉",
	--邪天翁malbatross.lua:
	sleeping_relocate = "遷移", divetask = "潛水", disengage = "脫離", satiated = "抓魚", splashdelay = "撲通",
	--蛤蟆toadstool.lua:
	sporebomb_cd = "孢子雲", mushroombomb_cd = "蘑菇炸彈", mushroomsprout_cd = "蘑菇樹", pound_cd = "蛤蟆蹲", channeltick = "施法等待", channel = "施法",
	--蘑菇toadstool_cap.lua
	darktimer = "中毒", respawndark = "毒菇重生", respawn = "重生",
	--海草waterplant.lua:
	resetcloud = "噴灑花粉", equipweapon = "裝備武器",
	--waveyjones.lua:
	laughter = "笑声", reactiondelay = "反應延遲", respawndelay = "重生等待", trappedtimer = "禁錮",
	--熊灌bearger
	GroundPound = "熊抱", Yawn = "給爺睡",
	--克劳斯klaus
	chomp_cd = "撕咬", command_cd = "號令冰火",
	--大白鲨Shark, Shark Boi
	getdistance = "獲取距離", minleaptime = "飛躍", calmtime = "冷靜", targetboatdelay = "目標", standing_dive_cd = "躍起潛水", torpedo_cd = "旋轉魚蕾",
	--gobble_cooldown --duplicate
	--远古箱子sacred_chest.lua
	localoffering = "合成中", localoffering_pst = "提供（pst）",
	--复活的骷髅stalker.lua
	snare_cd = "畫地為牢", spikes_cd = "萬箭穿心", channelers_cd = "不動如山", minions_cd = "五穀豐登", mindcontrol_cd = "誅邪！",
	--无眼鹿deer.lua
	growantler = "鹿角生長", deercast_cd = "施法冷卻",
	--沙拉蝾螈fruit_dragon.lua
	fire_cd = "冒火冷卻", panicing = "敗走",
	--月台moonbase.lua
	moonchargepre = "感應啟動中", mooncharge = "注入月能", mooncharge2 = "打通通道", mooncharge3 = "吸取月能", fullmoonstartdelay = "啟動等待",
	--龙蝇dragon fly
	regen_dragonfly = "再生", groundpound_cd = "怒火",
	--天体英雄
	hitsound_cd = "翻滾", roll_cooldown = "震地", summon_cooldown = "精神虛影", summon_cd = "精神虛影", spin_cd = "旋轉攻擊", spike_cd = "玻璃尖刺", traps_cd = "啟迪陷阱", finish_pulse = "完成脈衝", trap_lifetime = "陷阱持續", pulse = "脈衝", runaway_blocker = "逃離",
	--远古守护
	forceleapattack = "躍擊", forcebelch = "吐墨", rammed = "撞擊", endstun = "結束眩暈", leapattack_cooldown = "彈跳攻擊",
	--其他Others:
	repair = "修理", --尘蛾巢穴dustmothden
	dontfacetime = "不正視", --人鱼merm.lua
	--childspawner_regentime = "重生",
	growth = "生長", --盐堆saltstack.lua
	lordfruitfly_spawntime = "果蠅", -- farmin_manager.lua
	facetime = "正視", --mermbrain.lua
	regenover = "恢復", --药膏、肥包tillweedsalve.lua, compostwrap.lua, forgetmelots.lua, healthregenbuff.lua
	make_debris = "產生雜物", --杂草抵御weed_defs.lua
	spread = "蔓延", --杂草植物weed_plants.lua
	expire = "持續", --天体探测仪archive_resonator.lua
	drilling = "鬆土", --耕地机farm_plow.lua
	composting = "生成肥料", --堆肥桶compostingbin.lua
	HatchTimer = "孵化", --鹿鸭蛋mooseegg.lua
	lifespan = "剩餘", --海鱼oceanfish.lua
	offeringcooldown = "採摘冷卻", --火鸡perd.lua
	rock_ice_change = "冰變化", --冰山rock_ice.lua
	lifetime = "生存", --schoolherd.lua
	disperse = "退散", --睡眠云、孢子云sleepcloud.lua, sporecloud.lua, waterplant_pollen.lua, chum_aoe.lua
	extinguish = "距離消失", --唤星stafflight.lua
	transform_cd = "變大冷卻", --伯尼bernie_active.lua, bernie_big.lua, bernie_inactive.lua
	taunt_cd = "呵~弱者", --伯尼bernie
	buffover = "Buff", --食物BUFF（例如冬季盛宴）foodbuffs.lua, wintersfeastbuff.lua, halloweenpotion_buffs.lua
	resettoss = "跳躍冷卻", --一角鲸gnarwail.lua
	revive = "再生", --犬堆hound_corpse.lua
	toot = "釋放", --天体裂隙moon_fissure.lua
	training = "訓練", --gym.lua (component)
	salt = "舔鹽", --saltlicker.lua (component)
	foodspoil = "距離死亡", --陷阱trap.lua (component)
	--巨鹿deerclops
	laserbeam_cd = "鐳射", auratime = "絕對零度", uppercuttime = "蓄力爪", Freeze = "千里冰封",
	--鹿鸭moose
	DisarmCooldown = "震吼", SuperHop = "跳躍", WantsToLayEgg = "下蛋", TornadoAttack = "召喚旋風",
	explode = "爆炸", --孢子炸弹sporebomb.lua
	selfdestruct = "自爆", --熔岩虫stalker_minions.lua, lavae.lua
	self_combustion = "持續", --漂浮灯笼miniboatlantern.lua
	despawn_timer = "契約", --召唤猪猪pigelitefighter.lua
	rotting = "枯萎", --农作物plant_normal.lua
	grow = "種苗", --树、石果planted_tree.lua, rock_avocado_fruit.lua
	remove = "消除", --fishschoolspawnblocker.lua
	dominant = "󰀍", --crittertraits.lua (component)
	Spawner_SpawnDelay = "生成", --pighouse
	blink = "閃爍", flamethrower_cd = "極寒冰焰", ash = "燃盡",
	infest_cd = "感染冷卻",
	disappear = "消失",
	--机器人扫描仪
	toplightflash_tick = "正在扫描", onsucceeded_flashtick = "完成捕獲", onsucceeded_timeout = "捕獲冷卻", chargeregenupdate = "電量增加", ANNOUNCE_WX_SCANNER_NEW_FOUND = "宣佈新發現",
	--植物人契约
	finish_transformed_life = "契约",
	--水中木群落
	lookforfish = "出巡", eat_cooldown = "抓魚冷卻", investigating = "巡視中", enriched_cooldown = "養分吸收", shed = "脱落", facetarget = "對視", flotsamgenerator_sink = "沉沒", cocoon_regrow_check = "蟲繭再生", regrow_oceantreenut = "無花果種子再生",
	-- 月亮码头
	startportalevent = "事件啟動", fireportalevent = "事件發生中", spawnportalloot_tick = "生成物品", right_of_passage = "通行證生效", hit = "攻擊",
	--泰拉
	summon_delay = "正在召喚", warning = "預警", spawneyes_cd = "生成小眼", leash_cd = "施展法術", charge_cd = "衝撞",
	--暗影与月亮阵营
	targetswitched = "目标切换", attack_cooldown = "攻击冷却", idletimer = "柱立时间", try_crystals = "下次扩张",trynextstage = "下一阶段", seedmiasma = "溶合暗影", close = "裂隙关闭", jump_cooldown = "跳跃攻击", chase_tick = "分裂", finish_spawn = "完成生成", start_explosion = "爆炸", spawn_delay = "生成延迟", start_ball_growing = "膨胀", stalk_cd = "缓行", roar_cd = "咆哮",
	--神话
	growup = "成長", light = "燈光剩餘", peach = "桃子剩餘", blackbear = "黑風刷新", despawn = "消失", flyaway = "飛走", goaway = "離開", cd = "冷卻", myth_nian_timer = "年獸", nian_leave = "年獸佔據", bomb_cd = "腐敗雲", bombboom = "腐敗雲引爆", nian_noclose = "不打烊", nian_killed = "商品打折", timeover = "契約", yj_spear_elec = "充能",
	TreeDance = "樹舞", --大小生物
	--海难
	startsink = "沉沒", go_home_delay = "回家", SPIKE = "长刺", Run = "撕咬", --run似乎是攻击行为
	--不妥协
	regrow = "再生", passedby = "經過", infest =  "蛀蟲", vomit_time = "嘔吐", unelectrify = "放電", electrify = "充電中", scoutingparty = "偵察隊", stumptime = "距離變異", pounce = "猛撲", mortar = "吐絲", RockThrow = "投擲", glasshards = "碎片攻擊", summoncrystals = "召喚水晶", defusetime = "破碎", natural_death = "距離死亡", remoss = "蚜虫", podreset = "种荚恢复", refill = "重新填充", SpitCooldown = "投擲",--海象,蜘蛛女王
	--棱镜
	axeuppercut_cd = "斧頭上劈", heavyhack_cd = "重劈", callforlightning_cd = "召喚閃電", rangesplash_cd = "飛電/躍擊", flashwhirl_cd = "旋轉打擊", dehydration = "脫水腐爛", birddeath = "玄鳥重生", birth = "破殼", state1 = "孵化 1 阶", state2 = "孵化 2 阶", state3 = "孵化 3 阶", taunt = "魔音繞梁", caw = "花寄語", flap = "羽亂舞", flap_pre = "羽亂舞pre", eye = "同心同目", revolt = "反抗熱湧", moonsurge = "月耀涌动",fallenleaf = "掉落", swallow = "吞食", lure = "誘捕",
	--富贵(定时器名称太长了, 占用太多行, 放弃)
	evergreenpluckabletimer = "采摘冷卻", beehivepluckabletimer = "蜂蜜再生", beequeenhivegrownpluckabletimer = "偷取圖紙冷卻",
}
INTERNAL_STAGES = {
	--all trees:
	short = "小", normal = "中", tall = "大", old = "枯萎",
	--spiderden:
	small = "小", med = "中", large = "滿階", queen = "分離",
	--rock_avocado_bush:
	stage_1 = "沒果子", stage_2 = "再等等", stage_3 = "成熟", stage_4 = "裂開",
	--weed_plants:
	--small --duplicate
	--med --duplicate
	full = "成熟", bolting = "???", empty = "空枝",
	--farm_plants:
	seed = "種子", sprout = "發芽", rotten = "距離反生",
	--smallbird
	--small --duplicate
	--tall  --duplicate
	--baby beefalo:
	baby = "幼牛", toddler = "小牛", teen = "青年", grown = "成年",
	--mod
	blooming = "開花", fruitful = "碩果累累",
}

STRESS_TAGS = { --https://dontstarve.fandom.com/wiki/Farm_Plant
	nutrients = "缺乏肥料", moisture = "缺少水分", killjoys = "附近有影響生長物", family = "缺少家族", season = "不適應這季節", overcrowding = "過於擁擠", happiness = "不開心",
	withered = "已枯萎",
}

OTHER_TAGS = {	--拿不到的数值先写死吧
	onemanband = "照顧農作物\n演奏可使豬人/兔人跟隨",
	amulet = "作祟可復活",
	book_birds = "召喚鳥類",
	book_brimstone = "召喚數道閃電",
	book_gardening = "範圍: 30\n催熟範圍內植物",
	book_silviculture = "範圍: 30\n讓植物生長到最大階段",
	book_sleep = "範圍: 30\n催眠生物",
	wx78_music = "照顧附近農作物",
	wx78_movespeed2 = "之後每個增幅約 60%",
	wx78_heat = "提供增溫及增溫光環",
	wx78_moisture = "乾燥加快: 10%",
	wx78_cold = "提供降溫及降溫光環",
	wx78module_taser = "提供防雷保護\n提供感電攻擊BUFF",
	wx78module_nightvision = "提供夜視能力",
	wx78module_light = "提供發光光環",

	--万圣节
	halloweenpotion_health = "生命恢復 +1/秒, 持續 30 秒",
	halloweenpotion_sanity = "精神恢復 +1/秒, 持續 30 秒",
	--大力士
	wolfgang_whistle = "範圍: 6 地塊\n隨從獲得9.5秒雙倍傷害\n玩家獲得 5 精神增益",
	--弹珠
	slingshotammo_freeze = "凍結目標",
	slingshotammo_poop = "讓目標失去仇恨",
	slingshotammo_thulecite = "暗影觸手召喚概率 50%",
	--棱镜
	lileaves = "-30% 對方攻擊力",
	rosorns = "無視對方護甲",
	--海难
	shark_teethhat = "船上精神 +6.6/分鐘",
	brainjellyhat = "免科技製作",
	gashat = "防氣體毒氣",
	armorseashell = "防物理中毒",
}

OTHER_TITLES = {
	spice_salt = "食物血量 +%s",
	maxhealth = "最大生命值 +%s",
	maxsanity = "最大精神值 +%s",
	maxhunger = "最大饑餓值 +%s",
	wx78_hot_cold = "食物腐爛速度: %s",
	wx78_cold3 = "潮濕高於 %s 產生冰塊",
	ghost_atkf = "護盾傷害: %s",
	hungerslow = "饑餓減緩: %s",
	healthpertick = "生命恢復: +%s",
	ghost_atk = "獲得夜間傷害, 持續 %s 天",
	ghost_shd = "護盾時長增至 1 秒, 持續 %s 天",
	ghost_sd = "移速 +%s, 持續 %s 天",
	batbat = "攻擊吸血 %s, 精神 %s",
	book_hlt = "催熟 %s 株作物",
	ruins_bat = "暗影觸手幾率: %s",
	ruinshat = "保護罩幾率: %s",
	bs_dy = "武器耐久減緩 %s",
	bs_hp = "攻擊生命恢復 +%s/次 (薇格弗德 %s)",
	bs_san = "攻擊精神恢復 +%s/次",
	bs_desan = "負面精神效果 -%s",
	bs_fire = "受火焰傷害減 -%s",
	bs_it = "嘲諷範圍內敵人",
	bs_ip = "範圍內敵人恐慌 %s 秒",
	bs_shadow = "對月亮陣營生物傷害 +%s",
	bs_shadow2 = "受到暗影陣營生物傷害 %s",
	bs_lunar = "對暗影陣營生物傷害 +%s",
	bs_lunar2 = "受到月亮陣營生物傷害 %s",
	hpotion_bravery = "抵抗砍樹和開寶箱產生蝙蝠, 持續 %s 天",
	sammo_slow = "目標移速 %s, 持續 %s 秒",
	resist = "位抗: ",
	dmgresist = "擁有位面抵抗",
	point = " 點",
	grow_in = "距離成長：",
	grow_time = "@成長時間：",
	energytime = "能量剩餘: ",
	seednum = "正在轉化: ",
	fruitnum = "已轉化: ",
	second = " 秒",
	_in = " 大約 ",
	will_other = "剩餘: ",
	fueled = "耐久: ",
	moisture = "剩餘水分: ",
	nutrients = "肥料: ",
	nutrients_1 = "催長劑: ",
	nutrients_2 = "堆肥: ",
	nutrients_3 = "糞肥: ",
	capacity = "容量: ",
	siv_mask = "儲存: ",
	siv_light = "光耀: ",
	siv_health = "生命: ",
	ot_fuel = "燃料: ",
	ot_fuelval = "燃料值: ",
	lg_moon = "鑲嵌: ",
	beerpowerpower = "不靈電力: ",
	waterpowerpower = "不靈水量: ",
	gaspowerpower = "不靈氣體: ",
}

-- MY_DATA.perish.fn = function(arr)
	-- return "將會在 " .. arr.param[1] .. SHOWME_STRINGS.days .. "時" .. arr.data.desc
-- end

MY_DATA.uses_of.fn = function(arr)
	return "耐久度: " .. arr.param[1] .. " / " .. arr.param[2]
end

UpdateNewLanguage()