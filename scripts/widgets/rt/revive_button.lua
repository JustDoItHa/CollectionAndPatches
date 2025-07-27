---
--- @author zsh in 2023/3/8 10:57
---

local Widget = require "widgets/widget"
local ImageButton = require "widgets/imagebutton"
local TEMPLATES = require "widgets/redux/templates"

local locale = LOC.GetLocaleCode();
local L = (locale == "zh" or locale == "zht" or locale == "zhr") and true or false;

local REVIVE_BUTTON = setmetatable({
    txt = L and "复活" or "Resurrect";
    size = { 100, 50 };
    icon_data = nil;
}, {
    __call = function(self, onclick)
        self.onclick = onclick;
        return self.onclick, self.txt, self.size, self.icon_data;
    end
})

local REVIVE_ICON_BUTTON = setmetatable({
    iconAtlas = "images/inventoryimages.xml",
    iconTexture = "amulet.tex", --"reviver.tex",
    labelText = "",
    sideLabel = nil,
    alwaysShowLabel = nil,
    onclick = nil,
    textinfo = nil, -- table
    defaultTexture = nil
}, {
    __call = function(self, onclick)
        self.onclick = onclick;
        return self.iconAtlas,
        self.iconTexture,
        self.labelText,
        self.sideLabel,
        self.alwaysShowLabel,
        self.onclick,
        self.textinfo,
        self.defaultTexture;
    end
})

local REVIVE_IMAGE_BUTTON = setmetatable({
    atlas = "images/inventoryimages.xml",
    normal = "amulet.tex",
    focus = nil,
    disabled = nil,
    down = nil,
    selected = nil,
    scale = { 1, 1 },
    offset = { 0, 0 }
}, {
    __call = function(self)
        return self.atlas,
        self.normal,
        self.focus,
        self.disabled,
        self.down,
        self.selected,
        self.scale,
        self.offset;
    end
})

-- 2023-03-08-15:46：好歹算是实现了按钮可以移动以及数据持久化保存，虽然目前还不能做到降低耦合以及代码优雅...

local INIT_X, INIT_Y = 0, -75;
INIT_X, INIT_Y = 150 + 200, 0;
--INIT_X, INIT_Y = 0, -50;
--INIT_X, INIT_Y = 0, 0;
INIT_X, INIT_Y = 150 + 150, 0;

local BUTTON_SCALE = 0.5;

---@class ReviveButton:Widget
local ReviveButton = Class(Widget, function(self, namespace --[[MOD_NAME]], playerhud)
    Widget._ctor(self, "rt_revive_button");

    -- Q: 按钮套按钮？不然调用模板里现成的函数得到的不就是个完整的按钮？咋修改？
    --               ReviveButton 实例化之后，显示它的孩子 revive_button 呗？
    -- Q: 话说我点击的时候点击的就是它的孩子吗？如果我不设置 revive_button 的点击函数？
    -- Q: 设置为它的孩子，show的时候是不是显示全部你添加的ui？
    --self.r_button = self:AddChild(TEMPLATES.StandardButton(REVIVE_BUTTON(function()
    --    SendModRPCToServer(MOD_RPC[namespace]["resurrect"]);
    --end)));
    --self.r_button = self:AddChild(TEMPLATES.IconButton(REVIVE_ICON_BUTTON(function()
    --    SendModRPCToServer(MOD_RPC[namespace]["resurrect"]);
    --end)));
    self.r_button = self:AddChild(ImageButton(REVIVE_IMAGE_BUTTON()));
    self.r_button:SetScale(BUTTON_SCALE, BUTTON_SCALE, BUTTON_SCALE);
    -- ImageButton 构造函数不需要传入 onclick 函数，但是 Button 都是可以设置 onclick 函数的
    self.r_button:SetOnClick(function()
        SendModRPCToServer(MOD_RPC[namespace]["resurrect"]);
    end)


    -- 设置复活按钮的属性
    -- vertical 原点 y 坐标位置，0 中、1 上、2 下
    -- horizontal 原点 x 坐标位置，0 中、1 左、2 右

    self.r_button:SetVAnchor(0)
    self.r_button:SetHAnchor(0)
    self.r_button:SetPosition(INIT_X, INIT_Y, 0)

    self.r_button:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self.r_button:SetMaxPropUpscale(MAX_HUD_SCALE)

    -- 初始化的时候重设坐标点
    TheSim:GetPersistentString("rt_revive_button", function(load_success, str)
        if load_success == true and str ~= nil then
            -- 此处是最简单的办法，klei有封装相关函数，诸如 DataDumper，可以研究一下如何使用。
            local pt = string.split(str, ",")
            self.r_button:SetPosition(Vector3(tonumber(pt[1]), tonumber(pt[2]), 0));
        end
    end)

    self:RefreshTooltips();

    -- Q: owner 应该就是玩家自身吧？
    -- 设置一个延迟，等初始化之后在显示/隐藏
    --playerhud.owner:DoTaskInTime(0, function(owner, playerhud)
    --    if owner:HasTag("playerghost") then
    --        if playerhud.rt_revive_button then
    --            playerhud.rt_revive_button:Show();
    --        end
    --    else
    --        if playerhud.rt_revive_button then
    --            playerhud.rt_revive_button:Hide();
    --        end
    --    end
    --end, playerhud)
end)

