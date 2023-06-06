local TheNet = GLOBAL.TheNet
local lang = TheNet:GetDefaultServerLanguage()
local Vector3 = GLOBAL.Vector3
local io = GLOBAL.io

local checkingdays = GetModConfigData("checking_days")
local white_area = GetModConfigData("white_area")
local clean_mode = GetModConfigData("clean_mode")
local tumbleweed_maxnum = GetModConfigData("tumbleweed_maxnum")
local evergreen_maxnum = GetModConfigData("evergreen_maxnum")
local evergreen_sparse_maxnum = GetModConfigData("evergreen_sparse_maxnum")
local deciduoustree_maxnum = GetModConfigData("deciduoustree_maxnum")

local lightbulb = "󰀏"

local whitelist = {
    "book", --奶奶的书(关键词)
    "mooneye", --月眼(关键词)
    -- "saddle",                   --鞍(关键词)
    "powcake", --芝士蛋糕(关键词)
    "waxwelljournal", --老麦的书
    "fireflies", --萤火虫
    "slurper", --啜食者
    "pumpkin_lantern", --南瓜灯
    "bullkelp_beachedroot", --海带
    "driftwood_log", --浮木桩
    "panflute", --排箫
    -- "skeletonhat",              --骨盔
    -- "armorskeleton",            --骨甲
    "thurible", --香炉
    "fossil_piece", --化石碎片
    -- "shadowheart",              --心脏
    "amulet", --生命护符
    "reviver", --救赎之心
    "heatrock", --暖石
    "dug_trap_starfish", --挖起的海星
    "yellowstaff", --唤星法杖
    "opalstaff", --喚月法杖
    "cane", --步行手杖
    "orangestaff", --瞬移手杖
    "glommerfuel", --格罗姆燃料
    "lureplantbulb", --食人花种子
    -- "tentaclespots",            --触手皮
    -- "hivehat",                  --蜂王帽
    -- "tentaclespike",            --狼牙棒
    -- "nightsword",               --影刀
    -- "armor_sanity",             --影甲
    "tacklecontainer", --钓具箱
    "supertacklecontainer", --超级钓具箱
    "singingshell_octave", --贝壳钟(关键词 有3 4 5)
    "atrium_light_moon", --阿比的灯柱
    "nilxin_fox", -- 夜雨团子
}

local blacklist = {
    "twigs", --树枝
    "cutgrass", --割下的草
    "spoiled_food", --腐烂食物
    "houndstooth", --狗牙
    "stinger", --蜂刺
    "bookinfo_myth", --天书
    "shyerrytree1",
    "shyerrytree2",
    "shyerrytree3",
    "shyerrytree4",
    "redpouch_yot_catcoon",
    "dummytarget",
}

local whitetag = {
    "smallcreature", --鸟、兔子、鼹鼠
    "irreplaceable", --可疑的大理石、远古钥匙、眼骨、星空、天体灵球、格罗姆花
    "heavy", --雕像
    "backpack", --背包、小猪包、小偷包
    "bundle", --包裹、礼物
    "deerantler", --鹿角
    "trap", --陷阱、狗牙陷阱、海星

    "personal_possession", --猴子宝藏
}

local halfwhitelist = {
    "tentaclespike", --狼牙棒
    "nightsword", --影刀
    "armor_sanity", --影甲
}

local strongcleanlist = {
    --"tumbleweed",                    --风滚草
    "bookinfo_myth", --天书
    -- "shyerrytree1", --颤栗树
    -- "shyerrytree2", --颤栗树
    -- "shyerrytree3", --颤栗树
    -- "shyerrytree4", --颤栗树
    "redpouch_yot_catcoon",
    -- "alterguardian_phase1",            --天体英雄形态1
    -- "alterguardian_phase2",            --天体英雄形态2
    -- "alterguardian_phase3",            --天体英雄形态3
    -- "alterguardian_phase3dead",        --被击败的天体英雄
    -- "dustmothde", --尘蛾的窝
    -- "malbatross", --邪天翁
}

