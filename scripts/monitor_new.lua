--主要代码逻辑来自淡谷雪国及明明就
--呃无聊优化

local _G = GLOBAL
local TheNet = GLOBAL.TheNet
local IsServer = TheNet:GetIsServer() or TheNet:IsDedicated()
GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})

-- ThePlayer.Transform:SetPosition(-180.28, 0.00, -74.95)
-- print(ThePlayer.Transform:GetWorldPosition())


if IsServer then

local function GetDebugString(inst,data,name_list,x,y,z)
    local day = TheWorld.components.worldstate.data.cycles

    if _G.STRINGS.NAMES[string.upper(inst.prefab)] and _G.STRINGS.NAMES[string.upper(data.target.prefab)] then
        if #name_list > 0 then
            if type(_G.STRINGS.NAMES[string.upper(data.target.prefab)]) == "string" then
                print("[".._G.os.date("%Y-%m-%d %H:%M:%S").." |"..day.."天] ".._G.STRINGS.NAMES[string.upper(inst.prefab)].." | 在("..string.format("%.2f", x)..", "..string.format("%.2f", y)..", "..string.format("%.2f", z)..") | 砸".._G.STRINGS.NAMES[string.upper(data.target.prefab)].." | 附近有玩家("..table.concat(name_list,",")..")")
            elseif type(_G.STRINGS.NAMES[string.upper(data.target.prefab)]) == "table" then
                for c, d in pairs(_G.STRINGS.NAMES[string.upper(data.target.prefab)]) do
                print("[".._G.os.date("%Y-%m-%d %H:%M:%S").." |"..day.."天] ".._G.STRINGS.NAMES[string.upper(inst.prefab)].." | 在("..string.format("%.2f", x)..", "..string.format("%.2f", y)..", "..string.format("%.2f", z)..") | 砸"..d.." | 附近有玩家("..table.concat(name_list,",")..")")
                end
            end
        else
            if type(_G.STRINGS.NAMES[string.upper(data.target.prefab)]) == "string" then
                print("[".._G.os.date("%Y-%m-%d %H:%M:%S").." |"..day.."天] ".._G.STRINGS.NAMES[string.upper(inst.prefab)].." | 在("..string.format("%.2f", x)..", "..string.format("%.2f", y)..", "..string.format("%.2f", z)..") | 砸".._G.STRINGS.NAMES[string.upper(data.target.prefab)].." | 附近无玩家")
            elseif type(_G.STRINGS.NAMES[string.upper(data.target.prefab)]) == "table" then
                for c, d in pairs(_G.STRINGS.NAMES[string.upper(data.target.prefab)]) do
                print("[".._G.os.date("%Y-%m-%d %H:%M:%S").." |"..day.."天] ".._G.STRINGS.NAMES[string.upper(inst.prefab)].." | 在("..string.format("%.2f", x)..", "..string.format("%.2f", y)..", "..string.format("%.2f", z)..") | 砸"..d.." | 附近无玩家")
                end
            end
        end
    end
end


local listener = {
    "deerclops",          --巨鹿
    "bearger",            --熊大
    "elecarmet",          --电气boss
    --"stalker_forest",     --地上复活骨架
    --"stalker",            --地下复活骨架
    "klaus",              --克劳斯
}


for k, v in pairs(listener) do
    AddPrefabPostInit(v, function(inst)
        local name_list = {}
        if not TheWorld.ismastersim then
            return inst
        end

        inst:ListenForEvent("working", function(inst, data)
            if data and data.target and  data.target:HasTag("structure") then
                local x, y, z = data.target.Transform:GetWorldPosition()
                if x and y and z then
                    local ents = TheSim:FindEntities(x, y, z, 32)
                    for a, b in pairs(ents) do
                        if b:HasTag("player") then
                            table.insert(name_list, b.name)
                        end
                    end
                    GetDebugString(inst, data, name_list, x, y, z)
                    name_list = {}
                end
            end
        end)

    end)
