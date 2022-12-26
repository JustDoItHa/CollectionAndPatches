if not (GLOBAL.TheNet and GLOBAL.TheNet:GetIsServer()) then
    return
end
local _G = GLOBAL
local TheNet = _G.TheNet
local SpawnPrefab = _G.SpawnPrefab
local STRINGS = _G.STRINGS
local TheWorldState

local ANNOUNCE_TIP = GetModConfigData("ANNOUNCE_TIP")
local PACKS_CD = GetModConfigData("PACKS_CD")
local RESOURCE_BALANCE = GetModConfigData("RESOURCE_BALANCE")
local PACKS_CHARACTER = GetModConfigData("PACKS_CHARACTER")
local PACKS_BUILD = GetModConfigData("PACKS_BUILD")
local PACKS_SEASON = GetModConfigData("PACKS_SEASON")
local PACKS_BUFF = GetModConfigData("PACKS_BUFF") * 60
local PACKS_SCIENCE = GetModConfigData("PACKS_SCIENCE")
local PACKS_BACKPACK = GetModConfigData("PACKS_BACKPACK")

local function endswith(str, substr)
    if str == nil or substr == nil then
        return nil, "the string or the sub-string parameter is nil"
    end
    local str_tmp = string.reverse(str)
    local substr_tmp = string.reverse(substr)
    if string.find(str_tmp, substr_tmp) ~= 1 then
        return false
    else
        return true
    end
end

local CHARACTER_CORE = PACKS_CHARACTER > 1 and PACKS_CHARACTER - 1 or 0
local CHARACTER_NORMAL = PACKS_CHARACTER > 2 and 1 or 0
local CHARACTER_BASE = PACKS_CHARACTER > 2 and PACKS_CHARACTER - 1 or 0

local MY_STRINGS = {
    season_name = {
        "春季",
        "春末",
        "夏季",
        "夏末",
        "秋季",
        "秋末",
        "冬季",
        "冬末",
    },
    packs_msg = "%s (%s) 获得 <%s新手礼包>",
    packs_cd_msg = "%s 冷却:%d天",
    build_packs_msg = "%s (%s) 获得 <建筑礼包>",
    wait_packs_say = "<新手礼包> 冷却:%d天",
    build_packs_say = "<建筑礼包> : 免费制造物品一次",
}

do
    -- auto load languages translate
    --local support_languages = { chs = true, cht = true, zh_CN = "chs", cn = "chs", TW = "cht" }
    --local steam_support_languages = { schinese = "chs", tchinese = "cht" }

    AddPrefabPostInit("world", function(inst)
        --local steamlang = TheNet:GetLanguageCode() or nil
        --if steamlang and steam_support_languages[steamlang] then
        --	print("<Starting NovicePacks> Get your language from steam!")
        --	modimport("translate_" .. steam_support_languages[steamlang])
        --else
        --	local lang = _G.LanguageTranslator.defaultlang or nil
        --	if lang ~= nil and support_languages[lang] ~= nil then
        --		if support_languages[lang] ~= true then
        --			lang = support_languages[lang]
        --		end
        --		print("<Starting NovicePacks> Get your language from language mod!")
        --		modimport("modules/sel_define_start/translate_" .. lang)
        --	end
        --end

        if MY_STRINGS_OVERRIDE ~= nil then
            for k, v in pairs(MY_STRINGS_OVERRIDE) do
                if MY_STRINGS[k] ~= nil then
                    MY_STRINGS[k] = v
                end
            end
            MY_STRINGS_OVERRIDE = nil
        end
    end)
end

local resource = {}
for k, v in pairs(modinfo.resource_prefab) do
    resource[v.name] = GetModConfigData(v.name)
end

local cd_list = {}
local build_list = { number = 0 }

local season_item = {
    {
        umbrella = 1,
        raincoat = 1,
    },
    {
        umbrella = 1,
        heatrock = 1,
        ice = 5,
    },
    {
        watermelonhat = 1,
        heatrock = 1,
        ice = 15,
    },
    {
        heatrock = 1,
        ice = 10,
        dragonpie = 2,
    },
    {
        sewing_kit = 1,
        dragonpie = 5,
    },
    {
        heatrock = 1,
        dragonpie = 5,
    },
    {
        heatrock = 1,
        winterhat = 1,
    },
    {
        umbrella = 1,
        heatrock = 1,
    },
}

