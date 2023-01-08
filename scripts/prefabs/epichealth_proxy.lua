local PRECISION = 10 ^ 3

local STIMULI = { "fire", "electric" }
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
		netset(parent.epichealth._currenthealth, math.ceil(parent.components.health.currenthealth * PRECISION))
		netset(parent.epichealth._maxhealth, math.ceil(parent.components.health.maxhealth * PRECISION))
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
		OnHealthDelta(inst._parent)
		OnInvincible(inst._parent)
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