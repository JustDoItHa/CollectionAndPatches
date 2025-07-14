local assets =
{
    Asset("ANIM", "anim/blueprint_sketch.zip"),
}

local PROTECTPAPERS = 
{
    { name = "强化保护卷", mode = "strengthen" },
    { name = "附魔保护卷", mode = "increase" }
}

local function onload(inst, data)
end

local function onsave(inst, data)
end

function MakeSketchPrefab (data)
  local prefab_name = "wb_strengthen_" .. data.mode .."_protectpaper"
  STRINGS.NAMES[string.upper(prefab_name)] = data.name

  local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("blueprint_sketch")
    inst.AnimState:SetBuild("blueprint_sketch")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("wb_strengthen_protectpaper")

    MakeInventoryFloatable(inst, "med", nil, 0.75)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("named")
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:ChangeImageName("sketch")
    
    -- inst:AddComponent("tradable")
    -- inst:AddComponent("trader")

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL

    MakeHauntableLaunch(inst)

    inst.OnLoad = onload
    inst.OnSave = onsave

    inst.mode = data.mode
    inst.level = data.level
    inst.components.named:SetName(data.name)
    return inst
  end

  return Prefab(prefab_name, fn, assets)
end

local prefabs = {}
for index, value in ipairs(PROTECTPAPERS) do
  table.insert(prefabs, MakeSketchPrefab(value))
end

return unpack(prefabs)
