----花样风滚草 和 heap of foods冲突
if TUNING.HEAP_OF_FOOD_ENABLE and TUNING.INTERESTING_TUMBLEWEED_ENABLE then
    local easing = require("easing")

    local AVERAGE_WALK_SPEED = 4
    local WALK_SPEED_VARIATION = 2
    local SPEED_VAR_INTERVAL = .5
    local ANGLE_VARIANCE = 10

    local assets =
    {
        Asset("ANIM", "anim/tumbleweed.zip"),
        Asset("ATLAS", "images/tumbleweed.xml"),
    }

    local prefabs =
    {
        "ash",
    }

    local CHESS_LOOT =
    {
        "chesspiece_pawn_sketch",
        "chesspiece_muse_sketch",
        "chesspiece_formal_sketch",
        "trinket_15", --bishop
        "trinket_16", --bishop
        "trinket_28", --rook
        "trinket_29", --rook
        "trinket_30", --knight
        "trinket_31", --knight
    }
    --调料单
    local spice_loot={
        "spice_garlic",--蒜
        "spice_sugar",--糖
        "spice_chili",--辣椒
        "spice_salt",--盐
    }
    --加入勋章调料
    if TUNING.FUNCTIONAL_MEDAL_IS_OPEN then
        local medal_spices_status,medal_spices_data = pcall(require,"medal_defs/medal_spice_defs")
        if medal_spices_status then
            for i, v in ipairs(medal_spices_data) do
                table.insert(spice_loot, v)
            end
        end
    end

    for k, v in ipairs(CHESS_LOOT) do
        table.insert(prefabs, v)
    end

    local SFX_COOLDOWN = 5

    local function onplayerprox(inst)
        if not inst.last_prox_sfx_time or (GetTime() - inst.last_prox_sfx_time > SFX_COOLDOWN) then
            inst.last_prox_sfx_time = GetTime()
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/tumbleweed_choir")
        end
    end

    local function CheckGround(inst)
        --    if inst.components.inventoryitem and inst.components.inventoryitem:IsHeld() then
        -- 	print("进来了")
        -- end
        if not inst:IsOnValidGround() then
            SpawnPrefab("splash_ocean").Transform:SetPosition(inst.Transform:GetWorldPosition())
            inst:PushEvent("detachchild")
            inst:Remove()
        end
    end

    local function startmoving(inst)
        inst.AnimState:PushAnimation("move_loop", true)
        inst.bouncepretask = inst:DoTaskInTime(10*FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/tumbleweed_bounce")
            inst.bouncetask = inst:DoPeriodicTask(24*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/tumbleweed_bounce")
                CheckGround(inst)
            end)
        end)
        inst.components.blowinwind:Start()
        inst:RemoveEventCallback("animover", startmoving)
    end

    local tumbleweedResources = require("tumbleweed_resources")

    --生成风滚草资源列表
    local function MakeLoot(inst,picker)
        --生成资源列表
        local possible_loot=tumbleweedResources:CreatResources(picker)

        local chessunlocks = TheWorld.components.chessunlocks
        if chessunlocks ~= nil then
            for i, v in ipairs(CHESS_LOOT) do
                if not chessunlocks:IsLocked(v) then
                    table.insert(possible_loot, { chance = .1, item = v })
                end
            end
        end

        local totalchance = 0
        for m, n in ipairs(possible_loot) do
            totalchance = totalchance + n.chance
        end

        inst.loot = {}
        local next_loot = nil--道具、生物
        local next_aggro = nil--是否主动攻击
        local next_fn = nil--函数
        local next_announce = nil--公告
        local next_compensation = nil--幸运补偿
        local next_chance = nil
        local num_loots = 3
        while num_loots > 0 do
            next_chance = math.random()*totalchance
            next_loot = nil
            next_aggro = nil
            next_fn = nil
            for m, n in ipairs(possible_loot) do
                next_chance = next_chance - n.chance
                if next_chance <= 0 then
                    if n.item then next_loot = n.item else next_loot = nil end
                    if n.aggro then next_aggro = true else next_aggro = false end
                    if n.pickfn then next_fn = n.pickfn else next_fn = nil end
                    if n.announce then next_announce = n.announce else next_announce = nil end
                    if n.compensation then next_compensation = n.compensation else next_compensation = nil end
                    break
                end
            end
            if next_loot ~= nil then
                table.insert(inst.loot, {item=next_loot,aggro=next_aggro,announce=next_announce,compensation=next_compensation})
                num_loots = num_loots - 1
            end
            if next_fn ~= nil then
                table.insert(inst.loot, {pickfn=next_fn,compensation=next_compensation})
                num_loots = num_loots - 1
            end
        end
    end


    local function tumbleweedPostInit(inst)
        --打开风滚草
        local function onpickup(inst, picker)
            local x, y, z = inst.Transform:GetWorldPosition()
            local firstPickup=false--是否是第一次开
            local pickerNum=0--已经开过风滚草的玩家数量

            --判断打开风滚草的是不是玩家，防止眼球草吃风滚草后崩档
            if picker~=nil and picker:HasTag("player") then
                if TheWorld.components.firstpickersave then
                    --判断玩家是不是第一次打开风滚草
                    if TheWorld.components.firstpickersave:Isfirst(picker.userid) == nil then --~= 1 then
                        firstPickup=true
                    end
                    --获取已经开启过风滚草的玩家数量
                    pickerNum = TheWorld.components.firstpickersave:getPickerNum() or 0
                end
            end

            --生成风滚草内容，第一次开必出资源护符
            -- print("已经有"..pickerNum.."个玩家开启过风滚草")
            -- if picker and picker:HasTag("player") then
            -- firstPickup=true--测试用
            -- end
            if firstPickup then
                --有幸运值则添加各种幸运道具
                if TUNING.LUCKY_MODE==0 then
                    inst.loot = {
                        {item="transport_symbol"},--转运符
                        {item="prayer_symbol"},--祈运符
                        {item="keep_symbol"},--保运符
                    }
                    --非困难开局额外赠送一个保运符
                    if TUNING.OPENING_LEVEL<3 then
                        table.insert(inst.loot, {item="keep_symbol"})
                    end
                    --前3个开启的送资源护符(简单、正常开局)
                    if pickerNum<3 and TUNING.OPENING_LEVEL<2 then
                        table.insert(inst.loot, {item="resource_amulet"})
                    end
                    --简单开局额外赠送空间契约、保运符
                    if TUNING.OPENING_LEVEL<1 then
                        table.insert(inst.loot, {item="space_contract"})
                        table.insert(inst.loot, {item="keep_symbol"})
                    end
                else
                    inst.loot = {
                        {item="cutgrass"},
                        {item="twigs"},
                    }
                    --前3个开启的送资源护符(简单、正常开局)
                    if pickerNum<3 and TUNING.OPENING_LEVEL<2 then
                        table.insert(inst.loot, {item="resource_amulet"})
                    end
                    --简单开局赠送空间契约
                    if TUNING.OPENING_LEVEL<1 then
                        table.insert(inst.loot, {item="space_contract"})
                    end
                end
                TheWorld.components.firstpickersave:DoFirst(picker.userid)
            else
                MakeLoot(inst,picker)
            end

            inst:PushEvent("detachchild")

            for i, v in ipairs(inst.loot) do
                --执行函数
                if v.pickfn~=nil then
                    v.pickfn(inst,picker)
                    --进行幸运补偿
                    if v.compensation and TUNING.LUCKY_MODE==0 and TUNING.LUCKY_COMPENSATE>0 then
                        if picker~=nil and picker.components.lucky~=nil then
                            picker.components.lucky:DoDelta(v.compensation,true)
                        end
                    end
                    break
                    --生成物品
                else
                    local item = SpawnPrefab(v.item)
                    local item_code = v.item--实体代码，报错时方便查看
                    if item~=nil then
                        --如果是料理则随机调味
                        if item:HasTag("preparedfood") then
                            if math.random() < TUNING.PREPAREDFOODS_SPICE_MULTIPLE then
                                local spice_code=spice_loot[math.random(1,#spice_loot)]
                                if spice_code~=nil then
                                    item:Remove()
                                    item = SpawnPrefab(v.item.."_"..spice_code)
                                    item_code = item_code.."_"..spice_code
                                end

                            end
                        end
                    end
                    if item~=nil then
                        item.Transform:SetPosition(x, y, z)
                        if v.item=="klaus" then
                            item:SpawnDeer()
                        end
                        --切换随机皮肤
                        setRandomSkinFgc(item,picker)
                        --如果有掉落函数则触发掉落函数
                        if item.components.inventoryitem ~= nil and item.components.inventoryitem.ondropfn ~= nil then
                            item.components.inventoryitem.ondropfn(item)
                        end
                        --生物目标仇视玩家
                        if v.aggro and item.components.combat ~= nil and picker ~= nil then
                            if not (item:HasTag("spider") and (picker:HasTag("spiderwhisperer") or picker:HasTag("spiderdisguise") or (picker:HasTag("monster") and not picker:HasTag("player")))) then
                                item.components.combat:SuggestTarget(picker)
                            end
                        end
                        --进行幸运补偿
                        if v.compensation and TUNING.LUCKY_MODE==0 and TUNING.LUCKY_COMPENSATE>0 then
                            if picker~=nil and picker.components.lucky~=nil then
                                picker.components.lucky:DoDelta(v.compensation,true)
                            end
                        end
                        --公告
                        if v.announce~=nil and picker~=nil then
                            -- TheNet:Announce("【"..picker:GetDisplayName().."】从风滚草中开出了【"..item:GetDisplayName().."】")
                            TheNet:Announce(STRINGS.TUMBLEWEEDANNOUNCE.QIAN..picker:GetDisplayName()..STRINGS.TUMBLEWEEDANNOUNCE.ZHONG..item:GetDisplayName()..STRINGS.TUMBLEWEEDANNOUNCE.HOU)
                        end
                    else
                        -- TheNet:Announce("【"..v.item.."】不存在，如果看到该消息可截图给作者反馈~")
                        TheNet:Announce(STRINGS.TUMBLEWEEDANNOUNCE.QIAN..item_code..STRINGS.TUMBLEWEEDANNOUNCE.ERRORTXT)
                    end
                end
            end

            SpawnPrefab("tumbleweedbreakfx").Transform:SetPosition(x, y, z)
            inst:Remove()
            return true --This makes the inventoryitem component not actually give the tumbleweed to the player
        end

        inst.components.pickable.onpickedfn = onpickup
    end

    AddPrefabPostInit("tumbleweed", tumbleweedPostInit)
end


