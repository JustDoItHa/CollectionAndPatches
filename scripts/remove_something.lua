GLOBAL.setmetatable(env, { __index = function(t, k)
    return GLOBAL.rawget(GLOBAL, k)
end })

local remove_table = {
    --神话
    remove_myth_mooncake = { "myth_mooncake_ice", "myth_mooncake_lotus", "myth_mooncake_nuts" },
    remove_myth_qxj = { "myth_qxj" },
    remove_myth_bigpeach = { "bigpeach" },
    --Aria
    remove_aria_tower = { "aria_tower" },
    remove_aria_transfer = { "aria_transfer" },
    remove_aria_meteor = { "aria_meteor" },
    --伊蕾娜
    remove_elaina_bq = { "elaina_bq" },
    --奇幻降临阿比
    remove_abigail_williams_atrium_light_moon = { "atrium_light_moon" },
    remove_abigail_williams_black_gold = { "abigail_williams_black_gold" },
    remove_abigail_williams_psionic_bobbin_c = { "abigail_williams_psionic_bobbin_c" },
    remove_abigail_williams_ab_lnhx = { "ab_lnhx" },
    remove_abigail_williams_starry_bush = { "abigail_williams_starry_bush" },
    remove_abigail_williams_bonestew = { "abigail_williams_bonestew" },
    remove_abigail_williams_ab_wilsontorch = { "ab_wilsontorch" },
    remove_abigail_williams_traveler_armor = { "traveler_armor" },
    remove_abigail_williams_traveler_armor_2 = { "traveler_armor_2" },
    remove_abigail_williams_traveler_armor_3 = { "traveler_armor_3" },
    remove_abigail_williams_sword = { "traveler_sword" },
    remove_abigail_williams_sword_a = { "traveler_sword_a" },
    remove_abigail_williams_sword_b = { "traveler_sword_b" },
    remove_abigail_williams_psionic_bobbin_2_3_4 = { "abigail_williams_psionic_bobbin_2", "abigail_williams_psionic_bobbin_3", "abigail_williams_psionic_bobbin_4" },
    --夜雨空心
    remove_nilxin_fox = { "nilxin_fox" },
    remove_nilxin_yyxk1 = { "yyxk1" },
    remove_yyxk_auto_recipe = { "yyxk_auto_recipe" },
    remove_yyxk_auto_destroystructure = { "yyxk_auto_destroystructure" },
    remove_yyxk_item_togetherup0 = { "yyxk_item_togetherup0" },
    --小狐狸
    remove_kemomimi_book_fs = { "kemomimi_book_fs" },
    remove_kemomimi_magic_coin_colour = { "magic_coin_colour" },
    remove_kemomimi_build_pig = { "kemomimi_build_pig" },
    remove_kemomimi_boss_ds_zh = { "kemomimi_boss_ds_zh" },
    -- 时崎狂三
    remove_krm_broom = { "krm_broom" },
    remove_krm_bullet10 = { "krm_bullet10" },
    remove_krm_spirit_crystal = { "krm_spirit_crystal" },
    --勋章
    remove_monster_book = { "monster_book" },
    --怠惰科技
    remove_hclr_kjk = { "hclr_kjk" },
    --永不妥协
    ["老鼠"] = { "uncompromising_rat", "uncompromising_packrat", "uncompromising_junkrat" },
    ["恐怖剧钳"] = { "creepingfear" },
    --黑死病
    remove_tiddle_decay = { "tiddle_decay" },
    remove_krm_broom = { "krm_broom" },
    remove_krm_bullet10 = { "krm_bullet10" },
    --原版
    ["青蛙"] = { "frog" },
    ["鸟粪"] = { "guano" },
    ["月乌鸦"] = { "bird_mutant" },
    ["远古蜈蚣"] = { "archive_centipede" },
    --冬季盛宴
    ["圣诞节日"] = { "winter_food1", "winter_food2", "winter_food3", "winter_food4", "winter_food5", "winter_food6", "winter_food7", "winter_food8", "winter_food9", },
    remove_halloween_candy = { "halloweencandy_1",
                               "halloweencandy_2",
                               "halloweencandy_3",
                               "halloweencandy_4",
                               "halloweencandy_5",
                               "halloweencandy_6",
                               "halloweencandy_7",
                               "halloweencandy_8",
                               "halloweencandy_9",
                               "halloweencandy_10",
                               "halloweencandy_11",
                               "halloweencandy_12",
                               "halloweencandy_13",
                               "halloweencandy_14", },

    remove_taizhen_personal_fanhao = { "tz_fhzc",
                                       "tz_fhgx",
                                       "tz_fhft",
                                       "tz_fhdx",
                                       "tz_fhym",
                                       "tz_fhzlz",
                                       "tz_fhspts",
                                       "tz_fh_ym",
                                       "tz_fh_ml",
                                       "tz_fh_you",
                                       "tz_fh_ns",
                                       "tz_fh_ly",
                                       "tz_fh_jhz",
                                       "tz_fh_xhws",
                                       "tz_fh_fl",
                                       "tz_fh_ht",
                                       "tz_fh_hf",
                                       "tz_fh_nx",
                                       "tz_fh_fishgirl" },


    --remove_heap_of_food_bird = { "quagmire_pigeon", "toucan", "kingfisher" },
}
-- local remove_item  = {}
-- for k, v in pairs(remove_table) do
--  for j ,s in pairs(v) do
--      table.insert(remove_item,v)
--  end
-- end
local function recall_something(owner, sp, pos)
    if owner then
        if owner.components.inventory then
            owner.components.inventory:GiveItem(sp)
        elseif owner.components.container then
            owner.components.container:GiveItem(sp)
        end
    elseif pos then
        sp.Transform:SetPosition(pos.x, 0, pos.z)
    end
