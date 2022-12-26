-- 使用的mod名称：死亡复活按钮（Death Resurrection Button）
-- mod链接：https://steamcommunity.com/sharedfiles/filedetails/?id=2753774601
-- mod更新时间：2022.04.03 上午 01:40
-- mod作者：今晚早点睡
-- 修改范围：去除英文

----------------------------------------------------------------------------------------------------
--[[ 只代表查值时自动查global，增加global的变量或者修改global的变量时还是需要带"GLOBAL." ]]
----------------------------------------------------------------------------------------------------
GLOBAL.setmetatable(
    env,
    {
        __index = function(t, k)
            return GLOBAL.rawget(GLOBAL, k)
        end
    }
)
----------------------------------------------------------------------------------------------------
local ModConfigLanguage = GetModConfigData("Language")
local Language = function(english,chinese)
    if ModConfigLanguage then
        return english
    else
        return chinese
    end
end
----------------------------------------------------------------------------------------------------
--[[ 其他部分写在这里 ]]
----------------------------------------------------------------------------------------------------
if true then
    local CD = GetModConfigData("CD") --冷却时间
    local Health_Penalty = GetModConfigData("Health_Penalty") --血量上限惩罚
    local UI = GetModConfigData("UI") --UI位置

    local MODNAME = "modmain" --常量

    if true then
        --监听到玩家死亡时的处理函数
        local ms_becameghost_fn = function(inst, data)
            SendModRPCToClient(CLIENT_MOD_RPC[MODNAME]["ms_becameghost"], inst.userid, inst)
        end
        --监听到玩家复活时的处理函数
        local respawnfromghost_fn = function(inst, data)
            SendModRPCToClient(CLIENT_MOD_RPC[MODNAME]["respawnfromghost"], inst.userid, inst)
            if inst:HasTag("reborn_here") then --如果玩家通过按钮复活
                -- print("如果玩家通过按钮复活，开始设置血量上限惩罚")
                inst:RemoveTag("reborn_here") --移除该标签
                local new_penalty = inst.components.health.penalty + Health_Penalty
                if new_penalty > 0.75 then
                    new_penalty = 0.75
                end
                inst.components.health.penalty = new_penalty
                inst.components.health:ForceUpdateHUD(false)
            end
        end
        local AddPlayer_allplayers = function(inst)
            if not TheWorld.ismastersim then
                return inst
            end
            inst:ListenForEvent("ms_becameghost", ms_becameghost_fn) --监听玩家死亡
            inst:ListenForEvent("respawnfromghost", respawnfromghost_fn) --监听玩家复活
        end
        AddPlayerPostInit(AddPlayer_allplayers)
    end

    --[[ AddClientModRPCHandler ]]
    if true then
        local AddClientModRPCHandler_One = function(inst)
            -- print("玩家已经死亡，显示复活按钮")
            inst.HUD.reborn_button:Show()
        end
        local AddClientModRPCHandler_Two = function(inst)
            -- print("玩家已经复活，隐藏复活按钮")
            inst.HUD.reborn_button:Hide()
        end
        AddClientModRPCHandler(MODNAME, "ms_becameghost", AddClientModRPCHandler_One)
        AddClientModRPCHandler(MODNAME, "respawnfromghost", AddClientModRPCHandler_Two)
    end
    --[[ AddModRPCHandler ]]
    if true then
        local reborn = function(inst)
            if inst:HasTag("playerghost") then --如果玩家是死亡状态
                -- print("通过按钮复活，添加reborn_here标签")
                inst:AddTag("reborn_here")
                inst:PushEvent("respawnfromghost") --服务器发送事件源"respawnfromghost"，目的是让玩家复活
            end
        end
        local AddModRPCHandler_One = function(inst)
            if CD == 0 then --如果没有设置CD直接复活
                if inst and inst.components and inst.components.talker then
                    inst.components.talker:Say(Language("You didn't set the CD, just resurrect!", "你没有设置CD，直接复活！"))
                end
                reborn(inst) --复活
            else
                if not inst.components.timer:TimerExists("CD") then
                    inst.components.timer:StartTimer("CD", CD)
                    reborn(inst) --复活
                else
                    local lefttime = math.ceil(inst.components.timer:GetTimeLeft("CD")) or 0
                    if inst and inst.components and inst.components.talker then
                        inst.components.talker:Say(
                            Language(
                                "You have " .. lefttime .. " senconds before you can be resurrected！",
                                "还有 " .. lefttime .. "s 才能复活！"
                            )
                        )
                    end
                end
            end
        end
        AddModRPCHandler(MODNAME, "reborn", AddModRPCHandler_One)
    end
    --[[ 按钮 ]]
    if true then
        local TEMPLATES = require "widgets/redux/templates"
        local AddClassPostConstruct_One = function(self)
            --[[此处是客户端代码]]
            local old_CreateOverlays = self.CreateOverlays
            function self:CreateOverlays(owner)
                old_CreateOverlays(self, owner)
                local text = Language("Respawn", "立即复活")
                local size = {100, 50}
                self.reborn_button =
                    self:AddChild(
                    TEMPLATES.StandardButton(
                        function()
                            SendModRPCToServer(MOD_RPC[MODNAME]["reborn"])
                        end,
                        text,
                        size
                    )
                )
                --设置按钮的位置和缩放
                --vertical 原点y坐标位置，0中、1上、2下
                --horizontal 原点x坐标位置，0中、1左、2右
                if UI == "center" then --中心点
                    self.reborn_button:SetVAnchor(0)
                    self.reborn_button:SetHAnchor(0)
                elseif UI == "center_offset_down" then --中心偏下
                    self.reborn_button:SetVAnchor(0)
                    self.reborn_button:SetHAnchor(0)
                    self.reborn_button:SetPosition(0, -100, 0)
                elseif UI == "right_above" then --正上方
                    self.reborn_button:SetVAnchor(1)
                    self.reborn_button:SetHAnchor(0)
                    self.reborn_button:SetPosition(0, -100, 0)
                elseif UI == "upper_left" then --左上角
                    self.reborn_button:SetVAnchor(1)
                    self.reborn_button:SetHAnchor(1)
                    self.reborn_button:SetPosition(100, -100, 0)
                elseif UI == "lower_left" then --左下角
                    self.reborn_button:SetVAnchor(2)
                    self.reborn_button:SetHAnchor(1)
                    self.reborn_button:SetPosition(100, 100, 0)
                else --保证安全性
                    self.reborn_button:SetVAnchor(0)
                    self.reborn_button:SetHAnchor(0)
                end

                self.reborn_button:SetScaleMode(SCALEMODE_PROPORTIONAL)
                self.reborn_button:SetMaxPropUpscale(MAX_HUD_SCALE)

                --重载游戏时显示UI需要等待prefab全部初始化完成
                self.owner:DoTaskInTime(
                    0,
                    function(inst)
                        if self.owner:HasTag("playerghost") then --判断玩家有没有阿飘标签（playerghost）
                            self.reborn_button:Show() --显示
                        else
                            self.reborn_button:Hide() --隐藏
                        end
                    end
                )
            end
        end
        AddClassPostConstruct("screens/playerhud", AddClassPostConstruct_One)
    end
end