---关键函数
function ReviveButton:GetDragPosition(x, y)
    local mouse_pt = TheInput:GetScreenPosition()
    local widget_pt = self.r_button:GetPosition()
    local widget_scale = self.r_button:GetScale()
    -- 鼠标和按钮总是不能固定在一个位置，通过设置 offset 勉强让它们之间的偏移不至于过大！
    -- 不知道为什么会有偏移，但是通过测试发现 0.75 这个值挺好的。反正 0.6 和 1 绝对不行！
    local offset = 0.75;
    offset = 1.25; --?
    return widget_pt + (Vector3(x, y, 0) - mouse_pt) / (widget_scale.x / offset);
end

function ReviveButton:SaveDragPosition()
    if self.r_button_pt then
        --if ThePlayer.r_button_dragpt == nil then
        --    ThePlayer.r_button_dragpt = {}
        --end
        --ThePlayer.r_button_dragpt = { x = self.r_button_pt.x, y = self.r_button_pt.y }
        TheSim:SetPersistentString("rt_revive_button", tostring(self.r_button_pt.x) .. "," .. tostring(self.r_button_pt.y))
    end
end

function ReviveButton:RefreshTooltips()
    local left, right = "\238\132\128", "\238\132\129";
    right = "\238\132\130"; -- 改成鼠标中键
    self.r_button:SetTooltip(L
            and string.format("%s%s%s%s%s", "复活按钮\n", left, "复活 ", right, "拖拽")
            or string.format("%s%s%s%s%s", "Revive button\n", left, "Resurrect", right, "Drag"));
end

function ReviveButton:StartDrag()
    --print("", "Follow Mouse");
    self:FollowMouse()
end

function ReviveButton:StopDrag(x, y, z)
    --print("", "Stop Follow Mouse");
    self:StopFollowMouse()
    self.r_button:SetPosition(self:GetDragPosition(x, y))
    self:SaveDragPosition()
end

function ReviveButton:ResetDrag()
    self.r_button:SetPosition(INIT_X, INIT_Y, 0);
    self.r_button_pt = Vector3(INIT_X, INIT_Y, 0);
    self:SaveDragPosition()
end

-- 鼠标右键的时候设置按钮跟随鼠标，然后不断获得处理后的坐标并重设按钮坐标。当不再右键的时候，停止拖拽。
-- 改成中键
---@override
function ReviveButton:FollowMouse()
    if self.followhandler == nil then
        self.followhandler = TheInput:AddMoveHandler(function(x, y)
            self.r_button_pt = self:GetDragPosition(x, y)
            --self.r_button:UpdatePosition(self.r_button_pt.x, self.r_button_pt.y)
            self.r_button:SetPosition(self.r_button_pt.x, self.r_button_pt.y)
            if not Input:IsMouseDown(MOUSEBUTTON_MIDDLE) then
                self:StopDrag(x, y);
            end
        end)
        if self.r_button_pt then
            self.r_button:SetPosition(self.r_button_pt);
        end
    end
end

---@override
function ReviveButton:OnMouseButton(button, down, x, y)
    if not self.focus then
        return false;
    end

    if button == MOUSEBUTTON_MIDDLE--[[MOUSEBUTTON_RIGHT]] and down then
        self:StartDrag();
    else
        self:StopDrag(x, y);
    end
end

-- OnUpdate 父类里面没有这个函数了
--local count = 0;
--function ReviveButton:OnUpdate(dt)
--    count = count + 1;
--    if count == 20 then
--        count = 0;
--        print("self.r_button:GetPosition(): " .. tostring(self.r_button:GetPosition()));
--    end
--end

return ReviveButton;