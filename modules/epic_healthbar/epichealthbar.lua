AddPrefab("epichealth_proxy")

TUNING.EPICHEALTHBAR =
{
	GLOBAL = false,
	GLOBAL_NUMBERS = false,
	CAPTURE = false,

	TAG = "EPIC",
	FRAME_PHASES = true,
	DAMAGE_NUMBERS = true,
	DAMAGE_RESISTANCE = true,
	WETNESS_METER = false,
	HORIZONTAL_OFFSET = 0,

	CAMERA_FOCUS_MIN = 30,
	CAMERA_FOCUS_MAX = 60,
	CAMERA_PRIORITY = -10,

	HUE_THRESH = 12 / 360,
	DARK_THRESH = 20 / 100,
	POPUP_BRIGHTNESS = 80 / 100,

	BACKGROUND_COLOUR1 =					RGB(46, 28, 30),
	BACKGROUND_COLOUR2 =					RGB(96, 71, 74),
	METER_COLOUR =							RGB(191, 36, 36),
	FRAME_COLOUR =							RGB(132, 102, 62),
	BUTTON_COLOUR =							RGB(207, 174, 105),
	HEAL_COLOUR =							RGB(40, 255, 80),
	DAMAGE_COLOUR1 =						RGB(255, 80, 40),
	DAMAGE_COLOUR2 =						RGB(255, 201, 14),
	FIRE_COLOUR =							RGB(255, 130, 62),
	ELECTRIC_ADDCOLOUR1 =					RGB(55, 22, 0),
	ELECTRIC_ADDCOLOUR2 =					RGB(19, 15, 20),
	ELECTRIC_ADDCOLOUR3 =					RGB(-19, -15, -20),

	THEMES =
	{
		LEIF =								RGB(48, 123, 85),
		LEIF_SPARSE =						RGB(89, 115, 114),
		SPIDERQUEEN =						{ 0.93, 0.66, 0.72 },
		TREEGUARD =							RGB(132, 170, 74),
		TIGERSHARK =						RGB(189, 109, 24),
		TWISTER =							RGB(99, 107, 139),
		KRAKEN =							RGB(173, 130, 140),
		SHADOWCHESSPIECE =					RGB(0, 0, 0),
		BEEQUEEN =							{ 0.80, 0.47, 0.13 },
		KLAUS =								RGB(191, 36, 36),
		ANTLION =							RGB(154, 80, 52),
		STALKER =							RGB(183, 146, 200),
		STALKER_FOREST =					RGB(161, 186, 79),
		STALKER_ATRIUM =					RGB(233, 85, 107),
		BOARRIOR =							RGB(150, 46, 46),
		BEETLETAUR =						RGB(51, 153, 51),
		PUGALISK =							RGB(102, 100, 130),
		ANTQUEEN =							RGB(181, 122, 159),
		ANCIENT_HERALD =					RGB(171, 57, 57),
		ANCIENT_HULK =						RGB(179, 77, 51),
		MALBATROSS =						RGB(85, 99, 164),
		CRABKING =							RGB(239, 237, 140),
		LORDFRUITFLY =						RGB(253, 206, 119),
		ALTERGUARDIAN_PHASE1 =				RGB(96, 113, 137),
		ALTERGUARDIAN_PHASE1_LUNARRIFT =	RGB(96, 113, 137),
		ALTERGUARDIAN_PHASE2 =				RGB(109, 199, 154),
		ALTERGUARDIAN_PHASE3 =				RGB(156, 235, 255),
		ALTERGUARDIAN_PHASE4_LUNARRIFT =	RGB(255, 255, 255),
		EYEOFTERROR =						RGB(175, 53, 51),
		TWINOFTERROR1 = 					RGB(159, 75, 30),
		TWINOFTERROR2 = 					RGB(39, 87, 109),
		DAYWALKER =							RGB(170, 37, 33),
		DAYWALKER2 =						RGB(170, 112, 48),
		SHARKBOI =							RGB(140, 158, 176),
		WORM_BOSS =							RGB(107, 84, 145),
		WAGBOSS_ROBOT =						RGB(200, 149, 57),

		DEERCLOPS =
		{
			GENERIC =						RGB(140, 158, 176),
			DEERCLOPS_YULE =				RGB(222, 77, 57),
			DEERCLOPS_MUTATED =				RGB(124, 189, 181),
		},

		MOOSE =
		{
			GENERIC =						RGB(130, 123, 102),
			GOOSEMOOSE_YULE_BUILD =			RGB(183, 130, 66),
		},

		DRAGONFLY =
		{
			GENERIC =						RGB(90, 142, 74),
			DRAGONFLY_FIRE_BUILD =			RGB(255, 86, 18),
			DRAGONFLY_YULE_BUILD =			{ 0.90, 0.71, 0.15 },
			DRAGONFLY_FIRE_YULE_BUILD = 	RGB(247, 146, 8),
		},

		BEARGER =
		{
			GENERIC =						RGB(0, 0, 0),
			BEARGER_YULE =					{ 0.85, 0.87, 0.69 },
			BEARGER_MUTATED =				RGB(124, 189, 181),
		},

		WARG =
		{
			GENERIC =						RGB(148, 106, 107),
			CLAYWARG =						RGB(216, 132, 101),
			WARG_GINGERBREAD_BUILD =		RGB(175, 154, 109),
			WARG_MUTATED_ACTIONS =			RGB(124, 189, 181),
		},

		MINOTAUR =
		{
			GENERIC =						{ 0.55, 0.52, 0.49 },
			ROOK_RHINO_DAMAGED_BUILD =		RGB(0, 0, 0),
		},

		TOADSTOOL =
		{
			GENERIC =						RGB(124, 72, 151),
			TOADSTOOL_DARK_BUILD =			{ 0.91, 0.85, 0.24 },
		},
	},

	PHASES =
	{
		DRAGONFLY =							{ 0.8, 0.5, 0.2 },
		KRAKEN =							{ 0.75, 0.5, 0.25 },
		TOADSTOOL =							{ 0.7, 0.4 },
		TOADSTOOL_DARK =					{ 0.7, 0.4, 0.2 },
		BEEQUEEN =							{ 0.75, 0.5, 0.25 },
		STALKER =							{ 0.75 },
		STALKER_ATRIUM =					{ 0.625 },
		ANTQUEEN =							{ 0.75, 0.5, 0.25 },
		ANCIENT_HULK =						{ 0.5, 0.3 },
		MALBATROSS =						{ 0.66, 0.33 },
		CRABKING =							{ 0.875, 0.35 },
		EYEOFTERROR =						{ 0.65 },
		MINOTAUR =							{ 0.6 },
		DAYWALKER =							{ 0.5, 0.3 },
		DAYWALKER2 =						{ 0.5 },
		WAGBOSS_ROBOT =						{ 0.75, 0.4 },
		ALTERGUARDIAN_PHASE4_LUNARRIFT =	{ 0.65 },

		KLAUS = function(inst)
			if not inst._unchained:value() and inst.Physics:GetMass() <= 1000 then
				return { 0.5 }
			end
		end,
	},

	INTROS =
	{
		DEERCLOPS =							{ "mutate_pre" },
		BEARGER =							{ "mutate_pre" },
		WARG =								{ "mutate_pre", "mutate_pre_gingerbread" },
		TOADSTOOL =							{ "spawn_appear_toad" },
		BEEQUEEN =							{ "enter" },
		STALKER_ATRIUM =					{ "enter" },
		ALTERGUARDIAN_PHASE1 =				{ "phase1_spawn" },
		ALTERGUARDIAN_PHASE1_LUNARRIFT =	{ "spawn_lunar", "rebuild" },
		ALTERGUARDIAN_PHASE2 =				{ "phase2_spawn" },
		ALTERGUARDIAN_PHASE3 =				{ "phase3_spawn" },
	},

	CONDITIONS =
	{
		TIGERSHARK = Tykvesh.True,

		WORM_BOSS = function(inst)
			if inst.engaged == nil then
				local pos = inst:GetPosition()
				inst.engaged = TheSim:CountEntities(pos.x, 0, pos.z, 20, { "worm_boss_piece" }) > 2 or nil
			end
			return inst.engaged
		end,
	},
}

