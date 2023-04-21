---来自zy'mod
---+修改
local EquipmentSelector = require("widgets/soraequipmentselectscreen")

local soraRemoveDeathExpByLevel = GetModConfigData("soraRemoveDeathExpByLevel") or -1;
local soraRemoveRollExpByLevel = GetModConfigData("soraRemoveRollExpByLevel") or -1;
local soraHealDeath = GetModConfigData("soraHealDeath") or false;
local soraRepairerToPhilosopherStoneLimit = GetModConfigData("soraRepairerToPhilosopherStoneLimit") or 0;
local soraFastMaker = GetModConfigData("soraFastMaker") or false;
local soraDoubleMaker = GetModConfigData("soraDoubleMaker") or -1;
local soraPackLimit = GetModConfigData("soraPackLimit") or false;
local soraPackFL = GetModConfigData("soraPackFL") or false;
local sorafl_select = GetModConfigData("sorafl_select") or false;


local soraconfig = require "config/config"
if soraRemoveDeathExpByLevel > 0 then
    local old_DeathExp = soraconfig.level.DeathExp
    soraconfig.level.DeathExp = function(a)
        -- 穹一定等级后死亡不掉落经验
        if a < soraRemoveDeathExpByLevel then
            if old_DeathExp then return old_DeathExp(a) end
        else
            return 0
        end
    end
end

if soraRemoveRollExpByLevel > 0 then
    -- 穹换人不掉落经验
    AddComponentPostInit("soraexpsave", function(self)
        function self:GetExp(userid)
            local exptolev = soraconfig.level.exptolev
            local level = exptolev(self.exps[userid] or 0);
            local loseExp = level >= soraRemoveRollExpByLevel and 0 or 1000;
            return userid and self.exps[userid] and math.max(0, self.exps[userid] - loseExp) or -1
        end
    end)
end

-- if soraRemoveDeathExpByLevel > 0 then
--     -- 穹一定等级后死亡不掉落经验
--     AddPrefabPostInit('sora', function(inst)
--         if not __DeathExp and GLOBAL.DeathExp then
--             __DeathExp = GLOBAL.DeathExp
--             GLOBAL.DeathExp = function(a)
--                 if a >= soraRemoveDeathExpByLevel then
--                     return 0
--                 end
--                 return __DeathExp(a)
--             end
--         end
--     end)
-- end

-- if soraRemoveRollExpByLevel > 0 then
--     -- 穹2换人不掉落经验
--     AddComponentPostInit("soraexpsave",
--             function(self)
--                 function self:GetExp(userid)
--                     local level = GLOBAL.exptolev(self.exps[userid] or 0);
--                     local loseExp = level >= soraRemoveRollExpByLevel and 0 or 1000;
--                     return userid and self.exps[userid] and math.max(0, self.exps[userid] - loseExp) or -1
--                 end
--             end
--     )
-- end

if soraHealDeath then
    local heal = function(inst)
        --怪物冰冻
        if inst._heal then
            local pos = inst:GetPosition()
            local entc = TheSim:FindEntities(pos.x, pos.y, pos.z, 4, nil, { "player", "sora2lm" })
            for i, v in ipairs(entc) do
                if v:IsValid() and v.entity:IsVisible() and not v:IsInLimbo() and v.components.health and v.components.health:IsDead() then
                    v.components.health:DoDelta(30)
                end
            end
        end
    end

    -- 穹愈可以治疗死人
    AddPrefabPostInit("sorahealstar", function(inst)
        local oldStart = inst.Start;
        inst.Start = function(inst, ...)
            oldStart(inst, ...)
            inst:DoPeriodicTask(0.5, heal)
        end
    end)
end

if soraRepairerToPhilosopherStoneLimit > 0 then
    --缝纫包
    AddComponentPostInit("sorarepairer",
            function(self)
                local oldDoRepair = self.DoRepair;
                function self:DoRepair(inst, target, doer)
                    if target.prefab == "philosopherstone" then
                        target.components.finiteuses:Use(-1 * math.max(math.ceil(soraRepairerToPhilosopherStoneLimit * target.components.finiteuses.total), 5))
                        doer:PushEvent("sorarepair", { inst = inst, target = target, doer = doer, type = "finiteuses" })
                        return true;
                    else
                        return oldDoRepair(self, inst, target, doer)
                    end
                end
            end
    )
end

