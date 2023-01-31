local version = "20230116"
-- get rid of any GLOBAL. prefix
local GLOBAL = _G or GLOBAL
local env = GLOBAL and GLOBAL.getfenv and GLOBAL.getfenv() or GLOBAL or {}
if env == GLOBAL then
    -- disable strict mode so that there is no crash
    if GLOBAL.getmetatable then
        GLOBAL.getmetatable(GLOBAL).__index = function(t, k)
            return GLOBAL.rawget(t, k)
        end
    end
end
-- defined in utils.lua
if not table.has then
    table.has = table.contains
end
if not table.removev then
    table.removev = RemoveByValue
end
if not table.size then
    table.size = GetTableSize
end
local function GetKeyString(key)
    if type(key) == "table" then
        return tostring(key)
    end
    if type(key) == "userdata" then
        return "[c]" .. tostring(key)
    end
    if type(key) == "function" then
        return tostring(key)
    end
    return tostring(key)
end
local function GetTableString(t, current_depth, max_depth, indent, last_indent_string, blacklist)
    if not last_indent_string then
        last_indent_string = ""
    end
    local tail = last_indent_string
    for i = 1, indent do
        last_indent_string = last_indent_string .. "\t"
    end
    local head = "{\n"
    local str = ""
    if type(t) ~= "table" then
        return GetKeyString(t)
    end
    if current_depth >= max_depth then
        return "{...}"
    end
    str = ""
    for k, v in pairs(t) do
        if blacklist and table.has(blacklist, k) then
        elseif type(v) == "table" then
            str = str .. last_indent_string .. GetKeyString(k) .. "=" ..
                      GetTableString(v, current_depth + 1, max_depth, indent, last_indent_string, blacklist) .. "\n"
        else
            str = str .. last_indent_string .. GetKeyString(k) .. "=" .. GetKeyString(v) .. "\n"
        end
    end
    if str == "" then
        return "{}"
    end
    return head .. str .. tail .. "}"
end
if not table.tostring then
    table.tostring = function(t, indent, maxdepth, blacklist)
        if not indent then
            indent = 0
        end
        if not maxdepth then
            maxdepth = 5
        end
        return GetTableString(t, 0, maxdepth, indent, "", blacklist)
    end
end
function safeset(obj, key, val)
    if obj == GLOBAL then
        rawset(GLOBAL, key, val)
    elseif obj ~= nil then
        obj[key] = val
    end
end

function safeget(obj, key, val)
    local res = nil
    -- use rawget on GLOBAL
    if obj == GLOBAL then
        res = rawget(obj, key)
        if val ~= nil and type(obj) == "table" and res == nil and key ~= nil then
            rawset(obj, key, val)
            res = obj[key]
        end
    elseif obj ~= nil and type(obj) == "table" then
        res = obj[key]
        if res == nil then
            res = rawget(obj, key)
        end
        if val ~= nil and res == nil and key ~= nil then
            -- rawset(obj, key, val)
            obj[key] = val
            res = obj[key]
        end
    end
    return res
end

function safefetch(obj, key, ...)
    local res = nil
    -- use rawget on GLOBAL
    if obj == GLOBAL then
        res = rawget(obj, key)
    elseif obj ~= nil and type(obj) == "table" then
        res = obj[key]
        if res == nil then
            res = rawget(obj, key)
        end
    end
    if select("#", ...) > 0 then
        return safefetch(res, ...)
    else
        return res
    end
end
function undotted(text)
    return unpack(string.split(text, "."))
end
gettime = {
    real = function()
        return TheSim:GetRealTime()
    end,
    pertick = TheSim and TheSim:GetTickTime() or 1,
    tick = function()
        return TheSim:GetTick()
    end,
    time = function()
        return gettime.tick() * gettime.pertick
    end,
    timetable = function(time)
        local t = time or gettime.time()
        return {
            second = t % 60,
            minute = math.floor(t / 60) % 60,
            hour = math.floor(t / 3600) % 24
        }
    end,
    formatted = function(timetable, fmt)
        if not timetable then
            timetable = gettime.timetable()
        end
        return string.format(fmt or "[%02d:%02d:%02d]", timetable.hour, timetable.minute, timetable.second)
    end
}
RegisteredMods = safeget(GLOBAL, "RegisteredMods", {})
RegisteredEntry = safeget(GLOBAL, "RegisteredEntry", {})
-- support 2 levels
function RegisterMod(name, modulename)
    if not RegisteredMods[name] then
        if modulename then
            RegisteredMods[name] = {
                modulename = true
            }
        else
            RegisteredMods[name] = true
        end
        return false
    end
    if not modulename then
        return true
    end
    if type(RegisteredMods[name]) == "boolean" then
        RegisteredMods[name] = {}
    end
    if not RegisteredMods[name][modulename] then
        RegisteredMods[name][modulename] = true
        return false
    end
    return true