if not TheNet:IsDedicated() then
	AddAsset("ATLAS", "images/hud/epichealthbar.xml")
	AddAsset("ANIM", "anim/quagmire_hangry_bar.zip")

	AddControlsPostInit(function(self, owner)
		local EpicHealthbar = require "widgets/epichealthbar"
		self.epichealthbar = self.top_root:AddChild(EpicHealthbar(owner, modinfo, modname))
		self.epichealthbar:SetPosition(TUNING.EPICHEALTHBAR.HORIZONTAL_OFFSET, 0)
	end)

	AddComponentPostInit("focalpoint", function(self, inst)
		function self:IsFocusBlocked(source, require_source)
			return self.current_focus ~= nil
					and self.current_focus.source ~= source
					and (require_source ~= true or self.targets[source] ~= nil)
		end

		Tykvesh.Branch(self, "Reset", function(Reset, self, ...)
			if self.current_focus ~= nil and self.current_focus.id == "FIXED" then
				self.current_focus = nil
				TheCamera:SetDefaultOffset()
			else
				return Reset(self, ...)
			end
		end)

		Tykvesh.Branch(self, "StopFocusSource", function(StopFocusSource, self, source, id, ...)
			if id ~= "FIXED" then
				return StopFocusSource(self, source, id, ...)
			end
		end)
	end)

	for prefab, fn in pairs(TUNING.EPICHEALTHBAR.CONDITIONS) do
		AddPrefabPostInit(prefab:lower(), function(inst) inst.IsEpic = fn end)
	end
end

