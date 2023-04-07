GLOBAL.setmetatable(
        env,
        {
            __index = function(t, k)
                return GLOBAL.rawget(GLOBAL, k)
            end
        }
)

local _G = GLOBAL

--如果是管理员，则不执行本mod
if GetModConfigData("cheat_admin_for_character") then
    if _G.TheNet and _G.TheNet:GetIsServer() then
        return
    end
    if _G.TheNet and (_G.TheNet:GetIsClient() and _G.TheNet:GetIsServerAdmin()) then
        return
    end

    --if not(_G.TheNet and ((_G.TheNet:GetIsServer() and _G.TheNet:GetServerIsDedicated()) or (_G.TheNet:GetIsClient() and not _G.TheNet:GetIsServerAdmin()))) then
    --    return
    --end
end

--总
local MODLIST = {}
--禁用角色组
local NOTMODCHARA = {}

for k, character in pairs(_G.MODCHARACTERLIST) do
    --遍历角色列表
    print("MOD人物组:", character)
    table.insert(MODLIST, character)
end

--循环总MOD人物组，插入需要禁用的MOD人物
for i, v in ipairs(MODLIST) do
    if GetModConfigData(v) ~= nil and GetModConfigData(v) then
        print("MOD人物禁用:", v)
        table.insert(NOTMODCHARA, v)
    end
end

--自定义角色禁用循环
for i, v in pairs(NOTMODCHARA) do
    --遍历要移除的角色列表
    for k, character in pairs(_G.MODCHARACTERLIST) do
        --遍历角色列表
        if character == v then
            table.remove(_G.MODCHARACTERLIST, k) --移除角色
            break
        end
    end
end
local m_list = _G.MODCHARACTERLIST
local m_list_num = #m_list
local d_list_num = 18
local allclosure = GetModConfigData("allclosure")
if allclosure == true then
    if m_list_num > 0 then
        RemoveDefaultCharacter("wilson")
        RemoveDefaultCharacter("willow")
        RemoveDefaultCharacter("wolfgang")
        RemoveDefaultCharacter("wendy")
        RemoveDefaultCharacter("wx78")
        RemoveDefaultCharacter("wickerbottom")
        RemoveDefaultCharacter("woodie")
        RemoveDefaultCharacter("wes")
        RemoveDefaultCharacter("waxwell")
        RemoveDefaultCharacter("wathgrithr")
        RemoveDefaultCharacter("webber")
        RemoveDefaultCharacter("winona")
        RemoveDefaultCharacter("warly")
        RemoveDefaultCharacter("wortox")
        RemoveDefaultCharacter("wormwood")
        RemoveDefaultCharacter("wurt")
        RemoveDefaultCharacter("walter")
        RemoveDefaultCharacter("wanda")
        d_list_num = 1
    else
        RemoveDefaultCharacter("willow")
        RemoveDefaultCharacter("wolfgang")
        RemoveDefaultCharacter("wendy")
        RemoveDefaultCharacter("wx78")
        RemoveDefaultCharacter("wickerbottom")
        RemoveDefaultCharacter("woodie")
        RemoveDefaultCharacter("wes")
        RemoveDefaultCharacter("waxwell")
        RemoveDefaultCharacter("wathgrithr")
        RemoveDefaultCharacter("webber")
        RemoveDefaultCharacter("winona")
        RemoveDefaultCharacter("warly")
        RemoveDefaultCharacter("wortox")
        RemoveDefaultCharacter("wormwood")
        RemoveDefaultCharacter("wurt")
        RemoveDefaultCharacter("walter")
        RemoveDefaultCharacter("wanda")
        d_list_num = 0
    end
end

local c_num_choose = m_list_num + d_list_num

--威尔逊放最后 无人物可选时候选威尔逊
--local wilsonclosure = GetModConfigData("wilson")
--if wilsonclosure == true and c_num_choose > 1 then
--    RemoveDefaultCharacter("wilson")
--end

