local containers = require("containers")
local assert = GLOBAL.assert
local setmetatable = GLOBAL.setmetatable
local next = GLOBAL.next

--for containers data not listed in containers.params
local fakedcontainer = { SetNumSlots = function() end }
local function checkparams(prefab)
    if containers.params[prefab] == nil then
        containers.params[prefab] = {}
        local container = setmetatable(containers.params[prefab], { __index = fakedcontainer })
        containers.widgetsetup(container, prefab)
    end
end

local function IsSideWidget(prefab)
    local param = containers.params[prefab] or {}
    --	local str = string.format("[Upgradeable Chest]: Cannot find container params\n\tcontainer: %s", prefab)
    --	assert(cont ~= nil, str)
    if containers.params[prefab] == nil then
        print("[Upgradeable Chest]: Cannot find container params:", prefab)
        containers.params[prefab] = param
        local container = setmetatable(param, { __index = fakedcontainer })
        containers.widgetsetup(container, prefab)
        if next(param) ~= nil then
            print("[Upgradeable Chest]: Container params added:", prefab)
            for k, v in pairs(param) do
                print("", k, v)
            end
        end
    end
    return param.widget.issidewidget, param.widget.type
end

--------------------------------------------------
--change chest size scaled to its level
local function ChangeSize(inst)
    local cupg = inst.components.chestupgrade
    local clv = cupg.chestlv
    local blv = cupg.baselv
    inst.Transform:SetScale(
            ((clv.x / blv.x - 1) / TUNING.CHESTUPGRADE.SCALE_FACTOR + 1),
            ((clv.y / blv.y - 1) / TUNING.CHESTUPGRADE.SCALE_FACTOR + 1),
            1
    )
    if inst.prefab == "fish_box" then
        local x, y = inst.Transform:GetScale()
        inst.Transform:SetScale(x * 1.3, y * 1.3, 1.3)
    end
end

--------------------------------------------------
--some ui related config
local function CustomUI(prefab, widgetpos, bgimage)
    --if IsSideWidget(prefab) then return end
    local _, cont_type = IsSideWidget(prefab)

    widgetpos = cont_type == "chest" and widgetpos ~= false and GetModConfigData("UI_WIDGETPOS", true)
    bgimage = bgimage ~= false and GetModConfigData("UI_BGIMAGE", true)

    --make the widget to the left
    if widgetpos then
        containers.params[prefab].widget.pos = GLOBAL.Vector3(-140, 0, 0)
    end

    --hide bgimage
    if bgimage then
        containers.params[prefab].widget.animbuild = nil
        containers.params[prefab].widget.animbank = nil
    end
end

--------------------------------------------------
--add chestupgrade components to the container
--we will make it upgrade-able later
--x, y would be its size. ie. treasure chest 3,3; dragonfly chest 3,4; backpack 2,4
local function AddUpgradable(prefab, x, y)
    --CustomUI(prefab)

    AddPrefabPostInit(prefab, function(inst)
        if not GLOBAL.TheWorld.ismastersim then
            return
        end
        inst:AddComponent("chestupgrade")
        if x ~= nil and y ~= nil then
            inst.components.chestupgrade:SetBaseLv(x, y)
        end

        if GetModConfigData("CHANGESIZE") and inst.Transform ~= nil then
            inst:ListenForEvent("onchestlvchange", ChangeSize)
        end
    end)
end

--------------------------------------------------
local function OnDegradable(inst, data)
    if inst.components.container.opencount ~= 0 then
        return
    end
    local chestupgrade = inst.components.chestupgrade
    local x, y, z = chestupgrade:GetLv()
    local blv = chestupgrade.baselv
    if x > blv.x or y > blv.y or z > blv.z then
        chestupgrade:Degrade(data.doer)
    end
end

