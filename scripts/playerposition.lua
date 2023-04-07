local HoverText = require("widgets/hovertext")
if not TUNING.PLAYERPOSITIONS then
    TUNING.PLAYERPOSITIONS = {
        MIN_DIST = .1,
        INTERVAL_MID = 1 / 5,
        INTERVAL_MIN = 1 / 20,
        COLOURSET = {{rgba(255, 255, 255, 1)}, {rgba(223, 63, 2, 1)}, {rgba(248, 215, 27, 1)}, {rgba(37, 223, 11, 1)},
                     {rgba(55, 236, 236, 1)}, {rgba(78, 99, 250, 1)}, {rgba(176, 64, 251, 1)}, {rgba(247, 55, 166, 1)},
                     {rgba(142, 152, 152, 1)}, {rgba(255, 165, 91, 1)}, {rgba(139, 79, 61, 1)}}
    }
end
local t = TUNING.PLAYERPOSITIONS
local function IsPointNear(x, y, x1, y1)
    return math.abs(x1 - x) + math.abs(y1 - y) < t.MIN_DIST
end
local PlayerPosition = {
    inst = nil,
    userid = "",
    name = "",
    text = nil,
    x = 0,
    y = 0,
    z = 0,
    screenx = 0,
    screeny = 0,
    cached_screenx = 0,
    cached_screeny = 0,
    dirty = false,
    interval = t.INTERVAL_MID,
    onrecalcfn = {},
    isvalid = function(self)
        return self.inst and self.inst.entity:IsValid()
    end,
    update = function(self)
        local x, y, z = self.inst.Transform:GetWorldPosition()
        self.x = x
        self.y = y
        self.z = z
    end,
    recalc = function(self)
        local x, y = thescreen.map2screen(thescreen.world2map(self.x, self.y, self.z))
        -- should be a function
        if x ~= 0 or y ~= 0 then
            self.screenx = x
            self.screeny = y
            self:onrecalc()
            if not IsPointNear(self.screenx, self.screeny, self.cached_screenx, self.cached_screeny) then
                self.dirty = true
            end
        end
    end,
    onrecalc = function(self)
        for i, v in ipairs(self.onrecalcfn) do
            v(self)
        end
    end,
    isnear = function(self, other)
        if not self:isvalid() then
            return true
        end
        if not other or not other:isvalid() then
            return true
        end
        return IsPointNear(self.screenx, self.screeny, other.screenx, other.screeny)
    end,
    initplayer = function(self)
        self:setname(self.inst.playername:value())
        if not self.text then
            self.text = HoverText() --#TODO: add it to a good place
        end
    end,
    track = function(self, inst)
        if self.inst == inst then
            -- the same as before, only check interval and name
            self:initplayer()
            return
        end
        if self.inst then
            self:untrack()
        end
        if inst and inst:IsValid() then
            self.inst = inst
            self:initplayer()
            self.removelistener = function()
                self:untrack()
            end
            inst:ListenForEvent("onremove", self.removelistener)
        end
    end,
    untrack = function(self)
        if self.removelistener then
            self.inst:RemoveEventCallback("onremove", self.removelistener)
            self.removelistener = nil
        end
        self.inst = nil
    end,
    refresh = function(self)
        if not self:isvalid() then
            return
        end
        self:update()
        self:recalc()
        if self.dirty then
            CONSOLE.mute(self.name, self.x, self.z, self.screenx, self.screeny)
            if self.text then
                self.text:UpdatePosition(self.screenx, self.screeny)
            end
            self.cached_screenx = self.screenx
            self.cached_screeny = self.screeny
            self.dirty = false
        end
    end,
    startupdating = function(self)
        if not self.task and self:isvalid() then
            self.task = self.inst:DoPeriodicTask(self.interval, function()
                self:refresh()
            end)
        end
    end,
    stopupdating = function(self)
        if self.task then
            self.task:Cancel()
            self.task = nil
        end
    end,
    setname = function(self, newname)
        self.name = newname or "???"
        -- check by name whether this is us
        if ThePlayer and (newname == ThePlayer.name or newname == ThePlayer:GetDisplayName()) then
            self.interval = t.INTERVAL_MIN
        end
        if self.text then
            local id = math.abs(hash(self.name)) % (#t.COLOURSET)
            self.text:SetColour(t.COLOURSET[id + 1])
        end
    end,
    offset = function(self)
        if not self:isvalid() then
            return
        end
        self:recalc()
        CONSOLE.mute(self.name, self.x, self.z, self.screenx, self.screeny)
        if self.text then
            self.text:UpdatePosition(self.screenx, self.screeny)
        end
        self.dirty = false
    end,
    disable = function(self)
        self:stopupdating()
        if self.text then
            self.text:Disable()
        end
    end,
    enable = function(self)
        self:startupdating()
        if self.text then
            self:refresh()
            self.text:Enable()
            self.text:SetString(self.name)
        end
    end,
    destroy = function(self)
        self:untrack()
        self:stopupdating()
        if self.text then
            self.text:Kill()
            self.text = nil
        end
    end
}
function CreatePlayer(inst)
    local player = {}
    setmetatable(player, {
        __index = PlayerPosition
    })
    player:track(inst)
    return player
end

