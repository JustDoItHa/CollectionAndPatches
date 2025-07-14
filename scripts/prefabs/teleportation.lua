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
Asset("ANIM", "anim/ui_board_5x3.zip"),
   
   
   Asset("IMAGE", "images/inventoryimages/teleportation.tex"),   
   Asset("ATLAS", "images/inventoryimages/teleportation.xml"),  --小地图图标:64
}

local function onhammered(inst, worker)   --锤敲掉落材料
   inst.components.lootdropper:DropLoot()
   local fx = SpawnPrefab("collapse_small")
   fx.Transform:SetPosition(inst.Transform:GetWorldPosition())  --特效
   fx:SetMaterial("metal")
   inst:Remove()  --移除
end

local function onbuilt(inst)               --建造虚影
   inst.AnimState:PlayAnimation("idle")
   inst.SoundEmitter:PlaySound("dontstarve/common/icebox_craft")
end

local function zidonglight(inst, phase)             --自动灯光
   if phase == "night" then
      inst.AnimState:PlayAnimation("idle")
      inst.Light:Enable(true)                       --夜晚发光
   else
      inst.AnimState:PlayAnimation("idle")
      inst.Light:Enable(false)                      --其余时间关闭
   end
end

function fn()
   local inst = CreateEntity()                     --创建一个实体
   inst.entity:AddTransform()                      --添加位移组件,坐标位置
   inst.entity:AddNetwork()                        --添加网络组件
   inst.entity:AddSoundEmitter()                   --添加声音组件

        
   inst.entity:AddMiniMapEntity()                  --小地图图标
   inst.MiniMapEntity:SetIcon("teleportation.tex") 
     
   inst.entity:AddLight()                          --添加发光组件
   inst.Light:Enable(false)                        --默认关
   inst.Light:SetRadius(1*1)                       --发光范围:半径3格地皮
   inst.Light:SetFalloff(0.6)                        --衰减
   inst.Light:SetIntensity(0.85)                   --强度
   --inst.Light:SetColour(0.88, 1, 1)                --浅灰se
   inst.Light:SetColour(255 / 255, 175 / 255, 0 / 255)                --浅灰se
   inst.Light:EnableClientModulation(false)        --不读取客户端的本地设置

   inst.entity:AddAnimState()                      --添加动画组件
   inst.AnimState:SetBank("teleportation")        --smcl文件的名字
   inst.AnimState:SetBuild("teleportation")       --文件夹名字
   inst.AnimState:PlayAnimation("idle")            --动画子名称,播放的就是它

   inst:AddTag("teleportation")                   --独有标签

   inst:AddTag("lightsource")                      --光源
    
   inst:AddTag("structure")                        --建筑标签

   inst:AddTag("_writeable")
   
   inst.entity:SetPristine()                       --初始化

   if not TheWorld.ismastersim then                --主客机判定:下边的代码为主机独占,上方为主客机共用
      return inst
   end

    inst:RemoveTag("_writeable")

    inst:AddComponent("inspectable")
	
    inst:AddComponent("writeable")
	
    inst:AddComponent("lootdropper")
    
   inst:AddComponent("workable")                              --添加可破坏组件
   inst.components.workable:SetWorkAction(ACTIONS.HAMMER)     --锤子
   inst.components.workable:SetWorkLeft(4)                    --敲4次
   inst.components.workable:SetOnFinishCallback(onhammered)   --锤敲掉落材料
   --inst.components.workable:SetOnWorkCallback(onhit)        --流星损坏:不需要

   inst:WatchWorldState("phase", zidonglight)                 --自动灯光
   zidonglight(inst, TheWorld.state.phase)
   
   inst:ListenForEvent("onbuilt", onbuilt)                    --监听:建造

   inst:AddComponent("hauntable")                             --可闹鬼的,复活用
    
   return inst
end

return Prefab("teleportation", fn, assets),
MakePlacer("teleportation_placer", "teleportation", "teleportation", "idle")