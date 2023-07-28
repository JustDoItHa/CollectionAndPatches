function AddPrefab(file)
    table.insert(PrefabFiles, file)
end
function AddAsset(type, file, param)
    table.insert(Assets, Asset(type, file, param))
end

--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

postinitfns.PrefabPreInit = {}

function AddPrefabPreInit(name, fn)
    if postinitfns.PrefabPreInit[name] == nil then
        postinitfns.PrefabPreInit[name] = {}
    end
    table.insert(postinitfns.PrefabPreInit[name], fn)
end

function AddSimPreInit(fn)
    AddPrefabPostInit("world", fn)
end

AddSimPreInit(function()
    for name, fns in pairs(postinitfns.PrefabPreInit) do
        local prefab = _G.Prefabs[name]
        if prefab ~= nil then
            Tykvesh.Branch(prefab, "fn", function(fn, ...)
                for i, v in ipairs(fns) do
                    v(fn)
                end
                prefab.fn = fn
                return fn(...)
            end)
        end
    end
    postinitfns.PrefabPreInit = {}
end)

if not TheNet:IsDedicated() then
    postinitfns.ControlsPostInit = {}

    function AddControlsPostInit(fn)
        table.insert(postinitfns.ControlsPostInit, fn)
    end

    AddSimPostInit(function()
        local Controls = require "widgets/controls"

        Tykvesh.Parallel(Controls, "_ctor", function(...)
            for i, v in ipairs(postinitfns.ControlsPostInit) do
                v(...)
            end
        end, true)
    end)
end