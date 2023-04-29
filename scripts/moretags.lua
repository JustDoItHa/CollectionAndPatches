--风铃，小穹，开放级code
--[[
授权级别:开放级
Copyright 2022 [FL]。此产品仅授权在 Steam 和WeGame平台指定账户下，
Steam平台：MySora 模组ID：workshop-1638724235
WeGame平台: 穹の空 模组ID：workshop-2199027653598519351
禁止一切搬运！二次发布！自用！尤其是自用!
禁止一切搬运！二次发布！自用！尤其是自用!
禁止一切搬运！二次发布！自用！尤其是自用!

基于本mod的patch包 补丁包等 在以下情况下被允许：
1，原则上允许patch和补丁，但是请最好和我打声招呼。
2, patch包 补丁包浏览权限 请优先选择成“不公开” 或者 “仅好友可见”
3，禁止修改经验、进食、皮肤、热更相关内容。
4，本人保留要求相关patch、补丁包下架和做出反制的权利 。
5，之后会有详细的说明放置于mod根目录下的 ReadMe.txt文件，会提供更详细的说明和示例。


声明：本MOD所有内容不用于盈利，且拒绝接受捐赠、红包等行为。

对moder:
授权声明：
1,本mod内源码会严格分为'参考级'和'开放级',我会在源码内标明。
其中'参考级'允许作为参考,可以按照我的思路自行编写其他逻辑,但是禁止直接复制粘贴.
'开放级'允许直接复制粘贴后使用,并允许根据自己的需要进行修改,
但是我期望尽量减少修改以保证兼容和后续更新带来的麻烦,如果有功能改动可以和我沟通进行合并。
未标明的文件，默认授权级别为'参考级'。
2,本mod内贴图、动画相关文件禁止挪用,毕竟这是我自己花钱买的.
3,严禁直接修改本mod内文件后二次发布。
4,从本mod内提前的源码请保留版权信息,并且禁止加密、混淆。
]]
-- local Tags = {}
-- local key = modname .. "fixtag" -- 默认用modname 做key 防止冲突

-- function RegTag(tag) -- 必须先注册 主客机一起注册 注册后的tag会被截留
--     Tags[tag] = string.lower(tag)
-- end

-- local function AddTag(inst, stag, ...)
--     if not inst or not stag then return end
--     tag = string.lower(stag)
--     if Tags[tag] then
--         if inst[key].Tags and inst[key].Tags[tag] then
--             inst[key].Tags[tag]:set_local(false)
--             inst[key].Tags[tag]:set(true)
--         end
--     else
--         return inst[key].AddTag(inst, stag, ...)
--     end
-- end

-- local function RemoveTag(inst, stag, ...)
--     if not inst or not stag then return end
--     tag = string.lower(stag)
--     if Tags[tag] then
--         if inst[key].Tags and inst[key].Tags[tag] then
--             inst[key].Tags[tag]:set_local(true)
--             inst[key].Tags[tag]:set(false)
--         end
--     else
--         return inst[key].RemoveTag(inst, stag, ...)
--     end
-- end

-- local function HasTag(inst, stag, ...)
--     if not inst or not stag then return end
--     tag = string.lower(stag)
--     if Tags[tag] and inst[key].Tags and inst[key].Tags[tag] then
--         return inst[key].Tags[tag]:value()
--     else
--         return inst[key].HasTag(inst, stag, ...)
--     end
-- end

-- function FixTag(inst) -- 传入实体 主客机一起调用
--     inst[key] = {
--         AddTag = inst.AddTag,
--         HasTag = inst.HasTag,
--         RemoveTag = inst.RemoveTag,
--         Tags = {}
--     }
--     inst.AddTag = AddTag
--     inst.HasTag = HasTag
--     inst.RemoveTag = RemoveTag
--     for k, v in pairs(Tags) do
--         inst[key].Tags[k] = net_bool(inst.GUID, key .. "." .. k, GUID,
--                                      key .. "." .. k .. "dirty")
--         if inst[key].HasTag(inst, k) then
--             inst[key].RemoveTag(inst, k)
--             inst[key].Tags[k]:set_local(false)
--             inst[key].Tags[k]:set(true)
--         else
--             inst[key].Tags[k]:set(false)
--         end
--     end

-- end

-- AddPlayerPostInit(function(inst) -- 默认只扩展人物的
--     FixTag(inst)
-- end)

-- return {
    -- RegTag = RegTag, -- 用于注册tag   --需要主客机一起调用 注册后的tag会被截留
    -- FixTag = FixTag -- 用来扩展实体的tag槽位
-- }


