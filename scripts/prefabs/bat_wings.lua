--bat wings will have 
--	bat tag
--	dapperness
-- health on kill

local assets =
{
    Asset("ANIM", "anim/bat_wings.zip"),
    Asset("ANIM", "anim/swap_bat_wings.zip"),
    Asset("ANIM", "anim/ui_backpack_2x4.zip"),
	
	Asset("ATLAS", "images/inventoryimages/wingpack/bat_wings.xml"),
    Asset("IMAGE", "images/inventoryimages/wingpack/bat_wings.tex"),
}



local function onisnight(inst, isnight)
    
    if isnight then
        if inst.components.equippable.dapperness == (0) then
			inst.components.equippable.dapperness = (0.09)
		elseif not isnight then 
			if inst.components.equippable.dapperness ~= (0) then
				inst.components.equippable.dapperness = (0)
			end
		end
    end
end

local function onisday(inst, isday)
    
    if isday then
        if inst.components.equippable.dapperness == (0.09) then
			inst.components.equippable.dapperness = (0)
		end
    end
end



local function batattack(inst, data) -- to other functions
    if not data.weapon then
		return
	end
    if data ~= nil and data.target ~= nil and data.weapon:HasTag("batbuff") then		
        if not data.target:HasTag("engineering") or
            data.target:HasTag("wall")           
            and data.target.components.health ~= nil
            and data.target.components.combat ~= nil then
                inst.components.hunger:DoDelta(10)
				inst.components.health:DoDelta(3)
        end
    end
end


local function onequip(inst, owner)
   
    owner.AnimState:OverrideSymbol("swap_body", "swap_bat_wings", "swap_body")    
	
    inst.components.container:Open(owner)
	inst:ListenForEvent("onattackother", batattack, owner)
	owner:AddTag("bat")	
	
	
end

local function onunequip(inst, owner)
    	
    owner.AnimState:ClearOverrideSymbol("swap_body")	
	
    inst.components.container:Close(owner)
	inst:RemoveEventCallback("onattackother", batattack, owner)
	owner:RemoveTag("bat")	
	
	
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()	
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()		

    MakeInventoryPhysics(inst)	
		
	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon("bat_wings.tex")

    inst.AnimState:SetBank("bat_wings")
    inst.AnimState:SetBuild("swap_bat_wings")
    inst.AnimState:PlayAnimation("anim")

    inst.foleysound = "dontstarve/movement/foley/backpack"
	
	inst.OnEntityReplicated = function(inst) inst.replica.container:WidgetSetup("backpack") end
	
	inst:AddTag("bat_wings")
	
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
	inst.components.inventoryitem.atlasname = "images/inventoryimages/wingpack/bat_wings.xml"
	inst.components.inventoryitem.imagename = "bat_wings"
    inst.components.inventoryitem.cangoincontainer = true -- [[can be carried]]!!!!!!!!!!!!!!!!!!!!

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY	
	inst.components.equippable.dapperness = (0)
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)	
  	
    inst:AddComponent("container")
    inst.components.container:WidgetSetup("backpack")
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true	
		
	inst:WatchWorldState("isnight", onisnight)
    onisnight(inst, TheWorld.state.isnight)
	
	inst:WatchWorldState("isday", onisday)
    onisday(inst, TheWorld.state.isday)
	
    MakeHauntableLaunchAndDropFirstItem(inst)

    return inst
end

return Prefab("bat_wings", fn, assets)