end


--蚁狮拆家记录
AddPrefabPostInit("antlion_sinkhole", function(inst)
    local name_list = {}
    local item_tables = {}
    local day = TheWorld.components.worldstate.data.cycles
    inst:DoTaskInTime(30, function()
        inst:Remove()
    end)
    inst:ListenForEvent("startcollapse", function()

        local x,y,z = inst.Transform:GetWorldPosition()

        local ents = TheSim:FindEntities(x,y,z,4)
        for k,v in pairs(ents) do
            if v.components.workable then
                table.insert(item_tables, tostring(_G.STRINGS.NAMES[string.upper(v.prefab)]))
            end
        end

        ents = TheSim:FindEntities(x,y,z,6)
        for k,v in pairs(ents) do
            if v:HasTag("player") then
                table.insert(name_list, v.name)
            end
        end

        print("[".._G.os.date("%Y-%m-%d %H:%M:%S").." |"..day.."天] 蚁狮地陷生成在("..string.format("%.2f", x)..", "..string.format("%.2f", y)..", "..string.format("%.2f", z)..")附近玩家:("..table.concat(name_list,",").."), 附近建筑:("..table.concat(item_tables,",")..")")

        --print("[".._G.os.date("%Y-%m-%d|%H:%M:%S").."] 附近建筑:("..table.concat(item_tables,",")..")")
        --
        --print("[".._G.os.date("%Y-%m-%d|%H:%M:%S").."] 附近玩家:("..table.concat(name_list,",")..")")

        name_list = {}
        item_tables = {}
    end)
end)


--船拆家记录
AddPrefabPostInit("boat", function(inst)
    local name_list = {}
    local item_tables = {}
    local delay = 0.1
    local limit = 108
    local day = TheWorld.components.worldstate.data.cycles

    inst:ListenForEvent("death", function()
        local a, b, c = inst.Transform:GetWorldPosition()
        local ent = TheSim:FindEntities(a,b,c,6)

        for k, v in pairs(ent) do
            if v.prefab == "stagehand" then
                limit = 8
                delay = 3
            end
        end

        inst:DoTaskInTime(delay, function()

            local x,y,z = inst.Transform:GetWorldPosition()

            local ents = TheSim:FindEntities(x,y,z,6)
            for k, v in pairs(ents) do
                if v.components.workable and not v.inlimbo and not v:HasTag("player") then
                    if _G.STRINGS.NAMES[string.upper(v.prefab)] ~= nil then
                        table.insert(item_tables, tostring(_G.STRINGS.NAMES[string.upper(v.prefab)]))
                    else
                        if v:GetDisplayName() ~= "MISSING NAME" then
                            table.insert(item_tables, tostring(v:GetDisplayName()))
                        else
                            table.insert(item_tables, tostring(v.prefab))
                        end
                    end
                end
            end

            ents = TheSim:FindEntities(x,y,z,limit)
            for k, v in pairs(ents) do
                if v:HasTag("player") then
                    table.insert(name_list, v.name)
                end
            end

            print("[".._G.os.date("%Y-%m-%d %H:%M:%S").." |"..day.."天] 船在("..string.format("%.2f", x)..", "..string.format("%.2f", y)..", "..string.format("%.2f", z)..")毁坏, 附近玩家:("..table.concat(name_list,",").."), 附近建筑:("..table.concat(item_tables,",")..")")

            --print("[".._G.os.date("%Y-%m-%d|%H:%M:%S").."] 附近建筑:("..table.concat(item_tables,",")..")")
            --
            --print("[".._G.os.date("%Y-%m-%d|%H:%M:%S").."] 附近玩家:("..table.concat(name_list,",")..")")

            name_list = {}
            item_tables = {}

        end)
    end)

end)


