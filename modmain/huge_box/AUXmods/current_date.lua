---
--- @author zsh in 2023/1/8 18:43
---

local Widget = require "widgets/widget";
local Text = require 'widgets/text';

local Agency = {
    ["TextTime"] = setmetatable({
        font = NUMBERFONT, -- fonts.lua
        size = 18,
        text = '00:00:00',
        colour = { 255, 255, 255, 1 }
    }, {
        __call = function(t)
            return t.font, t.size, t.text, t.colour
        end
    })
}

---@class CurrentDate
local CurrentDate = Class(Widget, function(self, owner)
    Widget._ctor(self, 'mone_CurrentDate');

    self:SetScale(2, 2);

    self.timeText = self:AddChild(Text(Agency.TextTime()));
end);

function CurrentDate:OnUpdate()
    local function getHMS()
        return os.date("%H"), os.date("%M"), os.date("%S");
    end

    local h, m, s = getHMS();
    self.timeText:SetString(h .. ' : ' .. m .. ' : ' .. s);
end

env.AddClassPostConstruct('widgets/controls', function(self, owner)
    self.mone_currentdate = self:AddChild(CurrentDate(owner));

    do
        ---@type CurrentDate
        local currentdate = self.mone_currentdate;

        currentdate:SetHAnchor(0); -- x  1,0,2
        currentdate:SetVAnchor(1); -- y  1,0,2
        --currentdate:SetPosition(150, -200);
        currentdate:SetPosition(0, -20);

        currentdate:Show();

        local emptyEntity = CreateEntity();
        emptyEntity:DoPeriodicTask(1, function()
            currentdate:OnUpdate();
        end);
    end

end)