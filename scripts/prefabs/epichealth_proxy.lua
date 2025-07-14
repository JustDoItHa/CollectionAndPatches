local PRECISION = 10 ^ 3
local RESIST_MIN = 0
local RESIST_MAX = 7

local STIMULI = { "fire", "electric", "health" }
for i, v in ipairs(STIMULI) do
	STIMULI[v] = i
end

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
		ThePlayer:PushEvent("epictargetresisted", { target = inst._parent, resist = inst._resist:value() / RESIST_MAX })
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
		if data ~= nil and data.newpercent <= 0 and data.oldpercent > 0 then
			local damageresolved = data.oldpercent * parent.components.health.maxhealth + math.max(-999999, data.amount)
			netset(parent.epichealth._currenthealth, math.ceil(damageresolved * PRECISION))
			netset(parent.epichealth._stimuli, not data.cause and STIMULI.health or 0)
		else
			netset(parent.epichealth._currenthealth, math.ceil(parent.components.health.currenthealth * PRECISION))
			netset(parent.epichealth._maxhealth, math.ceil(parent.components.health.maxhealth * PRECISION))
			netset(parent.epichealth._stimuli, 0)
		end
	end
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

local function OnMinHealth(parent, data)
	if parent.components.health ~= nil then
		if parent.components.health.minhealth == 1 then
			parent:AddTag("nonlethal")
		elseif data ~= nil and not parent.components.health:IsDead() then
			netset(parent.epichealth._resist, RESIST_MAX, true)
		end
	end
end

local function OnExplosiveResist(parent, resist)
	netset(parent.epichealth._resist, math.ceil(Lerp(RESIST_MIN, RESIST_MAX, resist)), true)
end

local function OnAttacked(parent, data)
	if data ~= nil and data.original_damage ~= nil and data.original_damage > 0 and not data.redirected then
		local stimuli = data.stimuli or Tykvesh.Browse(data.weapon, "components", "weapon", "stimuli")
		netset(parent.epichealth._stimuli, STIMULI[stimuli] or 0)
		if data.damageresolved ~= nil and data.damageresolved < data.original_damage then
			netset(parent.epichealth._resist, math.ceil(Lerp(RESIST_MAX, RESIST_MIN, data.damageresolved / data.original_damage)), true)
		end
	end
	parent.epichealth._damaged:push()
end

local function OnEntityReplicated(inst)
	inst._parent = inst.entity:GetParent()
	if inst._parent ~= nil then
		inst._parent.epichealth = inst

		if TheWorld.ismastersim then
			inst:ListenForEvent("healthdelta", OnHealthDelta, inst._parent)
			inst:ListenForEvent("invincibletoggle", OnInvincible, inst._parent)
			inst:ListenForEvent("firedamage", OnFireDamage, inst._parent)
			inst:ListenForEvent("minhealth", OnMinHealth, inst._parent)
			inst:ListenForEvent("explosiveresist", OnExplosiveResist, inst._parent)
			inst:ListenForEvent("attacked", OnAttacked, inst._parent)
			OnHealthDelta(inst._parent)
			OnInvincible(inst._parent)
			OnMinHealth(inst._parent)
		end

		if not TheNet:IsDedicated() then
			inst:ListenForEvent("entitywake", OnEntityWake)
			inst:ListenForEvent("entitysleep", OnEntitySleep)
			inst:ListenForEvent("onremove", OnEntitySleep)
			if not inst:IsAsleep() then
				OnEntityWake(inst)
			end
		end
	end
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

		inst.maxhealth = 0
		inst.currenthealth = 0
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