end
function RegisterEntry(name, tblorfn)
    if type(tblorfn) ~= "function" and type(tblorfn) ~= "table" then
        CONSOLE.err("RegisterEntry: entry is", tblorfn, "with name", name)
    end
    if RegisteredEntry[name] then
        CONSOLE.err("Duplicate Entry for mod", name)
        return
    end
    RegisteredEntry[name] = tblorfn
end

-- id
function GetKleiId()
    -- KU_xxxxxxxx
    return TheNet:GetUserID()
end
modutils = {
    workshopprefix = "workshop-",
    translate = function(name)
        local anothername = modutils.workshopprefix .. name
        if IsWorkshopMod(name) then
            anothername = string.sub(name, string.len(modutils.workshopprefix))
        end
        return anothername
    end,
    subscribe = function(name)
        return TheSim:SubscribeToMod(name)
    end,
    has = function(name)
        return KnownModIndex:GetModInfo(name) or KnownModIndex:GetModInfo(modutils.translate(name))
    end,
    enabled = function(name)
        return KnownModIndex:IsModEnabledAny(name) or KnownModIndex:IsModEnabled(modutils.translate(name))
    end
}
modutils.exists = modutils.has
local isworkshop = nil
function GetIsWorkshop()
    if isworkshop ~= nil then
        return isworkshop
    end
    local folder_name = safefetch(GLOBAL, "folder_name") or env.MODROOT or ""
    isworkshop = not not folder_name:find("workshop-")
    return isworkshop
end
function GetIsWegame()
    return not not (PLATFORM and type(PLATFORM) == "string" and string.gmatch(PLATFORM, "RAIL"))
end

-- console function
debugfile = nil
CONSOLE = {
    tag = function(type)
        return "[" .. type .. "]"
    end,
    prt = function(...)
        if CONSOLE.dumpping then
            CONSOLE.dump(...)
        end
        print(...)
        return CONSOLE
    end,
    log = function(...)
        CONSOLE.prt(CONSOLE.tag("log"), ...)
        return CONSOLE
    end,
    err = function(...)
        CONSOLE.prt(CONSOLE.tag("error"), ...)
        -- force print traceback information
        CONSOLE.trace(nil, 3)
        return CONSOLE
    end,
    warn = function(...)
        CONSOLE.prt(CONSOLE.tag("warning"), ...)
        return CONSOLE

    end,
    info = function(...)
        CONSOLE.prt(CONSOLE.tag("info"), ...)
        return CONSOLE

    end,
    tagged = function(tag, ...)
        CONSOLE.prt(CONSOLE.tag(tag), ...)
        return CONSOLE
    end,
    make = function(tag)
        return function(...)
            CONSOLE.tagged(tag, ...)
            return CONSOLE
        end
    end,
    mute = function(...)
        if CONSOLE.dumpping then
            CONSOLE.dump(...)
        end
        return CONSOLE
    end,
    enabledump = function(enable)
        if enable and not debugfile then
            debugfile = MakeFile(MODROOT .. "debug.txt")
            debugfile.lastdumped = -100
            debugfile.data = debugfile:read()
            debugfile:close()
            debugfile:open(MODROOT .. "debug.txt", "w")
            debugfile:write(debugfile.data)
        end
        CONSOLE.dumpping = not not enable
    end,
    cleardump = function()
        if not debugfile then
            debugfile = MakeFile(MODROOT .. "debug.txt")
        end
        debugfile:write("")
        debugfile:close()
    end,
    void = function()
    end,
    disableprint = function()
        CONSOLE.log = CONSOLE.void
        CONSOLE.info = CONSOLE.void
        CONSOLE.warn = CONSOLE.void
        CONSOLE.msg = CONSOLE.void
    end
}
CONSOLE.error = CONSOLE.err
CONSOLE.print = CONSOLE.prt
CONSOLE.msg = CONSOLE.info
-- timer, in javascript style
function SetTimeout(fn, t, ...)
    if t == nil then
        t = 0.02
    end
    local id = math.random()
    return scheduler:ExecutePeriodic(t, fn, 1, t, id, ...)
