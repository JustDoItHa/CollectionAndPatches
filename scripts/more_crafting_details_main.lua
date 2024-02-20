
local Widget = GLOBAL.require("widgets/widget")
local Image = GLOBAL.require("widgets/image")
local Text = GLOBAL.require("widgets/text")
local _T = GLOBAL.TUNING

local dataset = GLOBAL.require("screens/redux/scrapbookdata")
local dataset2 = {
    healingsalve = {health = _T.HEALING_MED}, bandage = { health = _T.HEALING_MEDLARGE},
    cane = {speed = _T.CANE_SPEED_MULT}, piggyback = {speed = _T.PIGGYBACK_SPEED_MULT}, icehat = {speed = _T.ICEHAT_SPEED_MULT},
    ruins_bat = {speed = _T.RUINS_BAT_SPEED_MULT}, armormarble = {speed = _T.ARMORMARBLE_SLOW},
    bedroll_straw = {health = _T.SLEEP_HEALTH_PER_TICK*0.5, dapperness = _T.SLEEP_SANITY_PER_TICK*2/3, hungervalue = _T.SLEEP_HUNGER_PER_TICK },
    bedroll_furry = {health = _T.SLEEP_HEALTH_PER_TICK, dapperness = _T.SLEEP_SANITY_PER_TICK, hungervalue = _T.SLEEP_HUNGER_PER_TICK },
    tent = {health = _T.SLEEP_HEALTH_PER_TICK*2, dapperness = _T.SLEEP_SANITY_PER_TICK, hungervalue = _T.SLEEP_HUNGER_PER_TICK },
    siestahut = {health = _T.SLEEP_HEALTH_PER_TICK*2, dapperness = _T.SLEEP_SANITY_PER_TICK, hungervalue = _T.SLEEP_HUNGER_PER_TICK/3 },
}

local wolfgang = { wimpy = 0.75, mighty = 2 }
local iconSize = 48; local iconSize_2 = iconSize/2; local gapX = 4; local gapY = 6;local fontSize = 24; local fontSize2 = 18;
local count = 0; local x = 0; local y = 0; local maxRows = 2;

local makeentry = function(widget,tex,text,atlas)
    if tex then
        local a = atlas or GLOBAL.GetScrapbookIconAtlas(tex) or GLOBAL.GetScrapbookIconAtlas("cactus.tex")
        local icon = widget:AddChild(Image(a, tex))
        icon:ScaleToSize(iconSize,iconSize)
        icon:SetPosition(x + iconSize_2, y - iconSize_2)
    end
    if text then
        local txt = widget:AddChild(Text(GLOBAL.HEADERFONT, fontSize, text, GLOBAL.UICOLOURS.WHITE))
        local tw, th = txt:GetRegionSize()
        txt:SetPosition(x + iconSize + gapX + (tw/2), y - iconSize_2 )
    end

    count = count + 1; y = y - iconSize - gapY;
end
local makesubentry = function(widget,text)
    local txt = widget:AddChild(Text(GLOBAL.HEADERFONT, fontSize2, text, GLOBAL.UICOLOURS.WHITE))
    local tw, th = txt:GetRegionSize()
    txt:SetPosition(x+iconSize + gapX + (tw/2), y+gapY+4)
end

local texs = {
    health = "icon_health.tex", sanityaura = "icon_sanity.tex", damage = "icon_damage.tex", stacksize = "icon_stack.tex",
    finiteuses = "icon_uses.tex", waterproofer = "icon_wetness.tex", dapperness = "icon_sanity.tex", perishable = "icon_spoil.tex",
    hungervalue = "icon_hunger.tex"
}
local format = {
    damage = function(v) return string.format("%.1f", v) end,
    dapperness = function(v) return string.format("%.2f", v) end,
    hungervalue = function(v) return string.format("%.2f", v) end,
    perishable = function(v) return v/60/8 end,
    waterproofer = function(v) return (v*100).."%" end,
}
local function GetFuelIcon(fuel)
    if fuel == GLOBAL.FUELTYPE.BURNABLE then
        return"icon_fuel_burnable.tex" --STRINGS.SCRAPBOOK.DATA_FUELTYPE .. data.fueltype .." ".. data.fuelvalue
    elseif fuel == GLOBAL.FUELTYPE.CAVE then
        return "icon_fuel_cavelight.tex"
    elseif fuel == GLOBAL.FUELTYPE.NIGHTMARE then
        return "icon_fuel_nightmare.tex"
    elseif fuel == GLOBAL.FUELTYPE.MAGIC then
        return "icon_fuel_magic.tex"
    elseif fuel == GLOBAL.FUELTYPE.CHEMICAL then
        return "icon_fuel_chemical.tex"
    elseif fuel == GLOBAL.FUELTYPE.WORMLIGHT then
        return "icon_fuel_wormlight.tex"
    end
    return false