end
local function SpawnLootPrefab(owner, name, sum, pos)
    local sp = SpawnPrefab(name)
    if sp then
        if sp.components.stackable then
            local m = sp.components.stackable.maxsize
            local c = sum - m
            sp.components.stackable:SetStackSize(c > 0 and m or sum)
            recall_something(owner, sp, pos)
            while (c > 0) do
                local loot1 = SpawnPrefab(name)
                if c > m then
                    loot1.components.stackable:SetStackSize(m)
                else
                    loot1.components.stackable:SetStackSize(c)
                end

                recall_something(owner, loot1, pos)
                c = c - m
            end
        else
            recall_something(owner, sp, pos)
            if sum > 1 then
                for i = 2, sum do
                    local loot2 = SpawnPrefab(name)
                    recall_something(owner, loot2, pos)
                end
            end
        end
    end
end

-- local ablog = {
--  abigail_williams_black_gold = {pyrite = 64,ab_lunhuiitem = 8,abigail_williams_crystal = 8},
--  abigail_williams_bonestew = {ab_lizi = 256,},
--  ab_wilsontorch = {ab_lizi = 128},
--  traveler_armor = {ab_lizi = 128,},
--  traveler_armor_2 = {ab_lizi = 1024,ab_lunhuiitem = 1,},
--  traveler_armor_3 = {ab_lizi = 1024,ab_lunhuiitem = 2,},
--  traveler_sword_a = {ab_lizi = 512,},
--  traveler_sword_b = {ab_lizi = 2048,ab_lunhuiitem = 2,},
-- }

local function resomething(item)
    local ingred
    local name
    if type(item) == "string" then
        if TUNING.AB_RECIPELIST and TUNING.AB_RECIPELIST[item] then
            return TUNING.AB_RECIPELIST[item]["ingredient"], "abtravel_log"
        else
            for k, v in pairs(AllRecipes) do
                if v.product == item then
                    ingred = v.ingredients
                    name = v.name
                    break
                end
            end
            if ingred then
                return ingred, "ingredients", name
            else
                return false
            end
        end
    elseif type(item) == "table" then
        name = {}
        for k, v in pairs(AllRecipes) do
            if table.contains(item, v.product) then
                table.insert(name, v.name)
            end
        end
        if next(name) then
            return ingred, "ingredients", name
        else
            return false
        end
    else
        return false
    end
end
-- local function findplayer(inst)
--     local dis = 20
--     local x, y, z = inst.Transform:GetWorldPosition()
--     for i, v in ipairs(TheSim:FindEntities(x, y, z, 10, { "player" }, nil)) do
--         if inst:GetDistanceSqToInst(v) < dis then
--             dis = inst:GetDistanceSqToInst(v)
--             player = v
--         end
--     end
--     return player
-- end
-- local function reinfo(inst)
--     local player = inst.components.inventoryitem and inst.components.inventoryitem.owner or findplayer(inst)
--     local ingredientmod = player and player.components and player.components.builder and player.components.builder.ingredientmod or 1
--     if player and player:HasTag("player") then
--         local x, y, z = player.Transform:GetWorldPosition()
--         local x1, y1, z1 = inst.Transform:GetWorldPosition()
--         if checknumber(x) and checknumber(z) and checknumber(x1) and checknumber(z1) and distsq(x, z, x1, z1) < 100 then
--             return player, ingredientmod
--         else
--             return false
--         end
--     else
--         return false
--     end
-- end

