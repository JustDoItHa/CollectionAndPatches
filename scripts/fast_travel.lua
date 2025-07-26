-- 查值时自动查global,增加global的变量或者修改global的变量时还是需要带GLOBAL.
GLOBAL.setmetatable(env, { __index = function(t, k)
    return GLOBAL.rawget(GLOBAL, k)
end, })

local LAN_CN = GetModConfigData("CH_LANG")
if LAN_CN then
    require 'lang/nana_teleport_cn'
else
    require 'lang/nana_teleport_en'
end

-- local require = GLOBAL.require
local TravelScreen = require "screens/travelscreen"

local assets_list = --制作栏图标和物品栏图标(含皮肤)
{
    "teleportation", --物品名
    "t1", --skin name
    "t2",
    "t3",
    "t4",
    "t5",
    "t6",
    "t7",
    "t8",
    "t9",
    "t10",
}
for k, v in pairs(assets_list) do
    table.insert(Assets, Asset("IMAGE", "images/inventoryimages/" .. v .. ".tex"))
    table.insert(Assets, Asset("ATLAS", "images/inventoryimages/" .. v .. ".xml"))
end

table.insert(PrefabFiles, "travelable_classified") --传送功能文件
table.insert(PrefabFiles, "teleportation")--传送木牌

---- 预制物声明
--modimport("scripts/skin/nana_skin_list.lua")

AddMinimapAtlas("images/inventoryimages/teleportation.xml")

-- mod配置参数
local ArrowsignEnable = GetModConfigData("FT_ArrowsignEnable")
local HomesignEnable = GetModConfigData("FT_HomesignEnable")
local NewWoodTravelSignEnable = GetModConfigData("FT_NewWoodTravelSignEnable")
local Ownership = GetModConfigData("FT_Ownership")
local LIGHT_ENABLE = GetModConfigData("FT_LightEnable")
local RESURRECT_ENABLE = GetModConfigData("FT_ResurrectEnable")
GLOBAL.TRAVEL_HUNGER_COST = GetModConfigData("FT_Hunger_Cost")
GLOBAL.TRAVEL_SANITY_COST = GetModConfigData("FT_SanityCost")
GLOBAL.TRAVEL_COUNTDOWN_ENABLE = GetModConfigData("FT_set_wait_second")--延时传送
GLOBAL.TRAVEL_TEXT_ENABLE = GetModConfigData("FT_TextEnable")--显示木牌文字

if not GLOBAL.TRAVEL_COUNTDOWN_ENABLE then
    TUNING.TRAVEL_WAIT_SECOND = 0
elseif type(GLOBAL.TRAVEL_COUNTDOWN_ENABLE) == "number" and GLOBAL.TRAVEL_COUNTDOWN_ENABLE >= 0 then
    TUNING.TRAVEL_WAIT_SECOND = GLOBAL.TRAVEL_COUNTDOWN_ENABLE
else
    TUNING.TRAVEL_WAIT_SECOND = 3
end

local writeables = require("writeables")

local layouttable = {
    prompt = "", -- Unused
    animbank = "ui_board_5x3",
    animbuild = "ui_board_5x3",
    menuoffset = Vector3(6, -70, 0),

    cancelbtn = {
        text = STRINGS.BEEFALONAMING.MENU.CANCEL,
        cb = nil,
        control = CONTROL_CANCEL
    },
    acceptbtn = {
        text = STRINGS.BEEFALONAMING.MENU.ACCEPT,
        cb = nil,
        control = CONTROL_ACCEPT
    },
}

writeables.AddLayout("teleportation", layouttable)


--  小木牌相关功能。添加传送、灯光、作祟复活功能等
local FT_Points = {}
if ArrowsignEnable then
    table.insert(FT_Points, "arrowsign_post")
end
if HomesignEnable then
    table.insert(FT_Points, "homesign")
end
if NewWoodTravelSignEnable then
    table.insert(FT_Points, "teleportation")
end

AddReplicableComponent("travelable")

