local util = require("utils/chestupgrade_util")
local AddUpgradeRecipe = require("utils/chestupgrade_recipe")

local DEBUG = {}
function DEBUG.MaxLv(inst)
	if inst.components.container ~= nil then
		if inst.components.container:IsSideWidget() then
			--local maxpage = issidewidget and TUNING.CHESTUPGRADE.MAXPACKUPGRADE or TUNING.CHESTUPGRADE.MAX_PAGE
			local x, y = inst.components.chestupgrade:GetLv()
			local z = TUNING.CHESTUPGRADE.MAXPACKPAGE
			inst.components.chestupgrade:SetChestLv(x, y, z)
		else
			inst.components.chestupgrade:SetChestLv(TUNING.CHESTUPGRADE.MAX_LV, TUNING.CHESTUPGRADE.MAX_LV, TUNING.CHESTUPGRADE.MAX_PAGE)
		end
	end
end

function DEBUG.ItemInContainer(inst)
	if inst.components.container ~= nil then
		inst.components.chestupgrade:SetChestLv(TUNING.CHESTUPGRADE.MAX_LV, TUNING.CHESTUPGRADE.MAX_LV, 1)
		inst.components.chestupgrade:Degrade(1)
	end
end

local checkrecipe = function(prefab, params, lv, type)
	local AUR = ChestUpgrade.AllUpgradeRecipes
	if AUR[prefab] == nil then
		local prop = {lv = lv}
		AddUpgradeRecipe(prefab, params, nil, prop)
	end
	if AUR[prefab].upgradefn == nil then
		if type == "pack" then
			AUR[prefab].upgradefn = util.PackUpgradeFn
		else
			AUR[prefab].upgradefn = util.ChestUpgradeFn
		end
	end
end

local function ChestSetUp(prefab, params, size)
	checkrecipe(prefab, params, size)

	if size == nil then
		size = {3,3}
	end
	local x, y = (size.x or size[1]), (size.y or size[2])

	local widgetpos = GetModConfigData("UI_WIDGETPOS", true)
	local bgimage = not GetModConfigData("UI_BGIMAGE", true)

	util.CustomUI(prefab, widgetpos, bgimage)

	AddPrefabPostInit(prefab, function(inst)
		util.CanTakeTempItem(inst, params)

		if not GLOBAL.TheWorld.ismastersim then return end

		util.MakeUpgradeable(inst, x, y)
		util.CommonClose(inst, params)

		if GetModConfigData("RETURNITEM") then
			util.Deconstruct(inst)
		end

		if GetModConfigData("CHANGESIZE") then
			local scale = GLOBAL.Vector3(inst.Transform:GetScale())
			if scale == GLOBAL.Vector3(1,1,1) then
				scale = nil
			end
			util.ChangeSize(inst, scale)
		end

		if GetModConfigData("DEBUG_MAXLV") then
			DEBUG.MaxLv(inst)
		elseif GetModConfigData("DEBUG_IIC") then
			DEBUG.ItemInContainer(inst)
		end
	end)
end

local function PackSetUp(prefab, params, size)
	checkrecipe(prefab, params, size, "pack")

	if size == nil then
		size = {3,3}
	end

	local x, y = (size.x or size[1]), (size.y or size[2])

	AddPrefabPostInit(prefab, function(inst)
		util.CanTakeTempItem(inst, params)

		if not GLOBAL.TheWorld.ismastersim then return end

		util.MakeUpgradeable(inst, x, y)
		util.PackClose(inst, params)

		if GetModConfigData("RETURNITEM") then
			util.Deconstruct(inst)
		end

		if GetModConfigData("DEBUG_MAXLV") then
			DEBUG.MaxLv(inst)
		elseif GetModConfigData("DEBUG_IIC") then
			DEBUG.ItemInContainer(inst)
		end
	end)
end

local function EasySetUp(prefab, params, size)
	if util.IsSideWidget(prefab) then
		PackSetUp(prefab, params, size)
	else
		ChestSetUp(prefab, params, size)
	end
end

env.ChestUpgrade.EasySetUp = EasySetUp
env.ChestUpgrade.ChestSetUp = ChestSetUp
env.ChestUpgrade.PackSetUp = PackSetUp

env.ChestUpgrade.DEBUG = DEBUG