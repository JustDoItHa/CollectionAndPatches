MY_STRINGS_OVERRIDE = {
	hp="HP:", --for characters
	health="Здоровье:", --for food
	hunger="Сытость:",
	sanity="Рассудок:",
	sec="Секунды:",
	armor="Защита:",
	dmg="Урон:",
	warm="Утепление:",
	fuel="Топливо:",
	range="Дальность:",
	speed="Скорость:",
	resist="Сопротивление:",
	power="Сила:",
	loyal="Преданность:",
	love="Любовь:",
	heal="Лечение:",
	kills="Убийств:",
	kill="Убийство:",
	fishes="Рыб:",
	fish="Рыба:",
	owner="Владелец:",
	thickness="Толщина:",
	waterproof="Влагозащита:",
	aggro="Агрессия:",
	summer="Летняя защита:",
	absorb="Поглощение:",
	obedience="Покорность:",
	perish="Испортится через",
	cookpot = "Скорее всего, это будет" ,
	electric = "Электричество:" ,
	S2="Сейчас лето,",
	S4="Сейчас осень," , 
	remaining_days = "Осталось дней" ,
	S3="Сейчас весна," ,
	is_admin = "Это одмин!\nОн вне игры,\nпоэтому нет смысла его трогать." ,
	armor_character = "Защита:" ,
	sanity_character = "Рассудок:" ,
	S1="Сейчас зима," , 
	dmg_character = "Урон:" ,
	cooldown = "Откат:",
    domest = "Приручённость:", -- "Domestication:"
    will_die = "Умрёт через",
    will_dry = "Высушится через",
    dmg_bonus = "Бонус урона:",
    grow_in = "Вырастет через",
	water = "Вода:",
	salt = "Соль:",
	sip = "Глоток:",
	watergainspeed = "Скорость прироста воды:",
	water_poisoned = "Содержит яд!",
	timer = "Таймер",
	trade_gold = "Стоимость золота:",
	trade_rock = "Стоимость камня:",
	durability = 'Прочность:',
	strength = 'Сила:',
	--aoe = 'AoE:',
	precipitationrate = "Дождь:",
	wetness = "Влага мира:",
	fresh = "Освежится через",
	food_memory = 'Память',
	sanityaura = 'Аура:',
	effectiveness = 'Эффективность:',
	force = 'Сила:',
	repairer = 'Починка:',
	stress = 'Стресс:',
	children = 'Существа: ',
}

SHOWME_STRINGS = {
	loyal = "вечная",
	of = " из ",
	temperature = 'Температура',
	paused = 'пауза',
	already_fresh = 'Максимальная свежесть',
	cheat_fresh = 'Читерский мод свежести',
	Work = 'Добыча',
	Absorb = 'Поглощение',
	Attack = 'Атака',
	['Moisture Immunity'] = 'Влагостойкость',
	Electric = 'Электрический',
	Glow = 'Свечение',
	['Health Regen'] = 'Реген здоровья',
	onpickup = ' при срывании',
	lack_of = 'Недостаток ',
	_in = ' через ',
}

FOOD_TAGS = { --"dried" and "precook" are excluded.
	veggie = "овощей",
	fruit = "фруктов",
	monster = "монстро-еды",
	sweetener = "сахара",
	meat = "мяса",
	fish = "рыбы",
	magic = "магии",
	egg = "яиц",
	decoration = "украшений",
	dairy = "молока",
	inedible = "отравы",
	frozen = "льда",
	seed = "семян",
	fat = "жира",
	
	--Waiter 101
	fungus = "грибов", --all mushroom caps + cutlichen
	mushrooms = "полезных грибов", --all mushroom caps
	poultry = "птицы",
	wings = "крыльев", --about batwing
	seafood = "морепродуктов",
	nut = "орехов",
	cactus = "кактуса",
	starch = "крахмала", --about corn, pumpkin, cave_banana
	grapes = "винограда", --grapricot
	citrus = "цитрусовых", --grapricot_cooked, limon
	tuber = "клубня", --yamion
	shellfish = "моллюсков", --limpets, mussel
	
	--BEEFALO MILK and CHEESE mod
	rawmilk = "парного молока",
	
	--Camp Cuisine: Re-Lunched
	bulb = "шариков", --lightbulb
	spices = "специй",
	challa = "халы", -- Challah bread
	flour = "муки", --flour
	
	--Chocolate
	cacao_cooked == "какао",
}

STRESS_TAGS = { --https://dontstarve.fandom.com/wiki/Farm_Plant
	nutrients = "Нужно удобрение",
	moisture = "Нужен полив",
	killjoys = "Сорняки вокруг",	
	family = "Мало таких же растений",
	season = "Не сезон",
	overcrowding = "Много растений вокруг",
	happiness = "Нужна забота",
}

