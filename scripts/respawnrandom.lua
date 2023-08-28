if not GLOBAL.TheNet:GetIsServer() then 
    return
end

print("Mod Load: respawnrandom.lua")

local Vector3 = GLOBAL.Vector3
local SpawnPrefab = GLOBAL.SpawnPrefab
local GROUND = GLOBAL.GROUND

local leastnum_beefalo = GetModConfigData("leastnum_beefalo")
local leastnum_lightninggoat = GetModConfigData("leastnum_lightninggoat")
local leastnum_spiderden = GetModConfigData("leastnum_spiderden")
local leastnum_catcoonden = GetModConfigData("leastnum_catcoonden")
local leastnum_beehive = GetModConfigData("leastnum_beehive")
local leastnum_knight = GetModConfigData("leastnum_knight")

local function TrySpawn(strfab)
    local pt = Vector3(math.random(-1000, 1000), 0, math.random(-1000, 1000))
    local tile = GLOBAL.TheWorld.Map:GetTileAtPoint(pt.x, pt.y, pt.z)
    local canspawn = tile == GROUND.ROAD or tile == GROUND.ROAD or tile == GROUND.ROCKY or tile == GROUND.DIRT or tile == GROUND.SAVANNA or tile == GROUND.GRASS 
        or tile == GROUND.FOREST or tile == GROUND.MARSH or tile == GROUND.WOODFLOOR or tile == GROUND.CARPET or tile == GROUND.CHECKER or tile == GROUND.DECIDUOUS
        or tile == GROUND.DESERT_DIRT or tile == GROUND.SCALE -- or tile == GROUND.METEOR or tile == GROUND.PEBBLEBEACH 月岛地皮
    if canspawn then
        print(string.upper(strfab), "SPAWNED!")
        local b = SpawnPrefab(strfab)
        b.Transform:SetPosition(pt:Get())
    else
        TrySpawn(strfab)
    end
end

local function BeefaloSpawnner(inst)
	inst:ListenForEvent("onremove", function(inst)
		local current_num = GLOBAL.c_countprefabs("beefalo", true)
		if current_num < leastnum_beefalo then
			TrySpawn("beefalo")
		end
	end)
end

local function LightninggoatSpawnner(inst)
	inst:ListenForEvent("onremove", function(inst)
		local current_num = GLOBAL.c_countprefabs("lightninggoat", true)
		if current_num < leastnum_lightninggoat then
			TrySpawn("lightninggoat")
		end
	end)
end

local function SpiderdenSpawnner(inst)
	inst:ListenForEvent("onremove", function(inst)
		local current_num = GLOBAL.c_countprefabs("spiderden", true)
		if current_num < leastnum_spiderden then
			TrySpawn("spiderden")
		end
	end)
end

local function CatcoondenSpawnner(inst)
	inst:ListenForEvent("onremove", function(inst)
		local current_num = GLOBAL.c_countprefabs("catcoonden", true)
		if current_num < leastnum_catcoonden then
			TrySpawn("catcoonden")
		end
	end)
end

local function BeehiveSpawnner(inst)
	inst:ListenForEvent("onremove", function(inst)
		local current_num = GLOBAL.c_countprefabs("beehive", true)
		if current_num < leastnum_beehive then
			TrySpawn("beehive")
		end
	end)
end

local function KnightSpawnner(inst)
	inst:ListenForEvent("onremove", function(inst)
		local current_num = GLOBAL.c_countprefabs("knihgt", true)
		if current_num < leastnum_knight then
			TrySpawn("knight")
		end
	end)
end


AddPrefabPostInit("beefalo", BeefaloSpawnner)
AddPrefabPostInit("lightninggoat", LightninggoatSpawnner)
AddPrefabPostInit("spiderden", SpiderdenSpawnner)
AddPrefabPostInit("catcoonden", CatcoondenSpawnner)
AddPrefabPostInit("beehive", BeehiveSpawnner)
AddPrefabPostInit("knight", KnightSpawnner)