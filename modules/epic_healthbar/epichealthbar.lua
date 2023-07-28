AddPrefab("epichealth_proxy")

--if you want a custom frame for your HUD mod, prepare an atlas that includes
--"frame.tex" and "phase.tex" with any dimensions, but meter cutout has to be 490x20
--[[if TUNING.EPICHEALTHBAR ~= nil then
	AddClassPostConstruct("widgets/epichealthbar", function(self, owner)
		self.frame:SetTexture("images/epichealthbar_pink.xml", "frame.tex") --phases will inherit this atlas
		self.frame:SetTint(1, 1, 1, 1) --phases will inherit this tint
		--frame, frame_phases, name_text, currenthealth_text, maxhealth_text can be moved if needed
	end)
end]]

TUNING.EPICHEALTHBAR =
{
	NOEPIC = GetModConfigData("NOEPIC") and not GetModConfigData("NONOEPIC", true),
	FRAME_PHASES = GetModConfigData("FRAME_PHASES", true),
	DAMAGE_NUMBERS = GetModConfigData("DAMAGE_NUMBERS", true),
	DAMAGE_RESISTANCE = GetModConfigData("DAMAGE_RESISTANCE", true),
	WETNESS_METER = GetModConfigData("WETNESS_METER", true),
	HORIZONTAL_OFFSET = GetModConfigData("HORIZONTAL_OFFSET", true),

	BACKGROUND_COLOUR1 =				{ 46 / 255, 28 / 255, 30 / 255, 1 },
	BACKGROUND_COLOUR2 =				{ 96 / 255, 71 / 255, 74 / 255, 1 },
	METER_COLOUR =						{ 191 / 255, 36 / 255, 36 / 255, 1 },
	FRAME_COLOUR =						{ 132 / 255, 102 / 255, 62 / 255, 1 },
	HEAL_COLOUR =						{ 40 / 255, 255 / 255, 80 / 255, 1 },
	DAMAGE_COLOUR1 =					{ 255 / 255, 80 / 255, 40 / 255, 1 },
	DAMAGE_COLOUR2 =					{ 255 / 255, 201 / 255, 14 / 255, 1 },
	FIRE_COLOUR =						{ 255 / 255, 130 / 255, 62 / 255, 1 },
	ELECTRIC_ADDCOLOUR1 =				{ 55 / 255, 22 / 255, 0 / 255 },
	ELECTRIC_ADDCOLOUR2 =				{ 19 / 255, 15 / 255, 20 / 255 },
	ELECTRIC_ADDCOLOUR3 =				{ -19 / 255, -15 / 255, -20 / 255 },

	THEMES =
	{
		LEIF =							{ 48 / 255, 123 / 255, 85 / 255 },
		LEIF_SPARSE =					{ 89 / 255, 115 / 255, 114 / 255 },
		SPIDERQUEEN =					{ 0.93, 0.66, 0.72 },
		TREEGUARD =						{ 132 / 255, 170 / 255, 74 / 255 },
		TIGERSHARK =					{ 189 / 255, 109 / 255, 24 / 255 },
		TWISTER =						{ 99 / 255, 107 / 255, 139 / 255 },
		KRAKEN =						{ 173 / 255, 130 / 255, 140 / 255 },
		TOADSTOOL =						{ 124 / 255, 72 / 255, 151 / 255 },
		TOADSTOOL_DARK =				{ 0.91, 0.85, 0.24 },
		SHADOW_ROOK =					{ 0, 0, 0 },
		SHADOW_KNIGHT =					{ 0, 0, 0 },
		SHADOW_BISHOP =					{ 0, 0, 0 },
		BEEQUEEN =						{ 0.80, 0.47, 0.13 },
		KLAUS =							{ 191 / 255, 36 / 255, 36 / 255 },
		ANTLION =						{ 154 / 255, 80 / 255, 52 / 255 },
		STALKER =						{ 183 / 255, 146 / 255, 200 / 255 },
		STALKER_FOREST =				{ 161 / 255, 186 / 255, 79 / 255 },
		STALKER_ATRIUM =				{ 233 / 255, 85 / 255, 107 / 255 },
		BOARRIOR =						{ 150 / 255, 46 / 255, 46 / 255 },
		BEETLETAUR =					{ 51 / 255, 153 / 255, 51 / 255 },
		PUGALISK = 						{ 79 / 255, 78 / 255, 101 / 255 },
		ANTQUEEN =						{ 181 / 255, 122 / 255, 159 / 255 },
		ANCIENT_HERALD = 				{ 153 / 255, 51 / 255, 51 / 255 },
		ANCIENT_HULK =					{ 139 / 255, 60 / 255, 40 / 255 },
		MALBATROSS =					{ 85 / 255, 99 / 255, 164 / 255 },
		CRABKING =						{ 239 / 255, 237 / 255, 140 / 255 },
		LORDFRUITFLY =					{ 253 / 255, 206 / 255, 119 / 255 },
		ALTERGUARDIAN_PHASE1 =			{ 96 / 255, 113 / 255, 137 / 255 },
		ALTERGUARDIAN_PHASE2 =			{ 109 / 255, 199 / 255, 154 / 255 },
		ALTERGUARDIAN_PHASE3 =			{ 156 / 255, 235 / 255, 255 / 255 },
		EYEOFTERROR =					{ 175 / 255, 53 / 255, 51 / 255 },
		TWINOFTERROR1 =					{ 159 / 255, 75 / 255, 30 / 255 },
		TWINOFTERROR2 =					{ 39 / 255, 87 / 255, 109 / 255 },

		DEERCLOPS =
		{
			GENERIC =					{ 140 / 255, 158 / 255, 176 / 255 },
			DEERCLOPS_YULE =			{ 0.69, 0.23, 0.21 },
		},

		MOOSE =
		{
			GENERIC =					{ 130 / 255, 123 / 255, 102 / 255 },
			GOOSEMOOSE_YULE_BUILD =		{ 183 / 255, 130 / 255, 66 / 255 },
		},

		DRAGONFLY =
		{
			GENERIC =					{ 90 / 255, 142 / 255, 74 / 255 },
			DRAGONFLY_FIRE_BUILD =		{ 255 / 255, 86 / 255, 18 / 255 },
			DRAGONFLY_YULE_BUILD = 		{ 0.90, 0.71, 0.15 },
			DRAGONFLY_FIRE_YULE_BUILD = { 247 / 255, 146 / 255, 8 / 255 },
		},

		BEARGER =
		{
			GENERIC =					{ 0, 0, 0 },
			BEARGER_YULE = 				{ 0.85, 0.87, 0.69 },
		},

		MINOTAUR =
		{
			GENERIC =					{ 0.55, 0.52, 0.49 },
			ROOK_RHINO_DAMAGED_BUILD =	{ 0, 0, 0 },
		},
	},

	PHASES =
	{
		DRAGONFLY =						{ 0.8 },
		TIGERSHARK =					{ 0.1 },
		KRAKEN =						{ 0.75, 0.5, 0.25 },
		TOADSTOOL =						{ 0.7, 0.4 },
		TOADSTOOL_DARK =				{ 0.7, 0.4, 0.2 },
		BEEQUEEN =						{ 0.75, 0.5, 0.25 },
		STALKER =						{ 0.75 },
		STALKER_ATRIUM =				{ 0.625 },
		ANTQUEEN =						{ 0.75, 0.5, 0.25 },
		ANCIENT_HULK =					{ 0.5, 0.3 },
		MALBATROSS =					{ 0.66, 0.33 },
		CRABKING =						{ 0.9, 0.85 },
		EYEOFTERROR =					{ 0.65 },
		MINOTAUR =						{ 0.6 },

		KLAUS = function(inst)
			if not inst._unchained:value() and inst.Physics:GetMass() <= 1000 then
				return { 0.5 }
			end
		end,
	},

	INTROS =
	{
		TOADSTOOL =						{ "spawn_appear_toad" },
		TOADSTOOL_DARK =				{ "spawn_appear_toad" },
		BEEQUEEN =						{ "enter" },
		STALKER_ATRIUM =				{ "enter" },
		ALTERGUARDIAN_PHASE1 =			{ "phase1_spawn" },
		ALTERGUARDIAN_PHASE2 =			{ "phase2_spawn" },
		ALTERGUARDIAN_PHASE3 =			{ "phase3_spawn" },
	},
}