local cleanmaxnum = { --世界保留数量最大值 堆叠物判断懒得写了 目前按组判断 所以别加可堆叠和可以拿起来的物品

    tumbleweed = { max = checknumber(tumbleweed_maxnum) and tumbleweed_maxnum or -1 },
    evergreen = { max = checknumber(evergreen_maxnum) and evergreen_maxnum or -1 },
    evergreen_sparse = { max = checknumber(evergreen_sparse_maxnum) and evergreen_sparse_maxnum or -1 },
    deciduoustree = { max = checknumber(deciduoustree_maxnum) and deciduoustree_maxnum or -1 },
    shyerrytree1 = { max = 3 }, --颤栗树
    shyerrytree2 = { max = 2 }, --
    shyerrytree3 = { max = 2 }, --
    shyerrytree4 = { max = 3 }, --
    kyno_adai_spider_monkey = { max = 10 }, --
    kyno_adai_wargfant = { max = 10 }, --
    kyno_adai_merm = { max = 20 }, --

}
if GetModConfigData("use_for_tumbleweed") then
    -- table.insert(strongcleanlist, "tumbleweed")--风滚草
    table.insert(strongcleanlist, "alterguardian_phase1")--天体英雄形态1
    table.insert(strongcleanlist, "alterguardian_phase2")--天体英雄形态2
    table.insert(strongcleanlist, "alterguardian_phase3")--天体英雄形态3
    table.insert(strongcleanlist, "alterguardian_phase3dead")--被击败的天体英雄
    table.insert(strongcleanlist, "dustmothden")--尘蛾的窝
    table.insert(strongcleanlist, "dustmoth")--尘蛾的窝
    table.insert(strongcleanlist, "malbatross")--邪天翁
    table.insert(strongcleanlist, "rocky")--石虾
    table.insert(strongcleanlist, "minotaurchest") --华丽的箱子
    table.insert(strongcleanlist, "moonrockseed") --天体宝珠
    table.insert(strongcleanlist, "moon_altar_glass") --天体祭坛底座
    table.insert(strongcleanlist, "moon_altar_seed") --天体祭坛宝珠
    table.insert(strongcleanlist, "moon_altar_idol") --天体祭坛雕像
    table.insert(strongcleanlist, "moon_altar_crown") --天体贡品
    table.insert(strongcleanlist, "moon_altar_icon") --天体圣殿象征
    table.insert(strongcleanlist, "moon_altar_ward") --天体圣殿卫戍
    table.insert(strongcleanlist, "resurrectionstone") --复活台
    table.insert(strongcleanlist, "gift")
    table.insert(strongcleanlist, "mokuangshi")

    table.insert(strongcleanlist, "asparagus_oversized")
    table.insert(strongcleanlist, "carrot_oversized")
    table.insert(strongcleanlist, "corn_oversized")
    table.insert(strongcleanlist, "eggplant_oversized")
    table.insert(strongcleanlist, "garlic_oversized")
    table.insert(strongcleanlist, "onion_oversized")
    table.insert(strongcleanlist, "pepper_oversized")
    table.insert(strongcleanlist, "potato_oversized")
    table.insert(strongcleanlist, "pumpkin_oversized")
    table.insert(strongcleanlist, "tomato_oversized")
    table.insert(strongcleanlist, "dragonfruit_oversized")
    table.insert(strongcleanlist, "durian_oversized")
    table.insert(strongcleanlist, "pomegranate_oversized")
    table.insert(strongcleanlist, "watermelon_oversized")

    table.insert(strongcleanlist, "asparagus_oversized_rotten")
    table.insert(strongcleanlist, "carrot_oversized_rotten")
    table.insert(strongcleanlist, "corn_oversized_rotten")
    table.insert(strongcleanlist, "eggplant_oversized_rotten")
    table.insert(strongcleanlist, "garlic_oversized_rotten")
    table.insert(strongcleanlist, "onion_oversized_rotten")
    table.insert(strongcleanlist, "pepper_oversized_rotten")
    table.insert(strongcleanlist, "potato_oversized_rotten")
    table.insert(strongcleanlist, "pumpkin_oversized_rotten")
    table.insert(strongcleanlist, "tomato_oversized_rotten")
    table.insert(strongcleanlist, "dragonfruit_oversized_rotten")
    table.insert(strongcleanlist, "durian_oversized_rotten")
    table.insert(strongcleanlist, "pomegranate_oversized_rotten")
    table.insert(strongcleanlist, "watermelon_oversized_rotten")

