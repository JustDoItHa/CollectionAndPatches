GLOBAL.setmetatable(env, { __index = function(t, k)
    return GLOBAL.rawget(GLOBAL, k)
end })
TUNING = TUNING or GLOBAL.TUNING
TheNet = TheNet or GLOBAL.TheNet
--检测服务器mod是否开启
local function modenable(name)
    local moddir = KnownModIndex:GetModsToLoad(true)
    local enablemods = {}

    for k, dir in pairs(moddir) do
        --遍历mod的加载列表
        local info = KnownModIndex:GetModInfo(dir)
        local name = info and info.name or "unknow"
        enablemods[dir] = name   --把mod名字存在表里
    end
    if type(name) == "table" then
        for j, s in pairs(name) do
            for k, v in pairs(enablemods) do
                if v and (k:match(s) or v:match(s)) then
                    return true
                end
            end
        end
    elseif type(name) == "string" then
        for k, v in pairs(enablemods) do
            if v and (k:match(name) or v:match(name)) then
                return true
            end
        end
    end

    return false
end
--- 抄的
function keepNDecimalPlaces(decimal, n)
    -----------------------四舍五入保留n位小数的代码
    if type(decimal) ~= "number" then
        print('四舍五入错误', decimal)
        return
    end
    n = n or 0
    local h = math.pow(10, n)
    decimal = math.floor((decimal * h) + 0.5) / h
    return decimal
end
GLOBAL.keepNDecimalPlaces = keepNDecimalPlaces

PrefabFiles = {}
Assets = {}
------加载资源
--modimport("scripts/mod_assets.lua")

local max_player_num = GetModConfigData("max_player_num") or 0

-- 服务器人数
if max_player_num > 0 then
    TheNet:SetDefaultMaxPlayers(max_player_num)
end

modimport("scripts/limit_vote.lua")

