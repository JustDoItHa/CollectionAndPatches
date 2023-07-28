--if GLOBAL.TheNet:IsDedicated() then  return end
GLOBAL.setmetatable(env, {__index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end})

-- 目前是按住ctrl一次拿10个，正常一次拿1个
local AMOUNT_GROUP_LARGE = 10
local AMOUNT_GROUP_MID = 5		-- 5个5个取感觉有点怪，暂时没用到
local AMOUNT_GROUP_SMALL = 1

-- 默认FORCE ATTACK绑定的左control
local MOD_GROUP_LARGE = CONTROL_FORCE_ATTACK

local last_adjust_time = 0
-- repeat cd，太慢了可能影响手感，太快了频繁发RPC
local ADJUST_REPEAT_COOLDOWN = FRAMES

-- 滚轮上下滑动功能颠倒
local MOUSEWHEEL_DIRECTION_INVERSE = false

local modname = "CAP"

-- 别看写了那么多，全tm复制粘贴改个数
-- these codes base on COPY
----------------------------------INVENTORY-----------------------------------------------
local function Inventory_AddSomeOfSlotToActiveItem(self, slot, amount)
    local item = self:GetItemInSlot(slot)
    local active_item = self:GetActiveItem()
    if item ~= nil and
            active_item ~= nil and
            item.components.stackable ~= nil and
            --item.components.stackable:IsStack() and
            item.components.stackable:StackSize() >= amount and
            active_item.components.stackable ~= nil and
            active_item.components.stackable:StackSize() + amount <= active_item.components.stackable.maxsize and
            item.prefab == active_item.prefab and item.skinname == active_item.skinname then
        -- notice that this does not work on clients, use AnimState:GetSkinBuild instead on clients

        local someitem = item.components.stackable:Get(amount) -- half-->some
        local leftovers = active_item.components.stackable:Put(someitem)
        someitem.prevslot = slot
        someitem.prevcontainer = nil -- nil means inventory
        self:GiveActiveItem(leftovers)
        --print("inv_takeone_succ")
    end
    --print(item.components.stackable,active_item.components.stackable)
end

local function Inventory_AddSomeOfActiveItemToSlot(self, slot, amount)
    local active_item = self:GetActiveItem()
    local item = self:GetItemInSlot(slot)
    if active_item ~= nil and
            item ~= nil and
            self:CanTakeItemInSlot(active_item, slot) and
            item.prefab == active_item.prefab and item.skinname == active_item.skinname and
            item.components.stackable ~= nil and
            self:AcceptsStacks() and
            active_item.components.stackable ~= nil and
            active_item.components.stackable:StackSize() > amount and
            item.components.stackable:StackSize() + amount <= item.components.stackable.maxsize then -- will not overflow

        item.components.stackable:Put(active_item.components.stackable:Get(amount))
    end
end

local function Inventory_PutSomeOfActiveItemInSlot(self, slot, amount)
    local active_item = self:GetActiveItem()
    if active_item ~= nil and
            self:GetItemInSlot(slot) == nil and
            self:CanTakeItemInSlot(active_item, slot) and
            active_item.components.stackable ~= nil and
            active_item.components.stackable:StackSize() > amount then

        self.ignoresound = true
        self:GiveItem(active_item.components.stackable:Get(amount), slot)
        self.ignoresound = false
    end
end

AddComponentPostInit("inventory",function(self)
    if self.AddSomeOfSlotToActiveItem == nil then
        self.AddSomeOfSlotToActiveItem = Inventory_AddSomeOfSlotToActiveItem
        self.AddSomeOfActiveItemToSlot = Inventory_AddSomeOfActiveItemToSlot
        self.PutSomeOfActiveItemInSlot = Inventory_PutSomeOfActiveItemInSlot
    end
end)
-----------------------------------CONTAINER---------------------------------------------
local function QueryActiveItem(self, opener)
    local inventory = opener ~= nil and opener.components.inventory or nil
    return inventory, inventory ~= nil and inventory:GetActiveItem() or nil
end

