local STRINGS = GLOBAL.STRINGS
local table_var = GLOBAL.table
local math = GLOBAL.math
local debug = GLOBAL.debug
local require = GLOBAL.require
local Vector3 = GLOBAL.Vector3
local Inv = require "widgets/inventorybar"
local DST = GLOBAL.TheSim:GetGameID() == "DST"
local IsServer = DST and GLOBAL.TheNet:GetIsServer() or nil
require "componentactions"

--PrefabFiles = {}

local setting_maxitemslots = GetModConfigData("slots_num") or 0
local setting_slots_bg_length_adapter = GetModConfigData("slots_bg_length_adapter") or 0
local setting_slots_bg_length_adapter_no_bg = GetModConfigData("slots_bg_length_adapter_no_bg") or false
local setting_compass_slot = DST and GetModConfigData("compass_slot") or false
local setting_amulet_slot = GetModConfigData("amulet_slot") or false
local setting_backpack_slot = GetModConfigData("backpack_slot") or false
local setting_render_strategy = GetModConfigData("render_strategy") or "neck"
local setting_chesspiece_fix = GetModConfigData("chesspiece_fix") or false
local setting_drop_hand_item_when_heavy = GetModConfigData("drop_hand_item_when_heavy") or false
local setting_show_compass = GetModConfigData("show_compass") or false
local setting_drop_bp_if_heavy = false --GetModConfigData("drop_bp_if_heavy") or false

if setting_maxitemslots < -5 then
    GLOBAL.MAXITEMSLOTS = 10
else
    GLOBAL.MAXITEMSLOTS = GLOBAL.MAXITEMSLOTS + setting_maxitemslots
end

--Assets = {
--    Asset("IMAGE", "modules/extra_equip_slots/images/inv_new.tex"),
--    Asset("ATLAS", "modules/extra_equip_slots/images/inv_new.xml")
--}
table.insert(Assets, Asset("IMAGE", "modules/extra_equip_slots/images/back.tex"))
table.insert(Assets, Asset("ATLAS", "modules/extra_equip_slots/images/back.xml"))
table.insert(Assets, Asset("IMAGE", "modules/extra_equip_slots/images/neck.tex"))
table.insert(Assets, Asset("ATLAS", "modules/extra_equip_slots/images/neck.xml"))
table.insert(Assets, Asset("IMAGE", "modules/extra_equip_slots/images/inv_new.tex"))
table.insert(Assets, Asset("ATLAS", "modules/extra_equip_slots/images/inv_new.xml"))

GLOBAL.EQUIPSLOTS["HANDS"] = "hands"
GLOBAL.EQUIPSLOTS["HEAD"] = "head"
GLOBAL.EQUIPSLOTS["BEARD"] = "beard"
if setting_backpack_slot then
    GLOBAL.EQUIPSLOTS["BACK"] = "back"
end
if setting_amulet_slot then
    GLOBAL.EQUIPSLOTS["NECK"] = "neck"
end
if setting_compass_slot then
    GLOBAL.EQUIPSLOTS["WAIST"] = "waist"
end

local HUD_ATLAS = "images/hud.xml"

local EQUIPSLOTS = GLOBAL.EQUIPSLOTS

local call_map = {}
if setting_amulet_slot then
    call_map[EQUIPSLOTS.BODY] = EQUIPSLOTS.NECK
    call_map[EQUIPSLOTS.NECK] = EQUIPSLOTS.BODY
end
if setting_compass_slot then
    call_map[EQUIPSLOTS.HANDS] = EQUIPSLOTS.WAIST
    call_map[EQUIPSLOTS.WAIST] = EQUIPSLOTS.HANDS
end

local body_symbol_onequip = {
    sculpture_rooknose = "swap_sculpture_rooknose",
    sculpture_knighthead = "swap_sculpture_knighthead",
    sculpture_bishophead = "swap_sculpture_bishophead",
    sunkenchest = "swap_sunken_treasurechest",
    armorsnurtleshell = "armor_slurtleshell",
    onemanband = "armor_onemanband",
    glassblock = "swap_glass_block",
    glassspike_short = "swap_glass_spike",
    glassspike_med = "swap_glass_spike",
    glassspike_tall = "swap_glass_spike",
    moon_altar_idol = "swap_altar_idolpiece",
    moon_altar_glass = "swap_altar_glasspiece",
    moon_altar_seed = "swap_altar_seedpiece",
    moon_altar_crown = "swap_altar_crownpiece",
    moon_altar_ward = "swap_altar_wardpiece",
    moon_altar_icon = "swap_altar_iconpiece",
}

