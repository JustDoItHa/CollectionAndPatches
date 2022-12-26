STRINGS = GLOBAL.STRINGS
RECIPETABS = GLOBAL.RECIPETABS
Recipe = GLOBAL.Recipe
Ingredient = GLOBAL.Ingredient
TECH = GLOBAL.TECH
DEPLOYSPACING=GLOBAL.DEPLOYSPACING
DEPLOYSPACING_RADIUS=GLOBAL.DEPLOYSPACING_RADIUS
TheSim=GLOBAL.TheSim
PREFAB_SKINS=GLOBAL.PREFAB_SKINS
PREFAB_SKINS_IDS=GLOBAL.PREFAB_SKINS_IDS

--PrefabFiles = {
--    "newboats",
--}

table.insert(PrefabFiles, "newboats")

AddComponentPostInit("boatphysics",function(self,inst)
    self.sizespeedmultiplier=1
    local oaf=self.ApplyForce
    function self:ApplyForce(dir_x, dir_z, force)
        local force=(force and force or 0)*self.sizespeedmultiplier
        oaf(self,dir_x, dir_z, force)
    end
    local oam=self.AddMast
    function self:AddMast(mast)
        mast.sail_force=mast.sail_force*self.sizespeedmultiplier
        oam(self, mast)
    end
end)

AddPrefabPostInit("world",function()
    local WALKABLE_PLATFORM_TAGS={"walkableplatform"}
    GLOBAL.Map.GetPlatformAtPoint=function(self,pos_x,pos_y, pos_z, extra_radius)
        if pos_z == nil then
            pos_z = pos_y
            pos_y = 0
        end
        local entities = TheSim:FindEntities(pos_x, pos_y, pos_z, TUNING.MAX_WALKABLE_PLATFORM_RADIUS*5 + (extra_radius or 0), WALKABLE_PLATFORM_TAGS)
        for i, v in ipairs(entities) do
            if v.components.walkableplatform~=nil and math.sqrt(v:GetDistanceSqToPoint(pos_x, 0, pos_z))<=v.components.walkableplatform.platform_radius then
                return v 
            end
        end
        return nil
    end
    GLOBAL.Map.IsPassableAtPointWithPlatformRadiusBias=function(self,x, y, z, allow_water, exclude_boats, platform_radius_bias, ignore_land_overhang)
        local valid_tile = self:IsAboveGroundAtPoint(x, y, z, allow_water) or ((not ignore_land_overhang) and self:IsVisualGroundAtPoint(x,y,z) or false)
        if not allow_water and not valid_tile then
            if not exclude_boats then
                local entities = TheSim:FindEntities(x, 0, z, TUNING.MAX_WALKABLE_PLATFORM_RADIUS*5 + platform_radius_bias, WALKABLE_PLATFORM_TAGS)
                for i, v in ipairs(entities) do
                    local walkable_platform = v.components.walkableplatform 
                    if walkable_platform~=nil and math.sqrt(v:GetDistanceSqToPoint(x, 0, z))<=(walkable_platform.platform_radius+platform_radius_bias) then
                        local platform_x, platform_y, platform_z = v.Transform:GetWorldPosition()
                        local distance_sq = GLOBAL.VecUtil_LengthSq(x - platform_x, z - platform_z)
                        return distance_sq <= walkable_platform.platform_radius * walkable_platform.platform_radius
                    end
                end
            end
            return false
        end
        return valid_tile
    end
    GLOBAL.Map.CanDeployAtPointInWater=function(self,pt, inst, mouseover, data)
        local tile = self:GetTileAtPoint(pt.x, pt.y, pt.z)
        if tile == GROUND.IMPASSABLE or tile == GROUND.INVALID then
            return false
        end

        -- check if there's a boat in the way
        local min_distance_from_boat = (data and data.boat) or 0
        local radius = (data and data.radius) or 0
        local entities = TheSim:FindEntities(pt.x, 0, pt.z, TUNING.MAX_WALKABLE_PLATFORM_RADIUS*5 + radius + min_distance_from_boat, WALKABLE_PLATFORM_TAGS)
        for i, v in ipairs(entities) do
            if v.components.walkableplatform~=nil and math.sqrt(v:GetDistanceSqToPoint(pt.x, 0, pt.z))<=(v.components.walkableplatform.platform_radius+radius+min_distance_from_boat) then
                return false
            end
        end

        local min_distance_from_land = (data and data.land) or 0

        return (mouseover == nil or mouseover:HasTag("player"))
            and self:IsDeployPointClear(pt, nil, min_distance_from_boat + radius)
            and self:IsSurroundedByWater(pt.x, pt.y, pt.z, min_distance_from_land + radius)
    end
end)

