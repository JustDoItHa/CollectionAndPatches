--this mod will make the container so large
--every time you craft, it repeatedly search the container slot by slot
--we rewrite GetCraftingIngredient(), so that we will only do it once for
--every container openning, even we are crafting multiple items

--local cleartable = GLOBAL.cleartable
local GetStackSize = GLOBAL.GetStackSize

local crafting_priority_fn = function(a,b)
	if a.stacksize == b.stacksize then
		return a.index < b.index
	end
	return a.stacksize < b.stacksize
end

AddComponentPostInit("container", function(self)
	self.itemlist = nil

	function self:ClearItemList()
		if self.itemlist ~= nil then
			--cleartable(self.itemlist.slots)
			--cleartable(self.itemlist)
			self.itemlist = nil
		end
	end

	function self:UpdateItemList(slot, newitem, olditem)
		if slot == nil then return end
		local itemlist = self.itemlist
		local isdifferent = true
		if newitem then
			local prefab = newitem.prefab
			local slotlist = itemlist.prefabs[prefab]
			if slotlist == nil then
				itemlist.prefabs[prefab] = {}
				slotlist = itemlist.prefabs[prefab]
				itemlist.species = itemlist.species + 1
			end
			local shouldadd = true
			for _, v in ipairs(slotlist) do
				if v == slot then
					shouldadd = false
					break
				end
			end
			if shouldadd then
				table.insert(slotlist, slot)
				slot.sorted = false
			end
			isdifferent = prefab == (olditem and olditem.prefab)
		end
		if olditem and isdifferent then
			local prefab = olditem.prefab
			local slotlist = itemlist.prefabs[prefab]
			for i, v in ipairs(slotlist) do
				if v == slot then
					table.remove(slotlist, i)
					if #slotlist == 0 then
						itemlist.prefabs[prefab] = nil
						itemlist.species = itemlist.species - 1
					end
					break
				end
			end
		end
		itemlist.stacksize[slot] = GetStackSize(newitem)
	end

	function self:CreateItemList()
		if self.itemlist ~= nil then
			self:ClearItemList()
		end

		self.itemlist = {
			species = 0,
			prefabs = {},
			--slots = {},
			stacksize = {},
		}

		local itemlist = self.itemlist
		for slot = 1, self.numslots do
			local item = self.slots[slot]
			if item ~= nil then
				if itemlist.prefabs[item.prefab] == nil then
					itemlist.prefabs[item.prefab] = {}
					itemlist.species = itemlist.species + 1
				end
				local stack = GetStackSize(item)
				--table.insert(itemlist[item.prefab], k)
				table.insert(itemlist.prefabs[item.prefab], slot)
				table.insert(itemlist.stacksize, stack)
			else
				table.insert(itemlist.stacksize, 0)
			end
		end
	end

	--instead of look up all slots one by one
	--we create a list which act as an index
	--only slots that are listed in the "index" will be looked
	self.oldGetCraftingIngredient = self.GetCraftingIngredient
	function self:GetCraftingIngredient(ingr, amount, reverse_search_order, ...)
		if GLOBAL.ChestUpgrade.DISABLERS["CONTAINER"] then
			return self:oldGetCraftingIngredient(ingr, amount, reverse_search_order, ...)
		end

		if self.itemlist == nil then
			self:CreateItemList()
		end
		local itemlist = self.itemlist

		local items = itemlist.prefabs[ingr]

		if items == nil then return {} end
		--sort items, when:
		--(1) it has never been sorted;
		--(2) its current sorting is different from search order
		if not items.sorted or ((items.sorted == "dec") == (not reverse_search_order)) then
			local items_projection = {}
			for i, v in ipairs(items) do
				table.insert(items_projection, {
					slot = v,
					index = reverse_search_order and (#items - i + 1) or i,
					stacksize = self.slots[v] and GetStackSize(self.slots[v]) or 0,
				})
			end
			table.sort(items_projection, crafting_priority_fn)
			for i, v in ipairs(items_projection) do
				items[i] = v.slot
			end
			items.sorted = reverse_search_order and "dec" or "asc"
			--elseif ((items.sorted == "dec") == (not reverse_search_order)) then
			--	itemlist.prefabs[ingr] = table.reverse(items)
			--	items = itemlist.prefabs[ingr]
			--	items.sorted = reverse_search_order and "dec" or "asc"
		end

		local crafting_items = {}
		local is_itemlist_dirty
		for i, slot in ipairs(items) do
			local item = self.slots[slot]
			if item ~= nil then
				if not item:HasTag("nocrafting") then
					local stack = GetStackSize(item)
					local stacksize = math.min(stack, amount)
					crafting_items[item] = stacksize
					amount = amount - stacksize
					if amount <= 0 then
						break
					end
				end
			else
				is_itemlist_dirty = true
			end
		end

		if is_itemlist_dirty then
			local i = 1
			while true do
				local slot = items[i]
				if slot == nil then break end
				if self.slots[slot] ~= nil then
					i = i + 1
				else
					table.remove(items, i)
				end
			end
		end
		--[[
		--this part is removed because order is sorted based on "reverse_search_order"
		--"crafting_items" is now always selected from the beginning of "items"
		--remove the 0 stacksize item from the end of "items" when "reverse_search_order" == true
		if reverse_search_order then
			local last_slot = items[#items] or 0
			local last_item = self.slots[last_slot]
			while last_item == nil do
				if #items <= 0 then
					return crafting_items
				else
					table.remove(items)
					last_slot = items[#items] or 0
					last_item = self.slots[last_slot]
				end
			end
			local last_size = GetStackSize(last_item)
			for i, v in ipairs(items) do
				local item = self.slots[v]
				local size = GetStackSize(item)
				if last_size < size then
					table.insert(items, i, table.remove(items))
					break
				end
			end
		end
		]]
		return crafting_items
	end

	--the list is outdated if someone put in or take out sth
	--try to avoid put/take things while you are crafting
	local oldGiveItem = self.GiveItem
	function self:GiveItem(...)
		if self.itemlist ~= nil then
			self:ClearItemList()
		end
		return oldGiveItem(self, ...)
	end

	local oldRemoveItemBySlot = self.RemoveItemBySlot
	function self:RemoveItemBySlot(...)
		if self.itemlist ~= nil then
			self:ClearItemList()
		end
		return oldRemoveItemBySlot(self, ...)
	end

	--almost all put/take actions call this function
	--so we empty the list when we call the function
	local oldGetItemInSlot = self.GetItemInSlot
	function self:GetItemInSlot(...)
		if self.itemlist ~= nil then
			self:ClearItemList()
		end
		return oldGetItemInSlot(self, ...)
	end

	--clear the list after we close the container
	local oldClose = self.Close
	function self:Close(...)
		local res = oldClose(self, ...)
		if self.itemlist ~= nil and self.opencount <= 0 then
			self:ClearItemList()
		end
		return res
	end

	--let chestupgrade load before container
	local oldOnSave = self.OnSave
	function self:OnSave()
		local data, refs = oldOnSave(self)
		local chestupgrade = self.inst.components.chestupgrade
		if chestupgrade ~= nil then
			data.chestupgrade = chestupgrade:OnSave()
		end
		return data, refs
	end

	local oldOnLoad = self.OnLoad
	function self:OnLoad(data, ...)
		local chestupgrade = self.inst.components.chestupgrade
		if chestupgrade ~= nil and data.chestupgrade then
			chestupgrade:OnLoad(data.chestupgrade)
		end
		oldOnLoad(self, data, ...)
	end
end)