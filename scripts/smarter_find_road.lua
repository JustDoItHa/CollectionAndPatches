GLOBAL.setmetatable(env, {__index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end})

-- pathcaps :{
--player = true(just for test),
--ignorecreep = true,
--ignorewalls = true,
--ignoreLand = true,
--allowocean = true,
--}

-- walkable of one point(ground, creep, walls)
local function IsWalkablePoint(point, pathcaps)
    pathcaps = pathcaps or {allowocean = false, ignoreLand = false, ignorewalls = false, ignorecreep = false}

    -- check ocean and Land
    if not pathcaps.allowocean or pathcaps.ignoreLand then
        local is_onland = TheWorld.Map:IsVisualGroundAtPoint(point.x, 0, point.z)
        if not pathcaps.allowocean and not is_onland then -- not allow ocean but actually on ocean
            return false
        end
        if pathcaps.ignoreLand and is_onland then -- not allow land but actually on land
            return false
        end
    end
    -- -- check the creep
    -- if not pathcaps.ignorecreep then
    -- local is_oncreep = TheWorld.GroundCreep:OnCreep(point.x, 0, point.z)
    -- if is_oncreep then
    -- return false
    -- end
    -- end
    -- -- check the walls
    -- if not pathcaps.ignorewalls then
    -- local has_wall = TheWorld.Pathfinder:HasWall(point.x, 0, point.z)
    -- if has_wall then
    -- return false
    -- end
    -- end


    return true
end

local INVALID_SEARCH_HANDLES = {}
local _SubmitSearch = Pathfinder.SubmitSearch
function Pathfinder:SubmitSearch(x1, y1, z1, x2, y2, z2, pathcaps, ...)
    local handle = _SubmitSearch(self, x1, y1, z1, x2, y2, z2, pathcaps, ...)
    if not (IsWalkablePoint(Vector3(x1, y1, z1), pathcaps) and IsWalkablePoint(Vector3(x2, y2, z2), pathcaps)) then
        INVALID_SEARCH_HANDLES[tostring(handle)] = true
    end
    return handle
end

local _GetSearchStatus = Pathfinder.GetSearchStatus
local STATUS_CALCULATING = 0
local STATUS_FOUNDPATH = 1
local STATUS_NOPATH = 2
function Pathfinder:GetSearchStatus(handle, ...)
    if INVALID_SEARCH_HANDLES[tostring(handle)] then
        INVALID_SEARCH_HANDLES[tostring(handle)] = false
        return STATUS_NOPATH
    end
    return _GetSearchStatus(self, handle, ...)
end