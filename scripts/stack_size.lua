-- 使用的mod名称：生物可以被堆叠（Creatures Can Be Stacked）
-- mod链接：https://steamcommunity.com/sharedfiles/filedetails/?id=275135339
-- mod更新时间：2022.04.02 下午 4:45
-- mod作者：今晚早点睡

-- 堆叠上线修改
local stack_size = GetModConfigData("stack_size")
TUNING.STACK_SIZE_LARGEITEM = stack_size
TUNING.STACK_SIZE_MEDITEM = stack_size
TUNING.STACK_SIZE_SMALLITEM = stack_size
TUNING.STACK_SIZE_TINYITEM = stack_size

package.loaded["components/stackable_replica"] = nil --修复其他mod提前修改了堆叠报错
local stackable_replica = require("components/stackable_replica")
stackable_replica._ctor = function(self, inst)
    self.inst = inst
    self._stacksize = GLOBAL.net_shortint(inst.GUID, "stackable._stacksize", "stacksizedirty")
    self._maxsize = GLOBAL.net_tinybyte(inst.GUID, "stackable._maxsize")
end


-- local function stack(self)
--     function self.inst.replica.stackable:SetMaxSize(maxsize)
--         self._maxsize:set(1)
--     end
-- end

-- AddComponentPostInit("stackable", stack)
-- if stack_size > 63 then
--     local stackable_replica = GLOBAL.require("components/stackable_replica")
--     stackable_replica._ctor = function(self, inst)
--         self.inst = inst
--         self._stacksize = GLOBAL.net_shortint(inst.GUID, "stackable._stacksize", "stacksizedirty")
--         self._maxsize = GLOBAL.net_tinybyte(inst.GUID, "stackable._maxsize")
--     end
-- end


if GetModConfigData("stack_more") then
    local creatures = {
        ["rabbit"] = {ondropfn = nil}, --兔子

        ["mole"] = {ondropfn = nil}, --鼹鼠

        ["crow"] = {ondropfn = nil}, --乌鸦
        ["robin"] = {ondropfn = nil}, --红雀
        ["robin_winter"] = {ondropfn = nil}, --雪雀
        ["canary"] = {ondropfn = nil}, --金丝雀
        ["puffin"] = {ondropfn = nil}, --海鹦鹉

        ["canary_poisoned"] = {ondropfn = nil}, --中毒的金丝雀

        ["spider"] = {ondropfn = nil}, --蜘蛛
        ["spider_hider"] = {ondropfn = nil}, --洞穴蜘蛛
        ["spider_spitter"] = {ondropfn = nil}, --喷射蜘蛛
        ["spider_warrior"] = {ondropfn = nil}, --蜘蛛战士
        ["spider_moon"] = {ondropfn = nil}, --破碎蜘蛛
        ["spider_healer"] = {ondropfn = nil}, --护士蜘蛛
        ["spider_dropper"] = {ondropfn = nil}, --穴居悬蛛
        ["spider_water"] = {ondropfn = nil}, --水蜘蛛
        
        ["pondfish"] = {ondropfn = nil}, --淡水鱼

        ["pondeel"] = {ondropfn = nil}, --鳗鱼

        ["wobster_sheller_land"] = {ondropfn = nil}, --龙虾
        ["wobster_moonglass_land"] = {ondropfn = nil}, --月光龙虾
        
        ["oceanfish_medium_1_inv"] = {ondropfn = nil}, --泥鱼
        ["oceanfish_medium_2_inv"] = {ondropfn = nil}, --深海鲈鱼
        ["oceanfish_medium_3_inv"] = {ondropfn = nil}, --华丽狮子鱼
        ["oceanfish_medium_4_inv"] = {ondropfn = nil}, --黑鲇鱼
        ["oceanfish_medium_5_inv"] = {ondropfn = nil}, --玉米鱼
        ["oceanfish_medium_6_inv"] = {ondropfn = nil}, --花锦鱼
        ["oceanfish_medium_7_inv"] = {ondropfn = nil}, --金锦鱼
        ["oceanfish_medium_8_inv"] = {ondropfn = nil}, --冰鲷鱼
        ["oceanfish_medium_9_inv"] = {ondropfn = nil}, --甜味儿鱼
        ["oceanfish_small_1_inv"] = {ondropfn = nil}, --小孔雀鱼
        ["oceanfish_small_2_inv"] = {ondropfn = nil}, --针鼻喷墨鱼
        ["oceanfish_small_3_inv"] = {ondropfn = nil}, --小饵鱼
        ["oceanfish_small_4_inv"] = {ondropfn = nil}, --三文鱼苗
        ["oceanfish_small_5_inv"] = {ondropfn = nil}, --爆米花鱼
        ["oceanfish_small_6_inv"] = {ondropfn = nil}, --落叶比目鱼
        ["oceanfish_small_7_inv"] = {ondropfn = nil}, --花朵金枪鱼
        ["oceanfish_small_8_inv"] = {ondropfn = nil}, --炽热太阳鱼
        ["oceanfish_small_9_inv"] = {ondropfn = nil}, --口水鱼

        ["minotaurhorn"] = {ondropfn = nil}, --远古守护者角
    }
    local ondropfn = function(inst)
        if creatures[inst.prefab] and creatures[inst.prefab].ondropfn then
            creatures[inst.prefab].ondropfn(inst)
        end
        if inst.components.stackable then --如果有堆叠组件，一个一个放生
            while inst.components.stackable:StackSize() > 1 do 
                --[[
                    必须大于1
                        如果等于1，single就是inst了，然后下面OnDropped()无限循环，导致堆栈溢出
                ]]
                local single = inst.components.stackable:Get()
                if single and single.components.inventoryitem then
                    single.components.inventoryitem:OnDropped() --这为什么没出问题？哦哦，sigle和inst不一样
                    single.Physics:Teleport(inst.Transform:GetWorldPosition())
                end
            end
        end
    end
    local AddPrefab_creatures = function(inst)
        if not TheWorld.ismastersim then
            return inst
        end
        if inst.components.stackable == nil then
            inst:AddComponent("stackable")
            inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM --10，必须用官方的预设
        end
        if inst.components.inventoryitem then
            local old_ondropfn = inst.components.inventoryitem.ondropfn --存一下旧函数
            if creatures[inst.prefab] then
                creatures[inst.prefab].ondropfn = old_ondropfn
            end
            inst.components.inventoryitem:SetOnDroppedFn(ondropfn)
        end
    end

    if true then
        for k, v in pairs(creatures) do
            AddPrefabPostInit(tostring(k), AddPrefab_creatures)
        end
    end
end


