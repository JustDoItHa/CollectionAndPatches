require "prefabutil"
--from "data/databundles/scripts/prefablist.lua"

local function onopen(inst) --回调函数
    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open") --声音
end

local function onclose(inst) --回调函数
    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close") --声音
end

--掉落自动关闭
local function ondropped(inst) --回调函数
    if inst.components.container then
        inst.components.container:Close()
    end
end

--将原容器的物品转移至新容器中
local function transferEverything(inst, obj)
    --判空，如果不是容器则忽略
    if inst.components.container and not inst.components.container:IsEmpty() then
        if obj.components.container then
            -- local all_items = inst.components.container:RemoveAllItemsWithSlot()
            --!23: attempt to call method 'RemoveAllItemsWithSlot' (a nil value)
            local all_items = inst.components.container:RemoveAllItems()
            if all_items then
                for k, v in pairs(all_items) do
                    obj.components.container:GiveItem(v, k)
                end
            end
        end
    end
end

--部署函数，可以参考官方小木牌
local function ondeploy(inst, pt, deployer)
    local ent = SpawnPrefab("_big_box_chest") --spawn prefab，这for循环的话我该如何导入呢？--!巧了，好像也不能循环生成了。
    if ent ~= nil then
        -- ent.Transform:SetPosition(pt.x,pt.y,pt.z)
        ent.Transform:SetPosition(pt:Get())
        -- ent.SoundEmitter:PlaySound("dontstarve/common/dragonfly_chest_craft") --声音
        ent.SoundEmitter:PlaySound("dontstarve/common/sign_craft") --栽种小木牌的声音
        transferEverything(inst, ent) --!
        inst:Remove() --移除当前手里拿着的预制物
    end
end

--被锤时的回调函数
local function onhammered(inst, worker) --inst为老容器
    local new_container = inst.components.lootdropper:SpawnLootPrefab("_big_box")
    --想知道，inst.prefab是否为空
    -- print("inst.prefab:" .. (inst.prefab or "nil"))
    --确定为非空
    transferEverything(inst, new_container)
    inst:Remove()
end

--onbuild
local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place") --?
    inst.AnimState:PushAnimation("closed", false) --?
    inst.SoundEmitter:PlaySound("dontstarve/common/dragonfly_chest_craft")
end

--保存函数
local function OnSave(inst, data)
end

--加载函数
local function OnLoad(inst, data)
end

