local PersistentData = Class(function(self, file)
	self.file = file
	self.data = nil
end)

function PersistentData:Set(value)
	self.data = value
	TheSim:SetPersistentString(self.file, json.encode(self.data))
end

function PersistentData:Get()
	if self.data == nil then
		TheSim:GetPersistentString(self.file, function(success, string)
			self.data = success and string:match("^%s*(.*%S)%s*$") and json.decode(string) or nil
		end)
	end
	return self.data
end

return PersistentData