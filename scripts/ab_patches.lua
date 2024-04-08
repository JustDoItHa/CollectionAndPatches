local num = TUNING.STACK_SIZE_SMALLITEM or 40
AddComponentPostInit("stackable", function(self)
    local old_SetStackSize = self.SetStackSize
    self.SetStackSize = function(self, sz, ...)
        if self.inst.prefab == "abigail_williams_psionic_fragments" or self.inst.prefab == "abigail_williams_bowknot_wavepoint" then
            if sz > num then
                sz = num
            end
        end
        return old_SetStackSize and old_SetStackSize(self, sz, ...)
    end
end)

if GetModConfigData("ab_knot_drop_limit") then
    if TheNet:GetIsServer() then
        --抄自浅诗大佬
        local STACK_RADIUS = 15
        local function FindEntities(x, y, z)
            return TheSim:FindEntities(x, y, z, STACK_RADIUS, { "_stackable" },
                    { "INLIMBO", "NOCLICK", "lootpump_oncatch", "lootpump_onflight" })
        end
        local function Put(inst, item)
            if item ~= inst and item.prefab == inst.prefab and item.skinname == inst.skinname then
                SpawnPrefab("sand_puff").Transform:SetPosition(item.Transform:GetWorldPosition())
                inst.components.stackable:Put(item)
            end
        end
        AddComponentPostInit("stackable", function(Stackable)
            local Get = Stackable.Get
            function Stackable:Get(...)
                local instance = Get(self, ...)
                if instance.xt_stack_task then
                    instance.xt_stack_task:Cancel()
                    instance.xt_stack_task = nil
                end
                return instance
            end
        end)
        AddPrefabPostInit("abigail_williams_psionic_fragments", function(inst)
            if inst.components.stackable == nil then
                return
            end
            inst.xt_stack_task = inst:DoTaskInTime(.5, function()
                if inst.components.stackable == nil or inst:IsInLimbo() or inst:HasTag("NOCLICK") then
                    return
                end
                if inst:IsValid() and not inst.components.stackable:IsFull() then
                    for _, item in ipairs(FindEntities(inst.Transform:GetWorldPosition())) do
                        if item:IsValid() and not item.components.stackable:IsFull() then
                            Put(inst, item)
                        end
                    end
                end
            end)
        end)
        AddPrefabPostInit("abigail_williams_bowknot_wavepoint", function(inst)
            if inst.components.stackable == nil then
                return
            end
            inst.xt_stack_task = inst:DoTaskInTime(.5, function()
                if inst.components.stackable == nil or inst:IsInLimbo() or inst:HasTag("NOCLICK") then
                    return
                end
                if inst:IsValid() and not inst.components.stackable:IsFull() then
                    for _, item in ipairs(FindEntities(inst.Transform:GetWorldPosition())) do
                        if item:IsValid() and not item.components.stackable:IsFull() then
                            Put(inst, item)
                        end
                    end
                end
            end)
        end)
        -- AddPrefabPostInitAny(function(inst)
        --     if inst:HasTag("smallcreature") or inst:HasTag("heavy") or inst:HasTag("trap") or inst:HasTag("NET_workable") then
        --         return
        --     end
        --     if inst.components.stackable == nil or inst:IsInLimbo() or inst:HasTag("NOCLICK") or inst.prefab == "bird_egg" or inst.prefab == "poop" then return end
        --     inst.xt_stack_task = inst:DoTaskInTime(.5, function()
        --         if inst.components.stackable == nil or inst:IsInLimbo() or inst:HasTag("NOCLICK") then return end
        --         if inst:IsValid() and not inst.components.stackable:IsFull() then
        --             for _, item in ipairs(FindEntities(inst.Transform:GetWorldPosition())) do
        --                 if item:IsValid() and not item.components.stackable:IsFull() then Put(inst, item) end
        --             end
        --         end
        --     end)
        -- end)

        AddPrefabPostInit("ab_portablespicer_item", function(inst)
            if inst.components.trader == nil or inst.components.trader.onaccept == nil then
                return
            end
            inst.components.trader.onaccept = function(inst, giver, item, ...)
                giver.components.talker:Say("为什么呢？")
                if inst.components.trader.deleteitemonaccept == false then
                    giver.components.inventory.GiveItem(item)
                end
            end
        end)
        AddPrefabPostInit("ab_sword", function(inst)
            if inst.components.trader == nil or inst.components.trader.onaccept == nil then
                return
            end
            inst.components.trader.onaccept = function(inst, giver, item, ...)
                giver.components.talker:Say("为什么呢？")
                if inst.components.trader.deleteitemonaccept == false then
                    giver.components.inventory.GiveItem(item)
                end
            end
        end)

        -- local function ShouldAcceptItem(inst, item)
        --     return (item.prefab == "abigail_williams_bowknot_wavepoint" or item.prefab == "abigail_williams_psionic_fragments")
        -- end
        -- local function setname(inst,resetname)
        --     inst.components.weapon:SetDamage(math.min(basedamage + damagerate*inst.damagelevel ,maxdamage))
        --     local range = math.min(baserange+rangerate*inst.zhanshanum,maxrange)
        --     inst.components.weapon:SetRange(range, range)
        --     if resetname then
        --         local maxhealth = math.min(basehealth+healthrate*inst.zhanshalevel,maxhealth) *100
        --         inst.components.named:SetName(STRINGS.NAMES.AB_YZJXQ.."\n斩杀："..maxhealth.."%")
        --     end
        -- end
        AddPrefabPostInit("ab_yzjxq", function(inst)
            if inst.components.trader == nil or inst.components.trader.onaccept == nil then
                return
            end
            inst.components.trader.onaccept = function(inst, giver, item, ...)
                giver.components.talker:Say("为什么呢？")
                if inst.components.trader.deleteitemonaccept == false then
                    giver.components.inventory.GiveItem(item)
                end
            end
            -- inst.components.trader.test = ShouldAcceptItem
            -- inst.components.trader.onaccept = function(inst, giver, item,...)
            --     if item.prefab == "abigail_williams_psionic_fragments" then
            --         inst.damagelevel = inst.damagelevel + 1
            --         setname(inst)
            --     elseif item.prefab == "abigail_williams_bowknot_wavepoint" then
            --         inst.zhanshalevel = inst.zhanshalevel + 1
            --         setname(inst,true)
            --     end
            -- end
        end)
    end
