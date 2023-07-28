
local showbundle  = TUNING.HUAMINISIGN_BUNDLE
local changeskin  = TUNING.HUAMINISIGN_SKIN
local candig  = TUNING.HUAMINISIGN_DIG

local function newminisign(inst,self)
	if inst.components.drawable then
		inst.components.drawable.candraw = false
	end
	
	if inst.components.workable then
		if not candig then
			inst:RemoveComponent("workable")
		else
			inst.components.workable:SetOnFinishCallback(function()
				self.nohuaminisign = true
				inst:Remove()
			end)
		end
	end
	if inst.components.burnable then
		inst:RemoveComponent("burnable")
	end
	if inst.components.propagator then
		inst:RemoveComponent("propagator")
	end
end

local Smart_Minisign = Class(function(self, inst)
	self.inst = inst
	self.nohuaminisign = false
	self.sign = nil
	self.onclose = nil
	inst:ListenForEvent("onclose", function(...) self:OnClose() end)
	inst:DoTaskInTime(0.1,function (inst) --load or build
		if not self.nohuaminisign then
			self:SpawnSign()
			self:OnClose()
		end
	end)
    self._onremove = function(pet)
        self.sign = nil
    end
	if inst.components.burnable ~= nil then  --remove the fx after burnt
		local onburnt = inst.components.burnable.onburnt or nil 
		inst.components.burnable.onburnt = function()
			if onburnt ~= nil then
				onburnt(inst)
			end
			if self.sign ~= nil then 
				self.sign:Remove()
			end
		end
	end
end)

function Smart_Minisign:SpawnSign()
	local inst = self.inst
	if inst:HasTag("burnt") then  --of course not 
		return
	end
	if self.sign ~= nil then --only one
		return
	end

    local sign = SpawnPrefab("minisign")
	self:LinkSign(sign)
end

function Smart_Minisign:LinkSign(minisign)
	self.sign = minisign
	self.inst:AddChild(minisign)
	minisign.Transform:SetPosition(0, 0, 0)
    self.inst:ListenForEvent("onremove", self._onremove, minisign)
    minisign.persists = false
	newminisign(minisign,self)
end

function Smart_Minisign:OnClose()
	local inst = self.inst
	if self.sign ~= nil and  inst.components.container~= nil then
		local container = inst.components.container
		for i = 1, container:GetNumSlots() do
			local item = container:GetItemInSlot(i)
			if item ~= nil and item.replica.inventoryitem ~= nil  then
				if changeskin and item.prefab == "minisign_item" then --以旧换新
					self.sign:Remove()
					local sign = SpawnPrefab("minisign", item.linked_skinname, item.skin_id )
					self:LinkSign(sign)
				end
				local image = item.replica.inventoryitem:GetImage()
				local  build  = item.replica.inventoryitem:GetHuaAtlas()
				--for bundle
				if showbundle and item.components.unwrappable ~= nil and item.components.unwrappable.itemdata then
					for i, v in ipairs(item.components.unwrappable.itemdata) do
						if  v  then
							local bundledItem = SpawnPrefab(v.prefab, v.skinname, v.skin_id)
							if bundledItem ~= nil and bundledItem.replica.inventoryitem ~= nil  then
								item = bundledItem
								image = bundledItem.replica.inventoryitem:GetImage()
								build  = bundledItem.replica.inventoryitem:GetHuaAtlas()
								bundledItem:Remove()
								break
							end
							-- local copy = SpawnPrefab(v.prefab)
							-- if copy then 
							-- 	if copy.replica.inventoryitem ~= nil  then
							-- 		image = copy.replica.inventoryitem:GetImage()
							-- 		build  = copy.replica.inventoryitem:GetHuaAtlas()
							-- 	end
							-- 	copy:Remove()
							-- 	break
							-- end
						end
					end
				end
				self.sign.AnimState:OverrideSymbol("SWAP_SIGN", build, image)
                if item.inv_image_bg and item.inv_image_bg.atlas then
                    self.sign.AnimState:OverrideSymbol("SWAP_SIGN_BG", resolvefilepath(item.inv_image_bg.atlas), item.inv_image_bg.image)
                else
                    self.sign.AnimState:ClearOverrideSymbol("SWAP_SIGN_BG")
                end
				break
			end
			if i == container:GetNumSlots() and item == nil then
				self.sign.AnimState:ClearOverrideSymbol("SWAP_SIGN")
				self.sign.AnimState:ClearOverrideSymbol("SWAP_SIGN_BG")
			end
		end
	end
end

function Smart_Minisign:OnSave()
    return
    {
        nohuaminisign = self.nohuaminisign,
		sign = self.sign ~= nil and self.sign:GetSaveRecord() or nil
    }
end

function Smart_Minisign:OnLoad(data)
    if data then
		if data.nohuaminisign ~= nil then
			self.nohuaminisign = data.nohuaminisign
		end
		if data.sign ~= nil then
			local sign = SpawnSaveRecord(data.sign)
			self:LinkSign(sign)
		end
	end
end

return Smart_Minisign