local AllUpgradeRecipes = ChestUpgrade.AllUpgradeRecipes or {}

local function onbaselv(self, baselv)
	self.inst.replica.chestupgrade:SetBaseLv(baselv)
end

local function onchestlv(self, chestlv)
	self.inst.replica.chestupgrade:SetChestLv(chestlv)
end

local ChestUpgrade = Class(function(self, inst)
	self.inst = inst
	self.baselv = {x = 3, y = 3, z = 1}
	self.chestlv = {x = 3, y = 3, z = 1}

	--self.ingredient = {}
	--self.tags = {}
end)

function ChestUpgrade:GetLv()
	return self.chestlv.x, self.chestlv.y, self.chestlv.z
end

function ChestUpgrade:SetBaseLv(x, y, z)
	self:SetChestLv(x, y, z)
	self.baselv = self.chestlv
	self.inst.replica.chestupgrade:SetBaseLv(self.baselv)
	self:UpdateWidget()
end

function ChestUpgrade:SetChestLv(x, y, z)
	local container = self.inst.components.container
	if container ~= nil then
		z = z or self.chestlv.z
		if type(x) == "table" then
			if x.x ~= nil then
				x.z = x.z or self.chestlv.z
				self.chestlv = x
			else
				self:SetChestLv(unpack(x))
			end
		elseif y then
			self.chestlv = {x = x, y = y, z = z}
		elseif container.widget.animbank == "ui_chester_shadow_3x4" then
			self.chestlv = {x = x, y = x + 1, z = z}
		else
			self.chestlv = {x = x, y = x, z = z}
		end
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

local function GetOffset(slotpos, blv)
	--local slotpos
	local mid_pt = (slotpos[1] + slotpos[#slotpos]) / -2
	local scale_x = RoundBiasedDown(((blv.x - 1) * 80 / (slotpos[#slotpos].x - slotpos[1].x)), 2)
	local scale_y = RoundBiasedDown(((blv.y - 1) * 80 / (slotpos[1].y - slotpos[#slotpos].y)), 2)
	return mid_pt, {scale_x, scale_y}
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
			shift_offset, scale_offset = GetOffset(widget.slotpos, self.baselv)
			if widget.animbank == "ui_chester_shadow_3x4" or widget.animbank == "ui_portal_shadow_3x4" then
				scale_offset[1] = 1
			end
			params[self.inst.prefab].offset = {shift_offset, scale_offset}
		end
		--[[
		--for some container, eg. shadow chester/dragonfly chest
		if widget.animbank == "ui_chester_shadow_3x4" or widget.animbank == "ui_portal_shadow_3x4" then
			widget.bgscale = Vector3(lv_x / 3, lv_y / 4 * 1.06, 1)
			--1.06 is 80/75, the ratio of the widget spacing of treasure chest and dragonfly chest
		elseif widget.animbank == "ui_tacklecontainer_3x5" then
			widget.bgscale = Vector3(lv_x / 3, lv_y / 5, 1)
			widget.bgshift = Vector3(0, lv_y * 25, 0)
		elseif widget.animbank == "ui_bookstation_4x5" then
			widget.bgscale = Vector3(lv_x / 4 * 1.06, lv_y / 5 * 1.02, 1)
			widget.bgshift = Vector3(0, lv_y * 25, 0)
		elseif widget.animbank == "ui_cookpot_1x4" then
			widget.bgscale = Vector3(lv_x * .8, lv_y / 4, 1)
		else
			--change the bg scale to make it "fit" to the slot widget
			widget.bgscale = Vector3(lv_x / self.baselv.x, lv_y / self.baselv.y, 1)
		end
		]]
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

	--container:Close()
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
--[[
	if amount ~= nil and item ~= nil and item.components.stackable ~= nil and item.components.stackable:StackSize() ~= amount then
		return true
	end

	if not (item ~= nil and item.prefab == prefab or item == prefab) then
		return true
	end

	return false
]]
	return (amount ~= nil and item ~= nil and item.components.stackable ~= nil and item.components.stackable:StackSize() ~= amount)
		or not (item ~= nil and item.prefab == prefab or prefab == item)
end

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

local function CheckItem2(checklist, data, item)
	if checklist then
		checklist = false
		return CheckItem(data, item)
	end
	return false
end

function ChestUpgrade:CheckItem(slots, data)
	if data == nil then
		data = AllUpgradeRecipes[self.inst.prefab]		--self.ingredient
	end
	if data == nil then return false end

	local TR = self:GetLv()											--Top right hand corner
	local BR = self.inst.components.container:GetNumSlots()			--Bottom right
	local BL = BR - TR + 1											--Bottom left

	local checklist = {}
	for i = 1, BR do
		table.insert(checklist, true)
	end

	if data.slot then
		for k, v in pairs(data.slot) do
			if CheckItem2(checklist[k], v, slots[k]) then return false end
		end
	end

	if data.center then
		if (BR + 1)%2 == 0 then
			if CheckItem2(checklist[(BR + 1) / 2], data.center, slots[(BR + 1) / 2]) then return false end
		end
	end

	if data.hollow then
		for k = 1, TR - 2 do
			for i = k * TR + 2, k * TR + TR - 1 do
				if CheckItem2(checklist[i], nil, slots[i]) then return false end
			end
		end
	end

	if data.row then
		for i = 1, TR do
			for k, v in pairs(data.row) do
				local j = (k - 1) * TR + i
				if CheckItem2(checklist[j], v, slots[j]) then return false end
			end
		end
	end

	if data.column then
		for i = 1, BL, TR do
			for k, v in pairs(data.column) do
				local j = (k - 1) + i
				if CheckItem2(checklist[j], v, slots[j]) then return false end
			end
		end	
	end


	if data.side then
		for i = 1, TR do			--top
			if CheckItem2(checklist[i], data.side, slots[i]) then return false end
		end
		for i = BL, BR do			--bottom
			if CheckItem2(checklist[i], data.side, slots[i]) then return false end
		end	
		for i = 1, BL, TR do		--left
			if CheckItem2(checklist[i], data.side, slots[i]) then return false end
		end
		for i = TR, BR, TR do		--right
			if CheckItem2(checklist[i], data.side, slots[i]) then return false end
		end
	end

	if data.all then
		for i = 1, BR do
			if CheckItem2(checklist[i], data.all, slots[i]) then return false end
		end
	end

	return true
end

function ChestUpgrade:Upgrade(lv, data, doer, fnonly, fn)
	local container = self.inst.components.container
	local x, y, z = self:GetLv()
	if lv ~= nil and (x * y >= lv * lv) or container == nil then return end 	--check for max lv

	local slot = self:CreateCheckTable(data)
	if slot == nil or #slot == 0 then return end
	for i = 1, container:GetNumSlots() do
		local item = container.slots[i]
		if CheckItem(slot[i], item, self.inst, doer) then
			return
		end
	end
	--[[
	if not self:CheckItem(container.slots, data) then
		return
	end
	]]

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

function ChestUpgrade:Degrade()		--return the chest to normal
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
					hammer.components.finiteuses:Use(USES * TUNING.CHESTUPGRADE.DEGRADE_USE)
				end

				container:DropItemBySlot(i)

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
	--data.tags = self.tags
	return data
end

function ChestUpgrade:OnLoad(data)
	if data then
		self:SetChestLv(data.chestlv)
		--if #data.tags ~= 0 then
		--	self.tags = data.tags
		--end
	end
end

return ChestUpgrade