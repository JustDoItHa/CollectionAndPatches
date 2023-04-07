

	--Skins
	
GLOBAL.current_skin_icefurnace = "ice_furnace_default"
	
PREFAB_SKINS.icefurnace =
{
	"icefurnace_antique",
	"icefurnace_crystal",
}

GLOBAL.PREFAB_SKINS_IDS = {}
for prefab, skins in pairs(PREFAB_SKINS) do
	GLOBAL.PREFAB_SKINS_IDS[prefab] = {}
	for k, v in pairs(skins) do
		GLOBAL.PREFAB_SKINS_IDS[prefab][v] = k
	end
end
	
AllRecipes["icefurnace"]["skinnable_icefurnace"] = true
	
STRINGS.SKIN_NAMES.icefurnace = "Default"
STRINGS.SKIN_NAMES.icefurnace_antique = "Clawfoot Furnace"
STRINGS.SKIN_NAMES.icefurnace_crystal = "Crystalline Furnace"
	
local function RecipePopupPostConstruct(widget)
	local oldGetSkinsList_icefurnace = widget.GetSkinsList
	widget.GetSkinsList = function(self)
		if self.recipe.skinnable_icefurnace == nil then
			return oldGetSkinsList_icefurnace(self)
		end
		self.skins_list = {}
		if self.recipe and PREFAB_SKINS[self.recipe.name] then
			for _, item_type in pairs(PREFAB_SKINS[self.recipe.name]) do
				local data  = {}
				data.type = type
				data.item = item_type
				data.timestamp = nil
				table.insert(self.skins_list, data)
			end
		end
		return self.skins_list
	end

	local GetName = function(var)
		return STRINGS.SKIN_NAMES[var]
	end

	local oldGetSkinOptions_icefurnace = widget.GetSkinOptions
	widget.GetSkinOptions = function(self)
		if self.recipe.skinnable_icefurnace == nil then
			return oldGetSkinOptions_icefurnace(self)
		end
		local skin_options = {}
		table.insert(skin_options,
		{
			text = STRINGS.UI.CRAFTING.DEFAULT,
			data = nil,
			colour = SKIN_RARITY_COLORS["Common"],
			new_indicator = false,
			image = {self.recipe.atlas or "images/inventoryimages.xml", self.recipe.image or self.recipe.name..".tex", "default.tex"},
		})

		local recipe_timestamp = Profile:GetRecipeTimestamp(self.recipe.name)
		if self.skins_list and TheNet:IsOnlineMode() then
			for which = 1, #self.skins_list do
				local image_name = self.skins_list[which].item

				local colour = SKIN_RARITY_COLORS["Common"]
				local text_name = GetName(image_name) or SKIN_STRINGS.SKIN_NAMES["missing"]
				local new_indicator = not self.skins_list[which].timestamp or (self.skins_list[which].timestamp > recipe_timestamp)

				if image_name == "" then
					image_name = "default"
				else
					image_name = string.gsub(image_name, "_none", "")
				end

				table.insert(skin_options,
				{
					text = text_name,
					data = nil,
					colour = colour,
					new_indicator = new_indicator,
					image = {"images/inventoryimages/"..image_name..".xml" or "images/inventoryimages.xml", image_name..".tex" or "default.tex", "default.tex"},
				})
			end
		else
			self.spinner_empty = true
		end
		return skin_options
	end
end
AddClassPostConstruct("widgets/recipepopup", RecipePopupPostConstruct)
	
local function BuilderPostInit(builder)
	local oldMakeRecipeFromMenu_icefurnace = builder.MakeRecipeFromMenu
	builder.MakeRecipeFromMenu = function(self, recipe, skin)
		if recipe.skinnable_icefurnace == nil then
			oldMakeRecipeFromMenu_icefurnace(self, recipe, skin)
		else
			if recipe.placer == nil then
				if self:KnowsRecipe(recipe.name) then
					if self:IsBuildBuffered(recipe.name) or self:CanBuild(recipe.name) then
						self:MakeRecipe(recipe, nil, nil, skin)
					end
				elseif CanPrototypeRecipe(recipe.level, self.accessible_tech_trees) and
					self:CanLearn(recipe.name) and
					self:CanBuild(recipe.name) then
					self:MakeRecipe(recipe, nil, nil, skin, function()
						self:ActivateCurrentResearchMachine()
						self:UnlockRecipe(recipe.name)
					end)
				end
			end
		end
	end

	local oldDoBuild_icefurnace = builder.DoBuild
	builder.DoBuild = function(self, recname, pt, rotation, skin)
		if GetValidRecipe(recname).skinnable_icefurnace ~= nil then
			if skin ~= nil then
				if skin == "icefurnace_antique" then
					GLOBAL.current_skin_icefurnace = "ice_furnace_antique"
				else
					GLOBAL.current_skin_icefurnace = "ice_furnace_crystal"
				end
			else
				GLOBAL.current_skin_icefurnace = "ice_furnace_default"
			end
		end
		return oldDoBuild_icefurnace(self, recname, pt, rotation, skin)
	end
end
AddComponentPostInit("builder", BuilderPostInit)

local function PlayerControllerPostInit( playercontroller )
	local OldStartBuildPlacementMode = playercontroller.StartBuildPlacementMode
	playercontroller.StartBuildPlacementMode = function(self, recipe, skin)
		if recipe ~= nil and recipe.skinnable_icefurnace ~= nil and skin ~= nil 
		and (skin == "icefurnace_antique" or skin == "icefurnace_crystal") then
			self.placer_cached = nil
			self.placer_recipe = recipe
			self.placer_recipe_skin = skin

			if self.placer ~= nil then
				self.placer:Remove()
			end

			if skin == "icefurnace_antique" then
				self.placer = SpawnPrefab("icefurnace_placer_antique")
			else
				self.placer = SpawnPrefab("icefurnace_placer_crystal")
			end

			self.placer.components.placer:SetBuilder(self.inst, recipe)
			self.placer.components.placer.testfn = function(pt, rot)
				local builder = self.inst.replica.builder
				return builder ~= nil and builder:CanBuildAtPoint(pt, recipe, rot)
			end
		else
			return OldStartBuildPlacementMode(self, recipe, skin)
		end
	end
end
AddComponentPostInit("playercontroller", PlayerControllerPostInit)
	
