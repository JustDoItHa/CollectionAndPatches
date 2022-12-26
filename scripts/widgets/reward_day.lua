require "widgets/reward_day_list"
AddPlayerPostInit(function(inst)
    inst:AddComponent("reward_day_history") -- 用于记录已经获取过的奖励天数
    -- 这里用定时器因为在地下的时候不会触发时钟,不知道其他方法，有就改一下就好，知道了告诉我
    inst:DoPeriodicTask(240, function(inst)
        -- 每三十秒检测一次天数，可以改为每天检测一次inst:DoPeriodicTask(30, function(inst)
        if inst.components.reward_day_history ~= nil then
            if inst == nil or inst.components == nil or inst.components.age == nil then
                return
            end
            local liveDay = inst.components.age:GetDisplayAgeInDays()
            local temp = {}
            for k, v in pairs(rewardlist) do
                -- 每次检测都去奖励列表里查找是否有对应天数的奖励
                if v.day == liveDay then
                    temp = v
                    break
                end
            end
            if temp == nil or temp.reward == nil then
                return
            end
            ---- 新code
            local gifts_table = {}
            if liveDay > inst.components.reward_day_history:GetLastRewardDay() then
                -- 如果当前需要奖励的天数>最后一次获取奖励的天数，则发放奖励
                for _, v in pairs(temp.reward) do
                    local itemTest = GLOBAL.SpawnPrefab(v.code)
                    if itemTest ~= nil and itemTest.components.stackable then
                        local item = GLOBAL.SpawnPrefab(v.code)
                        if item ~= nil and v.number > 0 then
                            item.components.stackable:SetStackSize(v.number)
                            table.insert(gifts_table, item)
                        end
                    else
                        -- 遍历奖励物品表
                        for i = 1, v.number do
                            local item = GLOBAL.SpawnPrefab(v.code)
                            if item ~= nil then
                                table.insert(gifts_table, item)
                            end
                        end
                    end
                end
                if #gifts_table <= 0 then
                    return
                end
                if inst.components.health.currenthealth > 0 and
                        not inst:HasTag("instghost") then
                    -- 如果人物不是死亡状态
                    local alive_gift = SpawnPrefab("gift")
                    alive_gift.components.unwrappable:WrapItems(gifts_table, inst)
                    for k, v in pairs(gifts_table) do
                        if v then
                            v:Remove()
                        end
                    end
                    inst.components.inventory:GiveItem(alive_gift)
                else
                    local pt = Point(inst.Transform:GetWorldPosition()) -- 获得人物在世界的位置
                    if pt ~= nil and pt.x ~= nil and pt.y ~= nil and pt.z ~= nil then
                        local alive_gift = SpawnPrefab("gift")
                        alive_gift.components.unwrappable:WrapItems(gifts_table, inst)
                        for k, v in pairs(gifts_table) do
                            if v then
                                v:Remove()
                            end
                        end
                        local angle = math.random() * 2 * GLOBAL.PI -- 随机角度
                        alive_gift.Transform:SetPosition(pt.x, pt.y, pt.z) -- 物品放在人物脚下
                        alive_gift.Physics:SetVel(2 * math.cos(angle), 10,
                                2 * math.sin(angle))
                    end
                end
                -- 新code
                -- 更新最后一次发放奖励的天数
                inst.components.reward_day_history:UpdateLastRewardDay(liveDay)
                -- 发公告
                TheNet:Announce("恭喜玩家" .. inst:GetDisplayName() ..
                        "生存" .. liveDay .. "天，奖励" ..
                        temp.tips)
            end
        end
    end)
end)
