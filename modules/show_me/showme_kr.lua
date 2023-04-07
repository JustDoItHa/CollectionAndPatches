MY_STRINGS_OVERRIDE = {
	hp="체력:", --for characters
	health="체력:", --for food
	hunger="배고픔:",
	sanity="정신력:",
	sec="남은 시간:",
	armor="보호율:",
	dmg="공격력:",
	warm="따뜻함:",
	fuel="연료:",
	range="사거리:",
	speed="속도:",
	resist="저항성:",
	power="파워:",
	loyal="충성 시간:",
	love="호감도:",
	heal="체력:",
	kills="죽인 수:",
	kill="살해:",
	fishes="생선 수:",
	fish="생선 수:",
	owner="주인:",
	thickness="두께:",
	waterproof="방수율:",
	aggro="악행 지수:",
	summer="시원함:",
	absorb="총 보호율:",
	obedience="충성도:",
	perish="썩기까지",
	electric = "전기:" ,
	S2="여름이 오기까지",
	S4="겨울이 오기까지" , 
	remaining_days = "남은 일수:" ,
	S3="가을이 오기까지" ,
	is_admin = "그는 관리자야!\n지금 게임에 있지 않아.\n그러니까 건들면 안 돼." ,
	armor_character = "보호율:" ,
	sanity_character = "정신력:" ,
	S1="봄이 오기까지" , 
	dmg_character = "공격력:" ,
	cooldown = "쿨타임:",
    domest = "길들임:", -- "Domestication:"
    will_die = "죽기까지",
    will_dry = "마르기까지",
    dmg_bonus = "추가 공격력:",
    grow_in = "자라기까지",
	water = "물:",
	salt = "소금:",
	sip = "Sip:",
	watergainspeed = "Water gain speed:",
	water_poisoned = "물 중독!",
	timer = "Timer",
	trade_gold = "금으로의 가치:",
	trade_rock = "돌로의 가치:",
	durability = '내구도:',
	strength = '공격력:',
	--aoe = 'AoE:',
	stress = 'Stress:',
}

SHOWME_STRINGS = {
	loyal = "로얄",
	of = " OF ",
	units_1 = "1개의 ",
	units_many = "개의 ",
	days = "일", --Spoil in N days.
	temperature = 't',
	
	_in = ': ',
}

FOOD_TAGS = { --"dried" and "precook" are excluded.
	veggie = "야채",
	fruit = "과일",
	monster = "괴물",
	sweetener = "감미료",
	meat = "고기",
	fish = "생선",
	magic = "마법",
	egg = "알",
	decoration = "장식품",
	dairy = "우유",
	inedible = "비식품",
	frozen = "얼음",
	seed = "씨앗",
	fat = "기름",
	
	--Waiter 101
	fungus = "곰팡이", --all mushroom caps + cutlichen
	mushrooms = "버섯", --all mushroom caps
	poultry = "조류",
	wings = "날개", --about batwing
	seafood = "해산물",
	nut = "견과",
	cactus = "선인장",
	starch = "녹말", --about corn, pumpkin, cave_banana
	grapes = "포도", --grapricot
	citrus = "감귤", --grapricot_cooked, limon
	tuber = "덩이줄기", --yamion
	shellfish = "조개", --limpets, mussel
	
	--BEEFALO MILK and CHEESE mod
	rawmilk = "생우유",
	
	--Camp Cuisine: Re-Lunched
	bulb = "전구", --lightbulb
	spices = "양념",
	challa = "할라 빵", -- Challah bread
	flour = "가루", --flour
	
	--Chocolate
	cacao_cooked == "카카오",
}

STRESS_TAGS = { --https://dontstarve.fandom.com/wiki/Farm_Plant
	nutrients = "Lack of nutrients",
	moisture = "Lack of moisture",
	killjoys = "Killjoys around",	
	family = "No plant family",
	season = "Off Season",
	overcrowding = "Overcrowded plants",
	happiness = "Unhappy",
}

