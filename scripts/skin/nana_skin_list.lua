GLOBAL.setmetatable(env, { __index = function(t, k)
    return GLOBAL.rawget(GLOBAL, k)
end, })

modimport("scripts/skin/skinsapi.lua")--调用皮肤api  来自穹



local teleportation_skin_list = --对应的皮肤
{
    { "teleportation", "t1", STRINGS.NANA_TELEPORT_MFM, "idle" },
    { "teleportation", "t2", STRINGS.NANA_TELEPORT_TYGGJ, "idle" },
    { "teleportation", "t3", STRINGS.NANA_TELEPORT_MSNLB, "idle" },
    { "teleportation", "t4", STRINGS.NANA_TELEPORT_HDT, "idle" },
    { "teleportation", "t5", STRINGS.NANA_TELEPORT_NWSFS, "idle" },
    { "teleportation", "t6", STRINGS.NANA_TELEPORT_KGLXZ, "idle" },
    { "teleportation", "t7", STRINGS.NANA_TELEPORT_T7, "idle" },
    { "teleportation", "t8", STRINGS.NANA_TELEPORT_T8, "idle" },
    { "teleportation", "t9", STRINGS.NANA_TELEPORT_T9, "idle" },
    { "teleportation", "t10", STRINGS.NANA_TELEPORT_T10, "idle" },
}

--开始注册:

--注册默认皮肤
MakeItemSkinDefaultData("teleportation", { atlas = "images/inventoryimages/teleportation.xml", image = "teleportation" }, { bank = "teleportation", build = "teleportation", anim = "idle", animloop = false })


for k, v in pairs(teleportation_skin_list) do
    MakeItemSkin(v[1], v[2], --原名和皮肤名
            {
                basebuild = v[1],    --原物品scml文件名字
                basebank = v[1],
                rarity = v[3], --珍惜度:没有什么意义,是啥都行,可以随便编一个
                type = "item",       --类别
                name = v[3],         --填皮肤的名称:经典,小熊,小猫,小狗什么的
                atlas = "images/inventoryimages/"..v[2]..".xml",  --制作栏的图片
                image = v[2],
                build = v[2],
                bank = v[2],
                anim = v[4],
            })
end