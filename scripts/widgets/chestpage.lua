local Widget = require("widgets/widget")
local Image = require("widgets/image")
local ImageButton = require("widgets/imagebutton")
local Text = require("widgets/text")
local TextEdit = require("widgets/textedit")

local defaultatlas = {
	atlas 		= "images/hud.xml",
	normal 		= "craft_end_normal.tex",
	focus 		= "craft_end_normal_mouseover.tex",
	disabled 	= "craft_end_normal_disabled.tex",
	down 		= nil,
	selected 	= nil,
}

local HORIZONTAL = 3

local oneditpage = function(self, control, down)
	if not self:IsEnabled() then return end
	if self.editing and self.prediction_widget ~= nil and self.prediction_widget:OnControl(control, down) then
		return true
	end

	if self.ignore_controls[control] then
		return false
	end

	if TextEdit._base.OnControl(self, control, down) then return true end

	--gobble up extra controls
	if self.editing and (control ~= CONTROL_CANCEL and control ~= CONTROL_OPEN_DEBUG_CONSOLE and control ~= CONTROL_ACCEPT) then
		return not self.pass_controls_to_screen[control]
	end

	if self.editing and not down and control == CONTROL_CANCEL then
		self:SetEditing(false)
		TheInput:EnableDebugToggle(true)
		return not self.pass_controls_to_screen[control]
	end

	if self.enable_accept_control and control == CONTROL_ACCEPT then
		if not down then
			if not self.editing then
				self:SetEditing(true)
				return not self.pass_controls_to_screen[control]
			else
				-- Previously this was being done only in the OnRawKey, but that doesnt handle controllers very well, this does.
				self:OnProcess()
				return not self.pass_controls_to_screen[control]
			end
		end
		return true
	end

	return false
end

local ChestPage = Class(Widget, function(self, inv, show, total, container)
	Widget._ctor(self, "ChestPage")

	self.container = container

	self.pagebg = self:AddChild(Image("images/hud.xml", "craft_slot.tex"))
	self.pagebg:SetScale(.8)

	self.pgupbtn = self:AddChild(ImageButton("images/hud.xml", "craft_end_normal.tex", "craft_end_normal_mouseover.tex"))
	self.pgupbtn:SetScale(-.7)
	self.pgupbtn:SetOnClick(function()
		self:PageChange(-1)
	end)

	self.pgdnbtn = self:AddChild(ImageButton("images/hud.xml", "craft_end_normal.tex", "craft_end_normal_mouseover.tex"))
	self.pgdnbtn:SetScale(.7)
	self.pgdnbtn:SetOnClick(function()
		self:PageChange(1)
	end)

	self.currentpage = 1
	self.inv = inv
	self.show = show
	self.total = total
	self.allpage = false
	--self.defaultpos = nil

	self.pagenum = self:AddChild(TextEdit(TALKINGFONT, 35, string.format("%2d", self.currentpage), UICOLOURS.SILVER))
	self.pagenum:SetPosition(0, -3, 0)
	self.pagenum:SetForceEdit(true)
	self.pagenum:SetCharacterFilter("1234567890")
	self.pagenum:SetTextLengthLimit(2)
	self.pagenum:SetEditTextColour(UICOLOURS.SILVER)
	self.pagenum:SetIdleTextColour(UICOLOURS.SILVER)
	function self.pagenum.OnTextEntered(string)
		self:SetPage(tonumber(string) or self.currentpage)
	end
	self.pagenum.OnControl = oneditpage

	self:ReBuild()

	self:SetBtnHlt()
end)

function ChestPage:OnControl(control, down, force)
	if ChestPage._base.OnControl(self, control, down) then return true end

	if down and ((self.focus and self:IsVisible()) or force) then
		if control == CONTROL_SCROLLBACK then
			self:PageChange(-1)
			return true
		elseif control == CONTROL_SCROLLFWD then
			self:PageChange(1)
			return true
		end
	end
end

