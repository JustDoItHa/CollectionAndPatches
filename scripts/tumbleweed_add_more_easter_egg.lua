local tumbleweed_item_rates_l = GetModConfigData("tumbleweed_item_rates")
local tumbleweed_add_more_easter_egg_multiple_l = GetModConfigData("tumbleweed_add_more_easter_egg_multiple")
local cap_item_multiple_l  = GetModConfigData("cap_item_multiple")
if tumbleweed_add_more_easter_egg_multiple_l == nil or tumbleweed_add_more_easter_egg_multiple_l < 0 then
    tumbleweed_add_more_easter_egg_multiple_l = 1
end

STRINGS.TUMBLEWEEDANNOUNCE_MOD= {
    QIAN="【",
    MSZF = "】在开风滚草时得到了【猫神祝福】", --猫神祝福
    YDBY = "】在开风滚草时遇到了【盐都不盐了的诅咒】", --盐都不盐了的诅咒
}
----------------生成各种怪圈(玩家,预置物列表,公告)-----------------
local function spawnCircleItem(player,spawnLoot,announce)
    if player then
        local px,py,pz = player.Transform:GetWorldPosition()--获取玩家坐标
        local item=nil--空实体
        --遍历生成物列表
        for _,v in ipairs(spawnLoot) do
            --对玩家执行函数
            if v.playerfn then
                v.playerfn(player)
            end
            --有代码则生成对应预置物
            if v.item or v.randomlist then
                local num=v.num or 1--生成数量
                local specialnum=v.specialfn and math.random(num)-1 or nil--特殊道具
                --生成怪圈
                for i=0,num-1 do
                    local code=v.item--预置物代码
                    if v.randomlist then
                        code=GetRandomItem(v.randomlist)--从随机列表里取一种
                    end
                    local angle_offset=v.angle_offset or 0--角度偏移
                    local angle = (i+angle_offset) * 2 * PI / (num)--根据数量计算角度
                    local tries =v.offset and 5 or 1--尝试生成次数,有偏移值的情况下要多次尝试生成,避免少刷
                    local canspawn=nil--是否可生成
                    if v.randomlist then

                    end
                    --多次尝试生成
                    for j=1,tries do
                        --有偏移值则用偏移值生成坐标，否则根据半径生成坐标，没半径则原地生成
                        local ix=v.offset and (math.random()*2-1)*v.offset+px or v.radius and v.radius*math.cos(angle)+px or px
                        local iy=py
                        local iz=v.offset and (math.random()*2-1)*v.offset+pz or v.radius and v.radius*math.sin(angle)+pz or pz
                        --水中奇遇则判断坐标点是不是在水里
                        if v.iswater then
                            canspawn = TheWorld.Map:IsOceanAtPoint(ix, iy, iz)
                        else
                            canspawn = TheWorld.Map:IsPassableAtPoint(ix, iy, iz)
                        end
                        --坐标点可生成则生成，否则继续尝试
                        if canspawn then
                            item = SpawnPrefab(code)
                            if item then
                                item.Transform:SetPosition(ix, iy, iz)
                                --如果没有特意取消，那么开出来的生物默认仇恨玩家
                                if item.components.combat and not v.noaggro then
                                    item.components.combat:SuggestTarget(player)
                                end
                                --有特殊函数则执行特殊函数
                                if specialnum and i==specialnum then
                                    v.specialfn(item,player)
                                elseif v.itemfn then--否则执行正常预置物函数
                                    v.itemfn(item,player)
                                end
                            end
                            break
                        end
                    end
                end
            end
        end
        --发出公告
        if announce then
            TheNet:Announce(STRINGS.TUMBLEWEEDANNOUNCE_MOD.QIAN..player:GetDisplayName()..STRINGS.TUMBLEWEEDANNOUNCE_MOD[announce])
        end
    end
end

if GetModConfigData("interesting_tumbleweed_switch") and type(tumbleweed_item_rates_l) == "number" and tumbleweed_item_rates_l > 0 and TUNING.INTERESTING_TUMBLEWEED_ENABLE then
    TUNING.TUMBLEWEED_RESOURCES_EXPAND = TUNING.TUMBLEWEED_RESOURCES_EXPAND or {}
    TUNING.TUMBLEWEED_RESOURCES_EXPAND.more_easter_egg_god_resources = {--xxx_resources由你自己命名，尽量不要和别人的重复，可加多条不同类型资源
        resourcesList = {
            --猫神祝福0.05 赠送小猫包三个
            {chance = 0.001,pickfn = function(inst,picker)
                local spawnLoot={
                    {item="catback",num=3,radius=4},--小猫包
                }
                spawnCircleItem(picker,spawnLoot,"MSZF")
            end},
        },
        multiple = tumbleweed_add_more_easter_egg_multiple_l, --倍率(选填，不填默认为1)
        weightClass = "goodMax", --权重等级(选填，填了后掉率会随玩家幸运值变化,不填掉率不会随幸运值浮动)
    }

    TUNING.TUMBLEWEED_RESOURCES_EXPAND.more_easter_egg_bad_resources = {--xxx_resources由你自己命名，尽量不要和别人的重复，可加多条不同类型资源
        resourcesList = {
            --盐都不盐 怪物成群
            {chance = 0.001,pickfn = function(inst,picker)
                local spawnLoot={
                    {item="bearger",num=3,radius=8},--熊大
                    {item="minotaur",num=3,radius=12},--犀牛
                    {item="alterguardian_phase3",num=3,radius=15},--天体三阶段
                }
                spawnCircleItem(picker,spawnLoot,"YDBY")
            end},
        },
        multiple = tumbleweed_add_more_easter_egg_multiple_l, --倍率(选填，不填默认为1)
        weightClass = "badMax", --权重等级(选填，填了后掉率会随玩家幸运值变化,不填掉率不会随幸运值浮动)
    }
end