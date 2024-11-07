modconfig = {}
for i, v in ipairs(modinfo.configuration_options or modconfig) do
	if v.options and #v.options > 1 then
		modconfig[v.name] = GetModConfigData(v.name, v.client)
		env[v.name] = modconfig[v.name]
	end
end

function AddPrefab(file) table.insert(PrefabFiles, file) end
function AddAsset(type, file, param) table.insert(Assets, Asset(type, file, param)) end

--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

postinitfns.PrefabPreInit = {}

function AddPrefabPreInit(name, fn)
	if postinitfns.PrefabPreInit[name] == nil then
		postinitfns.PrefabPreInit[name] = {}
	end
	table.insert(postinitfns.PrefabPreInit[name], fn)
end

AddPrefabPostInit("world", function()
	for name, fns in pairs(postinitfns.PrefabPreInit) do
		local prefab = _G.Prefabs[name]
		if prefab ~= nil then
			Tykvesh.Branch(prefab, "fn", function(fn, ...)
				for i, v in ipairs(fns) do v(fn) end
				prefab.fn = fn
				return fn(...)
			end)
		end
	end
end)

if not TheNet:IsDedicated() then
	postinitfns.ControlsPostInit = {}

	function AddControlsPostInit(fn)
		table.insert(postinitfns.ControlsPostInit, fn)
	end

	AddSimPostInit(function()
		AddClassPostConstruct("widgets/controls", function(...)
			for i, v in ipairs(postinitfns.ControlsPostInit) do v(...) end
		end)
	end)
end

--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

for pre, pst in pairs({ ModRPC = "Server", ClientModRPC = "Client", ShardModRPC = "Shard" }) do
	local addfn = "Add" .. pre .. "Handler"
	local getfn = "Get" .. pre
	local sendfn = "SendModRPCTo" .. pst

	env[addfn] = function(namespace, name, fn)
		if fn == nil then
			namespace, name, fn = modname, namespace, name
		end
		_G[addfn](namespace, name, fn)
	end

	env[sendfn] = function(rpc, ...)
		if type(rpc) == "string" then
			rpc = _G[getfn](modname, rpc)
		end
		_G[sendfn](rpc, ...)
	end
end

function SendModRPCFromEntity(name, inst, ...)
	local clients = {}
	for i, v in ipairs(AllPlayers) do
		if v:IsNear(inst, 80) then
			table.insert(clients, v.userid)
		end
	end
	if #clients > 0 and not inst:IsAsleep() then
		SendModRPCToClient(name, clients, inst, ...)
	end
end