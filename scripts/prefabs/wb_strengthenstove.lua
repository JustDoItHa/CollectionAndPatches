require 'prefabutil'
-- local fooddef = require('wintersfeastcookedfoods')

local sounds = {
  --placeholder sounds
  proximity_loop = '',
  door_open = 'dontstarve/quagmire/common/safe/open',
  door_close = 'wintersfeast2019/winters_feast/oven/start',
  cooking_loop = 'wintersfeast2019/winters_feast/oven/LP',
  finish = 'wintersfeast2019/winters_feast/oven/done',
  picked = 'dontstarve/quagmire/common/cooking/dish_place',
  hit = 'dontstarve/wilson/hit_metal',
  place = 'wintersfeast2019/winters_feast/table/place'
}

local function RemoveFireFx(inst)
  if inst._firefx ~= nil then
    inst._firefx:Remove()
    inst._firefx = nil
  end
end

local function MakeFireFx(inst)
  RemoveFireFx(inst)

  inst._firefx = SpawnPrefab('wintersfeastoven_fire')
  inst._firefx.entity:SetParent(inst.entity)
end

local function SetLightEnabled(inst, enabled)
  inst.Light:Enable(enabled or false)
end

local function onopen(inst)
  if
    not inst:HasTag('burnt') and
      not inst.AnimState:IsCurrentAnimation('item_idle') and
      not inst.AnimState:IsCurrentAnimation('idle_open')
   then
    if inst.AnimState:IsCurrentAnimation('hit_door_open') then
      inst.AnimState:PushAnimation('idle_open')

      inst:DoTaskInTime(
        inst.AnimState:GetCurrentAnimationLength() - inst.AnimState:GetCurrentAnimationTime(),
        function(inst)
          inst.SoundEmitter:PlaySound(sounds.door_open)
        end
      )
    elseif inst.AnimState:IsCurrentAnimation('hit_door_closed') or inst.AnimState:IsCurrentAnimation('place') then
      inst.AnimState:PushAnimation('proximity')
      inst.AnimState:PushAnimation('idle_open')

      inst:DoTaskInTime(
        math.max(0, inst.AnimState:GetCurrentAnimationLength() - inst.AnimState:GetCurrentAnimationTime()),
        function(inst)
          inst.SoundEmitter:PlaySound(sounds.door_open)
        end
      )
    else
      inst.AnimState:PlayAnimation('proximity')
      inst.AnimState:PushAnimation('idle_open')

      inst.SoundEmitter:PlaySound(sounds.door_open)
    end

    inst.SoundEmitter:KillSound('cooking_loop')
    inst.SoundEmitter:PlaySound(sounds.proximity_loop, 'cooking_loop')
  end
end

local function onclose(inst)
  if
    not inst:HasTag('burnt')
   then
    inst.AnimState:PushAnimation('cooking_start')
    inst.AnimState:PushAnimation('idle_closed')

    inst.SoundEmitter:KillSound('cooking_loop')
    inst:DoTaskInTime(
      math.max(0, inst.AnimState:GetCurrentAnimationLength() - inst.AnimState:GetCurrentAnimationTime()),
      function(inst)
        inst.SoundEmitter:PlaySound(sounds.door_close)
      end
    )
  end
end

local function onhammered(inst, worker)
  if inst.components.pickable and inst.components.pickable.caninteractwith and inst.components.pickable.product then
    inst.components.lootdropper:SetLoot({inst.components.pickable.product})
  end
  inst.components.lootdropper:DropLoot()

  local fx = SpawnPrefab('collapse_small')
  fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
  fx:SetMaterial('metal')

  inst:Remove()
end

local function onhit(inst, worker)
  if not inst.AnimState:IsCurrentAnimation('cook_done') then
    if inst.components.pickable ~= nil and inst.components.pickable.caninteractwith then
      inst.AnimState:PlayAnimation('hit_door_open')
      inst.AnimState:PushAnimation('item_idle')
      inst.SoundEmitter:PlaySound(sounds.hit)
    elseif inst.components.prototyper ~= nil and inst.components.prototyper.on then
      inst.AnimState:PlayAnimation('hit_door_open')
      inst.AnimState:PushAnimation('idle_open')
      inst.SoundEmitter:PlaySound(sounds.hit)
    elseif inst.components.madsciencelab == nil or not inst.components.madsciencelab:IsMakingScience() then
      inst.AnimState:PlayAnimation('hit_door_closed')
      inst.AnimState:PushAnimation('idle_closed')
      inst.SoundEmitter:PlaySound(sounds.hit)
    end
  end
end

