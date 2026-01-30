--------------------------------------------------------------------------
require "prefabutil"
require "modutil"
--------------------
require "recipe"
--------------------
local cooking = require("cooking")
--------------------

local assets = {
    Asset("ANIM", "anim/catback.zip"),
    Asset("ANIM", "anim/swap_catback.zip"),
    Asset("ATLAS", "images/inventoryimages/catback.xml"),
    Asset("IMAGE", "images/minimap/catback.tex"),
    Asset("IMAGE", "images/inventoryimages/cbdz0.tex"),
    Asset("ATLAS", "images/inventoryimages/cbdz0.xml"),
    Asset("IMAGE", "images/inventoryimages/cbdz1.tex"),
    Asset("ATLAS", "images/inventoryimages/cbdz1.xml"),
    Asset("IMAGE", "images/inventoryimages/cbdz2.tex"),
    Asset("ATLAS", "images/inventoryimages/cbdz2.xml"),
    Asset("IMAGE", "images/inventoryimages/cbdz3.tex"),
    Asset("ATLAS", "images/inventoryimages/cbdz3.xml"),
    Asset("IMAGE", "images/inventoryimages/cbdz4.tex"),
    Asset("ATLAS", "images/inventoryimages/cbdz4.xml"),
    Asset("IMAGE", "images/inventoryimages/cbdz5.tex"),
    Asset("ATLAS", "images/inventoryimages/cbdz5.xml"),
    Asset("IMAGE", "images/inventoryimages/cbdz6.tex"),
    Asset("ATLAS", "images/inventoryimages/cbdz6.xml"),
    Asset("IMAGE", "images/inventoryimages/cbdz7.tex"),
    Asset("ATLAS", "images/inventoryimages/cbdz7.xml"),
    Asset("IMAGE", "images/inventoryimages/cbdz8.tex"),
    Asset("ATLAS", "images/inventoryimages/cbdz8.xml"),
    Asset("ANIM", "anim/cbdz0.zip"),
    Asset("ANIM", "anim/ui_cbdz0.zip"),
    Asset("ANIM", "anim/cbdz1.zip"),
    Asset("ANIM", "anim/ui_cbdz1.zip"),
    Asset("ANIM", "anim/cbdz2.zip"),
    Asset("ANIM", "anim/ui_cbdz2.zip"),
    Asset("ANIM", "anim/cbdz3.zip"),
    Asset("ANIM", "anim/ui_cbdz3.zip"),
    Asset("ANIM", "anim/cbdz4.zip"),
    Asset("ANIM", "anim/ui_cbdz4.zip"),
    Asset("ANIM", "anim/cbdz5.zip"),
    Asset("ANIM", "anim/ui_cbdz5.zip"),
    Asset("ANIM", "anim/cbdz6.zip"),
    Asset("ANIM", "anim/ui_cbdz6.zip"),
    Asset("ANIM", "anim/cbdz7.zip"),
    Asset("ANIM", "anim/ui_cbdz7.zip"),
    Asset("ANIM", "anim/cbdz8.zip"),
    Asset("ANIM", "anim/ui_cbdz8.zip")
}

local function getitem_catback(inst, data)
    if data and data.item ~= nil then
        if TUNING.ROOMCAR_BIGBAG_FRESH then
            if data.item:HasTag("spoiled") and data.item.components.perishable:GetPercent() < 1 then
                data.item.components.perishable:SetPercent(1)
                inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_finish")
            elseif data.item:HasTag("stale") and data.item.components.perishable:GetPercent() < 1 then
                data.item.components.perishable:SetPercent(1)
                inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_finish")
            elseif data.item:HasTag("fresh") and data.item.components.perishable:GetPercent() < 1 then
                data.item.components.perishable:SetPercent(1)
                inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_finish")
            end
            if data.item.components.finiteuses and data.item.components.finiteuses:GetPercent() < 1 then
                data.item.components.finiteuses:SetPercent(1)
                inst.SoundEmitter:PlaySound("dontstarve/common/telebase_gemplace")
            end
            if data.item.components.fueled and data.item.components.fueled:GetPercent() < 1 then
                data.item.components.fueled:SetPercent(1)
                inst.SoundEmitter:PlaySound("dontstarve/common/telebase_gemplace")
            end
            if data.item.components.armor and data.item.components.armor:GetPercent() < 1 then
                data.item.components.armor:SetPercent(1)
                inst.SoundEmitter:PlaySound("dontstarve/common/telebase_gemplace")
            end
        end

        if data.item.components.stackable and not data.item.components.stackable:IsFull() and TUNING.ROOMCAR_BIGBAG_STACK and inst:HasTag("catback") then
            inst.SoundEmitter:PlaySound("dontstarve/wilson/plant_seeds")
            data.item.components.stackable:SetStackSize(data.item.components.stackable.maxsize)
        end

        if data.item.prefab == "heatrock" then
            local currenttemp = data.item.components.temperature:GetCurrent()
            if TheWorld.state.iswinter and currenttemp <= 25 then
                data.item.components.temperature:SetTemperature(currenttemp + 40)
                inst.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel")
            elseif TheWorld.state.issummer and currenttemp >= 30 then
                data.item.components.temperature:SetTemperature(currenttemp - 40)
                inst.SoundEmitter:PlaySound("dontstarve/common/gem_shatter")
            end
        end

    end
