--this mod will make the container so large
--every time you craft, it repeatedly search the container slot by slot
--we rewrite GetCraftingIngredient(), so that we will only do it once for
--every container openning, even we are crafting multiple items

local cleartable = GLOBAL.cleartable
local GetStackSize = GLOBAL.GetStackSize

AddComponentPostInit("container", function(self)
	self.itemlist = nil

	function self:ClearItemList()
		if self.itemlist ~= nil then
			cleartable(self.itemlist.slots)
			cleartable(self.itemlist)
			self.itemlist = nil
		end
	end

	function self:CreateItemList()
		if self.itemlist ~= nil then
			self:ClearItemList()
		end

		self.itemlist = {
			prefabs = {},
			slots = {},
			stacksize = {},
		}

		local itemlist = {}
		for k = 1, self.numslots do
			local item = self.slots[k]
			if item ~= nil then
				if itemlist[item.prefab] == nil then
					itemlist[item.prefab] = {}
				end
				local stack = GetStackSize(item)
				table.insert(itemlist[item.prefab], k)
				table.insert(self.itemlist.stacksize, stack)
			else
				table.insert(self.itemlist.stacksize, 0)
			end
		end
		for prefab, slots in pairs(itemlist) do
			table.insert(self.itemlist.prefabs, prefab)
			table.insert(self.itemlist.slots, slots)
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

		--sort the list by order of stacksize
		--local items = self.itemlist[ingr]
		local items
		for idx, prefab in ipairs(self.itemlist.prefabs) do
			if prefab == ingr then
				items = self.itemlist.slots[idx]
				break
			end
		end

		if items == nil then return {} end

		if not items.sorted then
			table.sort(items, function(a, b)
				local sa, sb = self.itemlist.stacksize[a], self.itemlist.stacksize[b]
				if sa == sb then
					if reverse_search_order then
						return sa > sb
					end
					return sa < sb
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
				local v = self.itemlist.stacksize[slot]
				if stack > v then
					items.sorted = false
				end
				stack = math.min(stack, amount)
				if v <= amount then
					table.insert(removelist, 1, i)
					self.itemlist.stacksize[slot] = 0
				else
					self.itemlist.stacksize[slot] = v - stack	
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
end)