local willowclosure = GetModConfigData("willow")
if allclosure == false and willowclosure == true and c_num_choose > 1 then
    c_num_choose = c_num_choose - 1
    RemoveDefaultCharacter("willow")
end

local wolfgangclosure = GetModConfigData("wolfgang")
if allclosure == false and wolfgangclosure == true and c_num_choose > 1 then
    c_num_choose = c_num_choose - 1
    RemoveDefaultCharacter("wolfgang")
end

local wendyclosure = GetModConfigData("wendy")
if allclosure == false and wendyclosure == true and c_num_choose > 1 then
    c_num_choose = c_num_choose - 1
    RemoveDefaultCharacter("wendy")
end

local wx78closure = GetModConfigData("wx78")
if allclosure == false and wx78closure == true and c_num_choose > 1 then
    c_num_choose = c_num_choose - 1
    RemoveDefaultCharacter("wx78")
end

local wickerbottomclosure = GetModConfigData("wickerbottom")
if allclosure == false and wickerbottomclosure == true and c_num_choose > 1 then
    c_num_choose = c_num_choose - 1
    RemoveDefaultCharacter("wickerbottom")
end

local woodieclosure = GetModConfigData("woodie")
if allclosure == false and woodieclosure == true and c_num_choose > 1 then
    c_num_choose = c_num_choose - 1
    RemoveDefaultCharacter("woodie")
end

local wesclosure = GetModConfigData("wes")
if allclosure == false and wesclosure == true and c_num_choose > 1 then
    c_num_choose = c_num_choose - 1
    RemoveDefaultCharacter("wes")
end

local waxwellclosure = GetModConfigData("waxwell")
if allclosure == false and waxwellclosure == true and c_num_choose > 1 then
    c_num_choose = c_num_choose - 1
    RemoveDefaultCharacter("waxwell")
end

local wathgrithrclosure = GetModConfigData("wathgrithr")
if allclosure == false and wathgrithrclosure == true and c_num_choose > 1 then
    c_num_choose = c_num_choose - 1
    RemoveDefaultCharacter("wathgrithr")
end

local webberclosure = GetModConfigData("webber")
if allclosure == false and webberclosure == true and c_num_choose > 1 then
    c_num_choose = c_num_choose - 1
    RemoveDefaultCharacter("webber")
end

local winonaclosure = GetModConfigData("winona")
if allclosure == false and winonaclosure == true and c_num_choose > 1 then
    c_num_choose = c_num_choose - 1
    RemoveDefaultCharacter("winona")
end

local warlyclosure = GetModConfigData("warly")
if allclosure == false and warlyclosure == true and c_num_choose > 1 then
    c_num_choose = c_num_choose - 1
    RemoveDefaultCharacter("warly")
end

local wortoxclosure = GetModConfigData("wortox")
if allclosure == false and wortoxclosure == true and c_num_choose > 1 then
    c_num_choose = c_num_choose - 1
    RemoveDefaultCharacter("wortox")
end

local wormwoodclosure = GetModConfigData("wormwood")
if allclosure == false and wormwoodclosure == true and c_num_choose > 1 then
    c_num_choose = c_num_choose - 1
    RemoveDefaultCharacter("wormwood")
end

local wurtclosure = GetModConfigData("wurt")
if allclosure == false and wurtclosure == true and c_num_choose > 1 then
    c_num_choose = c_num_choose - 1
    RemoveDefaultCharacter("wurt")
end

local walterclosure = GetModConfigData("walter")
if allclosure == false and walterclosure == true and c_num_choose > 1 then
    c_num_choose = c_num_choose - 1
    RemoveDefaultCharacter("walter")
end

local wandaclosure = GetModConfigData("wanda")
if allclosure == false and wandaclosure == true and c_num_choose > 1 then
    c_num_choose = c_num_choose - 1
    RemoveDefaultCharacter("wanda")
end
local wilsonclosure = GetModConfigData("wilson")
if allclosure == false and wilsonclosure == true and c_num_choose > 1 then
    c_num_choose = c_num_choose - 1
    RemoveDefaultCharacter("wilson")
end
