
-- local upvaluehelper = require "utils/upvaluehelp_cap"
-- local lei = require "prefabs/player_common_extensions" --怜 开局礼包 修改
-- local vips = upvaluehelper.Get(lei.GivePlayerStartingItems,"vips")
-- if vips then
--     for k,v in pairs(vips) do
--         if v.items then
--            v.items = {"rei_start_stone"} ----星光石
--         end
--     end
-- end

AddPrefabPostInit("rei_start_stone", function(inst)
    if not TheWorld.ismastersim or inst.components.trader == nil or inst.components.trader.onaccept == nil then return end
    inst.components.trader.onaccept = function(inst,giver,...)
        giver.components.talker:Say("为什么呢？")
        if inst.components.trader.deleteitemonaccept == false then
            giver.components.inventory.GiveItem(item)
        end
    end
end)

AddPrefabPostInit("rei_weapon_sword4", function(inst)
    if not TheWorld.ismastersim then
        return
    end
    if inst.components.trader == nil or inst.components.trader.onaccept == nil then return end
    inst.components.trader.onaccept = function(inst,giver,item,...)
        giver.components.talker:Say("为什么呢？")
        if inst.components.trader.deleteitemonaccept == false then
            giver.components.inventory.GiveItem(item)
        end
    end
end)