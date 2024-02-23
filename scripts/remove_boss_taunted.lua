local SpawnPrefab = GLOBAL.SpawnPrefab

local function CombatPostInit(inst)

	local old_CanTarget = inst.CanTarget
	local old_CanAttack = inst.CanAttack
	local old_DoAttack = inst.DoAttack
	local old_DoAreaAttack = inst.DoAreaAttack

	function inst:CanTarget(target)
		if target and self.inst and target:HasTag("epic") and self.inst:HasTag("epic") then
			return false
		end
		return old_CanTarget(self, target)
	end

	function inst:CanAttack(target)
		if target and self.inst and target:HasTag("epic") and self.inst:HasTag("epic") then
			return false
		end
		return old_CanAttack(self, target)
	end

	function inst:DoAttack(targ, weapon, projectile, stimuli, instancemult)
		if targ and self.inst and targ:HasTag("epic") and self.inst:HasTag("epic") then
			SpawnPrefab("stalker_shield").Transform:SetPosition(targ.Transform:GetWorldPosition())
			return false
		end
		return old_DoAttack(self, targ, weapon, projectile, stimuli, instancemult)
	end

	function inst:DoAreaAttack(target, range, weapon, validfn, stimuli, excludetags)
		local hitcount = 0
		local x, y, z = target.Transform:GetWorldPosition()
		local ents = TheSim:FindEntities(x, y, z, range, AREAATTACK_MUST_TAGS, excludetags)
		for i, ent in ipairs(ents) do
			if ent ~= target and ent ~= self.inst and self:IsValidTarget(ent) and  (validfn == nil or validfn(ent, self.inst)) then
				self.inst:PushEvent("onareaattackother", { target = ent, weapon = weapon, stimuli = stimuli })
				if ent:HasTag("epic") and self.inst:HasTag("epic") then
					SpawnPrefab("stalker_shield").Transform:SetPosition(ent.Transform:GetWorldPosition())
				else
					ent.components.combat:GetAttacked(self.inst, self:CalcDamage(ent, weapon, self.areahitdamagepercent), weapon, stimuli)
				end
				hitcount = hitcount + 1
			end
		end
		return hitcount
	end
end

AddComponentPostInit("combat",CombatPostInit)

local List =
{
	"eyeofterror",
	"twinofterror1",
	"twinofterror2",
}

local RETARGET_MUST_TAGS = { "_combat" }
local RETARGET_CANT_TAGS = { "decor", "eyeofterror", "FX", "INLIMBO", "NOCLICK", "notarget", "playerghost", "wall" ,"epic"}
local RETARGET_ONEOF_TAGS = { "player" }    -- The eye tries to fight players and also other Epic monsters

local function myupdate_targets(inst)
	local to_remove = {}
	local pos = inst.components.knownlocations:GetLocation("spawnpoint") or inst:GetPosition()

	for k, _ in pairs(inst.components.grouptargeter:GetTargets()) do
		to_remove[k] = true
	end

	local ents_near_spawnpoint = TheSim:FindEntities(
			pos.x, 0, pos.z,
			TUNING.EYEOFTERROR_DEAGGRO_DIST,
			RETARGET_MUST_TAGS, RETARGET_CANT_TAGS, RETARGET_ONEOF_TAGS
	)
	for _, v in ipairs(ents_near_spawnpoint) do
		if to_remove[v] then
			to_remove[v] = nil
		else
			inst.components.grouptargeter:AddTarget(v)
		end
	end

	for non_target, _ in pairs(to_remove) do
		inst.components.grouptargeter:RemoveTarget(non_target)
	end
end

local TARGET_DIST = 20
local function get_target_test_range(inst, use_short_dist, target)
	return inst.sg:HasStateTag("charge")
			and inst.components.stuckdetection:IsStuck()
			and TUNING.EYEOFTERROR_CHARGE_AOERANGE + target:GetPhysicsRadius(0)
			or (use_short_dist and 8 + target:GetPhysicsRadius(0))
			or TARGET_DIST
end

local function myRetargetFn(inst)
	if inst:IsInLimbo() then
		return
	end

	myupdate_targets(inst)

	local current_target = inst.components.combat.target
	local target_in_range = current_target ~= nil and current_target:IsNear(inst, 8 + current_target:GetPhysicsRadius(0))

	if current_target ~= nil and current_target:HasTag("player") then
		local new_target = inst.components.grouptargeter:TryGetNewTarget()
		return (new_target ~= nil
				and new_target:IsNear(inst, get_target_test_range(inst, target_in_range, new_target))
				and new_target)
				or nil,
		true
	end

	local targets_in_range = {}
	for target, _ in pairs(inst.components.grouptargeter:GetTargets()) do
		if inst:IsNear(target, get_target_test_range(inst, target_in_range, target)) then
			table.insert(targets_in_range, target)
		end
	end
	return (#targets_in_range > 0 and targets_in_range[math.random(#targets_in_range)]) or nil, true
end

for i,v in ipairs(List) do
	AddPrefabPostInit(v, function(inst)
		if inst.components.combat then
			inst.components.combat:SetRetargetFunction(1, myRetargetFn)
		end
	end)
end
