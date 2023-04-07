require "prefabutil"

local assets =
{
	Asset("ANIM", "anim/magiclantern.zip"),
}

local function getRGB(color)
	if color == "white" then
		return 1,1,1
	elseif color == "yellow" then
		return 1,1,0
	elseif color == "green" then
		return 0,1,0
	elseif color == "pink" then
		return 1,0,1
	elseif color == "blue" then--cyan
		return 0,1,1
	elseif color == "orange" then
		return 1, .5, 0
	elseif color == "red" then
		return 1,0,0
	elseif color == "purple" then
		return .75,0,1
	end
end

local function AreaChill(inst)--Pink Effect
	local pt = inst:GetPosition()
  	--tell hostiles to chill out
	local ents = TheSim:FindEntities(pt.x,pt.y,pt.z, 6, {"_combat"}, {"player", "epic", "ghost", "shadow"}, nil)
	
	for i,v in ipairs(ents) do
		local chill_chance = 1--btw math.random() generates a number between 0.0 and 1.0
		if math.random() < chill_chance and v.components.combat then--so this "math.random() < chill_chance" is always true.
			v.components.combat:GiveUp(1000)
		end
	end 
end

local function AreaDamage(inst)--Green Effect
	local pt = inst:GetPosition()
  	--damaging
	local ents = TheSim:FindEntities(pt.x,pt.y,pt.z, 6, {"_combat"}, {"player", "ghost", "shadow", "chess", "wall"}, nil)
	
	for i,v in ipairs(ents) do
		if v.components.health then
			v.components.health:DoDelta(-TUNING.POISON)
		end
	end
end

local function AreaHeal(inst)--Purple Effect
	local pt = inst:GetPosition()
  	--healing
	local ents = TheSim:FindEntities(pt.x,pt.y,pt.z, 6, {"_combat"}, {"ghost", "shadow","wall"}, nil)
	
	for i,v in ipairs(ents) do
		if v.components.health then
			v.components.health:DoDelta(TUNING.TINCUTRE_HEAL)
		end
	end
end

local function ApplyLanternEffect(inst, color, isTurningOn)
	if color == "yellow" then
		if isTurningOn then
			inst.components.sanityaura.aura = TUNING.SUNSHINE * TUNING.SANITYAURA_SMALL
		else
			inst.components.sanityaura.aura = 0
		end
	elseif color == "green" then
		if isTurningOn then
			inst.damageaura = inst:DoPeriodicTask(2, AreaDamage)
		elseif inst.damageaura then
			inst.damageaura:Cancel()
			inst.damageaura = nil
		end
	elseif color == "pink" then
		if isTurningOn then
			inst.peaceaura = inst:DoPeriodicTask(2, AreaChill)
		elseif inst.peaceaura then
			inst.peaceaura:Cancel()
			inst.peaceaura = nil
		end
	elseif color == "blue" then
		if isTurningOn then
			inst.components.heater.heat = -100 * TUNING.EMBER
			inst.components.heater:SetThermics(false, true)
		else
			inst.components.heater.heat = nil--does this turn it off?
		end
	elseif color == "orange" then
		if isTurningOn then
			inst.components.heater.heat = 100 * TUNING.ICY
		else
			inst.components.heater.heat = nil--does this turn it off?
		end
	elseif color == "red" then
		if isTurningOn then
			inst.components.sanityaura.aura = -TUNING.SANITYAURA_SMALL * TUNING.MENACING
		else
			inst.components.sanityaura.aura = 0
		end
	elseif color == "purple" then
		if isTurningOn then
			inst.healaura = inst:DoPeriodicTask(2, AreaHeal)
		elseif inst.healaura then
			inst.healaura:Cancel()
			inst.healaura = nil
		end
	end
end

local magiclanterncolors = { "white", "yellow", "green", "pink", "blue", "orange", "red", "purple" }

local function onhammered(inst, worker)
	inst.components.lootdropper:DropLoot()
    SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst:Remove()
    inst.SoundEmitter:PlaySound("dontstarve/common/destroy_stone")
end

local function flicker_update(inst)
    local time = GetTime()*30
	local flicker = ( math.sin( time ) + math.sin( time + 2 ) + math.sin( time + 0.7777 ) ) / 2.0 -- range = [-1 , 1]
	flicker = ( 1.0 + flicker ) / 2.0 -- range = 0:1
    inst.Light:SetRadius( TUNING.LIGHT_SIZE + 0.1 * flicker)
end

local function phasechange(inst, phase, id)
	local color = magiclanterncolors[id]
	if not TheWorld:HasTag("cave") and phase == "nullday" then
		inst.Light:Enable(false)
		inst.AnimState:PlayAnimation(id .. "_idle_off")
		if inst.flickertask then
			inst.flickertask:Cancel()
			inst.flickertask = nil
		end
		ApplyLanternEffect(inst, color, false)
	 elseif not inst.flickertask then
		inst.Light:Enable(true)
		inst.flickertask = inst:DoPeriodicTask(0.1, flicker_update)
		inst.Light:SetRadius(1.5)
		inst.Light:SetFalloff(.5)
		inst.Light:SetIntensity(.8)
		local r,g,b = getRGB(color)
		inst.Light:SetColour(r,g,b)
		inst.AnimState:PushAnimation(id .. "_loop_on_" .. color, true)
		ApplyLanternEffect(inst, color, true)
	end
end

local function CreateLantern(id, color)	
    local function fn()
        local inst = CreateEntity()

		inst.entity:AddTransform()
		inst.entity:AddAnimState()
		inst.entity:AddSoundEmitter() 
		inst.entity:AddNetwork()	
		inst.entity:AddLight()
		inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
		inst.AnimState:SetRayTestOnBB(true)
		
		MakeInventoryPhysics(inst)
		
		MakeObstaclePhysics(inst, .1)
		
		inst:AddTag("HASHEATER")
		
		inst.AnimState:SetBank("magiclantern")
		inst.AnimState:SetBuild("magiclantern")
		inst.AnimState:PlayAnimation(id .. "_idle_off",true)
		
		inst.entity:SetPristine() 
		
		if not TheWorld.ismastersim then       
			return inst 
		end
		
		if color == "blue" or color == "orange" then--add extra component depending on lamp color
			inst:AddComponent("heater")
		elseif color == "yellow" or color == "red" then
			inst:AddComponent("sanityaura")
		end
		
		inst:WatchWorldState("phase", function(inst, phase)
			phasechange(inst, phase, id)
		end)
		inst:DoTaskInTime(0, phasechange, TheWorld.state.phase, id)

		inst:AddComponent("lootdropper")
		inst:AddComponent("workable")
		inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
		inst.components.workable:SetWorkLeft(2)
		inst.components.workable:SetOnFinishCallback(onhammered)

		inst:AddComponent("inspectable")

		return inst
    end

    return Prefab("common/objects/magiclantern_" .. color, fn, assets)
end

--- CREATE ALL MAGIC LANTERNS ---

local magiclanterns = {}
for id, color in ipairs(magiclanterncolors) do
    table.insert(magiclanterns, CreateLantern(id, color))--Creates The Magic Lantern via the above code
	table.insert(magiclanterns, MakePlacer( "common/magiclantern_".. color .. "_placer", "magiclantern", "magiclantern", id .. "_idle_off" ))--Creates the Placer for the respective lantern
end

return unpack(magiclanterns)