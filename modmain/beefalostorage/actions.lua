local actions = {
    CWJYXX_BEEF = Action({
        priority = 1
    }) -- 收/释放牛

}

actions.CWJYXX_BEEF.id = "CWJYXX_BEEF"
actions.CWJYXX_BEEF.strfn = function(act)
    return act.invobject:HasTag("storage_beef") and "RELEASE" or "STORAGE"
end
actions.CWJYXX_BEEF.fn = function(act)
    local followers = act.invobject.components.leader.followers
    if not act.invobject:HasTag("storage_beef") then
        return act.invobject.onstoragefn(act.invobject, followers, act.doer)
    else
        return act.invobject.onreleasefn(act.invobject, followers, act.doer)

    end

end

for k, v in pairs(actions) do
    AddAction(v)
end

local upvaluehelper = require "upvaluehelper"

-----修改原版动作的判定条件
local actions = upvaluehelper.Get(EntityScript.CollectActions, "COMPONENT_ACTIONS")
if actions and actions.INVENTORY and actions.INVENTORY.useabletargeteditem ~= nil then
    actions.INVENTORY.useabletargeteditem = function(inst, doer, actions)
        if inst:HasTag("can_storage_beef") then
            table.insert(actions, ACTIONS.CWJYXX_BEEF)
        elseif inst:HasTag("useabletargeteditem_inventorydisable") and inst:HasTag("inuse_targeted") then
            table.insert(actions, ACTIONS.STOPUSINGITEM)
        end

    end
end

AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.CWJYXX_BEEF, "dolongaction"))
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.CWJYXX_BEEF, "dolongaction"))