local character_item = {
    wilson = {
        lightning_rod_blueprint = 1,
        researchlab2_blueprint = 1,
        rainometer_blueprint = CHARACTER_NORMAL,
        winterometer_blueprint = CHARACTER_NORMAL,
        razor = 1,
        sweatervest = CHARACTER_NORMAL,
        twigs = CHARACTER_CORE * 5,
        cutgrass = CHARACTER_CORE * 5,
    },
    wendy = {
        rope_blueprint = 1,
        boards_blueprint = 1,
        cutstone_blueprint = 1,
        flowerhat = 1,
        armorwood = CHARACTER_BASE,
        purpleamulet = CHARACTER_NORMAL,
        greenstaff = CHARACTER_NORMAL,
        lantern = 1,
    },
    webber = {
        rope_blueprint = 1,
        tent_blueprint = CHARACTER_NORMAL,
        razor = 1,
        spiderhat = CHARACTER_NORMAL,
        spidereggsack = CHARACTER_BASE,
        spidergland = CHARACTER_BASE * 2,
        silk = CHARACTER_BASE * 3,
        monstermeat = CHARACTER_CORE * 2,
    },
    willow = {
        gunpowder_blueprint = 1,
        blowdart_fire = CHARACTER_BASE * 3,
        trunkvest_summer = CHARACTER_NORMAL,
        tophat = 1,
        charcoal = CHARACTER_CORE * 5,
        log = CHARACTER_CORE * 5,
        cutgrass = CHARACTER_CORE * 4,
        twigs = CHARACTER_CORE * 4,
    },
    waxwell = {
        researchlab3_blueprint = CHARACTER_NORMAL,
        researchlab4_blueprint = 1,
        cane = CHARACTER_NORMAL,
        nightmarefuel = CHARACTER_CORE * 5,
        livinglog = CHARACTER_CORE * 2,
        papyrus = CHARACTER_CORE * 4,
        redgem = CHARACTER_BASE,
        rabbit = CHARACTER_BASE,
    },
    wickerbottom = {
        birdcage_blueprint = CHARACTER_NORMAL,
        book_birds = 1,
        book_gardening = 1,
        honeycomb = CHARACTER_NORMAL,
        featherhat = CHARACTER_NORMAL,
        lantern = CHARACTER_NORMAL,
        papyrus = CHARACTER_CORE * 5,
        cactus_meat = CHARACTER_CORE * 5,
    },
    wolfgang = {
        rope_blueprint = 1,
        spear_blueprint = CHARACTER_NORMAL,
        hambat = CHARACTER_NORMAL,
        hammer = CHARACTER_NORMAL,
        armorslurper = CHARACTER_NORMAL,
        footballhat = 1,
        log = CHARACTER_CORE * 3,
        bonestew = CHARACTER_CORE * 3,
    },
    woodie = {
        trap_teeth_blueprint = CHARACTER_NORMAL,
        strawhat = 1,
        fishingrod = 1,
        bedroll_furry = CHARACTER_NORMAL,
        pinecone = CHARACTER_CORE * 5,
        acorn = CHARACTER_CORE * 5,
        log = CHARACTER_CORE * 5,
        rocks = CHARACTER_CORE * 3,
    },
    wathgrithr = {
        rope_blueprint = 1,
        spear_blueprint = CHARACTER_NORMAL,
        armorwood_blueprint = CHARACTER_NORMAL,
        trap = CHARACTER_BASE,
        tentaclespike = 1,
        goldnugget = CHARACTER_CORE * 4,
        rocks = CHARACTER_CORE * 4,
        meat_dried = CHARACTER_CORE * 3,
    },
    wes = {
        umbrella_blueprint = 1,
        fireflies = CHARACTER_CORE * 3,
        tophat = 1,
        trinket_1 = CHARACTER_BASE * 2,
        bugnet = 1,
        goldnugget = CHARACTER_CORE * 5,
        panflute = CHARACTER_NORMAL,
        mandrakesoup = CHARACTER_BASE,
    },
    wx78 = {
        minerhat_blueprint = 1,
        icebox_blueprint = CHARACTER_NORMAL,
        firesuppressor_blueprint = CHARACTER_NORMAL,
        umbrella = 1,
        boomerang = CHARACTER_NORMAL,
        trinket_11 = CHARACTER_CORE * 5,
        gears = CHARACTER_CORE * 5,
        goldnugget = CHARACTER_BASE * 3,
    },
}
local character_backpack = {
    wilson = 1,
    willow = 1,
    wendy = 1,
    woodie = 1,
    wolfgang = 0,
    wx78 = 1,
    wickerbottom = 1,
    wes = 2,
    waxwell = 0,
    wathgrithr = 0,
    webber = 0,
}
local night_item = {
    torch = 1,
}
local pvp_item = {
    spear = 1,
    footballhat = 1,
}
local BASE_MAX = 5

