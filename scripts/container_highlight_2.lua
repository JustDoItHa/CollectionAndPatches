GLOBAL.setmetatable(GLOBAL.getfenv(1), { __index = function(self, index) return GLOBAL.rawget(GLOBAL, index) end })

local TINT_CLR = GetModConfigData("Highlight_TINT") or 1
local Highlight_ingredientui = GetModConfigData("Highlight_ingredientui")
local Highlight_craftingmenu_pinslot = GetModConfigData("Highlight_craftingmenu_pinslot")

local AddClassPostConstruct = AddClassPostConstruct
local env = env
local UnHighlightTask

local CHEST_COLOURS = {
	{ 1, 1,   1, 1 }, -- White
	{ 1, 1,   0, 1 }, -- Yellow
	{ 1, 0.5, 0, 1 }, -- Orange
	{ 1, 0,   0, 1 }, -- Red
	{ 0, 1,   0, 1 }, -- Green
	{ 0, 0,   1, 1 }, -- Blue
	{ 0, 1,   1, 1 }, -- Light blue
	{ 1, 0,   1, 1 }, -- Pink
}
local color = CHEST_COLOURS[TINT_CLR]

local HIGHLITED_ENTS = {}

local function ClearHighLight()
	for _, ent in ipairs(HIGHLITED_ENTS) do
		ent.AnimState:SetLightOverride(0)
		if ent.AnimState.OverrideMultColour then
			ent.AnimState:OverrideMultColour(1, 1, 1, 1)
		else
			ent.AnimState:SetAddColour(0, 0, 0, 0)
		end
	end
	HIGHLITED_ENTS = {}
end

-- Server calls this on clients
local function HighLight(chest)
	-- print("got client rpc", chest)
	-- Probably a bug? The last argument is allways some random function :|
	chest = (chest and type(chest) ~= "function") and chest or nil
	if chest and chest.AnimState then
		chest.AnimState:SetLightOverride(.4)
		if chest.AnimState.OverrideMultColour then
			chest.AnimState:OverrideMultColour(color[1], color[2], color[3], color[4])
		else
			chest.AnimState:SetAddColour(color[1], color[2], color[3], color[4])
		end
		table.insert(HIGHLITED_ENTS, chest)
	else
		if next(HIGHLITED_ENTS) then
			ClearHighLight()
		end
	end
end

AddClientModRPCHandler("FINDER_REDUX", "HIGHLIGHT", HighLight)

local function FindItem(inst, item)
	-- 查找附近的物品
	if item then
		local x, y, z = inst.Transform:GetWorldPosition()
		local ents = TheSim:FindEntities(x, y, z, 20, nil,
			{ "player", "DECOR", "FX", "NOCLICK", "INLIMBO", "outofreach" })
		for _, ent in ipairs(ents) do
			if ent and ent:IsValid() and ent.entity:IsVisible() then
				if ((ent.components.container and ent.components.container:Has(item, 1)) or item == ent.prefab) then
					-- Send our chest to client
					-- Not sure if we call it more then once per tick. Needs to be checked
					-- print("Sending client rpc")
					SendModRPCToClient(GetClientModRPC("FINDER_REDUX", "HIGHLIGHT"), inst, ent)
				end
				if ent.components.container_proxy then
					local master = ent.components.container_proxy.master
					if master and master:IsValid() and master.components.container and master.components.container:Has(item, 1) then
						SendModRPCToClient(GetClientModRPC("FINDER_REDUX", "HIGHLIGHT"), inst, ent)
					end
				end
			end
		end
	else
		SendModRPCToClient(GetClientModRPC("FINDER_REDUX", "HIGHLIGHT"), inst, nil)
	end
end

local ingredients = require("cooking").ingredients
local function FindFoodTag(inst, searchtag)
	-- Look through cooking and find all foods with the tag we need
	-- Then iterate through all food and run FindItem for every item
	local prefabs = {}
	for prefab, data in pairs(ingredients) do
		for tag, num in pairs(data.tags) do
			if tag == searchtag then
				FindItem(inst, prefab)
				break
			end
		end
	end
end

-- Client calls this on its side and it runs on server
-- Item is a prefab string, not an instance
AddModRPCHandler("FINDER_REDUX", "FIND", function(inst, item, isfoodtag)
	-- print("Got server RPC", item)
	if isfoodtag then
		FindFoodTag(inst, item)
	else
		FindItem(inst, item)
	end
end)

------------------------------------------------------------
-------Patching widgets to send out items to server---------
------------------------------------------------------------
-- We don't need to run this on dedicated server.
-- Clients only (self-hosted servers too)
if TheNet:IsDedicated() then
	return
end

