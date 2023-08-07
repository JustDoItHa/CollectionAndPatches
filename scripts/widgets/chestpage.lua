local Widget = require("widgets/widget")
local Image = require("widgets/image")
local ImageButton = require("widgets/imagebutton")
local Text = require("widgets/text")

local defaultatlas = {
	atlas 		= "images/hud.xml",
	normal 		= "craft_end_normal.tex",
	focus 		= "craft_end_normal_mouseover.tex",
	disabled 	= "craft_end_normal_disabled.tex",
	down 		= nil,
	selected 	= nil,
}

local HORIZONTAL = 3

local ChestPage = Class(Widget, function(self, inv, show, total, container)
    Widget._ctor(self, "ChestPage")

	self.container = container

	self.pagebg = self:AddChild(ImageButton("images/hud.xml", "craft_slot.tex"))
	self.pagebg:SetScale(.8)
	self.pagebg.scale_on_focus = false
	self.pagebg.move_on_click = false
	self.pagebg:SetOnClick(function()
		SendModRPCToServer(GetModRPC("RPC_UPGCHEST", "fillcontent"), self.container)
		--[[
		if self.allpage then
			self:ShowOnePage()
		else
			self:ShowAllPage()
		end
		]]
	end)

	self.pgupbtn = self:AddChild(ImageButton())
	self.pgupbtn:SetOnClick(function()
		self:PageChange(-1)
	end)

	self.pgdnbtn = self:AddChild(ImageButton())
	self.pgdnbtn:SetOnClick(function()
		self:PageChange(1)
	end)

	self.currentpage = 1
	self.inv = inv
	self.show = show
	self.total = total
	self.allpage = false
	--self.defaultpos = nil

	self.pagenum = self:AddChild(Text(TALKINGFONT, 35, string.format("%2d", self.currentpage), UICOLOURS.SILVER))
	self.pagenum:SetPosition(0, -3, 0)

	self:ReBuild()

	self:SetBtnHlt()
end)

