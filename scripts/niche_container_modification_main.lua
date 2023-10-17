local Vector3 = GLOBAL.Vector3
local containers = GLOBAL.require("containers")
local params = containers.params
local deepcopy = GLOBAL.deepcopy

local package_container_modification = GetModConfigData("package_container_modification")
local package_open_modification = GetModConfigData("package_open_modification")
local shirenhua = GetModConfigData("shirenhua")

table.insert(Assets, Asset("ANIM", "anim/ui_chest_4x5.zip"))
table.insert(Assets, Asset("ANIM", "anim/ui_chest_5x8.zip"))
table.insert(Assets, Asset("ANIM", "anim/ui_chest_5x12.zip"))

local weizhi = GetModConfigData("rongliang_weizhi") ~= false and GetModConfigData("rongliang_weizhi") or 36
local function getrlfn(lx, bb)
    local widget = {}
    if bb then
        if lx == 14 then
            widget = { animbank = "ui_krampusbag_2x8", animbuild = "ui_krampusbag_2x8", pos = Vector3(-5, -120, 0), slotpos = {} }
            for y = 0, 6 do
                table.insert(widget.slotpos, Vector3(-162, -75 * y + 240, 0))
                table.insert(widget.slotpos, Vector3(-162 + 75, -75 * y + 240, 0))
            end
        elseif lx == 12 then
            widget = { animbank = "ui_piggyback_2x6", animbuild = "ui_piggyback_2x6", pos = Vector3(-5, -50, 0), slotpos = {} }
            for y = 0, 5 do
                table.insert(widget.slotpos, Vector3(-162, -75 * y + 170, 0))
                table.insert(widget.slotpos, Vector3(-162 + 75, -75 * y + 170, 0))
            end
        elseif lx == 20 then
            widget = { animbank = "", animbuild = "", pos = Vector3(0, -50, 0), slotpos = {} }
            for y = 0, 9 do
                table.insert(widget.slotpos, Vector3(-162, -75 * y + 260, 0))
                table.insert(widget.slotpos, Vector3(-162 + 75, -75 * y + 260, 0))
            end
        elseif lx == 30 then
            widget = { animbank = "", animbuild = "", pos = Vector3(0, -50, 0), slotpos = {} }
            for y = 0, 9 do
                table.insert(widget.slotpos, Vector3(-162 - 75, -75 * y + 260, 0))
                table.insert(widget.slotpos, Vector3(-162, -75 * y + 260, 0))
                table.insert(widget.slotpos, Vector3(-162 + 75, -75 * y + 260, 0))
            end
        elseif lx == 40 then
            widget = { animbank = "", animbuild = "", pos = Vector3(5, -50, 0), slotpos = {} }
            for y = 0, 9 do
                table.insert(widget.slotpos, Vector3(-162 - 150, -75 * y + 260, 0))
                table.insert(widget.slotpos, Vector3(-162 - 75, -75 * y + 260, 0))
                table.insert(widget.slotpos, Vector3(-162, -75 * y + 260, 0))
                table.insert(widget.slotpos, Vector3(-162 + 75, -75 * y + 260, 0))
            end
        elseif lx == 50 then
            widget = { animbank = "", animbuild = "", pos = Vector3(10, -50, 0), slotpos = {} }
            for y = 0, 9 do
                table.insert(widget.slotpos, Vector3(-162 - 225, -75 * y + 260, 0))
                table.insert(widget.slotpos, Vector3(-162 - 150, -75 * y + 260, 0))
                table.insert(widget.slotpos, Vector3(-162 - 75, -75 * y + 260, 0))
                table.insert(widget.slotpos, Vector3(-162, -75 * y + 260, 0))
                table.insert(widget.slotpos, Vector3(-162 + 75, -75 * y + 260, 0))
            end
        else
            widget = { slotpos = {}, animbank = "ui_backpack_2x4", animbuild = "ui_backpack_2x4", pos = Vector3(-5, -70, 0) }
            for y = 0, 3 do
                table.insert(widget.slotpos, Vector3(-162, -75 * y + 114, 0))
                table.insert(widget.slotpos, Vector3(-162 + 75, -75 * y + 114, 0))
            end
        end
    else
        if lx == 20 then
            widget = { animbank = "ui_chest_4x5", animbuild = "ui_chest_4x5", pos = Vector3(265, 150, 0), side_align_tip = 160, slotpos = {} }
            for y = 3, 0, -1 do
                for x = 0, 4 do
                    table.insert(widget.slotpos, Vector3(80 * x - 346 * 2 + 90, 80 * y - 80 * 2 + 90, 0))
                end
            end
        elseif lx == 40 then
            widget = { animbank = "ui_chest_5x8", animbuild = "ui_chest_5x8", pos = Vector3(180, 220, 0), side_align_tip = 160, slotpos = {} }
            for y = 4, 0, -1 do
                for x = 0, 7 do
                    table.insert(widget.slotpos, Vector3(80 * x - 346 * 2 + 109, 80 * y - 100 * 2 + 42, 0))
                end
            end
        elseif lx == 60 then
            widget = { animbank = "ui_chest_5x12", animbuild = "ui_chest_5x12", pos = Vector3(90, 230, 0), side_align_tip = 160, slotpos = {} }
            for y = 4, 0, -1 do
                for x = 0, 11 do
                    table.insert(widget.slotpos, Vector3(80 * x - 346 * 2 + 98, 80 * y - 100 * 2 + 42, 0))
                end
            end
        elseif lx == 90 then
            widget = { animbank = "", animbuild = "", pos = Vector3(weizhi, 250, 0), side_align_tip = 120, slotpos = {} }
            for y = 4, -1, -1 do
                for x = 0, 14 do
                    table.insert(widget.slotpos, Vector3(80 * x * 0.95 - 346 * 2 + 98, 80 * y * 0.95 - 100 * 2 + 42, 0))
                end
            end
        elseif lx == 105 then
            widget = { animbank = "", animbuild = "", pos = Vector3(weizhi, 280, 0), side_align_tip = 120, slotpos = {} }
            for y = 4, -2, -1 do
                for x = 0, 14 do
                    table.insert(widget.slotpos, Vector3(80 * x * 0.95 - 346 * 2 + 98, 80 * y * 0.95 - 100 * 2 + 42, 0))
                end
            end
        elseif lx == 120 then
            widget = { animbank = "", animbuild = "", pos = Vector3(weizhi, 310, 0), side_align_tip = 120, slotpos = {} }
            for y = 4, -3, -1 do
                for x = 0, 14 do
                    table.insert(widget.slotpos, Vector3(80 * x * 0.95 - 346 * 2 + 98, 80 * y * 0.95 - 100 * 2 + 42, 0))
                end
            end
        elseif lx == 12 then
            widget = { animbank = "ui_chester_shadow_3x4", animbuild = "ui_chester_shadow_3x4", pos = Vector3(0, 200, 0), side_align_tip = 160, slotpos = {} }
            for y = 2.5, -0.5, -1 do
                for x = 0, 2 do
                    table.insert(widget.slotpos, Vector3(75 * x - 75 * 2 + 75, 75 * y - 75 * 2 + 75, 0))
                end
            end
        elseif lx == 15 then
            widget = { animbank = "ui_tacklecontainer_3x5", animbuild = "ui_tacklecontainer_3x5", pos = Vector3(0, 280, 0), side_align_tip = 160, slotpos = {} }
            for y = 1, -3, -1 do
                for x = 0, 2 do
                    table.insert(widget.slotpos, Vector3(80 * x - 80 * 2 + 80, 80 * y - 45, 0))
                end
            end
        end
    end
    return widget