local lastfree=0
for k,v in pairs(DEPLOYSPACING) do 
    if v+1>lastfree then
        lastfree=v+1
    end
end
if lastfree<=7 then
    DEPLOYSPACING.LARGEBOATS=lastfree
    DEPLOYSPACING_RADIUS[DEPLOYSPACING.LARGEBOATS]=8
else
    for k,v in pairs(DEPLOYSPACING) do
        if DEPLOYSPACING_RADIUS[v]>=7 and DEPLOYSPACING_RADIUS[v]<10 then
            DEPLOYSPACING.LARGEBOATS=v
            break
        end
    end
end
--STRINGS
Boats=
{
    small=2,
    large=6,
    giant=8,
}
for j,k in pairs(Boats) do 
    j=string.upper(j)
    STRINGS.RECIPE_DESC["BOAT_ITEM_"..j]=STRINGS.RECIPE_DESC["BOAT_ITEM"]
    STRINGS.NAMES["BOAT_ITEM_"..j]=STRINGS.NAMES["BOAT_ITEM"].." "..string.lower(j)
    for i,v in ipairs(GLOBAL.DST_CHARACTERLIST) do 
        v=(v~="wilson") and string.upper(v) or "GENERIC"
		if STRINGS.CHARACTERS[v] then
			STRINGS.CHARACTERS[v].DESCRIBE["BOAT_ITEM_"..j]=STRINGS.CHARACTERS[v].DESCRIBE["BOAT_ITEM"]
		end
    end
end
--RECIPES
for k,v in pairs(Boats) do 
    --AddRecipe("boat_item_"..k, {Ingredient("boards", v^2/4)}, RECIPETABS.SEAFARING, TECH.SEAFARING_TWO,nil,nil,nil,nil,nil,nil,"boat_item.tex")
	AddRecipe2("boat_item_"..k, {Ingredient("boards", v^2/4)}, TECH.SEAFARING_ONE,{image="boat_item.tex"},{"SEAFARING"})
end

--SKINS
local SKINS=GLOBAL.require("prefabs/skinprefabs")
for k in pairs(Boats) do
	if GetModConfigData("ALLOWSKINS") then
		PREFAB_SKINS["boat_item_"..k]=PREFAB_SKINS["boat_item"]
		PREFAB_SKINS_IDS["boat_item_"..k]=PREFAB_SKINS_IDS["boat_item"]
		
		PREFAB_SKINS["boat_"..k]=PREFAB_SKINS["boat"]
		PREFAB_SKINS_IDS["boat_"..k]=PREFAB_SKINS_IDS["boat"]
	end
	
	GLOBAL["boat_item_"..k.."_init_fn"]=GLOBAL["boat_item_init_fn"]
	GLOBAL["boat_item_"..k.."_clear_fn"]=GLOBAL["boat_item_clear_fn"]
	
	GLOBAL["boat_"..k.."_init_fn"]=GLOBAL["boat_init_fn"]
	GLOBAL["boat_"..k.."_clear_fn"]=GLOBAL["boat_clear_fn"]
end