-- c_select().components.chestupgrade:SetChestLv(3,3,3)
-- local X_SEP = 80
-- local Y_SEP = 80
-- local Z_SEP = 40
function ChestPage:ShowAllPage()
	self.pgupbtn:Hide()
	self.pgdnbtn:Hide()
	local maxpage = math.ceil(self.total / self.show)
	local lv_x, lv_y, lv_z = self.container.replica.chestupgrade:GetLv()
	local zx, zy = math.min(lv_z, HORIZONTAL), math.ceil(lv_z / HORIZONTAL)
	self.parentpos = self:GetParent():GetPosition()
	for zz = zy, 1, -1 do
		for z = 1, zx do
			for y = lv_y, 1, -1 do
				for x = 1, lv_x do
					local slot = (zy * zx - zz * zx + z - 1) * self.show + (lv_y - y) * lv_x + x
					if slot > #self.inv then break end
					local ZX_SEP = (2 * z - zx - 1) * (40 * lv_x + 20)
					local ZY_SEP = (2 * zz - zy - 1) * (40 * lv_y + 20)
					local pos = Vector3(80 * x - 40 * lv_x - 40 + ZX_SEP, 80 * y - 40 * lv_y - 40 + ZY_SEP, 0)
					self.inv[slot]:SetPosition(pos)
					self.inv[slot]:Show()
				end
			end
		end
	end
	if zy == 1 then
		local position_x = self.inv[#self.inv]:GetPositionXYZ() + 70
		self:SetPosition(position_x, 0, 0)
		local pos = Vector3(0, 80 + 30 * lv_y, 0)
		self:GetParent():SetPosition(pos)
	else
		local inv = lv_x * lv_y * HORIZONTAL
		local position_x = self.inv[inv]:GetPositionXYZ() + 70
		self:SetPosition(position_x, 0, 0)
		self:GetParent():SetPosition(0, 0, 0)
	end
	local blv = self.container.replica.chestupgrade.baselv
	local xoffset, yoffset = (zx - 1) * blv.x / 20, (zy - 1) * blv.y / 12
	self:GetParent().bganim:SetScale(zx * lv_x / blv.x + xoffset, zy * lv_y / blv.y + yoffset, 1)
	self.allpage = true
	if self:GetParent().dragwidget then
		self:GetParent().dragwidget:Hide()
	end
end

function ChestPage:ShowOnePage()
	self.pgupbtn:Show()
	self.pgdnbtn:Show()
	if self.parentpos ~= nil then
		self:GetParent():SetPosition(self.parentpos)
	end
	if self.defaultpos ~= nil then
		self:SetPosition(self.defaultpos)
	end
	local lv_x, lv_y, lv_z = self.container.replica.chestupgrade:GetLv()
	local slot = 0
	for z = 1, lv_z do
		for y = lv_y, 1, -1 do
			for x = 1, lv_x do
				slot = slot + 1
				local pos = Vector3(80 * x - 40 * lv_x - 40, 80 * y - 40 * lv_y - 40, 0)
				self.inv[slot]:SetPosition(pos)
			end
		end
	end
	self:PageChange(0)
	local lv_x, lv_y, lv_z = self.container.replica.chestupgrade:GetLv()
	local blv = self.container.replica.chestupgrade.baselv
	self:GetParent().bganim:SetScale(lv_x / blv.x, lv_y / blv.y, 1)
	self.allpage = false
	if self:GetParent().dragwidget then
		self:GetParent().dragwidget:Show()
	end
end

function ChestPage:ReBuild(integrated)
	if integrated then
		self.integrated = true

		if self.pagebg then
			self.pagebg:Kill()
			self.pagebg = nil
		end

		self.pgupbtn:SetTextures("images/hud.xml", "turnarrow_icon.tex", "turnarrow_icon_over.tex")
		self.pgupbtn:SetScale(-1)
		self.pgupbtn:SetPosition(-60, 0, 0)

		self.pgdnbtn:SetTextures("images/hud.xml", "turnarrow_icon.tex", "turnarrow_icon_over.tex")
		self.pgdnbtn:SetScale(1)
		self.pgdnbtn:SetPosition(60, 0, 0)

		if not self.pagenum then
			self.pagenum = self:AddChild(Text(TALKINGFONT, 35, string.format("%2d", self.currentpage), UICOLOURS.SILVER))
			self.pagenum:SetPosition(0, -3, 0)
		end

	elseif self.container ~= nil and self.container.replica.container:IsSideWidget() then
		if self.pagebg then
			self.pagebg:Kill()
			self.pagebg = nil
		end

		local y_top = self.inv[1]:GetPosition().y
		self.pgupbtn:SetTextures("images/hud.xml", "craft_end_normal.tex", "craft_end_normal_mouseover.tex")
		self.pgupbtn:SetScale(-.7)
		self.pgupbtn:SetPosition(0, y_top + 75, 0)

		local y_bot = self.inv[self.show]:GetPosition().y
		self.pgdnbtn:SetTextures("images/hud.xml", "craft_end_normal.tex", "craft_end_normal_mouseover.tex")
		self.pgdnbtn:SetScale(.7)
		self.pgdnbtn:SetPosition(0, y_bot - 75, 0)

		if self.pagenum then
			self.pagenum:Kill()
			self.pagenum = nil
		end

	else
		if not self.pagebg then
			self.pagebg = self:AddChild(ImageButton("images/hud.xml", "craft_slot.tex"))
			self.pagebg:SetScale(.8)
			self.pagebg.scale_on_focus = false
			self.pagebg.move_on_click = false
			self.pagebg:SetOnClick(function()
				SendModRPCToServer(GetModRPC("RPC_UPGCHEST", "sortcontent"), self.container)
			end)
		end

		self.pgupbtn:SetTextures("images/hud.xml", "craft_end_normal.tex", "craft_end_normal_mouseover.tex")
		self.pgupbtn:SetScale(-.7)
		self.pgupbtn:SetPosition(0, 60, 0)

		self.pgdnbtn:SetTextures("images/hud.xml", "craft_end_normal.tex", "craft_end_normal_mouseover.tex")
		self.pgdnbtn:SetScale(.7)
		self.pgdnbtn:SetPosition(0, -60, 0)

		if not self.pagenum then
			self.pagenum = self:AddChild(Text(TALKINGFONT, 35, string.format("%2d", self.currentpage), UICOLOURS.SILVER))
			self.pagenum:SetPosition(0, -3, 0)
		end
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