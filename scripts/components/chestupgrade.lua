local AllUpgradeRecipes = ChestUpgrade.AllUpgradeRecipes or {}

local function mask(n)
	return bit.bnot(bit.lshift(bit.bnot(1), (n - 1)))
end

local function getmasklen(n)
	local masklen = 1
	while n > 1 do
		n = bit.rshift(n, 1)
		masklen = masklen + 1
	end
	return masklen
end

local MASKLEN_LV = math.max(4, getmasklen(TUNING.CHESTUPGRADE.MAX_LV))
local MASKLEN_PAGE = math.max(4, getmasklen(TUNING.CHESTUPGRADE.MAX_PAGE))
local MASKLEN_SP = 4

local MASK_LV = mask(MASKLEN_LV)
local MASK_PAGE = mask(MASKLEN_PAGE)
local MASK_SIDE = 1
local MASK_CENTER = 2

local ChestUpgrade = Class(function(self, inst)
	self.inst = inst
	self.baselv = Vector3(3, 3, 1)
	self.chestlv = Vector3(3, 3, 1)
end)

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

function ChestUpgrade:GetLv()
	return self.chestlv:Get()
end

function ChestUpgrade:SetBaseLv(x, y, z)
	SetLv(self.baselv, x, y, z)
	self.inst.replica.chestupgrade:SetBaseLv(self.baselv)
	self:SetChestLv(x, y, z)
	--self:UpdateWidget()
end

function ChestUpgrade:SetChestLv(x, y, z)
	SetLv(self.chestlv, x, y, z)
	self.inst.replica.chestupgrade:SetChestLv(self.chestlv)
	self:UpdateWidget()
	self.inst:PushEvent("onchestlvchange")
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

