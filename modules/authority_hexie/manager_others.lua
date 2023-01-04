local _G = GLOBAL
local TheSim = _G.TheSim
local TheNet = _G.TheNet
local TheShard = _G.TheShard
local worldShardId = TheShard:GetShardId()
local Vector3 = _G.Vector3
local SpawnPrefab = _G.SpawnPrefab
local ShakeAllCameras = _G.ShakeAllCameras
local FindEntity = _G.FindEntity

local IsServer = TheNet:GetIsServer() or TheNet:IsDedicated()

local STRINGS = _G.STRINGS
local ACTIONS = _G.ACTIONS
local FRAMES = _G.FRAMES
local CAMERASHAKE = _G.CAMERASHAKE

--防止火焰蔓延
local spreadFire = GetModConfigData("spread_fire")
--远古犀牛刷新时间,如果小于0则不刷新
local minotaur_regenerate = GetModConfigData("minotaur_regenerate")
--远古犀牛是否允许拆家
local minotaur_destroy = GetModConfigData("minotaur_destroy")

if IsServer then
	if spreadFire ~= 2 then
		local CurrentMakeSmallPropagator = _G.MakeSmallPropagator
		_G.MakeSmallPropagator = function(inst)
			CurrentMakeSmallPropagator(inst)
			if inst.components.propagator then
				if spreadFire == 1 then --Half range
					inst.components.propagator.propagaterange = inst.components.propagator.propagaterange/2.0
				else
					inst.components.propagator.propagaterange = 0
				end
			end
		end

		local CurrentMakeMediumPropagator = _G.MakeMediumPropagator
		_G.MakeMediumPropagator = function(inst)
			CurrentMakeMediumPropagator(inst)
			if inst.components.propagator then
				if spreadFire == 1 then --Half range
					inst.components.propagator.propagaterange = inst.components.propagator.propagaterange/2.0
				else
					inst.components.propagator.propagaterange = 0
				end
			end
		end
		
		local MakeLargePropagator = _G.MakeLargePropagator
		_G.MakeLargePropagator = function(inst)
			MakeLargePropagator(inst)
			if inst.components.propagator then
				if spreadFire == 1 then --Half range
					inst.components.propagator.propagaterange = inst.components.propagator.propagaterange/2.0
				else
					inst.components.propagator.propagaterange = 0
				end
			end
		end
	end

	---得到恶魔之门的坐标---
	AddPrefabPostInit("multiplayer_portal", function(inst)
		inst:DoTaskInTime(0, function()
			local pos = inst:GetPosition()
			if pos.x ~= nil and pos.y ~= nil and pos.z ~= nil then
				_G.TheWorld.multiplayer_portal_pos = pos
			end
		end)
	end)

	---防止炸药炸毁建筑---
	AddComponentPostInit("explosive", function(explosive, inst)
		inst.buildingdamage = 0
		explosive.CurrentOnBurnt = explosive.OnBurnt
		function explosive:OnBurnt()
			local x, y, z = inst.Transform:GetWorldPosition()
			--local ents2 = _G.TheSim:FindEntities(x, y, z, explosive.explosiverange, nil, { "INLIMBO" })
			local ents2 = _G.TheSim:FindEntities(x, y, z, 10)
			local nearbyStructure = false
			for k, v in ipairs(ents2) do
				if v.components.burnable ~= nil and not v.components.burnable:IsBurning() then
					if v:HasTag("structure") then
						nearbyStructure = true
					end
				end
			end
			--
			if nearbyStructure then  --Make sure structures aren't lit on fire (indirectly) from explosives
				inst:RemoveTag("canlight")
			else
				inst:AddTag("canlight")
				explosive:CurrentOnBurnt()
			end
		end
	end)

	-- 远古犀牛
	AddPrefabPostInit("minotaur", function (inst)
		if _G.TheWorld:HasTag("cave") and minotaur_regenerate > 0 then
			local auth_minotaur = _G.TheWorld.guard_authorization.minotaur
			if auth_minotaur == nil then
				auth_minotaur = {}
				_G.TheWorld.guard_authorization.minotaur = auth_minotaur
			end
			if auth_minotaur.position == nil then
				inst:DoTaskInTime(0, function()
					local base_x, base_y, base_z = inst.Transform:GetWorldPosition()
					if base_x ~= nil and base_x ~= 0 then
						auth_minotaur.position = { x = base_x, y = base_y, z = base_z }
					end
				end)
			end
			if auth_minotaur.name == nil then
				auth_minotaur.name = inst.name or (STRINGS.NAMES[string.upper(inst.prefab)] or "远古守护者")
			end
			auth_minotaur.isSpawnPrefab = false
			inst:ListenForEvent("onremove", function()
				local lastattacker = inst.components.combat and inst.components.combat.lastattacker
				TheNet:Announce("【 "..inst:GetDisplayName().." 】".. (lastattacker and "被【 "..lastattacker.name.." 】击杀" or "") .." 将在"..minotaur_regenerate.."天后刷新")
				auth_minotaur.isSpawnPrefab = true
				-- 仅仅记录下击杀时间
				auth_minotaur.lastDay = _G.tonumber(_G.TheWorld.state.cycles)
				auth_minotaur.generateDay = auth_minotaur.lastDay + minotaur_regenerate
				if auth_minotaur.position == nil then
					local x, y, z = inst.Transform:GetWorldPosition()
					auth_minotaur.position = x ~= nil and x ~= 0 and { x = x, y = y, z = z } or { x = 0, y = 0, z = 0 }
				end
			end)
		end

		if minotaur_destroy then
			local function ClearRecentlyCharged(inst, other)
				inst.recentlycharged[other] = nil
			end

			local function onothercollide(inst, other)
				if not other:IsValid() or inst.recentlycharged[other] then
					return
				elseif other:HasTag("smashable") and other.components.health ~= nil then
					--other.Physics:SetCollides(false)
					other.components.health:Kill()
				elseif other.components.workable ~= nil
					and other.components.workable:CanBeWorked()
					and other.components.workable.action ~= ACTIONS.NET then
					SpawnPrefab("collapse_small").Transform:SetPosition(other.Transform:GetWorldPosition())
					other.components.workable:Destroy(inst)
					if other:IsValid() and other.components.workable ~= nil and other.components.workable:CanBeWorked() then
						inst.recentlycharged[other] = true
						inst:DoTaskInTime(3, ClearRecentlyCharged, other)
					end
				elseif other.components.hammerworkable ~= nil
					and other.components.hammerworkable:CanBeWorked()
					and other.components.hammerworkable.action ~= ACTIONS.NET then
					SpawnPrefab("collapse_small").Transform:SetPosition(other.Transform:GetWorldPosition())
					other.components.hammerworkable:Destroy(inst)
					if other:IsValid() and other.components.hammerworkable ~= nil and other.components.hammerworkable:CanBeWorked() then
						inst.recentlycharged[other] = true
						inst:DoTaskInTime(3, ClearRecentlyCharged, other)
					end
				elseif other.components.health ~= nil and not other.components.health:IsDead() then
					inst.recentlycharged[other] = true
					inst:DoTaskInTime(3, ClearRecentlyCharged, other)
					SpawnPrefab("collapse_small").Transform:SetPosition(other.Transform:GetWorldPosition())
					inst.SoundEmitter:PlaySound("dontstarve/creatures/rook/explo")
					inst.components.combat:DoAttack(other)
				end

				-- 预留方法,用于摧毁额外的建筑
				if inst.onhxcollide ~= nil then
					inst.onhxcollide(inst, other)
				end
			end

			local function oncollide(inst, other)
				if not (other ~= nil and other:IsValid() and inst:IsValid())
					or inst.recentlycharged[other]
					or other:HasTag("player")
					or Vector3(inst.Physics:GetVelocity()):LengthSq() < 42 then
					return
				end
				ShakeAllCameras(CAMERASHAKE.SIDE, .5, .05, .1, inst, 40)
				inst:DoTaskInTime(2 * FRAMES, onothercollide, other)
			end

			inst.Physics:SetCollisionCallback(oncollide)
		end
	end)

	-- 远古犀牛刷新
	local function SpawnerMinotaurFn(inst)
		if inst.guard_authorization.minotaur.isSpawnPrefab then
			local new_minotaur = SpawnPrefab("minotaur")
			TheNet:Announce("【 ".. inst.guard_authorization.minotaur.name .." 】已刷新")
			local newPos = GetFanValidPoint(inst.guard_authorization.minotaur.position)
			local setPos = newPos or inst.guard_authorization.minotaur.position
			ItemAnimSetPosition(new_minotaur, setPos.x, setPos.y, setPos.z, false, true)
		end
	end

	-- 远古犀牛重生组件(蚁狮版本新加_当开启锁刷新时屏蔽系统犀牛重生)
	AddPrefabPostInit("minotaur_ruinsrespawner_inst", function (inst)
		if _G.TheWorld:HasTag("cave") and minotaur_regenerate > 0 then
			-- inst.resetruins = nil
			-- 移除刷新监听事件
			RemoveEventCallbackEx(inst, "resetruins", "scripts/prefabs/ruinsrespawner.lua", _G.TheWorld)
			inst:ListenForEvent("resetruins", SpawnerMinotaurFn, _G.TheWorld)
		end
	end)

	-- 使豪华大箱和大号华丽箱子可砸
	local caveChestTable = {
		-- "pandoraschest",   -- 豪华大箱
		"minotaurchest",   -- 大号华丽箱子
	}

	local function CaveChestWorkFn(inst)
		if inst.components.workable == nil and inst.gd_superlevel == nil then
			local function onhammered(inst, worker)
				if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
					inst.components.burnable:Extinguish()
				end
				inst.components.lootdropper:DropLoot()
				if inst.components.container ~= nil then
					inst.components.container:DropEverything()
				end
				local fx = SpawnPrefab("collapse_small")
				fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
				fx:SetMaterial("wood")
				inst:Remove()
			end

			local function onhit(inst, worker)
				if not inst:HasTag("burnt") then
					inst.AnimState:PlayAnimation("hit")
					inst.AnimState:PushAnimation("closed", false)
					if inst.components.container ~= nil then
						inst.components.container:DropEverything()
						inst.components.container:Close()
					end
				end
			end

			if inst.components.lootdropper == nil then
				inst:AddComponent("lootdropper")
			end
			inst:AddComponent("workable")
			inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
			inst.components.workable:SetWorkLeft(2)
			inst.components.workable:SetOnFinishCallback(onhammered)
			inst.components.workable:SetOnWorkCallback(onhit)

			if inst.components.burnable == nil then
				_G.MakeSmallBurnable(inst, nil, nil, true)
			end
			if inst.components.propagator == nil then
				_G.MakeMediumPropagator(inst)
			end

			-- 移除刷新监听事件
			RemoveEventCallbackEx(inst, "resetruins", "scripts/prefabs/treasurechest.lua", _G.TheWorld)
		end
	end

	for k,name in pairs(caveChestTable) do
		AddPrefabPostInit(name, CaveChestWorkFn)
	end

	AddPrefabPostInit("world", function(inst)
		inst:ListenForEvent("cycleschanged", function(inst, data)
			if inst.guard_authorization and inst.guard_authorization.minotaur and inst.guard_authorization.minotaur.generateDay and inst.state.cycles >= inst.guard_authorization.minotaur.generateDay then
				SpawnerMinotaurFn(inst)
			end
		end)
	end)

	-- 眼球塔攻击的权限判断 2020.02.26
	AddPrefabPostInit("eyeturret", 
		function(inst) 
			local Combat = inst.components.combat
			local old_CanTarget = Combat.CanTarget 

			-- 有权限的墙和眼球塔不作为目标
			function Combat:CanTarget(target) 
				
				if (target.ownerlist ~= nil and (string.find(target.prefab, "wall_") or string.find(target.prefab, "fence")) ) 
					or target.prefab == "eyeturret"
					then 
					return false
				end

				local ret = old_CanTarget(Combat, target) 
				return ret 
			end

			-- 重构选择目标的函数
			local old_retargetfn = Combat.targetfn 
			local function retargetfn(inst) 
				local target = old_retargetfn(inst) 

				if target ~= nil then 

					-- 只帮助有权限的人攻击目标
					local player_attacked = ((target.components.combat.target ~= nil and target.components.combat.target:HasTag("player")) and target.components.combat.target) or nil 
					if player_attacked ~= nil and CheckItemPermission(player_attacked, inst, true) then 
						return target 
					end

					-- 若攻击者有权限才协助其攻击
					for i, v in ipairs(_G.AllPlayers) do
						if v.components.combat.target ~= nil then
							local attack_target = v.components.combat.target 
							if CheckItemPermission(v, inst, true) then 
								return attack_target 
							end 
							return nil 
						end
					end 

					return nil 
				end

				return target
			end

			Combat:SetRetargetFunction(1, retargetfn)
		end
	)

end