local function GetItemSlots(player, item)
	if not player then
		return {}
	end
	local slots = {}
	local slotCount = 0

	if player.HUD and player.HUD.controls and player.HUD.controls.inv then
		local inventoryBar = player.HUD.controls.inv
		for i = 1, #inventoryBar.inv do
			local slot = inventoryBar.inv[i]
			if slot then
				slotCount = slotCount + 1
				slots[slotCount] = slot
			end
		end
		-- equipped items
		for _, slot in pairs(inventoryBar.equip) do
			if slot then
				slotCount = slotCount + 1
				slots[slotCount] = slot
			end
		end
		-- open containers
		--k, v = next(self.controls.containers) return v -- PlayerHud:GetFirstOpenContainerWidget
		for _, c in pairs(player.HUD.controls.containers) do
			if c and c.inv then
				for i = 1, #c.inv do
					local v = c.inv[i]
					if v then
						slotCount = slotCount + 1
						slots[slotCount] = v
					end
				end
			end
		end
		-- backpack inventory
		-- DST: Profile:GetIntegratedBackpack() -> true/false : is a thing
		local backpackInventory = inventoryBar.backpackinv

		for i = 1, #backpackInventory do
			local v = backpackInventory[i]
			if v then
				slotCount = slotCount + 1
				slots[slotCount] = v
			end
		end
	end

	for i = 1, #slots do
		local slot = slots[i]
		if slot.tile then
			if slot.tile.item.prefab == item then
				slot.tile.image:SetTint(color[1], color[2], color[3], color[4])
			elseif slot.tile.item.replica.container and slot.tile.item.replica.container:Has(item,1) then
				slot.tile.image:SetTint(color[1], color[2], color[3], color[4])				
			else
				slot.tile.image:SetTint(1, 1, 1, 1)
			end
		end
	end
end

local pass = function() return true end

local function FindItem(inst, item, isfood)
	-- print("Sending RPC...", item)
	-- print("isfood", isfood)
	GetItemSlots(inst, item)
	SendModRPCToServer(GetModRPC("FINDER_REDUX", "FIND"), item, isfood)
end

-- activeitem
AddPlayerPostInit(function(inst)
	if not inst then
		return
	end
	inst:ListenForEvent("newactiveitem", function(inst, data)
		local activeItem = data and data.item and data.item.prefab or nil
		-- 先初始化一下,不然切换“activeItem”的时候原先高亮的物品仍然会高亮着
		FindItem(inst, nil)
		if UnHighlightTask then
			UnHighlightTask:Cancel()
			UnHighlightTask = nil
		end
		inst:DoTaskInTime(GLOBAL.FRAMES, function()
			FindItem(inst, activeItem)
		end)

		inst:ListenForEvent("refreshinventory", function()
			-- FindItem(inst, activeItem)
			GetItemSlots(inst, activeItem)
			-- print("activeitem:",activeItem)
		end)
	end)
end)

-- ingredientui
if Highlight_ingredientui ~= 3 then
	AddClassPostConstruct("widgets/ingredientui",function(self, atlas, image, quantity, on_hand, has_enough, name, owner, recipe_type)
		-- Save our recipe_type
		self.product = recipe_type
		if Highlight_ingredientui == 1 then
			local _OnGainFocus = self.OnGainFocus or pass
			function self:OnGainFocus(...)
				-- 先清空高亮
				FindItem(self.owner, nil)
				if self.product then
					if UnHighlightTask then
						UnHighlightTask:Cancel()
						UnHighlightTask = nil
					end
					FindItem(self.owner, self.product)
					UnHighlightTask = self.owner:DoTaskInTime(8, function ()
						FindItem(self.owner, nil)
						UnHighlightTask = nil
					end)

				end
				return _OnGainFocus(self, ...)
			end
		else
			local _OnControl = self.OnControl or pass
			self.OnControl = function(self, control, down, ...)
				if control == CONTROL_SECONDARY and down and self.focus then
					TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
					FindItem(self.owner, nil)
					if self.product then
						if UnHighlightTask then
							UnHighlightTask:Cancel()
							UnHighlightTask = nil
						end
						FindItem(self.owner, self.product)
						UnHighlightTask = self.owner:DoTaskInTime(8, function ()
							FindItem(self.owner, nil)
							UnHighlightTask = nil
						end)
					end
					return _OnControl(self, control, down, ...)
				end
			end
		end
	end)
end

