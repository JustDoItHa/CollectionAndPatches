local _ = require('utils/wb_util')

local buffs_config = {}

-- ===========================================================
-- 移速
buffs_config['moving_speed'] = {
    label = "移速",
    tags = { "equippable-hands" },
    level = 1, -- 等级buff
    ismanualbuffs = false, -- 主动安装的buff
    isprizebuff = false, -- 奖励buff
    isincrease = false, -- 附魔才有
    bind_fn = function(inst, level, state, config)
        if inst.components.equippable then
            state.original_walkspeedmult = state.original_walkspeedmult or inst.components.equippable.walkspeedmult or 1
            state.level_walkspeedmult = 1 + (1 + level) / (50 + level)
            state.level_walkspeedmult = state.level_walkspeedmult - state.level_walkspeedmult % 0.01
            inst.components.equippable.walkspeedmult = math.max(state.original_walkspeedmult, state.level_walkspeedmult)
        end
    end,
    update_fn = function(inst, level, state, config)
        state.level_walkspeedmult = _.Floor(1 + (1 + level) / (50 + level), 2)
        inst.components.equippable.walkspeedmult = math.max(state.original_walkspeedmult, state.level_walkspeedmult)
    end,
    unbind_fn = function(inst, level, state, config)
        if inst.components.equippable then
            inst.components.equippable.walkspeedmult = state.original_walkspeedmult or 1
        end
    end
}
-- 伤害
buffs_config['damage'] = {
    label = "伤害",
    tags = { "weapon" },
    level = 1,
    isprizebuff = false,
    isincrease = false,
    weapon_base = 5,
    rangedattack_list = { -- 远程武器名单，不知道咋判断，只能搞名单了
        "elderwand", -- 老魔杖
    },
    bind_fn = function(inst, level, state, config)
        state.original_damage = (inst.components.weapon and inst.components.weapon.damage) or 0
        state.level_damage = 0
        inst.components.weapon.__OlbSetDamage = inst.components.weapon.SetDamage
        inst.components.weapon.SetDamage = _.Wrap(inst.components.weapon.SetDamage, function(fn, weapon, damage, ...)
            if damage ~= nil then
                state.original_damage = damage
            end
            if type(state.original_damage) == "number" then
                local damage = math.max(state.level_damage, state.original_damage)
                fn(weapon, damage, ...)
                if inst.damage ~= nil then
                    inst:DoTaskInTime(0, function()
                        inst.damage = damage
                    end) -- 覆盖魂刃，狐狸棒，光剑等升级武器显示错误
                end
            else
                fn(weapon, state.original_damage, ...)
            end
        end)
        config.update_fn(inst, level, state, config)
    end,
    update_fn = function(inst, level, state, config)
        local base = config.weapon_base or 5
        if inst.components.wb_strengthen.do_mode ~= "increase" then
            base = config.weapon_base - 1
        end
        if inst.components.weapon:CanRangedAttack() or _.Includes(config.rangedattack_list, inst.prefab) then
            base = base / 2
        end

        local level_damage = base * 2 ^ (level / 2)
        local level_damage2 = state.original_damage + (((state.original_damage * 2) - state.original_damage) * (level_damage / (state.original_damage * 2)))

        state.level_damage = _.Floor(math.max(level_damage, level_damage2), 1) -- 差异化
        inst.components.weapon:SetDamage()
    end,
    unbind_fn = function(inst, level, state, config)
        inst.components.weapon.SetDamage = inst.components.weapon.__OlbSetDamage
        inst.components.weapon.__OlbSetDamage = nil
        inst.components.weapon:SetDamage(state.original_damage)
    end
}
-- 防御
buffs_config['absorb_percent'] = {
    label = "防御",
    tags = { "armor" },
    level = 1,
    isprizebuff = false,
    isincrease = false,
    bind_fn = function(inst, level, state, config)
        state.original_absorb_percent = (inst.components.armor and inst.components.armor.absorb_percent) or 0
        state.level_absorb_percent = 0
        inst.components.armor.__OlbSetAbsorption = inst.components.armor.SetAbsorption
        inst.components.armor.SetAbsorption = _.Wrap(inst.components.armor.SetAbsorption, function(fn, armor, absorb_percent, ...)
            if absorb_percent ~= nil then
                state.original_absorb_percent = absorb_percent
            end
            return fn(armor, math.max(state.level_absorb_percent, state.original_absorb_percent), ...)
        end)
        config.update_fn(inst, level, state, config)
    end,
    update_fn = function(inst, level, state, config)
        local base = state.original_absorb_percent
        state.level_absorb_percent = _.Floor(base + (1 - base) * ((1 + level) / (10 + level)), 4)
        if state.level_absorb_percent > 1 then
            state.level_absorb_percent = 0.9999
        end
        inst.components.armor:SetAbsorption()
    end,
    unbind_fn = function(inst, level, state, config)
        inst.components.armor.SetAbsorption = inst.components.armor.__OlbSetAbsorption
        inst.components.armor.__OlbSetAbsorption = nil
        inst.components.armor:SetAbsorption(state.original_absorb_percent)
    end
}
-- ===========================================================
-- 永恒
buffs_config['eternal'] = {
    label = "永恒",
    tags = nil,
    level = 11,
    isprizebuff = false,
    isincrease = true,
    onpercentusedchange = function(inst, data)
        if inst.components.finiteuses then
            local percent = inst.components.finiteuses:GetPercent()
            if percent < 1 then
                inst.components.finiteuses:SetPercent(1)
            end
        end
        if inst.components.fueled then
            local percent = inst.components.fueled:GetPercent()
            if percent < 1 then
                inst.components.fueled:SetPercent(1)
            end
        end
        if inst.components.perishable then
            local percent = inst.components.perishable:GetPercent()
            if percent < 1 then
                inst.components.perishable:SetPercent(1)
            end
        end
    end,
    bind_fn = function(inst, level, state, config)
        inst:AddTag("hide_percentage")
        if inst.components.armor then
            inst.components.armor.indestructible = true
        end
        if inst.components.weapon then
            inst.components.weapon.attackwear = 0
        end
        if inst.components.finiteuses or inst.components.fueled then
            inst:ListenForEvent("percentusedchange", config.onpercentusedchange)
        end
        if inst.components.perishable then
            inst:ListenForEvent("perishchange", config.onpercentusedchange)
        end
    end,
    update_fn = function(inst, level, state, config)
    end,
    unbind_fn = function(inst, level, state, config)
        inst:RemoveTag("hide_percentage")
        if inst.components.armor then
            inst.components.armor.indestructible = false
        end
        if inst.components.weapon then
            inst.components.weapon.attackwear = 1
        end
        if inst.components.finiteuses or inst.components.fueled then
            inst:RemoveEventCallback("percentusedchange", config.onpercentusedchange)
        end
        if inst.components.perishable then
            inst:RemoveEventCallback("perishchange", config.onpercentusedchange)
        end
    end
}
-- ===========================================================
-- 锋利
buffs_config['attacks'] = {
    label = "锋利",
    tags = { "weapon", "equippable-hands" },
    isprizebuff = true,
    isincrease = true,
    onattackfn = function(inst, level, state, config, attacker, target, projectile)
        level = math.floor(level * (9 / 12))
        if level > 9 then
            level = 9
        end
        if target and target:IsValid() and target.components.combat and target.components.health and
                not target.components.health:IsDead() then
            target.components.combat:GetAttacked(attacker, level * 3)
        end
    end
}
-- 饮血
buffs_config['lifesteal'] = {
    label = "饮血",
    tags = { "weapon", "equippable-hands" },
    isprizebuff = true,
    isincrease = true,
    onattackfn = function(inst, level, state, config, attacker, target, projectile)
        level = math.floor(level * (9 / 12))
        if level > 9 then
            level = 9
        end
        if attacker.components.health and not attacker.components.health:IsDead() and not attacker:HasTag("playerghost") then
            attacker.components.health:DoDelta(level * 1)
        end
    end
}
-- 剧毒
buffs_config['poison'] = {
    label = "剧毒",
    tags = { "weapon", "equippable-hands" },
    isprizebuff = true,
    isincrease = true,
    onattackfn = function(inst, level, state, config, attacker, target, projectile)
        level = math.floor(level * (9 / 12))
        if level > 9 then
            level = 9
        end
        if not target.LyMagicWeaponPoisonLevel or target.LyMagicWeaponPoisonLevel < level then
            --------剧毒覆盖
            -- print("onattack_poison")
            target.LyMagicWeaponPoisonLevel = level
            if target.AnimState then
                -- target.AnimState:SetMultColour(14/255,255/255,2/255,1)------变成绿色
            end
            if not target.LyMagicWeaponPoisonFx then
                ---------毒气泡泡特效预留
                target.LyMagicWeaponPoisonFx = SpawnPrefab("poisonbubble")
                if target.LyMagicWeaponPoisonFx then
                    target.LyMagicWeaponPoisonFx.entity:SetParent(target.entity)
                    target.LyMagicWeaponPoisonFx.Transform:SetPosition(0, 0, 0)
                    if target:HasTag("smallcreature") then
                        target.LyMagicWeaponPoisonFx.Transform:SetScale(0.5, 0.5, 0.5)
                    elseif target:HasTag("largecreature") then
                        target.LyMagicWeaponPoisonFx.Transform:SetScale(1.2, 1.2, 1.2)
                    end
                end
            end
            if target.LyMagicWeaponPoisonTask then
                ------------消除旧的中毒
                target.LyMagicWeaponPoisonTask:Cancel()
                target.LyMagicWeaponPoisonTask = nil
            end
            if not target.LyMagicWeaponPoisonTask and target.components.health and not target.components.health:IsDead() and
                    not target:HasTag("wall") then
                -------------制造新的中毒
                target.LyMagicWeaponPoisonTask = target:DoPeriodicTask(1, function()
                    if target.components.health and not target.components.health:IsDead() then
                        local max = target.components.health.maxhealth
                        target.components.health:DoDelta(-max * 0.001 * level)
                    end
                end)
            end
            if target.LyMagicWeaponPoisonStopTask then
                -----------消除旧的解毒延时函数
                target.LyMagicWeaponPoisonStopTask:Cancel()
                target.LyMagicWeaponPoisonStopTask = nil
            end
            target.LyMagicWeaponPoisonStopTask = target:DoTaskInTime(10, function()
                -----------10秒后解毒
                if target.LyMagicWeaponPoisonTask then
                    ---------------停止中毒
                    target.LyMagicWeaponPoisonTask:Cancel()
                    target.LyMagicWeaponPoisonTask = nil
                end
                if target.AnimState then
                    -- target.AnimState:SetMultColour(1,1,1,1)-----变成正常颜色
                end
                if target.LyMagicWeaponPoisonFx then
                    ---------消除中毒泡泡特效
                    target.LyMagicWeaponPoisonFx:Remove()
                    target.LyMagicWeaponPoisonFx = nil
                end
                target.LyMagicWeaponPoisonLevel = nil -----------中毒等级归nil
                target.LyMagicWeaponPoisonStopTask = nil ---------解毒函数归nil
            end)
        end
    end
}
-- 重碾
buffs_config['heavy_hit'] = {
    label = "重碾",
    tags = { "weapon", "equippable-hands" },
    isprizebuff = true,
    isincrease = true,
    rands = { 3, 5, 8, 12, 15, 18, 23, 30, 40 }, -- 概率
    onattackfn = function(inst, level, state, config, attacker, target, projectile)
        level = math.floor(level * (9 / 12))
        if level > 9 then
            level = 9
        end
        local rand = config.rands[level] or config.rands[#config.rands]
        if math.random(0, 100) <= rand then
            -- print("onattack_heavy_hit")
            if target and target:IsValid() then
                local fx1 = SpawnPrefab("groundpound_fx")
                local fx2 = SpawnPrefab("groundpoundring_fx")
                local x, y, z = target:GetPosition():Get()
                fx1.Transform:SetPosition(x, y, z)
                fx2.Transform:SetPosition(x, y, z)
                fx2.Transform:SetScale(0.2, 0.2, 0.2)
                ShakeAllCameras(CAMERASHAKE.FULL, .7, .02, 1, target, 40)
                if target.brain then
                    target.brain:Stop()
                end
                if target.components.locomotor then
                    target.components.locomotor:Stop()
                end
                if target.Physics then
                    target.Physics:Stop()
                end
                if target.LyMagicWeaponHeavyHitTask then
                    target.LyMagicWeaponHeavyHitTask:Cancel()
                    target.LyMagicWeaponHeavyHitTask = nil
                end
                target.LyMagicWeaponHeavyHitTask = target:DoTaskInTime(2, function()
                    if target.brain then
                        target.brain:Start()
                    end
                end)
            end
        end
    end
}
-- 爆裂
buffs_config['explode'] = {
    label = "爆裂",
    tags = { "weapon", "equippable-hands" },
    isprizebuff = true,
    isincrease = true,
    rands = { 3, 5, 8, 12, 15, 18, 23, 30, 40 }, -- 概率
    onattackfn = function(inst, level, state, config, attacker, target, projectile)
        level = math.floor(level * (9 / 12))
        if level > 9 then
            level = 9
        end
        local rand = config.rands[level] or config.rands[#config.rands]
        if math.random(0, 100) <= rand then
            -- print("onattack_explode")
            if target and target:IsValid() then
                local x, y, z = target:GetPosition():Get()
                local ents = TheSim:FindEntities(x, y, z, 2, { "_combat" }, { "companion" })
                local damage = inst.components.weapon:GetDamage(attacker, target)
                SpawnPrefab("explode_small").Transform:SetPosition(x, y, z)
                for k, v in pairs(ents) do
                    if attacker and attacker.components.combat and attacker.components.combat:CanAttack(v) then
                        v.components.combat:GetAttacked(attacker, damage * 0.2)
                    end
                end
            end
        end
    end
}
-- 影袭
buffs_config['multhits'] = {
    label = "影袭",
    tags = { "weapon", "equippable-hands" },
    isprizebuff = true,
    isincrease = true,
    rands = { 3, 5, 8, 12, 15, 18, 23, 30, 40 }, -- 概率
    mults = { 2, 2, 3, 4, 5, 6, 7, 8, 9, 10 }, -- 影子数量
    onattackfn = function(inst, level, state, config, attacker, target, projectile)
        level = math.floor(level * (9 / 12))
        if level > 9 then
            level = 9
        end
        local rand = config.rands[level] or config.rands[#config.rands]
        local mult = config.mults[level] or config.mults[#config.mults]
        if math.random(0, 100) <= rand then
            -- if attacker.components.combat:CanAttack(target) then
            --[[print("onattack_multhits")
                local x,y,z = target:GetPosition():Get()
                local damage = inst.components.weapon.damage
                local fx = SpawnPrefab("icey_kill_fx")
                if fx then
                    fx.Transform:SetScale(2,2,2)
                    fx.Transform:SetPosition(x,y,z)
                end
                target.components.combat:GetAttacked(attacker,damage*(multhits_level_rand[level].mult - 1))--]]
            local damage = inst.components.weapon:GetDamage(attacker, target)
            local nums = mult

            local fulldamage = damage * nums
            local newnums = math.random(4, 6)
            local newdamage = fulldamage / newnums
            local roa_little = math.random() * math.pi - math.random() * 2 * math.pi

            local sleeptime = math.min(0.1, 0.4 / newnums)
            local rad = 4.5
            inst:StartThread(function()
                for roa = roa_little, 2 * math.pi + roa_little, 2 * math.pi / newnums do
                    local pos = target:GetPosition()
                    local offset = Vector3(math.cos(roa) * rad, 0, math.sin(roa) * rad)
                    local shadow = SpawnPrefab("ly_magical_shadow")
                    shadow:SetPosition(pos, offset)
                    shadow:SetDamage(newdamage)
                    shadow:SetTarget(target)
                    shadow:SetPlayer(attacker)
                    shadow:InitAnim("wilson", attacker.prefab)
                    local nx, nv, nz = (pos + offset):Get()
                    print("multhit! roa =", roa, "nx,ny,nz =", nx, nv, nz)
                    Sleep(sleeptime)
                end
            end)
            -- end
        end
    end
}
-- ===========================================================
-- 驱寒
buffs_config['anti_cold'] = {
    label = "驱寒",
    tags = { "armor" },
    isprizebuff = true,
    isincrease = true,
    bind_fn = function(inst, level, state, config)
        level = math.floor(level * (9 / 12))
        if level > 9 then
            level = 9
        end
        if not inst.components.insulator then
            inst:AddComponent("insulator")
        end
        local num, type = inst.components.insulator:GetInsulation()
        if type and type ~= SEASONS.WINTER then
            return
        end
        inst.components.insulator:SetInsulation(num + 100 + 10 * level)
    end,
    update_fn = function(inst, level, state, config)
        config.unbind_fn(inst, level, state, config)
        config.bind_fn(inst, level, state, config)
    end,
    unbind_fn = function(inst, level, state, config)
        level = math.floor(level * (9 / 12))
        if level > 9 then
            level = 9
        end
        if inst.components.insulator then
            local num, type = inst.components.insulator:GetInsulation()
            if type and type == SEASONS.WINTER then
                inst.components.insulator:SetInsulation(num - (100 + 10 * level))
            end
        end
    end
}
-- 饱食
buffs_config['anti_hunger'] = {
    label = "饱食",
    tags = { "armor" },
    isprizebuff = true,
    isincrease = true,
    onequipped = function(inst, level, state, config, data)
        local owner = data.owner
        level = math.floor(level * (9 / 12))
        if level > 9 then
            level = 9
        end
        if owner and owner.components.hunger then
            owner.components.hunger.burnratemodifiers:SetModifier("wb_strengthen", 1 - level * 0.1, "anti_hunger")
        end
    end,
    onunequipped = function(inst, level, state, config, data)
        local owner = data.owner
        if owner and owner.components.hunger then
            owner.components.hunger.burnratemodifiers:RemoveModifier("wb_strengthen", "anti_hunger")
        end
    end
}
-- 固守
buffs_config['protect'] = {
    label = "固守",
    tags = { "armor" },
    isprizebuff = true,
    isincrease = true,
    protect_carehealth = function(owner, data)
        if not owner.components.health or owner.components.health:IsDead() or owner:HasTag("playerghost") then
            return
        end
        local currenthealth = owner.components.health.currenthealth
        local armor = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
        local level = (armor and armor.components.wb_strengthen and armor.components.wb_strengthen.level)
        if not level then
            return
        end
        level = math.floor(level * (9 / 12))
        if level > 9 then
            level = 9
        end
        if not owner.ProtectCareHealthCd then
            owner.ProtectCareHealthCd = 0
        end
        local cd = owner.ProtectCareHealthCd and ((600 - 50 * level) - GetTime() + owner.ProtectCareHealthCd) or 1 -- 栈溢出
        -- print("固守buff监听主人状况", "armor:", armor, "currenthealth:", currenthealth, "CD:", cd)
        if currenthealth <= 30 and cd <= 0 then
            owner.components.health:SetPercent(1.0)
            owner.ProtectCareHealthCd = GetTime()
        end
    end,
    onequipped = function(inst, level, state, config, data)
        local owner = data.owner
        inst:ListenForEvent("healthdelta", config.protect_carehealth, owner)
    end,
    onunequipped = function(inst, level, state, config, data)
        local owner = data.owner
        inst:RemoveEventCallback("healthdelta", config.protect_carehealth, owner)
    end,
}
-- 吸收
buffs_config['absorb'] = {
    label = "吸收",
    tags = { "armor" },
    isprizebuff = true,
    isincrease = true,
    buff_absorb_persent = { 0.03, 0.05, 0.08, 0.12, 0.15, 0.18, 0.23, 0.30, 0.40 }, -- 各等级对应的伤害回血百分比
    ontakedamage = function(inst, level, state, config, damage_amount)
        level = math.floor(level * (9 / 12))
        if level > 9 then
            level = 9
        end
        local owner = inst.components.inventoryitem:GetGrandOwner()
        if math.random() <= config.buff_absorb_persent[level] and owner and owner:IsValid() and owner.components.health and
                not owner.components.health:IsDead() and not owner:HasTag("playerghost") then
            owner.components.health:DoDelta(damage_amount)
        end
    end,
}
-- 复仇 --此代码有bug，不会改，该功能修改为发光
buffs_config['anti_armor'] = {
    label = "光明",
    tags = { "armor" },
    isprizebuff = true,
    isincrease = true,
    --buff_anti_armor_percent = {0.05, 0.08, 0.12, 0.15, 0.18, 0.23, 0.26, 0.30, 0.40}, -- 反甲百分比与等级之间的关系
    --onattacked_anti_armor = function (owner, data)
    --local config = buffs_config['anti_armor']
    ---- print("onattacked_anti_armor")
    --local attacker = data.attacker
    --local damage = data.damage or 0
    --local armor = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
    --local level = (armor and armor.components.wb_strengthen and armor.components.wb_strengthen.level)
    --if not level then return end
    --level = math.floor(level * (9 / 12))
    --if level > 9 then level = 9 end
    --if attacker and attacker:IsValid() and attacker.components.health and not attacker.components.health:IsDead() and
    --attacker.components.combat and owner and damage then
    --attacker.components.combat:GetAttacked(owner, damage * config.buff_anti_armor_percent[level])
    --end
    --end,
    onequipped = function(inst, level, state, config, data)
        --local owner = data.owner
        --inst:ListenForEvent("attacked", config.onattacked_anti_armor, owner)
        if inst._light == nil or not inst._light:IsValid() then
            inst._light = SpawnPrefab("yellowamuletlight")
        end
        inst._light.entity:SetParent(data.owner.entity)
    end,
    onunequipped = function(inst, level, state, config, data)
        --local owner = data.owner
        --inst:RemoveEventCallback("attacked", config.onattacked_anti_armor, owner)
        if inst._light ~= nil then
            if inst._light:IsValid() then
                inst._light:Remove()
            end
            inst._light = nil
        end
    end,
}
-- 震荡
buffs_config['knockback'] = {
    label = "震荡",
    tags = { "armor" },
    isprizebuff = true,
    isincrease = true,
    buff_knockback_persent = { 0.03, 0.05, 0.08, 0.12, 0.15, 0.18, 0.23, 0.30, 0.40 }, -- 各等级对应的震荡概率
    timeoutrepel = function(inst, creatures, task)
        task:Cancel()
        for i, v in ipairs(creatures) do
            if v.speed ~= nil and v.inst.Physics ~= nil then
                v.inst.Physics:ClearMotorVelOverride()
                v.inst.Physics:Stop()
            end
        end
    end,
    updaterepel = function(inst, x, z, creatures, rad)
        for i = #creatures, 1, -1 do
            local v = creatures[i]
            if not (v.inst:IsValid() and v.inst.entity:IsVisible()) then
                table.remove(creatures, i)
            elseif v.speed == nil then
                local distsq = v.inst:GetDistanceSqToPoint(x, 0, z)
                if distsq < rad * rad then
                    if distsq > 0 then
                        v.inst:ForceFacePoint(x, 0, z)
                    end
                    local k = .5 * distsq / (rad * rad) - 1
                    v.speed = 25 * k
                    v.dspeed = 2
                    if v.inst.Physics then
                        v.inst.Physics:SetMotorVelOverride(v.speed, 0, 0)
                    end
                end
            else
                v.speed = v.speed + v.dspeed
                if v.speed < 0 then
                    local x1, y1, z1 = v.inst.Transform:GetWorldPosition()
                    if x1 ~= x or z1 ~= z then
                        v.inst:ForceFacePoint(x, 0, z)
                    end
                    v.dspeed = v.dspeed + .25
                    if v.inst.Physics then
                        v.inst.Physics:SetMotorVelOverride(v.speed, 0, 0)
                    end
                else
                    if v.inst.Physics then
                        v.inst.Physics:ClearMotorVelOverride()
                        v.inst.Physics:Stop()
                    end
                    table.remove(creatures, i)
                end
            end
        end
    end,
    ontakedamage = function(inst, level, state, config, damage_amount)
        level = math.floor(level * (9 / 12))
        if level > 9 then
            level = 9
        end
        local x, y, z = inst:GetPosition():Get()
        local ents = TheSim:FindEntities(x, y, z, 2.5, { "_combat" }, { "companion" })
        local owner = inst.components.inventoryitem:GetGrandOwner()
        local rad = 3
        -- print("ontakedamage_knockback")
        if not owner or math.random() > config.buff_knockback_persent[level] then
            return
        end
        -- print("ontakedamage_knockback_success!")
        for k, v in pairs(ents) do
            if v and v:IsValid() and v ~= owner and v.components.combat and v.components.health and
                    not v.components.health:IsDead() then
                -- v.components.combat:GetAttacked(owner, 1) -- 栈溢出
                -- print("ontakedamage_knockback", v)
                if v:HasTag("player") then
                    if TheNet:GetPVPEnabled() then
                        v:PushEvent("repelled", {
                            repeller = owner,
                            radius = rad
                        })
                    end
                else
                    -- print("exectuer knockback",v,rad)
                    local creatures = {}
                    if v.Physics then
                        table.insert(creatures, {
                            inst = v
                        })
                    end
                    if #creatures > 0 then
                        inst:DoTaskInTime(10 * FRAMES, config.timeoutrepel, creatures,
                                inst:DoPeriodicTask(0, config.updaterepel, nil, x, z, creatures, rad))
                    end
                end
            end
        end
    end,
}
-- ===========================================================
-- 绑定（外部手动调用)
-- self:BindBuff("bind", { userid = "userid", name = "name" })
-- self:UnBindBuff("bind")
buffs_config['bind'] = {
    label = "绑定",
    tags = { "equippable" },
    level = nil,
    ismanualbuffs = true,
    isprizebuff = false,
    isincrease = false,
    onputininventory = function(inst)
        inst:DoTaskInTime(0, function()
            local wbs = inst.components.wb_strengthen
            local state = wbs and wbs.buffs_status["bind"]
            local owner = inst.components.inventoryitem:GetGrandOwner()
            if wbs and state and owner and owner:HasTag("player") then
                -- 检查是否是正确的主人,不是的话自动掉出来
                inst:DoTaskInTime(0, function()
                    if state.userid and state.userid ~= owner.userid then
                        if owner.components.inventory then
                            owner.components.inventory:DropItem(inst, true, true)
                        end
                        owner.components.talker:Say("它在排斥我！")
                    end
                end)
            end
        end)
    end,
    bind_fn = function(inst, level, state, config)
        if not state.userid then
            return
        end
        local wbs = inst.components.wb_strengthen
        if wbs then
            inst:ListenForEvent("onputininventory", config.onputininventory)
        end
    end,
    update_fn = function(inst, level, state, config)
    end,
    unbind_fn = function(inst, level, state, config)
        inst:RemoveEventCallback("perishchange", config.onputininventory)
    end
}
-- ===========================================================
for buff_name, buff in pairs(buffs_config) do
    if buff.onattackfn then
        buff.bind_fn = function(inst, level, state, config)
            state.level = level
            if inst.components.weapon then
                local weapon = inst.components.weapon

                if weapon.__onattackfn_map == nil then
                    weapon.__onattackfn_map = {}
                end
                weapon.__onattackfn_map[buff_name] = config.onattackfn

                if weapon.__OnAttack == nil then
                    weapon.__OnAttack = weapon.OnAttack
                    weapon.OnAttack = _.Wrap(weapon.OnAttack, function(fn, weapon, attacker, target, projectile, ...)
                        fn(weapon, attacker, target, projectile, ...)
                        local inst = weapon.inst
                        if inst and inst.components.wb_strengthen and weapon.__onattackfn_map ~= nil then
                            for buff_name, onattackfn in pairs(weapon.__onattackfn_map) do
                                if onattackfn then
                                    local state = inst.components.wb_strengthen.buffs_status[buff_name]
                                    local config = buffs_config[buff_name]
                                    onattackfn(inst, state.level, state, config, attacker, target, projectile)
                                end
                            end
                        end
                    end)
                end

            end
        end
        buff.update_fn = function(inst, level, state, config)
            state.level = level
        end
        buff.unbind_fn = function(inst, level, state, config)
            if inst.components.weapon.__onattackfn_map ~= nil then
                inst.components.weapon.__onattackfn_map[buff_name] = nil
            end
        end
    elseif buff.ontakedamage then
        buff.bind_fn = function(inst, level, state, config)
            state.level = level

            if inst.__onarmordamaged_map == nil then
                inst.__onarmordamaged_map = {}
            end
            inst.__onarmordamaged_map[buff_name] = function(inst, damage_amount)
                config.ontakedamage(inst, state.level, state, config, damage_amount)
            end

            inst:ListenForEvent("armordamaged", inst.__onarmordamaged_map[buff_name])
        end
        buff.update_fn = function(inst, level, state, config)
            state.level = level
        end
        buff.unbind_fn = function(inst, level, state, config)
            if inst.__onarmordamaged_map and inst.__onarmordamaged_map[buff_name] then
                inst:RemoveEventCallback("perishchange", inst.__onarmordamaged_map[buff_name])
                inst.__onarmordamaged_map[buff_name] = nil
            end
        end
    elseif buff.onequipped and buff.onunequipped then
        buff.bind_fn = function(inst, level, state, config)
            state.level = level

            if inst.__onequipped_map == nil then
                inst.__onequipped_map = {}
            end
            if inst.__onunequipped_map == nil then
                inst.__onunequipped_map = {}
            end

            inst.__onequipped_map[buff_name] = function(inst, ...)
                return buff.onequipped(inst, level, state, config, ...)
            end
            inst.__onunequipped_map[buff_name] = function(inst, ...)
                return buff.onunequipped(inst, level, state, config, ...)
            end

            inst:ListenForEvent("equipped", inst.__onequipped_map[buff_name])
            inst:ListenForEvent("unequipped", inst.__onunequipped_map[buff_name])
        end
        buff.update_fn = function(inst, level, state, config)
            state.level = level
        end
        buff.unbind_fn = function(inst, level, state, config)
            if inst.__onequipped_map and inst.__onequipped_map[buff_name] then
                inst:RemoveEventCallback("equipped", inst.__onequipped_map[buff_name])
                inst.__onequipped_map[buff_name] = nil
            end
            if inst.__onunequipped_map and inst.__onunequipped_map[buff_name] then
                inst:RemoveEventCallback("equipped", inst.__onunequipped_map[buff_name])
                inst.__onunequipped_map[buff_name] = nil
            end
        end
    end
end

local level_buffs_config = {} -- 升级自动添加的buff
local prize_buffs_config = {} -- 附魔自动添加的buff
for buff_name, buff in pairs(buffs_config) do
    if buff.ismanualbuffs ~= true then
        if buff.level ~= nil and buff.isprizebuff ~= true then
            level_buffs_config[buff_name] = buff
        end
        if buff.isprizebuff == true then
            prize_buffs_config[buff_name] = buff
        end
    end
end
-- ===========================================================

local WbStrengthen = Class(function(self, inst)
    self.inst = inst

    self.original_name = self.inst:GetDisplayName() or STRINGS.NAMES[string.upper(self.inst.prefab)] or self.inst.name

    self.level = 0
    self.do_mode = nil
    self.buffs_status = {}
    self.prize_buff_list = {}
    self.manual_buff_list = {}

    self.inst:AddTag("wb_strengthen")

    if not TheWorld.ismastersim then
        return
    end

    if not self.inst.components.named then
        self.inst:AddComponent("named")
    end

    -- 显示强化名字
    self.inst.components.named.SetName = _.Wrap(self.inst.components.named.SetName, function(fn, named, name, ...)
        if (name == nil) then
            name = self.original_name
        end
        fn(named, name, ...)
        self.original_name = named.name
        if self.inst.components.wb_strengthen then
            name = inst.components.wb_strengthen:GetDisplayName(named.name)
            fn(named, name, ...)
        end
    end)

    self:SetLevel(self.level)
end)

-- 配置
WbStrengthen.BUFFS_CONFIG = buffs_config

function WbStrengthen:OnSave()
    return {
        do_mode = self.do_mode,
        level = self.level,
        original_name = self.original_name,
        buffs_status = self.buffs_status,
        prize_buff_list = self.prize_buff_list,
        manual_buff_list = self.manual_buff_list,
    }
end

function WbStrengthen:OnLoad(data)
    if data then
        if data.do_mode ~= nil then
            self.do_mode = data.do_mode
        end
        if data.level ~= nil then
            self.level = data.level
        end
        if data.original_name ~= nil then
            self.original_name = data.original_name
        end
        if data.buffs_status ~= nil then
            self.buffs_status = data.buffs_status
        end
        if data.prize_buff_list ~= nil then
            self.prize_buff_list = data.prize_buff_list
        end
        self:SetLevel(self.level)
        if data.manual_buff_list ~= nil then
            -- self.manual_buff_list = data.manual_buff_list
            for index, buff_name in ipairs(data.manual_buff_list) do
                self:BindBuff(buff_name, self.buffs_status[buff_name] or {})
            end
        end
    end
end

-- 获取显示名称
function WbStrengthen:GetDisplayName(name)
    if name ~= nil then

        local namestr = name

        if self.level ~= nil and self.level > 0 then
            namestr = ((self.do_mode == "increase" and "附魔") or "强化") .. "+" .. self.level .. " " .. name
        end

        if #self.prize_buff_list > 0 then
            namestr = namestr .. '\n被动：'
            for i, buff_name in ipairs(self.prize_buff_list) do
                local buff = buffs_config[buff_name]
                if buff and buff.isprizebuff == true then
                    namestr = namestr .. ' ' .. buff.label
                end
            end
        end

        if self:HasBuff("bind") then
            local state = self.buffs_status["bind"]
            if state.name then
                namestr = state.name .. '的 ' .. namestr
            end
        end

        return namestr
    end

    return name
end

-- 刷新状态
function WbStrengthen:Refresh()
    -- 脱下装备再换上，刷新状态
    if not self.inst.components.inventoryitem then
        return
    end
    local owner = self.inst.components.inventoryitem:GetGrandOwner()
    if owner and (self.inst.components.equippable and self.inst.components.equippable:IsEquipped()) then
        self.inst.components.equippable:Unequip(owner)
        self.inst:DoTaskInTime(0, function()
            self.inst.components.equippable:Equip(owner)
        end)
    end
    if self.inst.components.named then
        self.inst.components.named:SetName()
    end
end

-- BUFF 标签
function WbStrengthen:GetBuffTag(buff_name)
    return "wb_strengthenstove_buff_" .. buff_name
end

-- 是否有BUFF
function WbStrengthen:HasBuff(buff_name)
    return self.inst:HasTag(self:GetBuffTag(buff_name))
end

-- 安装BUFF
function WbStrengthen:BindBuff(buff_name, status)
    if self:HasBuff(buff_name) then
        return self:UpdateBuff(buff_name, status)
    end
    local buff = buffs_config[buff_name]
    if buff ~= nil and buff.bind_fn then
        if self.buffs_status[buff_name] == nil then
            self.buffs_status[buff_name] = {}
        end
        if status ~= nil then
            for key, value in pairs(status) do
                self.buffs_status[buff_name][key] = value
            end
        end
        buff.bind_fn(self.inst, self.level, self.buffs_status[buff_name], buff)
        self.inst:AddTag(self:GetBuffTag(buff_name))
        if buff.ismanualbuffs then
            table.insert(self.manual_buff_list, buff_name)
        end
    end
    self:Refresh()
end

-- 更新BUFF
function WbStrengthen:UpdateBuff(buff_name, status)
    if not self:HasBuff(buff_name) then
        return self:BindBuff(buff_name, status)
    end
    local buff = buffs_config[buff_name]
    if buff == nil then
        return
    end
    if status ~= nil then
        if self.buffs_status[buff_name] == nil then
            self.buffs_status[buff_name] = {}
        end
        for key, value in pairs(status) do
            self.buffs_status[buff_name][key] = value
        end
    end
    if buff.update_fn then
        buff.update_fn(self.inst, self.level, self.buffs_status[buff_name], buff)
    end
    self:Refresh()
end

-- 卸载BUFF
function WbStrengthen:UnBindBuff(buff_name)
    local buff = buffs_config[buff_name]
    if buff ~= nil and buff.unbind_fn then
        buff.unbind_fn(self.inst, self.level, self.buffs_status[buff_name] or {}, buff)
        self.inst:RemoveTag(self:GetBuffTag(buff_name))
        if self.buffs_status[buff_name] ~= nil then
            self.buffs_status[buff_name] = nil
        end
        if buff.ismanualbuffs then
            local index = _.IndexOf(self.manual_buff_list, buff_name)
            if index and index >= 1 then
                table.remove(self.manual_buff_list, index)
            end
        end
    end
    self:Refresh()
end

function WbStrengthen:GetLevel()
    if self.level then
        return self.level
    else
        return 0
    end
end

-- 设置等级, 默认非作弊，13级卷轴仅控制台可出，可以加全BUFF
function WbStrengthen:SetLevel(level, cheating)
    if nil == cheating then
        cheating = false
    end

    self.level = level

    if level > 0 and self.do_mode == nil then
        self.do_mode = 'strengthen'
    end

    -- 强化只能13级？老纠结了~早知道不搞强化了
    if self.do_mode == 'strengthen' and level > 13 then
        self.level = 13
    end

    -- 等级BUFF
    for buff_name, buff in pairs(level_buffs_config) do
        local hasTag = buff.tags == nil or _.Every(buff.tags, function(tag)
            return self.inst:HasTag(tag)
        end)
        if hasTag and ((buff.isincrease == true and self.do_mode == "increase") or true) then
            if self.level < buff.level then
                if self:HasBuff(buff_name) then
                    self:UnBindBuff(buff_name)
                end
            else
                if self:HasBuff(buff_name) then
                    self:UpdateBuff(buff_name)
                else
                    self:BindBuff(buff_name)
                end
            end
        end
    end

    -- 奖励buff
    local due_prize_buff_count = math.floor(self.level / 2) -- 可以拥有多少奖励BUFF（每次升级26%概率随机奖励一buff）
    if due_prize_buff_count > #self.prize_buff_list then
        local surplus_buff_list = {}
        for buff_name, buff in pairs(prize_buffs_config) do
            local checklevel = (buff.level ~= nil and buff.level >= self.level) or true -- 检查是否满足等级
            local checkincrease = buff.isincrease ~= true or self.do_mode == "increase" -- 检查是否附魔才可以
            local checkhastag = buff.tags == nil or _.Every(buff.tags, function(tag)
                return self.inst:HasTag(tag)
            end) -- 检查是否有标签
            local checkexistence = _.Includes(self.prize_buff_list, buff_name) ~= true -- 检查有没有已经存在
            local possible = 0.05 -- 26%概率,根据古典概率模型计算
            if cheating then
                possible = 1
            end
            if checklevel and checkincrease and checkhastag and checkexistence and math.random() < possible then
                table.insert(surplus_buff_list, buff_name)
                if not cheating then
                    break
                end
            end
        end
        local count = due_prize_buff_count - #self.prize_buff_list
        while count > 0 and #surplus_buff_list > 0 do
            local index = math.random(1, #surplus_buff_list)
            table.insert(self.prize_buff_list, surplus_buff_list[index])
            table.remove(surplus_buff_list, index)
            count = count - 1
        end
    elseif due_prize_buff_count < #self.prize_buff_list then
        local count = #self.prize_buff_list - due_prize_buff_count
        while count > 0 do
            local index = math.random(1, #self.prize_buff_list)
            table.remove(self.prize_buff_list, index)
            count = count - 1
        end
    end

    for buff_name, buff in pairs(prize_buffs_config) do
        if _.Includes(self.prize_buff_list, buff_name) then
            if self:HasBuff(buff_name) then
                self:UpdateBuff(buff_name)
            else
                self:BindBuff(buff_name)
            end
        elseif self:HasBuff(buff_name) then
            self:UnBindBuff(buff_name)
        end
    end

    self:Refresh()

end

-- 说话
function WbStrengthen:DoSay(player, do_mode, do_level, is_success)
    if not player or not player.components.talker then
        return
    end
    local mode_str = (self.do_mode == "increase" and "附魔") or "强化"
    if is_success == true then
        player.components.talker:Say(mode_str .. '+' .. do_level .. ' 成功！', 2.5, true, true, false, { 1, 0.33, 0.33, 1 })
    else
        if do_level >= 11 then
            player.components.talker:Say(mode_str .. '+' .. do_level .. ' 失败，咦？我的装备呢！', 2.5, true, true, false, { 0, 0, 0, 1 })
        else
            player.components.talker:Say(mode_str .. '+' .. do_level .. ' 失败！', 2.5, true, true, false, { 0, 0, 0, 1 })
        end
    end
end

-- 成功
function WbStrengthen:DoSuccess(player, do_mode, do_level, sayfn)
    self.do_mode = do_mode
    local mode_str = (self.do_mode == "increase" and "附魔") or "强化"
    self:SetLevel(do_level)
    if do_level >= 13 then
        local list = { '我欲问鼎天下,试问谁与争锋', '有朝一日虎归山,定要血染半边天', '纵横天地，心随我意', '我自横刀向天笑 去留肝胆两昆仑', '四海翻腾云水怒,五洲震荡风雷激', '十步一杀人，千里不留行', '一身转战三千里，一剑曾当百万师', '春来我不先开口，哪个虫儿敢做声', '誓将寸管化长剑， 杀尽世间狼与豺', '圣书万卷任纵横， 常觉心源极有灵' }
        local index = math.random(#list)
        TheNet:Announce(player.name .. ' ' .. mode_str .. '+' .. do_level .. ' ' .. self.original_name .. ' 成功！' .. list[index])
    elseif do_level >= 12 then
        TheNet:Announce(player.name .. ' ' .. mode_str .. '+' .. do_level .. ' ' .. self.original_name .. ' 成功')
    end
    if sayfn then
        sayfn(self, player, do_mode, do_level, true)
    else
        self:DoSay(player, do_mode, do_level, true)
    end
end

-- 失败
function WbStrengthen:DoFail(player, do_mode, do_level, sayfn)
    self.do_mode = do_mode
    local mode_str = (self.do_mode == "increase" and "附魔") or "强化"
    if do_mode == "strengthen" then
        if do_level >= 11 then
            self:SetLevel(0)
            self.inst:Remove() -- self.inst = nil
        elseif do_level >= 10 then
            self:SetLevel(0)
        elseif do_level >= 7 then
            self:SetLevel(self.level - 1)
        end
    elseif do_mode == "increase" then
        if do_level >= 11 then
            self:SetLevel(0)
            self.inst:Remove() -- self.inst = nil
        elseif do_level >= 8 then
            self:SetLevel(0)
        elseif do_level >= 5 then
            self:SetLevel(self.level - 1)
        end
    end
    if sayfn then
        sayfn(self, player, do_mode, do_level, false)
    else
        self:DoSay(player, do_mode, do_level, false)
    end
    if do_level >= 12 then
        TheNet:Announce(player.name .. ' ' .. mode_str .. '+' .. do_level .. ' ' .. self.original_name .. ' 失败')
    end
end

-- 获取概率
function WbStrengthen:GetProbability(player, do_mode, level)
    if do_mode == "increase" then
        return 1 * (0.9 ^ level)
    end
    return 1.05 * (0.9 ^ level)
end

-- 强化
function WbStrengthen:DoStrengthen(player, sayfn)
    self.do_player = player
    if self.level <= 0 or self.do_mode == nil or self.do_mode == 'strengthen' then
        self.do_mode = 'strengthen'
        local next_level = self.level + 1
        local probability = self:GetProbability(player, self.do_mode, next_level)
        if math.random() < probability then
            self:DoSuccess(player, self.do_mode, next_level, sayfn)
        else
            self:DoFail(player, self.do_mode, next_level, sayfn)
        end
    end
    self.do_player = nil
end

-- 附魔
function WbStrengthen:DoIncrease(player, sayfn)
    self.do_player = player
    if self.level <= 0 or self.do_mode == nil or self.do_mode == 'increase' then
        self.do_mode = 'increase'
        local next_level = self.level + 1
        local probability = self:GetProbability(player, self.do_mode, next_level)
        if math.random() < probability then
            -- if math.random() < 1 then
            self:DoSuccess(player, self.do_mode, next_level, sayfn)
        else
            self:DoFail(player, self.do_mode, next_level, sayfn)
        end
    end
    self.do_player = nil
end

-- a = ThePlayer.replica.inventory:GetItems()
-- a[1].components.wb_strengthen:SetLevel(12)

return WbStrengthen