-- [TUNING -- big bag]--------------------
TUNING.ROOMCAR_BIGBAG_BAGSIZE = GetModConfigData("BAGSIZE")
TUNING.ROOMCAR_BIGBAG_LANG = GetModConfigData("BIG_BAG_LANG")
--TUNING.ROOMCAR_BIGBAG_GIVE = GetModConfigData("GIVE")
TUNING.ROOMCAR_BIGBAG_STACK = GetModConfigData("BIG_BAG_STACK")
TUNING.ROOMCAR_BIGBAG_FRESH = GetModConfigData("BIG_BAG_FRESH")
TUNING.ROOMCAR_BIGBAG_KEEPFRESH = GetModConfigData("KEEPFRESH")
TUNING.ROOMCAR_BIGBAG_LIGHT = GetModConfigData("LIGHT")
TUNING.ROOMCAR_BIGBAG_RECIPE = GetModConfigData("RECIPE")
TUNING.ROOMCAR_BIGBAG_WALKSPEED = GetModConfigData("WALKSPEED")
TUNING.ROOMCAR_BIGBAG_CONTAINERDRAG_SWITCH = GetModConfigData("CONTAINERDRAG_SWITCH")
TUNING.ROOMCAR_BIGBAG_BAGINBAG = GetModConfigData("BAGINBAG")
TUNING.ROOMCAR_BIGBAG_HEATROCKTEMPERATURE = GetModConfigData("HEATROCKTEMPERATURE")
TUNING.ROOMCAR_BIGBAG_WATER = GetModConfigData("BIGBAGWATER")
TUNING.ROOMCAR_BIGBAG_PICK = GetModConfigData("BIGBAGPICK")
TUNING.NICE_BIGBAGSIZE = GetModConfigData("NICEBIGBAGSIZE")
TUNING.CATBACK_BIGBAGSIZE = GetModConfigData("CATBIGBAGSIZE")
TUNING.OPTIMISE_ANNOUNCEMENT = GetModConfigData("optimiseAnnouncement")
-- [TUNING -- big bag end]--------------------
TUNING.FUNCTIONAL_MEDAL_ENABLE = modenable({ "1909182187", "能力勋章", "Functional Medal" })
TUNING.YEYU_NILXIN_ENABLE = modenable({ "2736985627", "2626800998", "夜雨心空" })
TUNING.QIONG_ENABLE = modenable({ "1638724235", "小穹" })
TUNING.YEYU_NILXIN_XIUXIAN_ENABLE = modenable({ "2736985627", "2626800998", "夜雨心空" }) and modenable("修仙世界额外")
TUNING.ELAINA_ENABLE = modenable({ "2578692071", "魔女之旅" })
TUNING.SORA_ENABLE = modenable("1638724235")
TUNING.ARIA_CRYSTAL_ENABLE = modenable({ "2418617371", "Aria Crystal", "Aria Crystal", "Aria", "艾丽娅", "艾丽娅·克莉丝塔露" })
TUNING.UI_DRAGGABLE_ENABLE = modenable({ "2885137047", "UI拖拽缩放" })
TUNING.QIHUANJIANGLIN_ENABLE = modenable({ "2867435690", "2790273347", "奇幻降临：永恒终焉", "永恒终焉" }) or modenable({ "2898657309", "2958351483", "奇幻降临：第四人称", "第四人称" }) or modenable({ "2965155245", "第四人称：主线重载", "第四人称" })
TUNING.HEAP_OF_FOOD_ENABLE = modenable({ "2334209327", "Heap of Foods" })
TUNING.INTERESTING_TUMBLEWEED_ENABLE = modenable({ "1944492666", "Interesting Tumbleweed" }) or modenable({ "3009509015", "Interesting Tumbleweed" })
TUNING.MAUSER_RIFLE_BAYONET_ENABLE = modenable({ "955048205", "Mauser Rifle & Bayonet" })
TUNING.LEGION_ENABLE = modenable({ "1392778117", "legion", "Legion-棱镜" })
TUNING.SUCCULENT_PLANT_ENABLE = modenable({ "2441790846", "Succulent plant", "多肉植物" })
TUNING.NDNR_ENABLE = modenable({ "2823458540", "富贵险中求", "ndnr", "富贵险中求(No Danger No Rich)" })
TUNING.ARIA_ENABLE = modenable({ "2418617371", "艾丽娅·克莉丝塔露（重置版）" })
TUNING.SIMPLE_ECONOMY_FOR_RX = modenable({ "2846621983", "简单经济学(改专用)" })
TUNING.AOLAI_MYTH = modenable({ "3014738585", "神话：傲来神仙境" })
TUNING.CHERRY_FOREST_ENABLE = modenable({ "1289779251", "Cherry Forest" })
-----------------------------
TUNING.DEATH_COUNTER_SHOW_TITLE = GetModConfigData("death_counter_show_title")
---限制打包物品
TUNING.CANT_PACK_ITEMS = {
    multiplayer_portal = true, --天体门
    pigking = true, --猪王
    antlion = true, --蚁狮
    crabking = true, --帝王蟹
    beequeenhivegrown = true, --蜂王窝-底座
    statueglommer = true, --格罗姆雕像
    oasislake = true, --绿洲
    archive_switch = true, --档案馆华丽的基座
    archive_portal = true, --档案馆传送门
    archive_lockbox_dispencer = true, --知识饮水器
    archive_centipede = true, --远古哨兵蜈蚣
    archive_centipede_husk = true, --远古哨兵壳
    atrium_gate = true, --远古大门
    monkeyqueen = true, --月亮码头女王
    monkeyisland_portal = true, --非自然传送门
    toadstool_cap = true, --毒菌蟾蜍蘑菇
    elecourmaline = true, --电器台
    elecourmaline_keystone = true, --
    moondungeon = true, --月的地下城
    siving_thetree = true, --子圭神木岩
    myth_rhino_desk = true, --三犀牛台
    myth_chang_e = true, --嫦娥
    myth_store = true, --小店
    myth_store_construction = true, --未完成的小店
    myth_shop = true, --小店
    myth_shop_animals = true,
    myth_shop_foods = true,
    myth_shop_ingredient = true,
    myth_shop_numerology = true,
    myth_shop_plants = true,
    myth_shop_rareitem = true,
    myth_shop_weapons = true,
    medal_spacetime_devourer = true, --时空吞噬者
    star_monv = true, --星辰魔女
    elaina_npc_qp = true, --星辰魔女对话框
    ntex_other_lz = true, --逆天而行修仙龙柱
    garden_entrance = true, --糖果屋
    garden_entrance1 = true, --糖果屋
    garden_exit = true, --糖果屋
    garden_exit1 = true, --糖果屋
    lg_shop_wanju = true, --海洋传说商店
    lg_shop_rain = true, --海洋传说商店
    lg_shop_thing = true, --海洋传说商店
    lg_shop_food = true, --海洋传说商店
    lg_shop_cloth = true, --海洋传说商店
    catbag = true,
    catbigbag = true,
    saddle_baggage = true,
}

