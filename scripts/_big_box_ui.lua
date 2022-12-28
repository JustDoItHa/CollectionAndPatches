----按字母排序
--local function cmp(a, b)
--    if a and b then
--        a = tostring(a.prefab)
--        b = tostring(b.prefab)
--        local patt = "^(.-)%s*(%d+)$"
--        local _, _, col1, num1 = a:find(patt)
--        local _, col2, num2 = b:find(patt)
--        if (col1 and col2) and col1 == col2 then
--            return tonumber(num1) < tonumber(num2)
--        end
--        return a < b
--    end
--end
----容器排序
--local function slotsSort(inst)
--    if inst and inst.components.container then
--        local keys = table.getkeys(inst.components.container.slots)
--        if #keys > 0 then
--            table.sort(keys)
--            for k, v in ipairs(keys) do
--                if k ~= v then
--                    local item = inst.components.container:RemoveItemBySlot(v)
--                    if item then
--                        inst.components.container:GiveItem(item, k)
--                    end
--                end
--            end
--        end
--        table.sort(inst.components.container.slots, cmp)
--        for k, v in ipairs(inst.components.container.slots) do
--            local item = inst.components.container:RemoveItemBySlot(k)
--            if item then
--                inst.components.container:GiveItem(item)
--            end
--        end
--    end
--end
-------------------------------------------以下代码来自勋章-----------------------------------------------

---------------------------------------------------------------------------------------------------------
---------------------------------------------容器整理功能-------------------------------------------------
---------------------------------------------------------------------------------------------------------
--这边感谢B站小伙伴“@不肯吸水的偏铝酸钠”提供的排序代码优化,原本用的是table.sort排序并且没对道具类型做区分，会比较混乱
local function compareStr(str1, str2)
    if (str1 == str2) then
        return 0
    end
    if (str1 < str2) then
        return -1
    end
    if (str1 > str2) then
        return 1
    end
end


--按字母排序
local function cmp(a, b)
    if a and b then
        --尝试按照 prefab 名字排序
        local prefab_a = tostring(a.prefab)
        local prefab_b = tostring(b.prefab)

        return compareStr(prefab_a, prefab_b)
    end
end
--插入法排序函数
local function insert_sort(list, comp, inst)
    if not next(list) then return end
    for i = 2, #list do
        local v = list[i]
        local j = i - 1
        while (j>0 and (comp(list[j], v) > 0)) do
            list[j+1]=list[j]
            j=j-1
        end
        list[j+1]=v
    end

    for i = 1, #list do
        inst.components.container:GiveItem(list[i])
    end
end
-------------------------------随便写的 不知道怎么优化 就这样吧-------------------
local function perishable_table_fn(items)
    local perishable_table = {}
    local item_1 = {}
    for i = #items, 1, -1 do
        local v = items[i]
        if v.components.perishable and not v:HasTag("_equippable") then
            table.insert(perishable_table, v)
            -- table.remove(items, i)
        else
            table.insert(item_1, v)
        end
    end
    return item_1, perishable_table
end

local function equippable_table_fn(items)
    local hand_table = {}
    local body_armor_table = {}
    local hat_armor_table = {}
    local neck_table = {}
    local medal_table = {}
    local body_other_table = {}
    local hat_other_table = {}
    local other_table = {}

    local item_2 = {}
    for i = #items, 1, -1 do
        local v = items[i]
        if v:HasTag("_equippable") then
            if v.components.equippable.equipslot and v.components.equippable.equipslot == "hands" then
                table.insert(hand_table, v)
            elseif v.components.equippable.equipslot and v.components.equippable.equipslot == "body" then
                if v.components.armor then
                    table.insert(body_armor_table, v)
                else
                    table.insert(body_other_table, v)
                end
            elseif v.components.equippable.equipslot and v.components.equippable.equipslot == "head" then
                if v.components.armor then
                    table.insert(hat_armor_table, v)
                else
                    table.insert(hat_other_table, v)
                end
            elseif v.components.equippable.equipslot and v.components.equippable.equipslot == "neck" then
                table.insert(neck_table, v)
            elseif v:HasTag("medal") then
                table.insert(medal_table, v)
            else
                table.insert(other_table, v)
            end
        else
            table.insert(item_2, v)
        end
    end
    return item_2, hand_table, body_armor_table, hat_armor_table, neck_table, medal_table, body_other_table, hat_other_table, other_table
end

-- local function table_fn(items, sign, type) --暂时没用
--     local sign_table = {}
--     local item_1 = {}
--     if type == "com" then
--         for k,v in pairs(items) do
--             if v.components[sign] then
--                 table.insert(sign_table, v)
--             else
--                 table.insert(item_1, v)
--             end
--         end
--         return item_1, sign_table
--     elseif type == "tag" then
--         for k,v in pairs(items) do
--             if v:HasTag(sign) then
--                 table.insert(sign_table, v)
--             else
--                 table.insert(item_1, v)
--             end
--         end
--     end

