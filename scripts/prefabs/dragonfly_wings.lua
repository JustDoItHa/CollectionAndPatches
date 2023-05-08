local assets =
{
    Asset("ANIM", "anim/dragonfly_wings.zip"),
    Asset("ANIM", "anim/swap_dragonfly_wings.zip"),
    Asset("ANIM", "anim/ui_backpack_2x4.zip"),
	
	Asset("ATLAS", "images/inventoryimages/dragonfly_wings.xml"),
    Asset("IMAGE", "images/inventoryimages/dragonfly_wings.tex"),
}
--drognfly (fairy) wings will have
--	summer insulation 
--	refrigeration
--	spawns butterflies



local function flutterby(inst, DoSpawn)
	local loot_roll = math.random()
	if loot_roll <= (0.02) then
		flutterby = inst.components.periodicspawner:SetPrefab("moonbutterfly")			
		else if loot_roll >= (0.97) then
			flutterby = inst.components.periodicspawner:SetPrefab("killerbee")
		else 
			flutterby = inst.components.periodicspawner:SetPrefab("butterfly")
				
		end 
	end
end

local function onequip(inst, owner)
    
    owner.AnimState:OverrideSymbol("swap_body", "swap_dragonfly_wings", "swap_body")
    
	inst.components.periodicspawner:Start()
    inst.components.container:Open(owner)
	
end

local function onunequip(inst, owner)
    
    owner.AnimState:ClearOverrideSymbol("swap_body")
	inst.components.periodicspawner:Stop()
    inst.components.container:Close(owner)
	
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("dragonfly_wings")
    inst.AnimState:SetBuild("swap_dragonfly_wings")
    inst.AnimState:PlayAnimation("anim")

    local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon("dragonfly_wings.tex")

    inst.foleysound = "dontstarve/movement/foley/backpack"
	
	inst.OnEntityReplicated = function(inst) inst.replica.container:WidgetSetup("backpack") end

	inst:AddTag("dragonfly_wings")
	inst:AddTag("fridge")
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
	inst.components.inventoryitem.atlasname = "images/inventoryimages/dragonfly_wings.xml"
	inst.components.inventoryitem.imagename = "dragonfly_wings"
    inst.components.inventoryitem.cangoincontainer = true -- [[can be carried]]!!!!!!!!!!!!!!!!!!!!

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY	
	
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    
    inst:AddComponent("periodicspawner")
	inst:ListenForEvent("DoSpawn", flutterby)
    inst.components.periodicspawner:SetPrefab(flutterby)
    inst.components.periodicspawner:SetRandomTimes(60, 1, true)		
	
	inst:AddComponent("insulator")
        inst.components.insulator:SetInsulation(TUNING.INSULATION_LARGE)
        inst.components.insulator:SetSummer()

        inst.components.equippable.insulated = true

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("backpack")
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true	
	
	MakeHauntableLaunchAndDropFirstItem(inst)
	
	inst:DoPeriodicTask(59.0, flutterby)
	
    return inst
end

return Prefab("dragonfly_wings", fn, assets)
