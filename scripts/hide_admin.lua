AddClassPostConstruct("screens/playerstatusscreen",function(inst)
	local old_DoInit = inst.DoInit
	function inst:DoInit(ClientObjs)
		old_DoInit(self,ClientObjs)
		if inst.player_widgets ~= nil then
			for _,playerListing in ipairs(inst.player_widgets) do
				playerListing.adminBadge:Hide()
			end
		end

		local scroll_updateFn = inst.scroll_list.updatefn
		if scroll_updateFn ~= nil then
			function inst.scroll_list.updatefn(playerListing, client, i)
				scroll_updateFn(playerListing, client, i)
				playerListing.adminBadge:Hide()
			end
		end
	end
end)
AddClassPostConstruct("widgets/redux/playerlist",function(inst)
	local old_BuildPlayerList = inst.BuildPlayerList
	function inst:BuildPlayerList(ClientObjs)
		old_BuildPlayerList(self,ClientObjs)
		if inst.scroll_list.children ~= nil then
			for _,playerListing in pairs(inst.scroll_list.children) do
				if playerListing ~= nil and playerListing.adminBadge ~= nil then
					playerListing.adminBadge:Hide()
				end
			end
		end

		local scroll_updateFn = inst.scroll_list.update_fn
		if scroll_updateFn ~= nil then
			function inst.scroll_list.update_fn(context,widget,data,index)
				scroll_updateFn(context,widget,data,index)
				widget.adminBadge:Hide()
			end
		end
	end
end)