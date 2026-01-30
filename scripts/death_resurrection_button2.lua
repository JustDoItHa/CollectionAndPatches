---
--- @author zsh in 2023/3/9 9:17
---

local config_data = TUNING.RT_BUTTONS_TUNING.MOD_CONFIG_DATA;

local locale = LOC.GetLocaleCode();
local L = (locale == "zh" or locale == "zht" or locale == "zhr") and true or false;

local MOD_NAME = "rt_buttons";

local ReviveButton = require("widgets.rt.revive_button");

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

local function Revive(inst)
    if inst:HasTag("playerghost") then
        inst:AddTag("revive_by_button");
        inst:PushEvent("respawnfromghost", { source = inst });
        -- 生成光源，避免黑死。
        local x, y, z = inst.Transform:GetWorldPosition();
        if x and y and z then
            SpawnPrefab("spawnlight_multiplayer").Transform:SetPosition(x, y, z);
        end
    end
end

AddModRPCHandler(MOD_NAME, "resurrect", function(player, ...)
    if not config_data.RB.cd then
        -- 咋不说话？因为在执行其他动作吗？
        --player.components.talker:Say(L and "直接复活！" or "Direct resurrection!");
        Revive(player);
        return ;
    end

    -- 如果设置了冷却时间
    local CD = GetModConfigData("CD");
    if player.components.timer == nil then
        player:AddComponent("timer");
    end
    if not player.components.timer:TimerExists(MOD_NAME .. "_cd") then
        player.components.timer:StartTimer(MOD_NAME .. "_cd", CD);
        Revive(player);
        return ;
    end
    local left_time = math.ceil(player.components.timer:GetTimeLeft(MOD_NAME .. "_cd")) or 0;
    player.components.talker:Say(L and "距离复活还有 " .. tostring(left_time) .. " 秒" or tostring(left_time) .. " seconds until resurrection");
end);

local function addReviveButton(self)
    local old_CreateOverlays = self.CreateOverlays;
    function self:CreateOverlays(owner)
        old_CreateOverlays(self, owner);
        self.rt_revive_button = self:AddChild(require "widgets/redux/templates".StandardButton(REVIVE_BUTTON(function()
            SendModRPCToServer(MOD_RPC[MOD_NAME]["resurrect"]);
        end)));

        -- 设置复活按钮的属性
        -- vertical 原点 y 坐标位置，0 中、1 上、2 下
        -- horizontal 原点 x 坐标位置，0 中、1 左、2 右

        --正上方
        self.rt_revive_button:SetVAnchor(1)
        self.rt_revive_button:SetHAnchor(0)
        self.rt_revive_button:SetPosition(0, -50, 0)

        self.rt_revive_button:SetScaleMode(SCALEMODE_PROPORTIONAL)
        self.rt_revive_button:SetMaxPropUpscale(MAX_HUD_SCALE)

        self.owner:DoTaskInTime(0, function(owner, self)
            if owner:HasTag("playerghost") then
                self.rt_revive_button:Show();
            else
                self.rt_revive_button:Hide();
            end
        end, self)
    end
end

local function addReviveButton2(self)
    local old_CreateOverlays = self.CreateOverlays;
    function self:CreateOverlays(owner)
        old_CreateOverlays(self, owner);
        -- 在保护模式下执行
        local state = pcall(function()
            self.rt_revive_button = self:AddChild(ReviveButton(MOD_NAME, self));

            TheInput:AddKeyHandler(function(key, down)
                if down then
                    if key == 278 then
                        self.rt_revive_button:ResetDrag();
                    end
                end
            end)
        end)
        print("", "Chang: " .. "UI-ReviveButton, success?: " .. tostring(state));
    end
end

-- 按钮可以添加到这里，但是 ImageButton 添加到这里好像 SetTooltip 不生效。
--env.AddClassPostConstruct("screens/playerhud", function(self)
--    addReviveButton2(self);
--end)

