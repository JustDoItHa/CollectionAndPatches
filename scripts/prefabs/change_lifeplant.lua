require "prefabutil"

local assets=
{
	Asset("ANIM", "anim/lifeplant.zip"),
	Asset("ANIM", "anim/lifeplant_fx.zip"),
	Asset("MINIMAP_IMAGE", "lifeplant"),
}

local prefabs =
{
	"collapse_small",
}

local INTENSITY = .5

local function fadein(inst)
    inst.components.fader:StopAll()
    inst.Light:Enable(true)
	if inst:IsAsleep() then
		inst.Light:SetIntensity(INTENSITY)
	else
		inst.Light:SetIntensity(0)
		inst.components.fader:Fade(0, INTENSITY, 3+math.random()*2, function(v) inst.Light:SetIntensity(v) end)
	end
end

local function fadeout(inst)
    inst.components.fader:StopAll()
	if inst:IsAsleep() then
		inst.Light:SetIntensity(0)
	else
		inst.components.fader:Fade(INTENSITY, 0, .75+math.random()*1, function(v) inst.Light:SetIntensity(v) end)
	end
end


local function onburnt(inst)
	inst:AddTag("burnt")
    inst.components.burnable.canlight = false
    if inst.components.workable then
        inst.components.workable:SetWorkLeft(1)
    end

    local ash = SpawnPrefab("ash")
    ash.Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst:Remove()
end



local function onhit(inst, worker)
	if not inst:HasTag("burnt") then
		inst.AnimState:PlayAnimation("hit")
		inst.AnimState:PushAnimation("idle")
	end
end



local function onplanted(inst)
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("idle", false)
	inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/flower_of_life/plant")
end

local function onsave(inst, data)

	if inst:HasTag("burnt") or inst:HasTag("fire") then
        data.burnt = true
    end

    return 
end

local function onload(inst, data)
	if data and data.burnt then
        inst.components.burnable.onburnt(inst)
    end
end

local function OnLoadPostPass(inst, newents, data)

end


local function OnRemoved(inst)

   --[[ if inst.fountain and not inst.dug then
    	print("DEACTIVATING FOUNTAIN")
        inst.fountain.deactivate(inst.fountain)
    end    --]]
end

local function CalcSanityAura(inst, observer)
	return TUNING.SANITYAURA_MED / 5
end

local function sparkle(inst)
	--[[local player = inst:GetNearestPlayer(true)
	
	if player and player:IsValid() then 
		local sparkles = SpawnPrefab("change_lifeplant_sparkle")
		sparkles.Transform:SetPosition(player.Transform:GetWorldPosition())	
	end --]]
end

local function drain(inst)
	----------取消吸收饱食度
	--[[local player = inst:GetNearestPlayer(true)
	if player and player:IsValid() then 
		player.components.hunger:DoDelta(-1)  
	end  --]]
end

local function onnear(inst)	
	if not inst.reserrecting then
		inst.starvetask = inst:DoPeriodicTask(0.5,function() sparkle(inst) end)
		inst.starvetask2 = inst:DoPeriodicTask(2,function() drain(inst) end)
	end
end

local function onfar(inst)
	if inst.starvetask then
		inst.starvetask:Cancel()
		inst.starvetask = nil

		inst.starvetask2:Cancel()
		inst.starvetask2 = nil		
	end
end

local function dig_up(inst, chopper)
		
	local drop = inst.components.lootdropper:SpawnLootPrefab("change_waterdrop")

	inst.dug = true
	inst:Remove()
end

local function manageidle(inst)
	local anim = "idle_gargle"
	if math.random() < 0.5 then
		anim = "idle_vanity"
	end

	inst.AnimState:PlayAnimation(anim)
	inst.AnimState:PushAnimation("idle_loop",true)

	inst:DoTaskInTime(8+(math.random()*20), function() inst.manageidle(inst) end)
end