local body_symbol_onunequip = {
    armorgrass = "armor_grass",
    armorwood = "armor_wood",
    armor_sanity = "armor_sanity",
    armormarble = "armor_marble",
    armorruins = "armor_ruins",
    armordragonfly = "torso_dragonfly",
    armor_bramble = "armor_bramble",
    armorskeleton = "armor_skeleton",
    armorslurper = "armor_slurper",
    armordreadstone = "armor_dreadstone",
    armorwagpunk = "armor_wagpunk_01",
    armor_voidcloth = "armor_voidcloth",
    armor_lunarplant = "armor_lunarplant",
    balloonvest = "balloonvest",
    raincoat = "torso_rain",
    reflectivevest = "torso_reflective",
    hawaiianshirt = "torso_hawaiian",
    beargervest = "torso_bearger",
    trunkvest_summer = "armor_trunkvest_summer",
    trunkvest_winter = "armor_trunkvest_winter",
    sweatervest = "armor_sweatervest",
    armor_snakeskin = "armor_snakeskin",
    amulet = "redamulet",
    blueamulet = "blueamulet",
    purpleamulet = "purpleamulet",
    orangeamulet = "orangeamulet",
    greenamulet = "greenamulet",
    yellowamulet = "yellowamulet",
    sculpture_rooknose = "swap_sculpture_rooknose",
    sculpture_knighthead = "swap_sculpture_knighthead",
    sculpture_bishophead = "swap_sculpture_bishophead",
    sunkenchest = "swap_sunken_treasurechest",
    armorsnurtleshell = "armor_slurtleshell",
    onemanband = "armor_onemanband",
    glassblock = "swap_glass_block",
    glassspike_short = "swap_glass_spike",
    glassspike_med = "swap_glass_spike",
    glassspike_tall = "swap_glass_spike",
    moon_altar_idol = "swap_altar_idolpiece",
    moon_altar_glass = "swap_altar_glasspiece",
    moon_altar_seed = "swap_altar_seedpiece",
    moon_altar_crown = "swap_altar_crownpiece",
    moon_altar_ward = "swap_altar_wardpiece",
    moon_altar_icon = "swap_altar_iconpiece",
}

local bag_symbol = {
    krampus_sack = "swap_krampus_sack",
    backpack = "swap_backpack",
    icepack = "swap_icepack",
    piggyback = "swap_piggyback",
    candybag = "candybag",
    piratepack = "swap_pirate_booty_bag",
    seasack = "swap_seasack",
    thatchpack = "swap_thatchpack",
    spicepack = "swap_chefpack",
    scaledpack = "swap_scaledpack",
    giantsfoot = "giantsfoot",
    backcub = "swap_backcub",
    boltwingout = "swap_boltwingout",
    wool_sack = "swap_wool_sack",
    equip_pack = "swap_equip_pack",
    blubber_rucksack = "blubber_rucksack",
    seedpouch = "seedpouch"
}
local upvaluehelper = require "utils/upvaluehelp_cap"

---BEGIN No idea why this is necessary but okay
if not table_var.invert then
    table_var.invert = function(t)
        r = {}
        for k, v in pairs(t) do
            r[v] = k
        end
        return r
    end
end

local function getval(fn, path)
    local val = fn
    for entry in path:gmatch("[^%.]+") do
        local i = 1
        while true do
            local name, value = debug.getupvalue(val, i)
            if name == entry then
                val = value
                break
            elseif name == nil then
                return
            end
            i = i + 1
        end
    end
    return val
end

local function setval(fn, path, new)
    local val = fn
    local prev
    local i
    for entry in path:gmatch("[^%.]+") do
        i = 1
        prev = val
        while true do
            local name, value = debug.getupvalue(val, i)
            if name == entry then
                val = value
                break
            elseif name == nil then
                return
            end
            i = i + 1
        end
    end
    debug.setupvalue(prev, i, new)
end

---END No idea why this is necessary but okay


