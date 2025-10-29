--this mod make MAXITEMSLOTS so large that
--too many event listeners are registrated
--even the chest level is far from maximum
--which cause lagging when the chest opens

--Rewrite this part so that new listeners are added only if the listeners are not enough
--I dont think this is good solution but it do alleviate the lagging and no bug has yet been discovered

--re: it do cause bug, when moving between forest and cave, some backpack items disappear.

--re:re: possible reason: container replicate before chestupgrade
local containers = require("containers")

if false then --GetModConfigData("LAG_REDUCER") then
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
			PreInitializeSlots(inst, numslots)
			InitializeSlots(inst, numslots, ...)
		end
	end)

else
	local chestmaxlv = (TUNING.CHESTUPGRADE.MAX_LV + 1) * (TUNING.CHESTUPGRADE.MAX_LV + 1) * TUNING.CHESTUPGRADE.MAX_PAGE
	local packmaxlv = (TUNING.CHESTUPGRADE.MAXPACKSIZE * 2 + 14) * (TUNING.CHESTUPGRADE.MAXPACKSIZE * 2 + 14) * TUNING.CHESTUPGRADE.MAXPACKPAGE
	containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, chestmaxlv, packmaxlv)
end