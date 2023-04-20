local containercfg = GetModConfigData("container_organize_preference")
local hasmultisort = containercfg == -2 or containercfg == true

local ac_fns = {
    printStrSeq = function(list)
        local msg = {}
        for _, v in ipairs(list) do
            table.insert(msg, tostring(v.prefab))
        end
        print("{ " .. table.concat(msg, ",") .. " }")
    end,
    cmp = function(p1, p2)
        if not (p1 and p2) then
            --print("", "??? cmp-p1: " .. tostring(p1));print("", "??? cmp-p2: " .. tostring(p2));
            return
        end
        return tostring(p1.prefab) < tostring(p2.prefab) and true or false
    end,
    isInventory = function(inst)
        return inst.components.inventoryitem and inst.components.inventoryitem.canonlygoinpocket
    end,
    isEquippable = function(inst)
        return inst.components.equippable
    end,
    isStackable = function(inst)
        return inst.components.stackable
    end,
    isPerishable = function(inst)
        return inst.components.perishable
    end,
    isEdible = function(inst)
        return inst.components.edible
    end,
    hasPercent = function(inst)
        if inst.components.fueled or inst.components.finiteuses or inst.components.armor then
            return true
        end
        return false
    end,
    isCHARACTER = function(inst)
        local recipes = CRAFTING_FILTERS.CHARACTER.recipes
        if recipes and type(recipes) == "table" then
            for _, v in ipairs(recipes) do
                if inst.prefab == v then
                    return true
                end
            end
        end
        return false
    end,
    isREFINE = function(inst)
        if inst.prefab == "bearger_fur" then
            return false
        end
        local recipes = CRAFTING_FILTERS.REFINE.recipes
        if recipes and type(recipes) == "table" then
            for _, v in ipairs(recipes) do
                if inst.prefab == v then
                    return true
                end
            end
        end
        return false
    end,
    isRESTORATION = function(inst)
        -- 遍历治疗制作栏
        local recipes = CRAFTING_FILTERS.RESTORATION.recipes
        if recipes and type(recipes) == "table" then
            for _, v in ipairs(recipes) do
                if inst.prefab == v then
                    return true
                end
            end
        end
        if inst.prefab == "jellybean" then
            return true
        end
        return false
    end,
    isSilkFabric = function(inst)
        if
        inst:HasTag("cattoy") or inst.prefab == "silk" or inst.prefab == "bearger_fur" or inst.prefab == "furtuft" or
                inst.prefab == "shroom_skin" or
                inst.prefab == "dragon_scales"
        then
            --print("isSilkFabric: "..tostring(inst.prefab));
            return true
        end
        return false
    end,
    isRocks = function(inst)
        if inst:HasTag("molebait") or inst.prefab == "townportaltalisman" or inst.prefab == "moonrocknugget" then
            return true
        end
        return false
    end,
    genericResult = function(...)
        local args = {...}
        local result = {}
        if #args > 0 then
            for _, tab in ipairs(args) do
                for _, v in ipairs(tab) do
                    table.insert(result, v)
                end
            end
        end
        return result
    end
}

