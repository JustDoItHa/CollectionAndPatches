local CraftingMenu = require "widgets/redux/craftingmenu_hud"
local CraftingMenuIngredients = require "widgets/redux/craftingmenu_ingredients"
local LOC = require("languages/loc")
local lang_id = LOC:GetLanguage()
lang_id = (lang_id == LANGUAGE.CHINESE_T or lang_id == LANGUAGE.CHINESE_S or lang_id == LANGUAGE.CHINESE_S_RAIL) and LANGUAGE.CHINESE_S or lang_id
-- 这段代码和成就有冲突，很奇怪，所以不得不进行修复
-- local dragText =
--     ({
--     [LANGUAGE.CHINESE_S] = "拖拽",
--     [LANGUAGE.RUSSIAN] = "Переместить"
-- })[lang_id] or "Drag"
-- local resetText =
--     ({
--     [LANGUAGE.CHINESE_S] = "复原",
--     [LANGUAGE.RUSSIAN] = "Сброс"
-- })[lang_id] or "Reset"
local dragText = "Drag"
local resetText = "Reset"
if lang_id == LANGUAGE.CHINESE_S then
    dragText = "拖拽"
    resetText = "复原"
elseif lang_id == LANGUAGE.RUSSIAN then
    dragText = "Переместить"
    resetText = "Сброс"
end

-- [[以下代码部分来自于蘑菇慕斯的图标拖拽]]

local MOUSEBUTTON_DRAG = GetModConfigData("ui_button_badge_drag_button")
local MOUSEBUTTON_RESET = GetModConfigData("ui_button_badge_reset_button")
local MOUSEBUTTON_ZOOMOUT = GetModConfigData("ui_button_badge_zoomout_button")
local MOUSEBUTTON_ZOOMIN = GetModConfigData("ui_button_badge_zoomin_button")
local MIRRORFLIP = GetModConfigData("ui_button_badge_mirrorflip")

local UI_REMEMBER = GetModConfigData("ui_button_badge_remember")
local UI_SHOWTOOLTIP = GetModConfigData("ui_button_badge_tooltip")

local function generateUITip(ui)
    local DRAGTIP = MOUSEBUTTON_DRAG > 0 and not ui._DragZoomUIMod.disabledrag and (STRINGS.UI.CONTROLSSCREEN.INPUTS[1][MOUSEBUTTON_DRAG] .. dragText) or ""
    if MOUSEBUTTON_RESET <= 0 then return DRAGTIP end
    local RESETTIP = MOUSEBUTTON_RESET > 0 and not ui._DragZoomUIMod.disabledrag and not ui._DragZoomUIMod.disablezoom and
            (STRINGS.UI.CONTROLSSCREEN.INPUTS[1][MOUSEBUTTON_RESET] .. resetText) or ""
    if ui._DragZoomUIMod.disabledrag or MOUSEBUTTON_DRAG <= 0 then return RESETTIP end
    if DRAGTIP ~= "" and RESETTIP ~= "" then DRAGTIP = DRAGTIP .. "\n" end
    return DRAGTIP .. RESETTIP
end

local function saveUI(ui)
    local pos = ui:GetPosition()
    local scale = Vector3(0, 0, 0)
    scale.x, scale.y, scale.z = ui:GetLooseScale()
    ui._DragZoomUIMod.data = UI_REMEMBER and {
        pos = {x = pos.x or 0, y = pos.y or 0, z = pos.z or 0},
        scale = {x = scale.x or 0, y = scale.y or 0, z = scale.z or 0},
        mirrorflip = ui._DragZoomUIMod.data.mirrorflip
    } or (ui._DragZoomUIMod.mirrorflip and {mirrorflip = false} or {})

    SaveModData(ui._DragZoomUIMod.key, ui._DragZoomUIMod.data)
end

local function resetUI(ui, change)
    if change then
        ui._DragZoomUIMod.SetPosition(ui, ui._DragZoomUIMod.oldPosition)
        ui._DragZoomUIMod.SetScale(ui, ui._DragZoomUIMod.oldScale)
    end
    ui._DragZoomUIMod.data = {}
    if ui._DragZoomUIMod.mirrorflip then ui._DragZoomUIMod.mirrorflip = {mirrorflip = false} end
    SaveModData(ui._DragZoomUIMod.key, ui._DragZoomUIMod.data)
end

