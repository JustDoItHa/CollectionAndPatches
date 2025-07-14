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

	self.bganim = self:AddChild(UIAnim())
	self.bganim:SetPosition(100, 0, 0)
	self.bganim:GetAnimState():SetBank(texture.bg.atlas)
	self.bganim:GetAnimState():SetBuild(texture.bg.image)
    self.bganim:GetAnimState():AnimateWhilePaused(false)
	self.bganim:GetAnimState():PlayAnimation("open")

	self.container = container

	self.show = {SHOWMAX, SHOWMAX}
	self.rotate = rotate

	self.itemlist = self:CreateItemList()
	self.selected = {}

	self.inv = {}

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
		self.itemlist[prefab] = {}
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

	local parent_pos_x = (self.rotate and -190) or 0
	local parent_pos_y = (not self.rotate and 230) or 0
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
	local pos_y = (self.rotate and 200 + 40 * show_y) or 0

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
		table.insert(self.inv, slot)
	end
	self.spinner = self:AddChild(ScrollableList(self.inv, 80, 280, 75, 0, nil, nil, 20, nil, 0, -10, nil, nil, "GOLD"))
	if self.rotate then
		self.spinner.DoDragScroll = DoDragScroll
	end
end

return ChestSearcher