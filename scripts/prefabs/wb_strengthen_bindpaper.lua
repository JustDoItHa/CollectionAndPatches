
-- 容器
local function MakeContainer(name, build)
  local assets = { Asset("ANIM", "anim/"..build..".zip") }
  local function fn()
      local inst = CreateEntity()
      inst.entity:AddTransform()
      inst.entity:AddNetwork()
      inst:AddTag("bundle")
      --V2C: blank string for controller action prompt
      inst.name = " "
      inst.entity:SetPristine()
      if not TheWorld.ismastersim then
          return inst
      end
      inst:AddComponent("container")
      inst.components.container:WidgetSetup(name)
      inst.persists = false
      return inst
  end
  return Prefab(name, fn, assets)
end

-- 绑定卷
local function MakeBindpaper(name)
  local assets = { Asset("ANIM", "anim/blueprint_sketch.zip") }
  local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("blueprint_sketch")
    inst.AnimState:SetBuild("blueprint_sketch")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("wb_strengthen_bindpaper")

    MakeInventoryFloatable(inst, "med", nil, 0.75)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("named")
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:ChangeImageName("sketch")
    
    local function OnStartBundling(inst, doer)
      inst:Remove()
    end

    inst:AddComponent("bundlemaker")
    inst.components.bundlemaker:SetBundlingPrefabs("wb_strengthen_bindpaper_container", "wb_strengthen_bindpaper_bundle")
    inst.components.bundlemaker:SetOnStartBundlingFn(OnStartBundling)

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL

    MakeHauntableLaunch(inst)

    return inst
  end

  return Prefab(name, fn, assets)
end

-- 解绑
local function MakeBundle(name)
  local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()


    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("unwrappable")

    function inst.components.unwrappable.WrapItems(unwrappable, items, doer)
      for index, item in ipairs(items) do
        local wbs = item and item.components.wb_strengthen
        if wbs then
          if wbs:HasBuff("bind") then
            wbs:UnBindBuff("bind")
            doer.components.talker:Say("它现在自由了")
          else
            wbs:BindBuff("bind", { userid = doer.userid, name = doer.name })
            doer.components.talker:Say("我们签订了契约？")
          end
        end
        doer.components.inventory:GiveItem(item, nil, doer:GetPosition())
      end
      inst:Remove()
    end

    return inst
  end

  return Prefab(name, fn)
end

return MakeContainer("wb_strengthen_bindpaper_container", "ui_bundle_2x2"),
  MakeBundle("wb_strengthen_bindpaper_bundle"),
  MakeBindpaper("wb_strengthen_bindpaper")