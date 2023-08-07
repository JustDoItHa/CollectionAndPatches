-- local ChestUpgrade = GLOBAL.ChestUpgrade
-- local UpgradeRecipe = ChestUpgrade.UpgradeRecipe
-- local AllUpgradeRecipes = ChestUpgrade.AllUpgradeRecipes
--upgrade for modded containers and unlisted containers
--[[
local WhiteList = {}

local BlackList = {}
for k, v in pairs(AllUpgradeRecipes)
	BlackList[k] = true
end
]]
local widgetprops =
{
    "numslots",
    "acceptsstacks",
    "usespecificslotsforitems",
    "issidewidget",
    "type",
    "widget",
    "itemtestfn",
    "priorityfn",
    "openlimit"
}

local containers = require("containers")
--do I need this? keep it in case i need
local function checkparams(container)
	local prefab = container.inst.prefab
	if containers.params[prefab] == nil then
		print("[Upgradeable Chest]: Cannot find container params:", prefab)
		local cont = {}
		containers.params[prefab] = cont
		for _, v in ipairs(widgetprops) do
			cont[v] = container[v]
		end
		if GLOBAL.next(cont) ~= nil then
			print("[Upgradeable Chest]: Container params added:", prefab)
			for k, v in pairs(cont) do
				print("", k, v)
			end
			print("---------------------------------------------")
		end
	end
	return containers.params[prefab] ~= nil and (containers.params[prefab].type == "chest" or containers.params[prefab].type == "pack")
end