function testCantPackItem(target, forbidTable)
    local prefab = target.prefab
    if type(forbidTable) == "table" and next(forbidTable) then
        if target:HasTag("multiplayer_portal") or target:HasTag("garden_exit") or target:HasTag("myth_door") or target:HasTag("hua_door")
                or target.components.health or forbidTable[prefab]
        then
            return true
        end
    end
    return false
end

--修复标签问题
if GetModConfigData("beta_function_switch") and GetModConfigData("fix_tags_overflow_switch") then
    -- modimport("scripts/tags_for_additional.lua")
    --引用风铃code
    modimport("scripts/moretags.lua")
    -- for k, v in pairs(additional_tags_to_fix) do
    --     RegTag(v)
    -- end
end

-- 鼠标滚轮控制拿起的物品的数量
if GetModConfigData("change_stack_num_by_mousewheel_switch") then
    modimport("scripts/change_stack_num_by_mousewheel.lua")
end
-- 一键挂机
if GetModConfigData("invincible_status_switch") then
    modimport("scripts/invincible_status_main.lua")
end

-- 死亡不掉落
if GetModConfigData("dont_drop") == true then
    modimport("scripts/dont_drop.lua")
end

-- 五格装备栏
if GetModConfigData("extra_equip_slots") == true then
    modimport("modules/extra_equip_slots/main.lua")
end

-- 二本垃圾清理
if GetModConfigData("clean_garbage") == true then
    modimport("scripts/clean_garbage.lua")
end

-- 掉落堆叠范围
if GetModConfigData("auto_stack_range") > 0 then
    modimport("scripts/drop_stack.lua")
end

-- 物品堆叠数量、更多物品可堆叠
if GetModConfigData("stack_size") > 0 then
    modimport("scripts/stack_size.lua")
end

---- 帐篷耐久
--if GetModConfigData("tent_uses") > 0 then
--    TUNING.TENT_USES = GetModConfigData("tent_uses")
--end
--
---- 木棚耐久
--if GetModConfigData("siesta_canopy_uses") > 0 then
--    TUNING.SIESTA_CANOPY_USES = GetModConfigData("siesta_canopy_uses")
--end
-- 木棚耐久
if GetModConfigData("sleeping_buff_switch") then
    modimport("scripts/sleeping_buff_main.lua")
end

-- 死亡次数累计
if GetModConfigData("death_counter_switch") then
    modimport("scripts/death_counter_main.lua")
end

--隐藏管理员
if GetModConfigData("hide_admin_switch") then
    modimport("scripts/hide_admin.lua")
end
--宣告优化
modimport("scripts/optimise_announcement.lua")

-- 防止生物灭绝
if GetModConfigData("prevent_creature_extinction_switch") then
    modimport("scripts/prevent_creature_extinction_main.lua")
end

-- 生存天数奖励
if GetModConfigData('reward_for_survival') then
    modimport("scripts/widgets/reward_day")
end


-- 木牌传送
if GetModConfigData("fast_travel") == true then
    modimport("scripts/fast_travel.lua")
