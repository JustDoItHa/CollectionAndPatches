local require = GLOBAL.require
local time_phase= GetModConfigData("time_sync_with_master")
local function RetrieveLastEventListener(source, event, inst)
    local temp
    for i, v in ipairs(source.event_listeners[event][inst]) do
        temp = v
    end
    return temp
end

local function getval(fn, path)
    local val = fn
    for entry in path:gmatch("[^%.]+") do
        local i = 1
        while true do
            local name, value = GLOBAL.debug.getupvalue(val, i)
            if name == entry then
                val = value
                break
            elseif name == nil then
                return
            end
            i = i + 1
        end
    end
    return val
end

local function setval(fn, path, new)
    local val = fn
    local prev = nil
    local i
    for entry in path:gmatch("[^%.]+") do
        i = 1
        prev = val
        while true do
            local name, value = GLOBAL.debug.getupvalue(val, i)
            if name == entry then
                val = value
                break
            elseif name == nil then
                return
            end
            i = i + 1
        end
    end
    GLOBAL.debug.setupvalue(prev, i, new)
end

local function isslave()
    return GLOBAL.TheWorld.ismastersim and not GLOBAL.TheWorld.ismastershard
end

local function ClockConverter(self)
    local world = GLOBAL.TheWorld
    if isslave() then
        local _segs = getval(self.OnUpdate, "_segs")
        local OldOnClockUpdate = RetrieveLastEventListener(world, "secondary_clockupdate", self.inst)
        self.inst:RemoveEventCallback("secondary_clockupdate", OldOnClockUpdate, world)

        local function OnClockUpdate(src, data)
            if time_phase then
                OldOnClockUpdate(src, data)
            end
            --以前的写法
            --local totalsegs = 0
            --local remainsegs = 0
            --
            --for i, v in ipairs(data.segs) do
            --    if i < data.phase then
            --        totalsegs = totalsegs + v
            --    end
            --end
            --totalsegs = totalsegs + (data.totaltimeinphase - data.remainingtimeinphase) / TUNING.SEG_TIME
            --print(totalsegs)
            --for i, v in ipairs(_segs) do
            --    data.segs[i] = v:value()
            --    totalsegs = totalsegs - v:value()
            --    if totalsegs < 0 then
            --        data.phase = i
            --        remainsegs = -totalsegs
            --    end
            --end
            --
            --data.totaltimeinphase = _segs[data.phase]:value() * TUNING.SEG_TIME
            --data.remainingtimeinphase = remainsegs * TUNING.SEG_TIME
            --OldOnClockUpdate(src, data)
        end
        self.inst:ListenForEvent("secondary_clockupdate", OnClockUpdate, world)
        setval(self.OnUpdate, "_ismastershard", true)
    end
end
AddComponentPostInit("clock", ClockConverter)

local function SeasonsConverter(self)
    local world = GLOBAL.TheWorld
    if isslave() then
        local PushSeasonClockSegs = getval(self.OnLoad, "PushSeasonClockSegs")
        setval(PushSeasonClockSegs, "_ismastershard", true)

        local DEFAULT_CLOCK_SEGS = getval(self.OnLoad, "DEFAULT_CLOCK_SEGS")
        local SEASON_NAMES = getval(self.OnLoad, "SEASON_NAMES")
        local _segs = getval(self.OnLoad, "_segs")

        local function OnSetSeasonClockSegs(src, segs)
            print("OnSetSeasonClockSegs")
            local default = nil
            for k, v in pairs(segs) do
                default = v
                break
            end

            if default == nil then
                if segs ~= DEFAULT_CLOCK_SEGS then
                    OnSetSeasonClockSegs(DEFAULT_CLOCK_SEGS)
                end
                return
            end

            for i, v in ipairs(SEASON_NAMES) do
                _segs[i] = segs[v] or default
            end

            PushSeasonClockSegs()
        end

        local function OnSetSeasonSegModifier(src, mod)
            print("OnSetSeasonSegModifier")
            setval(PushSeasonClockSegs, "_segmod", mod)
            PushSeasonClockSegs()
        end

        self.inst:ListenForEvent("ms_setseasonclocksegs", OnSetSeasonClockSegs, world)
        self.inst:ListenForEvent("ms_setseasonsegmodifier", OnSetSeasonSegModifier, world)

        local OnSeasonDirty = RetrieveLastEventListener(self.inst, "seasondirty", self.inst)
        local OnLengthsDirty = RetrieveLastEventListener(self.inst, "lengthsdirty", self.inst)
        setval(OnSeasonDirty, "PushMasterSeasonData", function()
        end)
        setval(OnLengthsDirty, "PushMasterSeasonData", function()
        end)

        local OnSeasonsUpdate = RetrieveLastEventListener(world, "secondary_seasonsupdate", self.inst)
        self.inst:RemoveEventCallback("secondary_seasonsupdate", OnSeasonsUpdate, world)
    end
end
AddComponentPostInit("seasons", SeasonsConverter)