local Text = require "widgets/text"

local UI_SHOWTOOLTIP = GetModConfigData("ui_button_badge_tooltip")

-- 模组里使用变量时可以直接使用GLOBAL的属性变量了，非常方便
GLOBAL.setmetatable(env, {__index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end})

-- 模组动态加载，主要用来识别模组UI的widet定义文件
function isModuleAvailable(name)
    if package.loaded[name] then
        return true
    else
        for _, searcher in ipairs(package.searchers or package.loaders) do
            local loader = searcher(name)
            if type(loader) == "function" then
                package.preload[name] = loader
                return true
            end
        end
        return false
    end
end

-- [[以下代码来自蘑菇慕斯]]

-- 文件存储 --
-- 文件存储 id的值应该是存储数据的ID, 不同功能绝不应该设置相同的ID
local SavePSData = require("persistentdata")
local DataContainerID = "ModData_DragZoomUI"
local ModDataContainer = SavePSData(DataContainerID)
ModDataContainer:Load()

function SaveModData(id, value)
    if not id then return end
    ModDataContainer:SetValue(id, value)
    ModDataContainer:Save()
    print("ModDragZoomUI存储数据", id, value)
end

function LoadModData(id)
    if not id then return end
    local value = ModDataContainer:GetValue(id)
    if value == nil then print("ModDragZoomUI读取失败, 再次尝试", id) end
    return value
end

-- [[以下代码来自蘑菇慕斯]] 但经过一定魔改

--[[将该函数提取出来]]
-- 默认的原点坐标为父级的坐标，如果widget上有v_anchor和h_anchor这两个变量，就说明改变了默认的原点坐标
-- 我们会在GetMouseLocalPos函数里检查这两个变量，以对这种情况做专门的处理
-- 这个函数可以将鼠标坐标从屏幕坐标系下转换到和wiget同一个坐标系下
function GetMouseLocalPos(ui, mouse_pos) -- ui: 要拖拽的widget, mouse_pos: 鼠标的屏幕坐标(Vector3对象)
    local g_s = ui:GetScale() -- ui的全局缩放值
    local l_s = Vector3(0, 0, 0)
    l_s.x, l_s.y, l_s.z = ui:GetLooseScale() -- ui本身的缩放值
    local scale = Vector3(g_s.x / l_s.x, g_s.y / l_s.y, g_s.z / l_s.z) -- 父级的全局缩放值

    local ui_local_pos = ui:GetPosition() -- ui的相对位置（也就是SetPosition的时候传递的坐标）
    ui_local_pos = Vector3(ui_local_pos.x * scale.x, ui_local_pos.y * scale.y, ui_local_pos.z * scale.z)
    local ui_world_pos = ui:GetWorldPosition()
    -- 如果修改过ui的屏幕原点，就重新计算ui的屏幕坐标（基于左下角为原点的）
    if not (not ui.v_anchor or ui.v_anchor == ANCHOR_BOTTOM) or not (not ui.h_anchor or ui.h_anchor == ANCHOR_LEFT) then
        local screen_w, screen_h = TheSim:GetScreenSize() -- 获取屏幕尺寸（宽度，高度）
        if ui.v_anchor and ui.v_anchor ~= ANCHOR_BOTTOM then -- 如果修改了原点的垂直坐标
            ui_world_pos.y = ui.v_anchor == ANCHOR_MIDDLE and screen_h / 2 + ui_world_pos.y or screen_h - ui_world_pos.y
        end
        if ui.h_anchor and ui.h_anchor ~= ANCHOR_LEFT then -- 如果修改了原点的水平坐标
            ui_world_pos.x = ui.h_anchor == ANCHOR_MIDDLE and screen_w / 2 + ui_world_pos.x or screen_w - ui_world_pos.x
        end
    end

    local origin_point = ui_world_pos - ui_local_pos -- 原点坐标
    mouse_pos = mouse_pos - origin_point

    return Vector3(mouse_pos.x / scale.x, mouse_pos.y / scale.y, mouse_pos.z / scale.z) -- 鼠标相对于UI父级坐标的局部坐标
end

local positionTextUI = nil

AddClassPostConstruct("widgets/controls", function(self)
    self.positionTextUI = self:AddChild(Text(UIFONT, 30))
    self.positionTextUI:SetHAnchor(ANCHOR_MIDDLE)
    self.positionTextUI:SetVAnchor(ANCHOR_MIDDLE)
    self.positionTextUI:SetPosition(0, -100, 0)
    -- self.positionTextUI:SetRegionSize(200, 600)
    positionTextUI = self.positionTextUI
end)

local function ShowPositionText(text)
    if not positionTextUI then return end
    positionTextUI:Show()
    positionTextUI:SetString(text)
    if positionTextUI.task then positionTextUI.task:Cancel() end
    positionTextUI.task = positionTextUI.inst:DoTaskInTime(1.5, function()
        positionTextUI:Hide()
        positionTextUI.task = nil
    end)
