--local checkentity = GLOBAL.checkentity

local function checkentity(inst)
	return GLOBAL.checkentity(inst)
			and inst.components ~= nil
			and inst.components.container ~= nil
			and inst.components.chestupgrade ~= nil
end

----------------------------------------------------------------
local function GetStackSize(item)
	if item.components.stackable then
		return item.components.stackable:StackSize()
	end
	return 1
end
local function GetFromStack(item, num)
	if item.components.stackable then
		return item.components.stackable:Get(num)
	end
	return item
end

----------------------------------------------------------------
--sync items between server and client
local function sync(inst)
	local container = inst.components.container
	if inst.replica.container ~= nil then
		if inst.replica.container.classified ~= nil then
			local numslots = inst.replica.container:GetNumSlots()
			for slot = 1, numslots do
				local item = container.slots[slot]
				inst.replica.container.classified:SetSlotItem(slot, item)
			end
		end
	end
	inst:PushEvent("refresh")
end

----------------------------------------------------------------
--common sorting
local function CommonSorting(inst)
	local container = inst.components.container
	local last = container:GetNumSlots()
	if container.itemlist == nil then
		container:CreateItemList()
	end
	local old_t = container.itemlist.prefabs
	local items = {}
	for k, v in pairs(container.slots) do
		items[k] = v
		container.slots[k] = nil
	end
	local n = 1
	for prefab, data in pairs(old_t) do
		for i, index in ipairs(data) do
			local item = items[index]
			container.slots[n] = item
			data[i] = n
			n = n + 1
		end
	end
	sync(inst)
	--inst:PushEvent("refresh")
end

----------------------------------------------------------------
--a simple sorting
local function Sorting(inst)
	local container = inst.components.container
	local x = inst.components.chestupgrade:GetLv()
	if container.itemlist == nil then
		container:CreateItemList()
	end
	local old_t = container.itemlist.prefabs
	local items = {}
	for k, v in pairs(container.slots) do
		items[k] = v
		container.slots[k] = nil
	end
	local i = 0
	local fromlast = {}
	local idx = {}
	for _, slots in pairs(old_t) do
		for k, v in pairs(slots) do
			local item = items[v]
			if k > x then
				table.insert(fromlast, v)
				table.insert(idx, k)
			else
				local slot = i * x + k
				container.slots[slot] = item
				slots[k] = slot
			end
		end
		i = i + 1
	end
	local last = container:GetNumSlots()
	for i, v in ipairs(fromlast) do
		while container.slots[last] ~= nil do
			last = last - 1
		end
		local item = items[v]
		old_t[item.prefab][idx[i]] = last
		container.slots[last] = item
		last = last - 1
	end
	sync(inst)
	--inst:PushEvent("refresh")
end

----------------------------------------------------------------
--a much better sorting
--if item species > y then common sort
--if item species < y then my sort
local function BetterSorting(inst)
	local container = inst.components.container
	if inst.components.chestupgrade == nil then return end
	local x, y, z = inst.components.chestupgrade:GetLv()
	local maxline = y
	if container.itemlist == nil then
		container:CreateItemList()
	end
	--local old_t = container.itemlist.prefabs
	local tablesize = container.itemlist.species
	if tablesize > 1 and tablesize <= maxline then
		Sorting(inst)
	else
		CommonSorting(inst)
	end
end

----------------------------------------------------------------
--[[
make the slots into different zones with different size
zone	no.of slots
1		x
2		2*(y-1)
3		2*(x-2)
4		(y-3)
5		if rest < 6 then rest else again
]]
local function ZoneSort(inst)

end

