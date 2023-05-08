-----------���´���������������¯mod������
-----------�ڴ˱�ʾ��ߵľ��⣡

local assets = {
  Asset('ANIM', 'anim/lavaarena_shadow_lunge.zip'),
  Asset('ANIM', 'anim/waxwell_shadow_mod.zip'),
  Asset('ANIM', 'anim/swap_nightmaresword_shadow.zip')
}

local prefabs = {
  'statue_transition_2',
  'shadowstrike_slash_fx',
  'shadowstrike_slash2_fx',
  'weaponsparks'
}

local function StartShadows(self)
  SpawnPrefab('statue_transition_2').Transform:SetPosition(self.Transform:GetWorldPosition())
  self.AnimState:PlayAnimation('lunge_pre')
  self.AnimState:PushAnimation('lunge_lag')
  --self.AnimState:PushAnimation("lunge_pst")

  self:ListenForEvent(
    'animover',
    function()
      if self.AnimState:IsCurrentAnimation('lunge_lag') then
        self:InitAnim(nil, nil, true)
        self.AnimState:PlayAnimation('lunge_pst')
      end
    end
  )

  self:DoTaskInTime(
    12 * FRAMES,
    function(inst)
      inst.Physics:SetMotorVel(30, 0, 0)
    end
  )
  self:DoTaskInTime(
    15 * FRAMES,
    function(inst)
      inst:Attack()
    end
  )
  --self:DoTaskInTime(20*FRAMES, function(inst) inst.Physics:SetMotorVelOverride(5, 0, 0) end )
  self:DoTaskInTime(
    22 * FRAMES,
    function(inst)
      inst.Physics:ClearMotorVelOverride()
    end
  )
  self:DoTaskInTime(
    35 * FRAMES,
    function(inst)
      inst:Remove()
    end
  )
end

local function fn()
  local inst = CreateEntity()

  inst.entity:AddTransform()
  inst.entity:AddAnimState()
  inst.entity:AddSoundEmitter()
  inst.entity:AddPhysics()
  inst.entity:AddNetwork()

  inst.Transform:SetFourFaced(inst)

  --[[ inst.AnimState:SetBank("lavaarena_shadow_lunge")
    inst.AnimState:SetBuild("waxwell_shadow_mod")
    inst.AnimState:AddOverrideBuild("lavaarena_shadow_lunge")
    inst.AnimState:SetMultColour(0, 0, 0, .5)
    inst.AnimState:OverrideSymbol("swap_object", "swap_nightmaresword_shadow", "swap_nightmaresword_shadow")
    inst.AnimState:Hide("HAT")
    inst.AnimState:Hide("HAIR_HAT")--]]
  inst.Physics:SetMass(1)
  inst.Physics:SetFriction(0)
  inst.Physics:SetDamping(5)
  inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
  inst.Physics:ClearCollisionMask()
  inst.Physics:CollidesWith(COLLISION.GROUND)
  inst.Physics:SetCapsule(.5, 1)

  inst:AddTag('scarytoprey')
  inst:AddTag('NOBLOCK')

  inst.InitAnim = function(self, bank, build, override)
    inst.AnimState:SetBank(bank or 'lavaarena_shadow_lunge')
    inst.AnimState:SetBuild(build or 'waxwell_shadow_mod')
    if override then
      inst.AnimState:AddOverrideBuild('lavaarena_shadow_lunge')
    end
    inst.AnimState:SetMultColour(0, 0, 0, .5)
    inst.AnimState:OverrideSymbol('swap_object', 'swap_nightmaresword_shadow', 'swap_nightmaresword_shadow')
    --[[local hat = inst.player and inst.player.components.inventory and inst.player.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
		if hat then 
			local name = hat.prefab
			local fname = "hat_"..name
			inst.AnimState:Show("HAT")
			inst.AnimState:Show("HAIR_HAT")
			inst.AnimState:Hide("HAIR_NOHAT")
			inst.AnimState:Hide("HAIR")

			inst.AnimState:Hide("HEAD")
			inst.AnimState:Show("HEAD_HAT")
			inst.AnimState:OverrideSymbol("swap_hat", fname,"swap_hat")
		end--]]

    --inst.AnimState:Hide("HAT")
    --inst.AnimState:Hide("HAIR_HAT")
  end

  inst.entity:SetPristine()

  if not TheWorld.ismastersim then
    return inst
  end

  --[[inst:AddComponent("combat")
	inst.components.combat:SetDefaultDamage(TUNING.FORGE.SHADOWS.DAMAGE)--]]
  inst.SetPlayer = function(self, player)
    inst.player = player
    --if player and player.components.combat then player.components.combat:CopyBuffsTo(inst) end
  end

  inst.SetDamage = function(self, damage)
    inst.damage = damage or 0
  end

  inst.SetTarget = function(self, target)
    inst.target = target
    inst.target_pos = Point(target.Transform:GetWorldPosition())
    inst:FacePoint(inst.target_pos)
  end

  inst.SetPosition = function(self, target_pos, offset)
    inst.offset = offset
    self.Transform:SetPosition(target_pos.x + offset.x, target_pos.y + offset.y, target_pos.z + offset.z)
    StartShadows(self)
  end

  inst.Attack = function(self)
    local function RotateFX(fx)
      fx.Transform:SetPosition(self.target_pos.x, self.target_pos.y, self.target_pos.z)
      fx.Transform:SetRotation(self.Transform:GetRotation())
    end
    local rand = math.random(1, 2)
    if rand == 1 then
      RotateFX(SpawnPrefab('shadowstrike_slash_fx'))
    else
      RotateFX(SpawnPrefab('shadowstrike_slash2_fx'))
    end
    --RotateFX(SpawnPrefab("weaponsparks"))
    local spark_offset_mult = 0.25
    --SpawnPrefab("weaponsparks").Transform:SetPosition(self.target_pos.x + self.offset.x * spark_offset_mult, self.target_pos.y + self.offset.y * spark_offset_mult, self.target_pos.z + self.offset.z * spark_offset_mult)
    SpawnPrefab('ly_magical_weaponsparks'):SetThrusting(
      self.player,
      self.target,
      Vector3(self.offset.x * spark_offset_mult, self.offset.y * spark_offset_mult, self.offset.z * spark_offset_mult)
    )
    --self.player.components.combat:DoAttack(self.target, nil, nil, nil, 1, TUNING.FORGE.SHADOWS.DAMAGE, false, true)
    --self.components.combat:DoAttack(self.target, nil, nil, "strong")--"shadow")
    if self and self:IsValid() and self.target and self.target:IsValid() then
      local dist = math.sqrt(self:GetDistanceSqToInst(self.target))
      print('shadow attacks!', self.player, self.target, dist)
      if
        self.player and self.target and dist <= 3.5 and self.target.components.health and
          not self.target.components.health:IsDead()
       then
        self.target.components.combat:GetAttacked(self.player, self.damage)
      end
    end
    inst.SoundEmitter:PlaySound('dontstarve/common/lava_arena/fireball')
  end

  return inst
end

return Prefab('ly_magical_shadow', fn, assets, prefabs)
