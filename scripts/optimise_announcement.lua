local _G = GLOBAL;

if TUNING.OPTIMISE_ANNOUNCEMENT > 0 then
    _G.announceList = {}
    local net = GLOBAL.getmetatable(GLOBAL.TheNet)
    local oldAnnounce = GLOBAL.TheNet.Announce
    net.__index.Announce = function(Net, text, ...)
        local valid = true;
        local announceList = {}
        for k, v in ipairs(_G.announceList) do
            if _G.GetTime() - v.time < TUNING.OPTIMISE_ANNOUNCEMENT then
                table.insert(announceList, v)
            end
        end

        for k, v in ipairs(announceList) do
            if v.text == text then
                valid = false
            end
        end
        if valid then
            _G.announceList = announceList
            table.insert(_G.announceList, {
                time = _G.GetTime(),
                text = text,
            })
            SendModRPCToShard(SHARD_MOD_RPC["zy"]["announce"], text, _G.GetTime())
            return oldAnnounce(Net, text, ...)
        else
            _G.announceList = announceList
        end

    end

    AddShardModRPCHandler("zy", "announce", function(value, time)
        if value and type(value) == "string" then
            _G.announceList = _G.announceList or {};
            table.insert(_G.announceList, {
                time = time,
                text = value,
            })
        end
    end)
end
