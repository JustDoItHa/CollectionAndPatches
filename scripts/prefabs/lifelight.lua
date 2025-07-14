
local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddLight()
    inst.entity:AddNetwork()
    
    inst:AddTag("FX")
    inst.Light:SetFalloff(0.7)
    inst.Light:SetIntensity(.5)
    inst.Light:SetRadius(8)
    inst.Light:SetColour(190/255, 190/255, 190/255)

    inst.entity:SetPristine()
    
    if not TheWorld.ismastersim then
        return inst
    end

    --inst:DoTaskInTime(60, inst.Remove)

    inst.persists = false
    return inst
end

return Prefab("lifelight", fn)