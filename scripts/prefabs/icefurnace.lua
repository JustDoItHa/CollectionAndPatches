
require "prefabutil"

local assets = 
{
	Asset("ANIM", "anim/ice_furnace_default.zip"),
	Asset("ANIM", "anim/ice_furnace_antique.zip"),
	Asset("ANIM", "anim/ice_furnace_crystal.zip"),
}

local prefabs = 
{
	"collapse_big",
	"explode_reskin",
	"ice",
	"dragonflyfurnace",
}

	--Build

local function BuiltTimeLine1(inst)
    inst._task1 = nil
    inst.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel")
end

local function BuiltTimeLine2(inst)
    inst._task2 = nil
    inst.SoundEmitter:PlaySound("dontstarve/common/together/dragonfly_furnace/light")
    inst.SoundEmitter:PlaySound("dontstarve/common/together/dragonfly_furnace/fire_LP", "loop")
end

local function onbuilt(inst)
	if current_skin_icefurnace ~= nil then
		if current_skin_icefurnace == "ice_furnace_antique" then
			inst.skinname = 2
			inst.AnimState:SetBank("ice_furnace_antique")
			inst.AnimState:SetBuild("ice_furnace_antique")
		elseif current_skin_icefurnace == "ice_furnace_crystal" then
			inst.skinname = 3
			inst.AnimState:SetBank("ice_furnace_crystal")
			inst.AnimState:SetBuild("ice_furnace_crystal")
		end
	end
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("hi_pre", false)
	inst.AnimState:PushAnimation("hi")
	inst.SoundEmitter:KillSound("loop")
	inst.SoundEmitter:PlaySound("dontstarve/common/together/dragonfly_furnace/place")
	if inst._task2 ~= nil then
		inst._task2:Cancel()
		if inst._task1 ~= nil then
			inst._task1:Cancel()
		end
	end
	inst._task1 = inst:DoTaskInTime(30 * FRAMES, BuiltTimeLine1)
	inst._task2 = inst:DoTaskInTime(40 * FRAMES, BuiltTimeLine2)
end

	--Destory

local function onworked(inst)
    if inst._task2 ~= nil then
        inst._task2:Cancel()
        inst._task2 = nil
        inst.SoundEmitter:PlaySound("dontstarve/common/together/dragonfly_furnace/fire_LP", "loop")
        if inst._task1 ~= nil then
            inst._task1:Cancel()
            inst._task1 = nil
        end
    end
    inst.AnimState:PlayAnimation("hi_hit")
    inst.AnimState:PushAnimation("hi")
	if inst.components.container ~= nil then
		inst.components.container:DropEverything()
		if inst.components.container:IsOpen() then
			inst.components.container:Close()
		end
	end
end

local function onworkfinished(inst)
	if inst.components.lootdropper ~= nil then
		inst.components.lootdropper:DropLoot()
	end
    local fx = SpawnPrefab("collapse_big")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("metal")
    inst:Remove()
end

	--Ice Production

local function add_ice(inst)
	if inst.components.container ~= nil then
		local max_slots = num_slots_icefurnace or 3
		for current_slot = 1, max_slots do
			local item = inst.components.container:GetItemInSlot(current_slot)
			if item == nil then
				local fx = SpawnPrefab("crab_king_icefx")
				fx.entity:SetParent(inst.entity)
				fx.Transform:SetPosition(0, 0.9, 0)
				fx.Transform:SetScale(0.8, 0.8, 0.8)
				local prefab_ice = SpawnPrefab("ice")
				inst.components.container:GiveItem(prefab_ice, current_slot)
				return
			elseif item.prefab == "ice" then
				local stack_size = item.components.stackable:StackSize()
				if stack_size < 40 then
					local fx = SpawnPrefab("crab_king_icefx")
					fx.entity:SetParent(inst.entity)
					fx.Transform:SetPosition(0, 0.9, 0)
					fx.Transform:SetScale(0.8, 0.8, 0.8)
					local prefab_ice = SpawnPrefab("ice")
					inst.components.container:GiveItem(prefab_ice, current_slot)
					return
				end
			end
		end
	end		
