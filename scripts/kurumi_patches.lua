if GetModConfigData("kurumi_packer_limit_switch") then
    local packPostInit = function(inst)
        local oldCanPackFn = inst.CanPackTest
        inst.CanPackTest = function(inst, target)
            if testCantPackItem(target,TUNING.CANT_PACK_ITEMS) then
                return false;
            end
            return oldCanPackFn(inst, target);

        end

    end
    AddPrefabPostInit("krm_key", packPostInit)
end