local function remoe_gai(inst)
    local re_table, type = resomething(inst.prefab)
    if re_table then
        -- local player, ingredientmod = reinfo(inst)
        local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
        local ingredientmod = owner and owner.components and owner.components.builder and owner.components.builder.ingredientmod or 1
        local pos = inst:GetPosition()
        -- if player then
        inst:Remove()
        if type == "abtravel_log" then
            local ab_traveler_log = owner and owner:HasTag("player") and owner.components.inventory:GetCraftingIngredient("traveler_log", 1) or {}
            for k, v in pairs(re_table) do
                if k == "ab_lizi" and next(ab_traveler_log) then
                    for j, s in pairs(ab_traveler_log) do
                        if j.prefab == "traveler_log" then
                            j.components.ab_recipelist.inventoryitems.ab_lizi = j.components.ab_recipelist.inventoryitems.ab_lizi + v
                            break
                        end
                    end
                elseif k == "ab_lizi" then
                    SpawnLootPrefab(owner, "log", v, pos)
                else
                    SpawnLootPrefab(owner, k, v, pos)
                end
            end
        else
            for k, v in pairs(re_table) do
                SpawnLootPrefab(owner, v.type, RoundBiasedUp(v.amount * ingredientmod), pos)
                -- if inst:HasTag("structure") then
                --  SpawnLootPrefab(player, v.type, RoundBiasedUp(v.amount*0.5))
                -- else
                --  SpawnLootPrefab(player, v.type, RoundBiasedUp(v.amount*ingredientmod))
                -- end
            end
        end


        -- end
    else
        inst:Remove()
    end
end