if soraFastMaker then
    --快速制作
    AddStategraphPostInit("wilson", function(sg)
        local state_domediumaction = sg.states["domediumaction"]
        state_domediumaction.onenter = function(inst)
            local isSora = inst:HasTag("sora");
            local isEquipSora2amulet = inst.soratasgs and not isSora; --使用飞云术
            local isEquipHandyCertificate = inst.components.inventory
                    and inst.components.inventory.EquipMedalWithName
                    and inst.components.inventory:EquipMedalWithName("handy_certificate")
            local soraLevel = 0;
            local timeout = .5
            if isSora and isEquipHandyCertificate and inst.soralevel ~= nil then
                soraLevel = inst.soralevel:value();
                if soraLevel > 29 then
                    timeout = 2 * GLOBAL.FRAMES
                else
                    timeout = 5 * GLOBAL.FRAMES
                end
            elseif isEquipSora2amulet and isEquipHandyCertificate then
                timeout = 10 * GLOBAL.FRAMES
            end
            inst.sg:GoToState("dolongaction", timeout)
        end
    end)
end

if soraDoubleMaker > 0 then
    local function GiveOrDropItem(inst, recipe, item, pt)
        if recipe.dropitem then
            local angle = (inst.Transform:GetRotation() + GLOBAL.GetRandomMinMax(-65, 65)) * GLOBAL.DEGREES
            local r = item:GetPhysicsRadius(0.5) + inst:GetPhysicsRadius(0.5) + 0.1
            item.Transform:SetPosition(pt.x + r * math.cos(angle), pt.y, pt.z - r * math.sin(angle))
            item.components.inventoryitem:OnDropped()
        else
            inst.components.inventory:GiveItem(item, nil, pt)
        end
    end
    -- 30级双倍制作
    local function onbuilditem(inst, data)
        if inst:HasTag("sora") and inst.soralevel:value() >= soraDoubleMaker then
            local recipe = data.recipe;
            local skin = data.skin;
            local prod = GLOBAL.SpawnPrefab(recipe.product, recipe.chooseskin or skin, nil, inst.userid) or nil;
            if prod ~= nil then
                local pt = inst:GetPosition()
                if prod.components.inventoryitem ~= nil then
                    if inst.components.inventory ~= nil then
                        if recipe.numtogive <= 1 then
                            GiveOrDropItem(inst, recipe, prod, pt)
                        elseif prod.components.stackable ~= nil then
                            --The item is stackable. Just increase the stack size of the original item.
                            prod.components.stackable:SetStackSize(recipe.numtogive)
                            GiveOrDropItem(inst, recipe, prod, pt)
                        else
                            GiveOrDropItem(inst, recipe, prod, pt)
                            for i = 1, recipe.numtogive do
                                local addt_prod = GLOBAL.SpawnPrefab(recipe.product)
                                GiveOrDropItem(inst, recipe, addt_prod, pt)
                            end
                        end
                    end
                end
            end
        end
    end

    AddPrefabPostInit("sora", function(inst)
        inst:ListenForEvent("builditem", onbuilditem)
    end)
end

if soraPackLimit then
    local packPostInit = function(inst)
        if inst and inst.components and inst.components.sorapacker then
            local oldCanPackFn = inst.components.sorapacker.canpackfn
            inst.components.sorapacker:SetCanPackFn(function(target, inst2)
                if target:HasTag("multiplayer_portal") --天体门
                        or target.prefab == "pigking" --猪王
                        or target.prefab == "antlion" --蚁狮
                        or target.prefab == "crabking" --帝王蟹
                        or target.prefab == "beequeenhivegrown" --蜂王窝-底座
                        or target.prefab == "statueglommer" --格罗姆雕像
                        or target.prefab == "oasislake" --绿洲
                        or target.prefab == "archive_switch"--档案馆华丽的基座
                        or target.prefab == "archive_portal"--档案馆传送门
                        or target.prefab == "archive_lockbox_dispencer"--知识饮水器
                        or target.prefab == "archive_centipede"--远古哨兵蜈蚣
                        or target.prefab == "archive_centipede_husk"--远古哨兵壳
                        or target.prefab == "atrium_gate"--远古大门
                        or target.prefab == "monkeyqueen"--月亮码头女王
                        or target.prefab == "monkeyisland_portal"--非自然传送门


                        or target.prefab == "toadstool_cap"--毒菌蟾蜍蘑菇

                        or target.prefab == "elecourmaline" --电器台
                        or target.prefab == "elecourmaline_keystone" --
                        or target.prefab == "moondungeon" --月的地下城
                        or target.prefab == "siving_thetree" --子圭神木岩

                        or target.prefab == "myth_rhino_desk"--三犀牛台
                        or target.prefab == "myth_chang_e"--嫦娥
                        or target.prefab == "myth_store"--小店
                        or target.prefab == "myth_store_construction"--未完成的小店
                        or target.prefab == "myth_shop"--小店
                        or target.prefab == "myth_shop_animals"
                        or target.prefab == "myth_shop_foods"
                        or target.prefab == "myth_shop_ingredient"
                        or target.prefab == "myth_shop_numerology"
                        or target.prefab == "myth_shop_plants"
                        or target.prefab == "myth_shop_rareitem"
                        or target.prefab == "myth_shop_weapons"

                        or target.prefab == "medal_spacetime_devourer"--时空吞噬者

                        or target.prefab == "star_monv"--星辰魔女 
                        or target.prefab == "elaina_npc_qp" --星辰魔女对话框

                        or target.prefab == "ntex_other_lz" --逆天而行修仙龙柱
                then
                    return false;
                else
                    return oldCanPackFn(target, inst2);
                end
            end)
        end
    end
    AddPrefabPostInit("sorapacker", packPostInit)