local function SetJumpWidgetPos(widget, page_numslots, currentpage, allslots)
	local last_slot = page_numslots * currentpage
	local first_slot = last_slot - page_numslots + 1

	local first_pos = allslots[first_slot]
	local last_pos = allslots[last_slot]

	local pos = (first_pos + last_pos) / 2
	widget:SetPosition(pos)

	return pos
end

function ChestPage:ShowAllPage()
	self.pgupbtn:Hide()
	self.pgdnbtn:Hide()

	local parent = self:GetParent()
	self.parentpos = parent:GetPosition()

	local maxpage = math.ceil(self.total / self.show)
	local lv_x, lv_y, lv_z = self.container.replica.chestupgrade:GetLv()
	local zx, zy = math.min(lv_z, HORIZONTAL), math.ceil(lv_z / HORIZONTAL)

	local page_numslots = lv_x * lv_y
	local slotpos_ref = self.container.replica.container.widget.slotpos
	local slot = 1
	local SEP = {
		(80 * lv_x + 40),
		(80 * lv_y + 40)
	}
	for page_y = zy , 1, -1 do
		for page_x = 1, zx do
			if slot > self.container.replica.container:GetNumSlots() then
				break
			end
			local offset = {
				(page_x - (zx + 1) / 2),
				(page_y - (zy + 1) / 2)
			}
			for i = 1, page_numslots do
				local pos = slotpos_ref[slot] + Vector3(offset[1] * SEP[1], offset[2] * SEP[2], 0)
				self.inv[slot]:SetPosition(pos)
				self.inv[slot]:Show()
				slot = slot + 1
			end
		end
	end

	if zy == 1 then
		local position_x = self.inv[#self.inv]:GetPositionXYZ() + 70
		self:SetPosition(position_x, 0, 0)
		local pos = Vector3(0, 80 + 30 * lv_y, 0)
		parent:SetPosition(pos)
	else
		local inv = lv_x * lv_y * HORIZONTAL
		local position_x = self.inv[inv]:GetPositionXYZ() + 70
		self:SetPosition(position_x, 0, 0)
		parent:SetPosition(0, 0, 0)
	end
	--[[
        self.jumpwidget = self:AddChild(Image("images/plantregistry.xml", "oversizedpicturefilter.tex"))
        self.jumpwidget:SetScale(lv_x / 3, lv_y / 3, 1)
        SetJumpWidgetPos(self.jumpwidget, page_numslots, self.currentpage, self.inv)

        local parent_onclick = parent.onclick
        self.jumpwidget.parent_onclick = parent_onclick
        parent.onclick = function()
            local page = 1
            self:SetPage(page)
            self:ShowOnePage()
            parent.onclick = self.jumpwidget.parent_onclick
        end
    ]]
	local blv = self.container.replica.chestupgrade.baselv
	local xoffset, yoffset = (zx - 1) * blv.x / 20, (zy - 1) * blv.y / 12

	if parent.bganim then
		parent.bganim:SetScale(zx * lv_x / blv.x + xoffset, zy * lv_y / blv.y + yoffset, 1)
	elseif parent.bgimage then
		parent.bgimage:SetScale(zx * lv_x / blv.x + xoffset, zy * lv_y / blv.y + yoffset, 1)
	end

	self.allpage = true

	if parent.dragwidget then
		parent.dragwidget:Hide()
	end

	self.inst:DoTaskInTime(0, function(inst)
		if parent.chestupgrade_ulb then
			local pos_x, pos_y, pos_z = self.inv[#self.inv]:GetPositionXYZ()
			parent.chestupgrade_ulb:SetPosition(0, pos_y - 60, 0)
		end
	end)
end

function ChestPage:ShowOnePage()
	self.pgupbtn:Show()
	self.pgdnbtn:Show()
	local parent = self:GetParent()
	if self.parentpos ~= nil then
		parent:SetPosition(self.parentpos)
	end
	if self.defaultpos ~= nil then
		self:SetPosition(self.defaultpos)
	end
	local lv_x, lv_y, lv_z = self.container.replica.chestupgrade:GetLv()
	local widget = self.container.replica.container.widget
	local slotpos_ref = widget.slotpos
	for slot = 1, #slotpos_ref do
		local pos = slotpos_ref[slot]
		self.inv[slot]:SetPosition(pos)
	end
	self:PageChange(0)
	local lv_x, lv_y, lv_z = self.container.replica.chestupgrade:GetLv()
	local blv = self.container.replica.chestupgrade.baselv
	if parent.bganim ~= nil then
		parent.bganim:SetScale(widget.bgscale)
	elseif parent.bgimage ~= nil then
		parent.bganim:SetScale(widget.bgscale)
	end
	self.allpage = false
	if parent.dragwidget then
		parent.dragwidget:Show()
	end
end

function ChestPage:ReBuild(integrated)
	if integrated then
		self.integrated = true

		self.pagebg:Hide()

		self.pagenum:SetPosition(0, -3, 0)

		self.pgupbtn:SetTextures("images/hud.xml", "turnarrow_icon.tex", "turnarrow_icon_over.tex")
		self.pgupbtn:SetScale(-1)
		self.pgupbtn:SetPosition(-60, 0, 0)

		self.pgdnbtn:SetTextures("images/hud.xml", "turnarrow_icon.tex", "turnarrow_icon_over.tex")
		self.pgdnbtn:SetScale(1)
		self.pgdnbtn:SetPosition(60, 0, 0)

	elseif self.container ~= nil and self.container.replica.container:IsSideWidget() then
		local x = self.inv[1]:GetPosition().x
		local y_first = self.inv[1]:GetPosition().y
		local y_last = self.inv[self.show]:GetPosition().y
		local y_top = math.max(y_first, y_last)
		local y_bot = math.min(y_first, y_last)

		local pos_pagenum = Vector3(x - 60, (y_first + y_last)/2, 0)
		self.pagenum:SetPosition(pos_pagenum)

		self.pagebg:SetPosition(pos_pagenum)
		self.pagebg:SetRotation(90)

		self.pgupbtn:SetPosition(0, y_top + 75, 0)
		self.pgdnbtn:SetPosition(0, y_bot - 75, 0)

	else
		self.pgupbtn:SetPosition(0, 60, 0)
		self.pgdnbtn:SetPosition(0, -60, 0)
	end
end

local function Highlight(btn, dehighlight)
	return function()
		if not dehighlight then
			btn.image:SetTexture(btn.atlas, btn.image_focus)
		else
			btn.image:SetTexture(btn.atlas, btn.image_normal)
		end
	end
end

local function Click(btn)
	return function()
		btn.onclick()
		TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
	end
end

local function SetHlt(btn)
	btn.Highlight 	= Highlight(btn, false)
	btn.DeHighlight = Highlight(btn, true)
	btn.Click		= Click(btn)
	btn.hide_cursor = true
	btn.notslot		= true
end

function ChestPage:SetBtnHlt()
	SetHlt(self.pgupbtn)
	SetHlt(self.pgdnbtn)
	if self.pagebg ~= nil then
		SetHlt(self.pagebg)
	end
end

function ChestPage:PageChange(delta)
	local parent = self:GetParent()
	if parent.searchbar ~= nil and #parent.searchbar.selected ~= 0 then
		return
	end
	local maxpage = math.ceil(self.total / self.show)
	self.currentpage = math.clamp(self.currentpage + delta, 1, maxpage)
	for i = 1, self.total do
		self.inv[i]:Hide()
		--self.inv[i]:MoveToBack()
	end
	if parent.dragwidget then
		parent.dragwidget:Refresh()
		parent.dragwidget:ShowSection()
	else
		local start = math.min((self.currentpage - 1) * self.show + 1, self.total)
		local final = math.min(self.currentpage * self.show, self.total)
		for i = start, final do
			self.inv[i]:Show()
			--self.inv[i]:MoveToFront()
		end
	end
	if self.pagenum then
		self.pagenum:SetString(string.format("%2d", self.currentpage))
	end
end

function ChestPage:SetPage(page)
	self.currentpage = page
	self:PageChange(0)
end

return ChestPage