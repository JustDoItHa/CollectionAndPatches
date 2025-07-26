ALL_TRAVELABLES = {}

local function ontraveller(self, traveller)
    self.inst.replica.travelable:SetTraveller(traveller)
end
local wait_second=TUNING.TRAVEL_WAIT_SECOND
local max_time = nil
local say_time = nil

local default_dist_cost = 32
local max_hunger_cost = 200
local max_sanity_cost = 15
local min_hunger_cost = 5
local sanity_cost_ratio = 20 / 75
local find_dist = (max_sanity_cost / sanity_cost_ratio - min_hunger_cost) *
                      default_dist_cost

local ownershiptag = "uid_private"

local Travelable = Class(function(self, inst)
    self.inst = inst
    self.inst:AddTag("travelable")

    self.dist_cost = default_dist_cost
    self.traveller = nil
    self.destinations = {}
    self.travellers = {}

    self.onclosepopups = function(traveller) -- yay closures ~gj -- yay ~v2c
        if traveller == self.traveller then self:EndTravel() end
    end

    self.generatorfn = nil
    table.insert(ALL_TRAVELABLES, self)
end, nil, { traveller = ontraveller })

local function IsNearDanger(traveller)
    local hounded = TheWorld.components.hounded
    if hounded ~= nil and (hounded:GetWarning() or hounded:GetAttacking()) then
        return true
    end
    local burnable = traveller.components.burnable
    if burnable ~= nil and (burnable:IsBurning() or burnable:IsSmoldering()) then
        return true
    end
    if traveller:HasTag("spiderwhisperer") then
        return FindEntity(traveller, 10, function(target)
            return (target.components.combat ~= nil and
                       target.components.combat.target == traveller) or
                       (not (target:HasTag("player") or target:HasTag("spider")) and
                           (target:HasTag("monster") or target:HasTag("pig")))
        end, nil, nil, {"monster", "pig", "_combat"}) ~= nil
    end
    return FindEntity(traveller, 10, function(target)
        return (target.components.combat ~= nil and
                   target.components.combat.target == traveller) or
                   (target:HasTag("monster") and not target:HasTag("player"))
    end, nil, nil, {"monster", "_combat"}) ~= nil
end

local function DistToCost(dist)
    local cost_hunger = min_hunger_cost + dist / default_dist_cost
    cost_hunger = math.min(cost_hunger, max_hunger_cost)
    local cost_sanity = cost_hunger * sanity_cost_ratio
    if TheWorld.state.season == "winter" then
        cost_sanity = cost_sanity * 1.25
    elseif TheWorld.state.season == "summer" then
        cost_sanity = cost_sanity * 0.75
    end

    cost_hunger = math.ceil(cost_hunger * TRAVEL_HUNGER_COST)
    cost_sanity = math.ceil(cost_sanity * TRAVEL_SANITY_COST)
    return cost_hunger, cost_sanity
end

function Travelable:ListDestination(traveller)
    local x, y, z = self.inst.Transform:GetWorldPosition()
    local dests = TheSim:FindEntities(x, y, z, find_dist, "travelable")
    self.destinations = {}

    for i, v in ipairs(ALL_TRAVELABLES) do
        if not (v.ownership and v.inst:HasTag(ownershiptag) and
                traveller.userid ~= nil and
                not v.inst:HasTag("uid_" .. traveller.userid)) then
            table.insert(self.destinations, v.inst)
        end
    end

    table.sort(self.destinations, function(destA, destB)
        local writeA = destA.components.writeable
        local writeB = destB.components.writeable
        if writeA == nil or writeA:GetText() == nil or writeA:GetText() == "" then
            return false
        end
        if writeB == nil or writeB:GetText() == nil or writeB:GetText() == "" then
            return true
        end
        return string.lower(writeA:GetText()) < string.lower(writeB:GetText())
    end)

    self.totalsites = #self.destinations
    self.site = self.totalsites
end

