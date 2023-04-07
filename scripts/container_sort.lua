-- local function stack_up(inst)
--     for i = 1, inst.components.container:GetNumSlots() do
--         local d_item = inst.components.container:RemoveItemBySlot(i)
--         if d_item ~= nil then
--             inst.components.container:GiveItem(d_item)
--         end
--     end
-- end

-- function compare(a, b)
--     if a ~= nil and b ~= nil then
--         if a.prefab == b.prefab then
--             if a.components.stackable ~= nil and b.components.stackable ~= nil then
--                 return a.components.stackable:StackSize() > b.components.stackable:StackSize()
--             end
--             return false
--         end
--         return a.prefab < b.prefab
--     end
--     return true
-- end

-- function sync_conainer(inst)
--     for i = 1, inst.components.container:GetNumSlots() do
--         local item = inst.components.container.slots[i]
--         if item ~= nil then
--             inst:PushEvent("itemget", { slot = i, item = item })
--         end
--     end
-- end

-- local function sort_up(inst)
--     table.sort(inst.components.container.slots, compare)
-- end

-- local old_open = nil
-- local function onopen(inst)
--     stack_up(inst)
--     sort_up(inst)
--     sync_conainer(inst)
--     if old_open then
--         old_open(inst)
--     end
-- end

-- AddPrefabPostInit("treasurechest", function(inst)
--     if not GLOBAL.TheWorld.ismastersim then
--         return inst
--     end
--     old_open = inst.components.container.onopenfn
--     inst.components.container.onopenfn = onopen
-- end)
-- AddPrefabPostInit("dragonflychest", function(inst)
--     if not GLOBAL.TheWorld.ismastersim then
--         return inst
--     end
--     old_open = inst.components.container.onopenfn
--     inst.components.container.onopenfn = onopen
-- end)

-- AddPrefabPostInit("icebox", function(inst)
--     if not GLOBAL.TheWorld.ismastersim then
--         return inst
--     end
--     old_open = inst.components.container.onopenfn
--     inst.components.container.onopenfn = onopen
-- end)

-- AddPrefabPostInit("saltbox", function(inst)
--     if not GLOBAL.TheWorld.ismastersim then
--         return inst
--     end
--     old_open = inst.components.container.onopenfn
--     inst.components.container.onopenfn = onopen
-- end)

-- AddPrefabPostInit("storeroom", function(inst)
--     if not GLOBAL.TheWorld.ismastersim then
--         return inst
--     end
--     old_open = inst.components.container.onopenfn
--     inst.components.container.onopenfn = onopen
-- end)

-- AddPrefabPostInit("cellar", function(inst)
--     if not GLOBAL.TheWorld.ismastersim then
--         return inst
--     end
--     old_open = inst.components.container.onopenfn
--     inst.components.container.onopenfn = onopen
-- end)

--AddPrefabPostInit("abigail_williams_starbox", function(inst)
--    if not GLOBAL.TheWorld.ismastersim then
--        return inst
--    end
--    old_open = inst.components.container.onopenfn
--    inst.components.container.onopenfn = onopen
--end)

-- AddPrefabPostInit("atrium_light_moon", function(inst)
--     if not GLOBAL.TheWorld.ismastersim then
--         return inst
--     end
--     old_open = inst.components.container.onopenfn
--     inst.components.container.onopenfn = onopen
-- end)

-- AddPrefabPostInit("strange_lunar_chest2", function(inst)
--     if not GLOBAL.TheWorld.ismastersim then
--         return inst
--     end
--     old_open = inst.components.container.onopenfn
--     inst.components.container.onopenfn = onopen
-- end)
-- AddPrefabPostInit("strange_lunar_chest", function(inst)
--     if not GLOBAL.TheWorld.ismastersim then
--         return inst
--     end
--     old_open = inst.components.container.onopenfn
--     inst.components.container.onopenfn = onopen
-- end)


-- AddPrefabPostInit("yyxk_bukas", function(inst)
--     if not GLOBAL.TheWorld.ismastersim then
--         return inst
--     end
--     old_open = inst.components.container.onopenfn
--     inst.components.container.onopenfn = onopen
-- end)

-- AddPrefabPostInit("yyxk_buka", function(inst)
--     if not GLOBAL.TheWorld.ismastersim then
--         return inst
--     end
--     old_open = inst.components.container.onopenfn
--     inst.components.container.onopenfn = onopen
-- end)

-- AddPrefabPostInit("sora2ice", function(inst)
--     if not GLOBAL.TheWorld.ismastersim then
--         return inst
--     end
--     old_open = inst.components.container.onopenfn
--     inst.components.container.onopenfn = onopen
-- end)

-- AddPrefabPostInit("hclr_supermu1", function(inst)
--     if not GLOBAL.TheWorld.ismastersim then
--         return inst
--     end
--     old_open = inst.components.container.onopenfn
--     inst.components.container.onopenfn = onopen
-- end)

-- AddPrefabPostInit("hclr_supermu2", function(inst)
--     if not GLOBAL.TheWorld.ismastersim then
--         return inst
--     end
--     old_open = inst.components.container.onopenfn
--     inst.components.container.onopenfn = onopen
-- end)


