-- 使用的mod名称：快速工作
-- mod链接：https://steamcommunity.com/sharedfiles/filedetails/?id=1200745268
-- mod更新时间：2019.04.07 上午 10:46
-- mod作者：柴阿文
if GetModConfigData("Pick") == true then
	AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.PICK, "doshortaction"))
	AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.TAKEITEM, "doshortaction"))
	AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.HARVEST, "doshortaction"))
end
if GetModConfigData("BuildRepair") == true then
	AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.BUILD, "doshortaction"))
	AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.DECORATEVASE, "doshortaction"))
	AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.DRAW, "doshortaction"))
	AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.REPAIR, "doshortaction"))
	AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.SEW, "doshortaction"))
	AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.SMOTHER, "doshortaction"))
	AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.MANUALEXTINGUISH, "doshortaction"))
end
if GetModConfigData("HSHU") == true then
	local function QuickEat(inst, action)
		if inst.sg:HasStateTag("busy") then
			return
		end
		local obj = action.target or action.invobject
		if obj == nil then
			return
		elseif obj.components.edible ~= nil then
			if not inst.components.eater:PrefersToEat(obj) then
				inst:PushEvent("wonteatfood", { food = obj })
				return
			end
		elseif obj.components.soul ~= nil then
			if inst.components.souleater == nil then
				inst:PushEvent("wonteatfood", { food = obj })
				return
			end
		else
			return
		end
		return (inst:HasTag("beaver") and "beavereat")
			or "quickeat"
	end
	AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.EAT, QuickEat))
	AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.HEAL, "doshortaction"))
	AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.TEACH, "doshortaction"))
	AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.UPGRADE, "doshortaction"))
end
if GetModConfigData("Animal") == true then
	AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.PET, "doshortaction"))
	AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.FEED, "doshortaction"))
	AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.MURDER, "doshortaction"))
	AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.BRUSH, "doshortaction"))
	AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.SHAVE, "doshortaction"))	
end
if GetModConfigData("Others") == true then
	AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.USEKLAUSSACKKEY, "doshortaction"))
	AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.ACTIVATE, "doshortaction"))
	AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.FILL, "doshortaction"))
	AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.RESETMINE, "doshortaction"))
	AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.ATTUNE, "doshortaction"))
	AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.ABANDON, "doshortaction"))
	AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.UNWRAP, "doshortaction"))
end
if GetModConfigData("ChopTime") ~= 999 then
	GLOBAL.TUNING.EVERGREEN_CHOPS_SMALL = GetModConfigData("ChopTime")
	GLOBAL.TUNING.EVERGREEN_CHOPS_NORMAL = GetModConfigData("ChopTime")
	GLOBAL.TUNING.EVERGREEN_CHOPS_TALL = GetModConfigData("ChopTime")
	GLOBAL.TUNING.DECIDUOUS_CHOPS_SMALL = GetModConfigData("ChopTime")
	GLOBAL.TUNING.DECIDUOUS_CHOPS_NORMAL = GetModConfigData("ChopTime")
	GLOBAL.TUNING.DECIDUOUS_CHOPS_TALL = GetModConfigData("ChopTime")
	GLOBAL.TUNING.DECIDUOUS_CHOPS_MONSTER = GetModConfigData("ChopTime")
	GLOBAL.TUNING.MUSHTREE_CHOPS_SMALL = GetModConfigData("ChopTime")
	GLOBAL.TUNING.MUSHTREE_CHOPS_MEDIUM = GetModConfigData("ChopTime")
	GLOBAL.TUNING.MUSHTREE_CHOPS_TALL = GetModConfigData("ChopTime")
	GLOBAL.TUNING.WINTER_TREE_CHOP_SMALL = GetModConfigData("ChopTime")
	GLOBAL.TUNING.WINTER_TREE_CHOP_NORMAL = GetModConfigData("ChopTime")
	GLOBAL.TUNING.WINTER_TREE_CHOP_TALL = GetModConfigData("ChopTime")
	GLOBAL.TUNING.TOADSTOOL_MUSHROOMSPROUT_CHOPS = GetModConfigData("ChopTime")
	GLOBAL.TUNING.TOADSTOOL_DARK_MUSHROOMSPROUT_CHOPS = GetModConfigData("ChopTime")
	local function QuickChop(inst)
		if inst.components.workable then
			inst.components.workable:SetWorkLeft(GetModConfigData("ChopTime"))
		end
	end
	AddPrefabPostInit("cave_banana_tree", QuickChop)
	AddPrefabPostInit("marsh_tree", QuickChop)
	AddPrefabPostInit("livingtree", QuickChop)