----------------------------------------------------------------
--the more the stack, the better the priority
local function SortingA(inst)
	local container = inst.components.container
	local x, y, z = inst.components.chestupgrade:GetLv()
	local t = {}
	local new = {}
	local i = 0
	local maxline = y * z
	local last = container:GetNumSlots()
	local items = container:RemoveAllItems()
	for k, v in pairs(items) do
		local slot = 0
		if t[v.prefab] == nil then
			i = i + 1
			t[v.prefab] = i
			new[i] = {}
		end
		local key = t[v.prefab]
		table.insert(new[key], k)
	end
	t = nil
	table.sort(new, function(a,b) return #a > x or #a > #b end)
	for line, v in pairs(new) do
		for k, index in pairs(v) do
			local item = items[index]
			local slot = (line - 1) * x + k
			if k > x or line > y or slot >= last then
				while container.slots[last] ~= nil do
					last = last - 1
				end
				slot = last
			end
			container:GiveItem(item, slot)
			item.prevcontainer = nil
			item.prevslot = nil
		end
	end
end

-----------------------------------------------------------
--the first item in the line decide what is going next to it
local function SortingB(inst)
	local container = inst.components.container
	local x, y, z = inst.components.chestupgrade:GetLv()
	local t = {}
	local refe = {}
	local last = container:GetNumSlots()
	for n = 1, y do
		for m = 1, x do
			local slot = (n - 1) * x + m
			local item = container.slots[slot]
			if item ~= nil and refe[n] == nil then
				refe[n] = item.prefab
				break
			end
		end
	end
	local items = container:RemoveAllItems()
	for k, v in pairs(items) do
		local slot
		local line
		for i, prefab in pairs(refe) do
			if prefab == v.prefab then
				line = i
				break
			end
		end
		if refe[v.prefab] then
			local m = 1
			slot = (line - 1) * x + 1
			while container.slots[slot] ~= nil and m < x do
				slot = slot + 1
				m = m + 1
			end
			if m == x then
				table.remove(refe, line)
			end
		else
			while container.slots[last] ~= nil do
				last = last - 1
			end
			slot = last
		end
		container:GiveItem(v, slot)
		v.prevcontainer = nil
		v.prevslot = nil
	end
end

----------------------------------------------------------
local function FillContent(doer, inst)
	if not checkentity(inst) then return end
	local container = inst.components.container
	if container ~= nil and container.openlist[doer] and inst.components.chestupgrade ~= nil then
		local x, y, z = inst.components.chestupgrade:GetLv()
		local params = AllUpgradeRecipes[inst.prefab] and AllUpgradeRecipes[inst.prefab].params or nil
		if x < TUNING.CHESTUPGRADE.MAX_LV and y < TUNING.CHESTUPGRADE.MAX_LV then
			local checktable = inst.components.chestupgrade:CreateCheckTable()
			local t = {}
			for i, v in ipairs(checktable) do
				if v then
					local isstring = type(v) == "string"
					local prefab = isstring and v or v.type or v[1]
					local amount = isstring and 1 or v.amount or v[2]
					t[prefab] = (t[prefab] or 0) + amount
				end
			end
			local enoughitem = true
			for prefab, amount in pairs(t) do
				if not container:Has(prefab, amount) then
					enoughitem = false
					break
				end
			end
			if enoughitem then
				local collected_items = {}
				local other_items = {}

				for slot = container.numslots, 1, -1 do
					--local item = container:RemoveItemBySlot(slot, true)
					if container.slots[slot] then
						item = container.slots[slot]
						if t[item.prefab] and t[item.prefab] > 0  then
							if collected_items[item.prefab] == nil then
								collected_items[item.prefab] = {}
							end
							local stacksize = GetStackSize(item)
							if stacksize > t[item.prefab] then
								table.insert(collected_items[item.prefab], GetFromStack(item, t[item.prefab]))
								--table.insert(other_items, item)
								container:DropItemBySlot(slot, doer:GetPosition())
							else
								table.insert(collected_items[item.prefab], item)
								container:RemoveItemBySlot(slot, true)
							end
							t[item.prefab] = math.max(0, t[item.prefab] - stacksize)
						else
							--table.insert(other_items, item)
							container:DropItemBySlot(slot, doer:GetPosition())
						end
					end
				end
				for slot, v in ipairs(checktable) do
					if v then
						local isstring = type(v) == "string"
						local prefab = isstring and v or v.type or v[1]
						local amount = isstring and 1 or v.amount or v[2]
						local item
						repeat
							local lastitem = collected_items[prefab][1]
							local stacksize = GetStackSize(lastitem)
							local num = math.min(amount, stacksize)
							local itemget = GetFromStack(lastitem, num)
							if num == stacksize then
								table.remove(collected_items[prefab], 1)
							end
							if item == nil then
								item = itemget
							elseif item.components.stackable then
								item.components.stackable:Put(itemget)
							else	--break if item is non stackable while amount > 1
								break
							end
						until item == nil or GetStackSize(item) >= amount
						container:GiveItem(item, slot)
					end
				end
				--container:Close()
				--for _, item in ipairs(other_items) do
				--	container:GiveItem(item, item.prevslot)
				--end
				--FillContent(doer, inst)
				return
			end

		elseif z < TUNING.CHESTUPGRADE.MAX_PAGE then
			local side = params and params.side or nil
			if not side then return end
			local prefab = type(side) == "string" and side or side.type or side[1]
			if prefab == nil or not container:Has(prefab, x * y) then return end
			local t = {}
			local numtoget = x * y
			for k, v in pairs(container.slots) do
				if numtoget ~= 0 and v.prefab == prefab then
					local size = GetStackSize(v)
					if size <= numtoget then		--get the entire stack
						table.insert(t, container:RemoveItem(v, true))
						numtoget = numtoget - size
					else							--get just enough, and drop the excess
						local item = container:RemoveItem(v, true)
						table.insert(t, GetFromStack(item, numtoget))
						numtoget = 0
						item.Transform:SetPosition(inst:GetPosition():Get())
						if item.components.inventoryitem ~= nil then
							item.components.inventoryitem:OnDropped(true)
						end
						item.prevcontainer = nil
						item.prevslot = nil
						inst:PushEvent("dropitem", {item = item})

					end
				else		--drop all others if we have collect enough items
					container:DropItemBySlot(k, doer:GetPosition())
				end
			end
			for i, v in ipairs(t) do
				local size = GetStackSize(v)
				while size >= 2 do
					table.insert(t, GetFromStack(v))
					size = size - 1
				end
				container:GiveItem(v, i)
			end
			container.itemlist = nil
		end
	end
end

local function StackAndSort(doer, inst)
	if not checkentity(inst) then return end
	local container = inst.components.container
	if container ~= nil and container.openlist[doer] and not container:IsEmpty() then
		local items = {}
		for k, v in pairs(container.slots) do
			local p = v.prefab
			local perishable = v.components.perishable
			if perishable then
				if perishable:IsFresh() then
					p = p.."_fresh"
				elseif perishable:IsStale() then
					p = p.."_stale"
				elseif perishable:IsSpoiled() then
					p = p.."_spoiled"
				end
			end
			if not items[p] then
				items[p] = k
			else
				local targ = container:GetItemInSlot(items[p])
				local ret
				if targ and targ.components.stackable then
					ret = targ.components.stackable:Put(v)
				end
				if ret then
					items[p] = k
				end
			end
		end
		BetterSorting(inst)
	end
end

local function FillOrSort(doer, inst)
	if not checkentity(inst) then return end
	local container = inst.components.container
	if container ~= nil and container.openlist[doer] and not container:IsEmpty() and inst.components.chestupgrade ~= nil then
		local x, y, z = inst.components.chestupgrade:GetLv()
		local params = AllUpgradeRecipes[inst.prefab] and AllUpgradeRecipes[inst.prefab].params or nil
		local side = params and params.side or nil
		if not side then return end
		local prefab = side[1]
		if z > 1 and z < TUNING.CHESTUPGRADE.MAX_PAGE and prefab ~= nil and container:Has(prefab, x * y) then
			FillContent(doer, inst)
		else
			StackAndSort(doer, inst)
		end
	end
end

local function DropContent(doer, inst)
	if not checkentity(inst) then return end
	local container = inst.components.container
	if container ~= nil and container.openlist[doer] then
		for i = 1, container.numslots do
			local item = container:RemoveItemBySlot(i)
			if item ~= nil then
				item.Transform:SetPosition(doer:GetPosition():Get())
				if item.components.inventoryitem ~= nil then
					item.components.inventoryitem:OnDropped()
				end
				item.prevcontainer = nil
				item.prevslot = nil
				inst:PushEvent("dropitem", { item = item })
			end
		end
	end
end

local function UpgradeChest(doer, inst)
	if not checkentity(inst) then return end
	FillContent(doer, inst)
	local recipe = AllUpgradeRecipes[inst.prefab]
	if recipe and recipe.upgradefn ~= nil and recipe.params ~= nil then
		recipe.upgradefn(inst, recipe.params, {doer = doer})
	end
end

AddModRPCHandler("RPC_UPGCHEST", "fillcontent", FillContent)
--AddModRPCHandler("RPC_UPGCHEST", "sortcontent", FillOrSort)
AddModRPCHandler("RPC_UPGCHEST", "stackandsort", StackAndSort)
AddModRPCHandler("RPC_UPGCHEST", "dropcontent", DropContent)
AddModRPCHandler("RPC_UPGCHEST", "upgradechest", UpgradeChest)