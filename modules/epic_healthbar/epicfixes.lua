if not TheNet:GetIsServer() then
	local function PushMusicEX(PushMusic, inst, ...)
		if not inst:HasTag("epic") then
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

if not TheNet:IsDedicated() then
	AddPrefabPostInit("shadow_bishop_fx", function(inst)
		inst.AnimState:UsePointFiltering(true)
	end)
end

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