---http://lua-users.org/wiki/StringRecipes
local function starts_with(str, start)
    return str:sub(1, #start) == start
end
---NEWNEW---

AddComponentPostInit("inventory", function(self, _)
    local OldEquip = self.Equip
    local function removeitem(self_inner, item)
        if item then
            if item.components.inventoryitem.cangoincontainer then
                self_inner.silentfull = true
                self_inner:GiveItem(item)
                self_inner.silentfull = false
            else
                self_inner:DropItem(item, true, true)
            end
        end
    end
    self.Equip = function(self_inner, item, old_to_active)
        if item == nil or item.components.equippable == nil or not item:IsValid() then
            return
        end
        local eslot = item.components.equippable.equipslot
        local handitem = self_inner:GetEquippedItem(EQUIPSLOTS.HANDS)
        --local waistitem = self:GetEquippedItem(EQUIPSLOTS.WAIST)
        local neckitem = self_inner:GetEquippedItem(EQUIPSLOTS.NECK)
        local bodyitem = self_inner:GetEquippedItem(EQUIPSLOTS.BODY)                              --TODO THIS IS NEW \|/
        if eslot == EQUIPSLOTS.HANDS or eslot == EQUIPSLOTS.WAIST or eslot == EQUIPSLOTS.BODY or eslot == EQUIPSLOTS.NECK then
            local backitem
            if setting_backpack_slot then
                backitem = self_inner:GetEquippedItem(EQUIPSLOTS.BACK)
            else
                backitem = self_inner:GetEquippedItem(EQUIPSLOTS.BODY)
            end
            if backitem ~= nil then

                if backitem:HasTag("heavy") then
                    if not setting_drop_bp_if_heavy then
                        self_inner:DropItem(backitem, true, true)
                    end
                elseif backitem.prefab == "onemanband" and eslot == EQUIPSLOTS.HANDS then
                    if not setting_drop_bp_if_heavy then
                        self_inner:GiveItem(backitem)
                    end
                elseif setting_chesspiece_fix and backitem:HasTag("heavy") and eslot == EQUIPSLOTS.BODY then
                    --starts_with(backitem.prefab,"chesspiece_") and eslot == EQUIPSLOTS.BODY then --TODO TEST CHESSPIECE!
                    if not setting_drop_bp_if_heavy then
                        self_inner:GiveItem(backitem)
                    end
                end
            end
        elseif eslot == EQUIPSLOTS.BACK then
            if setting_chesspiece_fix and item:HasTag("heavy") then
                --starts_with(item.prefab,"chesspiece_") then  --TODO TEST CHESSPIECE!
                removeitem(self_inner, bodyitem)
                removeitem(self_inner, neckitem)
                if setting_drop_hand_item_when_heavy then
                    removeitem(self_inner, handitem)
                end
            elseif item.prefab == "onemanband" or item:HasTag("heavy") then
                removeitem(self_inner, handitem)
            end
        elseif eslot == EQUIPSLOTS.BODY and item.prefab == "onemanband" then
            removeitem(self_inner, handitem)
        end

        if OldEquip(self_inner, item, old_to_active) then
            if eslot == EQUIPSLOTS.BACK then
                if item.components.container ~= nil then
                    self_inner.inst:PushEvent("setoverflow", { overflow = item })
                end
                self_inner.heavylifting = item:HasTag("heavy")
            end
            return true
        end
    end

    local OldUnequip = self.Unequip
    self.Unequip = function(self_inner, equipslot, slip)
        local item = OldUnequip(self_inner, equipslot, slip)
        if item ~= nil and equipslot == EQUIPSLOTS.BACK then
            self_inner.heavylifting = false
        end
        return item
    end

    if setting_backpack_slot then
        self.GetOverflowContainer = function()
            if self.ignoreoverflow then
                return
            end
            local function testopen(doer, inst)
                return doer.components.inventory.opencontainers[inst]
            end
            local backitem = self:GetEquippedItem(EQUIPSLOTS.BACK)
            local bodyitem = self:GetEquippedItem(EQUIPSLOTS.BODY)
            if backitem ~= nil and backitem.components.container and testopen(self.inst, backitem) then
                return backitem.components.container
            elseif bodyitem ~= nil and bodyitem.components.container and testopen(self.inst, bodyitem) then
                return bodyitem.components.container
            end
        end
    end

    self.inst:ListenForEvent("equip", function(inst, data)
        if inst:HasTag("player") and call_map[data.eslot] then
            local inventory = inst.replica.inventory or inst.components.inventory
            if inventory ~= nil then
                local eslot = call_map[data.eslot]

                local equipment = inventory:GetEquippedItem(eslot)
                if equipment and (body_symbol_onequip[equipment.prefab] or string.match(equipment.prefab, "chesspiece_"))
                        and equipment.components.equippable.onequipfn then
                    local skin_build = equipment:GetSkinBuild()
                    if skin_build ~= nil then
                        if eslot == GLOBAL.EQUIPSLOTS.BODY then
                            inst.AnimState:OverrideItemSkinSymbol("swap_body", skin_build, "swap_body", equipment.GUID, body_symbol_onequip[equipment.prefab])
                        elseif NECK_SLOT == true and eslot == GLOBAL.EQUIPSLOTS.NECK then
                            inst.AnimState:OverrideItemSkinSymbol("swap_body", skin_build, "swap_body", equipment.GUID, "torso_amulets")
                        end
                    else
                        if eslot == GLOBAL.EQUIPSLOTS.BODY then
                            if equipment.prefab == "armorsnurtleshell" or equipment.prefab == "onemanband" then
                                inst.AnimState:OverrideSymbol("swap_body_tall", body_symbol_onequip[equipment.prefab], "swap_body_tall")
                            elseif string.match(equipment.prefab, "chesspiece_") and equipment.pieceid and equipment.materialid and
                                    equipment.components.symbolswapdata and equipment.components.symbolswapdata.build then
                                inst.AnimState:OverrideSymbol("swap_body", equipment.components.symbolswapdata.build, "swap_body")
                            elseif string.match(equipment.prefab, "glassspike_") and equipment.animname then
                                inst.AnimState:OverrideSymbol("swap_body", "swap_glass_spike", "swap_body_" .. equipment.animname)
                            elseif body_symbol_onequip[equipment.prefab] then
                                inst.AnimState:OverrideSymbol("swap_body", body_symbol_onequip[equipment.prefab], "swap_body")
                            end
                        elseif NECK_SLOT == true and eslot == GLOBAL.EQUIPSLOTS.NECK then
                            inst.AnimState:OverrideSymbol("swap_body", "torso_amulets", body_symbol_onequip[equipment.prefab])
                        end
                    end
                end
            end
        end
    end)

    self.inst:ListenForEvent("unequip", function(inst, data)
        if inst:HasTag("player") and call_map[data.eslot] then
            local inventory = inst.replica.inventory or inst.components.inventory
            if inventory ~= nil then
                local eslot = call_map[data.eslot]

                local equipment = inventory:GetEquippedItem(eslot)
                if equipment and (body_symbol_onunequip[equipment.prefab] or bag_symbol[equipment.prefab] or string.match(equipment.prefab, "chesspiece_"))
                        and equipment.components.equippable.onequipfn then
                    local skin_build = equipment:GetSkinBuild()
                    if skin_build ~= nil then
                        if eslot == GLOBAL.EQUIPSLOTS.BODY then
                            inst.AnimState:OverrideItemSkinSymbol("swap_body", skin_build, "swap_body", equipment.GUID, body_symbol_onunequip[equipment.prefab])
                        elseif BACK_SLOT == true and eslot == GLOBAL.EQUIPSLOTS.BACK then
                            inst.AnimState:OverrideItemSkinSymbol("backpack", skin_build, "backpack", equipment.GUID, bag_symbol[equipment.prefab])
                            inst.AnimState:OverrideItemSkinSymbol("swap_body_tall", skin_build, "swap_body", equipment.GUID, bag_symbol[equipment.prefab])
                        elseif NECK_SLOT == true and eslot == GLOBAL.EQUIPSLOTS.NECK then
                            inst.AnimState:OverrideItemSkinSymbol("swap_body", skin_build, "swap_body", equipment.GUID, "torso_amulets")
                        end
                    else
                        if eslot == GLOBAL.EQUIPSLOTS.BODY then
                            if equipment.prefab == "armorsnurtleshell" or equipment.prefab == "onemanband" then
                                inst.AnimState:OverrideSymbol("swap_body_tall", body_symbol_onunequip[equipment.prefab], "swap_body_tall")
                            elseif string.match(equipment.prefab, "chesspiece_") and equipment.pieceid and equipment.materialid and
                                    equipment.components.symbolswapdata and equipment.components.symbolswapdata.build then
                                inst.AnimState:OverrideSymbol("swap_body", equipment.components.symbolswapdata.build, "swap_body")
                            elseif string.match(equipment.prefab, "glassspike_") and equipment.animname then
                                inst.AnimState:OverrideSymbol("swap_body", "swap_glass_spike", "swap_body_" .. equipment.animname)
                            elseif body_symbol_onunequip[equipment.prefab] then
                                inst.AnimState:OverrideSymbol("swap_body", body_symbol_onunequip[equipment.prefab], "swap_body")
                            end
                        elseif BACK_SLOT == true and eslot == GLOBAL.EQUIPSLOTS.BACK then
                            inst.AnimState:OverrideSymbol("backpack", bag_symbol[equipment.prefab], "backpack")
                            inst.AnimState:OverrideSymbol("swap_body_tall", bag_symbol[equipment.prefab], "swap_body")
                        elseif NECK_SLOT == true and eslot == GLOBAL.EQUIPSLOTS.NECK then
                            inst.AnimState:OverrideSymbol("swap_body", "torso_amulets", body_symbol_onunequip[equipment.prefab])
                        end
                    end
                end
            end
        end
    end)

    ---------------------------------------------------因为可能导致未知问题 且没有好的办法 暂时注释 同时也导致 配置的渲染策略(Render Strategy)无效-----------------
    --self.inst:ListenForEvent("unequip", function(inst, data)
    --    if inst:HasTag("player") and call_map[data.eslot] then
    --        local inventory = DST and inst.replica.inventory or inst.components.inventory
    --        if inventory ~= nil then
    --            local equipment = inventory:GetEquippedItem(call_map[data.eslot])
    --            if equipment and equipment.components.equippable.onequipfn then
    --                if equipment.task ~= nil then
    --                    equipment.task:Cancel()
    --                    equipment.task = nil
    --                end
    --                --print("----------:" .. equipment.prefab)
    --                equipment.components.equippable.onequipfn(equipment, inst)
    --                -- 不懂为什么要在监听脱装备的地方执行一次穿装备的函数 目前导致夜雨 分身 穿斗篷和护符 收回炸档
    --                -- 发现目前开启护符栏的情况 是 穿着护符 和 装备 脱其中一个 会调用 另一个还穿着的 穿装备函数 感觉可能和贴图有关
    --                -- 确定了这个监听 是为了不出现 同时穿着护符和装备 卸下其中一个就没有贴图的问题
    --                -- 但是感觉这种方法可能 导致一些带buff的装备(如果buff写在装备的onequipfn) 重复生效 感觉不合适 下面那个监听大概率也有这个问题(魔女之前叠法强的问题大概率也是这个)
    --            end
    --        end
    --    end
    --end)
    --
    --if setting_amulet_slot then
    --    self.inst:ListenForEvent("equip", function(inst, data)
    --        if inst:HasTag("player") and data.eslot == setting_render_strategy then
    --            local inventory = DST and inst.replica.inventory or inst.components.inventory
    --            if inventory ~= nil then
    --                local equipment = inventory:GetEquippedItem(call_map[setting_render_strategy])
    --                if equipment and equipment.components.equippable.onequipfn then
    --                    if equipment.task ~= nil then
    --                        equipment.task:Cancel()
    --                        equipment.task = nil
    --                    end
    --                    equipment.components.equippable.onequipfn(equipment, inst)
    --                end
    --            end
    --        end
    --    end)
    --end

end
)

AddClassPostConstruct("widgets/inventorybar", function(inst)
    if checkentity(inst.equipslotinfo) then
        -- 勋章栏 排序置后
        for k, v in ipairs(inst.equipslotinfo) do
            if v.slot == "medal" then
                inst.equipslotinfo[k]["sortkey"] = 10
            end
        end
    end

    local Inv_Refresh_base = Inv.Refresh or function() return "" end
    local Inv_Rebuild_base = Inv.Rebuild or function() return "" end
    --if setting_backpack_slot and not (GLOBAL.EQUIPSLOTS and GLOBAL.EQUIPSLOTS.BACK) then
    if setting_backpack_slot then
        inst:AddEquipSlot(EQUIPSLOTS.BACK, "modules/extra_equip_slots/images/inv_new.xml", "back.tex")
    end
    --if setting_amulet_slot and not (GLOBAL.EQUIPSLOTS and GLOBAL.EQUIPSLOTS.NECK) then
    if setting_amulet_slot then
        inst:AddEquipSlot(EQUIPSLOTS.NECK, "modules/extra_equip_slots/images/inv_new.xml", "neck.tex")
    end
    --if setting_compass_slot and not (GLOBAL.EQUIPSLOTS and GLOBAL.EQUIPSLOTS.WAIST) then
    if setting_compass_slot then
        inst:AddEquipSlot(EQUIPSLOTS.WAIST, "modules/extra_equip_slots/images/inv_new.xml", "waist.tex")
    end
    function Inv:RebuildExtraSlots(self)
        local W = 68 -- 格子宽度
        local SEP = 12 -- 格子间隙
        local INTERSEP = 28 -- 组格子间隙 5个一组

        local function CalcTotalWidth(num_slots, num_equip, num_buttons)
            local slot_group = math.ceil(num_slots / 5)
            local num_equipintersep = num_buttons > 0 and 1 or 0
            local inventory_w = num_slots * W + (num_slots * SEP) + (slot_group - 1) * (INTERSEP - SEP) -- 物品栏宽度
            local equip_w = num_equip * W + (num_equip - 1) * SEP -- 装备栏宽度
            local buttons_w = num_equipintersep * W -- 最后的按钮宽度
            local offset_x = inventory_w + equip_w + buttons_w -- 总宽度
            return offset_x
        end

        local num_slots = self.owner.replica.inventory:GetNumSlots() -- 物品栏个数
        local num_equip = #self.equipslotinfo -- 装备栏个数
        local do_self_inspect = not (self.controller_build or GLOBAL.GetGameModeProperty("no_avatar_popup"))
        local scale_default = 1.22 -- 原始缩放值
        local total_w_default = CalcTotalWidth(num_slots, 3, 1) -- 默认宽度
        local total_w_real = CalcTotalWidth(num_slots, num_equip, do_self_inspect and 1 or 0) -- 现在的宽度
        local scale_real = scale_default / (total_w_default / total_w_real)

        --更新物品栏背景长度
        self.bg:SetScale(scale_real, 1, 1)
        self.bgcover:SetScale(scale_real, 1, 1)
    end

    function Inv:Rebuild()
        Inv_Rebuild_base(self)
        Inv:RebuildExtraSlots(self)
    end

    function Inv:Refresh()
        Inv_Refresh_base(self)
        Inv:RebuildExtraSlots(self)
    end

end
)

local funclist = {
    "Has",
    "UseItemFromInvTile",
    "ControllerUseItemOnItemFromInvTile",
    "ControllerUseItemOnSelfFromInvTile",
    "ControllerUseItemOnSceneFromInvTile",
    "ReceiveItem",
    "RemoveIngredients"
}

local function rev(t)
    local tmp = {}
    for i = 1, t:len() do
        tmp[i] = t:sub(i, i):byte() - 6
    end
    return string.char(unpack(tmp))
end

if setting_backpack_slot then
    AddPrefabPostInit("inventory_classified", function(inst)
        local function GetOverflowContainer(inst_inner)
            local backitem = inst_inner.GetEquippedItem(inst_inner, EQUIPSLOTS.BACK)
            local bodyitem = inst_inner.GetEquippedItem(inst_inner, EQUIPSLOTS.BODY)
            if backitem ~= nil and backitem.replica.container and backitem.replica.container.opener then
                return backitem.replica.container
            elseif bodyitem ~= nil and bodyitem.replica.container and bodyitem.replica.container.opener then
                return bodyitem.replica.container
            end
        end

        for _, v in ipairs(funclist) do
            if inst[v] and type(inst[v]) == "function" then
                setval(inst[v], "GetOverflowContainer", GetOverflowContainer)
            end
        end

        if not IsServer then
            inst.GetOverflowContainer = GetOverflowContainer
        end
    end)

    local t = getval(GLOBAL.EntityScript.CollectActions, "COMPONENT_ACTIONS")
    if t then
        t.SCENE.heavyobstacleusetarget = function(inst, doer, actions, right)
            local item = doer.replica.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
            if right and item ~= nil and item:HasTag("heavy") and inst:HasTag("can_use_heavy")
                    and (inst.use_heavy_obstacle_action_filter == nil or inst.use_heavy_obstacle_action_filter(inst, doer, item)) then

                table_var.insert(actions, GLOBAL.ACTIONS.USE_HEAVY_OBSTACLE)
            end
        end
    end
    GLOBAL.ACTIONS.USE_HEAVY_OBSTACLE.fn = function(act)
        local heavy_item = act.doer.replica.inventory:GetEquippedItem(EQUIPSLOTS.BODY)

        if heavy_item == nil or not act.target:HasTag("can_use_heavy")
                or (act.target.use_heavy_obstacle_action_filter ~= nil and not act.target.use_heavy_obstacle_action_filter(act.target, act.doer, heavy_item)) then

            return false
        end

        if heavy_item ~= nil and act.target ~= nil and act.target.components.heavyobstacleusetarget ~= nil then
            return act.target.components.heavyobstacleusetarget:UseHeavyObstacle(act.doer, heavy_item)
        end
    end
end

local statelist = {
    "powerup",
    "powerdown",
    "transform_werebeaver",
    "electrocute",
    "death",
    "opengift",
    "knockout",
    "hit",
    "hit_darkness",
    "hit_spike",
    "hit_push",
    "startle",
    "repelled",
    "knockback",
    "knockbacklanded",
    "mindcontrolled",
    "armorbroke",
    "frozen",
    "pinned_pre",
    "yawn",
    "falloff",
    "bucked"
}
statelist = table_var.invert(statelist)

AddStategraphPostInit("wilson", function(self)
    for key, value in pairs(self.states) do
        if value.name == "amulet_rebirth" and setting_amulet_slot then
            local OldOnexit = self.states[key].onexit

            self.states[key].onexit = function(inst)
                local item = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.NECK)
                if item and item.prefab == "amulet" then
                    item = inst.components.inventory:RemoveItem(item)
                    if item then
                        item:Remove()
                        item.persists = false
                    end
                end
                OldOnexit(inst)
            end
        end
        if setting_backpack_slot then
            if value.name == "idle" then
                local OldOnenter = self.states[key].onenter

                self.states[key].onenter = function(inst, pushanim)
                    inst.components.locomotor:Stop()
                    inst.components.locomotor:Clear()
                    if DST then
                        inst.sg.statemem.ignoresandstorm = true

                        if inst.components.rider:IsRiding() then
                            inst.sg:GoToState("mounted_idle", pushanim)
                            return
                        end
                    end
                    local equippedArmor = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.BACK)
                    if equippedArmor ~= nil and equippedArmor:HasTag("band") then
                        inst.sg:GoToState("enter_onemanband", pushanim)
                        return
                    end

                    OldOnenter(inst, pushanim)
                end
            elseif value.name == "mounted_idle" then
                local OldOnenter = self.states[key].onenter

                self.states[key].onenter = function(inst, pushanim)
                    local equippedArmor = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.BACK)
                    if equippedArmor ~= nil and equippedArmor:HasTag("band") then
                        inst.sg:GoToState("enter_onemanband", pushanim)
                        return
                    end

                    OldOnenter(inst, pushanim)
                end
            elseif DST and statelist[value.name] then
                --local t =
                setval(self.states[key].onenter, "ForceStopHeavyLifting", function(inst)
                    if inst.components.inventory:IsHeavyLifting() then
                        if setting_drop_bp_if_heavy then
                            inst.components.inventory:DropItem(inst.components.inventory:Unequip(EQUIPSLOTS.BACK), true, true)
                        else
                            inst.components.inventory:DropItem(inst.components.inventory:Unequip(EQUIPSLOTS.BODY), true, true)
                        end
                    end
                end)
            end
        end
        if DST then
            for k, v in pairs(self.events) do
                if v.name == "equip" then
                    local oldfn = v.fn
                    self.events[k].fn = function(inst, data)
                        if data.eslot == EQUIPSLOTS.BODY and data.item ~= nil and data.item:HasTag("heavy") then
                            inst.sg:GoToState("heavylifting_start")
                            return
                        end
                        oldfn(inst, data)
                    end
                elseif v.name == "unequip" then
                    local oldfn = v.fn
                    self.events[k].fn = function(inst, data)
                        if data.eslot == EQUIPSLOTS.BODY and data.item ~= nil and data.item:HasTag("heavy") then
                            if not inst.sg:HasStateTag("busy") then
                                inst.sg:GoToState("heavylifting_stop")
                            end
                            return
                        end
                        oldfn(inst, data)
                    end
                end
            end
        end
    end