INTERNAL_TIMERS = {
	--Antlion
	wall_cd = "",
	rage = "",
	nextrepair = "", --antlion_sinkhole.lua
	
	--squid
	ink_cooldown = "", 
	gobble_cooldown = "", --also: for shark
	
	-- for atrium_gate
	destabilizing = "",
	destabilizedelay = "",
	cooldown = "",
	
	-- beequeenhive
	hivegrowth1 = "",
	hivegrowth2 = "",
	hivegrowth = "",
	shorthivegrowth = "",
	hiveregen = "",
	firsthivegrowth = "",
	
	--beequeen
	spawnguards_cd = "",
	focustarget_cd = "",
	
	-- crabking
	spell_cooldown = "",
	claw_regen_delay1 = "", -- base 5, plus 9 gems. So 14 is maximum
	claw_regen_delay2 = "",
	claw_regen_delay3 = "",
	claw_regen_delay4 = "",
	claw_regen_delay5 = "",
	claw_regen_delay6 = "",
	claw_regen_delay7 = "",
	claw_regen_delay8 = "",
	claw_regen_delay9 = "",
	claw_regen_delay10 = "",
	claw_regen_delay11 = "",
	claw_regen_delay12 = "",
	claw_regen_delay13 = "",
	claw_regen_delay14 = "",
	regen_crabking = "",
	casting_timer = "",
	gem_shine = "",
	clawsummon_cooldown = "",
	seastacksummon_cooldown = "",
	fix_timer = "",
	
	--trees, ghostly_elixirs.lua
	decay = "",
	
	--grassgekko
	morphing = "", 
	morphrelay = "",
	morphdelay = "",
	growTail = "",
	
	--lightflier_flower.lua, flower_cave.lua
	recharge = "",
	turnoff = "",
	
	--mermking.lua
	hungrytalk_increase_cooldown = "", 
	hungrytalk_cooldown = "",
	
	--molebat.lua
	resetnap = "",
	cleannest_timer = "",
	resetallysummon = "",
	rememberinitiallocation = "",
	
	--Timer names for warlus_camp:
    walrus = "",
    little_walrus = "",
    icehound = "",
	
	--hermitcrab.lua:
	speak_time = "",
	complain_time = "",
	salad = "",
	bottledelay = "",
	fishingtime = "",
	--hermit_grannied plus GUID -- impossible to translate.
	
	--malbatross.lua:
	sleeping_relocate = "",
	divetask = "",
	disengage = "",
	satiated = "",
	splashdelay = "",
	
	--toadstool.lua:
	sporebomb_cd = "",
	mushroombomb_cd = "",
	mushroomsprout_cd = "",
	pound_cd = "",
	channeltick = "",
	channel = "",
	
	--toadstool_cap.lua
	darktimer = "",
	respawndark = "",
	respawn = "",
	
	--waterplant.lua:
	resetcloud = "",
	equipweapon = "",
	
	--waveyjones.lua:
	laughter = "",
	reactiondelay = "",
	respawndelay = "",
	trappedtimer = "",
	
	--bearger
	GroundPound = "",
	Yawn = "",
	
	--klaus
	chomp_cd = "",
	command_cd = "",
	
	--Shark
	getdistance = "",
	minleaptime = "",
	calmtime = "",
	targetboatdelay = "",
	--gobble_cooldown --duplicate
	
	--sacred_chest.lua
	localoffering = "",
	localoffering_pst = "",
	
	--stalker.lua
	snare_cd = "",
	spikes_cd = "",
	channelers_cd = "",
	minions_cd = "",
	mindcontrol_cd = "",
	
	--deer.lua
	growantler = "",
	deercast_cd = "",
	
	--fruit_dragon.lua
	fire_cd = "",
	panicing = "",
	
	--moonbase.lua
	moonchargepre = "",
	mooncharge = "",
	mooncharge2 = "",
	mooncharge3 = "",
	fullmoonstartdelay = "",
	
	--dragon fly
	regen_dragonfly = "",
	groundpound_cd = "",
	
	--Others:
	repair = "", --dustmothden
	dontfacetime = "", --merm.lua
	growth = "", --saltstack.lua
	lordfruitfly_spawntime = "", -- farmin_manager.lua
	facetime = "", --mermbrain.lua
	regenover = "", --tillweedsalve.lua, compostwrap.lua, forgetmelots.lua, healthregenbuff.lua
	make_debris = "", --weed_defs.lua
	spread = "", --weed_plants.lua
	expire = "", --archive_resonator.lua
	drilling = "", --farm_plow.lua
	composting = "", --compostingbin.lua
	HatchTimer = "", --mooseegg.lua
	lifespan = "", --oceanfish.lua
	offeringcooldown = "", --perd.lua
	rock_ice_change = "", --rock_ice.lua
	lifetime = "", --schoolherd.lua
	disperse = "", --sleepcloud.lua, sporecloud.lua, waterplant_pollen.lua, chum_aoe.lua
	extinguish = "", --stafflight.lua
	transform_cd = "", --bernie_active.lua, bernie_big.lua, bernie_inactive.lua
	taunt_cd = "", --bernie
	buffover = "", --foodbuffs.lua, wintersfeastbuff.lua, halloweenpotion_buffs.lua
	resettoss = "", --gnarwail.lua
	revive = "", --hound_corpse.lua
	toot = "", --moon_fissure.lua
	training = "", --gym.lua (component)
	salt = "", --saltlicker.lua (component)
	foodspoil = "", --trap.lua (component)
	laserbeam_cd = "", --deerclops
	DisarmCooldown = "", --moose
	explode = "", --sporebomb.lua
	selfdestruct = "", --stalker_minions.lua, lavae.lua
	self_combustion = "", --miniboatlantern.lua
	despawn_timer = "", --pigelitefighter.lua
	rotting = "", --plant_normal.lua
	grow = "", --planted_tree.lua, rock_avocado_fruit.lua
	remove = "", --fishschoolspawnblocker.lua
	dominant = "", --crittertraits.lua (component)
}

INTERNAL_STAGES = {
	--all trees:
	short = "",
	normal = "",
	tall = "",
	old = "",
	
	--spiderden:
	small = "",
	med = "",
	large = "",
	queen = "",
	
	--rock_avocado_bush:
	stage_1 = "",
	stage_2 = "",
	stage_3 = "",
	stage_4 = "",
	
	--weed_plants:
	--small --duplicate
	--med --duplicate
	full = "",
	bolting = "",
	
	--farm_plants:
	seed = "",
	sprout = "",
	
	--smallbird
	--small --duplicate
	--tall  --duplicate
	
	--baby beefalo:
	baby = "",
	toddler = "",
	teen = "",
	grown = "",
}

MY_DATA.uses_of.fn = function(arr)
	return "사용횟수: " .. arr.param[1] .. " / " .. arr.param[2]
end

MY_DATA.cookpot.fn = function(arr)
	return arr.param[1] .. " 요리가 완료되기까지"
end


UpdateNewLanguage()