--监测砸
local old_ACTION_HAMMER = _G.ACTIONS.HAMMER.fn
_G.ACTIONS.HAMMER.fn = function(act)
    local day = TheWorld.components.worldstate.data.cycles
    local x, y, z = act.target.Transform:GetWorldPosition()
    if act.doer and act.target and act.doer.userid then
        print("[".._G.os.date("%Y-%m-%d %H:%M:%S").." |"..day.."天] "..act.doer.name.." | "..act.doer.userid.." | 在("..string.format("%.2f", x)..", "..string.format("%.2f", y)..", "..string.format("%.2f", z)..") | 砸"..tostring(_G.STRINGS.NAMES[string.upper(act.target.prefab)]))
    else
        print("[".._G.os.date("%Y-%m-%d %H:%M:%S").." |"..day.."天] "..act.doer.name.." | 在("..string.format("%.2f", x)..", "..string.format("%.2f", y)..", "..string.format("%.2f", z)..") | 砸"..tostring(_G.STRINGS.NAMES[string.upper(act.target.prefab)]))
    end
    return old_ACTION_HAMMER(act)
end


--监测烧
local old_ACTION_LIGHT = _G.ACTIONS.LIGHT.fn
_G.ACTIONS.LIGHT.fn = function(act)
    local near_can_fire = {}
    local day = TheWorld.components.worldstate.data.cycles
    if act.doer and act.target then
        local x, y, z = act.target.Transform:GetWorldPosition()
        if x and y and z then
            -- print(x, y, z)
            local ents = TheSim:FindEntities(x, y, z, 6)
            for k, v in pairs(ents) do
                if v.components.burnable and not v.inlimbo and not v:HasTag("player") then
                    if _G.STRINGS.NAMES[string.upper(v.prefab)] ~= nil then
                        table.insert(near_can_fire, tostring(_G.STRINGS.NAMES[string.upper(v.prefab)]))
                    else
                        if v:GetDisplayName() ~= "MISSING NAME" then
                            table.insert(near_can_fire, tostring(v:GetDisplayName()))
                        else
                            table.insert(near_can_fire, tostring(v.prefab))
                        end
                    end
                end
            end
            if #near_can_fire > 1 then
                print("[".._G.os.date("%Y-%m-%d %H:%M:%S").." |"..day.."天] "..act.doer.name.." | "..act.doer.userid.." | 在("..string.format("%.2f", x)..", "..string.format("%.2f", y)..", "..string.format("%.2f", z)..") | 点燃了"..tostring(_G.STRINGS.NAMES[string.upper(act.target.prefab)]).." | 附近有可燃物("..table.concat(near_can_fire,",")..")")
            else
                print("[".._G.os.date("%Y-%m-%d %H:%M:%S").." |"..day.."天] "..act.doer.name.." | "..act.doer.userid.." | 在("..string.format("%.2f", x)..", "..string.format("%.2f", y)..", "..string.format("%.2f", z)..") | 点燃了"..tostring(_G.STRINGS.NAMES[string.upper(act.target.prefab)]).." | 附近无可燃物")
            end
            near_can_fire = {}
            -- TheNet:SystemMessage("test")
        end
    end
    return old_ACTION_LIGHT(act)
end

