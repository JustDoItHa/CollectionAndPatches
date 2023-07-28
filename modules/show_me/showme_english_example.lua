MY_STRINGS_OVERRIDE =
{ 
	armor = "Armor:" , --A --Armor of the item.
	aggro = "Aggression:" , --B --Score of griefing 
	cookpot = "Probably it will be" , --C (Crock Pot)
	dmg = "Damage:" , --D
	electric = "Electric:" , --E --electric power
	food = "Food:",
	S2="Now it's the summer," , --G
	health= "Health:" , --H --for food
	warm = "Insulation:" , --I --winter insulation
	kill = "Kill:" , --J  --for Canibalism 18 mod (if character murder only once)
	kills = "Kills:" , --K  --for Canibalism 18 mod (shows count of kills)
	loyal = "Loyality:" , --L  --pigman and bunnyman
	S4="Now it's the autumn," , --M
	remaining_days = "Remaining days" , --N
	owner = "Owner:" , --O --support of various mods
	power = "Power:", --P --usually means strengths of a weapon but not physical damage
	hunger= "Hunger:" , --Q
	range = "Range:" , --R  --for range weapon or for mobs
	sanity= "Sanity:" , --S
	thickness = "Thickness:" , --T --It's about thickness of the ice of a pond
	units_of = "units of" , --U
	resist = "Resistance:" , --V --against sleep darts, ice staff etc
	waterproof = "Waterproof:" , --W --Resistance against water
	heal = "Heal:" , --X --How much health will be restored by some medic pack
	fishes = "Fishes:" , --Y  --Count fishes in a pond
	fish = "Fish:" , --Z --Count fishes in a pond if there is only 1 fish
	sec= "Seconds:" ,  --for cooking in Crock Pot
	love = "Love:" , 
	summer = "Summer:" , --summer insulation
	absorb = "Absorb:" , --Absorb damage
	S3="Now it's the spring," , --
	is_admin = "This is the ADMIN!\nHe is out of the game\nso don't touch him." ,
	temperature = "t" ,
	hp= "HP:" , --for characters
	armor_character = "Armor:" , --Armor of the creature or player.
	sanity_character = "Sanity:" , --S	
	fuel = "Fuel:" , --F --for firepit
	speed = "Speed:" , --Bonus of the speed (percent)
	uses_of = "uses of" ,
	obedience = "Obedience:" ,
	S1="Now it's the winter," , 
	dmg_character = "Damage:" ,
	perish = "Spoil in", --P -- Spoil in N days. 
	cooldown="Cooldown:",
	domest = "Tamed:", -- "Domestication:"
	will_die = "Will die in", --will die in N days (saying about pet or animal).
	will_dry = "Will dry in",
	dmg_bonus = "Damage bonus:", -- Damage: +X (means damage modifier, not base damage)
	crop = "", --Not used. It's just a key for info type. Info - "Product: percent"
	grow_in = "Grow in", --About grass etc
	perish_product = "", --Just a key for info type. Info - "Product: time in days"
	just_time = "", --Just a key for info type. Info - [time]
	--Thirst mod
	water = "Water:",
	salt = "Salt:",
	sip = "A sip:",
	watergainspeed = "Water gain speed:",
	water_poisoned = "Is poisoned!",
	
	timer = "Timer",
	trade_gold = 'Gold tribute:',
	trade_rock = 'Rock tribute:',
	durability = 'Durability:',
	strength = 'Strength:',
	aoe = "AoE:",
	stress = "Stress:",
}

SHOWME_STRINGS = {
	loyal = "forever", --for very loyal pigman with loyalty over 9000
	of = " of ", -- X of Y (reserved)
	units_1 = "1 unit of ",
	units_many = " units of ",
	uses_1 = "1 use of ",
	uses_many = " uses of ", --X uses of Y, where X > 1
	days = " days", --Spoil in N days.
	temperature = 'Temperature',
	paused = 'Paused',
	stopped = 'Stopped',
	already_fresh = 'Maximum freshness',
	cheat_fresh = 'Cheat mod detected',
	onpickup = ' on pick up', --for flowers
	lack_of = 'Lack of ', -- e.g. Lack of nutrients
	_in = ' in ', -- something in X seconds
}

--Food tags are in genitive case.
--For example: "0.5 units of fruit"
FOOD_TAGS = { --"dried" and "precook" are excluded.
	veggie = "",
	fruit = "",
	monster = "",
	sweetener = "",
	meat = "",
	fish = "",
	magic = "",
	egg = "",
	decoration = "",
	dairy = "",
	inedible = "",
	frozen = "",
	seed = "",
	fat = "",
	
	--Waiter 101
	fungus = "", --all mushroom caps + cut lichen
	mushrooms = "", --all mushroom caps
	poultry = "",
	wings = "", --about bat wing
	seafood = "",
	nut = "",
	cactus = "",
	starch = "", --about corn, pumpkin, cave_banana
	grapes = "", --grapricot
	citrus = "", --grapricot_cooked, limon
	tuber = "", --yamion
	shellfish = "", --limpets, mussel
	
	--BEEFALO MILK and CHEESE mod
	rawmilk = "",
	
	--Camp Cuisine: Re-Lunched
	bulb = "", --lightbulb
	spices = "",
	challa = "", -- Challah bread
	flour = "", --flour
	
	--Chocolate
	cacao_cooked == "",
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

UpdateNewLanguage()

--You can add custom aspects of your native language.
--See showme_ru.lua for more details.