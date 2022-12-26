AddSimPostInit(function()
    if ElainaAPI then
        ElainaAPI.MakeCharacterSkin("elaina", "elaina_xd", {
            name = "伊蕾娜",
            des = "没错，就是我！",
            quotes = "有一位魔女坐着扫帚飞在空中，灰色头发在风中飘逸,这位像洋娃娃一般漂亮又可爱，连夏天的当空烈日见了都会放出更炙热光芒的美女究竟是谁呢？没错，就是我！",
            rarity = "限时",
            rarityorder = 4,
            raritycorlor = {120 / 255, 215 / 255, 0 / 255, 1},
            release_group = 100,
            skins = {normal_skin = "elena", ghost_skin = "ghost_elena_build"},
            skin_tags = {"BASE", "elaina", "CHARACTER"},
            share_bigportrait_name = "elaina",
            build_name_override = "elaina"
        })
    end
end)
