local assets =
{
    Asset("ANIM", "anim/boat_test.zip"),
}

local UpvalueHacker=require("tools/upvaluehacker")

local OnSpawnNewBoatLeak=UpvalueHacker.GetUpvalue(Prefabs.boat.fn, "OnSpawnNewBoatLeak")
local SpawnFragment=UpvalueHacker.GetUpvalue(Prefabs.boat.fn, "SpawnFragment")

local create_common_pre=UpvalueHacker.GetUpvalue(Prefabs.boat.fn, "create_common_pre")
local create_master_pst=UpvalueHacker.GetUpvalue(Prefabs.boat.fn, "create_master_pst")

local sounds=UpvalueHacker.GetUpvalue(Prefabs.boat.fn, "sounds")

local boat_player_collision_template=UpvalueHacker.GetUpvalue(Prefabs.boat_player_collision.fn, "boat_player_collision_template")
local boat_item_collision_template=UpvalueHacker.GetUpvalue(Prefabs.boat_item_collision.fn, "boat_item_collision_template")

local common_item_fn_pre=UpvalueHacker.GetUpvalue(Prefabs.boat_item.fn, "common_item_fn_pre")
local common_item_fn_pst=UpvalueHacker.GetUpvalue(Prefabs.boat_item.fn, "common_item_fn_pst")

local function MakeBoat(name,radius)
    local stats_multiplier=(radius/TUNING.BOAT.RADIUS)^2
    local scale_multiplier=radius/TUNING.BOAT.RADIUS
    
	local function wood_fn()
		local inst = CreateEntity()

		local bank = "boat_01"
		local build = "boat_test"
		local max_health = TUNING.BOAT.HEALTH*stats_multiplier
		local item_collision_prefab = "boat_"..name.."_item_collision"
		local scale = scale_multiplier
		local boatlip = "boatlip"

		inst = create_common_pre(inst, bank, build, radius, max_health, item_collision_prefab, scale, boatlip)

		inst.walksound = "wood"

		inst.components.walkableplatform.player_collision_prefab = "boat_"..name.."_player_collision"

		inst.entity:SetPristine()

		if not TheWorld.ismastersim then
			return inst
		end

		inst = create_master_pst(inst, bank, build, radius, max_health, item_collision_prefab, scale, boatlip)
		
		inst.components.boatphysics.sizespeedmultiplier=1/scale_multiplier
        inst.components.boatphysics.max_velocity=TUNING.BOAT.MAX_VELOCITY_MOD/scale_multiplier
		inst.components.hullhealth.leak_radius=2.5*scale_multiplier
		inst.components.waterphysics.restitution=0.75*stats_multiplier

		inst:ListenForEvent("spawnnewboatleak", OnSpawnNewBoatLeak)
		inst.boat_crackle = "fx_boat_crackle"

		inst.sinkloot = function()
				local ignitefragments = inst.activefires > 0
				local locus_point = Vector3(inst.Transform:GetWorldPosition())
				local num_loot = (radius^2/4)*(3/4)
				for i = 1, num_loot do
					local r = math.sqrt(math.random())*(TUNING.BOAT.RADIUS-2) + 1.5
					local t = i * PI2/num_loot + math.random() * (PI2/(num_loot * .5))
					SpawnFragment(locus_point, "boards",  math.cos(t) * r,  0, math.sin(t) * r, ignitefragments)
				end
			end

		inst.postsinkfn = function()
				local fx_boat_crackle = SpawnPrefab("fx_boat_pop")
				fx_boat_crackle.Transform:SetPosition(inst.Transform:GetWorldPosition())
				inst.SoundEmitter:PlaySoundWithParams(inst.sounds.damage, {intensity= 1})
				inst.SoundEmitter:PlaySoundWithParams(inst.sounds.sink)
			end

		inst.sounds = sounds

		return inst
	end

    local function item_fn()
		local inst = CreateEntity()

		common_item_fn_pre(inst)
		inst._boat_radius = radius

		inst.deploy_product = "boat_"..name

		inst.entity:SetPristine()

		if not TheWorld.ismastersim then
			return inst
		end

		common_item_fn_pst(inst)
		inst.components.deployable:SetDeploySpacing(scale_multiplier>=1.5 and DEPLOYSPACING.LARGEBOATS or DEPLOYSPACING.PLACER_DEFAULT)
		inst.components.inventoryitem:ChangeImageName("boat_item")

        return inst
    end

    return {Prefab("boat_"..name, wood_fn, assets, prefabs),
           Prefab("boat_"..name.."_player_collision", function() return boat_player_collision_template(radius) end),
           Prefab("boat_"..name.."_item_collision", function() return boat_item_collision_template(radius) end),
           Prefab("boat_item_"..name, item_fn),
           MakePlacer("boat_item_"..name.."_placer", "boat_01", "boat_test", "idle_full", true, false, false, math.sqrt(scale_multiplier), nil, nil, nil, radius*1.5)}
end
local FilePrefabs={}
for i,v in ipairs(MakeBoat("small",2)) do
    table.insert(FilePrefabs,v)
end
for i,v in ipairs(MakeBoat("large",6)) do
    table.insert(FilePrefabs,v)
end
for i,v in ipairs(MakeBoat("giant",8)) do
    table.insert(FilePrefabs,v)
end
return unpack(FilePrefabs)