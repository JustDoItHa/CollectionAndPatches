local assets =
{
	Asset("ANIM", "anim/waterdrop.zip"),
    Asset("ANIM", "anim/lifeplant.zip"),
	
	Asset( "IMAGE", "images/inventoryimages/change_waterdrop.tex" ),
	Asset( "ATLAS", "images/inventoryimages/change_waterdrop.xml" ),
}

local function ondeploy (inst, pt) 
    local plant = SpawnPrefab("change_lifeplant")
    plant.Transform:SetPosition(pt:Get() )
    plant.AnimState:PlayAnimation("grow")
    plant.AnimState:PushAnimation("idle_loop",true)

    inst.planted = true
    inst:Remove()
end

local notags = {'NOBLOCK', 'player', 'FX'}


local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()
	
    MakeInventoryPhysics(inst)


    inst.AnimState:SetBank("waterdrop")
    inst.AnimState:SetBuild("waterdrop")

    inst.AnimState:PlayAnimation("idle")
    inst:AddTag("waterdrop")
	
	inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("edible")
    inst.components.edible.foodtype = FOODTYPE.VEGGIE  
    inst.components.edible.healthvalue = 2
    inst.components.edible.hungervalue = 3
    inst.components.edible.sanityvalue = 3


    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "change_waterdrop"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/change_waterdrop.xml"

    
    inst:AddComponent("deployable")
    inst.components.deployable.ondeploy = ondeploy    

    return inst
end

return Prefab( "change_waterdrop", fn, assets),
       MakePlacer( "change_waterdrop_placer", "lifeplant", "lifeplant", "idle_loop" )

