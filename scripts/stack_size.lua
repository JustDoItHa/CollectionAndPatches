-- 使用的mod名称：更多物品堆叠
local TheNet = GLOBAL.TheNet
local TheSim = GLOBAL.TheSim
local IsServer = TheNet:GetIsServer() or TheNet:IsDedicated()

local stack_size = GetModConfigData("cap_stack_size")
local stack_size1 = GetModConfigData("cap_soul_stack_size")
local Stack_other_objects = GetModConfigData("cap_stack_more")

--旧版
-- GLOBAL.TUNING.STACK_SIZE_LARGEITEM = stack_size
-- GLOBAL.TUNING.STACK_SIZE_MEDITEM = stack_size
-- GLOBAL.TUNING.STACK_SIZE_SMALLITEM = stack_size
-- GLOBAL.TUNING.STACK_SIZE_TINYITEM = stack_size
-- GLOBAL.TUNING.WORTOX_MAX_SOULS = stack_size1

-- local mod_stackable_replica = GLOBAL.require("components/stackable_replica")
-- mod_stackable_replica._ctor = function(self, inst)
-- self.inst = inst
-- self._stacksize 		= _G.net_shortint(inst.GUID, "stackable._stacksize", "stacksizedirty")
-- self._stacksizeupper 	= _G.net_shortint(inst.GUID, "stackable._stacksizeupper", "stacksizedirty")
-- self._ignoremaxsize 	= _G.net_bool(inst.GUID, "stackable._ignoremaxsize")
-- self._maxsize 		= _G.net_shortint(inst.GUID, "stackable._maxsize")
-- end


--增加了原始数据选项
if stack_size ~= 20 then
    GLOBAL.TUNING.STACK_SIZE_LARGEITEM = stack_size
    GLOBAL.TUNING.STACK_SIZE_MEDITEM = stack_size
    GLOBAL.TUNING.STACK_SIZE_SMALLITEM = stack_size
    GLOBAL.TUNING.STACK_SIZE_TINYITEM = stack_size
end

if stack_size1 ~= 20 then
    GLOBAL.TUNING.WORTOX_MAX_SOULS = stack_size1
end

if stack_size ~= 20 or stack_size1 ~= 20 then
    local mod_stackable_replica = GLOBAL.require("components/stackable_replica")
    mod_stackable_replica._ctor = function(self, inst)
        self.inst = inst
        -- self._stacksize = GLOBAL.net_shortint(inst.GUID, "stackable._stacksize", "stacksizedirty")
        -- self._maxsize = GLOBAL.net_shortint(inst.GUID, "stackable._maxsize")
        self._stacksize = GLOBAL.net_shortint(inst.GUID, "stackable._stacksize", "stacksizedirty")
        self._stacksizeupper = GLOBAL.net_shortint(inst.GUID, "stackable._stacksizeupper", "stacksizedirty")
        self._ignoremaxsize = GLOBAL.net_bool(inst.GUID, "stackable._ignoremaxsize")
        self._maxsize = GLOBAL.net_shortint(inst.GUID, "stackable._maxsize")
    end
end


--遍历需要叠加的动物
local function AddAnimalStackables(value)
    if IsServer == false then
        return
    end
    for k,v in ipairs(value) do
        AddPrefabPostInit(v,function(inst)
            if(inst.components.stackable == nil) then
                inst:AddComponent("stackable")
            end
            inst.components.inventoryitem:SetOnDroppedFn(function(inst)
                -- if(inst.components.perishable ~= nil) then
                -- inst.components.perishable:StopPerishing()
                -- end
                if(inst.sg ~= nil) then
                    inst.sg:GoToState("stunned")
                end
                if inst.components.stackable then
                    while inst.components.stackable:StackSize() > 1 do
                        local item = inst.components.stackable:Get()
                        if item then
                            if item.components.inventoryitem then
                                item.components.inventoryitem:OnDropped()
                            end
                            item.Physics:Teleport(inst.Transform:GetWorldPosition())
                        end
                    end
                end
            end)
        end)
    end
end


--遍历需要叠加的物品
local function AddItemStackables(value)
    if IsServer == false then
        return
    end
    for k,v in ipairs(value) do
        AddPrefabPostInit(v,function(inst)
            if  inst.components.sanity ~= nil  then
                return
            end
            if  inst.components.inventoryitem == nil  then
                return
            end
            if(inst.components.stackable == nil) then
                inst:AddComponent("stackable")
            end
        end)
    end
end