function Travelable:MakeInfos()
    local infos = ""
    for i, destination in ipairs(self.destinations) do
        local name = destination.components.writeable and
                destination.components.writeable:GetText() or "~nil"
        local cost_hunger, cost_sanity = 0, 0
        if destination == self.inst then
            cost_hunger = -1
            cost_sanity = -1
        else
            local xi, yi, zi = self.inst.Transform:GetWorldPosition()
            local xf, yf, zf = destination.Transform:GetWorldPosition()
            -- entity may be removed
            if xi ~= nil and zi ~= nil and xf ~= nil and zf ~= nil then
                local dist = math.sqrt((xi - xf) ^ 2 + (zi - zf) ^ 2)
                cost_hunger, cost_sanity = DistToCost(dist)
            end
        end

        infos = infos .. (infos == "" and "" or "\n") .. i .. "\t" .. name ..
                "\t" .. cost_hunger .. "\t" .. cost_sanity
    end
    self.inst.replica.travelable:SetDestInfos(infos)
end

function Travelable:BeginTravel(traveller)
    local comment = self.inst.components.talker
    if not traveller then
        if comment then comment:Say(STRINGS.NANA_TELEPORT_WHO_TOUCHED_ME) end
        return
    end
    local talk = traveller.components.talker

    if self.ownership and self.inst:HasTag(ownershiptag) and traveller.userid ~=
            nil and not self.inst:HasTag("uid_" .. traveller.userid) then
        if comment then
            comment:Say(STRINGS.NANA_TELEPORT_UNDER_OWNERSHIP)
        elseif talk then
            talk:Say(STRINGS.NANA_TELEPORT_TEMPORARILY_WITHOUT_AUTHORITY)
        end
        return
    elseif self.traveller then
        if comment then
            comment:Say(STRINGS.NANA_TELEPORT_NOT_YOUR_TURN_YET)
        elseif talk then
            talk:Say(STRINGS.NANA_TELEPORT_NOT_MY_TURN_YET)
        end
        return
    elseif IsNearDanger(traveller) then
        if talk then
            talk:Say(STRINGS.NANA_TELEPORT_NOT_SAFE_NEARBY)
        elseif comment then
            comment:Say(STRINGS.NANA_TELEPORT_NOT_SAFE_NEARBY)
        end
        return
    end

    local isintask = false
    for k, v in pairs(self.travellers) do
        if v == traveller then isintask = true end
    end

    if not self.traveltask or isintask then
        self.inst:StartUpdatingComponent(self)

        self:ListDestination(traveller)
        self:MakeInfos()
        self:CancelTravel(traveller)
        self.travellers = {}

        self.traveller = traveller
        self.inst:ListenForEvent("ms_closepopups", self.onclosepopups, traveller)
        self.inst:ListenForEvent("onremove", self.onclosepopups, traveller)

        if traveller.HUD ~= nil then
            self.screen = traveller.HUD:ShowTravelScreen(self.inst)
        end
    else
        self:CancelTravel(traveller)
        self:Travel(traveller, self.site)
    end
end

