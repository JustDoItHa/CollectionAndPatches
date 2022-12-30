local Widget = require "widgets/widget"
local BeefaloBadge = require "widgets/beefaloBadge"


local BeefaloStatusBar = Class(Widget, function(self, owner, config)
    Widget._ctor(self, "BeefaloStatusBar")
    self.owner = owner
    self.config = config
    
    self.isHidden = true

    self.maxHealth = 1000
    self.maxHunger = 375
    self.buckDelay = 0
    self.mountStartTime = 0
    self.mounted = false
    self.tendency = nil
    self.timerTask = nil

    self.root = self:AddChild(Widget("root"))

    self.badgeStartPosition = -148
    self.badgeGap = self.config.gapModifier + (self.config.theme == "TheForge" and 4 or 0)
    self.badgeWidth = 74 + self.badgeGap

    local commonBadgeConfig = {theme = self.config.theme, brightness = self.config.bgBrightness, opacity = self.config.bgOpacity}

    self.healthBadge = self.root:AddChild(BeefaloBadge(commonBadgeConfig, {174 / 255, 21 / 255, 21 / 255, 1}, "status_health", nil, self.config.healthClearBG))
    self.healthBadge:SetPosition(self.badgeStartPosition, 0)

    self.domesticationBadge = self.root:AddChild(BeefaloBadge(commonBadgeConfig, self.config.badgeColors.ORNERY, nil, nil, true))
    self.domesticationBadge:SetPosition(self.badgeStartPosition + self.badgeWidth, 0)
    self.domesticationBadge.icon:SetTexture("minimap/minimap_data.xml", "beefalo_domesticated.png")

    self.obedienceBadge = self.root:AddChild(BeefaloBadge(commonBadgeConfig, self.config.badgeColors.OBEDIENCE, nil, nil, true))
    self.obedienceBadge:SetPosition(self.badgeStartPosition + self.badgeWidth * 2, 0)
    self.obedienceBadge.icon:SetTexture(GetInventoryItemAtlas("whip.tex"), "whip.tex")

    self.timerBadge = self.root:AddChild(BeefaloBadge(commonBadgeConfig, self.config.badgeColors.TIMER, nil, true, true))
    self.timerBadge:SetPosition(self.badgeStartPosition + self.badgeWidth * 3, 0)
    self.timerBadge.icon:SetTexture(GetInventoryItemAtlas("saddle_basic.tex"), "saddle_basic.tex")

    self.hungerBadge = self.root:AddChild(BeefaloBadge(commonBadgeConfig, {215 / 255, 165 / 255, 0 / 255, 1}, "status_hunger", nil, true))
    self.hungerBadge:SetPosition(self.badgeStartPosition + self.badgeWidth * 4, -130)
    self.hungerBadge:Hide()


    if self.healthBadge.bg ~= nil then
        self.config.rootPositionY = 18
    else
        if self.config.theme == "TheForge" then self.config.basePositionY = self.config.basePositionY + 4 end
    end

    self.config.rootPositionX = self.badgeWidth / 2 - (self.badgeGap * 2)

    self:Hide()
    self:SetScale(self.config.scale)
    self:SetPosition(self.config.basePositionX, self.config.basePositionY)
    self.root:SetPosition(self.config.rootPositionX, self.config.rootPositionYHidden)
end)


function BeefaloStatusBar:UpdateHealth(health)
    self.healthBadge:SetPercent(health / self.maxHealth, self.maxHealth)
end

function BeefaloStatusBar:UpdateDomestication (domestication, tendency)
    local displayValue = tonumber(string.format("%.1f", domestication))
    self.domesticationBadge:SetPercent(domestication / 100, 100, displayValue)
    if self.tendency ~= tendency then
        self.tendency = tendency
        self.domesticationBadge.anim:GetAnimState():SetMultColour(unpack(self.config.badgeColors[tendency]))
    end
end

function BeefaloStatusBar:UpdateObedience(obedience)
    self.obedienceBadge:SetPercent(obedience / 100, 100)
end

function BeefaloStatusBar:UpdateTimer()
    local timeLeft = math.floor(self.mountStartTime + self.buckDelay - GetTime())
    if timeLeft >= 0 then
        local seconds = timeLeft % 60
        local displayTime = math.floor(timeLeft / 60) .. ":" .. (seconds < 10 and "0" .. seconds or seconds)
        self.timerBadge:SetPercent(timeLeft / self.buckDelay, self.buckDelay, displayTime)
    end
