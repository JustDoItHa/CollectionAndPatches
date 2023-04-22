---提取自show me
---
local _G = GLOBAL

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


--Locals (Add compatibility with any other mineable mods).
local mods = GetGlobal("mods",{})

local GetTime = _G.GetTime
local TheNet = _G.TheNet
local is_PvP = TheNet:GetDefaultPvpSetting()
local SERVER_SIDE = TheNet:GetIsServer()
local CLIENT_SIDE =	 TheNet:GetIsClient() or (SERVER_SIDE and not TheNet:IsDedicated())

local tonumber = _G.tonumber

local chestR = tonumber(GetModConfigData('chestR',true)) or -1
if chestR == -1 then
	chestR = tonumber(GetModConfigData('chestR')) or 0.3
	if (chestR == -1) then chestR = 0.3 end
end
local chestG = tonumber(GetModConfigData('chestG',true)) or -1
if chestG == -1 then
	chestG = tonumber(GetModConfigData('chestG')) or 1
	if (chestG == -1) then chestG = 1 end
end
local chestB = tonumber(GetModConfigData('chestB',true)) or -1
if chestB == -1 then
	chestB = tonumber(GetModConfigData('chestB')) or 1
	if (chestB == -1) then chestB = 1 end
end
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
--Название на английском, краткая сетевая строка-алиас (для пересылки).
--Если алиас начинается с маленькой буквы, то он обязан быть длиной в 1 букву. Если с большой, то 2 (вторая буква может быть любого регистра).


