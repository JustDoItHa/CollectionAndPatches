---------------------------------------------------------------------------------------------------------
--------------------------------------------修改玩家相关-------------------------------------------------
---------------------------------------------------------------------------------------------------------
--玩家初始化
AddPlayerPostInit(function(inst)
--拖拽后坐标
	inst.bigbag_drag_pos = GLOBAL.net_string(inst.GUID, "bigbag_drag_pos", "bigbag_drag_posdirty")
	if GLOBAL.TheWorld.ismastersim then
		--存储拖拽坐标数据
		local oldOnSaveFn=inst.OnSave
		local oldOnLoadFn=inst.OnLoad
		inst.OnSave=function(inst,data)
			data.bigbagdargpos=inst.bigbag_drag_pos:value()
			if oldOnSaveFn then
				oldOnSaveFn(inst,data)
			end
		end
		inst.OnLoad=function(inst,data)
			if data.bigbagdargpos then
				inst.bigbag_drag_pos:set(data.bigbagdargpos)
			end
			if oldOnLoadFn then
				oldOnLoadFn(inst,data)
			end
		end
	end
end)