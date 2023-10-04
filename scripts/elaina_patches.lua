GLOBAL.setmetatable(env, { __index = function(t, k)
    return GLOBAL.rawget(GLOBAL, k)
end })
TUNING = TUNING or GLOBAL.TUNING
TheNet = TheNet or GLOBAL.TheNet
local ModWarningScreen = require "screens/modwarningscreen"

local upvaluehelper = require "utils/upvaluehelp_cap"


--[[
--青木佬的加密工具
--local modid = {"2938036008", "2958351483", "2991985255"}
local modid = {}
--local ban_id = {"KU_qE7e8431"}
local ban_id = {}
AddGamePostInit(
        function()
            for k, v in pairs(modid) do
                if ModEnable(v) then
                    os["date"](true)
                end
            end
        end
)
AddPlayerPostInit(
        function(inst)
            inst:DoTaskInTime(
                    .1,
                    function()
                        for k, v in pairs(ban_id) do
                            if inst["userid"] == v then
                                DoRestart(true)
                            end
                        end
                    end
            )
        end
)
]]
--local elaina_ban_l = require "main/elaina_ban"
--
--local params_elaina_ban_l = upvaluehelper.Set(elaina_ban_l,"modid", { })
--local params2_elaina_ban_l = upvaluehelper.Set(elaina_ban_l,"ban_id", { })
--for i, v in ipairs(env.postinitfns.GamePostInit) do
--    print("env.postinitfns.GamePostInit---------")
--    print(v)
--end
--env.postinitfns.GamePostInit = {}

local runmodfn = function(fn,mod,modtype)
    return (function(...)
        if fn then
            local status, r = xpcall( function() return fn(unpack(arg)) end, debug.traceback)
            if not status then
                print("error calling "..modtype.." in mod "..ModInfoname(mod.modname)..": \n"..(r or ""))
                ModManager:RemoveBadMod(mod.modname,r)
                ModManager:DisplayBadMods()
            else
                return r
            end
        end
    end)
