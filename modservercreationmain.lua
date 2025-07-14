for i, v in ipairs({ "_G", "setmetatable", "rawget" }) do
	env[v] = GLOBAL[v]
end

setmetatable(env,
{
	__index = function(table, key) return rawget(_G, key) end
})

pcall(modinfo.SetLocaleMod, env)

--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

local mem = setmetatable({}, { __mode = "v" })
local function argtohash(...) local str = ""; for i, v in ipairs(arg) do str = str .. tostring(v) end; return hash(str) end
local function memget(...) return mem[argtohash(...)] end
local function memset(value, ...) mem[argtohash(...)] = value end
local time_units = { { 86400, "d"}, { 3600, "h" }, { 60, "m" }, { 1, "s" }  }

Tykvesh =
{
	Dummy = function() end,

	Parallel = function(root, key, fn, lowprio)
		if type(root) == "table" then
			local oldfn = root[key]
			local newfn = oldfn and memget("PARALLEL", oldfn, fn)
			if not oldfn or newfn then
				root[key] = newfn or fn
			else
				if lowprio then
					root[key] = function(...) oldfn(...) return fn(...) end
				else
					root[key] = function(...) fn(...) return oldfn(...) end
				end
				memset(root[key], "PARALLEL", oldfn, fn)
			end
		end
	end,

	Branch = function(root, key, fn)
		if type(root) == "table" then
			local oldfn = root[key]
			if oldfn then
				local newfn = memget("BRANCH", oldfn, fn)
				if newfn then
					root[key] = newfn
				else
					root[key] = function(...) return fn(oldfn, ...) end
					memset(root[key], "BRANCH", oldfn, fn)
				end
			end
		end
	end,

	Timer = function(time)
		local bits = {}
		for index, data in pairs(time_units) do
			local range, suffix = unpack(data)
			if time > range then
				table.insert(bits, math.floor(time / range) .. suffix)
				time = time % range
				if #bits == 2 then
					break
				end
			end
		end
		return table.concat(bits, " ")
	end,
}

if rawget(_G, "Tykvesh") == nil then
	rawset(_G, "Tykvesh", Tykvesh)
else
	for name, data in pairs(Tykvesh) do
		_G["Tykvesh"][name] = data
	end
	Tykvesh = _G["Tykvesh"]
end

--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

local success, ModConfigurationScreen = pcall(require, "screens/redux/modconfigurationscreen")

if success and not ModConfigurationScreen._epichealthbarpatched then
	ModConfigurationScreen._epichealthbarpatched = true

	Tykvesh.Branch(ModConfigurationScreen, "_ctor", function(ctor, self, _modname, client_config, ...)
		if _modname == modname and not client_config then
			self._epichealthbardirty = true
			client_config = true
		end
		local screen = ctor(self, _modname, client_config, ...)
		if self._epichealthbardirty then
			self:MakeDirty(false)
		end
		return screen
	end)

	Tykvesh.Parallel(ModConfigurationScreen, "IsDefaultSettings", function(self)
		if self._epichealthbardirty then
			self:LoadConfigurationOptions()
		end
	end)

	Tykvesh.Parallel(ModConfigurationScreen, "Apply", function(self)
		if self._epichealthbardirty then
			local settings = self:CollectSettings()
			if TUNING.EPICHEALTHBAR ~= nil then
				for i, v in ipairs(settings) do
					if TUNING.EPICHEALTHBAR[v.name] ~= nil then
						TUNING.EPICHEALTHBAR[v.name] = v.saved
					end
				end
			end
			KnownModIndex:SaveConfigurationOptions(Tykvesh.Dummy, self.modname, settings, false)
		end
	end)

	function ModConfigurationScreen:LoadConfigurationOptions()
		local config = KnownModIndex:LoadModConfigurationOptions(self.modname)
		for _, option in ipairs(config or {}) do
			if not option.client and option.options and #option.options > 1 then
				local data = option.saved
				if data == nil then
					data = option.default
				end
				for i, v in ipairs(self.options) do
					if v.options == option.options then
						v.value = data
						break
					end
				end
			end
		end
	end
end

--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

local PersistentData = require "utils/persistentdata"
local SavedCaptures = PersistentData("epichealthbar_captures")

local function PatchModsTab()
	local TEMPLATES = require "widgets/redux/templates"
	local CaptureBrowser = require "screens/epiccapturebrowser"

	local screen = TheFrontEnd:GetActiveScreen()
	local mods_tab = screen and screen.mods_tab
	if mods_tab ~= nil and not mods_tab._epichealthbarpatched then
		mods_tab._epichealthbarpatched = true

		local menu = mods_tab.selectedmodmenu
		local offset = Vector3(-menu.offset * (#menu.items + 1), 0)
		local hovertext_top = { offset_x = 2, offset_y = 45 }

		Tykvesh.Parallel(mods_tab, "ShowModDetails", function(self)
			if self.currentmodname == modname and SavedCaptures:Exists() then
				if mods_tab.modextrasbutton ~= nil then
					return
				end
				mods_tab.modextrasbutton = TEMPLATES.IconButton("images/button_icons.xml", "movie.tex", "Captures", false, false, function()
					TheFrontEnd:PushScreen(CaptureBrowser(SavedCaptures, mods_tab.slotnum))
				end, hovertext_top)
				menu:AddCustomItem(mods_tab.modextrasbutton, offset)
			elseif mods_tab.modextrasbutton ~= nil then
				for index, item in ipairs(menu.items) do
					if item == mods_tab.modextrasbutton then
						table.remove(menu.items, index)
						break
					end
				end
				mods_tab.modextrasbutton = mods_tab.modextrasbutton:Kill()
			end
		end, true)

		return true
	end
end

if SavedCaptures:Exists() then
	if TUNING.EPICHEALTHBAR == nil then
		ModManager:InitializeModMain(modname, env, "modmain.lua", true)

		local prefab = Prefab("MOD_" .. modname, nil, Assets, {}, true)
		prefab.search_asset_first_path = MODS_ROOT .. modname .. "/"
		RegisterSinglePrefab(prefab)
		TheSim:LoadPrefabs({ prefab.name })

		TUNING.EPICHEALTHBAR.GLOBAL_NUMBERS = false
		TUNING.EPICHEALTHBAR.CAPTURE = false
		TUNING.EPICHEALTHBAR.PHASES.KLAUS = nil
	end

	if not PatchModsTab() then
		TheGlobalInstance:DoTaskInTime(0, PatchModsTab)
	end
end