INTERNAL_TIMERS = {
	--Antlion
	wall_cd = "",
	rage = "Ярость",
	nextrepair = "След. починка", --antlion_sinkhole.lua
	
	--squid
	ink_cooldown = "Чернила",
	gobble_cooldown = "Жрать", --also: for shark
	
	-- for atrium_gate
	destabilizing = "Дестабилизированные",
	destabilizedelay = "Пауза дестабилизации",
	cooldown = "Откат",
	
	-- beequeenhive
	hivegrowth1 = "Рост улья(2)",
	hivegrowth2 = "Рост улья(3)",
	hivegrowth = "Рост улья(1)",
	shorthivegrowth = "Малый рост улья",
	hiveregen = "Реген улья",
	firsthivegrowth = "Первый рост улья",
	
	--beequeen
	spawnguards_cd = "Спавн миньонов",
	focustarget_cd = "Фокус цели",
	
	-- crabking
	spell_cooldown = "Откат заклинания",
	claw_regen_delay1 = "Реген клешни(1)", -- base 5, plus 9 gems. So 14 is maximum
	claw_regen_delay2 = "Реген клешни(2)",
	claw_regen_delay3 = "Реген клешни(3)",
	claw_regen_delay4 = "Реген клешни(4)",
	claw_regen_delay5 = "Реген клешни(5)",
	claw_regen_delay6 = "Реген клешни(6)",
	claw_regen_delay7 = "Реген клешни(7)",
	claw_regen_delay8 = "Реген клешни(8)",
	claw_regen_delay9 = "Реген клешни(9)",
	claw_regen_delay10 = "Реген клешни(10)",
	claw_regen_delay11 = "Реген клешни(11)",
	claw_regen_delay12 = "Реген клешни(12)",
	claw_regen_delay13 = "Реген клешни(13)",
	claw_regen_delay14 = "Реген клешни(14)",
	regen_crabking = "Реген Короля крабов",
	casting_timer = "Время каста",
	gem_shine = "Блеск самоцветов",
	clawsummon_cooldown = "Откат призыва клешней",
	seastacksummon_cooldown = "Откат гейзера",
	fix_timer = "",
	
	--trees, ghostly_elixirs.lua
	decay = "Разложение",
	
	--grassgekko
	morphing = "Превращение", 
	morphrelay = "Смена превращения",
	morphdelay = "Пауза превращения",
	growTail = "Отращивание хвоста",
	
	--lightflier_flower.lua, flower_cave.lua
	recharge = "Перезарядка",
	turnoff = "Выключение",
	
	--mermking.lua
	hungrytalk_increase_cooldown = "Усиление голоса", 
	hungrytalk_cooldown = "Голодный голос",
	
	--molebat.lua
	resetnap = "Сброс сна",
	cleannest_timer = "Чистка гнезда",
	resetallysummon = "Сброс призыва друзей",
	rememberinitiallocation = "Память начальной локации",
	
	--Timer names for warlus_camp:
    walrus = "МакБивень",
    little_walrus = "Младший",
    icehound = "Лед. гончая",
	
	--hermitcrab.lua:
	speak_time = "Разговор",
	complain_time = "Жалоба",
	salad = "Салат",
	bottledelay = "Бутылка",
	fishingtime = "Рыбалка",
	--hermit_grannied plus GUID -- impossible to translate.
	
	--malbatross.lua:
	sleeping_relocate = "Место сна",
	divetask = "Ныряние",
	disengage = "Выход из боя",
	satiated = "Пресыщение",
	splashdelay = "Всплеск",
	
	--toadstool.lua:
	sporebomb_cd = "Споры газа",
	mushroombomb_cd = "Споры бумгрибов",
	mushroomsprout_cd = "Ростки грибов",
	pound_cd = "Ударная волна",
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
	laughter = "Смех",
	reactiondelay = "Реакция",
	respawndelay = "Возрождение",
	trappedtimer = "Ловушка",
	
	--bearger
	GroundPound = "Ударная волна",
	Yawn = "Зевок",
	
	--klaus
	chomp_cd = "Чавкание",
	command_cd = "Приказы",
	
	--Shark
	getdistance = "Узнать расстояние",
	minleaptime = "Прыжок",
	calmtime = "Спокойствие",
	targetboatdelay = "Фокус лодки",
	--gobble_cooldown --duplicate
	
	--sacred_chest.lua
	localoffering = "Предложение",
	localoffering_pst = "Предложение(pst)",
	
	--stalker.lua
	snare_cd = "Ловушка",
	spikes_cd = "Шипы",
	channelers_cd = "",
	minions_cd = "Миньоны",
	mindcontrol_cd = "Контроль разума",
	
	--deer.lua
	growantler = "Отращивание рогов",
	deercast_cd = "Каст",
	
	--fruit_dragon.lua
	fire_cd = "Огонь",
	panicing = "Паника",
	
	--moonbase.lua
	moonchargepre = "Зарядка(до начала)",
	mooncharge = "Зарядка(1)",
	mooncharge2 = "Зарядка(2)",
	mooncharge3 = "Зарядка(3)",
	fullmoonstartdelay = "Полная луна",
	
	--dragon fly
	regen_dragonfly = "Регенерация",
	groundpound_cd = "Ударная волна",
	
	--Others:
	repair = "Починка", --dustmothden
	dontfacetime = "", --merm.lua
	growth = "Прирост", --saltstack.lua
	lordfruitfly_spawntime = "Повелитель мух", -- farmin_manager.lua
	facetime = "", --mermbrain.lua
	regenover = "Восстановление", --tillweedsalve.lua, compostwrap.lua, forgetmelots.lua, healthregenbuff.lua
	make_debris = "Выработка обломков", --weed_defs.lua
	spread = "Распространение", --weed_plants.lua
	expire = "Истечение", --archive_resonator.lua
	drilling = "Бурение", --farm_plow.lua
	composting = "Гниение", --compostingbin.lua
	HatchTimer = "Вылупление", --mooseegg.lua
	lifespan = "Срок жизни", --oceanfish.lua
	offeringcooldown = "Откат предложения", --perd.lua
	rock_ice_change = "Таяние", --rock_ice.lua
	lifetime = "Жизнь", --schoolherd.lua
	disperse = "Рассеивание", --sleepcloud.lua, sporecloud.lua, waterplant_pollen.lua, chum_aoe.lua
	extinguish = "Угасание", --stafflight.lua
	transform_cd = "Трансформация", --bernie_active.lua, bernie_big.lua, bernie_inactive.lua
	taunt_cd = "Насмешка", --bernie
	buffover = "Баф", --foodbuffs.lua, wintersfeastbuff.lua, halloweenpotion_buffs.lua
	resettoss = "", --gnarwail.lua
	revive = "Воскрешение", --hound_corpse.lua
	toot = "", --moon_fissure.lua
	training = "Тренировка", --gym.lua (component)
	salt = "Соль", --saltlicker.lua (component)
	foodspoil = "Порча", --trap.lua (component)
	laserbeam_cd = "Лазерный луч", --deerclops
	DisarmCooldown = "Разоружение", --moose
	explode = "Взрыв", --sporebomb.lua
	selfdestruct = "Самоуничтожение", --stalker_minions.lua, lavae.lua
	self_combustion = "Самосожжение", --miniboatlantern.lua
	despawn_timer = "Исчезновение", --pigelitefighter.lua
	rotting = "Гниение", --plant_normal.lua
	grow = "Рост", --planted_tree.lua, rock_avocado_fruit.lua
	remove = "Удаление", --fishschoolspawnblocker.lua
	dominant = "", --crittertraits.lua (component)
    Spawner_SpawnDelay = "Возрождение", --pighouse
}

