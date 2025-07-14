local assets = {
	Asset("ANIM", "anim/change_light.zip"),
}

local SCALE = 0.65 

local function TurnOn(inst)
	inst.on = true
	inst.Light:Enable(true)
	inst.AnimState:PlayAnimation("idle_on")
end 

local function TurnOff(inst)
	inst.on = false 
	inst.Light:Enable(false)
	inst.AnimState:PlayAnimation("idle_off")
end

local function OnChange(inst, phase)
	if phase:match("night") then 
		inst.components.machine:TurnOn()
	else
		inst.components.machine:TurnOff()
	end
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

end

local function keepTwoDecimalPlaces(decimal) --四舍五入保留两位小数的代码 
    return math.floor((decimal * 100)+0.5)*0.01
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
	inst.entity:AddLight()
    inst.entity:AddNetwork()
	inst.entity:AddMiniMapEntity()  --要在小地图上显示的话，记得加这句
	inst.MiniMapEntity:SetIcon("change_light.tex")   --设置在地图上的图标，需要像人物一样先在modmain中先声明xml才行
	
	inst.Light:SetIntensity(.9)
    --inst.Light:SetColour(255 / 255, 175 / 255, 0 / 255)
    inst.Light:SetColour(255 / 255, 175 / 255, 0 / 255)
    inst.Light:SetFalloff(.6)
    inst.Light:SetRadius(10)
    inst.Light:Enable(false)

	MakeObstaclePhysics(inst, .05)
	
	inst.AnimState:SetBank("change_light")
    inst.AnimState:SetBuild("change_light")
    inst.AnimState:PlayAnimation("idle_on")
	
	inst.Transform:SetScale(SCALE,SCALE,SCALE)
	
	inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
	
	inst.on = false 
	
	inst:AddComponent("inspectable")
	
	inst:AddComponent("lootdropper")
	inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)
	
	inst:AddComponent("machine")
    inst.components.machine.turnonfn = TurnOn
    inst.components.machine.turnofffn = TurnOff
    inst.components.machine.cooldowntime = 0.5
	
	inst:DoTaskInTime(0, function(inst)
		local iscave = TheWorld:HasTag("cave")
		OnChange(inst, TheWorld.state[iscave and "cavephase" or "phase"])
		inst:WatchWorldState(iscave and "cavephase" or "phase", OnChange)
	end)
	
	return inst
end 

return Prefab("change_light", fn, assets),
	MakePlacer("change_light_placer", "change_light", "change_light", "idle_on",nil,nil,nil,SCALE) 