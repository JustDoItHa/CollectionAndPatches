

	--Transform

local function transform_icefurnace(inst, target, doer)
	if inst ~= nil and inst:IsValid() and target ~= nil and target:IsValid() then
		if target.prefab == "dragonflyfurnace" then
			if target.components.container ~= nil then
				target.components.container:DropEverything()
			end
			local x, y, z = target.Transform:GetWorldPosition()
			local fx = SpawnPrefab("dragonflyfurnace_transform_fx")
			fx.Transform:SetPosition(x, y + 0.3, z)
			fx.Transform:SetScale(1.2, 1.2, 1.2)
			local prefab_icefurnace = SpawnPrefab("icefurnace")
			if prefab_icefurnace ~= nil then
				prefab_icefurnace.Transform:SetPosition(x, y, z)
				if target:GetSkinBuild() ~= nil then
					if target:GetSkinName() == "dragonflyfurnace_antique" then
						prefab_icefurnace.skinname = 2
						prefab_icefurnace.AnimState:SetBank("ice_furnace_antique")
						prefab_icefurnace.AnimState:SetBuild("ice_furnace_antique")
					elseif target:GetSkinName() == "dragonflyfurnace_crystal" then
						prefab_icefurnace.skinname = 3
						prefab_icefurnace.AnimState:SetBank("ice_furnace_crystal")
						prefab_icefurnace.AnimState:SetBuild("ice_furnace_crystal")
					end
				end
				if target.components.workable ~= nil and target.components.workable.workleft > 0 then
					if prefab_icefurnace.components.workable ~= nil then
						prefab_icefurnace.components.workable.workleft = target.components.workable.workleft
					end
				end
			end
			target:Remove()
			inst:Remove()
		elseif target.prefab == "icefurnace" then
			if target.components.container ~= nil then
				target.components.container:DropEverything()
			end
			local x, y, z = target.Transform:GetWorldPosition()
			local fx = SpawnPrefab("icefurnace_transform_fx")
			fx.Transform:SetPosition(x, y + 0.3, z)
			fx.Transform:SetScale(1.2, 1.2, 1.2)
			local prefab_dragonfurnace = SpawnPrefab("dragonflyfurnace")
			if prefab_dragonfurnace ~= nil then
				prefab_dragonfurnace.Transform:SetPosition(x, y, z)
				if target.skinname ~= nil then
					if target.skinname == 2 then
						TheSim:ReskinEntity(prefab_dragonfurnace.GUID, nil, "dragonflyfurnace_antique", nil, doer.userid)
					elseif target.skinname == 3 then
						TheSim:ReskinEntity(prefab_dragonfurnace.GUID, nil, "dragonflyfurnace_crystal", nil, doer.userid)
					end
				end	
				if target.components.workable ~= nil and target.components.workable.workleft > 0 then
					if prefab_dragonfurnace.components.workable ~= nil then
						prefab_dragonfurnace.components.workable.workleft = target.components.workable.workleft
					end					
				end
			end
			target:Remove()
			inst:Remove()
		end
	end
end

local TRANSFORM_ICEFURNACE = Action({ priority = 999 })
TRANSFORM_ICEFURNACE.rmb = true
TRANSFORM_ICEFURNACE.distance = 20
TRANSFORM_ICEFURNACE.mount_valid = true
TRANSFORM_ICEFURNACE.id = "TRANSFORM_ICEFURNACE"
if is_english_icefurnace then
	TRANSFORM_ICEFURNACE.str = "Transform"
else
	TRANSFORM_ICEFURNACE.str = "转换"
end
TRANSFORM_ICEFURNACE.fn = function(act)
    if act.doer ~= nil and act.invobject ~= nil and act.target ~= nil then
        transform_icefurnace(act.invobject, act.target, act.doer)
		return true
    end
end

AddAction(TRANSFORM_ICEFURNACE)

AddComponentAction("EQUIPPED", "equippable", function(inst, doer, target, actions, right)
	if right and doer ~= nil and doer:HasTag("player") and target ~= nil
	and ((inst.prefab == "icestaff" and target.prefab == "dragonflyfurnace") 
	or (inst.prefab == "firestaff" and target.prefab == "icefurnace")) then
        table.insert(actions, ACTIONS.TRANSFORM_ICEFURNACE)
    end
end)

AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.TRANSFORM_ICEFURNACE, function(inst, action)
    if inst:HasTag("player") and action.invobject ~= nil and action.target ~= nil then
		return "veryquickcastspell"
	end
	return false
end))
	
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.TRANSFORM_ICEFURNACE, function(inst, action)
    if inst:HasTag("player") and action.invobject ~= nil and action.target ~= nil then
		return "veryquickcastspell"
	end
	return false
end))
	
