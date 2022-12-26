--------------------------------------------------------------------------
--[[ 全局 ]]
--------------------------------------------------------------------------

--下行代码只代表查值时自动查global，增加global的变量或者修改global的变量时还是需要带"GLOBAL."
GLOBAL.setmetatable(env, { __index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end })
local _G = GLOBAL

--------------------------------------------------------------------------
--[[ 主要 ]]
--------------------------------------------------------------------------

-- PrefabFiles = {
-- }

-- Assets = {
-- }

TUNING.MOD_SECRETMOON = true --设置全局标识，让其他mod也能检测到，以此做一些兼容吧

local IsServer = TheNet:GetIsServer() or TheNet:IsDedicated()

--------------------------------------------------------------------------
--[[ 码头套装制作一次获取多个 ]]
--------------------------------------------------------------------------

local _DockKitNum = GetModConfigData("DockKitNum")
if _DockKitNum and _DockKitNum ~= 4 then
    AllRecipes["dock_kit"].numtogive = _DockKitNum
end

--------------------------------------------------------------------------
--[[ 码头套装能在非浅海放置 ]]
--------------------------------------------------------------------------

local _DockKitAreaSea = GetModConfigData("DockKitAreaSea")
local _DockKitAreaCave = GetModConfigData("DockKitAreaCave")

if _DockKitAreaSea or _DockKitAreaCave then
    local TileTest = nil
    if _DockKitAreaSea and _DockKitAreaCave then
        TileTest = function(tile)
            return tile == WORLD_TILES.OCEAN_COASTAL_SHORE or tile == WORLD_TILES.OCEAN_COASTAL or
                tile == WORLD_TILES.OCEAN_SWELL or tile == WORLD_TILES.OCEAN_ROUGH or
                tile == WORLD_TILES.OCEAN_BRINEPOOL or tile == WORLD_TILES.OCEAN_BRINEPOOL_SHORE or
                tile == WORLD_TILES.OCEAN_HAZARDOUS or tile == WORLD_TILES.OCEAN_WATERLOG or
                tile == WORLD_TILES.UNDERGROUND or tile == WORLD_TILES.FAKE_GROUND or tile == WORLD_TILES.IMPASSABLE
        end
    elseif _DockKitAreaSea then
        TileTest = function(tile)
            return tile == WORLD_TILES.OCEAN_COASTAL_SHORE or tile == WORLD_TILES.OCEAN_COASTAL or
                tile == WORLD_TILES.OCEAN_SWELL or tile == WORLD_TILES.OCEAN_ROUGH or
                tile == WORLD_TILES.OCEAN_BRINEPOOL or tile == WORLD_TILES.OCEAN_BRINEPOOL_SHORE or
                tile == WORLD_TILES.OCEAN_HAZARDOUS or tile == WORLD_TILES.OCEAN_WATERLOG
        end
    else
        TileTest = function(tile)
            return tile == WORLD_TILES.OCEAN_COASTAL_SHORE or tile == WORLD_TILES.OCEAN_COASTAL or
                tile == WORLD_TILES.UNDERGROUND or tile == WORLD_TILES.FAKE_GROUND or tile == WORLD_TILES.IMPASSABLE
        end
    end

    local function IsDockNearOtherOnOcean(other, pt, min_spacing_sq)
        --FindEntities range check is <=, but we want <
        local min_spacing_sq_resolved = (other.deploy_extra_spacing ~= nil and math.max(other.deploy_extra_spacing * other.deploy_extra_spacing, min_spacing_sq))
            or min_spacing_sq
        local ox, oy, oz = other.Transform:GetWorldPosition()
        return distsq(pt.x, pt.z, ox, oz) < min_spacing_sq_resolved
            and not TheWorld.Map:IsVisualGroundAtPoint(ox, oy, oz)  -- Throw out any tests for anything that's not in the ocean.
    end

    AddPrefabPostInit("dock_kit", function(inst)
        inst._custom_candeploy_fn = function(inst, pt, mouseover, deployer, rotation)
            local tile = TheWorld.Map:GetTileAtPoint(pt.x, 0, pt.z)
            if --这个判断是修改的
                TileTest(tile)
            then
                local tx, ty = TheWorld.Map:GetTileCoordsAtPoint(pt.x, 0, pt.z)
                local found_adjacent_safetile = false
                for x_off = -1, 1, 1 do
                    for y_off = -1, 1, 1 do
                        if (x_off ~= 0 or y_off ~= 0) and IsLandTile(TheWorld.Map:GetTile(tx + x_off, ty + y_off)) then
                            found_adjacent_safetile = true
                            break
                        end
                    end

                    if found_adjacent_safetile then break end
                end

                if found_adjacent_safetile then
                    local pt = Vector3(TheWorld.Map:GetTileCenterPoint(tx, ty))

                    if _DockKitAreaCave then --这里也是修改的：主要是需要避开对洞穴深渊地皮的检查
                        -- TILE_SCALE is the dimension of a tile; 1.0 is the approximate overhang, but we overestimate for safety.
                        local min_distance_from_entities = (TILE_SCALE/2) + 1.2
                        local min_distance_from_boat = min_distance_from_entities + TUNING.MAX_WALKABLE_PLATFORM_RADIUS

                        local boat_entities = TheSim:FindEntities(pt.x, 0, pt.z, min_distance_from_boat, {"walkableplatform"})
                        for _, v in ipairs(boat_entities) do
                            if
                                v.components.walkableplatform ~= nil and
                                math.sqrt(v:GetDistanceSqToPoint(pt.x, 0, pt.z)) <= (v.components.walkableplatform.platform_radius + min_distance_from_entities)
                            then
                                return false
                            end
                        end
                        return (mouseover == nil or mouseover:HasTag("player"))
                            and TheWorld.Map:IsDeployPointClear(pt, nil, min_distance_from_entities, nil, IsDockNearOtherOnOcean)
                    end

                    return TheWorld.Map:CanDeployDockAtPoint(pt, inst, mouseover)
                end
            end

            return false
        end
    end)
end

--------------------------------------------------------------------------
--[[ 码头地皮不会连环崩坏 ]]
--------------------------------------------------------------------------

if GetModConfigData("DockTileBreak") and IsServer then
    AddComponentPostInit("dockmanager", function(self)
        self._TestForBreaking = function(self, ...)
            return false
        end
    end)
end