end
local function setrlfn(lx, bb)
    return bb and { widget = getrlfn(lx, true), issidewidget = true, type = "pack", openlimit = 1, } or { widget = getrlfn(lx), type = "chest" }
end

local function setwidget(lx, rl)
    local widget = {}
    local v1, v2, v3 = 0
    local p = Vector3(450, -50, 0)
    local sat = 100
    if lx == 6 then
        widget = { slotpos = {}, animbank = "ui_backpack_2x4", animbuild = "ui_backpack_2x4", pos = p, side_align_tip = sat, }
        for y = 0, 2 do
            table.insert(widget.slotpos, Vector3(-162, -75 * y + 100, 0))
            table.insert(widget.slotpos, Vector3(-162 + 75, -75 * y + 100, 0))
        end
        v1 = -125
        v2 = -120
    elseif lx == 10 then
        widget = { slotpos = {}, animbank = "ui_piggyback_2x6", animbuild = "ui_piggyback_2x6", pos = p, side_align_tip = sat, }
        for y = 0, 4 do
            table.insert(widget.slotpos, Vector3(-162, -75 * y + 155, 0))
            table.insert(widget.slotpos, Vector3(-162 + 75, -75 * y + 155, 0))
        end
        v1 = -125
        v2 = -215
    elseif lx == 12 then
        widget = { slotpos = {}, animbank = "ui_krampusbag_2x8", animbuild = "ui_krampusbag_2x8", pos = p, side_align_tip = sat, }
        for y = 0, 5 do
            table.insert(widget.slotpos, Vector3(-162, -75 * y + 230, 0))
            table.insert(widget.slotpos, Vector3(-162 + 75, -75 * y + 230, 0))
        end
        v1 = -125
        v2 = -220
    elseif lx == 14 then
        widget = { slotpos = {}, animbank = "ui_krampusbag_2x8", animbuild = "ui_krampusbag_2x8", pos = p, side_align_tip = sat, }
        for y = 0, 5.82, 0.97 do
            table.insert(widget.slotpos, Vector3(-162, -75 * y + 250, 0))
            table.insert(widget.slotpos, Vector3(-162 + 75, -75 * y + 250, 0))
        end
        v1 = -125
        v2 = -240
    elseif lx == 19 then
        widget = { slotpos = {}, animbank = "ui_chest_4x5", animbuild = "ui_chest_4x5", pos = p, side_align_tip = sat }
        for y = 3, 0, -1 do
            for x = 0, 4 do
                if not (y == 0 and x == 2) then
                    table.insert(widget.slotpos, Vector3(80 * x - 346 * 2 + 90 + (y == 0 and 7 * (x == 1 and -1 or x == 3 and 1 or 0) or 0), 80 * y - 80 * 2 + 90, 0))
                end
            end
        end
        v1 = -442
        v2 = -70
    end
    widget.buttoninfo = { text = GLOBAL.STRINGS.ACTIONS.WRAPBUNDLE, position = Vector3(v1, v2, v3) }
    widget.buttoninfo.fn = rl and rl.widget.buttoninfo and rl.widget.buttoninfo.fn or nil
    widget.buttoninfo.validfn = rl and rl.widget.buttoninfo and rl.widget.buttoninfo.validfn or nil
    return widget