end
function SetInterval(fn, t, ...)
    return FullSetInterval(fn, t, nil, nil, nil, ...)
end
function FullSetInterval(fn, t, limit, delay, _id, ...)
    if t == nil then
        t = 100
    end
    local id = _id or math.random()
    return scheduler:ExecutePeriodic(t, fn, limit, delay or 0, id, ...)
end

function SetInstTimeout(inst, fn, t, ...)
    if t == nil then
        t = 0.02
    end
    return inst:DoTaskInTime(t, fn, ...)
end

function SetInstInterval(inst, fn, t, ...)
    if t == nil then
        t = 100
    end
    return inst:DoPeriodicTask(t, fn, ...)
end
function CreateDelay(fn, t)
    return function(...)
        timer.tick(fn, t, ...)
    end
end
function ClearTask(task)
    return task:Cancel()
end

-- shorthand
timer = {
    tick = SetTimeout,
    loop = SetInterval,
    itick = SetInstTimeout,
    iloop = SetInstInterval,
    clear = ClearTask,
    delay = SetTimeout,
    idelay = SetInstTimeout,
    delayed = CreateDelay
}

-- server/client detection
function IsServer()
    return TheNet:GetIsServer()
end

function IsClient()
    return TheNet:GetIsClient()
end

function IsDedicated()
    return TheNet:IsDedicated()
end
-- Hint: this means you host game and env is server, not necessarily without caves.
-- but is it?
function IsMain()
    return not IsDedicated() and IsServer()
end
function HasHUD()
    return IsClient() or not IsDedicated()
end

function IsInGame()
    return IsServer() or IsClient()
end

-- this one determines if world is loaded
IsReallyInGame = InGamePlay

-- check if the world is different from the Constant.
function specialGameModeDetector()
    local gameMode = TheNet:GetServerGameMode()
    local isForge = gameMode == "lavaarena"
    local isGorge = gameMode == "quagmire"
    if isForge then
        return "forge"
    elseif isGorge then
        return "gorge"
    else
        return "normal"
    end
end

function GetConfig(key, isClient, modname)
    -- remove annoying ch
    local ret = {}
    if type(key) == "table" then
        FilterArray(key, function(k)
            ret[k] = GetModConfigData(k, isClient)
        end)
        return ret
    end
    local ret = GetModConfigData(key, isClient)
    if key == "language" and ret == "ch" then
        ret = "zh"
    end
    return ret
end
function GetClientConfig(key)
    return GetConfig(key, true)
end

function MakeAsset(assettype, name, folder, format)
    assettype = string.upper(assettype)
    if not folder then
        folder = ""
        if assettype == "IMAGE" or assettype == "ATLAS" or assettype == "INV_IMAGE" or assettype == "ATLAS_BUILD" then
            folder = "images"
        elseif assettype == "PKGREF" or assettype == "DYNAMIC_ANIM" or assettype == "DYNAMIC_ATLAS" then
            folder = "anim/dynamic"
        elseif assettype == "SOUND" or assettype == "SOUNDPACKAGE" then
            folder = "sound"
        elseif assettype == "ANIM" then
            folder = "anim"
        end
    end
    if folder ~= "" and string.sub(folder, -1) ~= "/" then
        folder = folder .. "/"
    end
    if not format then
        format = nil
        if assettype == "SOUND" then
            format = "fsb"
        elseif assettype == "SOUNDPACKAGE" then
            format = "fev"
        elseif assettype == "ANIM" or assettype == "DYNAMIC_ANIM" then
            format = "zip"
        elseif assettype == "IMAGE" or assettype == "INV_IMAGE" then
            format = "tex"
        elseif assettype == "ATLAS" or assettype == "DYNAMIC_ATLAS" or assettype == "ATLAS_BUILD" then
            format = "xml"
        elseif assettype == "PKGREF" then
            format = "dyn"
        end
    end
    if format then
        if string.sub(name, -string.len(format) - 1) ~= "." .. format then
            name = name .. "." .. format
        end
    end
    return Asset(assettype, folder .. name, assettype == "ATLAS_BUILD" and 256 or nil)
end
function AddAsset(...)
    local a = MakeAsset(...)
    if a then
        table.insert(ASSETS, a)
    end
end
function MakeAssetTable(tbl)
    return MapDict(tbl, function(k, v)
        return MakeAsset(unpack(v))
    end)
end
function AddPrefab(prefab)
    table.insert(PrefabFiles, prefab)
end

