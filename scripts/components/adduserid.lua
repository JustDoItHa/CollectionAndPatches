local function OnPutInInventory(inst)
	if inst:HasTag("irreplaceable")then
		inst:RemoveTag("irreplaceable")
	end
	inst:DoTaskInTime(0,function()
		local self = inst.components.adduserid
		if inst.components ==nil or inst.components.inventoryitem == nil then
			return
		end
		local owner = inst.components.inventoryitem:GetGrandOwner()
		if owner and owner:HasTag("player") and not self:IsLeagelOwner(owner) and self.owner_name and inst.name ~=nil then
			inst:DoTaskInTime(0,function()
				self:Drop()
				owner.components.talker:Say("这TM是"..self.owner_name.."的"..inst.name.."~~~")
			end)
		end
	end)
end
local function OnDropped(inst)
	if inst:HasTag("adduserid_locked") and not inst:HasTag("backpack") then
		inst:AddTag("irreplaceable")
	end
end
local AddUserId = Class(function(self,inst)
	self.inst = inst
	self.owner_userid = nil
	self.owner_name = nil
	self.inst:AddTag("adduserid")
	self.inst:ListenForEvent("onputininventory", OnPutInInventory)
	self.inst:ListenForEvent("ondropped", OnDropped)
end)

function AddUserId:LockOwner(giver)
	self.owner_userid = giver.userid
	self.owner_name = giver.name
	self.inst:AddTag("adduserid_locked")
end

function AddUserId:UnLockOwner()
	self.owner_userid = nil
	self.owner_name = nil
	self.inst:RemoveTag("adduserid_locked")
end

function AddUserId:IsLocked()
	return self.owner_userid ~= nil
end 

function AddUserId:IsLeagelOwner(picker)
	return picker and picker:IsValid() and picker:HasTag("player") and ((self:IsLocked()  and picker.userid == self.owner_userid) or not self:IsLocked())
end 

function AddUserId:Drop()
    local owner = self.inst.components.inventoryitem:GetGrandOwner()
    if owner ~= nil and owner.components.inventory ~= nil then
        owner.components.inventory:DropItem(self.inst, true, true)
    end
end
function AddUserId:CanAcceptTest(item,giver)
	return item and item:IsValid() and item.prefab == "shadowheart"
end 

function AddUserId:Adduserid(item,giver)
	local name = item.prefab
	local canremove = false 
	if self:CanAcceptTest(item,giver) then 
        if name == "shadowheart" then 
            if not self:IsLocked() then 
                self:LockOwner(giver)
                giver.components.talker:Say("绑定成功!")
                canremove = true
            elseif self:IsLeagelOwner(giver) then 
                self:UnLockOwner()
                giver.components.talker:Say("解绑成功!")
                canremove = true
			else
				giver.components.talker:Say("不能绑定别人的东西!!")
            end
        end
	end
	if canremove then 
		local one_item = (item.components.stackable and item.components.stackable:Get()) or item
		giver.SoundEmitter:PlaySound("dontstarve/wilson/equip_item_gold")
		one_item:Remove()
	end
end 
function AddUserId:OnSave()
	return {
		owner_userid = self.owner_userid,
		owner_name = self.owner_name
	}
end

function AddUserId:OnLoad(data)
	if data then 
		self.owner_userid = data.owner_userid
		self.owner_name = data.owner_name
	end
	if self:IsLocked() then
		self.inst:AddTag("adduserid_locked")
		-- local owner = self.inst.components.inventoryitem:GetGrandOwner()
		-- if owner == nil then
		-- 	self.inst:AddTag("irreplaceable")
		-- end
	else
		self.inst:RemoveTag("adduserid_locked")
	end
end

return AddUserId