--Основная функция получения описания.
local function GetTestString(item,viewer) --Отныне форкуемся от Tell Me, ибо всё сложно.
	--line_cnt = 0
	desc_table = {} --старый desc отменяется

	is_admin = nil
	local prefab = item.prefab
	local c=item.components
	local has_owner = false --Выводим инфу о владельце лишь ОДИН раз!
	if (prefab=="rock1" or prefab=="rock2") and not viewer.has_AlwaysOnStatus then
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

		if need_send_hp then --c.health
			local mx=math.ceil(h.maxhealth-h.minhealth)
			local cur=math.ceil(h.currenthealth-h.minhealth)
			if cur>mx then cur=mx end
			cn("hp",cur,mx)
		end

		if c.hunger then
			local val = c.hunger:GetPercent()
			--Либо голода мало, либо это вообще не игрок.
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
		if c.follower then
			if c.follower.leader and c.follower.leader:IsValid() and c.follower.leader:HasTag("player")
					and c.follower.leader.name and c.follower.leader.name ~= ""
			then
				cn("owner",c.follower.leader.name)
				has_owner = true
			end
			if c.follower.maxfollowtime then
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
		if item.kills and item.kills>0 then
			cn(item.kills==1 and "kill" or "kills",item.kills)
		end
		if item.aggro and item.aggro>0 then
			cn("aggro",item.aggro)
		end
		--Процент увеличения урона. Например, у Вигфрид +25%
		if c.combat and c.combat.damagemultiplier and c.combat.damagemultiplier ~= 1 then
			local perc = c.combat.damagemultiplier - 1
			cn("dmg_character",round2(perc*100,0))
		end
		--Урон
		if c.combat and c.combat.defaultdamage and c.combat.defaultdamage > 0 then
			--Игнорируем всех, чья сила равна 10 или меньше.
			local com = c.combat
			local dmg = com.defaultdamage
			local pvp_perc = tonumber(com.playerdamagepercent) --modifier for NPC dmg on players, only works with NO WEAPON
			if pvp_perc then
				if pvp_perc == 1 or not is_PvP and prefab == "abigail" then
					pvp_perc = nil
				else
					pvp_perc = round2((pvp_perc - 1)*100);
				end
			end
			cn("strength", math.floor( dmg + 0.5), pvp_perc)
			if com.areahitdamagepercent then --AoE
				cn("aoe", math.floor( dmg * com.areahitdamagepercent + 0.5))
			end
		end
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
		if c.stewer and c.stewer.product and c.stewer.IsCooking and c.stewer:IsCooking() then
			local tm=round2(c.stewer.targettime-_G.GetTime(),0)
			if tm<0 then tm=0 end
			cn("cookpot", c.stewer.product)
			cn("sec",tm)
		end
		if c.cooldown and c.cooldown.GetTimeToCharged and not c.cooldown.charged then
			local timer = round2(c.cooldown:GetTimeToCharged(),0)
			cn("cooldown", timer)
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
		--Part 2: secondary info
		if item_info_mod == 0 and c.armor and c.armor.absorb_percent and type(c.armor.absorb_percent)=="number" then
			local r=c.armor.absorb_percent --0.8
			local tm_buff = GetDebuffTime(viewer, 'buff_playerabsorption')
			if tm_buff then
				local power = TUNING[KNOWN_BUFFS.buff_playerabsorption.power]
				if power then
					r = r + (1 - r) * power
				end
			end
			cn("armor",round2(r*100,0),tm_buff and round2(tm_buff))
			--Support of absorption mod.
			if item.phys and (item.phys.blunt or item.phys.pierc or item.phys.slash) then
				local p = item.phys
				cn("absorb",(p.blunt or 0).." / "..(p.pierc or 0).." / "..(p.slash or 0))
			end
			if c.armor.condition and c.armor.condition > 0 and c.armor.maxcondition then
				cn("durability", math.floor(c.armor.condition + 0.5), math.floor(c.armor.maxcondition + 0.5))
			end
		end
		if item_info_mod == 0 then
			if item.damage and type(item.damage)=="number" and item.damage>0 then
				cn("dmg",round2(item.damage,1))
			elseif c.weapon ~= nil and c.weapon.damage and type(c.weapon.damage)=="number" and c.weapon.damage>0 then
				local r = c.weapon.damage
				local tm_buff = GetDebuffTime(viewer, 'buff_attack')
				if tm_buff then
					local power = TUNING[KNOWN_BUFFS.buff_attack.power]
					if power then
						r = r * power
					end
				end
				cn("dmg",round2(r,1),tm_buff and round2(tm_buff))
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
		if item_info_mod == 0 then
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
				if viewer ~= nil and viewer.FoodValuesChanger ~= nil then --Особая функция, призвание которой - менять еду при съедании.
					--print("+")
					--Правда, здесь мы можешь слегка подсмотреть ее результаты до поедания.
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
				if ed.temperaturedelta ~= 0 then -- food has temperature
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
				if base_mult ~= 1 then --foodmemory
					local fm = viewer.components.foodmemory
					if fm.GetBaseFood and fm.foods then
						local rec = fm.foods[fm:GetBaseFood(prefab)]
						if rec then
							local t = _G.GetTaskRemaining(rec.task)
							cn('food_memory',round2(base_mult,2),round2(t))
						end
					end
				end
				--Spice effect
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
		if item_info_mod == 0 and c.perishable ~= nil and c.perishable.updatetask ~= nil then
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
					cn("perish",round2(time/TUNING.TOTAL_DAY_TIME,1))
				end
			end
		end
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
		--[[if item.grow_stage and type(item.grow_stage) == "number" then --Support Clan System mod
            local val = math.floor(item.grow_stage+0.5)
            desc = cn(desc,tostring(val).."%","power")
            if IsAdmin(viewer) then
                desc = cn(desc,item.show_stage,"show_stage",true)
                desc = cn(desc,item.grow_stage,"grow_stage",true)
                desc = cn(desc,item.active,"active",true)
                desc = cn(desc,item.fuel,"fuel",true)
            end
        else--]]
		if item_info_mod == 0 and c.finiteuses then
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
		if c.temperature and c.temperature.current and type(c.temperature.current) == "number" then
			cn("temperature",round2(c.temperature.current,1))
		end
		if c.fueled and c.fueled:GetPercent()>0 and (SPICIAL_STRUCTURES[prefab] or item:HasTag("structure")) then
			cn("fuel",round2(c.fueled:GetPercent()*100,0))
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
				--Мы не знаем, что за имя. Но это "владелец". Так что надо вывести. И это точно не user_id.
				cn("owner",item.owner)
				has_owner = true
			end
		end
		if c.occupiable then
			local item = c.occupiable:GetOccupant()
			if item then
				local c = item.components
				if c.perishable ~= nil and c.perishable.updatetask ~= nil then --Here "Perishable" means "Hunger".
					local time = GetPerishTime(item, c)
					if time ~= nil then
						cn("will_die",round2(time/TUNING.TOTAL_DAY_TIME,1))
					end
				end
			end
		end
		if c.dryer and c.dryer.IsDrying then
			if c.dryer:IsDrying() and c.dryer.GetTimeToDry then
				cn("will_dry",round2(c.dryer:GetTimeToDry()/TUNING.TOTAL_DAY_TIME,1))
				--if c.dryer:IsPaused() then
				--end
			elseif c.dryer.IsDone and c.dryer:IsDone() and c.dryer.GetTimeToSpoil then
				cn("perish",round2(c.dryer:GetTimeToSpoil()/TUNING.TOTAL_DAY_TIME,1))
			end
		end
		if c.saddler then --Седло и его параметры.
			if c.saddler.speedmult and c.saddler.speedmult ~= 0 then
				local added_speed = math.floor((c.saddler.speedmult - 1)*100 + 0.5) -- (1.4 - 1) == 0.4
				cn("speed",added_speed)
			end
			if c.saddler.bonusdamage and c.saddler.bonusdamage ~= 0 then
				cn("dmg_bonus",round2(c.saddler.bonusdamage,1))
			end
		end
		if c.tradable then
			if c.tradable.goldvalue and c.tradable.goldvalue > 1 then
				cn("trade_gold", c.tradable.goldvalue)
			end
			if c.tradable.rocktribute and c.tradable.rocktribute > 0 and _G.TheWorld.state.issummer then
				cn("trade_rock", c.tradable.rocktribute)
			end
		end
		if TUNING.PERISH_FRIDGE_MULT ~= 0.5 and item:HasTag("fridge") then --icebox etc
			local fridge = tonumber(TUNING.PERISH_FRIDGE_MULT);
			if fridge then
				cn("frigde",round2(fridge,1))
			end
		end
		if viewer.boat_status_task and c.repairer and c.repairer.healthrepairvalue and c.repairer.healthrepairvalue ~= 0 then
			cn("repairer",round2(c.repairer.healthrepairvalue,2))
		end
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

		------------------Check prefabs?----------------------
		if prefab=="panflute" then
			--desc = cn("power","10")
		elseif prefab=="blowdart_sleep" then
			--desc = cn(desc,"1","power")
			--[[elseif prefab=="pond" and item.targettime then
                local tm = item.targettime - _G.GetTime()
                if tm>0 then
                    desc = "Broken "..cn(desc,tm,"sec")
                elseif item.broken then
                    desc = (desc=="" and "" or (desc.."\n")).."Broken"
                end--]]
		elseif prefab=="pond" or prefab=="pond_mos" or prefab=="pond_cave" or prefab=="oasislake" then
			if c.fishable and c.fishable.fishleft then
				cn(c.fishable.fishleft==1 and "fish" or "fishes",c.fishable.fishleft)
			end
		elseif prefab=="aqvarium" and item.data then
			if item.data.seeds and item.data.seeds>0 then
				table.insert(desc_table, "@Seeds: "..tostring(item.data.seeds))
			end
			if item.data.meat and item.data.meat>0 then
				table.insert(desc_table, "@Meat: "..tostring(item.data.meat))
				--desc = cn(desc,item.data.meat,"Meat:",true)
			end
			local need_wet= item.data.need_wet or 60
			if item.data.wet and item.data.wet>0 and item.data.wet<need_wet then
				table.insert(desc_table, "@Water: "..tostring(round2(100*item.data.wet/need_wet).."%"))
				--desc = cn(desc,round2(100*item.data.wet/need_wet).."%","Water:",true)
			end
			if item.total_heat then
				local temp = item.total_heat/10 --+ _G.TheWorld.state.temperature
				if temp>40 then temp = 40 end
				if temp>=0 then
					cn("temperature",tostring(round2(temp,1)))
				end
			end
		elseif prefab=="rainometer" then
			local function inSine(t, b, c, d)
				return -c * math.cos(t / d * (math.pi / 2)) + c + b
			end
			cn("precipitationrate",round2(inSine(_G.TheWorld.state.precipitationrate, 0, 0.75, 1),3).."/s")
			cn("wetness",round2(_G.TheWorld.state.wetness,1))
		elseif prefab=="winterometer" then
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
		elseif prefab=="moon_fissure" and c.sanityaura and c.sanityaura.aurafn then
			local current_sanity = c.sanityaura.aurafn(item, viewer)
			local max_sanity = 100/(TUNING.SEG_TIME*2) -- hardcoded!
			local effectiveness = current_sanity / max_sanity
			cn("effectiveness",round2(effectiveness * 100))
		elseif prefab=='boat' or prefab=='anchor' or prefab=='mast' or prefab=='boat_leak' or prefab=='mast_malbatross' or prefab=='steeringwheel' then
			--no info but boat status
			AddBoatStatus(viewer)
		end
		--Charges: lightning rod / lamp
		if item.chargeleft and item.chargeleft > 0 then
			table.insert(desc_table, "@Days left: "..tostring(math.floor(item.chargeleft+0.5)))
		end
		--Mod support:
		if item.GetShowItemInfo then
			local custom1, custom2, custom3 = item:GetShowItemInfo(viewer)
			if custom1 then table.insert(desc_table, "@"..tostring(custom1)) end
			if custom2 then table.insert(desc_table, "@"..tostring(custom2)) end
			if custom3 then table.insert(desc_table, "@"..tostring(custom3)) end
		end
		if c.pickable and c.pickable.task then --Трава и ветки.
			local targettime = c.pickable.targettime
			if targettime then
				local delta = targettime - GetTime()
				if delta > 0 then
					cn("grow_in",round2(delta/TUNING.TOTAL_DAY_TIME,1)) --days
				end
			end
		end
		--[[if c.witherable then
            local time = GetTime()
            table.insert(desc_table, "@witherable: "
                ..tostring(c.delay_to_time and (time-c.delay_to_time)) .. ", "
                ..tostring(c.task_to_time and (time-c.task_to_time)) .. ", "
                ..tostring(c.protect_to_time and (time-c.protect_to_time)) .. ", "
                ..tostring(c.is_watching_rain)
            )
        end
        if c.diseaseable then
            local time = GetTime()
            table.insert(desc_table, "@diseaseable: "
                --..tostring(c._spreadtask and (time-c.delay_to_time)) .. ", "
                --..tostring(c.task_to_time and (time-c.task_to_time)) .. ", "
                --..tostring(c.protect_to_time and (time-c.protect_to_time)) .. ", "
                --..tostring(c.is_watching_rain)
            )
        end--]]
		--Грядки - это на самом деле высаженные всходы (мышка наводится на них поверх грядок).
		if c.crop and c.crop.product_prefab and c.crop.product_prefab and c.crop.growthpercent
				and type(c.crop.growthpercent) == 'number' and c.crop.growthpercent < 1
		then
			--Передаем названием продукта и процент созревания (до целых).
			cn("crop",c.crop.product_prefab,round2(c.crop.growthpercent*100,0))
		end
		--c.unwrappable.itemdata[1].prefab
		--c.unwrappable.itemdata[1].data.perishable.time - оставшееся время порчи в секундах.
		--	   .stackable.stack - количество
		if show_buddle_item == 1 and c.unwrappable and c.unwrappable.itemdata and type(c.unwrappable.itemdata) == 'table' then
			--По одной строке на каждый предмет.
			for i,v in ipairs(c.unwrappable.itemdata) do
				if v.prefab then
					--Пересылаем название префаба и количество дней.
					local delta = v.data and v.data.perishable and v.data.perishable.time
					local count = v.data and v.data.stackable and v.data.stackable.stack
					cn('perish_product', v.prefab, count or 0, delta and round2(delta/TUNING.TOTAL_DAY_TIME,1))
				end
			end
		end
		--Боченок рассола из мода "Pickle It!"
		if c.pickler and c.pickler.targettime then
			local delta = c.pickler.targettime - GetTime()
			cn('just_time', round2(delta/TUNING.TOTAL_DAY_TIME,1))
		end
		--Для мода "Thirst" проверяем компонент "cwater"
		if c.cwater then
			local w = c.cwater
			--Особо не заморачиваемся. Просто выводим то, что в нём есть.
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
		--Stress points
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
		end
	end
	--Additional info for ALL prefabs (with health and without health)
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
	end
	--Depending from weapon info:
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
		local get_time = GetTime()
		local t = c.timer
		for name, data in pairs(t.timers) do
			if not IsUselessTimer(prefab,name) then
				--GetTimeLeft(name) IsPaused
				local tm = t:GetTimeLeft(name)
				local paused = t:IsPaused(name)
				if tm then
					cn('timer', round2(tm,0), name, paused and 1 or nil)
				else
					cn('timer', "-", name)
				end
			end
		end
	end
	if c.worldsettingstimer and c.worldsettingstimer.timers then --and c.GetTimeLeft and c.IsPaused then
		local get_time = GetTime()
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