--监测读书
local old_ACTION_READ = _G.ACTIONS.READ.fn
_G.ACTIONS.READ.fn = function(act)
    local item_tables = {}
    local day = TheWorld.components.worldstate.data.cycles
    if act.doer and act.invobject then
        if act.invobject.prefab == "book_brimstone" or act.invobject.prefab == "book_tentacles" then
            local x, y, z = act.invobject.Transform:GetWorldPosition()
            if x and y and z then
                local ents = TheSim:FindEntities(x, y, z, 10)
                for k, v in pairs(ents) do
                    if v.prefab and not v.inlimbo and not v:HasTag("player") then
                        if _G.STRINGS.NAMES[string.upper(v.prefab)] ~= nil then
                            table.insert(item_tables, tostring(_G.STRINGS.NAMES[string.upper(v.prefab)]))
                        else
                            if v:GetDisplayName() ~= "MISSING NAME" then
                                --MISSING NAME
                                table.insert(item_tables, tostring(v:GetDisplayName()))
                            end
                        end
                    end
                end
                if #item_tables > 0 then
                    print("[".._G.os.date("%Y-%m-%d %H:%M:%S").." |"..day.."天] "..act.doer.name.." | "..act.doer.userid.." | 在("..string.format("%.2f", x)..", "..string.format("%.2f", y)..", "..string.format("%.2f", z)..") | 读"..tostring(_G.STRINGS.NAMES[string.upper(act.invobject.prefab)]).." | 附近有("..table.concat(item_tables,",")..")")
                else
                    print("[".._G.os.date("%Y-%m-%d %H:%M:%S").." |"..day.."天] "..act.doer.name.." | "..act.doer.userid.." | 在("..string.format("%.2f", x)..", "..string.format("%.2f", y)..", "..string.format("%.2f", z)..") | 读"..tostring(_G.STRINGS.NAMES[string.upper(act.invobject.prefab)]).." | 附近无物品")
                end
                item_tables = {}
            end
        end
    end
    return old_ACTION_READ(act)
end


--监测火魔杖
local old_ACTION_ATTACK = _G.ACTIONS.ATTACK.fn
_G.ACTIONS.ATTACK.fn = function(act)
    local near_can_fire = {}
    local day = TheWorld.components.worldstate.data.cycles
    if act.doer and act.target then
        local weapon = act.doer.components.combat:GetWeapon()
        if weapon and weapon.prefab == "firestaff" then
            local x, y, z = act.target.Transform:GetWorldPosition()
            if x and y and z then
                -- print(x, y, z)
                local ents = TheSim:FindEntities(x, y, z, 6)
                for k, v in pairs(ents) do
                    if v.components.burnable and not v.inlimbo and not v:HasTag("player") then
                        if _G.STRINGS.NAMES[string.upper(v.prefab)] ~= nil then
                            table.insert(near_can_fire, tostring(_G.STRINGS.NAMES[string.upper(v.prefab)]))
                        else
                            if v:GetDisplayName() ~= "MISSING NAME" then
                                table.insert(near_can_fire, tostring(v:GetDisplayName()))
                            else
                                table.insert(near_can_fire, tostring(v.prefab))
                            end
                        end
                    end
                end
                if #near_can_fire > 1 then
                    print("[".._G.os.date("%Y-%m-%d %H:%M:%S").." |"..day.."天] "..act.doer.name.." | "..act.doer.userid.." | 在("..string.format("%.2f", x)..", "..string.format("%.2f", y)..", "..string.format("%.2f", z)..") | 使用了"..tostring(_G.STRINGS.NAMES[string.upper(weapon.prefab)]).." | 点燃了"..tostring(_G.STRINGS.NAMES[string.upper(act.target.prefab)]).." | 附近有可燃物("..table.concat(near_can_fire,",")..")")
                else
                    print("[".._G.os.date("%Y-%m-%d %H:%M:%S").." |"..day.."天] "..act.doer.name.." | "..act.doer.userid.." | 在("..string.format("%.2f", x)..", "..string.format("%.2f", y)..", "..string.format("%.2f", z)..") | 使用了"..tostring(_G.STRINGS.NAMES[string.upper(weapon.prefab)]).." | 点燃了"..tostring(_G.STRINGS.NAMES[string.upper(act.target.prefab)]).." | 附近无可燃物")
                end
                near_can_fire = {}
            end
        end
    end
    return old_ACTION_ATTACK(act)
end


