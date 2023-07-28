--------------------------------------------------------------------------
require "prefabutil"
require "modutil"
--------------------
require "recipe"
--------------------
local cooking = require("cooking")
--------------------

local assets=
{
    Asset("ANIM", "anim/backpack.zip"),
    Asset("ANIM", "anim/swap_bigbag.zip"),
    Asset("ATLAS", "images/inventoryimages/bigbag.xml"),
	Asset("IMAGE", "images/inventoryimages/bigbag.tex"),
}


local prefabs =
{
    "bluebigbag",
    "redbigbag",
}

local function ItemTradeTest_bigbag(inst, item)
	if inst.components.container and inst.components.inventoryitem.owner then
	if item == nil then
        return false
    elseif string.sub(item.prefab, -3) ~= "gem" then
        return false, "NOTGEM"
    elseif string.sub(item.prefab, -11, -4) == "precious" then
        return false, "WRONGGEM"
    end
	if item.prefab == "redgem" or "bluegem" then
		return true
	end
	end
end

--转移容器内物品(原容器,新容器) 参考能力勋章
local function transferEverything_bigbag(inst,obj)
	if inst.components.container and not inst.components.container:IsEmpty() then
		if obj.components.container then
			for i = 1, inst.components.container.numslots do
				local item = inst.components.container.slots[i]
				if item ~= nil then
					obj.components.container:GiveItem(item,i)
				end
			end
		end
	end
end

local function OnGemGiven_bigbag(inst, giver, item)
	if item.prefab == "redgem" or "bluegem" then
    local gembigbag = SpawnPrefab(string.sub(item.prefab, 1, -4).."bigbag")
	--print(string.sub(item.prefab, 1, -4).."bigbag")
    local container = inst.components.inventoryitem:GetContainer()
    if container ~= nil and gembigbag ~= nil then
        local slot = inst.components.inventoryitem:GetSlotNum()
		transferEverything_bigbag(inst,gembigbag)
        inst:Remove()
        container:GiveItem(gembigbag, slot)
    -- else
        -- local x, y, z = inst.Transform:GetWorldPosition()
		-- transferEverything_bigbag(inst,gembigbag)
        -- inst:Remove()
        -- gembigbag.Transform:SetPosition(x, y, z)
		gembigbag.SoundEmitter:PlaySound("dontstarve/common/telebase_gemplace")
    end
	end
end


--------------------------------------------------------------------------
local function getitem_bigbag(inst, data)
    if data and data.item ~= nil then
		if TUNING.ROOMCAR_BIGBAG_FRESH then
			if data.item:HasTag("spoiled") and data.item.components.perishable:GetPercent() < 1 then
                data.item.components.perishable:SetPercent(1)
				inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_finish")
            elseif data.item:HasTag("stale") and data.item.components.perishable:GetPercent() < 1 then
                data.item.components.perishable:SetPercent(1)
				inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_finish")
            elseif data.item:HasTag("fresh") and data.item.components.perishable:GetPercent() < 1 then
                data.item.components.perishable:SetPercent(1)
				inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_finish")
            end
            if data.item.components.finiteuses and data.item.components.finiteuses:GetPercent() < 1 then
                data.item.components.finiteuses:SetPercent(1)
				inst.SoundEmitter:PlaySound("dontstarve/common/telebase_gemplace")
            end
            if data.item.components.fueled and data.item.components.fueled:GetPercent() < 1 then
                data.item.components.fueled:SetPercent(1)
				inst.SoundEmitter:PlaySound("dontstarve/common/telebase_gemplace")
            end
            if data.item.components.armor and data.item.components.armor:GetPercent() < 1 then
                data.item.components.armor:SetPercent(1)
				inst.SoundEmitter:PlaySound("dontstarve/common/telebase_gemplace")
            end
		end

        if data.item.components.stackable and not data.item.components.stackable:IsFull() and TUNING.ROOMCAR_BIGBAG_STACK and inst:HasTag("bigbag") then
			inst.SoundEmitter:PlaySound("dontstarve/wilson/plant_seeds")
            data.item.components.stackable:SetStackSize(data.item.components.stackable.maxsize)
        end
		
		if TUNING.ROOMCAR_BIGBAG_HEATROCKTEMPERATURE and data.item.prefab == "heatrock" then
			local currenttemp = data.item.components.temperature:GetCurrent()
			if TheWorld.state.iswinter and currenttemp <= 25 then
				data.item.components.temperature:SetTemperature(currenttemp + 40)
				inst.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel")
			elseif TheWorld.state.issummer and currenttemp >= 30 then
				data.item.components.temperature:SetTemperature(currenttemp - 40)
				inst.SoundEmitter:PlaySound("dontstarve/common/gem_shatter")
			end
		end
		
	end