end

if clean_mode == 0 then
    local readtxt, err = io.open(MODROOT .. "/modules/strongclean/whitelist.txt", "r")
    if not err then
        for line in readtxt:lines() do
            line = string.sub(line, 1, -2)
            table.insert(whitelist, line)
            print('Whitelist Add:', line)
        end
    end
else
    local readtxt, err = io.open(MODROOT .. "/modules/strongclean/blacklist.txt", "r")
    if not err then
        for line in readtxt:lines() do
            line = string.sub(line, 1, -2)
            table.insert(blacklist, line)
            print('Blacklist Add:', line)
        end
    end
end

local readtxt2, err2 = io.open(MODROOT .. "/modules/strongclean/strongcleanlist.txt", "r")
if not err2 then
    for line in readtxt2:lines() do
        line = string.sub(line, 1, -2)
        table.insert(strongcleanlist, line)
        print('Strongcleanlist Add:', line)
    end
end

local function isWhitelist(name)
    if name == nil then
        return false
    end
    for k, v in pairs(whitelist) do
        if string.find(name, v) then
            return true
        end
    end
    return false
end

--是否是X判定
local function isX(name, X)
    if name == nil then
        return false
    end
    if not name then
        return false
    end
    if type(name) ~= "string" then
        return false
    end
    if name == X then
        return true
    end
    return false
end

--是否在强力清理名单中
local function isStrongcleanlist(name)
    if name == nil then
        return false
    end
    if not name then
        return false
    end
    if type(name) ~= "string" then
        return false
    end
    for k, v in pairs(strongcleanlist) do
        if name == v then
            return true
        end
    end
    return false
end

local function isBlacklist(name)
    for k, v in pairs(blacklist) do
        if string.find(name, v) then
            return true
        end
    end
    return false
end

local function isWhiteTag(fabs)
    for k, v in pairs(whitetag) do
        if fabs:HasTag(v) then
            return true
        end
    end
    return false
end

local function isHalfWhitelist(fabs)
    for k, v in pairs(halfwhitelist) do
        if string.find(fabs.prefab, v) then
            if fabs.components.finiteuses then
                if fabs.components.finiteuses:GetPercent() < 1 then
                    return true
                end
            end
        end
    end
end

local function isFloat(fabs)
    if fabs.components.floater then
        if fabs.components.floater:IsFloating() and fabs.prefab ~= "driftwood_log" then
            return true
        end
    end
    return false
end

local function WhiteArea(inst)
    if white_area then
        local pos = Vector3(inst.Transform:GetWorldPosition())
        entity_list = TheSim:FindEntities(pos.x, pos.y, pos.z, 4)
        for i, entity in pairs(entity_list) do
            if entity.prefab == "endtable" or entity.prefab == "pirate_stash" then
                -- 茶几 猴子宝藏
                return false
            end
        end
        return true
    else
        for i, entity in pairs(entity_list) do
            if entity.prefab == "pirate_stash" then
                -- 猴子宝藏
                return false
            end
        end
        return true
    end
end

local Removesign = {}

local function Positioncheck(v)
    local x, y, z = v.Transform:GetWorldPosition()
    if Removesign[v] and Removesign[v].x == math.floor(x) and Removesign[v].y == math.floor(y) then
        return true
    else
        v:RemoveTag("RemoveCountOne")
        return false
    end
end