--监测施法
local old_ACTION_CASTSPELL = _G.ACTIONS.CASTSPELL.fn
_G.ACTIONS.CASTSPELL.fn = function(act)
    local item_tables = {}
    local near_can_fire = {}
    local day = TheWorld.components.worldstate.data.cycles
    if act.doer then
        if act.doer.userid then
            local staff = act.invobject or act.doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            local act_pos = act:GetActionPoint()
            -- print("2021-09-10 "..staff.prefab)
            --不监测换皮施法
            if act.target and staff.prefab ~= "reskin_tool" then
                local x, y, z = act.target.Transform:GetWorldPosition()
                if x and y and z then
                    -- print(x, y, z)
                    local ents = TheSim:FindEntities(x, y, z, 6)
                    for k, v in pairs(ents) do
                        if v.components.workable and not v.inlimbo and not v:HasTag("player") then
                            if _G.STRINGS.NAMES[string.upper(v.prefab)] ~= nil then
                                table.insert(item_tables, tostring(_G.STRINGS.NAMES[string.upper(v.prefab)]))
                            else
                                if v:GetDisplayName() ~= "MISSING NAME" then
                                    table.insert(item_tables, tostring(v:GetDisplayName()))
                                else
                                    table.insert(item_tables, tostring(v.prefab))
                                end
                            end
                        end
                    end
                    if #item_tables > 1 then
                        print("[".._G.os.date("%Y-%m-%d %H:%M:%S").." |"..day.."天] "..act.doer.name.." | "..act.doer.userid.." | 在("..string.format("%.2f", x)..", "..string.format("%.2f", y)..", "..string.format("%.2f", z)..") | 使用了"..tostring(_G.STRINGS.NAMES[string.upper(staff.prefab)]).." | 目标是"..tostring(_G.STRINGS.NAMES[string.upper(act.target.prefab)]).." | 附近有("..table.concat(item_tables,",")..")")
                    else
                        print("[".._G.os.date("%Y-%m-%d %H:%M:%S").." |"..day.."天] "..act.doer.name.." | "..act.doer.userid.." | 在("..string.format("%.2f", x)..", "..string.format("%.2f", y)..", "..string.format("%.2f", z)..") | 使用了"..tostring(_G.STRINGS.NAMES[string.upper(staff.prefab)]).." | 目标是"..tostring(_G.STRINGS.NAMES[string.upper(act.target.prefab)]).." | 附近无可破坏物")
                    end
                    item_tables = {}
                end

            --监控星杖
            elseif act_pos and staff.prefab ~= "opalstaff" then
                -- print(act_pos)
                if act_pos.x and act_pos.y and act_pos.z then
                    local ents = TheSim:FindEntities(act_pos.x,act_pos.y,act_pos.z,6)
                    for k, v in pairs(ents) do
                        if v.components.burnable and not v.inlimbo and not v:HasTag("player") then
                            if _G.STRINGS.NAMES[string.upper(v.prefab)] ~= nil then
                                table.insert(near_can_fire, tostring(_G.STRINGS.NAMES[string.upper(v.prefab)]))
                            else
                                if v:GetDisplayName() ~= "MISSING NAME" then
                                    table.insert(near_can_fire, tostring(v:GetDisplayName()))
                                else
                                    table.insert(near_can_fire, tostring(v.prefab))
                                end
                            end
                        end
                    end

                    if #near_can_fire > 0 then
                        print("[".._G.os.date("%Y-%m-%d %H:%M:%S").." |"..day.."天] "..act.doer.name.." | "..act.doer.userid.." | 在("..string.format("%.2f", act_pos.x)..", "..string.format("%.2f", act_pos.y)..", "..string.format("%.2f", act_pos.z)..") | 使用了"..tostring(_G.STRINGS.NAMES[string.upper(staff.prefab)]).." | 附近有可燃物("..table.concat(near_can_fire,",")..")")
                    else
                        print("[".._G.os.date("%Y-%m-%d %H:%M:%S").." |"..day.."天] "..act.doer.name.." | "..act.doer.userid.." | 在("..string.format("%.2f", act_pos.x)..", "..string.format("%.2f", act_pos.y)..", "..string.format("%.2f", act_pos.z)..") | 使用了"..tostring(_G.STRINGS.NAMES[string.upper(staff.prefab)]).." | 附近无可燃物")
                    end
                    near_can_fire = {}
                end
            end
        end
    end
    return old_ACTION_CASTSPELL(act)