end
local function setrlfn1(lx, rl)
    return { widget = setwidget(lx, rl), type = "cooker", itemtestfn = rl and rl.itemtestfn or nil }
end
if package_container_modification then
    params.bundle_container = setrlfn1(package_container_modification, params.bundle_container)
    containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, package_container_modification or 0)
end
if package_container_modification or package_open_modification == 2 then
    AddPrefabPostInit("bundle_container", function(inst)
        if package_open_modification == 2 then
            if not inst.components.preserver then
                inst:AddComponent("preserver")
            end
            inst.components.preserver:SetPerishRateMultiplier(0)
        end
        if package_container_modification and inst.replica and inst.replica.container then
            inst.replica.container.widget = setwidget(package_container_modification, params.bundle_container)
            inst.replica.container._numslots = package_container_modification
        end
    end)
end
local baoguo_ming = {}
if package_open_modification then
    table.insert(baoguo_ming, { ming = "bundle" })
end
if GetModConfigData("gift_package_container_modification") then
    table.insert(baoguo_ming, { ming = "gift" })
end
if #baoguo_ming > 0 then
    for _, v in pairs(baoguo_ming) do
        AddPrefabPostInit(v.ming, function(inst)
            inst.bundlingprefab = "bundle_container"
            inst.bundledprefab = v.ming
            local self = inst.components.unwrappable
            if self then
                function self:Unwrap(doer)
                    if doer and doer.components.bundler then
                        doer.sg:GoToState("bundle")
                        doer.components.bundler:StartBundling(inst, true, self.itemdata)
                    end
                end
            end
        end)
    end
    local function weizhifn(wanjia, pt)
        local wz = pt
        local offset = GLOBAL.FindWalkableOffset(pt, wanjia.Transform:GetRotation() * GLOBAL.DEGREES, 1, 8, false, true, function(pt)
            return not GLOBAL.TheWorld.Map:IsPointNearHole(pt)
        end)
        wz.x, wz.z = offset and (pt.x + offset.x) or pt.x, offset and (pt.z + offset.z) or pt.z
        return wz
    end
    AddPlayerPostInit(function(inst)
        local self = inst.components.bundler
        if self then
            local chuangjian = self.StartBundling
            function self:StartBundling(item, pd, mod)
                if pd then
                    if item and item.bundlingprefab and item.bundledprefab then
                        self:StopBundling(pd)
                        self.dakai_baoguo = item
                        self.baoguo = true
                        self.baoguo_prefab = item.prefab
                        self.bundlinginst = GLOBAL.SpawnPrefab(item.bundlingprefab)
                        if self.bundlinginst then
                            if self.bundlinginst.components.container then
                                self.bundlinginst.components.container:Open(inst)
                                if self.bundlinginst.components.container:IsOpenedBy(inst) then
                                    local rl = self.bundlinginst.components.container:GetNumSlots()
                                    if mod then
                                        for i, v in pairs(mod) do
                                            local wp = GLOBAL.SpawnPrefab(v.prefab, v.skinname, v.skin_id)
                                            if wp and wp:IsValid() then
                                                wp:SetPersistData(v.data)
                                                if i <= rl then
                                                    self.bundlinginst.components.container:GiveItem(wp, i)
                                                else
                                                    local pos = weizhifn(inst, inst:GetPosition())
                                                    if wp.Physics then
                                                        wp.Physics:Teleport(pos:Get())
                                                    else
                                                        wp.Transform:SetPosition(pos:Get())
                                                    end
                                                    if wp.components.inventoryitem then
                                                        wp.components.inventoryitem:OnDropped(true, .5)
                                                    end
                                                end
                                            end
                                        end
                                    end
                                    self.bundlinginst.entity:SetParent(inst.entity)
                                    self.bundlinginst.persists = false
                                    self.itemprefab = item.prefab
                                    self.itemskinname = item.skinname
                                    self.wrappedprefab = item.bundledprefab
                                    self.wrappedskinname = item.skinname
                                    self.wrappedskin_id = item.skin_id
                                    item:Remove()
                                    self.dakai_baoguo = nil
                                    inst.sg.statemem.bundling = true
                                    inst.sg:GoToState("bundling")
                                    return true
                                end
                            end
                            self.bundlinginst:Remove()
                            self.bundlinginst = nil
                        end
                    end
                else
                    return chuangjian ~= nil and chuangjian(self, item)
                end
            end
            local chuangjian1 = self.StopBundling
            function self:StopBundling(pd)
                if self.baoguo and self.bundlinginst then
                    self.baoguo = nil
                    if self.bundlinginst.components.container then
                        if not self.bundlinginst.components.container:IsEmpty() and self.wrappedprefab then
                            local wrapped = GLOBAL.SpawnPrefab(self.wrappedprefab, self.wrappedskinname, self.wrappedskin_id)
                            if wrapped then
                                if wrapped.components.unwrappable then
                                    local items = {}
                                    for i = 1, self.bundlinginst.components.container:GetNumSlots() do
                                        local item = self.bundlinginst.components.container:GetItemInSlot(i)
                                        if item then
                                            table.insert(items, item)
                                        end
                                    end
                                    wrapped.components.unwrappable:WrapItems(items, inst)
                                    if inst.components.inventory then
                                        inst.components.inventory:GiveItem(wrapped, nil, inst:GetPosition())
                                    end
                                end
                            else
                                wrapped:Remove()
                            end
                        else
                            if inst.components.inventory and self.baoguo_prefab == "bundle" then
                                inst.components.inventory:GiveItem(GLOBAL.SpawnPrefab("waxpaper"))
                                inst.components.inventory:GiveItem(GLOBAL.SpawnPrefab("rope"))
                            else
                                GLOBAL.SpawnPrefab("gift_unwrap").Transform:SetPosition(inst:GetPosition():Get())
                            end
                            if self.dakai_baoguo then
                                self.dakai_baoguo:Remove()
                                self.dakai_baoguo = nil
                            end
                        end
                    end
                    self.bundlinginst:Remove()
                    self.bundlinginst = nil
                    self.itemprefab = nil
                    self.wrappedprefab = nil
                    self.wrappedskinname = nil
                    self.wrappedskin_id = nil
                    self.baoguo_prefab = nil
                elseif not pd then
                    return chuangjian1 ~= nil and chuangjian1(self)
                end
            end
            local wancheng = self.OnFinishBundling
            function self:OnFinishBundling()
                if wancheng ~= nil then
                    wancheng(self)
                end
                if self.dakai_baoguo and not self.bundlinginst then
                    self.dakai_baoguo:Remove()
                    self.dakai_baoguo = nil
                end
                self.baoguo = nil
            end
        end
    end)
