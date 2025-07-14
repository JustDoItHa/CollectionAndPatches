local UpgradeRecipe = require("chestupgrade_recipe")
local util = require("chestupgrade_util")

--local ALLOWEDTYPE = {"chest", "pack"}
local function IsTypeAllowed(container_type)
	return container_type == "chest" or container_type == "pack"
	--[[
	for _, v in pairs(ALLOWEDTYPE) do
		if container_type == v then
			return true
		end
	end
	]]
end

local function CalSize(container)
	local params = util.RegisterParams(container.inst.prefab) or {}
	--if params == nil then return end
	local widget = params.widget or container:GetWidget()
	local slotpos = widget ~= nil and widget.slotpos or {}
	local init_vec = slotpos[1]
	if init_vec == nil then
		return 0, 0
	end
	--local last_vec = slotpos[#slotpos]
	local x = 0
	local init_y = init_vec.y
	for k, pos in pairs(slotpos) do
		if pos.y == init_y then
			x = x + 1
		else
			break
		end
	end
	local y = #slotpos / x
	return x, y
end

local function GetPara(prefab)
	local AllRecipes = GLOBAL.AllRecipes

	local ingredient = nil
	local amount = 0

	if false and AllRecipes[prefab] ~= nil then
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

local old_itemtestfn = {}
local function new_itemtestfn(container, item, slot)
	local prefab = container.inst.prefab

	if old_itemtestfn[prefab] ~= nil and old_itemtestfn[prefab](container, item, slot) then
		return true
	end

	if AllUpgradeRecipes[prefab] ~= nil then
		local need = AllUpgradeRecipes[prefab].params.side.type
		if item.prefab == need then
			return true
		end
		return item:HasTag("HAMMER_tool")
	end
end

local function ResetItemTestFn(container, readonly)
	if container.itemtestfn == nil then return end
	local prefab = container.inst.prefab
	if readonly ~= false then
		GLOBAL.removesetter(container, "itemtestfn")
	end
	if old_itemtestfn[prefab] == nil then
		old_itemtestfn[prefab] = container.itemtestfn
	end
	if container.itemtestfn ~= new_itemtestfn then
		container.itemtestfn = new_itemtestfn
	end
	if readonly ~= false then
		GLOBAL.makereadonly(container, "itemtestfn")
	end
end

local blacklist = {}
for prefab in pairs(AllUpgradeRecipes) do
	blacklist[prefab] = true
end

local function MakeUpgradeable(inst)
	if inst == nil then return end

	local prefab = inst.prefab
	if prefab == nil or blacklist[prefab] then
		return
	end

	local container = inst.components.container

	if AllUpgradeRecipes[prefab] == nil then
		if IsTypeAllowed(container.type) then
			UpgradeRecipe(prefab, GetPara(prefab), {CalSize(container)})
		end
	end

	if AllUpgradeRecipes[prefab] == nil then
		blacklist[prefab] = true
		return
	end

	if inst.components.chestupgrade == nil then
		local blv_x, blv_y = CalSize(container)
		util.MakeUpgradeable(inst, blv_x, blv_y)
	end

	ResetItemTestFn(container)

	if GetModConfigData("CHANGESIZE") and inst.Transform ~= nil then
		util.ChangeSize(inst)
	end

	local params = AllUpgradeRecipes[prefab].params
	if util.IsSideWidget(prefab) then
		util.PackClose(inst, params)
	else
		util.CommonClose(inst, params)
	end
end

AddComponentPostInit("container", function(self)
	MakeUpgradeable(self.inst)
	--self.inst:DoTaskInTime(0, MakeUpgradeable)
end)

local function initialize(inst, self)
	local container = self.inst.components.container
	if container == nil or not IsTypeAllowed(container.type) or AllUpgradeRecipes[prefab] == nil then
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
		local data = OLD_OnSave(self) or {}
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

--[[
local function reg_para(inst)
	local container = inst.replica.container
	if container == nil or not IsTypeAllowed(container.type) or AllUpgradeRecipes[prefab] == nil then
		--inst:UnreplicateComponent("chestupgrade")
		return
	end
	local prefab = inst.prefab
	if AllUpgradeRecipes[prefab] == nil then
		if IsTypeAllowed(container.type) then
			UpgradeRecipe(prefab, GetPara(prefab))
		end
	end
	ResetItemTestFn(container, false)
end

AddClassPostConstruct("components/chestupgrade_replica", function(self)
	self.inst:DoTaskInTime(0, reg_para)
end)

GLOBAL.ChestUpgrade.GetRequirement = function()
	local params = AllUpgradeRecipes[GLOBAL.c_select().prefab].params
	local str = string.format("%d %s to all side slot", params.side.amount, params.side.type)
	print(str)
	return str
end
]]