if Stack_other_objects then
    if GetModConfigData("stack_more_rabbit") then
        --小兔子
        AddAnimalStackables({"rabbit",})
    end
    if GetModConfigData("stack_more_mole") then
        --鼹鼠
        AddAnimalStackables({"mole",})
    end
    if GetModConfigData("stack_more_bird") then
        --鸟类
        AddAnimalStackables({"robin","robin_winter","crow","puffin","canary","canary_poisoned","bird_mutant","bird_mutant_spitter",})
    end
    if GetModConfigData("stack_more_fish") then
        --鱼类
        local STACKABLE_OBJECTS_BASE = {"pondfish","pondeel","oceanfish_medium_1_inv","oceanfish_medium_2_inv","oceanfish_medium_3_inv","oceanfish_medium_4_inv","oceanfish_medium_5_inv","oceanfish_medium_6_inv","oceanfish_medium_7_inv","oceanfish_medium_8_inv","oceanfish_small_1_inv","oceanfish_small_2_inv","oceanfish_small_3_inv","oceanfish_small_4_inv","oceanfish_small_5_inv","oceanfish_small_6_inv","oceanfish_small_7_inv","oceanfish_small_8_inv","oceanfish_small_9_inv","wobster_sheller_land","wobster_moonglass_land","oceanfish_medium_9_inv"}
        AddAnimalStackables(STACKABLE_OBJECTS_BASE)
    end
    if GetModConfigData("stack_more_eyeturret") then
        --眼球炮塔
        AddItemStackables({"eyeturret_item"})
    end
    if GetModConfigData("stack_more_tallbirdegg") then
        --高脚鸟蛋相关
        AddAnimalStackables({"tallbirdegg_cracked","tallbirdegg"})
    end
    if GetModConfigData("stack_more_lavae_egg") then
        --岩浆虫卵相关
        AddAnimalStackables({"lavae_egg","lavae_egg_cracked","lavae_tooth","lavae_cocoon"})
    end
    if GetModConfigData("stack_more_shadowheart") then
        --暗影心房
        AddItemStackables({"shadowheart"})
    end
    if GetModConfigData("stack_more_minotaurhorn") then
        --犀牛角
        AddItemStackables({"minotaurhorn"})
    end

    -------- Thanks For 小花朵 ---------

    if GetModConfigData("stack_more_miao_packbox") then
        --超级打包盒
        AddItemStackables({"miao_packbox"})
    end
    if GetModConfigData("stack_more_glommerwings") then
        --格罗姆翅膀
        AddItemStackables({"glommerwings"})
    end
    if GetModConfigData("stack_more_moonrockidol") then
        --月岩雕像破碎的心
        AddItemStackables({"moonrockidol","reviver"})
    end
    if GetModConfigData("stack_more_horn") then
        --牛角
        AddItemStackables({"horn","gnarwail_horn"})
    end
    -- 2023-12-01 记
    if GetModConfigData("stack_more_myth_lotusleaf") then
        --荷叶,月饼【神话书说】
        AddItemStackables({"myth_lotusleaf","myth_mooncake_ice","myth_mooncake_lotus","myth_mooncake_nuts"})
    end
    -- 2023、12、20（各种蜘蛛）
    -- if GetModConfigData("spider") then
    --普通蜘蛛
    -- AddItemStackables({"spider"})
    -- end
    -- if GetModConfigData("spider_healer") then
    --护士蜘蛛
    -- AddItemStackables({"spider_healer"})
    -- end
    -- if GetModConfigData("spider_hider") then
    --洞穴蜘蛛
    -- AddItemStackables({"spider_hider"})
    -- end
    -- if GetModConfigData("spider_moon") then
    --破碎蜘蛛
    -- AddItemStackables({"spider_moon"})
    -- end
    -- if GetModConfigData("spider_spitter") then
    --喷射蜘蛛
    -- AddItemStackables({"spider_spitter"})
    -- end
    -- if GetModConfigData("spider_warrior") then
    --蜘蛛战士
    -- AddItemStackables({"spider_warrior"})
    -- end
    if GetModConfigData("stack_more_spider") then
        --蜘蛛类
        AddAnimalStackables({"spider","spider_healer","spider_hider","spider_moon","spider_spitter","spider_warrior",})
    end
    --2024-3-5日
    if GetModConfigData("stack_more_blank_certificate") then
        --空白勋章【能力勋章】
        AddItemStackables({"blank_certificate"})
    end
    if GetModConfigData("stack_more_lg_choufish_inv") then
        --小丑鱼【海洋传说】
        AddItemStackables({"lg_choufish_inv"})
    end
    if GetModConfigData("stack_more_aip_leaf_note") then
        --树叶笔记【额外物品包】
        AddItemStackables({"aip_leaf_note"})
    end
    -- if GetModConfigData("sketch1") then
    --常用草图
    -- AddItemStackables({"chesspiece_anchor_sketch","chesspiece_butterfly_sketch","chesspiece_moon_sketch","chesspiece_clayhound_sketch","chesspiece_claywarg_sketch","chesspiece_carrat_sketch","chesspiece_beefalo_sketch","chesspiece_catcoon_sketch","chesspiece_kitcoon_sketch","chesspiece_manrabbit_sketch","chesspiece_pawn_sketch","chesspiece_rook_sketch","chesspiece_knight_sketch","chesspiece_bishop_sketch","chesspiece_muse_sketch","chesspiece_formal_sketch","chesspiece_deerclops_sketch","chesspiece_bearger_sketch","chesspiece_moosegoose_sketch","chesspiece_dragonfly_sketch","chesspiece_minotaur_sketch","chesspiece_toadstool_sketch","chesspiece_beequeen_sketch","chesspiece_klaus_sketch","chesspiece_antlion_sketch","chesspiece_stalker_sketch","chesspiece_malbatross_sketch","chesspiece_crabking_sketch","chesspiece_guardianphase3_sketch","chesspiece_eyeofterror_sketch","chesspiece_twinsofterror_sketch","chesspiece_daywalker_sketch","chesspiece_deerclops_mutated_sketch","chesspiece_bearger_mutated_sketch","chesspiece_warg_mutated_sketch"})
    -- end
    --2024-3-14
    if GetModConfigData("stack_more_foliageath") then
        --青枝绿叶【棱镜】
        AddItemStackables({"foliageath"})
    end
    if GetModConfigData("stack_more_security_pulse_cage") then
        --火花柜
        AddItemStackables({"security_pulse_cage","security_pulse_cage_full"})
    end
    if GetModConfigData("stack_more_deer_antler") then
        --鹿角和麋鹿茸
        AddItemStackables({"deer_antler","deer_antler1","deer_antler2","deer_antler3","klaussackkey"})
    end
    -- if GetModConfigData("alterguardianhatshard") then
    --启迪碎片
    -- AddItemStackables({"alterguardianhatshard"})
    -- end
    if GetModConfigData("stack_more_reskin_tool") then
        --清洁扫把和提灯【娜娜很需要】
        AddItemStackables({"reskin_tool","lantern"})
    end
end