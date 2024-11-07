AddPrefabPostInit("tigershark", function(inst)
	inst.IsEpic = Tykvesh.True
end)

--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

if not TheNet:GetIsServer() then
	local function PushMusicEX(PushMusic, inst, ...)
		if not inst:HasTag("epic") then --ಠ_ಠ
			inst._playingmusic = false
		else
			PushMusic(inst, ...)
		end
	end

	AddPrefabPreInit("crabking", function(fn)
		pcall(Tykvesh.BranchUpvalue, fn, "PushMusic", PushMusicEX)
	end)
end

--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

local function MakeLureBloom(inst)
	inst.AnimState:SetSymbolBloom("wormlure", "shaders/anim.ksh")
end

AddPrefabPostInit("worm", MakeLureBloom)
AddPrefabPostInit("worm_boss_head", MakeLureBloom)
AddPrefabPostInit("worm_boss_segment", MakeLureBloom)

--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
if not TheNet:GetIsServer() then return end --\\\\\\\\\\\\\\\\\\\\\\\\\\\\
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

AddStategraphPostInit("malbatross", function(sg)
	local function MakeShadowTweener(inst)
		if inst.components.shadowtweener == nil then
			inst:AddComponent("shadowtweener")
			inst.components.shadowtweener:SetSize(6, 2)
		end
	end

	local function ClearTween(inst)
		inst.components.shadowtweener:ClearTween()
	end

	Tykvesh.Parallel(sg.states.arrive, "onexit", ClearTween)
	Tykvesh.Parallel(sg.states.arrive, "onenter", function(inst)
		MakeShadowTweener(inst)
		inst.components.shadowtweener:StartTween(Vector3(0, 0), Vector3(6, 2), 30 * FRAMES)
	end, true)

	Tykvesh.Parallel(sg.states.depart, "onexit", ClearTween)
	Tykvesh.Parallel(sg.states.depart, "onenter", function(inst)
		MakeShadowTweener(inst)
		inst.components.shadowtweener:StartTween(Vector3(6, 2), Vector3(0, 0), 20 * FRAMES, 30 * FRAMES)
	end, true)
end)

--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

AddStategraphPostInit("eyeofterror", function(sg)
	local function DisableShadow(inst)
		inst.DynamicShadow:Enable(false)
	end

	local function EnableShadow(inst)
		inst.DynamicShadow:Enable(true)
	end

	Tykvesh.Parallel(sg.states.arrive_delay, "onenter", DisableShadow)
	Tykvesh.Parallel(sg.states.arrive_delay, "onexit", EnableShadow)
	Tykvesh.Parallel(sg.states.flyback_delay, "onenter", DisableShadow)
	Tykvesh.Parallel(sg.states.flyback_delay, "onexit", EnableShadow)

	local function MakeShadowTweener(inst)
		if inst.components.shadowtweener == nil then
			inst:AddComponent("shadowtweener")
			inst.components.shadowtweener:SetSize(6, 2)
		end
	end

	local function ClearTween(inst)
		inst.components.shadowtweener:ClearTween()
	end

	Tykvesh.Parallel(sg.states.arrive, "onexit", ClearTween)
	Tykvesh.Parallel(sg.states.arrive, "onenter", function(inst)
		MakeShadowTweener(inst)
		inst.components.shadowtweener:StartTween(Vector3(0, 0), Vector3(4.5, 1.75), 7 * FRAMES, 36 * FRAMES, function(inst)
			inst.components.shadowtweener:StartTween(Vector3(4.5, 1.75), Vector3(6, 2), 10 * FRAMES, 73 * FRAMES)
		end)
	end, true)

	Tykvesh.Parallel(sg.states.flyaway, "onexit", ClearTween)
	Tykvesh.Parallel(sg.states.flyaway, "onenter", function(inst)
		MakeShadowTweener(inst)
		inst.components.shadowtweener:StartTween(Vector3(6, 2), Vector3(0, 0), 25 * FRAMES, 18 * FRAMES)
	end, true)

	Tykvesh.Parallel(sg.states.flyback, "onexit", ClearTween)
	Tykvesh.Parallel(sg.states.flyback, "onenter", function(inst)
		MakeShadowTweener(inst)
		inst.components.shadowtweener:StartTween(Vector3(0, 0), Vector3(6, 2), 30 * FRAMES)
	end, true)
end)

--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

