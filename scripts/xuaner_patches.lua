if GetModConfigData("xuaner_packer_limit_switch") then

    AddComponentPostInit("myxl_packer", function(self)
        local oldCanPack = self.CanPack
        function self:CanPack(target, ...)
            if target:HasTag("multiplayer_portal") --天体门
                    or target.components.health
                    or testCantPackItem(target.prefab,TUNING.CANT_PACK_ITEMS)
            then
                return false;
            end
            return oldCanPack(self, target, ...)
        end
    end)

end