function Travelable:Travel(traveller, index)
    if wait_second == 3 then
        max_time = 4
        say_time = 1
    elseif wait_second == 1 then
        max_time = 1
        say_time = 1
    elseif wait_second == 0 then
        max_time = 0
        say_time = 0
    else
        max_time = 8
        say_time = 3
    end
    local destination = self.destinations[index]
    if traveller and destination then
        self.site = index
        local comment = self.inst.components.talker
        local talk = traveller.components.talker

        -- Site information
        local desc = destination and destination.components.writeable and
                         destination.components.writeable:GetText()
        local description = desc and string.format('"%s"', desc) or
                STRINGS.NANA_TELEPORT_UNKNOWN
        local information = ""
        local cost_hunger = min_hunger_cost
        local cost_sanity = 0
        local xi, yi, zi = self.inst.Transform:GetWorldPosition()
        local xf, yf, zf = destination.Transform:GetWorldPosition()
        -- entity may be removed
        if xi ~= nil and zi ~= nil and xf ~= nil and zf ~= nil then
            local dist = math.sqrt((xi - xf) ^ 2 + (zi - zf) ^ 2)
            cost_hunger, cost_sanity = DistToCost(dist)
        end

        if destination and destination.components.travelable then
            table.insert(self.travellers, traveller)

            information = string.format(
                    STRINGS.NANA_TELEPORT_TELEPORTING_TO,
                    description, self.site, self.totalsites,
                    cost_hunger, cost_sanity)
            if comment then
                comment:Say(string.format(information), say_time)
            elseif talk then
                talk:Say(string.format(information), say_time)
            end

            self.traveltask = self.inst:DoTaskInTime(wait_second, function()
                self.traveltask = nil
                local dest_pos_valid = xf ~= nil and zf ~= nil and
                        TheWorld.Map:IsPassableAtPoint(xf, 0, zf)
                for k, who in pairs(self.travellers) do
                    if not destination:IsValid() or not dest_pos_valid then
                        if comment then
                            comment:Say(STRINGS.NANA_TELEPORT_DESTINATION_UNAVAILABLE)
                        elseif talk then
                            talk:Say(STRINGS.NANA_TELEPORT_DESTINATION_UNAVAILABLE)
                        end
                    elseif who == nil or
                            (who.components.health and
                                    who.components.health:IsDead()) then
                        if comment then
                            comment:Say(STRINGS.NANA_TELEPORT_UNABLE_TO_TELEPORT_BODY)
                        end
                    elseif not (who:IsValid() and self.inst:IsValid() and
                            who:IsNear(self.inst, 10)) then
                        print(STRINGS.NANA_TELEPORT_DESTINATION_INVALID)
                    elseif IsNearDanger(who) then
                        if talk then
                            talk:Say(STRINGS.NANA_TELEPORT_NOT_SAFE_NEARBY)
                        elseif comment then
                            comment:Say(STRINGS.NANA_TELEPORT_NOT_SAFE_NEARBY)
                        end
                    elseif destination.components.travelable.ownership and
                            destination:HasTag(ownershiptag) and who.userid ~= nil and
                            not destination:HasTag("uid_" .. who.userid) then
                        if comment then
                            comment:Say(STRINGS.NANA_TELEPORT_THE_DESTINATION_IS_CONTROLLED_BY_OWNERSHIP)
                        elseif talk then
                            talk:Say(STRINGS.NANA_TELEPORT_THE_DESTINATION_IS_CONTROLLED_BY_OWNERSHIP)
                        end
                    elseif who.components.hunger and who.components.sanity then
                        who.components.hunger:DoDelta(-cost_hunger)
                        who.components.sanity:DoDelta(-cost_sanity)
                        if who.Physics ~= nil then
                            who.Physics:Teleport(xf - 1, 0, zf)
                        else
                            who.Transform:SetPosition(xf - 1, 0, zf)
                        end

                        -- follow
                        if who.components.leader and
                                who.components.leader.followers then
                            for kf, vf in pairs(who.components.leader.followers) do
                                if kf.Physics ~= nil then
                                    kf.Physics:Teleport(xf + 1, 0, zf)
                                else
                                    kf.Transform:SetPosition(xf + 1, 0, zf)
                                end
                            end
                        end

                        local inventory = who.components.inventory
                        if inventory then
                            for ki, vi in pairs(inventory.itemslots) do
                                if vi.components.leader and
                                        vi.components.leader.followers then
                                    for kif, vif in pairs(vi.components.leader.followers) do
                                        if kif.Physics ~= nil then
                                            kif.Physics:Teleport(xf, 0, zf + 1)
                                        else
                                            kif.Transform:SetPosition(xf, 0, zf + 1)
                                        end
                                    end
                                end
                            end
                        end

                        local container = inventory:GetOverflowContainer()
                        if container then
                            for kb, vb in pairs(container.slots) do
                                if vb.components.leader and
                                        vb.components.leader.followers then
                                    for kbf, vbf in pairs(vb.components.leader.followers) do
                                        if kbf.Physics ~= nil then
                                            kbf.Physics:Teleport(xf, 0, zf - 1)
                                        else
                                            kbf.Transform:SetPosition(xf, 0, zf - 1)
                                        end
                                    end
                                end
                            end
                        end

                        --使用未写木牌传送时，删除之
                        -- if self.inst.components.writeable and
                        -- not self.inst.components.writeable:IsWritten() then
                        -- self.inst:Remove()
                        -- end
                    else
                        if talk then
                            talk:Say(STRINGS.NANA_TELEPORT_UNABLE_TO_TRANSMIT)
                        elseif comment then
                            comment:Say(STRINGS.NANA_TELEPORT_UNABLE_TO_TRANSMIT)
                        end
                    end
                end
                self.travellers = {}
            end)
            if wait_second == 5 then
			    self.traveltask5 = self.inst:DoTaskInTime(3, function()
                    comment:Say("5秒钟后出发.")
                end)
                self.traveltask4 = self.inst:DoTaskInTime(4, function()
                    comment:Say("请靠近点.")
                    self.inst.SoundEmitter:PlaySound("dontstarve/HUD/craft_down")
                end)
                self.traveltask3 = self.inst:DoTaskInTime(5, function()
                    comment:Say("3秒钟后出发.")
                    self.inst.SoundEmitter:PlaySound("dontstarve/HUD/craft_down")
                end)
                self.traveltask2 = self.inst:DoTaskInTime(6, function()
                    comment:Say("2秒钟后出发.")
                    self.inst.SoundEmitter:PlaySound("dontstarve/HUD/craft_down")
                end)
                self.traveltask1 = self.inst:DoTaskInTime(7, function()
                    comment:Say("1秒钟后出发.", 1)
                    self.inst.SoundEmitter:PlaySound("dontstarve/HUD/craft_down")
                end)
			elseif wait_second == 3 then
                self.traveltask3 = self.inst:DoTaskInTime(1, function()
                    comment:Say("3秒钟后出发.")
                    self.inst.SoundEmitter:PlaySound("dontstarve/HUD/craft_down")
                end)
                self.traveltask2 = self.inst:DoTaskInTime(2, function()
                    comment:Say("2秒钟后出发.")
                    self.inst.SoundEmitter:PlaySound("dontstarve/HUD/craft_down")
                end)
                self.traveltask1 = self.inst:DoTaskInTime(3, function()
                    comment:Say("1秒钟后出发.", 1)
                    self.inst.SoundEmitter:PlaySound("dontstarve/HUD/craft_down")
                end)
			end
        elseif comment then
            comment:Say(STRINGS.NANA_TELEPORT_DESTINATION_UNAVAILABLE)
        elseif talk then
            talk:Say(STRINGS.NANA_TELEPORT_DESTINATION_UNAVAILABLE)
        end
    end
    self:EndTravel()
