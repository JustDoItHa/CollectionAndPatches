require "prefabutil"

local assets =
{

   Asset("ANIM", "anim/teleportation.zip"),
   Asset("ANIM", "anim/t1.zip"),
   Asset("ANIM", "anim/t2.zip"),
   Asset("ANIM", "anim/t3.zip"),
   Asset("ANIM", "anim/t4.zip"),
   Asset("ANIM", "anim/t5.zip"),
   Asset("ANIM", "anim/t6.zip"),
   Asset("ANIM", "anim/t7.zip"),
   Asset("ANIM", "anim/t8.zip"),
   Asset("ANIM", "anim/t9.zip"),
   Asset("ANIM", "anim/t10.zip"),
   Asset("ANIM", "anim/ui_board_5x3.zip"),


   Asset("IMAGE", "images/inventoryimages/teleportation.tex"),
   Asset("ATLAS", "images/inventoryimages/teleportation.xml"), --小地图图标:64

   Asset("IMAGE", "images/inventoryimages/t1.tex"),
   Asset("ATLAS", "images/inventoryimages/t1.xml"),
   Asset("IMAGE", "images/inventoryimages/t2.tex"),
   Asset("ATLAS", "images/inventoryimages/t2.xml"),
   Asset("IMAGE", "images/inventoryimages/t3.tex"),
   Asset("ATLAS", "images/inventoryimages/t3.xml"),
   Asset("IMAGE", "images/inventoryimages/t4.tex"),
   Asset("ATLAS", "images/inventoryimages/t4.xml"),
   Asset("IMAGE", "images/inventoryimages/t5.tex"),
   Asset("ATLAS", "images/inventoryimages/t5.xml"),
   Asset("IMAGE", "images/inventoryimages/t6.tex"),
   Asset("ATLAS", "images/inventoryimages/t6.xml"),
   Asset("IMAGE", "images/inventoryimages/t7.tex"),
   Asset("ATLAS", "images/inventoryimages/t7.xml"),
   Asset("IMAGE", "images/inventoryimages/t8.tex"),
   Asset("ATLAS", "images/inventoryimages/t8.xml"),
   Asset("IMAGE", "images/inventoryimages/t9.tex"),
   Asset("ATLAS", "images/inventoryimages/t9.xml"),
   Asset("IMAGE", "images/inventoryimages/t10.tex"),
   Asset("ATLAS", "images/inventoryimages/t10.xml"),

}

-- 在小木牌上写字完毕后调用，告知客户端，小木牌上写的内容
local function OnWritingEnded(inst)
   local text = inst.components.writeable:GetText()   -- 获取writeable组件里面的GetText()方法return的值，也就是玩家写下的文字
   inst.net_text:set(text or "")                            -- 利用net_text(网络变量)告知客户端需要显示什么字
end

local function onhammered(inst, worker) --锤敲掉落材料
   inst.components.lootdropper:DropLoot()
   local fx = SpawnPrefab("collapse_small")
   fx.Transform:SetPosition(inst.Transform:GetWorldPosition()) --特效
   fx:SetMaterial("metal")
   inst:Remove()                                               --移除
end

local function SetSkin(inst)
   local skin_build = inst:GetSkinBuild()

   if skin_build ~= nil and skin_build == "t1" then
      inst.AnimState:SetSymbolBloom("fire")
   end
end

local function onbuilt(inst)                 --建造虚影
   inst.AnimState:PlayAnimation("idle", true) --上个动画播放之后循环播放idle，加ture可以让动画循环播放
   inst.SoundEmitter:PlaySound("dontstarve/common/icebox_craft")
end

local function OnLoadPostPass(inst)
   OnWritingEnded(inst)
end

local function fn()
   local inst = CreateEntity()    --创建一个实体
   inst.entity:AddTransform()     --添加位移组件,坐标位置
   inst.entity:AddNetwork()       --添加网络组件
   inst.entity:AddSoundEmitter()  --添加声音组件
   inst.entity:AddDynamicShadow() --添加动态阴影
   inst.DynamicShadow:SetSize(2, 2) --设置阴影大小， xy长宽尺寸

   -- 增加屏幕显示文字
   if TRAVEL_TEXT_ENABLE then
      inst.entity:AddLabel()
      inst.Label:SetFontSize(30)
      inst.Label:SetFont(TITLEFONT)
      inst.Label:SetWorldOffset(0, 3.5, 0)   -- 定位在屏幕上，x:横轴，y:纵轴，z:弃用（为统一格式，写上0）
      inst.Label:SetColour(1, 1, 1)
      inst.Label:Enable(true)
      inst.Label:SetText("")
      inst.net_text = net_string(inst.GUID, "skinnable_teleportation_text", "text_dirty")
      inst:ListenForEvent("text_dirty", function()
         inst.Label:SetText(inst.net_text:value())
      end)
   end

   inst.entity:AddMiniMapEntity() --小地图图标
   inst.MiniMapEntity:SetIcon("teleportation.tex")

   inst.entity:AddAnimState() --添加动画组件
   inst.AnimState:SetBank("teleportation")
   inst.AnimState:SetBuild("teleportation")
   inst:DoTaskInTime(0, function() inst.AnimState:PlayAnimation("idle", true) end) --将指令设置一个执行时间， 这样可以和其他指令分出优先级， 这样这条指令可以覆盖皮肤api文件里默认设置的动画不循环。 这样传送门皮肤的火焰就可以循环播放了

   inst:AddTag("teleportation")                                                   --独有标签
   inst:AddTag("lightsource")                                                     --光源
   inst:AddTag("structure")                                                       --建筑标签
   inst:AddTag("_writeable")
   inst.entity:SetPristine()                                                      --初始化

   if not TheWorld.ismastersim then                                               --主客机判定:下边的代码为主机独占,上方为主客机共用
      return inst
   end

   inst:RemoveTag("_writeable")

   inst:AddComponent("inspectable")

   inst:AddComponent("writeable")
   if TRAVEL_TEXT_ENABLE then
      inst.components.writeable:SetOnWritingEndedFn(OnWritingEnded)  --书写完成之后调用的函数（用于告知客户端木牌上需要显示什么字）
      inst.OnLoadPostPass = OnLoadPostPass  -- 预制体加载完成后显示文字
   end

   inst:AddComponent("lootdropper")

   inst:AddComponent("workable")                            --添加可破坏组件
   inst.components.workable:SetWorkAction(ACTIONS.HAMMER)   --锤子
   inst.components.workable:SetWorkLeft(4)                  --敲4次
   inst.components.workable:SetOnFinishCallback(onhammered) --锤敲掉落材料
   --inst.components.workable:SetOnWorkCallback(onhit)        --损坏:不需要

   inst:ListenForEvent("onbuilt", onbuilt) --监听:建造

   inst:AddComponent("hauntable")          --可闹鬼的,复活用

   -------因为皮肤api文件里的皮肤函数设置了默认动画不循环， 所以需要加这一段监听来使需要动画循环的皮肤的动画生效
   --inst:ListenForEvent("reskinned", function() -- 监听: 玩家用扫把换肤之后， push一个事件， 让预制体换皮肤的特效
   --   inst:DoTaskInTime(0, function()
   --      SetSkin(inst)
   --   end)
   --end)
   --
   --inst:DoTaskInTime(0, function() --初始化时候检测
   --   SetSkin(inst)
   --end)
   ----------结束----------
   return inst
end

return Prefab("teleportation", fn, assets),
   MakePlacer("teleportation_placer", "teleportation", "teleportation", "idle")