local function ItemBalance(count)
    local base = TheWorldState.cycles * 0.03 + 1
    if base > BASE_MAX then
        base = BASE_MAX
    end
    return math.floor(base * count)
end

local function GiveResource(player, prefab, count, gifts_table)
    local inventory = player and player.components.inventory or nil
    local lastitem
    for i = 1, count do
        local stackable_sign = false --堆叠标志
        local item = SpawnPrefab(prefab)
        if item == nil then
            print("give item is nil")
            break
        elseif RESOURCE_BALANCE and i == 1 and item.components and item.components.equippable == nil and item.components.inventoryitem then
            count = ItemBalance(count)
        end
        print("give item continue")
        -- heatrock heating / refrigeration
        if item.components.stackable then
            stackable_sign = true
            item.components.stackable:SetStackSize(count)
        end

        if prefab == "heatrock" then
            if TheWorldState.issummer or TheWorldState.isspring and TheWorldState.remainingdaysinseason < 3 then
                item.components.temperature:DoDelta(-80)
            elseif TheWorldState.iswinter or TheWorldState.isautumn and TheWorldState.remainingdaysinseason < 3 then
                item.components.temperature:DoDelta(80)
            end
        end

        local isgive = false
        if item.components and item.components.equippable then
            local itemequipslot = item.components.equippable.equipslot
            local itemequip = inventory:GetEquippedItem(itemequipslot)
            if itemequip == nil then
                inventory:Equip(item)
                isgive = true
            end
        end

        if not isgive then
            table.insert(gifts_table, item)
            lastitem = true and item or nil
            -- local gived = inventory:GiveItem(item)
            -- if gived == nil then
            --     if lastitem then
            --         lastitem:Remove()
            --         lastitem = nil
            --     end
            --     return
            -- else
            --     lastitem = gived == true and item or nil
            -- end
        end
        player.novicepacks.ispacks = true
        if stackable_sign then
            break
        end
    end
    return gifts_table
end

local function UnlockScience(player)
    if PACKS_SCIENCE == 1 then
        player.components.builder:UnlockRecipesForTech({ SCIENCE = 1 })
    elseif PACKS_SCIENCE == 2 then
        player.components.builder:UnlockRecipesForTech({ SCIENCE = 2 })
    elseif PACKS_SCIENCE == 3 then
        player.components.builder:UnlockRecipesForTech({ SCIENCE = 2, MAGIC = 2 })
    elseif PACKS_SCIENCE >= 4 then
        player.components.builder:UnlockRecipesForTech({ SCIENCE = 2, MAGIC = 3 })
    end
end

local function AddBuff(player)
    local initstate = {}
    initstate.absorb = player.components.health.absorb
    initstate.maxtemp = player.components.temperature.maxtemp
    initstate.mintemp = player.components.temperature.mintemp
    -- damage absorption
    player.components.health.absorb = 0.8
    -- constant temperature
    player.components.temperature.maxtemp = 40
    player.components.temperature.mintemp = 20
    player:AddTag("forcefield")
    local fx = SpawnPrefab("forcefieldfx")
    fx.entity:SetParent(player.entity)
    fx.Transform:SetPosition(0, 0, 0)
    local fx_hitanim = function()
        fx.AnimState:PlayAnimation("hit")
        fx.AnimState:PushAnimation("idle_loop")
    end
    fx:ListenForEvent("blocked", fx_hitanim, player)
    player.active = true
    local fx_func
    fx_func = function(time)
        player:DoTaskInTime(time, function()
            if player.forcefieldtime and player.forcefieldtime > 0 then
                local time = player.forcefieldtime
                player.forcefieldtime = nil
                player:DoTaskInTime(0.1, function()
                    fx_func(time)
                end)
            else
                fx:RemoveEventCallback("blocked", fx_hitanim, player)
                fx.kill_fx(fx)
                if player:IsValid() then
                    -- Return to normal state.
                    player.components.health.absorb = initstate.absorb
                    player.components.temperature.maxtemp = initstate.maxtemp
                    player.components.temperature.mintemp = initstate.mintemp
                    player:RemoveTag("forcefield")
                    player:DoTaskInTime(0.5, function()
                        player.active = nil
                    end)
                end
            end
        end)
    end
    fx_func(PACKS_BUFF)