end

function BeefaloStatusBar:StartTimer()
    if self.timerTask == nil and self.mounted then
        self:UpdateTimer()
        self.timerTask = self.owner:DoPeriodicTask(1, function () self:UpdateTimer() end)
    end
end

function BeefaloStatusBar:StopTimer()
    if self.timerTask ~= nil then
        self.timerTask:Cancel()
        self.timerTask = nil
    end
end

function BeefaloStatusBar:SetSaddle(saddleUses)
    local saddle = self.owner.replica.rider:GetSaddle()
    local image = saddle.replica.inventoryitem:GetImage()
    self.timerBadge:SetTooltip(saddle:GetDisplayName() .. "\n" .. (saddleUses > 1 and saddleUses .. " uses left" or "last use"))
    self.timerBadge.icon:SetTexture(GetInventoryItemAtlas(image), image)
end

function BeefaloStatusBar:UpdateHunger(hunger, initial)
    self.hungerBadge:SetPercent(hunger / self.maxHunger, self.maxHunger)
    if hunger == 0 and not initial then self:SetHungerVisibility(false) end
end

function BeefaloStatusBar:SetHungerVisibility(visible, transition)
    if self.hungerBadge.shown ~= visible then
        transition = transition or 0.4

        local rootPositionY = self.isHidden and self.config.rootPositionYHidden or self.config.rootPositionY
        self.config.rootPositionX = visible and 0 - self.badgeGap * 2 or self.badgeWidth / 2 - (self.badgeGap * 2)
        self.root:MoveTo(self.root:GetPosition(), {x = self.config.rootPositionX, y = rootPositionY, z = 0}, transition)

        local badgeTransition = transition == 0 and transition or transition / 1.5
        if visible then self.hungerBadge:Show() end
        self.hungerBadge:MoveTo(self.hungerBadge:GetPosition(), {x = self.badgeStartPosition + self.badgeWidth * 4, y = visible and 0 or -130, z = 0}, badgeTransition, function()
            if not visible then self.hungerBadge:Hide() end
        end)
    end
end

function BeefaloStatusBar:Activate(data)
    self.maxHealth = data.maxHealth
    self.maxHunger = data.maxHunger
    self.buckDelay = data.buckDelay
    self.mountStartTime = GetTime() 
    self.mounted = true

    self:UpdateHealth(data.health)
    self:UpdateDomestication(data.domestication, data.tendency)
    self:UpdateObedience(data.obedience)
    self:SetSaddle(data.saddleUses)
    self:UpdateHunger(data.hunger, true)
    self:SetHungerVisibility(data.hunger >= self.config.hungerThreshold and true or false, 0)

    if self.config.showByDefault then self:SlideIn() end
end

function BeefaloStatusBar:Deactivate()
    self.mounted = false
    if self:IsVisible() then self:SlideOut() end
end


function BeefaloStatusBar:SlideIn(transition)
    transition = transition or 0.5
    self.isHidden = false
    self:Show()
    self:StartTimer()
    self.root:CancelMoveTo()
    self.root:MoveTo(self.root:GetPosition(), {x = self.config.rootPositionX, y = self.config.rootPositionY, z = 0}, transition, function()
        if self.config.enableSounds then TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/craft_open") end
    end)
    self.root:ScaleTo(0.2, 1, transition)
end

function BeefaloStatusBar:SlideOut()
    self.isHidden = true
    self:StopTimer()
    self.root:CancelMoveTo()
    self.root:MoveTo(self.root:GetPosition(), {x = self.config.rootPositionX, y = self.config.rootPositionYHidden, z = 0}, 0.5, function() self:Hide() end)
    self.root:ScaleTo(1, 0.1, 0.5)

    if self.config.enableSounds then TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/craft_close") end
end

function BeefaloStatusBar:Reposition()
    local inventoryStateOffset = 0
    if Profile:GetIntegratedBackpack() or TheInput:ControllerAttached() then
        local backpack = self.owner.replica.inventory:GetOverflowContainer()
        if backpack and backpack:IsOpenedBy(self.owner) then inventoryStateOffset = 45 end
    end

    if self:IsVisible() then
        self:MoveTo(self:GetPosition(), {x = self.config.basePositionX, y = self.config.basePositionY + inventoryStateOffset, z = 0}, 0.15)
    else
        self:SetPosition(self.config.basePositionX, self.config.basePositionY + inventoryStateOffset)
    end
end

return BeefaloStatusBar