end

-- 死亡复活按钮
if GetModConfigData("death_resurrection_button") == true then
    modimport("scripts/death_resurrection_button.lua")
end

--重生
if GetModConfigData("restart_set") == true then
    modimport("scripts/restart_set.lua")
end

--冰箱返鲜
if GetModConfigData("smart_minisign_switch") == true then
    modimport("scripts/smart_minisign_main.lua")
end


--冰箱返鲜
if GetModConfigData("common_container_preserve") == true then
    modimport("scripts/common_container_preserve_main.lua")
end

--快速工作
if GetModConfigData("quick_work") == true then
    modimport("scripts/quick_work.lua")
end

--陷阱增强
if GetModConfigData("trap_enhance") == true then
    modimport("scripts/trap_enhance.lua")
end

--黑色法杖
modimport("scripts/blackstaff_main.lua")
--监控
modimport("scripts/spy_player_action.lua")

--堆叠指令
if GetModConfigData("command_stack") == true then
    modimport("scripts/manager_players.lua")
end
--小穹开始自带打包风铃草
--if GetModConfigData("bellflower_pack_start") then
--    modimport("scripts/bellflower_pack.lua")
--end
----小穹打包纸限制
--if GetModConfigData("limit_sorapacker") then
--    modimport("scripts/limit_sorapacker.lua")
--end
--小穹补丁
if GetModConfigData("sora_patches_switch") and TUNING.QIONG_ENABLE then
    modimport("scripts/sora_patches.lua")
end
--夜雨心空补丁
if GetModConfigData("yeyu_nilxin_patches_switch") and TUNING.YEYU_NILXIN_ENABLE then
    modimport("scripts/yeyu_nilxin_patches.lua")
end

--伊蕾娜
if GetModConfigData("elaina_patches_switch") and TUNING.ELAINA_ENABLE and GetModConfigData("elaina_additional_skin_switch") then
    modimport("scripts/elainaskin.lua")
end

if GetModConfigData("elaina_patches_switch") and TUNING.ELAINA_ENABLE then
    modimport("scripts/elaina_patches.lua")
end

--奇幻降临
if GetModConfigData("ab_patches_switch") and TUNING.QIHUANJIANGLIN_ENABLE then
    TUNING.AB_BOBBIN_C_CD_SETTING = GetModConfigData("ab_bobbin_c_cd_setting") or 1000
    modimport("scripts/ab_patches.lua")
end

--水晶领主
if GetModConfigData("aria_patches_switch") and TUNING.ARIA_ENABLE then
    modimport("scripts/aria_patches.lua")
end

--乃木园子
if GetModConfigData("yuanzi_patches_switch") then
    modimport("scripts/yuanzi_patches.lua")
end

--时崎狂三
if GetModConfigData("kurumi_patches_switch") then
    modimport("scripts/kurumi_patches.lua")
end
-- 璇儿
if GetModConfigData("xuaner_patches_switch") then
    modimport("scripts/xuaner_patches.lua")
end
-- 士条怜
if modenable("士条怜") then
    modimport("scripts/rei_patches.lua")
end

--全图定位
if GetModConfigData("global_position_switch") then
    modimport("scripts/global_position.lua")
end
--全图定位
if GetModConfigData("compass_switch") then
    modimport("scripts/compass_main.lua")
end

--蘑菇农场
if GetModConfigData("improve_mushroom_planters_switch") then
    modimport("scripts/improve_mushroom_planters.lua")
end

--简单血量条
if GetModConfigData("simple_health_bar_switch") and (not GetModConfigData("epic_health_bar_switch")) then
    modimport("scripts/simple_health_bar.lua")
end
if GetModConfigData("epic_health_bar_switch") then
    modimport("modules/epic_healthbar/epic_healthbar_main.lua")
end

--超大便携箱子
if GetModConfigData("bigbox_switch") then
    TUNING.MONITOR_CHESTS = TUNING.MONITOR_CHESTS or {}
    TUNING.MONITOR_CHESTS._big_box = true
    TUNING.MONITOR_CHESTS._big_box_chest = true

    modimport("scripts/huge_box_main.lua")