-- 注意每个ifelse的判定块都必须有一张表存在，不然会丢东西。
---@param slots table[] Prefab
local function preciseClassification(slots)
    local canonlygoinpocket = {}
    local equippable = {perishable = {}, non_percentage = {}, hands = {}, head = {}, body = {}, rest = {}}
    local non_stackable = {perishable = {}, rest = {}}
    local stackable = {perishable = {}, rest = {}} -- 由于扩充表的存在，perishable 算是 rest。
    -- 扩充表内容。注意此处请提前初始化完毕，不然会弄混！
    local stackable_perishable = {
        deployedfarmplant = {},
        preparedfood = {
            edible_veggie = {},
            edible_meat = {},
            rest = {}
        },
        edible_veggie = {},
        edible_meat = {}
    }

    -- 初始化表。注意新加表的时候必须在此处初始化！
    equippable.perishable = equippable.perishable or {}
    equippable.non_percentage = equippable.non_percentage or {}
    equippable.hands = equippable.hands or {}
    equippable.head = equippable.head or {}
    equippable.body = equippable.body or {}
    equippable.rest = equippable.rest or {}

    non_stackable.perishable = non_stackable.perishable or {}
    non_stackable.rest[1] = non_stackable.rest[1] or {}
    non_stackable.rest[2] = non_stackable.rest[2] or {}

    stackable.perishable = stackable.perishable or {}
    stackable.rest[1] = stackable.rest[1] or {}
    stackable.rest[2] = stackable.rest[2] or {}
    stackable.rest[3] = stackable.rest[3] or {}
    stackable.rest[4] = stackable.rest[4] or {}
    stackable.rest[5] = stackable.rest[5] or {}
    stackable.rest[6] = stackable.rest[6] or {}
    stackable.rest[7] = stackable.rest[7] or {}
    stackable.rest[8] = stackable.rest[8] or {}
    stackable.rest[9] = stackable.rest[9] or {}

    slots = slots or {}

    if #slots > 0 then
        for _, v in ipairs(slots) do
            if v ~= nil then
                if ac_fns.isInventory(v) then
                    table.insert(canonlygoinpocket, v)
                elseif ac_fns.isEquippable(v) then
                    local equipslot = v.components.equippable.equipslot
                    if ac_fns.isPerishable(v) then
                        table.insert(equippable.perishable, v)
                    elseif not ac_fns.hasPercent(v) or (ac_fns.hasPercent(v) and v:HasTag("hide_percentage")) then
                        table.insert(equippable.non_percentage, v)
                    elseif equipslot == EQUIPSLOTS.HANDS then
                        table.insert(equippable.hands, v)
                    elseif equipslot == EQUIPSLOTS.HEAD then
                        table.insert(equippable.head, v)
                    elseif equipslot == EQUIPSLOTS.BODY then
                        table.insert(equippable.body, v)
                    else
                        table.insert(equippable.rest, v) -- 剩余
                    end
                elseif not ac_fns.isStackable(v) then
                    if ac_fns.isPerishable(v) then
                        table.insert(non_stackable.perishable, v)
                    elseif ac_fns.hasPercent(v) then
                        table.insert(non_stackable.rest[1], v)
                    else
                        table.insert(non_stackable.rest[2], v) -- 剩余
                    end
                else
                    if ac_fns.isPerishable(v) then
                        if v:HasTag("deployedfarmplant") then
                            table.insert(stackable_perishable.deployedfarmplant, v)
                        elseif v:HasTag("preparedfood") then
                            if ac_fns.isEdible(v) then
                                if v.components.edible.foodtype == FOODTYPE.VEGGIE then
                                    table.insert(stackable_perishable.preparedfood.edible_veggie, v)
                                elseif v.components.edible.foodtype == FOODTYPE.MEAT then
                                    table.insert(stackable_perishable.preparedfood.edible_meat, v)
                                else
                                    table.insert(stackable_perishable.preparedfood.rest, v) -- 剩余
                                end
                            else
                                table.insert(stackable_perishable.preparedfood.rest, v) -- 剩余
                            end
                        else
                            if ac_fns.isEdible(v) then
                                if v.components.edible.foodtype == FOODTYPE.VEGGIE then
                                    table.insert(stackable_perishable.edible_veggie, v)
                                elseif v.components.edible.foodtype == FOODTYPE.MEAT then
                                    table.insert(stackable_perishable.edible_meat, v)
                                else
                                    table.insert(stackable.perishable, v) -- 剩余
                                end
                            else
                                table.insert(stackable.perishable, v) -- 剩余
                            end
                        end
                    elseif v:HasTag("fertilizerresearchable") then
                        table.insert(stackable.rest[4], v)
                    elseif ac_fns.isCHARACTER(v) then
                        table.insert(stackable.rest[7], v)
                    elseif ac_fns.isRESTORATION(v) then
                        table.insert(stackable.rest[6], v)
                    elseif v:HasTag("gem") then
                        table.insert(stackable.rest[1], v)
                    elseif ac_fns.isRocks(v) then
                        table.insert(stackable.rest[2], v)
                    elseif ac_fns.isREFINE(v) then
                        table.insert(stackable.rest[8], v)
                    elseif ac_fns.isSilkFabric(v) then
                        table.insert(stackable.rest[5], v)
                    elseif ac_fns.isEdible(v) then
                        table.insert(stackable.rest[9], v)
                    else
                        table.insert(stackable.rest[3], v) -- 剩余
                    end
                end
            end
        end
    end

    local cmp = ac_fns.cmp

    -- 首先把列表里面的项全按字典序排列一遍
    table.sort(canonlygoinpocket, cmp)
    table.sort(equippable.perishable, cmp) -- perishable
    table.sort(equippable.non_percentage, cmp) -- non_percentage
    table.sort(equippable.hands, cmp) -- hands
    table.sort(equippable.head, cmp) -- head
    table.sort(equippable.body, cmp) -- body
    table.sort(equippable.rest, cmp) -- rest

    table.sort(non_stackable.perishable, cmp) -- perishable
    table.sort(non_stackable.rest[1], cmp) -- hasPercent
    table.sort(non_stackable.rest[2], cmp) -- rest

    table.sort(stackable.perishable, cmp) -- perishable
    table.sort(stackable.rest[1], cmp) -- tag:gem
    table.sort(stackable.rest[2], cmp) -- tag:molebait
    table.sort(stackable.rest[3], cmp) -- rest
    table.sort(stackable.rest[4], cmp) -- tag:fertilizerresearchable
    table.sort(stackable.rest[5], cmp) -- custom: 丝织类
    table.sort(stackable.rest[6], cmp) -- custom: 治疗
    table.sort(stackable.rest[7], cmp) -- custom: 人物
    table.sort(stackable.rest[8], cmp) -- custom: 精炼
    table.sort(stackable.rest[9], cmp) -- custom: 食用

    table.sort(stackable_perishable.deployedfarmplant, cmp)
    table.sort(stackable_perishable.edible_veggie, cmp)
    table.sort(stackable_perishable.edible_meat, cmp)
    table.sort(stackable_perishable.preparedfood.edible_veggie, cmp)
    table.sort(stackable_perishable.preparedfood.edible_meat, cmp)
    table.sort(stackable_perishable.preparedfood.rest, cmp)

    -- 请保证健壮性。如果漏东西，那么问题是会非常严重的。

    -- 2023-03-13-20:08：搞复杂了，没必要。之后简化一下！！！而且其实没这么细！有些交集太多了。但是到底应该怎么设计呢？
    return ac_fns.genericResult(
            canonlygoinpocket,
    -- 装备：头部、身体、手部、剩余、无百分比
            equippable.head,
            equippable.body,
            equippable.hands,
            equippable.rest,
            equippable.non_percentage,
    -- 不可堆叠：有百分比、剩余
            non_stackable.rest[1],
            non_stackable.rest[2],
    -- 可堆叠：人物、治疗、可食用、宝石、鼹鼠爱吃的、丝织类、精炼、剩余、粪肥
            stackable.rest[7],
            stackable.rest[6],
            stackable.rest[9],
            stackable.rest[1],
            stackable.rest[2],
            stackable.rest[5],
            stackable.rest[8],
            stackable.rest[3],
            stackable.rest[4],
    -- 装备：有新鲜度；
    -- 不可堆叠：有新鲜度；
    -- 可堆叠有新鲜度：种子、可食用素、可食用荤、剩余；
    -- 可堆叠有新鲜度的料理：可食用素、可食用荤、剩余；
            equippable.perishable,
            non_stackable.perishable,
            stackable_perishable.deployedfarmplant,
            stackable_perishable.edible_veggie,
            stackable_perishable.edible_meat,
            stackable.perishable, -- rest
            stackable_perishable.preparedfood.edible_veggie,
            stackable_perishable.preparedfood.edible_meat,
            stackable_perishable.preparedfood.rest
    )
