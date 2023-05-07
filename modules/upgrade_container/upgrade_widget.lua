local Widget = require("widgets/widget")
local ImageButton = require("widgets/imagebutton")
local ChestPage = require("widgets/chestpage")
local DragContainer = require("widgets/dragcontainer")
local Text = require("widgets/text")
local SeachChest = require("widgets/searchchest")

local STRINGS = GLOBAL.STRINGS.UPGRADEABLECHEST
local SORTTEXT = STRINGS.SORTTEXT
local DROPALLTEXT = STRINGS.DROPALLTEXT
local DROPHOVER = STRINGS.DROPHOVER

local Vector3 = GLOBAL.Vector3

--------------------------------------------------
--[[
local function GetAlignPos(slotpos, align, dragwidget, offset)
	local first = slotpos[1]:GetPosition()
	local last = slotpos[#slotpos]:GetPosition()
	local mid_x = math.floor((first.x + last.x) / 2)
	local mid_y = math.floor((first.y + last.y) / 2)
	local drag_x, drag_y = 0, 0
	if dragwidget then
		drag_x = (dragwidget.total.x - dragwidget.show.x) * 20
		drag_y = (dragwidget.total.y - dragwidget.show.y) * 20
	end
	offset = offset or 0
	local pos
	if align = 0 then			--left
		pos = Vector3(first.x - (offset + drag_x), mid_y, 0)
	elseif align = 1 then		--top
		pos = Vector3(mid_x, first.y + (offset + drag_y), 0)
	elseif align = 2 then		--right
		pos = Vector3(last.x + (offset + drag_x), mid_y, 0)
	elseif align = 3 then		--btm
		pos = Vector3(mid_x, last.y - (offset + drag_y), 0)
	end
	return pos
end
]]
local function GetAlignPos2(size, align, offset)
	local drag = GetModConfigData("DRAGGABLE", true)
	local lv_x, lv_y = size[1], size[2]
	if drag then
		lv_x = math.min(lv_x, drag)
		lv_y = math.min(lv_y, drag)
	end
	offset = offset or 0
	local pos_x = lv_x * 40 + offset
	local pos_y = lv_y * 40 + offset
	local pos-- = Vector3((align < 2) and (-1 ^ align * pos_x) or 0, (align > 1) and (-1 ^ align * pos_y) or 0)
	if align == 0 then			--right
		pos = Vector3(pos_x, 0, 0)
	elseif align == 1 then		--left
		pos = Vector3(-pos_x, 0, 0)
	elseif align == 2 then		--top
		pos = Vector3(0, pos_y, 0)
	elseif align == 3 then		--btm
		pos = Vector3(0, -pos_y, 0)
	end
	return pos
end

local PositionRecord = {}

--------------------------------------------------
--containerwidget
--------------------------------------------------
--show the items needed for upgrade
local function ShowGuide(self, container)
	local chestupgrade = container.replica.chestupgrade
	local lv_x, lv_y, lv_z = chestupgrade:GetLv()
	if (lv_x < TUNING.CHESTUPGRADE.MAX_LV and lv_y < TUNING.CHESTUPGRADE.MAX_LV) and GLOBAL.ChestUpgrade.AllUpgradeRecipes[container.prefab] then
		local slots = chestupgrade:CreateCheckTable()
		for k, v in pairs(slots) do
			if v then
				local image = type(v) == "table" and (v.GetImage ~= nil and v.GetImage() or v[1]..".tex") or v..".tex"
				self.inv[k]:SetBGImage2(GLOBAL.resolvefilepath(GLOBAL.GetInventoryItemAtlas(image)), image, {1, 1, 1, .4})
			end
		end
	end
end

--------------------------------------------------
--pageable button
local function AddPageBtn(self, container)
	local lv_x, lv_y, lv_z = container.replica.chestupgrade:GetLv()
	local show = lv_x * lv_y
	if self.chestpage == nil then
		self.chestpage = self:AddChild(ChestPage(self.inv, show, #self.inv, container))
	else
		self.chestpage.inv = self.inv
		self.chestpage.show = show
		self.chestpage.total = #self.inv
		self.chestpage.container = container
		self.chestpage:ReBuild()
		self.chestpage:Show()
	end
	if container.replica.container:IsSideWidget() then
		local inv = self.inv
		local getmidptx = math.floor((inv[1]:GetPosition().x + inv[lv_x]:GetPosition().x) / 2)
		--local getmidpty = math.floor((inv[1]:GetPosition().y + inv[#inv]:GetPosition().y) / 2)
		self.chestpage:SetPosition(getmidptx, 0, 0)
		self.chestpage:PageChange(0)
	else
		self.chestpage.defaultpos = GetAlignPos2({lv_x, lv_y}, 0, 40)
		self.chestpage:SetPosition(self.chestpage.defaultpos)
		self.chestpage:PageChange(0)
		if GetModConfigData("SHOWALLPAGE", true) then
			self.chestpage.allpage = true
			self.chestpage:ShowAllPage()
		end
	end
end

--------------------------------------------------
--draggable widget
local function AddDragWidget(self, container, drag, uipos)
	local chestupgrade = container.replica.chestupgrade
	local lv_x, lv_y, lv_z = chestupgrade:GetLv()
	local show = {math.min(drag, lv_x), math.min(drag, lv_y)}
	local total = {lv_x, lv_y}
	local scale = {show[1] / total[1], show[2] / total[2]}
	if self.dragwidget == nil then
		if uipos then
			self.dragwidget = self:AddChild(DragContainer("images/hud.xml", "craftingsubmenu_fullvertical.tex", scale, show, total))
		else
			self.dragwidget = self:AddChild(DragContainer("images/hud.xml", "craftingsubmenu_fullhorizontal.tex", scale, show, total))
		end
	end
	if uipos then
		--self.dragwidget = self:AddChild(DragContainer("images/hud.xml", "craftingsubmenu_fullvertical.tex", scale, show, total))
		self.dragwidget:SetPosition(GetAlignPos2(show, 2, 260))
		self.dragwidget.bgimg:SetScale(1, -3/4, 1)
		self.dragwidget.bgimg:SetPosition(0, -24, 0)
	else
		--self.dragwidget = self:AddChild(DragContainer("images/hud.xml", "craftingsubmenu_fullhorizontal.tex", scale, show, total))
		self.dragwidget:SetPosition(GetAlignPos2(show, 1, 260))
		self.dragwidget.bgimg:SetScale(-1, 3/4, 1)
		self.dragwidget.bgimg:SetPosition(32, 0, 0)
	end
	self.dragwidget:Show()
	self.dragwidget:SetShowPos()
	self.dragwidget:ShowSection()
end

--------------------------------------------------
--search bar
local function AddSearchBar(self, container, uipos)
	if self.searchbar == nil then
		self.searchbar = self:AddChild(SeachChest(container, uipos))
	else
		self.searchbar.container = container
	end
	if uipos then
		self.searchbar:SetPosition(0, 400, 0)
		self.searchbar:SetScale(-1, 1, 1)
		self.searchbar:SetRotation(90)
	else
		self.searchbar:SetPosition(460, 0, 0)
	end
	self.searchbar:Initialize()
	self.searchbar:Hide()
end

--------------------------------------------------
local function setholdfn(btn, fn, hover, delay)
	--[[
	local old_onclick = btn.onclick
	btn:SetOnClick(function()
		btn.countdown = 0
		if not btn.holding then
			return old_onclick()
		end
	end)
	]]
	btn:SetWhileDown(fn)
	btn.countdown = 0
	btn.holding = false
	btn.OnUpdate = function(btn, dt)
		if not btn.holding and btn.whiledown then
			if btn.down then
				if btn.countdown > (delay or 2) then
					btn.holding = true
					btn.whiledown()
				else
					btn.countdown = btn.countdown + dt
				end
			else
				btn.countdown = 0
				btn.holding = false
			end
		end
	end
	if hover then
		btn:SetHoverText(hover)
	end
end

--some useless button
local UselessBtn = Class(Widget, function(self, sorting, dropall)
    Widget._ctor(self, "ChestUpgrade_ULB")

	--sort content
	if sorting then
		self.sortitembtn = self:AddChild(ImageButton("images/ui.xml", "button_small.tex", "button_small_over.tex", "button_small_disabled.tex", nil, nil, {.8,1.2}, {0,0}))
		self.sortitembtn:SetPosition(0, 0, 0)
		self.sortitembtn:SetOnClick(function()
			self.sortitembtn.countdown = 0
			if not self.sortitembtn.holding then
				SendModRPCToServer(GetModRPC("RPC_UPGCHEST", "stackandsort"), self:GetParent().container)
			end
		end)
		setholdfn(self.sortitembtn, function()
			SendModRPCToServer(GetModRPC("RPC_UPGCHEST", "fillcontent"), self:GetParent().container)
		end)

		self.sortitembtn:SetText(SORTTEXT)
		self.sortitembtn:SetFont(GLOBAL.BUTTONFONT)
		self.sortitembtn:SetTextSize(30)
	end

	--drop content
	if dropall then
		self.dropallbtn = self:AddChild(ImageButton("images/ui.xml", "button_small.tex", "button_small_over.tex", "button_small_disabled.tex", nil, nil, {.8,1.2}, {0,0}))
		self.dropallbtn:SetPosition(0, 0, 0)
		self.dropallbtn:SetOnClick(function()
			self.dropallbtn.countdown = 0
		end)
		setholdfn(self.dropallbtn, function()
			SendModRPCToServer(GetModRPC("RPC_UPGCHEST", "dropcontent"), self:GetParent().container)
		end)
		self.dropallbtn:SetText(DROPALLTEXT)
		self.dropallbtn:SetFont(GLOBAL.BUTTONFONT)
		self.dropallbtn:SetTextSize(30)
		self.dropallbtn:SetHoverText(DROPHOVER)
	end

	if sorting and dropall then
		self.dropallbtn:SetPosition(40, 0, 0)
		self.sortitembtn:SetPosition(-40, 0, 0)
	end
end)

--------------------------------------------------
--Open
local function NEW_Open(self, container, doer, ...)
	local chestupgrade = container.replica.chestupgrade
	if chestupgrade == nil then return end
	local lv_x, lv_y, lv_z = chestupgrade:GetLv()
	--change the bg scale
	local widget = container.replica.container:GetWidget()
	if widget.bgscale ~= nil then
		self.bganim:SetScale(widget.bgscale)
		self.bgimage:SetScale(widget.bgscale)
	end
	if widget.bgshift ~= nil then
		self.bganim:SetPosition(widget.bgshift)
		self.bgimage:SetPosition(widget.bgshift)
	end

	--shows the pageable button
	if lv_z ~= nil and lv_z > 1 then
		AddPageBtn(self, container)
	end

	if container.replica.container:IsSideWidget() then return end		--no backpack is going to do the following

	--show upgrade requirment
	local showguide = GetModConfigData("SHOWGUIDE", true) or 0
	if GetModConfigData("UPG_MODE") ~= 2 and showguide ~= 0 and (showguide ~= 2 or container.replica.container:IsEmpty()) then
		ShowGuide(self, container)
	end

	--shift the widget leftward if you are on the boat, or the container is icebox or saltbox
	local isonboat = doer:GetCurrentPlatform() ~= nil 
	local uipos = GetModConfigData("UI_WIDGETPOS", true)
	if uipos then
		local isfreezer = GetModConfigData("UI_ICEBOX", true) and (container.prefab == "icebox" or container.prefab == "saltbox")
		if widget.pos ~= nil and (isonboat or isfreezer) then	
			local rhs = Vector3(-140, 0, 0)
			self:SetPosition(widget.pos + rhs)
		end
	end

	if PositionRecord[container.prefab] then
		self:SetPosition(PositionRecord[container.prefab])
	end

	--draggable widget
	local drag = GetModConfigData("DRAGGABLE", true)
	if drag and (drag < lv_x or drag < lv_y) then
		AddDragWidget(self, container, drag, uipos)
	end

	--searchbar
	if GetModConfigData("SEARCHBAR", true) then
		AddSearchBar(self, container, uipos)
	end

	--useless button
	local sorting, dropall = GetModConfigData("SORTITEM", true), GetModConfigData("DROPALL", true)
	if sorting or dropall then
		if self.chestupgrade_ulb == nil then
			self.chestupgrade_ulb = self:AddChild(UselessBtn(sorting, dropall))
		else
			self.chestupgrade_ulb:Show()
		end
		self.chestupgrade_ulb:SetPosition(GetAlignPos2({lv_x, lv_y}, 3, 20))
	end
end

--------------------------------------------------
local function onchestlv()
	local config = {{name = "SHOWGUIDE", saved = 0}}
	GLOBAL.KnownModIndex:SaveConfigurationOptions(function() end, modname, config, true)
end

local function cleantask(inst, container)
	inst:RemoveEventCallback("onchestlv", onchestlv, container)
end

local function NEW_Close(self, ...)
	if self.isopen then
		--disable "SHOWGUIDE" after 1 upgrade
		if GetModConfigData("SHOWGUIDE", true) == 3 and self.container ~= nil then
			local ThePlayer = GLOBAL.ThePlayer
			ThePlayer:ListenForEvent("onchestlv", onchestlv, self.container)
			ThePlayer:DoTaskInTime(3, cleantask, self.container)
		end
		if self.dragwidget ~= nil then
			self.dragwidget:Hide()
		end
		if self.chestpage ~= nil then
			self.chestpage:Hide()
			--self.chestpage:Kill()
			--self.chestpage = nil
		end
		if self.chestupgrade_ulb ~= nil then
			self.chestupgrade_ulb:Hide()
		end
		if self.searchbar ~= nil then
			self.searchbar:Hide()
		end
	end
end

--------------------------------------------------
--search chest
local function ShowSearchBar(self)
	--self.searchbar:Initialize()
	self.searchbar:RefreshSpinner()
	self.searchbar:Show()
	self.searchbar:RelocateParent(true)
	if self.dragwidget ~= nil then
		self.dragwidget:Hide()
	end
end

local function HideSearchBar(self)
	self.searchbar:Hide()
	self.searchbar:Reset()
	self.searchbar:RelocateParent(true)
	if self.dragwidget ~= nil then
		self.dragwidget:Show()
	end
end

local function OnDoubleClick(self, control, down)
	if self._base.OnControl(self, control, down) then return true end

	if not self:IsEnabled() or not self.focus then return false end

	local prt = self:GetParent()
	local chestupgrade = prt.container ~= nil and prt.container.replica.chestupgrade ~= nil
	if not chestupgrade or prt.searchbar == nil then return end
	if control == GLOBAL.CONTROL_ACCEPT and GLOBAL.TheFrontEnd.isprimary then
		if not down then
			if self.down then
				self.down = false
				if self.lastclicktime ~= nil and (GLOBAL.GetTime() - self.lastclicktime) < .8 then
					if prt.searchbar:IsVisible() then
						HideSearchBar(prt)
					else
						ShowSearchBar(prt)
					end
					self.lastclicktime = nil
				else
					self.lastclicktime = GLOBAL.GetTime()
				end
			end
		else
			if not self.down then
				self.down = true
			end
		end
		return true
	end
end

local function AddSearchBarPreSet(self)
	local BGAnimOnControl = self.bganim.OnControl
	function self.bganim:OnControl(...)
		if BGAnimOnControl ~= nil then
			BGAnimOnControl(self, ...)
		end
		OnDoubleClick(self, ...)
	end
	local BGImageOnControl = self.bgimage.OnControl
	function self.bgimage:OnControl(...)
		if BGImageOnControl ~= nil then
			BGImageOnControl(self, ...)
		end
		OnDoubleClick(self, ...)
	end

	local OLD_OnItemGet = self.OnItemGet
	function self:OnItemGet(data, ...)
		if self.searchbar ~= nil then
			self.searchbar:OnItemGet(data)
		end
		return OLD_OnItemGet(self, data, ...)
	end
	local OLD_OnItemLose = self.OnItemLose
	function self:OnItemLose(data, ...)
		if self.searchbar ~= nil then
			self.searchbar:OnItemLose(data)
		end
		return OLD_OnItemLose(self, data, ...)
	end
end

--------------------------------------------------
local function vecdiv(vec, rhs)
	return Vector3(vec.x / rhs.x, vec.y / rhs.y, vec.z / rhs.z)
end

local function MakeDraggable(self)
	self.holding = false
	self.holdtime = 0

	local OLD_OnControl = self.OnControl
	function self:OnControl(control, down, ...)
		if self._base.OnControl(self, control, down) then return true end

		if not self:IsEnabled() or not self.focus then return false end

		local old = OLD_OnControl ~= nil and OLD_OnControl(self, control, down, ...)
		if control == GLOBAL.CONTROL_ACCEPT and GLOBAL.TheFrontEnd.isprimary then
			if down then
				if not self.down then
					self.down = true
					self:StartUpdating()
				end
			else
				if self.down then
					self.down = false
					if self.container ~= nil and self.holding then
						PositionRecord[self.container.prefab] = self:GetPosition()
					end
					self.holding = false
					self.holdtime = 0
					self:StopFollowMouse()
					self:StopUpdating()
				end
			end

			return true
		elseif control == GLOBAL.CONTROL_SECONDARY then
			if not down then
				if self.container ~= nil then
					PositionRecord[self.container.prefab] = nil
				end
			end
			return true
		end
		return old
	end

	local OLD_OnUpdate = self.OnUpdate
	function self:OnUpdate(dt, ...)
		if self.down then
			if not self.focus then
				self.down = false
				self.holdtime = 0
				self.holding = false
				self:StopFollowMouse()
				self:StopUpdating()
			elseif self.holdtime < 1 then
				self.holdtime = self.holdtime + dt
			elseif not self.holding then
				self.holding = true
				self:FollowMouse()
			end
		end
		if OLD_OnUpdate ~= nil then
			return OLD_OnUpdate(self, ...)
		end
	end

	function self:FollowMouse()
		if self.followhandler == nil then
			local scale_factor = self:GetParent():GetScale()
			local offset = self:GetLocalPosition() - vecdiv(GLOBAL.TheInput:GetScreenPosition(), scale_factor)
			self.followhandler = GLOBAL.TheInput:AddMoveHandler(function(...)
				local pos = vecdiv(Vector3(...), scale_factor) + offset
				self:UpdatePosition(pos)
			end)
			local pos = vecdiv(GLOBAL.TheInput:GetScreenPosition(), scale_factor) + offset
			self:SetPosition(pos)
		end
	end
end

--------------------------------------------------
AddClassPostConstruct("widgets/containerwidget", function(self)
	local OLD_Open = self.Open
	function self:Open(...)
		OLD_Open(self, ...)
		NEW_Open(self, ...)
	end

	local OLD_Close = self.Close
	function self:Close(...)
		NEW_Close(self, ...)
		OLD_Close(self, ...)
	end

	if GetModConfigData("SEARCHBAR", true) then
		AddSearchBarPreSet(self)
	end

	if true then --GetModConfigData("DRAGWHOLE") then
		MakeDraggable(self)
	end
end)

--------------------------------------------------
--inventory bar
--------------------------------------------------
--add page button for integrated backpack style
local function NEW_Rebuild(self)
	local overflow = self.owner.replica.inventory:GetOverflowContainer()
	overflow = (overflow ~= nil and overflow:IsOpenedBy(self.owner)) and overflow or nil

	if overflow	~= nil and self.integrated_backpack then
		local num = overflow:GetNumSlots()
		local offset = #self.inv - num
		local chestupgrade = overflow.inst.replica.chestupgrade
		if GetModConfigData("PACKSTYLE", true) and chestupgrade ~= nil and chestupgrade.chestlv.z > 1 then
			local x, y, z = chestupgrade:GetLv()
			local show = x * y
			local slottogo = num
			self.integrated_arrow:Kill()
			self.integrated_arrow = nil
			self.backpackpage = self.bottomrow:AddChild(ChestPage(self.backpackinv, show, slottogo, overflow.inst))
			--local mid = (self.equip[GLOBAL.EQUIPSLOTS.HANDS]:GetPosition().x + self.equip[GLOBAL.EQUIPSLOTS.BODY]:GetPosition().x) / 2
			--print(mid - self.inv[#self.inv]:GetPosition().x)
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
--inventorybar widget
AddClassPostConstruct("widgets/inventorybar", function(self)
	local OLD_Rebuild = self.Rebuild
	function self:Rebuild(...)
		OLD_Rebuild(self, ...)
		NEW_Rebuild(self)
	end

	--controller
	local old_GetInventoryLists = self.GetInventoryLists
	function self:GetInventoryLists(same_container_only, ...)
		local list = old_GetInventoryLists(self, same_container_only, ...)
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
end)