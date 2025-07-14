
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
local function MakeLevelpaper(name, mode, level, force)
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

    inst.mode = mode
    inst.level = level
    inst.force = force

    inst:AddTag("wb_strengthen_levelpaper")

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
    inst.components.bundlemaker:SetBundlingPrefabs("wb_strengthen_levelpaper_container", "wb_strengthen_levelpaper_bundle")
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
        local bundlinginst = doer.components.bundler.bundlinginst
        local count = 0
        for index, item in ipairs(items) do
          local wbs = item and item.components.wb_strengthen
          if wbs and bundlinginst.force or not wbs.do_mode or wbs.do_mode == bundlinginst.mode then
            item.components.wb_strengthen.do_mode = bundlinginst.mode
            if bundlinginst.level and bundlinginst.level == 13 then
				item.components.wb_strengthen:SetLevel(item.components.wb_strengthen:GetLevel()+1, true)
			else
				item.components.wb_strengthen:SetLevel(bundlinginst.level)
			end
            count = count + 1
          end
          doer.components.inventory:GiveItem(item, nil, doer:GetPosition())
        end
      
        local mode_str = "净化"
        if bundlinginst.mode == "strengthen" then mode_str = "强化" end
        if bundlinginst.mode == "increase" then mode_str = "附魔" end
        if count < #items then
          local bundler = doer.components.bundler
          local item = SpawnPrefab(bundler.itemprefab, bundler.itemskinname, bundler.wrappedskin_id )
          if item ~= nil then
            doer.components.inventory:GiveItem(item, nil, doer:GetPosition())
          end
          return doer.components.talker:Say("这件装备不可以" .. mode_str .. "了")
        end
        doer.components.talker:Say(mode_str .. "成功")
        inst:Remove()
      end
    end

    return inst
  end

  return Prefab(name, fn)
end

return MakeContainer("wb_strengthen_levelpaper_container", "ui_bundle_2x2"),
  MakeBundle("wb_strengthen_levelpaper_bundle"),
  MakeLevelpaper("wb_strengthen_clearpaper", nil, 0, true),
  MakeLevelpaper("wb_strengthen_strengthen_7_levelpaper", "strengthen", 7, false),
  MakeLevelpaper("wb_strengthen_strengthen_8_levelpaper", "strengthen", 8, false),
  MakeLevelpaper("wb_strengthen_strengthen_9_levelpaper", "strengthen", 9, false),
  MakeLevelpaper("wb_strengthen_strengthen_10_levelpaper", "strengthen", 10, false),
  MakeLevelpaper("wb_strengthen_strengthen_11_levelpaper", "strengthen", 11, false),
  MakeLevelpaper("wb_strengthen_strengthen_12_levelpaper", "strengthen", 12, false),
  MakeLevelpaper("wb_strengthen_increase_7_levelpaper", "increase", 7, false),
  MakeLevelpaper("wb_strengthen_increase_8_levelpaper", "increase", 8, false),
  MakeLevelpaper("wb_strengthen_increase_9_levelpaper", "increase", 9, false),
  MakeLevelpaper("wb_strengthen_increase_10_levelpaper", "increase", 10, false),
  MakeLevelpaper("wb_strengthen_increase_11_levelpaper", "increase", 11, false),
  MakeLevelpaper("wb_strengthen_increase_12_levelpaper", "increase", 12, false),
  MakeLevelpaper("wb_strengthen_increase_next_levelpaper", "increase", 13, false)
