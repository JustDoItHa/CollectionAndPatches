--Uncompromising Mode
--this change mod setting. so we move this before everythings
local KMI = GLOBAL.KnownModIndex
if KMI:IsModEnabled("workshop-2039181790") and GLOBAL.GetModConfigData("scaledchestbuff", "workshop-2039181790") and GetModConfigData("UNCOM_MODE") then
	local config = {
		["BACKPACK"] = false,
		["PAGEABLE"] = false,	
	}
	local local_option = GLOBAL.TheNet:GetIsServer() and not GLOBAL.TheNet:IsDedicated()
	local config_data = KMI:GetModConfigurationOptions_Internal(modname, local_option)
	for k, v in pairs(config_data) do
		local temp_option = config[v.name]
		if string.find(v.name, "C_") then
			temp_option = v.name == "C_DRAGONFLYCHEST"
		end
		if temp_option ~= nil then
			if v.saved_server == nil and v.saved_client == nil then
				v.saved = temp_option
			end
			if GLOBAL.TheNet:GetIsServer() then
				v.saved_server = temp_option
			else
				v.saved_client = temp_option
			end
		end
	end
	--KMI.savedata.known_mods[modname].temp_config_options = config_data
	local UNCOM_CONFIGS = KMI:GetModConfigurationOptions_Internal("workshop-2039181790", local_option)
	for k, v in pairs(UNCOM_CONFIGS) do
		if v.name == "scaledchestbuff" then
			if v.saved_server == nil and v.saved_client == nil then
				v.saved = false
			end
			if GLOBAL.TheNet:GetIsServer() then
				v.saved_server = false
			else
				v.saved_client = false
			end
		end
	end
end

TUNING.CHESTUPGRADE = {	--add to tuning so that they can be easily tuned
	MAX_LV			= GetModConfigData("MAX_LV"),
	DEGRADE_RATIO	= .5,						--math.min(GetModConfigData("DEGRADE_RATIO"), 1)
	DEGRADE_USE		= 1,						--GetModConfigData("DEGRADE_USE")
	MAX_PAGE		= GetModConfigData("PAGEABLE") and 10 or 1,

	SCALE_FACTOR	= GetModConfigData("SCALE_FACTOR"),
}

--local containers = require("containers")
--containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, (TUNING.CHESTUPGRADE.MAX_LV ^ 2 + 2 * TUNING.CHESTUPGRADE.MAX_LV) * TUNING.CHESTUPGRADE.MAX_PAGE)

AddReplicableComponent("chestupgrade")

---------------Strings----------------
local str = require("utils/upgrade_strings")

local function IsChinese()
	local locale = GLOBAL.LOC.GetLocaleCode()
	return locale == "zh" or locale == "zht"
end
local loc = GLOBAL.LOC.GetLocaleCode()

GLOBAL.STRINGS.UPGRADEABLECHEST = str("STRINGS")(loc)

----------------Main------------------
modimport("modules/upgrade_container/upgrade_util.lua")
-- modimport("modules/upgrade_container/upgrade_recipe.lua")
-- modimport("modules/upgrade_container/all_upg_recipes.lua")
TUNING.CHESTUPGRADE.MAXPACKUPGRADE = (GetModConfigData("BACKPACKPAGE") or 3) - 1
if GetModConfigData("BACKPACK") then
	--local maxslots = #containers.params.krampus_sack.widget.slotpos
	--containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, maxslots * (TUNING.CHESTUPGRADE.MAXPACKUPGRADE + 1))

	modimport("modules/upgrade_container/pack_upgrade.lua")
end

--modimport("modules/upgrade_container/upgrade_strings.lua")
modimport("modules/upgrade_container/chest_upgrade.lua")
modimport("modules/upgrade_container/upgrade_rpc.lua")
modimport("modules/upgrade_container/upgrade_widget.lua")
modimport("modules/upgrade_container/upgrade_component.lua")

--------------------------------------
AddClassPostConstruct("components/chestupgrade_replica", function(self, inst)
	if GetModConfigData("DRAGGABLE", true) then
		self.drag = GetModConfigData("DRAGGABLE", true)
	end
	if GetModConfigData("UI_WIDGETPOS", true) then
		self.uipos = true
	end
end)

local function PreInitializeSlots(inst, numslots)
	local curslots = #inst._items + #inst._itemspool
	if curslots > 0 and numslots > curslots then
		for i = curslots + 1, numslots do
			table.insert(inst._itemspool, GLOBAL.net_entity(inst.GUID, "container._items["..tostring(i).."]", "items["..tostring(i).."]dirty"))
		end
	end
end

AddPrefabPostInit("container_classified", function(inst)
	local InitializeSlots = inst.InitializeSlots
	inst.InitializeSlots = function(inst, numslots, ...)
		PreInitializeSlots(inst, numslots)
		return InitializeSlots(inst, numslots, ...)
	end
	--[[
	if GLOBAL.TheWorld.ismastersim then return end
	local tasks = inst.pendingtasks
	if tasks ~= nil then
		inst.OnReinitialize = GLOBAL.next(tasks).fn

		local OLD_InitializeSlots = inst.InitializeSlots
		inst.InitializeSlots = function(inst, ...)
			inst:RemoveAllEventCallbacks()
			OLD_InitializeSlots(inst, ...)
			inst.OnReinitialize(inst)
		end
	end
	]]
end)

----------------MOD-------------------
--Insight
if GetModConfigData("INSIGHT") and GLOBAL.KnownModIndex:IsModEnabled("workshop-2189004162") then
	local DESCRIBE = str("INSIGHT")
	local function AddDescriptors()
		GLOBAL.Insight.descriptors.chestupgrade = {
			Describe = function(self, context)
				local lang = (context.config.language == "automatic" and IsChinese() or context.config.language == "zh") and "zh" or "en"
				local text = DESCRIBE[lang] or DESCRIBE["en"]

				local description
				if TUNING.CHESTUPGRADE.MAX_PAGE > 1 then
					description = string.format(text.pageable, self:GetLv())
				else
					description = string.format(text.generic, self:GetLv())
				end

				return {
					priority = 0,
					description = description
				}
			end
		}
	end

	AddSimPostInit(AddDescriptors)
end