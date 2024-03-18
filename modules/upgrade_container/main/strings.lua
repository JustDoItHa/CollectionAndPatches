local LANGUAGE = {"zh", "zht"}

local DROPALLTEXT = {
	["zh"] = "清空",
	["zht"] = "清空",
	["en"] = "Drop All",
}

local DROPHOVER = {
	["zh"] = "长按以清理",
	["zht"] = "長按以清理",
	["en"] = "Hold to drop all",
}

local SORTTEXT = {
	["zh"] = "整理",
	["zht"] = "整理",
	["en"] = "Sort",
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
	STRINGS = function(loc)
		local lang = "en"
		for _, v in ipairs(LANGUAGE) do
			if loc == v then
				lang = loc
				break
			end
		end
		return {
			DROPALLTEXT	= DROPALLTEXT[lang],
			DROPHOVER 	= DROPHOVER[lang],
			SORTTEXT	= SORTTEXT[lang],
		}
	end,
	INSIGHT = DESCRIBE,
}

function env.GetString(i)
	return index[i]
end

local loc = GLOBAL.LOC.GetLocaleCode()

GLOBAL.STRINGS.UPGRADEABLECHEST = GetString("STRINGS")(loc)