end

if GetModConfigData("ab_packer_limit") then
    AddComponentPostInit("ab_packer", function(self)
        local oldCanPack = self.CanPack
        function self:CanPack(target, ...)
            if testCantPackItem(target, TUNING.CANT_PACK_ITEMS) then
                return false
            end

            return oldCanPack(self, target, ...)
        end
    end)
end

AddComponentPostInit("moisture", function(self)
    local oldDoDelta = self.DoDelta
    function self:DoDelta(...)
        if not self.inst:IsValid() then
            return
        end
        return oldDoDelta(self, ...)
    end
end)

local forbidItem = {
    "一大袋金币",
    "coin_bundle_big",
    "_big_box",
    "_big_box_chest",
    "huge_box",
    "bigbag",
    "bluebigbag",
    "redbigbag",
    "nicebigbag",
    "catbigbag",
    "catback",
    "cherryruins_resonator_item",
    "cherryruins_resonator_item_completed",
    "cherryruins_resonator",
    "wb_strengthen_bindpaper",
    "wb_strengthen_bindpaper_bundle",
    "wb_strengthen_bindpaper_container",
    "wb_strengthen_bindpaper_container",
    "wb_strengthen_cleanpaer",
    "wb_strengthen_increase_1_levelpaper",
    "wb_strengthen_increase_2_levelpaper",
    "wb_strengthen_increase_3_levelpaper",
    "wb_strengthen_increase_4_levelpaper",
    "wb_strengthen_increase_5_levelpaper",
    "wb_strengthen_increase_6_levelpaper",
    "wb_strengthen_increase_7_levelpaper",
    "wb_strengthen_increase_8_levelpaper",
    "wb_strengthen_increase_9_levelpaper",
    "wb_strengthen_increase_10_levelpaper",
    "wb_strengthen_increase_11_levelpaper",
    "wb_strengthen_increase_12_levelpaper",
    "wb_strengthen_strengthen_1_levelpaper",
    "wb_strengthen_strengthen_2_levelpaper",
    "wb_strengthen_strengthen_3_levelpaper",
    "wb_strengthen_strengthen_4_levelpaper",
    "wb_strengthen_strengthen_5_levelpaper",
    "wb_strengthen_strengthen_6_levelpaper",
    "wb_strengthen_strengthen_7_levelpaper",
    "wb_strengthen_strengthen_8_levelpaper",
    "wb_strengthen_strengthen_9_levelpaper",
    "wb_strengthen_strengthen_10_levelpaper",
    "wb_strengthen_strengthen_11_levelpaper",
    "wb_strengthen_strengthen_12_levelpaper",
    "wb_strengthen_increase_next_levelpaper",
    "wb_strengthen_increase_protectpaper",
    "wb_strengthen_strengthen_protectpaper",
    "wb_strengthen_strengthen_food",
    "wb_strengthen_increase_food",
    "myth_plant_infantree_trunk",
    "kemomimi_boss_ds",
    "multiplayer_portal", --天体门
    "multiplayer_portal_moonrock", --天体门
    "multiplayer_portal_moonrock_constr", --天体门
    "pigking", --猪王
    "antlion", --蚁狮
    "crabking", --帝王蟹
    "beequeenhivegrown", --蜂王窝-底座
    "statueglommer", --格罗姆雕像
    "oasislake", --绿洲
    "archive_switch", --档案馆华丽的基座
    "archive_portal", --档案馆传送门
    "archive_lockbox_dispencer", --知识饮水器
    "archive_centipede", --远古哨兵蜈蚣
    "archive_centipede_husk", --远古哨兵壳
    "atrium_gate", --远古大门
    "monkeyqueen", --月亮码头女王
    "monkeyisland_portal", --非自然传送门
    "toadstool_cap", --毒菌蟾蜍蘑菇
    "elecourmaline", --电器台
    "elecourmaline_keystone", --
    "moondungeon", --月的地下城
    "siving_thetree", --子圭神木岩
    "myth_rhino_desk", --三犀牛台
    "myth_chang_e", --嫦娥
    "myth_store", --小店
    "myth_store_construction", --未完成的小店
    "myth_shop", --小店
    "myth_shop_animals",
    "myth_shop_foods",
    "myth_shop_ingredient",
    "myth_shop_numerology",
    "myth_shop_plants",
    "myth_shop_rareitem",
    "myth_shop_weapons",
    "medal_spacetime_devourer", --时空吞噬者
    "star_monv", --星辰魔女
    "elaina_npc_qp", --星辰魔女对话框
    "ntex_other_lz", --逆天而行修仙龙柱
    "garden_entrance", --糖果屋
    "garden_entrance1", --糖果屋
    "garden_exit", --糖果屋
    "garden_exit1", --糖果屋
    "lg_shop_wanju", --海洋传说商店
    "lg_shop_rain", --海洋传说商店
    "lg_shop_thing", --海洋传说商店
    "lg_shop_food", --海洋传说商店
    "lg_shop_cloth", --海洋传说商店
    "yyxk_favorability_medicament1000",
    "yyxk_favorability_medicament",
    "sora_exp_medicament",
    "sora_exp_medicament100",
    "sora_exp_medicament500",
    "sora_exp_medicament1000",

}
local ab_t = GetModConfigData("ab_t")
local ab_ty = GetModConfigData("ab_ty")
if MOD_RPC_HANDLERS["ab_recipelist"] and MOD_RPC["ab_recipelist"] and MOD_RPC["ab_recipelist"]["ab_recipelist"] and MOD_RPC["ab_recipelist"]["ab_recipelist"].id then
    local old_ab_recipelist = MOD_RPC_HANDLERS["ab_recipelist"][MOD_RPC["ab_recipelist"]["ab_recipelist"].id];
    MOD_RPC_HANDLERS["ab_recipelist"][MOD_RPC["ab_recipelist"]["ab_recipelist"].id] = function(inst, recipename, isproduct, ...)

        if recipename == 1 and TUNING.AB_CHAONENGQUANXIAN then
            if TheWorld.state.cycles + 1 < ab_t then
                if ab_t == -1 then
                    inst.components.talker:Say("永久封禁")
                    return
                end
                inst.components.talker:Say("超限链接" .. ab_t .. "天后解锁")
                return
            end
            for k, v in pairs(forbidItem) do
                if isproduct == v then
                    inst.components.talker:Say("这东西不能用这个方式获得哦！")
                    return
                end
            end
        elseif recipename == 2 then
            if TheWorld.state.cycles + 1 < ab_ty then
                if ab_ty == -1 then
                    inst.components.talker:Say("永久封禁")
                    return
                end
                inst.components.talker:Say("桃源" .. ab_ty .. "天后解锁")
                return
            end
        end

        if old_ab_recipelist then
            old_ab_recipelist(inst, recipename, isproduct, ...)
        end
    end