end

-- 优化一下整理算法。不只是按字母首字母排序。
local function API_arrangeContainer2(inst)
    if not (inst and inst.components and (inst.components.container ~= nil or inst.components.inventory ~= nil)) then
        return
    end
    -- 首先先把里面的空洞给处理掉
    local container = inst.components.inventory or inst.components.container
    local slots = container.itemslots or container.slots

    local keys = {}
    for k, _ in pairs(slots) do
        keys[#keys + 1] = k
    end
    table.sort(keys)

    -- 这里很强！
    for k, v in ipairs(keys) do
        if k ~= v then
            local item = container:RemoveItemBySlot(v)
            container:GiveItem(item, k) -- Q: 如果超过堆叠上限会发生什么？ A: 会掉落
        end
    end

    -- 新的 slots
    slots = container.itemslots or container.slots

    -- 空洞已经处理完毕，开始排序了
    if inst.components.inventory then
        container.itemslots = preciseClassification(slots)
    else
        container.slots = preciseClassification(slots)
    end

    -- 更 新的 slots
    slots = container.itemslots or container.slots

    -- 此时，已经完全排序好了，开始整理
    for i, _ in ipairs(slots) do
        local item = container:RemoveItemBySlot(i)
        container:GiveItem(item) -- slot == nil，会遍历每一个格子把 item 塞进去，item == nil，返回 true
    end
end

--
-- 上述代码来自[码到成功]
--
local containers = require("containers")
local samecontainers = {
    -- {"inventory", "backpack", "piggyback", "icepack", "spicepack", "krampus_sack"},
    {"treasurechest", "dragonflychest"}
    -- {"tacklecontainer", "supertacklecontainer"}
}

local function issamecontainer(inst, v, incontainer)
    if incontainer then
        if inst.components.inventory and v.components.container and v.components.container.itemtestfn == nil then
            return true
        end
        if v.components.inventory and inst.components.container and inst.components.container.itemtestfn == nil then
            return true
        end
        if
        inst.components.container and v.components.container and
                inst.components.container.itemtestfn == v.components.container.itemtestfn
        then
            return true
        end
    end
    for _, containerstmp in ipairs(samecontainers) do
        if table.contains(containerstmp, inst.prefab) and table.contains(containerstmp, v.prefab) then
            return true
        end
    end
end

-- 跨容器排序
local function API_arrangeMultiContainers2(inst, player)
    if not (inst and inst.components and inst.components.container ~= nil) then
        return
    end
    local ents = {}
    if
    player and player.components and player.components.inventory and inst.components.equippable and
            inst.components.equippable:IsEquipped()
    then
        if inst.components.container.itemtestfn ~= nil then
            API_arrangeContainer2(inst)
            API_arrangeContainer2(player)
            return
        end
        -- 背包则只处理自己和物品栏;糖果袋一类不能进行此类处理
        table.insert(ents, inst)
        inst = player
    elseif
    inst.components.inventoryitem and inst.components.inventoryitem.owner and
            inst.components.inventoryitem.owner.components and
            (inst.components.inventoryitem.owner.components.inventory or
                    inst.components.inventoryitem.owner.components.container)
    then
        -- 钓具箱类只处理自己和所处容器内的同类容器
        local hasothercontainers = false
        local container =
        (inst.components.inventoryitem.owner.components.inventory or
                inst.components.inventoryitem.owner.components.container)
        for k, v in pairs(container.itemslots or container.slots) do
            if
            v ~= inst and v.components.container and v.components.container.canbeopened and
                    (v.prefab == inst.prefab or issamecontainer(inst, v, true))
            then
                hasothercontainers = true
                table.insert(ents, v)
            end
        end
        if not hasothercontainers then
            API_arrangeContainer2(inst)
            return
        end
    elseif inst.components.inventoryitem then
        API_arrangeContainer2(inst)
        return
    else
        -- 地面同名容器检测
        local x, y, z = inst.Transform:GetWorldPosition()
        local platform = inst:GetCurrentPlatform()
        local nearents = TheSim:FindEntities(x, y, z, 15)
        local hasothercontainers = false
        for i, v in ipairs(nearents) do
            if
            v ~= inst and v.components and v.components.container and v.components.container.canbeopened and
                    not v.components.inventoryitem and
                    (v.prefab == inst.prefab or issamecontainer(inst, v)) and
                    v:GetCurrentPlatform() == platform
            then
                hasothercontainers = true
                table.insert(ents, v)
            end
        end
        if not hasothercontainers then
            API_arrangeContainer2(inst)
            return
        end
    end
    -- 首先主容器物品收集
    local container = inst.components.inventory or inst.components.container
    local slots = container.itemslots or container.slots
    local keys = {}
    for k, _ in pairs(slots) do
        keys[#keys + 1] = k
    end
    table.sort(keys)
    -- 这里很强！
    for k, v in ipairs(keys) do
        if k ~= v then
            local item = container:RemoveItemBySlot(v)
            container:GiveItem(item, k)
        end
    end
    -- 新的 slots
    slots = container.itemslots or container.slots
    local totalslots = {}
    for key, value in ipairs(slots) do
        if value ~= nil then
            local item = container:RemoveItemBySlot(key)
            table.insert(totalslots, item)
        end
    end
    -- 其次额外的容器物品收集
    for i, v in ipairs(ents) do
        local container = v.components.container
        local slots = container.slots
        local keys = {}
        for k, _ in pairs(slots) do
            keys[#keys + 1] = k
        end
        table.sort(keys)
        -- 这里很强！
        for k, v in ipairs(keys) do
            if k ~= v then
                local item = container:RemoveItemBySlot(v)
                container:GiveItem(item, k)
            end
        end
        -- 新的 slots
        slots = container.slots
        for key, value in ipairs(slots) do
            if value ~= nil then
                local item = container:RemoveItemBySlot(key)
                table.insert(totalslots, item)
            end
        end
    end
    local tmp = CreateEntity()
    tmp:AddComponent("container")
    tmp.components.container.ShouldPrioritizeContainer = function()
        return true
    end
    tmp.components.container.CanTakeItemInSlot = function()
        return true
    end
    tmp.components.container:SetNumSlots(#totalslots)
    for _, item in ipairs(totalslots) do
        tmp.components.container:GiveItem(item)
    end
    API_arrangeContainer2(tmp)
    -- 分配到各个容器
    local finalslots = tmp.components.container.slots
    local entindex = 1
    local entsnumslots = ents[1].components.container.numslots + (container.maxslots or container.numslots)
    for index, item in ipairs(finalslots) do
        local item = tmp.components.container:RemoveItemBySlot(index)
        if index <= (container.maxslots or container.numslots) then
            container:GiveItem(item)
        elseif index <= entsnumslots then
            ents[entindex].components.container:GiveItem(item)
        else
            entindex = entindex + 1
            entsnumslots = entsnumslots + ents[entindex].components.container.numslots
            ents[entindex].components.container:GiveItem(item)
        end
    end
    tmp:Remove()
end

-- 跨容器排序
local function sortmulticontainer2hm(player, inst)
    if inst and inst.components and inst.components.container ~= nil then
        API_arrangeMultiContainers2(inst, player)
    end
end

AddModRPCHandler("MOD_HARDMODE", "sortmulticontainer2hm", sortmulticontainer2hm)

local function sortcontainerbuttonmultiinfofn(inst, doer)
    if inst.components.container ~= nil then
        sortmulticontainer2hm(doer, inst)
    elseif inst.replica.container ~= nil then
        SendModRPCToServer(GetModRPC("MOD_HARDMODE", "sortmulticontainer2hm"), inst)
    end
end

-- 单容器排序
local function sortcontainer2hm(player, inst)
    if inst and inst.components and inst.components.container ~= nil then
        API_arrangeContainer2(inst)
        if inst.components.equippable and inst.components.equippable:IsEquipped() then
            API_arrangeContainer2(player)
        end
    end
end

AddModRPCHandler("MOD_HARDMODE", "sortcontainer2hm", sortcontainer2hm)

local function sortcontainerbuttoninfofn(inst, doer)
    if inst.components.container ~= nil then
        sortcontainer2hm(doer, inst)
    elseif inst.replica.container ~= nil then
        SendModRPCToServer(GetModRPC("MOD_HARDMODE", "sortcontainer2hm"), inst)
    end
end

local function sortcontainerbuttoninfovalidfn(inst)
    return inst.components.container ~= nil or inst.replica.container ~= nil
end

-- 跨世界传送按钮
local function findcontainerproxyname(inst)
    if TheWorld.PocketDimensionContainers then
        for name, container in pairs(TheWorld.PocketDimensionContainers) do
            if container == inst then
                return name
            end
        end
    end
end

local function findanotherworldid()
    if ShardList then
        local shardids = {}
        for world_id, v in pairs(ShardList) do
            if world_id ~= TheShard:GetShardId() and Shard_IsWorldAvailable(world_id) then
                table.insert(shardids, world_id)
            end
        end
        if #shardids > 0 then
            return shardids[math.random(#shardids)]
        end
    end
end

local function processcontainerproxymastersend(inst, player, second, worldid, name)
    if inst and inst.components and inst.components.container ~= nil then
        local containername = name or findcontainerproxyname(inst)
        local world_id = worldid or findanotherworldid()
        local container = inst.components.container
        if containername and world_id then
            for i = 1, container.numslots do
                local item = container.slots[i]
                if item ~= nil then
                    item:PushEvent("player_despawn")
                end
            end
            local containerdata = container:OnSave()
            for i = 1, container.numslots do
                local item = container.slots[i]
                if item ~= nil then
                    item:Remove()
                end
            end
            SendModRPCToShard(
                    GetShardModRPC(
                            "MOD_HARDMODE",
                            second and "sendcontainerproxyworldsecond2hm" or "sendcontainerproxyworldfirst2hm"
                    ),
                    nil,
                    world_id,
                    containername,
                    DataDumper(containerdata, nil, true)
            )
            if player and player.components.talker then
                player.components.talker:Say(
                        (TUNING.MODHappyPatch.isCh and ("正在穿越到世界" .. world_id .. "啦") or
                                ("Passing through to" .. world_id .. " ~"))
                )
            end
        elseif player and player.components.talker then
            player.components.talker:Say(
                    (TUNING.MODHappyPatch.isCh and "找不到世界和容器穿越哎" or "Pass through can't find another world or container")
            )
        end
    end
end

local function processcontainerproxymasterreceive(inst, containerdata)
    if inst and inst.components and inst.components.container ~= nil and containerdata then
        local container = inst.components.container
        for i = 1, container.numslots do
            local item = container.slots[i]
            if item ~= nil then
                item:Remove()
            end
        end
        container:OnLoad(containerdata)
    end
end

-- 本世界穿越数据给其他世界,其他世界又穿越数据回来,进行处理
AddShardModRPCHandler(
        "MOD_HARDMODE",
        "sendcontainerproxyworldsecond2hm",
        function(shard_id, world_id, name, containerdata)
            if
            TheShard and tostring(TheShard:GetShardId()) ~= tostring(shard_id) and
                    tostring(TheShard:GetShardId()) == tostring(world_id)
            then
                local container = TheWorld:GetPocketDimensionContainer(name)
                if container and containerdata then
                    local success, data = RunInSandboxSafe(containerdata)
                    if success then
                        processcontainerproxymasterreceive(container, data)
                    end
                end
                if container and container.containerprocesstask2hm then
                    container.containerprocesstask2hm:Cancel()
                    container.containerprocesstask2hm = nil
                end
            end
        end
)

-- 收到其他世界穿越来的数据,把自己的数据穿越给对方
AddShardModRPCHandler(
        "MOD_HARDMODE",
        "sendcontainerproxyworldfirst2hm",
        function(shard_id, world_id, name, containerdata)
            if TheShard and TheShard:GetShardId() ~= shard_id and TheShard:GetShardId() == world_id then
                local container = TheWorld:GetPocketDimensionContainer(name)
                if container then
                    processcontainerproxymastersend(container, nil, true, shard_id, name)
                end
                if container and containerdata then
                    local success, data = RunInSandboxSafe(containerdata)
                    if success then
                        processcontainerproxymasterreceive(container, data)
                    end
                end
            end
        end
)

local function sendscontainerproxyotherworld(player, inst)
    if
    TheWorld.ismastersim and inst.components ~= nil and inst.components.container ~= nil and
            not inst.containerprocesstask2hm
    then
        inst.containerprocesstask2hm =
        inst:DoTaskInTime(
                3,
                function()
                    inst.containerprocesstask2hm = nil
                end
        )
        processcontainerproxymastersend(inst, player)
    end
end

AddModRPCHandler("MOD_HARDMODE", "sendcontainerproxyworld2hm", sendscontainerproxyotherworld)

local function sendscontainerproxyotherworldfn(inst, doer)
    if inst.components.container and TheWorld.ismastersim then
        sendscontainerproxyotherworld(doer, inst)
    elseif inst.replica.container ~= nil then
        SendModRPCToServer(GetModRPC("MOD_HARDMODE", "sendcontainerproxyworld2hm"), inst)
    end
end

local function sendscontainerproxyotherworldvalidfn(inst)
    return inst.components.container ~= nil or inst.replica.container ~= nil
end

-- 换装按钮
local function reskininwardrobe2hm(player, inst)
    if inst and inst.components.wardrobe ~= nil and inst:HasTag("wardrobe") then
        BufferedAction(player, inst, ACTIONS.CHANGEIN):Do()
    end
end

AddModRPCHandler("MOD_HARDMODE", "reskininwardrobe2hm", reskininwardrobe2hm)

local function reskinfn(inst, doer)
    if inst.components.wardrobe ~= nil and inst:HasTag("wardrobe") then
        BufferedAction(doer, inst, ACTIONS.CHANGEIN):Do()
    elseif inst.replica.container ~= nil and inst:HasTag("wardrobe") then
        SendModRPCToServer(GetModRPC("MOD_HARDMODE", "reskininwardrobe2hm"), inst)
    end
end

local function reskinvalidfn(inst)
    return (inst.components.container ~= nil or inst.replica.container ~= nil) and inst:HasTag("wardrobe")
end

-- 跨容器收纳
local getfinalowner
getfinalowner = function(inst)
    return inst.components and inst.components.inventoryitem and inst.components.inventoryitem.owner and
            getfinalowner(inst.components.inventoryitem.owner) or
            inst
end

local iscontainerowner
iscontainerowner = function(inst, item)
    if not (item.components and item.components.container) then
        return false
    end
    local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
    if owner == item then
        return true
    elseif owner ~= nil then
        return iscontainerowner(owner, item)
    end
end

local findcontainerincontainers
findcontainerincontainers = function(inst, containers)
    for k, v in pairs(inst.components.container.slots) do
        if v ~= inst and v.components.container and v.components.container.canbeopened then
            table.insert(containers, v)
            findcontainerincontainers(v, containers)
        end
    end
end

local function collectcontaineritem(inst, container, item, entcontainer, i, data)
    if item ~= nil and table.contains(data.prefabs, item.prefab) and item ~= inst and not iscontainerowner(inst, item) then
        if item.components and item.components.stackable and data.itemlackstackables[item.prefab] then
            -- 是所需堆叠,处理需求与供给数目关系
            if data.itemlackstackables[item.prefab] >= item.components.stackable.stacksize then
                -- 需求比供给多,直接给
                local giveitem = entcontainer:RemoveItemBySlot(i)
                data.itemlackstackables[giveitem.prefab] =
                data.itemlackstackables[giveitem.prefab] - giveitem.components.stackable.stacksize
                if data.itemlackstackables[giveitem.prefab] == 0 and data.extranumslots == 0 then
                    data.itemlackstackables[giveitem.prefab] = nil
                end
                container:GiveItem(giveitem)
            elseif data.extranumslots > 0 then
                -- 需求比供给少,但有空间,直接给
                data.extranumslots = data.extranumslots - 1
                local giveitem = entcontainer:RemoveItemBySlot(i)
                data.itemlackstackables[giveitem.prefab] =
                data.itemlackstackables[giveitem.prefab] + giveitem.components.stackable.maxsize -
                        giveitem.components.stackable.stacksize
                if data.itemlackstackables[giveitem.prefab] == 0 and data.extranumslots == 0 then
                    data.itemlackstackables[giveitem.prefab] = nil
                end
                container:GiveItem(giveitem)
            elseif data.itemlackstackables[item.prefab] > 0 then
                -- 需求比供给少且没有新空间
                local giveitem = item.components.stackable:Get(data.itemlackstackables[item.prefab])
                data.itemlackstackables[giveitem.prefab] = nil
                container:GiveItem(giveitem)
            end
        elseif data.extranumslots > 0 then
            data.extranumslots = data.extranumslots - 1
            local giveitem = entcontainer:RemoveItemBySlot(i)
            if
            giveitem.components and giveitem.components.stackable and
                    giveitem.components.stackable.stacksize < giveitem.components.stackable.maxsize
            then
                data.itemlackstackables[giveitem.prefab] =
                (data.itemlackstackables[giveitem.prefab] or 0) + giveitem.components.stackable.maxsize -
                        giveitem.components.stackable.stacksize
            end
            container:GiveItem(giveitem)
        elseif IsTableEmpty(data.itemlackstackables) then
            -- 全部堆满,结束收纳
            return true
        end
    end
end

local function collectcontainers(inst, player)
    if not (inst and inst.components and inst.components.container and inst.components.container.numslots > 0) then
        return
    end
    local data = {}
    data.itemlackstackables = {}
    data.prefabs = {}
    local hasnumslots = 0
    for i = 1, inst.components.container.numslots do
        local item = inst.components.container.slots[i]
        if item ~= nil then
            hasnumslots = hasnumslots + 1
            table.insert(data.prefabs, item.prefab)
            if
            item.components and item.components.stackable and
                    item.components.stackable.stacksize < item.components.stackable.maxsize
            then
                data.itemlackstackables[item.prefab] =
                (data.itemlackstackables[item.prefab] or 0) + item.components.stackable.maxsize -
                        item.components.stackable.stacksize
            end
        end
    end
    data.extranumslots = inst.components.container.numslots - hasnumslots
    if #data.prefabs == 0 or (data.extranumslots == 0 and IsTableEmpty(data.itemlackstackables)) then
        return
    end
    -- 识别要收纳的容器,不会收纳自己和自己的父容器
    local ents = {}
    if inst.components.inventoryitem and inst.components.inventoryitem.owner then
        local owner = getfinalowner(inst)
        table.insert(ents, owner)
        local container = owner.components.inventory or owner.components.container
        for k, v in pairs(container.itemslots or container.slots) do
            if v.components.container and v.components.container.canbeopened then
                table.insert(ents, v)
                findcontainerincontainers(v, ents)
            end
        end
        if owner.components.inventory then
            for k, v in pairs(EQUIPSLOTS) do
                local equip = owner.components.inventory:GetEquippedItem(v)
                if equip ~= nil and equip.components.container ~= nil then
                    table.insert(ents, equip)
                    findcontainerincontainers(equip, ents)
                end
            end
        end
        for i = #ents, 1, -1 do
            if ents[i] == inst then
                table.remove(ents, i)
                break
            end
        end
    else
        findcontainerincontainers(inst, ents)
        local x, y, z = inst.Transform:GetWorldPosition()
        local platform = inst:GetCurrentPlatform()
        local nearents = TheSim:FindEntities(x, y, z, 15)
        for i, v in ipairs(nearents) do
            if
            v ~= inst and v.components and v.components.container and v.components.container.canbeopened and
                    not v.components.inventoryitem and
                    v:GetCurrentPlatform() == platform
            then
                table.insert(ents, v)
                findcontainerincontainers(v, ents)
            end
        end
    end
    if #ents <= 0 then
        return
    end
    -- 收纳
    for _, ent in ipairs(ents) do
        if ent ~= inst and ent.components.container then
            for i = 1, ent.components.container.numslots do
                local item = ent.components.container.slots[i]
                if collectcontaineritem(inst, inst.components.container, item, ent.components.container, i, data) then
                    return
                end
            end
        elseif ent ~= inst and ent.components.inventory then
            for i = 1, ent.components.inventory.maxslots do
                local item = ent.components.inventory.itemslots[i]
                if collectcontaineritem(inst, inst.components.container, item, ent.components.inventory, i, data) then
                    return
                end
            end
        end
    end
end

local function collectcontainerready(player, inst)
    if inst and inst.components.container ~= nil then
        collectcontainers(inst, player)
    end
end

AddModRPCHandler("MOD_HARDMODE", "collectbtn2hm", collectcontainerready)

local function collectfn(inst, doer)
    if inst.components.container ~= nil then
        collectcontainerready(doer, inst)
    elseif inst.replica.container ~= nil then
        SendModRPCToServer(GetModRPC("MOD_HARDMODE", "collectbtn2hm"), inst)
    end
end

local function collectvalidfn(inst)
    return inst.components.container ~= nil or inst.replica.container ~= nil
end

-- UI相关
local function addbuttoninfoforcontainerparams(prefab, container)
    if
    container and not container.usespecificslotsforitems and container.acceptsstacks ~= false and container.widget and
            container.widget.slotpos and
            #container.widget.slotpos > 5 and
            not container.widget.buttoninfo
    then
        local finalslotpos = container.widget.slotpos[#container.widget.slotpos]
        local endslotpos = container.widget.slotpos[#container.widget.slotpos - 1]
        local thirdslotpos = container.widget.slotpos[#container.widget.slotpos - 2]
        local position1, position2, position3
        if endslotpos.x ~= finalslotpos.x then
            position1 = Vector3(finalslotpos.x, finalslotpos.y - 57, finalslotpos.z)
            position2 = Vector3(endslotpos.x, endslotpos.y - 57, endslotpos.z)
            if thirdslotpos.x ~= finalslotpos.x then
                position3 = Vector3(thirdslotpos.x, thirdslotpos.y - 57, thirdslotpos.z)
            else
                position3 = Vector3(finalslotpos.x, finalslotpos.y - 100, finalslotpos.z)
            end
        else
            position1 = Vector3(finalslotpos.x, finalslotpos.y - 57, finalslotpos.z)
            position2 = Vector3(finalslotpos.x, finalslotpos.y - 100, finalslotpos.z)
            position3 = Vector3(finalslotpos.x, finalslotpos.y - 143, finalslotpos.z)
        end
        container.widget.sortbtninfo2hm = {
            --text = TUNING.MODHappyPatch.isCh and "整理" or "Sort",
            text = "整理",
            position = position1,
            fn = sortcontainerbuttoninfofn,
            validfn = sortcontainerbuttoninfovalidfn
        }
        --if hasmultisort then
        --    container.widget.multisortbtninfo2hm = {
        --        --text = TUNING.MODHappyPatch.isCh and "跨整" or "MSort",
        --        text = "跨整",
        --        position = position2,
        --        fn = sortcontainerbuttonmultiinfofn,
        --        validfn = sortcontainerbuttoninfovalidfn
        --    }
        --end
        --container.widget.collectbtninfo2hm = {
        --    --text = TUNING.MODHappyPatch.isCh and "收纳" or "Collect",
        --    text = "收纳",
        --    position = hasmultisort and position3 or position2,
        --    fn = collectfn,
        --    validfn = collectvalidfn
        --}
        --container.widget.exchangebtninfo2hm = {
        --    --text = TUNING.MODHappyPatch.isCh and "穿越" or "PassW",
        --    text = "穿越",
        --    position = position2,
        --    fn = sendscontainerproxyotherworldfn,
        --    validfn = sendscontainerproxyotherworldvalidfn
        --}
        if prefab == "wardrobe" then
            local endslotpos = container.widget.slotpos[#container.widget.slotpos - 3]
            container.widget.reskinbtninfo2hm = {
                --text = TUNING.MODHappyPatch.isCh and "换衣" or "Skin",
                text = "换衣",
                position = hasmultisort and Vector3(endslotpos.x, endslotpos.y - 57, endslotpos.z) or position3,
                fn = reskinfn,
                validfn = reskinvalidfn
            }
        end
    end
end

if containers and containers.params then
    for name, data in pairs(containers.params) do
        addbuttoninfoforcontainerparams(name, data)
    end
end

local old_wsetup = containers.widgetsetup
function containers.widgetsetup(container, prefab, data, ...)
    result = old_wsetup(container, prefab, data, ...)
    addbuttoninfoforcontainerparams(prefab, container)
    return result
end

local ImageButton = require "widgets/imagebutton"
local function addbutton(self, container, doer, btnname, btninfo, position)
    local btn =
    self:AddChild(
            ImageButton(
                    "images/ui.xml",
                    "button_small.tex",
                    "button_small_over.tex",
                    "button_small_disabled.tex",
                    nil,
                    nil,
                    {1, 1},
                    {0, 0}
            )
    )
    btn.image:SetScale(0.77, 1.07, 1.07)
    btn.text:SetPosition(2, -2)
    btn:SetPosition(position or btninfo.position)
    btn:SetText(btninfo.text)
    if btninfo.fn ~= nil then
        btn:SetOnClick(
                function()
                    btninfo.fn(container, doer)
                end
        )
    end
    btn:SetFont(BUTTONFONT)
    btn:SetDisabledFont(BUTTONFONT)
    btn:SetTextSize(33)
    btn.text:SetVAlign(ANCHOR_MIDDLE)
    btn.text:SetColour(0, 0, 0, 1)
    self[btnname] = btn
end

AddClassPostConstruct(
        "widgets/inventorybar",
        function(self)
            local oldRebuild = self.Rebuild
            self.Rebuild = function(self, ...)
                oldRebuild(self, ...)
                local inventory = self.owner.replica.inventory
                local overflow = inventory:GetOverflowContainer()
                overflow = (overflow ~= nil and overflow:IsOpenedBy(self.owner)) and overflow or nil
                local do_integrated_backpack = overflow ~= nil and self.integrated_backpack
                if do_integrated_backpack and self.bottomrow and overflow and overflow.inst then
                    local widget = overflow:GetWidget()
                    local num = overflow:GetNumSlots()
                    if
                    self.backpackinv and self.backpackinv[num] and not widget.buttoninfo and widget.sortbtninfo2hm and
                            widget.multisortbtninfo2hm and
                            widget.collectbtninfo2hm
                    then
                        local pos = self.backpackinv[num]:GetPosition()
                        addbutton(
                                self.bottomrow,
                                overflow.inst,
                                self.owner,
                                "sortbutton2hm",
                                widget.sortbtninfo2hm,
                                Vector3(pos.x + 98, pos.y, pos.z)
                        )
                        if hasmultisort then
                            addbutton(
                                    self.bottomrow,
                                    overflow.inst,
                                    self.owner,
                                    "multisortbutton2hm",
                                    widget.multisortbtninfo2hm,
                                    Vector3(pos.x + 168, pos.y, pos.z)
                            )
                        end
                        addbutton(
                                self.bottomrow,
                                overflow.inst,
                                self.owner,
                                "collectbutton2hm",
                                widget.collectbtninfo2hm,
                                hasmultisort and Vector3(pos.x + 238, pos.y, pos.z) or Vector3(pos.x + 168, pos.y, pos.z)
                        )
                    end
                end
            end
        end
)

AddClassPostConstruct(
        "widgets/containerwidget",
        function(self)
            local oldOpen = self.Open
            self.Open = function(self, container, doer, ...)
                local result = oldOpen(self, container, doer, ...)
                local widget = container.replica.container:GetWidget()
                if not self.button and not widget.buttoninfo and widget.sortbtninfo2hm and widget.collectbtninfo2hm then
                    -- 整理
                    addbutton(self, container, doer, "sortbutton2hm", widget.sortbtninfo2hm)
                    if
                    container.prefab == "wardrobe" and widget.reskinbtninfo2hm and
                            container:HasTag("wardrobecontainer2hm")
                    then
                        -- 换装
                        addbutton(self, container, doer, "reskinbutton2hm", widget.reskinbtninfo2hm)
                    end
                    if container:HasTag("pocketdimension_container") and widget.exchangebtninfo2hm then
                        -- 穿越
                        addbutton(self, container, doer, "exchangebutton2hm", widget.exchangebtninfo2hm)
                    else
                        -- 跨整和跨收
                        if hasmultisort and widget.multisortbtninfo2hm then
                            addbutton(self, container, doer, "multisortbutton2hm", widget.multisortbtninfo2hm)
                        end
                        addbutton(self, container, doer, "collectbutton2hm", widget.collectbtninfo2hm)
                    end
                end
                -- if morefar then
                --     self:MoveToFront()
                -- end
                return result
            end
            local oldClose = self.Close
            self.Close = function(self, ...)
                if self.isopen then
                    if self.reskinbutton2hm ~= nil then
                        self.reskinbutton2hm:Kill()
                        self.reskinbutton2hm = nil
                    end
                    if self.exchangebutton2hm ~= nil then
                        self.exchangebutton2hm:Kill()
                        self.exchangebutton2hm = nil
                    end
                    if self.sortbutton2hm ~= nil then
                        self.sortbutton2hm:Kill()
                        self.sortbutton2hm = nil
                    end
                    if self.multisortbutton2hm ~= nil then
                        self.multisortbutton2hm:Kill()
                        self.multisortbutton2hm = nil
                    end
                    if self.collectbutton2hm ~= nil then
                        self.collectbutton2hm:Kill()
                        self.collectbutton2hm = nil
                    end
                end
                return oldClose(self, ...)
            end
        end
)

local function onopenwardrobe(inst)
    if inst.components.wardrobe then
        inst.components.wardrobe:SetCanUseAction(true)
    end
end

local function onclosewardrobe(inst)
    if inst.components.wardrobe then
        inst.components.wardrobe:SetCanUseAction(false)
    end
end

-- 妥协衣柜处理
AddPrefabPostInit(
        "wardrobe",
        function(inst)
            if not TheWorld.ismastersim then
                return
            end
            if inst.components.container and inst.components.wardrobe and inst.components.channelable then
                inst:AddTag("wardrobecontainer2hm")
                inst.components.wardrobe:SetCanUseAction(false)
                inst.components.channelable:SetEnabled(false)
                local oldonopen = inst.components.container.onopenfn
                inst.components.container.onopenfn = function(inst, ...)
                    if oldonopen then
                        oldonopen(inst, ...)
                    end
                    onopenwardrobe(inst)
                end
                local oldonclose = inst.components.container.onclosefn
                inst.components.container.onclosefn = function(inst, ...)
                    if oldonclose then
                        oldonclose(inst, ...)
                    end
                    onclosewardrobe(inst)
                end
            end
        end
)

-- if morefar then
--     local disableClose = false
--     AddComponentPostInit(
--         "container",
--         function(self)
--             local oldClose = self.Close
--             self.Close = function(self, ...)
--                 if not disableClose then
--                     oldClose(self, ...)
--                 end
--             end
--             local oldOpen = self.Open
--             self.Open = function(self, ...)
--                 disableClose = true
--                 oldOpen(self, ...)
--                 disableClose = false
--             end
--             self.OnUpdate = function(self, ...)
--                 if self.opencount == 0 then
--                     self.inst:StopUpdatingComponent(self)
--                 else
--                     for opener, _ in pairs(self.openlist) do
--                         if
--                             not (self.inst.components.inventoryitem ~= nil and
--                                 self.inst.components.inventoryitem:IsHeldBy(opener)) and
--                                 ((opener.components.rider ~= nil and opener.components.rider:IsRiding()) or
--                                     not (opener:IsNear(self.inst, 12) and CanEntitySeeTarget(opener, self.inst)))
--                          then
--                             self:Close(opener)
--                         end
--                     end
--                 end
--             end
--         end
--     )
-- end