function AddPrefabs(prefabs)
    for i, v in ipairs(prefabs) do
        table.insert(PrefabFiles, v)
    end
end

-- RemapSoundEvent Function
function ReSound(original, replacement)
    RemapSoundEvent(original, replacement)
end

-- modutils, some of them
utils = {
    prefab = AddPrefabPostInit,
    prefabs = function(prefabs)
        for i, v in ipairs(prefabs) do
            AddPrefabPostInit(v)
        end
    end,
    -- player = AddPlayerPostInit,
    -- from global positions mod
    _playerinits = {},
    _playeroninit = function(world, inst)
        if not inst then
            inst = world
        end
        for i, v in ipairs(utils._playerinits) do
            v[1](inst, unpack(v[2]))
        end
    end,
    player = function(fn, ...)
        local args = {fn, {...}}
        table.insert(utils._playerinits, args)
        if #utils._playerinits == 1 then
            if IsClient() then
                AddPlayerPostInit(utils._playeroninit)
            else
                AddPrefabPostInit("world", function(inst)
                    inst:ListenForEvent("ms_playerspawn", utils._playeroninit)
                end)
            end
        end
    end,
    theplayer = function(fn, ...)
        local param = {...}
        utils.player(function(p)
            if not ThePlayer then
                AddEventListener(p, "playeractivated", function()
                    fn(p, unpack(param))
                end)
                return
            end
            if p == ThePlayer then
                fn(p, unpack(param))
            end
        end)
    end,
    player_raw = AddPlayerPostInit,
    -- these two are very similar, just sim is before world post init
    sim = AddSimPostInit,
    game = AddGamePostInit,
    class = AddClassPostConstruct,
    sghandler = AddStategraphActionHandler,
    sgstate = AddStategraphState,
    sgevent = AddStategraphEvent,
    sg = AddStategraphPostInit,
    com = AddComponentPostInit,
    comreplica = AddReplicableComponent,
    comclass = function(name, fn)
        AddClassPostConstruct("components/" .. name, fn)
    end,
    prefabany = AddPrefabPostInitAny,
    recipeany = AddRecipePostInitAny,
    recipe = AddRecipePostInit,
    brain = AddBrainPostInit,
    resound = RemapSoundEvent,
    mod = function(mods)
        if type(mods) == "string" then
            mods = {mods}
        end
        for _, mod in ipairs(mods) do
            modimport(mod)
        end
    end
}
postinitutils = {
    prefab = function(name, fn)
        MapDict(GLOBAL.Ents or {}, function(_, inst)
            if VerifyInst(inst) then
                if inst.prefab == name then
                    fn(inst)
                end
            end
        end)
    end,
    tag = function(name, fn)
        MapDict(GLOBAL.Ents or {}, function(_, inst)
            if VerifyInst(inst) then
                if inst:HasTag(name) then
                    fn(inst)
                end
            end
        end)
    end,
    tags = function(names, fn)
        MapDict(GLOBAL.Ents or {}, function(_, inst)
            if VerifyInst(inst) then
                if inst:HasTags(names) then
                    fn(inst)
                end
            end
        end)
    end,
    theplayer = function(fn)
        if VerifyPlayer() then
            fn(ThePlayer)
        end
    end
}
-- create color for settint
function rgba(r, g, b, a)
    return r / 255, g / 255, b / 255, a
end

function wrapper(inst, name, fn)
    local oldfn = inst[name]
    if not oldfn then
        CONSOLE.err(CONSOLE.tag("wrapper"), ":before", name, "not found")
        return
    end
    inst[name] = function(...)
        fn(...)
        return oldfn(...)
    end
end

function wrapperAfter(inst, name, fn)
    local oldfn = inst[name]
    if not oldfn then
        CONSOLE.err(CONSOLE.tag("wrapper"), ":after", name, "not found")
        return
    end
    inst[name] = function(...)
        local ret = {oldfn(...)}
        fn(...)
        return unpack(ret)
    end
end

function wrapperSubstitute(inst, name, fn)
    local oldfn = inst[name]
    if not oldfn then
        CONSOLE.err(CONSOLE.tag("wrapper"), ":sub", name, "not found")
        return
    end
    inst[name] = function(...)
        local args = {...}
        local res = {oldfn(...)}
        return fn(args, res)
    end
end

function MakeWrapper(oldfn, fn)
    if not oldfn then
        return fn
    end
    if oldfn == fn then
        return oldfn
    end
    return function(...)
        fn(...)
        return oldfn(...)
    end
