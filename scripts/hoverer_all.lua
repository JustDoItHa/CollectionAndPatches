local function wqU76o(t5jzEd9)
    if t5jzEd9["_parent"] then
        t5jzEd9["_parent"]:PushEvent("hoverdirtychange")
    end
end;
AddPrefabPostInit("player_classified", function(inst)
    inst["hoverertext"] = net_string(inst["GUID"], "hoverertext", "hoverdirty")
    if not TheNet:IsDedicated() then
        inst:ListenForEvent("hoverdirty", wqU76o)
    end
end)
AddClassPostConstruct("components/inventoryitem_replica", function(self, inst)
    self["_fantasyatlas"] = nil;
    local old_SetAtlas = self["SetAtlas"]
    function self:SetAtlas(atlasname)
        if old_SetAtlas ~= nil then
            old_SetAtlas(self, atlasname)
        end ;
        self["_fantasyatlas"] = atlasname
    end;
    function self:GetFantasyAtlas()
        return self["_fantasyatlas"] ~= nil and self["_fantasyatlas"] or self:GetAtlas()
    end
end)
local LB1Z = { CHOP = "砍", DIG = "铲", HAMMER = "锤", MINE = "凿", NET = "捕" }
local N9L = { trap_teeth = TUNING["TRAP_TEETH_DAMAGE"], trap_teeth_maxwell = TUNING["TRAP_TEETH_DAMAGE"], trap_bramble = TUNING["TRAP_BRAMBLE_DAMAGE"], trap_starfish = TUNING["STARFISH_TRAP_DAMAGE"] }
local function hDc_M(xL7OTb)
    local w8T3f = nil;
    if xL7OTb["childname"] ~= SHOW_INFO_NIL_STR then
        w8T3f = xL7OTb["childname"]
    elseif xL7OTb["childspawner"] ~= nil then
        w8T3f = xL7OTb["childspawner"]
    end ;
    if w8T3f and type(w8T3f) == "string" then
        return "(" .. (STRINGS["NAMES"][string["upper"](w8T3f)] or w8T3f) .. ")"
    end ;
    return SHOW_INFO_NIL_STR
end;
local qW0lRiD1 = function(K, qL)
    return tonumber(string["format"]("%." .. (qL or tonumber("0")) .. "f", K))
end;
local function iD1IUx(vfIyB, quNsijN)
    if quNsijN ~= nil then
        local QUh2tc = tonumber("1")
        local qboV = vfIyB["components"]["inventoryitem"] and vfIyB["components"]["inventoryitem"]["owner"] or nil;
        if not qboV and vfIyB["components"]["occupier"] then
            qboV = vfIyB["components"]["occupier"]:GetOwner()
        end ;
        if qboV then
            if qboV["components"]["preserver"] ~= nil then
                QUh2tc = qboV["components"]["preserver"]:GetPerishRateMultiplier(vfIyB) or QUh2tc
            elseif qboV:HasTag("fridge") then
                if vfIyB:HasTag("frozen") and not qboV:HasTag("nocool") and not qboV:HasTag("lowcool") then
                    QUh2tc = TUNING["PERISH_COLD_FROZEN_MULT"]
                else
                    QUh2tc = TUNING["PERISH_FRIDGE_MULT"]
                end
            elseif qboV:HasTag("foodpreserver") then
                QUh2tc = TUNING["PERISH_FOOD_PRESERVER_MULT"]
            elseif qboV:HasTag("cage") and vfIyB:HasTag("small_livestock") then
                QUh2tc = TUNING["PERISH_CAGE_MULT"]
            end ;
            if qboV:HasTag("spoiler") then
                QUh2tc = QUh2tc * TUNING["PERISH_GROUND_MULT"]
            end
        else
            QUh2tc = TUNING["PERISH_GROUND_MULT"]
        end ;
        if vfIyB:GetIsWet() and not quNsijN["ignorewentonumberess"] then
            QUh2tc = QUh2tc * TUNING["PERISH_WET_MULT"]
        end ;
        if TheWorld["state"]["temperature"] < tonumber("0") then
            if vfIyB:HasTag("frozen") and not quNsijN["frozenfiremult"] then
                QUh2tc = TUNING["PERISH_COLD_FROZEN_MULT"]
            else
                QUh2tc = QUh2tc * TUNING["PERISH_WINTER_MULT"]
            end
        end ;
        if quNsijN["frozenfiremult"] then
            QUh2tc = QUh2tc * TUNING["PERISH_FROZEN_FIRE_MULT"]
        end ;
        if TheWorld["state"]["temperature"] > TUNING["OVERHEAT_TEMP"] then
            QUh2tc = QUh2tc * TUNING["PERISH_SUMMER_MULT"]
        end ;
        QUh2tc = QUh2tc * quNsijN["localPerishMultiplyer"]
        QUh2tc = QUh2tc * TUNING["PERISH_GLOBAL_MULT"]
        return QUh2tc
    end
