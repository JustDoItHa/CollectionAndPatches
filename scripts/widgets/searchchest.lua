local Widget = require("widgets/widget")
local UIAnim = require("widgets/uianim")
local Image = require("widgets/image")
local TEMPLATES = require("widgets/redux/templates")
local ScrollableList = require("widgets/scrollablelist")

local texture = {
	bg = {
		atlas = "ui_backpack_2x4",
		image = "ui_backpack_2x4",
	},
	slot = {
		atlas = "images/hud.xml",
		image = "inv_slot.tex"
	},
}

local SHOWMAX = 5

local ChestSearcher = Class(Widget, function(self, container, rotate)
	Widget._ctor(self, "ChestSearcher")

	self.bg = self:AddChild(Image())

	self.container = container

	self.show = {SHOWMAX, SHOWMAX}
	self.rotate = rotate

	self.itemlist = self:CreateItemList()
	self.selected = {}

	self.items = {}

	self.queue = {add = {}, kill = {}}
end)

--[[
itemlist[item.prefab] = {
	stacksize = function()
		local stack = 0
		for i, v in ipairs(itemlist[item.prefab]) do
			stack = stack + allitems[v].replica.stackable:GetStackSize()
		end
		return stack
	end,
}
]]

local oneditsearcher = function(self, control, down)
	if not self:IsEnabled() then return end
	if self.editing and self.prediction_widget ~= nil and self.prediction_widget:OnControl(control, down) then
		return true
	end

	if self.ignore_controls[control] then
		return false
	end

	if self._base.OnControl(self, control, down) then return true end

	--gobble up extra controls
	if self.editing and (control ~= CONTROL_CANCEL and control ~= CONTROL_OPEN_DEBUG_CONSOLE and control ~= CONTROL_ACCEPT) then
		return not self.pass_controls_to_screen[control]
	end

	if self.editing and not down and control == CONTROL_CANCEL then
		self:SetEditing(false)
		TheInput:EnableDebugToggle(true)
		return not self.pass_controls_to_screen[control]
	end

	if self.enable_accept_control and control == CONTROL_ACCEPT then
		if not down then
			if not self.editing then
				self:SetEditing(true)
				return not self.pass_controls_to_screen[control]
			else
				-- Previously this was being done only in the OnRawKey, but that doesnt handle controllers very well, this does.
				self:OnProcess()
				return not self.pass_controls_to_screen[control]
			end
		end
		return true
	end

	return false
end

function ChestSearcher:CreateNameSearcher()
	self.namesearcher = self:AddChild(TEMPLATES.StandardSingleLineTextEntry("", 300, 60, CHATFONT, 35, ""))
	local textbox = self.namesearcher.textbox
	textbox:SetTextLengthLimit(50)
	textbox:SetForceEdit(true)
	textbox:EnableWordWrap(false)
	textbox:SetHelpTextEdit("")
	textbox:SetHelpTextApply(STRINGS.UI.MODSSCREEN.SEARCH)
	textbox:SetTextPrompt(STRINGS.UI.MODSSCREEN.SEARCH, UICOLOURS.GREY)
	function textbox.OnTextEntered(name)
		if name == nil or not name:find("[^%s]") then
			textbox:SetString()
			self.spinner:SetList(self.items, true)
			return
		end
		local list = {}
		for prefab, v in pairs(self.itemlist) do
			if name and v._name and v._name:find(name:lower()) then
				for _, item in ipairs(self.items) do
					if item.item == prefab then
						table.insert(list, item)
						break
					end
				end
			end
		end
		for k, v in pairs(self.items) do
			v:Hide()
		end
		self.spinner:SetList(list, true)
	end
	textbox.OnControl = oneditsearcher
end

function ChestSearcher:CreateItemList()
	local itemlist = {}
	local allitems = self.container.replica.container:GetItems()
	for slot, item in pairs(allitems) do
		if item ~= nil then
			local inventoryitem = item.replica.inventoryitem
			if itemlist[item.prefab] == nil then
				itemlist[item.prefab] = {
					_image = inventoryitem:GetImage(),
					_atlas = inventoryitem:GetAtlas(),
					_name = string.lower(inventoryitem.inst:GetDisplayName()),
				}
			end
			local stack = GetStackSize(item)
			table.insert(itemlist[item.prefab], slot)
			--itemlist[item.prefab].stacksize = itemlist[item.prefab].stacksize + stack
		end
	end
	return itemlist
end

function ChestSearcher:TempSlotPos()
	local pos = {}
	for y = self.show[2], 1, -1 do
		for x = 1, self.show[1] do
			table.insert(pos, Vector3(80 * x - 40 * self.show[1] - 40, 80 * y - 40 * self.show[2] - 40, 0))
		end
	end
	return pos
end