end

local function OnOpen(inst)
	inst.AnimState:PlayAnimation("idle", true)
	inst.SoundEmitter:KillSound("loop")
	inst.SoundEmitter:PlaySound("dontstarve/common/fireOut")
	inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/vomitrumble", "rumble")
    inst.Light:SetRadius(0.7)
	inst:RemoveTag("fridge")
	if inst.give_ice ~= nil then
		inst.give_ice:Cancel()
		inst.give_ice = nil
	end
end

local function OnClose(inst)
	inst.AnimState:PlayAnimation("hi_pre")
	inst.AnimState:PushAnimation("hi")
	inst.SoundEmitter:KillSound("rumble")
	inst.SoundEmitter:PlaySound("dontstarve/common/together/dragonfly_furnace/fire_LP", "loop")
	inst.SoundEmitter:PlaySound("dontstarve/common/together/dragonfly_furnace/light")
    inst.Light:SetRadius(light_range_icefurnace)
	inst:AddTag("fridge")
	if inst.give_ice == nil and ice_production_icefurnace ~= nil and ice_production_icefurnace < 99999 then
		inst.give_ice = inst:DoPeriodicTask(ice_production_icefurnace, add_ice)
	end
end

	--Fresh

local function preserve_rate(inst)
	if inst.components.container ~= nil and inst.components.container:IsOpen() then
		return 1
	end
	if fresh_rate_icefurnace ~= nil then
		return fresh_rate_icefurnace
	end
end

	--Heater

local function get_heat_icefurnace(inst)
	local heat_icefurnace = inst.components.heater.heat
	if heat_icefurnace ~= nil then
		if inst.components.container ~= nil and inst.components.container:IsOpen() then
			return nil
		end
		if heat_control_icefurnace ~= nil and heat_control_icefurnace == true then
			if not TheWorld.state.issummer then
				return 0
			end
		end
		return heat_icefurnace
	end
end

	--Transform

local function turnoff_icefurnace(inst)
	if inst.components.container ~= nil then
		inst.components.container:DropEverything()
	end
	local x, y, z = inst.Transform:GetWorldPosition()
	local fx = SpawnPrefab("icefurnace_transform_fx")
	fx.Transform:SetPosition(x, y + 0.3, z)
	fx.Transform:SetScale(1.2, 1.2, 1.2)
	inst:DoTaskInTime(0, function()
		local prefab_dragonfurnace = SpawnPrefab("dragonflyfurnace")
		if prefab_dragonfurnace ~= nil then
			prefab_dragonfurnace.Transform:SetPosition(x, y, z)
			if inst.components.workable ~= nil and inst.components.workable.workleft > 0 then
				if prefab_dragonfurnace.components.workable ~= nil then
					prefab_dragonfurnace.components.workable.workleft = inst.components.workable.workleft
				end
			end
		end
		inst:Remove()
	end)
end

	--Save/Load

local function onsave_icefurnace(inst, data)
	data.skinname = inst.skinname
end

local function onload_icefurnace(inst, data)
	if data ~= nil and data.skinname ~= nil then
		inst.skinname = data.skinname
		if inst.skinname ~= 1 then
			if inst.skinname == 2 then
				inst.AnimState:SetBank("ice_furnace_antique")
				inst.AnimState:SetBuild("ice_furnace_antique")
			else
				inst.AnimState:SetBank("ice_furnace_crystal")
				inst.AnimState:SetBuild("ice_furnace_crystal")				
			end
		end
	end
end

	--Prefab
	