local function DoRemoveX(X)
    local list = {}
    if not GLOBAL.TheShard:IsSecondary() then
        if lang == "zh" then
            TheNet:Announce(lightbulb .. "开始清理" .. lightbulb)
        else
            TheNet:Announce(lightbulb .. "Server Cleaning begin" .. lightbulb)
        end
    end
    for k, v in pairs(GLOBAL.Ents) do
        -- 下面是修改部分，添加了风滚草的清理，同样加标志定时清理
        if isX(v.prefab, X) then
            v:Remove()
            local numm = list[v.name .. "  " .. v.prefab]
            if numm == nil then
                list[v.name .. "  " .. v.prefab] = 1
            else
                numm = numm + 1
                list[v.name .. "  " .. v.prefab] = numm
            end
        end
    end

    --如果list为空就不宣告
    if GLOBAL.next(list) ~= nil then
        for k, v in pairs(list) do
            print("wiped", v, k)
            if not GLOBAL.TheShard:IsSecondary() then
                if lang == "zh" then
                    TheNet:Announce(lightbulb .. "清理发现 " .. v .. " 组/个 " .. k .. lightbulb)
                else
                    TheNet:Announce(lightbulb .. "find " .. v .. k .. lightbulb)
                end
            end
        end
        print("Wiping Done!")
        if not GLOBAL.TheShard:IsSecondary() then
            if lang == "zh" then
                TheNet:Announce(lightbulb .. "服务器清理完毕" .. lightbulb)
            else
                TheNet:Announce(lightbulb .. "Server Cleaning Done" .. lightbulb)
            end
        end
    end
end

local function DoRemove()
    local list = {}
    local Removesign_c = {}
    if not GLOBAL.TheShard:IsSecondary() then
        if lang == "zh" then
            TheNet:Announce(lightbulb .. "开始清理" .. lightbulb)
        else
            TheNet:Announce(lightbulb .. "Server Cleaning begin" .. lightbulb)
        end
    end
    for k, v in pairs(GLOBAL.Ents) do

        if v.components and v.components.inventoryitem and v.components.inventoryitem.owner == nil then
            if (clean_mode == 0 and not isWhitelist(v.prefab) and not isWhiteTag(v))
                    or (clean_mode == 1 and isBlacklist(v.prefab))
                    or isHalfWhitelist(v) or isFloat(v) then
                if WhiteArea(v) then
                    if v:HasTag("RemoveCountOne") and Positioncheck(v) then
                        v:Remove()
                        local numm = list[v.name .. "  " .. v.prefab]
                        if numm == nil then
                            list[v.name .. "  " .. v.prefab] = 1
                        else
                            numm = numm + 1
                            list[v.name .. "  " .. v.prefab] = numm
                        end
                    else
                        v:AddTag("RemoveCountOne")
                        local x, y, z = v.Transform:GetWorldPosition()
                        Removesign_c[v] = { x = math.floor(x), y = math.floor(y) }
                    end
                end
            end
        end
    end
    Removesign = Removesign_c
    --如果list为空就不宣告
    if GLOBAL.next(list) ~= nil then
        for k, v in pairs(list) do
            print("wiped", v, k)
            if not GLOBAL.TheShard:IsSecondary() then
                if lang == "zh" then
                    TheNet:Announce(lightbulb .. "清理发现 " .. v .. " 组/个 " .. k .. lightbulb)
                else
                    TheNet:Announce(lightbulb .. "find " .. v .. k .. lightbulb)
                end
            end
        end
        print("Wiping Done!")
        if not GLOBAL.TheShard:IsSecondary() then
            if lang == "zh" then
                TheNet:Announce(lightbulb .. "服务器清理完毕" .. lightbulb)
            else
                TheNet:Announce(lightbulb .. "Server Cleaning Done" .. lightbulb)
            end
        end
    end
end

