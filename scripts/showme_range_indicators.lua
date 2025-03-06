local _G = GLOBAL
PrefabFiles = { "showme_range" }	--加载prefab文件

-- local controller = _G.require "components/playercontroller"
-- local old_OnLeftClick = controller.OnLeftClick

-- function controller:OnLeftClick(down,...)		--鼠标点击
-- 	if (not down) and self:UsingMouse() and self:IsEnabled() and not _G.TheInput:GetHUDEntityUnderMouse() then
-- 		local item = _G.TheInput:GetWorldEntityUnderMouse()
-- 		if item and (item.prefab == "lightning_rod"  or item.prefab == "oceantree_pillar")  then	--item:HasTag("hasemergencymode") 
-- 			ShowMeRange(item)
-- 		end
-- 	end
-- 	return old_OnLeftClick(self,down,...)
-- end
local function OnPutInInventory(inst)
    inst.components.timer:StopTimer("errode")
end

local showmePRL = {		--显示范围的物品列表
	"oceantree_pillar",
	"lightning_rod",
	"nightstick",		--星辰锤，不妥协添加了避雷针标签，当然，没不妥协是不显示范围的
	"fimbul_axe",		--棱镜电气斧
	"tourmalinecore",	--棱镜电气石
}
for k, v in pairs(showmePRL) do
	AddPrefabPostInit(v, function(inst)
		inst:DoTaskInTime(.5, function ()
			local d
			if k == 1 then		--根据表的序列赋予不同的SpawnPrefab
				d = "ocep_range_indicator"
			elseif k > 1  then
				d = "lhr_range_indicator"
			end
			local x, _, z = inst.Transform:GetWorldPosition()
			--local showme_range_indicators = _G.TheSim:FindEntities(x, 0, z, 2, {d})
			--if #showme_range_indicators < 1 then
			local showme_range = _G.SpawnPrefab(d)
			if d ~= nil and ( k == 1 or inst:HasTag("lightningrod") ) then		--如果是列表 1 的物品或者拥有避雷针标签的物品就添加上范围圈圈
				if not (inst.components.inventoryitem or inst.components.inventory) then
					showme_range.Transform:SetPosition(x, 0, z)
				end
			end
			-- inst:DoPeriodicTask(.5, function ()
				-- if inst:HasTag("INLIMBO") and inst:HasTag("lightningrod") then		--获取可拾取物品标签INLIMBO，拾取后移除范围圈圈
					-- if showme_range and showme_range.Remove then
						-- showme_range:Remove()
						-- inst:AddTag("showme_rtag")		--添加个自定标签，方便标记
					-- end
				-- elseif inst:HasTag("showme_rtag") and inst:HasTag("lightningrod") then		--移除后再给添加上，方便下次丢弃时应用上圈圈
					-- showme_range = _G.SpawnPrefab(d)
					-- x, _, z = inst.Transform:GetWorldPosition()
					-- if d ~= nil then
						-- showme_range.Transform:SetPosition(x, 0, z)
						-- inst:RemoveTag("showme_rtag")
					-- end
				-- end
			-- end)
			
			inst:ListenForEvent("onpickup", function()	--监听拾取
				if showme_range and showme_range.Remove then
					showme_range:Remove()
				end
			end)
			inst:ListenForEvent("equipped", function()	--监听装备
				if showme_range and showme_range.Remove then
					showme_range:Remove()
				end
			end)
			inst:ListenForEvent("ondropped", function()	--监听丢弃
				showme_range = _G.SpawnPrefab(d)
				x, _, z = inst.Transform:GetWorldPosition()
				if d ~= nil then
					showme_range.Transform:SetPosition(x, 0, z)
					inst:RemoveTag("showme_rtag")
				end
			end)
			
			inst:ListenForEvent("onremove", function ()		--监听建筑物品是否被移除，若移除了范围圈圈也跟着移除
				if showme_range and showme_range.Remove then
					showme_range:Remove()
				end
			end)
		end)
	end)
end

