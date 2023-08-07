--[[
params = {
	all = Ingredient(),			--all slot
	page = {					--all slot of page[n]
		[n] = Ingredient(),
	},
	side = Ingredient(),		--side, main feature for this mod
	hollow = true/false,		--should be center empty(ie. except "side")
	row = {						--all slot of row[n]
		[n] = Ingredient(),
	},
	column = {					--all slot of column[n]
		[n] = Ingredient(),
	},
	center = Ingredient(),		--center-most
	slot = {					--slot[n]
		[n] = Ingredient(),
	},
	degrade = Ingredient(),		--should do nothing, but return this item when degrade
			/ function(chestlv) --if function, return "item" and "count"
}

instead of using Ingredient(), a simple string "prefab_name",
or a function(item, inst, doer) return true/false end
item: is the item we get from the corresponding container slot,
inst: is the container
doer: is player who close the chest
note that, the return value is not-ed. ie false will keep upgrade, and true stop --going to change it in the future

priority from slot -> all. all has the lowest priority and slot has the highest
only higher priority will be checked for same slot
]]

----------------------------------------------------------------
GLOBAL.ChestUpgrade.AllUpgradeRecipes = {}
local AUR = GLOBAL.ChestUpgrade.AllUpgradeRecipes
local commonlv = {3,3}

UpgradeRecipe = Class(function(self, prefab, params, lv, degrade)
	self.prefab = prefab
	self.params = params

	self.all = params.all
	self.page = params.page
	self.side = params.side
	self.hollow = params.hollow
	self.row = params.row
	self.column = params.column
	self.center = params.center
	self.slot = params.slot

	if params.degrade ~= nil or degrade ~= nil then
		self.degrade = degrade or params.degrade or nil
		if self.params.degrade ~= nil then
			self.params.degrade = nil
		end
	else
		self.degrade = params.side
	end

	self.lv = params.lv or lv or commonlv
	if self.params.lv ~= nil then
		self.params.lv = nil
	end

	GLOBAL.ChestUpgrade.AllUpgradeRecipes[self.prefab] = self
end)

function UpgradeRecipe:GetParams(prefab)
	return self.params ~= nil and self.params or nil
end
--[[
function UpgradeRecipe:AddIngredient(index, ingr)
	local old_ingr = self.params[index]
	if type(old_ingr) ~= "table" then
		self.params[index] = {old_ingr, ingr}
	else
		table.insert(self.params[index], ingr)
	end
end
]]
function UpgradeRecipe:ChangeIngredient(index, ingr)
	self.params[index] = ingr
	self[index] = ingr
end

function UpgradeRecipe:GetIngredient(index)
	return self.params[index]
end

function UpgradeRecipe:GetRequirement(index)
	return self.params[index].type, self.params[index].amount
end

function UpgradeRecipe:RemoveIngredient(index)
	self.params[index] = nil
end

function UpgradeRecipe:RemoveRecipe()
	GLOBAL.ChestUpgrade.AllUpgradeRecipes[self.prefab] = nil
end

function UpgradeRecipe:AddBlackList(prefab)
	if GLOBAL.ChestUpgrade.BlackList == nil then
		GLOBAL.ChestUpgrade.BlackList = {}
	end
	GLOBAL.ChestUpgrade.AllUpgradeRecipes.BlackList[prefab] = true
	if GLOBAL.ChestUpgrade.AllUpgradeRecipes[prefab] then
		GLOBAL.ChestUpgrade.AllUpgradeRecipes[prefab] = nil
	end
end

GLOBAL.ChestUpgrade.UpgradeRecipe = UpgradeRecipe

--return UpgradeRecipe