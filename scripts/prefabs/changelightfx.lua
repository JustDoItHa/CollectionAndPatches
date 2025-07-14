local function StopLightFx(inst)
	if inst.ChangeLightFx and inst.ChangeLightFx:IsValid() then 
		inst.ChangeLightFx:Remove()
	end
	if inst.ChangeLightCircle and inst.ChangeLightCircle:IsValid() then 
		inst.ChangeLightCircle:FadeOut()
	end
	inst.ChangeLightFx = nil 
	inst.ChangeLightCircle = nil 
	inst.change_lightfx_ison = false 
	print(inst,"Stop Light Fx !!!")
end 

local function StartLightFx(inst)
	if not inst.change_lightfx_ison then ------没开灯的话打开灯
		local checkcd = setcd(inst,"change_lightfx_cd",5*60,"嫦娥发光",true)
		if not checkcd then 
			return 
		end
		StopLightFx(inst)
		local fx = inst:SpawnChild("changelightfx")
		local circle = inst:SpawnChild("change_light_circle")
		circle:FadeIn()
		circle.Transform:SetScale(0.8,0.8,0.8)
		inst.ChangeLightFx = fx 
		inst.ChangeLightCircle = circle
		inst.change_lightfx_ison = true 
		WatchWorldStateOnce(inst, "startday", StopLightFx)
		print(inst,"Start Light Fx !!!")
	else ----------否则关闭灯
		StopLightFx(inst)
	end 
end 

local function ReBuildRPC()----------------可以清空过量的RPC并重新添加正确RPC
	MOD_RPC["change"] = nil   
	if TheNet:GetIsClient() then  
		AddModRPCHandler("change","change_lightfx",function() end)  
	end  
end

local function fxfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.Light:SetIntensity(0.8)
    inst.Light:SetColour(255 / 255, 250 / 255, 250 / 255)
    inst.Light:SetFalloff(.5)
    inst.Light:SetRadius(2)
    inst.Light:Enable(true)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

-------------在这里添加RPC比较合适
if TheNet:GetIsServer() then 
	AddModRPCHandler("change","change_lightfx",StartLightFx)
else
	AddModRPCHandler("change","change_lightfx",function() end)
end
ReBuildRPC()

return Prefab("changelightfx", fxfn)