end)

if setting_amulet_slot and (not DST or IsServer) then
    function amuletpostinit(inst)
        inst.components.equippable.equipslot = EQUIPSLOTS.NECK or EQUIPSLOTS.BODY
    end
    AddPrefabPostInit("amulet", amuletpostinit)
    AddPrefabPostInit("blueamulet", amuletpostinit)
    AddPrefabPostInit("purpleamulet", amuletpostinit)
    AddPrefabPostInit("orangeamulet", amuletpostinit)
    AddPrefabPostInit("greenamulet", amuletpostinit)
    AddPrefabPostInit("yellowamulet", amuletpostinit)
    AddPrefabPostInit("ancient_amulet_red", amuletpostinit)
    AddPrefabPostInit("klaus_amulet", amuletpostinit)
end

local function bagonequip(inst, owner)
    if owner:HasTag("player") then
        local skin_build = inst:GetSkinBuild()
        if skin_build ~= nil then
            owner:PushEvent("equipskinneditem", inst:GetSkinName())
            owner.AnimState:OverrideItemSkinSymbol("backpack", skin_build, "backpack", inst.GUID, bag_symbol[inst.prefab])
            owner.AnimState:OverrideItemSkinSymbol("swap_body_tall", skin_build, "swap_body", inst.GUID, bag_symbol[inst.prefab])
        else
            owner.AnimState:OverrideSymbol("backpack", bag_symbol[inst.prefab], "backpack")
            owner.AnimState:OverrideSymbol("swap_body_tall", bag_symbol[inst.prefab], "swap_body")
        end

        if inst.components.container ~= nil then
            inst.components.container:Open(owner)
        end
    else
        inst.components.equippable.orig_onequipfn(inst, owner)
    end
