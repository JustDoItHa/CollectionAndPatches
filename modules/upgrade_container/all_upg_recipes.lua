local ChestUpgrade = GLOBAL.ChestUpgrade
local UpgradeRecipe = ChestUpgrade.UpgradeRecipe
local AllUpgradeRecipes = ChestUpgrade.AllUpgradeRecipes

local upgradable_container = 
{
--	[""] = {side = "", center = ""},
	["treasurechest"] 	= {side = Ingredient("boards", 1)},
	["icebox"] 			= {side = Ingredient("cutstone", 1), row = {[1] = Ingredient("gears", 1)}},
	["saltbox"] 		= {side = Ingredient("saltrock", 1), center = Ingredient("bluegem", 1)},
	["dragonflychest"] 	= {side = Ingredient("boards", 1)},
	["fish_box"] 		= {side = Ingredient("rope", 1)},
	["bookstation"]		= {side = Ingredient("livinglog", 1)},
	["tacklecontainer"] = {side = Ingredient("cookiecuttershell", 1)},
	["supertacklecontainer"] 	= {side = Ingredient("cookiecuttershell", 1)},
	["shadow_container"] 		= {side = Ingredient("shadowheart", 1)},
	["ocean_trawler"]	= {all = Ingredient("malbatross_feather", 1)},
}

for prefab, params in pairs(upgradable_container) do
	UpgradeRecipe(prefab, params)
end

local packs_params = {
	--["backpack"] = "rope",
	--背包-彩虹宝石
	["backpack"] = "opalpreciousgem",
	--保鲜背包-电子元件
	["icepack"] = "transistor",
	--厨师包-硝石
	["spicepack"] = "nitre",
	--小偷包-彩虹宝石
	["krampus_sack"] = "opalpreciousgem",
	["catback"] = "opalpreciousgem",
	--["catbigbag"] = "opalpreciousgem",
	--["krampus_sack"] = "rope",
	--小猪包-猪皮
	["piggyback"] = "pigskin",
	--	["seedpouch"] = "slurtle_shellpieces",
	--	["candybag"] = "rope",
}

for prefab, item in pairs(packs_params) do
	local params = {
		page = { [1] = Ingredient(item, 1) }
	}
	UpgradeRecipe(prefab, params)
end

--------------------------------------------------
--upgrade for modded containers and unlisted containers

if not GetModConfigData("ALLCANUPG") then return end
--[[
local WhiteList = {}

local BlackList = {}
for k, v in pairs(AllUpgradeRecipes)
	BlackList[k] = true
end
]]
local containers = require("containers")
local fakedcontainer = {SetNumSlots = function() end}
local function checkparams(prefab)
	if containers.params[prefab] == nil then
		print("[Upgradeable Chest]: Cannot find container params:", prefab)
		local cont = {}
		local container = GLOBAL.setmetatable(cont, {__index = fakedcontainer})
		containers.widgetsetup(container, prefab)
		if GLOBAL.next(cont) ~= nil then
			containers.params[prefab] = cont
			print("[Upgradeable Chest]: Container params added:", prefab)
			for k, v in pairs(cont) do
				print("", k, v)
			end
			print("---------------------------------------------")
		end
	end
	return containers.params[prefab] ~= nil
end

local function CalSize(prefab)
	local slotpos = containers.params[prefab].widget.slotpos
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
		amount = math.ceil(amount / 3)
	else
		ingredient = "waxpaper"
		amount = 1
	end

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

local function GetSUpgData(mode, x, y, z)
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
local function SetTempContainable(prefab)
	--make upgd items can be put into the container
	if old_itemtestfn[prefab] == nil then
		if containers.params[prefab] == nil then
			return
		end
		old_itemtestfn[prefab] = containers.params[prefab].itemtestfn
		containers.params[prefab].itemtestfn = function(cont, item, slot)
			for _, need in pairs(AllUpgradeRecipes[prefab].params) do
				while type(need) == "table" do
					need = need[1]
				end
				if type(need) == "string" and item.prefab == need then
					return true
				end
			end

			return item:HasTag("HAMMER_tool")
				or old_itemtestfn[prefab](cont, item, slot)
		end
	end
	return old_itemtestfn[prefab]
end

--drop upgd material that are not able to put in to the container
local function DropTempItem(inst)
	local OLD_itemtestfn = SetTempContainable(inst.prefab)
	if OLD_itemtestfn ~= nil then
		local container = inst.components.container
		local drop = {}
		for i = 1, container:GetNumSlots() do 
			local item = container.slots[i]
			if item ~= nil and not OLD_itemtestfn(container, item, i) then
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
		return true
	else
		return false
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
			chestupgrade:SpecialUpgrade(GetSUpgData(1, x, y, z), data.doer, {x = 1})
		end
		--row upgd
		if y < TUNING.CHESTUPGRADE.MAX_LV then
			chestupgrade:SpecialUpgrade(GetSUpgData(2, x, y, z), data.doer, {y = 1})
		end
	end

	--normal upgd
	if GetModConfigData("UPG_MODE") ~= 2 then
		chestupgrade:Upgrade(TUNING.CHESTUPGRADE.MAX_LV, AllUpgradeRecipes[prefab].params, data.doer)
	end

	--page upgd
	if GetModConfigData("PAGEABLE")then
		--can be upgd only when it is in max lv
		if x * y >= TUNING.CHESTUPGRADE.MAX_LV ^ 2 and z < TUNING.CHESTUPGRADE.MAX_PAGE then
			chestupgrade:SpecialUpgrade(GetSUpgData(0, x, y, z), data.doer, {z = 1})
		end
	end

	if GetModConfigData("DEGRADABLE") then
		if inst.components.container.opencount ~= 0 then return end
		local blv = chestupgrade.baselv
		if x > blv.x or y > blv.y or z > blv.z then
			chestupgrade:Degrade()
		end
	end

	if not DropTempItem(inst) then
		inst:RemoveComponent("chestupgrade")
		inst:RemoveEventCallback("onclose", OnChestClose)
	end
end

local blacklist = {}
for prefab in pairs(AllUpgradeRecipes) do
	blacklist[prefab] = true
end
AddPrefabPostInit("container", function(self)
	local inst = self.inst
	if blacklist[inst.prefab] then
		return
	end
	if AllUpgradeRecipes[inst.prefab] == nil then
		AllUpgradeRecipes[inst.prefab] = checkparams(inst.prefab) and GetPara(inst.prefab) or nil
	end
	if AllUpgradeRecipes[inst.prefab] == nil then
		blacklist[inst.prefab] = true
	end
	inst:AddComponent("chestupgrade")
	local x, y = CalSize(inst.prefab)
	if x ~= nil and y ~= nil then
		inst.components.chestupgrade:SetBaseLv(x, y)
	end

	if GetModConfigData("CHANGESIZE") and inst.Transform ~= nil then
		inst:ListenForEvent("onchestlvchange", ChangeSize)
	end

	inst:ListenForEvent("onclose", OnChestClose)
end)