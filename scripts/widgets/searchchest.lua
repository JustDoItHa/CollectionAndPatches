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

local SearchChest = Class(Widget, function(self, container, rotate)
    Widget._ctor(self, "SearchChest")

	self.bganim = self:AddChild(UIAnim())
	self.bganim:SetPosition(100, 0, 0)
	self.bganim:GetAnimState():SetBank(texture.bg.atlas)
	self.bganim:GetAnimState():SetBuild(texture.bg.image)
    self.bganim:GetAnimState():AnimateWhilePaused(false)
	self.bganim:GetAnimState():PlayAnimation("open")

	self.container = container

	self.show = {5, 5}
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

function SearchChest:CreateItemList()
	local itemlist = {}
	local allitems = self.container.replica.container:GetItems()
	for slot, item in pairs(allitems) do
		if item ~= nil then
			if itemlist[item.prefab] == nil then
				itemlist[item.prefab] = {}
			end
			local stack = GetStackSize(item)
			table.insert(itemlist[item.prefab], slot)
			--itemlist[item.prefab].stacksize = itemlist[item.prefab].stacksize + stack
		end
	end
	return itemlist
end

function SearchChest:TempSlotPos()
	local pos = {}
	for y = self.show[2], 1, -1 do
		for x = 1, self.show[1] do
			table.insert(pos, Vector3(80 * x - 40 * self.show[1] - 40, 80 * y - 40 * self.show[2] - 40, 0))
		end
	end
	return pos
end

local QUAGMIRE_PORTS = {
	"tomato",
	"onion",
}

function SearchChest:MakeListItem(prefab)
	local slot = Image(texture.slot.atlas, texture.slot.image)
	slot.item = prefab
	local image = prefab..".tex"
	if prefab == "tomato" or prefab == "onion" then
		image = "quagmire_"..image
	end
	local atlas = GetInventoryItemAtlas(image)
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

function SearchChest:QueueRefresh(prefab, new)
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

function SearchChest:RefreshSpinner()
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

function SearchChest:OnItemGet(data)
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

function SearchChest:OnItemLose(data)
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

--I hate this, but I have no other idea
function SearchChest:RelocateParent(init)
	local parent = self:GetParent()
	local widget = self.container.replica.container:GetWidget()
	local chestupgrade = self.container.replica.chestupgrade
	if chestupgrade == nil then return end
	local lv_x, lv_y = chestupgrade:GetLv()
	if not init and widget.bgscale ~= nil and (lv_x >= 5 or lv_y >= 5) then
		parent.bganim:SetScale(widget.bgscale.x * 5 / lv_x, widget.bgscale.y * 5 / lv_y, 1)
		parent.bgimage:SetScale(widget.bgscale.x * 5 / lv_x, widget.bgscale.y * 5 / lv_y, 1)
		if parent:GetPosition() == widget.pos then
			local pos
			if self.rotate then
				pos = Vector3(-190, 0, 0)
			else
				pos = Vector3(0, 230, 0)
			end
			parent:SetPosition(pos)
		end
		if self.rotate then
			self:SetPosition(0, 400, 0)
		else
			self:SetPosition(460, 0, 0)
		end
	else
		self.show[1] = math.min(lv_x, self.show[1])
		self.show[2] = math.min(lv_y, self.show[2])
		if widget.bgscale ~= nil then
			parent.bganim:SetScale(widget.bgscale)
			parent.bgimage:SetScale(widget.bgscale)
		else
			parent.bganim:SetScale(1, 1, 1)
			parent.bgimage:SetScale(1, 1, 1)
		end
		if self.rotate then
			self:SetPosition(0, 240 + 40 * (lv_y - 1), 0)
		else
			self:SetPosition(300 + 40 * (lv_x - 1), 0, 0)
		end
	end
end

function SearchChest:RefreshSlot()
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

function SearchChest:Reset()
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

function SearchChest:Initialize()
	for k, v in pairs(self.itemlist) do
		local slot = self:MakeListItem(k)
		table.insert(self.inv, slot)
	end
	self.spinner = self:AddChild(ScrollableList(self.inv, 80, 280, 75, 0, nil, nil, 20, nil, 0, -10, nil, nil, "GOLD"))
	if self.rotate then
		self.spinner.DoDragScroll = DoDragScroll
	end
end

return SearchChest