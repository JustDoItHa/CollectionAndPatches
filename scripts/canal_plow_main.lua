GLOBAL.setmetatable(
        env, {
            __index = function(t, k)
                return GLOBAL.rawget(GLOBAL, k)
            end
        }
)

TUNING.CANAL_PLOW_DEPLOY_RULE = GetModConfigData("DEPLOY_RULE")

--Assets = {
--    Asset("ATLAS", "images/inventoryimages/canal_plow_item.xml"),
--    Asset("IMAGE", "images/inventoryimages/canal_plow_item.tex")
--}
--
--PrefabFiles = {"canal_plow"}
table.insert(PrefabFiles, "canal_plow")

local old_extra_arrive_dist = ACTIONS.DEPLOY.extra_arrive_dist
ACTIONS.DEPLOY.extra_arrive_dist = function(doer, dest, bufferedaction)
    if dest ~= nil and bufferedaction ~= nil and bufferedaction.invobject ~= nil and bufferedaction.invobject:HasTag("canal_plow_item") then
        return ((bufferedaction.invobject.replica.inventoryitem ~= nil and bufferedaction.invobject.replica.inventoryitem:DeploySpacingRadius()) or 0) + 1.0
    end
    return old_extra_arrive_dist and old_extra_arrive_dist(doer, dest, bufferedaction)
end

STRINGS.ACTIONS.DEPLOY.CANAL_PLOW = "填海造海"
local old_strfn = ACTIONS.DEPLOY.strfn
ACTIONS.DEPLOY.strfn = function(act)
    if act.invobject ~= nil and act.invobject:HasTag("canal_plow_item") then return "CANAL_PLOW" end
    return old_strfn and old_strfn(act)
end

AddRecipe2(
        "canal_plow_item", {
            Ingredient("boards", 2), Ingredient("rope", 2),
            Ingredient("goldnugget", 8)
        }, TECH.SCIENCE_TWO, {
            atlas = "images/inventoryimages/canal_plow_item.xml",
            numtogive = 4
        }, {"TOOLS"}
)

STRINGS.NAMES.CANAL_PLOW = "填海造海道具"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.CANAL_PLOW =
STRINGS.CHARACTERS.WAXWELL.DESCRIBE.FARM_PLOW

STRINGS.NAMES.CANAL_PLOW_ITEM = "填海造海道具"
STRINGS.RECIPE_DESC.CANAL_PLOW_ITEM =
"填海造陆 或者挖陆造海"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.CANAL_PLOW_ITEM = "Fill sea to land or dig land to ocean"