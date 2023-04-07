for i, v in ipairs({ "_G", "setmetatable", "rawget" }) do
	env[v] = GLOBAL[v]
end

setmetatable(env,
{
	__index = function(table, key) return rawget(_G, key) end
})

modpath = package.path:match("([^;]+)")
package.path = package.path:sub(#modpath + 2) .. ";" .. modpath

--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

--PrefabFiles = {}
--Assets = {}
Modules = { "modutil", "epichealthbar", "epicfixes" }

--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

local mem = setmetatable({}, { __mode = "v" })
local function argtohash(...) local str = ""; for i, v in ipairs(arg) do str = str .. tostring(v) end; return hash(str) end
local function memget(...) return mem[argtohash(...)] end
local function memset(value, ...) mem[argtohash(...)] = value end

Tykvesh =
{
	Dummy = function() end,
	InLimbo = { "INLIMBO" },

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

	GetUpvalue = function(fn, ...)
		local prevfn, i
		for _, name in ipairs(arg) do
			for _i = 1, math.huge do
				local _name, _upvalue = debug.getupvalue(fn, _i)
				if _upvalue == nil then
					return
				elseif _name == name then
					fn, i, prevfn = _upvalue, _i, fn
					break
				end
			end
		end
		return fn, i, prevfn
	end,

	BranchUpvalue = function(fn, ...)
		local upvalue = table.remove(arg)
		local fn, i, prevfn = Tykvesh.GetUpvalue(fn, unpack(arg))
		if type(fn) ~= "function" then
			debug.setupvalue(prevfn, i, upvalue(fn))
		else
			debug.setupvalue(prevfn, i, function(...) return upvalue(fn, ...) end)
		end
	end,

	Browse = function(table, ...)
		for i, v in ipairs(arg) do
			if type(table) ~= "table" then
				return
			end
			table = table[v]
		end
		return table
	end,

	OnEntityReplicated = function(inst, fn, lowprio)
		if TheWorld.ismastersim or inst.Network == nil then
			StartThread(fn, inst.GUID, inst)
		else
			Tykvesh.Parallel(inst, "OnEntityReplicated", fn, lowprio)
		end
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

for index, module in ipairs(Modules) do
	local result = kleiloadlua(MODROOT .. "modules/epic_healthbar/" .. module .. ".lua")
	if type(result) == "function" then
		RunInEnvironment(result, env)
	end
end