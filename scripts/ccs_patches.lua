
local ccsPackLimit = GetModConfigData("ccs_packer_limit_switch") or false;

---魔法少女小樱打包限制
if ccsPackLimit then
    local packPostInit = function(inst)
        if inst and inst.components and inst.components.sorapacker then
            local oldCanPackFn = inst.components.ccs_pack.canpackfn
            inst.components.ccs_pack:SetCanPackFn(function(target, inst2)
                if testCantPackItem(target, TUNING.CANT_PACK_ITEMS) then
                    return false;
                else
                    return oldCanPackFn(target, inst2);
                end
            end)
        end
    end
    AddPrefabPostInit("ccs_pack", packPostInit)
end