end

if soraPackFL and sorafl_select then
    AddClassPostConstruct("screens/playerhud", function(self)
        self.ShowEquipmentSelector = function()
            local sor_fl
            local x, y, z = self.owner.Transform:GetWorldPosition()
            local ent = TheSim:FindEntities(x, y, z, 2, { "plant" })
            for _, v in pairs(ent) do
                if v.prefab == "sora_fl" and v:HasTag(self.owner.userid) then
                    sor_fl = v
                    break
                end
            end
            self.equipmentselector = EquipmentSelector(self.owner, sor_fl)
            self:OpenScreenUnderPause(self.equipmentselector)
            return self.equipmentselector
        end
    end)
    AddPlayerPostInit(function(inst)
        if inst:HasTag("sora") then
            inst._soraeqselect = net_bool(inst.GUID, "soraeqselect",
                    "soraeqselectdirty")
            inst:ListenForEvent("soraeqselectdirty", function()
                if inst.HUD then
                    inst.HUD:ShowEquipmentSelector(inst)
                end
            end)
        end
    end)
    AddComponentPostInit("sorafllink", function(self)
        self.newLink = self.Link
        self.Link = function(s, doer)
            if not (doer:HasTag("sora") and not self.link) then
                return
            end
            doer._soraeqselect:set(true)
            doer._soraeqselect:set_local(false)
        end
    end)
    local function checkequipment(equipment)
        local equipments = {
            "soratele", "sorapick", "soramagic", "sorahealing", "soraclothes",
            "sorahat", "sorabowknot"
        }
        for _, v in pairs(equipments) do
            if v == equipment then
                return true
            end
        end
        return false
    end
    AddModRPCHandler("SoraPatch", "SoraEQSelect",
            function(player, sora_fl, equipment)
                if player and sora_fl and sora_fl:HasTag(player.userid) then
                    if checkequipment(equipment) and not sora_fl.components.sorafllink.link then
                        sora_fl.components.sorafllink.item = equipment
                    end
                    sora_fl.components.sorafllink:newLink(player)
                end
            end)
end

if soraPackFL then
    AddComponentPostInit("sorafl", function(self)
        local oldInit = self.Init;
        function self:Init()
            if not self.has then
                local fl = GLOBAL.SpawnPrefab("sora_fl")
                fl.components.sorabind:Bind(self.inst.userid)
                local pack = GLOBAL.SpawnPrefab("sorapacker")
                local valid = false;
                if pack and pack.components.sorapacker:Pack(fl, self.inst, true) then
                    self.inst.components.inventory:GiveItem(pack)
                    valid = true
                end
                if valid then
                    self.has = true
                    return fl
                else
                    if fl and fl.Remove then
                        fl:Remove()
                    end
                    if pack and pack.Remove then
                        pack:Remove()
                    end
                    return oldInit(self)
                end
            end
        end
    end)
end

local originalExpMax = 120;
local soraRemoveExpLimit = 150;
--根据选项给出一个等价的初始判断值
local getInitExp = function(isOut)
    return originalExpMax - (isOut and soraRemoveExpLimit * 0.5 or soraRemoveExpLimit);
end

local limit = {
    kill = 50,
    attack = 50,
    emote = 20,
}
AddPrefabPostInit("sora", function(inst)
    inst.FixExpVersion = 1
    inst:WatchWorldState("startday", function()
        local t = GLOBAL.TheWorld.state.cycles
        local olddayexp = inst.soradayexp or {}-- getexppatch
        inst.soradayexp = {}
        for k, v in pairs(olddayexp) do
            local maxexp = limit[k] or soraRemoveExpLimit
            if k and v and v >= (maxexp) then
                inst.soradayexp[k] = getInitExp(true)
            else
                inst.soradayexp[k] = getInitExp(false)
            end
        end
        inst.soraday = t
    end)
end)






