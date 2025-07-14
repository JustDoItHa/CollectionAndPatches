--this mod will make the container so large
--every time you craft, it repeatedly search the container slot by slot
--we rewrite GetCraftingIngredient(), so that we will only do it once for
--every container openning, even we are crafting multiple items

--local cleartable = GLOBAL.cleartable
local GetStackSize = GLOBAL.GetStackSize
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

		--build the list
		if self.itemlist == nil then
			self:CreateItemList()
		end
		local itemlist = self.itemlist

		--sort the list by order of stacksize
		--local items = self.itemlist[ingr]
		local items = itemlist.prefabs[ingr]

		if items == nil then return {} end
		if not items.sorted then
			table.sort(items, function(a, b)
				local sa, sb = itemlist.stacksize[a], itemlist.stacksize[b]
				if sa == sb then
					if reverse_search_order then
						return a > b
					end
					return a < b
				end
				return sa < sb
			end)
			items.sorted = true
		end

		local crafting_items = {}
		local removelist = {}
		local listoutdate = false
		for i, slot in ipairs(items) do
			local item = self.slots[slot]
			if item ~= nil and item.prefab == ingr then
				local stack = GetStackSize(item)
				local v = itemlist.stacksize[slot]
				if stack > v then
					items.sorted = false
				end
				stack = math.min(stack, amount)
				if v <= amount then
					table.insert(removelist, 1, i)
					itemlist.stacksize[slot] = 0
				else
					itemlist.stacksize[slot] = v - stack
				end
				crafting_items[item] = stack
				amount = amount - stack
				if amount <= 0 then
					break
				end
			else
				listoutdate = true
			end
		end

		if listoutdate then
			self.itemlist = nil
		elseif #removelist > 0 then
			--table.sort(removelist, function(a, b) return a > b end)
			for i, v in ipairs(removelist) do
				table.remove(items, v)
			end
			if #items == 0 then
				itemlist.prefabs[ingr] = nil
				itemlist.species = itemlist.species - 1
			end
		end

		return crafting_items
	end

	--the list is outdated if someone put in or take out sth
	--try to avoid put/take things while you are crafting
	local old_giveitem = self.GiveItem
	function self:GiveItem(...)
		if self.itemlist ~= nil then
			self:ClearItemList()
		end
		return old_giveitem(self, ...)
	end

	local old_removeitem = self.RemoveItemBySlot
	function self:RemoveItemBySlot(...)
		if self.itemlist ~= nil then
			self:ClearItemList()
		end
		return old_removeitem(self, ...)
	end

	--almost all put/take actions call this function
	--so we empty the list when we call the function
	local old_getitem = self.GetItemInSlot
	function self:GetItemInSlot(...)
		if self.itemlist ~= nil then
			self:ClearItemList()
		end
		return old_getitem(self, ...)
	end

	--clear the list after we close the container
	local old_close = self.Close
	function self:Close(...)
		local res = old_close(self, ...)
		if self.itemlist ~= nil and self.opencount <= 0 then
			self:ClearItemList()
		end
		return res
	end

	--to advoid issue when container load before chestupgrade
	--i hate this, but i have no better idea
	local old_save = self.OnSave
	function self:OnSave()
		local data, refs = old_save(self)
		local chestupgrade = self.inst.components.chestupgrade
		if chestupgrade ~= nil then
			data.chestupgrade = chestupgrade:OnSave()
		end
		return data, refs
	end

	local old_load = self.OnLoad
	function self:OnLoad(data, ...)
		local chestupgrade = self.inst.components.chestupgrade
		if chestupgrade ~= nil and data.chestupgrade then
			chestupgrade:OnLoad(data.chestupgrade)
		end
		old_load(self, data, ...)
	end
end)