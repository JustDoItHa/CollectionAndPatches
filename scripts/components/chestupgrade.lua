local AllUpgradeRecipes = ChestUpgrade.AllUpgradeRecipes or {}

local function mask(n)
	return bit.bnot(bit.lshift(bit.bnot(1), (n - 1)))
end

local function getmasklen()
	local MASKLEN_LV = math.max(4, math.floor(math.log10(TUNING.CHESTUPGRADE.MAX_LV) / math.log10(2)) + 1)
	local MASKLEN_PAGE = math.max(4, math.floor(math.log10(TUNING.CHESTUPGRADE.MAX_PAGE) / math.log10(2)) + 1)
	return MASKLEN_LV, MASKLEN_PAGE
end

local function getlvcode(self)
	local MASKLEN_LV = getmasklen()
	local x, y, z = self.chestlv:Get()
	return bit.bor(bit.lshift(z, (MASKLEN_LV + MASKLEN_LV)), bit.lshift(y, MASKLEN_LV), x)
end

local function onbaselv(self, baselv)
	self.inst.replica.chestupgrade:SetBaseLv(baselv)
end

local function onchestlv(self, chestlv)
	self.inst.replica.chestupgrade:SetChestLv(chestlv)
end

local function SetLv(lv, x, y, z)
	if z == nil then
		z = lv.z
	end
	if type(x) == "table" then
		if x.x ~= nil then
			lv.x = x.x or lv.x
			lv.y = x.y or lv.y
			lv.z = x.z or lv.z
		else
			SetLv(lv, unpack(x))
		end
	elseif y then
		lv._ctor(lv, x, y, z)
	else
		lv._ctor(lv, x, x, z)
	end
end
--[[
local LV_VEC3 = Class(Vector3)
LV_VEC3.SetLv = SetLv
]]
local ChestUpgrade = Class(function(self, inst)
	self.inst = inst
	self.baselv = Vector3(3, 3, 1)
	self.chestlv = Vector3(3, 3, 1)

	self.baselv.SetLv = SetLv
	self.chestlv.SetLv = SetLv
	--self.ingredient = {}
	--self.tags = {}
end)

function ChestUpgrade:GetLv()
	return self.chestlv.x, self.chestlv.y, self.chestlv.z
end

function ChestUpgrade:SetBaseLv(x, y, z)
	if self.baselv == self.chestlv then
		self:SetChestLv(x, y, z)
	end
	self.baselv:SetLv(x, y, z)
	--self.baselv = self.chestlv
	self.inst.replica.chestupgrade:SetBaseLv(self.baselv)
	self:UpdateWidget()
end

function ChestUpgrade:SetChestLv(x, y, z)
	local container = self.inst.components.container
	if container ~= nil then
		self.chestlv:SetLv(x, y, z)
		self.inst.replica.chestupgrade:SetChestLv(self.chestlv)
		self:UpdateWidget()
		self.inst:PushEvent("onchestlvchange")
	end
end

--for mods that overwrite containers.widgetsetup and not adding data arg
local function ModCompat(container, widget)
	--remove them from read only so that we can update them
	removesetter(container, "widget")
	removesetter(container, "numslots")

	container.widget = widget
	container.numslots = widget.slotpos ~= nil and #widget.slotpos or 0
	container.inst.replica.chestupgrade:UpdateWidget()

	--make them read only again after update
	makereadonly(container, "widget")
	makereadonly(container, "numslots")
end