end

-- AddModRPCHandler("ab_recipelist", "ab_recipelist", function(inst, recipename, isproduct, id)
--     if IsEntityDeadOrGhost(inst, true) then
--         return
--     end
--     if checknumber(recipename) and recipename == 1 and checkstring(isproduct) and TUNING.AB_CHAONENGQUANXIAN then
--         if inst.using_traveler_log and inst.using_traveler_log:IsValid() and inst.using_traveler_log.components.ab_recipelist and
--                 inst.using_traveler_log.components.ab_recipelist.inventoryitems["abigail_williams_black_gold"] and inst.using_traveler_log.components.ab_recipelist.inventoryitems["abigail_williams_black_gold"] > 0 then
--             local new = SpawnPrefab(isproduct)
--             local pt = inst:GetPosition()

--             local itemForbidden = false
--             for k, v in pairs(forbidItem) do
--                 if isproduct == v then
--                     itemForbidden = true
--                     break
--                 end
--             end

--             if new then
--                 if not itemForbidden then
--                     if new.components.inventoryitem then
--                         inst.components.inventory:GiveItem(new, nil, pt)
--                     elseif new.Transform then
--                         new.Transform:SetPosition(pt:Get())
--                     end
--                     inst.using_traveler_log.components.ab_recipelist.inventoryitems["abigail_williams_black_gold"] = inst.using_traveler_log.components.ab_recipelist.inventoryitems["abigail_williams_black_gold"] - 1
--                 else
--                     inst.components.talker:Say("这东西不能用这个方式获得哦！")
--                 end
--             else
--                 inst.components.talker:Say("无效得物品")
--             end
--             return
--         end
--         if inst.components.inventory:Has("abigail_williams_black_gold", 1) then
--             local new = SpawnPrefab(isproduct)
--             local pt = inst:GetPosition()

--             local itemForbidden = false
--             for k, v in pairs(forbidItem) do
--                 if isproduct == v then
--                     itemForbidden = true
--                     break
--                 end
--             end

--             if new then
--                 if not itemForbidden then
--                     if new.components.inventoryitem then
--                         inst.components.inventory:GiveItem(new, nil, pt)
--                     elseif new.Transform then
--                         new.Transform:SetPosition(pt:Get())
--                     end
--                     inst.components.inventory:ConsumeByName("abigail_williams_black_gold", 1)
--                 else
--                     inst.components.talker:Say("这东西不能用这个方式获得哦！")
--                 end
--             else
--                 inst.components.talker:Say("无效得物品")
--             end
--             return
--         end
--         inst.components.talker:Say("缺少材料暗金")
--     elseif checknumber(recipename) and recipename == 2 and checkstring(isproduct) and checknumber(id) then
--         if inst.using_traveler_log and inst.using_traveler_log:IsValid() then
--             inst.using_traveler_log.components.ab_recipelist:ty(isproduct, id == 1, inst)
--         end
--     elseif inst.using_traveler_log and inst.using_traveler_log:IsValid() and checkstring(recipename)
--             and checkbool(isproduct) and inst.using_traveler_log.components.ab_recipelist then
--         inst.using_traveler_log.components.ab_recipelist:Build(recipename, inst, isproduct)
--     end
-- end)

