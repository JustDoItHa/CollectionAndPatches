local PRECISION = 10 ^ 3

local STIMULI = { "fire", "electric" }
for i, v in ipairs(STIMULI) do
	STIMULI[v] = i
end

local COMBAT_RANGE = 10
local COMBAT_TIMEOUT = 2
local COMBAT_TAGS = { "_combat", "_health" }
local COMBAT_NOTAGS = { "INLIMBO", "player" }
local COMBAT_PROJECTILE_TAGS = { "activeprojectile" }

local AllEpicTargets = {}

if not TheNet:IsDedicated() then
	require("widgets/epichealthbar").targets = AllEpicTargets
end

local function netset(netvar, value, force)
	if netvar:value() ~= value then
		netvar:set(value)
	elseif force then
		netvar:set_local(value)
		netvar:set(value)
	end
end

local function getnpctargets(parent)
	local x, y, z = parent.Transform:GetWorldPosition()
	if x== nil or y == nil or z==nil then
		return {}
	end
	return TheSim:FindEntities(x, y, z, COMBAT_RANGE, COMBAT_TAGS, COMBAT_NOTAGS)
end

local function istargetedby(parent, attacker)
	return attacker ~= parent
		and (attacker.replica.combat ~= nil and attacker.replica.combat:GetTarget() == parent)
		and (attacker.replica.health ~= nil and not attacker.replica.health:IsDead())
end

local function isattackedby(parent, attacker)
	return istargetedby(parent, attacker)
		and (attacker.sg ~= nil and attacker.sg:HasStateTag("attack") or attacker:HasTag("attack"))
end

local function OnEntityWake(inst)
	AllEpicTargets[inst._parent] = true

	if ThePlayer ~= nil then
		ThePlayer:PushEvent("newepictarget", inst._parent)
	end
end

local function OnEntitySleep(inst)
	AllEpicTargets[inst._parent] = nil

	if ThePlayer ~= nil then
		ThePlayer:PushEvent("lostepictarget", inst._parent)
	end
end

local function OnCurrentHealthDirty(inst)
	inst.currenthealth = inst._currenthealth:value() / PRECISION
end

local function OnMaxHealthDirty(inst)
    inst.maxhealth = inst._maxhealth:value() / PRECISION
end

local function OnInvincibleDirty(inst)
	inst.invincible = inst._invincible:value()
end

local function OnResistDirty(inst)
	if ThePlayer ~= nil then
		ThePlayer:PushEvent("epictargetresisted", { target = inst._parent, resist = inst._resist:value() / 7 })
	end
end

local function OnStimuliDirty(inst)
	inst.stimuli = STIMULI[inst._stimuli:value()]
end

local function OnDamaged(inst)
	inst.lastwasdamagedtime = GetTime()
end

local function OnHealthDelta(parent, data)
	if parent.components.health ~= nil then
		if data ~= nil and data.oldpercent > 0 and data.newpercent <= 0 then
			local damage = data.oldpercent * parent.components.health.maxhealth + math.max(-999999, data.amount)
			netset(parent.epichealth._currenthealth, math.ceil(damage * PRECISION))
		else
			netset(parent.epichealth._currenthealth, math.ceil(parent.components.health.currenthealth * PRECISION))
			netset(parent.epichealth._maxhealth, math.ceil(parent.components.health.maxhealth * PRECISION))
		end
   	end
	netset(parent.epichealth._stimuli, data ~= nil and STIMULI[data.cause] or 0)
end

local function OnInvincible(parent, data)
	if parent.components.health ~= nil then
		netset(parent.epichealth._invincible, not not parent.components.health:IsInvincible())
	end
end

local function OnFireDamage(parent)
	netset(parent.epichealth._stimuli, STIMULI.fire)
	parent.epichealth._damaged:push()
end

local function OnExplosiveResist(parent, resist)
	netset(parent.epichealth._resist, math.ceil(7 * resist), true)
end

local function OnAttacked(parent, data)
	if data ~= nil and data.damage ~= nil and data.damage > 0 then
		if data.damageresolved ~= nil and data.damageresolved < data.damage then
			netset(parent.epichealth._resist, math.ceil(Lerp(7, 0, data.damageresolved / data.damage)), true)
		end

		local stimuli = data.stimuli
		if stimuli == nil and data.weapon ~= nil and data.weapon.components.weapon ~= nil then
			stimuli = data.weapon.components.weapon.stimuli
		end
		netset(parent.epichealth._stimuli, STIMULI[stimuli] or 0)
	end
	parent.epichealth._damaged:push()
end