end

function MakeWrapperAfter(oldfn, fn)
    if not oldfn then
        return fn
    end
    if oldfn == fn then
        return fn
    end
    return function(...)
        local ret = {oldfn(...)}
        fn(...)
        return unpack(ret)
    end
end
function MakeWrapperSubstitute(oldfn, fn)
    if not oldfn then
        return fn
    end
    if oldfn == fn then
        return fn
    end
    return function(...)
        local args = {...}
        local res = {oldfn(...)}
        return fn(args, res)
    end
end

function exposeToGlobal(name, fn, override, force)
    if not force and GetIsWorkshop() then
        return
    end
    -- will fail because not declared
    if safeget(GLOBAL, name) ~= nil and not override then
        -- CONSOLE.err(CONSOLE.tag("exposeToConsole"), name, "already exists on GLOBAL scope")
        return
    end
    if type(name) == "table" then
        for i, v in pairs(name) do
            GLOBAL.rawset(GLOBAL, i, v)
        end
    else
        GLOBAL.rawset(GLOBAL, name, fn)
    end
end
-- get language
-- there are many ways to get language
function GetLanguageCode()
    local loc = env.locale or safeget(LOC.CurrentLocale, "code") or LanguageTranslator.defaultlang or ""
    local traditional = loc == "zht"
    -- replace wegame suffix
    if loc == "zhr" then
        loc = "zh"
    end
    return loc, traditional
end

function GetLanguageName()
    local lang = GetLanguageCode()
    local traditional = lang == "zht"
    local language = {
        en = "english",
        es = "spanish",
        ru = "russian",
        fr = "french",
        de = "german",
        it = "italian",
        ja = "japanese",
        ko = "korean",
        pt = "portuguese",
        pl = "polish",
        zh = "chinese",
        zhr = "chinese",
        zht = "chinese"
    }
    lang = language[lang] or lang
    return lang, traditional
end

function GetValue(obj, key)
    local up = 1
    local name, value = nil, nil
    while true do
        name, value = debug.getupvalue(obj, up)
        if not name then
            break
        elseif name == key then
            break
        else
            up = up + 1
        end
    end
    return name, value, up
end

function GetAllValue(obj)
    local up = 1
    local name, value = nil, nil
    local ret = {}
    while true do
        name, value = debug.getupvalue(obj, up)
        if not name then
            break
        else
            ret[name] = {
                value = value,
                up = up
            }
            up = up + 1
        end
    end
    return ret
end
function GetValueRecursive(obj, key, depth)
    local MAXDEPTH = 10
    if type(depth) ~= "number" then
        depth = 1
    end
    if depth > MAXDEPTH then
        CONSOLE.err("GetValueRecursive: reached max depth")
        return nil, nil, nil
    end
    -- print("[get]", obj, key)
    local up = 1
    local name, value = nil, nil
    local temp_name, temp_value, temp_up = nil, nil, nil
    local ret = nil
    while true do
        name, value = debug.getupvalue(obj, up)
        -- print("[upvalue]", name, value, up)
        if name == nil then
            break
        elseif name == key then
            ret = value
            break
        elseif type(value) == "function" then
            temp_name, temp_value, temp_up = GetValueRecursive(value, key, depth + 1)
            if temp_value then
                obj = temp_name
                ret = temp_value
                up = temp_up
                break
            end
        end
        up = up + 1
    end
    return obj, ret, up
end
function GetValueSuccessive(obj, ...)
    local names = {...}
    if #names == 0 then
        return nil, nil, nil
    end
    local up = 1
    local name, value = nil, obj
    for _, key in ipairs(names) do
        if type(value) ~= "function" then
            CONSOLE.err("Upvalue", obj, key, "terminated before", key)
        end
        obj = value
        name, value, up = GetValue(value, key)
        -- print("[upvalue]", name, value, up)
        if not name then
            CONSOLE.err("Upvalue", key, "not found in", obj)
            return nil, nil, nil
        end
    end
    return obj, value, up
end
-- end at nil, safe
function packstring(...)
    local n = select('#', ...)
    n = math.min(n, 10)
    local args = {...}
    local function safepack(args, n)
        local str = ""
        for i = 1, n do
            str = str .. tostring(args[i]) .. " "
        end
        return str
    end
    local success, str = pcall(safepack, args, n)
    if success and str then
        return str
    end
    print("error in packstring")
    return ""
end
-- concat all, unsafe
function catstring(...)
    local args = {...}
    local str = ""
    for k, v in pairs(args) do
        str = str .. tostring(v)
    end
    return str
