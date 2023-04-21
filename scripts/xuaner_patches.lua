if GetModConfigData("xuaner_packer_limit_switch") then

    AddComponentPostInit("myxl_packer", function(self)
        local oldCanPack = self.CanPack
        function self:CanPack(target, ...)
            if target:HasTag("multiplayer_portal") --天体门
                or target.components.health
                or target.prefab == "pigking" --猪王
                or target.prefab == "antlion" --蚁狮
                or target.prefab == "crabking" --帝王蟹
                or target.prefab == "beequeenhivegrown" --蜂王窝-底座
                or target.prefab == "statueglommer" --格罗姆雕像
                or target.prefab == "oasislake" --绿洲
                or target.prefab == "archive_switch"--档案馆华丽的基座
                or target.prefab == "archive_portal"--档案馆传送门
                or target.prefab == "archive_lockbox_dispencer"--知识饮水器
                or target.prefab == "archive_centipede"--远古哨兵蜈蚣
                or target.prefab == "archive_centipede_husk"--远古哨兵壳
                or target.prefab == "atrium_gate"--远古大门
                or target.prefab == "monkeyqueen"--月亮码头女王
                or target.prefab == "monkeyisland_portal"--非自然传送门

                or target.prefab == "toadstool_cap"--毒菌蟾蜍蘑菇

                or target.prefab == "elecourmaline" --电器台
                or target.prefab == "elecourmaline_keystone" --
                or target.prefab == "moondungeon" --月的地下城
                or target.prefab == "siving_thetree" --子圭神木岩

                or target.prefab == "myth_rhino_desk"--三犀牛台
                or target.prefab == "myth_chang_e"--嫦娥
                or target.prefab == "myth_store"--小店
                or target.prefab == "myth_store_construction"--未完成的小店
                or target.prefab == "myth_shop"--小店
                or target.prefab == "myth_shop_animals"
                or target.prefab == "myth_shop_foods"
                or target.prefab == "myth_shop_ingredient"
                or target.prefab == "myth_shop_numerology"
                or target.prefab == "myth_shop_plants"
                or target.prefab == "myth_shop_rareitem"
                or target.prefab == "myth_shop_weapons"

                or target.prefab == "medal_spacetime_devourer"--时空吞噬者

                or target.prefab == "star_monv"--星辰魔女
                or target.prefab == "elaina_npc_qp" --星辰魔女对话框

                or target.prefab == "ntex_other_lz" --逆天而行修仙龙柱
            then
                return false;
            end
            return oldCanPack(self, target, ...)
        end
    end)

end