local function DoStrongRemove()
    local list = {}
    for k, v in pairs(GLOBAL.Ents) do
        -- 下面是修改部分，添加了风滚草的清理，同样加标志定时清理
        if isStrongcleanlist(v.prefab) then
            if v.components.inventoryitem == nil or (v.components.inventoryitem and v.components.inventoryitem.owner == nil) then
                if v:HasTag("RemoveCountOne") then
                    v:Remove()
                    local numm = list[v.name .. "  " .. v.prefab]
                    if numm == nil then
                        list[v.name .. "  " .. v.prefab] = 1
                    else
                        numm = numm + 1
                        list[v.name .. "  " .. v.prefab] = numm
                    end
                else
                    v:AddTag("RemoveCountOne")
                end
            end
        end
    end

    --如果list为空就不宣告
    if GLOBAL.next(list) ~= nil then
        for k, v in pairs(list) do
            print("wiped", v, k)
            if not GLOBAL.TheShard:IsSecondary() then
                if lang == "zh" then
                    TheNet:Announce(lightbulb .. "强力清理了 " .. v .. " 组/个 " .. k .. lightbulb)
                else
                    TheNet:Announce(lightbulb .. "find " .. v .. k .. lightbulb)
                end
            end
        end
        print("Wiping Done!")
        if not GLOBAL.TheShard:IsSecondary() then
            if lang == "zh" then
                TheNet:Announce(lightbulb .. "服务器清理完毕" .. lightbulb)
            else
                TheNet:Announce(lightbulb .. "Server Cleaning Done" .. lightbulb)
            end
        end
    end
end

local function AutoDoRemove()
    local list = {}
    local countList = {}
    local Removesign_c = {}
    if not GLOBAL.TheShard:IsSecondary() then
        if lang == "zh" then
            TheNet:Announce(lightbulb .. "开始清理" .. lightbulb)
        else
            TheNet:Announce(lightbulb .. "Server Cleaning begin" .. lightbulb)
        end
    end
    local ents_copy = {}
    local ents_num = 0
    for k, v in pairs(Ents) do
        table.insert(ents_copy, v)
        ents_num = ents_num + 1
    end
    if ents_num < 1 then
        return
    end
    for k, v in pairs(ents_copy) do

        local max_clean = false
        local v_prefab = v.prefab
        if v_prefab and cleanmaxnum[v_prefab] then
            if countList[v_prefab] == nil then
                countList[v_prefab] = 1
            else
                countList[v_prefab] = countList[v_prefab] + 1
                if cleanmaxnum[v_prefab].max < countList[v_prefab] and cleanmaxnum[v_prefab].max >= 0 then
                    max_clean = true
                end
            end
        end
        local strong_clean = isStrongcleanlist(v.prefab)
        local inventoryitem_v = v.components.inventoryitem and v.components.inventoryitem.owner == nil
        if v and v:IsValid() and (inventoryitem_v or strong_clean or max_clean) then
            if (clean_mode == 0 and not isWhitelist(v.prefab) and not isWhiteTag(v))
                    or (clean_mode == 1 and isBlacklist(v.prefab))
                    or isHalfWhitelist(v) or isFloat(v) or strong_clean or max_clean then
                if v and v:IsValid() and WhiteArea(v) then
                    if v and v:IsValid() and ((v:HasTag("RemoveCountOne") and (Positioncheck(v) or strong_clean)) or max_clean) then
                        v:Remove()
                        local numm = list[v.name .. "  " .. v.prefab]
                        if numm == nil then
                            list[v.name .. "  " .. v.prefab] = 1
                        else
                            numm = numm + 1
                            list[v.name .. "  " .. v.prefab] = numm
                        end
                        Sleep(math.min(0.01, 60 / ents_num))
                    else
                        v:AddTag("RemoveCountOne")
                        if not strong_clean then
                            local x, y, z = v.Transform:GetWorldPosition()
                            Removesign_c[v] = { x = math.floor(x), y = math.floor(y) }
                        end
                    end
                end
            end
        end

    end
    Removesign = Removesign_c
    --如果list为空就不宣告
    if GLOBAL.next(list) ~= nil then
        for k, v in pairs(list) do
            print("wiped", v, k)
            if not GLOBAL.TheShard:IsSecondary() then
                if lang == "zh" then
                    TheNet:Announce(lightbulb .. "清理发现 " .. v .. " 组/个 " .. k .. lightbulb)
                else
                    TheNet:Announce(lightbulb .. "find " .. v .. k .. lightbulb)
                end
            end
        end
        print("Wiping Done!")
        if not GLOBAL.TheShard:IsSecondary() then
            if lang == "zh" then
                TheNet:Announce(lightbulb .. "服务器清理完毕" .. lightbulb)
            else
                TheNet:Announce(lightbulb .. "Server Cleaning Done" .. lightbulb)
            end
        end
    end
