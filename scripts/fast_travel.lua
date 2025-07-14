-- 使用的mod名称：Fast Travel (GUI)
-- mod链接：https://steamcommunity.com/sharedfiles/filedetails/?id=1530801499
-- mod更新时间：2020.06.17 下午 07:28
-- mod作者：SoraYuki（原作者Isosurface）
-- 修改范围：全汉化并增加传送秒数设置
local require = GLOBAL.require
local TravelScreen = require "screens/travelscreen"

--PrefabFiles = {"travelable_classified"}

local assets_list =  --制作栏图标和物品栏图标(含皮肤)
{
    "teleportation",        --物品名
    "t1", 	--skin name
    "t2",
    "t3",
    "t4",
    "t5",
    "t6",
    "t7",
    "t8",
}
for k,v in pairs (assets_list) do
    table.insert(Assets, Asset( "IMAGE", "images/inventoryimages/"..v..".tex" ))
    table.insert(Assets, Asset( "ATLAS", "images/inventoryimages/"..v..".xml" ))
end

table.insert(PrefabFiles, "travelable_classified")
table.insert(PrefabFiles, "teleportation")

--预制物声明
modimport("scripts/skin/nana_skin_list.lua")
modimport("scripts/skin/lantu.lua")

AddMinimapAtlas("images/inventoryimages/teleportation.xml")


if GetModConfigData("NewWoodTravelSignEnable") then
    --注册配方
    AddRecipe2("teleportation",{Ingredient("boards", 1)},
            TECH.SCIENCE_ONE,
            {
                atlas = "images/inventoryimages/teleportation.xml",
                image = "teleportation.tex",
                placer = "teleportation_placer",    --放置虚影
                min_spacing = 1,             --建筑最小建造间距
            },
            {"LIGHT","DECOR","STRUCTURES","MODS"}
    )
end


local writeables = require("writeables")
writeables.AddLayout("teleportation", {
    prompt = "", -- Unused
    animbank = "ui_board_5x3",
    animbuild = "ui_board_5x3",
    menuoffset = Vector3(6, -70, 0),

    cancelbtn = {
        text = STRINGS.BEEFALONAMING.MENU.CANCEL,
        cb = nil,
        control = CONTROL_CANCEL
    },
    -- middlebtn = {
    -- text = STRINGS.KITCOON_NAMING.MENU_RANDOM,
    -- cb = function(inst, doer, widget)
    -- widget:OverrideText( STRINGS.KITCOON_NAMING.NAMES[math.random(#STRINGS.KITCOON_NAMING.NAMES)] )
    -- end,
    -- control = CONTROL_MENU_MISC_2
    -- },
    acceptbtn = {
        text = STRINGS.BEEFALONAMING.MENU.ACCEPT,
        cb = nil,
        control = CONTROL_ACCEPT
    },
})


local FT_Points = {"teleportation"}

local ArrowsignEnable = GetModConfigData("ArrowsignEnable")
local HomesignEnable = GetModConfigData("HomesignEnable")

local Ownership = GetModConfigData("Ownership")
GLOBAL.TRAVEL_HUNGER_COST = GetModConfigData("Hunger_Cost")
GLOBAL.TRAVEL_SANITY_COST = GetModConfigData("Sanity_Cost")
-- 设置等待时间
GLOBAL.TRAVEL_WAIT_SECOND = GetModConfigData("set_wait_second")

if ArrowsignEnable then table.insert(FT_Points, "arrowsign_post") end

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

if HomesignEnable then
    AddPrefabPostInit("homesign", function(inst)
        inst:AddComponent("talker")
        inst:AddTag("_travelable")
        inst.entity:AddLight()                          --添加发光组件
        inst.Light:Enable(false)                        --默认关
        inst.Light:SetRadius(1*1)                       --发光范围:半径3格地皮
        inst.Light:SetFalloff(0.6)                        --衰减
        inst.Light:SetIntensity(0.85)                   --强度
        inst.Light:SetColour(0.88, 1, 1)                --浅灰se
        inst.Light:EnableClientModulation(false)        --不读取客户端的本地设置

        local function zidonglight(inst, phase)             --自动灯光
            if phase == "night" then
                inst.AnimState:PlayAnimation("idle")
                inst.Light:Enable(true)                       --夜晚发光
            else
                inst.AnimState:PlayAnimation("idle")
                inst.Light:Enable(false)                      --其余时间关闭
            end
        end

        if GLOBAL.TheWorld.ismastersim then
            inst:RemoveTag("_travelable")
            inst:AddComponent("travelable")
            inst.components.travelable.ownership = Ownership
            inst:WatchWorldState("phase", zidonglight)                 --自动灯光
            zidonglight(inst, TheWorld.state.phase)
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

AddAction("DESTINATION_UI", STRINGS.NANA_TELEPORT_DESTINATIONS, function(act)
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

-- Stategraph ----------------------------

AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(
        GLOBAL.ACTIONS.DESTINATION_UI, "give"))
AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(
        GLOBAL.ACTIONS.DESTINATION_UI, "give"))
