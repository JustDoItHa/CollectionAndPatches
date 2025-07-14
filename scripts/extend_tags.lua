-- 对玩家标签的处理

-- 实现四步处理：
-- 1. 定义一个标签表tags存储标签
-- 2. 覆盖entityscript文件中标签相关方法
-- 3. 覆盖FindEntities
-- 4. 解决可装备组件的限制标签和可放置组件的限制标签的判断问题

-- 对于能力勋章扩展标签（风铃草写的那个）的兼容：
-- 调低优先级，让该mod晚于勋章加载，或者检测到勋章启用就不要再扩展标签了

--- 有些标签延迟一帧设置会有些问题，这里让原版经常设置的标签继续调用原方法
local EXCLUDE_TAGS = {
    moving = true,
    busy = true,
    idle = true,
    autopredict = true,
    pausepredict = true,
    attack = true,
    doing = true,
    notarget = true,
    spawnprotection = true
}

---函数装饰器，增强原有函数的时候可以使用
---@param beforeFn function|nil 先于fn执行，参数为fn参数，返回三个值：新返回值表、是否跳过旧函数执行，旧函数执行参数（要求是表，会用unpack解开）
---@param afterFn function|nil 晚于fn执行，第一个参数为前面执行后的返回值表，后续为fn的参数，返回值作为最终返回值（要求是表或nil，会用unpack解开）
---@param isUseBeforeReturn boolean|nil 在没有afterFn却有beforeFn的时候，是否采用beforeFn的返回值作为最终返回值，默认以原函数的返回值作为最终返回值
local function FnDecorator(obj, key, beforeFn, afterFn, isUseBeforeReturn)
    assert(type(obj) == "table")
    assert(beforeFn == nil or type(beforeFn) == "function", "beforeFn must be nil or a function")
    assert(afterFn == nil or type(afterFn) == "function", "afterFn must be nil or a function")

    local oldVal = obj[key]

    obj[key] = function(...)
        local retTab, isSkipOld, newParam, r
        if beforeFn then
            retTab, isSkipOld, newParam = beforeFn(...)
        end

        if type(oldVal) == "function" and not isSkipOld then
            if newParam ~= nil then
                r = { oldVal(unpack(newParam)) }
            else
                r = { oldVal(...) }
            end
            if not isUseBeforeReturn then
                retTab = r
            end
        end

        if afterFn then
            retTab = afterFn(retTab, ...)
        end

        if retTab == nil then
            return nil
        end
        return unpack(retTab)
    end
end

local KEY = "ttt" --key值

local function UpdateTag(inst)
    inst[KEY .. "_tagUpdateTask"] = nil
    local data = inst[KEY .. "_tagData"]
    if next(data.cache) then
        -- print("推送", inst, json.encode(data.cache))
        data.tag_dirty:set(json.encode(data.cache)) --先不判断长度，如果长度溢出了再做缓冲处理
        data.cache = {}
    end
end

local function OnTagDirty(inst)
    local data = inst[KEY .. "_tagData"]
    local tags = json.decode(data.tag_dirty:value())
    -- print("处理", inst, data.tag_dirty:value())
    for tag, enable in pairs(tags) do
        data.tags[tag] = enable or nil
    end
end

local function TagNeedUpdate(inst)
    if TheWorld.ismastersim then
        --如果该单位在休眠，则本地不会立刻调用监听回调，只会在进入加载范围后才进行，不过正常玩家用不到这一步，只有直接生成的玩家的对象才需要
        if inst:IsAsleep() then
            inst.entity:SetCanSleep(false)
        end

        local k = KEY .. "_tagUpdateTask"
        if not inst[k] then
            --本来写成0，但是加载时前后两帧推送的数据在客机还是只收最后一次的，这里延长推送时间，希望解决这个问题
            inst[k] = inst:DoTaskInTime(FRAMES * 2, UpdateTag)
        end
    end
end

local function AddTagBefore(inst, tag)
    tag = string.lower(tag)
    if EXCLUDE_TAGS[tag]              --不应该延迟
        or string.find(tag, "_") == 1 --主要用于组件副件的标签，跳过是因为好像和insight冲突
    then
        return
    end

    local data = inst[KEY .. "_tagData"]
    if not data.tags[tag] then --没有时才更新
        data.tags[tag] = true
        data.cache[tag] = true --缓存
        TagNeedUpdate(inst)
    end
    return nil, true
end

local function RemoveTagBefore(inst, tag)
    tag = string.lower(tag)
    local data = inst[KEY .. "_tagData"]
    if data.tags[tag] then
        data.tags[tag] = nil
        data.cache[tag] = false
        TagNeedUpdate(inst)
    end
end

local function AddOrRemoveTag(inst, tag, condition)
    if condition then
        inst:AddTag(tag)
    else
        inst:RemoveTag(tag)
    end