end

local function insulatorstate(inst)
    if inst.components.insulator ~= nil then
        inst:RemoveComponent("insulator")
    end
    if TheWorld.state.iswinter then
        inst:AddComponent("insulator")
        inst.components.insulator:SetWinter()
        inst.components.insulator:SetInsulation(4800)
    elseif TheWorld.state.issummer then
        inst:AddComponent("insulator")
        inst.components.insulator:SetSummer()
        inst.components.insulator:SetInsulation(4800)
    end

end

---幸运玩家隐藏事件
---月圆时间 有概率
--- 大背包中的物品，回满耐久值/回满新鲜度
--- 有堆叠的物品变成两倍但不能超过最大堆叠数
local function doBenefit_catback(inst)
    if inst.last_do_cycle_day == nil then
        inst.last_do_cycle_day = TheWorld.state.cycles
    end

    if TheWorld.state.cycles <= inst.last_do_cycle_day + 32 then
        return
    end

    --if TheWorld.state.moonphase ~= "half" then
    --    return
    --end
    if not TheWorld.state.isfullmoon then
        return
    end

    --[[local random_num = math.random()
    if not (random_num < 0.01 or ((TheWorld.state.issummer or TheWorld.state.iswinter) and TheWorld.state.remainingdaysinseason%10 < 2 and random_num<0.51)) then
        return
    end]]
    --if math.random() > 0.1 then
    --    return
    --end
    if not (TheWorld.state.issummer or TheWorld.state.iswinter) then
        return
    end

    if TheWorld.state.remainingdaysinseason > 2 then
        return
    end
    if inst.components.container == nil or inst.components.container:IsEmpty() then
        return
    end

    local owner = inst.components.inventoryitem.owner
    if owner == nil or owner.components == nil or owner.components.inventory == nil then
        return
    end

    inst.components.container:Close()
    owner:DoTaskInTime(
            0.5,
            function()
                owner.components.inventory:DropItem(inst)
            end
    )
    inst.last_do_cycle_day = TheWorld.state.cycles
    inst:DoTaskInTime(3, function()
        for i = 1, inst.components.container.numslots do
            local item = inst.components.container.slots[i]
            if item ~= nil then
                if item:HasTag("spoiled") then
                    item.components.perishable:SetPercent(1)
                elseif item:HasTag("stale") then
                    item.components.perishable:SetPercent(1)
                elseif item:HasTag("fresh") then
                    item.components.perishable:SetPercent(1)
                end
                if item.components.finiteuses then
                    item.components.finiteuses:SetPercent(1)
                end
                if item.components.fueled then
                    item.components.fueled:SetPercent(1)
                end
                if item.components.armor then
                    item.components.armor:SetPercent(1)
                end
            end
        end

        for i = 1, inst.components.container.numslots do
            local item = inst.components.container.slots[i]
            if item ~= nil then
                if item.components.stackable then
                    local itemnum = item.components.stackable:StackSize()
                    if itemnum <= item.components.stackable.maxsize / 2 then
                        item.components.stackable:SetStackSize(itemnum * 2)
                    else
                        item.components.stackable:SetStackSize(item.components.stackable.maxsize)
                    end
                end
            end
        end

        local fx = SpawnPrefab("chesterlight")
        fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
        fx:TurnOn()
        inst.SoundEmitter:PlaySound("dontstarve/creatures/chester/raise")
        inst:DoTaskInTime(1, function()
            if fx ~= nil then
                fx:TurnOff()
            end
        end)
    end)

end

local function onequip(inst, owner)
    --owner.AnimState:OverrideSymbol("backpack", "swap_catback", "backpack")
    --owner.AnimState:OverrideSymbol("swap_body", "swap_catback", "swap_body")

    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("equipskinneditem", inst:GetSkinName())
        --owner.AnimState:OverrideItemSkinSymbol("backpack", skin_build, "backpack", inst.GUID, bag_symbol[inst.prefab])
        owner.AnimState:OverrideItemSkinSymbol("swap_body", skin_build, "swap_body", inst.GUID, "swap_backpack")
    else
        --owner.AnimState:OverrideSymbol("backpack", bag_symbol[inst.prefab], "backpack")
        owner.AnimState:OverrideSymbol("swap_body", "swap_catback", "swap_body")
    end

    inst.components.container:Open(owner)
    if owner.components.health ~= nil then
        owner.components.health.externalabsorbmodifiers:SetModifier(inst, .98)
    end
    if owner.components.temperature ~= nil then
        owner.components.temperature:SetTemperature(TUNING.STARTING_TEMP)
        owner.catback_protect = true
    end
    inst.light = SpawnPrefab("lifelight")
    inst.light.entity:SetParent(owner.entity)

    if owner.components.hunger ~= nil then
        owner.components.hunger.burnratemodifiers:SetModifier(inst, 0.5)
    end
