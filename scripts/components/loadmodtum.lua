local LoadModTum = Class(function(self, inst)
	self.inst=inst
	self.load=true
end)

function LoadModTum:OnSave()
    return {
        load = self.load,
    }
end

function LoadModTum:OnLoad(data)
    self.load = data.load == nil and true or data.load
end


return LoadModTum