local function CalSize(container)
	local widget = container:GetWidget()
	local slotpos = widget ~= nil and widget.slotpos or {}
	local init_vec = slotpos[1]
	if init_vec == nil then
		return 0, 0, GLOBAL.Vector3(0, 0, 0)
	end
	local last_vec = slotpos[#slotpos]
	local x = 0
	local init_y = init_vec.y
	for k, s_pos in pairs(slotpos) do
		if s_pos.y == init_y then
			x = x + 1
		else
			break
		end
	end
	local y = #slotpos / x

	local pos
	if x < y then
		local pos_x = (init_vec.x + last_vec.x) / 2 - 40
		pos = GLOBAL.Vector3(pos_x, 0, 0)
	else
		local pos_y = (init_vec.y + last_vec.y) / 2 + 100
		pos = GLOBAL.Vector3(0, pos_y, 0)
	end

	return x, y, pos
end

local function GetPara(prefab)
	local AllRecipes = GLOBAL.AllRecipes

	local ingredient = nil
	local amount = 0

	if AllRecipes[prefab] ~= nil then
		local recipe = AllRecipes[prefab]
		for i, ingr in ipairs(recipe.ingredients) do
			if ingr.amount > amount then
				ingredient = ingr.type
				amount = ingr.amount
			end
		end
		--amount = math.ceil(amount / 3)
	else
		ingredient = "waxpaper"
	end
	amount = 1

	return {["side"] = Ingredient(ingredient, amount)}
end

--[[
local function MakeUpgradeable(prefab)
	if AllUpgradeRecipes[prefab] == nil and checkparams(prefab) then
		local para = GetPara(prefab)
		local x, y = CalSize(prefab)
		UpgradeRecipe(prefab, para)

		ChestUpgrade.EasySetUp(prefab, para, {x,y})
		ChestUpgrade.CustomUI(prefab)
	end
end

local allcont = GLOBAL.CRAFTING_FILTERS.CONTAINERS.recipes
for i, prefab in ipairs(allcont) do
	MakeUpgradeable(prefab)
end
]]

local function ChangeSize(inst)
	local cupg = inst.components.chestupgrade
	local clv = cupg.chestlv
	local blv = cupg.baselv
	inst.Transform:SetScale(
		((clv.x / blv.x - 1) / TUNING.CHESTUPGRADE.SCALE_FACTOR + 1),
		((clv.y / blv.y - 1) / TUNING.CHESTUPGRADE.SCALE_FACTOR + 1),
		1
	)
	if inst.prefab == "fish_box" then
		local x, y = inst.Transform:GetScale()
		inst.Transform:SetScale(x * 1.3, y * 1.3, 1.3)
	end
end

local function GetSUpgData(prefab, mode, x, y, z)
	local data = {
		slot = {},
	}
	local major, minor
	for k, v in pairs(AllUpgradeRecipes[prefab].params) do
		if k == "side" then
			major = v
		elseif k ~= "lv" and k ~= "skiptemp" then
			minor = v
			if type(minor) == "table" then
				while type(minor[1]) == "table" do
					minor = minor[1]
				end
			end
		end
	end
	if mode == 0 then		--page
		for i = 1, x * y do
			table.insert(data.slot, major)
		end
	elseif mode == 1 then	--column
		data.column = {}
		data.column[x] = major
		data.slot[x] = minor
	elseif mode == 2 then	--row
		local i = x * y - x + 1
		data.row = {}
		data.row[y] = major
		data.slot[i] = minor
	end
	return data
end

local old_itemtestfn = {}
local function new_itemtestfn(container, item, slot)
	local prefab = container.inst.prefab

	if AllUpgradeRecipes[prefab] ~= nil then
		local need = AllUpgradeRecipes[prefab].params.side.type
		if item.prefab == need then
			return true
		end
	end

	return item:HasTag("HAMMER_tool")
		or old_itemtestfn[prefab] ~= nil and old_itemtestfn[prefab](container, item, slot)
end

local function ResetItemTestFn(container, readonly)
	if container.itemtestfn ~= nil then
		local prefab = container.inst.prefab
		if readonly ~= false then
			GLOBAL.removesetter(container, "itemtestfn")
		end
		if old_itemtestfn[prefab] == nil then
			old_itemtestfn[prefab] = container.itemtestfn
		end
		container.itemtestfn = new_itemtestfn
		if readonly ~= false then
			GLOBAL.makereadonly(container, "itemtestfn")
		end
	end
end

--drop upgd material that are not able to put in to the container
local function DropTempItem(inst)
	--local OLD_itemtestfn = old_itemtestfn[inst.prefab]--SetTempContainable(inst.prefab)
	if old_itemtestfn[inst.prefab] ~= nil then
		local container = inst.components.container
		local drop = {}
		for i = 1, container:GetNumSlots() do 
			local item = container.slots[i]
			if item ~= nil and not old_itemtestfn[inst.prefab](container, item, i) then
				--stack all stackable to make the floor tidy
				local slot = drop[item.prefab]
				local stackable = item.components.stackable
				if item.components.stackable then
					if slot ~= nil then
						if (stackable:StackSize() + container.slots[slot].components.stackable:StackSize()) > stackable.maxsize then
							stackable:Put(container.slots[slot])
							container:DropItemBySlot(i)
						else
							container.slots[slot].components.stackable:Put(item)
						end
					else
						drop[item.prefab] = i
					end
				else
					container:DropItemBySlot(i)
				end
			end
		end
		for k, v in pairs(drop) do
			container:DropItemBySlot(v)
		end
	end
end

local function OnChestClose(inst, data)
	local container = inst.components.container
	--upgrade only if all player close the container
	if container.opencount ~= 0 then return end

	local chestupgrade = inst.components.chestupgrade
	if chestupgrade == nil then return end
	local x, y, z = chestupgrade:GetLv()

	--upgd mode: 1: normal; 2: row/column; 3: both 1 & 2
	if GetModConfigData("UPG_MODE") ~= 1 then
		--column upgd
		if x < TUNING.CHESTUPGRADE.MAX_LV then
			chestupgrade:SpecialUpgrade(GetSUpgData(inst.prefab, 1, x, y, z), data.doer, {x = 1})
		end
		--row upgd
		if y < TUNING.CHESTUPGRADE.MAX_LV then
			chestupgrade:SpecialUpgrade(GetSUpgData(inst.prefab, 2, x, y, z), data.doer, {y = 1})
		end
	end

	--normal upgd
	if GetModConfigData("UPG_MODE") ~= 2 then
		chestupgrade:Upgrade(TUNING.CHESTUPGRADE.MAX_LV, AllUpgradeRecipes[inst.prefab].params, data.doer)
	end

	--page upgd
	if GetModConfigData("PAGEABLE")then
		--can be upgd only when it is in max lv
		if x * y >= TUNING.CHESTUPGRADE.MAX_LV ^ 2 and z < TUNING.CHESTUPGRADE.MAX_PAGE then
			chestupgrade:SpecialUpgrade(GetSUpgData(inst.prefab, 0, x, y, z), data.doer, {z = 1})
		end
	end

	if GetModConfigData("DEGRADABLE") then
		if inst.components.container.opencount ~= 0 then return end
		local blv = chestupgrade.baselv
		if x > blv.x or y > blv.y or z > blv.z then
			chestupgrade:Degrade()
		end
	end

	DropTempItem(inst)
end

local blacklist = {}
for prefab in pairs(AllUpgradeRecipes) do
	blacklist[prefab] = true
end

local function MakeUpgradeable(inst)
	if inst == nil then return end
	local prefab = inst.prefab
	local container = inst.components.container
	if blacklist[prefab] then
		return
	end
	if AllUpgradeRecipes[prefab] == nil then
		if checkparams(container) then
			UpgradeRecipe(prefab, GetPara(prefab))
		end
	end
	if AllUpgradeRecipes[prefab] == nil then
		blacklist[prefab] = true
		return
	end

	if inst.components.chestupgrade == nil then
		local blv_x, blv_y = CalSize(container)
		inst:AddComponent("chestupgrade")
		inst.components.chestupgrade:SetBaseLv(blv_x, blv_y)
	-- else
	-- 	inst.components.chestupgrade.baselv = {x = blv_x, y = blv_y, z = 1}
	-- 	inst.replica.chestupgrade:SetBaseLv(inst.components.chestupgrade.baselv)
	-- 	inst.components.chestupgrade:UpdateWidget()
	end

	ResetItemTestFn(container)

	if GetModConfigData("CHANGESIZE") and inst.Transform ~= nil then
		inst:ListenForEvent("onchestlvchange", ChangeSize)
	end

	inst:ListenForEvent("onclose", OnChestClose)
end
--[[
local function ReplicateUpgradeable(inst)
	if inst == nil then return end
	local prefab = inst.prefab
	if blacklist[prefab] then
		return
	end
	if AllUpgradeRecipes[prefab] == nil then
		if checkparams(prefab) then
			UpgradeRecipe(prefab, GetPara(prefab))
		end
	end
	if AllUpgradeRecipes[prefab] == nil then
		blacklist[prefab] = true
	end
	inst:PrereplicateComponent("chestupgrade")
	SetTempContainable(inst.prefab)
end

AddClassPostConstruct("components/container_replica", function(self)
	--if GLOBAL.TheWorld.ismastersim then return end
	self.inst:DoTaskInTime(0, ReplicateUpgradeable)
end)
]]
AddComponentPostInit("container", function(self)
	self.inst:DoTaskInTime(0, MakeUpgradeable)
end)

local function initialize(inst, self)
	local container = self.inst.components.container
	if container == nil or not checkparams(container) or AllUpgradeRecipes[prefab] == nil then
		--self.inst:RemoveComponent("chestupgrade")
		return
	end
	local blv_x, blv_y = CalSize(container)
	self:SetBaseLv(blv_x, blv_y)
	ResetItemTestFn(container)
end

AddComponentPostInit("chestupgrade", function(self)
	local OLD_OnSave = self.OnSave
	function self:OnSave()
		local data = OLD_OnSave(self)
		data.add_component_if_missing = true
		return data
	end
	local OLD_OnLoad = self.OnLoad
	function self:OnLoad(...)
		local container = self.inst.components.container
		if container == nil then
			self.inst:DoTaskInTime(0, initialize, self)
		else
			initialize(nil, self)
		end
		return OLD_OnLoad(self, ...)
	end
end)

local function reg_para(inst)
	local container = inst.replica.container
	if container == nil or not checkparams(container) or AllUpgradeRecipes[prefab] == nil then
		--inst:UnreplicateComponent("chestupgrade")
		return
	end
	local prefab = inst.prefab
	if AllUpgradeRecipes[prefab] == nil then
		if checkparams(container) then
			UpgradeRecipe(prefab, GetPara(prefab))
		end
	end
	ResetItemTestFn(container, false)
end

AddClassPostConstruct("components/chestupgrade_replica", function(self)
	self.inst:DoTaskInTime(0, reg_para)
end)
--[[
GLOBAL.c_getrequirement = function()
	local params = AllUpgradeRecipes[GLOBAL.c_select().prefab].params
	local str = string.format("%d %s to all side slot", params.side.amount, params.side.type)
	print(str)
	return str
end
]]