local function GetOffset(slotpos, blv, issidewidget)
	--local slotpos
	local SEP = issidewidget and 75 or 80
	local mid_pt = (slotpos[1] + slotpos[#slotpos]) / -2

	local wide_original = (blv.x - 1) * SEP
	local wide_now = slotpos[#slotpos].x - slotpos[1].x
	local hight_original = (blv.y - 1) * SEP
	local hight_now = slotpos[1].y - slotpos[#slotpos].y

	local scale = {1, 1}
	if wide_now > 0 and wide_original > 0 then
		scale[1] = RoundBiasedDown((wide_original / wide_now), 2)
	end
	if hight_now > 0 and hight_original > 0 then
		scale[2] = RoundBiasedDown((hight_original / hight_now), 2)
	end

	return mid_pt, scale
end

local params = {}
function ChestUpgrade:UpdateWidget()
	local container = self.inst.components.container
	if container == nil then return end
	local lv_x, lv_y, lv_z = self:GetLv()

	local widget
	local lv_code = 0
	if lv_x < 64 and lv_z < 64 then
		lv_code = lv_x + bit.lshift(lv_y, 6) + bit.lshift(lv_z, 12)
	end
	if params[self.inst.prefab] ~= nil and params[self.inst.prefab][lv_code] ~= nil then
		widget = params[self.inst.prefab][lv_code]

	else
		widget = shallowcopy(container.widget)
		local shift_offset, scale_offset
		if params[self.inst.prefab] ~= nil and params[self.inst.prefab].offset ~= nil then
			shift_offset, scale_offset = unpack(params[self.inst.prefab].offset)
		else
			if params[self.inst.prefab] == nil then
				params[self.inst.prefab] = {}
			end
			shift_offset, scale_offset = GetOffset(widget.slotpos, self.baselv, container.issidewidget)
			if widget.animbank == "ui_chester_shadow_3x4" or widget.animbank == "ui_portal_shadow_3x4" then
				scale_offset[1] = 1
			end
			params[self.inst.prefab].offset = {shift_offset, scale_offset}
		end
		if container.issidewidget then
			--[[
				--get mid pt of the widgets
				local mid_y = (widget.slotpos[1].y + widget.slotpos[#widget.slotpos].y) / 2
				--finely adjust the pos, so that we can locate the top pos
				local adjust = lv_y / 2 + 75 / 2
				--75/2 because y start from 1 instead of 0
				--lv_y/2 for 37.5*lv_y, we move the decimal pt calculation here
			]]
			local adjust = math.floor((widget.slotpos[1].y + widget.slotpos[#widget.slotpos].y + lv_y + 75) / 2)
			widget.slotpos = {}
			for z = 1, lv_z do
				for y = 1, lv_y do
					for x = 1, lv_x do
						table.insert(widget.slotpos, Vector3(75 * x - 75 * lv_x - 87, -75 * y + 37 * lv_y + adjust, 0))
					end
				end
			end

		else
			--the widget pos should shift leftward so that it wont block the chest and the player
			widget.pos = Vector3(-65 - 25 * lv_x, 0, 0)		--Vector3(-50 - 30 * lv_x, 0, 0)

			--rearrange the slot widget
			widget.slotpos = {}
			for z = 1, lv_z do
				for y = lv_y, 1, -1 do
					for x = 1, lv_x do
						table.insert(widget.slotpos, Vector3(80 * x - 40 * lv_x - 40, 80 * y - 40 * lv_y - 40, 0))
					end
				end
			end
			widget.bgshift = Vector3(lv_x / self.baselv.x * shift_offset.x, lv_y / self.baselv.y * shift_offset.y, 0)
			widget.bgscale = Vector3(lv_x / self.baselv.x * scale_offset[1], lv_y / self.baselv.y * scale_offset[2], 1)
		end
		if lv_code ~= 0 then
			params[self.inst.prefab][lv_code] = widget
		end
	end

	container:Close()
	--container:WidgetSetup(self.inst.prefab, {["widget"] = widget})
	ModCompat(container, widget)
end

local function CheckItem(data, item, ...)
	local prefab, amount
	if type(data) == "string" then
		prefab = data
	elseif type(data) == "table" then
		if data.type ~= nil then
			prefab = data.type
			amount = data.amount ~= 0 and data.amount or nil
		else
			prefab, amount = data[1], data[2]
		end
	elseif type(data) == "function" then
		return data(item, ...)
	end

	if amount ~= nil and item ~= nil and item.components.stackable ~= nil and item.components.stackable:StackSize() ~= amount then
		return false
	end

	if not (item ~= nil and item.prefab == prefab or item == prefab) then
		return false
	end

	return true
end

--slot, center, column, row, hollow, side, page, all
function ChestUpgrade:CreateCheckTable(data)
	if data == nil then
		data = AllUpgradeRecipes[self.inst.prefab]		--self.ingredient
	end

	if data == nil then return end

	local TR, y = self:GetLv()										--Top right hand corner
	local BR = self.inst.components.container:GetNumSlots()			--Bottom right
	local BL = BR - TR + 1											--Bottom left

	local slot = {}
	local all = data.all or false
	for i = 1, BR do
		slot[i] = all
	end

	if data.page then
		local PBR = TR * y			--page bottom right
		for k, v in pairs(data.page) do
			for i = 1, PBR do
				local j = (k - 1) * PBR + i
				slot[j] = v
			end
		end
	end

	if data.side then
		for i = 1, TR do slot[i] = data.side end			--top
		for i = BL, BR do slot[i] = data.side end			--bottom
		for i = 1, BL, TR do slot[i] = data.side end		--left
		for i = TR, BR, TR do slot[i] = data.side end		--right
	end

	if data.hollow then
		for k = 1, TR - 2 do
			for i = k * TR + 2, k * TR + TR - 1 do
				slot[i] = false
			end
		end
	end

	if data.row then
		for k, v in pairs(data.row) do
			for i = 1, TR do
				local j = (k - 1) * TR + i
				slot[j] = v
			end
		end
	end

	if data.column then
		for k, v in pairs(data.column) do
			for i = 1, BL, TR do
				local j = (k - 1) + i
				slot[j] = v
			end
		end
	end

	if data.center then
		if (BR + 1)%2 == 0 then
			slot[(BR + 1)/2] = data.center
		end
	end

	if data.slot then
		for k, v in pairs(data.slot) do
			slot[k] = v
		end
	end

	return slot
end

--[[
local function GetSlotProps(allslots, targetslot)
	if targetslot ~= nil and allslots[targetslot] then
		local target = allslots[targetslot]
		local isside = bit.band(target, 0x1000) ~= 0
		local iscenter = bit.band(target, 0x2000) ~= 0
		local page = bit.band(bit.rshift(target, 8), 15)
		local row = bit.band(bit.rshift(target, 4), 15)
		local column = bit.band(target, 15)
		return target, isside, iscenter, page, row, column
	--elseif not slots[slot] then
		--print("[ChestUpgrade]: Invalid input on getting SlotProps")
	end
end
]]

local function GetSlotProps(allslots, targetslot)
	local MASKLEN_LV, MASKLEN_PAGE = getmasklen()
	local MASKPOS_SIDE = MASKLEN_LV * 2 + MASKLEN_PAGE

	local MASK_LV = mask(MASKLEN_LV)
	local MASK_PAGE = mask(MASKLEN_PAGE)
	local MASK_SIDE = bit.lshift(1, MASKPOS_SIDE)
	local MASK_CENTER = bit.lshift(2, MASKPOS_SIDE)

	if targetslot ~= nil and allslots[targetslot] then
		local target = allslots[targetslot]
		local isside = bit.band(target, MASK_SIDE) ~= 0
		local iscenter = bit.band(target, MASK_CENTER) ~= 0
		local page = bit.band(bit.rshift(target, MASKLEN_LV * 2), MASK_PAGE)
		local row = bit.band(bit.rshift(target, MASKLEN_LV), MASK_LV)
		local column = bit.band(target, MASK_LV)
		return target, isside, iscenter, page, row, column
	end
end

function ChestUpgrade:CheckItem(slots, data, ...)
	if data == nil then
		data = AllUpgradeRecipes[self.inst.prefab]		--self.ingredient
	end
	if data == nil or slots == nil then return false end
	local slotprops = self:SlotProps()
	local checkpass = true
	for i = 1, self.inst.components.container:GetNumSlots() do
		local target, isside, iscenter, page, row, column = GetSlotProps(slotprops, i)
		if data.slot and data.slot[i] then
			checkpass = CheckItem(data.slot[i], slots[i], i, ...)
		elseif data.center and iscenter then
			checkpass = CheckItem(data.center, slots[i], i, ...)
		elseif data.column and data.column[column] then
			checkpass = CheckItem(data.column[column], slots[i], i, ...)
		elseif data.row and data.row[row] then
			checkpass = CheckItem(data.row[row], slots[i], i, ...)
		elseif data.hollow and not isside then
			checkpass = CheckItem(nil, slots[i], i, ...)
		elseif data.side and isside then
			checkpass = CheckItem(data.side, slots[i], i, ...)
		elseif data.page and data.page[page] then
			checkpass = CheckItem(data.page[page], slots[i], i, ...)
		elseif data.all then
			checkpass = CheckItem(data.all, slots[i], i, ...)
		else
			checkpass = CheckItem(nil, slots[i], i, ...)
		end
		if not checkpass then
			return false
		end
	end
	return true
end

--center: 0010 0000 0000 0000	--8192
--side	: 0001 0000 0000 0000	--4096
--page	: 0000 1111 0000 0000	--256~3840
--row	: 0000 0000 1111 0000	--16~240
--column: 0000 0000 0000 1111	--1~15
local props = {}
--[[
function ChestUpgrade:SlotProps(slot)
	local x, y, z = self:GetLv()
	local lv_code = x + bit.lshift(y, 4) + bit.lshift(z, 8)
	local slots = props[lv_code] or {}
	if props[lv_code] == nil then
		local TR = x					--Top right hand corner
		local BR = x * y				--Bottom right
		local BL = BR - TR + 1			--Bottom left
		local TOTAL = self.inst.components.container:GetNumSlots()			--page bottom left

		for i = 1, TOTAL do
			local page = math.floor((i - 1) / BR) + 1
			local bit_page = bit.lshift(bit.band(page, 15), 8)
			local row = math.floor((i - 1) / x) + 1
			local bit_row = bit.lshift(bit.band(row, 15), 4)
			local column = (i - 1) % x + 1
			local bit_col = bit.band(column, 15)
			slots[i] = bit_page + bit_row + bit_col
		end

		for p = 1, z do
			local j = (p - 1) * BR
			for i = 1, TR do			--side: top
				slots[i+j] = bit.bor(slots[i+j], 0x1000)
			end
			for i = BL, BR do			--side: bottom
				slots[i+j] = bit.bor(slots[i+j], 0x1000)
			end
			for i = 1, BL, TR do		--sied: left
				slots[i+j] = bit.bor(slots[i+j], 0x1000)
			end
			for i = TR, BR, TR do	--side: right
				slots[i+j] = bit.bor(slots[i+j], 0x1000)
			end
			local m = 0
			local i = 0
			if x % 2 ~= 0 then
				m = m + 1
			end
			if y % 2 ~= 0 then
				m = m + 2
			end
			if m == 0 then				--center: x-even	y-even
				i = (BR - x) / 2
				slots[i+j] = bit.bor(slots[i+j], 0x2000)
				slots[i+j+1] = bit.bor(slots[i+j+1], 0x2000)
				slots[i+j+x] = bit.bor(slots[i+j+x], 0x2000)
				slots[i+j+x+1] = bit.bor(slots[i+j+x+1], 0x2000)
			elseif m == 1 then			--center: x-odd		y-even
				i = (BR - x - 1) / 2
				slots[i+j] = bit.bor(slots[i+j], 0x2000)
				slots[i+j+x] = bit.bor(slots[i+j+x], 0x2000)
			elseif m == 2 then			--center: x-even	y-odd
				i = BR / 2
				slots[i+j] = bit.bor(slots[i+j], 0x2000)
				slots[i+j+1] = bit.bor(slots[i+j+x], 0x2000)
			elseif m == 3 then			--center: x-odd		y-odd
				i = (BR + 1) / 2
				slots[i+j] = bit.bor(slots[i+j], 0x2000)
			end
		end
		props[lv_code] = slots
	end

	if slot then
		return GetSlotProps(slots, slot)
	end
	return slots
end
]]
function ChestUpgrade:SlotProps(slot)
	local x, y, z = self:GetLv()

	local MASKLEN_LV, MASKLEN_PAGE = getmasklen()
	local MASKPOS_SIDE = MASKLEN_LV * 2 + MASKLEN_PAGE

	local MASK_LV = mask(MASKLEN_LV)
	local MASK_PAGE = mask(MASKLEN_PAGE)
	local MASK_SIDE = bit.lshift(1, MASKPOS_SIDE)
	local MASK_CENTER = bit.lshift(2, MASKPOS_SIDE)

	local lv_code = x + bit.lshift(y, MASKLEN_LV) + bit.lshift(z, MASKLEN_LV * 2)

	local slots = props[lv_code] or {}
	if props[lv_code] == nil then
		local TR = x					--Top right hand corner
		local BR = x * y				--Bottom right
		local BL = BR - TR + 1			--Bottom left
		local TOTAL = BR * z

		for i = 1, TOTAL do
			local page = math.floor((i - 1) / BR) + 1
			local bit_page = bit.lshift(bit.band(page, MASK_PAGE), MASKLEN_LV * 2)
			local row = math.floor((i - 1) / x) + 1
			local bit_row = bit.lshift(bit.band(row, MASK_LV), MASKLEN_LV)
			local column = (i - 1) % x + 1
			local bit_col = bit.band(column, MASK_LV)
			slots[i] = bit_page + bit_row + bit_col
		end

		for p = 1, z do
			local j = (p - 1) * BR
			for i = 1, TR do			--side: top
				slots[i+j] = bit.bor(slots[i+j], MASK_SIDE)
			end
			for i = BL, BR do			--side: bottom
				slots[i+j] = bit.bor(slots[i+j], MASK_SIDE)
			end
			for i = 1, BL, TR do		--sied: left
				slots[i+j] = bit.bor(slots[i+j], MASK_SIDE)
			end
			for i = TR, BR, TR do	--side: right
				slots[i+j] = bit.bor(slots[i+j], MASK_SIDE)
			end
			local m = 0
			local i = 0
			if x % 2 ~= 0 then
				m = m + 1
			end
			if y % 2 ~= 0 then
				m = m + 2
			end
			if m == 0 then				--center: x-even	y-even
				i = (BR - x) / 2
				slots[i+j] = bit.bor(slots[i+j], MASK_CENTER)
				slots[i+j+1] = bit.bor(slots[i+j+1], MASK_CENTER)
				slots[i+j+x] = bit.bor(slots[i+j+x], MASK_CENTER)
				slots[i+j+x+1] = bit.bor(slots[i+j+x+1], MASK_CENTER)
			elseif m == 1 then			--center: x-odd		y-even
				i = (BR - x - 1) / 2
				slots[i+j] = bit.bor(slots[i+j], MASK_CENTER)
				slots[i+j+x] = bit.bor(slots[i+j+x], MASK_CENTER)
			elseif m == 2 then			--center: x-even	y-odd
				i = BR / 2
				slots[i+j] = bit.bor(slots[i+j], MASK_CENTER)
				slots[i+j+1] = bit.bor(slots[i+j+1], MASK_CENTER)
			elseif m == 3 then			--center: x-odd		y-odd
				i = (BR + 1) / 2
				slots[i+j] = bit.bor(slots[i+j], MASK_CENTER)
			end
		end
		props[lv_code] = slots
	end

	if slot then
		return GetSlotProps(slots, slot)
	end
	return slots
end

function ChestUpgrade:PrintSlotProps(slot)
	local target, isside, iscenter, page, row, column = self:SlotProps(slot)
	local str = string.format(
			"Slot: %d\tIs Side: %s\tIs Center: %s\nPage: %d\tRow: %d\tColumn: %d",
			slot,
			tostring(isside),
			tostring(iscenter),
			page,
			row,
			column
	)
	print(str)
	return str
end

function ChestUpgrade:Upgrade(lv, data, doer, fnonly, fn)
	local container = self.inst.components.container
	local x, y, z = self:GetLv()
	if lv ~= nil and (x * y >= lv * lv) or container == nil then return end 	--check for max lv
	if not self:CheckItem(container.slots, data, self.inst, doer) then
		return
	end

	--container:Close()
	container:DestroyContents()

	if not fnonly then
		self:SetChestLv(x + 2, y + 2)
	end

	if fn ~= nil then
		fn(self.inst, doer, data)
	end

	self.inst:PushEvent("onchestupgraded", {doer = doer, newlv = {self:GetLv()}, oldlv = {x, y, z}})
end

function ChestUpgrade:Degrade(doer)		--return the chest to normal
	local container = self.inst.components.container
	local side = AllUpgradeRecipes[self.inst.prefab] and
			(AllUpgradeRecipes[self.inst.prefab].degrade or AllUpgradeRecipes[self.inst.prefab].side) or nil
	if side ~= nil and container ~= nil and container:NumItems() == 1 then
		for i = 1, container:GetNumSlots() do

			local hammer = container.slots[i]

			if hammer ~= nil and hammer:HasTag("HAMMER_tool") then		--use tag so that modded hammer can do degrade

				--container:Close()

				if hammer.components.finiteuses ~= nil then				--~=nil check for infinite uses hammer
					local USES = math.max(self.chestlv.x - self.baselv.x + self.chestlv.y - self.baselv.y, 0)
					--local USES = math.floor(self.chestlv:Dist(self.baselv))
					hammer.components.finiteuses:Use(USES * TUNING.CHESTUPGRADE.DEGRADE_USE)
				end

				container:DropItemBySlot(i, doer:GetPosition())

				local count = math.max((self.chestlv.x - 2) * (self.chestlv.y - 2) - 1, 0) * TUNING.CHESTUPGRADE.DEGRADE_RATIO
				local prefab, amount
				if type(side) == "table" then
					if side.type then
						prefab = side.type
						amount = side.amount
					else
						prefab = side[1]
						amount = side[2]
					end
				elseif type(side) == "string" then
					prefab = side
					amount = 1
				elseif type(side) == "function" then
					prefab, count = side(self.chestlv)
					amount = 1
				else
					break
				end

				self:SetChestLv(self.baselv)
				for i = 1, math.floor(count) do
					for j = 1, amount do
						container:GiveItem(SpawnPrefab(prefab))
					end
				end
				break

			end

		end
	end
end

function ChestUpgrade:SpecialUpgrade(data, doer, delta)
	local x, y, z = self:GetLv()
	self:Upgrade(nil, data, doer, true, function()
		self:SetChestLv(x + (delta.x or 0), y + (delta.y or 0), z + (delta.z or 0))
	end)
end

function ChestUpgrade:OnSave()
	local data = {}
	data.chestlv = {self:GetLv()}
	--if #self.tags > 0 then
	--	data.tags = self.tags
	--end
	return data
end

function ChestUpgrade:OnLoad(data)
	if data then
		self:SetChestLv(data.chestlv)
		--if data.tags then
		--	self.tags = data.tags
		--end
		--self.inst:PushEvent("chectupgrade_onload", {chestlv = self.chestlv, tags = self.tags})
	end
end

return ChestUpgrade