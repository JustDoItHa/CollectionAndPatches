-- local Image = require "widgets/image"
local LOC = require("languages/loc")
local lang_id = LOC:GetLanguage()
lang_id =
    (lang_id == LANGUAGE.CHINESE_T or lang_id == LANGUAGE.CHINESE_S or lang_id == LANGUAGE.CHINESE_S_RAIL) and
    LANGUAGE.CHINESE_S or
    lang_id
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
    local DRAGTIP =
        MOUSEBUTTON_DRAG > 0 and not ui._DragZoomUIMod.disabledrag and
        (STRINGS.UI.CONTROLSSCREEN.INPUTS[1][MOUSEBUTTON_DRAG] .. dragText) or
        ""
    if MOUSEBUTTON_RESET <= 0 then
        return DRAGTIP
    end
    local RESETTIP =
        MOUSEBUTTON_RESET > 0 and not ui._DragZoomUIMod.disabledrag and not ui._DragZoomUIMod.disablezoom and
        (STRINGS.UI.CONTROLSSCREEN.INPUTS[1][MOUSEBUTTON_RESET] .. resetText) or
        ""
    if ui._DragZoomUIMod.disabledrag or MOUSEBUTTON_DRAG <= 0 then
        return RESETTIP
    end
    if DRAGTIP ~= "" and RESETTIP ~= "" then
        DRAGTIP = DRAGTIP .. "\n"
    end
    return DRAGTIP .. RESETTIP
end

local function saveUI(ui)
    local pos = ui:GetPosition()
    local scale = Vector3(0, 0, 0)
    scale.x, scale.y, scale.z = ui:GetLooseScale()
    ui._DragZoomUIMod.data =
        UI_REMEMBER and
        {
            pos = {
                x = pos.x or 0,
                y = pos.y or 0,
                z = pos.z or 0
            },
            scale = {
                x = scale.x or 0,
                y = scale.y or 0,
                z = scale.z or 0
            }
        } or
        {}
    SaveModData(ui._DragZoomUIMod.key, ui._DragZoomUIMod.data)
end

local function resetUI(ui, change)
    if change then
        ui._DragZoomUIMod.SetPosition(ui, ui._DragZoomUIMod.oldPosition)
        ui._DragZoomUIMod.SetScale(ui, ui._DragZoomUIMod.oldScale)
    end
    ui._DragZoomUIMod.data = {}
    SaveModData(ui._DragZoomUIMod.key, ui._DragZoomUIMod.data)
end

local function mirrorflipUI(ui)
    -- 镜像UI，同时加上0.25秒的CD防止连点
    if MIRRORFLIP and ui._DragZoomUIMod.mirrorflip and not ui._DragZoomUIMod.mirrorfliptimeout then
        ui._DragZoomUIMod.mirrorfliptimeout =
            ui.inst:DoTaskInTime(
            0.25,
            function()
                ui._DragZoomUIMod.mirrorfliptimeout = nil
            end
        )
        ui.reversed = not ui.reversed
        -- 此时UI将变为原版时，视为复原
        if ui.reversed == ui._DragZoomUIMod.oldreversed then
            if ui._DragZoomUIMod.key == "ui_button_badge_craftingmenu" then
                ui._DragZoomUIMod.need_root.craftingmenu:Kill()
                ui._DragZoomUIMod.need_root.craftingmenu =
                    ui._DragZoomUIMod.need_root.left_root:AddChild(
                    CraftingMenu(ui._DragZoomUIMod.need_root.owner, true)
                )
                saveUI(ui)
            else
                resetUI(ui, true)
            end
        elseif ui._DragZoomUIMod.key == "ui_button_badge_craftingmenu" then
            ui._DragZoomUIMod.need_root.craftingmenu:Kill()
            ui._DragZoomUIMod.need_root.craftingmenu =
                ui._DragZoomUIMod.need_root.right_root:AddChild(CraftingMenu(ui._DragZoomUIMod.need_root.owner, true))
            saveUI(ui)
        else
            -- 此时UI将变为原版的镜像时，视为翻转
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
    ui._DragZoomUIMod.data =
        UI_REMEMBER and
        {
            pos = {
                x = pos.x or 0,
                y = pos.y or 0,
                z = pos.z or 0
            },
            scale = {
                x = scale.x or 0,
                y = scale.y or 0,
                z = scale.z or 0
            }
        } or
        {}
    SaveModData(ui._DragZoomUIMod.key, ui._DragZoomUIMod.data)
end