AddUserCommand("epic",
		{
			aliases = { "epichealth", "epichealthbar" },
			permission = COMMAND_PERMISSION.USER,
			slash = true,
			params = {},
			localfn = function(params, caller)
				if caller ~= nil and caller.HUD ~= nil then
					caller.HUD.controls.epichealthbar:ShowConfigurationScreen()
				end
			end,
		})

AddClientModRPCHandler("ShowPopupNumber", function(target, value, stimuli, x, y, z)
	if ThePlayer ~= nil then
		ThePlayer:PushEvent("epicpopupnumber", { target = target, value = value, damaged = true, stimuli = stimuli, pos = Point(x, y, z) })
	end
end)

--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
if not TheNet:GetIsServer() then return end --\\\\\\\\\\\\\\\\\\\\\\\\\\\\
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

local function AddHealthProxy(inst)
	if inst.epichealth == nil and not inst.isplayer then
		inst.epichealth = inst:SpawnChild("epichealth_proxy")
	end
end

local function OnAddTag(inst, tag)
	if tag == "epic" then
		AddHealthProxy(inst)
	end
end

AddComponentPostInit("health", function(self, inst)
	if TUNING.EPICHEALTHBAR.GLOBAL then
		if not inst:HasTag("wall") then
			AddHealthProxy(inst)
		end
	elseif inst:HasTag("epic") then
		AddHealthProxy(inst)
	elseif inst:HasAnyTag("largecreature", "hostile") then
		Tykvesh.Parallel(inst, "AddTag", OnAddTag)
	end
end)

local function OnExplosiveDamage(self, damage, source)
	if self.resistance > 0 then
		self.inst:PushEvent("explosiveresist", self.resistance)
	end
end

AddComponentPostInit("explosiveresist", function(self, inst)
	Tykvesh.Parallel(self, "OnExplosiveDamage", OnExplosiveDamage)
end)

--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

local function ResolveSource(attacker)
	if attacker == nil or attacker.isplayer then
		return attacker
	elseif attacker.components.follower ~= nil then
		local leader = attacker.components.follower:GetLeader()
		while leader and leader.parent ~= nil do leader = leader.parent end
		return leader
	elseif attacker.components.complexprojectile ~= nil then
		return ResolveSource(attacker.components.complexprojectile.attacker)
	end

	if attacker.sourceplayer ~= nil then
		return attacker.sourceplayer
	elseif attacker.sourceplayerlookup ~= nil then
		return attacker[attacker.sourceplayerlookup]
	elseif attacker:HasTag("hostile") then
		return nil
	end
	for k, v in pairs(attacker) do
		if checkentity(v) and v.isplayer then
			attacker.sourceplayerlookup = k
			return v
		end
	end
end

local function GetDamagePosition(attacker, target)
	local pos1 = target:GetPosition()
	local pos2 = attacker:GetPosition()
	local dist = math.min(target:GetPhysicsRadius(0.5), pos1:Dist(pos2))
	local offset = (pos2 - pos1):Normalize()
	return pos1.x + offset.x * dist, pos1.y, pos1.z + offset.z * dist
end

local function OnAttacked(inst, data)
	if data ~= nil and data.damageresolved ~= nil and (data.damageresolved > 0 or data.redirected) then
		local success, source = pcall(ResolveSource, data.attacker)
		if checkentity(source) and source.isplayer and source ~= inst then
			SendModRPCToClient("ShowPopupNumber",
					source.userid,
					inst.parent or inst,
					math.min(999999, data.damageresolved),
					data.redirected and "redirected" or data.stimuli or Tykvesh.Browse(data.weapon, "components", "weapon", "stimuli"),
					GetDamagePosition(data.attacker, inst)
			)
		end
	end
end

local function OnNewTarget(inst, data)
	local other = Tykvesh.Browse(data, "target", "components", "combat", "target")
	if other ~= nil and other.isplayer then
		inst.sourceplayer = other
	end
end

local function OnRemoveFromEntity(self)
	self.inst:RemoveEventCallback("attacked", OnAttacked)
	self.inst:RemoveEventCallback("newcombattarget", OnNewTarget)
end

AddComponentPostInit("combat", function(self, inst)
	if TUNING.EPICHEALTHBAR.GLOBAL_NUMBERS then
		inst:ListenForEvent("attacked", OnAttacked)
		if inst:HasTag("companion") then
			inst:ListenForEvent("newcombattarget", OnNewTarget)
		end
		Tykvesh.Parallel(self, "OnRemoveFromEntity", OnRemoveFromEntity)
	end
end)

local function OnIgnite(inst, data)
	if data ~= nil then
		inst.sourceplayer = data.doer or data.attacker
	end
end

AddComponentPostInit("explosive", function(self, inst)
	if TUNING.EPICHEALTHBAR.GLOBAL_NUMBERS then
		inst:ListenForEvent("onignite", OnIgnite)
		inst:ListenForEvent("attacked", OnIgnite)
	end
end)