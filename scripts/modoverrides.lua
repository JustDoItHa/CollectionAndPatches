local PRESETS =
{
	LAVAARENA =
	{
		BACKGROUND_COLOUR1 =	RGB(41, 34, 28),
		BACKGROUND_COLOUR2 =	RGB(74, 61, 52),
		FRAME_COLOUR =  		RGB(110, 64, 31),
		BUTTON_COLOUR = 		RGB(166, 62, 37),
	},

	QUAGMIRE =
	{
		BACKGROUND_COLOUR1 =	RGB(38, 34, 35),
		BACKGROUND_COLOUR2 =	RGB(80, 71, 73),
		FRAME_COLOUR =  		RGB(183, 166, 166),
		BUTTON_COLOUR = 		WHITE,
	},

	EQUINOX =
	{
		BASE =					"QUAGMIRE",
		FRAME_COLOUR =			{ 0, 0, 0, 0.5 },
	},

	WORTOX =
	{
		BASE =					"QUAGMIRE",
		FRAME_COLOUR =			RGB(237, 206, 169),
		BUTTON_COLOUR =			RGB(245, 94, 85),
	},
}

local MODS =
{
	["workshop-1824509831"] =	PRESETS.LAVAARENA,
	["workshop-1583765151"] =   PRESETS.QUAGMIRE,
	["workshop-2250176974"] =   PRESETS.QUAGMIRE,
	["workshop-2854270129"] =   PRESETS.EQUINOX,
	["workshop-2954087809"] =   PRESETS.WORTOX,
}

local function ApplyOverrides(data)
	if data.BASE ~= nil then
		ApplyOverrides(PRESETS[data.BASE])
	end
	for type, value in pairs(data) do
		TUNING.EPICHEALTHBAR[type] = value
		--print("ApplyOverrides", type, value)
	end
end

ApplyOverrides(modconfig)
--ApplyOverrides(PRESETS.LAVAARENA)

for mod, overrides in pairs(MODS) do
	if KnownModIndex:IsModEnabled(mod) then
		return ApplyOverrides(overrides)
	end
end