function processUI(ui, keyortable)
    -- 判断是否是合法UI
    if not (ui and ui.SetPosition and keyortable) then
        return
    end
    -- UI的参数初始化，防止UI重复处理
    ui._DragZoomUIMod = ui._DragZoomUIMod or {}
    if ui._DragZoomUIMod.init then
        return
    end
    ui._DragZoomUIMod.init = true
    local key = ""
    if type(keyortable) == "table" then
        key = keyortable.key
        for k, v in pairs(keyortable) do
            ui._DragZoomUIMod[k] = v
        end
    elseif type(keyortable) == "string" then
        key = keyortable
        ui._DragZoomUIMod.key = keyortable
    else
        return
    end
    if ui._DragZoomUIMod.key == "" then
        return
    end
    -- 同时禁用拖拽缩放那后面还处理个鬼啊
    if ui._DragZoomUIMod.disabledrag and ui._DragZoomUIMod.disablezoom then
        return
    end
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
            ui:SetTooltip(ui._DragZoomUIMod.tooltip)
        end
    end
    -- 默认代理UI的位置操作，拦截其他途径对位置的操作，不一定能全部拦截
    local oldSetPosition = ui.SetPosition
    ui.SetPosition = function(...)
        if ui._DragZoomUIMod.allow == true or ui._DragZoomUIMod.allowpostion then
            oldSetPosition(...)
        end
    end
    ui._DragZoomUIMod.SetPosition = function(...)
        ui._DragZoomUIMod.allow = true
        ui.SetPosition(...)
        ui._DragZoomUIMod.allow = false
    end
    -- 默认代理UI的尺寸操作，拦截其他途径对尺寸的操作，不一定能全部拦截
    local oldSetScale = ui.SetScale
    ui.SetScale = function(...)
        if ui._DragZoomUIMod.allow == true or ui._DragZoomUIMod.allowscale then
            oldSetScale(...)
        end
    end
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
            ui._DragZoomUIMod.SetPosition(
                ui,
                ui._DragZoomUIMod.data.pos.x,
                ui._DragZoomUIMod.data.pos.y,
                ui._DragZoomUIMod.data.pos.z
            )
        end
        if ui._DragZoomUIMod.data.scale then
            ui._DragZoomUIMod.SetScale(
                ui,
                ui._DragZoomUIMod.data.scale.x,
                ui._DragZoomUIMod.data.scale.y,
                ui._DragZoomUIMod.data.scale.z
            )
            nowscalex = ui._DragZoomUIMod.data.scale.x
        end
    else
        resetUI(ui, false)
    end
    -- 初始化UI的镜像方向，更新UI内部变量
    if MIRRORFLIP and ui._DragZoomUIMod.mirrorflip then
        ui._DragZoomUIMod.oldreversed = ui.reversed == true
        -- 当前x和原始x正负不同乘积小于0则说明翻转过，正负相同大于0则说明未翻转过
        local notreversed = nowscalex == ui._DragZoomUIMod.oldScale.x or ui._DragZoomUIMod.oldScale.x * nowscalex > 0
        if not notreversed then
            ui.reversed = not ui.reversed
        end
    end
    -- 代理UI的鼠标操作，以实现UI通过鼠标拖拽和复原
    -- if not ui.bgimage then
    --     ui.bgimage = ui:AddChild(Image())
    -- end
    ui:SetClickable(true)
    local oldOnMouseButton = ui.OnMouseButton or function()
        end
    ui.OnMouseButton = function(self, button, down, x, y)
        -- 设置UI拖拽按键，拖拽中不能复位
        if button == MOUSEBUTTON_DRAG and down and not self._DragZoomUIMod.disabledrag then --鼠标拖拽键按下
            self._DragZoomUIMod.draging = true
            self._DragZoomUIMod.FollowMouse(self) -- 开启控件的鼠标跟随
        elseif button == MOUSEBUTTON_DRAG and not self._DragZoomUIMod.disabledrag then --鼠标拖拽键抬起
            -- print("退出拖拽")
            self._DragZoomUIMod.draging = false
            self._DragZoomUIMod.StopFollowMouse(self) -- 停止控件的跟随
            saveUI(self)
        elseif button == MOUSEBUTTON_RESET and not self._DragZoomUIMod.draging then
            if MIRRORFLIP and ui._DragZoomUIMod.mirrorflip then
                mirrorflipUI(self)
            else
                resetUI(self, true)
            end
        elseif button == MOUSEBUTTON_ZOOMOUT and not self._DragZoomUIMod.draging and not self._DragZoomUIMod.disablezoom then
            zoomUI(self, true)
        elseif button == MOUSEBUTTON_ZOOMIN and not self._DragZoomUIMod.draging and not self._DragZoomUIMod.disablezoom then
            zoomUI(self, false)
        end
        -- 鼠标事件依旧抛出，希望非本模组代码对此UI的操作不会和本模组冲突
        oldOnMouseButton(self, button, down, x, y)
    end
end

function processUIList(parentUI, uiList, rootUI)
    rootUI = rootUI or parentUI
    for k, v in pairs(uiList) do
        if k == "self" then
            if v.need_root then
                v.need_root = rootUI
            end
            processUI(parentUI, v)
        elseif type(v) == "table" and parentUI[k] then
            processUIList(parentUI[k], v, rootUI)
        elseif parentUI[k] then
            processUI(parentUI[k], v)
        end
    end
end