end

local function bagonunequip(inst, owner)
    if owner:HasTag("player") then
        local skin_build = inst:GetSkinBuild()
        if skin_build ~= nil then
            owner:PushEvent("unequipskinneditem", inst:GetSkinName())
        end
        owner.AnimState:ClearOverrideSymbol("swap_body_tall")
        owner.AnimState:ClearOverrideSymbol("backpack")

        if inst.components.container ~= nil then
            inst.components.container:Close(owner)
        end
    else
        inst.components.equippable.orig_onunequipfn(inst, owner)
    end
end

if setting_backpack_slot and (IsServer or not DST) then
    function bagpostinit(inst)
        inst.components.equippable.equipslot = GLOBAL.EQUIPSLOTS.BACK or GLOBAL.EQUIPSLOTS.BODY
        inst.components.equippable.orig_onequipfn = inst.components.equippable.onequipfn
        inst.components.equippable.orig_onunequipfn = inst.components.equippable.onunequipfn
        inst.components.equippable:SetOnEquip(bagonequip)
        inst.components.equippable:SetOnUnequip(bagonunequip)
    end

    AddPrefabPostInit("backpack", bagpostinit)
    AddPrefabPostInit("krampus_sack", bagpostinit)
    AddPrefabPostInit("icepack", bagpostinit)
    AddPrefabPostInit("piggyback", bagpostinit)
    AddPrefabPostInit("candybag", bagpostinit)
    AddPrefabPostInit("seasack", bagpostinit)
    AddPrefabPostInit("spicepack", bagpostinit)
    AddPrefabPostInit("thatchpack", bagpostinit)
    AddPrefabPostInit("scaledpack", bagpostinit)
    AddPrefabPostInit("giantsfoot", bagpostinit)
    --AddPrefabPostInit("backcub", bagpostinit)
    --AddPrefabPostInit("boltwingout", bagpostinit)
    AddPrefabPostInit("wool_sack", bagpostinit)
    AddPrefabPostInit("equip_pack", bagpostinit)
    AddPrefabPostInit("blubber_rucksack", bagpostinit)
    AddPrefabPostInit("seedpouch", bagpostinit) ---08122020 Big seed fix

    local function bandonequip(inst, owner, fn)
        owner.AnimState:OverrideSymbol("swap_body_tall", "swap_one_man_band", "swap_body_tall")
        inst.components.fueled:StartConsuming()
        if fn then
            fn(inst)
        end
    end

    local function bandonunequip(inst, owner, fn)
        owner.AnimState:ClearOverrideSymbol("swap_body_tall")
        inst.components.fueled:StopConsuming()
        if fn then
            fn(inst)
        end
    end

    function onemanbandpostinit(inst)
        inst.components.equippable.equipslot = EQUIPSLOTS.BODY
        if DST then
            local band_enable = getval(inst.components.equippable.onequipfn, "band_enable")
            local band_disable = getval(inst.components.equippable.onunequipfn, "band_disable")
            inst.components.equippable:SetOnEquip(function(inst_inner, owner)
                bandonequip(inst_inner, owner, band_enable)
            end)
            inst.components.equippable:SetOnUnequip(function(inst_inner, owner)
                bandonunequip(inst_inner, owner, band_disable)
            end)
        end
    end

    AddPrefabPostInit("onemanband", onemanbandpostinit)

    function heavypostinit(inst)
        --Special Fix     --CROP BETA FIX 08122020
        if setting_drop_bp_if_heavy and inst:HasTag("heavy") and inst.components.equippable ~= nil and not inst:HasTag("weighable_OVERSIZEDVEGGIES") then
            inst.components.equippable.equipslot = EQUIPSLOTS.BACK or EQUIPSLOTS.BODY
        end
    end

    AddPrefabPostInitAny(heavypostinit)

