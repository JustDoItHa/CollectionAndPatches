local PlayerManager = Class(function(self, inst)
    self.inst = inst
    self.link_userid = {}--{"link_userid"}
end)
function PlayerManager:AddPlayer(userid)
    if userid == nil then return end
    for k, v in pairs(self.link_userid) do
        if v == userid then
            return false
        end
    end
    table.insert(self.link_userid, userid)
    return true
end
function PlayerManager:DelPlayer(userid)
    if userid == nil then return end
    if #self.link_userid >0 then
        for k, v in pairs(self.link_userid) do
            if userid == v then
                table.remove(self.link_userid, k)
                return true
            end
        end
    end
    return false
end

function PlayerManager:OnSave()
    return{
        link_userid = self.link_userid,
    }
end

function PlayerManager:OnLoad(data)
    if data ~= nil then
		self.link_userid = data.link_userid
	end
end
return PlayerManager