
local assets = 
{
	Asset("ANIM", "anim/structure_collapse_fx.zip"),
}

local function fn_dragon()

    local inst = CreateEntity()
	
	inst.entity:AddTransform()
    inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()
	
    inst.AnimState:SetBank("collapse")
    inst.AnimState:SetBuild("structure_collapse_fx")
    inst.AnimState:PlayAnimation("collapse_small")
	inst.AnimState:SetMultColour(0.58, 0.69, 0.82, 1)
	
	inst:AddTag("NOCLICK")
	inst:AddTag("FX")
	
	inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
	inst:DoTaskInTime(0, function()
		inst.SoundEmitter:PlaySound("dontstarve/common/destroy_smoke")
	end)
	
	inst.persists = false
	
	inst:ListenForEvent("animover", inst.Remove)
	
    return inst
end

local function fn_ice()

    local inst = CreateEntity()
	
	inst.entity:AddTransform()
    inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()
	
    inst.AnimState:SetBank("collapse")
    inst.AnimState:SetBuild("structure_collapse_fx")
    inst.AnimState:PlayAnimation("collapse_small")
	inst.AnimState:SetMultColour(0.67, 0.53, 0.53, 1)
	
	inst:AddTag("NOCLICK")
	inst:AddTag("FX")
	
	inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
	inst:DoTaskInTime(0, function()
		inst.SoundEmitter:PlaySound("dontstarve/common/destroy_smoke")
	end)
	
	inst.persists = false
	
	inst:ListenForEvent("animover", inst.Remove)
	
    return inst
end

return 	Prefab("dragonflyfurnace_transform_fx", fn_dragon, assets),
		Prefab("icefurnace_transform_fx", fn_ice, assets)
		