local function OnHostileProjectile(parent, data)
	if parent.sg ~= nil and data ~= nil and data.thrower ~= nil then
		local x, y, z = data.thrower.Transform:GetWorldPosition()
		for i, v in ipairs(TheSim:FindEntities(x, y, z, COMBAT_RANGE, COMBAT_PROJECTILE_TAGS)) do
			if v.components.projectile ~= nil and v.components.projectile.target == parent then
				if parent.components.catcher == nil then
					parent:AddComponent("catcher")
				end
				parent.components.catcher:StartWatching(v)
			end
		end
	end
end

local function OnEntityReplicated(inst)
	inst._parent = inst.entity:GetParent()
	if inst._parent ~= nil then
		inst._parent.epichealth = inst

		if not TheNet:IsDedicated() then
			inst:ListenForEvent("entitywake", OnEntityWake)
			inst:ListenForEvent("entitysleep", OnEntitySleep)
			inst:ListenForEvent("onremove", OnEntitySleep)
			if not inst:IsAsleep() then
				OnEntityWake(inst)
			end
		end

		if not TheWorld.ismastersim then
			return
		end

		inst:ListenForEvent("healthdelta", OnHealthDelta, inst._parent)
		inst:ListenForEvent("invincibletoggle", OnInvincible, inst._parent)
		inst:ListenForEvent("firedamage", OnFireDamage, inst._parent)
		inst:ListenForEvent("explosiveresist", OnExplosiveResist, inst._parent)
		inst:ListenForEvent("attacked", OnAttacked, inst._parent)
		inst:ListenForEvent("hostileprojectile", OnHostileProjectile, inst._parent)
		OnHealthDelta(inst._parent)
		OnInvincible(inst._parent)
	end
end

local function IsPlayingMusic(inst)
	return inst._parent._playingmusic ~= nil or inst._parent._musictask ~= nil
end

local function TestForCombat(inst)
	local time = inst.lastwasdamagedtime
	if time ~= nil then
		if inst:IsPlayingMusic() then
			time = time + 1
		end
		if time >= GetTime() then
			return true
		end
	end

	local target = inst._parent.replica.combat:GetTarget()
	if inst._parent.replica.combat:IsValidTarget(target) then
		return true
	end

	for i, v in ipairs(AllPlayers) do
		if istargetedby(inst._parent, v) then
			return true
		end
	end
	for i, v in ipairs(getnpctargets(inst._parent)) do
		if istargetedby(inst._parent, v) then
			return true
		end
	end
	return false
end

local function IsGroupAttacked(inst, amount)
	local num_remaining = amount or 2
	for i, v in ipairs(AllPlayers) do
		if isattackedby(inst._parent, v) then
			num_remaining = num_remaining - 1
			if num_remaining <= 0 then
				return true
			end
		end
	end
	for i, v in ipairs(getnpctargets(inst._parent)) do
		if isattackedby(inst._parent, v) then
			num_remaining = num_remaining - 1
			if num_remaining <= 0 then
				return true
			end
		end
	end
	return false
end

local function IsBeingAttacked(inst)
	if inst._parent:HasTag("cancatch") then
		return true
	elseif inst.lastwasdamagedtime == nil or GetTime() - inst.lastwasdamagedtime > COMBAT_TIMEOUT then
		return false
	end
	return inst:IsGroupAttacked(1)
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddNetwork()

	inst:AddTag("CLASSIFIED")

	inst:Hide()

	inst._currenthealth = net_int(inst.GUID, "epichealth.currenthealth", "currenthealthdirty")
    inst._maxhealth = net_int(inst.GUID, "epichealth.maxhealth", "maxhealthdirty")
	inst._invincible = net_bool(inst.GUID, "epichealth.invincible", "invincibledirty")
	inst._resist = net_tinybyte(inst.GUID, "epichealth.resist", "resistdirty")
	inst._stimuli = net_tinybyte(inst.GUID, "epichealth.stimuli", "stimulidirty")
	inst._damaged = net_event(inst.GUID, "damaged")

	if not TheNet:IsDedicated() then
		inst:ListenForEvent("currenthealthdirty", OnCurrentHealthDirty)
       	inst:ListenForEvent("maxhealthdirty", OnMaxHealthDirty)
		inst:ListenForEvent("invincibledirty", OnInvincibleDirty)
		inst:ListenForEvent("resistdirty", OnResistDirty)
		inst:ListenForEvent("stimulidirty", OnStimuliDirty)
		inst:ListenForEvent("damaged", OnDamaged)

		inst.IsPlayingMusic = IsPlayingMusic
		inst.IsGroupAttacked = IsGroupAttacked
		inst.IsBeingAttacked = IsBeingAttacked
		inst.TestForCombat = TestForCombat

		inst.currenthealth = 0
		inst.maxhealth = 0
		inst.invincible = false
	end

	inst.entity:SetPristine()

	Tykvesh.OnEntityReplicated(inst, OnEntityReplicated)

	if not TheWorld.ismastersim then
		return inst
	end

	inst.persists = false

	return inst
end

return Prefab("epichealth_proxy", fn)