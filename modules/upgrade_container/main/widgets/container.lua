local Widget = require("widgets/widget")
local ImageButton = require("widgets/imagebutton")
local ChestPage = require("widgets/chestpage")
local DragContainer = require("widgets/dragcontainer")
local Text = require("widgets/text")
local ChestSearcher = require("widgets/searchchest")

local STRINGS = GLOBAL.STRINGS.UPGRADEABLECHEST
local SORTTEXT = STRINGS.SORTTEXT
local DROPALLTEXT = STRINGS.DROPALLTEXT
local DROPHOVER = STRINGS.DROPHOVER

local Vector3 = GLOBAL.Vector3
local TheInput = GLOBAL.TheInput

--------------------------------------------------
local function GetAlignPos(size, align, offset)
	--local drag = GetModConfigData("DRAGGABLE", true)
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
local function BGReScale(self, widget)
	if widget.bgscale ~= nil then
		self.bganim:SetScale(widget.bgscale)
		self.bgimage:SetScale(widget.bgscale)
	end
	if widget.bgshift ~= nil then
		self.bganim:SetPosition(widget.bgshift)
		self.bgimage:SetPosition(widget.bgshift)
	end
end

--------------------------------------------------
local function AddPageBtn(self, container)
	local lv_x, lv_y, lv_z = container.replica.chestupgrade:GetLv()
	local show = lv_x * lv_y

	if self.chestpage == nil then
		self.chestpage = self:AddChild(ChestPage(self.inv, show, #self.inv, container))
	end
	if container.replica.container:IsSideWidget() then
		local inv = self.inv
		local getmidptx = math.floor((inv[1]:GetPosition().x + inv[lv_x]:GetPosition().x) / 2)
		self.chestpage:SetPosition(getmidptx, 0, 0)
		self.chestpage:PageChange(0)
	else
		self.chestpage.defaultpos = GetAlignPos({lv_x, lv_y}, 0, 40)
		self.chestpage:SetPosition(self.chestpage.defaultpos)
		self.chestpage:PageChange(0)
		if GetModConfigData("SHOWALLPAGE", true) then
			self.chestpage.allpage = true
			self.chestpage:ShowAllPage()
		end
	end
end

--------------------------------------------------
--Show Guide
local function ShowGuide(self, container)
	local chestupgrade = container.replica.chestupgrade
	local lv_x, lv_y, lv_z = chestupgrade:GetLv()
	if (lv_x < TUNING.CHESTUPGRADE.MAX_LV and lv_y < TUNING.CHESTUPGRADE.MAX_LV) and AllUpgradeRecipes[container.prefab] then
		local slots = chestupgrade:CreateCheckTable()
		for k, v in pairs(slots) do
			if v then
				local image = type(v) == "table" and (v.GetImage ~= nil and v:GetImage() or v[1]..".tex") or v..".tex"
				self.inv[k]:SetBGImage2(GLOBAL.resolvefilepath(GLOBAL.GetInventoryItemAtlas(image)), image, {1, 1, 1, .4})
			end
		end
	end
end

--------------------------------------------------
--Don't Block Cooker
local function DontBlockCooker(self, container, doer)
	local widget = container.replica.container:GetWidget()
	local isonboat = doer:GetCurrentPlatform() ~= nil
	local isfreezer = GetModConfigData("UI_ICEBOX", true) and (container.prefab == "icebox" or container.prefab == "saltbox")
	if widget.pos ~= nil and (isonboat or isfreezer) then
		local rhs = Vector3(-140, 0, 0)
		self:SetPosition(widget.pos + rhs)
	end
end

--------------------------------------------------
--Draggable widget
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
		self.dragwidget:SetPosition(GetAlignPos(show, 2, 260))
		self.dragwidget.bgimg:SetScale(1, -3/4, 1)
		self.dragwidget.bgimg:SetPosition(0, -24, 0)
	else
		--self.dragwidget = self:AddChild(DragContainer("images/hud.xml", "craftingsubmenu_fullhorizontal.tex", scale, show, total))
		self.dragwidget:SetPosition(GetAlignPos(show, 1, 260))
		self.dragwidget.bgimg:SetScale(-1, 3/4, 1)
		self.dragwidget.bgimg:SetPosition(32, 0, 0)
	end
	self.dragwidget:Show()
	self.dragwidget:SetShowPos()
	self.dragwidget:ShowSection()

	local items = container.replica.container:GetItems()
	self.dragwidget:BuildItemList(items)

	self.dw_update = function(inst, data)
		self.dragwidget:UpdateItem(data)
	end
	self.inst:ListenForEvent("itemlose", self.dw_update, container)
	self.inst:ListenForEvent("itemget", self.dw_update, container)
end

--------------------------------------------------
--Search Bar
local function AddSearchBar(self, container, uipos)
	if self.searchbar == nil then
		self.searchbar = self:AddChild(ChestSearcher(container, uipos))
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

--Useless btn
local UselessBtn = Class(Widget, function(self, button, sorting, dropall)
	Widget._ctor(self, "ChestUpgrade_ULB")

	self.buttons = {}
	if button then
		button:GetParent():RemoveChild(button)
		self.button = self:AddChild(button)
		table.insert(self.buttons, button)
	end

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
		table.insert(self.buttons, self.sortitembtn)
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
		table.insert(self.buttons, self.dropallbtn)
	end

	local SEP = 80
	local POS = -(#self.buttons - 1) * SEP / 2 - SEP
	for i, btn in ipairs(self.buttons) do
		btn:SetPosition(POS + SEP * i, 0, 0)
	end
end)

--------------------------------------------------
local function NEW_Open(self, container, doer, ...)
	local chestupgrade = container.replica.chestupgrade
	if chestupgrade == nil then return end

	--change the bg scale
	local widget = container.replica.container:GetWidget()
	BGReScale(self, widget)

	--shows the pageable button
	local lv_x, lv_y, lv_z = chestupgrade:GetLv()
	if lv_z ~= nil and lv_z > 1 then
		AddPageBtn(self, container)
	end

	if container.replica.container:IsSideWidget() then return end		--no backpack is going to do the following

	--show upgrade requirment
	local showguide = GetModConfigData("SHOWGUIDE", true) or 0
	if GetModConfigData("UPG_MODE") ~= 2 and showguide ~= 0 then
		if showguide ~= 2 or container.replica.container:IsEmpty() then
			ShowGuide(self, container)
		end
	end

	--shift the widget leftward if you are on the boat, or the container is icebox or saltbox
	local uipos = GetModConfigData("UI_WIDGETPOS", true)
	if uipos then
		DontBlockCooker(self, container, doer)
	end

	if PositionRecord[container.type] then
		self:SetPosition(PositionRecord[container.type])
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
		self.chestupgrade_ulb = self:AddChild(UselessBtn(self.button, sorting, dropall))
		self.chestupgrade_ulb:SetPosition(GetAlignPos({lv_x, lv_y}, 3, 20))
	end
end

--------------------------------------------------
--Close
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
			self.inst:RemoveEventCallback("itemlose", self.dw_update, self.container)
			self.inst:RemoveEventCallback("itemget", self.dw_update, self.container)
			self.dw_update = nil
			self.dragwidget:Kill()
			self.dragwidget = nil
		end
		if self.chestpage ~= nil then
			self.chestpage:Kill()
			self.chestpage = nil
		end
		if self.chestupgrade_ulb ~= nil then
			self.chestupgrade_ulb:Kill()
			self.chestupgrade_ulb = nil
		end
		if self.searchbar ~= nil then
			self.searchbar:Kill()
			self.searchbar = nil
		end
	end
end

--------------------------------------------------
--Search Bar
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

local function OnControlBG(bg, ...)
	if bg.oldOnControl ~= nil then
		bg:oldOnControl(...)
	end
	OnDoubleClick(bg, ...)
end

local function AddSearchBarPreSet(self)
	local bg = self.bganim or self.bgimage
	if bg then
		if bg.oldOnControl == nil then
			bg.oldOnControl = bg.OnControl
		end
		bg.OnControl = OnControlBG
	end
end

--------------------------------------------------
--Quick Split
local function Highlight(slot, ...)
	local container_widget = slot:GetParent()
	local pressing = TheInput:IsControlPressed(GLOBAL.CONTROL_PUTSTACK)
			or (TheInput:IsControlPressed(GLOBAL.CONTROL_FORCE_STACK) and TheInput:IsControlPressed(GLOBAL.CONTROL_PRIMARY))

	if pressing then
		local active_item = GLOBAL.ThePlayer.replica.inventory:GetActiveItem() or nil
		local item = slot.container:GetItemInSlot(slot.num) or nil

		if active_item ~= nil and (item == nil or item.prefab == active_item.prefab) then
			slot:Click(true)
		end
	end
	return slot.oldHighlight and slot:oldHighlight(...)
end

local function MakeQuickSplit(inv)
	if inv ~= nil and #inv > 0 then
		for _, slot in pairs(inv) do
			slot.oldHighlight = slot.Highlight
			slot.Highlight = Highlight
		end
	end
end

--------------------------------------------------
local function vecdiv(vec, rhs)
	return Vector3(vec.x / rhs.x, vec.y / rhs.y, vec.z / rhs.z)
end

--Draggable
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
				local container = self.container
				if container ~= nil and PositionRecord[container.prefab] ~= nil then
					PositionRecord[container.prefab] = nil
					local widget = container.replica.container:GetWidget()
					if widget ~= nil and widget.pos ~= nil then
						self:SetPosition(widget.pos)
					end
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
			local offset = self:GetLocalPosition() - vecdiv(TheInput:GetScreenPosition(), scale_factor)
			self.followhandler = TheInput:AddMoveHandler(function(...)
				local pos = vecdiv(Vector3(...), scale_factor) + offset
				self:UpdatePosition(pos)
			end)
			local pos = vecdiv(TheInput:GetScreenPosition(), scale_factor) + offset
			self:SetPosition(pos)
		end
	end
end

--------------------------------------------------
--OnItemChange
local function NEW_OnItemGet(self, data)
	local chestupgrade = self.container ~= nil and self.container.replica.chestupgrade or nil

	if chestupgrade == nil then return end

	if self.searchbar ~= nil then
		self.searchbar:OnItemGet(data)
	end
	if self.dragwidget ~= nil then
		self.dragwidget:UpdateItem(data)
	end
	if GetModConfigData("SHOWGUIDE", true) == 2 then
		if self.iscontainerempty and self.inv ~= nil then
			self.iscontainerempty = false
			for _, v in pairs(self.inv) do
				if v.bgimage2 ~= nil then
					v:SetBGImage2()
				end
			end
		end
	end
end

local function NEW_OnItemLose(self, data)
	local inst = self.container
	local chestupgrade = inst ~= nil and inst.replica.chestupgrade or nil

	if chestupgrade == nil then return end

	if self.searchbar ~= nil then
		self.searchbar:OnItemLose(data)
	end
	if self.dragwidget ~= nil then
		self.dragwidget:UpdateItem(data)
	end
	if GetModConfigData("SHOWGUIDE", true) == 2 then
		local container = inst.replica.container
		if container ~= nil and not container:IsSideWidget() and container:IsEmpty() then
			self.iscontainerempty = true
			ShowGuide(self, inst)
		end
	end
end

AddClassPostConstruct("widgets/containerwidget", function(self)
	local OLD_Open = self.Open
	function self:Open(...)
		OLD_Open(self, ...)
		MakeQuickSplit(self.inv)
		NEW_Open(self, ...)
	end

	local OLD_Close = self.Close
	function self:Close(...)
		NEW_Close(self, ...)
		OLD_Close(self, ...)
	end

	local OLD_OnItemGet = self.OnItemGet
	function self:OnItemGet(...)
		NEW_OnItemGet(self, ...)
		OLD_OnItemGet(self, ...)
	end

	local OLD_OnItemLose = self.OnItemLose
	function self:OnItemLose(...)
		NEW_OnItemLose(self, ...)
		OLD_OnItemLose(self, ...)
	end

	if GetModConfigData("SEARCHBAR", true) then
		AddSearchBarPreSet(self)
	end

	if true then --GetModConfigData("DRAGWHOLE") then
		MakeDraggable(self)
	end
end)