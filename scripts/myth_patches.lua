GLOBAL.setmetatable(env, {__index = function(t, k)return GLOBAL.rawget(GLOBAL, k)end})

local upvaluehelper = require "components/upvaluehelper"
local containers = require "containers"
local cooking = require "cooking"
local _G = GLOBAL
local mythBlackBearRockClearTime = GetModConfigData("mythBlackBearRockClearTime") or 0
--local mythFlyingSpeedMultiplier = GetModConfigData("mythFlyingSpeedMultiplier") or 0

local function findentity(prefabname)
    for k, v in pairs(Ents) do
        if v.prefab == prefabname then
            return v
        end
    end
end

local myth_tips = {
    myth_honeypot = {
        zhsname = "黑熊大王",
        timername = "blackbear",
        tips = false
    },
    myth_rhino_desk = {
        zhsname = "犀牛三大王",
        timername = "cd",
        tips = false
    },
    myth_goldfrog_spawner = {
        zhsname = "聚宝金蟾",
        timername = "regen_myth_forg",
        tips = false
    }
}

local timeleft_tips = GetModConfigData("timeleft_tips")
local tip_key = GetModConfigData("tip_key")
local blackbear_respawn = GetModConfigData("blackbear_respawn")
local rhino_respawn = GetModConfigData("rhino_respawn")
local regen_myth_forg_respawn = GetModConfigData("regen_myth_forg_respawn")
local laozi_trade_num = GetModConfigData("laozi_trade_num")
local granary_not_rot = GetModConfigData("granary_not_rot")
local granary_save_fruit = GetModConfigData("granary_save_fruit")

if blackbear_respawn ~= 20 then
    AddPrefabPostInit("myth_honeypot", function(inst)
        if inst.components.container then
            local onclosefn = inst.components.container.onclosefn
            inst.components.container.onclosefn = function(inst)
                onclosefn(inst)
                if inst.components.timer:TimerExists("blackbear") then
                    local cdtimeleft = inst.components.timer:GetTimeLeft("blackbear")
                    if cdtimeleft > blackbear_respawn * 480 then
                        inst.components.timer:SetTimeLeft("blackbear", blackbear_respawn * 480)
                        myth_tips.myth_honeypot.tips = false
                    end
                end
            end
        end
    end)
end

if rhino_respawn ~= 50 then
    AddPrefabPostInit("myth_rhino_desk", function(inst)
        inst:WatchWorldState("phase", function(inst)
            if inst.components.timer and inst.components.timer:TimerExists("cd") then
                local cdtimeleft = inst.components.timer:GetTimeLeft("cd")
                if cdtimeleft > rhino_respawn * 480 then
                    inst.components.timer:SetTimeLeft("cd", rhino_respawn * 480)
                    myth_tips.myth_rhino_desk.tips = false
                end
            end
        end)
    end)
end

if regen_myth_forg_respawn ~= 20 then
    AddPrefabPostInit("myth_goldfrog_spawner", function(inst)
        if inst.components.childspawner ~= nil then
            inst.components.childspawner.onchildkilledfn = function(inst)
                inst.components.timer:StartTimer("regen_myth_forg", 480 * regen_myth_forg_respawn)
            end
        end
    end)
end

if timeleft_tips ~= 1 then
    local tipsfn = function()
        for key, value in pairs(myth_tips) do
            local ent = findentity(key)
            if ent then
                if ent.components.timer then
                    if ent.components.timer:TimerExists(value.timername) then
                        local timeleft = ent.components.timer:GetTimeLeft(value.timername)
                        if not value.tips and timeleft < 480 then
                            local minute = math.ceil(timeleft / 60)
                            local second = math.ceil(timeleft % 60)
                            TheNet:Announce(value.zhsname .. " 还剩 " .. minute .. ":" .. second .. " 刷新")
                            value.tips = true
                        end
                        if value.tips and timeleft <= 5 then
                            TheNet:Announce(value.zhsname .. " 还剩 " .. math.floor(timeleft) .. "s 刷新")
                        end
                    end
                end
            end
        end
    end

    if timeleft_tips == 2 then
        AddPrefabPostInit("world", function(inst)
            tipsfn()
            inst:DoPeriodicTask(1, tipsfn)
        end)
    elseif timeleft_tips == 3 then
        local keytipsfn = function()
            for key, value in pairs(myth_tips) do
                local ent = findentity(key)
                if ent then
                    if ent.components.timer then
                        if ent.components.timer:TimerExists(value.timername) then
                            local timeleft = ent.components.timer:GetTimeLeft(value.timername)
                            local minute = math.ceil(timeleft / 60)
                            local second = math.ceil(timeleft % 60)
                            TheNet:Announce(value.zhsname .. " 还剩 " .. minute .. ":" .. second .. " 刷新")
                        else
                            TheNet:Announce(value.zhsname .. " 已经刷新了")
                        end
                    end
                end
            end
        end
        AddModRPCHandler("myth_patches", "tips", function(player)
            keytipsfn()
        end)
        TheInput:AddKeyHandler(function(key, down)
            if down then
                if key == tip_key then
                    SendModRPCToServer(MOD_RPC["myth_patches"]["tips"])
                end
            end
        end)
    end