--     return item_1, sign_table
-- end
-----------------------------------------------------------------------------------------------------------------------------------

--容器排序
local function slotsSort(inst)
    if inst and inst.components.container then
        --取出容器中的所有物品
        local items = {}
        for k, v in pairs(inst.components.container.slots) do
            local item = inst.components.container:RemoveItemBySlot(k)
            if (item) then
                table.insert(items, item)
            end
        end
        local items_1, perishable_table = perishable_table_fn(items)
        local items_2, hand_table, body_armor_table, hat_armor_table, neck_table, medal_table, body_other_table, hat_other_table, other_table
        = equippable_table_fn(items_1)

        if #items_2 + #perishable_table +
                #hand_table + #body_armor_table + #hat_armor_table + #neck_table + #medal_table + #body_other_table + #hat_other_table + #other_table
                == #items
        then
            insert_sort(perishable_table, cmp, inst)

            insert_sort(hand_table, cmp, inst)
            insert_sort(body_armor_table, cmp, inst)
            insert_sort(hat_armor_table, cmp, inst)
            insert_sort(neck_table, cmp, inst)
            insert_sort(medal_table, cmp, inst)
            insert_sort(body_other_table, cmp, inst)
            insert_sort(hat_other_table, cmp, inst)
            insert_sort(other_table, cmp, inst)

            insert_sort(items_2, cmp, inst)
        else
            insert_sort(items, cmp, inst)
        end

    end
end

-----------------------------------------------------------------------------------------
--整理按钮点击函数
local function optimized_collation_fn(inst, doer)
    if inst.components.container ~= nil then --如果有 container 这个组件，也就是属性
        slotsSort(inst)
    elseif inst.replica.container ~= nil and not inst.replica.container:IsBusy() then
        SendRPCToServer(RPC.DoWidgetButtonAction, nil, inst, nil)
    end
end
--整理按钮亮起规则
local function slotsSortValidFn(inst)
    if inst.components.container ~= nil and not inst.components.container:IsEmpty() then
        return true
    elseif inst.replica.container ~= nil and not inst.replica.container:IsEmpty() then
        --!好像是因为我这个按钮设置了两个UI样式。所以我需要写客户端，
        return true
    end
end

local default_pos = {}
local params = {}
-- local containers = require("containers")
-- local params = containers.params
-- default_pos._big_box = Vector3(0, -100, 0)
default_pos._big_box = Vector3(TUNING._BIGBOXUILOCATION_H, TUNING._BIGBOXUILOCATION_V, 0)
-- print("TUNING._BIGBOXUILOCATION_V:  "..(TUNING._BIGBOXUILOCATION_V or "nil"))

--上+下-
--左-右+

STRINGS._MY_CUSTOM_UI_1 = {
    TIDY = "一键整理"
}
----------------------------------------------------------------
--超级大盒子
params._big_box = {
    widget = {
        slotpos = {},
        animbank = "big_box_ui_120",
        animbuild = "big_box_ui_120",
        pos = default_pos._big_box,
        buttoninfo = {
            text = STRINGS._MY_CUSTOM_UI_1.TIDY, --
            position = Vector3(-5, 193, 0), --背景图手动调的，难受。这个按钮也歪了。
            fn = optimized_collation_fn,
            validfn = slotsSortValidFn
        }
    },
    issidewidget = false,
    type = "chest"
    -- openlimit = 1
}
----------------------------------------------------------------
function params._big_box.itemtestfn(container, item, slot)
    if item.prefab == "oceanfishingrod" then --海钓竿是容器
        return true
    end
    if item.prefab == "alterguardianhat" then --启迪之冠是容器
        return true
    end
    if item:HasTag("_container") then --不能放容器，其他都能放
        return false
    end
    return true --直接什么都能放呗，把自己放进去了咋办？ --!!!
end
----------------------------------------------------------------
--![]
local spacer = 30 --间距
local posX = nil --x
local posY = nil --y
for z = 0, 2 do
    for y = 7, 0, -1 do
        for x = 0, 4 do
            posX = 80 * x - 600 + 80 * 5 * z + spacer * z
            posY = 80 * y - 100

            if y > 3 then
                posY = posY + spacer
            end

            table.insert(params._big_box.widget.slotpos, Vector3(posX, posY, 0))
        end
    end
end
----------------------------------------------------------------


--!!!!!!!!!!!!
----------------------------------------------------------------
local containers = require "containers"
local old_widgetsetup = containers.widgetsetup

function containers.widgetsetup(container, prefab, data)
    local pref = prefab or container.inst.prefab

    local containerParams = params[pref]
    if containerParams then
        for k, v in pairs(containerParams) do
            container[k] = v
        end
        container:SetNumSlots(container.widget.slotpos ~= nil and #container.widget.slotpos or 0)
        return
    end

    return old_widgetsetup(container, prefab, data)
end

for k, v in pairs(params) do
    containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, v.widget.slotpos ~= nil and #v.widget.slotpos or 0)
end
----------------------------------------------------------------
--!!!!!!!!!!!!