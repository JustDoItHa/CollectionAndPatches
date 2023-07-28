local Protector = Class(function(self, inst)
    self.inst = inst
    self.userid = nil --"userid"
    self.username = nil --"username" --"别人的"
    self.isprotected = true
    self.protectortime = nil
    self.inst:AddTag("protected")
end)

function Protector:OnSave()
    return{
        protectortime = self.protectortime,
        userid = self.userid,
        username = self.username,
        isprotected = self.isprotected,
    }
end

function Protector:OnLoad(data)
    if data ~= nil then
        self.protectortime = data.protectortime
		self.userid = data.userid
        self.username = data.username
        self.isprotected = data.isprotected
	end
end
return Protector