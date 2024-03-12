GLOBAL.setmetatable(env, { __index = function(t, k)
    return GLOBAL.rawget(GLOBAL, k)
end })

table.insert(PrefabFiles, "change_coconut")
table.insert(PrefabFiles, "change_light")
table.insert(PrefabFiles, "changelightfx")
table.insert(PrefabFiles, "change_tree")
table.insert(PrefabFiles, "change_jungletrees")
table.insert(PrefabFiles, "change_jungletreeseed")
table.insert(PrefabFiles, "change_lifeplant")
table.insert(PrefabFiles, "change_waterdrop")

table.insert(Assets, Asset("ATLAS", "images/inventoryimages/change_light.xml"))
table.insert(Assets, Asset("IMAGE", "images/inventoryimages/change_light.tex"))
table.insert(Assets, Asset("ATLAS", "images/inventoryimages/change_coconut.xml"))
table.insert(Assets, Asset("IMAGE", "images/inventoryimages/change_coconut.tex"))
table.insert(Assets, Asset("ATLAS", "images/map_icons/palmtree.xml"))
table.insert(Assets, Asset("IMAGE", "images/map_icons/palmtree.tex"))
table.insert(Assets, Asset("ATLAS", "images/inventoryimages/change_tree.xml"))
table.insert(Assets, Asset("IMAGE", "images/inventoryimages/change_tree.tex"))
table.insert(Assets, Asset("ATLAS", "images/inventoryimages/change_jungletreeseed.xml"))
table.insert(Assets, Asset("IMAGE", "images/inventoryimages/change_jungletreeseed.tex"))
table.insert(Assets, Asset("ATLAS", "images/inventoryimages/change_waterdrop.xml"))
table.insert(Assets, Asset("IMAGE", "images/inventoryimages/change_waterdrop.tex"))

-- 丛林树种子
AddRecipe2("change_jungletreeseed", {Ingredient("pinecone",2),Ingredient("bird_egg", 5),},
        TECH.SCIENCE_TWO,
        { min_spacing = 1, atlas = "images/inventoryimages/change_jungletreeseed.xml", image = "change_jungletreeseed.tex" },
        { "REFINE" })

-- 宫灯
AddRecipe2("change_light", {Ingredient("orangegem", 1),Ingredient("goldnugget", 10),Ingredient("log", 2),},
        TECH.SCIENCE_TWO,
        { placer = "change_light_placer", min_spacing = 1, atlas = "images/inventoryimages/change_light.xml", image = "change_light.tex" },
        { "LIGHT" })

--月桂树
AddRecipe2("change_tree", {Ingredient("moon_tree_blossom", 15),Ingredient("yellowgem", 5),Ingredient("livinglog", 10)},
        TECH.SCIENCE_TWO,
        { placer = "change_tree_placer", min_spacing = 1, atlas = "images/inventoryimages/change_tree.xml", image = "change_tree.tex" },
        { "LIGHT","STRUCTURES" })
--水仙花
AddRecipe2("change_waterdrop", {Ingredient("petals", 8),Ingredient("ice", 12)},
        TECH.SCIENCE_TWO,
        { min_spacing = 1, atlas = "images/inventoryimages/change_waterdrop.xml", image = "change_waterdrop.tex" },
        { "REFINE" })


RegisterInventoryItemAtlas("images/inventoryimages/change_light.xml", "change_light.tex")
AddMinimapAtlas("images/inventoryimages/change_light.xml")
RegisterInventoryItemAtlas("images/map_icons/palmtree.xml", "palmtree.tex")
AddMinimapAtlas("images/map_icons/palmtree.xml")