end

local function GetSeason()
    if TheWorldState.isspring then
        return 1
    elseif TheWorldState.issummer then
        return 2
    elseif TheWorldState.isautumn then
        return 3
    elseif TheWorldState.iswinter then
        return 4
    end
end

local OnPlayerSpawn = function(src, player)
    if PACKS_SCIENCE == 5 then
        player.components.builder.ancient_bonus = 4
    end

    local Old_OnNewSpawn = player.OnNewSpawn
    player.OnNewSpawn = function(...)
        player.novicepacks = {}
        if PACKS_CD == 0 or cd_list[player.userid] == nil or (PACKS_CD > 0 and cd_list[player.userid] + PACKS_CD <= TheWorldState.cycles) then
            -- Close SpawnPrefab sound.
            player.components.inventory.ignoresound = true
            local isbuild = false
            if PACKS_SCIENCE >= 1 and PACKS_SCIENCE <= 5 then
                UnlockScience(player)
                player.novicepacks.ispacks = true
            end
            if PACKS_BUFF ~= 0 then
                AddBuff(player)
                player.novicepacks.ispacks = true
            end
            local backpack_type = PACKS_BACKPACK
            if PACKS_CHARACTER > 0 and character_backpack[player.prefab] and character_backpack[player.prefab] > backpack_type then
                backpack_type = character_backpack[player.prefab]
            end
            local backpacks = {
                "backpack",
                "piggyback",
                "icepack",
                "krampus_sack",
            }
            if backpacks[backpack_type] then
                player.components.inventory:Equip(SpawnPrefab(backpacks[backpack_type]))
                player.novicepacks.ispacks = true
            end
            local resources = {}
            local season_msg = ""
            for k, v in pairs(resource) do
                resources[k] = v
            end
            if PACKS_CHARACTER > 0 then
                if not TheWorldState.isday then
                    for k, v in pairs(night_item) do
                        if TheWorldState.isnight then
                            v = v + 1
                        end
                        if resources[k] == nil or resources[k] < v then
                            resources[k] = v
                        end
                    end
                end
                if TheNet:GetPVPEnabled() then
                    for k, v in pairs(pvp_item) do
                        if resources[k] == nil or resources[k] < v then
                            resources[k] = v
                        end
                    end
                end
                if PACKS_CHARACTER > 1 and character_item[player.prefab] then
                    for k, v in pairs(character_item[player.prefab]) do
                        if endswith(k, "_blueprint") then
                            player.components.builder:UnlockRecipe(string.sub(k, 1, #k - 10))
                        elseif resources[k] == nil or resources[k] < v then
                            resources[k] = v
                        end
                    end
                end
                if PACKS_CHARACTER > 3 then
                    if resources["blueprint"] == nil or resources["blueprint"] < 1 then
                        resources["blueprint"] = 1
                    end
                end
            end
            if PACKS_SEASON then
                local season_type = GetSeason() * 2
                if TheWorldState.remainingdaysinseason >= 3 then
                    season_type = season_type - 1
                end
                season_msg = MY_STRINGS.season_name[season_type]
                for k, v in pairs(season_item[season_type]) do
                    resources[k] = resources[k] and resources[k] + v or v
                end
            end
            local gifts_table = {}

            for k, v in pairs(resources) do
                gifts_table = GiveResource(player, k, v, gifts_table)
            end
            ----非装备物品打包
            local start_gift = SpawnPrefab("gift")
            if gifts_table ~= nil and #gifts_table > 0 then
                start_gift.components.unwrappable:WrapItems(gifts_table, player)
                for k, v in pairs(gifts_table) do
                    if v then
                        v:Remove()
                    end
                end
                player.components.inventory:GiveItem(start_gift)
            end

            if PACKS_BUILD > 0 and TheWorldState.cycles <= 10 and build_list.number < PACKS_BUILD and build_list[player.userid] == nil and player.components and player.components.builder and math.random() < 0.7 then
                player.components.builder:GiveAllRecipes()
                player.novicepacks_build = 1
                local Old_RemoveIngredients = player.components.builder.RemoveIngredients
                player.components.builder.RemoveIngredients = function(self, inst, recname)
                    player.components.builder.RemoveIngredients = Old_RemoveIngredients
                    Old_RemoveIngredients(self, inst, recname)
                    player.components.builder:UnlockRecipe(recname)
                    player.components.builder:GiveAllRecipes()
                    player.novicepacks_build = nil
                end
                build_list.number = build_list.number + 1
                build_list[player.userid] = true
                player.novicepacks.ispacks = true
                isbuild = true
            end

            if player.novicepacks.ispacks then
                cd_list[player.userid] = TheWorldState.cycles
                if ANNOUNCE_TIP then
                    local playername = player:GetDisplayName()
                    local charactername = STRINGS.CHARACTER_NAMES[player.prefab] or player.prefab
                    player:DoTaskInTime(0.5, function()
                        local message = string.format(MY_STRINGS.packs_msg, playername, charactername, season_msg)
                        if PACKS_CD > 0 then
                            message = string.format(MY_STRINGS.packs_cd_msg, message, PACKS_CD)
                        end
                        TheNet:Announce(message)
                    end)
                    if isbuild then
                        player:DoTaskInTime(1, function()
                            TheNet:Announce(string.format(MY_STRINGS.build_packs_msg, playername, charactername))
                        end)
                    end
                end
            end
            player.components.inventory.ignoresound = false

        elseif PACKS_CD < 0 then
            --
        else
            player:DoTaskInTime(1, function()
                if player.components.talker then
                    player.components.talker:Say(string.format(MY_STRINGS.wait_packs_say, (cd_list[player.userid] + PACKS_CD - TheWorldState.cycles)))
                end
            end)
        end

        player.novicepacks.ispacks = nil
        player.novicepacks = nil

        if Old_OnNewSpawn then
            return Old_OnNewSpawn(...)
        end
    end

    local Old_OnSave = player.OnSave
    player.OnSave = function(inst, data)
        if player.novicepacks_build then
            data.novicepacks_build = 2
        end
        if Old_OnSave ~= nil then
            return Old_OnSave(inst, data)
        end
    end
    local Old_OnLoad = player.OnLoad
    player.OnLoad = function(inst, data)
        if data.novicepacks_build then
            player.novicepacks_build = 2
        end
        if Old_OnLoad ~= nil then
            return Old_OnLoad(inst, data)
        end
    end
end

local OnPlayerJoin = function(src, player)
    if player.novicepacks_build == 2 then
        player:DoTaskInTime(1, function()
            player.components.builder:GiveAllRecipes()
            local Old_RemoveIngredients = player.components.builder.RemoveIngredients
            player.components.builder.RemoveIngredients = function(self, inst, recname)
                player.components.builder.RemoveIngredients = Old_RemoveIngredients
                Old_RemoveIngredients(self, inst, recname)
                player.components.builder:UnlockRecipe(recname)
                player.components.builder:GiveAllRecipes()
                player.novicepacks_build = nil
            end
            if player.components.talker then
                player.components.talker:Say(MY_STRINGS.build_packs_say)
            end
        end)
    end
end

AddPrefabPostInit("world", function(inst)
    TheWorldState = _G.TheWorld.state
    local Old_OnSave = inst.OnSave
    inst.OnSave = function(inst, data)
        if cd_list ~= nil and build_list ~= nil then
            data.novicepacks = {
                ["cd_list"] = cd_list,
                ["build_list"] = build_list,
            }
        end
        if Old_OnSave ~= nil then
            return Old_OnSave(inst, data)
        end
    end
    local Old_OnLoad = inst.OnLoad
    inst.OnLoad = function(inst, data)
        if data ~= nil and data.novicepacks ~= nil then
            cd_list = data.novicepacks.cd_list
            build_list = data.novicepacks.build_list
        end
        if Old_OnLoad ~= nil then
            return Old_OnLoad(inst, data)
        end
    end
    inst:ListenForEvent("ms_playerspawn", OnPlayerSpawn, inst)
    inst:ListenForEvent("ms_playerjoined", OnPlayerJoin, inst)
end)