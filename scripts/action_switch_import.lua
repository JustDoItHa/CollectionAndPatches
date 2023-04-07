

	--Switch
	
AddPrefabPostInit("dragonflyfurnace", function(inst)	
	if GLOBAL.TheWorld.ismastersim then
		inst:DoTaskInTime(1, function()
			inst:AddTag("cooldowndone_furnace")
		end)
	end
end)

local function switch_icefurnace(target, doer)
	if target ~= nil and target:IsValid() then
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
		end
	end
end

local SWITCH_ICEFURNACE = Action({ priority = 999 })
SWITCH_ICEFURNACE.id = "SWITCH_ICEFURNACE"
if is_english_icefurnace then
	SWITCH_ICEFURNACE.str = "Switch"
else
	SWITCH_ICEFURNACE.str = "切换"
end
SWITCH_ICEFURNACE.fn = function(act)
	local tar = act.target or act.invobject
    if act.doer ~= nil and tar ~= nil then
        switch_icefurnace(tar, act.doer)
		return true
    end
end

AddAction(SWITCH_ICEFURNACE)

AddComponentAction("SCENE", "workable", function(inst, doer, actions, right)
	if right and (inst.prefab == "dragonflyfurnace" or inst.prefab == "icefurnace") and inst:HasTag("cooldowndone_furnace") then
        table.insert(actions, ACTIONS.SWITCH_ICEFURNACE)
    end
end)

AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.SWITCH_ICEFURNACE, function(inst, action)
    if inst:HasTag("player") and action.target ~= nil then
		return "give"
	end
	return false
end))
	
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.SWITCH_ICEFURNACE, function(inst, action)
    if inst:HasTag("player") and action.target ~= nil then
		return "give"
	end
	return false
end))
	