end

local function onunequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")
    owner.AnimState:ClearOverrideSymbol("backpack")
    inst.components.container:Close(owner)
    if owner.components.health ~= nil then
        owner.components.health.externalabsorbmodifiers:RemoveModifier(inst)
    end
    if owner.components.temperature ~= nil then
        owner.catback_protect = nil
    end
    if inst.light ~= nil then
        inst.light:Remove()
    end
    if owner.components.hunger ~= nil then
        owner.components.hunger.burnratemodifiers:RemoveModifier(inst)
    end
end
local function ondropped(inst)
    if inst.components.container ~= nil then
        inst.components.container:Close()
    end
end
local function onequiptomodel(inst, owner)
    inst.components.container:Close(owner)
end

local function OnHaunt(inst, haunter)
    if haunter:HasTag("playerghost") then
        haunter:PushEvent("respawnfromghost")
    end
end
local function onsave(inst, data)
    if inst.last_do_cycle_day ~= nil then
        data.last_do_cycle_day = inst.last_do_cycle_day
    else
        data.last_do_cycle_day = TheWorld.state.cycles
    end
end

local function onload(inst, data)
    if data.last_do_cycle_day ~= nil then
        inst.last_do_cycle_day = data.last_do_cycle_day
        --inst.components.named:SetName(STRINGS.NAMES.CATBIGBAG .. ":已激活")
    else
        inst.last_do_cycle_day = 1
    end
    --inst.components.named:SetName(STRINGS.NAMES.CATBACK .. "\n" .. "上次CD时间: 世界第" .. inst.last_do_cycle_day .. "天")
end
local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
    inst.MiniMapEntity:SetIcon("catback.tex")

    inst.AnimState:SetBank("catback")
    inst.AnimState:SetBuild("catback")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("backpack")
    inst:AddTag("fridge")
    inst:AddTag("nocool")
    if TUNING.ROOMCAR_BIGBAG_WATER then
        inst:AddTag("umbrella")
        inst:AddTag("waterproofer")
    end
    inst:AddTag("catback")
    inst:AddTag("special_benefit_cd_days")
    --inst:AddTag("gemsocket")
    --inst:AddTag("trader")
    --inst:AddTag("give_dolongaction")

    if TUNING.ROOMCAR_BIGBAG_KEEPFRESH then
        inst:AddTag("keepfresh")
    end

    --waterproofer (from waterproofer component) added to pristine state for optimization
    --inst:AddTag("waterproofer")

    local swap_data = { bank = "backpack1", anim = "anim" }
    MakeInventoryFloatable(inst, "med", 0.1, 0.65, nil, nil, swap_data)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    --if inst.components.preserver == nil then
    --    inst:AddComponent("preserver")
    --    inst.components.preserver:SetPerishRateMultiplier(0)---TUNING.PERISH_SALTBOX_MULT
    --end
    --inst.components.preserver:SetPerishRateMultiplier(function(inst, item)
    --    return (item ~= nil) and 0 or nil
    --end)

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/catback.xml"
    inst.components.inventoryitem.imagename = "catback"
    inst.components.inventoryitem:SetOnDroppedFn(ondropped)
    inst.components.inventoryitem.cangoincontainer = true -- [[can be carried]]!!!!!!!!!!!!!!!!!!!!
    inst.components.inventoryitem.foleysound = "dontstarve/movement/foley/marblearmour"

    --[[
    inst:AddComponent("insulator")
    inst.components.insulator:SetInsulation(TUNING.INSULATION_LARGE)
    ]]
    if TUNING.ROOMCAR_BIGBAG_KEEPFRESH then
        if inst.components.preserver==nil then
            inst:AddComponent("preserver")
        end
        inst.components.preserver:SetPerishRateMultiplier(function(inst, item)
            return (item ~= nil) and 0 or nil
        end)
    end

    inst:AddComponent("named")

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BACK or EQUIPSLOTS.BODY
    inst.components.equippable.dapperness = 6.0
    inst.components.equippable.walkspeedmult = 1.5
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable:SetOnEquipToModel(onequiptomodel)

    inst:AddComponent("waterproofer")
    inst.components.waterproofer:SetEffectiveness(1)

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("catback")--krampus_sack
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_INSTANT_REZ)
    inst.components.hauntable:SetOnHauntFn(OnHaunt)

    inst:ListenForEvent("itemget", getitem_catback)

    inst:WatchWorldState("isfullmoon", doBenefit_catback)
    --inst:WatchWorldState("moonphase",doBenefit_catback)
    inst:WatchWorldState("isday", insulatorstate)

    inst.OnSave = onsave
    inst.OnLoad = onload

    return inst
end

return Prefab("catback", fn, assets)