end
UPVALUE = {
    get = function(obj, key)
        if type(obj) == "string" then
            obj = safeget(GLOBAL, obj)
        end
        if type(obj) ~= "function" then
            CONSOLE.err("UPVALUE.get:", obj, "is not a function")
            return nil, nil, nil
        end
        local upperfn, value, up = GetValueRecursive(obj, key)
        if value then
            return upperfn, value, up
        else
            CONSOLE.err(CONSOLE.tag("UPVALUE"), "key", key, "not found in", obj)
            return nil, nil, nil
        end
    end,
    fetch = function(obj, ...)
        if type(obj) == "string" then
            obj = safeget(GLOBAL, obj)
        end
        if type(obj) ~= "function" then
            CONSOLE.err("UPVALUE.fetch:", obj, "is not a function")
            return nil, nil, nil
        end
        local upperfn, value, up = GetValueSuccessive(obj, ...)
        if value then
            return upperfn, value, up
        else
            local keys = {...}
            CONSOLE.err(CONSOLE.tag("UPVALUE"), "key", keys[1], "not found", packstring(obj, ...))
            return nil, nil, nil
        end
    end,
    set = function(fn, up, value)
        if type(fn) ~= "function" then
            CONSOLE.err(CONSOLE.tag("UPVALUE"), "value", value, "is not a function")
        end
        debug.setupvalue(fn, up, value)
    end
}
--[[
    wtype:before|after|substitute|override
]]
function UpvalueWrapper(obj, key, newfn, wtype)
    local upperfn, oldfn, up = nil, nil, nil
    if type(key) == "string" then
        upperfn, oldfn, up = UPVALUE.get(obj, key)
    elseif type(key) == "table" and #key > 0 and type(key[1]) == "string" then
        upperfn, oldfn, up = UPVALUE.fetch(obj, unpack(key))
    end
    if not upperfn then
        return
    end
    if not wtype then
        wtype = "override"
    end
    if wtype == "before" then
        UPVALUE.set(upperfn, up, MakeWrapper(oldfn, newfn))
    elseif wtype == "after" then
        UPVALUE.set(upperfn, up, MakeWrapperAfter(oldfn, newfn))
    elseif wtype == "substitute" then
        UPVALUE.set(upperfn, up, MakeWrapperSubstitute(oldfn, newfn))
    elseif wtype == "override" then
        UPVALUE.set(upperfn, up, newfn)
    else
        CONSOLE.err(CONSOLE.tag("UPVALUE"), "wtype", wtype, "not supported")
    end
end

--[[
    level=0 debug.getinfo
          1 DBGPRINT
          2 the function that calls DBGPRINT, we begin at here
          3 stack[-1]
          ...
    fnname: you lose it via load/loadstring/pcall/xpcall and other C level functions because debug library doesn't try to get the symbol further than its current env
]]
function DBGPRINT(levelorfunction, ...)
    local level = levelorfunction
    local lua, c = "Lua", "C"
    local info = debug.getinfo(1)
    local cur = 2
    if type(levelorfunction) == "function" then
    else
        if (type(level) ~= "number") then
            level = tonumber(level)
        end
        if not level then
            level = 2
        elseif level < 2 then
            level = 2
        end
        repeat
            info = debug.getinfo(cur)
            local type = info.what
            if type ~= lua then
                cur = level + 2
            end
            cur = cur + 1
        until cur >= level
        if cur ~= level then
            return
        end
    end
    local ismod = "../mods/"
    info = debug.getinfo(level)
    local defaultvalue = ""
    local type = info.what
    if type ~= lua and type ~= c then
        type = "LuaBinary"
    end
    local filename = info.source or defaultvalue
    if string.find(filename, ismod) then
        filename = "[mod]" .. string.sub(filename, string.len(ismod))
    end
    local fnname = info.name or defaultvalue
    local line = info.currentline ~= -1 and info.currentline or info.linedefined
    local from, to = info.linedefined, info.lastlinedefined
    local range = ""
    if from and to then
        range = catstring("[", from, "-", to, "]")
    end
    local str = catstring(filename, ":", line, "\n", type, " Function ", fnname, range, "\n", ...)
    return str
