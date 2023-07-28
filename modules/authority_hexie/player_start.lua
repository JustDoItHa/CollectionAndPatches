local _G = GLOBAL
-- 给予玩家初始物品
local give_start_item = GetModConfigData("give_start_item")

-- 给礼物(玩家，礼物列表，礼物1数量，礼物2数量，礼物3数量，礼物4数量) 2020.02.24
function GiveStartGift(player, items, i1, i2, i3, i4)
    local bundle = _G.SpawnPrefab("gift") 

    local stacksize = 
    {
        i1,i2,i3,i4,
    } 

    local spawn_items = {} 

    for i = 1,#items do 
        spawn_items[i] = _G.SpawnPrefab(items[i]) 
        if spawn_items[i] ~= nil and spawn_items[i].components.stackable ~= nil then 
            spawn_items[i].components.stackable.stacksize = stacksize[i] or 1 
        end
    end

    bundle.components.unwrappable:WrapItems(spawn_items)
    for i, v in ipairs(spawn_items) do
        v:Remove()
    end 
    local container = player.components.inventory or player.components.container
    container:GiveItem(bundle)
end 

--玩家初始物品（可根据自己需要自行修改，因为物资是通过包装的礼物的形式给的，所以一个礼物包的物品不能超过四种） 2020.02.24
local function StartingInventory(inst, player)
    
    --玩家第一次进入时获取初始物品
    local CurrentOnNewSpawn = player.OnNewSpawn or function()
            return true
        end
    player.OnNewSpawn = function(...)
        PlayerSay(player, GetSayMsg("player_start"), nil, 5)

        player.components.inventory.ignoresound = true

        player:DoTaskInTime(
            1,
            function(inst) 
                -- 基本的物资1
                local basic_items1 = 
                {
                    "cutgrass", -- 草
                    "twigs", -- 树枝
                    "log", -- 木头
                    "flint", -- 燧石
                }
                GiveStartGift(player, basic_items1, 9, 8, 8, 8)

                -- 基本的物资2
                local basic_items2 = 
                {
                    "rocks", -- 石头
                    "meat", -- 肉
                    "zyjb",
                    "zyzs",
                    --"nightmare_timepiece", -- 远古勋章
					--"xxsq", -- 修仙神器
                }
                GiveStartGift(player, basic_items2, 9, 2, 6)

                --初始进入的时间是冬天或者临近冬天的时候
                if
                    GLOBAL.TheWorld.state.iswinter 
                    or (GLOBAL.TheWorld.state.isautumn and GLOBAL.TheWorld.state.remainingdaysinseason < 5)
                    then

                    -- 冬天的物资
                    local winter_items = 
                    {
                        "heatrock", -- 暖石
                        "winterhat", -- 冬帽
                        "cutgrass", -- 草
                        "log", -- 木头
                    }
                    GiveStartGift(player, winter_items, 1, 1, 2, 2)
                end

                --春天
                if
                    GLOBAL.TheWorld.state.isspring 
                    or (GLOBAL.TheWorld.state.iswinter and GLOBAL.TheWorld.state.remainingdaysinseason < 3)
                    then

                    -- 春天物资
                    local spring_items = 
                    {
                        "umbrella", -- 雨伞
                        "strawhat", -- 草帽
                    }
                    GiveStartGift(player, spring_items)
                end

                --夏天
                if
                    GLOBAL.TheWorld.state.issummer 
                    or (GLOBAL.TheWorld.state.isspring and GLOBAL.TheWorld.state.remainingdaysinseason < 5)
                    then
      
                    -- 夏天物资
                    local summer_items = 
                    {
                        "nitre", -- 硝石
                        "ice", -- 冰
                        "heatrock", -- 暖石
                        "strawhat", -- 草帽
                    }
                    GiveStartGift(player, summer_items, 6, 6)
                end

                --夜晚(零零星星的就直接给了,不包了)
                if GLOBAL.TheWorld.state.isnight or (GLOBAL.TheWorld.state.isdusk and GLOBAL.TheWorld.state.timeinphase > .8) then 
                    player.components.inventory:GiveItem(_G.SpawnPrefab("torch")) -- 火把
                end

                --如果初始点在洞穴
                if GLOBAL.TheWorld:HasTag("cave") then
                    player.components.inventory:GiveItem(_G.SpawnPrefab("minerhat")) -- 矿工帽
                end

                --如果是PVP模式
                if GLOBAL.TheNet:GetPVPEnabled() then
                    player.components.inventory:GiveItem(_G.SpawnPrefab("spear")) -- 长矛
                    player.components.inventory:GiveItem(_G.SpawnPrefab("footballhat")) -- 猪皮帽
                end
            end
        )

        return CurrentOnNewSpawn(...)
    end
end

--初始化
AddPrefabPostInit(
    "world",
    function(inst)
        if GLOBAL.TheWorld.ismastersim then --判断是不是主机
            --监听玩家安置，给初始物品
            if give_start_item then
                inst:ListenForEvent("ms_playerspawn", StartingInventory, inst)
            end
        end
    end
)