end

-- local function giveitems(inst, eventdata)
    -- -- 参考“owner:PushEvent("cantbuild", { owner = owner, recipe = recipe })” PushEvent("builditem")
    -- if eventdata.owner.components.inventory and eventdata.recipe then
        -- for ik, iv in pairs(eventdata.recipe.ingredients) do
            -- if not eventdata.owner.components.inventory:Has(iv.type, iv.amount) then
                -- for i = 1, iv.amount do
                    -- local item = SpawnPrefab(iv.type)
                    -- eventdata.owner.components.inventory:GiveItem(item)
                -- end
            -- end
        -- end
    -- end
-- end




local function onopen(inst)
	inst.AnimState:PlayAnimation("open")
    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
end

local function onclose(inst)
	inst.AnimState:PlayAnimation("closed")
    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
	
end

local function ondropped(inst)
    if inst.components.container ~= nil then
        inst.components.container:Close()
    end
	inst.AnimState:SetBank("backpack1")
    inst.AnimState:SetBuild("swap_bigbag")
    inst.AnimState:PlayAnimation("anim")
end
--------------------

local function onequip(inst, equiper)
	
    --print("    BIGBAG    onequip")
    -- if TUNING.ROOMCAR_BIGBAG_GIVE then
        -- print("    BIGBAG    ROOMCAR_BIGBAG_GIVE=true")
    -- else
        -- print("    BIGBAG    ROOMCAR_BIGBAG_GIVE=false")
    -- end

    -- light
    if TUNING.ROOMCAR_BIGBAG_LIGHT then
        inst.Light:Enable(true)
    end

    -- give
    -- if TUNING.ROOMCAR_BIGBAG_GIVE then
        -- equiper:ListenForEvent("cantbuild", giveitems)
    -- end

    -- original
     equiper.AnimState:OverrideSymbol("swap_body", "swap_bigbag", "swap_body")
	 if TUNING.ROOMCAR_BIGBAG_PICK then
	 equiper:AddTag("fastpick")    --成就快采
	 equiper:AddTag("fastpicker")  --蜘蛛快采
	 end
    if inst.components.container ~= nil then
       inst.components.container:Open(equiper)
    end
	-- TheInput:AddKeyDownHandler(TUNING.ROOMCAR_BIGBAG_EASYSWITCH, function()
	-- SendModRPCToServer(MOD_RPC["Bigbag"]["Bigbag_Switch"],inst)
	--end)

end

local function onunequip(inst, equiper)

    --print("    BIGBAG    onunequip")

    -- light
    if TUNING.ROOMCAR_BIGBAG_LIGHT then
        inst.Light:Enable(false)
    end

    -- give
    -- if TUNING.ROOMCAR_BIGBAG_GIVE then
        -- equiper:RemoveEventCallback("cantbuild", giveitems)
        -- --print("    BIGBAG    equiper:RemoveEventCallback(\"cantbuild\", giveitems)")
    -- end
	
    -- --original
	if TUNING.ROOMCAR_BIGBAG_PICK then
	equiper:RemoveTag("fastpick")
	equiper:RemoveTag("fastpicker")  --蜘蛛快采
	end
    if inst.components.container ~= nil then
        inst.components.container:Close(equiper)
    end
	equiper.AnimState:ClearOverrideSymbol("swap_body")
