local UpvalueHacker = GLOBAL.require("tools/upvaluehacker")

if GetModConfigData("aria_magiccore_can_make") then
    AddRecipe2(
            'aria_magiccore',
            {
                Ingredient('thulecite', 10),
                Ingredient('gears', 5),
                Ingredient('aria_stone', 15, 'images/inventoryimages/aria_stone.xml'),
                Ingredient('orangestaff', 3),
                Ingredient('yellowstaff', 3),
                Ingredient('greenstaff', 3),
                Ingredient('icestaff', 3),
                Ingredient('firestaff', 3),
                Ingredient('telestaff', 3),
                Ingredient('opalstaff', 3),
            },
            GLOBAL.TECH.LAB_FIVE,
            { builder_tag = 'aria', atlas = 'images/inventoryimages/aria_magiccore.xml', image = 'aria_magiccore.tex' },
            { 'REFINE', 'ARIA_LAB3TAB' }
    )
end

local function cleareight(inst)
    for i = 1, 4 do
        local item = inst.components.container:RemoveItemBySlot(i)
        if item ~= nil then
            item:Remove()
        end
    end
    for i = 6, 9 do
        local item = inst.components.container:RemoveItemBySlot(i)
        if item ~= nil then
            item:Remove()
        end
    end
end

if GetModConfigData("turn_off_aria_transfer_replicate_function") then
    AddPrefabPostInit("aria_transfer", function(inst)
        local old_transfer_fun = inst.transfer
        --直接覆盖 希望作者加个开关吧
        inst.transfer = function(tran)
            tran.components.container:Close()
            tran.SoundEmitter:PlaySound("dontstarve/common/place_structure_straw")
            SpawnPrefab("waterplant_destroy").Transform:SetPosition(Vector3(tran.Transform:GetWorldPosition()):Get())

            local item = tran.components.container:GetItemInSlot(5)

            --魔法核心生成
            if tran.components.container:Has("firestaff", 1) and tran.components.container:Has("icestaff", 1) and tran.components.container:Has("telestaff", 1)
                    and tran.components.container:Has("greenstaff", 1) and tran.components.container:Has("yellowstaff", 1) and tran.components.container:Has("orangestaff", 1)
                    and tran.components.container:Has("opalstaff", 1) then

                tran.components.container:DestroyContents()
                tran.components.container:GiveItem(SpawnPrefab("aria_magiccore"))
                tran:SetDuration(nil, 480)

                --是幻想世界法杖，能强化
            elseif item ~= nil and item.prefab == "aria_worldstaffplus" and tran.replica.container:IsFull() then

                --清掉镶嵌附魔
                if item.components.container and not item.components.container:IsEmpty() then
                    item.components.container:DropEverything()
                end

                --强化
                if tran.components.container:Has("redgem", 8) then
                    tran.components.container:ConsumeByName("redgem", 8)
                    item.aria_redlevel = math.min(item.aria_redlevel + 1, TUNING.ARIA_WORLDSTAFFMAXLEVEL)
                elseif tran.components.container:Has("bluegem", 8) then
                    tran.components.container:ConsumeByName("bluegem", 8)
                    item.aria_bluelevel = math.min(item.aria_bluelevel + 1, TUNING.ARIA_WORLDSTAFFMAXLEVEL)
                elseif tran.components.container:Has("purplegem", 8) then
                    tran.components.container:ConsumeByName("purplegem", 8)
                    item.aria_purplelevel = math.min(item.aria_purplelevel + 1, TUNING.ARIA_WORLDSTAFFMAXLEVEL)
                elseif tran.components.container:Has("greengem", 8) then
                    tran.components.container:ConsumeByName("greengem", 8)
                    item.aria_greenlevel = math.min(item.aria_greenlevel + 1, TUNING.ARIA_WORLDSTAFFMAXLEVEL)
                elseif tran.components.container:Has("yellowgem", 8) then
                    tran.components.container:ConsumeByName("yellowgem", 8)
                    item.aria_yellowlevel = math.min(item.aria_yellowlevel + 1, TUNING.ARIA_WORLDSTAFFMAXLEVEL)
                elseif tran.components.container:Has("orangegem", 8) then
                    tran.components.container:ConsumeByName("orangegem", 8)
                    item.aria_orangelevel = math.min(item.aria_orangelevel + 1, TUNING.ARIA_WORLDSTAFFMAXLEVEL)
                elseif tran.components.container:Has("opalpreciousgem", 8) then
                    tran.components.container:ConsumeByName("opalpreciousgem", 8)
                    item.aria_opalpreciouslevel = math.min(item.aria_opalpreciouslevel + 1, TUNING.ARIA_WORLDSTAFFMAXLEVEL)
                elseif tran.components.container:HasItemWithTag("aria_stone", 8) then
                    cleareight(tran)
                    item.aria_stonelevel = math.min(item.aria_stonelevel + 1, TUNING.ARIA_WORLDSTAFFMAXLEVEL)
                end

                item.components.weapon:SetDamage(51 + 5 * item.aria_stonelevel)

                --    --物品复制
                --elseif item ~= nil and item.components.equippable == nil and item.components.container == nil and item.components.unwrappable == nil
                --        and ((inst.components.container:HasItemWithTag("aria_stone", 8) and not item:HasTag("aria_stone")) or inst.components.container:HasItemWithTag("aria_stone", 9))
                --        and inst.replica.container:IsFull() then
                --    inst.itemprefab = item:GetSaveRecord()
                --    cleareight(inst)
                --    inst:SetDuration(inst.itemprefab, 900)

            else
                tran.components.container:DropEverything()
                --这是个垃圾桶
                --     inst.components.container:DestroyContents()
            end
        end
    end)
end