--
--AddClassPostConstruct(
--        "components/container",
--        function(self)
--            if not GLOBAL.TheWorld.ismastersim then
--                return self
--            end
--            old_open = self.onopenfn
--            self.onopenfn = onopen
--        end
--)






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
    if not next(list) then
        return
    end
    for i = 2, #list do
        local v = list[i]
        local j = i - 1
        while (j > 0 and (comp(list[j], v) > 0)) do
            list[j + 1] = list[j]
            j = j - 1
        end
        list[j + 1] = v
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
        local items_2, hand_table, body_armor_table, hat_armor_table, neck_table, medal_table, body_other_table, hat_other_table, other_table = equippable_table_fn(items_1)

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
local function slotsSortFn(inst, doer)
    if not inst.cap_sort then
        inst.cap_sort = true
        if inst.components.container ~= nil then
            if inst.components.container ~= nil and not inst.components.container:IsEmpty() then
                slotsSort(inst)
            end
        elseif inst.replica.container ~= nil and not inst.replica.container:IsBusy() then
            if inst.replica.container ~= nil and not inst.replica.container:IsEmpty() then
                SendModRPCToServer(MOD_RPC["CAP_BUTTON"]["containers"], inst)
            end
        end
        inst:DoTaskInTime(0.5 ,function() inst.cap_sort = false end)
    end
end
--整理按钮亮起规则
-- local function slotsSortValidFn(inst)
--     return inst.replica.container ~= nil and not inst.replica.container:IsEmpty()--容器不为空
-- end

AddModRPCHandler("CAP_BUTTON", "containers", function(player, inst)
    if inst then
        slotsSort(inst)
    end
end)

local add_container_table = {
    treasurechest = true,
    dragonflychest = true,
    saltbox = true,
    icebox = true,

    storeroom = true,
    cellar = true,

    abigail_williams_starbox = true,
    atrium_light_moon = true,

    strange_lunar_chest = true,
    strange_lunar_chest2 = true,

    yyxk_bukas = true,
    yyxk_buka = true,

    sora2ice = true,

    hclr_supermu1 = true,
    hclr_supermu2 = true,

    --肉仓
    zx_granary_meat = true,
    --菜仓
    zx_granary_veggie = true,

    --神话谷仓
    myth_granary = true,
}
AddClassPostConstruct("widgets/containerwidget",function(self, owner)
    local ImageButton = require "widgets/imagebutton"
    local old_Open = self.Open

    self.Open = function(self, container, doer, ...)

        if old_Open then
            old_Open(self, container, doer, ...)
        end

        if add_container_table[container.prefab] then

            local slotpos = container.replica.container.widget.slotpos
            local x = {min=nil, max=nil}
            local y
            for k, v in pairs(slotpos) do
                if y == nil then
                    y = v.y
                else
                    y = math.max(y,v.y)
                end

                if x.min == nil then
                    x.min = v.x
                    x.max = v.x
                else
                    x.min = math.min(x.min,v.x)
                    x.max = math.max(x.min,v.x)
                end
            end
            y = y + 67
            local pos = Vector3((x.min+x.max)/2, y, 0)

            if doer ~= nil and doer.components.playeractionpicker ~= nil then
                doer.components.playeractionpicker:RegisterContainer(container)
            end

            self.cap_sort = self:AddChild(ImageButton("images/ui.xml", "button_small.tex", "button_small_over.tex", "button_small_disabled.tex", nil, nil, { 1, 1 }, { 0, 0 }))
            self.cap_sort.image:SetScale(1.07)
            self.cap_sort.text:SetPosition(2, -2)
            self.cap_sort:SetPosition(pos)
            self.cap_sort:SetText("整理")

            self.cap_sort:SetOnClick(function()
                if doer ~= nil then
                    if doer:HasTag("busy") then
                        --Ignore button click when doer is busy
                        return
                    elseif doer.components.playercontroller ~= nil then
                        local iscontrolsenabled, ishudblocking = doer.components.playercontroller:IsEnabled()
                        if not (iscontrolsenabled or ishudblocking) then
                            --Ignore button click when controls are disabled
                            --but not just because of the HUD blocking input
                            return
                        end
                    end
                end
                slotsSortFn(container, doer)
            end)

            self.cap_sort:SetFont(BUTTONFONT)
            self.cap_sort:SetDisabledFont(BUTTONFONT)
            self.cap_sort:SetTextSize(33)
            self.cap_sort.text:SetVAlign(ANCHOR_MIDDLE)
            self.cap_sort.text:SetColour(0, 0, 0, 1)

            -- if widget.buttoninfo.validfn ~= nil then
            --     if widget.buttoninfo.validfn(container) then
            --         self.button:Enable()
            --     else
            --         self.button:Disable()
            --     end
            -- end

            -- if TheInput:ControllerAttached() then
            --     self.cap_sort:Hide()
            -- end

            -- self.cap_sort.inst:ListenForEvent("continuefrompause", function()
            --     if TheInput:ControllerAttached() then
            --         self.cap_sort:Hide()
            --     else
            --         self.cap_sort:Show()
            --     end
            -- end, TheWorld)
        end

    end

    local old_Close = self.Close
    self.Close = function(self, ...)
        if self.isopen then
            if self.cap_sort ~= nil then
                self.cap_sort:Kill()
                self.cap_sort = nil
            end
        end
        if old_Close then old_Close(self, ...) end
    end
end)

