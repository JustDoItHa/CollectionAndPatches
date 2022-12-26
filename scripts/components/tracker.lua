local Tracker = Class(function(self, inst)
	self.inst = inst
	self.userid = nil
	self.username = nil
end)

function Tracker:GetName()
	return self.username
end

function Tracker:GetId()
	return self.userid
end

function Tracker:UpdateInfo(userid, username)
	self.userid = userid or self.userid
	self.username = username or username
end

function Tracker:DisplayOwnerInfo()
	return "所有者：" .. self.username
end

function Tracker:OnSave()
	return { userid =  self.userid, username = self.username}
end

function Tracker:OnLoad(data)
	if data then
		self.userid = data.userid
		self.username = data.username
	end
end

return Tracker
