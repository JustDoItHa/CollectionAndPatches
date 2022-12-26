--对于开 阿比 度日如年 玩家物品栏 勋章栏异常的权宜之计
if TUNING.ADD_MEDAL_EQUIPSLOTS then

    -- local Inv = require "widgets/inventorybar"
    local Widget = require "widgets/widget"

    if GLOBAL.EQUIPSLOTS then
        GLOBAL.EQUIPSLOTS["MEDAL"] = "medal"
    else
        GLOBAL.EQUIPSLOTS = {
            HANDS = "hands",
            HEAD = "head",
            BODY = "body",
            MEDAL = "medal",
        }
    end
    GLOBAL.EQUIPSLOT_IDS = {}
    local slot = 0--装备栏格子数量
    local noslot = {--屏蔽元素反应模组的额外装备栏，防止装备栏UI异常增长
        CIRCLET = true,
        SANDS = true,
        GOBLET = true,
        FLOWER = true,
        PLUME = true,

        ODOY_LIFEFUEL = true --度日如年
    }
    for k, v in pairs(GLOBAL.EQUIPSLOTS) do
        slot = slot + (noslot[k] and 0 or 1)
        GLOBAL.EQUIPSLOT_IDS[v] = slot
    end

    -- AddGlobalClassPostConstruct("widgets/inventorybar", "Inv", function(self)
    AddClassPostConstruct("widgets/inventorybar", function(self)
        local W = 68
        local SEP = 12
        local INTERSEP = 28
        -- local Inv_Refresh_base = Inv.Refresh or function() return "" end
        -- local Inv_Rebuild_base = Inv.Rebuild or function() return "" end
        local Inv_Refresh_base = self.Refresh or function()
            return ""
        end
        local Inv_Rebuild_base = self.Rebuild or function()
            return ""
        end

        self.medal_inv = self.root:AddChild(Widget("medal_inv"))
        self.medal_inv:SetScale(1.5, 1.5)

        --获取total_w
        local function getTotalW(self)
            local inventory = self.owner.replica.inventory
            local num_slots = inventory:GetNumSlots()
            local num_equip = #self.equipslotinfo
            local num_buttons = self.controller_build and 0 or 1
            local num_slotintersep = math.ceil(num_slots / 5)
            local num_equipintersep = num_buttons > 0 and 1 or 0
            local total_w = (num_slots + num_equip + num_buttons) * W + (num_slots + num_equip + num_buttons - num_slotintersep - num_equipintersep - 1) * SEP + (num_slotintersep + num_equipintersep) * INTERSEP
            local x = (W - total_w) * .5 + num_slots * W + (num_slots - num_slotintersep) * SEP + num_slotintersep * INTERSEP
            return total_w, x
        end
        --设置融合勋章栏位置
        local function setMedalInv(self, do_integrated_backpack)
            local total_w, x = getTotalW(self)
            local medal_inv_y = do_integrated_backpack and 80 or 40
            for k, v in ipairs(self.equipslotinfo) do
                if v.slot == EQUIPSLOTS.MEDAL then
                    self.medal_inv:SetPosition(x, medal_inv_y, 0)
                end
                x = x + W + SEP
            end
        end
        --加载勋章栏
        local function LoadMedalSlots()
            self.bg:SetScale(1.3 + (slot - 4) * 0.05, 1, 1.25)--根据格子数量缩放装备栏
            self.bgcover:SetScale(1.3 + (slot - 4) * 0.05, 1, 1.25)

            if self.addmedalslots == nil then
                self.addmedalslots = 1

                self:AddEquipSlot(GLOBAL.EQUIPSLOTS.MEDAL, "images/medal_equipslots.xml", "medal_equipslots.tex")

                if self.inspectcontrol then
                    local total_w, x = getTotalW(self)
                    self.inspectcontrol.icon:SetPosition(-4, 6)
                    self.inspectcontrol:SetPosition((total_w - W) * .5 + 3, -6, 0)
                end
            end
        end
        --刷新函数
        -- function Inv:Refresh()
        function self:Refresh()
            Inv_Refresh_base(self)
            LoadMedalSlots()
        end
        --构建函数
        -- function Inv:Rebuild()
        function self:Rebuild()
            Inv_Rebuild_base(self)
            LoadMedalSlots()
            local inventory = self.owner.replica.inventory
            local overflow = inventory:GetOverflowContainer()
            overflow = (overflow ~= nil and overflow:IsOpenedBy(self.owner)) and overflow or nil
            local do_integrated_backpack = overflow ~= nil and self.integrated_backpack
            setMedalInv(self, do_integrated_backpack)
        end
    end)
end