-- the difference between inventory and container is that container need register currentuser info
local function Container_AddSomeOfSlotToActiveItem(self, slot, amount, opener)
    local inventory, active_item = QueryActiveItem(self, opener)
    local item = self:GetItemInSlot(slot)
    if item ~= nil and
            active_item ~= nil and
            inventory ~= nil and
            item.components.stackable ~= nil and
            --item.components.stackable:IsStack() and
            item.components.stackable:StackSize() >= amount and --add a extra judgment to ensure we have enough amount
            active_item.components.stackable ~= nil and
            active_item.components.stackable:StackSize() + amount <= active_item.components.stackable.maxsize and -- and ensure will not overflow
            item.prefab == active_item.prefab and item.skinname == active_item.skinname then

        self.currentuser = opener

        local someitem = item.components.stackable:Get(amount) -- half-->some
        local leftovers = active_item.components.stackable:Put(someitem)
        someitem.prevslot = slot
        someitem.prevcontainer = self
        inventory:GiveActiveItem(leftovers)

        self.currentuser = nil
        --print("takeone_succ")
    end
    --print(item.components.stackable,active_item.components.stackable)
end

local function Container_AddSomeOfActiveItemToSlot(self, slot, amount, opener)
    local inventory, active_item = QueryActiveItem(self, opener)
    local item = self:GetItemInSlot(slot)
    if active_item ~= nil and
            item ~= nil and
            self:CanTakeItemInSlot(active_item, slot) and
            item.prefab == active_item.prefab and item.skinname == active_item.skinname and
            item.components.stackable ~= nil and
            self:AcceptsStacks() and
            active_item.components.stackable ~= nil and
            active_item.components.stackable:IsStack() and
            active_item.components.stackable:StackSize() > amount and  --add a extra judgment to ensure we have enough amount
            item.components.stackable:StackSize() + amount <= item.components.stackable.maxsize then

        self.currentuser = opener

        item.components.stackable:Put(active_item.components.stackable:Get(amount))

        self.currentuser = nil
    end
end


local function Container_PutSomeOfActiveItemInSlot(self, slot, amount, opener)
    local inventory, active_item = QueryActiveItem(self, opener)
    if active_item ~= nil and
            self:GetItemInSlot(slot) == nil and
            self:CanTakeItemInSlot(active_item, slot) and
            active_item.components.stackable ~= nil and
            active_item.components.stackable:IsStack() and
            active_item.components.stackable:StackSize() > amount then

        self.currentuser = opener

        self.ignoresound = true
        self:GiveItem(active_item.components.stackable:Get(amount), slot)
        self.ignoresound = false

        self.currentuser = nil
    end
end
AddComponentPostInit("container",function(self)
    if self.AddSomeOfSlotToActiveItem == nil then
        self.AddSomeOfSlotToActiveItem = Container_AddSomeOfSlotToActiveItem
        self.AddSomeOfActiveItemToSlot = Container_AddSomeOfActiveItemToSlot
        self.PutSomeOfActiveItemInSlot = Container_PutSomeOfActiveItemInSlot
    end
end)

-------------------------------------ADD MODRPC HANDLER---------------------------
-- 我不知道这样可不可行，目前是先服务端更新后发放给客户端更新，而官方用的classfied是先更新客户端数据再发送RPC请求服务端更新
-- 目前已知的问题就是：1.数量到账需要等待服务器延迟。2.不同步会触发classified的OnStackItemDirty，有额外的声音
-- 不然的话就得PostInit classified了，里面的PushStackSize是local方法，要不就抄一份要不就用upvalue hacker
AddModRPCHandler(modname,"AddSomeOfSlotToActiveItem",function(player, amount, slot, container)
    if not (checkuint(slot) and
            optentity(container)) then
        --printinvalid("TakeActiveItemFromHalfOfSlot", player)
        print("invalidModRpc in AddSomeOfSlotToActiveItem")
        return
    end
    local inventory = player.components.inventory
    if inventory ~= nil then
        if container == nil then
            inventory:AddSomeOfSlotToActiveItem(slot, amount)
            --print("call inv takeone")
        else
            container = container.components.container
            if container ~= nil and container:IsOpenedBy(player) then
                container:AddSomeOfSlotToActiveItem(slot, amount, player)
                --print("call container takeone")
            end
        end
    end
end)

AddModRPCHandler(modname,"AddSomeOfActiveItemToSlot",function(player, amount, slot, container)
    if not (checkuint(slot) and
            optentity(container)) then
        --printinvalid("TakeActiveItemFromHalfOfSlot", player)
        print("invalidModRpc in AddSomeOfActiveItemToSlot")
        return
    end
    local inventory = player.components.inventory
    if inventory ~= nil then
        if container == nil then
            inventory:AddSomeOfActiveItemToSlot(slot, amount)
            --print("call inv takeone")
        else
            container = container.components.container
            if container ~= nil and container:IsOpenedBy(player) then
                container:AddSomeOfActiveItemToSlot(slot, amount, player)
                --print("call container takeone")
            end
        end
    end
end)

