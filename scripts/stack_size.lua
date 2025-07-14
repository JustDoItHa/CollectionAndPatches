-- 使用的mod名称：更多物品堆叠
local TheNet = GLOBAL.TheNet
local TheSim = GLOBAL.TheSim
local IsServer = TheNet:GetIsServer() or TheNet:IsDedicated()

local stack_size = GetModConfigData("cap_stack_size")
local stack_size1 = GetModConfigData("cap_soul_stack_size")
local Stack_other_objects = GetModConfigData("cap_stack_more")
local cap_stack_show_real_num_l = GetModConfigData("cap_stack_show_real_num") or false

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


if (stack_size > 4096 or stack_size1 > 4096) and cap_stack_show_real_num_l then
    --增加了原始数据选项
    if stack_size > 0 then
        GLOBAL.TUNING.STACK_SIZE_LARGEITEM = stack_size
        GLOBAL.TUNING.STACK_SIZE_MEDITEM = stack_size
        GLOBAL.TUNING.STACK_SIZE_SMALLITEM = stack_size
        GLOBAL.TUNING.STACK_SIZE_TINYITEM = stack_size
    end

    if stack_size1 > 0 then
        GLOBAL.TUNING.WORTOX_MAX_SOULS = stack_size1
    end
    local SUFFIXES = { 'K', 'M', 'B', 'T' }
    function formatQuantity(quantity)
        if quantity <= 999 then
            return
        end

        local log = string.len(tostring(quantity)) - 1

        if log < 3 then
            return
        end

        if quantity < 10000 then
            return tostring(quantity)
        end

        local index = #SUFFIXES

        for i, _ in ipairs(SUFFIXES) do
            if log < i * 3 then
                index = i - 1

                break
            end
        end

        local mult = 10 ^ (index * 3)
        local suffix = SUFFIXES[index]

        return log < index * 3 + 1
                and string.sub(tostring(quantity / mult), 1, 3) .. suffix
                or math.floor(quantity / mult) .. suffix
    end

    local stackable_replica = require("components/stackable_replica")

    local function OnStackSizeDirty(inst)
        local self = inst.replica.stackable
        if not self then
            return --stackable removed?
        end

        self:ClearPreviewStackSize()

        --instead of inventoryitem_classified listening for "stacksizedirty" as well
        --forward a new event to guarantee order
        inst:PushEvent("inventoryitem_stacksizedirty")
    end

    stackable_replica._ctor = function(self, inst)
        self.inst = inst

        self._stacksize = net_ushortint(inst.GUID, "stackable._stacksize", "stacksizedirty")
        self._stacksizeupper = net_ushortint(inst.GUID, "stackable._stacksizeupper", "stacksizedirty")
        self._ignoremaxsize = net_bool(inst.GUID, "stackable._ignoremaxsize")
        self._maxsize = net_tinybyte(inst.GUID, "stackable._maxsize")

        if not TheWorld.ismastersim then
            --self._previewstacksize = nil
            --self._previewtimeouttask = nil
            inst:ListenForEvent("stacksizedirty", OnStackSizeDirty)
        end
    end

    stackable_replica.SetStackSize = function(self, stacksize)
        stacksize = stacksize - 1
        if stacksize <= 65535 then
            self._stacksizeupper:set(0)
            self._stacksize:set(stacksize)
        elseif stacksize >= 4095 then
            if self._stacksizeupper:value() ~= 65535 then
                self._stacksizeupper:set(65535)
            else
                self._stacksize:set_local(65535) --force sync to trigger UI events even when capped
            end
            self._stacksize:set(65535)
        else
            local upper = math.floor(stacksize / 65536)
            self._stacksizeupper:set(upper)
            self._stacksize:set(stacksize - upper * 65536)
        end
    end

    stackable_replica.StackSize = function(self)
        return self:GetPreviewStackSize() or (self._stacksizeupper:value() * 65536 + self._stacksize:value() + 1)
    end

    AddClassPostConstruct("widgets/controls", function()
        local ItemTile = require("widgets/itemtile")
        local oldSetQuantity = ItemTile.SetQuantity

        function ItemTile:SetQuantity(quantity, ...)
            local quantityString = formatQuantity(quantity)
            oldSetQuantity(self, quantity, ...)
            if (quantity > 65535 and quantityString == nil) or quantityString =="4.2B" then
                self.quantity:SetString("+∞")
            elseif quantityString ~= nil then
                self.quantity:SetString(quantityString)
            end

        end
    end)
