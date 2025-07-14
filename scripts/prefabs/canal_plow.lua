local assets = {
    Asset("ANIM", "anim/farm_plow.zip"),
    Asset("ATLAS", "images/inventoryimages/canal_plow_item.xml"),
    Asset("IMAGE", "images/inventoryimages/canal_plow_item.tex")
}

local prefabs = {"collapse_big", "canal_plow"}

local function timerdone(inst, data)
    local x, y, z = inst.Transform:GetWorldPosition()
    SpawnPrefab("collapse_big").Transform:SetPosition(x, y, z)

    -- 地图操作
    local tile = TheWorld.Map:GetTileAtPoint(x, 0, z)
    local tx, ty = TheWorld.Map:GetTileCoordsAtPoint(x, y, z)
    if IsLandTile(tile) then
        TheWorld.Map:SetTile(
                tx, ty, TheWorld.has_ocean and WORLD_TILES.OCEAN_COASTAL or
                        WORLD_TILES.IMPASSABLE
        )
    elseif IsOceanTile(tile) then
        TheWorld.Map:SetTile(tx, ty, WORLD_TILES.ROCKY)
    end

    inst:Remove()
end

local function dodrilling(inst)
    inst:RemoveEventCallback("animover", dodrilling)
    inst.AnimState:PlayAnimation("drill_loop", true)
    inst.SoundEmitter:PlaySound("farming/common/farm/plow/LP", "loop")
end

local function startup(inst)
    inst.AnimState:PlayAnimation("drill_pre")
    inst:ListenForEvent("animover", dodrilling)
    inst.SoundEmitter:PlaySound("farming/common/farm/plow/drill_pre")
    inst.components.timer:StartTimer("working", 6)
end

local function main_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    MakeObstaclePhysics(inst, 0.5)

    inst.AnimState:SetBank("farm_plow")
    inst.AnimState:SetBuild("farm_plow")

    inst:AddTag("scarytoprey")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("timer")

    inst:DoTaskInTime(0, startup)
    inst:ListenForEvent("timerdone", timerdone)

    return inst
end

local function ondeploy(inst, pt, deployer)
    local cx, cy, cz = TheWorld.Map:GetTileCenterPoint(pt:Get())
    local item = SpawnPrefab("canal_plow")
    item.Transform:SetPosition(cx, cy, cz)

    inst.components.stackable:Get():Remove()
end

-- local function client_candeplyitem(inst, pt, mouseover, deployer, rotation)
--     local tx, ty = TheWorld.Map:GetTileCoordsAtPoint(pt.x, 0, pt.z)
--     local cx, cy, cz = TheWorld.Map:GetTileCenterPoint(pt:Get())
--     local ents = TheSim:FindEntities(
--             cx, cy, cz, 3, nil,
--             {"INLIMBO", "FX", "CLASSIFIED", "player"}
--     )
--     if next(ents) == nil then
--         local tile = TheWorld.Map:GetTile(tx, ty)
--         if TUNING.CANAL_PLOW_DEPLOY_RULE == false and
--                 (IsLandTile(tile) or IsOceanTile(tile)) then
--             return true
--         end
--         if IsLandTile(tile) and tile ~= WORLD_TILES.MONKEY_DOCK then
--             for x_off = -1, 1, 1 do
--                 for y_off = -1, 1, 1 do
--                     if ((x_off ~= 0 and y_off == 0) or
--                             (x_off == 0 and y_off ~= 0)) and
--                             IsOceanTile(TheWorld.Map:GetTile(tx + x_off, ty + y_off)) then
--                         return true
--                     end
--                 end
--             end
--         elseif IsOceanTile(tile) and tile ~= WORLD_TILES.MONKEY_DOCK then
--             for x_off = -1, 1, 1 do
--                 for y_off = -1, 1, 1 do
--                     -- if ((x_off ~= 0 and y_off == 0) or
--                     --         (x_off == 0 and y_off ~= 0)) and
--                     --         IsLandTile(TheWorld.Map:GetTile(tx + x_off, ty + y_off)) then
--                     if (x_off ~= 0 or y_off ~= 0) and IsLandTile(TheWorld.Map:GetTile(tx + x_off, ty + y_off)) then
--                         return true
--                     end
--                 end
--             end
--         end
--     end
--     return false
-- end


