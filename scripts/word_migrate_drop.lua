local function migrate_drop(inst)
    inst:ListenForEvent("ms_playerdespawnandmigrate", function(inst, data)
        if data.player then
            if data.player.prefab == "yeyu" then
                data.player.nilxin_unique = nil
                -- data.player.components.inventory.DropItem = data.player.components.inventory.nil_DropItem
            end
            data.player.components.inventory:DropEverything()
            if data.player.components.leader ~= nil then
                local followers = data.player.components.leader.followers
                for k, v in pairs(followers) do
                    if k.components.inventory ~= nil then
                        k.components.inventory:DropEverything()
                    elseif k.components.container ~= nil then
                        k.components.container:DropEverything()
                    end
                end
            end
        end
    end)

end
AddPrefabPostInit("world", migrate_drop)

AddComponentPostInit("yyxk", function(self)
    self.additem = function(self, inst, n, ...)
        self.inst.components.talker:Say("该世界禁用")
    end
end)