end
end


if TUNING.MYTH_CHARACTER_MOD_OPEN then --判断神话人物mod是否开启
local function OnBuilt(inst, builder)
    if not( builder and builder:IsValid() and builder.prefab == 'monkey_king')then
            return
    end
    local pos = builder:GetPosition()
    pos.y =0
    local a = -builder.Transform:GetRotation()*DEGREES
    local dist = 4
    local skin = builder.AnimState:GetBuild()

    local targetpos = pos + Vector3(dist*math.cos(a), 0, dist*math.sin(a))
    local pillar = SpawnPrefab("mk_jgb_pillar")
    pillar.owner = builder
    pillar.Transform:SetPosition(targetpos:Get())
    pillar.AnimState:PlayAnimation("pillar_drop")
    pillar:DoTaskInTime(0.5, function()
            pillar.Physics:SetActive(true)
            if not (builder._is_player_astral ~= nil and  builder._is_player_astral:value()) then
                    pillar.components.groundpounder:GroundPound()
                    pillar:DoTaskInTime(0.1, function()
                            pillar.components.groundpounder:GroundPound()
                    end)
            end
            ShakeAllCameras(CAMERASHAKE.VERTICAL, .7, .025, 1.25, pillar, 40)
    end)
    pillar:SetSkin(skin)

    inst:Remove()
end


AddPrefabPostInit("mk_jgb_rec", function(inst)
    inst.OnBuilt = OnBuilt
end)


-- 监控金箍棒砸
AddPrefabPostInit("mk_jgb_pillar", function(inst)
    local item_tables = {}
    local player_tables = {}

    local function OnGroundPound(inst)

        local x, y, z = inst.Transform:GetWorldPosition()
        if x and y and z then

            local item_ents = TheSim:FindEntities(x, y, z, 12)
            for k, v in pairs(item_ents) do
                if v.components.workable and not v.inlimbo and not v:HasTag("player") then
                    if _G.STRINGS.NAMES[string.upper(v.prefab)] ~= nil then
                        table.insert(item_tables, tostring(_G.STRINGS.NAMES[string.upper(v.prefab)]))
                    else
                        if v:GetDisplayName() ~= "MISSING NAME" then
                            table.insert(item_tables, tostring(v:GetDisplayName()))
                        else
                            table.insert(item_tables, tostring(v.prefab))
                        end
                    end
                end
            end

            local player_ents = TheSim:FindEntities(x, y, z, 32)
            for k, v in pairs(player_ents) do
                if v:HasTag("player") then
                    table.insert(player_tables, v.name)
                end
            end

            print("[".._G.os.date("%Y-%m-%d|%H:%M:%S").."] (砸)金箍棒附近有("..table.concat(item_tables,",")..")")

            print("[".._G.os.date("%Y-%m-%d|%H:%M:%S").."] (砸)金箍棒附近有("..table.concat(player_tables,",")..")")

            item_tables = {}
            player_tables = {}
        end
    end

    inst.components.groundpounder.groundpoundFn = OnGroundPound --震地

end)
end


--AddComponentPostInit("playerspawner", function(PlayerSpawner, inst)
--    inst:DoTaskInTime(5, function()
--        inst:Remove()
--    end)
--    --监听玩家加入游戏
--    inst:ListenForEvent("ms_playerspawn", function(inst, player)
--        if not player then
--            return
--        else
--            print('20210819')
--            print(player.userid)
--            print(player.name)
--            --for a, b in pairs(player) do
--            --    print(a, b)
--            --end
--        end
--    end)
--    ----监听玩家离开
--    --inst:ListenForEvent("ms_playerdespawn", function(inst, player)
--    --    if not player then
--    --        return
--    --    end
--    --end)
--end)


--AddSimPostInit(function()
--    TheWorld:ListenForEvent("ms_playerspawn", SendWorld)
--    TheWorld:ListenForEvent("ms_playerleft", SendWorld)
--end)