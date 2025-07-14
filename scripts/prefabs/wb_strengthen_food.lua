
local food_list = {
  {
    prefab = "wb_strengthen_strengthen_food",
    name = "强化秘药",
    assets = {
      Asset("ANIM", "anim/halloween_potions.zip"),
    },

    atlas = "images/inventoryimages1.xml",
    imagename = "halloweenpotion_bravery_large", -- .tex

    bank = "halloween_potions",
    build = "halloween_potions",
    play_animation = "bravery_large",

    tags = {},

    maxsize = 1,

    foodtype = FOODTYPE.GOODIES,

    hungervalue = 0, --三维
    sanityvalue = 0,
    healthvalue = 0,

    oneaten = function (nst, eater)
      if eater and eater.components.talker then
        eater.components.talker:Say("欧皇附体！")
      end
    end,

    buff_id = "wb_strengthen_strengthen_food_buff",
    buff_duration = 2 * 60,
    buff_onattach = function (inst, target)
      inst.wb_strengthen_probability = 0.01 -- 加1.5%概率
    end,
    buff_onextend = function (inst, target)
      inst.components.timer:StopTimer('regenover')
      inst.components.timer:StartTimer('regenover', inst.param.buff_duration)
    end,
    buff_ondetach = function (inst, target)
      inst.wb_strengthen_probability = 0
    end,
  },
  {
    prefab = "wb_strengthen_increase_food",
    name = "增幅秘药",
    assets = {
      Asset("ANIM", "anim/halloween_potions.zip"),
    },

    atlas = "images/inventoryimages1.xml",
    imagename = "halloweenpotion_bravery_large", -- .tex

    bank = "halloween_potions",
    build = "halloween_potions",
    play_animation = "bravery_large",

    tags = {},

    maxsize = 1,

    foodtype = FOODTYPE.GOODIES,

    hungervalue = 0, --三维
    sanityvalue = 0,
    healthvalue = 0,

    oneaten = function (nst, eater)
      if eater and eater.components.talker then
        eater.components.talker:Say("欧皇附体！")
      end
    end,

    buff_id = "wb_strengthen_increase_food_buff",
    buff_duration = 2 * 60,
    buff_onattach = function (inst, target)
      inst.wb_strengthen_probability = 0.01 -- 加1.5%概率
    end,
    buff_onextend = function (inst, target)
      inst.components.timer:StopTimer('regenover')
      inst.components.timer:StartTimer('regenover', inst.param.buff_duration)
    end,
    buff_ondetach = function (inst, target)
      inst.wb_strengthen_probability = 0
    end,
  },
}

for i, param in ipairs(food_list) do
  if param.atlas == nil then
    param.atlas = "images/inventoryimages/" .. param.prefab .. ".xml"
  end
end

function MakeFood(name, param)
  STRINGS.NAMES[string.upper(name)] = param.name
	local assets = {}
  if param.assets then
    for index, asset in ipairs(param.assets) do
      table.insert(assets, asset)
    end
  end

  if param.atlas then
    table.insert(assets, Asset("ATLAS", param.atlas))
  end

	local function fn()
		local inst = CreateEntity()

		inst.entity:AddTransform()
		inst.entity:AddAnimState()
		inst.entity:AddSoundEmitter()
		inst.entity:AddNetwork()

		MakeInventoryPhysics(inst)

		inst.AnimState:SetBank(param.bank)
		inst.AnimState:SetBuild(param.build)
		inst.AnimState:PlayAnimation(param.play_animation)

    for index, tag in ipairs(param.tags) do
      inst:AddTag(tag)
    end

		MakeInventoryFloatable(inst)
		
		inst.entity:SetPristine()

		if not TheWorld.ismastersim then
			return inst
		end

    inst:AddComponent("edible")
    inst.components.edible.foodtype = FOODTYPE.GOODIES
    inst.components.edible.hungervalue = param.hungervalue or 0
    inst.components.edible.sanityvalue = param.sanityvalue or 0
    inst.components.edible.healthvalue = param.healthvalue or 0

    if param.buff_id and param.buff_duration > 1 then
      inst.components.edible.oneaten = function (inst, eater)
        if param.oneaten then
          param.oneaten(inst, eater)
        end
        if eater.components.debuffable ~= nil and eater.components.debuffable:IsEnabled() and
          not (eater.components.health ~= nil and eater.components.health:IsDead()) and
          not eater:HasTag("playerghost") then
          eater.components.debuffable:AddDebuff(param.buff_id, param.buff_id)
        end
      end
    end

		inst:AddComponent("tradable")

		inst:AddComponent("inspectable")

		inst:AddComponent("inventoryitem")
		inst.components.inventoryitem.atlasname = param.atlas
    inst.components.inventoryitem:ChangeImageName(param.imagename)

    if param.maxsize ~= 1 then
      inst:AddComponent("stackable")
      inst.components.stackable.maxsize = param.maxsize or TUNING.STACK_SIZE_LARGEITEM
    end

		MakeHauntableLaunch(inst)

		return inst
	end
	return Prefab(name, fn, assets)
end

function MakeFoodBuff(name, param)
	local function fn()
		local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()
    
    inst:AddTag('CLASSIFIED')
    inst:AddTag('NOCLICK')
    inst:AddTag('NOBLOCK')

    inst.param = param

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
      return inst
    end

    inst.persists = false
    inst:AddComponent('debuff')
    inst.components.debuff:SetAttachedFn(function (inst, target, ...)
      param.buff_onattach(inst, target, ...)
      return target:AddChild(inst)
    end)
    inst.components.debuff:SetDetachedFn(function (inst, target, ...)
      param.buff_ondetach(inst, target, ...)
      return inst:Remove()
    end)
    inst.components.debuff:SetExtendedFn(param.buff_onextend)
    inst.components.debuff.keepondespawn = true

    inst:AddComponent('timer')
    inst.components.timer:StartTimer('buffover', param.buff_duration)
    inst:ListenForEvent('timerdone', function(inst, data)
      if data.name == 'buffover' then
        inst.components.debuff:Stop()
      end
    end)

    inst:Hide()

		return inst
	end
	return Prefab(name, fn)
end

local prefab_list = {}
for i, param in ipairs(food_list) do
  table.insert(prefab_list, MakeFood(param.prefab, param))
  if param.buff_id then
    table.insert(prefab_list, MakeFoodBuff(param.buff_id, param))
  end
end

return unpack(prefab_list)