AddModRPCHandler(modname,"PutSomeOfActiveItemInSlot",function(player, amount, slot, container)
    if not (checkuint(slot) and
            optentity(container)) then
        --printinvalid("TakeActiveItemFromHalfOfSlot", player)
        print("invalidModRpc in PutSomeOfActiveItemInSlot")
        return
    end
    local inventory = player.components.inventory
    if inventory ~= nil then
        if container == nil then
            inventory:PutSomeOfActiveItemInSlot(slot, amount)
            --print("call inv takeone")
        else
            container = container.components.container
            if container ~= nil and container:IsOpenedBy(player) then
                container:PutSomeOfActiveItemInSlot(slot, amount, player)
                --print("call container takeone")
            end
        end
    end
end)

-----------------------------INVSLOT TWEAK-----------------------------
local function AdjustActiveItem(self, amount, slot_num, add)
    local slot_number = slot_num
    local character = ThePlayer
    local inventory = character and character.replica.inventory or nil
    local active_item = inventory and inventory:GetActiveItem() or nil
    local container = self.container -- container_replica
    local container_item = container and container:GetItemInSlot(slot_number) or nil

    if active_item ~= nil then

        if not add then
            --- mouse wheel down ,active_item num decrease ,put into container
            if container_item == nil then

                if container:CanTakeItemInSlot(active_item, slot_number) then
                    if active_item.replica.stackable ~= nil and
                            active_item.replica.stackable:IsStack() and
                            active_item.replica.stackable:StackSize() > amount and
                            container:AcceptsStacks() then
                        --Put one only
                        --container:PutOneOfActiveItemInSlot(slot_number)
                        --SendRPCToServer(RPC.PutOneOfActiveItemInSlot, slot_number,(container ~= inventory) and container.inst or nil)
                        SendModRPCToServer(MOD_RPC[modname]["PutSomeOfActiveItemInSlot"], amount, slot_number,(container ~= inventory) and container.inst or nil)
                        --print("put one")
                    end
                    TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/click_object")
                else
                    TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/click_negative")
                end
            elseif container:CanTakeItemInSlot(active_item, slot_number) then
                if container_item.prefab == active_item.prefab and
                        container_item.AnimState:GetSkinBuild() == active_item.AnimState:GetSkinBuild() and
                        container_item.replica.stackable ~= nil and container:AcceptsStacks() then
                    if active_item.replica.stackable ~= nil and
                            active_item.replica.stackable:IsStack() and
                            active_item.replica.stackable:StackSize() > amount and	-- have enough source
                            container_item.replica.stackable:StackSize() + amount <= container_item.replica.stackable:MaxSize() then
                        --Add only one
                        --container:AddOneOfActiveItemToSlot(slot_number)
                        --SendRPCToServer(RPC.AddOneOfActiveItemToSlot, slot_number,(container ~= inventory) and container.inst or nil)
                        SendModRPCToServer(MOD_RPC[modname]["AddSomeOfActiveItemToSlot"], amount, slot_number,(container ~= inventory) and container.inst or nil)
                        --print("add one")
                    end
                    TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/click_object")
                else
                    TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/click_negative")
                end
            else
                TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/click_negative")
            end
        else
            --- mouse wheel up ,active_item num increase ,take from container
            -- if container_item.replica.stackable ~= nil and
            -- container_item.replica.stackable:IsStack() then
            --Take one only
            -- end
            if container_item ~= nil and container_item.prefab == active_item.prefab and
                    container_item.AnimState:GetSkinBuild() == active_item.AnimState:GetSkinBuild() and
                    container_item.replica.stackable ~= nil and container_item.replica.stackable:StackSize() >= amount and -- we have enough source
                    container:AcceptsStacks() then
                if active_item.replica.stackable ~= nil and
                        --and active_item.replica.stackable:IsStack() then
                        active_item.replica.stackable:StackSize() + amount <= active_item.replica.stackable:MaxSize() then--  will not overflow

                    SendModRPCToServer(MOD_RPC[modname]["AddSomeOfSlotToActiveItem"], amount, slot_number,(container ~= inventory) and container.inst or nil)
                end
                TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/click_object")
            else
                TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/click_negative")
            end
        end
    end

end


