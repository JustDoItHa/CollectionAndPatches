
--PrefabFiles =
--{
--	"icefurnace",
--	"furnace_transform_fx",
--}
table.insert(PrefabFiles, "icefurnace")
table.insert(PrefabFiles, "furnace_transform_fx")
--Assets =
--{
--    Asset("ANIM", "anim/ui_chest_3x1.zip"),
--	Asset("ANIM", "anim/ui_chest_3x2.zip"),
--	Asset("ANIM", "anim/ui_chest_3x3.zip"),
--	Asset("ANIM", "anim/ui_chester_shadow_3x4.zip"),
--	Asset("ANIM", "anim/ui_tacklecontainer_3x5.zip"),
--
--
--	Asset("IMAGE", "images/inventoryimages/icefurnace.tex"), Asset("ATLAS", "images/inventoryimages/icefurnace.xml"),
--	Asset("IMAGE", "images/inventoryimages/icefurnace_antique.tex"), Asset("ATLAS", "images/inventoryimages/icefurnace_antique.xml"),
--	Asset("IMAGE", "images/inventoryimages/icefurnace_crystal.tex"), Asset("ATLAS", "images/inventoryimages/icefurnace_crystal.xml"),
--
--	Asset("IMAGE", "images/minimap/icefurnace.tex"), Asset("ATLAS", "images/minimap/icefurnace.xml"),
--}

table.insert(Assets, Asset("ANIM", "anim/ui_chest_3x1.zip"))
table.insert(Assets, Asset("ANIM", "anim/ui_chest_3x2.zip"))
table.insert(Assets, Asset("ANIM", "anim/ui_chest_3x3.zip"))
table.insert(Assets, Asset("ANIM", "anim/ui_chester_shadow_3x4.zip"))
table.insert(Assets, Asset("ANIM", "anim/ui_tacklecontainer_3x5.zip"))

table.insert(Assets, Asset("IMAGE", "images/inventoryimages/icefurnace.tex"))
table.insert(Assets, Asset("ATLAS", "images/inventoryimages/icefurnace.xml"))
table.insert(Assets, Asset("IMAGE", "images/inventoryimages/icefurnace_antique.tex"))
table.insert(Assets, Asset("ATLAS", "images/inventoryimages/icefurnace_antique.xml"))
table.insert(Assets, Asset("IMAGE", "images/inventoryimages/icefurnace_crystal.tex"))
table.insert(Assets, Asset("ATLAS", "images/inventoryimages/icefurnace_crystal.xml"))

table.insert(Assets, Asset("IMAGE", "images/minimap/icefurnace.tex"))
table.insert(Assets, Asset("ATLAS", "images/minimap/icefurnace.xml"))


GLOBAL.setmetatable(env, {__index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end})

GLOBAL.is_english_icefurnace = GetModConfigData("lang")
GLOBAL.heat_control_icefurnace = GetModConfigData("temp")
GLOBAL.light_range_icefurnace = GetModConfigData("light_range") or 1
GLOBAL.num_slots_icefurnace = GetModConfigData("container_slot") or 3
GLOBAL.fresh_rate_icefurnace = GetModConfigData("fresh_rate") or 0
GLOBAL.ice_production_icefurnace = GetModConfigData("produce_ice") or 240
GLOBAL.way_to_obtain_icefurnace = GetModConfigData("way_to_obtain") or 1

--AddMinimapAtlas("images/minimap/icefurnace.xml")
AddMinimapAtlas("images/minimap/icefurnace.xml")


	--Description
	
if is_english_icefurnace then
	STRINGS.NAMES.ICEFURNACE = "Ice Furnace"
	STRINGS.RECIPE_DESC.ICEFURNACE = "No one can refuse it in summer."
	STRINGS.CHARACTERS.GENERIC.DESCRIBE.ICEFURNACE = "So cool!"
else
	STRINGS.NAMES.ICEFURNACE = "龙鳞冰炉"
	STRINGS.RECIPE_DESC.ICEFURNACE = "没有人能在夏天拒绝它。"
	STRINGS.CHARACTERS.GENERIC.DESCRIBE.ICEFURNACE = "透心凉!"
end

	--Containers
if num_slots_icefurnace > 0 then
	modimport("scripts/containers_import.lua")
end

	--Transform/Build
