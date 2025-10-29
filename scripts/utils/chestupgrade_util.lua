local containers = require("containers")

local containers_mt = {__index = {inst = {components = {}}, SetNumSlots = function() end}}
local function RegisterParams(prefab)
	if containers.params[prefab] == nil then
		local container = {}
		setmetatable(container, containers_mt)
		containers.widgetsetup(container, prefab)
		setmetatable(container, nil)
		if next(container) ~= nil then
			container.modded = true
			containers.params[prefab] = container
		end
	end
	return containers.params[prefab]
end

local function IsSideWidget(prefab)
	local params = RegisterParams(prefab)
	return params.issidewidget
end

local function GetContainerType(prefab)
	local params = RegisterParams(prefab)
	return params.type
end

local function WidgetPos(prefab, enable, pos)
	local params = RegisterParams(prefab)
	if not params then return end

	if enable then
		if not pos then
			pos = Vector3(-140, 0, 0)
		elseif not pos.IsVector3 then
			pos = Vector3(pos)
		end

		params.widget.pos = pos
	end
end

local function BGImage(prefab, enable, build, bank, isimage)
	local params = RegisterParams(prefab)
	if not params then return end

	local widget = params.widget
	if enable ~= false then
		if build and bank then
			if isimage then
				widget.bgimage = build
				widget.bgatlas = bank
			else
				widget.animbuild = build
				widget.animbank = bank
			end
		end
	else
		widget.animbuild = nil
		widget.animbank = nil
		widget.bgimage = nil
		widget.bgatlas = nil
	end
end

local function CustomUI(prefab, widgetpos, bgimage)
	WidgetPos(prefab, widgetpos)
	BGImage(prefab, bgimage)
end

local function ChangeSize(inst, factor)
	local onchestlvchange = function(chest, data)
		local cupg = chest.components.chestupgrade
		local clv = cupg.chestlv
		local blv = cupg.baselv
		chest.Transform:SetScale(
				((clv.x / blv.x - 1) / TUNING.CHESTUPGRADE.SCALE_FACTOR + 1),
				((clv.y / blv.y - 1) / TUNING.CHESTUPGRADE.SCALE_FACTOR + 1),
				1
		)
		if factor then
			local x, y = chest.Transform:GetScale()
			chest.Transform:SetScale(x * (factor.x or 1), y * (factor.y or 1), factor.z or 1)
		end
	end

	inst:ListenForEvent("onchestlvchange", onchestlvchange)
end

local function CalSize(inst)
	local container = inst.components.container
	local widget = container:GetWidget()
	if widget == nil then
		return
	end
	local slotpos = widget.slotpos
	local init_slot = slotpos[1]
	local x, y = 0, 0
	for slot, pos in iparis(slotpos) do
		if pos.x == init_slot.x then
			y = y + 1
		end
		if pos.y == init_slot.y then
			x = x + 1
		end
	end
	--local doublecheck = #slotpos == x * y
	--return doublecheck and Vector3(x, y, 1) or nil
	return Vector3(x, y, 1)
end

local function itemtest(temp_items, item, ...)
	for k, v in pairs(temp_items) do
		if type(v) == "string" then
			if v == item.prefab then
				return true
			end
		elseif type(v) == "table" then
			if v.type ~= nil then
				if v.type == item.prefab then
					return true
				end
			elseif itemtest(v, item) then
				return true
			end
		elseif type(v) == "function" then
			if v(item, ...) then
				return true
			end
		end
	end
end

local function makecantaketempitem(container, params)
	if container ~= nil then
		local oldCanTakeItemInSlot = container.CanTakeItemInSlot
		function container:CanTakeItemInSlot(item, slot, ...)
			if item == nil then return false end
			return oldCanTakeItemInSlot(container, item, slot, ...)
					or itemtest(params, item, slot, container, ...)
					or item:HasTag("HAMMER_tool")
		end
	end
end

local function CanTakeTempItem(inst, params)
	if TheWorld.ismastersim then
		makecantaketempitem(inst.components.container, params)
		makecantaketempitem(inst.replica.container, params)
	else
		inst:DoTaskInTime(0, function()
			makecantaketempitem(inst.replica.container, params)
		end)
	end
end

local function DropTempItem(inst, data)
	local container = inst.components.container
	if container.itemtestfn ~= nil and container.opencount == 0 then
		local itemtodrop = {}
		for i = 1, container:GetNumSlots() do
			local item = container.slots[i]
			if item ~= nil and not container:itemtestfn(item, i) then
				--stack all stackable to make the floor tidy
				local stackable = item.components.stackable
				if item.components.stackable then
					local slot = itemtodrop[item.prefab]
					if slot ~= nil then
						local totalstacksize = stackable:StackSize() + container.slots[slot].components.stackable:StackSize()
						if totalstacksize > stackable.maxsize then
							stackable:Put(container.slots[slot])
							container:DropItemBySlot(i, data.doer:GetPosition())
						else
							container.slots[slot].components.stackable:Put(item)
						end
					else
						itemtodrop[item.prefab] = i
					end
				else
					container:DropItemBySlot(i, data.doer:GetPosition())
				end
			end
		end
		for k, v in pairs(itemtodrop) do
			container:DropItemBySlot(v, data.doer:GetPosition())
		end
	end
