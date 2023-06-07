local siwangjishu = Class(function(self, inst)
    self.inst = inst
	self.num = 0
	self.inst:ListenForEvent("death",function()
		self.num = self.num + 1

		if self.inst.deathed_num and self.inst.deathed_num:IsValid() then
               self.inst.deathed_num:Stext("死亡次数"..self.num, 2, 25, 3, true) 
		end	

		if self.inst._deathed_num:value() then
			 self.inst._deathed_num:set(self.num)
		end

		SendModRPCToClient(CLIENT_MOD_RPC["siwangjishu"]["siwangjishu"],self.inst.userid,"玩家"..self.inst.name.."当前死亡次数："..self.num)
	end)

	--self:StartUpdate()
	self.inst:StartUpdatingComponent(self)
end)

function siwangjishu:OnUpdate(dt)
      --print("开始刷新")
    if self.inst.deathed_num == nil or (self.inst._deathed_num and not self.inst.deathed_num:IsValid()) then
	      self.inst.deathed_num = SpawnPrefab("deathed_num") 
	      self.inst.deathed_num.entity:SetParent(self.inst.entity) 

	      self.inst.deathed_num:Stext("死亡次数"..self.num, 2, 25, 3, true) 
	end  
end	

function siwangjishu:OnSave()
	return self.num ~= 0 and { num = self.num } or nil
end

function siwangjishu:OnLoad(data)
	if data and data.num then
		self.num = data.num
		
		if self.inst._deathed_num:value() then
			 self.inst._deathed_num:set(self.num)
		end	
	end
end

return siwangjishu