end

--月亮书籍
if GetModConfigData("add_moon_book_switch") then
    modimport("scripts/moon_book_main.lua")
end

--show me 不与信息显示同时开启
if GetModConfigData("show_me_switch") and ((not (GetModConfigData("cap_show_info_switch")) and (not modenable("666155465")))) then
    modimport("scripts/show_me.lua")
end


--容器内容显示
if GetModConfigData("container_high_light_switch") then
    modimport("scripts/container_high_light.lua")
end

--信息显示
if GetModConfigData("cap_show_info_switch") then
    modimport("scripts/show_info_main.lua")
end

--神话书说补丁
if GetModConfigData("myth_patches_switch") then
    modimport("scripts/myth_patches.lua")
end

--怠惰科技补丁
if GetModConfigData("lazy_technology_patches_switch") then
    modimport("scripts/lazyTechnology.lua")
end

--小房子可种植补丁
if GetModConfigData("sweet_house_patches_switch") then
    modimport("scripts/sweet_house.lua")
end

--红锅补丁
if GetModConfigData("red_pot_for_everyone_switch") then
    modimport("scripts/redpot_patches.lua")
end

--风滚草补丁
if GetModConfigData("interesting_tumbleweed_switch") and GetModConfigData("tumbleweed_prevent_error_patch_switch") then
    modimport("scripts/tumbleweed_prevent_error_patch.lua")
end

--能力勋章补丁
if TUNING.FUNCTIONAL_MEDAL_ENABLE and GetModConfigData("medal_patch_switch") then
    modimport("scripts/tumbleweed_prevent_error_patch.lua")
end

--码头套装增强
if GetModConfigData("dock_kit_enhance_switch") then
    modimport("scripts/medal_patches.lua")
end


--萝卜冰箱
if GetModConfigData("venus_icebox_switches") then
    modimport("scripts/venus_icebox_main.lua")
end

--船只大小
if GetModConfigData("new_boats_size_switch") then
    modimport("scripts/newboats_main.lua")
end

--龙鳞冰炉
modimport("scripts/ice_furnace.lua")

--霓庭灯 兔子喷泉
modimport("scripts/more_produce.lua")

--移除某些东西
if GetModConfigData("remove_something") then
    modimport("scripts/remove_something.lua")
end
--填海造海道具
if GetModConfigData("canal_plow") then
    modimport("scripts/canal_plow_main.lua")
end
--发光的瓶子
if GetModConfigData("light_bottle_switch") then
    modimport("scripts/light_bottle_main.lua")
end

--移除boss间仇恨
if GetModConfigData("remove_boss_taunted") then
    modimport("scripts/remove_boss_taunted.lua")
end

--boss掉落增多
if GetModConfigData("boss_prop_more_drop_switch") then
    modimport("scripts/boss_prop_more_drop_main.lua")
end

--自定义开局
if GetModConfigData("self_define_start_switch") then
    modimport("modules/self_define_start/self_define_start_main.lua")
end

--随机蓝图掉落
if GetModConfigData("random_blueprint_drop") then
    modimport("scripts/random_blueprint_drop_main.lua")
end


--强力清理
if GetModConfigData("strong_leaner_switch") then
    modimport("scripts/strongclean_main.lua")
end

--反作弊
if GetModConfigData("anti_cheat_switch") then
    modimport("scripts/anti_cheat.lua")
end
--大背包
if GetModConfigData("bigbag_switch") then
    modimport("scripts/bigbag_main.lua")
end
--翅膀背包
if GetModConfigData("wingpack_switch") then
    modimport("scripts/wing_pack_main.lua")
end

--自定义禁用角色
--旧的方式
--if GetModConfigData("remove_default_character_switch") then
--    modimport("scripts/remove_default_character.lua")
--end

if GetModConfigData("remove_character_switch") then
    modimport("scripts/remove_character.lua")
end

