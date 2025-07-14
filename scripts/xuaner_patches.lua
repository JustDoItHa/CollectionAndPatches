if GetModConfigData("xuaner_packer_limit_switch") then

    AddComponentPostInit("myxl_packer", function(self)
        local oldCanPack = self.CanPack
        function self:CanPack(target, ...)
            if testCantPackItem(target,TUNING.CANT_PACK_ITEMS) then
                return false;
            end
            return oldCanPack(self, target, ...)
        end
    end)

end