else

    --增加了原始数据选项
    if stack_size > 0 then
        GLOBAL.TUNING.STACK_SIZE_LARGEITEM = stack_size
        GLOBAL.TUNING.STACK_SIZE_MEDITEM = stack_size
        GLOBAL.TUNING.STACK_SIZE_SMALLITEM = stack_size
        GLOBAL.TUNING.STACK_SIZE_TINYITEM = stack_size
    end

    if stack_size1 > 0 then
        GLOBAL.TUNING.WORTOX_MAX_SOULS = stack_size1
    end

    local function OnStackSizeDirty(inst)
        local self = inst.replica.stackable
        if not self then
            return --stackable removed?
        end

        self:ClearPreviewStackSize()
        inst:PushEvent("inventoryitem_stacksizedirty")
    end

    local mod_stackable_replica = require("components/stackable_replica")
    mod_stackable_replica._ctor = function(self, inst)
        self.inst = inst
        self._stacksize = net_shortint(inst.GUID, "stackable._stacksize", "stacksizedirty")
        self._stacksizeupper = net_shortint(inst.GUID, "stackable._stacksizeupper", "stacksizedirty")
        self._ignoremaxsize = net_bool(inst.GUID, "stackable._ignoremaxsize")
        self._maxsize = net_shortint(inst.GUID, "stackable._maxsize")
        if not TheWorld.ismastersim then
            inst:ListenForEvent("stacksizedirty", OnStackSizeDirty)
        end
    end

end


--遍历需要叠加的动物
local function AddAnimalStackables(value)
    if IsServer == false then
        return
    end
    for k, v in ipairs(value) do
        AddPrefabPostInit(v, function(inst)
            if (inst.components.stackable == nil) then
                inst:AddComponent("stackable")
            end
            if inst.components.follower then
                local old_stack_get = inst.components.stackable.Get
                function inst.components.stackable:Get(num)
                    local stack_get = old_stack_get(self, num)
                    if inst.components.follower then
                        stack_get.components.follower:SetLeader(inst.components.follower.leader)
                    end
                    return stack_get
                end
            end
            if inst.components.inventoryitem then
                inst.components.inventoryitem:SetOnDroppedFn(function(inst)
                    -- if(inst.components.perishable ~= nil) then
                    -- inst.components.perishable:StopPerishing()
                    -- end
                    if (inst.sg ~= nil) then
                        inst.sg:GoToState("stunned")
                    end
                    local leader = nil
                    if inst.components.follower then
                        leader = inst.components.follower.leader
                    end
                    if inst.components.stackable then
                        while inst.components.stackable:StackSize() > 1 do
                            local item = inst.components.stackable:Get()
                            if item then
                                if item.components.inventoryitem then
                                    if item.components.follower and leader then
                                        item.components.follower:SetLeader(leader)
                                    end
                                    item.components.inventoryitem:OnDropped()
                                end
                                item.Physics:Teleport(inst.Transform:GetWorldPosition())
                            end
                        end
                    end
                end)
            end
        end)
    end
end


--遍历需要叠加的物品
local function AddItemStackables(value)
    if IsServer == false then
        return
    end
    for k, v in ipairs(value) do
        AddPrefabPostInit(v, function(inst)
            if inst.components.sanity ~= nil then
                return
            end
            if inst.components.inventoryitem == nil then
                return
            end
            if (inst.components.stackable == nil) then
                inst:AddComponent("stackable")
            end
        end)
    end
end

