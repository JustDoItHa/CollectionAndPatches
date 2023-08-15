local _G = GLOBAL

if GetModConfigData("xiuxian_patches") and TUNING.YEYU_NILXIN_XIUXIAN_ENABLE then
    --mod优先级需要小于夜雨空心的优先级
    local containers = require("containers")

    local old_widgetsetup = containers.widgetsetup
    function containers.widgetsetup(container, prefab, data, ...)
        local pref = prefab or container.inst.prefab
        if pref == "nilxin_scepter" then
            container.itemtestfn = function(inst, item, slot)
                return not (string.find(item.prefab, "ntex_extra_weapon"))
            end
        end
        return old_widgetsetup(container, prefab, data, ...)
    end
end

--地图岛资源不生成
--AddPrefabPostInit("yyxk_san_base_layout",function (inst)
--    inst:Remove()
--end)

--聚合仪器 和 结构仪器 接口 可以禁止一些东西
--AddPrefabPostInit("yyxk_auto_destroystructure",function (inst)
--    inst.replica.container.yyxkitemtestfn = function(container, item, slot)
--        return true
--    end
--end)
--AddPrefabPostInit("yyxk_auto_recipe",function (inst)
--    inst.replica.container.yyxkitemtestfn = function(container, item, slot)
--        return true
--    end
--end)

--夜雨空心入侵修改
if GetModConfigData("yeyu_ruqin") and TUNING.YEYU_NILXIN_ENABLE then
    if TheNet:GetIsServer() then
        local Removea_day = GetModConfigData("yeyu_ruqin") or -1
        local monster_invade_shadowflower = {
            { prefab = "yyxk_tigershark", des = "虎鲨", one = true },
            { prefab = "yyxk_shadowflower_leader1", des = "海象突击队" },
            { prefab = "yyxk_shadowflower_leader2", des = "火鸡大将" }
        }

        for k, v in pairs(monster_invade_shadowflower) do
            AddPrefabPostInit(v.prefab, function(inst)
                if Removea_day > -1 then
                    inst:DoPeriodicTask(Removea_day * 480, function()
                        if inst.components and inst.components.leader and inst.components.leader.followers then
                            for j, s in pairs(inst.components.leader.followers) do
                                j:Remove()
                            end
                        end
                        inst:Remove()
                    end)
                end

                inst:DoTaskInTime(0, function()
                    if math.abs(inst:GetPosition().x) > 1300 or math.abs(inst:GetPosition().y) > 1300 then
                        inst:Remove()
                    end
                end)
            end)
        end
    end
end

if GetModConfigData("yeyu_nilxin_pack_limit") and TUNING.YEYU_NILXIN_ENABLE then
    --【设置不能打包的物品】
    -- local yyxkcantbundles = TUNING.CANT_PACK_ITEMS
    -- for i, v in ipairs(yyxkcantbundles) do
    --     AddPrefabPostInit(v, function(inst)
    --         inst:AddTag("yyxkcantbundle") --给物品添加此标签即可
    --     end)
    -- end
    AddPrefabPostInit("yyxk_gift", function(inst)
        if not TheWorld.ismastersim then return inst end
        if inst.components.yyxkaction and inst.components.yyxkaction.canfn then
            local old_can = inst.components.yyxkaction.canfn
            inst.components.yyxkaction.canfn = function(inst, target, ...)
                if testCantPackItem(target,TUNING.CANT_PACK_ITEMS) then
                    return false;
                end
                return old_can and old_can(inst, target, ...) 
            end
        end
    end)
end

local distance_limit = GetModConfigData("yeyu_nilxin_jump_distance_limit")
if distance_limit >= 0 and TUNING.YEYU_NILXIN_ENABLE then
    local function distanceRestrict(inst, x, z)
        return inst:GetDistanceSqToPoint(x, 0, z) <= distance_limit * distance_limit
    end

    AddComponentPostInit("yyxk", function(self)
        local NILSKILL1 = self.NILSKILL1
        self.NILSKILL1 = function(self, x, y, z)
            if distanceRestrict(self.inst, x, z) then
                NILSKILL1(self, x, y, z)
            else
                if self.inst ~= nil and self.inst.components ~= nil and self.inst.components.talker then
                    self.inst.components.talker:Say("要哭了，心灵受伤了，根本跳不了这么远-_=!!")
                end
            end
        end

        local LUNGE = self.LUNGE
        self.LUNGE = function(self, x, y, z)
            if distanceRestrict(self.inst, x, z) then
                LUNGE(self, x, y, z)
            else
                if self.inst ~= nil and self.inst.components ~= nil and self.inst.components.talker then
                    self.inst.components.talker:Say("要哭了，心灵受伤了，根本跳不了这么远-_=!!")
                end
            end
        end

        local SWORDQI = self.SWORDQI
        self.SWORDQI = function(self, x, y, z)
            if distanceRestrict(self.inst, x, z) then
                SWORDQI(self, x, y, z)
            else
                if self.inst ~= nil and self.inst.components ~= nil and self.inst.components.talker then
                    self.inst.components.talker:Say("要哭了，心灵受伤了，根本跳不了这么远-_=!!")
                end
            end
        end
    end)
