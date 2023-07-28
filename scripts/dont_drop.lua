local _G = GLOBAL
local R_diao = GetModConfigData("rendiao") or 0
local B_diao = GetModConfigData("baodiao") or 0
local amu_diao = GetModConfigData("amudiao") or false
local zhuang_bei = GetModConfigData("zbdiao") or false
local modnillots = GetModConfigData("nillots") or 0
local drown_drop = GetModConfigData("drown_drop")
local R_d = R_diao - 3
local B_d = B_diao - 5
if R_d < 0 then
    R_d = 0
end
if B_d < 0 then
    B_d = 0
end

AddComponentPostInit("container", function(Container, inst)
    function Container:DropSuiji(ondeath)
        local amu_x = true
        local rev_x = true
        for k = 1, self.numslots do
            local v = self.slots[k]
            if amu_diao and amu_x and v and (v.prefab == "amulet" or v.prefab == "reviver") then
                --掉落护符or v.prefab == "yeyu_sword"
                amu_x = false
                self:DropItem(v)
            end
            -- if amu_diao and rev_x and v and v.prefab == "reviver" then --掉落心脏
            -- 	rev_x = false
            -- 	self:DropItem(v)
            -- end
        end
        for k = 1, self.numslots do
            --随机掉落背包里的物品
            local v = self.slots[math.random(1, self.numslots)]
            if k > math.random(B_d, B_diao) then
                return false
            end
            if v then
                self:DropItem(v)
            end
        end
    end
end)

AddComponentPostInit("inventory", function(Inventory, inst)
    Inventory.oldDropEverythingFn = Inventory.DropEverything
    function Inventory:DropSuiji(ondeath)
        local amu_x = true
        local rev_x = true
        local nillots = modnillots
        for k = 1, self.maxslots do
            local v = self.itemslots[k]
            if amu_diao and amu_x and v and (v.prefab == "amulet" or v.prefab == "reviver") then
                --掉落护符 or v.prefab == "yeyu_sword"
                amu_x = false
                self:DropItem(v, true, true)
            end
            -- if amu_diao and rev_x and v and v.prefab == "reviver" then --掉落心脏
            -- 	rev_x = false
            -- 	self:DropItem(v, true, true)
            -- end
        end

        for k = 1, self.maxslots do
            --随机掉落身体上的物品
            if k ~= 1 and k > math.random(R_d, R_diao) then
                return false
            end
            if v then
                self:DropItem(v, true, true)
            end
        end

        for k = 1, self.maxslots do
            --计算空格数量
            if v == nil then
                nillots = nillots + 1
            end
        end
        if nillots == 0 then
            --掉落身体上一格的物品，为了能够使用心脏复活
            local v = self.itemslots[1] --math.random(1, self.maxslots)
            if v then
                self:DropItem(v, true, true)
            end
        end
    end

    function Inventory:PlayerSiWang(ondeath)
        -- For WX-78's modules, they will be dropped!
        if (self.inst.components.upgrademoduleowner ~= nil) then
            -- The game pushes their modules into the ActiveItem slot(the mouse cursor), this prevents them from respawning correctly.
            -- So drop it!
            self.inst.components.inventory:DropActiveItem()
        end

        for k, v in pairs(self.equipslots) do
            if v:HasTag("backpack") and v.components.container then
                v.components.container:DropSuiji(true)
            end
            -- if v.prefab == "yeyu_sword" then
            -- 	self:DropItem(v, true, true)
            -- end
        end
        if zhuang_bei then
            for k, v in pairs(self.equipslots) do
                if not v:HasTag("backpack") then
                    self:DropItem(v, true, true)
                end
            end
        end
        self.inst.components.inventory:DropSuiji(true)
    end

    function Inventory:DropEverything(ondeath, keepequip)
        if not inst:HasTag("player") or inst:HasTag("player") and not inst.components.health  --不是玩家或玩家有血则掉落全部物品
                or inst:HasTag("player") and inst.components.health and inst.components.health.currenthealth > 0 then
            --兼容换人
            return Inventory:oldDropEverythingFn(ondeath, keepequip)
        else
            return Inventory:PlayerSiWang(ondeath)
        end
    end
end)

AddComponentPostInit("inventory", function(self)
    --有容器装备 死亡 冰冻 催眠等 等不自动关闭
    local oldHide = self.Hide
    self.Hide = function(self, ...)
        local equ_loot = {}
        for k, v in pairs(self.opencontainers) do
            if table.contains(self.equipslots, k) then
                if k.components.container then
                    table.insert(equ_loot, k)
                end
            end
        end

        if oldHide then
            oldHide(self, ...)
        end

        if #equ_loot > 0 then
            for k, v in ipairs(equ_loot) do
                if self.inst and v and self:IsHolding(v) and not v.components.container:IsOpenedBy(self.inst) then
                    --and v.components.equippable:IsEquipped()
                    v.components.container:Open(self.inst)
                end
            end
        end
    end

    local oldClose = self.Close
    self.Close = function(self, ...)
        local equ_loot = {}
        for k, v in pairs(self.opencontainers) do
            if table.contains(self.equipslots, k) then
                if k.components.container then
                    table.insert(equ_loot, k)
                end
            end
        end

        if oldClose then
            oldClose(self, ...)
        end

        if #equ_loot > 0 then
            for k, v in ipairs(equ_loot) do
                if self.inst and v and self:IsHolding(v) and not v.components.container:IsOpenedBy(self.inst) then
                    --and v.components.equippable:IsEquipped()
                    v.components.container:Open(self.inst)
                end
            end
        end
    end

end)

if not drown_drop then
    AddComponentPostInit("drownable", function(component)
        component.DropInventory = function(self, inst)
        end
        component.ShouldDropItems = function(self, inst)
        end
    end)
end