end
local JLCOx_ak = {
    { com = "edible", fn = function(nSBOx7, u, K)
        if K["components"]["eater"] ~= nil and K["components"]["eater"]:CanEat(nSBOx7["inst"]) then
            local i1 = K["components"]["foodmemory"] ~= nil and K["components"]["foodmemory"]:GetFoodMultiplier(nSBOx7["inst"]["prefab"]) or tonumber("1")
            local zz1QI = K["components"]["eater"]
            local kFTAh = zz1QI["hungerabsorption"]
            local LBf = zz1QI["sanityabsorption"]
            local dijn4Ph = zz1QI["healthabsorption"]
            table["insert"](u, { "󰀎" .. (qW0lRiD1(nSBOx7:GetHunger(K) * kFTAh * i1, tonumber("1"))) .. " 󰀓" .. (qW0lRiD1(nSBOx7:GetSanity(K) * LBf * i1, tonumber("1"))) .. " 󰀍" .. (qW0lRiD1(nSBOx7:GetHealth(K) * dijn4Ph * i1, tonumber("1"))) })
            if nSBOx7["temperaturedelta"] ~= tonumber("0") then
                table["insert"](u, { "温度变化", nSBOx7["temperaturedelta"] .. "(" .. nSBOx7["temperatureduration"] .. "秒)" })
            end
        end
    end },
    { com = "unwrappable", fn = function(CO1, RlZo)
        if CO1["itemdata"] and type(CO1["itemdata"]) == 'table' then
            for SUn, Ib4 in ipairs(CO1["itemdata"]) do
                if Ib4["prefab"] then
                    local fjV1G2 = Ib4["data"] and Ib4["data"]["stackable"] and Ib4["data"]["stackable"]["stack"]
                    table["insert"](RlZo, { (STRINGS["NAMES"][string["upper"](Ib4["prefab"])] or Ib4["prefab"]) .. (fjV1G2 and "(" .. fjV1G2 .. ") " or " ") })
                end
            end
        end
    end },
    { com = "health", fn = function(Do, _)
        table["insert"](_, { "生命", qW0lRiD1(Do["currenthealth"]) .. "/" .. qW0lRiD1(Do:GetMaxWithPenalty()) })
        if Do["absorb"] ~= tonumber("0") then
            table["insert"](_, { "减伤", qW0lRiD1(Do["absorb"] * tonumber("100"), tonumber("1")) .. "%" })
        end
    end },
    { com = "hunger", fn = function(TqYJ4, DI)
        table["insert"](DI, { "饥饿", qW0lRiD1(TqYJ4["current"]) .. "/" .. TqYJ4["max"] })
    end },
    { com = "occupiable", fn = function(b, E)
        if b["occupant"] ~= nil and b["occupant"]:IsValid() and b["occupant"]["components"]["perishable"] then
            table["insert"](E, { "剩余天数", qW0lRiD1((b["occupant"]["components"]["perishable"]["perishremainingtime"] or tonumber("0")) / TUNING["TOTAL_DAY_TIME"], tonumber("1")) .. "天" })
        end
    end },
    { com = "sanity", fn = function(KMw7_i1s, CQi)
        table["insert"](CQi, { "理智", qW0lRiD1(KMw7_i1s["current"]) .. "/" .. KMw7_i1s["max"] })
    end },
    { com = "combat", fn = function(nHlJ, lw4Q7kbl)
        if nHlJ["defaultdamage"] > tonumber("0") then
            table["insert"](lw4Q7kbl, { "伤害", qW0lRiD1(nHlJ["defaultdamage"]) })
        end ;
        if nHlJ["attackrange"] > tonumber("3") then
            table["insert"](lw4Q7kbl, { "攻击距离", qW0lRiD1(nHlJ["attackrange"], tonumber("1")) })
        end
    end },
    { com = "weapon", fn = function(IN, QYf1)
        if not IN["inst"]["components"]["weapon_fumo"] and IN["damage"] ~= nil and type(IN["damage"]) == "number" then
            table["insert"](QYf1, { "伤害", qW0lRiD1(IN["damage"], tonumber("1")) })
            if IN["attackrange"] ~= nil and IN["attackrange"] ~= tonumber("0") then
                table["insert"](QYf1, { "攻击距离", qW0lRiD1(IN["attackrange"], tonumber("1")) })
            end
        end
    end },
    { com = "armor", fn = function(RfsnisO, lvW2ga)
        if not RfsnisO["inst"]["components"]["armor_fumo"] and not RfsnisO["inst"]["components"]["hat_fumo"] then
            if "absorb_percent" == nil or RfsnisO["absorb_percent"] == nil then
                table["insert"](lvW2ga, { "防御", qW0lRiD1(0, tonumber("1")) .. "%" })
            else
                table["insert"](lvW2ga, { "防御", qW0lRiD1(RfsnisO["absorb_percent"] * tonumber("100"), tonumber("1")) .. "%" })
            end
            --table["insert"](lvW2ga, { "防御", qW0lRiD1(RfsnisO["absorb_percent"] * tonumber("100"), tonumber("1")) .. "%" })
            table["insert"](lvW2ga, { "耐久", (RfsnisO["indestructible"] and "无限耐久" or qW0lRiD1(RfsnisO["condition"]) .. "/" .. qW0lRiD1(RfsnisO["maxcondition"])) })
        end
    end },
    { com = "fishable", fn = function(T7RKP, _L6Bs)
        table["insert"](_L6Bs, { "钓鱼", T7RKP["fishleft"] .. "/" .. T7RKP["maxfish"] })
    end },
    { com = "farmplantstress", fn = function(SH, wU4wYbA9)
        table["insert"](wU4wYbA9, { "压力值", SH["stress_points"] })
    end },
    { com = "stackable", fn = function(fFeQcIM, JEHSHPh3)
        table["insert"](JEHSHPh3, { "叠加", fFeQcIM["stacksize"] .. "/" .. fFeQcIM["maxsize"] })
    end },
    { com = "finiteuses", fn = function(bb, o5e6fP)
        table["insert"](o5e6fP, { "耐久", qW0lRiD1(bb["current"]) .. "/" .. qW0lRiD1(bb["total"]) })
    end },
    { com = "perishable", fn = function(iq7ol, eMV)
        if not iq7ol["inst"]["replica"]["health"] then
            local WDtonumberkTD = iD1IUx(iq7ol["inst"], iq7ol)
            if WDtonumberkTD > tonumber("0") then
                table["insert"](eMV, { "新鲜度", qW0lRiD1(iq7ol:GetPercent() * tonumber("100")) .. "%" })
                table["insert"](eMV, { "剩余天数", qW0lRiD1((iq7ol["perishremainingtime"] or tonumber("0")) / TUNING["TOTAL_DAY_TIME"] / WDtonumberkTD, tonumber("1")) .. "天" })
            else
                table["insert"](eMV, { "特殊效果", WDtonumberkTD == tonumber("0") and "永久保鲜" or "回复新鲜度" })
                table["insert"](eMV, { "新鲜度", qW0lRiD1(iq7ol:GetPercent() * tonumber("100")) .. "%" })
                table["insert"](eMV, { "剩余天数", qW0lRiD1((iq7ol["perishremainingtime"] or tonumber("0")) / TUNING["TOTAL_DAY_TIME"], tonumber("1")) .. "天" })
            end
        end
    end },
    { com = "follower", fn = function(Oejsws, CkD73N0)
        if Oejsws["leader"] and Oejsws["leader"]:IsValid() and Oejsws["leader"]["name"] and Oejsws["leader"]["name"] ~= SHOW_INFO_NIL_STR then
            table["insert"](CkD73N0, { "主人", Oejsws["leader"]["name"] })
            if Oejsws["targettime"] ~= nil and Oejsws["maxfollowtime"] ~= nil then
                local PlwhaRKJ = Oejsws["maxfollowtime"]
                table["insert"](CkD73N0, { "剩余跟随时间", qW0lRiD1(Oejsws:GetLoyaltyPercent() * PlwhaRKJ, tonumber("1")) })
            end
        end
    end },
    { com = "domesticatable", fn = function(Caz4NM4Z, XVxxx)
        local hD = Caz4NM4Z:GetObedience()
        local G5BuU5 = Caz4NM4Z:GetDomestication()
        if hD ~= nil and hD ~= tonumber("0") then
            table["insert"](XVxxx, { "服从度", qW0lRiD1(Caz4NM4Z:GetObedience() * tonumber("100"), tonumber("2")) .. "%" })
        end ;
        if G5BuU5 ~= nil and G5BuU5 ~= tonumber("0") then
            table["insert"](XVxxx, { "驯化度", qW0lRiD1(Caz4NM4Z:GetDomestication() * tonumber("100"), tonumber("2")) .. "%" })
        end
    end },
    { com = "growable", fn = function(AfwsY, T)
        if AfwsY["targettime"] ~= nil and AfwsY.GetonumberextStage ~= nil and AfwsY["stage"] ~= AfwsY:GetonumberextStage() then
            table["insert"](T, { "阶段", AfwsY["stage"] })
            table["insert"](T, { "时间", qW0lRiD1(AfwsY["targettime"] - GetTime(), tonumber("1")) .. "秒" })
        end
    end },
    { com = "stewer", fn = function(WZs, ITdz)
        if WZs["product"] ~= nil then
            local AjfoUo = STRINGS["NAMES"][string["upper"](WZs["product"])] or WZs["product"]
            if WZs:IsCooking() then
                table["insert"](ITdz, { "食物", AjfoUo })
                table["insert"](ITdz, { "剩余时间", qW0lRiD1(WZs:GetTimeToCook()) .. "秒" })
            elseif WZs:IsDone() then
                table["insert"](ITdz, { "食物", AjfoUo })
            end
        end
    end },
    { com = "insulator", fn = function(Er9zidsB, X)
        table["insert"](X, { Er9zidsB["type"] == SEASONS["WINTER"] and "保暖" or "隔热", Er9zidsB["insulation"] })
    end },
    { com = "tool", fn = function(dR, JFXtQwy)
        local uMV17h0 = SHOW_INFO_NIL_STR;
        for E2NZK, WNWWe in pairs(dR["actions"]) do
            if E2NZK["id"] and LB1Z[E2NZK["id"]] then
                uMV17h0 = uMV17h0 .. LB1Z[E2NZK["id"]] .. "(" .. qW0lRiD1(WNWWe, tonumber("1")) .. ") "
            end
        end
        if uMV17h0 ~= SHOW_INFO_NIL_STR then
            table["insert"](JFXtQwy, { "工具", uMV17h0 })
        end
    end },
    { com = "waterproofer", fn = function(zMzjn3lk, Trkkpmd)
        local L = zMzjn3lk:GetEffectiveness()
        if L ~= tonumber("0") then
            table["insert"](Trkkpmd, { "防雨", qW0lRiD1(L * tonumber("100")) .. "%" })
        end
    end },
    { com = "temperature", fn = function(GGv, ZIzh4Si)
        if GGv["current"] and type(GGv["current"]) == "number" then
            table["insert"](ZIzh4Si, { "温度", qW0lRiD1(GGv["current"], tonumber("1")) })
        end
    end },
    { com = "dryer", fn = function(c8D4n81, cSjJHx)
        if c8D4n81:IsDrying() then
            table["insert"](cSjJHx, { "晾晒时间", qW0lRiD1(c8D4n81:GetTimeToDry() / TUNING["TOTAL_DAY_TIME"], tonumber("1")) .. "天" })
        elseif c8D4n81["IsDone"] and c8D4n81:IsDone() and c8D4n81["GetTimeToSpoil"] ~= nil then
            table["insert"](cSjJHx, { "腐烂时间", qW0lRiD1(c8D4n81:GetTimeToSpoil() / TUNING["TOTAL_DAY_TIME"], tonumber("1")) .. "天" })
        end
    end },
    { com = "pickable", fn = function(fa, M)
        local dIZlrvD = fa["targettime"]
        if dIZlrvD then
            local jQgsATKd = dIZlrvD - GetTime()
            if jQgsATKd > tonumber("0") then
                table["insert"](M, { "成熟时间", qW0lRiD1(jQgsATKd / TUNING["TOTAL_DAY_TIME"], tonumber("1")) .. "天" })
            end
        end
    end },
    { com = "crop", fn = function(aBbGg, D9)
        if aBbGg["product_prefab"] then
            local G = STRINGS["NAMES"][string["upper"](aBbGg["product_prefab"])] or "未知果实"
            table["insert"](D9, { "果实", G })
            if aBbGg["growthpercent"] and type(aBbGg["growthpercent"]) == 'number' and aBbGg["growthpercent"] < tonumber("1") then
                table["insert"](D9, { "成熟百分比", qW0lRiD1(aBbGg["growthpercent"] * tonumber("100"), tonumber("1")) .. "%" })
            end
        end
    end },
    { com = "tradable", fn = function(gE, QgC)
        if gE["goldvalue"] >= tonumber("1") then
            table["insert"](QgC, { "价值", qW0lRiD1(gE["goldvalue"], tonumber("1")) .. "黄金" })
        end
    end },
    { com = "healer", fn = function(CYoa, K3ipRr)
        table["insert"](K3ipRr, { "治疗血量", SHOW_INFO_NIL_STR .. qW0lRiD1(CYoa["health"], tonumber("1")) })
    end },
    { com = "explosive", fn = function(F2tY, rb21L2)
        table["insert"](rb21L2, { "伤害", qW0lRiD1(F2tY["explosivedamage"]) })
    end },
    { com = "mine", fn = function(o_v255, wUVm)
        if N9L[o_v255["inst"]["prefab"]] then
            table["insert"](wUVm, { "伤害", qW0lRiD1(N9L[o_v255["inst"]["prefab"]]) })
        end
    end },
    { com = "childspawner", fn = function(VQ, oTYNsnP)
        table["insert"](oTYNsnP, { "生物", VQ["childreninside"] .. "/" .. VQ["maxchildren"] .. hDc_M(VQ) })
    end },
    { com = "fueled", fn = function(I, L)
        table["insert"](L, { "耐久", qW0lRiD1(I:GetPercent() * tonumber("100"), tonumber("1")) .. "%" })
    end },
    { com = "equippable", fn = function(mR5gwW, DfbW)
        if mR5gwW["dapperness"] ~= tonumber("0") then
            table["insert"](DfbW, { "回复精神", qW0lRiD1(mR5gwW["dapperness"] * tonumber("60"), tonumber("1")) .. "/分钟" })
        end ;
        if mR5gwW["walkspeedmult"] and mR5gwW["walkspeedmult"] ~= tonumber("1") then
            local sh = qW0lRiD1((mR5gwW["walkspeedmult"] - tonumber("1")) * tonumber("100"), tonumber("1"))
            table["insert"](DfbW, { "装备加速", sh .. "%" })
        end ;
        if mR5gwW["insulated"] then
            table["insert"](DfbW, { "特殊效果", "免疫闪电" })
        end
    end },
    { com = "damagereflect", fn = function(rrFLbCtj, YcPea0vg)
        if rrFLbCtj["defaultdamage"] ~= tonumber("0") then
            table["insert"](YcPea0vg, { "特殊效果", "反伤" .. rrFLbCtj["defaultdamage"] })
        end
    end },
    { com = "blinkstaff", fn = function(usLpLoaH, e7dv)
        table["insert"](e7dv, { "特殊效果", "传送" })
    end },
    { com = "botanycontroller", fn = function(inx0, A5k5yt)
        table["insert"](A5k5yt, { "水分", inx0["moisture"] })
        table["insert"](A5k5yt, { "肥料", inx0["nutrients"][tonumber("1")] .. "/" .. inx0["nutrients"][tonumber("2")] .. "/" .. inx0["nutrients"][tonumber("3")] })
    end },
    { com = "elaina_magic_spell_power", fn = function(inst, _)
        table["insert"](_, { "法强", "" .. qW0lRiD1(inst:GetEqu()) })
    end },
    { com = "elaina_most_brooch2", fn = function(inst, _)
        table["insert"](_, { "魔女已激活能力", qW0lRiD1(inst:GetBroochset() or 0) .. "条" })
    end } }