end

local blacklist = {
    multiplayer_portal_moonrock = true, --天体门
    multiplayer_portal_moonrock_constr = true,
    multiplayer_portal = true,
    cave_entrance_open = true, --洞穴
    cave_entrance_ruins = true,
    cave_entrance = true,
    cave_exit = true, --楼梯
}
local sea = GetModConfigData("yeyu_nilxin_sea")
if sea ~= -1 then
    AddPrefabPostInit("nilxin_scepter", function(inst)
        if inst.magic then
            local old_PITCHFORK = inst.magic.PITCHFORK
            inst.magic.PITCHFORK = function(inst, caster, target, pos)
                if TUNING.NILXIN.N_S_PITCHFORK == 3 then
                    caster.components.talker:Say("设置关闭")
                    return
                end
                local item = inst.components.container:GetItemInSlot(1)
                if item == nil or item.components.deployable == nil or item:HasTag("groundtile") then
                    local ent = TheSim:FindEntities(pos.x, 0, pos.z, 12, nil, { "FX", "NOCLICK", "DECOR", "INLIMBO" }, nil)
                    for _, v in pairs(ent) do
                        if blacklist[v.prefab] or (sea == 1 and v:HasTag("structure")) then
                            caster.components.talker:Say("某些建筑附近无法挖陆造海")
                            return
                        end
                    end
                end
                if old_PITCHFORK then
                    old_PITCHFORK(inst, caster, target, pos)
                end
            end
        end
    end)
end

--if GetModConfigData("everyone_is_yeyu_nilxin") then
--    TUNING.YYXK.X3RV9ANX = true
--else
--    TUNING.YYXK.X3RV9ANX = false
--end

---防止箱子升级炸服的修复
local old_YYXKTOGETHERUP = ACTIONS.YYXKTOGETHERUP.fn
if old_YYXKTOGETHERUP then
    ACTIONS.YYXKTOGETHERUP.fn = function(act)
        if act.doer and act.target and act.target.components.container and #act.target.components.container.widget.slotpos > 25 then
            act.doer.components.talker:Say("箱子大于25格无法升级")
            return
        end
        return old_YYXKTOGETHERUP(act)
    end
end


local function findSpawnPoint()
    for i=1,10000 do
        local x = math.random(-600,600)
        local y = math.random(-600,600)
        local yes = true
        local ents = TheSim:FindEntities(x,0,y,2,nil,{"FX","NOCLICK","NOBLOCK"})
        yes = yes and #ents < 1
        for ix = -2,2,1 do
            for iy = -2,2,1 do
                yes = yes and TheWorld.Map:CanPlantAtPoint(x+ix*4,0,y+iy*4)
                yes = yes and TheWorld.Map:IsPassableAtPoint(x+ix*4,0,y+iy*4,false,true)
            end
        end

        if yes then
            local ix = math.random()
            local iy = math.random()
            x = x + ix
            y = y + iy
            print(i,x,y,ix,math.random())
            return Vector3(x,0,y)
        end
    end
    return Vector3(math.random()*20,0,math.random()*20)
end


---不生成资源岛
if GetModConfigData("yeyu_nilxin_island_generate_no") then
    AddPrefabPostInit("yyxk_san_base_layout",function (inst)
        inst:Remove()
        --地图随机生成魔力花(nilxin_lifeplant)星光之石(yyxk_san_layout) 任务中心(yyxk_homesign)
        SpawnAt("nilxin_lifeplant",findSpawnPoint())
        SpawnAt("nilxin_lifeplant",findSpawnPoint())
        SpawnAt("nilxin_lifeplant",findSpawnPoint())
        SpawnAt("nilxin_lifeplant",findSpawnPoint())
        SpawnAt("nilxin_lifeplant",findSpawnPoint())
        SpawnAt("nilxin_lifeplant",findSpawnPoint())
        SpawnAt("nilxin_lifeplant",findSpawnPoint())
        SpawnAt("nilxin_lifeplant",findSpawnPoint())
        SpawnAt("nilxin_lifeplant",findSpawnPoint())
        SpawnAt("nilxin_lifeplant",findSpawnPoint())
        SpawnAt("yyxk_san_layout",findSpawnPoint())
        SpawnAt("yyxk_homesign",findSpawnPoint())

    end)

end