end

-- local function WorldPeriodicRemove(inst)
--  if not GLOBAL.TheWorld:HasTag("cave") and GLOBAL.TheWorld.ismastersim then
--         inst:DoTaskInTime(.5, function(inst)
--          inst:ListenForEvent("cycleschanged", function()
--              local count_days = GLOBAL.TheWorld.state.cycles / checkingdays
--              if math.floor(count_days) == count_days then --默认每20天检查一次
--                     local do_remove = StartThread(function() DoRemove() end)
--                     local do_sremove = StartThread(function() DoStrongRemove() end)
--              end
--          end)
--         end)
--  end
-- end

-- local function CavePeriodicRemove(inst)
--  if GLOBAL.TheWorld:HasTag("cave") and GLOBAL.TheWorld.ismastersim then
--         inst:DoTaskInTime(.5, function(inst)
--          inst:ListenForEvent("cycleschanged", function()
--              local count_days = GLOBAL.TheWorld.state.cycles / checkingdays
--              if math.floor(count_days) == count_days then --默认每20天检查一次
--                     local do_remove = StartThread(function() DoRemove() end)
--                     local do_sremove = StartThread(function() DoStrongRemove() end)
--              end
--          end)
--         end)
--  end
-- end

-- AddPrefabPostInit("forest", WorldPeriodicRemove)
-- AddPrefabPostInit("cave", CavePeriodicRemove)

local function WorldRemove(inst)
    if GLOBAL.TheWorld.ismastersim then
        inst:DoTaskInTime(.5, function(inst)
            inst:ListenForEvent("cycleschanged", function()
                local count_days = GLOBAL.TheWorld.state.cycles / checkingdays
                if math.floor(count_days) == count_days then
                    --默认每20天检查一次
                    local do_remove = StartThread(AutoDoRemove)
                end
            end)
        end)
    end
end

AddPrefabPostInit("world", WorldRemove)

--添加手动清理的功能
GLOBAL.DoRemove = DoRemove
GLOBAL.CLX = DoRemoveX
GLOBAL.DoStrongRemove = DoStrongRemove

--For Boat

if GetModConfigData("boat_clean") then

    local boat_delete_time = GetModConfigData("boat_clean") * 480

    local function starttimer(inst)
        local players = inst.components.walkableplatform:GetEntitiesOnPlatform({ "player" }, nil)
        if #players == 0 then
            inst.components.timer:StartTimer("boatRemoval", boat_delete_time)
            --print("计时器：开始")
        end
    end

    local function stoptimer(inst, obj)
        if obj and obj:HasTag("player") then
            inst.components.timer:StopTimer("boatRemoval")
            --print("计时器：结束")
        end
    end

    local function ontimerdone(inst)
        local players = inst.components.walkableplatform:GetEntitiesOnPlatform({ "player" }, nil)
        if #players == 0 then
            inst:Remove()
            print("计时器：删除船")
        end
    end

    local function BoatAutoRemove(inst)
        if not GLOBAL.TheWorld.ismastersim then
            return inst
        end
        inst:AddComponent("timer")
        inst:ListenForEvent("obj_got_on_platform", stoptimer)
        inst:ListenForEvent("obj_got_off_platform", starttimer)
        inst.components.timer:StartTimer("boatRemoval", boat_delete_time)
        inst:ListenForEvent("timerdone", ontimerdone)
    end

    AddPrefabPostInit("boat", BoatAutoRemove)

end