local tagslist = {
    -- MakePlayerCharacter
    ["player"] = true,
    ["scarytoprey"] = true,
    ["character"] = true,
    ["lightningtarget"] = true,
    [UPGRADETYPES.WATERPLANT.."_upgradeuser"] = true,
    [UPGRADETYPES.MAST.."_upgradeuser"] = true,
    ["usesvegetarianequipment"] = true,

    ["trader"] = true,
    --debuffable (from debuffable component, added to pristine state for optimization
    ["debuffable"] = true,
    -- stageacotr (from stageactor component, added to pristine state for optimization
    ["stageactor"] = true,
    --Sneak these into pristine state for optimization
    ["_health"] = true,
    ["_hunger"] = true,
    ["_sanity"] = true,
    ["_builder"] = true,
    ["_combat"] = true,
    ["_moisture"] = true,
    ["_sheltered"] = true,
    ["_rider"] = true,
    -- wx78
    ["electricdamageimmune"] = true,
    --electricdamageimmune is for combat and not lightning strikes
    --also used in stategraph for not stomping custom light values
    
    ["batteryuser"] = true,          -- from batteryuser component
    ["chessfriend"] = true,
    ["HASHEATER"] = true,            -- from heater component
    ["soulless"] = true,
    ["upgrademoduleowner"] = true,   -- from upgrademoduleowner component
    -- wurt
    ["playermerm"] = true,
    ["merm"] = true,
    ["mermguard"] = true,
    ["mermfluent"] = true,
    ["merm_builder"] = true,
    ["wet"] = true,
    ["stronggrip"] = true,
    -- wortox
    ["playermonster"] = true,
    ["monster"] = true,
    ["soulstealer"] = true,

    ["souleater"] = true,
    -- walter
    ["expertchef"] = true,
    ["pebblemaker"] = true,
    ["pinetreepioneer"] = true,
    ["allergictobees"] = true,
    ["slingshot_sharpshooter"] = true,
    ["efficient_sleeper"] = true,
    ["dogrider"] = true,
    ["nowormholesanityloss"] = true,
    ["storyteller"] = true, -- for storyteller component
        ["quagmire_shopper"] = true,
    -- wanda
    ["clockmaker"] = true,
    ["pocketwatchcaster"] = true,
    ["health_as_oldage"] = true,
    ["slowbuilder"] = true,
    -- warly
    ["masterchef"] = true,
    ["professionalchef"] = true,
    -- wathgrithr
    ["valkyrie"] = true,
    ["battlesinger"] = true,
    ["usesvegetarianequipment"] = true,

        ["quagmire_butcher"] = true,

    -- waxwell
    ["shadowmagic"] = true,
    ["dappereffects"] = true,
    --magician (from magician component, added to pristine state for optimization
    ["magician"] = true,
    --reader (from reader component, added to pristine state for optimization
    ["reader"] = true,
    -- webber
    ["spiderwhisperer"] = true,
    ["dualsoul"] = true,
    [UPGRADETYPES.SPIDER.."_upgradeuser"] = true,

    ["fastpicker"] = true,
    ["quagmire_farmhand"] = true,

    ["bearded"] = true,
    -- wendy
    ["ghostlyfriend"] = true,
    ["elixirbrewer"] = true,
    ["quagmire_grillmaster"] = true,
    -- wes
    ["mime"] = true,
    ["balloonomancer"] = true,

    ["quagmire_cheapskate"] = true,
    -- wickerbottom
    ["insomniac"] = true,
    ["bookbuilder"] = true,
    ["quagmire_foodie"] = true,
    -- willow
    ["pyromaniac"] = true,
    ["bernieowner"] = true,
    
    ["heatresistant"] = true, --less overheat damage

    ["bernie_reviver"] = true,


    -- wilson
    ["quagmire_potmaster"] = true,
    -- winona
    ["handyperson"] = true,
    ["fastbuilder"] = true,
    ["hungrybuilder"] = true,
    ["quagmire_fasthands"] = true,
    -- wolfgang
    ["strongman"] = true,
    ["quagmire_ovenmaster"] = true,
    -- wonkey
    ["wonkey"] = true,
    ["monkey"] = true,
    -- woodie
    ["woodcutter"] = true,
    ["polite"] = true,
    ["werehuman"] = true,

    ["wereness"] = true,
    ["wereplayer"] = true,
    -- newmode == WEREMODES.BEAVER and "beaver" or ("were"..WEREMODE_NAMES[newmode],

    -- wormwood
    ["plantkin"] = true,
    ["self_fertilizable"] = true,
}
----以下代码来着小穹 修改了点(尝试兼容更多mod tag 但是写的很垃圾) 感谢风铃
local Tags = {}
local key = modname .. "fixtag" -- 默认用modname 做key 防止冲突


local function AddTag(inst, stag, ...)
    if not inst or not stag then return end
    local fninfo = debug.getinfo(2)
    -- print("--------:"..stag)
    -- dumptable(fninfo)

    if (not tagslist[stag] and (fninfo.source and fninfo.source:match("mods/workshop-") or inst[key].Tags[stag])) and not inst[key].HasTag(inst, stag, ...) then
        inst[key].Tags[stag] = 1
        local tagsstr = json.encode(inst[key].Tags)
        inst[key].fixTag:set(tagsstr)
    else
        return inst[key].AddTag(inst, stag, ...)
    end
end

local function RemoveTag(inst, stag, ...)
    if not inst or not stag then return end

    if inst[key].Tags and inst[key].Tags[stag] then
        inst[key].Tags[stag] = 0
        local tagsstr = json.encode(inst[key].Tags)
        inst[key].fixTag:set(tagsstr)
    end
    if inst[key].HasTag(inst, stag, ...) then
        return inst[key].RemoveTag(inst, stag, ...)
    end
end

local function HasTag(inst, stag, ...)
    if not inst or not stag then return end

    return inst[key].Tags[stag] == 1 or inst[key].HasTag(inst, stag, ...) 
end

local function FixTag(inst) -- 传入实体 主客机一起调用
    inst[key] = {
        AddTag = inst.AddTag,
        HasTag = inst.HasTag,
        RemoveTag = inst.RemoveTag,
        Tags = {},
    }
    inst[key].fixTag = net_string(inst.GUID, key .. "." .. "fixtag",key .. "." .. "fixtag" .. "dirty")
    inst.AddTag = AddTag
    inst.HasTag = HasTag
    inst.RemoveTag = RemoveTag
    if not TheWorld.ismastersim then
        inst:ListenForEvent(key .. "." .. "fixtag" .. "dirty", function(inst)
            local tagstb = json.decode(inst[key].fixTag:value())
            for i,v in pairs(tagstb) do
                inst[key].Tags[i] = v
            end
        end)
    end
end


AddPlayerPostInit(function(inst) -- 默认只扩展人物的
    FixTag(inst)
end)
