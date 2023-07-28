---
--- @author zsh in 2023/1/8 17:13
--- 客户端 mod，班花的 looktietu，可以显示物品的代码、动画等，辅助测试用。

local API = require("chang_mone.dsts.API");

if API.hasBeenReleased(env) then
    return ;
end

local function GetBuild(inst)
    local strnn = ""
    local str = inst.entity:GetDebugString()

    if not str then
        return nil
    end
    local bank, build, anim = str:match("bank: (.+) build: (.+) anim: .+:(.+) Frame")

    if bank ~= nil and build ~= nil then
        strnn = strnn .. "动画: anim/" .. bank .. ".zip"
        strnn = strnn .. "\n" .. "贴图: anim/" .. build .. ".zip"
    end
    return strnn
end

env.AddClassPostConstruct("widgets/hoverer", function(self)
    local old_SetString = self.text.SetString
    self.text.SetString = function(text, str)
        local target = TheInput:GetHUDEntityUnderMouse() -- NOTE:
        if target ~= nil then
            target = (target.widget ~= nil and target.widget.parent ~= nil) and target.widget.parent.item
        else
            target = TheInput:GetWorldEntityUnderMouse()
        end
        if target and target.entity ~= nil then
            if target.prefab ~= nil then
                str = str .. "\n" .. "代码:" .. target.prefab
            end
            local build = GetBuild(target)
            if build ~= nil then
                str = str .. "\n" .. build
            end
        end
        return old_SetString(text, str)
    end
end)