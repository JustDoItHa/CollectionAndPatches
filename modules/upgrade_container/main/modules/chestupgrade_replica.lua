AddClassPostConstruct("components/chestupgrade_replica", function(self, inst)
	if GetModConfigData("UI_WIDGETPOS", true) then
		self.uipos = true
	end
end)