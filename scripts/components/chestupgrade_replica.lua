local AllUpgradeRecipes = ChestUpgrade.AllUpgradeRecipes or {}
--net_byte: 8; net_ushortint: 16
local use_net_byte = TUNING.CHESTUPGRADE.MAX_PAGE == 1 and TUNING.CHESTUPGRADE.MAX_LV <= 15 and TUNING.CHESTUPGRADE.MAXPACKUPGRADE == nil

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
		chestupgrade.chestlv.y = bit.rshift(bit.band(clv, 4032), 6)
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
	elseif TUNING.CHESTUPGRADE.MAX_LV <= 63 then
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
	elseif TUNING.CHESTUPGRADE.MAX_LV <= 63 then
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
		data = AllUpgradeRecipes[self.inst.prefab] or {}
	end

	local TR, y = self:GetLv()
	local BR = TR * y
	local BL = BR - TR + 1

	local slot = {}
	local all = data.all or false
	for i = 1, BR do
		slot[i] = all
	end

	if data.side then
		for i = 1, TR do slot[i] = data.side end
		for i = BL , BR do slot[i] = data.side end
		for i = 1, BL, TR do slot[i] = data.side end
		for i = TR, BR, TR do slot[i] = data.side end
	end

	if data.hollow then
		for k = 1, TR - 2 do
			for i = k * TR + 2, k * TR + TR - 1 do
				slot[i] = false
			end
		end
	end

	if data.row then
		for i = 1, TR do
			for k, v in pairs(data.row) do
				local j = (k - 1) * TR + i
				slot[j] = v
			end
		end
	end

	if data.column then
		for i = 1, BL, TR do
			for k, v in pairs(data.column) do
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
	local container = self.inst.replica.container
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
		widget = shallowcopy(container:GetWidget())

		local shift_offset, scale_offset
		if params[self.inst.prefab] ~= nil and params[self.inst.prefab].offset ~= nil then
			shift_offset, scale_offset = unpack(params[self.inst.prefab].offset)
		else
			if params[self.inst.prefab] == nil then
				params[self.inst.prefab] = {}
			end
			shift_offset, scale_offset = GetOffset(widget.slotpos, self.baselv, container.issidewidget)
			--print("shift_offset",shift_offset)
			if widget.animbank == "ui_chester_shadow_3x4" or widget.animbank == "ui_portal_shadow_3x4" then
				scale_offset[1] = 1
			end
			params[self.inst.prefab].offset = {shift_offset, scale_offset}
		end

		if container.issidewidget then
			local adjust = math.floor((widget.slotpos[1].y + widget.slotpos[#widget.slotpos].y + lv_y) / 2) + 37
			widget.slotpos = {}
			for z = 1, lv_z do
				for y = 1, lv_y do
					for x = 1, lv_x do
						table.insert(widget.slotpos, Vector3(75 * x - 75 * lv_x - 87, -75 * y + 37 * lv_y + adjust, 0))
					end
				end
			end

		else
			widget.slotpos = {}
			for z = 1, lv_z do
				for y = lv_y, 1, -1 do
					for x = 1, lv_x do
						table.insert(widget.slotpos, Vector3(80 * x - 40 * lv_x - 40, 80 * y - 40 * lv_y - 40, 0))
					end
				end
			end

			if container.type == "chest" then
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
			widget.bgscale = Vector3(lv_x / self.baselv.x * scale_offset[1], lv_y / self.baselv.y * scale_offset[2], 1)
		end

		if lv_code ~= 0 then
			params[self.inst.prefab][lv_code] = widget
		end
	end
	--container:Close()
	--container:WidgetSetup(self.inst.prefab, {["widget"] = widget})
	ModCompat(container, widget)
end

return ChestUpgrade