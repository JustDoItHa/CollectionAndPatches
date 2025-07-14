--------------------------------------------------------------------------
--[[ 全局 ]]
--------------------------------------------------------------------------

--下行代码只代表查值时自动查global，增加global的变量或者修改global的变量时还是需要带"GLOBAL."
GLOBAL.setmetatable(env, { __index = function(t, k)
    return GLOBAL.rawget(GLOBAL, k)
end })
local _G = GLOBAL

--------------------------------------------------------------------------
--[[ 主要 ]]
--------------------------------------------------------------------------

-- PrefabFiles = {
-- }

-- Assets = {
-- }

local IsServer = TheNet:GetIsServer() or TheNet:IsDedicated()

--------------------------------------------------------------------------
--[[ 包裹相关监听 ]]
--------------------------------------------------------------------------

local function RecordItemDetail(inst)
    local txt = ""
    if inst.components.perishable ~= nil then
        --具有新鲜度的物品
        txt = txt .. "|新鲜" .. math.floor(inst.components.perishable:GetPercent() * 100) .. "%"
    end
    if inst.components.finiteuses ~= nil then
        --一般是武器、工具，使用时会消耗的耐久
        txt = txt .. "|耐久" .. math.floor(inst.components.finiteuses:GetPercent() * 100) .. "%"
    end
    if inst.components.armor ~= nil then
        --一般是护甲，被攻击时会消耗的护甲生命值
        txt = txt .. "|护甲" .. math.floor(inst.components.armor:GetPercent() * 100) .. "%"
    end
    if inst.components.fueled ~= nil then
        --一般是衣服类的，穿戴时会消耗的耐久
        txt = txt .. "|耐久" .. math.floor(inst.components.fueled:GetPercent() * 100) .. "%"
    end
    if inst.components.stackable ~= nil then
        txt = txt .. "|叠加" .. inst.components.stackable:StackSize()
    end
    return txt
end
local function RecordItem(inst, needdetail)
    local name = inst.nameoverride or
            (inst.components.inspectable ~= nil and inst.components.inspectable.nameoverride) or
            inst.prefab or nil
    if name then
        name = STRINGS.NAMES[string.upper(name)] or "未知物品"
    else
        name = "未知物品"
    end
    if needdetail then
        name = name .. RecordItemDetail(inst)
    end
    return "[" .. name .. "] "
end
local function RecordPlayer(inst)
    local txt = "【"
    if inst.admin then
        --是否为管理员
        txt = txt .. "*"
    end
    txt = txt .. tostring(inst.userid) .. "|" .. tostring(inst.name) .. "|" .. tostring(inst.prefab) .. "】"
    return txt
end
local function Record(inst, actionname)
    local player = inst and RecordPlayer(inst) or "【无玩家】"
    return "---【" .. actionname .. "|" .. tostring(os.date("%Y-%m-%d %H:%M:%S")) .. "|" ..
            tostring(TheWorld.components.worldstate.data.cycles) .. "天】" .. player .. "："
end

if GetModConfigData("SpyBundle") and IsServer then
    AddComponentPostInit("unwrappable", function(self)
        local WrapItems_old = self.WrapItems
        self.WrapItems = function(self, items, doer, ...)
            if
            #items > 0 and
                    doer ~= nil
            then
                local txt = Record(doer, "打包") .. RecordItem(self.inst, false)
                for _, v in ipairs(items) do
                    txt = txt .. RecordItem(v, true)
                end
                print(txt)
            end
            WrapItems_old(self, items, doer, ...)
        end

        local Unwrap_old = self.Unwrap
        self.Unwrap = function(self, doer, ...)
            if
            doer ~= nil and
                    self.itemdata ~= nil
            then
                local txt = Record(doer, "解包") .. RecordItem(self.inst, false)
                for _, v in ipairs(self.itemdata) do
                    local item = SpawnSaveRecord(v)
                    if item ~= nil then
                        txt = txt .. RecordItem(item, true)
                        item:Remove()
                    end
                end

                print(txt)
            end
            Unwrap_old(self, doer, ...)
        end
    end)

    local bundles = { "bundle", "gift" }
    for _, bd in ipairs(bundles) do
        AddPrefabPostInit(bd, function(inst)
            local TryToSink_old = inst.components.inventoryitem.TryToSink
            inst.components.inventoryitem.TryToSink = function(self, ...)
                if ShouldEntitySink(self.inst, self.sinks) then
                    local x, y, z = self.inst.Transform:GetWorldPosition()
                    local mindis = nil
                    local badguy = nil
                    for _, p in ipairs(AllPlayers) do
                        if
                        p:IsValid()
                        then
                            if mindis == nil then
                                mindis = p:GetDistanceSqToPoint(x, y, z)
                                badguy = p
                            else
                                local dis = p:GetDistanceSqToPoint(x, y, z)
                                if dis <= mindis then
                                    mindis = dis
                                    badguy = p
                                end
                            end
                        end
                    end

                    local txt = Record(badguy, "丢海") .. "(平方距" .. tostring(mindis) .. ") " .. RecordItem(self.inst, false)
                    local cptdata = self.inst.components.unwrappable.itemdata
                    if cptdata ~= nil then
                        for _, v in ipairs(cptdata) do
                            local item = SpawnSaveRecord(v)
                            if item ~= nil then
                                txt = txt .. RecordItem(item, true)
                                item:Remove()
                            end
                        end
                    end
                    print(txt)
                end
                TryToSink_old(self, ...)
            end
        end)
    end

end

--------------------------------------------------------------------------
--[[ 全能监听 ]]
--------------------------------------------------------------------------

if GetModConfigData("SpyOther") and IsServer then
    modimport("scripts/monitor_new.lua")
end
