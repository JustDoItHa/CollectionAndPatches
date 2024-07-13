local containers = require("containers")

--local fancyname = "Upgradeable Chest"
--local modname = KnownModIndex:GetModActualName(fancyname)
--local GetThisModConfigData = function(optionname, get_local_config)
--	return GetModConfigData(optionname, modname, get_local_config)
--end

local containers_mt = {__index = {inst = {components = {}}, SetNumSlots = function() end}}
local function RegisterParams(prefab)
	if containers.params[prefab] == nil then
		containers.params[prefab] = {}
		local container = containers.params[prefab]
		container.modded = true
		setmetatable(container, containers_mt)
		containers.widgetsetup(container, prefab)
		setmetatable(container, nil)
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
	if enable then
		if not pos then
			pos = Vector3(-140, 0, 0)
		elseif not pos.IsVector3 then
			pos = Vector3(pos)
		end

		containers.params[prefab].widget.pos = pos
	end
end

local function BGImage(prefab, enable, build, bank, isimage)
	local widget = containers.params[prefab].widget
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

local function MakeTempContainable(prefab, temp_items)
	local params = containers.params[prefab] or {}

	if params.itemtestfn == nil then
		return
	elseif params.olditemtestfn == nil then
		params.olditemtestfn = params.itemtestfn
	end

	containers.params[prefab].itemtestfn = function(cont, item, slot)
		if params.olditemtestfn(cont, item, slot) then
			return true
		end

		if itemtest(temp_items, item, slot, cont) then
			return true
		end

		return item:HasTag("HAMMER_tool")
	end
end

local function DropTempItem(inst, data)
	local container = inst.components.container
	if container.olditemtestfn ~= nil and container.opencount == 0 then
		local itemtodrop = {}
		for i = 1, container:GetNumSlots() do 
			local item = container.slots[i]
			if item ~= nil and not container.olditemtestfn(container, item, i) then
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

local function NormalUpgrade(inst, data, params)
	local chestupgrade = inst.components.chestupgrade
	chestupgrade:Upgrade(TUNING.CHESTUPGRADE.MAX_LV, params, data.doer)
end

local nextval = function(t, i)
	if not t or type(t) ~= "table" then return end
	local _, v = next(t, i)
	return v
end

local function RowColumnUpgrade(inst, data, params)
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
	if x < TUNING.CHESTUPGRADE.MAX_LV then
		chestupgrade:SpecialUpgrade(column, data.doer, {x = 1})
	end
	--row upg
	if y < TUNING.CHESTUPGRADE.MAX_LV then
		chestupgrade:SpecialUpgrade(row, data.doer, {y = 1})  
	end
end

local function PageUpgrade(inst, data, params, nomult)
	local chestupgrade = inst.components.chestupgrade
	local ispack = inst.components.container.type == "pack"
	local z_max = ispack and (TUNING.CHESTUPGRADE.MAXPACKPAGE or 0) or TUNING.CHESTUPGRADE.MAX_PAGE
	local ingr = (params.page and params.page[1]) or params.side or params.all or nil
	local x, y, z = chestupgrade:GetLv()
	if ingr ~= nil and (ispack or x * y >= TUNING.CHESTUPGRADE.MAX_LV ^ 2) and z < z_max then
		if nomult or ispack and GetModConfigData("EXPENSIVE_BACKPACK") then
			chestupgrade:SpecialUpgrade(params, data.doer, {z = 1})
			return
		end

		local firstitem = inst.components.container.slots[1]
		if firstitem == nil then return end

		local amount = type(ingr) == "string" and 1 or ingr.amount or ingr[2]
		local stacksize = firstitem.components.stackable ~= nil and firstitem.components.stackable:StackSize() or 1
		local times = math.min(z_max - z, math.floor(stacksize / amount))

		local page_prefab = type(ingr) == "string" and ingr or ingr.type or ingr[1]
		local page_amount = amount * times
		local page_ingr = Ingredient(page_prefab, page_amount)
		local page_params = {page = {[1] = page_ingr}}

		chestupgrade:SpecialUpgrade(page_params, data.doer, {z = times})
	end
end