INTERNAL_STAGES = {
	--all trees:
	short = "Короткое",
	normal = "Нормальное",
	tall = "Высокое",
	old = "Старое",
	
	--spiderden:
	small = "Маленькое",
	med = "Среднее",
	large = "Большое",
	queen = "Королева",
	
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
	seed = "Семя",
	sprout = "Росток",
	
	--smallbird
	--small --duplicate
	--tall  --duplicate
	
	--baby beefalo:
	baby = "Младенец",
	toddler = "Ребёнок",
	teen = "Подросток",
	grown = "Взрослый",
}

--Russian declension of numerals
local st_tbl = {
	units = {" единица "," единицы "," единиц "},
	--uses = {" использование из ", " использования из ", " использований из "},
	days = {"день","дня","дней"},
}

function StringTime(nn,s)
	local n =  math.floor(GLOBAL.tonumber(nn) or 0)
	local days = st_tbl[s]
	if days then
		local pl_type=n%10==1 and n%100~=11 and 1
			or(n%10>=2 and n%10<=4 and(n%100<10 or n%100>=20)and 2 or 3)
		return tostring(nn).." "..days[pl_type]
	else
		return tostring(nn).." "..s --просто "N дней"
	end
end

MY_DATA.units_of.fn = function(arr)
	local s = FOOD_TAGS[arr.param[2]]
	s = s ~= "" and s or arr.param[2] --If translation exists.
	return StringTime(arr.param[1],"units")..s
end
MY_DATA.uses_of.fn = function(arr)
	--return StringTime(arr.param[1],"uses")..arr.param[2]
	return arr.param[1] .. ' / ' .. arr.param[2]
end
MY_DATA.perish.fn = function(arr)
	local days = GLOBAL.tonumber(arr.param[1]) or 0
	if days == math.floor(days) then
		return arr.data.desc .. " " .. StringTime(days, "days")
	elseif days >= 1.4 and days <= 1.6 then
		return arr.data.desc .. " полтора дня"
	elseif days >= 0.4 and days <= 0.6 then
		return arr.data.desc .. " полдня"
	else
		return arr.data.desc .. " " .. tostring(days) .. " " .. st_tbl.days[3]
	end
end

local old_buff_fn = MY_DATA.buff.fn;
MY_DATA.buff.fn = function(arr)
	old_buff_fn(arr)
	local name = arr.param[1]
	local bonus = arr.param[3]
	local days = arr.param[2]
	if bonus then
		return name .. ' ' .. bonus .. '%'
			.. (days ~= '0' and ' длится ' .. StringTime(days,'days') or '')
	end
	return name .. ' длится ' .. StringTime(days,'days')
end


UpdateNewLanguage()
