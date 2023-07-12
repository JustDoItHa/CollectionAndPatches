mode = TUNING.SORAMODE
local expneed = {}
local expdead = {}
local maxlevel = 100

local function exptolev(a)
    for i = maxlevel, 1, -1 do
        if a >= expneed[i] then
            return i
        end
    end
    return 0
end

local function expfornextlev(a)
    if a >= 100 then
        return 0
    elseif a < 1 then
        return expneed[1]
    else
        return expneed[a + 1]
    end
end

local function expper(exp)
    local level = exptolev(exp)
    if level > 99 then
        return 100
    end
    local has = exp - (expneed[level] or 0)
    local next = expneed[level + 1] - (expneed[level] or 0)
    local per = math.floor(has / next * 20) * 5
    return per
end

local function DeathExp(a)
    if a < 1 then
        return expdead[1]
    elseif a >= 100 then
        return expdead[100]
    else
        return expdead[a]
    end
end
local function ListExp()
    local a = ""
    local b = ""
    for i = 1, 100, 1 do
        a = a .. i .. "=" .. expneed[i] .. ","
        b = b .. i .. "=" .. expdead[i] .. ","
    end
end
if mode == 1 then
    -- 1-10级 经验 = 300 * 等级  
    -- 11-20级 经验  = 3000+500*等级
    -- 21-30级 经验 = 1000*等级
    for i = 1, 10, 1 do
        expneed[i] = 300 * i
        expdead[i] = 0
    end
    for i = 11, 20, 1 do
        expneed[i] = 500 * i - 2000
        expdead[i] = -100
    end
    for i = 21, 30, 1 do
        expneed[i] = 1000 * i - 12000
        expdead[i] = -500
    end

    --
    for i = 31, 100, 1 do
        expneed[i] = 1000 * i - 12000
        expdead[i] = -800
    end

elseif mode == 2 then
    for i = 1, 10, 1 do
        expneed[i] = 500 * i
        expdead[i] = i > 1 and -200 or 0
    end
    for i = 11, 20, 1 do
        expneed[i] = 1500 * i - 10000
        expdead[i] = -500
    end
    for i = 21, 30, 1 do
        expneed[i] = 3000 * i - 40000
        expdead[i] = -3000
    end

    --
    for i = 31, 100, 1 do
        expneed[i] = 3000 * i - 40000
        expdead[i] = -5000
    end
elseif mode == 3 then
    for i = 1, 10, 1 do
        expneed[i] = 1000 * i
        expdead[i] = -2000
    end
    for i = 11, 20, 1 do
        expneed[i] = 3000 * i - 20000
        expdead[i] = -5000
    end
    for i = 21, 30, 1 do
        expneed[i] = 6000 * i - 80000
        expdead[i] = -10000
    end
    --
    for i = 31, 100, 1 do
        expneed[i] = 6000 * i - 80000
        expdead[i] = -15000
    end
end

-- ListExp()
-- exptolev(5000)
-- expfornextlev(10)
-- DeathExp(10)
-- exptolev(20000)
-- expfornextlev(15)
-- DeathExp(15)
-- exptolev(50000)
-- expfornextlev(20)
-- DeathExp(20)
return {
    exptolev = exptolev,
    expfornextlev = expfornextlev,
    expper = expper,
    DeathExp = DeathExp,
    ListExp = ListExp

}