local function fn(Sim)
	local inst = CreateEntity()
	
    inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddMiniMapEntity()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()
	inst.entity:AddLight()
	
    inst.Light:SetIntensity(INTENSITY)
    inst.Light:SetColour(180/255, 195/255, 150/255)
	-- inst.Light:SetColour(180/255, 4/255, 100/255)
    inst.Light:SetFalloff( 0.9 )
    inst.Light:SetRadius( 2 )
    
    inst.Light:Enable(true)  
    
    MakeObstaclePhysics(inst, .3)

	inst.MiniMapEntity:SetIcon( "lifeplant.png" )
    
    inst.AnimState:SetBank("lifeplant")
    inst.AnimState:SetBuild("lifeplant")
    inst.AnimState:PlayAnimation("idle_loop",true)
	
	inst.AnimState:SetMultColour(0.9,0.9,0.9,1)

    inst:AddTag("lifeplant")
	
	inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    
    inst:AddComponent("inspectable")
	
    inst:AddComponent("lootdropper")
    
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.DIG)
    inst.components.workable:SetWorkLeft(1)
	inst.components.workable:SetOnFinishCallback(dig_up)
	
	MakeSnowCovered(inst, .01)    

	inst:AddComponent("burnable")
    inst.components.burnable:SetFXLevel(3)
    inst.components.burnable:SetBurnTime(10)
    inst.components.burnable:AddBurnFX("fire", Vector3(0, 0, 0) )
    inst.components.burnable:SetOnBurntFn(onburnt)
    MakeLargePropagator(inst)

    inst:AddComponent("fader")

  
    fadein(inst)

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aurafn = CalcSanityAura


    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(6,7)
    inst.components.playerprox:SetOnPlayerNear(onnear)
    inst.components.playerprox:SetOnPlayerFar(onfar)

    inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )

	inst.OnSave = onsave 
    inst.OnLoad = onload
    inst.OnLoadPostPass = OnLoadPostPass

    inst:ListenForEvent("onremove", OnRemoved)
	
	--取消花的一些不必要的动作
    --inst.manageidle = manageidle
    --inst:DoTaskInTime(8+(math.random()*20), function() inst.manageidle(inst) end)

    --[[inst:DoTaskInTime(0,function()
            for k,v in pairs(Ents) do                
                if v:HasTag("pugalisk_fountain") then
                    inst.fountain = v
                    break
                end
            end
        end)--]]

   	
    return inst
end

local function testforplant(inst)
	local x,y,z = inst.Transform:GetWorldPosition()
	local ent = TheSim:FindFirstEntityWithTag("lifeplant")

	if ent and ent:GetDistanceSqToInst(inst) < 1 then
		inst:Remove()
	end
end

local function onspawn(inst)
	local x,y,z = inst.Transform:GetWorldPosition()
	local ent = TheSim:FindFirstEntityWithTag("lifeplant")
	if ent then
		local x2,y2,z2 = ent.Transform:GetWorldPosition()
    	local angle = inst:GetAngleToPoint(x2, y2, z2)
    	inst.Transform:SetRotation(angle)

		inst.components.locomotor:WalkForward()
		inst:DoPeriodicTask(0.1,function() testforplant(inst) end)
	else
		inst:Remove()
	end
end

local function sparklefn(Sim)
	local inst = CreateEntity()

    inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()
   

    --MakeNoPhysics(inst, 1, 0.3)
    --RemovePhysicsColliders(inst)
	MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)
	
	inst.AnimState:SetBank("lifeplant_fx")
    inst.AnimState:SetBuild("lifeplant_fx")
    inst.AnimState:PlayAnimation("single"..math.random(1,3),true)


	inst:AddTag("flying")
    inst:AddTag("NOCLICK")
    --inst:AddTag("DELETE_ON_INTERIOR")
	
	inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
	
	
    inst.persists = false

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = 2
	inst.components.locomotor:SetTriggersCreep(false)

    inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )
    inst:DoTaskInTime(0,function() onspawn(inst) end)
	
	inst.OnEntitySleep = function() inst:Remove() end
   

    return inst
end


return Prefab( "common/objects/change_lifeplant", fn, assets, prefabs),
	   Prefab( "common/objects/change_lifeplant_sparkle", sparklefn, assets, prefabs)		