local upvaluehelper = require "utils/upvaluehelp_cap"
--local ab_wg = require "components/ab_wg" --阿比第四 开局礼包 修改
--local zslist = upvaluehelper.Get(ab_wg.InIt, "zslist")
--if zslist then
--    for k, v in pairs(zslist) do
--        if v.id and v.item then
--            v.item = { "pyrite" }--黄铁
--        end
--    end
--end
local ab_c_builder = require "components/ab_c_builder" --彩虹宝石的修改

if TUNING.AB_BOBBIN_C_CD_SETTING > 0 then
    local timecd = TUNING.AB_BOBBIN_C_CD_SETTING
    local param = upvaluehelper.Set(ab_c_builder.Use, "timecd",timecd)
end


--黑色舞会机制修改

local heisewuhui_optimize = GetModConfigData("ab_heisewuhui_optimize") or 0

if heisewuhui_optimize > 0 then
    local function pickyishang(inst)
        inst.ab_yishang_world = math.random(100)
        for i, v in ipairs(AllPlayers) do
            if v:IsValid() and v.components.talker then
                v.components.talker:Say("当前世界黑色舞会骰子点数:" .. inst.ab_yishang_world)
            end
        end
    end
    AddPrefabPostInit("world", function(inst)
        if not TheWorld.ismastersim then
            return inst
        end
        inst:WatchWorldState("cycles", function()
            pickyishang(inst)
        end)
        pickyishang(inst)
    end)
    AddComponentPostInit("combat", function(self)
        local oldGetAttacked = self.GetAttacked
        function self:GetAttacked(attacker, damage, weapon, stimuli)
            local old = oldGetAttacked(self, attacker, damage, weapon, stimuli)
            if self.inst:HasTag("player") and TheWorld.ab_yishang_world ~= nil and self.inst.components.health then
                if self.inst.components.health and not self.inst.components.health:IsDead() then
                    local cause = attacker == self.inst and weapon or attacker
                    local exdamage = math.min(22 * heisewuhui_optimize, damage * (TheWorld.ab_yishang_world + (self.inst.components.health.ab_yishang_health or 0)) * 0.01)
                    self.inst.components.health:DoDelta(-exdamage, nil, cause ~= nil and (cause.nameoverride or cause.prefab) or "NIL", nil, cause)
                end
            end
            return old
        end
    end)

    STRINGS.NAMES.AB_LX_BUFF = "流血"
    local function DoRegen(inst, self)
        if not self:IsDead() then
            self:DoDelta(-1, nil, "ab_lx_buff")
        end
    end
    AddComponentPostInit("health", function(self)
        local old_sava = self.OnSave
        function self:OnSave()
            local old = old_sava(self)
            if old then
                old.ab_yishang_health = self.ab_yishang_health
            end
            return old
        end
        local old_load = self.OnLoad
        function self:OnLoad(data)
            if data and data.ab_yishang_health then
                self.ab_yishang_health = data.ab_yishang_health
            end
            old_load(self, data)
        end
        if self.inst:HasTag("player") then
            self.ab_yishang_health = 0
            if heisewuhui_optimize > 1 then
                self.inst:ListenForEvent("healthdelta", function(_inst, data)
                    if data and data.amount and data.amount < 0 then
                        if self:IsDead() then
                            return
                        end
                        --改成概率获得持续流血debuff直到死亡
                        if math.random() > 0.2 then
                            return
                        end
                        if not self.ab_lx_task then
                            self.ab_lx_task = self.inst:DoPeriodicTask(5, DoRegen, nil, self)
                        end
                        if heisewuhui_optimize > 2 then
                            if data.amount < -2 then
                                --小于-2 的才会计数
                                if not self.lastab_yishangtime then
                                    self.lastab_yishangtime = GetTime()
                                elseif (GetTime() - self.lastab_yishangtime) < 1 then
                                    --间隔1秒
                                    return
                                end
                                self.lastab_yishangtime = GetTime()
                                self.ab_yishang_health = self.ab_yishang_health + 1
                            end
                        end
                    end
                end)
                self.inst:ListenForEvent("oneat", function(_inst, data)
                    if data and data.food and data.food.prefab == "garlic" then
                        if self.ab_yishang_health > 1 then
                            self.ab_yishang_health = self.ab_yishang_health - 1
                        end
                    end
                end)
                self.inst:ListenForEvent("death", function(_inst, data)
                    self.ab_yishang_health = 0
                    if self.ab_lx_task then
                        self.ab_lx_task:Cancel()
                        self.ab_lx_task = nil
                    end
                end)
            end
        end
    end)

    if heisewuhui_optimize > 1 then
        local canheal = {
            healingsalve = true,
            tillweedsalve = true,
            bandage = true,
        }
        AddComponentPostInit("healer", function(self)
            local old_Heal = self.Heal
            function self:Heal(target, ...)
                local old = old_Heal(self, target, ...)
                if old and canheal[self.inst.prefab] and target and target.components.health and target.components.health.ab_lx_task then
                    target.components.health.ab_lx_task:Cancel()
                    target.components.health.ab_lx_task = nil
                end
                return old
            end
        end)
    end
end