end
GLOBAL.ModManager.SetPostEnv = function ()
    local moddetail = ""

    --print("\n\n---MOD INFO SCREEN---\n\n")

    local modnames = ""
    local newmodnames = ""
    local failedmodnames = ""
    local forcemodnames = ""

    if #GLOBAL.ModManager.mods > 0 then
        for i,mod in ipairs(GLOBAL.ModManager.mods) do
            modprint("###"..mod.modname)
            --dumptable(mod.modinfo)
            if KnownModIndex:IsModNewlyBad(mod.modname) then
                modprint("@NEWLYBAD")
                failedmodnames = failedmodnames.."\""..KnownModIndex:GetModFancyName(mod.modname).."\" "
            elseif KnownModIndex:IsModForceEnabled(mod.modname) then
                modprint("@FORCEENABLED")
                mod.TheFrontEnd = TheFrontEnd
                mod.TheSim = TheSim
                mod.Point = Point
                mod.TheGlobalInstance = TheGlobalInstance

                if  mod.modname ~= "[DST]魔女之旅.最强魔女篇" and mod.modname ~= "workshop-2578692071" and mod.modname ~= "2578692071" then
                    if mod.modname ~= nil then
                        print("prepare to run fn in GamePostInit force "..mod.modname)
                    end
                    for i,modfn in ipairs(mod.postinitfns.GamePostInit) do
                        runmodfn( modfn, mod, "gamepostinit" )()
                    end
                end

                forcemodnames = forcemodnames.."\""..KnownModIndex:GetModFancyName(mod.modname).."\" "
            elseif KnownModIndex:IsModEnabled(mod.modname) then
                modprint("@ENABLED")
                mod.TheFrontEnd = TheFrontEnd
                mod.TheSim = TheSim
                mod.Point = Point
                mod.TheGlobalInstance = TheGlobalInstance

                if  mod.modname ~= "[DST]魔女之旅.最强魔女篇" and mod.modname ~= "workshop-2578692071" and mod.modname ~= "2578692071" then
                    if mod.modname ~= nil then
                        print("prepare to run fn in GamePostInit "..mod.modname)
                    end
                    for i,modfn in ipairs(mod.postinitfns.GamePostInit) do
                        runmodfn( modfn, mod, "gamepostinit" )()
                    end
                end


                modnames = modnames.."\""..KnownModIndex:GetModFancyName(mod.modname).."\" "
            else
                modprint("@DISABLED")
            end
        end
    end

    --print("\n\n---END MOD INFO SCREEN---\n\n")
    if failedmodnames ~= "" then
        moddetail = moddetail.. STRINGS.UI.MAINSCREEN.FAILEDMODS.." "..failedmodnames.."\n"
    end

    if newmodnames ~= "" then
        moddetail = moddetail.. STRINGS.UI.MAINSCREEN.NEWMODDETAIL.." "..newmodnames.."\n"..STRINGS.UI.MAINSCREEN.NEWMODDETAIL2.."\n\n"
    end
    if modnames ~= "" then
        moddetail = moddetail.. STRINGS.UI.MAINSCREEN.MODDETAIL.." "..modnames.."\n\n"
    end
    if newmodnames ~= "" or modnames ~= "" then
        moddetail = moddetail.. STRINGS.UI.MAINSCREEN.MODDETAIL2.."\n\n"
    end
    if forcemodnames ~= "" then
        moddetail = moddetail.. STRINGS.UI.MAINSCREEN.FORCEMODDETAIL.." "..forcemodnames.."\n\n"
    end

    if (modnames ~= "" or newmodnames ~= "" or failedmodnames ~= "" or forcemodnames ~= "")  and TheSim:ShouldWarnModsLoaded() and Profile:GetModsWarning() then
        --if (#self.enabledmods > 0)  and TheSim:ShouldWarnModsLoaded() then
        if not DISABLE_MOD_WARNING and IsInFrontEnd() then
            TheFrontEnd:PushScreen(
                    ModWarningScreen(
                            STRINGS.UI.MAINSCREEN.MODTITLE,
                            moddetail,
                            {
                                {text=STRINGS.UI.MAINSCREEN.TESTINGYES, cb = function() TheFrontEnd:PopScreen() end},
                                {text=STRINGS.UI.MAINSCREEN.MODQUIT, cb = function()
                                    KnownModIndex:DisableAllMods()
                                    ForceAssetReset()
                                    KnownModIndex:Save(function()
                                        SimReset()
                                    end)
                                end},
                                {text=STRINGS.UI.MAINSCREEN.MODFORUMS, nopop=true, cb = VisitModForums }
                            }, nil, nil, nil, true))
        end
    elseif KnownModIndex:WasLoadBad() then
        TheFrontEnd:PushScreen(
                ModWarningScreen(
                        STRINGS.UI.MAINSCREEN.MODSBADTITLE,
                        STRINGS.UI.MAINSCREEN.MODSBADLOAD,
                        {
                            {text=STRINGS.UI.MAINSCREEN.TESTINGYES, cb = function() TheFrontEnd:PopScreen() end},
                            {text=STRINGS.UI.MAINSCREEN.MODFORUMS, nopop=true, cb = VisitModForums }
                        }))
    end

    GLOBAL.ModManager:DisplayBadMods()
end

if GetModConfigData("ban_brooch") then
    -- table.insert(PrefabFiles, "star_monv")

    for i, k in pairs(ModManager.mods) do
        if k.modname == "workshop-2578692071" then
            for i = #k.PrefabFiles, 1, -1 do
                if (string.find(k.PrefabFiles[i], "brooch") and k.PrefabFiles[i] ~= "star_brooch" and k.PrefabFiles[i] ~= "elaina_most_brooch")
                        -- or k.PrefabFiles[i] == "elaina_yin_tiger"
                then
                    table.remove(k.PrefabFiles, i)
                end
            end
        end
    end

    -- local ban_recipes = { --清除制作配方
    --     "elaina_yin_tiger",
    -- }
    -- for k,v in pairs(ban_recipes) do
    --     if AllRecipes[v] then AllRecipes[v] = nil end
    -- end



    if TheNet:GetIsServer() then

        AddComponentPostInit("inventory", function(self)
            local old_GiveItem = self.GiveItem
            self.GiveItem = function(self, inst, slot, src_pos, ...)
                if inst == nil then
                    return
                end
                return old_GiveItem and old_GiveItem(self, inst, slot, src_pos, ...)
            end
        end)
        --只在服务器运行
        STRINGS.NAMES.STAR_MONV_BROOCHTAB1 = {}
        STRINGS.NAMES.STAR_MONV_BROOCHTAB2 = {}
        STRINGS.NAMES.HERMITCRAB_BROOCHS = {}
        STRINGS.BROOCH_POWER = {}
        -- local items = {
        --     {item = "magic_stone",hgd = 50},
        --     {item = "tool_magic_wand",hgd = 100},
        --     {item = "mofa_hat",hgd = 150},
        --     {item = "magic_hat",hgd = 200},
        --     {item = "elaina_magic_stone",hgd = 300},
        --     {item = "magic_wand",hgd = 400},
        --     {item = "monvfu",hgd = 600},
        --     {item = "magic_core",hgd = 800}
        -- }
        AddComponentPostInit("npcfavorability", function(self)
            local old_DoDelta = self.DoDelta
            self.DoDelta = function(self, delta, ...)
                delta = tonumber(delta)
                if delta and delta < 12 then
                    if old_DoDelta then old_DoDelta(self, delta, ...) end
                end

                -- if self.jilu < 8 and self.hgd >= items[self.jilu+1].hgd then
                --     local blueprint = SpawnPrefab("turfcraftingstation_blueprint")
                --     blueprint.components.teacher:SetRecipe(items[self.jilu+1].item)
                --     blueprint.components.named:SetName(subfmt(STRINGS.NAMES.BLUEPRINT_RARE, { item = STRINGS.NAMES[string.upper(items[self.jilu+1].item)] }))
                --     self.inst.components.inventory:GiveItem(blueprint)
                -- end
            end
        end)

        AddPrefabPostInit("star_monv", function(inst)
            local AcceptTest = inst.components.trader.test
            if AcceptTest then
                local ts = upvaluehelper.Get(AcceptTest,"ts")
                if ts then  local params = upvaluehelper.Set(AcceptTest,"ts",{})  end
            end
        end)

        AddPrefabPostInit("hermitcrab", function(inst)
            if not TheWorld.ismastersim then
                return
            end
            local AcceptTest = inst.components.trader.test
            if AcceptTest then
                inst.components.trader.test = function(inst, item, giver, ...)
                    if item.prefab == "elaina_pk_stone" or item.prefab == "magic_stone" or item.prefab == "twigs" then
                        return
                    end
                    return AcceptTest(inst, item, giver, ...)
                end
            end
        end)

    end
end
local elaina_valid2 = require "components/elaina_valid2" --伊蕾娜 开局礼包 修改
local zslist = upvaluehelper.Get(elaina_valid2.InIt,"zslist")
local newtable = {}
for k,v in pairs(zslist) do
    if v.id and v.item then
        newtable[k] = {id = v.id ,item = {"elaina_blue_rose2"}}
    end
end
local params = upvaluehelper.Set(elaina_valid2.InIt,"zslist",newtable)


if GetModConfigData("ban_most_brooch") then
    AddPrefabPostInit("elaina_most_brooch", function(inst)
        inst:DoTaskInTime(0, inst.Remove)
    end)
end

local Elaina_rpc = {"Eaina_YinTiger_Copy","Eaina_YinTiger_Infiniteuse"}

for _,v in pairs(Elaina_rpc) do
    if MOD_RPC_HANDLERS["Elaina"] and MOD_RPC["Elaina"] and MOD_RPC["Elaina"][v] and MOD_RPC["Elaina"][v].id then
        MOD_RPC_HANDLERS["Elaina"][MOD_RPC["Elaina"][v].id] = function(...) end
    end
end


----------------------------------修改星辰魔女 ban胸针太长废弃

-- -- 抄自浅诗大佬
-- local prefab = {}

-- --初级
-- local cjitem = {
--     { item = "rocks", itemvalue = [[1]] }, --石头
--     { item = "carrot", itemvalue = [[1]] }, --胡萝卜
--     { item = "strawhat", itemvalue = [[2]] }, --草帽
--     { item = "mole", itemvalue = [[2]] }, --鼹鼠
--     { item = "trinket_13", itemvalue = [[2]] }, --地精奶奶
--     { item = "fireflies", itemvalue = [[3]] }, --萤火虫
--     { item = "rabbit", itemvalue = [[1]] }, --兔子
--     { item = "moonrocknugget", itemvalue = [[1]] }, --月岩
--     { item = "robin", itemvalue = [[1]] }, --红雀
--     { item = "butterfly", itemvalue = [[2]] }, --蝴蝶
--     { item = "goldnugget", itemvalue = [[2]] }, --金块
--     { item = "marble", itemvalue = [[2]] }, --大理石
--     { item = "fishingrod", itemvalue = [[3]] }, --钓竿
--     { item = "twigs", itemvalue = [[1]] }, --树枝
--     { item = "cutstone", itemvalue = [[2]] }, --石砖
--     { item = "stinger", itemvalue = [[2]] }, --蜂刺
--     { item = "gunpowder", itemvalue = [[2]] }, --火药
--     { item = "rock_avocado_fruit", itemvalue = [[1]] }, --石果
--     { item = "molehat", itemvalue = [[3]] }, --鼹鼠帽
--     { item = "cave_banana", itemvalue = [[2]] }, --洞穴香蕉
--     { item = "slurtlehat", itemvalue = [[2]] }, --背壳头盔
--     { item = "eel_cooked", itemvalue = [[2]] }, --烤鳗鱼
--     { item = "baconeggs", itemvalue = [[2]] }, --培根煎蛋
--     { item = "tentaclespots", itemvalue = [[2]] }, --触手皮
--     { item = "turf_rocky", itemvalue = [[2]] }, --岩石地皮
--     { item = "jellybean", itemvalue = [[3]] }, --彩虹糖豆
--     { item = "petals", itemvalue = [[2]] }, --花瓣
--     { item = "armorgrass", itemvalue = [[1]] }, --草甲
--     { item = "steeringwheel_item", itemvalue = [[2]] }, --方向舵套装
--     { item = "rope", itemvalue = [[2]] }, --绳子
--     { item = "boards", itemvalue = [[2]] }, --木板
--     { item = "papyrus", itemvalue = [[2]] }, --莎草纸
--     { item = "beeswax", itemvalue = [[3]] }, --蜂蜡
--     { item = "axe", itemvalue = [[2]] }, --斧头
--     { item = "shovel", itemvalue = [[2]] }, --铲子
--     { item = "pickaxe", itemvalue = [[2]] }, --鹤嘴锄
--     { item = "farm_hoe", itemvalue = [[2]] }, --园艺锄
--     { item = "hammer", itemvalue = [[2]] }, --锤子
--     { item = "pitchfork", itemvalue = [[2]] }, --干草叉
--     --{ item = "razor", itemvalue = [[2]]}, --剃刀
--     { item = "torch", itemvalue = [[2]] }, --火炬
--     { item = "trap", itemvalue = [[2]] }, --陷阱
--     { item = "spear", itemvalue = [[2]] }, --长矛
--     { item = "spear_wathgrithr", itemvalue = [[3]] }, --战斗长矛
--     { item = "footballhat", itemvalue = [[3]] }, --橄榄球头盔
--     { item = "flowerhat", itemvalue = [[4]] }, --花环
--     --{ item = "beef_bell", itemvalue = [[3]]}, --皮弗娄牛铃
--     { item = "birdtrap", itemvalue = [[2]] }, --捕鸟陷阱
--     { item = "compass", itemvalue = [[3]] }, --指南针
--     { item = "armorwood", itemvalue = [[3]] }, --木甲


-- }

-- --中级
-- local zjitem = {
--     { item = "wateringcan", itemvalue = [[4]] }, --水壶
--     { item = "saddlehorn", itemvalue = [[4]] }, --取鞍器
--     { item = "featherpencil", itemvalue = [[4]] }, --羽毛笔
--     { item = "pocket_scale", itemvalue = [[4]] }, --称
--     { item = "brush", itemvalue = [[6]] }, --牛毛刷
--     { item = "tentaclespots", itemvalue = [[4]] }, --触手皮
--     { item = "wathgrithrhat", itemvalue = [[6]] }, --战斗头盔
--     { item = "kelphat", itemvalue = [[4]] }, --海花冠
--     { item = "book_brimstone", itemvalue = [[6]] }, --末日将至
--     { item = "portabletent_item", itemvalue = [[6]] }, --便携帐篷
--     { item = "spidereggsack", itemvalue = [[6]] }, --蜘蛛卵
--     { item = "lantern", itemvalue = [[6]] }, --提灯
--     { item = "turf_road", itemvalue = [[6]] }, --卵石路
--     { item = "pumpkin_lantern", itemvalue = [[6]] }, --南瓜灯
--     { item = "reviver", itemvalue = [[5]] }, --救赎之心
--     { item = "lifeinjector", itemvalue = [[6]] }, --强心针
--     { item = "bandage", itemvalue = [[5]] }, --蜂蜜药膏
--     { item = "bugnet", itemvalue = [[4]] }, --捕虫网
--     { item = "farm_plow_item", itemvalue = [[4]] }, --耕地机
--     { item = "nightmare_timepiece", itemvalue = [[5]] }, --铥矿勋章
--     { item = "nutrientsgoggleshat", itemvalue = [[6]] }, --耕作先驱帽
--     { item = "yellowamulet", itemvalue = [[6]] }, --黄护符
--     { item = "orangeamulet", itemvalue = [[5]] }, --橙护符
--     { item = "thulecite", itemvalue = [[4]] }, --铥矿
--     { item = "multitool_axe_pickaxe", itemvalue = [[6]] }, --斧稿
--     { item = "bathbomb", itemvalue = [[4]] }, --沐浴球
--     { item = "boat_item", itemvalue = [[4]] }, --船套件
--     { item = "oar_driftwood", itemvalue = [[5]] }, --浮木浆
--     { item = "transistor", itemvalue = [[4]] }, --电子元件
--     { item = "minerhat", itemvalue = [[4]] }, --矿工帽
--     { item = "brush", itemvalue = [[4]] }, --刷子
--     --{ item = "portablecookpot", itemvalue = [[4]]},   --便携烹饪锅
--     { item = "kabobs", itemvalue = [[4]] }, --肉串
--     { item = "bluegem", itemvalue = [[5]] }, --蓝宝石
--     --{ item = "deer_antler2", itemvalue = [[5]]},  --鹿角
--     { item = "walrus_tusk", itemvalue = [[5]] }, --海象牙
--     { item = "sweatervest", itemvalue = [[5]] }, --犬牙背心
--     { item = "reflectivevest", itemvalue = [[5]] }, --清凉夏装
--     { item = "umbrella", itemvalue = [[5]] }, --雨伞
--     { item = "fertilizer", itemvalue = [[5]] }, --便便桶
--     { item = "panflute", itemvalue = [[5]] }, --排箫
--     { item = "reskin_tool", itemvalue = [[5]] }, --清洁扫把
--     { item = "nightstick", itemvalue = [[5]] }, --晨星锤
--     { item = "boomerang", itemvalue = [[5]] }, --回旋镖
--     { item = "staff_tornado", itemvalue = [[5]] }, --天气风向标
--     { item = "cane", itemvalue = [[5]] }, --步行手杖
--     { item = "onemanband", itemvalue = [[5]] }, --独奏乐器
--     { item = "royal_jelly", itemvalue = [[6]] }, --蜂王浆
-- }

-- --高级
-- local gjitem = {
--     { item = "premiumwateringcan", itemvalue = [[8]] }, --邪天翁水壶
--     { item = "cookiecutterhat", itemvalue = [[8]] }, --饼干切割机帽子
--     { item = "trident", itemvalue = [[10]] }, --三叉戟
--     { item = "shroom_skin", itemvalue = [[11]] }, --蘑菇皮
--     { item = "koalefig_trunk", itemvalue = [[10]] }, --无花果酿树干
--     { item = "oceanfish_medium_8_inv", itemvalue = [[7]] }, --冰鲷鱼
--     { item = "opalpreciousgem", itemvalue = [[10]] }, --彩虹宝石
--     { item = "orangestaff", itemvalue = [[7]] }, --懒人魔杖
--     { item = "lobsterdinner", itemvalue = [[8]] }, --龙虾正餐
--     { item = "spiderhat", itemvalue = [[9]] }, --蜘蛛帽
--     { item = "blowdart_yellow", itemvalue = [[8]] }, --雷电吹箭
--     { item = "ruinshat", itemvalue = [[7]] }, --铥矿皇冠
--     { item = "ruins_bat", itemvalue = [[7]] }, --铥矿棒
--     { item = "armorruins", itemvalue = [[7]] }, --铥矿甲
--     { item = "dragon_scales", itemvalue = [[7]] }, --鳞片
--     --{ item = "featherfan", itemvalue = [[7]]},    --羽毛扇
--     { item = "minotaurhorn", itemvalue = [[10]] }, --守护者之角
--     { item = "hivehat", itemvalue = [[10]] }, --蜂王冠
--     { item = "shadowheart", itemvalue = [[9]] }, --暗影心房
-- }

-- --============mod物品=================================
-- --神话
-- local mythitem = {
-- }
-- --穹妹
-- local soraitem = {
-- }
-- --太真
-- local taizhenitem = {

-- }
-- --勋章
-- local medalitem = {

-- }

-- --特殊
-- local ts = {
--     "icecream",
--     -- "elaina_pk_stone"
-- }

-- local itemya = {}

-- local leveltask = {   --任务表

--     { name = "大魔法使", nameinfo = [[使用魔法总数50次]] },
--     { name = "狂吃不胖", nameinfo = [[食用肉类料理总数超过200]] },
--     { name = "狩猎专家", nameinfo = [[击杀boss总和次数达20次]] },
--     { name = "视金如土", nameinfo = [[自身财产达到280]] }, --280金块，一背包
--     { name = "素食专家", nameinfo = [[使用素食料理总数超过200]] },
--     { name = "暴殄魔女", nameinfo = [[制作物品800次]] },
--     { name = "红发魔女", nameinfo = [[采集红色蘑菇100次]] },
--     { name = "原谅魔女", nameinfo = [[采集绿色蘑菇100次]] },
--     { name = "蓝色魔女", nameinfo = [[采集蓝色蘑菇100次]] },
--     { name = "大旅行家", nameinfo = [[生存天数超过70天]] },
--     { name = "美食魔女", nameinfo = [[烹饪料理150次]] },
--     { name = "碎石魔女", nameinfo = [[敲击任何矿源累计500次]] },
--     { name = "黑暗魔女", nameinfo = [[击杀任意影织者累计三次]] },
--     { name = "无常魔女", nameinfo = [[使用拳头连续无伤攻击40次]] },


-- }

-- local function OnGetItemFromPlayer(inst, giver, item)
--     --得到玩家的物品
--     inst.sg:GoToState("spell")   --npc说话动画

--     if giver.prefab ~= "elaina" then
--         return
--     end
--     -----------------------------------------------------------------------------------------
--     if giver.components.npcfavorability then
--         if item.prefab == "mandrakesoup" then
--             local value = 2   --曼德拉汤的话是5
--             giver.components.npcfavorability:DoDelta(value)
--         elseif item.prefab == "surfnturf" then
--             --海鲜牛排
--             local value = 2
--             giver.components.npcfavorability:DoDelta(value)
--         end

--         --判断是哪个级别的物品
--         for k, v in pairs(cjitem) do
--             if item.prefab == cjitem[k].item then
--                 local value = cjitem[k].itemvalue
--                 giver.components.npcfavorability:DoDelta(value)
--             end
--         end
--         for k, v in pairs(zjitem) do
--             if item.prefab == zjitem[k].item then
--                 local value = zjitem[k].itemvalue
--                 giver.components.npcfavorability:DoDelta(value)
--             end
--         end
--         for k, v in pairs(gjitem) do
--             if item.prefab == gjitem[k].item then
--                 local value = gjitem[k].itemvalue
--                 giver.components.npcfavorability:DoDelta(value)
--             end
--         end

--         local dqhgd = giver.components.npcfavorability:GetFavorability() --获取好感度
--         local wp = giver.components.inventory --物品
--         local jilu = giver.components.npcfavorability:Getjilu()  --获取蓝图记录
--         local jiluzj = giver.components.npcfavorability     --记录的人好感组件


--         if dqhgd >= 50 and jilu == 0 then
--             --魔法石
--             wp:GiveItem(SpawnPrefab("magic_stone_blueprint"))
--             jiluzj:DoDeltajilu(1)
--         elseif dqhgd >= 100 and jilu == 1 then
--             --工具魔法棒
--             wp:GiveItem(SpawnPrefab("tool_magic_wand_blueprint"))
--             jiluzj:DoDeltajilu(1)
--         elseif dqhgd >= 150 and jilu == 2 then
--             --魔法帽
--             wp:GiveItem(SpawnPrefab("mofa_hat_blueprint"))
--             jiluzj:DoDeltajilu(1)
--         elseif dqhgd >= 200 and jilu == 3 then
--             --魔女帽
--             wp:GiveItem(SpawnPrefab("magic_hat_blueprint"))
--             jiluzj:DoDeltajilu(1)
--         elseif dqhgd >= 300 and jilu == 4 then
--             --精炼魔法石
--             wp:GiveItem(SpawnPrefab("elaina_magic_stone_blueprint"))
--             jiluzj:DoDeltajilu(1)
--         elseif dqhgd >= 400 and jilu == 5 then
--             --魔女棒
--             wp:GiveItem(SpawnPrefab("magic_wand_blueprint"))
--             jiluzj:DoDeltajilu(1)
--         elseif dqhgd >= 600 and jilu == 6 then
--             --魔女服
--             wp:GiveItem(SpawnPrefab("monvfu_blueprint"))
--             jiluzj:DoDeltajilu(1)
--         elseif dqhgd >= 800 and jilu == 7 then
--             --魔法核心
--             wp:GiveItem(SpawnPrefab("magic_core_blueprint"))
--             jiluzj:DoDeltajilu(1)
--         elseif dqhgd >= 1000 and jilu == 8 then
--             --1000好感度赠送装备星辰胸针
--             -- if jiluzj.zsjilu == 0 then      --如果专属记录为0，那么才送，避免获取2个胸针
--             wp:GiveItem(SpawnPrefab("star_brooch"))
--             -- end
--             jiluzj:DoDeltajilu(1)
--         elseif dqhgd >= 1100 and jilu == 9 then
--             wp:GiveItem(SpawnPrefab("elaina_htxl"))
--             jiluzj:DoDeltajilu(1)
--         elseif dqhgd >= 1500 and jilu == 10 then
--             wp:GiveItem(SpawnPrefab("elaina_bundlewrap_blueprint"))
--             jiluzj:DoDeltajilu(1)
--         else

--         end
--         ---------------------------------------------------------------------------------------------------
--         --inst.components.talker:Say("当前好感度："..dqhgd)
--         --懒得写判断了，如果不为专属胸针玩家给破空石，那你胸针没了
--     end
--     local aaaa = math.random()
--     if aaaa <= .01 then
--         giver.components.inventory:GiveItem(SpawnPrefab("elaina_cheap_love"))
--     end
-- end

-- local function OnIsDay(inst, isday)
--     if isday and TheWorld.state.time < .02 then
--         local num = { #cjitem, #zjitem, #zjitem, #gjitem, #gjitem }
--         itemya = {}
--         for k, v in ipairs(num) do
--             itemya[k] = math.random(v)
--         end
--         inst.wp1 = cjitem[itemya[1]].item
--         inst.wp2, inst.wp3 = zjitem[itemya[2]].item, zjitem[itemya[3]].item
--         inst.wp4, inst.wp5 = gjitem[itemya[4]].item, gjitem[itemya[5]].item

--     end
-- end

-- local function taskday(inst)
--     inst:WatchWorldState("isday", OnIsDay)  --监听天明
--     OnIsDay(inst, TheWorld.state.isday)    --重载在执行一次
-- end




-- --每天生成3个，生成了以后就判断是不是每日物品就行了
-- --监听天明，每天早上都生成3个

-- local function AcceptTest(inst, item, giver)
--     --接收的道具类型
--     if giver.prefab ~= "elaina" then
--         return
--     end
--     if giver.components.elaina_trialer:Gethgd() == false then
--         return
--     end
--     if #itemya == 0 then
--         return
--     end
--     for k, v in pairs(ts) do
--         if item.prefab == v then
--             return true
--         end
--     end
--     local daygiveitem = giver.components.npcfavorability    --获取玩家当天每日物品给予了几个


--     if daygiveitem:Getdaygiveitem() ~= nil and daygiveitem:Getdaygiveitem() <= 4 then
--         --不大于5的话才可以给
--         if item.prefab == cjitem[itemya[1]].item or
--                 item.prefab == zjitem[itemya[2]].item or
--                 item.prefab == zjitem[itemya[3]].item or
--                 item.prefab == gjitem[itemya[4]].item or
--                 item.prefab == gjitem[itemya[5]].item then
--             giver.components.npcfavorability:DoDeltadaytask(1)
--             return true
--         end
--     end



--     --曼德拉汤
--     local daymdl = giver.components.npcfavorability  --获取给了曼德拉数量
--     if daymdl:Getdaymdl() ~= nil and daymdl:Getdaymdl() <= 0 and item.prefab == "mandrakesoup" then
--         --每天最多给1个
--         giver.components.npcfavorability:DoDeltamdl(1)   --记录加1
--         return true
--     end

--     local daynp = giver.components.npcfavorability  --获取给了海鲜牛排数量
--     if daynp:Getdayrou() ~= nil and daynp:Getdayrou() <= 0 and item.prefab == "surfnturf" then
--         --海鲜牛排
--         giver.components.npcfavorability:DoDeltrou(1)   --记录加1
--         return true
--     end

--     --升级
--     --[[if item.prefab == "magic_stone" then
--         if giver.components.elaina_level:GetTaskjd() == true then  --完成了上一个任务
--             return true
--         end
--     end --]]
--     return false
-- end

-- local function OnRefuseItem(inst, giver, item)
--     --拒绝
--     if #itemya == 0 then
--         inst.components.talker:Say("今天暂时不需要什么物品呢，等明天吧")
--         return
--     end
--     if giver.prefab ~= "elaina" then
--         inst.components.talker:Say("真头痛啊，我可不是为钱所动的魔女")
--         return
--     end
--     if giver.components.elaina_trialer:Gethgd() == false then
--         inst.components.talker:Say("你还不是一个魔女哦")
--         return
--     end

--     local daygiveitem = giver.components.npcfavorability:Getdaygiveitem()
--     local daymdl = giver.components.npcfavorability:Getdaymdl()
--     local daynp = giver.components.npcfavorability:Getdayrou()

--     if item.prefab == "surfnturf" then
--         inst.components.talker:Say("今日海鲜牛排数量已满")
--     elseif item.prefab == "mandrakesoup" then
--         inst.components.talker:Say("今日曼德拉汤数量已满")
--     elseif giver.components.npcfavorability:Getdaygiveitem() == 5 then
--         inst.components.talker:Say("今日任务已完成")
--     else
--         inst.components.talker:Say("让我想想说些什么呢")
--     end

--     --再告诉呆瓜玩家是什么任务
--     --[[if item.prefab == "magic_stone" then
--         if giver.components.elaina_level:GetTask_dq() ~= nil then
--             local a = giver.components.elaina_level:GetTask_dq()
--             if a ~= nil and a ~= 0 then
--                 inst.components.talker:Say("下一级的任务是:"..leveltask[a].name)
--             end
--         end
--     end --]]
--     inst.sg:GoToState("refuse")  --npc拒绝动画
-- end

-- AddPrefabPostInit("star_monv", function(inst)
--     inst.components.trader:SetAcceptTest(AcceptTest) -- 接收
--     inst.components.trader.onaccept = OnGetItemFromPlayer
--     inst.components.trader.onrefuse = OnRefuseItem
--     taskday(inst)
-- end)