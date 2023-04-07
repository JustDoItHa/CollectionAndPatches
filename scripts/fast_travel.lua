-- 使用的mod名称：Fast Travel (GUI)
-- mod链接：https://steamcommunity.com/sharedfiles/filedetails/?id=1530801499
-- mod更新时间：2020.06.17 下午 07:28
-- mod作者：SoraYuki（原作者Isosurface）
-- 修改范围：全汉化并增加传送秒数设置
local require = GLOBAL.require
local TravelScreen = require "screens/travelscreen"

--PrefabFiles = {"travelable_classified"}

table.insert(PrefabFiles, "travelable_classified")

local Ownership = GetModConfigData("Ownership")
GLOBAL.TRAVEL_HUNGER_COST = GetModConfigData("Hunger_Cost")
GLOBAL.TRAVEL_SANITY_COST = GetModConfigData("Sanity_Cost")
-- 设置等待时间
GLOBAL.TRAVEL_WAIT_SECOND = GetModConfigData("set_wait_second")

local FT_Points = {"homesign"}

AddReplicableComponent("travelable")
for k, v in pairs(FT_Points) do
    AddPrefabPostInit(v, function(inst)
        inst:AddComponent("talker")
        inst:AddTag("_travelable")
        if GLOBAL.TheWorld.ismastersim then
            inst:RemoveTag("_travelable")
            inst:AddComponent("travelable")
            inst.components.travelable.ownership = Ownership
        end
    end)
end

-- Mod RPC ------------------------------
AddModRPCHandler("FastTravel", "Travel", function(player, inst, index)
    local travelable = inst.components.travelable
    if travelable ~= nil then travelable:Travel(player, index) end
end)

-- PlayerHud UI -------------------------

AddClassPostConstruct("screens/playerhud", function(self, anim, owner)
    self.ShowTravelScreen = function(_, attach)
        if attach == nil then
            return
        else
            self.travelscreen = TravelScreen(self.owner, attach)
            self:OpenScreenUnderPause(self.travelscreen)
            return self.travelscreen
        end
    end

    self.CloseTravelScreen = function(_)
        if self.travelscreen then
            self.travelscreen:Close()
            self.travelscreen = nil
        end
    end
end)

-- Actions ------------------------------

AddAction("DESTINATION_UI", "右键选择目的地", function(act)
    if act.doer ~= nil and act.target ~= nil and act.doer:HasTag("player") and
        act.target.components.travelable and not act.target:HasTag("burnt") and
        not act.target:HasTag("fire") then
        act.target.components.travelable:BeginTravel(act.doer)
        return true
    end
end)
GLOBAL.ACTIONS.DESTINATION_UI.priority = 1

-- Component actions ---------------------

AddComponentAction("SCENE", "travelable", function(inst, doer, actions, right)
    if right then
        if not inst:HasTag("burnt") and not inst:HasTag("fire") then
            table.insert(actions, GLOBAL.ACTIONS.DESTINATION_UI)
        end
    end
end)

-- AddComponentPostInit("travelable")
-- Stategraph ----------------------------

AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(
                               GLOBAL.ACTIONS.DESTINATION_UI, "give"))
AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(
                               GLOBAL.ACTIONS.DESTINATION_UI, "give"))