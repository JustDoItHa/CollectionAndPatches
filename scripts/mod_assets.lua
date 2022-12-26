
Assets = {
	-- 黑色法杖
	Asset( "ATLAS", "images/blackstaff.xml" ),
	Asset("IMAGE", "images/blackstaff.tex"),
	Asset("ANIM", "anim/blackstaff.zip"),
	Asset("ANIM", "anim/swap_blackstaff.zip"),

	-- 五格装备栏
	Asset("IMAGE", "modules/extra_equip_slots/images/back.tex"),
	Asset("ATLAS", "modules/extra_equip_slots/images/back.xml"),
	Asset("IMAGE", "modules/extra_equip_slots/images/neck.tex"),
	Asset("ATLAS", "modules/extra_equip_slots/images/neck.xml"),
	Asset("IMAGE", "modules/extra_equip_slots/images/inv_new.tex"),
    Asset("ATLAS", "modules/extra_equip_slots/images/inv_new.xml"),

	--全图定位
	Asset( "IMAGE", "minimap/campfire.tex" ),
	Asset( "ATLAS", "minimap/campfire.xml" ),
	Asset( "IMAGE", "images/status_bg.tex" ),
	Asset( "ATLAS", "images/status_bg.xml" ),
	Asset( "IMAGE", "images/sharelocation.tex" ),
	Asset( "ATLAS", "images/sharelocation.xml" ),
	Asset( "IMAGE", "images/unsharelocation.tex" ),
	Asset( "ATLAS", "images/unsharelocation.xml" ),


	--蘑菇农场增强
	Asset("ANIM", "anim/mushroom_farm_moon_build.zip"),
	Asset("ATLAS", "images/inventoryimages/spore_moon.xml"),

	--龙鳞冰炉
	Asset("ANIM", "anim/ui_chest_3x1.zip"),
	Asset("ANIM", "anim/ui_chest_3x2.zip"),
	Asset("ANIM", "anim/ui_chest_3x3.zip"),
	Asset("ANIM", "anim/ui_chester_shadow_3x4.zip"),
	Asset("ANIM", "anim/ui_tacklecontainer_3x5.zip"),
	Asset("IMAGE", "images/inventoryimages/icefurnace.tex"), Asset("ATLAS", "images/inventoryimages/icefurnace.xml"),
	Asset("IMAGE", "images/inventoryimages/icefurnace_antique.tex"), Asset("ATLAS", "images/inventoryimages/icefurnace_antique.xml"),
	Asset("IMAGE", "images/inventoryimages/icefurnace_crystal.tex"), Asset("ATLAS", "images/inventoryimages/icefurnace_crystal.xml"),
	Asset("IMAGE", "images/minimap/icefurnace.tex"), Asset("ATLAS", "images/minimap/icefurnace.xml"),

	--兔子喷泉
	Asset("IMAGE", "images/inventoryimages/change_fountain.tex"),
	Asset("ATLAS", "images/inventoryimages/change_fountain.xml"),
	--霓庭灯
	Asset("IMAGE", "images/inventoryimages/lamp_post.tex"),
	Asset("ATLAS", "images/inventoryimages/lamp_post.xml"),
	--虹庭灯
	Asset("IMAGE", "images/inventoryimages/lamp_short.tex"),
	Asset("ATLAS", "images/inventoryimages/lamp_short.xml"),

	--填海造海
	Asset("ATLAS", "images/inventoryimages/canal_plow_item.xml"),
	Asset("IMAGE", "images/inventoryimages/canal_plow_item.tex"),

	--萝卜冰箱音效
	Asset( "SOUND" , "sound/malibag.fsb" ),
	Asset( "SOUNDPACKAGE" , "sound/malibag.fev" ),
	--萝卜冰箱
	Asset("IMAGE", "images/inventoryimages/venus_icebox.tex"),
	Asset("ATLAS", "images/inventoryimages/venus_icebox.xml"),
	Asset( "IMAGE", "images/map_icons/venus_icebox.tex" ),
	Asset( "ATLAS", "images/map_icons/venus_icebox.xml" ),

	--发光的瓶子
	Asset("ATLAS", "images/inventoryimages/magiclantern_white.xml"),
	Asset("ATLAS", "images/inventoryimages/magiclantern_red.xml"),
	Asset("ATLAS", "images/inventoryimages/magiclantern_blue.xml"),
	Asset("ATLAS", "images/inventoryimages/magiclantern_pink.xml"),
	Asset("ATLAS", "images/inventoryimages/magiclantern_purple.xml"),
	Asset("ATLAS", "images/inventoryimages/magiclantern_orange.xml"),
	Asset("ATLAS", "images/inventoryimages/magiclantern_yellow.xml"),
	Asset("ATLAS", "images/inventoryimages/magiclantern_green.xml"),


	--大背包
	Asset("ANIM", "anim/swap_bigbag.zip"),
	Asset("ANIM", "anim/ui_bigbag_3x8.zip"),
	Asset("ANIM", "anim/ui_bigbag_4x8.zip"),
	--Asset("ANIM", "anim/bigbag_ui_8x6.zip"),
	--Asset("ANIM", "anim/bigbag_ui_8x8.zip"),

	Asset("IMAGE", "images/inventoryimages/bigbag.tex"),
	Asset("ATLAS", "images/inventoryimages/bigbag.xml"),

	Asset("IMAGE", "minimap/bigbag.tex"),
	Asset("ATLAS", "minimap/bigbag.xml"),

	--Asset("IMAGE", "images/bigbagbg.tex"),
	--Asset("ATLAS", "images/bigbagbg.xml"),

	Asset("IMAGE", "images/bigbagbg_8x8.tex"),
	Asset("ATLAS", "images/bigbagbg_8x8.xml"),

	Asset("IMAGE", "images/bigbagbg_8x6.tex"),
	Asset("ATLAS", "images/bigbagbg_8x6.xml"),

	---elaina额外皮肤补丁
	Asset("ANIM", "anim/elena.zip"),
	Asset("ANIM", "anim/ghost_elena_build.zip"),

}

--全图定位
AddMinimapAtlas("minimap/campfire.xml")

--龙鳞冰炉
AddMinimapAtlas("images/minimap/icefurnace.xml")

--萝卜冰箱
AddMinimapAtlas("images/map_icons/venus_icebox.xml")

--大背包
AddMinimapAtlas("minimap/bigbag.xml")