end

-- 代码来自神话模组源码，感谢神话码师提供的方法

if laozi_trade_num > 1 then
    AddPrefabPostInit("laozi", function(inst)
        if not TheWorld.ismastersim then return inst end

        inst.trade_num = {}
        if inst.components.trader then
            local _onaccept = inst.components.trader.onaccept
            inst.components.trader.onaccept = function(inst, giver, item)
                if inst.trade_num[giver.userid] and inst.trade_num[giver.userid] >= laozi_trade_num then
                    inst.components.talker:Say(STRINGS.LAOZI.A)
                    return false
                end
                _onaccept(inst, giver, item)
                inst.trader_list = {}
                if not inst.trade_num[giver.userid] then
                    inst.trade_num[giver.userid] = 1
                else
                    inst.trade_num[giver.userid] = inst.trade_num[giver.userid] + 1
                end
            end
            local _test = inst.components.trader.test
            inst.components.trader.test = function(inst, item, giver)
                local flag = _test(inst, item, giver)
                if inst.trade_num[giver.userid] and inst.trade_num[giver.userid] >= laozi_trade_num then
                    inst.components.talker:Say(STRINGS.LAOZI.A)
                    return false
                end
                return flag
            end
        end

        local _onload = inst.OnLoad
        local _onsave = inst.OnSave
        inst.OnLoad = function(inst, data)
            _onload(inst, data)
            if data.trade_num then
                inst.trade_num = data.trade_num
            end
        end
        inst.OnSave = function(inst, data)
            _onsave(inst, data)
            data.trade_num = inst.trade_num
        end
    end)
end

if granary_not_rot then
    AddPrefabPostInit("myth_granary", function(inst)
        if not TheWorld.ismastersim then return inst end

        if inst.components.preserver then
            inst.components.preserver:SetPerishRateMultiplier(0)
        end
    end)
end

if granary_save_fruit then
    AddPrefabPostInit("world", function(inst)
        local params = containers.params
        if params and params.myth_granary then
            params.myth_granary.itemtestfn = function(container, item, slot)
                -- return cooking.ingredients[item.prefab] ~= nil and cooking.ingredients[item.prefab].tags["inedible"] == nil and cooking.ingredients[item.prefab].tags["magic"] == nil
                if item:HasTag("icebox_valid") then
                    return true
                end

                --Perishable
                if not (item:HasTag("fresh") or item:HasTag("stale") or item:HasTag("spoiled")) then
                    return false
                end

                if item:HasTag("smallcreature") then
                    return false
                end

                --Edible
                for k, v in pairs(FOODTYPE) do
                    if item:HasTag("edible_"..v) then
                        return true
                    end
                end

                return false
            end
        end
    end)
end

if mythBlackBearRockClearTime > 0 then
    AddPrefabPostInit("blackbear_rock", function(inst)
        -- 黑熊岩石清理
        if not _G.TheWorld.ismastersim then
            return
        end
        if inst._clearTask and inst._clearTask.Cancel then
            inst._clearTask:Cancel();
            inst._clearTask = nil;
        end
        inst._clearTask = inst:DoTaskInTime(mythBlackBearRockClearTime, function(inst)
            inst:Remove()
        end)
    end)
end

--if mythFlyingSpeedMultiplier > 0 then
--    AddComponentPostInit("locomotor", function(self)
--        local oldGetRunSpeed = self.GetRunSpeed;
--        function self:GetRunSpeed(...)
--            if self.inst.components.mk_flyer ~= nil and self.inst.components.mk_flyer:IsFlying() then
--
--                local speedMultiplier = self:GetSpeedMultiplier() - 1;
--                if speedMultiplier > 0 then
--                    speedMultiplier = speedMultiplier * mythFlyingSpeedMultiplier + 1;
--                else
--                    speedMultiplier = 1;
--                end
--                return self.inst.components.mk_flyer.runspeed * speedMultiplier
--            end
--            return oldGetRunSpeed(self, ...)
--        end
--    end)
--end
--AddPrefabPostInit("myth_small_goldfrog",function(inst)
--    inst.sounds = {
--        attack_spit  = "dontstarve/frog/attack_spit",
--        attack_voice = "dontstarve/frog/attack_voice",
--        die          = "dontstarve/frog/die",
--        grunt        = "dontstarve/frog/grunt",
--        walk         = "dontstarve/frog/walk",
--        splat        = "dontstarve/frog/splat",
--        wake         = "dontstarve/frog/wake",
--    }
--end)