local function invslot_postinit(self)

    local old_OnMouseButton = self.OnMouseButton
    self.OnMouseButton = function(self, button, down, x, y)

        --print("trigger")
        if ThePlayer and ThePlayer.replica.inventory:GetActiveItem() ~= nil and
                down and (button == MOUSEBUTTON_SCROLLUP or button == MOUSEBUTTON_SCROLLDOWN or button == MOUSEBUTTON_MIDDLE) then
            local time = GetStaticTime()
            if last_adjust_time == nil or time - last_adjust_time > ADJUST_REPEAT_COOLDOWN then
                -- 主要是IsKeyDown 经常会卡键误检
                local amount = TheInput:IsControlPressed(MOD_GROUP_LARGE) and AMOUNT_GROUP_LARGE or AMOUNT_GROUP_SMALL

                if button == (MOUSEWHEEL_DIRECTION_INVERSE and MOUSEBUTTON_SCROLLDOWN or MOUSEBUTTON_SCROLLUP) then
                    AdjustActiveItem(self, amount, self.num, true)
                elseif button == (MOUSEWHEEL_DIRECTION_INVERSE and MOUSEBUTTON_SCROLLUP or MOUSEBUTTON_SCROLLDOWN) then
                    AdjustActiveItem(self, amount, self.num, false)
                    -- if ThePlayer.replica.inventory:GetActiveItem() ~= nil then
                    -- self:Click(true)
                    -- end
                    --elseif button == MOUSEBUTTON_MIDDLE then

                    --TODO： 调整为一半,感觉又好像没有这个需求的必要
                end
                last_adjust_time = time
            end
        end
        return old_OnMouseButton and old_OnMouseButton(self, button, down, x, y)
    end
end

--if not GLOBAL.TheNet:IsDedicated() then
AddClassPostConstruct("widgets/invslot",invslot_postinit)
--end

----------------playercontroller----------

local function IsCursorOnHUD()
    local input = TheInput
    return input.hoverinst and input.hoverinst.Transform == nil and input.hoverinst.entity:IsVisible()
    --idk why function GetHUDEntityUnderMouse() sometime return false because of the hoverinst.entity:Isvalid()
    --so i remove it
end

local function playercontroller_postinit(self)
    local old_DoCameraControl = self.DoCameraControl
    function self:DoCameraControl()
        if not ((TheInput:IsControlPressed(CONTROL_ZOOM_IN) or TheInput:IsControlPressed(CONTROL_ZOOM_OUT)) and IsCursorOnHUD() ) then
            if old_DoCameraControl ~= nil then
                old_DoCameraControl(self)
            end
        end

    end

    --local old_OnControl = self.OnControl
    --function self:OnControl(control, down)
    --	if not (control == CONTROL_ACCEPT or control == CONTROL_PRIMARY and TheInput:GetHUDEntityUnderMouse() ~= nil )then
    --		old_OnControl(self, control, down)
    --	end
    --end


end

AddComponentPostInit("playercontroller",playercontroller_postinit)

-- replica在单多层世界都有，replica 会根据是不是单层世界(又是客户端又是服务器)采取行动
--(单层世界有component直接用component,
--多层世界只有classified（是个prefab），里面更新缓存的数据，然后发送RPC)
-- 例如：
-- function Container:AddOneOfActiveItemToSlot(slot)
-- if self.inst.components.container ~= nil then
-- self.inst.components.container:AddOneOfActiveItemToSlot(slot, ThePlayer)
-- elseif self.classified ~= nil then
-- self.classified:AddOneOfActiveItemToSlot(slot)
-- end
-- end
-- 而container_classified 内置了一个队列，定期更新_busy，因此会有频率限制，所以我想直接SendRPC，但是这样会产生一些问题，看看ADD MODRPC HANDLER那里的注释
--local TIMEOUT = 0.5
-- local function QueueRefresh(inst, delay)
-- if inst._refreshtask == nil then
-- inst._refreshtask = inst:DoStaticTaskInTime(delay, Refresh)
-- inst._busy = true
-- RefreshCrafting(inst)
-- end
-- end

-- local function PutOneOfActiveItemInSlot(inst, slot)
-- if not IsBusy(inst) and inst._activeitem ~= nil then	--因为有频率限制，如果短时间多次触发，IsBusy会return true
-- local giveitem = SlotItem(inst._activeitem, slot)
-- PushItemGet(inst, giveitem, true)
-- PushStackSize(inst, inst._activeitem, 1, false, inst._activeitem.replica.stackable:StackSize() - 1, true)
-- SendRPCToServer(RPC.PutOneOfActiveItemInSlot, slot)
-- end
-- end

