local assets =
{
    Asset("ANIM", "anim/white_wings.zip"),
    Asset("ANIM", "anim/swap_white_wings.zip"),
    Asset("ANIM", "anim/ui_backpack_2x4.zip"),
	
	Asset("ATLAS", "images/inventoryimages/wingpack/white_wings.xml"),
    Asset("IMAGE", "images/inventoryimages/wingpack/white_wings.tex"),
}


--white wings will have
	--insulation,
	--light,
	--slow hunger?
	

	
local function onequip(inst, owner)
   
    owner.AnimState:OverrideSymbol("swap_body", "swap_white_wings", "swap_body")
    
	if inst._light == nil or not inst._light:IsValid() then
        inst._light = SpawnPrefab("angellight")
    end
    inst._light.entity:SetParent(owner.entity)

    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")	
	inst._light.Light:Enable(true)
	
	if owner.components.hunger ~= nil then
        owner.components.hunger.burnratemodifiers:SetModifier(inst, 0.50)
    end	
		
    inst.components.container:Open(owner)
	owner:RemoveTag("scarytoprey")
	
end

local function turnoff_angel(inst)
    if inst._light ~= nil then
        if inst._light:IsValid() then
            inst._light:Remove()
        end
        inst._light = nil
    end
end

local function onunequip(inst, owner)
    
    owner.AnimState:ClearOverrideSymbol("swap_body")
	
	inst.AnimState:ClearBloomEffectHandle()
    inst._light.Light:Enable(false) 
	turnoff_angel(inst)
	if owner.components.hunger ~= nil then
        owner.components.hunger.burnratemodifiers:RemoveModifier(inst)
    end
    inst.components.container:Close(owner)
	owner:AddTag("scarytoprey")
	
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("white_wings")
    inst.AnimState:SetBuild("swap_white_wings")
    inst.AnimState:PlayAnimation("anim")

    local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon("white_wings.tex")

    inst.foleysound = "dontstarve/movement/foley/backpack"
	
	inst.OnEntityReplicated = function(inst) inst.replica.container:WidgetSetup("backpack") end

	inst:AddTag("white_wings")
	
    inst:AddTag("backpack")

    MakeInventoryFloatable(inst, "small", 0.1, 0.85)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst.OnEntityReplicated = function(inst) 
			inst.replica.container:WidgetSetup("backpack") 
		end
		
		return inst
	end	    

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.cangoincontainer = false
	inst.components.inventoryitem.atlasname = "images/inventoryimages/wingpack/white_wings.xml"
	inst.components.inventoryitem.imagename = "white_wings"
    inst.components.inventoryitem.cangoincontainer = true -- [[can be carried]]!!!!!!!!!!!!!!!!!!!!

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY	
	
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)    
	
	inst:AddComponent("insulator")
    inst.components.insulator:SetInsulation(480)

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("backpack")
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true
	
	inst._light = nil
    inst.OnRemoveEntity = turnoff_angel
	
    MakeHauntableLaunchAndDropFirstItem(inst)

    return inst
end

local function angellightfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.Light:SetRadius(1)
    inst.Light:SetFalloff(1)
    inst.Light:SetIntensity(.6)
    inst.Light:SetColour(7 / 255, 160 / 255, 198 / 255)
    inst.Light:Enable(false)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

return Prefab("white_wings", fn, assets),
	Prefab("angellight", angellightfn)
	