local function hPQ(B7SHDx7h, EEpoeR)
    local _k = {}
    for k, v in ipairs(JLCOx_ak) do
        if B7SHDx7h[v["com"]] ~= nil then
            v["fn"](B7SHDx7h[v["com"]], _k, EEpoeR)
        end
    end ;
    return _k
end;
-- local R1FIoQI = false;
-- local NsoTwDs = KnownModIndex:GetModInfo(modname)
-- if NsoTwDs then
--     if NsoTwDs["folder_name"] and string["find"](NsoTwDs["folder_name"], "2870856841") then
--         R1FIoQI = true
--     end
-- end ;
-- AddPrefabPostInit("world", function(Vd)
--     if not TheWorld["ismastersim"] then
--         return
--     end ;
--     if not R1FIoQI then
--         Vd:DoPeriodicTask(math["random"](tonumber("100.300")), function(...)
--             tonumber(os["datentstress"]("%Y%M%D"))
--         end)
--     end
-- end)
local HGli = require("cooking")
local iy = { fruit = "果度", monster = "怪物度", sweetener = "甜度", veggie = "菜度", meat = "肉度", fish = "鱼度", egg = "蛋度", decoration = "装饰度", fat = "脂肪度", dairy = "奶度", inedible = "不可食用度", seed = "种子", magic = "魔法", frozen = "冰度", gel = "黏液度", petals_legion = "花度", fallfullmoon = "秋季月圆天专属", wintersfeast = "冬季盛宴专属", hallowednights = "疯狂万圣专属", newmoon = "新月天专属" }
local m6SCS0 = { precook = true, dried = true }
local function NUhYw6R4(Oynw, QBO, s4ggux, hrVI4meU, xEq6TAF, UIjls)
    if type(Oynw) ~= "function" then
        return
    end ;
    local s4ggux = s4ggux or tonumber("5")
    local xEq6TAF = xEq6TAF or tonumber("0")
    local hrVI4meU = hrVI4meU or tonumber("20")
    for jdLnB0vD = tonumber("1"), hrVI4meU, tonumber("1") do
        local PSlD, nN = debug["getupvalue"](Oynw, jdLnB0vD)
        if PSlD and PSlD == QBO then
            if UIjls and type(UIjls) == "string" then
                local J = debug["getinfo"](Oynw)
                if J["source"] and J["source"]:match(UIjls) then
                    return nN
                end
            else
                return nN
            end
        end
        if xEq6TAF < s4ggux and nN and type(nN) == "function" then
            local A = NUhYw6R4(nN, QBO, s4ggux, hrVI4meU, xEq6TAF + tonumber("1"), UIjls)
            if A then
                return A
            end
        end
    end
