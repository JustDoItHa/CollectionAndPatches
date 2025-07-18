local Widget = require("widgets/widget")
local Image = require("widgets/image")
local ImageButton = require("widgets/imagebutton")
local Text = require("widgets/text")

local steps_x, steps_y, start_x, start_y = 0, 0, 0, 0
local item_scale = Vector3()
local function initialize(self)
	steps_x = self.width / self.total[1]
	steps_y = self.hight / self.total[2]
	start_x = (steps_x - self.width) / 2
	start_y = (self.hight - steps_y) / 2
	item_scale.x = 3 / self.total[1]
	item_scale.y = 3 / self.total[2]
end

local DragContainer = Class(Widget, function(self, altas, texture, scale, show, total)
	Widget._ctor(self, "DragContainer")

	--background image
	self.bgimg = self:AddChild(ImageButton(altas, texture))
	self.bgimg.scale_on_focus = false
	self.bgimg.move_on_click = false
	self.bgimg:SetOnDown(function()
		self.ondrag = true
	end)
	self.bgimg:SetWhileDown(function()
		if self.selsec and self.ondrag then
			if self.cursor_now == nil
					or math.abs(TheFrontEnd.lastx - self.cursor_now.x) >= (steps_x / 2)
					or math.abs(TheFrontEnd.lasty - self.cursor_now.y) >= (steps_y / 2) then
				self:GoSection(TheFrontEnd.lastx, TheFrontEnd.lasty)
			end
		end
	end)
	self.bgimg:SetOnClick(function()
		if self.selsec and self.ondrag then
			self.ondrag = false
			self:GoSection(TheFrontEnd.lastx, TheFrontEnd.lasty)
		end
	end)

	--selected section
	self.selsec = self:AddChild(Image("images/plantregistry.xml", "oversizedpicturefilter.tex"))
	if type(scale) == "table" then
		self.selsec:SetScale(scale[1], scale[2], 0)
	else
		self.selsec:SetScale(scale or 1)
	end

	self.show = show
	self.total = total
	self.now = {1, 1}
	self.width = 240
	self.hight = 240

	self.list = {}
	self.imageroot = self:AddChild(Widget())
	self.imageroot.pages = {}

	initialize(self)
end)

function DragContainer:SlotToPos(x, y)
	return start_x + steps_x * (x - 1), start_y - steps_y * (y - 1)
end

-- (+2-1) for avoiding a weird bug when self.total == 7
function DragContainer:PosToSlot(x, y)
	return math.floor((x - start_x) / steps_x + 2 - 1), math.floor((start_y - y) / steps_y + 2 - 1)
end

function DragContainer:FindNearest(x, y)
	local pos = self:GetWorldPosition()
	x = RoundToNearest(x - pos.x - start_x, steps_x)
	y = RoundToNearest(pos.y + start_y - y, steps_y)

	return start_x + x, start_y - y
end

function DragContainer:SetShowPos()
	local x = self.now[1] + (self.show[1] - 1) / 2
	local y = self.now[2] + (self.show[2] - 1) / 2
	self.selsec:SetPosition(self:SlotToPos(x, y))
end

function DragContainer:GoSection(x, y)
	local range_x = (self.show[1] - self.total[1]) / 2 * steps_x
	local range_y = (self.total[2] - self.show[2]) / 2 * steps_y
	local offset_x = (1 - self.show[1]) / 2 * steps_x
	local offset_y = (self.show[2] - 1) / 2 * steps_y

	local pos = self:GetWorldPosition()
	x = math.clamp(x, pos.x + range_x, pos.x - range_x) + offset_x
	y = math.clamp(y, pos.y - range_y, pos.y + range_y) + offset_y

	local nearest = Vector3(self:FindNearest(x, y))
	self.now[1], self.now[2] = self:PosToSlot(nearest.x, nearest.y)

	self.cursor_now = nearest + pos - Vector3(offset_x, offset_y)

	self:SetShowPos()
	self:ShowSection()
end

function DragContainer:TempSlotPos()
	local pos = {}
	for y = self.show[2], 1, -1 do
		for x = 1, self.show[1] do
			table.insert(pos, Vector3(80 * x - 40 * self.show[1] - 40, 80 * y - 40 * self.show[2] - 40, 0))
		end
	end
	return pos
end