--权限
if GetModConfigData("player_authority_switch") then
    modimport("modules/authority/authority_main.lua")
end
if (not GetModConfigData("player_authority_switch")) and GetModConfigData("authority_hexie_switch") then
    modimport("modules/authority_hexie/authority_hexie_main.lua")
end

-- 微小游戏体验提升
if GetModConfigData("little_modify_for_pure_switch") then
    if GetModConfigData("show_bundle_content_switch") then
        modimport("modules/bundle/show_bundle.lua")
    end
    if GetModConfigData("smart_unwrap_bundle_switch") then
        modimport("modules/bundle/smart_unwrap.lua")
    end
    if GetModConfigData("combinable_equipment_switch") then
        modimport("modules/equipment/repairable_equipment.lua")
    end
    if GetModConfigData("naming_for_watches_switch") then
        modimport("modules/naming/nameable_watches.lua")
    end
    if GetModConfigData("glommer_statue_repairable_switch") then
        modimport("modules/creature/repairable_statueglommer.lua")
    end
    if GetModConfigData("block_pooping_switch") then
        modimport("modules/creature/blockable_pooping.lua")
    end
    if GetModConfigData("faster_trading_switch") then
        modimport("modules/actions/faster_trading_main.lua")
    end
    --- 猪王、鸟笼、蚁狮都可快速交易
    if GetModConfigData("faster_trading_for_multi_switch") and GetModConfigData("faster_trading_switch") ~= true then
        modimport("modules/actions/faster_trading_main2.lua")
    end
    if GetModConfigData("limit_ripening_plant_switch") then
        modimport("scripts/limit_ripening_plant.lua")
    end
    if GetModConfigData("more_crafting_details_switch") then
        modimport("scripts/more_crafting_details_main.lua")
    end
    -- 亮茄定期死亡
    if GetModConfigData("CREATURE_DIE_TIME") then
        modimport("scripts/creature_die_time_patches.lua")
    end

end

--驯牛状态
if GetModConfigData("beefalo_status_bar_switch") then
    modimport("scripts/beefalo_status_bar_main.lua")
end

--访客掉落
if GetModConfigData("passer_by_switch") then
    modimport("modules/passerby/passer_by_main.lua")
end
--UI拖拽缩放
if not TUNING.UI_DRAGGABLE_ENABLE and GetModConfigData("ui_button_badge_draggable_switch") then
    modimport("scripts/ui_button_badge_drag_main.lua")
end
--98K补丁
if GetModConfigData("m_98K_patches_switch") and TUNING.MAUSER_RIFLE_BAYONET_ENABLE then
    GLOBAL.MAUSER_PARAMS.RIFLE_DMG_R = GetModConfigData("m_98k_RIFLE_DMG_R_multi") or 1
    GLOBAL.MAUSER_PARAMS.RIFLE_DMG_M = GetModConfigData("m_98k_RIFLE_DMG_M_multi") or 1
    GLOBAL.MAUSER_PARAMS.BAYONET_DMG_2 = GetModConfigData("m_98k_BAYONET_DMG_2_multi") or 1
    GLOBAL.MAUSER_PARAMS.BAYONET_DMG_1 = GetModConfigData("m_98k_BAYONET_DMG_1_multi") or 1
end

modimport("scripts/mod_conflict_fix.lua")
modimport("scripts/blance_bug_fix.lua")

--if modenable("1991746508") then-- 神话 兼容 原版洞穴池塘 酸雨硝化 设定：在执行文件中
--    modimport("scripts/fix_pond_error.lua")
--end
--修复月台错误
modimport("scripts/fix_moon_beast_error.lua")

if GetModConfigData("word_migrate_drop_sync_switch") or GetModConfigData("character_word_forbidden_option") then
    modimport("scripts/word_migrate_drop.lua")
end

if GetModConfigData("upgrade_container_switch") then
    modimport("scripts/upgrade_container_main.lua")
end

if GetModConfigData("wb_strengthen_switch") then
    modimport("scripts/wb_strengthenstove.lua")
