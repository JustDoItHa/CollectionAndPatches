
GLOBAL.setmetatable(env,{__index=function(t,k)return GLOBAL.rawget(GLOBAL,k)end})

local containers = require("containers")
local MAX_STACK_SIZE = TUNING.STACK_SIZE_MEDITEM -- 兼容修改堆叠的mod

local params = {}
local containers_widgetsetup_base = containers.widgetsetup
function containers.widgetsetup(container, prefab, data, ...)
	local t = params[prefab or container.inst.prefab]
	if t ~= nil then
		for k, v in pairs(t) do
			container[k] = v
		end
		container:SetNumSlots(container.widget.slotpos ~= nil and #container.widget.slotpos or 0)
	else
		containers_widgetsetup_base(container, prefab, data, ...)
	end
end

local iaipk = {
	widget =
	{
		slotpos = {},
		animbank = "ui_chester_shadow_3x4",
		animbuild = "ui_chester_shadow_3x4",
		pos = Vector3(0, -120, 0),
		side_align_tip = 0,
		buttoninfo =
		{
			text = "交易",
			position = Vector3(0, -170, 0),
		}
	},
	type = "iaipk",
}
for y = 2.5, -0.5, -1 do
	for x = 0, 2 do
		table.insert(iaipk.widget.slotpos, Vector3(75*x-75*2+75, 75*y-75*2+75,0))
	end
end

params.iaipk = iaipk

for k, v in pairs(params) do
	containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, v.widget.slotpos ~= nil and #v.widget.slotpos or 0)
end

local function MakeGiftTable(fullslotnum, restnum, maxstack)
	local prefab = "goldnugget"
	local t = {}
	if fullslotnum > 0 then
		for i=1, fullslotnum do
			table.insert(t, {prefab = prefab, count = maxstack})
		end
	end
	if fullslotnum < 4 then
		if restnum > 0 then
			table.insert(t, {prefab = prefab, count = restnum})
		end
	end
	return t
end

local function MakeGift(t)
	local items = {}
	for i=1, #t do
		local myitem = SpawnPrefab(t[i].prefab)
		if t[i].count > 1 then
			myitem.components.stackable:SetStackSize(t[i].count)
		end
		table.insert(items, myitem)
	end

	local gift = SpawnPrefab("gift")
	gift.components.unwrappable:WrapItems(items)
	for i, v in ipairs(items) do
		v:Remove()
	end
	return gift
end

local function bfn(player, inst)
	if TheWorld.state.isnight then player.components.talker:Say("现在是睡觉时间！") return end
	local item
	local extra_item = {}
	local num = 0
	for i=1,12 do
		item = inst.components.container:GetItemInSlot(i)
		local stack = 1
		if item ~= nil then
			local gold = 0
			if item.components.edible and item.components.edible.foodtype == FOODTYPE.MEAT then
				gold = 1
			end
			if item.components.tradable and item.components.tradable.goldvalue > 0 then
				gold = item.components.tradable.goldvalue
			end
			if gold > 0 then
				if item.components.stackable then
					stack = item.components.stackable:StackSize()
				end
				num = num + stack * gold
				inst.components.container:ConsumeByName(item.prefab, stack)
			end
			-- 兼容棋子交换给图纸
			if item.components.tradable and item.components.tradable.tradefor ~= nil then
				local chess_stack = 1
				if item.components.stackable then
					chess_stack = item.components.stackable:StackSize()
				end
				for _,v in pairs(item.components.tradable.tradefor) do
					for j=1,chess_stack do
						table.insert(extra_item, v)
					end
				end
			end
		end
	end
	local item

	local maxstack = MAX_STACK_SIZE or 20 --20
	local maxpack = maxstack * 4 --80
	local fullpacknum = math.floor(num / maxpack) -- 满包数
	local restpackitemnum = num % maxpack -- 剩余非满包内容物总数
	local restpackfullslotnum = math.floor(restpackitemnum / maxstack) -- 剩余非满包满堆叠格子数
	local restpackrestnum = restpackitemnum % maxstack -- 剩余非满包剩余物品数
	-- 生成满包
	if fullpacknum > 0 then
		for i=1, fullpacknum do
			item = MakeGift(MakeGiftTable(4, 0, maxstack))
			if item then inst.components.container:GiveItem(item) end
		end
	end
	-- 生成剩余包
	if restpackitemnum > 0 then
		item = MakeGift(MakeGiftTable(restpackfullslotnum, restpackrestnum, maxstack))
		if item then inst.components.container:GiveItem(item) end
	end
	-- 生成棋子图纸
	for _,v in pairs(extra_item) do
		local chess = SpawnPrefab(v)
		inst.components.container:GiveItem(chess)
	end
	--[[
		local str =
			"\n"..
			"总金子数："..num.."\n"..
			"最大堆叠："..maxstack.."\n"..
			"满包数  ："..fullpacknum.."\n"..
			"剩余总数："..restpackitemnum.."\n"..
			"剩余满格："..restpackfullslotnum.."\n"..
			"剩余剩余："..restpackrestnum.."\n"
		print(str)
	]]
	if item or #extra_item > 0 then
		player.SoundEmitter:PlaySound("dontstarve/wilson/equip_item_gold")
	end
end

function params.iaipk.widget.buttoninfo.fn(inst, doer)
	if TheWorld.ismastersim then
		bfn(doer, inst)
	else
		SendModRPCToServer(MOD_RPC["iaipk"]["iaipk"], inst)
	end
end

local function pk(inst)
	if not TheWorld.ismastersim then
		-- inst:DoTaskInTime(0, function()
		-- if inst.replica then
		-- if inst.replica.container then
		-- inst.replica.container:WidgetSetup("iaipk")
		-- end
		-- end
		-- end)
		inst.OnEntityReplicated = function(inst)
			inst.replica.container:WidgetSetup("iaipk")
		end
		return inst
	end
	if TheWorld.ismastersim then
		local temp = SpawnPrefab("goldnugget")
		if temp then
			if temp.components.stackable then
				MAX_STACK_SIZE = temp.components.stackable.maxsize
			end
			temp:Remove()
		end
		if not inst.components.container then
			inst:AddComponent("container")
			inst.components.container:WidgetSetup("iaipk")
		end
	end
end

AddModRPCHandler("iaipk", "iaipk", bfn)
AddPrefabPostInit("pigking", pk)


-----------------------------------------------------------
--[[
local require = GLOBAL.require
local Vector3 = GLOBAL.Vector3
local SpawnPrefab = GLOBAL.SpawnPrefab
local containers = require("containers")

local params = {}

local containers_widgetsetup_base = containers.widgetsetup
function containers.widgetsetup(container, prefab, data, ...)
    local t = params[prefab or container.inst.prefab]
    if t ~= nil then
        for k, v in pairs(t) do
            container[k] = v
        end
        container:SetNumSlots(container.widget.slotpos ~= nil and #container.widget.slotpos or 0)
    else
        containers_widgetsetup_base(container, prefab, data, ...)
    end
end

local fasttrade =
{
	widget =
	{
		slotpos = {},
		animbank = "ui_chest_3x3",
		animbuild = "ui_chest_3x3",
		pos = Vector3(0, -60, 0),
        side_align_tip = 160,
		buttoninfo =
        {
            text = "交易",
            position = Vector3(0, -150, 0),
        },
	},
	type = "fasttrade",
}

local fasttradebird =
{
	widget =
	{
		slotpos = {},
		animbank = "ui_chest_3x3",
		animbuild = "ui_chest_3x3",
		pos = Vector3(0, -200, 0),
        side_align_tip = 160,
		buttoninfo =
        {
            text = "放入鸟笼",
            position = Vector3(0, -180, 0),
        },
	},
	type = "fasttradebird",
}
params.fasttrade = fasttrade
for y = 2, 0, -1 do
    for x = 0, 2 do
        table.insert(params.fasttrade.widget.slotpos, Vector3(80 * x - 80 * 2 + 80, 80 * y - 80 * 2 + 80, 0))
    end
end

params.fasttradebird = fasttradebird
for y = 2, 0, -1 do
    for x = 0, 2 do
        table.insert(params.fasttradebird.widget.slotpos, Vector3(80 * x - 80 * 2 + 80, 80 * y - 80 * 2 + 80, 0))
    end
end

for k, v in pairs(params) do
    containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, v.widget.slotpos ~= nil and #v.widget.slotpos or 0)
end

local function MakeGiftPack(fullslotnum, restnum, maxstack, prefab)
	local t = {}
	if fullslotnum > 0 then
		for i=1, fullslotnum do
			table.insert(t, {prefab = prefab, count = maxstack})
		end
	end
	if fullslotnum < 4 then
		if restnum > 0 then
			table.insert(t, {prefab = prefab, count = restnum})
		end
	end
	return t
end

local function MakeGift(t)
	local items = {}
	for i=1, #t do
		local myitem = GLOBAL.SpawnPrefab(t[i].prefab)
		if t[i].count > 1 then
			myitem.components.stackable:SetStackSize(t[i].count)
		end
		table.insert(items, myitem)
	end

	local gift = GLOBAL.SpawnPrefab("gift")
	gift.components.unwrappable:WrapItems(items)
	for i, v in ipairs(items) do
		v:Remove()
	end
	return gift
end

local invalid_foods =
{
    "bird_egg",
    "bird_egg_cooked",
    "rottenegg",
    -- "monstermeat",
    -- "cookedmonstermeat",
    -- "monstermeat_dried",
}
local function ShouldAcceptItem(item)
    local seed_name = string.lower(item.prefab .. "_seeds")

    local can_accept = item.components.edible
        and (GLOBAL.Prefabs[seed_name]
        or item.prefab == "seeds"
        or string.match(item.prefab, "_seeds")
        or item.components.edible.foodtype == GLOBAL.FOODTYPE.MEAT)

    if table.contains(invalid_foods, item.prefab) then
        can_accept = false
    end

    return can_accept
end

local function tradeBird(inst)
	local item
	local num = 0
	for i=1, 9 do
		item = inst.components.container:GetItemInSlot(i)
		local stack = 1
		if item ~= nil and ShouldAcceptItem(item) then
			local giveitem
			if item.components.edible and item.components.edible.foodtype == GLOBAL.FOODTYPE.MEAT then
				--If the food is meat:
					--Spawn an egg.
				if inst.components.occupiable and inst.components.occupiable:GetOccupant() and inst.components.occupiable:GetOccupant():HasTag("bird_mutant") then
					giveitem = SpawnPrefab("rottenegg")
				else
					giveitem = SpawnPrefab("bird_egg")
				end
			else
				if inst.components.occupiable and inst.components.occupiable:GetOccupant() and inst.components.occupiable:GetOccupant():HasTag("bird_mutant") then
					giveitem = SpawnPrefab("spoiled_food")
				else
					local seed_name = string.lower(item.prefab .. "_seeds")
					if GLOBAL.Prefabs[seed_name] ~= nil then
						giveitem = SpawnPrefab(seed_name)
					else
						--Otherwise...
							--Spawn a poop 1/3 times.
						if math.random() < 0.33 then
							giveitem = SpawnPrefab("guano")
						end
					end
				end
			end
			if item.components.stackable then
				stack = item.components.stackable:StackSize()
			end
			if giveitem then
				giveitem.components.stackable:SetStackSize(stack)
				inst.components.container:ConsumeByName(item.prefab, stack)
				inst.components.container:GiveItem(giveitem)
			end
		end
	end
end
local function launchitem(item, angle)
    local speed = math.random() * 4 + 2
    angle = (angle + math.random() * 60 - 30) * GLOBAL.DEGREES
    item.Physics:SetVel(speed * math.cos(angle), math.random() * 2 + 8, speed * math.sin(angle))
end

local function tradePigKing(inst)
	local item
	local num = 0
	for i=1, 9 do
		item = inst.components.container:GetItemInSlot(i)
		local stack = 1
		if item ~= nil then
			local gold = 0
			if item.components.edible and item.components.edible.foodtype == GLOBAL.FOODTYPE.MEAT then
				gold = 1
			end
			if item.components.tradable and item.components.tradable.goldvalue > 0 then
				gold = item.components.tradable.goldvalue
			end
			if gold > 0 then
				if item.components.stackable then
					stack = item.components.stackable:StackSize()
				end
				num = num + stack * gold
				inst.components.container:ConsumeByName(item.prefab, stack)
			end
			local x, y, z = inst.Transform:GetWorldPosition()
			y = 4.5

			if item.components.tradable and item.components.tradable.tradefor ~= nil then
				for _, v in pairs(item.components.tradable.tradefor) do
					local prefab = SpawnPrefab(v)
					if prefab ~= nil then
						prefab.Transform:SetPosition(x, y, z)
						launchitem(prefab, 90)
					end
				end
			end
		end
	end
	return num,"goldnugget"
end


local function fasttradeHandler(player, inst)
	local num,prefab
	if inst.prefab == "pigking" then
		if GLOBAL.TheWorld.state.isnight then player.components.talker:Say("不要打扰王的休息！")
			return
		end

		num,prefab = tradePigKing(inst)
		local maxstack = GLOBAL.TUNING.STACK_SIZE_MEDITEM
		local maxpack = maxstack * 4
		local fullpacknum = math.floor(num / maxpack)
		local restpackitemnum = num % maxpack
		local restpackfullslotnum = math.floor(restpackitemnum / maxstack)
		local restpackrestnum = restpackitemnum % maxstack
		local item
		if fullpacknum > 0 then
			for i=1, fullpacknum do
				item = MakeGift(MakeGiftPack(4, 0, maxstack, prefab))
				if item then inst.components.container:GiveItem(item) end
			end
		end
		if restpackitemnum > 0 then
			item = MakeGift(MakeGiftPack(restpackfullslotnum, restpackrestnum, maxstack, prefab))
			if item then inst.components.container:GiveItem(item) end
		end
		if item then
			player.SoundEmitter:PlaySound("dontstarve/wilson/equip_item_gold")
		end
	elseif inst.prefab == "birdcage" then
		if inst.components.sleeper and inst.components.sleeper:IsAsleep() then
			player.components.talker:Say("求求你让它先睡一会！")
			return
		end
		tradeBird(inst)
	end
end

local function fasttradeStoreHandler(player, inst)
	for i = 1, 9 do
		local item = inst.components.container:GetItemInSlot(i)
		if item and item:HasTag(inst.components.occupiable.occupanttype) and item.components.occupier ~= nil then
			inst.components.occupiable:Occupy(item)
			inst.components.container:RemoveItem(item, 1)
			break
		end
	end
end

function params.fasttrade.widget.buttoninfo.fn(inst, doer)
    if GLOBAL.TheNet:GetIsServer() then
        fasttradeHandler(doer, inst)
    else
        SendModRPCToServer(GLOBAL.MOD_RPC["fasttrade"]["fasttrade"], inst)
    end
end

function params.fasttradebird.widget.buttoninfo.fn(inst, doer)
	if GLOBAL.TheNet:GetIsServer() then
		if inst.AnimState:IsCurrentAnimation("idle_empty") then
			fasttradeStoreHandler(doer, inst)
		else
			fasttradeHandler(doer,inst)
		end
	else
		if inst.AnimState:IsCurrentAnimation("idle_empty") then
			SendModRPCToServer(GLOBAL.MOD_RPC["fasttrade"]["store"], inst)
		else
			SendModRPCToServer(GLOBAL.MOD_RPC["fasttrade"]["fasttrade"], inst)
		end
    end
end

local function fasttradefn(inst)
    if GLOBAL.TheNet:GetIsClient() then
		inst.OnEntityReplicated = function(inst)
			inst.replica.container:WidgetSetup("fasttrade")
		end
        return inst
    end
    if not GLOBAL.TheNet:GetIsClient() then
        if not inst.components.container then
            inst:AddComponent("container")
            inst.components.container:WidgetSetup("fasttrade")
        end
    end
end

local function fasttradebirdfn(inst)
    if GLOBAL.TheNet:GetIsClient() then
		inst.OnEntityReplicated = function(inst)
			inst.replica.container:WidgetSetup("fasttradebird")
		end
        return inst
    end
    if not GLOBAL.TheNet:GetIsClient() then
        if not inst.components.container then
            inst:AddComponent("container")
            inst.components.container:WidgetSetup("fasttradebird")
        end
    end
end

local function openHandler(player, inst)
	inst.components.container:Open(player)
end


AddComponentPostInit("playercontroller", function(self, inst)
    if inst ~= GLOBAL.ThePlayer then return end
    local ThePlayer = GLOBAL.ThePlayer
    local PlayerControllerOnControl = self.OnControl
    self.OnControl = function(self, control, down)
        if control == GLOBAL.CONTROL_SECONDARY then
            if down then
				local target = GLOBAL.TheInput:GetWorldEntityUnderMouse()
				if target and target.prefab == "birdcage" and ThePlayer:GetDistanceSqToInst(target) < 1.5 then
					if GLOBAL.TheNet:GetIsServer() then
						openHandler(ThePlayer,target)
					else
						SendModRPCToServer(GLOBAL.MOD_RPC["fasttrade"]["open"], target)
					end
				end
			end
        elseif control == GLOBAL.CONTROL_PRIMARY then
			if down then
				local target = GLOBAL.TheInput:GetWorldEntityUnderMouse()
				if target and target.prefab == "birdcage" then
					if GLOBAL.TheInput:IsKeyDown(GLOBAL.KEY_LCTRL) then
						SendModRPCToServer(GLOBAL.MOD_RPC["fasttrade"]["birdcagetrade_start"], target)
					else
						SendModRPCToServer(GLOBAL.MOD_RPC["fasttrade"]["birdcagetrade_end"], target)
					end
				end
			end
        end
		PlayerControllerOnControl(self, control, down)
    end
end)

local function GetBird(inst)
    return (inst.components.occupiable and inst.components.occupiable:GetOccupant()) or nil
end

local function DigestFood(inst, food, count)
    --Refill bird stomach.
    local bird = GetBird(inst)
    if bird and bird:IsValid() and bird.components.perishable then
        bird.components.perishable:SetPercent(1)
    end

	if food.components.edible.foodtype == GLOBAL.FOODTYPE.MEAT then
        --If the food is meat:
            --Spawn an egg.
        if inst.components.occupiable and inst.components.occupiable:GetOccupant() and inst.components.occupiable:GetOccupant():HasTag("bird_mutant") then
            return "rottenegg",count
        else
            return "bird_egg",count
        end
    else
        if inst.components.occupiable and inst.components.occupiable:GetOccupant() and inst.components.occupiable:GetOccupant():HasTag("bird_mutant") then
            return "spoiled_food",count

        else
            local seed_name = string.lower(food.prefab .. "_seeds")
            if GLOBAL.Prefabs[seed_name] ~= nil then
    			return seed_name,count
            else
                --Otherwise...
                    --Spawn a poop 1/3 times.
				local num = 0
				for i = 0,count do
					if math.random() < 0.33 then
						num = num + 1
					end
				end
				return "guano",num
				-- local loot = inst.components.lootdropper:SpawnLootPrefab("guano")
				-- loot.Transform:SetScale(.33, .33, .33)
            end
        end
    end
end

local function PushStateAnim(inst, anim, loop)
    inst.AnimState:PushAnimation(anim..inst.CAGE_STATE, loop)
end

local function OnGetItem(inst, giver, item)
    --If you're sleeping, wake up.
    if inst.components.sleeper and inst.components.sleeper:IsAsleep() then
        inst.components.sleeper:WakeUp()
    end
    if item.components.edible ~= nil and
        (   item.components.edible.foodtype == GLOBAL.FOODTYPE.MEAT
            or item.prefab == "seeds"
            or string.match(item.prefab, "_seeds")
            or GLOBAL.Prefabs[string.lower(item.prefab .. "_seeds")] ~= nil
        ) then
        --If the item is edible...
        --Play some animations (peck, peck, peck, hop, idle)
        inst.AnimState:PlayAnimation("peck")
        inst.AnimState:PushAnimation("peck")
        inst.AnimState:PushAnimation("peck")
        inst.AnimState:PushAnimation("hop")
       PushStateAnim(inst, "idle", true)
        --Digest Food in 60 frames.
		local num = 1
		if item.components.stackable then
			num = item.components.stackable:StackSize()
		end
		local prefab,count = DigestFood(inst,item,num)
		if prefab then
			local loot = inst.components.lootdropper:SpawnLootPrefab(prefab)
			if loot.components.stackable then

				loot.components.stackable:SetStackSize(count)
			end
			if prefab == "guano" then
				loot.Transform:SetScale(.33, .33, .33)
			end
		end
    end
end

local function birdcagetradeStartHandler(player, inst)
	if inst.fastTradeBirdcage == nil then
		inst.fastTradeBirdcage = {}
	end
	inst.fastTradeBirdcage[player] = true
end

local function birdcagetradeEndHandler(player, inst)
	if inst.fastTradeBirdcage == nil then
		inst.fastTradeBirdcage = {}
	end
	inst.fastTradeBirdcage[player] = false
end


local function fasttradebirdfn1(inst)
	if not GLOBAL.TheNet:GetIsClient() then
        inst.components.trader.onaccept = OnGetItem
    end
end

local actions_give_fn = GLOBAL.ACTIONS.GIVE.fn
GLOBAL.ACTIONS.GIVE.fn = function(act)
	if act.target and act.target.prefab == "birdcage" and act.target.fastTradeBirdcage and act.target.fastTradeBirdcage[act.doer] then
		local abletoaccept, reason = act.target.components.trader:AbleToAccept(act.invobject,act.doer)
		if abletoaccept then
			local cnt = 1
			if act.invobject.components.stackable ~= nil  then
				cnt = act.invobject.components.stackable:StackSize()
			end
			act.target.components.trader:AcceptGift(act.doer, act.invobject,cnt)
			return true
		else
			return false, reason
		end
	else
		return actions_give_fn(act)
	end
end

local function fasttradebirdfn2(inst)
	if not GLOBAL.TheNet:GetIsClient() then
		local actions_feed_fn = GLOBAL.ACTIONS.FEED.fn
		GLOBAL.ACTIONS.FEED.fn = function(act)
			if act.target.prefab == "birdcage" and inst.fastTradeBirdcage and inst.fastTradeBirdcage[inst.doer] then
				local abletoaccept, reason = act.target.components.trader:AbleToAccept(act.invobject,act.doer)
				if abletoaccept then
					local cnt = 1
					if act.invobject.components.stackable ~= nil  then
						cnt = act.invobject.components.stackable:StackSize()
					end
					act.target.components.trader:AcceptGift(act.doer, act.invobject,cnt)
					return true
				else
					return false, reason
				end
			else
				return actions_feed_fn(act)
			end
		end
    end
end
AddModRPCHandler("fasttrade", "fasttrade", fasttradeHandler)
-- AddModRPCHandler("fasttrade", "store", fasttradeStoreHandler)
-- AddModRPCHandler("fasttrade", "open", openHandler)
AddModRPCHandler("fasttrade", "birdcagetrade_start", birdcagetradeStartHandler)
AddModRPCHandler("fasttrade", "birdcagetrade_end", birdcagetradeEndHandler)
AddPrefabPostInit("pigking", fasttradefn)
-- AddPrefabPostInit("birdcage", fasttradebirdfn)
AddPrefabPostInit("birdcage", fasttradebirdfn1)
-- AddPrefabPostInit("birdcage", fasttradebirdfn2)
]]