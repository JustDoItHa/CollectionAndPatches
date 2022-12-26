MY_STRINGS_OVERRIDE =
{ 
	armor = "傷害吸收: " , --A --Armor of the item.
	aggro = "攻擊力: " , --B --Score of griefing 
	cookpot = "正在烹煮 " , --C (Crock Pot)
	dmg = "攻擊力: " , --D
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
	owner = "所有者: " , --O --support of various mods
	power = "造成傷害: ", --P --usually means strengths of a weapon but not physical damage
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
	speed = "速度: " , --Bonus of the speed (percent)
	uses_of = "次可使用, 總次數" ,
	obedience = "服從: " ,
	S1="現在是冬天," , 
	dmg_character = "攻擊力: " ,
	perish = "腐爛", --P -- Spoil in N days. 
	cooldown="冷卻: ",
	domest = "馴化: ", -- "Domestication:"
	will_die = "死亡", -- will die in N days (saying about pet or animal).
	will_dry = "曬乾", --
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
	
	timer = "倒數",
	trade_gold = '黃金供品: ',
	trade_rock = '石頭供品: ',
	durability = '耐久度: ',
	strength = '攻擊力: ',
	aoe = "範圍攻擊: ",
}

SHOWME_STRINGS = {
	loyal = "臣服", --for very loyal pigman with loyalty over 9000
	of = " 屬於 ", -- X of Y (reserved)
	units_1 = "1 單位的",
	units_many = " 單位的",
	uses_1 = "1 次可使用, 總次數 ", --#overide#
	uses_many = " 次可使用, 總次數 ", --#overide# X uses of Y, where X > 1
	days = " 天", --Spoil in N days.
	temperature = '溫度',

	_in = ': ',
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
	decoration = "裝飾",
	dairy = "乳製品",
	inedible = "不可食用",
	frozen = "冰",
	seed = "種子",
	fat = "油脂",
	
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

MY_DATA.perish.fn = function(arr)
	return "將會在 " .. arr.param[1] .. SHOWME_STRINGS.days .. "時" .. arr.data.desc
end

MY_DATA.uses_of.fn = function(arr)
	return "耐久度: " .. arr.param[1] .. " / " .. arr.param[2]
end

UpdateNewLanguage()