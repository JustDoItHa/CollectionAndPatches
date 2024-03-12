local assets = {
	Asset("ANIM", "anim/change_tree.zip"),
}

local SCALE = 1.0 

local function PlaySleepLoopSoundTask(inst, stopfn)
    inst.SoundEmitter:PlaySound("dontstarve/common/tent_sleep")
end

local function stopsleepsound(inst)
    if inst.sleep_tasks ~= nil then
        for i, v in ipairs(inst.sleep_tasks) do
            v:Cancel()
        end
        inst.sleep_tasks = nil
    end
end

local function startsleepsound(inst, len)
    stopsleepsound(inst)
    inst.sleep_tasks =
    {
        inst:DoPeriodicTask(len, PlaySleepLoopSoundTask, 33 * FRAMES),
        inst:DoPeriodicTask(len, PlaySleepLoopSoundTask, 47 * FRAMES),
    }
end

local function onhammered(inst, worker)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_big")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function onhit(inst, worker)
    if not inst:HasTag("burnt") then
        stopsleepsound(inst)
        --inst.AnimState:PlayAnimation("hit")
        --inst.AnimState:PushAnimation("idle", true)
    end
    if inst.components.sleepingbag ~= nil and inst.components.sleepingbag.sleeper ~= nil then
        inst.components.sleepingbag:DoWakeUp()
    end
end


local function onignite(inst)
    inst.components.sleepingbag:DoWakeUp()
end

--We don't watch "stop'phase'" because that
--would not work in a clock without 'phase'
local function wakeuptest(inst, phase)
    if phase ~= inst.sleep_phase then
        inst.components.sleepingbag:DoWakeUp()
    end
end

local function onwake(inst, sleeper, nostatechange)
    if inst.sleeptask ~= nil then
        inst.sleeptask:Cancel()
        inst.sleeptask = nil
    end

    inst:StopWatchingWorldState("phase", wakeuptest)
    sleeper:RemoveEventCallback("onignite", onignite, inst)

    if not nostatechange then
        if sleeper.sg:HasStateTag("tent") then
            sleeper.sg.statemem.iswaking = true
        end
        sleeper.sg:GoToState("wakeup")
    end

    if inst.sleep_anim ~= nil then
        inst.AnimState:PushAnimation("idle", true)
        --stopsleepsound(inst)
    end

    --inst.components.finiteuses:Use()
	print(inst,sleeper,"onwake")
end

local function onsleeptick(inst, sleeper)
    local isstarving = sleeper.components.beaverness ~= nil and sleeper.components.beaverness:IsStarving()

    if sleeper.components.hunger ~= nil then
        sleeper.components.hunger:DoDelta(inst.hunger_tick, true, true)
        isstarving = sleeper.components.hunger:IsStarving()
    end

    if sleeper.components.sanity ~= nil and sleeper.components.sanity:GetPercentWithPenalty() < 1 then
        sleeper.components.sanity:DoDelta(TUNING.SLEEP_SANITY_PER_TICK, true)
    end

    if not isstarving and sleeper.components.health ~= nil then
        sleeper.components.health:DoDelta(TUNING.SLEEP_HEALTH_PER_TICK * 2, true, inst.prefab, true)
    end

    if sleeper.components.temperature ~= nil then
        if inst.is_cooling then
            if sleeper.components.temperature:GetCurrent() > TUNING.SLEEP_TARGET_TEMP_TENT then
                sleeper.components.temperature:SetTemperature(sleeper.components.temperature:GetCurrent() - TUNING.SLEEP_TEMP_PER_TICK)
            end
        elseif sleeper.components.temperature:GetCurrent() < TUNING.SLEEP_TARGET_TEMP_TENT then
            sleeper.components.temperature:SetTemperature(sleeper.components.temperature:GetCurrent() + TUNING.SLEEP_TEMP_PER_TICK)
        end
    end

    if isstarving then
        inst.components.sleepingbag:DoWakeUp()
    end
	
	print(inst,sleeper,"onsleeptick")
