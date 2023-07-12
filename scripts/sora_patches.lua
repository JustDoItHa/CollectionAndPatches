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

local soraconfig = require "soraconfig/config"


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
                if testCantPackItem(target, TUNING.CANT_PACK_ITEMS) then
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

if GetModConfigData("soraExp") then

    -- local originalExpMax = 120;
    -- local soraRemoveExpLimit = 150;
    -- --根据选项给出一个等价的初始判断值
    -- local getInitExp = function(isOut)
    --     return originalExpMax - (isOut and soraRemoveExpLimit * 0.5 or soraRemoveExpLimit);
    -- end

    -- local limit = {
    --     kill = 50,
    --     attack = 50,
    --     emote = 20,
    -- }
    AddPrefabPostInit("sora", function(inst)
        -- inst.FixExpVersion = 1
        inst:WatchWorldState("startday", function()
            -- local t = GLOBAL.TheWorld.state.cycles
            -- local olddayexp = inst.soradayexp or {}-- getexppatch
            inst.soradayexp = {}
            -- for k, v in pairs(olddayexp) do
            --     local maxexp = limit[k] or soraRemoveExpLimit
            --     if k and v and v >= (maxexp) then
            --         inst.soradayexp[k] = getInitExp(true)
            --     else
            --         inst.soradayexp[k] = getInitExp(false)
            --     end
            -- end
            -- inst.soraday = t
        end)
    end)

end

if GetModConfigData("sora_level_broke_through") then
    local upvaluehelper = require "utils/upvaluehelp_cap"
    local soralevelup_patch_l = require "soralevelup_patch"
    soraconfig.level = soralevelup_patch_l
    -- 小穹难度设置 简单 普通 困难
    --local sora_model = GLOBAL.TUNING.SORAMODE

    local sora_character_p = require "prefabs/sora" --小穹
    --local param = upvaluehelper.Set(sora_character_prefab.GetPostInitFns, "GetExp",GetExp_l)

    AddPrefabPostInit("sora", function(inst)
        local old_GetExp = upvaluehelper.Get(sora_character_p.fn,"GetExp")
        local old_applyupgrades = upvaluehelper.Get(sora_character_p.fn,"applyupgrades")
        local old_ReFreshExp = upvaluehelper.Get(sora_character_p.fn,"ReFreshExp")

        inst.GetExp = function(inst_inner, num, code, dmaxexp, once)
            -- 获得经验
            if once then
                if not inst_inner.soraonceexp[code] then
                    inst_inner.soraonceexp[code] = num
                else
                    num = 0
                end
            else
                local maxexp = dmaxexp or 120
                local t = TheWorld.state.cycles
                if (t - inst_inner.soraday) > 0 then
                    local olddayexp = inst_inner.soradayexp -- getexppatch
                    inst_inner.soradayexp = {}
                    for k, v in pairs(olddayexp) do
                        if k and v and v >= (maxexp * 0.75) then
                            inst_inner.soradayexp[k] = math.random(maxexp * 0.8, maxexp * 0.95)
                        else
                            inst_inner.soradayexp[k] = math.random(maxexp * 0.1, maxexp * 0.3)
                        end
                    end
                    inst_inner.soraday = t
                end
                if code then
                    if not inst_inner.soradayexp[code] then
                        inst_inner.soradayexp[code] = 0
                    end
                    if (inst_inner.soradayexp[code] + num > maxexp) then
                        num = math.min(math.max(0, maxexp - inst_inner.soradayexp[code]), num)
                    end
                    inst_inner.soradayexp[code] = inst_inner.soradayexp[code] + num
                end

            end
            if num == 0 then
                return
            end
            inst_inner.soraexp:set(math.max(0, inst_inner.soraexp:value() + num))
            if inst_inner.soralevel:value() < 100 and inst_inner.soraexp:value() >= soraconfig.level.expfornextlev(inst_inner.soralevel:value()) or
                    num <= 0 then
                old_applyupgrades(inst_inner, true)
                old_ReFreshExp(inst_inner)
            end
            inst_inner.soraexpget = inst_inner.soraexpget + num
            if inst_inner.soraexpget > 1000 then
                inst_inner.soraexpget = 0
                old_applyupgrades(inst_inner, true)
                old_ReFreshExp(inst_inner)
            end
            TheWorld.components.soraexpsave:SetExp(inst_inner.userid, inst_inner.soraexp:value())
        end

        -- 伤害系数  计算方式不变
        -- inst.components.combat.damagemultiplier = 0.7 + (inst.soralevel:value() * 0.02)
        -- 防御系数
        --inst.components.health.absorb = -0.3 + (inst.soralevel:value() * 0.02)
        --100百级满防御
        inst.components.health.absorb = -0.3 + (inst.soralevel:value() * 0.013)
    end)
end