end
if shirenhua then
    local lureplant_rl = deepcopy(setrlfn(shirenhua))
    lureplant_rl.itemtestfn = function(container, item, slot)
        return not item:HasTag("irreplaceable")
    end
    params.lureplant = lureplant_rl
    AddPrefabPostInit("lureplant", function(inst)
        if inst.replica and inst.replica.container then
            inst.replica.container.widget = getrlfn(shirenhua)
            inst.replica.container._numslots = shirenhua
        end
    end)
end

if not (GLOBAL.TheNet:GetIsServer() or GLOBAL.TheNet:IsDedicated()) then
    return
end

if shirenhua then
    local function dakaifn(inst, data)
        local self = inst.components.inventory
        if not self then
            return
        end
        local n = 1
        for k = 1, self.maxslots do
            local item = self.itemslots[k]
            if item and item:IsValid() then
                local wuti = self:RemoveItem(item)
                if k > inst.components.container:GetNumSlots() then
                    n = nil
                else
                    n = k
                end
                inst.components.container:GiveItem(wuti, n)
            end
        end
    end
    local function guanbifn(inst, data)
        local self = inst.components.container
        if not inst.components.inventory then
            return
        end
        local n = 1
        for k = 1, self:GetNumSlots() do
            local item = self:GetItemInSlot(k)
            if item and item:IsValid() then
                local wuti = self:RemoveItem(item)
                if k > inst.components.inventory.maxslots then
                    n = nil
                else
                    n = k
                end
                inst.components.inventory:GiveItem(wuti, n)
            end
        end
    end
    local function quxiaofn(inst, doer)
        local self = inst.components.shelf
        if self and self.itemonshelf then
            self.ontakeitemfn(inst, doer)
        end
    end
    local function quzoufn(inst, data)
        local self = inst.components.inventory
        local self1 = inst.components.container
        if not data or not data.prev_item or not self then
            return
        end
        local dx = self.itemslots[data.slot]
        if dx and dx:IsValid() then
            dx:Remove()
            self.itemslots[data.slot] = nil
        end
        dx = self1.slots[data.slot]
        if dx and dx:IsValid() then
            dx:Remove()
            self1.slots[data.slot] = nil
        end
        if data.prev_item.prefab ~= "plantmeat" then
            return
        end
        local pd = true
        for k = 1, self.maxslots do
            local item = self.itemslots[k]
            if item and item.prefab == "plantmeat" then
                pd = false
            end
        end
        for k = 1, self1:GetNumSlots() do
            local item = self1:GetItemInSlot(k)
            if item and item.prefab == "plantmeat" then
                pd = false
            end
        end
        if pd then
            quxiaofn(inst, data.doer)
        end
    end
    AddPrefabPostInit("lureplant", function(inst)
        if not inst.components.container then
            inst:AddComponent("container")
        end
        local self1 = inst.components.container
        self1:WidgetSetup("lureplant")
        self1.onopenfn = dakaifn
        self1.onclosefn = guanbifn
        local self = inst.components.digester
        if self then
            local qingchu = self.TryDigest
            function self:TryDigest()
                if self1:IsOpen() then
                    self1:Close()
                end
                return qingchu ~= nil and qingchu(self)
            end
        end
        inst:ListenForEvent("itemlose", quzoufn)
    end)
end
