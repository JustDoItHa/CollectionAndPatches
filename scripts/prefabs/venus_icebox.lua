require "prefabutil"

local assets=
{
	Asset("ANIM", "anim/venus_icebox.zip"),
	Asset("ANIM", "anim/UI_Musha_4x4.zip"),
	Asset("SOUND", "sound/malibag.fsb"),
	Asset("SOUNDPACKAGE" , "sound/malibag.fev"),
	Asset("ATLAS", "images/inventoryimages/venus_icebox.xml"),
	Asset("IMAGE", "images/inventoryimages/venus_icebox.tex"),
}

local prefabs =
{
    "collapse_small",
}

local function onopen(inst)
    inst.AnimState:PlayAnimation("open")
    inst.SoundEmitter:PlaySound("malibag/malibag/open")
    for i = 1 , 4 do
        local item = inst.components.container:GetItemInSlot(i)
        if item and item.components.perishable then
            item.components.perishable.localPerishMultiplyer = 1
        end
    end
end

local function onclose(inst)
    inst.AnimState:PlayAnimation("close")
    inst.SoundEmitter:PlaySound("malibag/malibag/close")
    for i = 1 , 4 do
        local item = inst.components.container:GetItemInSlot(i)
        if item and item.components.perishable then
            item.components.perishable.localPerishMultiplyer = -0.2
        end
    end
end

local function onhammered(inst, worker)
    inst.components.lootdropper:DropLoot()
    inst.components.container:DropEverything()
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("metal")
    inst:Remove()
end

local function onhit(inst, worker)
    inst.AnimState:PlayAnimation("hit")
    inst.components.container:DropEverything()
    inst.AnimState:PushAnimation("closed", false)
    inst.components.container:Close()
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("closed", false)
    inst.SoundEmitter:PlaySound("dontstarve/common/icebox_craft")
end

local function onload( inst , date )
    if inst.prefab == "venus_icebox" then
        for i = 1 , 4 do
            local item = inst.components.container:GetItemInSlot(i)
            if item and item.components.perishable then
                item.components.perishable.localPerishMultiplyer = -0.2
            end
        end
    elseif inst.prefab == "venus_icebox" then
        for i = 1 , 4 do
            local item = inst.components.container:GetItemInSlot(i)
            if item and Platform ~= "TGP" then
                if item.components.perishable then
                    item.components.perishable.localPerishMultiplyer = -0.2
                elseif item.components.fueled then

                end
            end
        end
    end
end

local function fn()
    local inst = CreateEntity()
    
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("venus_icebox.tex")
    
    inst:AddTag("fridge")
    inst:AddTag("structure")
   
    inst.AnimState:SetBank("icebox")
    inst.AnimState:SetBuild("venus_icebox")
    inst.AnimState:PlayAnimation("closed")

    inst.SoundEmitter:PlaySound("dontstarve/common/ice_box_LP", "idlesound")

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
    
    inst:AddComponent("inspectable")
    inst:AddComponent("container")
    --inst.components.container.itemtestfn = itemtest
    inst.components.container:WidgetSetup("venus_icebox")
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose
    
    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(6)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    inst:ListenForEvent("onbuilt", onbuilt)
    MakeSnowCovered(inst)

    AddHauntableDropItemOrWork(inst)

    return inst
end

return Prefab("venus_icebox", fn, assets, prefabs),
        MakePlacer("venus_icebox_placer", "icebox", "venus_icebox", "closed")