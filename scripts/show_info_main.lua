_G = _G or GLOBAL;
_M = _M or env;
_G.setmetatable(env, { __index = function(t, k)
    return _G.rawget(_G, k)
end })

CHAR = "teng_dst"
_G.CHAR = CHAR;
SHOW_INFO_NIL_STR = ""

TUNING.CAP_SHOW_INFO_BG = GetModConfigData("show_info_bg")
GLOBAL.daxmodjiaz = modimport;

table.insert(Assets, Asset("ATLAS", "images/text_teng_hoverer.xml"))
table.insert(Assets, Asset("IMAGE", "images/text_teng_hoverer.tex"))

modimport("scripts/hoverer_client.lua")
modimport("scripts/hoverer_all.lua")