if soraRemoveDeathExpByLevel > 0 then
    local old_DeathExp = soraconfig.level.DeathExp
    soraconfig.level.DeathExp = function(a)
        -- 穹一定等级后死亡不掉落经验
        if a < soraRemoveDeathExpByLevel then
            if old_DeathExp then
                return old_DeathExp(a)
            end
        else
            return 0
        end
    end
end



--[[
 --
    --local sora_level_up = require "soraconfig/soralevelup" --小穹 等级设置
    --local expneed_l = {}
    --local expdead_l = {}
    --local maxlevel_l = 100
    ----local expneed_l = upvaluehelper.Get(sora_level_up.InIt, "expneed")
    ----local expdead_l = upvaluehelper.Get(sora_level_up.InIt, "expdead")
    ----local maxlevel_l = upvaluehelper.Get(sora_level_up.InIt, "maxlevel")
    --
    --local function exptolev(a)
    --    for i = maxlevel_l, 1, -1 do
    --        if a >= expneed_l[i] then
    --            return i
    --        end
    --    end
    --    return 0
    --end
    --
    --local function expfornextlev(a)
    --    if a >= 100 then
    --        return 0
    --    elseif a < 1 then
    --        return expneed_l[1]
    --    else
    --        return expneed_l[a + 1]
    --    end
    --end
    --
    --local function expper(exp)
    --    local level = exptolev(exp)
    --    if level > 99 then
    --        return 100
    --    end
    --    local has = exp - (expneed_l[level] or 0)
    --    local next = expneed_l[level + 1] - (expneed_l[level] or 0)
    --    local per = math.floor(has / next * 20) * 5
    --    return per
    --end
    --
    --local function DeathExp(a)
    --    if a < 1 then
    --        return expdead_l[1]
    --    elseif a >= 100 then
    --        return expdead_l[100]
    --    else
    --        return expdead_l[a]
    --    end
    --end
    --local function ListExp()
    --    local a = ""
    --    local b = ""
    --    for i = 1, 100, 1 do
    --        a = a .. i .. "=" .. expneed_l[i] .. ","
    --        b = b .. i .. "=" .. expdead_l[i] .. ","
    --    end
    --end
    --
    --if sora_model == 1 then
    --    -- 1-10级 经验 = 300 * 等级
    --    -- 11-20级 经验  = 3000+500*等级
    --    -- 21-30级 经验 = 1000*等级
    --    for i = 1, 10, 1 do
    --        expneed_l[i] = 300 * i
    --        expdead_l[i] = 0
    --    end
    --    for i = 11, 20, 1 do
    --        expneed_l[i] = 500 * i - 2000
    --        expdead_l[i] = -100
    --    end
    --    for i = 21, 30, 1 do
    --        expneed_l[i] = 1000 * i - 12000
    --        expdead_l[i] = -500
    --    end
    --    --
    --    for i = 31, 100, 1 do
    --        expneed_l[i] = 1000 * i - 12000
    --        expdead_l[i] = -800
    --    end
    --
    --elseif sora_model == 2 then
    --    for i = 1, 10, 1 do
    --        expneed_l[i] = 500 * i
    --        expdead_l[i] = i > 1 and -200 or 0
    --    end
    --    for i = 11, 20, 1 do
    --        expneed_l[i] = 1500 * i - 10000
    --        expdead_l[i] = -500
    --    end
    --    for i = 21, 30, 1 do
    --        expneed_l[i] = 3000 * i - 40000
    --        expdead_l[i] = -3000
    --    end
    --
    --    --
    --    for i = 31, 100, 1 do
    --        expneed_l[i] = 3000 * i - 40000
    --        expdead_l[i] = -5000
    --    end
    --elseif sora_model == 3 then
    --    for i = 1, 10, 1 do
    --        expneed_l[i] = 1000 * i
    --        expdead_l[i] = -2000
    --    end
    --    for i = 11, 20, 1 do
    --        expneed_l[i] = 3000 * i - 20000
    --        expdead_l[i] = -5000
    --    end
    --    for i = 21, 30, 1 do
    --        expneed_l[i] = 6000 * i - 80000
    --        expdead_l[i] = -10000
    --    end
    --
    --    for i = 31, 100, 1 do
    --        expneed_l[i] = 6000 * i - 80000
    --        expdead_l[i] = -15000
    --    end
    --end
    --
    --upvaluehelper.Set(sora_level_up.fn, "exptolev", exptolev)
    --upvaluehelper.Set(sora_level_up.fn, "expfornextlev", expfornextlev)
    --upvaluehelper.Set(sora_level_up.fn, "expper", expper)
    --upvaluehelper.Set(sora_level_up.fn, "DeathExp", DeathExp)
    --upvaluehelper.Set(sora_level_up.fn, "ListExp", ListExp)
    --
    --upvaluehelper.Set(sora_level_up.InIt, "expneed", expneed_l)
    --upvaluehelper.Set(sora_level_up.InIt, "expdead", expdead_l)
    --upvaluehelper.Set(sora_level_up.InIt, "maxlevel", maxlevel_l)
]]
