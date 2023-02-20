local upvaluehelper = require "utils/upvaluehelp_cap"


if TUNING.ELAINA_ENABLE then
    AddComponentPostInit("unwrappable", function(self) -- 伊蕾娜 打包纸 临时修复
        local old_Unwrap = self.Unwrap
        function self:Unwrap(doer)  
            if self.inst:HasTag("elaina_bundle") then
                if self.itemdata ~= nil then
                    local cache = self.itemdata
                    if not checkentity(cache) then  return old_Unwrap(self,doer) end
                    self.itemdata = {}
                    for i, v in ipairs(cache) do
                        local item = SpawnPrefab(v.prefab)
                        if item.components and item.components.edible ~= nil then
                            table.insert(self.itemdata,v)
                        end
                        item:Remove()
                    end
                end
            end
            return old_Unwrap(self,doer)
        end
    end)
end


if TUNING.SORA_ENABLE then

    local containers = require "containers"
    local params = upvaluehelper.Get(containers.widgetsetup,"params","scripts/containers")
    if params and params.sorapack_container then
        local old_sorapack_itemtestfn = params.sorapack_container.itemtestfn
        function params.sorapack_container.itemtestfn(container, item, slot, ...)
            if item.components.follower or item.components.leader or item.components.inventory then
                return false
            end
            if type(old_sorapack_itemtestfn) == "function" then return old_sorapack_itemtestfn(container, item, slot, ...) end
        end
    end

    AddComponentPostInit("sorapacker", function(self)
        local old_CanPack = self.CanPack
        self.CanPack = function(self, target, ...)
            if target == nil or target.components.follower or target.components.leader or target.components.inventory then
                return false
            end
            for k,_ in pairs(target.components) do
                if type(k) == "string" and string.find(k, "teleporter") then
                    return false
                end
            end
            return old_CanPack and old_CanPack(self, target, ...)
        end
    end)
end