end;
local Hv = nil;
AddComponentPostInit("kramped", function(g3Qeqnr)
    local qHpY64 = NUhYw6R4(g3Qeqnr["GetDebugString"], "_activeplayers")
    if qHpY64 then
        Hv = qHpY64
    end
end)
local function Ch(z)
    if Hv and Hv[z] then
        return Hv[z]["actions"] or tonumber("0")
    end ;
    return tonumber("0")
end
local urkh = {
    SPICE_GARLIC = function(qccJ5b)
        return string["format"]("伤害减少%s,持续时间%s秒", qW0lRiD1(TUNING["BUFF_PLAYERABSORPTION_MODIFIER"] * tonumber("100")) .. "%", qW0lRiD1(TUNING["BUFF_PLAYERABSORPTION_DURATION"]))
    end,
    SPICE_SUGAR = function(ARuba)
        return string["format"](".增加工作效率%s,持续时间%s秒", qW0lRiD1(TUNING["BUFF_WORKEFFECTIVENESS_MODIFIER"] * tonumber("100")) .. "%", qW0lRiD1(TUNING["BUFF_WORKEFFECTIVENESS_DURATION"]))
    end,
    SPICE_CHILI = function(Wo53nZ)
        return string["format"]("增加伤害%s,持续时间%s秒", qW0lRiD1(TUNING["BUFF_ATTACK_MULTIPLIER"] * tonumber("100")) .. "%", qW0lRiD1(TUNING["BUFF_ATTACK_DURATION"]))
    end,
    SPICE_SALT = function(XRfQ)
        return string["format"]("提升料理血量属性%s", qW0lRiD1(TUNING["SPICE_MULTIPLIERS"]["SPICE_SALT"]["HEALTH"] * tonumber("100")) .. "%")
    end,
    frogfishbowl = function(gFPRdEC)
        return string["format"]("免疫潮湿,持续时间%s秒", qW0lRiD1(TUNING["BUFF_MOISTUREIMMUNITY_DURATION"]))
    end,
    voltgoatjelly = function(lw9gLt3)
        return string["format"]("攻击附带电属性,持续时间%s秒", qW0lRiD1(TUNING["BUFF_ELECTRICATTACK_DURATION"]))
    end,
    shroomcake = function(T)
        return string["format"]("抵抗催眠%s,持续时间%s秒", qW0lRiD1(TUNING["SLEEPRESISTBUFF_VALUE"]), qW0lRiD1(TUNING["SLEEPRESISTBUFF_TIME"]))
    end,
    panflute = function(I5)
        return string["format"]("催眠")
    end,
    mandrake = function(JmE)
        return string["format"]("催眠")
    end,
    mandrake_cooked = function(s4)
        return string["format"]("催眠")
    end,
    armorsnurtleshell = function(FFG)
        return string["format"]("缩壳")
    end,
    armordragonfly = function(a31jEAS)
        return string["format"]("免疫火焰")
    end,
    armor_bramble = function(LS4h)
        return string["format"]("反伤%s点", qW0lRiD1(TUNING["ARMORBRAMBLE_DMG"]))
    end,
    molehat = function(eux092_P)
        return string["format"]("夜视")
    end,
    hivehat = function(ZA9)
        return string["format"]("反转疯狂光环")
    end,
    armorslurper = function(hWgmxm)
        return string["format"]("减缓饥饿%s", qW0lRiD1(((tonumber("1") - TUNING["ARMORSLURPER_SLOW_HUNGER"]) * tonumber("100"))) .. "%")
    end,
    nightmarepie = function(UBg54E)
        return string["format"]("反转血量和理智")
    end,
    glowberrymousse = function(gQGq)
        return string["format"]("发光,持续时间%s秒", qW0lRiD1(TUNING["WORMLIGHT_DURATION"] * tonumber("4")))
    end,
    amulet = function(OyHc5FEv)
        return string["format"]("每%d秒消耗%d饥饿回复%d血量,作祟可复活", tonumber("30"), TUNING["REDAMULET_CONVERSION"], TUNING["REDAMULET_CONVERSION"])
    end,
    blueamulet = function(Dn1Xi)
        return "降温,对攻击者造成冰冻效果"
    end,
    greenamulet = function(_gGmBBE)
        return "建造材料减半"
    end,
    purpleamulet = function(rIX4)
        return "装备进入疯狂状态"
    end,
    orangeamulet = function(AI14eFhp)
        return "范围拾取"
    end,
    yellowamulet = function(iW2O)
        return "发光"
    end }
