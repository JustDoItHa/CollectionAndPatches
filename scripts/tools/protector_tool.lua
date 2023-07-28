local tool = {}

local function isfind_link_id(prefab,link_id)
    if #link_id == 0 then return false end
    for _ ,id in pairs(link_id) do
        if id == prefab.components.protector.userid then
            return true
        else
        end
    end
    return false
end

local function check(prefab)
    for key, value in pairs(TUNING.PROTECTOR_ITEMS) do
        if prefab.prefab ~= nil then
            if string.find(prefab.prefab, "_spawner") then return true end
            if prefab.prefab == value then
                return true
            end
        end
    end
end

tool.CanDo =  function (pt, doer, target)
    local x,y,z
    if pt == nil and target ~=nil then
        x,y,z = target.Transform:GetWorldPosition()
    elseif pt ~= nil then
        x,y,z = pt:Get()
    else
        return true
    end
    local ents = TheSim:FindEntities(x, y, z, TUNING.PROTECTOR_DEPLOY_AREA, {"protected"}, { "INLIMBO" })
    local not_self = {}
    for k ,v in pairs(ents) do
        if v.components.protector ~= nil and v.components.protector.userid ~= nil then
            if v.components.protector.userid ~= doer.userid then
                table.insert(not_self, v)
            end
        end
    end
    local link_id = doer.components.playermanager.link_userid
    for k ,v in pairs(not_self) do
        if not isfind_link_id(v, link_id) then
            return false
        end
    end
    return true
end

tool.SetName = function(inst, name, id)
    if inst.components.protector ~= nil and inst.components.named ~= nil and (inst.components.inventoryitem == nil or (inst:HasTag("heavy") and not inst:HasTag("irreplaceable")))then
        inst.components.protector.username = name
        inst.components.protector.userid = id
        inst.components.protector.protectortime = 0

        if inst.name and type(inst.name) == "table" then print("无法设置名字.....") return end---....

        local x,y,z = inst.Transform:GetWorldPosition()
        local ents = TheSim:FindEntities( x, y, z, TUNING.UNPROTECTOR_AREA, nil, { "INLIMBO" })
        for k, v in pairs(ents) do
            if check(v) then
                if inst.components.named and inst.components.named.name == nil then
                    inst.components.protector.userid = nil
                    inst.components.named:SetName(PROTECTOR.UNPROTECTED..((inst.nameoverride ~= nil and STRINGS.NAMES[string.upper(inst.nameoverride)]) or inst.name) .. (name ~= nil and (PROTECTOR.MASTER ..name) or ""))
                end
                -- 客机设置名字
                -- inst.displaynamefn = function ()
                --     return ((inst.nameoverride ~= nil and STRINGS.NAMES[string.upper(inst.nameoverride)]) or inst.name) .. PROTECTOR.MASTER .. name
                -- end
                return
            end
        end
        if inst.components.named and inst.components.named.name == nil then
             inst.components.named:SetName(((inst.nameoverride ~= nil and STRINGS.NAMES[string.upper(inst.nameoverride)]) or inst.name) .. (name ~= nil and (PROTECTOR.MASTER .. name) or ""))
        end
        -- print("设置 实体名字",inst:GetDisplayName())
        -- print("设置 实体名字 named 组件",inst.components.named.name)
    end
end

tool.ReSetName = function(target, doer, pt)
    if target == nil and doer == nil then
        return
    end
    local name
    local id
    local x,y,z
    if doer ~= nil and pt ~= nil then
        name = doer.name
        id = doer.userid
        x,y,z = pt:Get()
    elseif doer ~= nil and target ~= nil then
        x,y,z = target.Transform:GetWorldPosition()
        name = doer.name
        id = doer.userid
    elseif target ~= nil and pt == nil then
        x,y,z = target.Transform:GetWorldPosition()
        name = target.components.protector.username
        id = target.components.protector.userid
    end
    if x and y and z then
        TheWorld:DoTaskInTime(.2, function()
            -----------------------------------------.55 1
            local ents = TheSim:FindEntities(x, y, z, .55, nil, { "INLIMBO" })
            for _, v in pairs(ents) do
                if v.components.protector ~= nil and v.components.protector.userid == nil then
                    tool.SetName(v,name,id)
                end
            end
        end)
    end
end

tool.CheckPlayer = function(doer)
   for _, value in pairs(TUNING.PROTECTOR_PLAYERS) do
       if doer.userid == value then
           return true
       end
   end
   return false
end

local function Put(item, target)
    if target and target ~= item and target.prefab == item.prefab and item.components.stackable and not item.components.stackable:IsFull() and target.components.stackable and not target.components.stackable:IsFull()then
        local small_puff = SpawnPrefab("small_puff")
        small_puff.Transform:SetPosition(target.Transform:GetWorldPosition())
        small_puff.Transform:SetScale(.5, .5, .5)
        item.components.stackable:Put(target)
    end
end

tool.AutoStack = function(pt)
    local x,y,z = pt:Get()
    local ents = TheSim:FindEntities( x, y, z, 8, { "_inventoryitem" }, { "INLIMBO", "NOCLICK", "catchable", "fire", "bee" ,"butterfly" })
        for _, objBase in pairs(ents) do
        if objBase:IsValid() and objBase.components.stackable and not objBase.components.stackable:IsFull() then
            for _, obj in pairs(ents) do
                if obj:IsValid() then
                    Put(objBase, obj)
                end
            end
        end
    end
end
return tool