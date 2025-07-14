
local ADD_USER_ID = Action()
ADD_USER_ID.id = "ADD_USER_ID"
ADD_USER_ID.str = ""
ADD_USER_ID.priority = 11
ADD_USER_ID.fn = function(act)
    local item = act.invobject
    if item and item:IsValid() and act.doer:HasTag("player") and act.target.components.adduserid then
        act.target.components.adduserid:Adduserid(item, act.doer)
        return true
    end
    return false
end
ADD_USER_ID.strfn = function(act)
    return act.invobject and act.target and act.invobject.prefab == "shadowheart" and
               (act.target:HasTag("adduserid_locked") and "解除绑定" or "绑定")
end
ADD_USER_ID.stroverridefn = ADD_USER_ID.strfn
AddAction(ADD_USER_ID)
local type = "USEITEM"
local component = "tradable"
local testfn = function(inst, doer, target, actions, right)
    if right and target and target:HasTag("adduserid") and doer and doer:HasTag("player") and inst.prefab == "shadowheart" then
        table.insert(actions, ACTIONS.ADD_USER_ID)
    end
end

AddComponentAction(type, component, testfn)

AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.ADD_USER_ID, "dolongaction"))
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.ADD_USER_ID, "dolongaction"))
AddPrefabPostInitAny(function (inst)
    if TheWorld.ismastersim then
        if inst:IsValid() and inst.components.equippable ~= nil and inst.components.adduserid == nil then
            inst:AddComponent("adduserid")
        end
    end
end)