end
if GetModConfigData("MineTime") ~= 999 then
	GLOBAL.TUNING.MARBLESHRUB_MINE_SMALL = GetModConfigData("MineTime") --大理石灌木(矿)(小)6
	GLOBAL.TUNING.MARBLESHRUB_MINE_NORMAL = GetModConfigData("MineTime") --大理石灌木(矿)(中)8
	GLOBAL.TUNING.MARBLESHRUB_MINE_TALL = GetModConfigData("MineTime") --大理石灌木(矿)(大)10
	GLOBAL.TUNING.ICE_MINE = GetModConfigData("MineTime") --冰矿3

	GLOBAL.TUNING.ROCKS_MINE = GetModConfigData("MineTime") --岩矿6
	GLOBAL.TUNING.ROCKS_MINE_MED = GetModConfigData("MineTime") --岩矿MED 4
	GLOBAL.TUNING.ROCKS_MINE_LOW = GetModConfigData("MineTime") --岩矿LOW 2
	GLOBAL.TUNING.SPILAGMITE_SPAWNER = GetModConfigData("MineTime") --蜘蛛卵器 2
	GLOBAL.TUNING.SPILAGMITE_ROCK = GetModConfigData("MineTime") --蜘蛛卵矿 4
	GLOBAL.TUNING.MARBLEPILLAR_MINE = GetModConfigData("MineTime") --大理石柱子10
	GLOBAL.TUNING.MARBLETREE_MINE = GetModConfigData("MineTime") --大理石树8
	GLOBAL.TUNING.CAVEIN_BOULDER_MINE = GetModConfigData("MineTime") --卡文巨石矿 3
	GLOBAL.TUNING.SEASTACK_MINE = GetModConfigData("MineTime") --海栈矿 9
	GLOBAL.TUNING.SHELL_CLUSTER_MINE = GetModConfigData("MineTime") --壳簇矿 3
	GLOBAL.TUNING.SALTSTACK_WORK_REQUIRED = GetModConfigData("MineTime") --盐堆 10

	GLOBAL.TUNING.PETRIFIED_TREE_SMALL = GetModConfigData("MineTime") --石化的树小 2
	GLOBAL.TUNING.PETRIFIED_TREE_NORMAL = GetModConfigData("MineTime") --石化的树 3
	GLOBAL.TUNING.PETRIFIED_TREE_TALL = GetModConfigData("MineTime") --石化树大 4
	GLOBAL.TUNING.GARGOYLE_MINE = GetModConfigData("MineTime") --石像鬼 4
	GLOBAL.TUNING.GARGOYLE_MINE_LOW = GetModConfigData("MineTime") --石像鬼LOW 2

	GLOBAL.TUNING.MOONALTAR_ROCKS_MINE = GetModConfigData("MineTime") --月岩 20
	GLOBAL.TUNING.SCULPTURE_COVERED_WORK = GetModConfigData("MineTime") --雕塑作品 3

	-- AddPrefabPostInit("rock_ice", function(inst)
	-- 	inst.components.workable:SetWorkLeft(TUNING.ICE_MINE/10)
	-- local STAGES = 
	-- 	{
	-- 	    {
	-- 	        name = "dryup",
	-- 	        animation = "dryup",
	-- 	        showrock = false,
	-- 	        work = -1,
	-- 	        isdriedup = true,
	-- 	    },
	-- 	    {
	-- 	        name = "empty",
	-- 	        animation = "melted",
	-- 	        showrock = false,
	-- 	        work = -1,
	-- 	    },
	-- 	    {
	-- 	        name = "short",
	-- 	        animation = "low",
	-- 	        showrock = true,
	-- 	        work = GetModConfigData("MineTime"),
	-- 	        icecount = 2,
	-- 	    },
	-- 	    {
	-- 	        name = "medium",
	-- 	        animation = "med",
	-- 	        showrock = true,
	-- 	        work = GetModConfigData("MineTime"),
	-- 	        icecount = 2,
	-- 	    },
	-- 	    {
	-- 	        name = "tall",
	-- 	        animation = "full",
	-- 	        showrock = true,
	-- 	        work = GetModConfigData("MineTime"),
	-- 	        icecount = 3,
	-- 	    },
	-- 	}
	-- end)
end
if GetModConfigData("FishTime") ~= 999 then
	local function QuickFishing(inst)
		if inst.components.fishingrod then
			inst.components.fishingrod:SetWaitTimes(GetModConfigData("FishTime"), GetModConfigData("FishTime"))
		end
	end
	AddPrefabPostInit("fishingrod", QuickFishing)
end
if GetModConfigData("CookTime") ~= 999 then
	AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.COOK, "doshortaction"))
	if GetModConfigData("CookTime") < 998 then
		GLOBAL.TUNING.BASE_COOK_TIME = GetModConfigData("CookTime")
	end
end
if GetModConfigData("QuickDry") == true then
	GLOBAL.TUNING.DRY_FAST = 0
	GLOBAL.TUNING.DRY_MED = 0
end
if GetModConfigData("QuickGrow") ~= 999 then
	GLOBAL.TUNING.MIN_CROP_GROW_TEMP = -100
	if GetModConfigData("QuickGrow") == 0 then
		GLOBAL.TUNING.SEEDS_GROW_TIME = 0.1
	end
end