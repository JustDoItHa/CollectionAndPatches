local TheNet = GLOBAL.TheNet
local IsServer = TheNet:GetIsServer() or TheNet:IsDedicated()
GLOBAL.setmetatable(env, { __index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end })
local AddPrefabPostInit = AddPrefabPostInit

if IsServer then
	---------------------------------------------------------------------鸟笼批量换蛋-------------------------------------------------------------------
	--原函数定义
	local function DigestFood(inst, food)
		if food.components.edible.foodtype == FOODTYPE.MEAT then
			--If the food is meat:
			--Spawn an egg.
			if inst.components.occupiable and inst.components.occupiable:GetOccupant() and inst.components.occupiable:GetOccupant():HasTag("bird_mutant") then  --变异鸟
				inst.components.lootdropper:SpawnLootPrefab("rottenegg")        --烂鸡蛋
			else
				inst.components.lootdropper:SpawnLootPrefab("bird_egg")         --鸡蛋
			end
		else
			if inst.components.occupiable and inst.components.occupiable:GetOccupant() and inst.components.occupiable:GetOccupant():HasTag("bird_mutant") then
				inst.components.lootdropper:SpawnLootPrefab("spoiled_food")     --腐烂食物

			else
				local seed_name = string.lower(food.prefab .. "_seeds")
				if GLOBAL.Prefabs[seed_name] ~= nil then
					inst.components.lootdropper:SpawnLootPrefab(seed_name)
				else
					--Otherwise...
					--Spawn a poop 1/3 times.
					if math.random() < 0.33 then
						local loot = inst.components.lootdropper:SpawnLootPrefab("guano")       --鸟粪
						loot.Transform:SetScale(.33, .33, .33)
					end
				end
			end
		end

		--Refill bird stomach.
		local bird = (inst.components.occupiable and inst.components.occupiable:GetOccupant()) or nil
		if bird and bird:IsValid() and bird.components.perishable then
			bird.components.perishable:SetPercent(1)
		end
	end

	AddPrefabPostInit("birdcage",function (inst)
		local oldonaccept = inst.components.trader.onaccept
		inst.components.trader.onaccept = function (inst, giver, item)
			if inst.components.sleeper and inst.components.sleeper:IsAsleep() then          --不许睡
				inst.components.sleeper:WakeUp()
			end

			if item.components.edible ~= nil and        --喂食类别
					(item.components.edible.foodtype == GLOBAL.FOODTYPE.MEAT
							or item.prefab == "seeds"
							or string.match(item.prefab, "_seeds")
							or GLOBAL.Prefabs[string.lower(item.prefab .. "_seeds")] ~= nil) then
				inst.AnimState:PlayAnimation("peck")
				inst.AnimState:PushAnimation("peck")
				inst.AnimState:PushAnimation("peck")
				inst.AnimState:PushAnimation("hop")
				inst:DoTaskInTime(60 * GLOBAL.FRAMES, function(inst, item)
					local num = item.components.stackable and item.components.stackable:StackSize() or 1
					if num then
						for i = 1, num do
							DigestFood(inst, item)
						end
					end
				end,item)
			end
		end
	end)

	------------------------------------------------------------------------------------------------------------------------------------------------------
	----------------------------------------------------------------猪王批量换金块-------------------------------------------------------------------------
	------------------------------------------------------------------------------------------------------------------------------------------------------
	local function launchitem(item, angle)
		local speed = math.random() * 4 + 2
		angle = (angle + math.random() * 60 - 30) * DEGREES
		item.Physics:SetVel(speed * math.cos(angle), math.random() * 2 + 8, speed * math.sin(angle))
	end

	local function ontradeforgold(inst, item, giver)
		AwardPlayerAchievement("pigking_trader", giver)

		local x, y, z = inst.Transform:GetWorldPosition()
		y = 4.5

		local angle
		if giver ~= nil and giver:IsValid() then
			angle = 180 - giver:GetAngleToPoint(x, 0, z)
		else
			local down = TheCamera:GetDownVec()
			angle = math.atan2(down.z, down.x) / DEGREES
			giver = nil
		end

		for k = 1, item.components.tradable.goldvalue do
			local nug = SpawnPrefab("goldnugget")
			nug.Transform:SetPosition(x, y, z)
			launchitem(nug, angle)
		end

		if item.components.tradable.tradefor ~= nil then
			for _, v in pairs(item.components.tradable.tradefor) do
				local item = SpawnPrefab(v)
				if item ~= nil then
					item.Transform:SetPosition(x, y, z)
					launchitem(item, angle)
				end
			end
		end

		if IsSpecialEventActive(SPECIAL_EVENTS.HALLOWED_NIGHTS) then
			-- pick out up to 3 types of candies to throw out
			local candytypes = { math.random(NUM_HALLOWEENCANDY), math.random(NUM_HALLOWEENCANDY), math.random(NUM_HALLOWEENCANDY) }
			local numcandies = (item.components.tradable.halloweencandyvalue or 1) + math.random(2) + 2

			-- only people in costumes get a good amount of candy!
			if giver ~= nil and giver.components.skinner ~= nil then
				for _, item in pairs(giver.components.skinner:GetClothing()) do
					if DoesItemHaveTag(item, "COSTUME") or DoesItemHaveTag(item, "HALLOWED") then
						numcandies = numcandies + math.random(4) + 2
						break
					end
				end
			end

			for k = 1, numcandies do
				local candy = SpawnPrefab("halloweencandy_"..GetRandomItem(candytypes))
				candy.Transform:SetPosition(x, y, z)
				launchitem(candy, angle)
			end
		end
	end

	AddPrefabPostInit("pigking",function (inst)
		local oldonaccept = inst.components.trader.onaccept
		inst.components.trader.onaccept =  function (inst, giver, item)
			local is_event_item = IsSpecialEventActive(SPECIAL_EVENTS.HALLOWED_NIGHTS) and item.components.tradable.halloweencandyvalue and item.components.tradable.halloweencandyvalue > 0
			if item.components.tradable.goldvalue > 0 or is_event_item then
				inst.sg:GoToState("cointoss")
				local num = item.components.stackable and item.components.stackable:StackSize() or 1
				if num then
					inst:DoTaskInTime(2 / 3, function()
						for i = 1, num do
							ontradeforgold(inst, item, giver)
						end
					end ,item, giver)
				end
			else oldonaccept(inst, giver, item)
				StartMinigame(inst)
			end
		end
	end)
	---------------------------------------------------------------------------------------------------------------------------------------------------------
	-----------------------------------------------------------------蚁狮批量换沙之石-----------------------------------------------------------------------------
	---------------------------------------------------------------------------------------------------------------------------------------------------------
	AddPrefabPostInit("antlion",function (inst)
		local oldonaccept = inst.components.trader.onaccept     --旧函数
		inst.components.trader.onaccept = function (inst, giver, item)
			if item.components.unwrappable then                 -- 兼容勋章
				oldonaccept(inst, giver, item)
				return
			end
			if item.currentTempRange ~= nil then                    --贡品温度
				-- NOTES(JBK): currentTempRange is only on heatrock and now dumbbell_heat no need to check prefab here.
				local trigger =
				(item.currentTempRange <= 1 and "freeze") or
						(item.currentTempRange >= 4 and "burn") or
						nil
				if trigger ~= nil then
					inst:PushEvent("onacceptfighttribute", { tributer = giver, trigger = trigger })
					return
				end
			end

			inst.tributer = giver   --献祭者

			local num = item.components.stackable and item.components.stackable:StackSize() or 1
			if item.prefab == "antliontrinket" or item.prefab == "cotl_trinket" or item.components.tradable.goldvalue > 0 then
				inst.pendingrewarditem ={}
				for i = 1 ,num do
					if item.prefab == "antliontrinket" then             --沙滩玩具
						table.insert(inst.pendingrewarditem,"townportal_blueprint")
						table.insert(inst.pendingrewarditem,"antlionhat_blueprint")
					elseif item.prefab == "cotl_trinket" then           --红冠
						table.insert(inst.pendingrewarditem,"turf_cotl_brick_blueprint")
						table.insert(inst.pendingrewarditem,"turf_cotl_gold_blueprint")
						table.insert(inst.pendingrewarditem,"cotl_tabernacle_level1_blueprint")
					elseif item.components.tradable.goldvalue > 0 then  --普通玩具
						table.insert(inst.pendingrewarditem,"townportaltalisman")
					end
				end
			else
				inst.pendingrewarditem = nil
			end
			local rage_calming = item.components.tradable.rocktribute * TUNING.ANTLION_TRIBUTE_TO_RAGE_TIME * num   --平息时间乘堆叠数
			inst.maxragetime = math.min(inst.maxragetime + rage_calming, TUNING.ANTLION_RAGE_TIME_MAX)

			local timeleft = inst.components.worldsettingstimer:GetTimeLeft(ANTLION_RAGE_TIMER)
			if timeleft ~= nil then
				timeleft = math.min(timeleft + rage_calming, TUNING.ANTLION_RAGE_TIME_MAX)
				inst.components.worldsettingstimer:SetTimeLeft(ANTLION_RAGE_TIMER, timeleft)
				inst.components.worldsettingstimer:ResumeTimer(ANTLION_RAGE_TIMER)
			else
				inst.components.worldsettingstimer:StartTimer(ANTLION_RAGE_TIMER, inst.maxragetime)
			end
			inst.components.sinkholespawner:StopSinkholes()

			inst:PushEvent("onaccepttribute", { tributepercent = (timeleft or 0) / TUNING.ANTLION_RAGE_TIME_MAX })

			if giver ~= nil and giver.components.talker ~= nil and GetTime() - (inst.timesincelasttalker or -TUNING.ANTLION_TRIBUTER_TALKER_TIME) > TUNING.ANTLION_TRIBUTER_TALKER_TIME then
				inst.timesincelasttalker = GetTime()
				giver.components.talker:Say(GetString(giver, "ANNOUNCE_ANTLION_TRIBUTE"))
			end
			return item
		end
	end)
	------------------------------------------------------------------------------------------------------------------------------------------------------------------
	local actions_give_fn = GLOBAL.ACTIONS.GIVE.fn
	GLOBAL.ACTIONS.GIVE.fn = function(act)
		if act.target and act.target.prefab == "birdcage" or act.target.prefab == "pigking" or act.target.prefab == "antlion" then
			local pigking = act.target
			local abletoaccept, reason = pigking.components.trader:AbleToAccept(act.invobject, act.doer)
			if abletoaccept then
				local cnt = act.invobject.components.stackable and act.invobject.components.stackable:StackSize() or 1
				pigking.components.trader:AcceptGift(act.doer, act.invobject, cnt)
				return true
			else
				return false, reason
			end
			local num = (act.invobject and act.invobject.components and act.invobject.components.stackable) and act.invobject.components.stackable:StackSize() or 1
			if act.invobject.prefab == "pig_token" then num = 1 end
			act.target.components.trader:AcceptGift(act.doer, act.invobject,num)
			return true
		end
		return actions_give_fn(act)
	end
end