end

function Travelable:CancelTravel(traveller)
    if self.traveltask ~= nil then
        self.traveltask:Cancel()
        self.traveltask = nil
    end
    if self.traveltask1 ~= nil then
        self.traveltask1:Cancel()
        self.traveltask1 = nil
    end
    if self.traveltask2 ~= nil then
        self.traveltask2:Cancel()
        self.traveltask2 = nil
    end
    if self.traveltask3 ~= nil then
        self.traveltask3:Cancel()
        self.traveltask3 = nil
    end
    if self.traveltask4 ~= nil then
        self.traveltask4:Cancel()
        self.traveltask4 = nil
    end
    if self.traveltask5 ~= nil then
        self.traveltask5:Cancel()
        self.traveltask5 = nil
    end
end

function Travelable:EndTravel()
    if self.traveller ~= nil then
        self.inst:StopUpdatingComponent(self)

        if self.screen ~= nil then
            self.traveller.HUD:CloseTravelScreen()
            self.screen = nil
        end

        self.inst:RemoveEventCallback("ms_closepopups", self.onclosepopups, self.traveller)
        self.inst:RemoveEventCallback("onremove", self.onclosepopups, self.traveller)

        if IsXB1() then
            if self.traveller:HasTag("player") and
                    self.traveller:GetDisplayName() then
                local ClientObjs = TheNet:GetClientTable()
                if ClientObjs ~= nil and #ClientObjs > 0 then
                    for i, v in ipairs(ClientObjs) do
                        if self.traveller:GetDisplayName() == v.name then
                            self.netid = v.netid
                            break
                        end
                    end
                end
            end
        end

        self.traveller = nil
    elseif self.screen ~= nil then
        -- Should not have screen and no traveller, but just in case...
        if self.screen.inst:IsValid() then self.screen:Kill() end
        self.screen = nil
    end
end

--------------------------------------------------------------------------
-- Check for auto-closing conditions
--------------------------------------------------------------------------

function Travelable:OnUpdate(dt)
    if self.traveller == nil then
        self.inst:StopUpdatingComponent(self)
    elseif (self.traveller.components.rider ~= nil and
            self.traveller.components.rider:IsRiding()) or
            not (self.traveller:IsNear(self.inst, 3) and
                    CanEntitySeeTarget(self.traveller, self.inst)) then
        self:EndTravel()
    end
end

--------------------------------------------------------------------------

function Travelable:OnRemoveFromEntity()
    Travelable:OnRemoveEntity()
    self.inst:RemoveTag("travelable")
end

function Travelable:OnRemoveEntity()
    self:EndTravel()
    for i, v in ipairs(ALL_TRAVELABLES) do
        if v == self then
            table.remove(ALL_TRAVELABLES, i)
            break
        end
    end
end

return Travelable