for k, v in pairs(FT_Points) do
    AddPrefabPostInit(v, function(inst)
        inst:AddComponent("talker")
        inst:AddTag("_travelable")
        if LIGHT_ENABLE then
            inst.entity:AddLight()                               --添加发光组件
            inst.Light:Enable(false)                             --默认关
            inst.Light:SetRadius(1 * 1)                            --发光范围:半径3格地皮
            inst.Light:SetFalloff(0.6)                           --衰减
            inst.Light:SetIntensity(0.85)                        --强度
            --inst.Light:SetColour(0.88, 1, 1)                   --浅灰se
            inst.Light:SetColour(255 / 255, 175 / 255, 0 / 255)  --浅灰se
            inst.Light:EnableClientModulation(false)             --不读取客户端的本地设置
        end

        if not TheWorld.ismastersim then
            --主客机判定:下边的代码为主机独占,上方为主客机共用
            return inst
        end

        inst:RemoveTag("_travelable")
        inst:AddComponent("travelable")
        inst.components.travelable.ownership = Ownership
        if LIGHT_ENABLE then
            local function AutoLight(inst, phase)
                --自动灯光
                if phase == "night" then
                    inst.AnimState:PlayAnimation("idle")
                    inst.Light:Enable(true)                       --夜晚发光
                else
                    inst.AnimState:PlayAnimation("idle")
                    inst.Light:Enable(false)                      --其余时间关闭
                end
            end
            inst:WatchWorldState("phase", AutoLight)          --自动灯光
            AutoLight(inst, TheWorld.state.phase)
        end
        if RESURRECT_ENABLE then
            local function OnHaunt(inst, haunter)
                if haunter:HasTag("playerghost") then
                    haunter:PushEvent("respawnfromghost")

                    -- 在玩家位置生成光源
                    haunter:DoTaskInTime(FRAMES * 70, function()
                        local x, y, z = haunter.Transform:GetWorldPosition()
                        SpawnPrefab("spawnlight_multiplayer").Transform:SetPosition(x, y, z)
                    end)
                    if haunter.net_travel_respawn_light then
                        haunter.net_travel_respawn_light:set(true)
                    end
                    return true
                end
                return false
            end
            inst:AddComponent("hauntable")                       --可闹鬼的,复活用
            inst.components.hauntable.cooldown = TUNING.HAUNT_COOLDOWN_TINY
            inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)
            inst.components.hauntable:SetOnHauntFn(OnHaunt)
        end
    end)
end

if NewWoodTravelSignEnable then
    --注册配方
    AddRecipe2("teleportation", { Ingredient("boards", 1) },
            TECH.SCIENCE_ONE,
            {
                atlas = "images/inventoryimages/teleportation.xml",
                image = "teleportation.tex",
                placer = "teleportation_placer", --放置虚影
                min_spacing = 1, --建筑最小建造间距
            },
            { "LIGHT", "DECOR", "STRUCTURES", "MODS" }
    )
end
-- Mod RPC ------------------------------

AddModRPCHandler("FastTravel", "Travel", function(player, inst, index)
    local travelable = inst.components.travelable
    if travelable ~= nil then
        travelable:Travel(player, index)
    end
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

--AddPrefabPostInit("reskin_tool", function(inst)
--    if not TheWorld.ismastersim then
--        return
--    end
--    local oldSpellFn = inst.components.spellcaster.spell
--    inst.components.spellcaster.spell = function(inst, target, pos, doer)
--        oldSpellFn(inst, target, pos, doer)
--        if target ~= nil then
--            target:DoTaskInTime(FRAMES, function()
--                target:PushEvent("reskinned")
--            end)
--        end
--    end
--end)

---- 预制物声明
--modimport("scripts/skin/nana_skin_list.lua")

table.insert(TUNING.cap_skin_item_list,"teleportation")

table.insert(TUNING.cap_skin_skin_list,{ "teleportation", "t1", STRINGS.NANA_TELEPORT_MFM, "idle" })
table.insert(TUNING.cap_skin_skin_list,{ "teleportation", "t2", STRINGS.NANA_TELEPORT_TYGGJ, "idle" })
table.insert(TUNING.cap_skin_skin_list,{ "teleportation", "t3", STRINGS.NANA_TELEPORT_MSNLB, "idle" })
table.insert(TUNING.cap_skin_skin_list,{ "teleportation", "t4", STRINGS.NANA_TELEPORT_HDT, "idle" })
table.insert(TUNING.cap_skin_skin_list,{ "teleportation", "t5", STRINGS.NANA_TELEPORT_NWSFS, "idle" })
table.insert(TUNING.cap_skin_skin_list,{ "teleportation", "t6", STRINGS.NANA_TELEPORT_KGLXZ, "idle" })
table.insert(TUNING.cap_skin_skin_list,{ "teleportation", "t7", STRINGS.NANA_TELEPORT_T7, "idle" })
table.insert(TUNING.cap_skin_skin_list,{ "teleportation", "t8", STRINGS.NANA_TELEPORT_T8, "idle" })
table.insert(TUNING.cap_skin_skin_list,{ "teleportation", "t9", STRINGS.NANA_TELEPORT_T9, "idle" })
table.insert(TUNING.cap_skin_skin_list,{ "teleportation", "t10", STRINGS.NANA_TELEPORT_T10, "idle" })