local function GetOffset(slotpos, blv, sep)
	--local SEP = issidewidget and 75 or 80
	local mid_pt = -(slotpos[1] + slotpos[#slotpos]) / 2

	local wide_original = (blv.x - 1) * sep.x
	local wide_now = slotpos[#slotpos].x - slotpos[1].x
	local hight_original = (blv.y - 1) * sep.y
	local hight_now = slotpos[1].y - slotpos[#slotpos].y

	local scale = Vector3(1,1)
	if wide_now > 0 and wide_original > 0 then
		scale.x = RoundBiasedDown((wide_original / wide_now), 2)
	end
	if hight_now > 0 and hight_original > 0 then
		scale.y = RoundBiasedDown((hight_original / hight_now), 2)
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
	if lv_x < 64 and lv_y < 64 then
		lv_code = lv_x + bit.lshift(lv_y, 6)
	end
	if params[self.inst.prefab] ~= nil and params[self.inst.prefab][lv_code] ~= nil then
		widget = params[self.inst.prefab][lv_code]

	else
		widget = setmetatable({}, {__index = container.widget})

		if params[self.inst.prefab] == nil then
			params[self.inst.prefab] = {}
		end

		local slotpos = container.widget.slotpos or {}
		local sep = params[self.inst.prefab].sep
		if sep == nil then
			sep = Vector3(80, 80)
			if #slotpos > 1 then
				if self.baselv.x > 1 then
					sep.x = (slotpos[2].x - slotpos[1].x)
				end
				if self.baselv.y > 1 then
					sep.y = (slotpos[1].y - slotpos[self.baselv.x + 1].y)
				end
			end
			params[self.inst.prefab].sep = sep
		end

		local shift_offset, scale_offset
		if params[self.inst.prefab].offset ~= nil then
			shift_offset, scale_offset = unpack(params[self.inst.prefab].offset)
		else
			shift_offset, scale_offset = GetOffset(container.widget.slotpos, self.baselv, sep)
			params[self.inst.prefab].offset = {shift_offset, scale_offset}
		end

		if container.issidewidget then
			widget.pos = Vector3(0, widget.pos.y, 0)
			widget.pos.x = math.floor((self.baselv.x - lv_x) * 23) - 92

		elseif container.type == "chest" then
			if self.drag then
				lv_x = math.min(self.drag, lv_x)
				lv_y = math.min(self.drag, lv_y)
			end
			if self.uipos then
				widget.pos = Vector3(-65 - 25 * lv_x, 0, 0)
			else
				widget.pos = Vector3(0, 80 + 30 * lv_y, 0)
			end
		end

		widget.bgshift = Vector3(lv_x / self.baselv.x * shift_offset.x, lv_y / self.baselv.y * shift_offset.y, 0)
		widget.bgscale = Vector3(lv_x / self.baselv.x * scale_offset.x, lv_y / self.baselv.y * scale_offset.y, 1)

		local init_x = -(lv_x + 1) * math.floor(sep.x / 2)
		local init_y = -(lv_y + 1) * math.floor(sep.y / 2)

		widget.slotpos = {}
		for y = lv_y, 1, -1 do
			for x = 1, lv_x do
				table.insert(widget.slotpos, Vector3(x * sep.x + init_x, y * sep.y + init_y, 0))
			end
		end

		if lv_code ~= 0 then
			params[self.inst.prefab][lv_code] = widget
		end
	end

	if lv_z > 1 then
		local slotpos_ref = widget.slotpos
		widget = setmetatable({slotpos = {}}, {__index = widget})

		for z = 1, lv_z do
			for _, pos in pairs(slotpos_ref) do
				table.insert(widget.slotpos, pos)
			end
		end
	end

	container:Close()
	--container:WidgetSetup(self.inst.prefab, {["widget"] = widget})
	ModCompat(container, widget)
end

local function GetSlotProps(allslots, targetslot)
	if targetslot ~= nil and allslots[targetslot] then
		local target 	= allslots[targetslot]
		local isside 	= bit.band(target, MASK_SIDE) ~= 0
		local iscenter 	= bit.band(target, MASK_CENTER) ~= 0
		local page 		= bit.band(bit.rshift(target, MASKLEN_SP + MASKLEN_LV + MASKLEN_LV), MASK_PAGE)
		local row 		= bit.band(bit.rshift(target, MASKLEN_SP + MASKLEN_LV), MASK_LV)
		local column 	= bit.band(bit.rshift(target, MASKLEN_SP), MASK_LV)
		return target, isside, iscenter, page, row, column
	end
end

local props = {}
function ChestUpgrade:SlotProps(slot)
	local x, y, z = self:GetLv()

	local lv_code = x + bit.lshift(y, MASKLEN_LV) + bit.lshift(z, MASKLEN_PAGE)

	local slots = props[lv_code] or {}
	if props[lv_code] == nil then
		local TR = x					--Top right hand corner
		local BR = x * y				--Bottom right
		local BL = BR - TR + 1			--Bottom left
		local TOTAL = BR * z

		for i = 1, TOTAL do
			local page = math.floor((i - 1) / BR) + 1
			local row = math.floor((i - 1) / x) + 1
			local column = (i - 1) % x + 1
			local bit_page = bit.lshift(bit.band(page, MASK_PAGE), MASKLEN_LV + MASKLEN_LV)
			local bit_row = bit.lshift(bit.band(row, MASK_LV), MASKLEN_LV)
			local bit_col = bit.band(column, MASK_LV)
			slots[i] = bit.lshift(bit_page + bit_row + bit_col, MASKLEN_SP)
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
			for i = TR, BR, TR do		--side: right
				slots[i+j] = bit.bor(slots[i+j], MASK_SIDE)
			end
			local m = 0
			local i = 0
			if bit.band(x, 1) ~= 0 then	--x-odd
				m = m + 1
			end
			if bit.band(y, 1) ~= 0 then	--y-odd
				m = m + 2
			end
			if m == 0 then				--center: x-even	y-even
				i = bit.rshift(BR - x, 1)
				slots[i+j] 		= bit.bor(slots[i+j]	, MASK_CENTER)
				slots[i+j+1] 	= bit.bor(slots[i+j+1]	, MASK_CENTER)
				slots[i+j+x] 	= bit.bor(slots[i+j+x]	, MASK_CENTER)
				slots[i+j+x+1] 	= bit.bor(slots[i+j+x+1], MASK_CENTER)
			elseif m == 1 then			--center: x-odd		y-even
				i = bit.rshift(BR - x + 1, 1)
				slots[i+j] 		= bit.bor(slots[i+j]	, MASK_CENTER)
				slots[i+j+x] 	= bit.bor(slots[i+j+x]	, MASK_CENTER)
			elseif m == 2 then			--center: x-even	y-odd
				i = bit.rshift(BR, 1)
				slots[i+j] 		= bit.bor(slots[i+j]	, MASK_CENTER)
				slots[i+j+1] 	= bit.bor(slots[i+j+1]	, MASK_CENTER)
			elseif m == 3 then			--center: x-odd		y-odd
				i = bit.rshift(BR + 1, 1)
				slots[i+j] 		= bit.bor(slots[i+j]	, MASK_CENTER)
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

function ChestUpgrade:CheckItem(slots, data, ...)
	if data == nil then
		data = AllUpgradeRecipes:GetParams(self.inst.prefab)		--self.ingredient
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

function ChestUpgrade:CreateCheckTable(data)
	if data == nil then
		data = AllUpgradeRecipes:GetParams(self.inst.prefab)		--self.ingredient
	end

	if data == nil then return {} end

	local slots = {}
	local slotprops = self:SlotProps()

	for i = 1, self.inst.components.container:GetNumSlots() do
		local target, isside, iscenter, page, row, column = GetSlotProps(slotprops, i)
		if data.slot and data.slot[i] then
			slots[i] = data.slot[i]
		elseif data.center and iscenter then
			slots[i] = data.center
		elseif data.column and data.column[column] then
			slots[i] = data.column[column]
		elseif data.row and data.row[row] then
			slots[i] = data.row[row]
		elseif data.hollow and not isside then
			slots[i] = false
		elseif data.side and isside then
			slots[i] = data.side
		elseif data.page and data.page[page] then
			slots[i] = data.page[page]
		elseif data.all then
			slots[i] = data.all
		else
			slots[i] = false
		end
	end

	return slots
end

function ChestUpgrade:Upgrade(lv, data, doer, fn, fnonly)
	local container = self.inst.components.container
	local x, y, z = self:GetLv()
	if lv ~= nil and (x * y >= lv * lv) or container == nil then return end 	--check for max lv
	if not self:CheckItem(container.slots, data, self.inst, doer) then
		return
	end

	container:DestroyContents()

	if not fnonly then
		self:SetChestLv(x + 2, y + 2)
	end

	local oldlv = {x, y, z}
	local newlv = {self:GetLv()}
	if self.onupgradefn ~= nil then
		self.onupgradefn(self.inst, doer, data, newlv, oldlv)
	end

	if fn ~= nil then
		fn(self.inst, doer, data, newlv, oldlv)
	end

	self.inst:PushEvent("onchestupgraded", {doer = doer, newlv = newlv, oldlv = oldlv})
end

function ChestUpgrade:Degrade(ratio, fn)
	if self.chestlv == self.baselv then return end

	local x, y, z = self:GetLv()

	local degradefn = AllUpgradeRecipes[self.inst.prefab] ~= nil and AllUpgradeRecipes[self.inst.prefab].degrade
	if degradefn then
		degradefn(self.inst, self)
	elseif (ratio == nil or ratio > 0) then
		local oldchecktbl = self:CreateCheckTable()
		self:SetChestLv(self.baselv)
		local newchecktbl = self:CreateCheckTable()

		local olditems = {}
		--for k, v in pairs(oldchecktbl) do
		for i = 1, (x * y) do
			local v = oldchecktbl[i]
			if v then
				local item = v.type
				local amount = v.amount

				olditems[item] = (olditems[item] or 0) + amount
			end
		end

		local newitems = {}
		for k, v in ipairs(newchecktbl) do
			if v then
				local item = v.type
				local amount = v.amount

				newitems[item] = (newitems[item] or 0) + amount
			end
		end

		local lvfactor = (x - self.baselv.x + y - self.baselv.y) / 4 + 1
		for prefab, amount in pairs(newitems) do
			local oldamount = olditems[prefab]
			local repayamount = (amount + oldamount) * lvfactor / 2 - oldamount
			--[[
			if amount == oldamount then
				repayamount = amount * (lvfactor - 1)
			else
				repayamount = (amount + oldamount) * lvfactor / 2 - oldamount
			end
			]]
			repayamount = math.floor(repayamount * (ratio or TUNING.CHESTUPGRADE.DEGRADE_RATIO))

			for i = 1, repayamount do
				self.inst.components.container:GiveItem(SpawnPrefab(prefab))
			end
		end
	else
		self:SetChestLv(self.baselv)
	end

	if self.ondegrade ~= nil then
		self.ondegrade(self.inst)
	end

	if fn ~= nil then
		fn(self.inst)
	end

	self.inst:PushEvent("onchestdegraded", {oldlv = {x,y,z}})
end

function ChestUpgrade:SpecialUpgrade(data, doer, delta)
	local x, y, z = self:GetLv()
	self:Upgrade(nil, data, doer, function()
		self:SetChestLv(x + (delta.x or 0), y + (delta.y or 0), z + (delta.z or 0))
	end, true)
end

function ChestUpgrade:OnSave()
	--local data = {}
	if self.chestlv ~= self.baselv then
		return {chestlv = {self:GetLv()}}
	end
	--return data
end

function ChestUpgrade:OnLoad(data)
	if data and data.chestlv then
		local savedlv = Vector3(unpack(data.chestlv))
		if self.chestlv ~= savedlv then
			self:SetChestLv(savedlv)
		end
	end
end

return ChestUpgrade