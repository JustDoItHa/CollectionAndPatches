if GetModConfigData("word_migrate_drop_sync_switch") then
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

end

if GetModConfigData("character_word_forbidden_option") then

    if TUNING.MWP == nil then return end --多层世界模组没开
    local character_ban = GetModConfigData("character_word_forbidden_option")

    function TUNING.MWP.ShouldMigrate(player, worldId, ...)
            -- worldId = tonumber(worldId)
            if character_ban.worldId and table.contains(character_ban.worldId ,player.prefab) then 
                player:DoTaskInTime(0.1, function()
                    player.components.talker:Say("该人物无法到达该世界。")
                end)
                return false
            end
        return true
    end

end