----------------------------傳說覺悟 翻译，请勿搬运WeGame，为避免出现多个相同模组----------------------------
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


--Добавляем подсказку для игрока, через которую будем пересылать данные (всплывающий текст с инфой под именем предмета)
do
	--Функция возвращает подсказку, если она в точности совпадает с присланной информацией (в player_classified).
	--И возвращает подсказку, либо "".
	local function CheckUserHint(inst)
		local c = _G.ThePlayer and _G.ThePlayer.player_classified
		if c == nil then --Нет локального игрока или classified
			return ""
		end
		--c.showme_hint
		local i = string.find(c.showme_hint2,';',1,true)
		if i == nil then --Строка имеет неправильный формат.
			return ""
		end
		local guid = _G.tonumber(c.showme_hint2:sub(1,i-1))
		if guid ~= inst.GUID then --guid не совпадает (либо вообще nil)
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

		--Разбираем случаи, когда нужно отправить guid об объекте под мышью.
		local old_inst --Запоминаем, чтобы не спамить один и тот же inst по несколько раз.
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
				table.insert(arr,string.sub(str,pos,st-1)) -- Attach chars left of current divider
				pos = sp + 1 -- Jump past current divider
			end
			table.insert(arr,string.sub(str,pos)) -- Attach chars right of last divider
			return arr
		end

		local save_target
		local last_check_time = 0 --последнее время проверки. Будет устаревать каждые 2 сек.
		local LOCAL_STRING_CACHE = {} --База данных строк, чтобы не обсчитывать замены каждый раз (правда, будет потихоньку пожирать память)
		AddClassPostConstruct("widgets/hoverer",function(hoverer) --hoverer=self
			local old_SetString = hoverer.text.SetString
			local _debug_info = ''
			local NEWLINES_SHIFT = {
				'', --без инфы
				'', -- 1 инфо строка
				'', -- 2 инфо строки
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
					--target.widget.parent - это ItemTile
					target = target.widget ~= nil and target.widget.parent ~= nil and target.widget.parent.item --реальный итем (на клиенте)
				else
					target = _G.TheInput:GetWorldEntityUnderMouse()
				end
				--local lmb = hoverer.owner.components.playercontroller:GetLeftMouseAction()
				if target ~= nil then
					--print(tostring(target))
					--Проверяем совпадение с данными.
					local str2 = CheckUserHint(target)
					if str2 ~= "" then
						--Так, сначала чистим старую строку от переходов на новую строку. Мало ли какие там моды чего добавили.
						local cnt_newlines, _ = 0 --Считаем переходы строк в конце строки (совместимость с DFV)
						while cnt_newlines < #str do
							local ch = str:sub(#str-cnt_newlines,#str-cnt_newlines)
							if ch ~= "\n" and ch ~= " " then
								break
							end
							cnt_newlines = cnt_newlines + 1
						end
						--Очищаем строку от этого мусора
						if cnt_newlines > 0 then
							str = str:sub(1,#str-cnt_newlines)
						end
						--print(#str,"clear")
						--Очищаем строку от промежуточного мусора
						if string.find(str,"\n\n",1,true) ~= nil then
							str = str:gsub("[\n]+","\n")
						end

						if string.find(str,"\n",1,true) ~= nil then
							_,cnt_newlines = str:gsub("\n","\n") --Подсчитываем количество переходов внутри (если есть).
						else
							cnt_newlines = 0
						end


						--Извлекаем данные из полученной упакованной строки.
						str2 = UnpackData(str2,"\2")
						local arr2 = {} --Формируем массив данных в удобоваримом виде.
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
						--_G.rawset(_G,"arr2",arr2) --Для теста.
						--Формируем строку
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
					--Если первый раз, то отправляем запрос.
					if target ~= save_target or last_check_time + 1 < GetTime() then
						save_target = target
						last_check_time = GetTime()
						SendModRPCToServer(MOD_RPC.ShowMeSHint.Hint, save_target.GUID, save_target)
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

	--Обработчик на сервере
	AddModRPCHandler("ShowMeSHint", "Hint", function(player, guid, item)
		if player.player_classified == nil then
			print("ERROR: player_classified not found!")
			return
		end
		if item ~= nil and item.components ~= nil then
			local s = GetTestString(item,player) --Формируем строку на сервере.
			if s ~= "" then
				player.player_classified.net_showme_hint2:set(guid..";"..s) --Пакуем в строку и отсылаем обратно тому же игроку.
			end
		end
	end)

	--networking
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

--Обработка сундуков
do
	local MAIN_VAR_NAME = 'net_ShowMe_chest';
	local NETVAR_NAME = 'ShowMe_chestlq_.'; -- hash value: 983115,  Ratio: 0.000983115
	local EVENT_NAME = 'ShowMe_chest_dirty';
	--[[
	If you want add your custom chest, use this code:
		TUNING.MONITOR_CHESTS = TUNING.MONITOR_CHESTS or {}
		TUNING.MONITOR_CHESTS.chestprefab = true
	--]]
	local MONITOR_CHESTS = { treasurechest=1, dragonflychest=1, skullchest=1, pandoraschest=1, minotaurchest=1,
		--bundle=1, --No container component. =\
							 icebox=1, cookpot=1, -- No cookpot because it may be changed.
							 chester=1, hutch=1,
							 largechest=1, largeicebox=1, --Large Chest mod.
							 safebox=1, safechest=1, safeicebox=1, --Safe mod.
							 red_treasure_chest=1, purple_treasure_chest=1, green_treasure_chest=1, blue_treasure_chest=1, --Treasure Chests mod.
							 backpack=1, candybag=1, icepack=1, piggyback=1, krampus_sack=1, seedpouch=1,
							 venus_icebox=1, chesterchest=1, --SL mod
							 saltbox=1, wobybig=1, wobysmall=1, mushroom_light=1, mushroom_light2=1, fish_box=1, supertacklecontainer=1, tacklecontainer=1, archive_cookpot=1,
							 portablecookpot=1, sacred_chest=1,  --new
							 storeroom=1, alchmy_fur=1, myth_granary=1, hiddenmoonlight=1,--myth mod -- pill_bottle_gourd=1丹药葫芦,
							 ro_bin=1, roottrunk_child=1, corkchest=1, smelter=1, --Hamlet
							 thatchpack=1, packim=1, cargoboat=1, piratepack=1, --SW
	}
	if TUNING.MONITOR_CHESTS then
		for k in pairs(TUNING.MONITOR_CHESTS) do
			MONITOR_CHESTS[k] = 1
		end
	end
	local _active --Текущий предмет в курсоре (на клиенте).
	local _ing_prefab --Ингредиент. Через 5 секунд убирается.
	local net_string = _G.net_string
	local chests_around = {} --Массив всех сундуков в радиусе видимости клиента. Для хоста - все сундуки, но это норм.

	--[[
	_G.showme_count_chests = function() --debug function
		local cnt = 0
		for k,v in pairs(chests_around) do
			cnt = cnt + 1
		end
		print('Chests around:',cnt)
	end
	--]]

	local function OnClose(inst) --,err) --При закрытии сундука посылаем новые данные клиенту о его содержимом.
		local c = inst.components.container
		if not c then
			--[[if type(err) ~= "number" then err=nil end
			print('ERROR ShowMe: in ',inst.prefab,err)
			if not err then
				if inst.components then
					print("\tComponents:")
					for k in pairs(inst.components) do
						print("\t\t"..tostring(k))
					end
				else
					print("\tNo components at all!")
				end
			end
			if not err or err < 2000 then
				inst:DoTaskInTime(0,function(inst)
					OnClose(inst,err and (err+1) or 1)
				end)
			end--]]
			return
		end
		--if err then
		--	print("Found!!!!! Problem solved",err)
		--end
		if c:IsEmpty() then
			inst[MAIN_VAR_NAME]:set('')
			return
		end
		local arr = {} -- [префаб]=true
		--[[ Отрывок из предыдущего сочинения (чтобы знать, что там происходит):
		if c.unwrappable and c.unwrappable.itemdata and type(c.unwrappable.itemdata) == 'table' then
			--По одной строке на каждый предмет.
			for i,v in ipairs(c.unwrappable.itemdata) do
				if v.prefab then
					--Пересылаем название префаба и количество дней.
					local delta = v.data and v.data.perishable and v.data.perishable.time
					local count = v.data and v.data.stackable and v.data.stackable.stack
					cn('perish_product', v.prefab, count or 0, delta and round2(delta/TUNING.TOTAL_DAY_TIME,1))
				end
			end
		end--]]
		for k,v in pairs(c.slots) do
			arr[tostring(v.prefab)] = true
			local u = v.components and v.components.unwrappable
			if u and u.itemdata then
				for i,v in ipairs(u.itemdata) do
					arr[v.prefab] = true --Добавляем префаб в упаковке.
				end
			end
		end
		local s
		for k in pairs(arr) do
			if s then
				s = s .. ' ' .. k --Только пробельные символы будут далее работать.
			else
				s = k
			end
		end
		inst[MAIN_VAR_NAME]:set(s) --Посылаем данные.
	end

	--Обновляет подсветку сундука. Функция должна сама узнавать, что в руке игрока.
	local function UpdateChestColor(inst)
		local in_container = inst.ShowMe_chest_table and (
				(_active and inst.ShowMe_chest_table[_active.prefab])
						or (_ing_prefab and inst.ShowMe_chest_table[_ing_prefab])
		)
		if inst.b_ShowMe_changed_color then
			if not in_container then
				if inst.ShowMeColor then
					inst.ShowMeColor(true)
				else
					inst.AnimState:SetMultColour(1,1,1,1) --По умолчанию.
					inst.b_ShowMe_changed_color = nil
				end
			end
		else
			if in_container then
				if inst.ShowMeColor then
					inst.ShowMeColor(false)
				else
					inst.AnimState:SetMultColour(chestR,chestG,chestB,1)
					inst.b_ShowMe_changed_color = true
				end
			end
		end
	end

	local function OnShowMeChestDirty(inst)
		--inst.components.HuntGameLogic.hunt_kills = inst.components.HuntGameLogic.net_hunt_kills:value()
		local str = inst[MAIN_VAR_NAME]:value()
		--inst.test_str = str --test
		--print('Test Chest:',str)
		local t = inst.ShowMe_chest_table
		for k in pairs(t) do
			t[k] = nil
		end
		for w in string.gmatch(str, "%S+") do
			t[w] = true
		end
		UpdateChestColor(inst) --Перерисовывает данный конкретный сундук, если изменилось его содержимое.
	end

	local function InitChest(inst)
		inst[MAIN_VAR_NAME] = net_string(inst.GUID, NETVAR_NAME, EVENT_NAME )
		if CLIENT_SIDE then
			inst:ListenForEvent(EVENT_NAME, OnShowMeChestDirty)
			chests_around[inst] = true
			inst.ShowMe_chest_table = {}
			--inst.ShowTable = function() for k in pairs(inst.ShowMe_chest_table) do print(k) end end --debug
			inst:ListenForEvent('onremove', function(inst)
				chests_around[inst] = nil
			end)
		end
		if not SERVER_SIDE then
			return
		end
		inst:ListenForEvent("onclose", OnClose)
		inst:ListenForEvent("itemget", OnClose) --Для рюкзаков.
		--There is inject in SmarterCrockPot!! : ContainerWidget.old_on_item_lose = ContainerWidget.OnItemLose
		inst:ListenForEvent("itemlose", OnClose)
		inst:DoTaskInTime(0,function(inst)
			OnClose(inst) --Изначально тоже посылаем данные, а не только при закрытии. Ведь сундук мог быть загружен.
		end)
	end

	for k in pairs(MONITOR_CHESTS) do
		AddPrefabPostInit(k,InitChest)
	end
	--Фиксим игрока, чтобы мониторить действия курсора.
	if CLIENT_SIDE then
		local function UpdateAllChestsAround()
			for k in pairs(chests_around) do
				UpdateChestColor(k)
			end
		end
		AddPrefabPostInit("inventory_classified",function(inst)
			inst:ListenForEvent("activedirty", function(inst)
				--print("ACTIVE:",inst._active:value())
				_active = inst._active:value()
				_ing_prefab = nil --Если взят предмет, то рецепт сразу же забываем.
				UpdateAllChestsAround() --Перерисовываем ВСЕ сундуки при каждом активном предмете или его отмене.
			end)
		end)

		local _ing_task
		local function UpdateIngredientView(player, prefab)
			_ing_prefab = prefab
			UpdateAllChestsAround()
			if _ing_task then
				_ing_task:Cancel()
			end
			_ing_task = player:DoTaskInTime(15,function(inst)
				_ing_prefab = nil
				_ing_task = nil
				UpdateAllChestsAround()
			end)
		end

		local ingredientui = _G.require 'widgets/ingredientui'
		local old_OnGainFocus = ingredientui.OnGainFocus

		function ingredientui:OnGainFocus(...)
			local prefab = self.ing and self.ing.texture and self.ing.texture:match('[^/]+$'):gsub('%.tex$', '')
			local player = self.parent and self.parent.parent and self.parent.parent.owner

			if prefab and player then
				--print("INGREDIENT:",prefab)
				UpdateIngredientView(player,prefab)
			end
			if old_OnGainFocus then
				return old_OnGainFocus(self, ...)
			end
		end
	end
end
----------------------------------------