if TUNING.YEYU_NILXIN_ENABLE then
    

    AddShardModRPCHandler("yyxkui", "mp", function(worldid, message, userid, str,world_id)
        print("----------ffffmp") print(message) print(userid) print(str) print("world_id"..world_id)
    end)

    AddPrefabPostInit("yyxk_cykjcc", function(inst)
        if not TheWorld.ismastersim then return end
        
        local yyxk_can = upvaluehelper.Get(inst.yyxkpickup,"can")
        if type(yyxk_can) == "function" then
            local new_can = function(target,...)
                if target.components.teleporter or target.components.follower or target.components.leader or target.components.inventory then
                    return false
                end

                return yyxk_can(target,...)
            end


            local params = upvaluehelper.Set(inst.yyxkpickup,"can", new_can)
        end

        local old_yyxkpickup = inst.yyxkpickup
        if type(old_yyxkpickup) == "function" then
            inst.yyxkpickup = function(inst,doer,...)

                local followers_item = {}
                for j,s in pairs(doer.components.leader.followers) do
                    if j and j.components.container and not j.components.container:IsEmpty() then
                        followers_item[j] = {}
                        for k, v in pairs(j.components.container.slots) do
                            local item = j.components.container:RemoveItemBySlot(k)
                            if (item) then
                                table.insert(followers_item[j], item)
                            end
                        end
                    end
                end
                
                if doer and inst and inst.components.container then 
                    print("doer_name:"..(checkstring(doer.name) and doer.name or "nil").."--doer_prefab:"..(checkstring(doer.prefab) and doer.prefab or "nil"))
                    print("doer_id:"..(checkstring(doer.userid) and doer.userid or "nil"))
                    dumptable(inst.components.container.slots)
                    local str = ""
                    for k,v in pairs(inst.components.container.slots) do
                        if v and v.prefab then
                            str = str.."--"..v.prefab..":"..(v.components.stackable ~= nil and v.components.stackable.stacksize or 1)
                        end
                    end
                    print(str)
                    SendModRPCToShard(GetShardModRPC("yyxkui","mp"), {1,0},str,doer.userid,doer.name,TheShard:GetShardId())
                end
                
                old_yyxkpickup(inst,doer,...)

                for j,s in pairs(followers_item) do
                    if j and j:IsValid() then
                        for _,v in pairs(s) do
                            j.components.container:GiveItem(v)
                        end
                    else
                        for _,v in pairs(s) do
                            doer.components.inventory:GiveItem(v)
                        end
                    end
                end

            end
        end
    end)

    AddComponentPostInit("yyxk", function(self)

        local old_additem = self.additem
        self.additem = function(self, inst, n, ...)
            if inst then
                local old_GetPersistData = inst.GetPersistData
                inst.GetPersistData = function(inst)
                    local references
                    local data
                    data, references = old_GetPersistData(inst)
                    if inst.components.inventoryitem.owner and inst.components.inventoryitem.owner.prefab == "yyxk_cykjcc" then
                        local owner = inst.components.inventoryitem.owner
                        for i = 1, owner.components.container.numslots do
                            if owner.components.container.slots[i] == inst then
                                owner.components.container:RemoveItemBySlot(i)
                                inst:Remove()
                            end
                        end
                    end
                    return data, references
                end
            end
            return old_additem and old_additem(self, inst, n, ...)
        end

        local function spawn(inst,p,data)
            local sp = data == nil and SpawnPrefab(p) or SpawnPrefab(p, data.skinname, data.skin_id)
            if sp ~= nil then
                sp.Transform:SetPosition(inst.Transform:GetWorldPosition())
                if data ~= nil then
                    sp:SetPersistData(data.data)
                end 
                return sp
            end
        end
        function self:giveitem(p,sum)
            if self.items[p] ~= nil and self.items[p] > 0 then
                if sum >= self.items[p] then
                    sum = self.items[p]
                    self.items[p] = nil
                else
                    self.items[p] = self.items[p] - sum
                end
                local data = nil 
                if self.iteminfos[p] ~= nil then
                    data = table.remove(self.iteminfos[p])
                end
                
                local sp = spawn(self.inst,p,data)
                if sp ~= nil then
                    if sp.components.stackable ~= nil then
                        local smax = sp.components.stackable.maxsize
                        local curr = sum - smax
                        sp.components.stackable:SetStackSize(curr > 0 and smax or sum)
                        while(curr > 0) do
                            local sp1 = spawn(self.inst,p,data)
                            if curr > smax then
                                sp1.components.stackable:SetStackSize(smax)
                            else
                                sp1.components.stackable:SetStackSize(curr)
                            end
                            if sp1.components.inventoryitem ~= nil then
                                self.inst.components.inventory:GiveItem(sp1, nil, self.inst:GetPosition())
                            end
                            curr = curr - smax
                        end
                    elseif sum > 1 then
                        for i = 2, sum do
                            local sp1 = spawn(self.inst,p,table.remove(self.iteminfos[p]))
                            if sp1.components.inventoryitem ~= nil then
                                self.inst.components.inventory:GiveItem(sp1, nil, self.inst:GetPosition())
                            end
                        end
                    end 
                    if sp.components.inventoryitem ~= nil then
                        self.inst.components.inventory:GiveItem(sp, nil, self.inst:GetPosition())
                    end
                end
            end
        end

    end)

    AddPrefabPostInit("yyxk_gift", function(inst)
        if not TheWorld.ismastersim then return end
        local old_canfn = inst.components.yyxkaction.canfn
        inst.components.yyxkaction.canfn = function(inst, target, doer, ...)
            if target == nil or target.components.follower or target.components.leader or target.components.inventory then
                return false
            end
            for k,_ in pairs(target.components) do
                if type(k) == "string" and string.find(k, "teleporter") then
                    return false
                end
            end
            return old_canfn and old_canfn(inst, target, doer, ...)
        end
    end)

    local function foxball_xg(inst)
        if not TheWorld.ismastersim then return end
        local old_GetPersistData = inst.GetPersistData
        inst.GetPersistData = function(inst)
            local references
            local data
            data, references = old_GetPersistData(inst)
            if data and data.petleash then
                data.petleash = nil
            end
            return data, references
        end
    end
    AddPrefabPostInit("nilxin_foxball_blue", foxball_xg)
    AddPrefabPostInit("nilxin_foxball_red", foxball_xg)

    AddPrefabPostInit("telestaff", function(inst)
        if not TheWorld.ismastersim then return end
        if inst.components.spellcaster then
            local old_spell = inst.components.spellcaster.spell
            inst.components.spellcaster.spell = function(inst, target, pos, doer)
                if target then
                    for k,_ in pairs(target.components) do
                        if type(k) == "string" and string.find(k, "teleporter") then
                            return
                        end
                    end
                end
                return old_spell and old_spell(inst, target, pos, doer)
            end
        end
    end)

end