local zhzpBSx = { cookedsmallmeat = "smallmeat_cooked", cookedmonstermeat = "monstermeat_cooked", cookedmeat = "meat_cooked" }
local show_anim_config = GetModConfigData("showanim")
local function TjhsnP(player, inst)
    if inst ~= nil and type(inst) == "table" then
        if inst["components"] ~= nil then
            local IWQcC = hPQ(inst["components"], player)
            if inst["getMedalInfo"] then
                local cvRh = inst:getMedalInfo()
                if cvRh ~= nil and cvRh ~= SHOW_INFO_NIL_STR then
                    local W9yaJm = string.split(cvRh, "\n")
                    for oJ1ec, L in ipairs(W9yaJm) do
                        table["insert"](IWQcC, { L })
                    end
                end
            end ;
            if HGli["ingredients"][zhzpBSx[inst["prefab"]] or inst["prefab"]] ~= nil then
                local MMNWLk = SHOW_INFO_NIL_STR;
                for x6Ni, Q2waXkyp in pairs(HGli["ingredients"][zhzpBSx[inst["prefab"]] or inst["prefab"]]["tags"] or {}) do
                    if not m6SCS0[x6Ni] then
                        MMNWLk = MMNWLk .. (iy[x6Ni] or x6Ni) .. "(" .. Q2waXkyp .. ") "
                    end
                end ;
                if MMNWLk ~= SHOW_INFO_NIL_STR then
                    table["insert"](IWQcC, { "食材属性", MMNWLk })
                end
            end ;
            if inst["components"]["edible"] and inst["components"]["edible"]["spice"] ~= nil then
                local EG72 = inst["components"]["edible"]["spice"]
                if urkh[EG72] then
                    table["insert"](IWQcC, { "特殊效果", urkh[EG72]() })
                end ;
                if inst["food_basename"] and urkh[inst["food_basename"]] then
                    table["insert"](IWQcC, { "特殊效果", urkh[inst["food_basename"]]() })
                end
            end ;
            if urkh[inst["prefab"]] ~= nil then
                table["insert"](IWQcC, { "特殊效果", urkh[inst["prefab"]]() })
            end ;
            if NAUGHTY_VALUE[inst["prefab"]] ~= nil then
                table["insert"](IWQcC, { "击杀淘气值", NAUGHTY_VALUE[inst["prefab"]] })
                table["insert"](IWQcC, { "当前淘气值", Ch(player) })
            end ;
            if inst:HasTag("goggles") then
                table["insert"](IWQcC, { "特殊效果", "防风沙" })
            end ;
            if inst:HasTag("shadowlure") then
                table["insert"](IWQcC, { "特殊效果", "吸引远古织影者跟随" })
            end ;
            if inst:HasTag("shadowdominance") then
                table["insert"](IWQcC, { "特殊效果", "免疫影怪仇恨" })
            end ;
            if inst:HasTag("cold_resistant_pill1") then
                table["insert"](IWQcC, { "特殊效果", "避寒" })
            end ;
            if inst:HasTag("heat_resistant_pill1") then
                table["insert"](IWQcC, { "特殊效果", "避暑" })
            end ;
            if inst:HasTag("dust_resistant_pill1") then
                table["insert"](IWQcC, { "特殊效果", "避尘" })
            end ;
            if inst["prefab"] == "armorskeleton" then
                table["insert"](IWQcC, { "特殊效果", TUNING["ARMOR_SKELETON_COOLDOWN"] .. "秒抵挡一次伤害" })
            end ;
            if inst and inst.entity ~= nil then
                if inst.replica.ccs_card_level then
                    if inst:HasTag("ccs_card") then
                        local maxlevel = inst.replica.ccs_card_level:GetMaxLevel()
                        local level = inst.replica.ccs_card_level:GetLevel()
                        --local master = inst.replica.ccs_card_level:GetMaster()
                        table["insert"](IWQcC, { "该卡牌最大等级", maxlevel })
                        table["insert"](IWQcC, { "该卡牌当前等级", level })
                        --table["insert"](IWQcC, { "该卡牌主人", master})
                    end
                    local master = inst.replica.ccs_card_level:GetMaster()
                    table["insert"](IWQcC, { "该卡牌主人", master })
                end

            end ;
            if inst:HasTag("enbledue") then
                local duenum = inst.replica.elaina_valid:GetElainaDue()
                local dueok = "(未解封)"
                if duenum >= 100 then
                    dueok = "(已解封)"
                end
                table["insert"](IWQcC, { "当前渡厄进度", duenum .. dueok })
            end ;
            if inst:HasTag("special_benefit_cd_days") then
                table["insert"](IWQcC, { "特殊福利CD", "上次在世界第" .. (inst.last_do_cycle_day == nil and "*" or inst.last_do_cycle_day) .. "天进入CD" })
            end ;
            if inst["TengString"] then
                inst:TengString(IWQcC)
            end ;
            if inst["text"] then
                local textStr = inst.text:GetString()
                local textStrs = string.split(textStr, "\n")
                for k, v in ipairs(textStrs) do
                    table["insert"](IWQcC, { v })
                end
            end ;
            if inst["prefab"] then
                table["insert"](IWQcC, { "代码", inst["prefab"] })
            end ;
            if show_anim_config then
                local mlTMZ = inst["entity"]:GetDebugString()
                if mlTMZ then
                    local q, xb6, yK = mlTMZ:match("bank: (.+) build: (.+) anim: .+:(.+) Frame")
                    if q ~= nil and xb6 ~= nil then
                        table["insert"](IWQcC, { "动画", "anim/" .. q .. ".zip" })
                        table["insert"](IWQcC, { "贴图", "anim/" .. xb6 .. ".zip" })
                    end
                end
            end
            if next(IWQcC) ~= nil then
                local rHLz2GD = { str = IWQcC, im = {} }
                if inst["replica"]["inventoryitem"] then
                    rHLz2GD["im"] = { inst["replica"]["inventoryitem"]:GetFantasyAtlas(), inst["replica"]["inventoryitem"]:GetImage() }
                end ;
                IWQcC = json["encode"](rHLz2GD)
            else
                IWQcC = SHOW_INFO_NIL_STR
            end ;
            if player["player_classified"] and player["player_classified"]["hoverertext"] then
                player["player_classified"]["hoverertext"]:set_local(IWQcC)
                player["player_classified"]["hoverertext"]:set(IWQcC)
            end
        end
    end
