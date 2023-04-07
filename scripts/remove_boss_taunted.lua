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