local function mirrorflipCraftingmenu(ui, is_left)
    if ui:IsCraftingOpen() then ui:Close() end
    if is_left then
        ui._DragZoomUIMod.need_root.left_root:AddChild(ui)
    else
        ui._DragZoomUIMod.need_root.right_root:AddChild(ui)
    end
    local is_left_aligned = is_left
    ui.is_left_aligned = is_left_aligned
    local y_offset = IsSplitScreen() and -50 or 0
    if is_left_aligned then
        ui.closed_pos = Vector3(0, y_offset, 0)
        ui.opened_pos = Vector3(530, y_offset, 0)
    else
        ui.closed_pos = Vector3(0, y_offset, 0)
        ui.opened_pos = Vector3(-530, y_offset, 0)
    end
    ui.craftingmenu:SetPosition(is_left_aligned and -255 or 255, 0)
    ui.openhint:SetPosition(is_left_aligned and 28 or -28, 334 + y_offset)
    ui.craftingmenu:DoFocusHookups()
    ui.pinbar.root:SetPosition(is_left and 30 or -30, 0)
    ui.pinbar.open_menu_button:SetPosition(is_left and 9 or -9, 378)
    ui.pinbar.open_menu_button:SetNormalScale(is_left and 0.4 or -.4, .4)
    ui.pinbar.open_menu_button:SetFocusScale(is_left and 0.45 or -.45, .45)
    ui.pinbar.open_menu_button.icon:SetScale(is_left and 0.75 or -0.75, 0.75)
    ui.pinbar.page_spinner.bg:SetScale(is_left and 0.65 or -0.65, 0.65)
    ui.pinbar.page_spinner.bg:SetPosition(is_left and -1 or 1, 1)
    local offset = {is_left and 5 or -5, 0}
    for _, pin_slot in ipairs(ui.pinbar.pin_slots) do
        pin_slot.craft_button.image_offset = offset
        pin_slot.craft_button.image:SetPosition(offset[1], offset[2])
        pin_slot.craft_button:SetNormalScale(is_left and 1 or -1, 1)
        pin_slot.craft_button:SetFocusScale(is_left and 1.15 or -1.15, 1.15)
        pin_slot.craft_button:SetPosition(is_left and -5 or 5, 0)
        pin_slot.unpin_controllerhint:SetHAlign(is_left and ANCHOR_LEFT or ANCHOR_RIGHT)
        pin_slot.unpin_controllerhint:SetScale(is_left and 1 or -1, 1)
        pin_slot.recipe_popup.ShowPopup = function(popup_self, recipe)
            if recipe ~= nil then
                popup_self:Show()
                if popup_self.ingredients ~= nil then popup_self.ingredients:Kill() end
                popup_self.ingredients = popup_self:AddChild(CraftingMenuIngredients(popup_self.owner, popup_self.max_ingredients_wide, recipe, 1.1))
                popup_self.background:ManualFlow(math.min(popup_self.max_ingredients_wide, popup_self.ingredients.num_items), true)
                local x = popup_self.background.startcap:GetPositionXYZ()
                local popup_x = x * popup_self._scale + 34 / pin_slot.base_scale
                popup_self:SetPosition(is_left and popup_x or -popup_x, 0)
                local hint_x = x * popup_self._scale * 0.5 + 6 / pin_slot.base_scale
                popup_self.openhint:SetPosition(is_left and hint_x or -hint_x, 0)
            else
                popup_self:Hide()
            end
        end
    end
    ui.pinbar:RefreshPinnedRecipes()
end

local function mirrorflipUI(ui, isInitTime)
    -- 镜像UI，同时加上0.25秒的CD防止连点
    if MIRRORFLIP and ui._DragZoomUIMod.mirrorflip and not ui._DragZoomUIMod.mirrorfliptimeout then
        ui._DragZoomUIMod.mirrorfliptimeout = ui.inst:DoTaskInTime(0.25, function() ui._DragZoomUIMod.mirrorfliptimeout = nil end)
        if isInitTime then
            if ui._DragZoomUIMod.key == "craftingmenu" and ui._DragZoomUIMod.data.mirrorflip then
                mirrorflipCraftingmenu(ui, false)
            elseif ui._DragZoomUIMod.key == "upgrademodulesdisplay" then
                ui.reversed = ui._DragZoomUIMod.data.mirrorflip
            end
            return
        end
        if ui._DragZoomUIMod.key == "craftingmenu" then
            if ui._DragZoomUIMod.data.mirrorflip then
                ui._DragZoomUIMod.data.mirrorflip = false
                mirrorflipCraftingmenu(ui, true)
                resetUI(ui, true)
            else
                ui._DragZoomUIMod.data.mirrorflip = true
                mirrorflipCraftingmenu(ui, false)
                -- Extra Change
                ui._DragZoomUIMod.SetPosition(ui, ui._DragZoomUIMod.oldPosition)
                -- ui._DragZoomUIMod.SetScale(ui, ui._DragZoomUIMod.oldScale)
                saveUI(ui)
            end
            return
        end
        if ui._DragZoomUIMod.key == "upgrademodulesdisplay" then ui.reversed = not ui.reversed end
        if ui._DragZoomUIMod.data.mirrorflip then
            ui._DragZoomUIMod.data.mirrorflip = false
            resetUI(ui, true)
        else
            ui._DragZoomUIMod.data.mirrorflip = true
            -- 水平翻转UI
            local x, y, z = ui:GetLooseScale()
            local scale = Vector3(-x, y, z)
            ui._DragZoomUIMod.SetScale(ui, scale)
            saveUI(ui)
        end
    end
