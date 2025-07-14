GLOBAL.setmetatable(env, {
    __index = function(t, k)
        return GLOBAL.rawget(GLOBAL, k)
    end
})

modimport("modmain/beefalostorage/actions.lua")
modimport("cn/beefalo_storage_zhs.lua")

------ 牛铃可收纳牛 start-------------
-- 保存一个实体和生成实体可以考虑直接用record = inst:GetSaveRecord()和inst = SpawnSaveRecord(record)

local function storagefn(inst, followers, player)
    for beef, value in pairs(followers) do
        beef:RemoveFromScene()
        beef.Transform:SetPosition(0, 0, 0)
        inst:AddTag("storage_beef")
        return true
    end
    return false
end

local function releasefn(inst, followers, player)
    for beef, value in pairs(followers) do
        beef:ReturnToScene()
        local x, y, z = player.Transform:GetWorldPosition()
        beef.Transform:SetPosition(x, y, z)
        inst:RemoveTag("storage_beef")
        -- 如果睡觉 就唤醒
        if beef.components.sleeper and beef.components.sleeper:IsAsleep() then
            beef.components.sleeper:WakeUp()
        end
        return true
    end
    if inst.cwjyxx_record == nil then
        return false
    end
    -- 生成一头牛
    local beef = SpawnSaveRecord(inst.cwjyxx_record) -- 以指定状态生成实体
    if inst.cwjyxx_clothing then
        beef.components.skinner_beefalo:reloadclothing(inst.cwjyxx_clothing)
    end
    local x, y, z = player.Transform:GetWorldPosition()
    beef.Transform:SetPosition(x, y, z)

    -- 与牛铃建立联系
    inst.components.useabletargeteditem:StartUsingItem(beef)
    -- 牛铃删除保存牛数据
    inst:RemoveTag("storage_beef")
    inst.cwjyxx_record = nil
    inst.cwjyxx_clothing = nil
    return true
end

AddPrefabPostInit("beef_bell", function(inst)

    inst:AddTag("can_storage_beef")

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("named")

    inst.onstoragefn = storagefn
    inst.onreleasefn = releasefn

    local _OnSave = inst.OnSave
    inst.OnSave = function(inst, data)
        data.storage_beef = inst:HasTag("storage_beef")
        data.cwjyxx_record = inst.cwjyxx_record
        data.cwjyxx_clothing = inst.cwjyxx_clothing
        _OnSave(inst, data)
    end
    local _OnLoad = inst.OnLoad
    inst.OnLoad = function(inst, data)
        _OnLoad(inst, data)
        for beef, v in pairs(inst.components.leader.followers) do
            inst.components.named:SetName(beef.components.named.name, nil)
            if data and data.storage_beef then
                inst:AddTag("storage_beef")
                inst.cwjyxx_record = data.cwjyxx_record
                inst.cwjyxx_clothing = data.cwjyxx_clothing
                beef:RemoveFromScene()
                beef.Transform:SetPosition(0, 0, 0)
            end
        end
    end

end)

AddClassPostConstruct("components/writeable", function(self)
    local _EndWriting = self.EndWriting

    function self:EndWriting()
        _EndWriting(self)
        -- 修改牛铃名字和牛一致
        if self.inst.components.follower then
            local bell = self.inst.components.follower:GetLeader()
            if bell ~= nil and bell.prefab == "beef_bell" and bell.components.named and self.inst.components.named then
                bell.components.named:SetName(self.inst.components.named.name, nil)
            end
        end
    end

end)

------ 牛铃可收纳牛 end-------------

