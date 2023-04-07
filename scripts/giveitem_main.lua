--不笑猫的拾取优化
GLOBAL.setmetatable(env, { __index = function(_, k)
    return GLOBAL.rawget(GLOBAL, k)
end })

local function FindBestContainer(self, item, containers, exclude_containers)
    if item == nil or containers == nil then
        return
    end

    --Construction containers
    --NOTE: reusing containerwithsameitem variable
    local containerwithsameitem = self.inst ~= nil and self.inst.components.constructionbuilderuidata ~= nil and self.inst.components.constructionbuilderuidata:GetContainer() or nil
    if containerwithsameitem ~= nil then
        if containers[containerwithsameitem] ~= nil then
            local slot = self.inst.components.constructionbuilderuidata:GetSlotForIngredient(item.prefab)
            if slot ~= nil then
                local container = containerwithsameitem.components.container
                if container ~= nil and container:CanTakeItemInSlot(item, slot) then
                    local existingitem = container:GetItemInSlot(slot)
                    if existingitem == nil or (container:AcceptsStacks() and existingitem.components.stackable ~= nil and not existingitem.components.stackable:IsFull()) then
                        return containerwithsameitem
                    end
                end
            end
        end
        containerwithsameitem = nil
    end

    --local containerwithsameitem = nil --reused with construction containers code above
    local containerwithemptyslot
    local containerwithnonstackableslot
    local overflowContainer = self:GetOverflowContainer()
    local backpack = overflowContainer and overflowContainer.inst

    for k, _ in pairs(containers) do
        local container = k.components.container or k.components.inventory
        if container ~= nil and container:CanTakeItemInSlot(item) and (k.persists or k == self.inst) and not (exclude_containers and exclude_containers[k]) then
            local isfull = container:IsFull()
            if container:AcceptsStacks() then
                if not isfull and (containerwithemptyslot == nil or containerwithemptyslot ~= self.inst and k == backpack or k == self.inst) then
                    containerwithemptyslot = k
                end
                if item.components.equippable ~= nil and container == k.components.inventory then
                    local equip = container:GetEquippedItem(item.components.equippable.equipslot)
                    if equip and equip.prefab == item.prefab and equip.skinname == item.skinname then
                        if equip.components.stackable ~= nil and not equip.components.stackable:IsFull() then
                            return k
                        elseif not isfull and (containerwithsameitem == nil or containerwithsameitem ~= self.inst and k == backpack or k == self.inst) then
                            containerwithsameitem = k
                        end
                    end
                end
                for _, v1 in pairs(container.itemslots or container.slots) do
                    if v1 and v1.prefab == item.prefab and v1.skinname == item.skinname then
                        if v1.components.stackable ~= nil and not v1.components.stackable:IsFull() then
                            return k
                        elseif not isfull and (containerwithsameitem == nil or containerwithsameitem ~= self.inst and k == backpack or k == self.inst) then
                            containerwithsameitem = k
                        end
                    end
                end
            elseif not isfull and containerwithnonstackableslot == nil then
                containerwithnonstackableslot = k
            end
        end
    end

    return containerwithsameitem or containerwithemptyslot or containerwithnonstackableslot
end
local function inventory(self)

    local OldGiveItem = self.GiveItem
    function self:GiveItem(item, slot, src_pos, drop_on_fail)
        if item == nil
                or item.components ==nil
                or item.components.inventoryitem == nil
                or not item:IsValid() then
            print("Warning: Can't give item because it's not an inventory item.")
            return
        end

        local eslot = self:IsItemEquipped(item)

        if eslot then
            self:Unequip(eslot)
        end

        local objectDestroyed = item.components.inventoryitem:OnPickup(self.inst, src_pos)
        if objectDestroyed then
            return
        end
        local result
        if slot == nil and drop_on_fail == nil and self.inst:HasTag("player") then
            result = self:TradeItem(item, slot, src_pos)
        end
        if not result then
            return OldGiveItem(self, item, slot, src_pos)
        end
        return result
    end
    function self:TradeItem(item, slot, src_pos)
        if item ~= nil then
            local opencontainers = self.opencontainers
            if next(opencontainers) == nil then
                return
            end

            local overflow = self:GetOverflowContainer()
            local backpack
            if overflow ~= nil and overflow:IsOpenedBy(self.inst) then
                backpack = overflow.inst
            end

            opencontainers[self.inst] = true
            local container_owner = item.components.inventoryitem and item.components.inventoryitem.owner
            local exclude_containers = container_owner and container_owner ~= self.inst and { [container_owner] = true }
            local dest_inst
            dest_inst = FindBestContainer(self, item, opencontainers, exclude_containers)
            opencontainers[self.inst] = nil
            if dest_inst and dest_inst ~= self.inst and dest_inst ~= backpack then
                return dest_inst.components.container:GiveItem(item, slot, src_pos)
            end
        end
        return false
    end
end
AddComponentPostInit("inventory", inventory)