function ChestSearcher:MakeListItem(prefab)
	local slot = Image(texture.slot.atlas, texture.slot.image)
	slot.item = prefab
	local image = self.itemlist[prefab]._image or (prefab..".tex")
	local atlas = self.itemlist[prefab]._atlas or GetInventoryItemAtlas(image)
	slot.bgimage = slot:AddChild(Image(atlas, image))
	local checkbox = TEMPLATES.LabelCheckbox(function(box)
		local item = box:GetParent().item
		box.checked = not box.checked
		if box.checked then
			table.insert(self.selected, item)
		else
			table.removearrayvalue(self.selected, item)
		end
		self:RefreshSlot()
		box:Refresh()
	end, false)
	slot.checkbox = slot:AddChild(checkbox)
	if self.rotate then
		slot:SetScale(-1, 1, 1)
		slot:SetRotation(90)
		slot.checkbox:SetPosition(0, 60, 0)
	else
		slot.checkbox:SetPosition(-60, 0, 0)
	end
	return slot
end

function ChestSearcher:QueueRefresh(prefab, new)
	if new then
		for i, v in ipairs(self.queue.kill) do
			if v == prefab then
				table.remove(self.queue.kill, i)
				return
			end
		end
		table.insert(self.queue.add, prefab)
	else
		for i, v in ipairs(self.queue.add) do
			if v == prefab then
				table.remove(self.queue.add, i)
				return
			end
		end
		table.insert(self.queue.kill, prefab)
	end
end

function ChestSearcher:RefreshSpinner()
	for i, prefab in ipairs(self.queue.kill) do
		for _, v in ipairs(self.spinner.items) do
			if v.item == prefab then
				self.spinner:RemoveItem(v)
				v:Kill()
				break
			end
		end
	end
	for i, prefab in ipairs(self.queue.add) do
		self.spinner:AddItem(self:MakeListItem(prefab))
	end
	cleartable(self.queue.kill)
	cleartable(self.queue.add)
end

function ChestSearcher:OnItemGet(data)
	local prefab = data.item.prefab
	--if self.itemlist == nil then
	--	self.itemlist = self:CreateItemList()
	--end
	local t = self.itemlist[prefab]
	if t == nil then
		local inventoryitem = data.item.replica.inventoryitem
		self.itemlist[prefab] = {
			_image = inventoryitem:GetImage(),
			_atlas = inventoryitem:GetAtlas(),
			_name = string.lower(data.item:GetDisplayName()),
		}
		t = self.itemlist[prefab]
		if self:IsVisible() then
			self.spinner:AddItem(self:MakeListItem(prefab))
		else
			self:QueueRefresh(prefab, true)
		end
	elseif table.contains(t, data.slot) then
		--local old_stack = tonumber(self:GetParent().inv[data.slot].tile.quantity.string)
		--t.stacksize = t.stacksize - old_stack + data.item.replica.stackable:StackSize()
		return
	end
	table.insert(t, data.slot)
	--t.stacksize = t.stacksize + data.item.replica.stackable:StackSize()
	if self:IsVisible() and #self.selected > 0 then
		self:RefreshSlot()
	end
end

function ChestSearcher:OnItemLose(data)
	local tile = self:GetParent().inv[data.slot].tile
	if tile ~= nil then
		local prefab = tile.item.prefab
		if self.itemlist == nil then
			self.itemlist = self:CreateItemList()
		end
		local t = self.itemlist[prefab]
		if t == nil then return end
		for i, slot in ipairs(t) do
			if slot == data.slot then
				table.remove(t, i)
				--t.stacksize = t.stacksize - tonumber(tile.quantity.string)
				if #t == 0 then
					if self:IsVisible() then
						for _, v in ipairs(self.spinner.items) do
							if v.item == prefab then
								self.spinner:RemoveItem(v)
								v:Kill()
								break
							end
						end
					else
						self:QueueRefresh(prefab, false)
					end
					self.itemlist[prefab] = nil
					table.removearrayvalue(self.selected, prefab)
					if self:IsVisible() and #self.selected == 0 then
						self:RefreshSlot()
					end
				end
				break
			end
		end
	end
	--self:RefreshSlot()
end

function ChestSearcher:RelocateParent(init)
	local parent = self:GetParent()
	local widget = self.container.replica.container:GetWidget()
	local chestupgrade = self.container.replica.chestupgrade

	if chestupgrade == nil then return end

	local lv_x, lv_y = chestupgrade:GetLv()

	--local parent_pos_x = (self.rotate and -190) or 0
	--local parent_pos_y = (not self.rotate and 230) or 0
	local parent_pos_x = (not self.rotate and 0) or (lv_x > SHOWMAX and -190) or parent:GetPosition().x
	local parent_pos_y = (self.rotate and 0) or (lv_y > SHOWMAX and 230) or parent:GetPosition().y
	local parent_pos = (init and widget.pos) or Vector3(parent_pos_x, parent_pos_y, 0)

	parent:SetPosition(parent_pos)

	self.show[1] = math.min(lv_x, SHOWMAX)
	self.show[2] = math.min(lv_y, SHOWMAX)

	local show_x = (init and lv_x) or math.min(SHOWMAX, lv_x)
	local show_y = (init and lv_y) or math.min(SHOWMAX, lv_y)

	local scale_x = widget.bgscale ~= nil and widget.bgscale.x or 1
	local scale_y = widget.bgscale ~= nil and widget.bgscale.y or 1
	local scale = Vector3(scale_x * show_x / lv_x, scale_y * show_y / lv_y, 1)

	parent.bganim:SetScale(scale)
	parent.bgimage:SetScale(scale)

	local pos_x = (not self.rotate and 260 + 40 * show_x) or 0
	local pos_y = (self.rotate and 200 + 40 * show_y) or -30

	self:SetPosition(pos_x, pos_y, 0)
