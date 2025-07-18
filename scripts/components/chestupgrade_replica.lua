local AllUpgradeRecipes = ChestUpgrade.AllUpgradeRecipes or {}
--net_byte: 8; net_ushortint: 16
local use_net_byte = TUNING.CHESTUPGRADE.MAX_LV <= 15 and TUNING.CHESTUPGRADE.MAX_PAGE == 1 and TUNING.CHESTUPGRADE.MAXPACKPAGE == 1
local use_ushort = TUNING.CHESTUPGRADE.MAX_LV <= 63 and TUNING.CHESTUPGRADE.MAX_PAGE <= 15 and TUNING.CHESTUPGRADE.MAXPACKPAGE <= 15

local function OnBaseLv(inst)
	local chestupgrade = inst.replica.chestupgrade
	local blv = chestupgrade.net_blv:value()
	chestupgrade.baselv.x = bit.band(blv, 7)
	chestupgrade.baselv.y = bit.rshift(blv, 3)
	chestupgrade:UpdateWidget()
end

local function OnChestLv(inst)
	local chestupgrade = inst.replica.chestupgrade
	local clv = chestupgrade.net_clv:value()
	if use_net_byte then
		chestupgrade.chestlv.x = bit.band(clv, 15)
		chestupgrade.chestlv.y = bit.rshift(clv, 4)
	else
		chestupgrade.chestlv.x = bit.band(clv, 63)
		chestupgrade.chestlv.y = bit.band(bit.rshift(clv, 6), 63)
		chestupgrade.chestlv.z = bit.rshift(clv, 12)
	end
	chestupgrade:UpdateWidget()
end

local function OnChestLvDirty(inst)
	local chestupgrade = inst.replica.chestupgrade
	chestupgrade.chestlv.x = chestupgrade.net_lvx:value()
	chestupgrade.chestlv.y = chestupgrade.net_lvy:value()
	chestupgrade.chestlv.z = chestupgrade.net_lvz:value()
	chestupgrade:UpdateWidget()
end

local ChestUpgrade = Class(function(self, inst)
	self.inst = inst
	self.baselv = Vector3(3, 3, 1)
	self.net_blv = net_smallbyte(self.inst.GUID, "onbaselv", "onbaselv")

	self.chestlv = Vector3(3, 3, 1)
	if use_net_byte then
		self.net_clv = net_byte(self.inst.GUID, "chestlv", "onchestlv")
	elseif use_ushort then
		self.net_clv = net_ushortint(self.inst.GUID, "chestlv", "onchestlv")
	else
		self.net_lvx = net_ushortint(self.inst.GUID, "chestlvx", "onchestlvdirty")
		self.net_lvy = net_ushortint(self.inst.GUID, "chestlvy", "onchestlvdirty")
		self.net_lvz = net_ushortint(self.inst.GUID, "chestlvz", "onchestlvdirty")
	end

	if not TheWorld.ismastersim then
		self.inst:ListenForEvent("onbaselv", OnBaseLv)
		self.inst:ListenForEvent("onchestlv", OnChestLv)
		self.inst:ListenForEvent("onchestlvdirty", OnChestLvDirty)
	end
end)

function ChestUpgrade:GetLv()
	return self.chestlv.x, self.chestlv.y, self.chestlv.z
end

function ChestUpgrade:SetBaseLv(baselv)
	--self:SetChestLv(baselv)
	self.baselv = baselv
	local blv = baselv.x + bit.lshift(baselv.y, 3)
	self.net_blv:set(blv)
	--self:UpdateWidget()
end

function ChestUpgrade:SetChestLv(chestlv)
	self.chestlv = chestlv
	if use_net_byte then
		local clv = chestlv.x + bit.lshift(chestlv.y, 4)
		self.net_clv:set(clv)
	elseif use_ushort then
		local clv = chestlv.x + bit.lshift(chestlv.y, 6) + bit.lshift(chestlv.z, 12)
		self.net_clv:set(clv)
	else
		self.net_lvx:set(chestlv.x)
		self.net_lvy:set(chestlv.y)
		self.net_lvz:set(chestlv.z)
	end
	--self:UpdateWidget()