end

local function HasTagBefore(inst, tag)
    return { true }, inst[KEY .. "_tagData"].tags[tag]
end

local function HasTagsBefore(inst, ...)
    local tags = select(1, ...)
    local t = {}
    for _, v in ipairs(type(tags) == "table" and tags or { ... }) do
        if not inst:HasTag(v) then
            table.insert(t, v)
        end
    end

    if #t <= 0 then
        return { true }, true
    end

    return nil, false, { inst, t }
end

local function HasOneOfTagsBefore(inst, ...)
    local tags = select(1, ...)
    for _, v in ipairs(type(tags) == "table" and tags or { ... }) do
        if inst:HasTag(v) then
            return { true }, true
        end
    end
end

AddPlayerPostInit(function(inst)
    inst[KEY .. "_tagData"] = {
        tags = {},                                                                                --自己记录的标签
        tag_dirty = net_string(inst.GUID, "player." .. KEY .. "_tag_dirty", KEY .. "_tag_dirty"), --用来主客机标签同步
        cache = {},                                                                               --缓存，存储需要同步的数据
    }

    if not TheNet:IsDedicated() then
        inst:ListenForEvent(KEY .. "_tag_dirty", OnTagDirty) --只有客机需要监听
    end

    FnDecorator(inst, "AddTag", AddTagBefore)
    FnDecorator(inst, "RemoveTag", RemoveTagBefore)
    inst.AddOrRemoveTag = AddOrRemoveTag
    FnDecorator(inst, "HasTag", HasTagBefore)
    FnDecorator(inst, "HasTags", HasTagsBefore)
    inst.HasAllTags = inst.HasTags
    FnDecorator(inst, "HasOneOfTags", HasOneOfTagsBefore)
    inst.HasAnyTag = inst.HasOneOfTags
end)

----------------------------------------------------------------------------------------------------

local oldFindEntities = getmetatable(TheSim).__index["FindEntities"]
getmetatable(TheSim).__index["FindEntities"] = function(self, x, y, z, radius, mustTags, cantTags, oneOfTags)
    local ents = {}
    for _, v in ipairs(oldFindEntities(self, x, y, z, radius)) do --全部查找并且自己标签判断，可能有点儿效率问题
        if (not mustTags or v:HasTags(mustTags))
            and (not cantTags or not v:HasOneOfTags(cantTags))
            and (not oneOfTags or v:HasOneOfTags(oneOfTags))
        then
            table.insert(ents, v)
        end
    end

    return ents
end

----------------------------------------------------------------------------------------------------

AddPrefabPostInit("inventoryitem_classified", function(inst)
    --新增一个网络变量来记录标签的字符串值
    inst[KEY .. "equiprestrictedtag"] = net_string(inst.GUID, "equippable. " .. KEY .. "restrictedtag")
    inst[KEY .. "deployrestrictedtag"] = net_string(inst.GUID, "deployable." .. KEY .. "restrictedtag")
end)

AddClassPostConstruct("components/inventoryitem_replica", function(self)
    FnDecorator(self, "SetEquipRestrictedTag", function(self, restrictedtag)
        self.classified[KEY .. "equiprestrictedtag"]:set(restrictedtag or "")
    end)

    FnDecorator(self, "SetEquipRestrictedTag", function(self, restrictedtag)
        self.classified[KEY .. "deployrestrictedtag"]:set(restrictedtag or "")
    end)


    --- 把原来的散列值替换成字符串，不知道有没有什么问题
    function self:GetEquipRestrictedTag()
        if self.inst.components.equippable ~= nil then
            return self.inst.components.equippable:GetRestrictedTag() --话说这个方法已经不存在了，留着是个bug
        end
        -- ###
        return self.classified ~= nil
            and self.classified[KEY .. "equiprestrictedtag"]:value() ~= ""
            and self.classified[KEY .. "equiprestrictedtag"]:value()
            or nil
    end

    function self:IsDeployable(deployer)
        if self.inst.components.deployable ~= nil then
            return self.inst.components.deployable:IsDeployable(deployer)
        elseif self.classified == nil or self.classified.deploymode:value() == DEPLOYMODE.NONE then
            return false
        end
        -- ###
        -- local restrictedtag = self.classified.deployrestrictedtag:value()
        -- if restrictedtag and restrictedtag ~= 0 and not (deployer and deployer:HasTag(restrictedtag)) then
        --     return false
        -- end
        local restrictedtag = self.classified[KEY .. "deployrestrictedtag"]:value()
        if restrictedtag and restrictedtag ~= "" and not (deployer and deployer:HasTag(restrictedtag)) then
            return false
        end
        local rider = deployer and deployer.replica.rider or nil
        if rider and rider:IsRiding() then
            --can only deploy tossables while mounted
            return self.inst:HasTag("projectile")
        end
        return true
    end
end)
