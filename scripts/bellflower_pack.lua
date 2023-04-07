AddComponentPostInit("sorafl", function(self)
    local oldInit = self.Init;
    function self:Init()
        if not self.has then
            local fl = GLOBAL.SpawnPrefab("sora_fl")
            fl.components.sorabind:Bind(self.inst.userid)
            local pack = GLOBAL.SpawnPrefab("sorapacker")
            local valid = false;
            if pack and pack.components.sorapacker:Pack(fl, self.inst, true) then
                self.inst.components.inventory:GiveItem(pack)
                valid = true
            end
            if valid then
                self.has = true
                return fl
            else
                if fl and fl.Remove then
                    fl:Remove()
                end
                if pack and pack.Remove then
                    pack:Remove()
                end
                return oldInit(self)
            end
        end
    end
end)