end

function ChestUpgrade:CreateCheckTable(data)
	if data == nil then
		data = AllUpgradeRecipes:GetParams(self.inst.prefab)
	end

	if data == nil then return {} end

	local x, y, z = self:GetLv()

	local TL = 1
	local TR = x
	local BR = TR * y
	local BL = BR - TR + 1

	local slot = {}
	for page = 1, z do
		--local all = data.all or false
		local n = BR * (page - 1)
		for i = 1, BR do
			slot[i+n] = (data.page ~= nil and data.page[page]) or data.all or false
		end

		if data.side then
			for i = 1, TR do slot[i+n] = data.side end
			for i = BL, BR do slot[i+n] = data.side end
			for i = 1, BL, TR do slot[i+n] = data.side end
			for i = TR, BR, TR do slot[i+n] = data.side end
		end

		if data.hollow then
			for k = 1, BL - 2 do
				for i = k * TR + 2, k * TR + TR - 1 do
					slot[i+n] = false
				end
			end
		end

		if data.row then
			for k, v in pairs(data.row) do
				for i = 1, TR do
					local j = (k - 1) * TR + i + n
					slot[j] = v
				end
			end
		end

		if data.column then
			for k, v in pairs(data.column) do
				for i = 1, BL, TR do
					local j = (k - 1) + i + n
					slot[j] = v
				end
			end
		end

		if data.center then
			local m = 0
			local i = 0
			if IsNumberEven(x) then
				m = m + 1
			end
			if IsNumberEven(y) then
				m = m + 2
			end
			if m == 3 then				--center: x-even	y-even
				i = (BR - x) / 2
				slot[i+n] 		= data.center
				slot[i+n+1] 	= data.center
				slot[i+n+x] 	= data.center
				slot[i+n+x+1] 	= data.center
			elseif m == 2 then			--center: x-odd		y-even
				i = (BR - x + 1) / 2
				slot[i+n] 		= data.center
				slot[i+n+x] 	= data.center
			elseif m == 1 then			--center: x-even	y-odd
				i = (BR) / 2
				slot[i+n] 		= data.center
				slot[i+n+1] 	= data.center
			elseif m == 0 then			--center: x-odd		y-odd
				i = (BR + 1) / 2
				slot[i+n] 		= data.center
			end
		end
	end

	if data.slot then
		for k, v in pairs(data.slot) do
			slot[k] = v
		end
	end

	return slot
end

local function ModCompat(container, widget)
	container.widget = widget

	container:SetNumSlots(widget.slotpos ~= nil and #widget.slotpos or 0)

	if container.classified ~= nil then
		container.classified:InitializeSlots(container:GetNumSlots())
		--[[
		if container.classified.OnReinitialize ~= nil then
			container.classified:RemoveAllEventCallbacks()
			container.classified:OnReinitialize()
		end
		]]
	end
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
	local container = self.inst.replica.container
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

		if widget.slotbg ~= nil and widget.slotbg[1] ~= nil then
			local generic = widget.slotbg[1]
			for k, v in pairs(widget.slotbg) do
				if v.image ~= generic.image or v.atlas ~= generic.atlas then
					generic = nil
				end
			end
			--container.widget.slotbg.generic = generic
			if generic then
				widget.slotbg = generic
				widget.slotbg.generic = true
			end
		end

		local slotpos = container.widget.slotpos or {}
		local sep = params[self.inst.prefab].sep
		if sep == nil then
			sep = Vector3(80, 80)
			if #slotpos > 1 then
				if self.baselv.x > 1 then
					sep.x = math.abs(slotpos[#slotpos].x - slotpos[1].x) / (self.baselv.x - 1)
				end
				if self.baselv.y > 1 then
					sep.y = math.abs(slotpos[1].y - slotpos[#slotpos].y) / (self.baselv.y - 1)
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

	--container:Close()
	--container:WidgetSetup(self.inst.prefab, {["widget"] = widget})
	ModCompat(container, widget)
end

return ChestUpgrade