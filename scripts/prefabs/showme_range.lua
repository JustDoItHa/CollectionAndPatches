local assets=
{
    Asset("ANIM", "anim/winona_spotlight_placement.zip"),
    Asset("ANIM", "anim/firefighter_placement.zip"),
}
PLACER_SCALE = 1.5

function OnEnableHelper_lhr(inst, enabled)
    if enabled then
        if inst.helper == nil then
            inst.helper = CreateEntity()
            --[[Non-networked entity]]
            inst.helper.entity:SetCanSleep(false)
            inst.helper.persists = false
            inst.helper.entity:AddTransform()
            inst.helper.entity:AddAnimState()
            inst.helper:AddTag("CLASSIFIED")
            inst.helper:AddTag("NOCLICK")
            inst.helper:AddTag("placer")

            local rval = 1.063      --40范围，圈似乎有点不圆...
            local p_s_r = string.format("%0.3f", PLACER_SCALE * rval)

            inst.helper.Transform:SetScale(p_s_r, p_s_r, p_s_r)
            inst.helper.AnimState:SetBank("winona_spotlight_placement")
            inst.helper.AnimState:SetBuild("winona_spotlight_placement")
            inst.helper.AnimState:SetAddColour(.3, .3, .1, 0)       --光叠加，RGBA橙黄
            inst.helper.AnimState:PlayAnimation("idle")
            inst.helper.AnimState:SetLightOverride(1)
            inst.helper.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
            inst.helper.AnimState:SetLayer(LAYER_BACKGROUND)
            inst.helper.AnimState:SetSortOrder(1)
            inst.helper.entity:SetParent(inst.entity)
        end
    elseif inst.helper ~= nil then
        inst.helper:Remove()
        inst.helper = nil
    end
end

function OnEnableHelper_ocep(inst, enabled)
    if enabled then
        if inst.helper == nil then
            inst.helper = CreateEntity()
            --[[Non-networked entity]]
            inst.helper.entity:SetCanSleep(false)
            inst.helper.persists = false
            inst.helper.entity:AddTransform()
            inst.helper.entity:AddAnimState()
            inst.helper:AddTag("CLASSIFIED")
            inst.helper:AddTag("NOCLICK")
            inst.helper:AddTag("placer")

            local rval = 1.25
            local p_s_r = string.format("%0.2f", PLACER_SCALE * rval)

            inst.helper.Transform:SetScale(p_s_r, p_s_r, p_s_r)
            inst.helper.AnimState:SetBank("firefighter_placement")
            inst.helper.AnimState:SetBuild("firefighter_placement")
            inst.helper.AnimState:SetAddColour(0, .2, .8, 0)     --蓝紫
            inst.helper.AnimState:PlayAnimation("idle")
            inst.helper.AnimState:SetLightOverride(1)
            inst.helper.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
            inst.helper.AnimState:SetLayer(LAYER_BACKGROUND)
            inst.helper.AnimState:SetSortOrder(1)
            inst.helper.entity:SetParent(inst.entity)
        end
    elseif inst.helper ~= nil then
        inst.helper:Remove()
        inst.helper = nil
    end
end

local function lhr_fn()     --避雷针
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.persists = false

    if not TheNet:IsDedicated() then
        inst:AddComponent("deployhelper")
        inst.components.deployhelper.onenablehelper = OnEnableHelper_lhr
    end
    --inst:ListenForEvent("onremove", function () inst:Remove() end)
    return inst
end

local function ocep_fn()        --大树干
	local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.persists = false

    if not TheNet:IsDedicated() then
        inst:AddComponent("deployhelper")
        inst.components.deployhelper.onenablehelper = OnEnableHelper_ocep
    end
	-- if RANGE_CHECK_TIME > 1 then
	-- 	inst:DoTaskInTime(RANGE_CHECK_TIME, function() inst:Remove() end)
	-- end

    return inst
end

return
		Prefab( "common/lhr_range_indicator", lhr_fn, assets),
		Prefab( "common/ocep_range_indicator", ocep_fn, assets)
