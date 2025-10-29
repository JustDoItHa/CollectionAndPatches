local ChestPage = require("widgets/chestpage")

local Vector3 = GLOBAL.Vector3
local TheInput = GLOBAL.TheInput

--------------------------------------------------
--add page button for integrated backpack style
local function NEW_Rebuild(self)
	local overflow = self.owner.replica.inventory:GetOverflowContainer()
	overflow = (overflow ~= nil and overflow:IsOpenedBy(self.owner)) and overflow or nil

	if overflow	~= nil and self.integrated_backpack then
		local chestupgrade = overflow.inst.replica.chestupgrade
		if chestupgrade == nil then return end
		local num = overflow:GetNumSlots()
		local offset = #self.inv - num
		if GetModConfigData("PACKSTYLE", true) and not (chestupgrade.chestlv.x * chestupgrade.chestlv.y > #self.inv) and chestupgrade.chestlv.z > 1 then
			local x, y, z = chestupgrade:GetLv()
			local show = x * y
			local slottogo = num
			self.integrated_arrow:Kill()
			self.integrated_arrow = nil
			self.backpackpage = self.bottomrow:AddChild(ChestPage(self.backpackinv, show, slottogo, overflow.inst))
			--local mid = (self.equip[GLOBAL.EQUIPSLOTS.HANDS]:GetPosition().x + self.equip[GLOBAL.EQUIPSLOTS.BODY]:GetPosition().x) / 2
			self.backpackpage:SetPosition(self.inv[#self.inv]:GetPosition().x + 136, 0, 0)
			for n = 1, z do
				for k = 1, x * y do
					local slot = self.backpackinv[(n - 1) * show + k]
					local inv = #self.inv - show + k
					slot:SetPosition(self.inv[inv]:GetPosition().x, 0, 0)
					if n == self.backpackpage.currentpage then
						slot:Show()
						slot:MoveToFront()
					else
						slot:Hide()
						slot:MoveToBack()
					end
					--slottogo = slottogo - 1
				end
			end
		elseif GetModConfigData("OVERFLOW", true) and offset < 0 and #self.inv > 3 then
			local show = #self.inv - 3
			local slottogo = num
			self.backpackpage = self.bottomrow:AddChild(ChestPage(self.backpackinv, show, slottogo, overflow.inst))
			self.backpackpage:SetPosition(self.inv[2]:GetPosition().x, 0, 0)
			for n = 1, math.ceil(num / show) do
				for k = 1, math.min(show, slottogo) do
					local slot = self.backpackinv[(n - 1) * show + k]
					local inv = k + 3
					slot:SetPosition(self.inv[inv]:GetPosition().x, 0, 0)
					if n == self.backpackpage.currentpage then
						slot:Show()
						slot:MoveToFront()
					else
						slot:Hide()
						slot:MoveToBack()
					end
					slottogo = slottogo - 1
				end
			end
		end
		if self.backpackpage ~= nil then
			self.backpackpage:ReBuild(true)
			self.pagebtn = {self.backpackpage.pgupbtn, self.backpackpage.pgdnbtn}
		end
	end
end

--------------------------------------------------
--allow flip page using controller's shoulder button
local function NEW_OnControl(self, control, down, ...)
	if self._base.OnControl(self, control, down) then
		return true
	elseif not self.open then
		return
	elseif down then
		return
	elseif self.current_list == nil or self.active_slot == nil then
		return
	end
	if control == GLOBAL.CONTROL_SCROLLBACK or control == GLOBAL.CONTROL_SCROLLFWD then
		local chestpage = (self.current_list == self.backpackinv) and self.backpackpage
				or self.active_slot:GetParent().chestpage
		if chestpage then
			local delta = control == GLOBAL.CONTROL_SCROLLBACK and -1 or 1
			chestpage:PageChange(delta)
			self:CursorNav(Vector3(), true)
			--local slot = self:GetClosestWidget({self.current_list}, self.active_slot:GetWorldPosition(), Vector3())
			--self:SelectSlot(slot)
			self:UpdateCursor()
			return true
		end
	end
end

--------------------------------------------------
--make page btn be selectable by controller
local function MakePageBtnSelectable(self)
	local OLD_GetInventoryLists = self.GetInventoryLists
	function self:GetInventoryLists(same_container_only, ...)
		local list = OLD_GetInventoryLists(self, same_container_only, ...)
		if not same_container_only or self.current_list == self.backpackinv then
			table.insert(list, self.pagebtn)
		elseif self.current_list == self.pagebtn then
			table.insert(list, self.backpackinv)
		end
		return list
	end

	local OLD_UpdateCursorText = self.UpdateCursorText
	function self:UpdateCursorText(...)
		if self.active_slot.notslot then
			return
		end
		return OLD_UpdateCursorText(self, ...)
	end

	local OLD_GetClosestWidget = self.GetClosestWidget
	function self:GetClosestWidget(...)
		local closest, closest_list = OLD_GetClosestWidget(self, ...)
		if closest == nil then
			closest = self.active_slot
		end
		if closest_list == nil then
			closest_list = self.current_list
		end
		if closest and closest_list and not closest:IsVisible() then
			local pos = closest:GetWorldPosition()
			for k, v in pairs(closest_list) do
				if v:IsVisible() and v:GetWorldPosition() == pos then
					closest = v
					break
				end
			end
		end
		return closest, closest_list
	end

	local OLD_CursorLeft = self.CursorLeft
	local OLD_CursorRight = self.CursorRight
	local OLD_CursorUp = self.CursorUp
	local OLD_CursorDown = self.CursorDown
	function self:CursorLeft(...)
		local oldslot = self.active_slot
		OLD_CursorLeft(self, ...)
		if self.reps == 1 and self.active_slot == oldslot then
			if self.pagebtn ~= nil then
				if self.current_list == self.pagebtn then
					self.current_list = self.backpackinv
					local page = self.backpackpage
					local slot = page.currentpage * page.show
					self:SelectSlot(self.backpackinv[slot])
				elseif self.current_list == self.backpackinv then
					self.current_list = self.pagebtn
					self:SelectSlot(self.pagebtn[#self.pagebtn])
				end
			elseif oldslot:GetParent().name == "ChestPage" then
				self:CursorNav(Vector3(-1,0,0))
			else
				return
			end
			GLOBAL.TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
		end
	end

	function self:CursorRight(...)
		local oldslot = self.active_slot
		OLD_CursorRight(self, ...)
		if self.reps == 1 and self.active_slot == oldslot then
			if self.pagebtn ~= nil then
				if self.current_list == self.pagebtn then
					self.current_list = self.backpackinv
					local page = self.backpackpage
					local slot = (page.currentpage - 1) * page.show + 1
					self:SelectSlot(self.backpackinv[slot])
				elseif self.current_list == self.backpackinv then
					self.current_list = self.pagebtn
					self:SelectSlot(self.pagebtn[1])
				end
			elseif oldslot:GetParent().chestpage ~= nil then
				local page = oldslot:GetParent().chestpage
				local list = {page.pgupbtn, page.pgdnbtn}
				self.current_list = list
				local btn = page.pgupbtn
				if oldslot:GetWorldPosition().y <= page:GetWorldPosition().y then
					btn = page.pgdnbtn
				end
				self:SelectSlot(btn)
			else
				return
			end
			GLOBAL.TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
		end
	end

	function self:CursorUp(...)
		local oldslot = self.active_slot
		if oldslot:GetParent().name == "ChestPage" and not oldslot:GetParent().integrated then
			local newslot = self.current_list[1]
			--[[
			if oldslot == self.current_list[3] then
				newslot = self.current_list[2]
			end
			]]
			self:SelectSlot(newslot)
			GLOBAL.TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
		else
			return OLD_CursorUp(self, ...)
		end
	end

	function self:CursorDown(...)
		local oldslot = self.active_slot
		if oldslot:GetParent().name == "ChestPage" and not oldslot:GetParent().integrated then
			local newslot = self.current_list[2]
			--[[
			if oldslot == self.current_list[1] then
				newslot = self.current_list[2]
			end
			]]
			self:SelectSlot(newslot)
			GLOBAL.TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
		else
			return OLD_CursorDown(self, ...)
		end
	end
end

--------------------------------------------------
--inventorybar widget
AddClassPostConstruct("widgets/inventorybar", function(self)
	local OLD_Rebuild = self.Rebuild
	function self:Rebuild(...)
		OLD_Rebuild(self, ...)
		NEW_Rebuild(self)
	end

	local OLD_OnControl = self.OnControl
	function self:OnControl(control, down, ...)
		return NEW_OnControl(self, control, down, ...)
				or OLD_OnControl(self, control, down, ...)
				or nil
	end

	--controller
	MakePageBtnSelectable(self)
end)