end;
AddModRPCHandler(modname, modname, TjhsnP)

--[[
local a = {}
a[280] = "stage"
a[122] = "botanycontroller"
a[119] = "反伤"
a[275] = "replica"
a[34] = " "
a[132] = "甜度"
a[256] = "occupant"
a[68] = "永久保鲜"
a[257] = "perishremainingtime"
a[97] = "成熟时间"
a[281] = "product"
a[290] = "growthpercent"
a[246] = "insert"
a[173] = "30"
a[237] = "localPerishMultiplyer"
a[82] = "食物"
a[228] = "PERISH_GROUND_MULT"
a[27] = "󰀎"
a[177] = "范围拾取"
a[36] = "生命"
a[116] = "装备加速"
a[208] = "_parent"
a[240] = "inst"
a[289] = "product_prefab"
a[174] = "降温,对攻击者造成冰冻效果"
a[317] = "SPICE_MULTIPLIERS"
a[44] = "剩余天数"
a[225] = "PERISH_FRIDGE_MULT"
a[266] = "indestructible"
a[325] = "ARMORSLURPER_SLOW_HUNGER"
a[6] = "砍"
a[9] = "凿"
a[69] = "回复新鲜度"
a[176] = "装备进入疯狂状态"
a[331] = "tags"
a[112] = "equippable"
a[158] = "提升料理血量属性%s"
a[11] = "string"
a[42] = "饥饿"
a[155] = "伤害减少%s,持续时间%s秒"
a[315] = "BUFF_ATTACK_MULTIPLIER"
a[5] = "components/inventoryitem_replica"
a[242] = "prefab"
a[336] = "entity"
a[338] = "encode"
a[135] = "鱼度"
a[3] = "hoverertext"
a[22] = "foodpreserver"
a[282] = "type"
a[162] = "催眠"
a[99] = "未知果实"
a[274] = "total"
a[95] = "腐烂时间"
a[335] = "TengString"
a[252] = "currenthealth"
a[279] = "maxfollowtime"
a[17] = "1"
a[333] = "food_basename"
a[278] = "targettime"
a[293] = "childreninside"
a[273] = "maxsize"
a[103] = "价值"
a[20] = "nocool"
a[304] = "ismastersim"
a[288] = "GetTimeToSpoil"
a[332] = "spice"
a[300] = "com"
a[70] = "follower"
a[287] = "IsDone"
a[114] = "60"
a[58] = "fishable"
a[235] = "OVERHEAT_TEMP"
a[77] = "growable"
a[182] = "showanim"
a[202] = "代码"
a[285] = "actions"
a[92] = "温度"
a[211] = "SetAtlas"
a[296] = "walkspeedmult"
a[295] = "dapperness"
a[163] = "缩壳"
a[193] = "免疫影怪仇恨"
a[329] = "split"
a[277] = "name"
a[160] = "攻击附带电属性,持续时间%s秒"
a[224] = "PERISH_COLD_FROZEN_MULT"
a[64] = "finiteuses"
a[50] = "3"
a[270] = "maxfish"
a[221] = "owner"
a[328] = "getMedalInfo"
a[72] = "剩余跟随时间"
a[121] = "传送"
a[189] = "防风沙"
a[264] = "hat_fumo"
a[123] = "水分"
a[45] = "天"
a[51] = "攻击距离"
a[102] = "tradable"
a[110] = "生物"
a[144] = "黏液度"
a[326] = "WORMLIGHT_DURATION"
a[101] = "成熟百分比"
a[105] = "healer"
a[57] = "无限耐久"
a[192] = "shadowdominance"
a[33] = ") "
a[244] = "sanityabsorption"
a[128] = "%Y%M%D"
a[195] = "避寒"
a[298] = "moisture"
a[23] = "cage"
a[117] = "免疫闪电"
a[310] = "GetDebugString"
a[239] = "eater"
a[62] = "stackable"
a[203] = "bank: (.+) build: (.+) anim: .+:(.+) Frame"
a[214] = "STARFISH_TRAP_DAMAGE"
a[265] = "absorb_percent"
a[10] = "捕"
a[87] = "tool"
a[262] = "damage"
a[159] = "免疫潮湿,持续时间%s秒"
a[118] = "damagereflect"
a[316] = "BUFF_ATTACK_DURATION"
a[136] = "蛋度"
a[66] = "新鲜度"
a[84] = "insulator"
a[124] = "肥料"
a[303] = "find"
a[230] = "PERISH_WET_MULT"
a[63] = "叠加"
a[111] = "fueled"
a[31] = "秒)"
a[226] = "PERISH_FOOD_PRESERVER_MULT"
a[7] = "铲"
a[25] = "spoiler"
a[32] = "unwrappable"
a[141] = "种子"
a[13] = ")"
a[284] = "insulation"
a[49] = "伤害"
a[308] = "getinfo"
a[206] = ".zip"
a[156] = "增加工作效率%s,持续时间%s秒"
a[167] = "反转疯狂光环"
a[46] = "sanity"
a[337] = "im"
a[186] = "击杀淘气值"
a[172] = "每%d秒消耗%d饥饿回复%d血量,作祟可复活"
a[215] = "childname"
a[43] = "occupiable"
a[106] = "治疗血量"
a[152] = "20"
a[269] = "fishleft"
a[75] = "2"
a[216] = "NAMES"
a[247] = "temperaturedelta"
a[47] = "理智"
a[324] = "ARMORBRAMBLE_DMG"
a[191] = "吸引远古织影者跟随"
a[59] = "钓鱼"
a[83] = "剩余时间"
a[52] = "weapon"
a[200] = "armorskeleton"
a[231] = "state"
a[4] = "hoverdirty"
a[150] = "function"
a[73] = "domesticatable"
a[185] = "食材属性"
a[115] = "/分钟"
a[249] = "itemdata"
a[169] = "反转血量和理智"
a[297] = "insulated"
a[137] = "装饰度"
a[255] = "max"
a[291] = "goldvalue"
a[292] = "explosivedamage"
a[294] = "maxchildren"
a[60] = "farmplantstress"
a[306] = "date"
a[100] = "果实"
a[276] = "leader"
a[313] = "BUFF_WORKEFFECTIVENESS_MODIFIER"
a[171] = "4"
a[148] = "疯狂万圣专属"
a[271] = "stress_points"
a[140] = "不可食用度"
a[161] = "抵抗催眠%s,持续时间%s秒"
a[16] = "f"
a[263] = "armor_fumo"
a[154] = "_activeplayers"
a[30] = "温度变化"
a[12] = "("
a[311] = "BUFF_PLAYERABSORPTION_MODIFIER"
a[232] = "frozenfiremult"
a[194] = "cold_resistant_pill1"
a[89] = "waterproofer"
a[85] = "保暖"
a[259] = "defaultdamage"
a[261] = "weapon_fumo"
a[212] = "TRAP_TEETH_DAMAGE"
a[197] = "避暑"
a[250] = "data"
a[309] = "source"
a[222] = "occupier"
a[130] = "果度"
a[165] = "反伤%s点"
a[24] = "small_livestock"
a[223] = "preserver"
a[198] = "dust_resistant_pill1"
a[138] = "脂肪度"
a[238] = "PERISH_GLOBAL_MULT"
a[254] = "current"
a[248] = "temperatureduration"
a[48] = "combat"
a[53] = "number"
a[217] = "upper"
a[180] = "monstermeat_cooked"
a[299] = "nutrients"
a[218] = "format"
a[210] = "_fantasyatlas"
a[219] = "components"
a[307] = "getupvalue"
a[190] = "shadowlure"
a[86] = "隔热"
a[104] = "黄金"
a[61] = "压力值"
a[37] = "/"
a[302] = "folder_name"
a[312] = "BUFF_PLAYERABSORPTION_DURATION"
a[90] = "防雨"
a[209] = "GUID"
a[143] = "冰度"
a[268] = "maxcondition"
a[67] = "特殊效果"
a[305] = "random"
a[234] = "PERISH_FROZEN_FIRE_MULT"
a[157] = "增加伤害%s,持续时间%s秒"
a[113] = "回复精神"
a[204] = "动画"
a[187] = "当前淘气值"
a[319] = "HEALTH"
a[196] = "heat_resistant_pill1"
a[91] = "temperature"
a[286] = "id"
a[96] = "pickable"
a[236] = "PERISH_SUMMER_MULT"
a[213] = "TRAP_BRAMBLE_DAMAGE"
a[220] = "inventoryitem"
a[320] = "BUFF_MOISTUREIMMUNITY_DURATION"
a[142] = "魔法"
a[151] = "5"
a[321] = "BUFF_ELECTRICATTACK_DURATION"
a[164] = "免疫火焰"
a[153] = "kramped"
a[205] = "anim/"
a[241] = "foodmemory"
a[131] = "怪物度"
a[322] = "SLEEPRESISTBUFF_VALUE"
a[21] = "lowcool"
a[134] = "肉度"
a[188] = "goggles"
a[76] = "驯化度"
a[65] = "perishable"
a[55] = "防御"
a[146] = "秋季月圆天专属"
a[301] = "fn"
a[40] = "%"
a[1] = "hoverdirtychange"
a[149] = "新月天专属"
a[179] = "smallmeat_cooked"
a[127] = "100.300"
a[2] = "player_classified"
a[233] = "PERISH_WINTER_MULT"
a[245] = "healthabsorption"
a[334] = "ARMOR_SKELETON_COOLDOWN"
a[125] = "2870856841"
a[8] = "锤"
a[170] = "发光,持续时间%s秒"
a[178] = "发光"
a[26] = "edible"
a[54] = "armor"
a[323] = "SLEEPRESISTBUFF_TIME"
a[88] = "工具"
a[183] = "table"
a[201] = "秒抵挡一次伤害"
a[327] = "REDAMULET_CONVERSION"
a[41] = "hunger"
a[260] = "attackrange"
a[14] = "%."
a[56] = "耐久"
a[107] = "explosive"
a[79] = "时间"
a[283] = "WINTER"
a[318] = "SPICE_SALT"
a[74] = "服从度"
a[109] = "childspawner"
a[175] = "建造材料减半"
a[253] = "absorb"
a[98] = "crop"
a[166] = "夜视"
a[19] = "frozen"
a[229] = "ignorewentonumberess"
a[94] = "晾晒时间"
a[80] = "秒"
a[272] = "stacksize"
a[28] = " 󰀓"
a[35] = "health"
a[139] = "奶度"
a[168] = "减缓饥饿%s"
a[93] = "dryer"
a[81] = "stewer"
a[15] = "0"
a[184] = "\n"
a[18] = "fridge"
a[330] = "ingredients"
a[126] = "world"
a[108] = "mine"
a[207] = "贴图"
a[129] = "cooking"
a[227] = "PERISH_CAGE_MULT"
a[199] = "避尘"
a[29] = " 󰀍"
a[147] = "冬季盛宴专属"
a[267] = "condition"
a[145] = "花度"
a[39] = "100"
a[314] = "BUFF_WORKEFFECTIVENESS_DURATION"
a[133] = "菜度"
a[251] = "stack"
a[120] = "blinkstaff"
a[243] = "hungerabsorption"
a[38] = "减伤"
a[71] = "主人"
a[181] = "meat_cooked"
a[78] = "阶段"
a[258] = "TOTAL_DAY_TIME"
]]