local ents_special_table = {
    multiplayer_portal_moonrock = true, --天体门
    multiplayer_portal_moonrock_constr = true,
    multiplayer_portal = true,
    cave_entrance_open = true,--洞穴
    cave_entrance_ruins = true,
    cave_entrance = true,
    cave_exit = true, --楼梯
}


local function checkent(inst, pt, deployer)

    local x, z = pt.x, pt.z
    local ents_table = {
        Tile = TheWorld.Map:GetEntitiesOnTileAtPoint(x, 0, z),--检测同一地皮内的实体
        Special = TheSim:FindEntities(x, 0, z, 8, nil, nil, nil)--检测范围8内的实体
    }

    for k, ents in pairs(ents_table) do
        for _, ent in pairs(ents) do
            if (
                    k == "Tile" and ent ~= inst and ent ~= deployer and
                            not (ent:HasTag("NOBLOCK") or ent:HasTag("locomotor") or ent:HasTag("NOCLICK") or ent:HasTag("FX") or ent:HasTag("DECOR"))
                            or( k == "Tile" and ent.components.health )
            )--(同地皮内有物品 基本上和耕地机判定一样)
                    or (k == "Special" and ent.prefab and ents_special_table[ent.prefab]) --范围20内有黑名单物品(大门洞穴)
            then
                return false
            end
        end
    end
    return true
end


local function client_candeplyitem(inst, pt, mouseover, deployer, rotation)
    local tile = TheWorld.Map:GetTileAtPoint(pt.x, 0, pt.z)
    local tileinfo_land = IsLandTile(tile)
    local tileinfo_ocean = IsOceanTile(tile)

    if IsLandTile(tile) or IsOceanTile(tile) then
        local found_adjacent_safetile = false
        local tx, ty = TheWorld.Map:GetTileCoordsAtPoint(pt.x, 0, pt.z)

        if TUNING.CANAL_PLOW_DEPLOY_RULE then
            for x_off = -1, 1, 1 do
                for y_off = -1, 1, 1 do
                    if (x_off ~= 0 or y_off ~= 0) and
                            ( tileinfo_ocean and IsLandTile(TheWorld.Map:GetTile(tx + x_off, ty + y_off)) ) or
                            ( tileinfo_land and IsOceanTile(TheWorld.Map:GetTile(tx + x_off, ty + y_off)) )
                    then
                        found_adjacent_safetile = true
                        break
                    end
                end
            end
        elseif TUNING.CANAL_PLOW_DEPLOY_RULE == false then
            found_adjacent_safetile = true
        end

        if found_adjacent_safetile then
            local center_pt = Vector3(TheWorld.Map:GetTileCenterPoint(tx, ty))
            if tileinfo_land then
                return found_adjacent_safetile and checkent(inst, center_pt, deployer)
            elseif tileinfo_ocean then
                return found_adjacent_safetile and TheWorld.Map:CanDeployDockAtPoint(center_pt, inst, mouseover)
            end
        end

    end



    return false
end

local function item_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("farm_plow")
    inst.AnimState:SetBuild("farm_plow")
    inst.AnimState:PlayAnimation("idle_packed")

    -- inst:AddTag("usedeploystring")
    -- inst:AddTag("tile_deploy")


    inst:AddTag("canal_plow_item")

    MakeInventoryFloatable(inst, "small", 0.1, 0.8)

    inst._custom_candeploy_fn = client_candeplyitem

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "canal_plow_item"
    inst.components.inventoryitem.atlasname =
    "images/inventoryimages/canal_plow_item.xml"

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM

    inst:AddComponent("deployable")
    inst.components.deployable:SetDeployMode(DEPLOYMODE.CUSTOM)
    inst.components.deployable:SetUseGridPlacer(true)
    inst.components.deployable.ondeploy = ondeploy

    MakeSmallBurnable(inst)

    return inst
end

return Prefab("canal_plow", main_fn, assets),
Prefab("canal_plow_item", item_fn, assets, prefabs)