end

local function onsleep(inst, sleeper)
    inst:WatchWorldState("phase", wakeuptest)
    sleeper:ListenForEvent("onignite", onignite, inst)

    if inst.sleep_anim ~= nil then
        inst.AnimState:PlayAnimation(inst.sleep_anim, true)
        --startsleepsound(inst, inst.AnimState:GetCurrentAnimationLength())
    end

    if inst.sleeptask ~= nil then
        inst.sleeptask:Cancel()
    end
    inst.sleeptask = inst:DoPeriodicTask(TUNING.SLEEP_TICK_PERIOD, onsleeptick, nil, sleeper)
	
	print(inst,sleeper,"onsleep")
end

local function SpawnTreeLight()
	local treelignt = CreateEntity()
    treelignt.entity:AddTransform()
    treelignt.entity:AddLight()
    treelignt.entity:AddNetwork()

    treelignt:AddTag("FX")

    treelignt.Light:SetIntensity(.8)
    treelignt.Light:SetColour(255/255, 250/255, 250/255)
    treelignt.Light:SetFalloff(.5)
    treelignt.Light:SetRadius(2)
    treelignt.Light:Enable(true)

    treelignt.entity:SetPristine()

    if not TheWorld.ismastersim then
        return treelignt
    end

    treelignt.persists = false

    return treelignt
end
local function SpawnLight(inst)
	if inst.TreeLight and inst.TreeLight:IsValid() then
		inst.TreeLight:Remove()
	end
	inst.TreeLight = nil
	
	
	-- inst.TreeLight = SpawnTreeLight()
	inst.TreeLight = SpawnPrefab("changelightfx")
	
	-- inst.TreeLight:SetIntensity(.9)
    -- inst.TreeLight:SetColour(255 / 255, 175 / 255, 0 / 255)
    -- inst.TreeLight:SetFalloff(.6)
    -- inst.TreeLight:SetRadius(6)
    -- inst.TreeLight:Enable(false)
	inst.TreeLight.entity:AddFollower()
    inst.TreeLight.Follower:FollowSymbol(inst.GUID, "tree", 150, -450, 0)
	inst.TreeLight.Light:SetColour(252/255, 251/255, 69/255)
	-- inst.TreeLight.Light:SetRadius(2.75)
	inst.TreeLight.Light:SetRadius(8)
end 

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
	
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
	
	inst:AddTag("tent")
    inst:AddTag("structure")
	
	-- xiugai
	-- inst.entity:AddLight()
	-- inst.Light:SetIntensity(.8)
    -- inst.Light:SetColour(255 / 255, 240 / 255, 69 / 255)
    -- inst.Light:SetFalloff(.5)
    -- inst.Light:SetRadius(2.25)
    -- inst.Light:Enable(true)

	MakeObstaclePhysics(inst, .05)
	
	inst.AnimState:SetBank("change_tree")
    inst.AnimState:SetBuild("change_tree")
    inst.AnimState:PlayAnimation("idle")
	
	inst.Transform:SetScale(SCALE,SCALE,SCALE)
	
	inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
	
	inst.TreeLight = nil 
	inst.sleep_phase = "night"
    inst.sleep_anim = "idle"
    inst.hunger_tick = TUNING.SLEEP_HUNGER_PER_TICK
	
	inst:AddComponent("inspectable")
	
	inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)
	
	inst:AddComponent("sleepingbag")
    inst.components.sleepingbag.onsleep = onsleep
    inst.components.sleepingbag.onwake = onwake
    inst.components.sleepingbag.dryingrate = math.max(0, -TUNING.SLEEP_WETNESS_PER_TICK / TUNING.SLEEP_TICK_PERIOD)
	
	inst:DoTaskInTime(0,SpawnLight)
	
	return inst
end

return Prefab("change_tree", fn, assets),
	MakePlacer("change_tree_placer", "change_tree", "change_tree", "idle",nil,nil,nil,SCALE) 