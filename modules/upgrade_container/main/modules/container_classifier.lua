--this mod make MAXITEMSLOTS so large that
--too many event listeners are registrated
--even the chest level is far from maximum
--which cause lagging when the chest opens

--Rewrite this part so that new listeners are added only if the listeners are not enough
--I dont think this is good solution but it do alleviate the lagging and no bug has yet been discovered

--local containers = require("containers")
--local slotslimit = math.max(containers.MAXITEMSLOTS, (TUNING.CHESTUPGRADE.MAX_LV ^ 2 + 2 * TUNING.CHESTUPGRADE.MAX_LV) * TUNING.CHESTUPGRADE.MAX_PAGE)

local function PreInitializeSlots(inst, numslots)
	local curslots = #inst._items + #inst._itemspool
	--GLOBAL.assert(slotslimit >= numslots)
	if curslots > 0 and numslots > curslots then
		for i = curslots + 1, numslots do
			table.insert(inst._itemspool, GLOBAL.net_entity(inst.GUID, "container._items["..tostring(i).."]", "items["..tostring(i).."]dirty"))
		end
	end
end

AddPrefabPostInit("container_classified", function(inst)
	local InitializeSlots = inst.InitializeSlots
	inst.InitializeSlots = function(inst, numslots, ...)
        if not GLOBAL.ChestUpgrade.DISABLERS["CONTAINER_C"] then
    		PreInitializeSlots(inst, numslots)
        end
		return InitializeSlots(inst, numslots, ...)
	end
	--[[
	if GLOBAL.TheWorld.ismastersim then return end
	local tasks = inst.pendingtasks
	if tasks ~= nil then
		inst.OnReinitialize = GLOBAL.next(tasks).fn

		local OLD_InitializeSlots = inst.InitializeSlots
		inst.InitializeSlots = function(inst, ...)
			inst:RemoveAllEventCallbacks()
			OLD_InitializeSlots(inst, ...)
			inst.OnReinitialize(inst)
		end
	end
	]]
end)