if Stack_other_objects then

    if GetModConfigData("stack_more_rabbit") then
        --小兔子
        AddAnimalStackables({ "rabbit", })
    end
    if GetModConfigData("stack_more_mole") then
        --鼹鼠
        AddAnimalStackables({ "mole", })
    end
    if GetModConfigData("stack_more_bird") then
        --鸟类
        AddAnimalStackables({ "robin", "robin_winter", "crow", "puffin", "canary", "canary_poisoned", "bird_mutant_spitter", })
    end
    if GetModConfigData("stack_more_crow") then
        --月盲乌鸦
        AddAnimalStackables({ "bird_mutant" })
    end

    if GetModConfigData("stack_more_fish") then
        --鱼类
        local STACKABLE_OBJECTS_BASE = { "pondfish", "pondeel", "oceanfish_medium_1_inv", "oceanfish_medium_2_inv", "oceanfish_medium_3_inv", "oceanfish_medium_4_inv", "oceanfish_medium_5_inv", "oceanfish_medium_6_inv", "oceanfish_medium_7_inv", "oceanfish_medium_8_inv", "oceanfish_small_1_inv", "oceanfish_small_2_inv", "oceanfish_small_3_inv", "oceanfish_small_4_inv", "oceanfish_small_5_inv", "oceanfish_small_6_inv", "oceanfish_small_7_inv", "oceanfish_small_8_inv", "oceanfish_small_9_inv", "wobster_sheller_land", "wobster_moonglass_land", "oceanfish_medium_9_inv", "lightcrab" }
        AddAnimalStackables(STACKABLE_OBJECTS_BASE)
    end
    if GetModConfigData("stack_more_eyeturret") then
        --眼球炮塔
        AddItemStackables({ "eyeturret_item" })
    end
    if GetModConfigData("stack_more_tallbirdegg") then
        --高脚鸟蛋相关
        AddAnimalStackables({ "tallbirdegg_cracked", "tallbirdegg" })
    end
    if GetModConfigData("stack_more_lavae_egg") then
        --岩浆虫卵相关
        AddAnimalStackables({ "lavae_egg", "lavae_egg_cracked", "lavae_tooth", "lavae_cocoon" })
    end
    if GetModConfigData("stack_more_shadowheart") then
        --暗影心房
        AddItemStackables({ "shadowheart" })
    end

    if GetModConfigData("stack_more_glommerwings") then
        --格罗姆翅膀
        AddItemStackables({ "glommerwings" })
    end
    if GetModConfigData("stack_more_moonrockidol") then
        --月岩雕像破碎的心
        AddItemStackables({ "moonrockidol", "reviver" })
    end
    if GetModConfigData("stack_more_horn") then
        --牛角
        AddItemStackables({ "horn", "gnarwail_horn" })
    end

    if GetModConfigData("stack_more_spider") then
        --蜘蛛类
        AddAnimalStackables({ "spider", "spider_healer", "spider_hider", "spider_moon", "spider_spitter", "spider_warrior", "spider_dropper", "spider_water" })
    end

    if GetModConfigData("stack_more_security_pulse_cage") then
        --火花柜和约束静电
        AddItemStackables({ "security_pulse_cage", "security_pulse_cage_full", "moonstorm_static_item" })
    end
    if GetModConfigData("stack_more_deer_antler") then
        --鹿角和麋鹿茸
        AddItemStackables({ "deer_antler", "deer_antler1", "deer_antler2", "deer_antler3", "klaussackkey" })
    end
    -- if GetModConfigData("alterguardianhatshard") then
    --启迪碎片
    -- AddItemStackables({"alterguardianhatshard"})
    -- end
    if GetModConfigData("stack_more_chestupgrade_stacksize") then
        --箱子升级组件
        AddItemStackables({ "chestupgrade_stacksize" })
    end
    if GetModConfigData("stack_more_shell") then
        --贝壳钟
        AddItemStackables({ "singingshell_octave3", "singingshell_octave4", "singingshell_octave5" })
    end

    if GetModConfigData("stack_more_wally") then
        --厨师炊具
        AddItemStackables({ "portablecookpot_item", "portableblender_item", "portablespicer_item" })
    end

    if GetModConfigData("stack_more_winona") then
        --女工得投石机和聚光灯
        AddItemStackables({ "winona_catapult_item", "winona_spotlight_item" })
    end

    if GetModConfigData("stack_more_mooneye") then
        --月眼
        AddItemStackables({
            --"moonrockcrater", 升级时候会整组变一个， 暂时先不加
            "redmooneye", "orangemooneye", "yellowmooneye", "greenmooneye", "purplemooneye", "bluemooneye" })
    end

    if GetModConfigData("stack_more_boat_stuff") then
        --船上用品
        AddItemStackables({
            --常规船上用品
            "boat_grass_item", "boat_item", "anchor_item", "steeringwheel_item", "boat_rotator_kit", "mast_item", "ocean_trawler_kit", "boat_cannon_kit", "mastupgrade_lightningrod_item", "mast_malbatross_item",
            --龙年限定
            "dragonboat_pack", "boatrace_seatack_throwable_deploykit", "dragonboat_kit", "yotd_anchor_item", "mast_yotd_item", "yotd_steeringwheel_item",
        })
    end

    if GetModConfigData("stack_more_ancienttree_stuff") then
        --惊喜种子
        AddItemStackables({ "ancienttree_seed", "ancienttree_nightvision_sapling_item", "ancienttree_gem_sapling_item" })
    end

    --
    ---- 这里草图和蓝图都需要
    --if GetModConfigData("blueprint") or GetModConfigData("sketch") then
    --    -- 蓝图、草图擦除修复
    --    AddComponentPostInit("stackable", function(self)
    --        --	if not IsServer then return inst end
    --        -- local oldOnSave = self.OnSave
    --
    --        -- function self:OnSave(sz)
    --        -- local data = oldOnSave(self) or {}
    --        -- data.stack = self.stacksize
    --        -- return data
    --        -- end
    --
    --        function self:SetStackSize(sz)
    --            sz = sz or 1
    --            local old_size = self.stacksize
    --            self.stacksize = math.min(sz, MAXUINT)
    --            self.inst:PushEvent("stacksizechange", {stacksize = sz, oldstacksize=old_size})
    --        end
    --    end)
    --
    --
    --end
    --
    ---- 蓝图部分
    --if GetModConfigData("blueprint") then
    --    -- 学习蓝图全组消耗修复
    --    AddComponentPostInit("teacher", function(self)
    --        --	if not IsServer then return inst end
    --        function self:Teach(target)
    --            if self.recipe == nil then
    --                self.inst:Remove()
    --                return false
    --            elseif target.components.builder == nil then
    --                return false
    --            elseif target.components.builder:KnowsRecipe(self.recipe) then
    --                return false, "KNOWN"
    --            elseif not target.components.builder:CanLearn(self.recipe) then
    --                return false, "CANTLEARN"
    --            else target.components.builder:UnlockRecipe(self.recipe)
    --                if self.onteach then
    --                    self.onteach(self.inst, target)
    --                end
    --                --学习蓝图时不会一次全消耗
    --                --self.inst:Remove()
    --                if self.inst.components.stackable then
    --                    self.inst.components.stackable:Get():Remove()
    --                else
    --                    self.inst:Remove()
    --                end
    --                return true
    --            end
    --        end
    --    end)
    --
    --    AddPrefabPostInit("blueprint", function(inst)
    --        if not IsServer then return inst end
    --        inst:DoTaskInTime(0, function(inst)
    --            inst.skinname=inst.components.teacher.recipe
    --        end)
    --        if inst.components.stackable == nil then
    --            inst:AddComponent("stackable")
    --        end
    --        if inst.components.teacher and inst.components.teacher.recipe then
    --            local old_stack_get = inst.components.stackable.Get
    --            function inst.components.stackable:Get(num)
    --                old_stack_get(self, num):Remove()
    --                local inst = SpawnPrefab(self.inst.components.teacher.recipe .. "_blueprint")
    --                inst.components.stackable:SetStackSize(num)
    --                return inst
    --            end
    --        end
    --    end)
    --
    --    --广告部分
    --    AddPrefabPostInit("tacklesketch", function(inst)
    --        if not IsServer then return inst end
    --        inst:DoTaskInTime(0, function(inst)
    --            inst.skinname=inst.components.teacher.recipe
    --        end)
    --        if inst.components.stackable == nil then
    --            inst:AddComponent("stackable")
    --        end
    --        if inst.components.teacher and inst.components.teacher.recipe then
    --            local old_stack_get = inst.components.stackable.Get
    --            function inst.components.stackable:Get(num)
    --                old_stack_get(self, num):Remove()
    --                local inst = SpawnPrefab(self.inst.components.teacher.recipe .. "_tacklesketch")
    --                inst.components.stackable:SetStackSize(num)
    --                return inst
    --            end
    --        end
    --    end)
    --end
    --
    ---- 草图部分
    --if GetModConfigData("sketch") then
    --    AddPrefabPostInit("sketch", function(inst)
    --        if not IsServer then return inst end
    --        inst:DoTaskInTime(0, function(inst)
    --            inst.skinname=inst:GetSpecificSketchPrefab()
    --        end)
    --        if inst.components.stackable == nil then
    --            inst:AddComponent("stackable")
    --        end
    --        local old_stack_get = inst.components.stackable.Get
    --        function inst.components.stackable:Get(num)
    --            old_stack_get(self, num):Remove()
    --            local inst = SpawnPrefab(inst:GetSpecificSketchPrefab())
    --            inst.components.stackable:SetStackSize(num)
    --            return inst
    --        end
    --    end)
    --end

    --模组物品
    if GetModConfigData("cap_stack_mod") then
        if TUNING.DENGXIAN_ENABLE then
            --【登仙】暗影玫瑰， 上品灵石， 仙品灵石
            AddItemStackables({ "xd_aymg", "xd_lingshi3", "xd_lingshi4" })
        end

        if TUNING.MYTH_THEME_ENABLE then
            --荷叶,月饼【神话书说】
            AddItemStackables({ "myth_lotusleaf",
                                "myth_mooncake_ice",
                                "myth_mooncake_lotus",
                                "myth_mooncake_nuts",
                                "myth_rhino_blueheart",
                                "myth_rhino_yellowheart",
                                "myth_rhino_redheart",
                                "mk_huoyuan",
                                "myth_redlantern" })
        end
        if TUNING.FUNCTIONAL_MEDAL_ENABLE then
            --空白勋章【能力勋章】
            AddItemStackables({ "blank_certificate", "lavaeel" })
        end
        if TUNING.LEGEND_AND_SEA_ENABLE then
            --小丑鱼【海洋传说】
            AddItemStackables({ "lg_choufish_inv" })
        end
        if TUNING.ADDITIONAL_ITEM_PACKAGE_ENABLE then
            --树叶笔记【额外物品包】
            AddItemStackables({ "aip_leaf_note", "aip_prosperity_seed" })
        end

        if TUNING.LEGION_ENABLE then
            --青枝绿叶【棱镜】
            AddItemStackables({ "foliageath", "raindonate" })
        end

        if TUNING.MIAO_PACKBOX_ENABLE then
            --【超级打包盒】
            AddItemStackables({ "miao_packbox" })
        end

        if TUNING.HEAP_OF_FOOD_ENABLE then
            --HOF【更多料理】
            AddItemStackables({
                --松鼠
                "kyno_piko_orange", "kyno_piko",
                --罐头
                "kyno_beancan", "kyno_tomatocan", "kyno_tunacan", "kyno_meatcan", "kyno_beancan_open", "kyno_tomatocan_open", "kyno_tunacan_open", "kyno_meatcan_open", "kyno_cokecan", "kyno_sodacan", "kyno_energycan",
                --鸡
                "kyno_chicken2",
                --鱼
                "kyno_grouper", "kyno_salmonfish", "kyno_tropicalfish", "kyno_koi", "kyno_neonfish", "kyno_pierrotfish",
                --鸟
                "toucan", "toucan_hamlet", "kingfisher", })
        end

        if TUNING.TROPICAL_ENABLE then
            --【热带冒险】
            AddItemStackables({
                --鸟
                "parrot", "parrot_blue", "parrot_pirate", "toucan", "toucan_hamlet", "seagull", "quagmire_pigeon", "cormorant", "kingfisher", "doydoy",
                --蜘蛛类
                "spiderb", "spiderb1", "spiderb2", "spider_tropical",
                --海鲜
                "crab", "jellyfish", "rainbowjellyfish",
                --fish
                "oceanfish_small_1_inv", "oceanfish_small_2_inv", "oceanfish_small_3_inv", "oceanfish_small_4_inv", "oceanfish_small_5_inv", "oceanfish_small_6_inv", "oceanfish_small_7_inv", "oceanfish_small_8_inv", "oceanfish_small_9_inv", "oceanfish_small_10_inv", "oceanfish_small_11_inv", "oceanfish_small_12_inv", "oceanfish_small_13_inv", "oceanfish_small_14_inv", "oceanfish_small_15_inv", "oceanfish_small_16_inv", "oceanfish_small_17_inv", "oceanfish_small_18_inv", "oceanfish_small_19_inv", "oceanfish_small_20_inv", "oceanfish_small_21_inv", "oceanfish_small_61_inv", "oceanfish_small_71_inv", "oceanfish_small_81_inv", "oceanfish_small_91_inv",
                "oceanfish_medium_1_inv", "oceanfish_medium_2_inv", "oceanfish_medium_3_inv", "oceanfish_medium_4_inv", "oceanfish_medium_5_inv", "oceanfish_medium_6_inv", "oceanfish_medium_7_inv", "oceanfish_medium_8_inv",
                --其他生物
                "glowfly", "coral_brain", "magic_seal",
                --船上用品
                "porto_lograft_old", "porto_raft_old", "porto_rowboat", "porto_cargoboat", "porto_armouredboat", "porto_encrustedboat", "porto_tar_extractor", "porto_sea_yard", "trawlnet", "armor_lifejacket", "porto_buoy",

            })
        end
    end
    if GetModConfigData("stack_more_reskin_tool") then
        --清洁扫把和提灯和陷阱【娜娜自用】
        AddItemStackables({ "reskin_tool", "lantern", "trap_teeth" })
    end
end

