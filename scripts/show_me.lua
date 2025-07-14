--源码来自Star版本，本人只略懂代码，边学边更新，如果你有对此模组兴趣欢迎继承更新。--在此非常感谢对此模组提供协助的所有人

--[[
--致模组开发者: 你的模组容器可使用以下代码，实现与ShowMe联动容器高亮。	--源开发者 Star 留
	TUNING.MONITOR_CHESTS = TUNING.MONITOR_CHESTS or {}
	TUNING.MONITOR_CHESTS.chestprefab = true	-- chestprefab 即你的容器代码名称

--多容器模式, 优先级高低判断可同时加上
--优先级高于 ShowMe
	TUNING.MONITOR_CHESTS = TUNING.MONITOR_CHESTS or {}
	for _, v in ipairs(容器列表) do
		TUNING.MONITOR_CHESTS[v] = true
	end

--优先级低于 ShowMe		--来自 风铃草 —— 穹妹
	for k, m in pairs(ModManager.mods) do
		if m and _G.rawget(m, "SHOWME_STRINGS") then
			if m.postinitfns and m.postinitfns.PrefabPostInit and m.postinitfns.PrefabPostInit.treasurechest then
				for _,v in ipairs(容器列表) do
					m.postinitfns.PrefabPostInit[v] = m.postinitfns.PrefabPostInit.treasurechest
				end
			end
			break
		end
	end
--]]

local _G = GLOBAL

-- if modinfo then
-- 	print("ShowMe version:",modinfo.version)
-- end

local GetGlobal=function(gname,default)
	local res=_G.rawget(_G,gname)
	if res == nil and default ~= nil then
		_G.rawset(_G,gname,default)
		return default
	end
	return res
end

--nice round function
local round2=function(num, idp)
	return _G.tonumber(string.format("%." .. (idp or 0) .. "f", num))
end

--本地（增加其他模组的兼容性）
local mods = GetGlobal("mods",{})

local GetTime = _G.GetTime	--计时器
local TheNet = _G.TheNet
local is_PvP = TheNet:GetDefaultPvpSetting()	--PVP
local SERVER_SIDE = TheNet:GetIsServer()	--服务器
local CLIENT_SIDE =	 TheNet:GetIsClient() or (SERVER_SIDE and not TheNet:IsDedicated())	--本地

local tonumber = _G.tonumber
local food_order = tonumber(GetModConfigData("food_order",true)) or 0
if food_order == 0 then
	food_order = tonumber(GetModConfigData("food_order")) or 0
end
--TUNING.SHOWME_FOOD_ORDER = food_order --兼容 Tell Me
local food_style = tonumber(GetModConfigData("food_style",true)) or 0
if food_style == 0 then
	food_style = tonumber(GetModConfigData("food_style")) or 0
end
--TUNING.SHOWME_FOOD_STYLE = food_style

local display_hp = tonumber(GetModConfigData("display_hp",true)) or -1
if display_hp == -1 then
	display_hp = tonumber(GetModConfigData("display_hp")) or -1
end


local food_estimation = tonumber(GetModConfigData("food_estimation",true)) or -1
if food_estimation == -1 then
	food_estimation = tonumber(GetModConfigData("food_estimation")) or 0
end

local show_food_units = tonumber(GetModConfigData("show_food_units",true)) or -1
if show_food_units == -1 then
	show_food_units = tonumber(GetModConfigData("show_food_units")) or 0
end
print('show_food_units',show_food_units,GetModConfigData("show_food_units",true),GetModConfigData("show_food_units"))

local show_uses = tonumber(GetModConfigData("show_uses",true)) or -1
if show_uses == -1 then
	show_uses = tonumber(GetModConfigData("show_uses")) or 0
end
print('show_uses',show_uses,GetModConfigData("show_uses",true),GetModConfigData("show_uses"))

-- local chestR = tonumber(GetModConfigData('chestR',true)) or -1
-- if chestR == -1 then
-- 	chestR = tonumber(GetModConfigData('chestR')) or 0.3
-- 	if (chestR == -1) then chestR = 0.3 end
-- end
-- local chestG = tonumber(GetModConfigData('chestG',true)) or -1
-- if chestG == -1 then
-- 	chestG = tonumber(GetModConfigData('chestG')) or 1
-- 	if (chestG == -1) then chestG = 1 end
-- end
-- local chestB = tonumber(GetModConfigData('chestB',true)) or -1
-- if chestB == -1 then
-- 	chestB = tonumber(GetModConfigData('chestB')) or 1
-- 	if (chestB == -1) then chestB = 1 end
-- end
--print('RGB CHEST',chestR,chestG,chestB)
--new derived from id=2188103687
local show_buddle_item = tonumber(GetModConfigData("show_buddle_item",true)) or 1
if show_buddle_item == 1 then
	show_buddle_item = tonumber(GetModConfigData("show_buddle_item")) or 1
end
local item_info_mod = tonumber(GetModConfigData("item_info_mod",true)) or 0
if item_info_mod == 0 then
	item_info_mod = tonumber(GetModConfigData("item_info_mod")) or 0
end
local show_nutrients = GetModConfigData("show_nutrients")
local show_fuel = GetModConfigData("show_fuel")
local show_fueled = GetModConfigData("show_fueled")
local show_planar_resist = GetModConfigData("show_planar_resist")

local MY_STRINGS =
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

--从 char 解码到 MY_STRINGS 中的索引
local function decodeFirstSymbol(sym)
	--local my_s = MY_STRINGS[string.byte(v:sub(1,1))-64]
	local c = string.byte(sym);
	local idx;
	if c>=64 and c<=126 then idx=c-64 -- '@' is en "error" symbol or use "as is" (a param string). It must be converted to 0.
	elseif c>=32 and c<=62 then idx=c+31
	elseif c>=17 and c<=31 then idx=c+77
	else idx=0 end
	--print('dec_idx',idx,tostring(MY_STRINGS[idx] and MY_STRINGS[idx].key))
	return idx
end

local function encodeFirstSymbol(idx) --print('idx',idx)
	if (idx <= 62) then return string.char(idx+64) -- 1-62: chars 65-126
	elseif (idx <= 93) then return string.char(idx-31) -- 63-93: chars 32-62
	elseif (idx <= 108) then return string.char(idx-77) -- 94-108: chars = error (17-31)
	else return string.char(63) end -- error
	--not 63 and 64
	--sym = i < 63 and string.char(i+64) or string.char(i-32), -- A+
end

MY_DATA = {}
for i,v in ipairs(MY_STRINGS) do
	for k,str in pairs(v) do --одна пара
		MY_DATA[k] = {
			desc = str,
			id = i,
			sym = encodeFirstSymbol(i), -- A+
			fn = nil, --Function to return the proper string. By default: desc + " " + param1
			percent = nil, --To add "%" at the end of the number
		}
		v.key = k --将密钥写入单独的变量。
		break
	end
end


local function DefaultDisplayFn(arr) --输入有一个特殊的结构：{ data, param }。 data 是对 MY_DATA 元素的引用，param 是对数组 p 的引用。
	if arr.data == nil then
		return arr.param_str --以来自服务器的形式显示字符串（没有第一个字符）。 对“@”符号的适配
	end
	if arr.data.sign ~= nil and (tonumber(arr.param[1]) or -1) >= 0 then
		arr.param[1] = "+" .. tostring(arr.param[1])
	end
	local s = arr.data.desc .. " " .. tostring(arr.param[1])
	if arr.data.percent ~= nil then
		s = s .. "%"
	end
	return s
end
CallDefaultDisplayFn = DefaultDisplayFn --用于语言模块。

local function DefaultFraction(arr) --典型输出：“名称：cur / max”
	local cur,mx = arr.param[1], arr.param[2]
	return arr.data.desc .. " " .. cur .. " / " .. mx
end

--农作物tag
MY_DATA.stress_tag.fn = function(arr)
	local key = arr.param[1]
	if STRESS_TAGS[key] then
		return STRESS_TAGS[key]
	end
	return SHOWME_STRINGS.lack_of .. tostring(key)
end
--创建其他tag
MY_DATA.other_tag.fn = function(arr)
	local key = arr.param[1]
	if OTHER_TAGS[key] then
		return OTHER_TAGS[key]
	end
end

MY_DATA.sanity.fn = function(arr)
	local str = DefaultDisplayFn(arr)
	if arr.param[2] == '1' then -- on pick up
		return str .. SHOWME_STRINGS.onpickup --花朵采摘
	end
	return str
end
--BUFF
MY_DATA.buff.fn = function(arr)
	local name = SHOWME_STRINGS[arr.param[1]] or arr.param[1]
	local bonus = tonumber(arr.param[3])
	local days = arr.param[2]
	if bonus then
		bonus = round2((bonus - 1) * 100)
		if bonus >= 0 then
			bonus = "+" .. tostring(bonus)
		end
	end
	arr.param[1] = name
	arr.param[3] = bonus
	if bonus then
		return name .. ' ' .. tostring(bonus) .. '%'
				.. (days ~= '0' and SHOWME_STRINGS.chixu .. tostring(days) .. ' ' .. SHOWME_STRINGS.days or '')
	end
	return name .. SHOWME_STRINGS.chixu .. tostring(days) .. ' ' .. SHOWME_STRINGS.days
end
--生物巢
MY_DATA.children.fn = function(arr)
	local inside = arr.param[1]
	local maximum = arr.param[2]
	local outside = arr.param[3]
	if outside then
		return arr.data.desc .. "(" .. inside .. "+" .. outside .. ") / " .. maximum
	else
		return arr.data.desc .. inside .. " / " .. maximum
	end
end
--BOSS对玩家的伤害信息
MY_DATA.strength.fn = function(arr)
	if not arr.param[2] then
		return DefaultDisplayFn(arr)
	end
	return arr.data.desc .. " " .. tostring(arr.param[1]) .. " ( " .. SHOWME_STRINGS.pvp .. round2(tostring(arr.param[2]) * tostring(arr.param[1]) * 0.01 + tostring(arr.param[1]),1).." )" --BOSS对玩家的伤害值，直接显示常值好了
end

MY_DATA.hp.fn = function(arr)
	local cur,mx = arr.param[1], arr.param[2]
	return cur .. " / " .. mx
end
MY_DATA.owner.fn = function(arr)
	return arr.data.desc .. " " .. arr.param_str  --如果名称中有逗号，将忽略逗号。
end
MY_DATA.loyal.fn = function(arr)
	if (tonumber(arr.param[1]) or 0) > 9000 then --忠诚大于9000
		return arr.data.desc .. " " .. SHOWME_STRINGS.loyal
	end
	return DefaultDisplayFn(arr)
end

MY_DATA.water.fn = DefaultFraction
MY_DATA.water_poisoned.fn = function(arr)
	return arr.data.desc
end

local function DataTimerFn(seconds)
	if (not seconds) then
		return 'error'
	end
	local total = tonumber(seconds)
	if not total then
		return "???"
	end
	total = math.abs(total)
	local hours = math.floor(total * 0.0002777777777777) --整小时数。 1/3600
	local mins = math.floor((total - (hours * 3600)) * 0.01666666666666) --分钟。 1/60
	local secs = math.floor(total - (hours * 3600) - (mins * 60)) --秒整数
	return
	(hours > 0 and (hours .. ':'
			.. (mins > 9 and mins or ('0' .. mins)) .. ':'
			.. (secs > 9 and secs or ('0' .. secs))
	) or ( mins .. ':'
			.. (secs > 9 and secs or ('0' .. secs))
	))
end
--植物生长时间
MY_DATA.timer.fn = function(arr)
	local name = arr.param[2]
	local s;
	if INTERNAL_TIMERS[name] and INTERNAL_TIMERS[name] ~= "" then
		s = INTERNAL_TIMERS[name] .. ': '
	else
		s = arr.data.desc .. (name and (' "'..name..'": ') or ': ')
	end
	return s .. DataTimerFn(arr.param[1])
			.. (arr.param[3] == '1' and ' ('..SHOWME_STRINGS.paused..')' --作物生长状态
			or (arr.param[3] == '2' and ' ('..SHOWME_STRINGS.stopped..')' or ''))
end
--例如：蜂箱，蘑菇农场
MY_DATA.harvest.fn = function(arr)
	local maxproduce = arr.param[3]
	if not maxproduce then
		return DefaultDisplayFn(arr)
	end
	local name = arr.param[1]
	local produce = arr.param[2]
	local count_str = produce .. '/' .. maxproduce
	local tm = arr.param[4]
	local paused = (arr.param[5] == '0')
	if (tm) then
		return count_str .. ', +1 ' .. (_G.STRINGS.NAMES[name:upper()] or name) .. SHOWME_STRINGS._in .. DataTimerFn(tm)
				.. (paused and '('..SHOWME_STRINGS.paused..')' or '')
	else
		return count_str .. ' ' .. (_G.STRINGS.NAMES[name:upper()] or name)
	end
end


MY_DATA.durability.fn = DefaultFraction
--武器上显示的攻击BUFF
MY_DATA.dmg.fn = function(arr)
	local str = DefaultDisplayFn(arr)
	if arr.param[2] then --buff 时间
		str = str .. ' ↑ ' .. DataTimerFn(arr.param[2])
	end
	return str
end
MY_DATA.armor.fn = MY_DATA.dmg.fn
MY_DATA.effectiveness.fn = MY_DATA.dmg.fn

-- Temperature: +10, 0:05
MY_DATA.food_temperature.fn = function(arr) -- { temperature, time }
	local temperature_str = arr.param[1]
	if tonumber(temperature_str) > 0 then
		temperature_str = '+' .. temperature_str
	end
	local time_str = DataTimerFn(arr.param[2])
	return SHOWME_STRINGS.temperature .. ': ' .. temperature_str .. ', ' .. time_str
end


MY_DATA.sanity_character.percent = true
MY_DATA.sanity.sign = true
MY_DATA.sanityaura.sign = true
MY_DATA.dmg_character.percent = true
MY_DATA.dmg_character.sign = true
MY_DATA.speed.percent = true
MY_DATA.speed.sign = true
MY_DATA.temperature.sign = true
MY_DATA.armor.percent = true
MY_DATA.armor_character.percent = true
MY_DATA.armor_character.sign = true
MY_DATA.waterproof.percent = true
MY_DATA.dmg_bonus.sign = true

MY_DATA.watergainspeed.sign = true
MY_DATA.sip.sign = true

MY_DATA.trade_gold.sign = true
MY_DATA.trade_rock.sign = true

MY_DATA.effectiveness.percent = true
MY_DATA.force.percent = true
MY_DATA.repairer.sign = true

local AOS_Temperature_fn --将游戏中的温度单位转换为摄氏度、华氏度。
local is_Fahrenheit = false
local function ConvertTemperature(val)
	if not val then
		return "???"
	end
	if is_Fahrenheit then
		return math.floor(1.8*(val) + 32.5).."\176F"
	else
		return math.floor(val*0.5 + 0.5) .. "\176C"
	end
end

local function MainConvertTemperature(val)
	return AOS_Temperature_fn and AOS_Temperature_fn(tonumber(val)) or ConvertTemperature(tonumber(val))
end

MY_DATA.temperature.sign = true
MY_DATA.temperature.fn = function(arr)
	arr.param[1] = MainConvertTemperature(arr.param[1])
	return DefaultDisplayFn(arr)
end

--从STRINGS.NAMES获取物品名称
local function GetPrefabFancyName(prefab)
	local product = tostring(prefab or "nil")
	local name = _G.STRINGS.NAMES[string.upper(product)]
	if name == nil then	--如果NAMES获取不到就获取一个prefab的对象, 为解决部分在容器里不显示中文的问题
		local item = _G.SpawnPrefab(prefab)
		if item and item.GetDisplayName then
			name = string.gsub(item:GetDisplayName(), "\n", "")	--通过对象获取 GetDisplayName
			if name then
				_G.STRINGS.NAMES[string.upper(product)] = name	--保存到 NAMES 里
			end
		end
	end
	return name or product
	--return _G.STRINGS.NAMES[string.upper(product)] or product
end
--烹饪锅
MY_DATA.cookpot.fn = function(arr)
	return arr.data.desc .. " " .. GetPrefabFancyName(arr.param[1])
end
--食物信息
MY_DATA.food.fn = function(arr)
	local hg,sn,hp = arr.param[1],arr.param[2],arr.param[3]
	if food_order <= 1 then
		if food_style <= 1 then
			return MY_DATA.hunger.desc .. " "..hg.." / "..MY_DATA.sanity.desc.." "..sn.." / "..MY_DATA.health.desc.." "..hp
		else
			return hg.." / "..sn.." / "..hp
		end
	else
		if food_style <= 1 then
			return MY_DATA.health.desc.." "..hp.." / "..MY_DATA.hunger.desc.." "..hg.." / "..MY_DATA.sanity.desc.." "..sn
		else
			return hp.." / "..hg.." / "..sn
		end
	end
end
--食物填充单位
MY_DATA.units_of.fn = function(arr)
	local s = FOOD_TAGS[arr.param[2]]
	s = s ~= "" and s or arr.param[2] --If translation exists.
	if arr.param[1] == "1" then
		return SHOWME_STRINGS.units_1 .. s
	else
		return arr.param[1] .. SHOWME_STRINGS.units_many .. s
	end
end
--工具可用度
MY_DATA.uses_of.fn = function(arr)
	if arr.param[1] == "1" then
		return SHOWME_STRINGS.uses_1 .. arr.param[2]
	else
		return arr.param[1] .. SHOWME_STRINGS.uses_many .. arr.param[2]
	end