local function getpage(self)
	return self:GetParent().chestpage ~= nil and self:GetParent().chestpage.currentpage or 1
end

function DragContainer:ShowSection()
	local inv = self:GetParent().inv
	if inv == nil then return end
	for i = 1, #inv do
		inv[i]:Hide()
	end
	local now_x, now_y = unpack(self.now)
	local show_x, show_y = unpack(self.show)
	local total_x, total_y = unpack(self.total)

	local y_start = now_y
	local y_end = now_y + show_y - 1
	local x_start = now_x
	local x_end = now_x + show_x - 1

	local pos = self:TempSlotPos()
	local j = 0
	local z = getpage(self)

	for y = y_start, y_end do
		for x = x_start, x_end do
			local i = x + (y - 1) * total_x + (z - 1) * total_x * total_y
			j = j + 1
			if inv[i] then
				inv[i]:SetPosition(pos[j])
				inv[i]:Show()
			end
		end
	end
end

function DragContainer:BuildItemList(list)
	local tx, ty = unpack(self.total)
	local page = 1
	local page_total = tx * ty

	for k, v in pairs(list) do
		local inventoryitem = v.replica.inventoryitem
		local atlas = inventoryitem:GetAtlas()
		local image = inventoryitem:GetImage()

		while k > page_total do
			page = page + 1
		end
		page_total = page_total + page * tx * ty
		local ItemGroup = self.imageroot.pages[page]
		if ItemGroup == nil then
			ItemGroup = self.imageroot:AddChild(Widget())
			self.imageroot.pages[page] = ItemGroup
		end

		local int, fra = math.modf((page_total - k) / tx)
		local x, y = tx - tx * fra, ty - int

		local item = Image(atlas, image)
		self.list[k] = ItemGroup:AddChild(item)
		item:SetScale(item_scale)
		item:SetPosition(self:SlotToPos(x, y))
	end

	self:Refresh()
end

function DragContainer:UpdateItem(data)
	local slot = data.slot
	local item = data.item
	if item and self.list[slot] then
		local inventoryitem = item.replica.inventoryitem
		local atlas = inventoryitem:GetAtlas()
		local image = inventoryitem:GetImage()
		self.list[slot]:SetTexture(atlas, image)
	elseif item then
		local tx, ty = unpack(self.total)
		local page_total = tx * ty
		local page = math.modf((slot - 1) / page_total) + 1

		local ItemGroup = self.imageroot.pages[page]
		if ItemGroup == nil then
			ItemGroup = self.imageroot:AddChild(Widget())
			self.imageroot.pages[page] = ItemGroup
		end

		local inventoryitem = item.replica.inventoryitem
		local atlas = inventoryitem:GetAtlas()
		local image = inventoryitem:GetImage()

		local int, fra = math.modf((page_total * page - slot) / tx)
		local x, y = tx - tx * fra, ty - int

		local item = Image(atlas, image)
		self.list[slot] = ItemGroup:AddChild(item)
		item:SetScale(item_scale)
		item:SetPosition(self:SlotToPos(x, y))
	elseif self.list[slot] then
		self.list[slot]:Kill()
		self.list[slot] = nil
	end
end

function DragContainer:Refresh()
	local currentpage = getpage(self)
	for k, v in pairs(self.imageroot.pages) do
		v:Hide()
	end
	if self.imageroot.pages[currentpage] then
		self.imageroot.pages[currentpage]:Show()
	end
end

function DragContainer:GetItemInSlot(x, y, z)
	if self.list and self.total then
		local lv_x, lv_y = unpack(self.total)
		local slot = (z - 1) * lv_x * lv_y + (y - 1) * lv_x + x
		return self.list[slot]
	end
end

function DragContainer:RescaleParentBG()
	local parent = self:GetParent()
	local container = parent.container
	local widget = container.replica.container:GetWidget()

	if not widget then return end

	local lv_x, lv_y = container.replica.chestupgrade:GetLv()

	local show_x, show_y = unpack(self.show)
	local scale_x = widget.bgscale ~= nil and widget.bgscale.x or 1
	local scale_y = widget.bgscale ~= nil and widget.bgscale.y or 1
	local scale = Vector3(scale_x * show_x / lv_x, scale_y * show_y / lv_y, 1)

	parent.bganim:SetScale(scale)
	parent.bgimage:SetScale(scale)
end

return DragContainer