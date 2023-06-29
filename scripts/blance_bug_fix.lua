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



if TUNING.YEYU_NILXIN_ENABLE then
    

    AddShardModRPCHandler("yyxkui", "mp", function(worldid, message, userid, str,world_id)
        print("----------ffffmp") print(message) print(userid) print(str) print("world_id"..world_id)
    end)

    AddPrefabPostInit("yyxk_cykjcc", function(inst)
        if not TheWorld.ismastersim then return end
        
        local yyxk_can = upvaluehelper.Get(inst.yyxkpickup,"can")
        if type(yyxk_can) == "function" then
            local new_can = function(target,...)
                if  target.components.leader then
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



    end)




    local function foxball_xg(inst)
        if not TheWorld.ismastersim then return end

        local old_onspawnfn = inst.components.petleash.onspawnfn
        inst.components.petleash.onspawnfn = function(inst, pet, ...)
            local l = pet.components.follower:GetLeader() or inst.components.inventoryitem:GetGrandOwner()
            if l == nil or l:HasTag("player") then
                inst:DoTaskInTime(0.15, function()
                    inst:RemoveTag("call")
                    inst.components.nilxinfoxball:foxUnequip(pet)
                    pet:Remove()
                    inst.components.inventoryitem:ChangeImageName("nilxin_foxball_" .. inst.components.nilxinfoxball.foxType)
                    inst.AnimState:PlayAnimation(inst.components.nilxinfoxball.foxType, true)
                end)
                return
            end
            old_onspawnfn(inst, pet, ...)
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


AddPlayerPostInit(function(inst)
    local old_remove = inst.Remove
    inst.Remove = function(inst)
        local fninfo = debug.getinfo(2, "S")
        if fninfo and fninfo.source:match("mods/workshop-") then
            SerializeUserSession(inst)
        end
        return old_remove(inst)
    end
end)

AddPrefabPostInit("beef_bell", function(inst)
    if not TheWorld.ismastersim then return end
    local old_OnLoad = inst.OnLoad
    inst.OnLoad = function(inst, data)
        if data and data.beef_record then
            local fninfo
            local i = 2
            while true do
                fninfo = debug.getinfo(i)
                if fninfo and (fninfo.func == ResumeExistingUserSession or (type(fninfo.source) == "string" and fninfo.source:match("scripts/gamelogic.lua")) ) then 
                    break
                end
                if fninfo and type(fninfo.source) == "string" and fninfo.source:match("scripts/bufferedaction.lua") or fninfo == nil then 
                    data.beef_record = nil 
                    break 
                end
                i = i + 1
            end
        end

        if old_OnLoad then old_OnLoad(inst, data) end

    end
end)

-- AddPrefabPostInit("yyxk_buka", function(inst)
--     if not TheWorld.ismastersim then return end
--     local old_test = inst.components.trader.test
--     inst.components.trader.test = function(...)
--         if TUNING.CAP_NULLTEST then
--             local fninfo
--             local i = 2
--             while true do
--                 fninfo = debug.getinfo(i)
--                 print("------:"..i)
--                 dumptable(fninfo)
--                 if fninfo == nil then 
--                     break 
--                 end
--                 i = i + 1
--             end
--         end
--         if old_test then return old_test(...) end
--     end
-- end)