end

local function zoomUI(ui, zoomout)
    local num = zoomout and 0.01 or -0.01
    local pos = ui:GetPosition()
    local scale = Vector3(0, 0, 0)
    scale.x, scale.y, scale.z = ui:GetLooseScale()
    scale.x = scale.x + num
    scale.y = scale.y + num
    scale.z = scale.z + num
    if not zoomout then
        scale.x = scale.x > 0 and scale.x or 0
        scale.y = scale.y > 0 and scale.y or 0
        scale.z = scale.z > 0 and scale.z or 0
    end
    ui._DragZoomUIMod.SetScale(ui, scale)
    ui._DragZoomUIMod.data = UI_REMEMBER and {
        pos = {x = pos.x or 0, y = pos.y or 0, z = pos.z or 0},
        scale = {x = scale.x or 0, y = scale.y or 0, z = scale.z or 0},
        mirrorflip = ui._DragZoomUIMod.data.mirrorflip
    } or (ui._DragZoomUIMod.mirrorflip and {mirrorflip = false} or {})
    SaveModData(ui._DragZoomUIMod.key, ui._DragZoomUIMod.data)
end

function processUI(ui, keyortable)
    -- 判断是否是合法UI
    if not (ui and ui.SetPosition and keyortable) then return end
    -- UI的参数初始化，防止UI重复处理
    ui._DragZoomUIMod = ui._DragZoomUIMod or {}
    if ui._DragZoomUIMod.init then return end
    ui._DragZoomUIMod.init = true
    local key = ""
    if type(keyortable) == "table" then
        key = keyortable.key
        for k, v in pairs(keyortable) do ui._DragZoomUIMod[k] = v end
    elseif type(keyortable) == "string" then
        key = keyortable
        ui._DragZoomUIMod.key = keyortable
    else
        return
    end
    if ui._DragZoomUIMod.key == "" then return end
    -- 同时禁用拖拽缩放那后面还处理个鬼啊
    if ui._DragZoomUIMod.disabledrag and ui._DragZoomUIMod.disablezoom then return end
    -- UI设置提示文本
    if UI_SHOWTOOLTIP and not ui._DragZoomUIMod.notip then
        local oldTooltip = ui.tooltip or ""
        ui._DragZoomUIMod.tooltip = generateUITip(ui)
        if oldTooltip ~= "" and ui._DragZoomUIMod.tooltip ~= "" then
            ui._DragZoomUIMod.tooltip = ui._DragZoomUIMod.tooltip .. "\n" .. oldTooltip
        else
            ui._DragZoomUIMod.tooltip = ui._DragZoomUIMod.tooltip .. oldTooltip
        end
        if ui._DragZoomUIMod.tooltip ~= "" then
            local actui = ui._DragZoomUIMod.acttarget and ui._DragZoomUIMod.acttarget or ui
            actui:SetTooltip(ui._DragZoomUIMod.tooltip)
        end
    end
    -- 默认代理UI的位置操作，拦截其他途径对位置的操作，不一定能全部拦截
    local oldSetPosition = ui.SetPosition
    ui.SetPosition = function(...) if ui._DragZoomUIMod.allow == true or ui._DragZoomUIMod.allowpostion then oldSetPosition(...) end end
    ui._DragZoomUIMod.SetPosition = function(...)
        ui._DragZoomUIMod.allow = true
        ui.SetPosition(...)
        ui._DragZoomUIMod.allow = false
    end
    -- 默认代理UI的尺寸操作，拦截其他途径对尺寸的操作，不一定能全部拦截
    local oldSetScale = ui.SetScale
    ui.SetScale = function(...) if ui._DragZoomUIMod.allow == true or ui._DragZoomUIMod.allowscale then oldSetScale(...) end end
    ui._DragZoomUIMod.SetScale = function(...)
        ui._DragZoomUIMod.allow = true
        ui.SetScale(...)
        ui._DragZoomUIMod.allow = false
    end
    -- 读取和缓存UI的原始位置尺寸
    local oldpos = ui:GetPosition()
    local oldscale = Vector3(0, 0, 0)
    oldscale.x, oldscale.y, oldscale.z = ui:GetLooseScale()
    ui._DragZoomUIMod.oldPosition = oldpos
    ui._DragZoomUIMod.oldScale = oldscale
    local nowscalex = oldscale.x
    -- 代理UI的鼠标跟随操作
    InitUIFollowMouse(ui)
    -- UI位置尺寸初始化
    ui._DragZoomUIMod.data = LoadModData(key) or {}
    if UI_REMEMBER then
        if ui._DragZoomUIMod.data.pos then
            ui._DragZoomUIMod.SetPosition(ui, ui._DragZoomUIMod.data.pos.x, ui._DragZoomUIMod.data.pos.y, ui._DragZoomUIMod.data.pos.z)
        end
        if ui._DragZoomUIMod.data.scale then
            ui._DragZoomUIMod.SetScale(ui, ui._DragZoomUIMod.data.scale.x, ui._DragZoomUIMod.data.scale.y, ui._DragZoomUIMod.data.scale.z)
            nowscalex = ui._DragZoomUIMod.data.scale.x
        end
    else
        resetUI(ui, false)
    end
    -- 初始化UI的镜像方向，更新UI内部变量
    if MIRRORFLIP and ui._DragZoomUIMod.mirrorflip and UI_REMEMBER then
        if ui._DragZoomUIMod.key == "upgrademodulesdisplay" and ui._DragZoomUIMod.data.mirrorflip == nil then
            ui._DragZoomUIMod.oldreversed = ui.reversed == true
            -- 当前x和原始x正负不同乘积小于0则说明翻转过，正负相同大于0则说明未翻转过
            local notreversed = nowscalex == ui._DragZoomUIMod.oldScale.x or ui._DragZoomUIMod.oldScale.x * nowscalex > 0
            if not notreversed then ui.reversed = not ui.reversed end
            ui._DragZoomUIMod.data.mirrorflip = not notreversed
        elseif ui._DragZoomUIMod.data.mirrorflip == nil then
            ui._DragZoomUIMod.data.mirrorflip = false
        end
        mirrorflipUI(ui, true)
    end
    -- 代理UI的鼠标操作，以实现UI通过鼠标拖拽和复原
    -- if not ui.bgimage then
    --     ui.bgimage = ui:AddChild(Image())
    -- end
    -- 同时兼容容器,对边框才进行拖拽,但是进行整体移动
    local acttargets = {}
    if ui._DragZoomUIMod.acttargets then
        acttargets = ui._DragZoomUIMod.acttargets
    elseif ui._DragZoomUIMod.acttarget then
        table.insert(acttargets, ui._DragZoomUIMod.acttarget)
    elseif ui._DragZoomUIMod.acttargetkey then
        table.insert(acttargets, ui[ui._DragZoomUIMod.acttargetkey])
    else
        table.insert(acttargets, ui)
    end
    for _, actui in ipairs(acttargets) do
        actui:SetClickable(true)
        local oldOnMouseButton = actui.OnMouseButton
        actui.OnMouseButton = function(self, button, down, x, y)
            -- 设置UI拖拽按键，拖拽中不能复位
            if button == MOUSEBUTTON_DRAG and down and not ui._DragZoomUIMod.disabledrag then -- 鼠标拖拽键按下
                ui._DragZoomUIMod.draging = true
                ui._DragZoomUIMod.FollowMouse(ui) -- 开启控件的鼠标跟随
            elseif button == MOUSEBUTTON_DRAG and not ui._DragZoomUIMod.disabledrag then -- 鼠标拖拽键抬起
                -- print("退出拖拽")
                ui._DragZoomUIMod.draging = false
                ui._DragZoomUIMod.StopFollowMouse(ui) -- 停止控件的跟随
                saveUI(ui)
            elseif button == MOUSEBUTTON_RESET and not ui._DragZoomUIMod.draging then
                if MIRRORFLIP and ui._DragZoomUIMod.mirrorflip then
                    mirrorflipUI(ui)
                else
                    resetUI(ui, true)
                end
            elseif button == MOUSEBUTTON_ZOOMOUT and not ui._DragZoomUIMod.draging and not ui._DragZoomUIMod.disablezoom then
                zoomUI(ui, true)
            elseif button == MOUSEBUTTON_ZOOMIN and not ui._DragZoomUIMod.draging and not ui._DragZoomUIMod.disablezoom then
                zoomUI(ui, false)
            end
            -- 鼠标事件依旧抛出，希望非本模组代码对此UI的操作不会和本模组冲突
            if oldOnMouseButton then oldOnMouseButton(self, button, down, x, y) end
        end
    end
end

function processUIList(parentUI, uiList, rootUI)
    rootUI = rootUI or parentUI
    for k, v in pairs(uiList) do
        if k == "self" then
            if v.need_root then v.need_root = rootUI end
            processUI(parentUI, v)
        elseif type(v) == "table" and parentUI[k] then
            processUIList(parentUI[k], v, rootUI)
        elseif parentUI[k] then
            processUI(parentUI[k], v)
        end
    end
end
