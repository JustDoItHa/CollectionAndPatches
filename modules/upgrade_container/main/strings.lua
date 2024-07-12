local LANGUAGE = {"zh", "zht"}

local strings = {
	DROPALLTEXT = {
		["zh"] = "清空",
		["zht"] = "清空",
		["en"] = "Drop All",
	},
	DROPHOVER = {
		["zh"] = "长按以清理",
		["zht"] = "長按以清理",
		["en"] = "Hold to drop all",
	},
	SORTTEXT = {
		["zh"] = "整理",
		["zht"] = "整理",
		["en"] = "Sort",
	},
	CLOSETEXT = {
		["zh"] = "关闭",
		["zht"] = "關閉",
		["en"] = "Close",
	},
	FILLTEXT = {
		["zh"] = "填充",
		["zht"] = "填充",
		["en"] = "Fill",
	},
	FILLHOVER = {
		["zh"] = "长按以自动填充升级材料",
		["zht"] = "長按以自動填充升級材料",
		["en"] = "Hold to auto fill upgrade item",
	},
}

local DESCRIBE = {
	["zh"] = {
		generic = "容量: %dx%d",
		pageable = "容量: %dx%d, 页数: %d",
	},
	["zht"] = {
		generic = "容量: %dx%d",
		pageable = "容量: %dx%d, 頁數: %d",
	},
	["en"] = {
		generic = "Size: %dx%d",
		pageable = "Size: %dx%d, Page: %d",
	},
}

local index = {
	STRINGS = GLOBAL.setmetatable(strings, {
		__call = function(t, loc)
			local res = {}
			for k, v in pairs(t) do
				res[k] = v[loc] or v["en"]
			end
			return res
		end
	}),
	-- STRINGS = function(loc)
	-- 	local lang = "en"
	-- 	for _, v in ipairs(LANGUAGE) do
	-- 		if loc == v then
	-- 			lang = loc
	-- 			break
	-- 		end
	-- 	end
	-- 	return {
	-- 		DROPALLTEXT	= DROPALLTEXT[lang],
	-- 		DROPHOVER 	= DROPHOVER[lang],
	-- 		SORTTEXT	= SORTTEXT[lang],
	-- 	}
	-- end,
	INSIGHT = DESCRIBE,
}

function env.GetString(i)
	return index[i]
end

local loc = GLOBAL.LOC.GetLocaleCode()

GLOBAL.STRINGS.UPGRADEABLECHEST = GetString("STRINGS")(loc)