end

function ChestSearcher:RefreshSlot()
	--if self:IsVisible() then return end
	local allslots = self:GetParent().inv
	if #self.selected > 0 then
		local showing = {}
		local pos = self:TempSlotPos()
		for i, prefab in ipairs(self.selected) do
			for j, item in ipairs(self.itemlist[prefab]) do
				table.insert(showing, item)
			end
		end
		local show_inv = table.invert(showing)
		table.sort(showing)
		local index, slot = next(showing)
		for i, v in ipairs(allslots) do
			if i == slot then
				v:SetPosition(pos[show_inv[slot]])
				v:Show()
				--v:MoveToFront()
				index, slot = next(showing, index)
			else
				v:Hide()
			end
		end
		self:RelocateParent(false)
	else
		local widget = self.container.replica.container:GetWidget()
		for i, v in ipairs(widget.slotpos) do
			allslots[i]:SetPosition(v)
			allslots[i]:Show()
		end
		if self:GetParent().chestpage ~= nil then
			self:GetParent().chestpage:PageChange(0)
		end
		self:RelocateParent(true)
	end
end

function ChestSearcher:Reset()
	local items = self.spinner.items
	for i, v in ipairs(items) do
		local cb = v.checkbox
		if cb.checked then
			cb:onclick()
		end
	end
end

local function DoDragScroll(self)
	-- Near the scroll bar, keep drag-scrolling
	local marker = self.position_marker:GetWorldPosition()
	if self.dragging and math.abs(TheFrontEnd.lasty - marker.y) <= 150 then
		local pos = self:GetWorldPosition()

		local _,scaleY,_ = self:GetHierarchicalScale()

		local click_y = TheFrontEnd.lastx
		local prev_step = self:GetNearestStep()

		local scaledHalflength = (self.height/2) * scaleY
		local scaledArrowHeight = 40 * scaleY

		click_y = click_y - pos.x
		click_y = math.clamp(- click_y, - scaledHalflength + scaledArrowHeight, scaledHalflength - scaledArrowHeight)

		click_y = click_y / scaleY

		self.position_marker:SetPosition(self.width/2, click_y + self.y_adjustment)
		local curr_step = self:GetNearestStep()
		if curr_step ~= prev_step then
			self:Scroll(prev_step - curr_step, false)
		end
	else -- Far away from the scroll bar, revert to original pos
		local prev_step = self:GetNearestStep()
		if self.position_marker.o_pos then
			self.position_marker:SetPosition(self.position_marker.o_pos)
		end
		local curr_step = self:GetNearestStep()
		if curr_step ~= prev_step then
			self:Scroll(prev_step - curr_step, false)
		end
		self:MoveMarkerToNearestStep()
	end
end

function ChestSearcher:Initialize()
	for k, v in pairs(self.itemlist) do
		local slot = self:MakeListItem(k)
		table.insert(self.items, slot)
	end
	self.spinner = self:AddChild(ScrollableList(self.items, 80, 280, 75, 0, nil, nil, 20, nil, 0, -10, nil, nil, "GOLD"))
	self:CreateNameSearcher()
	if self.rotate then
		self:SetPosition(0, 320, 0)
		self.bg:SetTexture("images/hud.xml", "craftingsubmenu_fullvertical.tex")
		self.bg:SetScale(1.33, -.75, 1)
		self.bg:SetPosition(0, 35, 0)
		self.spinner:SetScale(-1, 1, 1)
		self.spinner:SetRotation(90)
		self.spinner.DoDragScroll = DoDragScroll
		self.namesearcher:SetPosition(0, 140, 0)
	else
		self:SetPosition(460, 0, 0)
		self.bg:SetTexture("images/hud.xml", "craftingsubmenu_fullhorizontal.tex")
		self.bg:SetScale(.75, 1.2, 1)
		self.bg:SetPosition(-45, 30, 0)
		self.namesearcher:SetPosition(-20, 180, 0)
		self.namesearcher.textbox_bg:ScaleToSize(160, 60, 0)
		self.namesearcher.textbox:SetRegionSize(130, 60, 0)
		self.namesearcher.textbox.prompt:SetRegionSize(130, 60, 0)
	end
end

return ChestSearcher