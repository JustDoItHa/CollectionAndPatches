MY_STRINGS_OVERRIDE =
{
	armor = "傷害吸收: " , --A --Armor of the item.
	aggro = "攻擊力: " , --B --Score of griefing 
	cookpot = "正在烹煮 " , --C (Crock Pot)
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
	remaining_days = "剩餘天數" , --N
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
	is_admin = "這是管理員！\n他不進行遊戲，\n所以不要在意他。" ,
	temperature = "溫度" ,
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
	will_die = "剩餘", -- will die in N days (saying about pet or animal).
	will_dry = "剩餘", --
	dmg_bonus = "傷害乘數: ", -- Damage: +X (means damage modifier, not base damage)
	crop = "", --Not used. It's just a key for info type. Info - "Product: percent"
	grow_in = "成長", -- About grass etc
	perish_product = "", --Just a key for info type. Info - "Product: time in days"
	just_time = "", --Just a key for info type. Info - [time]
	--Thirst mod
	water = "水: ",
	salt = "鹽: ",
	sip = "一口: ",
	watergainspeed = "水分增加速度: ",
	water_poisoned = "中毒了!",

	timer = "預計:",
	trade_gold = '價值金塊: ',
	trade_rock = '價值石頭: ',
	durability = '耐久度: ',
	strength = '攻擊力: ',
	aoe = "群傷: ",

	food_temperature = "食物溫度:",
	precipitationrate = "世界雨:",
	wetness = "世界濕潤:",
	growable = "成長:",

	sanityaura = "理智:",
	fresh = "達到最新鮮",
	frigde = "冰箱",
	food_memory = "效果",
	buff = "增益",
	effectiveness = "實效:",
	force = "動力:",
	repairer = "修理:",
	stress = "養分流失:",
	--2021
	harvest="收穫: ",
	children="生物: ",
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
}

--Food tags are in genitive case.
--For example: "0.5 units of fruit"
FOOD_TAGS = { --"dried" and "precook" are excluded.
	veggie = "蔬菜",
	fruit = "水果",
	monster = "怪物肉",
	sweetener = "糖類",
	meat = "肉類",
	fish = "魚類",
	magic = "魔法",
	egg = "蛋類",
	decoration = "鱗翅",
	dairy = "乳製品",
	fat = "油脂",
	inedible = "枝條",
	frozen = "冰",
	ice = "冰",
	seed = "種子",
	mogu = "蘑菇",
	petals_legion = "花瓣",
	foliage = "蕨葉",
	rice = "米",
	insectoid = "昆蟲",
	gourd = "葫蘆",

	--Waiter 101
	fungus = "菌類", --all mushroom caps + cut lichen
	mushrooms = "蘑菇", --all mushroom caps
	poultry = "禽肉",
	wings = "翅膀", --about bat wing
	seafood = "海鮮",
	nut = "堅果",
	cactus = "仙人掌",
	starch = "澱粉", --about corn, pumpkin, cave_banana
	grapes = "葡萄", --grapricot
	citrus = "柑橘", --grapricot_cooked, limon
	tuber = "塊莖", --yamion
	shellfish = "貝類", --limpets, mussel

	--BEEFALO MILK and CHEESE mod
	rawmilk = "鮮奶",

	--Camp Cuisine: Re-Lunched
	bulb = "螢光果", --lightbulb
	spices = "香料",
	challa = "哈拉麵包", -- Challah bread
	flour = "麵粉", --flour

	--Chocolate
	cacao_cooked == "可可",
}