if Highlight_craftingmenu_pinslot ~= 3 then
-- craftingmenu_pinslot
	AddClassPostConstruct("widgets/redux/craftingmenu_pinslot",function(self,...)
		if Highlight_craftingmenu_pinslot == 1 then
			local _OnGainFocus = self.OnGainFocus or pass
			function self:OnGainFocus(...)
				-- 先清空高亮
				FindItem(self.owner, nil)
				if self.recipe_name then
					if UnHighlightTask then
						UnHighlightTask:Cancel()
						UnHighlightTask = nil
					end
					FindItem(self.owner, self.recipe_name)
					UnHighlightTask = self.owner:DoTaskInTime(8, function ()
						FindItem(self.owner, nil)
						UnHighlightTask = nil
					end)
				end
				return _OnGainFocus(self, ...)
			end
		else
			local _OnControl = self.OnControl
			self.OnControl = function(self, control, down, ...)
				if control == CONTROL_SECONDARY and down and self.focus then
					TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
					FindItem(self.owner, nil)
					if self.recipe_name then
						if UnHighlightTask then
							UnHighlightTask:Cancel()
							UnHighlightTask = nil
						end
						FindItem(self.owner, self.recipe_name)
						UnHighlightTask = self.owner:DoTaskInTime(8, function ()
							FindItem(self.owner, nil)
							UnHighlightTask = nil
						end)
					end
				end
				return _OnControl(self, control, down, ...)
			end
		end
	end)
end

-- craftingmenu_widget
AddClassPostConstruct("widgets/redux/craftingmenu_widget",function(self,...)
	-- local _MakeRecipeList = self.MakeRecipeList
	-- function self:MakeRecipeList(...)
	-- 	for key, value in pairs(self) do
	-- 		print(key)
	-- 		print(value)
	-- 	end
	-- 	return _MakeRecipeList(...)
	-- end
	local _OnControl = self.OnControl
	self.OnControl = function(self, control, down, ...)
		if control == CONTROL_SECONDARY and down and self.crafting_hud and self.crafting_hud:IsCraftingOpen() and
			not TheInput:IsControlPressed(CONTROL_FORCE_INSPECT) and not TheInput:IsControlPressed(CONTROL_FORCE_STACK) and
			not TheInput:IsControlPressed(CONTROL_FORCE_TRADE) and self.focus and self.enabled then
			if self.recipe_grid and self.recipe_grid.shown and self.recipe_grid.focus then
				local index = self.recipe_grid.focused_widget_index + self.recipe_grid.displayed_start_index
				local items = self.recipe_grid.items
				if index and items and items[index] then
					local recipe = items[index].recipe
					if recipe and (recipe.name or recipe.product) then
						TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
						FindItem(self.owner, nil)
						if UnHighlightTask then
							UnHighlightTask:Cancel()
							UnHighlightTask = nil
						end
						FindItem(self.owner, recipe.name or recipe.product)
						UnHighlightTask = self.owner:DoTaskInTime(8, function ()
							FindItem(self.owner, nil)
							UnHighlightTask = nil
						end)
					end
				end
			end
		end
		return _OnControl(self, control, down, ...)
	end
end)

AddClassPostConstruct("widgets/tabgroup", function(self)
	local _DeselectAll = self.DeselectAll
	function self:DeselectAll(...)
		FindItem(self.owner, nil)
		return _DeselectAll(self, ...)
	end
end)

-- Compatibility with Craft Pot Mod
-- Looking for food with matching tags
-- foodingredientui
if pcall(require, "widgets/foodingredientui") then
	AddClassPostConstruct("widgets/foodingredientui", function(self)
		local _OnGainFocus = self.OnGainFocus or pass
		local _OnLoseFocus = self.OnLoseFocus or pass

		function self:OnGainFocus(...)
			local searchtag = self.prefab -- tag or name
			local isname = self.is_name

			-- print(isname or searchtag and print("searchtag"))
			-- Clear old highlights
			if UnHighlightTask then
				UnHighlightTask:Cancel()
				UnHighlightTask = nil
			end
			FindItem(self.owner, nil)
			if isname then
				FindItem(self.owner, PREFABDEFINITIONS[searchtag] and PREFABDEFINITIONS[searchtag].name or searchtag)
			else
				FindItem(self.owner, searchtag, true)
			end

			return _OnGainFocus(self, ...)
		end

		-- function self:OnLoseFocus(...)
		-- 	FindItem(self.owner, nil, true)
		-- 	return _OnLoseFocus(self, ...)
		-- end
	end)

	AddClassPostConstruct("widgets/foodcrafting", function(self)
		local _OnLoseFocus = self.OnLoseFocus or pass
		function self:OnLoseFocus(...)
			FindItem(self.owner, nil)
			return _OnLoseFocus(self, ...)
		end

		local _Close = self.Close or pass
		function self:Close(...)
			FindItem(self.owner, nil)
			return _Close(self, ...)
		end
	end)
end