local function ReplaceCorpse(inst)
	local rot = inst.Transform:GetRotation()
	local build = inst.AnimState:GetBuild()
	local burning = inst.components.burnable:IsBurning()
	inst = ReplacePrefab(inst, inst.mutantprefab)
	inst.Transform:SetRotation(rot)
	inst.AnimState:MakeFacingDirty()
	inst.sg:GoToState("corpse_mutate", build)
	if burning then
		inst.components.burnable:Ignite(true)
	end
end

local function OnEnter(inst, build)
	if inst.components.health == nil then
		return ReplaceCorpse(inst) --may be corpse with old save data
	end
	inst.components.health:SetInvincible(true)
	inst.sg.statemem.build = inst.AnimState:GetBuild()
	inst.AnimState:SetBuild(build)
	inst.AnimState:PlayAnimation("mutate_pre")
	if inst:HasTag("deerclops") then
		inst.AnimState:OverrideSymbol("eye_crystal", "deerclops_mutated", "eye_crystal")
		inst.AnimState:OverrideSymbol("frozen_debris", "deerclops_mutated", "frozen_debris")
		inst.SoundEmitter:PlaySound("rifts3/mutated_deerclops/ice_crackling_LP", "loop")
	elseif inst:HasTag("bearger") then
		inst.AnimState:HideSymbol("flameL")
		inst.AnimState:HideSymbol("flameR")
		inst.AnimState:OverrideSymbol("bearger_rib", "bearger_mutated", "bearger_rib")
		inst.SoundEmitter:PlaySound("rifts3/mutated_bearger/mutate_pre_tone_f0")
	elseif inst:HasTag("warg") then
		inst.AnimState:OverrideSymbol("SPIKE", "warg_mutated_actions", "SPIKE")
		inst.AnimState:OverrideSymbol("hair_mutate", "warg_mutated_actions", "hair_mutate")
		if build == "warg_gingerbread_build" then
			inst.AnimState:OverrideSymbol("cookiecrumbs", "warg_mutated_actions", "cookiecrumbs")
			inst.AnimState:PlayAnimation("mutate_pre_gingerbread")
		end
		inst.SoundEmitter:PlaySound("rifts3/mutated_varg/mutate_pre_f0")
	end
end

local function OnAnimOver(inst)
	inst.sg:GoToState("mutate_pst")
end

local function OnExit(inst)
	if inst.components.burnable:IsBurning() then
		inst.components.burnable.fastextinguish = true
		inst.components.burnable:Extinguish()
		inst.components.burnable.fastextinguish = false
	end
	inst.components.health:SetInvincible(false)
	inst.AnimState:SetBuild(inst.sg.statemem.build)
	--inst.AnimState:ClearAllOverrideSymbols()
	if inst:HasTag("bearger") then
		inst.AnimState:ShowSymbol("flameL")
		inst.AnimState:ShowSymbol("flameR")
	end
end

local function MoveCorpseStates(sg) --to actual bosses so intro can be played
	if sg.states.corpse_mutate_pre == nil then
		return
	elseif sg.states.corpse_mutate_pre.ontimeout ~= nil then
		sg.states.corpse_mutate_pre.ontimeout = ReplaceCorpse
	elseif sg.states.corpse_mutate_pre.timeline ~= nil then
		sg.states.corpse_mutate_pre.timeline[#sg.states.corpse_mutate_pre.timeline].fn = ReplaceCorpse
	end
	sg.states.corpse_mutate.tags.busy = true
	sg.states.corpse_mutate.tags.noattack = true
	sg.states.corpse_mutate.tags.nofreeze = true
	sg.states.corpse_mutate.onenter = OnEnter
	sg.states.corpse_mutate.events.animover.fn = OnAnimOver
	sg.states.corpse_mutate.onexit = OnExit
end

AddStategraphPostInit("deerclops", MoveCorpseStates)
AddStategraphPostInit("bearger", MoveCorpseStates)
AddStategraphPostInit("warg", MoveCorpseStates)

--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

local function MarkTagAsAttack(sg, tag)
	for name, state in pairs(sg.states) do
		if state.tags[tag] then
			state.tags.attack = true
		end
	end
end

AddStategraphPostInit("alterguardian_phase2", function(sg) MarkTagAsAttack(sg, "spin") end)
AddStategraphPostInit("alterguardian_phase3", function(sg) MarkTagAsAttack(sg, "attacking") end)