end
function DBGTRACEBACK(level, fromlevel)
    local lua, c, bin = "Lua", "C", "Bin"
    local info = {}
    local cur = fromlevel or 2
    -- enough for traceback!
    if not level then
        level = 10
    end
    if (type(level) ~= "number") then
        level = tonumber(level)
    end
    if level < 2 then
        level = 2
    end
    local str = ""
    local defaultvalue = "???"
    local anonymous = "(anonymous)"
    local prev_filename = "???"
    local ismod = "../mods/"
    repeat
        info = debug.getinfo(cur)
        if not info then
            break
        end
        cur = cur + 1
        local ttype = info.what
        if ttype ~= lua and ttype ~= c then
            ttype = bin
        end
        local filename = info.source or defaultvalue
        if string.len(filename) > 60 then
            -- perhaps this is a chunk
            filename = string.sub(filename, 20) .. "..."
        end
        if string.sub(filename, 1, string.len(ismod)) == ismod then
            filename = "[mod]" .. string.sub(filename, string.len(ismod) + 1)
        end
        local from, to = info.linedefined, info.lastlinedefined
        local range = ""
        if from and to then
            range = catstring("[", from, "~", to, "]")
        end
        local display_filename = filename == prev_filename and "" or catstring(filename, ":", "\n")
        prev_filename = filename
        local fnname = info.name or anonymous
        local line = info.currentline ~= -1 and info.currentline or info.linedefined
        local display_line = line and (":" .. line) or ""
        local display_type = ""
        if ttype == c or ttype == bin then
            display_type = "[x]"
        end
        local str1 = catstring(display_filename, display_type, fnname, display_line, range, "\n")
        str = str .. str1
    until cur > level or ttype ~= lua
    return str
end
CONSOLE.dbg = function(l, m)
    CONSOLE.prt(DBGPRINT(l, m))
end
CONSOLE.debug = CONSOLE.dbg
CONSOLE.traceback = function(l, t)
    if not l then
        l = 10
    end
    if not t then
        t = 2
    end
    CONSOLE.prt(DBGTRACEBACK(l + 1, t + 1))
end
CONSOLE.trace = CONSOLE.traceback
function SequentialSearch(array, val)
    for i = 1, #array do
        if val == array[i] then
            return i
        end
    end
    return -1
end

function BinarySearch(array, val)
    local low = 1
    local high = #array
    while low <= high do
        local mid = math.floor((low + high) / 2)
        if array[mid] == val then
            return mid
        elseif array[mid] < val then
            low = mid + 1
        else
            high = mid - 1
        end
    end
    return -1
end

function FilterArray(array, filter)
    if type(array) ~= "table" then
        CONSOLE.err(array, "is not an array")
        return {}
    end
    local ret = {}
    for i, v in ipairs(array) do
        if filter(v) then
            table.insert(ret, v)
        end
    end
    return ret
end
if not table.filter then
    table.filter = FilterArray
end
table.ifilter = FilterArray

function MapDict(dict, mapfn)
    if type(dict) ~= "table" then
        CONSOLE.err(dict, "is not a dict")
        return {}
    end
    local ret = {}
    for k, v in pairs(dict) do
        ret[k] = mapfn(k, v)
    end
    return ret
end
if not table.mapp then
    table.mapp = MapDict
end

local function Merge(array, low, mid, high)
    local array3 = {}
    local i, j, k = low, mid + 1, low
    repeat
        if array[i] > array[j] then
            table.insert(array3, array[j])
            j = j + 1
        else
            table.insert(array3, array[i])
            i = i + 1
        end
    until i > mid or j > high
    if i < mid then
        repeat
            table.insert(array3, array[i])
            i = i + 1
        until i > mid
    elseif j < high then
        repeat
            table.insert(array3, array[j])
            j = j + 1
        until j > high
    end
    repeat
        array[k] = array3[k - low + 1]
        k = k + 1
    until k > high
end