end


local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
	inst.entity:AddNetwork()
    --------------------
    -- This needs to be in any entity that you want to create on the server 
    -- and have it show up for all players. 
    -- Most things have this, but in a few cases you want things to 
    -- only exist on the server (e.g. meteorspawners, which are invisible), 
    -- and in some very rare cases you may want to create things independently on each client.
    --------------------
	inst.MiniMapEntity:SetIcon("bigbag.tex")
	
    MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("backpack1")
    inst.AnimState:SetBuild("swap_bigbag")
    inst.AnimState:PlayAnimation("anim")
    
    if TUNING.ROOMCAR_BIGBAG_LIGHT then
        inst.entity:AddLight()
        inst.Light:Enable(false)
        inst.Light:SetRadius(0.25)
        inst.Light:SetFalloff(0.5)
        inst.Light:SetIntensity(0.25)
        inst.Light:SetColour(255/255,255/255,255/255)
    end

    inst:AddTag("fridge")
    inst:AddTag("nocool")
	if TUNING.ROOMCAR_BIGBAG_WATER then
	inst:AddTag("umbrella")
	inst:AddTag("waterproofer")
	end
    inst:AddTag("bigbag")
	
	inst:AddTag("gemsocket")
	inst:AddTag("trader")
	inst:AddTag("give_dolongaction")
	
	if TUNING.ROOMCAR_BIGBAG_KEEPFRESH then
		inst:AddTag("keepfresh")
	end
	
	MakeInventoryFloatable(inst)
	
    inst.foleysound = "dontstarve/movement/foley/krampuspack"

    --------------------
    inst.entity:SetPristine()
    -- This basically says "everything above this was done on both the client or the server, 
    -- so don't bother networking any of that". 
    -- This reduces a bit of the bandwidth used by creating entities. 
    -- I can't think of a case where you wouldn't want this immediately 
    -- after the "if not TheWorld.ismastersim then return inst end" part, 
    -- which is where you'll see it in the game's code.
    --------------------

    --------------------
    if not TheWorld.ismastersim then
		-- inst.OnEntityReplicated = function(inst) 
			-- inst.replica.container:WidgetSetup("bigbag") 
		-- end
        return inst
    end
    -- This is really important for almost all prefabs. 
    -- This essentially says "if this is running on the client, stop here". 
    -- Almost all components should only be created on the server 
    -- (the really important ones will get replicated to the client through the replica system). 
    -- Visual things and tags that will always be added can go above this, though.
    --------------------
	
	
	if TUNING.ROOMCAR_BIGBAG_KEEPFRESH then
		if inst.components.preserver==nil then
			inst:AddComponent("preserver")
		end
		inst.components.preserver:SetPerishRateMultiplier(function(inst, item)
		return (item ~= nil) and 0 or nil
		end)
	end
	if TUNING.ROOMCAR_BIGBAG_WATER then
	inst:AddComponent("waterproofer")
	end
	inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BACK or EQUIPSLOTS.BODY
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.walkspeedmult = TUNING.ROOMCAR_BIGBAG_WALKSPEED
    
	inst:AddComponent("inspectable")
	inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/bigbag.xml"
	inst.components.inventoryitem:SetOnDroppedFn(ondropped)
    inst.components.inventoryitem.cangoincontainer = true -- [[can be carried]]!!!!!!!!!!!!!!!!!!!!
	inst.components.inventoryitem.foleysound = "dontstarve/movement/foley/marblearmour"
	
    inst:AddComponent("container")
    inst.components.container:WidgetSetup("bigbag")
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose
	inst:ListenForEvent("itemget", getitem_bigbag)
	
	inst:AddComponent("trader")
    inst.components.trader:SetAbleToAcceptTest(ItemTradeTest_bigbag)
    inst.components.trader.onaccept = OnGemGiven_bigbag
	
	MakeHauntableLaunch(inst)
    return inst
end

--------------------------------------------------------------------------
--------------------------------------------------------------------------

return Prefab( "common/inventory/bigbag", fn, assets,prefabs)