INTERNAL_TIMERS = {
	--蚁狮Antlion
	wall_cd = "沙牆冷卻",
	rage = '距離發怒',
	nextrepair = '進行治愈',
	eat_cd = "修復",

	--乌贼squid
	ink_cooldown = "噴墨冷卻",
	gobble_cooldown = "吞食", --also: for shark

	-- 中庭for atrium_gate
	destabilizing = "生物重生",
	destabilizedelay = "大門破壞",
	cooldown = "召喚冷卻",

	-- 蜂后蜂巢beequeenhive
	hivegrowth1 = "第1階段",
	hivegrowth2 = "第2階段",
	hivegrowth = "第3階段",
	shorthivegrowth = "蜂巢恢復",
	hiveregen = "蜂蜜再生",
	firsthivegrowth = "首次增長",

	--蜂后beequeen
	spawnguards_cd = "召喚蜜蜂",
	focustarget_cd = "號令衝撞",

	-- 帝王蟹crabking
	spell_cooldown = "咒語冷卻",
	claw_regen_delay1 = "爪子 1", -- base 5, plus 9 gems. So 14 is maximum
	claw_regen_delay2 = "爪子 2",
	claw_regen_delay3 = "爪子 3",
	claw_regen_delay4 = "爪子 4",
	claw_regen_delay5 = "爪子 5",
	claw_regen_delay6 = "爪子 6",
	claw_regen_delay7 = "爪子 7",
	claw_regen_delay8 = "爪子 8",
	claw_regen_delay9 = "爪子 9",
	claw_regen_delay10 = "爪子 10",
	claw_regen_delay11 = "爪子 11",
	claw_regen_delay12 = "爪子 12",
	claw_regen_delay13 = "爪子 13",
	claw_regen_delay14 = "爪子 14",
	regen_crabking = "治愈",
	casting_timer = "施法預計",
	gem_shine = "映射寶石",
	clawsummon_cooldown = "爪召喚冷卻",
	claw_regen_timer = "喚爪",
	seastacksummon_cooldown = "沸騰海域",
	fix_timer = "修復中",
	heal_cooldown = "修復冷卻",--mod

	--树木, 幽灵ghostly_elixirs.lua
	decay = "消失",

	--草蜥蜴grassgekko
	morphing = "生成",
	morphrelay = "傳達",
	morphdelay = "生成延遲",
	growTail = "長草",

	--飞荧光果lightflier_flower.lua, flower_cave.lua
	recharge = "蓄能",
	turnoff = "釋放能量",
	Pickable_RegenTime = "再生",

	--鱼人王mermking.lua
	hungrytalk_increase_cooldown = "饑餓的對話增加",
	hungrytalk_cooldown = "饑餓的談話",

	--裸鼹鼠蝙蝠molebat.lua
	resetnap = "睡覺",
	cleannest_timer = "打掃蝠窩",
	resetallysummon = "召喚同伴",
	rememberinitiallocation = "標記位置",

	--海象营地的计时器名称：Timer names for warlus_camp:
	walrus = "海象刷新",
	little_walrus = "小海象刷新",
	icehound = "冰狗刷新",

	--寄居蟹hermitcrab.lua:
	speak_time = "發牢騷",
	complain_time = "抱怨",
	salad = "花沙拉",
	bottledelay = "扔瓶子",
	fishingtime = "釣魚",
	--hermit_grannied plus GUID -- 该词条会动态添加GUID，无法翻译

	--邪天翁malbatross.lua:
	sleeping_relocate = "遷移",
	divetask = "潛水",
	disengage = "脫離",
	satiated = "抓魚",
	splashdelay = "撲通",

	--蛤蟆toadstool.lua:
	sporebomb_cd = "孢子雲",
	mushroombomb_cd = "蘑菇炸彈",
	mushroomsprout_cd = "蘑菇樹",
	pound_cd = "蛤蟆蹲",
	channeltick = "施法等待",
	channel = "施法",

	--蘑菇toadstool_cap.lua
	darktimer = "中毒",
	respawndark = "毒菇重生",
	respawn = "重生",

	--海草waterplant.lua:
	resetcloud = "噴灑花粉",
	equipweapon = "裝備武器",

	--waveyjones.lua:
	laughter = "笑声",
	reactiondelay = "反應延遲",
	respawndelay = "重生等待",
	trappedtimer = "禁錮",

	--熊灌bearger
	GroundPound = "熊抱",
	Yawn = "給爺睡",

	--克劳斯klaus
	chomp_cd = "撕咬",
	command_cd = "號令冰火",

	--大白鲨Shark
	getdistance = "獲取距離",
	minleaptime = "飛躍",
	calmtime = "冷靜",
	targetboatdelay = "目標",
	--gobble_cooldown --duplicate

	--远古箱子sacred_chest.lua
	localoffering = "合成中",
	localoffering_pst = "提供（pst）",

	--复活的骷髅stalker.lua
	snare_cd = "畫地為牢",
	spikes_cd = "萬箭穿心",
	channelers_cd = "不動如山",
	minions_cd = "五穀豐登",
	mindcontrol_cd = "誅邪！",

	--无眼鹿deer.lua
	growantler = "鹿角生長",
	deercast_cd = "施法冷卻",

	--沙拉蝾螈fruit_dragon.lua
	fire_cd = "冒火冷卻",
	panicing = "敗走",

	--月台moonbase.lua
	moonchargepre = "感應啟動中",
	mooncharge = "注入月能",
	mooncharge2 = "打通通道",
	mooncharge3 = "吸取月能",
	fullmoonstartdelay = "啟動等待",

	--龙蝇dragon fly
	regen_dragonfly = "再生",
	groundpound_cd = "怒火",

	--天体英雄
	hitsound_cd = "翻滾",
	roll_cooldown = "震地",
	summon_cooldown = "精神虛影",
	spin_cd = "旋轉攻擊",
	spike_cd = "玻璃尖刺",
	traps_cd = "啟迪陷阱",
	finish_pulse = "完成脈衝",
	trap_lifetime = "陷阱持續",
	pulse = "脈衝",
	runaway_blocker = "逃離",

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
	refill = "重新填充",	--不妥协酒瓶
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
	laserbeam_cd = "鐳射", --巨鹿deerclops
	auratime = "絕對零度",
	uppercuttime = "蓄力爪",
	Freeze = "千里冰封",
	DisarmCooldown = "震吼", --鹿鸭moose
	SuperHop = "跳躍",
	WantsToLayEgg = "下蛋",
	TornadoAttack = "召喚旋風",
	explode = "爆炸", --孢子炸弹sporebomb.lua
	selfdestruct = "自爆", --熔岩虫stalker_minions.lua, lavae.lua
	self_combustion = "持續", --漂浮灯笼miniboatlantern.lua
	despawn_timer = "契約", --召唤猪猪pigelitefighter.lua
	rotting = "枯萎", --农作物plant_normal.lua
	grow = "種苗", --树、石果planted_tree.lua, rock_avocado_fruit.lua
	remove = "消除", --fishschoolspawnblocker.lua
	dominant = "󰀍", --crittertraits.lua (component)
	Spawner_SpawnDelay = "生成", --pighouse
	toplightflash_tick = "頂燈閃爍", --机器人扫描仪
	onsucceeded_flashtick = "完成捕獲",
	onsucceeded_timeout = "捕獲冷卻",
	lookforfish = "出巡",
	eat_cooldown = "抓魚冷卻",
	investigating = "巡視中",
	enriched_cooldown = "養分吸收",
	shed = "脱落",
	facetarget = "對視",
	flotsamgenerator_sink = "沉沒",
	cocoon_regrow_check = "蟲繭再生",
	regrow_oceantreenut = "無花果種子再生",
	-- 月亮码头
	startportalevent = "事件啟動",
	fireportalevent = "事件發生中",
	spawnportalloot_tick = "生成物品",
	right_of_passage = "通行證生效",
	hit = "攻擊",
	--Mod
	growup = "成長",
	light = "燈光剩餘",
	peach = "桃子剩餘",
	blackbear = "黑風刷新",
	despawn = "消失",
	flyaway = "飛走",
	goaway = "離開",
	blink = "閃爍",
	infest_cd = "感染冷卻",
	cd = "冷卻",
	myth_nian_timer = "年獸",
	nian_leave = "年獸佔據",
	bomb_cd = "腐敗雲",
	bombboom = "腐敗雲引爆",
	nian_noclose = "不打烊",
	nian_killed = "商品打折",
	timeover = "契約",
	TreeDance = "樹舞",
	yj_spear_elec = "充能",
	startsink = "沉沒", --海难
	--泰拉
	summon_delay = "正在召喚",
	warning = "預警",
	spawneyes_cd = "生成小眼",
	leash_cd = "施展法術",
	charge_cd = "衝撞",
	--不妥协
	regrow = "再生",
	passedby = "經過",
	infest =  "蛀蟲",
	vomit_time = "嘔吐",
	unelectrify = "放電",
	electrify = "充電中",
	scoutingparty = "偵察隊",
	stumptime = "距離變異",
	pounce = "猛撲",
	mortar = "吐絲",
	RockThrow = "投擲",
	glasshards = "碎片攻擊",
	summoncrystals = "召喚水晶",
	SpitCooldown = "投擲",--海象,蜘蛛女王
	defusetime = "破碎",
	--棱镜
	axeuppercut_cd = "斧頭上劈",
	heavyhack_cd = "重劈",
	callforlightning_cd = "召喚閃電",
	rangesplash_cd = "範圍跳躍",
	flashwhirl_cd = "旋轉打擊",
}
INTERNAL_STAGES = {
	--all trees:
	short = "小",
	normal = "中",
	tall = "大",
	old = "枯萎",

	--spiderden:
	small = "小",
	med = "中",
	large = "滿階",
	queen = "分離",

	--rock_avocado_bush:
	stage_1 = "沒果子",
	stage_2 = "再等等",
	stage_3 = "成熟",
	stage_4 = "裂開",

	--weed_plants:
	--small --duplicate
	--med --duplicate
	full = "成熟",
	bolting = "???",
	empty = "空枝",

	--farm_plants:
	seed = "種子",
	sprout = "發芽",
	rotten = "距離反生",

	--smallbird
	--small --duplicate
	--tall  --duplicate

	--baby beefalo:
	baby = "幼牛",
	toddler = "小牛",
	teen = "青年",
	grown = "成年",

	--mod
	blooming = "開花",
	fruitful = "碩果累累",
}

STRESS_TAGS = { --https://dontstarve.fandom.com/wiki/Farm_Plant
	nutrients = "缺乏肥料",
	moisture = "缺少水分",
	killjoys = "附近有影響生長物",
	family = "缺少家族",
	season = "不適應這季節",
	overcrowding = "過於擁擠",
	happiness = "不開心",
}

-- local doc_data={
-- ["stresspoints"] = "養分流失",
-- ["nutrients"]    = "缺乏營養",
-- ["moisture"]     = "缺少水分",
-- ["family"]       = "缺少家族",
-- ["overcrowding"] = "過於擁擠",
-- ["killjoys"]     = "附近有影響生長物",
-- ["happiness"]    = "不開心",
-- ["season"]       = "不適應這季節",
-- }

-- MY_DATA.perish.fn = function(arr)
-- return "將會在 " .. arr.param[1] .. SHOWME_STRINGS.days .. "時" .. arr.data.desc
-- end

MY_DATA.uses_of.fn = function(arr)
	return "耐久度: " .. arr.param[1] .. " / " .. arr.param[2]
end

UpdateNewLanguage()