if TheNet:GetIsServer() then
    for k, v in pairs(remove_table) do
        local remove_day = GetModConfigData(k) or 0
        -- if k == "remove_abigail_williams_atrium_light_moon" and TheShard:GetShardId() == "1" then remove_day=0 end
        for j, s in pairs(v) do
            AddPrefabPostInit(s, function(inst)
                if remove_day < 0 or TheWorld.state.cycles + 1 < remove_day then
                    inst:DoPeriodicTask(0.05, function()
                        -- inst:DoTaskInTime(0, function()
                        if inst.components and inst.components.container then
                            --and not inst.components.container:IsEmpty()
                            if inst.components.container:IsEmpty() then
                                remoe_gai(inst)
                            else
                                inst.components.container:DropEverything()
                            end
                        else
                            remoe_gai(inst)
                        end
                    end, 0)
                end
            end)
        end
    end

end
STRINGS.CHARACTERS.GENERIC.ACTIONFAIL.BUILD.NODAY0 = "永久封禁"
local kj_name = {}
AddPlayerPostInit(function(inst)
    if TheWorld then
        for k, v in pairs(remove_table) do
            local remove_day = GetModConfigData(k) or 0
            if remove_day < 0 or TheWorld.state.cycles + 1 < remove_day then
                local re_table, type, name = resomething(v)
                local str = "NODAY" .. remove_day
                STRINGS.CHARACTERS.GENERIC.ACTIONFAIL.BUILD[str] = "世界" .. remove_day .. "天解锁"
                if type == "ingredients" and next(name) then
                    for j, s in pairs(name) do
                        kj_name[s] = remove_day
                        local rec = AllRecipes[s]
                        rec.canbuild = function()
                            if TheWorld.state.cycles + 1 < remove_day then
                                return false, str
                            elseif remove_day < 0 then
                                return false, "NODAY0"
                            else
                                return true
                            end
                        end
                    end
                end
            end
        end
    end
end)

AddClassPostConstruct(
        "widgets/redux/craftingmenu_details",
        function(self, owner)

            local oldUpdateBuildButton = self.UpdateBuildButton
            function self:UpdateBuildButton(from_pin_slot)
                oldUpdateBuildButton(self, from_pin_slot)
                if kj_name[self.data.recipe.name] then
                    local remove_day = kj_name[self.data.recipe.name] or 0
                    if TheWorld.state.cycles + 1 >= remove_day and remove_day ~= -1 then
                        return
                    end
                    local str
                    if remove_day > 0 then
                        str = "世界" .. remove_day .. "天后解锁"
                    else
                        str = "永久封禁"
                    end
                    if TheWorld.state.cycles + 1 < remove_day or remove_day < 0 then
                        local teaser = self.build_button_root.teaser
                        teaser:SetSize(20)
                        teaser:UpdateOriginalSize()
                        teaser:SetMultilineTruncatedString(
                                str,
                                2,
                                (self.panel_width / 2) * 0.8,
                                nil,
                                false,
                                true
                        )
                        teaser:Show()
                        self.build_button_root.button:Hide()
                    end
                end
            end

        end
)
--鉴于阿比版本不一样 会导致一些内容失效 不再使用覆盖法
if MOD_RPC_HANDLERS["ab_recipelist"] and MOD_RPC["ab_recipelist"] and MOD_RPC["ab_recipelist"]["ab_recipelist"] and MOD_RPC["ab_recipelist"]["ab_recipelist"].id then
    local old_ab_recipelist = MOD_RPC_HANDLERS["ab_recipelist"][MOD_RPC["ab_recipelist"]["ab_recipelist"].id];
    MOD_RPC_HANDLERS["ab_recipelist"][MOD_RPC["ab_recipelist"]["ab_recipelist"].id] = function(inst, recipename, isproduct, ...)
        if checkstring(recipename) then
            for k, v in pairs(remove_table) do
                local remove_day = GetModConfigData(k) or 0
                if remove_day < 0 or TheWorld.state.cycles + 1 < remove_day then
                    for j, s in pairs(v) do
                        if s == recipename then
                            if remove_day > 0 then
                                inst.components.talker:Say("世界" .. remove_day .. "天后解锁")
                            else
                                inst.components.talker:Say("永久封禁")
                            end
                            return
                        end
                    end
                end
            end
        end
        -- local black_gold = GetModConfigData("remove_abigail_williams_black_gold")
        -- if recipename == 1 and TUNING.AB_CHAONENGQUANXIAN and TheWorld.state.cycles + 1 < black_gold then
        --     inst.components.talker:Say("随暗金天数解锁")
        --     return
        -- end
        if old_ab_recipelist then
            old_ab_recipelist(inst, recipename, isproduct, ...)
        end
    end
end

-- local newtable = {}
-- for k,v in pairs(zslist) do
--     if v.id and v.item then
--        newtable[k] = {id = v.id ,item = {"elaina_blue_rose2"}} 
--     end
-- end
-- local params = upvaluehelper.Set(elaina_valid2.InIt,"zslist",newtable)

-- AddModRPCHandler("ab_recipelist", "ab_recipelist", function(inst, recipename, isproduct)
--     if checkstring(recipename) then
--         for k, v in pairs(remove_table) do
--             local remove_day = GetModConfigData(k) or 0
--             if remove_day < 0 or TheWorld.state.cycles + 1 < remove_day then
--                 for j, s in pairs(v) do
--                     if s == recipename then
--                         if remove_day > 0 then
--                             inst.components.talker:Say("世界" .. remove_day .. "天后解锁")
--                         else
--                             inst.components.talker:Say("永久封禁")
--                         end
--                         return
--                     end
--                 end
--             end
--         end
--     end

--     if IsEntityDeadOrGhost(inst, true) then
--         return
--     end
--     if checknumber(recipename) and recipename == 1 and checkstring(isproduct) and TUNING.AB_CHAONENGQUANXIAN then
--         if inst.using_traveler_log and inst.using_traveler_log:IsValid() and inst.using_traveler_log.components.ab_recipelist and
--                 inst.using_traveler_log.components.ab_recipelist.inventoryitems["abigail_williams_black_gold"] and inst.using_traveler_log.components.ab_recipelist.inventoryitems["abigail_williams_black_gold"] > 0 then
--             local new = SpawnPrefab(isproduct)
--             local pt = inst:GetPosition()
--             if new then
--                 if new.components.inventoryitem then
--                     inst.components.inventory:GiveItem(new, nil, pt)
--                 elseif new.Transform then
--                     new.Transform:SetPosition(pt:Get())
--                 end
--                 inst.using_traveler_log.components.ab_recipelist.inventoryitems["abigail_williams_black_gold"] = inst.using_traveler_log.components.ab_recipelist.inventoryitems["abigail_williams_black_gold"] - 1
--             else
--                 inst.components.talker:Say("无效得物品")
--             end
--             return
--         end

--         if inst.components.inventory:Has("abigail_williams_black_gold", 1) then
--             local new = SpawnPrefab(isproduct)
--             local pt = inst:GetPosition()
--             if new then
--                 if new.components.inventoryitem then
--                     inst.components.inventory:GiveItem(new, nil, pt)
--                 elseif new.Transform then
--                     new.Transform:SetPosition(pt:Get())
--                 end
--                 inst.components.inventory:ConsumeByName("abigail_williams_black_gold", 1)
--             else
--                 inst.components.talker:Say("无效得物品")
--             end
--             return
--         end
--         inst.components.talker:Say("缺少材料暗金")
--     elseif inst.using_traveler_log and inst.using_traveler_log:IsValid() and checkstring(recipename)
--             and checkbool(isproduct) and inst.using_traveler_log.components.ab_recipelist then
--         inst.using_traveler_log.components.ab_recipelist:Build(recipename, inst, isproduct)
--     end
-- end)