end

function GetPosStr(x, y, z) return "(" .. string.format("%.2f", x) .. " , " .. string.format("%.2f", y) .. " , " .. string.format("%.2f", z) .. ")" end

local _lastui
-- [[将该函数提取出来]]
function InitUIFollowMouse(ui)
    -- [[初始化条件判断]]
    if not (ui and ui._DragZoomUIMod and ui._DragZoomUIMod.init) then return end

    -- GetWorldPosition获得的坐标是基于屏幕原点的，默认为左下角，当单独设置了原点的时候，这个函数返回的结果和GetPosition的结果一样了，达不到我们需要的效果
    -- 因为官方没有提供查询原点坐标的接口，所以需要修改设置原点的两个函数，将原点位置记录在widget上
    -- 注意：虽然默认的屏幕原点为左下角，但是每个widget默认的坐标原点为其父级的屏幕坐标；
    -- 而当你单独设置了原点坐标后，不仅其屏幕原点改变了，而且坐标原点的位置也改变为屏幕原点了
    local old_sva = ui.SetVAnchor
    ui.SetVAnchor = function(self, anchor, ...)
        self.v_anchor = anchor
        return old_sva(self, anchor, ...)
    end

    local old_sha = ui.SetHAnchor
    ui.SetHAnchor = function(self, anchor, ...)
        self.h_anchor = anchor
        return old_sha(self, anchor, ...)
    end
    -- [[魔改，使用不被拦截的坐标设置代理，且记录和保持鼠标点击位置和原始位置的偏移]]
    -- 修改官方的鼠标跟随，以适应所有情况
    ui._DragZoomUIMod.FollowMouse = function(self, ...)
        -- 取消上一个UI的拖拽
        if _lastui and _lastui ~= ui and _lastui._DragZoomUIMod and _lastui._DragZoomUIMod.draging then
            _lastui._DragZoomUIMod.draging = false
            _lastui._DragZoomUIMod.StopFollowMouse(_lastui) -- 停止控件的跟随
        end
        _lastui = ui
        if self.followhandler == nil then
            local mousepos = GetMouseLocalPos(self, TheInput:GetScreenPosition())
            local oldPosition = ui:GetPosition()
            if not ui._DragZoomUIMod.offset_x then
                self._DragZoomUIMod.offset_x = oldPosition.x - mousepos.x
                self._DragZoomUIMod.offset_y = oldPosition.y - mousepos.y
                self._DragZoomUIMod.offset_z = oldPosition.z - mousepos.z
            end
            self._DragZoomUIMod.SetPosition(self, mousepos.x + self._DragZoomUIMod.offset_x, mousepos.y + self._DragZoomUIMod.offset_y,
                    mousepos.z + self._DragZoomUIMod.offset_z)
            if UI_SHOWTOOLTIP then
                local worldpos = ui:GetWorldPosition()
                ShowPositionText(self._DragZoomUIMod.key .. "\n" ..
                        GetPosStr(mousepos.x + self._DragZoomUIMod.offset_x, mousepos.y + self._DragZoomUIMod.offset_y,
                                mousepos.z + self._DragZoomUIMod.offset_z) .. "\n" .. GetPosStr(worldpos.x, worldpos.y, worldpos.z))
            end
            self.followhandler = TheInput:AddMoveHandler(function(x, y)
                local loc_pos = GetMouseLocalPos(self, Vector3(x, y, 0)) -- 主要是将原本的x,y坐标进行了坐标系的转换，使用转换后的坐标来更新widget位置
                self._DragZoomUIMod.SetPosition(self, loc_pos.x + self._DragZoomUIMod.offset_x, loc_pos.y + self._DragZoomUIMod.offset_y,
                        loc_pos.z + self._DragZoomUIMod.offset_z)
                if UI_SHOWTOOLTIP then
                    local worldpos = ui:GetWorldPosition()
                    ShowPositionText(self._DragZoomUIMod.key .. "\n" ..
                            GetPosStr(loc_pos.x + self._DragZoomUIMod.offset_x, loc_pos.y + self._DragZoomUIMod.offset_y,
                                    loc_pos.z + self._DragZoomUIMod.offset_z) .. "\n" .. GetPosStr(worldpos.x, worldpos.y, worldpos.z))
                end
            end)
        end
        return self.FollowMouse(self, ...)
    end
    ui._DragZoomUIMod.StopFollowMouse = function(self, ...)
        self._DragZoomUIMod.offset_x = nil
        self._DragZoomUIMod.offset_y = nil
        self._DragZoomUIMod.offset_z = nil
        return self.StopFollowMouse(self, ...)
    end
end