end
--距离腐烂
MY_DATA.perish.fn = function(arr)
	return arr.data.desc .. " " .. arr.param[1] .. SHOWME_STRINGS.days
end
--将生物的距离腐烂定义为距离死亡
local PerishFunction = function(arr)
	return MY_DATA.perish.fn(arr) --Redirect to perish function with another description - "Will die in..."
end

MY_DATA.will_die.fn = PerishFunction
MY_DATA.will_dry.fn = PerishFunction --Здесь тоже просто делаем ссылку.
MY_DATA.grow_in.fn = PerishFunction
MY_DATA.just_time.fn = PerishFunction
--鱼桶返鲜
MY_DATA.fresh.fn = function(arr)
	if (arr.param[1] == "0" or arr.param[1] == "-0") then
		return SHOWME_STRINGS.already_fresh;
	elseif (arr.param[1] and arr.param[1]:sub(1,1) == '-') then
		return SHOWME_STRINGS.cheat_fresh;
	end
	return PerishFunction(arr);
end
--冰箱保鲜程度
MY_DATA.frigde.fn = function(arr)
	local v = tonumber(arr.param[1]);
	if v == 0 then
		return SHOWME_STRINGS.norot; --hard coded
	elseif v == 1 then
		return 'Broken';
	elseif v > 1 then
		return SHOWME_STRINGS.hot ..round2((v-1)*100)..'%';
	elseif v > 0.5 then
		return SHOWME_STRINGS.weak ..round2((v-0.5)*200)..'%';
	elseif v > 0 then
		return SHOWME_STRINGS.cold ..round2(1/(v)+1)..'x'; --少了数，应该再+1
	elseif v < 0 then
		return SHOWME_STRINGS.refresh ..round2((-v)*1)..'%';
	end
	return 'Paradox '..tostring(v); --error
end

local CONST_COUNT = { ['1'] = '(1)', ['2'] = '(2)', ['3'] = '(3)', ['4'] = '(4)', ['5'] = '(5)', ['6'] = '(6)', ['7'] = '(7)',
					  ['8'] = '(8)', ['9'] = '(9)', ['10'] = '(10)', ['11'] = '(11)', ['12'] = '(12)', ['13'] = '(13)', ['14'] = '(14)',
					  ['15'] = '(15)', ['16'] = '(16)', ['17'] = '(17)', ['18'] = '(18)', ['19'] = '(19)', ['20'] = '(20)',
					  ['21'] = '(21)', ['22'] = '(22)', ['23'] = '(23)', ['24'] = '(24)', ['25'] = '(25)',
					  ['26'] = '(26)', ['27'] = '(27)', ['28'] = '(28)', ['29'] = '(29)', ['30'] = '(30)',
					  ['31'] = '(31)', ['32'] = '(32)', ['33'] = '(33)', ['34'] = '(34)', ['35'] = '(35)',
					  ['36'] = '(36)', ['37'] = '(37)', ['38'] = '(38)', ['39'] = '(39)', ['40'] = '(40)',
					  ['0'] = '', --如果没有可堆叠的组件，那么根本不会显示数量。
}

--包裹生物食物信息
--param[1] - продукт
--param[2] - 剩余天数或为零
MY_DATA.perish_product.fn = function(arr)
	local name = GetPrefabFancyName(arr.param[1]) .. (
			CONST_COUNT[arr.param[2]] or ('(' .. tostring(arr.param[2]) .. ')')
	)
	if not arr.param[3] then --未指定时间
		return name
	end
	arr.param[1] = arr.param[3] --dirty hack!!! Preparing for using in PerishFunction
	--arr.param[2] = nil --need not
	return name.. ":" .. PerishFunction(arr) -- desc == ""
end

MY_DATA.heal.sign = true
MY_DATA.fuel.percent = true
MY_DATA.obedience.percent = true
MY_DATA.domest.percent = true
--MY_DATA.fuel.percent = true
--MY_DATA.fuel.percent = true
--MY_DATA.fuel.percent = true
--物品：百分比
MY_DATA.crop.fn = function(arr) -- Product: percent
	return GetPrefabFancyName(arr.param[1]) .. ": " .. tostring(arr.param[2]) .. "%"
end
--用于石果、大理石
MY_DATA.growable.fn = function(arr) -- stage num or name, time, paused (1/0)
	arr=arr.param;
	local stagename = tonumber(arr[1]) and (SHOWME_STRINGS.jieduan .. arr[1]) or arr[1];  --大理石生长
	if INTERNAL_STAGES[stagename] and INTERNAL_STAGES[stagename] ~= "" then
		stagename = INTERNAL_STAGES[stagename]
	end
	local time_str = DataTimerFn(arr[2]);
	return stagename .. (arr[3] == '1' and ' ('..SHOWME_STRINGS.paused..') : ' or ' : ') .. time_str;
end
--厨师食物记忆
MY_DATA.food_memory.fn = function(arr)
	local perc = tonumber(arr.param[1])
	perc = perc and (round2(perc * 100) .. '%') or tostring(arr.param[1])
	return arr.data.desc .. '(' .. perc .. '): ' .. DataTimerFn(arr.param[2])
end

--MY_STRINGS_OVERRIDE = nil

if show_food_units == 0 or show_food_units == 2 then
	MY_DATA.units_of.hidden = true
end

if show_uses == 0 or show_uses == 2 then
	MY_DATA.uses_of.hidden = true
end

local need_show_hp = display_hp == -1 or display_hp == 1
if not need_show_hp then
	MY_DATA.hp.hidden = true
end

local SHOWME_STRINGS_EN_OLD;
function UpdateNewLanguage()
	--print(MY_STRINGS_OVERRIDE)
	if MY_STRINGS_OVERRIDE ~= nil then --Меняем локальный перевод (в т.ч. для хоста).
		for k,tr in pairs(MY_STRINGS_OVERRIDE) do
			local data = MY_DATA[k]
			if data ~= nil then
				data.desc = tr
				--else MY_STRINGS[k] = {tr}
			end
		end
	end
	--print(MY_STRINGS.aggro[1])
	for k,v in pairs(SHOWME_STRINGS_EN_OLD) do
		if not SHOWME_STRINGS[k] then
			SHOWME_STRINGS[k] = v
		end
	end
end


do --适配语言
	local support_languages = { ru = true, chs = true, cht = true, br = true, pl = true,
								tw="cht", zh_cn="chs", ch="chs", kr=true, ko="kr", es = true,}
	--For override: name=file. Example: ,cht="chs",
	local lang = GetModConfigData("show_me_lang", true) or "auto"
	if lang == "auto" then
		lang = GetModConfigData("show_me_lang") or "auto"
	end
	print("Detected language for ShowMe: ", lang, lang == "auto" and _G.LanguageTranslator.defaultlang or "")

	AddPrefabPostInit("world",function(inst)
		if lang == "auto" then
			lang = _G.LanguageTranslator.defaultlang --print("LANG=",lang)
			if _G.STRINGS.ACTIONS.PLAY == "\253\253\253\253\253\253\253\253\253\253\6\196\232\253\253\253\253\253\253\253\253\1\205" then
				lang = "kr" --Korean
			end
		end
		if type(lang) ~= "string" or lang == "chs" then
			return
		end
		lang = lang:lower()
		SHOWME_STRINGS_EN_OLD = SHOWME_STRINGS;
		if support_languages[lang] ~= nil then
			if support_languages[lang] ~= true then --алиас
				lang = support_languages[lang]
			end
			modimport("modules/show_me/showme_"..lang..".lua")
		end
		UpdateNewLanguage()
	end)
end



--尝试检测客户端模组并通过 RPC 发送它们
AddModRPCHandler("ShowMe","AOS",function(inst)
	--调用此函数将禁用此玩家的提示。
	inst.has_AlwaysOnStatus = true
end)

--是否考虑特定用户的伤害状态。
AddModRPCHandler("ShowMe","Estimate",function(inst)
	--调用此函数将禁用此玩家的提示。
	inst.should_Estimate_Stale = true
end)

--local AOS_Temperature_fn --客户端转换游戏温度的功能。

--We climb into the client interface in order to reduce the displayed temperature
if CLIENT_SIDE then
	--We make the most correct function in the world "AddPlayersPostInit"
	--GetGlobal("mods",{})
	--if not _G.rawget(_G,"mods") then _G.rawset(_G,"mods",{}) end
	if not mods.player_preinit_fns then
		mods.player_preinit_fns={}
		--Dirty hack
		local old_MakePlayerCharacter = _G.require("prefabs/player_common")
		local function new_MakePlayerCharacter(...)
			local inst=old_MakePlayerCharacter(...)
			for _,v in ipairs(mods.player_preinit_fns) do
				v(inst)
			end
			return inst
		end
		_G.package.loaded["prefabs/player_common"] = new_MakePlayerCharacter
	end

	local function AddPlayersPreInit(fn)
		table.insert(mods.player_preinit_fns,fn)
	end

	local player_postinit_fns = {}
	local function AddPlayersPostInit(fn) -- <<<--------- Вот она!
		table.insert(player_postinit_fns,fn)
	end

	local done_players = {}
	AddPlayersPreInit(function(inst)
		local s = inst.prefab or inst.name
		if not done_players[s] then
			done_players[s] = true
			AddPrefabPostInit(s,function(inst)
				for _,v in ipairs(player_postinit_fns) do
					v(inst)
				end
			end)
		end
	end)

	local player_afterinit_fns = {}
	function AddPlayersAfterInit(fn)
		table.insert(player_afterinit_fns,fn)
	end
	AddPlayersPostInit(function(inst)
		if #player_afterinit_fns > 0 then
			inst:DoTaskInTime(0,function(inst)
				for i=1,#player_afterinit_fns do
					player_afterinit_fns[i](inst)
				end
			end)
		end
	end)

	--А вот и не угадали. Не трогаем интерфейс. Вместо этого определяем настройки и лишь в случае их отсутствия трогаем интерфейс.

	--温度检查。 反向格式和转换为通用摄氏度。
	local tonumber = _G.tonumber
	local function FixTemperature(s)
		if type(s) ~= "string" then
			return s --Вообще не строка. Что за?
		end
		--На конце может быть один из конкретных вариантов строки.
		local sep = s:find("\176",1,true)
		if not sep then
			return s
		end
		local pre, pst = tonumber(s:sub(1,sep-1)), s:sub(sep+1)
		if not pre then
			return s --字符串的第一部分不是数字。
		end
		if pst == "C" then
			return s --这是摄氏温度，无需转换。
		elseif pst == "F" then
			--华氏温度
			is_Fahrenheit = true
			return s
		else
			--我们假设温度以游戏单位为单位，我们用摄氏度来解决这个问题。
			return ConvertTemperature(pre) --TODO：减少中有一个小错误。 在 5.1 的温度下，数字 2 将出现，尽管它应该是 3。
		end
	end

	local AOS_UNITS, AOS_UNIT

	--Interface patching feature on the client. Triggered for all players upon spawn.
	local function FixClient(inst)
		if inst ~= _G.ThePlayer then
			return
		end

		--以一种 hacky 的方式添加发送食物显示偏好设置
		if food_estimation == 1 then
			--print("SendRPC")
			SendModRPCToServer(MOD_RPC.ShowMe.Estimate)
		end

		local status = inst.HUD and inst.HUD.controls and inst.HUD.controls.status
		if not status then
			print("ERROR SHOW_ME: Can't fix client side status!")
			return
		end
		local AOS
		AOS_UNITS = TUNING.COMBINED_STATUS_UNITS
		AOS_UNIT = TUNING.COMBINED_STATUS_UNIT
		if (AOS_UNITS and AOS_UNIT and AOS_UNITS[AOS_UNIT]) then
			AOS = true
			AOS_Temperature_fn = AOS_UNITS[AOS_UNIT]
		else --旧版本的 AOS
			if status.temperature then
				AOS = true
				local old_SetString = status.temperature.num.SetString
				status.temperature.num.SetString = function(self,s,...)
					return old_SetString(self,FixTemperature(s),...)
				end
			end
			if status.worldtemp then
				AOS = true
				local old_SetString = status.worldtemp.num.SetString
				status.worldtemp.num.SetString = function(self,s,...)
					return old_SetString(self,FixTemperature(s),...)
				end
			end
		end
		if AOS then
			SendModRPCToServer(MOD_RPC.ShowMe.AOS)
		end
	end
	AddPlayersAfterInit(FixClient)
end

