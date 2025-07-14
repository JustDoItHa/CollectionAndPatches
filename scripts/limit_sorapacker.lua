local packPostInit = function(inst)
	if inst and inst.components and inst.components.sorapacker then
		local oldCanPackFn = inst.components.sorapacker.canpackfn
		inst.components.sorapacker:SetCanPackFn(function(target, inst2)
			if target:HasTag("multiplayer_portal") --大门
					or target.prefab == "pigking" --猪王
					or target.prefab == "beequeenhivegrown" --蜂王窝-底座
					or target.prefab == "statueglommer" --格罗姆雕像
					or target.prefab == "oasislake" --绿洲
					or target.prefab == "archive_switch"--档案馆华丽的基座
					or target.prefab == "archive_portal"--档案馆传送门
					or target.prefab == "archive_lockbox_dispencer"--知识饮水器
					or target.prefab == "atrium_gate"--远古大门

					or target.prefab == "toadstool_cap"--毒菌蟾蜍蘑菇

					or target.prefab == "elecourmaline" --电器台
					or target.prefab == "elecourmaline_keystone" --
					or target.prefab == "siving_thetree" --子圭神木岩

					or target.prefab == "myth_rhino_desk"--三犀牛台
					or target.prefab == "myth_chang_e"--嫦娥
					or target.prefab == "myth_store"--小店
					or target.prefab == "myth_store_construction"--未完成的小店
			then
				return false;
			else
				return oldCanPackFn(target, inst2);
			end
		end)
	end
end

AddPrefabPostInit("sorapacker", packPostInit)