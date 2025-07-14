
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

-- 升级卷
local function MakePaper(name)
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

    inst:AddTag("wb_handsskill_paper")

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
      if doer.components.bundler then
        local bundlinginst = doer.components.bundler.bundlinginst
        bundlinginst.mode = inst.mode
        bundlinginst.level = inst.level
        bundlinginst.force = inst.force
      end
      inst:Remove()
    end

    inst:AddComponent("bundlemaker")
    inst.components.bundlemaker:SetBundlingPrefabs("wb_handsskill_paper_container", "wb_handsskill_paper_bundle")
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
      if doer.components.bundler then
        local count = 0
        for index, item in ipairs(items) do
          local wbs = item and item.components.wb_strengthen
          local wbh = item and item.components.wb_handsskill
          if wbs and wbs.level >= 11 and item:HasTag('equippable-hands') and ((not item.components.spellcaster and not item.components.blinkstaff) or wbh) then
            if not wbh then item:AddComponent('wb_handsskill') end
            wbh = item.components.wb_handsskill
            wbh:RandomInstallSkill()
            doer.components.talker:Say("装备获得技能：" .. wbh.skill_name)
            count = count + 1
          end
          doer.components.inventory:GiveItem(item, nil, doer:GetPosition())
        end

        if count < #items then
          local bundler = doer.components.bundler
          local item = SpawnPrefab(bundler.itemprefab, bundler.itemskinname, bundler.wrappedskin_id )
          if item ~= nil then
            doer.components.inventory:GiveItem(item, nil, doer:GetPosition())
          end
          return doer.components.talker:Say("无法对这个装备使用")
        end
        inst:Remove()
      end
    end

    return inst
  end

  return Prefab(name, fn)
end

return MakeContainer("wb_handsskill_paper_container", "ui_bundle_2x2"),
  MakeBundle("wb_handsskill_paper_bundle"),
  MakePaper("wb_handsskill_paper")