--upgrade the chest when it is closed
--can be customized like upgrade when you kill 3 monster
--or upgrade when it is full moon, using WatchWorldState
local function SetOnCloseFn(prefab, fn, degradable)
    AddPrefabPostInit(prefab, function(inst)
        if not GLOBAL.TheWorld.ismastersim then
            return
        end
        --check if upgrade posible when the container is closed
        inst:ListenForEvent("onclose", fn)

        if degradable == nil and not IsSideWidget(prefab) then
            degradable = GetModConfigData("DEGRADABLE")
        end

        if degradable ~= false then
            inst:ListenForEvent("onclose", OnDegradable)
        end
    end)
end

--------------------------------------------------
--a quicker way to set the close fn
--designing how to modify this
local function SetCommonCloseFn(prefab, para, degradable)
    local function GetSUpgData(mode, x, y, z)
        local data = {
            slot = {},
        }
        local major, minor
        for k, v in pairs(para) do
            if k == "side" then
                major = v
            else
                minor = v
                if type(minor) == "table" then
                    while type(minor[1]) == "table" do
                        minor = minor[1]
                    end
                end
            end
        end
        if mode == 0 then
            --page
            for i = 1, x * y do
                table.insert(data.slot, major)
            end
        elseif mode == 1 then
            --column
            data.column = {}
            data.column[x] = major
            data.slot[x] = minor
        elseif mode == 2 then
            --row
            local i = x * y - x + 1
            data.row = {}
            data.row[y] = major
            data.slot[i] = minor
        end
        return data
    end

    local function OnChestClose(inst, data)
        local container = inst.components.container
        --upgrade only if all player close the container
        if container.opencount ~= 0 then
            return
        end

        local chestupgrade = inst.components.chestupgrade
        local x, y, z = chestupgrade:GetLv()

        --upgd mode: 1: normal; 2: row/column; 3: both 1 & 2
        if GetModConfigData("UPG_MODE") ~= 1 then
            --column upgd
            if x < TUNING.CHESTUPGRADE.MAX_LV then
                chestupgrade:SpecialUpgrade(GetSUpgData(1, x, y, z), data.doer, { x = 1 })
            end
            --row upgd
            if y < TUNING.CHESTUPGRADE.MAX_LV then
                chestupgrade:SpecialUpgrade(GetSUpgData(2, x, y, z), data.doer, { y = 1 })
            end
        end

        --normal upgd
        if GetModConfigData("UPG_MODE") ~= 2 then
            chestupgrade:Upgrade(TUNING.CHESTUPGRADE.MAX_LV, para, data.doer)
        end

        --page upgd
        if GetModConfigData("PAGEABLE") then
            --can be upgd only when it is in max lv
            if x * y >= TUNING.CHESTUPGRADE.MAX_LV ^ 2 and z < TUNING.CHESTUPGRADE.MAX_PAGE then
                chestupgrade:SpecialUpgrade(GetSUpgData(0, x, y, z), data.doer, { z = 1 })
            end
        end
    end

    SetOnCloseFn(prefab, OnChestClose, degradable)
end

--------------------------------------------------
--a quicker way for backpack
local function SetPackCloseFn(prefab, item)
    local function GetPackUpgData(prefab, x, y, z)
        if type(item) == "table" then
            return item
        end
        local data = { slot = {} }
        for i = 1, x * y do
            table.insert(data.slot, { item, 1 })
        end
        return data
    end

    local function OnPackClose(inst, data)
        local container = inst.components.container
        if container.opencount == 0 then
            local chestupgrade = inst.components.chestupgrade
            local x, y, z = chestupgrade:GetLv()

            if z < (chestupgrade.baselv.z + TUNING.CHESTUPGRADE.MAXPACKUPGRADE) then
                chestupgrade:SpecialUpgrade(GetPackUpgData(inst.prefab, x, y, z), data.doer, { z = 1 })
            end
        end
    end

    SetOnCloseFn(prefab, OnPackClose, false)
end

--------------------------------------------------
local function itemtest(temp_items, item, ...)
    for k, v in pairs(temp_items) do
        if type(v) == "string" then
            if v == item.prefab then
                return true
            end
        elseif type(v) == "table" then
            if v.type ~= nil then
                if v.type == item.prefab then
                    return true
                end
            else
                return itemtest(v, item)
            end
        elseif type(v) == "function" then
            if v(item, ...) then
                return true
            end
        end
    end
