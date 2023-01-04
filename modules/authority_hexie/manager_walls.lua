local _G = GLOBAL

--加载墙体权限，对象，索引依次为1.是否有权限控制 2.是否能被怪物摧毁 3.是否有权限才能被打开
local walls_config = {
    ["fence_gate_lock"] = GetModConfigData("door_lock"),
    ["fence_lock"] = GetModConfigData("fence_lock"),
    ["wall_hay_lock"] = GetModConfigData("wall_hay_lock"),
    ["wall_wood_lock"] = GetModConfigData("wall_wood_lock"),
    ["wall_stone_lock"] = GetModConfigData("wall_stone_lock"),
    ["wall_ruins_lock"] = GetModConfigData("wall_ruins_lock"),
    ["wall_moonrock_lock"] = GetModConfigData("wall_moonrock_lock")
} 

walls_table = 
{
	"wall_stone",-- 石墙
	"wall_hay",-- 草墙
	"wall_wood",-- 木墙
	"wall_ruins",-- 铥矿墙
	"wall_moonrock",-- 月石墙
	"fence_gate",-- 木门
	"fence",-- 木栅栏
} 

walls_state_config = {
    -- 普通墙
    walls_normal = {},
    -- 超级墙
    walls_power = {}
}

-- 判断墙体权限
-- param @name 墙体名
-- param @index 权限索引: 1.是否有权限控制 2.是否不能被怪物摧毁 3.是否有权限才能被打开
function CheckWallActionPermission(inst, index) 
    name = inst.prefab
    if name == nil then
        return false
    end 

    if inst.ownerlist == nil then 
        return true 
    end

    local itemKey = name .. "_lock"
    if walls_config[itemKey] ~= nil and walls_config[itemKey][index] ~= nil then
        return (walls_config[itemKey][index] ~= 1)
    end

    return false
end 

-- 获取血量百分比 2020.02.14
local function Get_wall_percent(percent) 
    if percent <= 0 then return 0 end 
    if percent > 0 and percent <= 0.4 then return 0 end 
    if percent > 0.4 and percent <= 0.5 then return 0.4 end 
    if percent > 0.5 and percent <= 0.99 then return 0.5 end 
    if percent > 0.99 then return 0.99 end 
end

-- 砸墙时墙的高度变化 2020.02.14
function wall_height_change(inst) 
    local old_percent = inst.components.health:GetPercent() 
    local new_percent = Get_wall_percent(old_percent) 
    inst.components.health:SetPercent(new_percent) 

    -- 把墙打平之后移除其阻碍
    if new_percent == 0 then 
        inst.Physics:SetActive(false)
        inst._ispathfinding:set(false) 
    end
end

-- 处理攻击墙的权限 2020.02.14
local function wall_permission(inst) 
    if inst.components.combat ~= nil then 
        local Combat = inst.components.combat
        local old_GetAttacked = inst.components.combat.GetAttacked 
        function Combat:GetAttacked(attacker, damage, weapon, stimuli) 
            attacker = attacker or inst.components.combat.lastattacker 
            -- 攻击者为玩家
            if attacker:HasTag("player") and CheckWallActionPermission(inst, 1) == false then 
                -- 门和栅栏有权限则打三下就被破坏
                --强行关闭攻击破坏
                if false and (inst.prefab == "fence" or inst.prefab == "fence_gate") and CheckItemPermission(attacker, inst, true) then 
                    old_GetAttacked(Combat, attacker, damage, weapon, stimuli) 
                -- 墙受保护则受到的伤害为0
                else 
                    old_GetAttacked(Combat, attacker, 0, weapon, stimuli) 
                end
            -- 攻击者为怪物
            elseif not attacker:HasTag("player") and CheckWallActionPermission(inst, 2) == false then 
                old_GetAttacked(Combat, attacker, 0, weapon, stimuli)
            else 
                old_GetAttacked(Combat, attacker, damage, weapon, stimuli) 
            end
        end 
    end
end

-- 墙状态初始化
for k, v in pairs(walls_config) do
    walls_config[k] = {}

    for i = 1, 3, 1 do
        local nItemValue = _G.tonumber(string.sub(v, i, i))
        table.insert(walls_config[k], nItemValue)
    end

    local wallKey = k:gsub("_lock", "")
    if walls_config[k][1] == 1 or walls_config[k][2] == 1 then
        walls_state_config.walls_power[wallKey] = true
    else
        walls_state_config.walls_normal[wallKey] = true
    end
end 

for k, name in pairs(walls_table) do
    AddPrefabPostInit(name, wall_permission) 
end

-----权限保存与加载----
for k, v in pairs(walls_state_config) do
    for wall_name, val in pairs(v) do
        SavePermission(wall_name)
    end
end


