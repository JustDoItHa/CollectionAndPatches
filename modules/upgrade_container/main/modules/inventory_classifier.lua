--the game go through every inventory & container slots very frequently
--for updating the craftingmenu. see: widgets/redux/craftingmenu_hud.lua
--this module may reduce some lagging when opening a container
--by checking each slots once only for each update of craftingmenu

local function AddToList(itemlist, item, iscrafting)
	if item == nil or iscrafting and item:HasTag("nocrafting") then return end
	local prefab = item.prefab
	local stack = item.replica.stackable ~= nil and item.replica.stackable:StackSize() or 1
	itemlist[prefab] = (itemlist[prefab] or 0) + stack
end

local function CreateItemList(inst, checkallcontainers)
	local iscrafting = checkallcontainers
	local itemlist = inst.itemlist

	if itemlist == nil then
		itemlist = {}
		inst.itemlist = itemlist
	end

	if inst._activeitem ~= nil then
		local item = inst._activeitem
		AddToList(itemlist, item, iscrafting)
	end

	if inst._itemspreview ~= nil then
		for i, v in ipairs(inst._items) do
			local item = inst._itemspreview[i]
			AddToList(itemlist, item, iscrafting)
		end
	else
		for i, v in ipairs(inst._items) do
			local item = v:value()
			if item ~= nil and item ~= inst._activeitem then
				AddToList(itemlist, item, iscrafting)
			end
		end
	end

	local overflow = inst:GetOverflowContainer()
	if overflow ~= nil then
		local items = overflow:GetItems()
		for _, item in pairs(items) do
			AddToList(itemlist, item, iscrafting)
		end
	end

	if checkallcontainers then
		local inventory_replica = inst and inst._parent and inst._parent.replica.inventory
		local containers = inventory_replica and inventory_replica:GetOpenContainers()

		if containers then
			for container_inst in pairs(containers) do
				local container = container_inst.replica.container or container_inst.replica.inventory
				if container and container ~= overflow and not container.excludefromcrafting then
					local items = container.GetItems ~= nil and container:GetItems() or {}
					for _, item in pairs(items) do
						AddToList(itemlist, item, iscrafting)
					end
				end
			end
		end
	end

	return itemlist
end

local function removelist(inst)
	if inst.itemlist ~= nil then
		inst.itemlist = nil
	end
	inst._removelist:Cancel()
	inst._removelist = nil
end

local function NewHas(inst, prefab, amount, checkallcontainers, ...)
	if GLOBAL.ChestUpgrade.DISABLERS["INVENTORY"] then
		return inst:oldHas(prefab, amount, checkallcontainers, ...)
	end

	if inst._removelist == nil then
		inst._removelist = inst:DoTaskInTime(0, removelist)
	end

	local itemlist = inst.itemlist
	if itemlist == nil then
		itemlist = CreateItemList(inst, checkallcontainers)
	end

	local count = itemlist[prefab] or 0

	return count >= amount, count
end

AddPrefabPostInit("inventory_classified", function(inst)
	if GLOBAL.TheWorld.ismastersim then return end
	inst.itemlist = {}

	inst.CreateItemList = CreateItemList
	inst.oldHas = inst.Has
	inst.Has = NewHas
end)