end

--make item be able to put into container, but drop when close
--backpack is not suggested to add this. only unequiping the backpack will "close" it
--that means we can put something it is not supposed to carry and go everywhere
local function SetTempContainable(prefab, temp_items)
    --make upgd items can be put into the container
    local OLD_itemtestfn = containers.params[prefab].itemtestfn

    if OLD_itemtestfn == nil then
        return
    end

    if temp_items == nil then
        temp_items = GLOBAL.ChestUpgrade.AllUpgradeRecipes[prefab].params or {}
    end

    containers.params[prefab].itemtestfn = function(cont, item, slot)
        if itemtest(temp_items, item, slot, cont) then
            return true
        end

        return item:HasTag("HAMMER_tool")
                or OLD_itemtestfn(cont, item, slot)
    end

    --drop upgd material that are not able to put in to the container
    local function DropTempItem(inst, data)
        local container = inst.components.container
        if OLD_itemtestfn ~= nil and container.opencount == 0 then
            local drop = {}
            for i = 1, container:GetNumSlots() do
                local item = container.slots[i]
                if item ~= nil and not OLD_itemtestfn(container, item, i) then
                    --stack all stackable to make the floor tidy
                    local slot = drop[item.prefab]
                    local stackable = item.components.stackable
                    if item.components.stackable then
                        if slot ~= nil then
                            if (stackable:StackSize() + container.slots[slot].components.stackable:StackSize()) > stackable.maxsize then
                                stackable:Put(container.slots[slot])
                                container:DropItemBySlot(i, data.doer:GetPosition())
                            else
                                container.slots[slot].components.stackable:Put(item)
                            end
                        else
                            drop[item.prefab] = i
                        end
                    else
                        container:DropItemBySlot(i, data.doer:GetPosition())
                    end
                end
            end
            for k, v in pairs(drop) do
                container:DropItemBySlot(v, data.doer:GetPosition())
            end
        end
    end

    AddPrefabPostInit(prefab, function(inst)
        if not GLOBAL.TheWorld.ismastersim then
            return
        end
        inst:ListenForEvent("onclose", DropTempItem)
    end)
end

--------------------------------------------------
--simple and easy. nice~~
local function EasySetUp(prefab, para, size)
    --print("Make "..prefab.." upgradeable")
    local ChestUpgrade = GLOBAL.ChestUpgrade
    local UpgradeRecipe = ChestUpgrade.UpgradeRecipe
    local AllUpgradeRecipes = ChestUpgrade.AllUpgradeRecipes

    if size == nil and AllUpgradeRecipes[prefab] ~= nil then
        size = AllUpgradeRecipes[prefab].lv
    end
    if para == nil and AllUpgradeRecipes[prefab] ~= nil then
        para = AllUpgradeRecipes[prefab].params or {}
    end

    local x, y = (size.x or size[1]), (size.y or size[2])
    AddUpgradable(prefab, x, y)

    local side = IsSideWidget(prefab)
    if side then
        SetPackCloseFn(prefab, nil, para)
        SetTempContainable(prefab, para)
    else
        local degradable = GetModConfigData("DRAGGABLE")

        --CustomUI(prefab)
        SetCommonCloseFn(prefab, para, degradable)
        SetTempContainable(prefab, para)
    end

    if AllUpgradeRecipes[prefab] == nil then
        UpgradeRecipe(prefab, para, { x, y })
    end
end

--------------------------------------------------
local ChestUpgrade = {
    CustomUI = CustomUI,
    AddUpgradable = AddUpgradable,
    SetOnCloseFn = SetOnCloseFn,
    SetCommonCloseFn = SetCommonCloseFn,
    SetPackCloseFn = SetPackCloseFn,
    SetTempContainable = SetTempContainable,
    EasySetUp = EasySetUp,
}

GLOBAL.ChestUpgrade = ChestUpgrade

--return ChestUpgrade