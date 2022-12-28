local _save_data = {}

local function notdrop(self,player)
    if player.Network:IsServerAdmin() then
        return true
    end
    return  self.budiaoluo
end

local character_recipes_index = {
    ["willow"]={1, 2}, ["warly"]={3, 6}, ["wurt"]={7, 11}, ["wendy"]={8, 19},
    ["woodie"]={20, 22}, ["wathgrithr"]={23, 31}, ["walter"]={32, 41}, ["wolfgang"]={42, 46},
    ["wickerbottom"]={47, 52}, ["waxwell"]={53, 53}, ["winona"]={54, 58}, ["webber"]={59, 70},
    ["wormwood"]={71, 74}, ["wanda"]={75, 82}, ["wes"]={83, 88}, ["wx78"]={89, 105}
}

local function MyDropEverything(self,pt, character)
    -- 获取角色专属物品
    local character_recipes = {
        -- 灯不丢弃
        ["lantern"]=true, ["minerhat"]=true
    }
    if character_recipes_index[character] ~= nil then
        local index = character_recipes_index[character]
        for i=index[1], index[2] do
            character_recipes[CRAFTING_FILTERS.CHARACTER.recipes[i]] = true
        end
    end
    ------丢弃物品------------
    if  self.activeitem ~= nil and not character_recipes[self.activeitem.prefab] then
        self:DropItem(self.activeitem, true, true, pt)
        self:SetActiveItem(nil)
    end

    for k = 1, self.maxslots do
        local v = self.itemslots[k]
        if v ~= nil and not character_recipes[v.prefab] then
            self:DropItem(v, true, true, pt)
        end
    end

    for k, v in pairs(self.equipslots) do
        if v:HasTag("backpack") then
            for i = 1, v.components.container.numslots do
                if v.components.container.slots[i] ~= nil and not character_recipes[v.components.container.slots[i].prefab] then
                    v.components.container:DropItemBySlot(i,pt)
                end
            end
        end
        if v~=nil and not character_recipes[v.prefab] then self:DropItem(v, true, true, pt) end
    end
end

local function dodrop(player)
    local pt = nil
    if type(TUNING.DIAOLUO_TARGET)=="table" --[[and TUNING.DIAOLUO_TARGET:IsValid()]] then
        pt = TUNING.DIAOLUO_TARGET
    end
    if TUNING.DIAOLUO_TARGET=="none" or pt==nil then
        pt=player:GetPosition()
        if not player:HasTag("playerghost") or not player:HasTag("corpse") then
            local sign = SpawnPrefab("homesign")
            sign.Transform:SetPosition(player.Transform:GetWorldPosition())
            sign.components.writeable:SetText(player.name .. "的掉落物")
        end
    end
    if player.components.inventory then
        MyDropEverything(player.components.inventory,pt, player.prefab)
    end
end

local tianshu = TUNING.VISITOR_TIME


local diaoluo = Class(function(self, inst)
    self.inst = inst
    self.budiaoluo = false
    self.banned = false

    self.inst:ListenForEvent("ms_playerjoined", function(inst, player, cb)
        if  player and player == self.inst then
            self:OnLoad(_save_data[player.userid])
        end
    end,TheWorld)

    -- 重生（重置用户数据和重生门重生）
    self.inst:ListenForEvent("ms_playerdespawnanddelete", function(inst, player)
        if player and player == self.inst then
            _save_data[player.userid] = self:OnSave()
        end
    end, TheWorld)

    self.inst:ListenForEvent("ms_playerdespawn", function(inst, player, cb)
        if  player and player == self.inst then
            if not notdrop(self,self.inst)  then
                dodrop(self.inst)
            end
        end
    end,TheWorld)

    self.inst:WatchWorldState("cycles", function()
        local days = self.inst.components.age:GetDisplayAgeInDays()

        if self.inst.Network:IsServerAdmin() then
            return
        end

        if days >= tianshu and not self.banned and not self.budiaoluo then
            self.budiaoluo = true
            self.inst.components.talker:Say("恭喜你升级为成员")
            self.inst:PushEvent("mem_vis")
        end
    end)

    self.inst:PushEvent("mem_vis")
end)


function diaoluo:TiSheng(doer)
    if self.inst.Network:IsServerAdmin() then
        return
    end
    self.budiaoluo = true
    self.banned = false
    self.inst.components.talker:Say("恭喜你被提升成为成员")
    self.inst:PushEvent("mem_vis")
    if doer ~= nil and doer.components.talker ~= nil then
        doer.components.talker:Say("成功将"..self.inst.name.."升级为成员")
    end
end

function diaoluo:Ban(doer)
    if self.inst.Network:IsServerAdmin() then
        return
    end
    self.budiaoluo = false
    self.banned = true
    self.inst.components.talker:Say("很遗憾你被降级为了访客")
    self.inst:PushEvent("mem_vis")
    doer.components.talker:Say("成功将"..self.inst.name.."降级为访客")
end

function diaoluo:OnSave()
    return { budiaoluo =  self.budiaoluo, banned = self.banned}
end

function diaoluo:OnLoad(data)
    if data then
        self.budiaoluo = data.budiaoluo
        self.banned = data.banned
        _save_data[self.inst.userid] = nil
    end
end

return diaoluo