local function GetContainerData (inst)
  if inst and inst.components.container == nil then return nil end
  local container = inst.components.container

  local c_item = container:GetItemInSlot(1)
  -- local c_item = event.item
  local data = {}
  if c_item == nil then return data end

  local c_item_wbs = c_item.components.wb_strengthen
  if c_item_wbs == nil then return data end

  data.name = c_item_wbs.original_name or c_item.name
  data.do_mode = c_item_wbs.do_mode

  if data.do_mode == nil then return data end

  data.level = c_item_wbs.level
  data.isweapon = c_item:HasTag('weapon')
  data.isarmor = c_item:HasTag('armor')

  data.c_level = c_item_wbs.level
  data.c_damage = ((c_item_wbs.buffs_status["damage"] and c_item_wbs.buffs_status["damage"].level_damage) or 0)
  data.c_absorb_percent = ((c_item_wbs.buffs_status["absorb_percent"] and c_item_wbs.buffs_status["absorb_percent"].level_absorb_percent) or 0)
  data.c_prizebuff_count = #c_item_wbs.prize_buff_list

  local n_item = SpawnPrefab(c_item.prefab)
  local n_item_wbs = n_item.components.wb_strengthen
  n_item_wbs.do_mode = c_item_wbs.do_mode
  n_item_wbs:SetLevel(c_item_wbs.level + 1)

  data.n_level = n_item_wbs.level
  data.n_damage = ((n_item_wbs.buffs_status["damage"] and n_item_wbs.buffs_status["damage"].level_damage) or 0)
  data.n_absorb_percent = ((n_item_wbs.buffs_status["absorb_percent"] and n_item_wbs.buffs_status["absorb_percent"].level_absorb_percent) or 0)
  data.n_prizebuff_count = #n_item_wbs.prize_buff_list

  if inst.components.container.opencount == 1 then
    for doer, value in pairs(inst.components.container.openlist) do
      data.probability = c_item_wbs:GetProbability(doer, c_item_wbs.do_mode, c_item_wbs.level + 1)
      if data.do_mode == "strengthen" then
        local _, redgem_count = doer.components.inventory:Has("redgem", 1)
        data.redgem_count = redgem_count or 0
      elseif data.do_mode == "increase" then
        local _, purplegem_count = doer.components.inventory:Has("purplegem", 1)
        data.purplegem_count = purplegem_count or 0
      end
    end
  end

  n_item:Remove()
  n_item = nil

  return data
end

local function UpdateContainerData (inst)
  local data = GetContainerData(inst)
  local suc, data_str = pcall(json.encode, data)
  if suc then
    inst._container_data:set(data_str)
    if TheWorld.ismastersim then
      inst:PushEvent("watch_container_data")
    end
  end
end

local assets = {}

local function fn()
  local inst = CreateEntity()

  inst.a = 1
	inst._container_data = net_string(inst.GUID, "wb_strengthenstove._container_data", "watch_container_data")
  -- inst:ListenForEvent("watch_container_data",function() end)

  inst.entity:AddTransform()
  inst.entity:AddAnimState()
  inst.entity:AddSoundEmitter()
  inst.entity:AddMiniMapEntity()
  inst.entity:AddLight()
  inst.entity:AddNetwork()

  inst.MiniMapEntity:SetIcon('wintersfeastoven.png') -- 图标

  inst:AddTag('structure') -- 建筑
  MakeObstaclePhysics(inst, 0.8, 1.2) -- 障碍物物理

  -- 光
  inst.Light:Enable(false)
  inst.Light:SetRadius(2)
  inst.Light:SetFalloff(1.5)
  inst.Light:SetIntensity(.5)
  inst.Light:SetColour(250 / 255, 180 / 255, 50 / 255)

  inst.AnimState:SetBank('wintersfeast_oven')
  inst.AnimState:SetBuild('wintersfeast_oven')
  inst.AnimState:PlayAnimation('idle_closed')
  inst.AnimState:SetFinalOffset(1)

  MakeSnowCoveredPristine(inst) -- 积雪

  inst.entity:SetPristine()

  if not TheWorld.ismastersim then
    return inst
  end

  inst:AddComponent('inspectable') -- 可检查

  inst:AddComponent('container') -- 容器
  inst.components.container:WidgetSetup('wb_strengthenstove')
  inst.components.container.onopenfn = onopen
  inst.components.container.onclosefn = onclose
  inst.components.container.skipclosesnd = true
  inst.components.container.skipopensnd = true

  inst:AddComponent('lootdropper') -- 战利品掉落（锤子锤掉）
  inst:AddComponent('workable') -- 可交互
  inst.components.workable:SetWorkAction(ACTIONS.HAMMER) -- 锤子
  inst.components.workable:SetWorkLeft(4) -- 2下？
  inst.components.workable:SetOnWorkCallback(onhit) -- 锤掉
  inst.components.workable:SetOnFinishCallback(onhammered) -- 交互

  MakeSmallBurnable(inst, nil, nil, true) -- 易燃

  MakeMediumPropagator(inst) -- 制作中号传播者?

  inst:AddComponent('hauntable') -- 作祟
  inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

  MakeSnowCovered(inst) -- 大雪覆盖

  UpdateContainerData(inst)
  inst.UpdateContainerData = function () return UpdateContainerData(inst) end
  inst:ListenForEvent("itemget", inst.UpdateContainerData)
  inst:ListenForEvent("itemlose", inst.UpdateContainerData)
  inst:ListenForEvent("onopen", function (inst, data)
    if inst.UpdateContainerData then
      inst.UpdateContainerData(inst)
      data.doer:ListenForEvent("itemget", inst.UpdateContainerData)
      data.doer:ListenForEvent("itemlose", inst.UpdateContainerData)
    end
  end)
  inst:ListenForEvent("onclose", function (inst, data)
    if inst.UpdateContainerData then
      data.doer:RemoveEventCallback("itemget", inst.UpdateContainerData)
      data.doer:RemoveEventCallback("itemlose", inst.UpdateContainerData)
    end
  end)

  if TUNING.PROTOTYPER_TREES.WB_STRENGTHENSTOVE_ONE then
    inst:AddComponent('prototyper')
    inst.components.prototyper.trees = TUNING.PROTOTYPER_TREES.WB_STRENGTHENSTOVE_ONE
    -- inst.components.prototyper.onturnon = onturnon
    -- inst.components.prototyper.onturnoff = onturnoff
  end

  -- inst.OnSave = onsave
  -- inst.OnLoad = onload

  return inst
end

return Prefab(
  'wb_strengthenstove',
  fn,
  {
    Asset('ANIM', 'anim/wintersfeast_oven.zip'),
    Asset('ANIM', 'anim/food_winters_feast_2019.zip')
  },
  {
    'wintersfeastoven_fire',
    'collapse_small'
  }
), MakePlacer('wb_strengthenstove_placer', 'wintersfeast_oven', 'wintersfeast_oven', 'idle_closed')
