local _ = require('utils/wb_util')

local skill_configs = {}
skill_configs['召唤极光'] = {
  canuseonpoint = true,
  spellfn = function(level, skill, staff, target, pos)
    local light = SpawnPrefab('stafflight')
    light.Transform:SetPosition(pos:Get())
    local caster = staff.components.inventoryitem.owner
    if caster then
      caster.components.talker:Say('Lumos!')
    end
  end
}
skill_configs['召唤矮星'] = {
  canuseonpoint = true,
  spellfn = function(level, skill, staff, target, pos)
    local caster = staff.components.inventoryitem.owner
    if caster then
      caster.components.talker:Say('Lumos Maxima!')
    end
    local light = SpawnPrefab('staffcoldlight')
    light.Transform:SetPosition(pos:Get())
  end
}
skill_configs['催眠法术'] = {
  canuseonpoint = true,
  spellfn = function(level, skill, staff, target, pos)
    local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, 30)
    for k, v in pairs(ents) do
      if v.components.sleeper ~= nil and not v:HasTag('player') then
        v.components.sleeper:AddSleepiness(10, TUNING.PANFLUTE_SLEEPTIME)
      end
      if v.components.grogginess ~= nil and not v:HasTag('player') then
        v.components.grogginess:AddGrogginess(10, TUNING.PANFLUTE_SLEEPTIME)
      end
    end
  end
}
skill_configs['召唤寒冰'] = {
  canuseonpoint = true,
  spellfn = function(level, skill, staff, target, pos)
    local light = SpawnPrefab('deer_ice_circle')
    light.Transform:SetPosition(pos:Get())
    light:DoTaskInTime(0, light.TriggerFX)
    light:DoTaskInTime(5, light.KillFX)
    local caster = staff.components.inventoryitem.owner
    if caster then
      caster.components.talker:Say('Freezing Charm!')
    end
  end
}
skill_configs['召唤火焰'] = {
  canuseonpoint = true,
  spellfn = function(level, skill, staff, target, pos)
    local light = SpawnPrefab('deer_fire_circle')
    light.Transform:SetPosition(pos:Get())
    light:DoTaskInTime(0, light.TriggerFX)
    light:DoTaskInTime(5, light.KillFX)
    local caster = staff.components.inventoryitem.owner
    if caster then
      caster.components.talker:Say('Furnunculus!')
    end
  end
}
skill_configs['召唤旋风'] = {
  canuseonpoint = true,
  spellfn = function(level, skill, staff, target, pos)
    local x,
      y,
      z = pos:Get()
    local lighta = SpawnPrefab('tornado')
    lighta.Transform:SetPosition(x + 1, y, z)
    local lightb = SpawnPrefab('tornado')
    lightb.Transform:SetPosition(x - 1, y, z)
    local lighte = SpawnPrefab('tornado')
    lighte.Transform:SetPosition(x, y, z + 1)
    local lightf = SpawnPrefab('tornado')
    lightf.Transform:SetPosition(x, y, z - 1)
    local caster = staff.components.inventoryitem.owner
    if caster then
      caster.components.talker:Say('Ventus!')
    end
  end
}
skill_configs['召唤流星'] = {
  canuseonpoint = true,
  spellfn = function(level, skill, staff, target, pos)
    local light = SpawnPrefab('shadowmeteor')
    light.Transform:SetPosition(pos:Get())
    local caster = staff.components.inventoryitem.owner
    if caster then
      caster.components.talker:Say('Reducto!')
    end
  end
}
skill_configs['召唤孢子云'] = {
  canuseonpoint = true,
  spellfn = function(level, skill, staff, target, pos)
    local light = SpawnPrefab('sporecloud')
    light.Transform:SetPosition(pos:Get())
    local caster = staff.components.inventoryitem.owner
    if caster then
      caster.components.talker:Say('Stinging Jinx!')
    end
  end
}
skill_configs['召唤沙刺'] = {
  canuseonpoint = true,
  spellfn = function(level, skill, staff, target, pos)
    local x,
      y,
      z = pos:Get()
    local lighta = SpawnPrefab('sandspike_tall')
    lighta.Transform:SetPosition(x + 1, y, z)
    local lightb = SpawnPrefab('sandspike_tall')
    lightb.Transform:SetPosition(x - 1, y, z)
    local lighte = SpawnPrefab('sandspike_tall')
    lighte.Transform:SetPosition(x, y, z + 1)
    local lightf = SpawnPrefab('sandspike_tall')
    lightf.Transform:SetPosition(x, y, z - 1)
    local caster = staff.components.inventoryitem.owner
    if caster then
      caster.components.talker:Say('Expulso!')
    end
  end
}
skill_configs['召唤爆炸蘑菇'] = {
  canuseonpoint = true,
  spellfn = function(level, skill, staff, target, pos)
    local x,
      y,
      z = pos:Get()
    local lighta = SpawnPrefab('mushroombomb')
    lighta.Transform:SetPosition(x + 1.73, y, z - 1)
    local lightb = SpawnPrefab('mushroombomb')
    lightb.Transform:SetPosition(x - 1.72, y, z - 1)
    local lightc = SpawnPrefab('mushroombomb')
    lightc.Transform:SetPosition(x, y, z + 2)
    local caster = staff.components.inventoryitem.owner
    if caster then
      caster.components.talker:Say('Confringo!')
    end
  end
}
skill_configs['召唤触手'] = {
  canuseonpoint = true,
  spellfn = function(level, skill, staff, target, pos)
    local x,
      y,
      z = pos:Get()
    local lighta = SpawnPrefab('tentacle')
    lighta.Transform:SetPosition(x + 1, y, z)
    local lightb = SpawnPrefab('tentacle')
    lightb.Transform:SetPosition(x - 1, y, z)
    local lightc = SpawnPrefab('tentacle')
    lightc.Transform:SetPosition(x, y, z + 1)
    local lightd = SpawnPrefab('tentacle')
    lightd.Transform:SetPosition(x, y, z - 1)
    local caster = staff.components.inventoryitem.owner
    if caster then
      caster.components.talker:Say('Tentacle Charm!')
    end
  end
}
skill_configs['召唤闪电'] = {
  canuseonpoint = true,
  spellfn = function(level, skill, staff, target, pos)
    local caster = staff.components.inventoryitem.owner
    --local Sleep = GLOBAL.Sleep
    local TheWorld = _G.TheWorld
    local num_lightnings = 16
    caster:StartThread(function()
      for k = 0, num_lightnings do
        local pos = Vector3(pos:Get()) + Vector3(math.random(0, 1), 0, math.random(0, 1))
        TheWorld:PushEvent('ms_sendlightningstrike', pos)
        --Sleep(.3 + math.random() * .2)
      end
    end)
    if caster then
      caster.components.talker:Say('Lightning Charm')
    end
  end
}
skill_configs['召唤鸟'] = {
  canuseonpoint = true,
  spellfn = function(level, skill, staff, target, pos)
    local TheWorld = _G.TheWorld
    local Sleep = _G.Sleep
    local birdspawner = TheWorld.components.birdspawner
    if birdspawner == nil then
      return false
    end
    local caster = staff.components.inventoryitem.owner
    local pt = caster:GetPosition()
    local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, 10, nil, nil, {'magicalbird'})
    if #ents > 30 then
      if caster then
        caster.components.talker:Say('Avis!')
      end
    else
      local num = math.random(10, 20)
      if #ents > 20 then
        if caster then
          caster.components.talker:Say('Avis！')
        end
      else
        num = num + 10
      end
      caster:StartThread(
        function()
          for k = 1, num do
            local pos = birdspawner:GetSpawnPoint(pt)
            if pos ~= nil then
              local bird = birdspawner:SpawnBird(pos, true)
              if bird ~= nil then
                bird:AddTag('magicalbird')
              end
            end
            Sleep(math.random(.2, .25))
          end
        end
      )
    end

    local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, 30)
    for k, v in pairs(ents) do
      if v.components.sleeper ~= nil and not v:HasTag('player') then
        v.components.sleeper:AddSleepiness(10, TUNING.PANFLUTE_SLEEPTIME)
      end
      if v.components.grogginess ~= nil and not v:HasTag('player') then
        v.components.grogginess:AddGrogginess(10, TUNING.PANFLUTE_SLEEPTIME)
      end
    end

    return true
  end
}
skill_configs['催熟作物'] = {
  canuseonpoint = true,
  spellfn = function(level, skill, staff, target, pos)
    local function trygrowth(inst)
      if inst:IsInLimbo() or (inst.components.witherable ~= nil and inst.components.witherable:IsWithered()) then
        return
      end

      if inst.components.pickable ~= nil then
        if inst.components.pickable:CanBePicked() and inst.components.pickable.caninteractwith then
          return
        end
        inst.components.pickable:FinishGrowing()
      end

      if inst.components.crop ~= nil and (inst.components.crop.rate or 0) > 0 then
        inst.components.crop:DoGrow(1 / inst.components.crop.rate, true)
      end

      if inst.components.growable ~= nil then
        -- If we're a tree and not a stump, or we've explicitly allowed magic growth, do the growth.
        if
          ((inst:HasTag('tree') or inst:HasTag('winter_tree')) and not inst:HasTag('stump')) or
            inst.components.growable.magicgrowable
         then
          inst.components.growable:DoGrowth()
        end
      end

      if
        inst.components.harvestable ~= nil and inst.components.harvestable:CanBeHarvested() and
          inst:HasTag('mushroom_farm')
       then
        inst.components.harvestable:Grow()
      end
    end

    local caster = staff.components.inventoryitem.owner
    if caster then
      caster.components.talker:Say('Orchideous!')
    end
    local x,
      y,
      z = caster.Transform:GetWorldPosition()
    local range = 30
    local ents = TheSim:FindEntities(x, y, z, range, nil, {'pickable', 'stump', 'withered', 'INLIMBO'})
    if #ents > 0 then
      trygrowth(table.remove(ents, math.random(#ents)))
      if #ents > 0 then
        local timevar = 1 - 1 / (#ents + 1)
        for i, v in ipairs(ents) do
          v:DoTaskInTime(timevar * math.random(), trygrowth)
        end
      end
    end
    return true
  end
}
skill_configs['呼风唤雨'] = {
  canuseonpoint = true,
  spellfn = function(level, skill, staff, target, pos)
    local TheWorld = _G.TheWorld
    if TheWorld.state.israining or TheWorld.state.issnowing then
      TheWorld:PushEvent('ms_forceprecipitation', false)
    else
      TheWorld:PushEvent('ms_forceprecipitation', true)
    end
    local caster = staff.components.inventoryitem.owner
    if caster then
      caster.components.talker:Say('Atmospheric Charm!')
    end
  end
}

local skill_list = {}
for skill_name, skill in pairs(skill_configs) do
  skill.skill_name = skill_name
  table.insert(skill_list, skill)
end

-- ==================================================================

local WbHandsskill = Class(function(self, inst)
  self.inst = inst
  self.skill_name = nil
  self.skill_level = 0

  self.onspellfn = function (...)
    local skill = skill_configs[self.skill_name]
    if not skill then return end
    skill.spellfn(self.skill_level, skill, ...)
  end
end)

function WbHandsskill:OnSave()
  return {
    skill_name = self.skill_name,
    skill_level = self.skill_level
  }
end

function WbHandsskill:OnLoad(data)
  if data and data.skill_name then
    self:InstallSkill(data.skill_name, data.skill_level or 1)
  end
end

-- 安装技能
function WbHandsskill:InstallSkill(skill_name, skill_level)
  local skill = skill_configs[skill_name]
  if not skill then return end
  self.skill_name = skill_name
  self.skill_level = skill_level
  if not self.inst.components.spellcaster then
    self.inst:AddComponent("spellcaster")
  end
  self.inst.components.spellcaster:SetSpellFn(self.onspellfn)
  self.inst.components.spellcaster.canuseonpoint = skill.canuseonpoint
end

-- 随机安装技能
function WbHandsskill:RandomInstallSkill()
  local index = math.random(1, #skill_list)
  local skill = skill_list[index]
  if not skill then return end
  return self:InstallSkill(skill.skill_name, 1)
end

-- 是否有技能
function WbHandsskill:HasSkill()
  return self.skill_name ~= nil
end

-- 卸载技能
function WbHandsskill:UninstallSkill()
  self.skill_name = nil
  self.skill_level = 0
end

return WbHandsskill
