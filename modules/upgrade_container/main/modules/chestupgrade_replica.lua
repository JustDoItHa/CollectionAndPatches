AddClassPostConstruct("components/chestupgrade_replica", function(self, inst)
	if GetModConfigData("DRAGGABLE", true) then
		self.drag = GetModConfigData("DRAGGABLE", true)
	end
	if GetModConfigData("UI_WIDGETPOS", true) then
		self.uipos = true
	end
end)