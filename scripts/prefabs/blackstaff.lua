local assets=
{
	Asset("ANIM", "anim/blackstaff.zip"),
	Asset("ANIM", "anim/swap_blackstaff.zip"),
	Asset("ATLAS", "images/blackstaff.xml"),
	Asset("IMAGE", "images/blackstaff.tex"),
}

local function onequip(inst, owner) 
	owner.AnimState:OverrideSymbol("swap_object", "swap_blackstaff", "symbol0")
	owner.AnimState:Show("ARM_carry")
	owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner) 
    owner.AnimState:Hide("ARM_carry") 
    owner.AnimState:Show("ARM_normal")
end

local function blackstafffn(staff, target, pos)
	local ents = TheSim:FindEntities(pos.x,pos.y,pos.z, 2.7)
	
	for k,v in pairs(ents) do
        if v.components.inventoryitem
        and v.components.inventoryitem.owner == nil
        and v.prefab ~= "chester_eyebone"
        and v.prefab ~= "glommerflower"
        and v.prefab ~= "hutch_fishbowl"
        and v.prefab ~= "moonrockseed"
        and v.prefab ~= "moon_altar_glass"
        and v.prefab ~= "moon_altar_idol"
        and v.prefab ~= "moon_altar_seed"
        and v.prefab ~= "sculpture_rooknose"
        and v.prefab ~= "sculpture_knighthead"
        and v.prefab ~= "sculpture_bishophead"
        and staff.components.finiteuses.current >= 1 then
			staff.components.inventoryitem.owner.SoundEmitter:PlaySound("dontstarve/common/staff_dissassemble")
			if v.components.inventory then v.components.inventory:DropEverything() end
			if v.components.container then v.components.container:DropEverything() end
			staff.components.finiteuses:Use(1)
			v:Remove()
		end
	end
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("blackstaff")
    inst.AnimState:SetBuild("blackstaff")
    inst.AnimState:PlayAnimation("idle")

	inst:AddTag("sharp")
    inst:AddTag("nopunch")
    inst:AddTag("allow_action_on_impassable")
	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
        return inst
    end

	inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "blackstaff"
    inst.components.inventoryitem.atlasname = "images/blackstaff.xml"
	
	inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

	inst:AddComponent("spellcaster")
    inst.components.spellcaster:SetSpellFn(blackstafffn)
	inst.components.spellcaster.canuseonpoint = true
	inst.components.spellcaster.canuseonpoint_water = true
	return inst
end
return Prefab("blackstaff", fn, assets)