local function CustomUpgrade(inst, data, params, fn)
	local chestupgrade = inst.components.chestupgrade
	chestupgrade:Upgrade(TUNING.CHESTUPGRADE.MAX_LV, params, data.doer, true, fn)
end

local function Degrade(inst, ratio, fn)
	local chestupgrade = inst.components.chestupgrade
	local x, y, z = chestupgrade:GetLv()
	local blv = chestupgrade.baselv

	if x > blv.x or y > blv.y or z > blv.z then
		chestupgrade:Degrade(ratio, fn)
	end
end

local function Deconstruct(inst)
	local worked = function(inst, data)
		if data.workleft <= 0 then
			Degrade(inst)
		end
	end
	local ondeconstructstructure = function(inst, data)
		Degrade(inst, 1)
	end
	inst:ListenForEvent("worked", worked)
	inst:ListenForEvent("ondeconstructstructure", ondeconstructstructure)
end

local function DegradeByHammer(inst, data)
	local container = inst.components.container

	if container == nil then return end

	local idx = next(container.slots)
	if idx == nil or next(container.slots, idx) ~= nil then	--make sure only one item in chest
		return
	end

	local chestupgrade = inst.components.chestupgrade
	local x, y, z = chestupgrade:GetLv()
	local blv = chestupgrade.baselv

	if not (x > blv.x or y > blv.y or z > blv.z) then return end

	for i = 1, container:GetNumSlots() do
		local hammer = container.slots[i]
		if hammer ~= nil and hammer:HasTag("HAMMER_tool") then
			if hammer.components.finiteuses ~= nil then
				local USES = math.max(x - blv.x + y - blv.y, 0)
				hammer.components.finiteuses:Use(USES * TUNING.CHESTUPGRADE.DEGRADE_USE)
			end
			container:DropItemBySlot(i, data.doer:GetPosition())
			Degrade(inst)
			break
		end
	end
end

local function CommonClose(chest, params)
	local onclose = function(inst, data)
		local container = inst.components.container
		--upgrade only if all player close the container
		if container.opencount ~= 0 then return end

		if GetModConfigData("DEGRADABLE") then
			DegradeByHammer(inst, data)
		end

		--upgd mode: 1: normal; 2: row/column; 3: both 1 & 2
		if GetModConfigData("UPG_MODE") ~= 1 and container.slots[1] == nil then
			RowColumnUpgrade(inst, data, params)
		end
		if GetModConfigData("UPG_MODE") ~= 2 then
			NormalUpgrade(inst, data, params)
		end
		if GetModConfigData("PAGEABLE") then
			PageUpgrade(inst, data, params)
		end

		DropTempItem(inst, data)
	end

	chest:ListenForEvent("onclose", onclose)
end

local function PackClose(pack, params)
	local onclose = function(inst, data)
		local container = inst.components.container
		if container.opencount == 0 then
			local chestupgrade = inst.components.chestupgrade
			local x, y, z = chestupgrade:GetLv()

			if z < TUNING.CHESTUPGRADE.MAXPACKPAGE then
				--chestupgrade:SpecialUpgrade(params, data.doer, {z = 1})
				PageUpgrade(inst, data, params)
			end
		end
	end

	pack:ListenForEvent("onclose", onclose)
end

local function CustomClose(chest, params, fn, fnonly)
	fnonly = fnonly ~= false
	local onclose = function(inst, data)
		local container = inst.components.container
		if container.opencount == 0 then
			local chestupgrade = inst.components.chestupgrade
			chestupgrade:Upgrade(nil, params, data.doer, fnonly, fn)
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

	MakeTempContainable = MakeTempContainable,
	DropTempItem = DropTempItem,

	NormalUpgrade = NormalUpgrade,
	RowColumnUpgrade = RowColumnUpgrade,
	PageUpgrade = PageUpgrade,
	CustomUpgrade = CustomUpgrade,

	Degrade = Degrade,
	DegradeByHammer = DegradeByHammer,
	Deconstruct = Deconstruct,

	CommonClose = CommonClose,
	PackClose = PackClose,
	CustomClose = CustomClose,

	MakeUpgradeable = MakeUpgradeable,
}