end
local FNs = {
    planardamage = function (w,v,data)
        if not data.weapondamage or data.weapondamage==0 then
            makeentry(w,"icon_damage.tex",v)
            makesubentry(w,"("..v.." Planar)")
        end
    end,
    weapondamage = function (w,v,data)
        local real = v

        if (type(v) == "number") then
            v = string.format("%.1f", v)

            local pjName = GLOBAL.ThePlayer.prefab
            local dmgMult = string.upper(pjName).."_DAMAGE_MULT"
            real = v

            if pjName=="wolfgang" then
                local state = GLOBAL.ThePlayer.GetCurrentMightinessState and GLOBAL.ThePlayer:GetCurrentMightinessState()
                if state and wolfgang[state] then v = v * wolfgang[state] end
            elseif _T[dmgMult] then
                v = v * _T[dmgMult]
            end

            if data.planardamage then
                v = v + data.planardamage;
                real = "("..data.planardamage.." Planar)"
            end
        else
            v = " "
        end

        makeentry(w,"icon_damage.tex",v)
        makesubentry(w,real)
    end,
    armor = function (w,v,data)
        makeentry(w,"icon_armor.tex",v)
        if data.absorb_percent then makesubentry(w,(data.absorb_percent*100).. "%") end
    end,
    insulator = function (w,v,data)
        if data.insulator_type and data.insulator_type == GLOBAL.SEASONS.SUMMER then makeentry(w,"icon_heat.tex",v)
        else makeentry(w,"icon_cold.tex",v)
        end
    end,
    fueledrate = function (w,v,data)
        if not data.fueledmax then return end


        local days = math.floor((data.fueledmax/data.fueledrate)/60/8*100)/100; local icon
        if data.fueledtype1 then
            icon = GetFuelIcon(data.fueledtype1)
            if icon then makeentry(w,icon,days)
            elseif data.fueledtype1 == GLOBAL.FUELTYPE.USAGE then makeentry(w,"icon_clothing.tex",days)
            end
        end
    end,
    fueltype = function (w,v,data)
        if not data.fuelvalue then return end

        local icon = GetFuelIcon(data.fueltype)
        if icon then makeentry(w,icon,data.fuelvalue) end
    end,
    speed = function (w,v,data) makeentry(w,"arrow2_right.tex",v,"images/ui.xml") end
}
local rows = { grass_umbrella = 3, bedroll_straw = 3, bedroll_furry = 3 }

local function MakeDetails(data,widget,topY)
    for k, v in pairs(data) do
        if v~=0 then
            if format[k] then v=format[k](v) end

            if FNs[k] then FNs[k](widget,v,data) elseif texs[k] then makeentry(widget,texs[k],v) end

            if count == maxRows then x = 0; y = topY - gapY end
        end
    end
end
local function PopulateDetails(recipeName,widget,topY)
    count = 0; y = topY - gapY;
    maxRows = rows[recipeName] or 2
    iconSize = 96/maxRows; iconSize_2 = iconSize/2;

    -- if not dataset[recipeName].knownlevel or dataset[recipeName].knownlevel < 2 then makeentry(widget,x,false,"Needs to be examined")

    if dataset[recipeName] then MakeDetails(dataset[recipeName],widget,topY) end
    if dataset2[recipeName] then MakeDetails(dataset2[recipeName],widget,topY) end
    if _T.dataset and _T.dataset[recipeName] then MakeDetails(_T.dataset[recipeName],widget,topY) end
end
AddClassPostConstruct("widgets/redux/craftingmenu_details", function (craftingmenu_details)
    -- for prefab,data in pairs(dataset) do data.knownlevel = GLOBAL.TheScrapbookPartitions:GetLevelFor(prefab) end

    local old_PopulateRecipeDetailPanel = craftingmenu_details.PopulateRecipeDetailPanel
    function craftingmenu_details:PopulateRecipeDetailPanel(data, skin_name)
        old_PopulateRecipeDetailPanel(self, data, skin_name)

        if not GLOBAL.ThePlayer.HUD or not GLOBAL.ThePlayer.HUD:IsCraftingOpen() then return end

        if data == nil then return end
        local recipeName = data.recipe.name;

        local root_left = self:AddChild(Widget("left_root")); root_left:SetPosition(-self.panel_width / 4, 0)
        local wWidth = self.panel_width / 2;

        local topY = -102;
        -- Divider 2
        local line = root_left:AddChild(Image("images/ui.xml", "line_horizontal_white.tex"))
        line:SetPosition(0, topY)
        line:SetTint(GLOBAL.unpack(GLOBAL.BROWN)); line:ScaleToSize(wWidth, 4); line:MoveToBack()
        -- More Details
        x = -wWidth/2;
        PopulateDetails(recipeName,root_left,topY)
    end
end)