local function fn()

    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 0.5)

    inst.MiniMapEntity:SetIcon("icefurnace.tex")

    inst.Light:Enable(true)
    inst.Light:SetRadius(light_range_icefurnace)
    inst.Light:SetFalloff(0.9)
    inst.Light:SetIntensity(0.5)
    inst.Light:SetColour(12/255, 121/255, 235/255)

	inst.skinname = 1
	inst.AnimState:SetBank("ice_furnace_default")
	inst.AnimState:SetBuild("ice_furnace_default")
    inst.AnimState:PlayAnimation("hi", true)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetLightOverride(0.4)

    inst:AddTag("structure")
    inst:AddTag("wildfireprotected")
    inst:AddTag("HASHEATER")
	inst:AddTag("fridge")
	inst:AddTag("furnace")
	inst:AddTag("icefurnace")
	
	if ice_production_icefurnace ~= nil and ice_production_icefurnace < 99999 then
		inst.give_ice = inst:DoPeriodicTask(ice_production_icefurnace, add_ice)
	end

    inst.entity:SetPristine()
	
	if not TheWorld.ismastersim then
		if num_slots_icefurnace ~= nil and num_slots_icefurnace > 0 then
			inst.OnEntityReplicated = function(inst)
				if num_slots_icefurnace == 6 then
					inst.replica.container:WidgetSetup("icefurnace_container_3x2")
				elseif num_slots_icefurnace == 9 then
					inst.replica.container:WidgetSetup("icefurnace_container_3x3")
				elseif num_slots_icefurnace == 12 then
					inst.replica.container:WidgetSetup("icefurnace_container_3x4")
				elseif num_slots_icefurnace == 15 then
					inst.replica.container:WidgetSetup("icefurnace_container_3x5")
				else
					inst.replica.container:WidgetSetup("icefurnace_container_3x1")
				end
			end
		end
        return inst
    end
	
	inst.SoundEmitter:PlaySound("dontstarve/common/together/dragonfly_furnace/fire_LP", "loop")
	
    inst:AddComponent("inspectable")
	
    inst:AddComponent("lootdropper")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(6)
	inst.components.workable:SetOnWorkCallback(onworked)
    inst.components.workable:SetOnFinishCallback(onworkfinished)

    inst:AddComponent("heater")  
	inst.components.heater.heat = -45
	inst.components.heater.heatfn = get_heat_icefurnace
    inst.components.heater:SetThermics(false, true)
	
	if num_slots_icefurnace ~= nil and num_slots_icefurnace > 0 then
		inst:AddComponent("container")
		if num_slots_icefurnace == 6 then
			inst.components.container:WidgetSetup("icefurnace_container_3x2")
		elseif num_slots_icefurnace == 9 then
			inst.components.container:WidgetSetup("icefurnace_container_3x3")
		elseif num_slots_icefurnace == 12 then
			inst.components.container:WidgetSetup("icefurnace_container_3x4")
		elseif num_slots_icefurnace == 15 then
			inst.components.container:WidgetSetup("icefurnace_container_3x5")
		else
			inst.components.container:WidgetSetup("icefurnace_container_3x1")
		end
		inst.components.container.onopenfn = OnOpen
		inst.components.container.onclosefn = OnClose
		inst.components.container.skipclosesnd = true
		inst.components.container.skipopensnd = true
		
		inst:AddComponent("preserver") 
		inst.components.preserver:SetPerishRateMultiplier(preserve_rate)
	end
	
	if way_to_obtain_icefurnace ~= nil and way_to_obtain_icefurnace == 2 then
		inst:DoTaskInTime(1, function()
			inst:AddTag("cooldowndone_furnace")
		end)
	end
	
    inst:ListenForEvent("onbuilt", onbuilt)

    MakeHauntableWork(inst)

	inst.OnSave = onsave_icefurnace
	inst.OnLoad = onload_icefurnace

    return inst
end

return 	Prefab("icefurnace", fn, assets, prefabs),
		MakePlacer("icefurnace_placer_default", "ice_furnace_default", "ice_furnace_default", "idle"),
		MakePlacer("icefurnace_placer_antique", "ice_furnace_antique", "ice_furnace_antique", "idle"),
		MakePlacer("icefurnace_placer_crystal", "ice_furnace_crystal", "ice_furnace_crystal", "idle")