if GetModConfigData("ice_furnace_switch") then
	if way_to_obtain_icefurnace == 1 then
		modimport("scripts/action_staff_import.lua")
	elseif way_to_obtain_icefurnace == 2 then
		modimport("scripts/action_switch_import.lua")
	else
		AddPrefabPostInit("dragonfly", function(inst)
			if GLOBAL.TheWorld.ismastersim then
				if inst.components.lootdropper ~= nil then
					inst.components.lootdropper:AddChanceLoot("icefurnace_blueprint", 1.0)
				end
			end
		end)
		--AddRecipe("icefurnace", {Ingredient("dragon_scales", 1), Ingredient("bluegem", 2), Ingredient("nitre", 10)},
		--		RECIPETABS.TOWN, TECH.LOST,
		--		"icefurnace_placer_default", nil, nil, nil, nil,
		--		"images/inventoryimages/icefurnace.xml", "icefurnace.tex")
		AddRecipe2("icefurnace", {Ingredient("dragon_scales", 1), Ingredient("bluegem", 2), Ingredient("nitre", 10)},
				TECH.LOST,
				{placer = "icefurnace_placer_default", atlas = "images/inventoryimages/icefurnace.xml", image = "icefurnace.tex"},
				{"LIGHT","MAGIC","SUMMER"})
		AllRecipes["icefurnace"]["sortkey"] = AllRecipes["dragonflyfurnace"]["sortkey"] + 0.01
		modimport("scripts/skin_build_import.lua")
	end
end


	--Clean Sweeper

local function spell_icefurnace(inst, target, pos, ...)
	if target ~= nil and target:HasTag("icefurnace") and target.skinname ~= nil then
		local fx_prefab = "explode_reskin"
		local skin_fx = SKIN_FX_PREFAB[inst:GetSkinName()]
		if skin_fx ~= nil and skin_fx[1] ~= nil then
			fx_prefab = skin_fx[1]
		end
		local fx = SpawnPrefab(fx_prefab)
		local x, y, z = target.Transform:GetWorldPosition()
		fx.Transform:SetScale(1.8, 1.8, 1.8)
		fx.Transform:SetPosition(x, y + 0.6, z)
		if target.skinname == 1 then
			target.skinname = 2
			target.AnimState:SetBank("ice_furnace_antique")
			target.AnimState:SetBuild("ice_furnace_antique")
			return
		elseif target.skinname == 2 then
			target.skinname = 3
			target.AnimState:SetBank("ice_furnace_crystal")
			target.AnimState:SetBuild("ice_furnace_crystal")
			return
		else
			target.skinname = 1
			target.AnimState:SetBank("ice_furnace_default")
			target.AnimState:SetBuild("ice_furnace_default")
			return	
		end
	end
	if inst.old_spell_icefurnace ~= nil then
		return inst.old_spell_icefurnace(inst, target, pos, ...)
	end
end
	
AddPrefabPostInit("reskin_tool", function(inst)
	if GLOBAL.TheWorld.ismastersim then
		if inst.components.spellcaster ~= nil then
			inst.old_spell_icefurnace = inst.components.spellcaster.spell
			inst.components.spellcaster:SetSpellFn(spell_icefurnace)
		end
	end
end)

	--Temperature

AddComponentPostInit("temperature", function(Temperature, inst)
	Temperature.oldOnUpdateFn_icefurnace = Temperature.OnUpdate
	function Temperature:OnUpdate(dt, applyhealthdelta)
		local owner = self.inst.components.inventoryitem ~= nil and self.inst.components.inventoryitem.owner or nil
		if owner ~= nil and owner:HasTag("icefurnace") and owner:HasTag("fridge") then
			if self.settemp ~= nil or
				self.inst.is_teleporting or (self.inst.components.health ~= nil and self.inst.components.health:IsInvincible()) then
				return
			end
			local mintemp = self.mintemp
			local maxtemp = self.maxtemp
			self.rate = -TUNING.WARM_DEGREES_PER_SEC
			self:SetTemperature(math.clamp(self.current + self.rate * dt, mintemp, maxtemp))
			
			if applyhealthdelta ~= false and self.inst.components.health ~= nil then
				if self.current < 0 then
					self.inst.components.health:DoDelta(-self.hurtrate * dt, true, "cold")
				elseif self.current > self.overheattemp then
					self.inst.components.health:DoDelta(-(self.overheathurtrate or self.hurtrate) * dt, true, "hot")
				end
			end
		else
			return Temperature:oldOnUpdateFn_icefurnace(dt, applyhealthdelta)
		end
	end
end)