end

local function NormalUpgrade(inst, params, data)
	local chestupgrade = inst.components.chestupgrade
	return chestupgrade:Upgrade(TUNING.CHESTUPGRADE.MAX_LV, params, data.doer)
end

local function NormalPackUpgrade(inst, params, data)
	local chestupgrade = inst.components.chestupgrade
	local x, y = chestupgrade.baselv.x, chestupgrade.baselv.y
	local maxsize = {
		x = x + TUNING.CHESTUPGRADE.MAXPACKSIZE * 2,
		y = y + TUNING.CHESTUPGRADE.MAXPACKSIZE * 2,
	}
	return chestupgrade:Upgrade(maxsize, params, data.doer)
end

local nextval = function(t, i)
	if not t or type(t) ~= "table" then return end
	local _, v = next(t, i)
	return v
end

local function RowColumnUpgrade(inst, params, data)
	local chestupgrade = inst.components.chestupgrade
	local x, y, z = chestupgrade:GetLv()

	local major = params.side or params.all or nil
	local minor = (
			params.center or
					nextval(params.column) or
					nextval(params.row) or
					nextval(params.slot) or
					nil
	)

	if major == nil then
		major, minor = minor, nil
	end

	local row = {
		row = {[y] = major}
	}
	local column = {
		column = {[x] = major}
	}
	if minor ~= nil then
		local slot_row = x * y - x + 1
		row.slot = {[slot_row] = minor}

		local slot_column = x
		column.slot = {[slot_column] = minor}
	end

	--column upg
	if chestupgrade:SpecialUpgrade(column, data.doer, {x = 1}, {x = TUNING.CHESTUPGRADE.MAX_LV}) then
		return true
	end
	--row upg
	if chestupgrade:SpecialUpgrade(row, data.doer, {y = 1}, {y = TUNING.CHESTUPGRADE.MAX_LV}) then
		return true
	end

	return false
end

local function PageUpgrade(inst, params, data, nomult)
	local chestupgrade = inst.components.chestupgrade
	local ispack = inst.components.container.type == "pack"
	local z_max = ispack and (TUNING.CHESTUPGRADE.MAXPACKPAGE or 0) or TUNING.CHESTUPGRADE.MAX_PAGE
	local ingr = (params.page and params.page[1]) or params.side or params.all or nil
	if ingr ~= nil then
		if nomult then
			return chestupgrade:SpecialUpgrade(params, data.doer, {z = 1}, {z = z_max})
		end

		local firstitem = inst.components.container.slots[1]
		if firstitem == nil then
			return false
		end

		local amount = type(ingr) == "string" and 1 or ingr.amount or ingr[2]
		local stacksize = firstitem.components.stackable ~= nil and firstitem.components.stackable:StackSize() or 1
		local times = math.min(z_max, math.floor(stacksize / amount))

		local page_prefab = type(ingr) == "string" and ingr or ingr.type or ingr[1]
		local page_amount = amount * times
		local page_ingr = Ingredient(page_prefab, page_amount)
		local page_params = {page = {[1] = page_ingr}}

		if ispack and TUNING.CAP_EXPENSIVE_BACKPACK then
			times = 1
			page_params = {all = page_ingr}
		end

		return chestupgrade:SpecialUpgrade(page_params, data.doer, {z = times}, {z = z_max})
	end
	return false
end

local function CustomUpgrade(inst, params, data, fn, maxlv)
	local chestupgrade = inst.components.chestupgrade
	return chestupgrade:Upgrade(maxlv, params, data.doer, true, fn)
end

local function ChestUpgradeFn(inst, params, data)
	local x, y, z = inst.components.chestupgrade:GetLv()
	local pageable = x >= TUNING.CHESTUPGRADE.MAX_LV and y >= TUNING.CHESTUPGRADE.MAX_LV
	return TUNING.CAP_UPG_MODE ~= 1 and inst.components.container.slots[1] == nil and RowColumnUpgrade(inst, params, data)
			or TUNING.CAP_UPG_MODE ~= 2 and NormalUpgrade(inst, params, data)
			or TUNING.CAP_PAGEABLE and pageable and PageUpgrade(inst, params, data)
end