-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------- HOST -----------------------------------------------------------------
--只在主机上工作。
if TheNet and TheNet:GetIsServer() then
	require = _G.require

	--检测启用的模组
	local mod_names	 --названия всех модов (чтобы не дергать джвижок)
	local mod_names_nover --названия модов с обрезанной версией (если смысловая часть достаточно длинная)
	mod_names = {}
	mod_names_nover = {}
	local function GetAllModNames()
		if not (_G.KnownModIndex and _G.KnownModIndex.savedata and _G.KnownModIndex.savedata.known_mods
				and _G.ModManager and _G.ModManager.enabledmods)
		then
			return
		end
		local folders = {} --ассоциативный массив включенных модов (по папкам)
		for _,v in ipairs(_G.ModManager.enabledmods) do
			folders[v]=true
		end
		for folder, mod in pairs(_G.KnownModIndex.savedata.known_mods) do
			local name = mod.modinfo.name
			if name then
				mod_names[name]=folders[folder] and true or false
				--print("NEW_MOD: "..name.." "..tostring(mod_names[name]))
				local s=string.match(name,"^(.-)([0-9%._ ]+)$")
				if s then
					mod_names_nover[s]=name --обрезаем номер версии с конца
					--вместо true сохраняем полное имя мода (чтобы идентифицировать его в системе)
				else
					mod_names_nover[name]=name
				end
			end
		end
	end
	GetAllModNames()
	mods.mod_names = mod_names
	mods.mod_names_nover = mod_names_nover

	local function SearchForModsByName()
		if mods.active_mods_by_name then
			return --Уже проинициализировано. Либо полная несовместимость.
		end
		mods.active_mods_by_name = {}
		if not (_G.KnownModIndex and _G.KnownModIndex.savedata and _G.KnownModIndex.savedata.known_mods) then
			print("ERROR COMMON LIB: Can't find KnownModIndex!")
			return
		end
		for name,mod in pairs(_G.KnownModIndex.savedata.known_mods) do
			if (mod.enabled or mod.temp_enabled or _G.KnownModIndex:IsModForceEnabled(name)) --Мод активен
					and not mod.temp_disabled --И не отключен
			then
				local real_name = mod.modinfo.name
				if real_name == nil then
					print("SHOW_ME ERROR: real_name of a mod is nil,",tostring(name))
					--TODO: error if TUNING.STAR_DEBUG
				else
					mods.active_mods_by_name[real_name] = true
				end
			end
		end
	end
	SearchForModsByName()

	local is_HealthInfo = nil --Check it to decide, is there a reason to show hp in description.检查客机血量显示模组
	for name in pairs(mods.active_mods_by_name) do
		if name:find("Health Info",1,true) or name:find("Health Bar",1,true) then
			is_HealthInfo = true
			break
		end
	end
	--print('is_HealthInfo',is_HealthInfo)

	local need_send_hp = display_hp == -1 and not is_HealthInfo or display_hp == 0 or display_hp == 1
	--print('need_send_hp',need_send_hp)
	--print('display_hp',display_hp)

	local is_DisplayFoodValues = mods.active_mods_by_name["Display food values"]
	--TODO: Эта проверка нужна на клиенте!
	local is_AlwaysOnStatus = mods.active_mods_by_name["Combined Status"] or mods.active_mods_by_name["Always On Status"]
	--_G.arr(mod_names)

	local cooking = require("cooking")

	local ing = cooking.ingredients

	local ww
	AddPrefabPostInit("world",function(inst)
		ww = inst.state
	end)

	--容器
	local function GetPerishTime(inst, c)
		local modifier = 1
		local owner = c.inventoryitem and c.inventoryitem.owner or nil
		if not owner and c.occupier then
			owner = c.occupier:GetOwner() --Для птичек?
		end

		if owner then
			if owner.components.preserver ~= nil then
				modifier = owner.components.preserver:GetPerishRateMultiplier(inst) or modifier -- 传入被检查物品, 使容器能够正确显示保鲜度
			elseif owner:HasTag("fridge") then
				if inst:HasTag("frozen") and not owner:HasTag("nocool") and not owner:HasTag("lowcool") then
					modifier = TUNING.PERISH_COLD_FROZEN_MULT
				else
					modifier = TUNING.PERISH_FRIDGE_MULT
				end
			elseif owner:HasTag("foodpreserver") then
				modifier = TUNING.PERISH_FOOD_PRESERVER_MULT
			elseif owner:HasTag("cage") and inst:HasTag("small_livestock") then
				modifier = TUNING.PERISH_CAGE_MULT
			end

			if owner:HasTag("spoiler") then
				modifier = modifier * TUNING.PERISH_GROUND_MULT
			end
		else
			modifier = TUNING.PERISH_GROUND_MULT
		end

		if inst:GetIsWet() then
			modifier = modifier * TUNING.PERISH_WET_MULT
		end

		if ww.temperature < 0 then
			if inst:HasTag("frozen") and not c.perishable.frozenfiremult then
				modifier = TUNING.PERISH_COLD_FROZEN_MULT
			else
				modifier = modifier * TUNING.PERISH_WINTER_MULT
			end
		end

		if c.perishable.frozenfiremult then
			modifier = modifier * TUNING.PERISH_FROZEN_FIRE_MULT
		end

		if ww.temperature > TUNING.OVERHEAT_TEMP then
			modifier = modifier * TUNING.PERISH_SUMMER_MULT
		end

		if c.perishable.localPerishMultiplyer then
			modifier = modifier * c.perishable.localPerishMultiplyer
		end

		modifier = modifier * TUNING.PERISH_GLOBAL_MULT

		local old_val = c.perishable.perishremainingtime
		if old_val ~= nil then
			local delta = old_val / modifier
			if delta ~= nil then --and delta >= 0 then
				if delta < 0 and c.perishable.perishtime and c.perishable.perishtime > 0 then --modifier < 0 !
					return delta, (c.perishable.perishremainingtime - c.perishable.perishtime) / modifier;
				end
				return delta
			end
		end
	end

	local function old_v38_GetPerishTime(inst,c)
		local modifier = 1
		local owner = c.inventoryitem and c.inventoryitem.owner or nil
		if owner == nil and c.occupier ~= nil then
			owner = c.occupier:GetOwner() --Для птичек?
		end

		if owner ~= nil then
			if owner:HasTag("fridge") then
				if inst:HasTag("frozen") and not owner:HasTag("nocool") and not owner:HasTag("lowcool") then
					modifier = TUNING.PERISH_COLD_FROZEN_MULT
				else
					modifier = TUNING.PERISH_FRIDGE_MULT
				end
			elseif owner:HasTag("spoiler") then
				modifier = TUNING.PERISH_GROUND_MULT
				--elseif owner:HasTag("cage") and inst:HasTag("small_livestock") then
				--	modifier = TUNING.PERISH_CAGE_MULT
			end
		else
			modifier = TUNING.PERISH_GROUND_MULT
		end

		if inst:GetIsWet() then
			modifier = modifier * TUNING.PERISH_WET_MULT
		end

		if ww.temperature < 0 then
			if inst:HasTag("frozen") and not c.perishable.frozenfiremult then
				modifier = TUNING.PERISH_COLD_FROZEN_MULT
			else
				modifier = modifier * TUNING.PERISH_WINTER_MULT
			end
		end

		if c.perishable.frozenfiremult then
			modifier = modifier * TUNING.PERISH_FROZEN_FIRE_MULT
		end

		if ww.temperature > TUNING.OVERHEAT_TEMP then
			modifier = modifier * TUNING.PERISH_SUMMER_MULT
		end

		if c.perishable.localPerishMultiplyer then
			modifier = modifier * c.perishable.localPerishMultiplyer
		end

		modifier = modifier * TUNING.PERISH_GLOBAL_MULT

		local old_val = c.perishable.perishremainingtime
		if old_val ~= nil then
			local delta = old_val / modifier
			if delta ~= nil then --and delta >= 0 then
				if delta < 0 and c.perishable.perishtime and c.perishable.perishtime > 0 then --modifier < 0 !
					return delta, (c.perishable.perishremainingtime - c.perishable.perishtime) / modifier;
				end
				return delta
			end
		end
	end

	--Новая функция
	local desc_table
	local function cn(key,param1,param2,param3,param4,param5)
		local data = MY_DATA[key]
		if data == nil then
			return
		end
		if param1 == nil then
			table.insert(desc_table, data.sym)
			return
		end
		if param2 == nil then
			table.insert(desc_table, data.sym ..tostring(param1))
			return
		end
		if param3 == nil then
			table.insert(desc_table, data.sym ..tostring(param1) .. "," ..tostring(param2))
			return
		end
		if param4 == nil then
			table.insert(desc_table, data.sym ..tostring(param1) .. "," ..tostring(param2) .. "," ..tostring(param3))
			return
		end
		if param5 == nil then
			table.insert(desc_table, data.sym ..tostring(param1) .. "," ..tostring(param2) .. "," ..tostring(param3)
					.. "," ..tostring(param4))
			return
		end
		table.insert(desc_table, data.sym ..tostring(param1) .. "," ..tostring(param2) .. "," ..tostring(param3)
				.. "," ..tostring(param4) .. "," ..tostring(param5))
		return
	end

	local is_admin
	local last_user_talbe = {}
	--Проверяет, является ли чел админом.
	local function IsAdmin(viewer)
		if is_admin ~= nil then
			return is_admin
		end
		if not (viewer and viewer.userid) then
			return false
		end
		for i=1,#last_user_talbe do
			local user = last_user_talbe[i]
			if user.userid == viewer.userid then
				is_admin = user.admin or false
				return is_admin
			end
		end
		last_user_talbe = _G.TheNet:GetClientTable()
		for i=1,#last_user_talbe do
			local user = last_user_talbe[i]
			if user.userid == viewer.userid then
				is_admin = user.admin or false
				return is_admin
			end
		end
	end

	local function name_by_id(userid)
		for i,v in ipairs(_G.AllPlayers) do
			if v.userid == userid then
				return v.name
			end
		end
		return "---Unknown---"
	end
	--GetGlobal("name_by_id",name_by_id)

	--local TemperatureFormatLocal

	local SPICIAL_STRUCTURES = {
		campfire = true, coldfire = true,
	}

	--食物BUFF 信息显示
	--local test_buff_seen = {buff_playerabsorption=1, buff_workeffectiveness=1, buff_attack=1}
	local KNOWN_BUFFS = {
		buff_workeffectiveness = {
			name = SHOWME_STRINGS.xiaolv,
			duration = 'BUFF_WORKEFFECTIVENESS_DURATION',
			power = 'BUFF_WORKEFFECTIVENESS_MODIFIER',
		},
		buff_playerabsorption = {
			name = SHOWME_STRINGS.fangyu,
			duration = 'BUFF_PLAYERABSORPTION_DURATION',
			power = 'BUFF_PLAYERABSORPTION_MODIFIER',
			shift = true,
		},
		buff_attack = {
			name = SHOWME_STRINGS.gongji,
			duration = 'BUFF_ATTACK_DURATION',
			power = 'BUFF_ATTACK_MULTIPLIER',
		},
		buff_moistureimmunity = {
			name = SHOWME_STRINGS.fangshui,
			duration = 'BUFF_MOISTUREIMMUNITY_DURATION',
			--power = 'BUFF_WORKEFFECTIVENESS_MODIFIER',
		},
		buff_electricattack = {
			name = SHOWME_STRINGS.gandian,
			duration = 'BUFF_ELECTRICATTACK_DURATION',
			--power = 'BUFF_WORKEFFECTIVENESS_MODIFIER',
		},
		wormlight_light_greater = {
			name = SHOWME_STRINGS.faguang,
			duration = function()
				return TUNING.WORMLIGHT_DURATION and TUNING.WORMLIGHT_DURATION * 4 -- multiplier is hardcoded, sadly. See wormlight.lua
			end,
			--power = 'BUFF_WORKEFFECTIVENESS_MODIFIER',
		},
		healthregenbuff = {
			name = SHOWME_STRINGS.huifu,
			duration = 'JELLYBEAN_DURATION',
			--power = 'BUFF_WORKEFFECTIVENESS_MODIFIER',
		},
	}
	--debuff时间
	local function GetDebuffTime(viewer, buff_name)
		local d = viewer.components.debuffable
		if not d then
			return
		end
		for k,v in pairs(d.debuffs) do
			if k == buff_name then
				local timer = v.inst.components.timer
				if timer and timer.GetTimeLeft then
					local tm = timer:GetTimeLeft('buffover')
					return tm
				end
				break
			end
		end
	end

	--在船上显示木材、树枝修理度
	local function AddBoatStatus(viewer)
		if viewer.boat_status_task then
			viewer.boat_status_task:Cancel()
		end
		viewer.boat_status_task = viewer:DoTaskInTime(120,function(inst)
			inst.boat_status_task = nil
		end)
	end

	local C_FINITEUSES_PREFAB = { -- mult to num "uses" for each prefab
		spiderden_bedazzler = 0.05,
		spider_repellent = 0.1,
		spider_whistle = 0.5,
	}

	local USELESS_TIMERS = {
		--default for all prefabs
		toadstool = { channeltick = true },
		all = { ChildSpawner_RegenPeriod = true, ChildSpawner_SpawnPeriod = true, },
	}

	local function IsUselessTimer(prefab,name)
		local data = USELESS_TIMERS[prefab]
		if not data then
			return USELESS_TIMERS.all[name]
		end
		if data == name then
			return true
		end
		if type(data) == 'table' and data[name] then
			return true
		end
		return USELESS_TIMERS.all[name]
	end

	--Основная функция получения описания.
	function GetTestString(item,viewer) --从这里开始，与Tell Me区分
		--line_cnt = 0
		desc_table = {} --старый desc отменяется

		is_admin = nil
		local prefab = item.prefab
		local c=item.components
		local has_owner = false --Выводим инфу о владельце лишь ОДИН раз!
		local o_t = OTHER_TITLES
	local UpvalueHacker = require("tools/upvaluehacker")
		-- local ftime =  function (seconds)	--时间格式化
		-- local minutes = math.floor(seconds / 60)
		-- seconds = seconds % 60
		-- return string.format("%02d:%02d", minutes, seconds)
		-- end
		if (prefab=="rock1" or prefab=="rock2") and not viewer.has_AlwaysOnStatus then	--没有开季节时钟则在石头上显示季节与剩余天数
			--if not is_AlwaysOnStatus then --TODO: Do not check! NB!
			local w=_G.TheWorld.state
			local tt=round2(w.temperature,1)
			if w.iswinter then cn("S1")
			elseif w.issummer then cn("S2")
			elseif w.isspring then cn("S3")
			elseif w.isautumn then cn("S4")
			end
			cn("remaining_days",w.remainingdaysinseason)
			cn("temperature",tt)
			--..MY_STRINGS["remaining_days"][2]..": "..w.remainingdaysinseason.."\n"
			--.."t "..(tt>=0 and "+" or "")..tt
			--end
		elseif c.health and not item.grow_stage then --Health, Hunger, Sanity Bar
			local h=c.health
			--cheat
			if item.is_admin then
				cn("is_admin")
				return desc_table[1]
			end
			--生物血量
			if need_send_hp then --c.health
				local mx;
				local cur;
				if (h.minhealth ~= nil and h ~= nil) then
					mx=math.ceil(h.maxhealth-h.minhealth)
					cur=math.ceil(h.currenthealth-h.minhealth)

					if cur>mx then cur=mx end
					cn("hp",cur,mx)
				end
			end
			--生物饥饿
			if c.hunger then
				local val = c.hunger:GetPercent()
				--要么没饥饿值的，要么这根本就不是一个玩家。
				if (c.grogginess and val <= 0.5) or (not c.grogginess and (val > 0 or prefab ~= "beefalo")) then
					cn("hunger",round2(c.hunger.current,0))
				end
			elseif item_info_mod == 0 and c.perishable ~= nil and c.perishable.updatetask ~= nil then --Here "Perishable" means "Hunger".
				local time = GetPerishTime(item, c)
				if time ~= nil then
					cn("will_die",round2(time/TUNING.TOTAL_DAY_TIME,1))
				end
			end
			if c.sanity and c.sanity:GetPercent()<=0.5 then
				local sanity = round2(math.floor(c.sanity:GetPercent()*100+0.5),1)
				cn("sanity_character",sanity)
			end
			--随从
			if c.follower then
				if c.follower.leader and c.follower.leader:IsValid() and c.follower.leader:HasTag("player")
						and c.follower.leader.name and c.follower.leader.name ~= ""
				then
					cn("owner",c.follower.leader.name)
					has_owner = true
				end
				if c.follower.maxfollowtime then	--最大跟随时间
					mx = c.follower.maxfollowtime
					cur = math.floor(c.follower:GetLoyaltyPercent()*mx+0.5)
					if cur>0 then
						cn("loyal",cur,mx)
					end
				end
			end
			--[[if c.locomotor and type(c.locomotor.walkspeed)=="number" then
                local speed = (c.locomotor.walkspeed + (type(c.locomotor.bonusspeed)=="number" and c.locomotor.bonusspeed or 0))
                    / TUNING.WILSON_WALK_SPEED
                if speed>1.01 or speed<0.99 then
                    desc = cn(desc,"x"..round2(speed,2),"speed")
                end
            end --]]
			if item.kills and type(item.kills) == "number" and item.kills>0 then
				cn(item.kills==1 and "kill" or "kills",item.kills)
			end
			if item.aggro and type(item.aggro) == "number" and item.aggro>0 then
				cn("aggro",item.aggro)
			end
			--伤害增加百分比。 例如，女武神 +25%
			if c.combat and c.combat.damagemultiplier and c.combat.damagemultiplier ~= 1 then
				local perc = c.combat.damagemultiplier - 1
				cn("dmg_character",round2(perc*100,0))
			end
			--伤害
			if c.combat and c.combat.defaultdamage and c.combat.defaultdamage > 0 then
				--Игнорируем всех, чья сила равна 10 или меньше.
				local com = c.combat
				local dmg = com.defaultdamage
				local pvp_perc = tonumber(com.playerdamagepercent) --玩家 NPC 伤害修正，仅适用于无武器
				if pvp_perc then
					if pvp_perc == 1 or not is_PvP and prefab == "abigail" then
						pvp_perc = nil
					else
						pvp_perc = round2((pvp_perc - 1)*100);
						--pvp_perc = tostring(round2(pvp_perc,2))
					end
				end
				cn("strength", tostring(round2(dmg,1)), pvp_perc)

				if c.planardamage and c.planardamage.basedamage and c.planardamage.basedamage > 0 then		--生物位面伤害
					cn("basedmg", math.floor(c.planardamage.basedamage))	--位面伤害不计算小数？向下整取试试, 不知有没pvp
				end

				if show_planar_resist and c.planarentity then	--生物位面抵抗
					table.insert(desc_table, "@"..o_t.dmgresist)
				end

				if com.areahitdamagepercent then --AoE
					cn("aoe", math.floor( dmg * com.areahitdamagepercent + 0.5))
				end
			end

			--防御
			if h.absorb~=0 or h.playerabsorb~=0 then
				local perc = 1-(1-h.absorb)*(1-h.playerabsorb)
				cn("armor_character",round2(perc*100,0))
			end
			if item.asunaheal_score and prefab == "asuna" and TUNING.ASUNA_HEAL_SCORE_SWORD
					and item.asunaheal_score < TUNING.ASUNA_HEAL_SCORE_SWORD
			then
				local asuna_proof = round2(math.floor((item.asunaheal_score/TUNING.ASUNA_HEAL_SCORE_SWORD)*100+0.5),0)
				if asuna_proof > 99 then
					asuna_proof = 99
				end
				table.insert(desc_table, "@Asuna Proof: "..asuna_proof.."%")
			end
			--inst.components.domesticatable:GetObedience()
			if c.domesticatable ~= nil then
				if c.domesticatable.GetObedience ~= nil then
					local obedience = c.domesticatable:GetObedience()
					if obedience ~= 0 then
						cn("obedience",round2(obedience*100,0))
					end
				end
				if c.domesticatable.GetDomestication ~= nil then
					local domest = c.domesticatable:GetDomestication()
					if domest ~= 0 then
						cn("domest",round2(domest*100,0))
					end
				end
			end
			if c.growable and c.growable.GetStage then
				local g = c.growable
				local t = (g.pausedremaining ~= nil and math.max(0, math.floor(g.pausedremaining)))
						or (g.targettime ~= nil and math.floor(g.targettime - _G.GetTime()))
						or nil
				if t then
					local stage = g.stage ~= 1 and tonumber(g.stage) or 1;
					local data = g.stages and g.stages[stage];
					cn("growable",data and data.name or stage,round2(t),g.pausedremaining ~= nil and 1 or 0);
				end
			end
			if c.sanityaura then
				local s = c.sanityaura;
				local aura_val = s.aurafn and s.aurafn(item, viewer) or s.aura
				if aura_val then
					if s.fallofffn then -- fallofffn but not distance
						local fall = s.fallofffn(item, viewer, 99)
						if fall and fall ~= 0 and (fall < 0.98 or fall > 1.02) then
							aura_val = aura_val / fall;
						end
					end
					aura_val = round2(aura_val * TUNING.TOTAL_DAY_TIME * 0.125,1) --240 hardcoded. I'm not sure what it is
					if aura_val ~= 0 then
						cn("sanityaura",aura_val)
					end
				end
			end
		else --elseif prefab~="rocks" and prefab~="flint" then --No rocks and flint
			--Part 1: primary info
			--烹饪锅
			if c.stewer and c.stewer.product and c.stewer.IsCooking and c.stewer:IsCooking() then
				local tm=round2(c.stewer.targettime-_G.GetTime(),0)
				if tm<0 then tm=0 end
				cn("cookpot", c.stewer.product)
				cn("sec",tm)
			end
			--冷却
			if c.cooldown and c.cooldown.GetTimeToCharged and not c.cooldown.charged then
				local timer = round2(c.cooldown:GetTimeToCharged(),0)
				cn("cooldown", timer)
			end
			--成长
			if c.growable and c.growable.GetStage then
				local g = c.growable
				local t = (g.pausedremaining ~= nil and math.max(0, math.floor(g.pausedremaining)))
						or (g.targettime ~= nil and math.floor(g.targettime - _G.GetTime()))
						or nil
				if t then
					local stage = g.stage ~= 1 and tonumber(g.stage) or 1;
					local data = g.stages and g.stages[stage];
					cn("growable",data and data.name or stage,round2(t),g.pausedremaining ~= nil and 1 or 0);
				end
			end
			--Part 2: secondary info
			if item_info_mod == 0 then
				if c.armor and c.armor.absorb_percent and type(c.armor.absorb_percent)=="number" then
					local r=c.armor.absorb_percent --0.8
					local tm_buff = GetDebuffTime(viewer, 'buff_playerabsorption')
					if tm_buff then
						local power = TUNING[KNOWN_BUFFS.buff_playerabsorption.power]
						if power then
							r = r + (1 - r) * power
						end
					end
					cn("armor",round2(r*100,0),tm_buff and round2(tm_buff))
					if c.planardefense and c.planardefense.basedefense and type(c.planardefense.basedefense)=="number" then
						cn("basearmor",round2(c.planardefense.basedefense,0)..o_t.point)	--新增的防具位面防御，不吃BUFF
					end
					--Support of absorption mod.
					if item.phys and (item.phys.blunt or item.phys.pierc or item.phys.slash) then
						local p = item.phys
						cn("absorb",(p.blunt or 0).." / "..(p.pierc or 0).." / "..(p.slash or 0))
					end
					if c.armor.condition and c.armor.condition > 0 and c.armor.maxcondition  and not item:HasTag("hide_percentage") then	--耐久度
						cn("durability", math.floor(c.armor.condition + 0.5), math.floor(c.armor.maxcondition + 0.5))
					end
				end
			end
			if item_info_mod == 0 then
				if item.damage and type(item.damage)=="number" and item.damage>0 then	--item的伤害与位面伤害
					cn("dmg",round2(item.damage,1))
					if item.basedamage and type(item.basedamage)=="number" and item.basedamage>0 then
						cn("basedmg",round2(item.basedamage,1))
					end
				elseif c.weapon ~= nil and c.weapon.damage and type(c.weapon.damage)=="number" and c.weapon.damage>0 then
					local r = c.weapon.damage
					local tm_buff = GetDebuffTime(viewer, 'buff_attack')
					if tm_buff then
						local power = TUNING[KNOWN_BUFFS.buff_attack.power]
						if power then
							r = r * power
						end
					end
					--local prval = string.gsub(string.format("%.1f", (math.sqrt(r * 4 + 64) - 8) * 4),".0","")
					local prval = tostring(round2((math.sqrt(r * 4 + 64) - 8) * 4,1))
					local pr_val = ""
					if show_planar_resist then pr_val = " ( "..o_t.resist..prval.." )" end
					cn("dmg",round2(r,1)..pr_val, tm_buff and round2(tm_buff))

					if c.planardamage ~= nil and c.planardamage.basedamage and type(c.planardamage.basedamage)=="number" and c.planardamage.basedamage>0 then
						cn("basedmg",round2(math.floor(c.planardamage.basedamage)))	--武器/工具的位面伤害，不吃BUFF
					end
					--Support of absobtion mod.
					if item.phys_dmg then
						local p = item.phys_dmg == "blunt" and "Blunt" or (
								item.phys_dmg == "pierc" and "Piercing" or (
										item.phys_dmg == "slash" and "Slashing" or nil
								)
						)
						if p ~= nil then
							table.insert(desc_table, "@Type: "..p)
						end
					end
				elseif c.zupalexsrangedweapons ~= nil
						and c.zupalexsrangedweapons.GetArrowBaseDamage ~= nil
						and type(c.zupalexsrangedweapons.GetArrowBaseDamage) == "function"
				then
					local dmg = c.zupalexsrangedweapons:GetArrowBaseDamage()
					if dmg ~= nil and type(dmg) == "number" and dmg > 0 then
						cn("dmg",round2(dmg,1))
					end
				end
			end
			if item_info_mod == 0 then	--物品显示的范围
				if c.weapon and c.weapon.damage and type(c.weapon.attackrange)=="number" and c.weapon.attackrange>0.3 then
					cn("range",round2(c.weapon.attackrange,1))
				elseif c.projectile and c.projectile.damage and type(c.projectile.range)=="number" and c.projectile.range>0.3 then
					cn("range",round2(c.projectile.range,1))
				elseif c.combat and c.combat.damage and type(c.combat.attackrange)=="number" and c.combat.attackrange>2.5 then
					cn("range",round2(c.combat.attackrange,1))
				end
			end
			if c.tool then
				local found = nil
				for k,v in pairs(c.tool.actions) do
					if k == _G.ACTIONS.HAMMER or k == _G.ACTIONS.CHOP or k == _G.ACTIONS.MINE then
						found = true
						break
					end
				end
				if found then
					local tm_buff = GetDebuffTime(viewer, 'buff_workeffectiveness')
					if tm_buff then
						local power = TUNING[KNOWN_BUFFS.buff_workeffectiveness.power]
						if power then
							cn("effectiveness", round2(power*100), round2(tm_buff))
						end
					end
				end
			end
			if item_info_mod == 0 and c.insulator and c.insulator.insulation and type(c.insulator.insulation)=="number" and c.insulator.insulation~=0 then
				if c.insulator.SetInsulationEx then --ServerMod
					local winter,summer = c.insulator:GetInsulationEx()
					if winter~=0 then
						cn("warm",round2(winter,0))
					end
					if summer~=0 then
						cn("summer",round2(summer,0))
					end
				elseif c.insulator.GetInsulation then
					local insul,typ = c.insulator:GetInsulation()
					if insul ~= 0 then
						if typ == _G.SEASONS.WINTER then
							cn("warm",round2(insul,0))
						elseif typ == _G.SEASONS.SUMMER then
							cn("summer",round2(insul,0))
						end
					end
				end
			end
			if item_info_mod == 0 then
				if c.dapperness and c.dapperness.dapperness and type(c.dapperness.dapperness)=="number" and c.dapperness.dapperness~=0 then
					local sanity = round2(c.dapperness.dapperness*54,1)
					cn("sanity",sanity)
				elseif c.equippable and c.equippable.dapperness and type(c.equippable.dapperness)=="number" and c.equippable.dapperness~=0 then
					local sanity = round2(c.equippable.dapperness*54,1)
					cn("sanity",sanity)
				elseif prefab == "flower_evil" then
					cn("sanity",-_G.TUNING.SANITY_TINY,1)
				end
			end
			if c.sanityaura then
				local s = c.sanityaura;
				local aura_val = s.aurafn and s.aurafn(item, viewer) or s.aura
				if aura_val then
					if s.fallofffn then -- fallofffn but not distance
						local fall = s.fallofffn(item, viewer, 99)
						if fall and fall ~= 0 and (fall < 0.98 or fall > 1.02) then
							aura_val = aura_val / fall;
						end
					end
					aura_val = round2(aura_val * TUNING.TOTAL_DAY_TIME * 0.125,1)
					if aura_val ~= 0 then
						cn("sanityaura",aura_val)
					end
				end
			end
			if c.equippable and c.equippable.walkspeedmult and c.equippable.walkspeedmult ~= 1 then
				local added_speed = math.floor((c.equippable.walkspeedmult - 1)*100+0.5)
				cn("speed",added_speed)
			end
			if item_info_mod == 0 then
				if c.dapperness and c.dapperness.mitigates_rain and prefab ~= "umbrella" then
					cn("waterproof","90")
				elseif item.protect_from_rain then
					cn("waterproof",round2((item.protect_from_rain)*100,0))
				elseif c.waterproofer then
					local effectiveness = _G.tonumber(c.waterproofer.effectiveness) or 0
					if effectiveness ~= 0 then
						cn("waterproof",round2((effectiveness)*100,0))
					else
						--desc = (desc=="" and "" or (desc.."\n")).."Waterproofer"
					end
				end
			end
			if c.oar and c.oar.force and tonumber(c.oar.force) then
				cn('force',round2(c.oar.force*100))
			end
			--if c.striker and c.striker.chance and type(c.striker.chance) == "number" then
			--	desc = cn(desc,round2((c.striker.chance)*100,0).."%","striker")
			--end
			--if c.tinder and c.tinder.tinder and c.tinder.GetTinder then
			--	local power = c.tinder:GetTinder()
			--	if power >= 0.005 then
			--		desc = cn(desc,round2(power*100,0).."%","tinder")
			--	end
			--end
			if item_info_mod == 0 and c.edible and not is_DisplayFoodValues then
				local can_eat = false
				if viewer and viewer.components.eater then
					can_eat = viewer.components.eater:CanEat(item)
				end
				if can_eat then
					local ed = c.edible
					local should_Estimate_Stale = viewer and viewer.should_Estimate_Stale --client priority
					if not should_Estimate_Stale then
						should_Estimate_Stale = food_estimation ~= 0
					end
					local hp,hg,sn
					if should_Estimate_Stale and ed.GetSanity then
						--print("Estimate")
						hp=round2(ed:GetHealth(viewer),1)
						hg=round2(ed:GetHunger(viewer),1)
						sn=round2(ed:GetSanity(viewer),1)
					else
						--print("Not Estimate")
						hp=round2(ed.healthvalue,1)
						hg=round2(ed.hungervalue,1)
						sn=round2(ed.sanityvalue,1)
					end
					if viewer ~= nil and viewer.FoodValuesChanger ~= nil then --一种特殊功能，其目的是在食用时改变食物。
						--print("+")
						--确实，在这里我们可以在吃之前稍微看看它的结果。
						local hp2, hg2, sn2 = viewer:FoodValuesChanger(item)
						if sn2 ~= nil then
							--print("++")
							hp=round2(hp2,1)
							hg=round2(hg2,1)
							sn=round2(sn2,1)
						end
					end
					local base_mult = viewer ~= nil and viewer.components.foodmemory ~= nil and viewer.components.foodmemory:GetFoodMultiplier(prefab) or 1
					do --check multiplier
						local hp_mult = (ed.healthabsorption or 1) * base_mult
						local hg_mult = (ed.hungerabsorption or 1) * base_mult
						local sn_mult = (ed.sanityabsorption or 1) * base_mult
						hp = hp * hp_mult
						hg = hg * hg_mult
						sn = sn * sn_mult
					end
					if prefab == "petals_evil" then
						sn = round2(sn - _G.TUNING.SANITY_TINY,1)
					end
					if hp > 0 then
						hp = "+" .. tostring(hp)
					end
					if hg > 0 then
						hg = "+" .. tostring(hg)
					end
					if sn > 0 then
						sn = "+" .. tostring(sn)
					end
					cn("food",hg,sn,hp)
					if ed.temperaturedelta ~= 0 then -- 食物有温度
						if ed.temperatureduration ~= 0 and ed.chill < 1 and viewer ~= nil and viewer.components.temperature ~= nil then
							local delta_multiplier = 1
							local duration_multiplier = 1
							if ed.spice and _G.TUNING.SPICE_MULTIPLIERS[ed.spice] then
								if _G.TUNING.SPICE_MULTIPLIERS[ed.spice].TEMPERATUREDELTA then
									delta_multiplier = delta_multiplier + _G.TUNING.SPICE_MULTIPLIERS[ed.spice].TEMPERATUREDELTA
								end
								if _G.TUNING.SPICE_MULTIPLIERS[ed.spice].TEMPERATUREDURATION then
									duration_multiplier = duration_multiplier + _G.TUNING.SPICE_MULTIPLIERS[ed.spice].TEMPERATUREDURATION
								end
							end
							local delta, duration = ed.temperaturedelta * (1 - ed.chill) * delta_multiplier, ed.temperatureduration * duration_multiplier
							cn('food_temperature',round2(delta), round2(duration))
						end
					end
					if base_mult ~= 1 then --食物储存，例如厨子
						local fm = viewer.components.foodmemory
						if fm.GetBaseFood and fm.foods then
							local rec = fm.foods[fm:GetBaseFood(prefab)]
							if rec then
								local t = _G.GetTaskRemaining(rec.task)
								cn('food_memory',round2(base_mult,2),round2(t))
							end
						end
					end
					--香料效果
					if ed.spice and false then
						if ed.spice == 'SPICE_SUGAR' then --spice_sugar
							cn("buff","Work",round2(TUNING.BUFF_WORKEFFECTIVENESS_MODIFIER,1),round2(TUNING.BUFF_WORKEFFECTIVENESS_DURATION/TUNING.TOTAL_DAY_TIME))
						elseif ed.spice == 'SPICE_GARLIC' then --spice_garlic
							cn("buff","Absorb",round2(TUNING.BUFF_PLAYERABSORPTION_MODIFIER + 1,1),round2(TUNING.BUFF_PLAYERABSORPTION_DURATION/TUNING.TOTAL_DAY_TIME))
						elseif ed.spice == 'SPICE_CHILI' then --spice_chili
							cn("buff","Attack",round2(TUNING.BUFF_ATTACK_MULTIPLIER,1),round2(TUNING.BUFF_ATTACK_DURATION/TUNING.TOTAL_DAY_TIME))
						end
					end
					--Warly effects
					for _,struct in pairs(cooking.recipes) do
						for food,v in pairs(struct) do
							if food == prefab then
								if not v.prefabs then
									break
								end
								for i,buff_name in ipairs(v.prefabs) do
									local duration = nil
									local power = nil
									local data = KNOWN_BUFFS[buff_name]
									if data then
										if type(data.duration) == 'function' then
											duration = data.duration()
										else
											duration=TUNING[data.duration]
										end
										if data.power then
											power=TUNING[data.power]
										end
										if data.shift and data.power then
											power = power + 1
										end
										buff_name = data.name
									else
										local up = buff_name:upper();
										duration = TUNING[up .. '_DURATION']
										power = TUNING[up .. '_MULTIPLIER'] or TUNING[up .. '_MODIFIER']
										if buff_name:find("buff_",1,true) == 1 then
											buff_name = buff_name:sub(6)
										end
										if buff_name:find("buff",#buff_name-3,true) then
											buff_name = buff_name:sub(1,#buff_name-4)
										end
									end
									if duration then
										duration = round2(duration / TUNING.TOTAL_DAY_TIME,1)
										cn("buff",buff_name,duration,power)
									end
								end
							end
						end
					end
				end
			end
			if show_nutrients ~= false then --肥料信息
				if c.fertilizer then
					local _nt = c.fertilizer
					if show_nutrients == 1 then
						table.insert(desc_table, "@"..o_t.nutrients_1.._nt.nutrients[1].." / "..o_t.nutrients_2.._nt.nutrients[2].." / "..o_t.nutrients_3.._nt.nutrients[3])
					elseif show_nutrients == 2 then
						table.insert(desc_table, "@"..o_t.nutrients.._nt.nutrients[1].." / ".._nt.nutrients[2].." / ".._nt.nutrients[3])
					end
				end
			end
			if item_info_mod == 0 and c.perishable ~= nil and c.perishable.updatetask ~= nil then	--鱼，死亡到腐烂：x 天
				local time, fresh = GetPerishTime(item, c)
				if time ~= nil then
					if time < 0 then
						if fresh then
							if fresh < 0 then
								--fresh = 0
							end
							cn("fresh",round2(fresh/TUNING.TOTAL_DAY_TIME,1))
						end
					elseif time ~= math.huge and time ~= -math.huge then
						if item:HasTag("critter") then
							table.insert(desc_table, "@"..o_t.critterhunger..tostring(round2(time/TUNING.TOTAL_DAY_TIME,1))..SHOWME_STRINGS.days)
						else
							cn("perish",round2(time/TUNING.TOTAL_DAY_TIME,1))
						end
					end
				end
			end
			--显示食物填充单位
			if ing[prefab] and show_food_units ~= 2 then -- ==2 means that food info is forbidden on the server.
				for k,v in pairs(ing[prefab].tags) do
					if k~="precook" and k~="dried" then
						cn("units_of",v,k)
					end
				end
			end
			if item_info_mod == 0 and c.healer then
				local heal = round2(c.healer.health,1)
				if heal == 0 then
					if prefab == 'spider_healer_item' then
						heal = TUNING.HEALING_MEDSMALL
					end
				end
				if heal and heal ~= 0 then
					cn("heal",heal)
				end
			end
			--工具、武器耐久
			if item_info_mod == 0 and c.finiteuses and not item:HasTag("hide_percentage") then
				local mult = C_FINITEUSES_PREFAB[prefab]
				if c.finiteuses.consumption then
					for k,v in pairs(c.finiteuses.consumption) do
						local new_mult = 1/v
						if mult == nil or new_mult > mult then
							mult = new_mult
						end
					end
				end
				if mult == nil then
					mult = 1
				end
				local cur = math.floor(c.finiteuses.current * mult + 0.5)
				if c.finiteuses.current*mult > cur then
					cur = cur + 1
				end
				cn("uses_of",cur,math.floor(c.finiteuses.total * mult + 0.5))
				--desc = (desc=="" and "" or (desc.."\n"))..cur.." use"..(cur~=1 and "s" or "").." of "..c.finiteuses.total
			end
			--温度
			if c.temperature and c.temperature.current and type(c.temperature.current) == "number" then
				cn("temperature",round2(c.temperature.current,1))
			end
			--建筑燃料
			if c.fueled and c.fueled:GetPercent()>0 and (SPICIAL_STRUCTURES[prefab] or item:HasTag("structure")) then
				--cn("fuel",round2(c.fueled:GetPercent()*100,0))
				if c.fueled.currentfuel ~= nil then
					table.insert(desc_table, "@"..o_t.ot_fuel..DataTimerFn(c.fueled.currentfuel).." ( "..math.floor(c.fueled:GetPercent()*100).."% )")
				end
				if show_fuel ~= false and c.fueled.bonusmult ~= nil and c.fueled.bonusmult > 1 then
					table.insert(desc_table, "@"..o_t.ot_fuelval..c.fueled.bonusmult.."x")
				end
			end
			--堆肥桶容量
			if c.compostingbin and c.compostingbin ~= nil then
				table.insert(desc_table, "@"..o_t.capacity..c.compostingbin:GetMaterialTotal().." / "..c.compostingbin.max_materials)
			end

			if c.instrument and type(c.instrument.range)=="number" and c.instrument.range>0.4 then
				cn("range",round2(c.instrument.range,0))
			end
			if c.crystallizable and c.crystallizable.formation --support of Krizor's mod
					and c.crystallizable.formation.thickness
					and type(c.crystallizable.formation.thickness)=="table"
					and c.crystallizable.formation.thickness.current
					and c.crystallizable.formation.thickness.current>0
			then
				cn("thickness",round2(c.crystallizable.formation.thickness.current,1))
			end
			--装备饥饿减免
			if prefab=="beargervest" then
				table.insert(desc_table, "@"..string.format(o_t.hungerslow, (1-TUNING.ARMORBEARGER_SLOW_HUNGER)*100).."%")
			elseif prefab=="armorslurper" or prefab=="hat_albicans_mushroom" then
				table.insert(desc_table, "@"..string.format(o_t.hungerslow, (1-TUNING.ARMORSLURPER_SLOW_HUNGER)*100).."%")
			elseif prefab == "red_mushroomhat" or prefab == "green_mushroomhat" or prefab == "blue_mushroomhat" then
				table.insert(desc_table, "@"..string.format(o_t.hungerslow, (1-TUNING.MUSHROOMHAT_SLOW_HUNGER)*100).."%")
			end
			--跟随者
			if c.mine then
				if c.mine.nick then
					cn("owner",c.mine.nick)
					has_owner = true
				end
				--[[if c.mine.pret and viewer and viewer.userid then
                    for k,v in pairs(c.mine.pret) do
                        if k==viewer.userid then
                            --desc = (desc=="" and "" or (desc.."\n")).."I can see it!"
                            desc = cn(desc,v,"known",true)
                            break
                        end
                    end
                end--]]
			end
			if not has_owner then
				if item.stealable and item.stealable.owner and item.stealable.owner ~= "_?\1" then
					cn("owner",item.stealable.owner)
					has_owner = true
				elseif item.owner and type(item.owner)=="string" and string.sub(item.owner,1,3) ~= "KU_" then
					--不知道名字是什么，但这就是“主人”，所以需要取出来，而且这绝对不是user_id。
					cn("owner",item.owner)
					has_owner = true
				end
			end
			if c.occupiable then
				local item = c.occupiable:GetOccupant()
				if item then
					local c = item.components
					if c.perishable ~= nil and c.perishable.updatetask ~= nil then --这里“易腐烂”的意思是“饥饿”。
						local time = GetPerishTime(item, c)
						if time ~= nil then
							cn("will_die",round2(time/TUNING.TOTAL_DAY_TIME,1))
						end
					end
				end
			end
			if c.dryer and c.dryer.IsDrying then
				if c.dryer:IsDrying() and c.dryer.GetTimeToDry then
					cn("will_dry",round2(c.dryer:GetTimeToDry()/TUNING.TOTAL_DAY_TIME,1)) --距离死亡
					--if c.dryer:IsPaused() then
					--end
				elseif c.dryer.IsDone and c.dryer:IsDone() and c.dryer.GetTimeToSpoil then --距离腐烂
					cn("perish",round2(c.dryer:GetTimeToSpoil()/TUNING.TOTAL_DAY_TIME,1))
				end
			end
			--鞍具
			if c.saddler then
				if c.saddler.speedmult and c.saddler.speedmult ~= 0 then
					local added_speed = math.floor((c.saddler.speedmult - 1)*100 + 0.5) -- (1.4 - 1) == 0.4
					cn("speed",added_speed)
				end
				if c.saddler.bonusdamage and c.saddler.bonusdamage ~= 0 then
					cn("dmg_bonus",round2(c.saddler.bonusdamage,1))
				end
			end
			--服饰耐久
			if show_fueled ~= false then --if c.fueled.rate --效率
				if c.fueled ~= nil and not item:HasTag("hide_percentage") then
					local FueledTime = DataTimerFn(c.fueled.currentfuel)
					local FueledDay = tostring(round2(c.fueled.currentfuel / TUNING.TOTAL_DAY_TIME,1))
					local FDays = SHOWME_STRINGS.days
					if show_fueled == 1 then	--根据配置，显示不同的样式
						s_fval = o_t.fueled..FueledTime
					elseif show_fueled == 2 then
						s_fval = o_t.fueled..FueledDay..FDays
					else
						s_fval = o_t.fueled..FueledTime.." ( "..FueledDay..FDays.." )"
					end
					--CAVE, NIGHTMARE, MAGIC, CHEMICAL, WORMLIGHT
					if (c.fueled.fueltype == _G.FUELTYPE.USAGE or c.fueled.secondaryfueltype == _G.FUELTYPE.USAGE) and not (c.fueled.no_sewing or item:HasTag("heatrock")) then
						table.insert(desc_table, "@"..s_fval)
					elseif c.fueled.fueltype == _G.FUELTYPE.CAVE or c.fueled.secondaryfueltype == _G.FUELTYPE.CAVE or c.fueled.fueltype == _G.FUELTYPE.WORMLIGHT or c.fueled.secondaryfueltype == _G.FUELTYPE.WORMLIGHT then
						table.insert(desc_table, "@"..s_fval)
					elseif (c.fueled.fueltype == _G.FUELTYPE.NIGHTMARE or c.fueled.secondaryfueltype == _G.FUELTYPE.NIGHTMARE) and c.fueled.accepting and not (item:HasTag("pocketwatch") or item:HasTag("fossil") or item:HasTag("structure") or item:HasTag("book")) then
						table.insert(desc_table, "@"..s_fval)
					elseif (c.fueled.fueltype == _G.FUELTYPE.MAGIC or c.fueled.secondaryfueltype == _G.FUELTYPE.MAGIC) and not (item:HasTag("structure") or prefab == "miniboatlantern") then
						table.insert(desc_table, "@"..s_fval)
					elseif prefab == "torch" or prefab == "lighter" or prefab == "nightstick" or prefab == "minifan" or prefab == "walking_stick" then
						table.insert(desc_table, "@"..s_fval)
					end
				end
			end
			--物品价值金块、石头
			if c.tradable then
				if c.tradable.goldvalue and c.tradable.goldvalue > 1 then
					cn("trade_gold", c.tradable.goldvalue)
				end
				if c.tradable.rocktribute and c.tradable.rocktribute > 0 and _G.TheWorld.state.issummer then
					cn("trade_rock", c.tradable.rocktribute)
				end
			end
			--冰箱 etc
			if TUNING.PERISH_FRIDGE_MULT ~= 0.5 and item:HasTag("fridge") then
				local fridge = tonumber(TUNING.PERISH_FRIDGE_MULT);
				if fridge then
					cn("frigde",round2(fridge,1))
				end
			end
			--物品对船的修理值
			if viewer.boat_status_task and c.repairer and c.repairer.healthrepairvalue and c.repairer.healthrepairvalue ~= 0 then
				cn("repairer",round2(c.repairer.healthrepairvalue,2))
			end
			--收获
			if c.harvestable then
				local h = c.harvestable
				if h.product and h.produce and h.maxproduce and type(h.produce)=='number' and type(h.maxproduce)=='number' then
					local tt = tonumber(h.targettime)
					local pt = tonumber(h.pausetime)
					local paused = not (h.enabled and tt)
					if tt then
						local tm = round2(tt - GetTime(),0)
						if tm >= 0 then
							cn("harvest",h.product,h.produce,h.maxproduce,tm,paused and 0 or nil)
						end
					elseif pt then
						cn("harvest",h.product,h.produce,h.maxproduce,round2(pt,0),0)
					else
						cn("harvest",h.product,h.produce,h.maxproduce)
					end
				end
			end
			--弹弓弹药
			if item:HasTag("slingshotammo") then
				local SLINGSHOT_AMMO_DATA = {}	--创建表
				for i,v in pairs(_G.Prefabs) do		--获取官方Prefab
					if v.fn and _G.debug.getinfo(v.fn, "S").source == "scripts/prefabs/slingshotammo.lua" then		--Prefab 的Fn
						if v.name:sub(-5) == "_proj" then
							--table.insert(ammo_prefabs, Prefab(name, function() return fn(data) end, assets, prefabs))  --新
							--table.insert(ammo_prefabs, Prefab(v.name.."_proj", function() return projectile_fn(v) end, assets, prefabs))  --旧
							local ammo_data = UpvalueHacker.GetUpvalue(v.fn, "data") --"v" > "data"
							if ammo_data ~= nil and type(ammo_data) == "table" then
								SLINGSHOT_AMMO_DATA[ammo_data.name] = ammo_data
							end
						end
					end
				end

				local function GetSlingshotAmmoData(inst)
					return SLINGSHOT_AMMO_DATA[prefab]
				end
				local ammo_data = GetSlingshotAmmoData(ammo)
				if ammo_data ~= nil then
					if ammo_data.damage ~= nil then cn("dmg", ammo_data.damage) end
					if ammo_data.planar ~= nil then cn("basedmg", ammo_data.planar) end

				end
			end
			--if item:HasTag("book") then
			--local book_defs = UpvalueHacker.GetUpvalue(_G.Book.SetOnRead, "self.onread")
			-- if prefab == "book_horticulture_upgraded" then
			-- table.insert(desc_table, "@: ".."2333")
			-- end
			--end

			------------------Check prefabs?----------------------
			if prefab=="pond" or prefab=="pond_mos" or prefab=="pond_cave" or prefab=="oasislake" then --池塘
				if c.fishable and c.fishable.fishleft then
					cn(c.fishable.fishleft==1 and "fish" or "fishes",c.fishable.fishleft)
				end
			elseif prefab=="aqvarium" and item.data then
				if item.data.seeds and item.data.seeds>0 then --种子
					table.insert(desc_table, "@Seeds: "..tostring(item.data.seeds))
				end
				if item.data.meat and item.data.meat>0 then --肉
					table.insert(desc_table, "@Meat: "..tostring(item.data.meat))
					--desc = cn(desc,item.data.meat,"Meat:",true)
				end
				local need_wet= item.data.need_wet or 60
				if item.data.wet and item.data.wet>0 and item.data.wet<need_wet then --水
					table.insert(desc_table, "@Water: "..tostring(round2(100*item.data.wet/need_wet).."%"))
					--desc = cn(desc,round2(100*item.data.wet/need_wet).."%","Water:",true)
				end
				if item.total_heat then --总温度
					local temp = item.total_heat/10 --+ _G.TheWorld.state.temperature
					if temp>40 then temp = 40 end
					if temp>=0 then
						cn("temperature",tostring(round2(temp,1)))
					end
				end
			elseif prefab=="rainometer" then --雨量计
				local function inSine(t, b, c, d)
					return -c * math.cos(t / d * (math.pi / 2)) + c + b
				end
				cn("precipitationrate",round2(inSine(_G.TheWorld.state.precipitationrate, 0, 0.75, 1),3).."/s")
				cn("wetness",round2(_G.TheWorld.state.wetness,1))
			elseif prefab=="winterometer" then --温度计
				local w=_G.TheWorld.state
				local tt=round2(w.temperature,1)
				cn("temperature",tt)
			elseif prefab=="spice_garlic" then
				local data = KNOWN_BUFFS.buff_playerabsorption
				cn("buff",data.name,0,TUNING[data.power]+1)
			elseif prefab=="spice_chili" then
				local data = KNOWN_BUFFS.buff_attack
				cn("buff",data.name,0,TUNING[data.power])
			elseif prefab=="spice_sugar" then
				local data = KNOWN_BUFFS.buff_workeffectiveness
				cn("buff",data.name,0,TUNING[data.power])
			elseif prefab=="moon_fissure" and c.sanityaura and c.sanityaura.aurafn then --月亮裂隙
				local current_sanity = c.sanityaura.aurafn(item, viewer)
				local max_sanity = 100/(TUNING.SEG_TIME*2) -- hardcoded!
				local effectiveness = current_sanity / max_sanity
				cn("effectiveness",round2(effectiveness * 100))
			elseif prefab=='boat' or prefab=='anchor' or prefab=='mast' or prefab=='boat_leak' or prefab=='mast_malbatross' or prefab=='steeringwheel' then --船工具
				--没有信息，只有船的状态
				AddBoatStatus(viewer)
			elseif prefab=="cannonball_rock_item" then
				cn("dmg", TUNING.CANNONBALL_DAMAGE)
			elseif prefab=="batbat" then
				local o_bbd = TUNING.BATBAT_DRAIN
				table.insert(desc_table, "@"..string.format(o_t.batbat, o_bbd, -.5 * o_bbd))
			elseif prefab=="ruins_bat" then
				table.insert(desc_table, "@"..string.format(o_t.ruins_bat, TUNING.RUINS_BAT_SHADOW_LEVEL*10).."%")
			elseif prefab=="ruinshat" then
				table.insert(desc_table, "@"..string.format(o_t.ruinshat, (TUNING.RUINSHAT_SHADOW_LEVEL+1.3)*10).."%")
			elseif prefab=="spice_salt" then
				table.insert(desc_table, "@"..string.format(o_t.spice_salt, TUNING.SPICE_MULTIPLIERS.SPICE_SALT.HEALTH*100 .."%"))
			elseif prefab=="slingshotammo_slow" then
				table.insert(desc_table, "@"..string.format(o_t.sammo_slow, math.ceil((TUNING.SLINGSHOT_AMMO_MOVESPEED_MULT - 1)*100) .. "%", TUNING.SLINGSHOT_AMMO_MOVESPEED_DURATION))
			elseif prefab=="slingshotammo_honey" then
				table.insert(desc_table, "@"..string.format(o_t.sammo_honey, math.ceil((TUNING.BEEQUEEN_HONEYTRAIL_SPEED_PENALTY - 1)*100) .. "%"))
			elseif prefab=="slingshotammo_purebrilliance" then
				table.insert(desc_table, "@"..string.format(o_t.mpl_hit, TUNING.SLINGSHOT_BRILLIANCE_MARK_PLANAR_DAMAGE, TUNING.SLINGSHOT_BRILLIANCE_MARK_TIMEOUT))
			elseif prefab=="slingshotammo_horrorfuel" then
				table.insert(desc_table, "@"..string.format(o_t.shf_hit, TUNING.SLINGSHOT_HORROR_PLANAR_DAMAGE, TUNING.SLINGSHOT_HORROR_TICKS))
			elseif prefab=="slingshotammo_stinger" then
				cn("aoe", TUNING.SLINGSHOT_AMMO_DAMAGE_STINGER_AOE)
			elseif prefab=="slingshotammo_moonglass" then
				cn("aoe", TUNING.SLINGSHOT_AMMO_DAMAGE_MOONGLASS_AOE)
			elseif prefab=="slingshot_band_pigskin" then
				table.insert(desc_table, "@"..string.format(o_t.slingshot_range, TUNING.SLINGSHOT_MOD_BONUS_RANGE_1))
				table.insert(desc_table, "@"..string.format(o_t.ammo_speed, TUNING.SLINGSHOT_MOD_SPEED_MULT_1))
			elseif prefab=="slingshot_band_tentacle" or prefab=="slingshot_band_mimic" then
				table.insert(desc_table, "@"..string.format(o_t.slingshot_range, TUNING.SLINGSHOT_MOD_BONUS_RANGE_2))
				table.insert(desc_table, "@"..string.format(o_t.ammo_speed, TUNING.SLINGSHOT_MOD_SPEED_MULT_2))
				if prefab=="slingshot_band_mimic" then table.insert(desc_table, "@"..string.format(o_t.slingshot_speed, TUNING.SLINGSHOT_MOD_FREE_AMMO_CHANCE * 100 .. "%")) end
			end
			--其他物品添加标签	VOIDCLOTH
			local o_t_list = {
				"orchitwigs",	--1
				"halloweenpotion_health_large", "halloweenpotion_health_small",	--2~3
				"halloweenpotion_sanity_large", "halloweenpotion_sanity_small",	--4~5
				"halloweenpotion_bravery_small", "halloweenpotion_bravery_large",	--6~7
				"slingshot_frame_wagpunk","slingshot_frame_wagpunk_0",	--8~9
				"wx78module_taser", "wx78module_nightvision", "wx78module_light", "slingshotammo_thulecite", "slingshotammo_freeze","slingshotammo_poop", "wolfgang_whistle",  "lileaves", "rosorns", "shark_teethhat", "brainjellyhat", "gashat", "onemanband", "armorseashell", "book_birds", "book_brimstone", "book_gardening", "book_silviculture", "book_sleep", "slingshot_frame_bone", "slingshot_frame_gems", "slingshot_handle_voidcloth", }
			for i, n in pairs(o_t_list) do
				if prefab == n then		--必须是列表里面的，不然全部物品都加上这些标签0.0!
					if i == 1 then
						if c.weapon.onattack ~= nil then
							cn("aoe", TUNING.BASE_SURVIVOR_ATTACK*0.7)	--兰草穗群伤，目前只能写死伤害
						end
					elseif i > 1 and i <= 3 then
						cn("other_tag", "halloweenpotion_health")
					elseif i > 3 and i <= 5 then
						cn("other_tag", "halloweenpotion_sanity")
					elseif i > 5 and i <= 7 then
						local potion_time = 0.5
						if i == 7 then
							potion_time = 0.75
						end
						table.insert(desc_table, "@"..string.format(o_t.hpotion_bravery, potion_time))
					elseif i > 7 and i <= 9 then
						cn("other_tag", "slingshot_frame_wagpunk_0")
					elseif i > 9 then
						cn("other_tag", n)
					end
				end
			end
			-- if item:HasTag("lureplant") then --食人花，加不了标签！什么情况？
			-- table.insert(desc_table, "@".."233\n23333")
			-- end
			if c.ghostlyelixir then	--阿比盖尔的药水
				local g_pt = item.potion_tunings
				local day_time = TUNING.TOTAL_DAY_TIME
				local f_duration = TUNING.GHOSTLYELIXIR_FASTREGEN_DURATION
				if g_pt.TICK_FN then
					if g_pt.DURATION == f_duration then
						table.insert(desc_table, "@"..string.format(o_t.healthpertick, TUNING.GHOSTLYELIXIR_FASTREGEN_HEALING).." /"..o_t.second..","..SHOWME_STRINGS.chixu..g_pt.DURATION..o_t.second)
					else
						table.insert(desc_table, "@"..string.format(o_t.healthpertick, TUNING.GHOSTLYELIXIR_SLOWREGEN_HEALING).." /"..o_t.second..","..SHOWME_STRINGS.chixu..g_pt.DURATION/day_time..SHOWME_STRINGS.days)
					end
				elseif g_pt.ONDETACH then
					table.insert(desc_table, "@"..string.format(o_t.ghost_atk, g_pt.DURATION/day_time))
				elseif g_pt.speed_hauntable == true then
					table.insert(desc_table, "@"..string.format(o_t.ghost_sd, (TUNING.GHOSTLYELIXIR_SPEED_LOCO_MULT-1)*100 .."%", g_pt.DURATION/day_time))
				elseif g_pt.shield_prefab then
					if g_pt.shield_prefab == "abigailforcefieldretaliation" then
						table.insert(desc_table, "@"..string.format(o_t.ghost_atkf, TUNING.GHOSTLYELIXIR_RETALIATION_DAMAGE))
					end
					table.insert(desc_table, "@"..string.format(o_t.ghost_shd, g_pt.DURATION/day_time))
				end
			end

			if item:HasTag("battlesong") then	--女武神书
				local song_tunings = require("prefabs/battlesongdefs").song_defs
				if item.songdata == song_tunings.battlesong_durability then
					table.insert(desc_table, "@"..string.format(o_t.bs_dy, (1 - TUNING.BATTLESONG_DURABILITY_MOD) * 100).."%")
				elseif item.songdata == song_tunings.battlesong_healthgain then
					table.insert(desc_table, "@"..string.format(o_t.bs_hp, TUNING.BATTLESONG_HEALTHGAIN_DELTA, TUNING.BATTLESONG_HEALTHGAIN_DELTA_SINGER))
				elseif item.songdata == song_tunings.battlesong_sanitygain then
					table.insert(desc_table, "@"..string.format(o_t.bs_san, TUNING.BATTLESONG_SANITYGAIN_DELTA))
				elseif item.songdata == song_tunings.battlesong_sanityaura then
					table.insert(desc_table, "@"..string.format(o_t.bs_desan, (1 - TUNING.BATTLESONG_NEG_SANITY_AURA_MOD) * 100).."%")
				elseif item.songdata == song_tunings.battlesong_fireresistance then
					table.insert(desc_table, "@"..string.format(o_t.bs_fire, (1 - TUNING.BATTLESONG_FIRE_RESIST_MOD) * 100).."%")
				elseif item.songdata == song_tunings.battlesong_instant_taunt then
					table.insert(desc_table, "@"..o_t.bs_it)
				elseif item.songdata == song_tunings.battlesong_instant_panic then
					table.insert(desc_table, "@"..string.format(o_t.bs_ip, TUNING.BATTLESONG_PANIC_TIME))
				elseif item.songdata == song_tunings.battlesong_shadowaligned then
					table.insert(desc_table, "@"..string.format(o_t.bs_shadow, (TUNING.BATTLESONG_SHADOWALIGNED_VS_LUNAR_BONUS - 1) * 100).."%")
					table.insert(desc_table, "@"..string.format(o_t.bs_shadow2, (TUNING.BATTLESONG_SHADOWALIGNED_SHADOW_RESIST - 1) * 100).."%")
				elseif item.songdata == song_tunings.battlesong_lunaraligned then
					table.insert(desc_table, "@"..string.format(o_t.bs_lunar, (TUNING.BATTLESONG_LUNARALIGNED_VS_SHADOW_BONUS - 1) * 100).."%")
					table.insert(desc_table, "@"..string.format(o_t.bs_lunar2, (TUNING.BATTLESONG_LUNARALIGNED_LUNAR_RESIST - 1) * 100).."%")
				end
			end
			--WX78
			if prefab=="wx78module_maxhealth" or prefab=="wx78module_maxhealth2" then
				local wx78_mhp = 1
				if prefab=="wx78module_maxhealth2" then
					wx78_mhp = TUNING.WX78_MAXHEALTH2_MULT
				end
				table.insert(desc_table, "@"..string.format(o_t.maxhealth, TUNING.WX78_MAXHEALTH_BOOST * wx78_mhp))
			elseif prefab=="wx78module_maxsanity" or prefab=="wx78module_maxsanity1" then
				local wx78_san = ""
				if prefab=="wx78module_maxsanity" then
					cn("sanity", round2(TUNING.WX78_MAXSANITY_DAPPERNESS * 60))
					wx78_san = TUNING.WX78_MAXSANITY_BOOST
				else
					wx78_san = TUNING.WX78_MAXSANITY1_BOOST
				end
				table.insert(desc_table, "@"..string.format(o_t.maxsanity, wx78_san))
			elseif prefab=="wx78module_maxhunger" or prefab=="wx78module_maxhunger1" then
				local wx78_mhg = ""
				if prefab=="wx78module_maxhunger" then
					wx78_mhg = TUNING.WX78_MAXHUNGER_BOOST
					table.insert(desc_table, "@"..string.format(o_t.hungerslow, (1-TUNING.WX78_MAXHUNGER_SLOWPERCENT)*100).."%")
				else
					wx78_mhg = TUNING.WX78_MAXHUNGER1_BOOST
				end
				table.insert(desc_table, "@"..string.format(o_t.maxhunger, wx78_mhg))
			elseif prefab=="wx78module_movespeed" or prefab=="wx78module_movespeed2" then
				local added_speed = math.floor(TUNING.WILSON_RUN_SPEED*4+1)
				cn("speed", added_speed)
				if prefab=="wx78module_movespeed2" then
					cn("other_tag", "wx78_movespeed2")
				end
			elseif prefab=="wx78module_bee" then
				cn("sanity", round2(TUNING.WX78_MAXSANITY_DAPPERNESS * 60))
				table.insert(desc_table, "@"..string.format(o_t.healthpertick, TUNING.WX78_BEE_HEALTHPERTICK).." / "..TUNING.WX78_BEE_TICKPERIOD..o_t.second)
				table.insert(desc_table, "@"..string.format(o_t.maxsanity, TUNING.WX78_MAXSANITY_BOOST))
			elseif prefab=="wx78module_music" then
				cn("sanity", round2(TUNING.WX78_MUSIC_SANITYAURA * 60, 1))
				cn("other_tag", "wx78_music")
			elseif prefab=="wx78module_heat" then
				table.insert(desc_table, "@"..string.format(o_t.wx78_hot_cold, "+"..(TUNING.WX78_PERISH_HOTRATE-1)*100).."%")
				cn("other_tag", "wx78_moisture")
				cn("other_tag", "wx78_heat")
			elseif prefab=="wx78module_cold" then
				table.insert(desc_table, "@"..string.format(o_t.wx78_hot_cold, (TUNING.WX78_PERISH_COLDRATE-1)*100).."%")
				table.insert(desc_table, "@"..string.format(o_t.wx78_cold3, TUNING.WX78_COLD_ICEMOISTURE.."%"))
				cn("other_tag", "wx78_cold")
			end
			--重生护符
			if (prefab == "ancient_amulet_red" or prefab == "amulet") and c.hauntable then
				cn("other_tag", "amulet")
			end
			--Charges: lightning rod / lamp
			if item.chargeleft and item.chargeleft > 0 then
				table.insert(desc_table, "@"..o_t.will_other..tostring(math.floor(item.chargeleft+0.5))..SHOWME_STRINGS.days) --避雷针
			end
			if show_fuel ~= false and c.fuel ~= nil then	--燃料信息
				table.insert(desc_table, "@"..o_t.ot_fuelval..DataTimerFn(c.fuel.fuelvalue))
			end
			--Mod support:
			if item.GetShowItemInfo then
				local custom1, custom2, custom3 = item:GetShowItemInfo(viewer)
				if custom1 then table.insert(desc_table, "@"..tostring(custom1)) end
				if custom2 then table.insert(desc_table, "@"..tostring(custom2)) end
				if custom3 then table.insert(desc_table, "@"..tostring(custom3)) end
			end
			if c.pickable and c.pickable.task then --草和树苗
				local targettime = c.pickable.targettime
				if targettime then
					local delta = targettime - GetTime()
					if delta > 0 then
						cn("grow_in",round2(delta/TUNING.TOTAL_DAY_TIME,1)) --days
					end
				end
			end
			--可采摘次数
			if c.pickable and c.pickable.transplanted and c.pickable.cycles_left ~= nil and c.pickable.max_cycles ~= nil then
				table.insert(desc_table, "@"..o_t.ot_pickable..c.pickable.cycles_left.." / "..c.pickable.max_cycles)
			end
			--种植的幼苗，一般用在旧农场
			if c.crop and c.crop.product_prefab and c.crop.product_prefab and c.crop.growthpercent
					and type(c.crop.growthpercent) == 'number' and c.crop.growthpercent < 1
			then
				--作物的生长百分比
				cn("crop",c.crop.product_prefab,round2(c.crop.growthpercent*100,0))
			end
			--c.unwrappable.itemdata[1].prefab
			--c.unwrappable.itemdata[1].data.perishable.time - оставшееся время порчи в секундах.
			--	   .stackable.stack - количество
			if show_buddle_item == 1 and c.unwrappable and c.unwrappable.itemdata and type(c.unwrappable.itemdata) == 'table' then
				--包裹信息？？每样一行
				for i,v in ipairs(c.unwrappable.itemdata) do
					if v.prefab then
						--发送预制件的名称和天数。
						local delta = v.data and v.data.perishable and v.data.perishable.time
						local count = v.data and v.data.stackable and v.data.stackable.stack
						cn('perish_product', v.prefab, count or 0, delta and round2(delta/TUNING.TOTAL_DAY_TIME,1))
					end
				end
			end
			--"Pickle It!" 模组
			if c.pickler and c.pickler.targettime then
				local delta = c.pickler.targettime - GetTime()
				cn('just_time', round2(delta/TUNING.TOTAL_DAY_TIME,1))
			end
			--“Thirst”模组，检查“cwater”组件
			if c.cwater then
				local w = c.cwater
				if w.current and w.max then
					cn('water',round2(w.current,0),round2(w.max,0))
				end
				if w.waterperdrink and type(w.waterperdrink)=="number" and w.waterperdrink ~= 0 then
					cn("sip",round2(w.waterperdrink,0))
				end
				if w.watergainspeed and type(w.watergainspeed)=="number" and w.watergainspeed ~= 0 then
					cn("watergainspeed",round2(w.watergainspeed,0))
				end
				if w.poisoned then
					cn("water_poisoned")
				end
			end
			if c.friendlevels then	--好感度
				cn("friendlevels",round2(c.friendlevels.level,0))
			end
			--Stress points 新版耕地农作物状态显示
			local TS_crop = GetModConfigData("T_crop")
			if TS_crop then
				if c.farmplantstress and c.farmplantstress.stress_points then
					cn("stress",c.farmplantstress.stress_points)
					if c.farmplantstress.stressors_testfns then
						for k,fn in pairs(c.farmplantstress.stressors_testfns) do
							if k == 'happiness' then
								if c.farmplantstress.stressors and c.farmplantstress.stressors.happiness then
									cn("stress_tag",k)
								end
							else
								local bool = fn(item,k,false)
								if bool then
									cn("stress_tag",k)
								end
							end
						end
					end
				end

				--棱镜已做显示, 则全部已废弃
				--[[local legion_c1, legion_c2 = c.perennialcrop, c.perennialcrop2
                local function legion_pc(inst)
                    --每次task_grow的周期,time_start乘time_mult, 周期越短长得越快
                    --总成长所需时间GetGrowTime() - (当前已成长时间time_grow - 成长周期time_start * 生长速度time_mult)
                    --DataTimerFn(GetTime() - (inst:GetGrowTime() - (inst.time_grow - inst.time_start * inst.time_mult)))
                    --DataTimerFn(GetTime() - ((inst:GetGrowTime() - inst.time_grow) / inst.time_mult))
                    local mult, lgpc_time1, lgpc_time2 = "", 0, 0
                    if inst.time_mult ~= nil and inst.time_mult > 0 then	--这个time_mult会为nil, 又参与乘除计算, 难绷
                        lgpc_time2 = tostring(round2(inst.time_mult,3))
                    else
                        lgpc_time2 = 1	--是nil就赋值1, 这样参与计算还不至于崩
                    end
                    if inst.time_grow ~= nil then
                        lgpc_time1 = inst:GetGrowTime() - inst.time_grow
                        if inst.pause_reason ~= nil or lgpc_time2 == 1 then	--pause_reason不为nil 或 time_mult 为 nil, 显示为 暂停成长
                            mult = ' ('..SHOWME_STRINGS.paused..')'
                        else
                            mult = ' ('..lgpc_time2..'x)'	--否则显示成长速度
                        end
                    else
                        mult = ' ('..SHOWME_STRINGS.stopped..')'	--当time_grow 为 nil 的时候，作物 停止成长
                        lgpc_time1 = inst:GetGrowTime() - 0
                    end

                    table.insert(desc_table, "@" .. SHOWME_STRINGS.jieduan .. "["..inst.stage.."/"..inst.stage_max.."]:  "	--o_t.grow_in
                        .. tostring(round2((lgpc_time1 / lgpc_time2) / TUNING.TOTAL_DAY_TIME + 0.1,1)) .. SHOWME_STRINGS.days .. mult)
                end

                if legion_c1 then  --子圭垄
                    legion_pc(legion_c1)

                    --压力计算
                    if legion_c1.stage_max and legion_c1.regrowstage and legion_c1.stage and legion_c1.stage < legion_c1.stage_max then
                        local lost = 0
                        local stagegrow_cur = legion_c1.stage - legion_c1.regrowstage
                        if stagegrow_cur < 0 then
                            stagegrow_cur = 0
                        end
                        local count_lostFN = function (n)
                            local count_lost = stagegrow_cur - n
                            if count_lost > 0 then
                                return count_lost
                            end
                            return 0
                        end
                        if legion_c1.num_moisture then
                            lost = lost + count_lostFN(legion_c1.num_moisture)
                        end
                        if legion_c1.num_nutrient then
                            lost = lost + count_lostFN(legion_c1.num_nutrient)
                        end
                        if legion_c1.num_tended then
                            lost = lost + count_lostFN(legion_c1.num_tended)
                        end
                        cn("stress", lost)
                    end
                    if legion_c1.pollinated then
                        cn("pollinated", legion_c1.pollinated)
                    end
                    if legion_c1.sickness > 0 then
                        cn("sickness", round2(legion_c1.sickness, 2))	--疏忽了，病害居然有无尽的小数
                    end

                    if legion_c1.nutrient and legion_c1.cost_nutrient then
                        if legion_c1.nutrient < legion_c1.cost_nutrient then
                            cn("stress_tag", "nutrients")
                        end
                    end
                    if legion_c1.Tendable and legion_c1:Tendable() == true then
                        cn("stress_tag", "happiness")
                    end
                    if not _G.TheWorld.state.israining and not _G.TheWorld.state.issnowing and (legion_c1.moisture and legion_c1.cost_moisture and legion_c1.moisture < legion_c1.cost_moisture) then
                        cn("stress_tag", "moisture")
                    end
                    if legion_c1.goodseasons and not legion_c1.goodseasons[_G.TheWorld.state.season] then
                        cn("stress_tag", "season")
                    end
                end
                --perennialcrop 2 异作
                if legion_c2 then
                    legion_pc(legion_c2)

                    if legion_c2.pollinated then
                        cn("pollinated", legion_c2.pollinated)
                    end
                    if legion_c2.infested > 0 then
                        cn("infested", round2(legion_c2.infested, 2))
                    end
                    if legion_c2.inst:HasTag("nognatinfest") then
                        cn("stress_tag", "withered")
                    else
                        if legion_c2.inst:HasTag("fertableall") then
                            cn("stress_tag", "nutrients")
                        end
                        if legion_c2.inst:HasTag("tendable_farmplant") then
                            cn("stress_tag", "happiness")
                        end
                        if legion_c2.inst:HasTag("needwater") then
                            cn("stress_tag", "moisture")
                        end
                    end
                end ]]--
				--棱镜农作物 END
			end		--农作物 END
		end
		--棱镜 子圭育
		--[[ if c.genetrans then  --他自带刷新机制?? 所有定时器到0依旧无法实时更新状态???
            local lg_y = c.genetrans
            local paused, lg_fast, lg_tup, lg_upx = "", "", "", 1
            if lg_y.energytime <= 0 or lg_y.seednum <= 0 then
                paused = ' ('..SHOWME_STRINGS.paused..')'
            end
            if lg_y.timedata_fast.now ~= nil then
                lg_fast= " ↓"
                lg_tup = " ↑"
                lg_upx = 2
            end

            if lg_y.energytime ~= nil then  --能量剩余
                string.sub(lg_y.energytime / 480, 1, 4)) --将时间格式化到1位小数
                string.gsub(string.format("%.1f", lg_y.energytime / TUNING.TOTAL_DAY_TIME),".0","")
                table.insert(desc_table, "@"..o_t.energytime .. tostring(round2(lg_y.energytime / TUNING.TOTAL_DAY_TIME,1)) .. SHOWME_STRINGS.days .. lg_fast .. paused)
            end

            if lg_y.seednum ~= nil and lg_y.seednum > 0 then  --正在转化
                table.insert(desc_table, "@"..o_t.seednum .. lg_y.seednum)
            end
            if lg_y.fruitnum ~= nil and lg_y.fruitnum > 0 then  --已转化
                table.insert(desc_table, "@"..o_t.fruitnum .. lg_y.fruitnum)
            end
            if lg_y.timedata.all ~= nil and lg_y.timedata.start ~=nil and lg_y.timedata.pass ~=nil then  -- +1 大约 0:00
                table.insert(desc_table, "@+1"..o_t._in .. DataTimerFn((lg_y.timedata.all - lg_y.timedata.pass) / lg_upx - (GetTime() - lg_y.timedata.start)).. lg_tup)
            end
        end
        if c.botanycontroller then  --botanycontroller 三个种菜装置
            -- local lg_cm = c.botanycontroller
            -- local lg_cmn1, lg_cmn2, lg_cmn3 = tostring(round2(lg_cm.nutrients[1],1)), tostring(round2(lg_cm.nutrients[2],1)), tostring(round2(lg_cm.nutrients[3],1))
            -- local lg_cmn = o_t.nutrients_1..lg_cmn1.." / "..o_t.nutrients_2..lg_cmn2.." / "..o_t.nutrients_3..lg_cmn3
            -- if lg_cm.type == 1 then  --利川
                -- if lg_cm.moisture then
                    -- table.insert(desc_table, "@"..o_t.moisture .. lg_cm.moisture)
                -- end
            -- elseif lg_cm.type == 2 then  --益矩
                -- if lg_cm.nutrients then
                    -- table.insert(desc_table, "@"..lg_cmn)
                -- end
            -- else  --崇溟
                -- if lg_cm.moisture then
                    -- table.insert(desc_table, "@"..o_t.moisture .. lg_cm.moisture)
                -- end
                -- if lg_cm.nutrients then
                    -- table.insert(desc_table, "@"..lg_cmn)
                -- end
            -- end
        -- end
        if item.healthcounter then	--子圭汲、歃
            table.insert(desc_table, "@"..o_t.siv_mask .. item.healthcounter .. " / ".. item.healthcounter_max)
        end
        if item.tradeditems then	--子圭巨岩、神木
            table.insert(desc_table, "@"..o_t.siv_light..item.tradeditems.light.." / "..o_t.siv_health..item.tradeditems.health)
        end
        if item.countHealth then
            table.insert(desc_table, "@"..o_t.siv_mask..tostring(round2(item.countHealth,2)))	--神木生命储存也会出现无数小数，截取到2位小数
        end
        if item._lvl_l ~= nil and c.upgradeable.numstages ~= nil then
            local lg_numstages = c.upgradeable.numstages - 1
            table.insert(desc_table, "@"..o_t.lg_moon..item._lvl_l:value().." / "..lg_numstages)
        end ]]--
		--棱镜END
		--buling
		if c.beerpower then
			local blb = c.beerpower
			if c.beerpower ~= nil then table.insert(desc_table, "@"..o_t.beerpowerpower.."< "..blb.power.." / "..blb.PowerMax.." >") end
		end
		if c.waterpower then
			local blw = c.waterpower
			if c.waterpower ~= nil then table.insert(desc_table, "@"..o_t.waterpowerpower.."< "..blw.power.." / "..blw.PowerMax.." >") end
		end

		if c.gaspower then
			local blg = c.gaspower
			if c.gaspower ~= nil then table.insert(desc_table, "@"..o_t.gaspowerpower.."< "..blg.power.." / "..blg.PowerMax.." >") end
		end
		--blend
		--生物巢,生物：6/6
		if c.childspawner then
			--local outside = tonumber(c.childspawner.numchildrenoutside) -- buggy (often +1 more)
			--local extra = tonumber(c.childspawner.maxemergencycommit) -- extra guards
			local inside = tonumber(c.childspawner.childreninside)
			local maximum = tonumber(c.childspawner.maxchildren)
			--print(inside, outside, maximum, extra)
			if inside and maximum then
				--if outside then
				--	outside = round2(outside,0)
				--end
				--cn("children",round2(inside,0),round2(maximum+(extra or 0),0),outside > 0.5 and outside or nil)
				cn("children",round2(inside,0),round2(maximum,0))
			end
			-- if prefab == "mermwatchtower" and c.childspawner:CountChildrenOutside() < 1 then
			-- table.insert(desc_table, "@ 鱼人房"..)
			-- end
		end

		--从武器信息看:
		if viewer and type(viewer)=="table" and viewer.components and viewer.components.inventory then
			local weapon = viewer.components.inventory:GetEquippedItem(_G.EQUIPSLOTS.HANDS)
			if weapon then
				local resist = nil --base resist
				local total_resist = nil --base + bonus resist
				local now = nil --amount of current resist
				if weapon.prefab=="icestaff" and c.freezable then
					resist = c.freezable.resistance
					total_resist = c.freezable.ResolveResistance and c.freezable:ResolveResistance() or resist
					if c.freezable.coldness and c.freezable.coldness ~= 0 then
						now = round2(total_resist - c.freezable.coldness,1)
					end
					--cn("resist",c.freezable.resistance)
				elseif (weapon.prefab=="blowdart_sleep" or weapon.prefab=="panflute") and c.sleeper then
					resist = c.sleeper.resistance
					total_resist = resist -- there is sleep time bonus but not sleep armor bonus
					if c.sleeper.sleepiness and c.sleeper.sleepiness ~= 0 then
						now = round2(total_resist - c.sleeper.sleepiness,1)
					end
					--cn("resist",c.sleeper.resistance)
				end
				if resist then
					if total_resist ~= resist then
						resist = resist .. '+' .. round2(math.abs(total_resist-resist),1)
					end
					if now then
						resist = now .. ' / ' .. resist
					end
					cn("resist",resist)
				end
			end
		end
		if item.inlove and item.inlove>0 then
			if prefab=="chester" then
				cn("love",item.inlove/10)
			else
				cn("love",item.inlove)
			end
		end
		--Additional
		if c.timer and c.timer.timers then
			--local get_time = GetTime()
			local t = c.timer
			for name, data in pairs(t.timers) do
				if not IsUselessTimer(prefab,name) then
					--GetTimeLeft(name) IsPaused
					local tm = t:GetTimeLeft(name)
					local paused = t:IsPaused(name)
					if tm then
						if item:HasTag("critter") then
							return
						end
						cn('timer', round2(tm,0), name, paused and 1 or nil)
					else
						cn('timer', "-", name)
					end
				end
			end
		end
		--预计：
		if c.worldsettingstimer and c.worldsettingstimer.timers and not (prefab == "grass" and c.pickable.transplanted) then --transplanted 可移植的
			--local get_time = GetTime()
			local t = c.worldsettingstimer
			for name, data in pairs(t.timers) do
				if not IsUselessTimer(prefab,name) then
					--IsPaused GetMaxTime TimerEnabled GetTimeLeft
					local tm = t:GetTimeLeft(name)
					local paused = t:IsPaused(name)
					if tm then
						cn('timer', round2(tm,0), name, paused and 1 or nil)
					elseif t.GetMaxTime then
						local max_tm = t:GetMaxTime(name)
						if max_tm then
							cn('timer', round2(data.maxtime,0), name, 2)
						end
					else
						cn('timer', "-", name)
					end
				end
			end
		end
		--[[
        if prefab=="chester" then
            local name = name_by_id(self.inst.userid)
            desc = (desc=="" and "" or (desc.."\n")).."Owner: "..name
                .."\nuserid="..tostring(self.inst.userid)
                .."\nLeader: "..tostring(c.follower.leader)
            has_owner = true
        end
        if prefab=="chester_eyebone" then
            local name = name_by_id(self.inst.userid)
            desc = (desc=="" and "" or (desc.."\n")).."Owner: "..name
                .."\nuserid="..tostring(self.inst.userid)
            has_owner = true
        end
        --]]
		--print("GetTestString: "..tostring(item)..", "..tostring(viewer)..", "..tostring(desc))
		--for i=1,line_cnt do
		--	desc = desc .. "\n" --Поднимаем описание предмета, чтобы оно было НАД предметом. Но лучше это сделать на клиенте.
		--end

		return table.concat(desc_table,"\2") --an error with no info
	end

	--Main description function
	--[[
    AddComponentPostInit("inspectable", function(inst)
        local oldGetDesc = inst.GetDescription
        function inst:GetDescription(viewer)
            local desc = oldGetDesc(self,viewer)
            if self.inst and self.inst.components then
                local item = self.inst
                if type(desc)~="string" then
                    desc=""
                end
                local desc = GetTestString(item,viewer,desc)
            end
            return desc
        end
    end)
    --]]

	--[[
    AddPrefabPostInit("wes",function(wes)
        if wes.components and wes.components.talker then
            local oldSay = wes.components.talker.Say
            function wes.components.talker:Say(script, time, noanim)
                local test=type(script)=="string" and string.match(script,"([0-9]+ / [0-9]+)$") or ""
                if test then
                    script=test
                else
                    script=""
                end
                oldSay(self, script, time, noanim)
            end
            wes.components.talker.special_speech = false
        end
    end)

    GetGlobal("fol",function()

    end)
    --]]


end

----------------------------WeGame有在维护，请勿搬运，为避免出现多个相同模组----------------------------
------------------------------------------- HOST & CLIENT AGAIN ---------------------------------------------

local FindUpvalue = function(fn, upvalue_name, member_check, no_print, newval)
	local info = _G.debug.getinfo(fn, "u")
	local nups = info and info.nups
	if not nups then return end
	local getupvalue = _G.debug.getupvalue
	local s = ''
	--print("FIND "..upvalue_name.."; nups = "..nups)
	for i = 1, nups do
		local name, val = getupvalue(fn, i)
		s = s .. "\t" .. name .. ": " .. type(val) .. "\n"
		if (name == upvalue_name)
				and ((not member_check) or (type(val)=="table" and val[member_check] ~= nil)) --Надежная проверка
		then
			--print(s.."FOUND "..tostring(val))
			if newval ~= nil then
				_G.debug.setupvalue(fn, i, newval)
			end
			return val, true
		end
	end
	if no_print == nil then
		print("CRITICAL ERROR: Can't find variable "..tostring(upvalue_name).."!")
		print(s)
	end
end

--为玩家添加一个提示，通过该提示将发送数据（在项目名称下弹出带有信息的文本）
do
	--如果该函数与发送的信息（在player_classified中）完全匹配，则返回一个提示。
	--返回一个提示，要么是 ""。
	local function CheckUserHint(inst)
		local c = _G.ThePlayer and _G.ThePlayer.player_classified
		if c == nil then --没有本地玩家或 classified
			return ""
		end
		--c.showme_hint
		local i = string.find(c.showme_hint2,';',1,true)
		if i == nil then --字符串格式不正确情况下
			return ""
		end
		local guid = _G.tonumber(c.showme_hint2:sub(1,i-1))
		if guid ~= inst.GUID then --guid不匹配 (或nil情况下)
			return ""
		end
		return c.showme_hint2:sub(i+1)
	end
	if CLIENT_SIDE then
		--patching Get Display Name. Нужно только клиенту.
		--[[local old_GetDisplayName = _G.EntityScript.GetDisplayName
		_G.EntityScript.GetDisplayName = function(self)
			local old_name = old_GetDisplayName(self)
			if type(old_name) ~= "string" then
				return old_name
			end
			local str2 = CheckUserHint(self)
			return old_name .. str2
		end--]]

		--让我们看一下需要发送有关鼠标下的对象的 guid 的情况。
		local old_inst --我们记住不要多次向同一个inst发送无用信息
		--[[AddWorldPostInit(function(w)
			w:DoPeriodicTask(0.1,function(w)
				if _G.ThePlayer == nil then
					return
				end
				local inst = _G.TheInput:GetWorldEntityUnderMouse()
				if inst ~= nil then
					if inst == old_inst then
						return
					end
					old_inst = inst
					--Посылаем желаемую подсказку.
					SendModRPCToServer(MOD_RPC.ShowMeSHint.Hint, inst.GUID, inst)
				end
			end)
		end)--]]

		local function UnpackData(str,div)
			local pos,arr = 0,{}
			-- for each divider found
			for st,sp in function() return string.find(str,div,pos,true) end do
				table.insert(arr,string.sub(str,pos,st-1)) -- 在当前分隔符左侧附加字符
				pos = sp + 1 -- Jump past current divider
			end
			table.insert(arr,string.sub(str,pos)) -- 在最后一个分隔符右侧附加字符
			return arr
		end

		local save_target
		local last_check_time = 0 --最后一次查看时间, 每 2 秒过期一次。
		local LOCAL_STRING_CACHE = {} --字符串的表，以免每次都计算替换（虽然会耗点内存）
		AddClassPostConstruct("widgets/hoverer",function(hoverer) --hoverer=self
			local old_SetString = hoverer.text.SetString
			local _debug_info = ''
			local NEWLINES_SHIFT = {
				'', --无信息
				'', -- 1 条信息
				'', -- 2 条信息
				'\n ',
			}
			local function InitNewLinesShift(idx)
				local str = NEWLINES_SHIFT[idx]
				if str then
					return str
				end
				str = '\n' .. InitNewLinesShift(idx-1)
				NEWLINES_SHIFT[idx] = str
				return str
			end
			hoverer.text.SetString = function(text,str) --text=self
				--print(tostring(str))
				text.cnt_lines = nil
				local target = _G.TheInput:GetHUDEntityUnderMouse()
				if target ~= nil then
					--target.widget.parent -- 这是项目图层
					--target = target.widget ~= nil and target.widget.parent ~= nil and target.widget.parent.item --实体物品（在客户端）

					-- local tar = target.widget ~= nil and target.widget.parent ~= nil and target.widget.parent.item
					-- if tar ~= nil then	--多加一层判断
					-- target = tar
					-- else	--获取深一层的图层，奔雷矛多了一层parent
					-- target = target.widget ~= nil and target.widget.parent ~= nil and target.widget.parent.parent ~= nil and target.widget.parent.parent.item
					-- end
					--使用递归以免以后有N层parent
					local function par(w)
						return w.parent and (w.parent.item or par(w.parent)) or nil
					end
					target = target.widget ~= nil and par(target.widget)
				else
					target = _G.TheInput:GetWorldEntityUnderMouse()
				end
				if type(target) ~= "table" or not target.GUID then
					target = nil
				end
				--local lmb = hoverer.owner.components.playercontroller:GetLeftMouseAction()
				if target ~= nil then
					--print(tostring(target))
					--检查数据是否匹配。
					local str2 = CheckUserHint(target)
					if str2 ~= "" then
						--首先清除旧行到新行的过渡，因为你永远不知道添加了什么样的模组。
						local cnt_newlines, _ = 0 --计算行末尾的行转换（DFV 兼容）
						while cnt_newlines < #str do
							local ch = str:sub(#str-cnt_newlines,#str-cnt_newlines)
							if ch ~= "\n" and ch ~= " " then
								break
							end
							cnt_newlines = cnt_newlines + 1
						end
						--清除该行的废弃信息
						if cnt_newlines > 0 then
							str = str:sub(1,#str-cnt_newlines)
						end
						--print(#str,"clear")
						--清除线路中间废弃信息
						if string.find(str,"\n\n",1,true) ~= nil then
							str = str:gsub("[\n]+","\n")
						end

						if string.find(str,"\n",1,true) ~= nil then
							_,cnt_newlines = str:gsub("\n","\n") --计算内部的转换数量（如果有的话）
						else
							cnt_newlines = 0
						end


						--从生成的打包字符串中提取数据。
						str2 = UnpackData(str2,"\2")
						local arr2 = {} --以易于理解的形式形成一组数据。
						for i,v in ipairs(str2) do
							if v ~= "" then
								local param_str = v:sub(2)
								local data = { param = UnpackData(param_str,","), param_str=param_str }
								local my_s = MY_STRINGS[decodeFirstSymbol(v:sub(1,1))]; -- if "@", must pass nil
								if my_s ~= nil then
									data.data = MY_DATA[my_s.key]
								end
								table.insert(arr2,data)
							end
						end
						arr2.str2= str2
						--_G.rawset(_G,"arr2",arr2) --测试
						--形成一个字符串
						for i=#arr2,1,-1 do
							local v = arr2[i]
							if v.data ~= nil then
								if v.data.hidden == nil then
									if v.data.fn ~= nil then
										arr2[i] = v.data.fn(v)
									else
										arr2[i] = DefaultDisplayFn(v)
									end
								else
									table.remove(arr2,i)
								end
							else
								arr2[i] = DefaultDisplayFn(v)
							end
						end
						--table.insert(arr2,"xxxxx")
						--table.insert(arr2,"xyz")
						--table.insert(arr2,"aaabbbccc")
						--table.insert(arr2,"dddddd123")
						str2 = table.concat(arr2,'\n')

						--_G.arr({inst=text.inst,hover=text.parent},5)
						--print("-----"..str.."-----")
						--local sss=""
						--for i=#str,#str-10,-1 do
						--	sss=sss..string.byte(str:sub(i,i))..", "
						--end
						--print("Chars: "..sss)
						--[[print(#str,"cut str")
						--В конце тоже убираем переход, если есть.
						if str:sub(#str,#str) == "\n" then
							str = str:sub(1,#str-1)
						end--]]
						--print(#str,"test cache")
						--print("count new cache")
						--print("newlines",#str2)

						--str2 = str2 .. _debug_info
						--local scale = text:GetScale()
						--str2 = str2 .. 'scale = ' .. scale.x .. ';' .. scale.y .. '\n'
						--local scr_w, scr_h = TheSim:GetScreenSize()
						--str2 = str2 .. scr_w .. 'x' .. scr_h .. '\n'

						text.cnt_lines = cnt_newlines + #arr2 + 1


						str = str .. '\n' .. str2 .. (NEWLINES_SHIFT[text.cnt_lines] or InitNewLinesShift(text.cnt_lines))
					end
					--print("Check User Hint: "..str2)
					--如果这是第一次，那么会发送请求。
					if target ~= save_target or last_check_time + 1 < GetTime() then
						save_target = target
						last_check_time = GetTime()
						SendModRPCToServer(MOD_RPC.ShowMeSHint.Hint, save_target.GUID, save_target)		--客户端向服务器发送请求的RPC
					end
				else
					--print("target nil")
				end
				return old_SetString(text,str)
			end
			--FindUpvalue(hoverer.UpdatePosition, "YOFFSETUP", 150)
			--FindUpvalue(hoverer.UpdatePosition, "YOFFSETDOWN", 120)

			local XOFFSET = 10

			hoverer.UpdatePosition = function(self,x,y)
				local YOFFSETDOWN = 10
				local cnt_lines = self.text and self.text.cnt_lines
				if cnt_lines then
					local extra = cnt_lines - 3
					if extra > 0 then
						YOFFSETDOWN = YOFFSETDOWN - extra * 30
					end
				end


				local scale = self:GetScale()
				local scr_w, scr_h = _G.TheSim:GetScreenSize()
				local w = 0
				local h = 0

				--_debug_info='x='..x..'; y='..y..'\n' .. 'YOFFSETDOWN = ' .. YOFFSETDOWN .. ';' ..tostring(self.text.cnt_lines) .. '\n';

				if self.text ~= nil and self.str ~= nil then
					local w0, h0 = self.text:GetRegionSize()
					w = math.max(w, w0)
					h = math.max(h, h0)
					--_debug_info=_debug_info..'w0='..w0..'; h0='..h0..'\n'
				end
				if self.secondarytext ~= nil and self.secondarystr ~= nil then
					local w1, h1 = self.secondarytext:GetRegionSize()
					w = math.max(w, w1)
					h = math.max(h, h1)
					--_debug_info=_debug_info..'w1='..w1..'; h1='..h1..'\n'
				end

				w = w * scale.x * .5
				h = h * scale.y * .5
				--_debug_info=_debug_info..'w='..w..'; h='..h..'\n'
				--y=y+h

				--_debug_info=_debug_info..'cx='..math.clamp(x, w + XOFFSET, scr_w - w - XOFFSET)..'; cy='..math.clamp(y, h + YOFFSETDOWN * scale.y, scr_h - h - (-80) * scale.y)..'\n'
				self:SetPosition(
						math.clamp(x, XOFFSET + w, scr_w - w - XOFFSET),
						math.clamp(y, YOFFSETDOWN + h, scr_h + 9999),
						0)
			end


		end)
	end

	--服务器上的处理程序
	AddModRPCHandler("ShowMeSHint", "Hint", function(player, guid, item)	--服务器RPC执行客户端发来的请求
		if player.player_classified == nil then
			print("ERROR: player_classified not found!")
			return
		end
		if item ~= nil and item.components ~= nil then
			local s = GetTestString(item,player) --在服务器上形成一个字符串。
			if s and s ~= "" then
				player.player_classified.net_showme_hint2:set(tostring(guid)..";"..s) --将其打包成一行并将其发送回同一玩家
			end
		end
	end)

	--联网
	-- showme_hint2 => "showme_hintbua." -- hash value: 78865, Ratio: 0.000078865
	AddPrefabPostInit("player_classified",function(inst)
		inst.showme_hint2 = ""
		inst.net_showme_hint2 = _G.net_string(inst.GUID, "showme_hintbua.", "showme_hint_dirty2")
		if CLIENT_SIDE then
			inst:ListenForEvent("showme_hint_dirty2",function(inst)
				inst.showme_hint2 = inst.net_showme_hint2:value()
			end)
		end
	end)
end

--处理箱子模块
--do
--	local MAIN_VAR_NAME = 'net_ShowMe_chest';
--	local NETVAR_NAME = 'ShowMe_chestlq_.'; -- hash value: 983115,  Ratio: 0.000983115
--	local EVENT_NAME = 'ShowMe_chest_dirty';
--	--[[
--	--致模组开发者: 你的模组容器可使用以下代码，实现与ShowMe联动容器高亮。	--源开发者 Star 留
--		TUNING.MONITOR_CHESTS = TUNING.MONITOR_CHESTS or {}
--		TUNING.MONITOR_CHESTS.chestprefab = true	-- chestprefab 即你的容器代码名称
--
--	--多容器模式, 优先级高低判断可同时加上
--	--优先级高于 ShowMe
--		TUNING.MONITOR_CHESTS = TUNING.MONITOR_CHESTS or {}
--		for _, v in ipairs(容器列表) do
--			TUNING.MONITOR_CHESTS[v] = true
--		end
--
--	--优先级低于 ShowMe
--		for k, m in pairs(ModManager.mods) do
--			if m and _G.rawget(m, "SHOWME_STRINGS") then
--				if m.postinitfns and m.postinitfns.PrefabPostInit and m.postinitfns.PrefabPostInit.treasurechest then
--					for _,v in ipairs(容器列表) do
--						m.postinitfns.PrefabPostInit[v] = m.postinitfns.PrefabPostInit.treasurechest
--					end
--				end
--				break
--			end
--		end
--	--]]
--	--拿起物品箱子颜色显示的容器列表
--	local MONITOR_CHESTS = { treasurechest=1, dragonflychest=1, pandoraschest=1, minotaurchest=1, --skullchest=1,
--		--bundle=1, --No container component. =\
--							 icebox=1, cookpot=1, -- 冰箱、烹饪锅.
--							 chester=1, hutch=1, beargerfur_sack=1,  --小妾、哈奇、极地熊灌桶
--							 largechest=1, largeicebox=1, bookstation=1, wardrobe=1, --暗妾(已失效)、冰妾、书架、衣柜.
--							 safebox=1, safechest=1, safeicebox=1, --Safe mod.
--							 red_treasure_chest=1, purple_treasure_chest=1, green_treasure_chest=1, blue_treasure_chest=1, --Treasure Chests mod.
--							 backpack=1, candybag=1, icepack=1, piggyback=1, krampus_sack=1, seedpouch=1, spicepack=1,
--							 venus_icebox=1, chesterchest=1, --SL mod
--							 saltbox=1, wobybig=1, wobysmall=1, mushroom_light=1, mushroom_light2=1, fish_box=1, supertacklecontainer=1, tacklecontainer=1, archive_cookpot=1,
--							 portablecookpot=1, portablespicer=1, sacred_chest=1, boat_ancient_container=1, --便携锅, 香料站, 远古箱, 古董船
--							 storeroom=1, alchmy_fur=1, myth_granary=1, hiddenmoonlight=1, coffin=1, grave=1, musha_rpice=1, musha_tallrrrrrice=1, musha_tallrrrrice=1, musha_tallrrrice=1, hiddenmoonlight_inf=1, chest_whitewood_inf=1, chest_whitewood_big_inf=1, --pill_bottle_gourd=1, --丹药葫芦会崩 神话代码加密 无解
--							 ro_bin=1, roottrunk_child=1, corkchest=1, smelter=1, --Hamlet
--							 thatchpack=1, packim=1, cargoboat=1, piratepack=1, --SW
--	}
--	if TUNING.MONITOR_CHESTS then
--		for k in pairs(TUNING.MONITOR_CHESTS) do
--			MONITOR_CHESTS[k] = 1
--		end
--	end
--	local _active --光标中的当前项目（在客户端上）。
--	local _ing_prefab --成分，5 秒后将其移除。
--	local net_string = _G.net_string
--	local chests_around = {} --客户端可见范围内的所有箱子的数组。 对于主机来说——都是箱子，但这很正常。
--
--	--[[
--	_G.showme_count_chests = function() --debug function
--		local cnt = 0
--		for k,v in pairs(chests_around) do
--			cnt = cnt + 1
--		end
--		print('Chests around:',cnt)
--	end
--	--]]
--
--	local function OnClose(inst) --,err) --关闭箱子时，我们会向客户端发送有关其内容的新数据。
--		local c = inst.components.container
--		if not c then
--			--[[if type(err) ~= "number" then err=nil end
--			print('ERROR ShowMe: in ',inst.prefab,err)
--			if not err then
--				if inst.components then
--					print("\tComponents:")
--					for k in pairs(inst.components) do
--						print("\t\t"..tostring(k))
--					end
--				else
--					print("\tNo components at all!")
--				end
--			end
--			if not err or err < 2000 then
--				inst:DoTaskInTime(0,function(inst)
--					OnClose(inst,err and (err+1) or 1)
--				end)
--			end--]]
--			return
--		end
--		--if err then
--		--	print("Found!!!!! Problem solved",err)
--		--end
--		if c:IsEmpty() then
--			inst[MAIN_VAR_NAME]:set('')
--			return
--		end
--		local arr = {} -- [预制件]=true
--		--[[ Отрывок из предыдущего сочинения (чтобы знать, что там происходит):
--		if c.unwrappable and c.unwrappable.itemdata and type(c.unwrappable.itemdata) == 'table' then
--			--По одной строке на каждый предмет.
--			for i,v in ipairs(c.unwrappable.itemdata) do
--				if v.prefab then
--					--Пересылаем название префаба и количество дней.
--					local delta = v.data and v.data.perishable and v.data.perishable.time
--					local count = v.data and v.data.stackable and v.data.stackable.stack
--					cn('perish_product', v.prefab, count or 0, delta and round2(delta/TUNING.TOTAL_DAY_TIME,1))
--				end
--			end
--		end--]]
--		for k,v in pairs(c.slots) do
--			arr[tostring(v.prefab)] = true
--			local u = v.components and v.components.unwrappable
--			if u and u.itemdata then
--				for i,v in ipairs(u.itemdata) do
--					arr[v.prefab] = true --将预制件添加到包中。
--				end
--			end
--		end
--		local s
--		for k in pairs(arr) do
--			if s then
--				s = s .. ' ' .. k --只有空白字符才可以继续工作。
--			else
--				s = k
--			end
--		end
--		inst[MAIN_VAR_NAME]:set(s) --发送数据
--	end
--
--	--更新箱子高亮，该功能本身必须识别玩家手中的东西。
--	local function UpdateChestColor(inst)
--		local in_container = inst.ShowMe_chest_table and (
--				(_active and inst.ShowMe_chest_table[_active.prefab])
--						or (_ing_prefab and inst.ShowMe_chest_table[_ing_prefab])
--		)
--		if inst.b_ShowMe_changed_color then
--			if not in_container then
--				if inst.ShowMeColor then
--					inst.ShowMeColor(true)
--				else
--					if inst.AnimState ~= nil then
--						inst.AnimState:SetMultColour(1,1,1,1) --默认颜色RGBA
--						inst.AnimState:SetLightOverride(0)
--					end
--					inst.b_ShowMe_changed_color = nil
--				end
--			end
--		else
--			if in_container then
--				if inst.ShowMeColor then
--					inst.ShowMeColor(false)
--				else
--					if inst.AnimState ~= nil then
--						inst.AnimState:SetMultColour(chestR,chestG,chestB,1)
--						inst.AnimState:SetLightOverride(.5)		--给箱子添加光覆盖，让夜间也能看清，50%亮度可以在月圆或去色夜空中还能有显示
--					end
--					inst.b_ShowMe_changed_color = true
--				end
--			end
--		end
--	end
--
--	local function OnShowMeChestDirty(inst)
--		--inst.components.HuntGameLogic.hunt_kills = inst.components.HuntGameLogic.net_hunt_kills:value()
--		local str = inst[MAIN_VAR_NAME]:value()
--		--inst.test_str = str --test
--		--print('Test Chest:',str)
--		local t = inst.ShowMe_chest_table
--		for k in pairs(t) do
--			t[k] = nil
--		end
--		for w in string.gmatch(str, "%S+") do
--			t[w] = true
--		end
--		UpdateChestColor(inst) --如果其内容发生变化，则重新绘制该特定箱子。
--	end
--
--	local function InitChest(inst)
--		inst[MAIN_VAR_NAME] = net_string(inst.GUID, NETVAR_NAME, EVENT_NAME )
--		if CLIENT_SIDE then
--			inst:ListenForEvent(EVENT_NAME, OnShowMeChestDirty)
--			chests_around[inst] = true
--			inst.ShowMe_chest_table = {}
--			--inst.ShowTable = function() for k in pairs(inst.ShowMe_chest_table) do print(k) end end --debug
--			inst:ListenForEvent('onremove', function(inst)
--				chests_around[inst] = nil
--			end)
--		end
--		if not SERVER_SIDE then
--			return
--		end
--		inst:ListenForEvent("onclose", OnClose)
--		inst:ListenForEvent("itemget", OnClose) --用于背包
--		--There is inject in SmarterCrockPot!! : ContainerWidget.old_on_item_lose = ContainerWidget.OnItemLose
--		inst:ListenForEvent("itemlose", OnClose)
--		inst:DoTaskInTime(0,function(inst)
--			OnClose(inst) --不仅仅只在关闭时发送数据，毕竟箱子本来可以装东西的。
--		end)
--	end
--
--	for k in pairs(MONITOR_CHESTS) do	--添加API
--		AddPrefabPostInit(k,InitChest)
--	end
--	--Фиксим игрока, чтобы мониторить действия курсора.
--	if CLIENT_SIDE then
--		local function UpdateAllChestsAround()
--			for k in pairs(chests_around) do
--				UpdateChestColor(k)
--			end
--		end
--		AddPrefabPostInit("inventory_classified",function(inst)
--			inst:ListenForEvent("activedirty", function(inst)
--				--print("ACTIVE:",inst._active:value())
--				_active = inst._active:value()
--				_ing_prefab = nil --Если взят предмет, то рецепт сразу же забываем.
--				UpdateAllChestsAround() --会为每个活动物品或其取消的物品重新绘制所有箱子。
--			end)
--		end)
--
--		local _ing_task
--		local function UpdateIngredientView(player, prefab)
--			_ing_prefab = prefab
--			UpdateAllChestsAround()
--			if _ing_task then
--				_ing_task:Cancel()
--			end
--			_ing_task = player:DoTaskInTime(15,function(inst)
--				_ing_prefab = nil
--				_ing_task = nil
--				UpdateAllChestsAround()
--			end)
--		end
--
--		local ingredientui = _G.require 'widgets/ingredientui'
--		local old_OnGainFocus = ingredientui.OnGainFocus
--
--		function ingredientui:OnGainFocus(...)
--			--print("self.ing.texture:", self.ing.texture, type(self.ing.texture))
--			--从 self.ing.texture 中提取文件名，并去掉 .tex 扩展名
--			--'[^/]+$' 是一个正则表达式，它的含义是：
--			--[^/]: 匹配除了 / 之外的任意字符。
--			--+: 匹配前面的模式（[^/]）一次或多次。
--			--$: 匹配字符串的末尾，就是文件名（包括扩展名）。
--			--'%.tex$' 是一个正则表达式，它的含义是：
--			--%.: 匹配一个点（.），因为 . 在正则表达式中有特殊含义，所以需要用 % 转义。
--			--tex: 匹配字符串 tex。
--			--$: 匹配字符串的末尾，gsub('%.tex$', '')是将匹配的.tex转换为空字符串''
--			local prefab
--			if self.ing and self.ing.texture and type(self.ing.texture) == "string" then
--				prefab = self.ing.texture:match('[^/]+$'):gsub('%.tex$', '')
--			end
--			--处理多层parent
--			local function gfpar(obj, visited)
--				visited = visited or {}  -- 初始化访问记录表
--				if not obj then
--					return nil	--如果 obj 是 nil，表示已经到达链的末尾，返回 nil
--				end
--				if visited[obj] then
--					return nil  -- 如果已经访问过该对象，避免循环
--				end
--				visited[obj] = true  -- 标记当前对象为已访问
--				if obj.owner then
--					return obj.owner	--如果 obj.owner 存在，直接返回 owner
--				end
--				return gfpar(obj.parent, visited)  -- 如果没找到owner，则继续递归查找
--			end
--
--			-- 使用递归函数, 通过 gfpar(self) 从当前对象 self 开始查找 owner
--			local player = gfpar(self)
--
--			if prefab and player then
--				--print("INGREDIENT:",prefab)
--				UpdateIngredientView(player,prefab)
--			end
--			if old_OnGainFocus then
--				return old_OnGainFocus(self, ...)
--			end
--		end
--	end
--end
----------------------------------------
if GetModConfigData("Show_range") ~= false then		--显示范围加载的文件，客户端
	modimport("scripts/showme_range_indicators.lua")
end

if GetModConfigData("Show_naughtiness") ~= false then	--显示顽皮值加载的文件，服务端
	modimport("scripts/showme_naughtiness.lua")
end
