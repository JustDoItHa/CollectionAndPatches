local AllUpgradeRecipes = ChestUpgrade.AllUpgradeRecipes
local COMMONLV = {3,3}

local UpgradeRecipe = Class(function(self, prefab, params, lv, degrade)
	self.prefab = prefab

	if params == nil then
		params = {}
	end

	self.params = {
		all 	= params.all,
		page 	= params.page,
		side 	= params.side,
		hollow 	= params.hollow,
		row 	= params.row,
		column 	= params.column,
		center 	= params.center,
		slot 	= params.slot,
	}

	if params.degrade ~= nil or degrade ~= nil then
		self.degrade = degrade or params.degrade or nil
	end

	lv = lv or params.lv or COMMONLV
	self.lv = Vector3(lv.x or lv[1], lv.y or lv[2], lv.z or lv[3] or 1)

	self.isupgraderecipe = true

	self:AddRecipe()
end)

function UpgradeRecipe:GetParams()
	return self.params
end

function UpgradeRecipe:AddIngredient(index, idx2, ingr, amount)
	if index == nil or idx2 == nil then return end
	if type(idx2) ~= "number" then
		idx2, ingr, amount = nil, idx2, ingr
	end
	if ingr == nil then return end
	if type(ingr) == "string" then
		ingr = Ingredient(ingr, amount or 1)
	end
	if idx2 then
		if self.params[index] == nil then
			self.params[index] = {}
		end
		self.params[index][idx2] = ingr
	else
		self.params[index] = ingr
	end
end

function UpgradeRecipe:ChangeIngredient(index, ingr)
	self.params[index] = ingr
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

function UpgradeRecipe:AddRecipe()
	if AllUpgradeRecipes then
		AllUpgradeRecipes[self.prefab] = self
	end
end

function UpgradeRecipe:RemoveRecipe()
	if AllUpgradeRecipes then
		AllUpgradeRecipes[self.prefab] = nil
	end
end

function UpgradeRecipe:AddBlackList()
	local prefab = self.prefab
	if AllUpgradeRecipes then
		if AllUpgradeRecipes.BlackList == nil then
			AllUpgradeRecipes.BlackList = {}
		end
		AllUpgradeRecipes.BlackList[prefab] = self
		if AllUpgradeRecipes[prefab] then
			AllUpgradeRecipes[prefab] = nil
		end
	end
end

--ChestUpgrade.UpgradeRecipe = UpgradeRecipe

return UpgradeRecipe