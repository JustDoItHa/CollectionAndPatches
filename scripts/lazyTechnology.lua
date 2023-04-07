local lazyTechKJKLimit = GetModConfigData("lazyTechKJKLimit") or false;
local lazyTechHDSelectOptimize = GetModConfigData("lazyTechHDSelectOptimize") or false;
if lazyTechKJKLimit then
    local disableKjk = function(inst)
        if inst.components.lrhc_wxnj then
            local isEquippable = inst.components.equippable ~= nil;
            local isWeapon = inst.components.weapon ~= nil;  --判断是不是武器
            local isArmor = inst.components.armor ~= nil; --判断是不是护甲
            local isBody = false;
            local isHead = false;
            if isEquippable then
                isBody = inst.components.equippable.equipslot == GLOBAL.EQUIPSLOTS.BODY;
                isHead = inst.components.equippable.equipslot == GLOBAL.EQUIPSLOTS.HEAD;
            end
            local isClothing = isEquippable and (isBody or isHead);
            local valid = false;
            if lazyTechKJKLimit == "equipment" then
                valid = isEquippable;
            elseif lazyTechKJKLimit == "weaponAndClothing" then
                valid = isWeapon or isClothing;
            elseif lazyTechKJKLimit == "clothing" then
                valid = isClothing;
            elseif lazyTechKJKLimit == "weapon" then
                valid = isWeapon;
            elseif lazyTechKJKLimit == "null" then
                valid = false;
            end
            if not valid and inst.components.lrhc_wxnj then
                inst:RemoveComponent('lrhc_wxnj')
            end
        end
    end
    AddPrefabPostInitAny(function(inst)
        if inst and inst.components.lrhc_wxnj then
            disableKjk(inst);
        end
    end)
end

if lazyTechHDSelectOptimize then
    local function lookforfuel(inst)
        local x, y, z = inst.Transform:GetWorldPosition()
        local chd = GLOBAL.TheSim:FindEntities(x, 0, z, 12, { "for_hclr_xdhd" }, { "INLIMBO" })
        for _, v in ipairs(chd) do
            if v
                    and v.components.container
                    and not v.components.container:IsEmpty()
                    and v.components.container:Has("hclr_xdhd_item", 1)
            then
                local fuelItem = v.components.container:FindItem(function(item)
                    return item.components.fuel
                end)
                if fuelItem then
                    if fuelItem.components.stackable then
                        fuelItem = fuelItem.components.stackable:Get()
                    end
                    inst.components.fueled:TakeFuelItem(fuelItem)
                    break
                end
            end
        end
    end
    local function Oncheck(inst)
        if inst.components.fueled:GetPercent() < 0.5 then
            lookforfuel(inst)
        end
    end
    AddPrefabPostInit("hclr_xdhd", function(inst)
        if inst.checkfuel then
            inst.checkfuel:Cancel();
            inst.checkfuel = inst:DoPeriodicTask(1, Oncheck, 1)
        end
    end)
end