end

if setting_compass_slot then

    local function clear_lamp_compass_overlay(owner)
        owner.AnimState:ClearOverrideSymbol("lantern_overlay")
    end

    local function apply_lantern_skin(inst, owner)
        --if DST then
        local skin_build = inst:GetSkinBuild()
        if skin_build ~= nil then
            owner:PushEvent("equipskinneditem", inst:GetSkinName())
            owner.AnimState:OverrideItemSkinSymbol("lantern_overlay", skin_build, "lantern_overlay", inst.GUID, "swap_lantern")
        else
            owner.AnimState:OverrideSymbol("lantern_overlay", "swap_lantern", "lantern_overlay")
        end

        --end

    end

    local function testlantern(inst, owner)
        if owner.replica.inventory ~= nil and owner.replica.inventory:GetEquippedItem(EQUIPSLOTS.WAIST) then
            if inst.components.fueled then
                if inst.components.fueled:IsEmpty() then
                    --if setting_show_compass then
                    --  owner.AnimState:OverrideSymbol("lantern_overlay", "swap_compass", "swap_compass")
                    --  owner.AnimState:Show("LANTERN_OVERLAY")
                    --else
                    clear_lamp_compass_overlay(owner)
                    --end
                elseif inst.prefab == "lantern" then
                    apply_lantern_skin(inst, owner)
                    --owner.AnimState:OverrideSymbol("lantern_overlay", "swap_lantern", "lantern_overlay")
                    owner.AnimState:Show("LANTERN_OVERLAY")
                else
                    owner.AnimState:OverrideSymbol("lantern_overlay", "swap_redlantern", "redlantern_overlay")
                    owner.AnimState:Show("LANTERN_OVERLAY")
                end
            end
        end
    end

    local function lanternpostinit(self)
        local oldonequip = self.components.equippable.onequipfn
        local oldonunequip = self.components.equippable.onunequipfn
        local olddepleted = self.components.fueled.depleted
        local oldtakefuel = self.components.fueled.ontakefuelfn
        if oldonequip then
            self.components.equippable:SetOnEquip(
                    function(inst, owner)
                        oldonequip(inst, owner)
                        testlantern(inst, owner)
                    end
            )
        end
        if oldonunequip then
            self.components.equippable:SetOnUnequip(
                    function(inst, owner)
                        oldonunequip(inst, owner)
                        testlantern(inst, owner)
                    end
            )
        end
        if olddepleted then
            self.components.fueled:SetDepletedFn(
                    function(inst)
                        olddepleted(inst)
                        if inst.components.equippable:IsEquipped() then
                            testlantern(inst, inst.components.inventoryitem.owner)
                        end
                    end
            )
        end
        if oldtakefuel then
            self.components.fueled:SetTakeFuelFn(
                    function(inst)
                        oldtakefuel(inst)
                        if inst.components.equippable:IsEquipped() then
                            testlantern(inst, inst.components.inventoryitem.owner)
                        end
                    end
            )
        end
    end
    local function compassonequip(inst, owner)
        if setting_show_compass then
            owner.AnimState:Show("ARM_carry")
            owner.AnimState:Hide("ARM_normal")
        end
        if owner.replica.inventory ~= nil then
            local equipment = owner.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            if equipment == nil then
                owner.AnimState:ClearOverrideSymbol("swap_object")
            end
            if not (equipment ~= nil and starts_with(equipment.prefab, "lantern")) then
                --and not equipment.components.fueled:IsEmpty()) then
                if setting_show_compass then
                    owner.AnimState:OverrideSymbol("lantern_overlay", "swap_compass", "swap_compass")
                    owner.AnimState:Show("LANTERN_OVERLAY")
                else
                    clear_lamp_compass_overlay(owner)--TODO probably wrong
                end
            end
        end

        inst.components.fueled:StartConsuming()

        if owner.components.maprevealable ~= nil then
            owner.components.maprevealable:AddRevealSource(inst, "compassbearer")
        end
        owner:AddTag("compassbearer")
    end

    local function compassonunequip(inst, owner)
        --if setting_show_compass then --TODO probably doesn't do anything
        owner.AnimState:Hide("ARM_carry")
        owner.AnimState:Show("ARM_normal")
        --end
        if owner.replica.inventory ~= nil then
            local equipment = owner.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            if not (equipment ~= nil and starts_with(equipment.prefab, "lantern")) then
                -- and not equipment.components.fueled:IsEmpty()) then
                --if setting_show_compass then
                clear_lamp_compass_overlay(owner)
                --owner.AnimState:Hide("LANTERN_OVERLAY")
                --owner.AnimState:ClearOverrideSymbol("swap_compass")
                --end
            end
        end

        inst.components.fueled:StopConsuming()

        if owner.components.maprevealable ~= nil then
            owner.components.maprevealable:RemoveRevealSource(inst)
        end
        owner:RemoveTag("compassbearer")
    end

    local function compasspostinit(inst)
        inst.components.equippable.equipslot = EQUIPSLOTS.WAIST or EQUIPSLOTS.HANDS
        inst.components.equippable:SetOnEquip(compassonequip)
        inst.components.equippable:SetOnUnequip(compassonunequip)
    end

    local function TryCompass(self)
        if self.owner.replica.inventory ~= nil then
            local equipment = self.owner.replica.inventory:GetEquippedItem(EQUIPSLOTS.WAIST or EQUIPSLOTS.HANDS)
            if equipment ~= nil and equipment:HasTag("compass") then
                self:OpenCompass()
                return true
            end
        end
        self:CloseCompass()
        return false
    end

    local function replacelistener(source, target, event, func)
        local listeners = target.event_listeners[event][source]
        local oldfunc = listeners[#listeners]
        source:RemoveEventCallback(event, oldfunc, target)
        source:ListenForEvent(event, func, target)
    end

    local function hudcompasspostconstruct(self)
        replacelistener(
                self.inst,
                self.owner,
                "refreshinventory",
                function(_)
                    TryCompass(self)
                end
        )
        replacelistener(
                self.inst,
                self.owner,
                "unequip",
                function(_, data)
                    if data.eslot == EQUIPSLOTS.WAIST then
                        self:CloseCompass()
                    end
                end
        )
        TryCompass(self)
    end

    if IsServer then
        AddPrefabPostInit("compass", compasspostinit)
        AddPrefabPostInit("lantern", lanternpostinit)
        AddPrefabPostInit("redlantern", lanternpostinit)
    end
    AddClassPostConstruct("widgets/hudcompass", hudcompasspostconstruct)
end

---BEGIN This code adds stuff to the "resurrectable"-component
AddComponentPostInit("resurrectable", function(self, _)
    local OldFindClosestResurrector = self.FindClosestResurrector
    local OldCanResurrect = self.CanResurrect
    local OldDoResurrect = self.DoResurrect

    local function findamulet(self_inner)
        if self_inner.inst.components.inventory then
            local item = self_inner.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.NECK)
            if item and item.prefab == "amulet" then
                return item
            end
        end
    end

    self.FindClosestResurrector = function(self_inner, cause)
        local item = findamulet(self_inner)
        if cause == "drowning" and item then
            self_inner.shouldwashuponbeach = true
        end
        local source = OldFindClosestResurrector(self_inner, cause)
        if source and not source.components.resurrector then
            return source
        end
        if item and not self_inner.shouldwashuponbeach then
            return item
        end
    end

    self.CanResurrect = function(self_inner, cause)
        local result = OldCanResurrect(self_inner, cause)
        if findamulet(self_inner) and not result or self_inner.resurrectionmethod == "resurrector" or self_inner.resurrectionmethod == "other" then
            self_inner.resurrectionmethod = "amulet"
            return true
        end
        return result
    end

    self.DoResurrect = function(self_inner, res, cause)
        if not res and findamulet(self_inner) then
            self_inner.inst:PushEvent("resurrect")
            self_inner.inst.sg:GoToState("amulet_rebirth")
            return true
        end
        return OldDoResurrect(self_inner, res, cause)
    end
end
)

---END This code adds stuff to the "resurrectable"-component