local function common_func(item_name, certain_box_def)
    -- print(item_name .. "开始初始化")
    ---------------------------[[修改这里]]--------------------------
    local assets = {
        Asset("ANIM", "anim/big_box_ui_120.zip"), --ui动画文件
        Asset("ATLAS", "images/inventoryimages/" .. certain_box_def.atlas .. "/" .. certain_box_def.atlas .. ".xml") --图片文档，物品栏图片
    }
    ---------------------------[[修改这里]]--------------------------
    local prefabs = {} --预加载，好像写和不写都一样
    ----------------------------------------------------------------
    local function func() --描述函数，这里我设置成了通用函数
        --[[第一部分，服务端和客户端都执行的部分]]
        local inst = CreateEntity()

        inst.entity:AddTransform() --变换，要能移动位置[添加变换组件]
        inst.entity:AddAnimState() --动画，要显示在地图上[添加动画组件]
        inst.entity:AddNetwork() --网络，要能被其他玩家看到和互动
        inst.entity:AddSoundEmitter() --音效

        -- inst.entity:AddMiniMapEntity()
        -- inst.MiniMapEntity:SetIcon(item_name..".tex")

        --盒子落地发光
        inst.entity:AddLight()
        inst.Light:SetIntensity(0.1) -- 光照强度.99为强光
        inst.Light:SetColour(180 / 255, 195 / 255, 150 / 255) --色彩
        inst.Light:SetFalloff(1) -- 最大范围再向外辐射的光效，1几乎不辐射
        inst.Light:SetRadius(1) -- 照明范围

        MakeInventoryPhysics(inst) --物理引擎，要能被其他玩家看到和互动[设置物品拥有一般物品栏物体的物理特性]
        MakeInventoryFloatable(inst, "small", 0.15, 0.65) --是物体落水漂浮

        inst.AnimState:SetBank("sunken_treasurechest") --设置动画属性Bank .scml内
        inst.AnimState:SetBuild("sunken_treasurechest") --设置动画属性Build .zip
        inst.AnimState:PlayAnimation("closed") --设置默认播放动感 bank内

        ----------------------------------------------------------------
        --利用表循环来避免重复工作
        if certain_box_def.tags ~= nil then --先判断是否有tags
            for _, tag in ipairs(certain_box_def.tags) do
                inst:AddTag(tag)
            end
        end
        ----------------------------------------------------------------

        inst.entity:SetPristine()
        --以下是设置网络状态的，并且作为一个分解线
        --以上是：[[主客机通用代码]]
        if not TheWorld.ismastersim then
            --此处是：[[客户端代码]] --?
            inst.OnEntityReplicated = function(inst)
                inst.replica.container:WidgetSetup(certain_box_def.weight) --WidgetSetup --!!!
            end
            return inst
        end
        --以下是：[[只限于主机使用的代码]]
        --注意：绝大部分的组件都是只在主机上工作的，所以必须写在主客机分割代码下面

        inst:AddComponent("inspectable") --检查组件

        inst:AddComponent("inventoryitem") --库存组件
        inst.components.inventoryitem.atlasname =
            "images/inventoryimages/" .. certain_box_def.atlas .. "/" .. certain_box_def.atlas .. ".xml"

        inst.components.inventoryitem:SetOnDroppedFn(ondropped) --掉落时候的回调函数，我设置为自动关闭
        inst.components.inventoryitem.canonlygoinpocket = true --是否只能放在身上

        --[[核心组件：直接影响物体的核心功能（区别于其他物体的特征）]]
        inst:AddComponent("container")
        inst.components.container:WidgetSetup(certain_box_def.weight) --WidgetSetup --!!!
        inst.components.container.onopenfn = certain_box_def.onopenfn or onopen --onopenfn回调函数
        inst.components.container.onclosefn = certain_box_def.onclosefn or onclose --onclosefn回调函数

        inst:AddComponent("deployable") --可以被放置在地上
        inst.components.deployable.ondeploy = ondeploy --
        inst.components.deployable:SetDeploySpacing(DEPLOYSPACING.DEFAULT) --默认。可以设置为NONE的

        --保鲜设置
        if checknumber(TUNING._SET_PRESERVER_BIG_BOX) then
            inst:AddComponent("preserver")
            inst.components.preserver:SetPerishRateMultiplier(TUNING._SET_PRESERVER_BIG_BOX)
        end

        --!计划实现：物品放置在地上的动态效果

        MakeHauntableLaunch(inst) --作祟

        inst.OnSave = OnSave
        inst.OnLoad = OnLoad
        -- print(item_name .. "初始化完成，将执行OnLoad()") --!!!
        return inst
    end
    local function func_chest() --描述函数，这里我设置成了通用函数
        --[[第一部分，服务端和客户端都执行的部分]]
        local inst = CreateEntity()

        inst.entity:AddTransform() --变换，要能移动位置[添加变换组件]
        inst.entity:AddAnimState() --动画，要显示在地图上[添加动画组件]
        inst.entity:AddNetwork() --网络，要能被其他玩家看到和互动
        inst.entity:AddSoundEmitter() --音效

        -- inst.entity:AddMiniMapEntity()
        -- inst.MiniMapEntity:SetIcon(item_name..".tex")

        --落地发光
        inst.entity:AddLight()
        inst.Light:SetIntensity(0.1) -- 光照强度.99为强光
        inst.Light:SetColour(180 / 255, 195 / 255, 150 / 255) --色彩
        inst.Light:SetFalloff(1) -- 最大范围再向外辐射的光效，1几乎不辐射
        inst.Light:SetRadius(1) -- 照明范围

        MakeInventoryPhysics(inst) --物理引擎，要能被其他玩家看到和互动[设置物品拥有一般物品栏物体的物理特性]
        MakeInventoryFloatable(inst, "small", 0.15, 0.65) --是物体落水漂浮

        inst.AnimState:SetBank("sunken_treasurechest") --设置动画属性Bank .scml内
        inst.AnimState:SetBuild("sunken_treasurechest") --设置动画属性Build .zip
        inst.AnimState:PlayAnimation("closed") --设置默认播放动感 bank内

        ----------------------------------------------------------------
        --利用表循环来避免重复工作
        if certain_box_def.tags ~= nil then --先判断是否有tags
            for _, tag in ipairs(certain_box_def.tags) do
                inst:AddTag(tag)
            end
        end
        ----------------------------------------------------------------

        inst.entity:SetPristine()
        --以下是设置网络状态的，并且作为一个分解线
        --以上是：[[主客机通用代码]]
        if not TheWorld.ismastersim then
            --此处是：[[客户端代码]] --?
            inst.OnEntityReplicated = function(inst)
                inst.replica.container:WidgetSetup(certain_box_def.weight) --WidgetSetup --!!!
            end
            return inst
        end
        --以下是：[[只限于主机使用的代码]]
        --注意：绝大部分的组件都是只在主机上工作的，所以必须写在主客机分割代码下面

        inst:AddComponent("inspectable") --检查组件

        inst:AddComponent("container")
        inst.components.container:WidgetSetup(certain_box_def.weight) --WidgetSetup --!!!
        inst.components.container.onopenfn = certain_box_def.onopenfn or onopen --onopenfn回调函数
        inst.components.container.onclosefn = certain_box_def.onclosefn or onclose --onclosefn回调函数

        --!计划实现：物品放置在地上的动态效果

        --保鲜设置
        if checknumber(TUNING._SET_PRESERVER_BIG_BOX) then
            inst:AddComponent("preserver")
            inst.components.preserver:SetPerishRateMultiplier(TUNING._SET_PRESERVER_BIG_BOX)
        end

        inst:AddComponent("lootdropper")
        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
        inst.components.workable:SetWorkLeft(1)
        inst.components.workable:SetOnFinishCallback(onhammered)

        inst.dismantle = onhammered --拆卸

        --兼容智能小木牌
        if TUNING.SMART_SIGN_DRAW_ENABLE then
            SMART_SIGN_DRAW(inst)
        end

        inst:ListenForEvent("onbuilt", onbuilt)

        -- MakeHauntableLaunch(inst) --作祟

        inst.OnSave = OnSave
        inst.OnLoad = OnLoad
        -- print(item_name .. "初始化完成，将执行OnLoad()") --!!!
        return inst
    end
    --<2> return Prefab(物品名,描述函数,加载资源表)
    --function MakePlacer(name, bank, build, anim,...)
    return Prefab(item_name, func, assets), MakePlacer(
        "_big_box_placer",
        "sunken_treasurechest",
        "sunken_treasurechest",
        "closed"
    ), Prefab("_big_box_chest", func_chest, assets), MakePlacer(
        "_big_box_chest_placer",
        "sunken_treasurechest",
        "sunken_treasurechest",
        "closed"
    )
    --MakePlacer("about_moon_placer", "halloween_potion_moon", "halloween_potion_moon","idle_"..PlayRandomIdle(inst))
    --  MakePlacer("fish_bowl_item_placer", "fish_bowl", "fish_bowl", "idle")
    --Can't find prefab fish_bowl_placer
end

local boxs_def = {} --不同盒子的定义，设置了key值，因此需要用pairs索引 boxs_definition 表

boxs_def._big_box = {
    ----------------------------------------------------------------
    --地面动画
    bank = "_big_box",
    build = "_big_box",
    animation = "_big_box", --地面动画
    ----------------------------------------------------------------
    -- tags = {
    -- },
    ----------------------------------------------------------------
    --物品栏图片
    image = "_big_box",
    atlas = "_big_box", --!!!
    ----------------------------------------------------------------
    --ui
    weight = "_big_box" --WidgetSetup
    ----------------------------------------------------------------
}

-- local boxs_list = {} --盒子预制物，未设置key值，直接插入，用ipairs索引 boxs_list 表
-- for key, value in pairs(boxs_def) do
--     table.insert(boxs_list, common_func(key, value)) --向boxs_list表中[应该是按顺序]插入 预制物
-- end

--!多了个函数，不能这样insert了

-- return unpack(boxs_list) --boxs_list表中元素是预制物

return common_func("_big_box", boxs_def._big_box)

--月亮精华液 halloweenpotion_moon