if not TheNet:IsDedicated() then
	AddAsset("ATLAS", "images/hud/epichealthbar.xml")
	AddAsset("ANIM", "anim/epichealthbar.zip")

	if KnownModIndex:IsModEnabledAny("workshop-1583765151") then
		TUNING.EPICHEALTHBAR.FRAME_COLOUR =			{ 183 / 255, 166 / 255, 166 / 255, 1 }
		TUNING.EPICHEALTHBAR.BACKGROUND_COLOUR1 =	{ 38 / 255, 34 / 255, 35 / 255, 1 }
		TUNING.EPICHEALTHBAR.BACKGROUND_COLOUR2 =	{ 80 / 255, 71 / 255, 73 / 255, 1 }
	end

	AddControlsPostInit(function(self, owner)
		local EpicHealthbar = require "widgets/epichealthbar"
		self.epichealthbar = self.top_root:AddChild(EpicHealthbar(owner, modinfo.version))
		self.epichealthbar:SetPosition(TUNING.EPICHEALTHBAR.HORIZONTAL_OFFSET, 0)

		Tykvesh.Parallel(self, "ShowStatusNumbers", function() self.epichealthbar:OnGainFocus() end)
		Tykvesh.Parallel(self, "HideStatusNumbers", function() self.epichealthbar:OnLoseFocus() end)
	end)

	Tykvesh.Branch(_G, "Networking_ModOutOfDateAnnouncement", function(ModOutOfDateAnnouncement, mod, ...)
		if mod ~= modinfo.name then
			return ModOutOfDateAnnouncement(mod, ...)
		elseif ThePlayer ~= nil and ThePlayer.HUD ~= nil then
			ThePlayer.HUD.controls.epichealthbar:MakeOutdated()
		end
	end)
end

--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
if not TheNet:GetIsServer() then return end --\\\\\\\\\\\\\\\\\\\\\\\\\\\\
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

local function AddHealthProxy(inst)
	if inst.epichealth == nil then
		inst.epichealth = inst:SpawnChild("epichealth_proxy")
	end
end

if not GetModConfigData("NOEPIC") then
	local function OnAddTag(inst, tag)
		if tag == "epic" then
			AddHealthProxy(inst)
		end
	end

	AddComponentPostInit("health", function(self, inst)
		if inst:HasTag("epic") then
			AddHealthProxy(inst)
		elseif inst:HasTag("largecreature") or inst:HasTag("hostile") then
			Tykvesh.Parallel(inst, "AddTag", OnAddTag)
		end
	end)
else
	AddComponentPostInit("health", function(self, inst)
		if not inst:HasTag("player") then
			AddHealthProxy(inst)
		end
	end)
end

local function OnExplosiveDamage(self, damage, source)
	if self.resistance > 0 then
		self.inst:PushEvent("explosiveresist", self.resistance)
	end
end

AddComponentPostInit("explosiveresist", function(self, inst)
	Tykvesh.Parallel(self, "OnExplosiveDamage", OnExplosiveDamage)
end)