local function PackUpgradeFn(inst, params, data)
	if TUNING.CAP_BACKPACKMODE == 2 then
		return PageUpgrade(inst, params, data)
	elseif TUNING.CAP_BACKPACKMODE == 1 then
		return TUNING.CAP_UPG_MODE ~= 1 and inst.components.container.slots[1] == nil and RowColumnUpgrade(inst, params, data)
				or TUNING.CAP_UPG_MODE ~= 2 and NormalPackUpgrade(inst, params, data)
	else
		local x, y = inst.components.chestupgrade:GetLv()
		local xx, yy = inst.components.chestupgrade.baselv:Get()
		local pageable = x >= xx + TUNING.CHESTUPGRADE.MAXPACKSIZE * 2 and y >= yy + TUNING.CHESTUPGRADE.MAXPACKSIZE * 2
		return TUNING.CAP_UPG_MODE ~= 1 and inst.components.container.slots[1] == nil and RowColumnUpgrade(inst, params, data)
				or TUNING.CAP_UPG_MODE ~= 2 and NormalPackUpgrade(inst, params, data)
				or pageable and PageUpgrade(inst, params, data)
	end
end

local function Degrade(inst, ratio, fn)
	local chestupgrade = inst.components.chestupgrade
	local x, y, z = chestupgrade:GetLv()
	local blv = chestupgrade.baselv

	if x > blv.x or y > blv.y or z > blv.z then
		return chestupgrade:Degrade(ratio, fn)
	end
	return false
end

local function Deconstruct(inst)
	local worked = function(inst, data)
		if data.workleft <= 0 then
			Degrade(inst)
		end
	end
	local ondeconstructstructure = function(inst, data)
		Degrade(inst, 1)
		if inst.components.container ~= nil then
			inst.components.container:DropEverything()
		end
	end
	inst:ListenForEvent("worked", worked)
	inst:ListenForEvent("ondeconstructstructure", ondeconstructstructure)
end

local function DegradeByHammer(inst, data)
	local container = inst.components.container

	if container == nil then
		return false
	end

	local idx = next(container.slots)
	if idx == nil or next(container.slots, idx) ~= nil then	--make sure only one item in chest
		return false
	end

	local chestupgrade = inst.components.chestupgrade
	local x, y, z = chestupgrade:GetLv()
	local blv = chestupgrade.baselv

	if not (x > blv.x or y > blv.y or z > blv.z) then
		return false
	end

	for i = 1, container:GetNumSlots() do
		local hammer = container.slots[i]
		if hammer ~= nil and hammer:HasTag("HAMMER_tool") then
			if hammer.components.finiteuses ~= nil then
				local USES = math.max(x - blv.x + y - blv.y, 0)
				hammer.components.finiteuses:Use(USES * TUNING.CHESTUPGRADE.DEGRADE_USE)
			end
			container:DropItemBySlot(i, data.doer:GetPosition())
			return Degrade(inst)
		end
	end
	return false
end

local function CommonClose(chest, params)
	local onclose = function(inst, data)
		--upgrade only if all player close the container
		if inst.components.container.opencount == 0 then
			if TUNING.CAP_DEGRADABLE then
				if DegradeByHammer(inst, data) then
					return
				end
			end

			ChestUpgradeFn(inst, params, data)

			DropTempItem(inst, data)
		end
	end

	chest:ListenForEvent("onclose", onclose)
end

local function PackClose(pack, params)
	local onclose = function(inst, data)
		if inst.components.container.opencount == 0 then
			PackUpgradeFn(inst, params, data)
		end
	end

	pack:ListenForEvent("onclose", onclose)
end

local function CustomClose(chest, params, fn, fnonly, maxlv)
	fnonly = fnonly ~= false
	local onclose = function(inst, data)
		local container = inst.components.container
		if container.opencount == 0 then
			local chestupgrade = inst.components.chestupgrade
			chestupgrade:Upgrade(maxlv, params, data.doer, fnonly, fn)
		end
	end

	chest:ListenForEvent("onclose", onclose)
end

local function MakeUpgradeable(inst, x, y)
	inst:AddComponent("chestupgrade")
	if x == nil then
		return
	elseif type(x) == "table" then
		inst.components.chestupgrade:SetBaseLv(x)
	elseif y ~= nil then
		inst.components.chestupgrade:SetBaseLv(x, y)
	end
end

return {
	RegisterParams = RegisterParams,
	IsSideWidget = IsSideWidget,
	GetContainerType = GetContainerType,

	WidgetPos = WidgetPos,
	BGImage = BGImage,
	CustomUI = CustomUI,

	ChangeSize = ChangeSize,

	CalSize = CalSize,

	CanTakeTempItem = CanTakeTempItem,
	DropTempItem = DropTempItem,

	NormalUpgrade = NormalUpgrade,
	NormalPackUpgrade = NormalPackUpgrade,
	RowColumnUpgrade = RowColumnUpgrade,
	PageUpgrade = PageUpgrade,
	CustomUpgrade = CustomUpgrade,

	ChestUpgradeFn = ChestUpgradeFn,
	PackUpgradeFn = PackUpgradeFn,

	Degrade = Degrade,
	DegradeByHammer = DegradeByHammer,
	Deconstruct = Deconstruct,

	CommonClose = CommonClose,
	PackClose = PackClose,
	CustomClose = CustomClose,

	MakeUpgradeable = MakeUpgradeable,
}