end

TUNING.RIPENING_PLANT_FREQUENCY = GetModConfigData("ripening_plant_frequency") or 60
--- beta功能
if GetModConfigData("beta_function_switch") then
    modimport("scripts/sgdeath.lua")
    --对于开 阿比 度日如年 玩家物品栏 勋章栏异常的权宜之计
    --if GetModConfigData("medal_ab_drrn_patches_switch") and modenable({ "2867435690", "2790273347", "奇幻降临：永恒终焉", "永恒终焉" }) and modenable("1909182187") and modenable("2845206007") then
    --    modimport("scripts/medal_ab_drrn_patches.lua")
    --end
    --------鞭尸怪物修复 理论上应该也修复了玩家被鞭尸
    --if GetModConfigData("repeat_death_fix") then
    --    modimport("scripts/repeat_death_fix.lua")
    --end

    if GetModConfigData("container_open_dont_drop_switch") then
        modimport("scripts/container_open_dont_drop.lua")
    end

    if GetModConfigData("container_sort_switch") then
        modimport("scripts/container_sort.lua")
    end
    if GetModConfigData("container_organize_preference") then
        modimport("scripts/container_organize.lua")
    end
    if GetModConfigData("give_item_optimize_switch") then
        modimport("scripts/giveitem_main.lua")
    end
    if GetModConfigData("fix_heap_of_food_switch") then
        TUNING.KYNO_BREWINGRECIPECARD_CHANCE = -1
        modimport("scripts/heap_of_food_fix.lua")
    end
    if GetModConfigData("cancel_sync_cycles_with_master_switch") then
        modimport("scripts/sync_cycles_with_master_main.lua")
    end

    if GetModConfigData("fix_migration_data_lost_switch") then
        modimport("scripts/fix_migration_data_lost.lua")
    end

    if GetModConfigData("fix_medal_conflict_with_other_mod_switch") then
        modimport("scripts/fix_medal_conflict_with_other_mod.lua")
    end

    --if GetModConfigData("blueprint_error_fix_switch") then
    --    modimport("scripts/blueprint_error_fix.lua")
    --end

    --Heap Of food 汉化
    if GetModConfigData("heap_of_food_chs_language_switch") then
        modimport("cn/hof_strings")
    end
    if GetModConfigData("vtf_chs_language_switch") then
        modimport("cn/vtf_strings_chs")
    end

    if GetModConfigData("htf_chs_language_switch") then
        modimport("cn/htf_strings_chs")
    end

    -- 新饮水系统汉化
    if GetModConfigData("dont_starve_dehydrated_chs_language_switch") then
        modimport("cn/hydration_strings")
    end

    --the lamb
    if GetModConfigData("the_lamb_chs_language_switch") then
        modimport("cn/the_lamb_strings")
    end
    --if GetModConfigData("the_lamb_bug_fix_switch") then
    --    modimport("scripts/the_lamb_patches")
    --end
end

if GetModConfigData("niche_container_modification_switch") then
    modimport("scripts/niche_container_modification_main.lua")
end

---制作配方的修改
modimport("scripts/items_recipe_modification.lua")

----处理下重复加组件的问题 不知道放哪里 先写这里
AddGlobalClassPostConstruct("entityscript", "EntityScript", function(self)
    local oldcap_add = self.AddComponent
    function self:AddComponent(name, ...)
        local lower_name = string.lower(name)
        if self.lower_components_shadow[lower_name] ~= nil then
            return self.components[name]
        end

        local cmp = oldcap_add(self, name, ...)

        return cmp
    end
end)

--测试道具
--AddPrefabPostInit("lemontree", function(inst)
--    local old_RemoveComponent = inst.RemoveComponent
--    inst.RemoveComponent = function(...)
--
--        local fninfo
--        for i=2,8 do
--            fninfo = debug.getinfo(i)
--            print("------:"..i)
--            dumptable(fninfo)
--        end
--
--        return old_RemoveComponent(...)
--    end
--
--end)