local function SortArray(array, low, high)
    if low >= high then
        return
    end
    if low + 1 == high then
        if array[low] > array[high] then
            array[low], array[high] = array[high], array[low]
        end
        return
    end
    local mid = math.floor((low + high) / 2)
    SortArray(array, low, mid)
    SortArray(array, mid + 1, high)
    Merge(array, 1, mid, #array)
end

function _MergeSort(array)
    SortArray(array, 1, #array)
end

function VerifyPlayer()
    local player = safeget(GLOBAL, "ThePlayer")
    if not player then
        return false
    end
    if not player.entity:IsValid() then
        return false
    end
    return true
end

function VerifyInst(inst)
    return inst and inst.entity and inst.entity:IsValid()
end
function IsInteractive(inst)
    return VerifyInst(inst) and not inst:HasTag("INLIMBO")
end

_File = {
    open = function(self, name, op, trytimes)
        if trytimes == nil then
            trytimes = 1
        end
        if trytimes > 3 then
            return self
        end
        local function func()
            local myfile = io.open(name, op)
            if not myfile then
                return nil
            end
            self.file = myfile
            return myfile
        end

        self.name = name
        local flag, data = pcall(func)
        if not (flag and data) then
            CONSOLE.err("open file", name, "failed")
            self:write("")
            self:close()
            self:open(name, op, trytimes + 1)
        end
        return self
    end,
    writestr = function(self, ...)
        local str = packstring(...)
        self:write(str)
        return self
    end,
    write = function(self, data)
        if not self.file then
            self:open(self.name, "w")
        end
        if not self.file then
            return
        end
        if data then
            self.data = self.data .. data
        end
        self.file:write(data)
        self:tryclose()
        return self
    end,
    read = function(self, name)
        if not self.file then
            self:open(name, "r")
        end
        local function func()
            local data = self.file:read("*a")
            self:tryclose()
            return data
        end

        local flag, data = pcall(func)
        if not (flag and data) then
            CONSOLE.err("read data error")
            data = nil
        end
        return data
    end,
    tryclose = function(self)
        if not self.persist then
            self:close()
        end
        return self
    end,
    close = function(self)
        if self.file then
            self.file:close()
            self.file = nil
        end
        return self
    end,
    append = function(self, str)
        self.data = self.data .. str
        return self
    end
}
--[[
    op=r|w|a|r+|w+|a+,b
    unfortunately, a are not supported
]]
function MakeFile(name, op)
    local f = {
        file = nil,
        name = name,
        data = ""
    }
    setmetatable(f, {
        __index = _File
    })
    if name then
        f.persist = true
        f:open(name, op or "r")
    end
    return f
end

CONSOLE.dump = function(...)
    local t = gettime.time()
    local header = ""
    if t - debugfile.lastdumped > 1 then
        header = gettime.formatted()
    end
    if debugfile.lastdumped < 0 then
        debugfile:write("------------------------------------\n")
    end
    debugfile.lastdumped = t
    local str = header .. packstring(...) .. "\n"
    debugfile:writestr(str)
end

function EXPOSE(name, fname)
    if not fname then
        fname = name
    end
    local fn = safeget(env, fname)
    if not fn then
        return
    end
    exposeToGlobal(name, fn, false, true)
end

function FormatString(str, ...)
    if type(str) == "table" then
        str = str[math.random(#str) + 1]
    end
    if not str then
        return ""
    end
    if select("#", ...) > 0 then
        str = string.format(str, ...)
    end
    return str
end

function SendModRPC(name, fnname, ...)
    return SendModRPCToServer(GetModRPC(name or modname, fnname or ""), ...)
end
-- wrap an array so that it looks as if all elements can be seen as a total one.
-- note that it don't support number keys
-- also if the first param passed is the array, the interpretation is that it is a class function
-- array.fn(...) array:fn(...) array[key]=value
-- but do not expect return value
function MakeBroadcast(tbl)
    if not tbl then
        tbl = {}
    end
    setmetatable(tbl, {
        __index = function(t, k)
            -- do not intefere with array
            if type(k) == "number" then
                return nil
            elseif type(k) == "nil" then
                return nil
            end
            local ret = {}
            setmetatable(ret, {
                __call = function(t, self, ...)
                    if self == tbl then
                        self = nil
                    end
                    for i, v in ipairs(tbl) do
                        if v[k] then
                            v[k](self or v, ...)
                        end
                    end
                end
            })
            return ret
        end,
        __newindex = function(t, k, v)
            if type(k) == "number" then
                return rawset(tbl, k, v)
            elseif type(k) == "nil" then
                CONSOLE.err("attempt to assign nil to array")
                return
            end
            for i, v in ipairs(tbl) do
                v[k] = v
            end
            return v
        end
    })
    return tbl
end
function MakeNamed(tbl, name)
    return function(...)
        return tbl[name](...)
    end
end
function InheritClass(tbl, metatbl)
    setmetatable(tbl, {
        __index = metatbl
    })
end
-- prevent from Prefabs being replaced by ModWrangler
ThePrefab = GLOBAL.Prefabs
local GLOBALVARIABLES = {"RegisteredMods", "RegisteredEntry"}
FilterArray(GLOBALVARIABLES, function(v)
    EXPOSE(v)
end)
RegisterMod("apis", version)