local function addReviveButton3(self)
    self.rt_revive_button = self:AddChild(ReviveButton(MOD_NAME));

    TheInput:AddKeyHandler(function(key, down)
        if down then
            if key == 278 then
                self.rt_revive_button:ResetDrag();
            end
        end
    end)

    if ThePlayer and ThePlayer.DoTaskInTime then
        ThePlayer:DoTaskInTime(0, function(inst, mapcontrols)
            if inst:HasTag("playerghost") then
                if mapcontrols.rt_revive_button then
                    mapcontrols.rt_revive_button:Show();
                end
            else
                if mapcontrols.rt_revive_button then
                    mapcontrols.rt_revive_button:Hide();
                end
            end
        end, self)
    end

    if ThePlayer and ThePlayer:HasTag("playerghost") then
        if self.rt_revive_button then
            self.rt_revive_button:Show();
        end
    else
        -- 难道还会出现 ThePlayer 不存在的情况？
        if self.rt_revive_button then
            self.rt_revive_button:Hide();
        end
    end

end

-- mapcontrols 图标会清晰许多  2023-03-11-12:04：但是为什么会一直停留在小地图上？
env.AddClassPostConstruct("widgets/mapcontrols"--[["widgets/controls"]], function(self)
    addReviveButton3(self);
end)

AddClientModRPCHandler(MOD_NAME, "ms_becameghost", function(inst)
    --if inst.HUD and inst.HUD.rt_revive_button then
    --    inst.HUD.rt_revive_button:Show()
    --end
    -- 在这里修改吧！
    if inst.HUD and inst.HUD.controls
            and inst.HUD.controls.mapcontrols
            and inst.HUD.controls.mapcontrols.rt_revive_button then
        inst.HUD.controls.mapcontrols.rt_revive_button:Show();
    end
end)
AddClientModRPCHandler(MOD_NAME, "ms_respawnedfromghost", function(inst)
    --if inst.HUD and inst.HUD.rt_revive_button then
    --    inst.HUD.rt_revive_button:Hide()
    --end
    -- 在这里修改吧！
    if inst.HUD and inst.HUD.controls
            and inst.HUD.controls.mapcontrols
            and inst.HUD.controls.mapcontrols.rt_revive_button then
        inst.HUD.controls.mapcontrols.rt_revive_button:Hide()
    end
end)

env.AddPlayerPostInit(function(inst)
    if not TheWorld.ismastersim then
        return inst;
    end
    inst:ListenForEvent("ms_becameghost", function(inst, data)
        SendModRPCToClient(CLIENT_MOD_RPC[MOD_NAME]["ms_becameghost"], inst.userid, inst);
        -- 第一次死亡也会计时
        if config_data.RB.cd then
            --print("inst: "..tostring(inst));
            -- 之前写在了客户端模块，由于是未开启洞穴的主机，所以崩掉了。
            if inst.components.timer and not inst.components.timer:TimerExists(MOD_NAME .. "_cd") then
                inst.components.timer:StartTimer(MOD_NAME .. "_cd", config_data.RB.cd);
            end
        end
    end);
    inst:ListenForEvent("ms_respawnedfromghost", function(inst, data)
        SendModRPCToClient(CLIENT_MOD_RPC[MOD_NAME]["ms_respawnedfromghost"], inst.userid, inst);
        if inst:HasTag("revive_by_button") then
            inst:RemoveTag("revive_by_button");
            -- plan: 通过此处复活的话，保存一下死亡次数。
            -- TheNet:Announce("玩家 xxx 已经通过复活按钮复活 x 次了。")


            local penalty = config_data.RB.penalty;
            if penalty then
                -- 有年龄组件取消惩罚
                if inst.components.oldager then
                    return ;
                end
                inst.components.health.penalty = math.min(inst.components.health.penalty + penalty, 0.75);
                inst.components.health:ForceUpdateHUD(true);
            end
        end
    end);
end)