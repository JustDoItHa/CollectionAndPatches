local Widget = require("widgets/widget")
local Image = require("widgets/image")
local ImageButton = require("widgets/imagebutton")
local Text = require("widgets/text")

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
			self:GoSection(TheFrontEnd.lastx, TheFrontEnd.lasty)
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
end)

function DragContainer:SlotToPos(x, y)
	local steps_x = self.width / self.total[1]
	local steps_y = self.hight / self.total[2]
	local start_x = (steps_x - self.width) / 2
	local start_y = (self.hight - steps_y) / 2

	return start_x + steps_x * (x - 1), start_y - steps_y * (y - 1)
end

function DragContainer:PosToSlot(x, y)
	local steps_x = self.width / self.total[1]
	local steps_y = self.hight / self.total[2]
	local start_x = (steps_x - self.width) / 2
	local start_y = (self.hight - steps_y) / 2

	return (x - start_x) / steps_x + 1, (start_y - y) / steps_y + 1
end

function DragContainer:FindNearest(x, y)
	local steps_x = self.width / self.total[1]
	local steps_y = self.hight / self.total[2]
	local start_x = (steps_x - self.width) / 2
	local start_y = (self.hight - steps_y) / 2

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
	local steps_x = self.width / self.total[1]
	local steps_y = self.hight / self.total[2]
	local start_x = (self.show[1] - self.total[1]) / 2 * steps_x
	local start_y = (self.total[2] - self.show[2]) / 2 * steps_y

	local pos = self:GetWorldPosition()
	x = math.clamp(x, pos.x + start_x, pos.x - start_x) - (self.show[1] - 1) / 2 * steps_x
	y = math.clamp(y, pos.y - start_y, pos.y + start_y) + (self.show[2] - 1) / 2 * steps_y
	
	self.now[1], self.now[2] = self:PosToSlot(self:FindNearest(x, y))

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

function DragContainer:ShowSection()
	local inv = self:GetParent().inv
	if inv == nil then return end
	for i = 1, #inv do
		inv[i]:Hide()
	end
	local pos = self:TempSlotPos()
	local j = 0
	local z = self:GetParent().chestpage ~= nil and self:GetParent().chestpage.currentpage or 1
	for y = self.now[2], self.now[2] + (self.show[2] - 1) do
		for x = self.now[1], self.now[1] + (self.show[1] - 1) do
			local i = x - self.total[1] + self.total[1] * y + self.total[1] * self.total[2] * (z - 1)
			j = j + 1
			if inv[i] then
				inv[i]:SetPosition(pos[j])
				inv[i]:Show()
			elseif self.total[1] == 7 then		--idk why when it = 7 and y or x = 2, bug appear
				inv[7+x]:SetPosition(pos[j])
				inv[7+x]:Show()
			end
		end
	end
end

return DragContainer