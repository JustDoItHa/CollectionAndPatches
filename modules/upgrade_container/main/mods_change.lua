local KMI = GLOBAL.KnownModIndex

local pre = {}
local post = {}

local UNCMODE = false
function pre.UncompomisingMode()
	if KMI:IsModEnabled("workshop-2039181790") and GLOBAL.GetModConfigData("scaledchestbuff", "workshop-2039181790") then
		if GetModConfigData("UNCOM_MODE") then
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
		else
			UNCMODE = true
		end
	end
end

function post.UncompomisingMode()
	if UNCMODE then
		AddPrefabPostInit("dragonflychest", function(inst)
			if not GLOBAL.TheWorld.ismastersim then return end
			if inst.components.chestupgrade ~= nil then
				inst.components.chestupgrade:SetBaseLv(5, 5, 1)
			end
		end)
	end
end

local isChinese = function()
	local locale = GLOBAL.LOC.GetLocaleCode()
	return locale == "zh" or locale == "zht"
end

--Insight
function post.Insight()
	if GetModConfigData("INSIGHT") and KMI:IsModEnabled("workshop-2189004162") then
		local DESCRIBE = env.GetString("INSIGHT")
		local function AddDescriptors()
			GLOBAL.Insight.descriptors.chestupgrade = {
				Describe = function(self, context)
					local lang = context.config.language == "automatic" and isChinese() and "zh" or context.config.language
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
end

function post.UpgradeableChest()
	AddClassPostConstruct("components/chestupgrade_replica", function(self, inst)
		if GetModConfigData("DRAGGABLE", true) then
			self.drag = GetModConfigData("DRAGGABLE", true)
		end
		if GetModConfigData("UI_WIDGETPOS", true) then
			self.uipos = true
		end
	end)
end

function pre.KrampusOnly()
	local option_name = "BACKPACK"
	if GetModConfigData("KRAMPUS_ONLY") and not GetModConfigData(option_name) then
		local config, temp_options = KMI:GetModConfigurationOptions_Internal(modname, false)
		if temp_options then
			config[option_name] = true
		else
			for i,v in pairs(config) do
				if v.name == option_name then
					if GLOBAL.TheNet:GetIsServer() then
						v.saved_server = true
					end
					if v.saved ~= nil then
						v.saved = true
					end
					break
				end
			end
		end
	end
end
--[[
function post.KrampusOnly()
	if GetModConfigData("KRAMPUS_ONLY") then
		local recipe = AllUpgradeRecipes["krampus_sack"]
		recipe.params.page = {[1] = Ingredient("waxpaper", 1)}
		ChestUpgrade.PackSetUp("krampus_sack", recipe.params, recipe.lv)
	end
end
]]
function env.ChestUpgradePreInit()
	for _, fn in pairs(pre) do
		fn()
	end
end

function env.ChestUpgradePostInit()
	for _, fn in pairs(post) do
		fn()
	end
end