---------------------------------------------------------------------------------------------------------
-----------------------------------------------新容器----------------------------------------------------
---------------------------------------------------------------------------------------------------------

--容器默认坐标
local default_pos_bigbag={
	--medal_box = Vector3(-140, -50, 0),--勋章盒2*6
	bigbag = Vector3(-180,-75,0),
	redbigbag = Vector3(-180,-75,0),
	bluebigbag = Vector3(-180,-75,0),
	nicebigbag = Vector3(-150, -120, 0),
}
--大背包
local params = {}
local gridsize = 66
local mis = 3.5*gridsize
if TUNING.ROOMCAR_BIGBAG_BAGSIZE == 4 then
	params.bigbag = {
		widget =
		{
			slotpos = {},
			animbank = "ui_krampusbag_2x8",
			animbuild = "ui_bigbag_3x8",
			--bgatlas = "images/bigbagbg.xml",
			--bgimage = "bigbagbg.tex",
			--side_align_tip = 160,
			pos = default_pos_bigbag.bigbag,
			dragtyp="bigbag",--拖拽标签，有则可拖拽
			-- buttoninfo =
			-- {
				-- text = STRINGS.bigbag_BUTTON,
				-- position = Vector3(-130, -320, 0),
				-- --fn = slotsSortFn_bigbag,
				-- --validfn = slotsSortValidFn_bigbag,
			-- }
		},
		issidewidget = true,
		type = "pack",
		openlimit = 1,
	}
	-- 格子设定	
	for y = 0, 7 do
		table.insert(params.bigbag.widget.slotpos, Vector3(-131 - 75, -75 * y + 264, 0)) 
		table.insert(params.bigbag.widget.slotpos, Vector3(-131, -75 * y + 264, 0))  
		table.insert(params.bigbag.widget.slotpos, Vector3(-131 + 75, -75 * y + 264, 0)) 
	end
elseif TUNING.ROOMCAR_BIGBAG_BAGSIZE == 1 then
	params.bigbag = {
		widget =
		{
			slotpos = {},
			animbank = "ui_krampusbag_2x8",
			animbuild = "ui_bigbag_4x8",
			--bgatlas = "images/bigbagbg.xml",
			--bgimage = "bigbagbg.tex",
			--side_align_tip = 160,
			pos = default_pos_bigbag.bigbag,
			dragtyp="bigbag",--拖拽标签，有则可拖拽
			-- buttoninfo =
			-- {
				-- text = STRINGS.bigbag_BUTTON,
				-- position = Vector3(-130, -320, 0),
				-- --fn = slotsSortFn_bigbag,
				-- --validfn = slotsSortValidFn_bigbag,
			-- }
		},
		issidewidget = true,
		type = "pack",
		openlimit = 1,
	}
	-- 格子设定	
	for y = 0, 7 do
		table.insert(params.bigbag.widget.slotpos, Vector3(-168 - 75, -75 * y + 266, 0)) 
		table.insert(params.bigbag.widget.slotpos, Vector3(-168, -75 * y + 266, 0))  
		table.insert(params.bigbag.widget.slotpos, Vector3(-168 + 75, -75 * y + 266, 0)) 
		table.insert(params.bigbag.widget.slotpos, Vector3(-168 + 150, -75 * y + 266, 0)) 
	end
-- elseif TUNING.ROOMCAR_BIGBAG_BAGSIZE == 2 then
	-- params.bigbag = {
		-- widget =
		-- {
			-- slotpos = {},
			-- animbank = "ui_krampusbag_2x8",
			-- animbuild = "bigbag_ui_8x6",
			-- --bgatlas = "images/bigbagbg_8x6.xml",
			-- --bgimage = "bigbagbg_8x6.tex",
			-- pos = default_pos_bigbag.bigbag,
			-- --side_align_tip = 160,
			-- dragtyp="bigbag",--拖拽标签，有则可拖拽
			-- buttoninfo =
			-- {
				-- text = STRINGS.bigbag_BUTTON,
				-- position = Vector3(-128, -290, 0),
				-- --fn = slotsSortFn_bigbag,
				-- --validfn = slotsSortValidFn_bigbag,
			-- }
		-- },
		-- issidewidget = true,
		-- type = "pack",
		-- openlimit = 1,
	-- }
	-- -- 格子设定	
	-- for n = 0, 7 do
		-- table.insert(params.bigbag.widget.slotpos, Vector3(-1*gridsize - mis+4, 462 - mis - n*gridsize, 0))
		-- table.insert(params.bigbag.widget.slotpos, Vector3(0*gridsize - mis+4, 462 - mis - n*gridsize, 0))  --(-3.5*66,7*66-3.5*66)
		-- table.insert(params.bigbag.widget.slotpos, Vector3(1*gridsize - mis+4, 462 - mis - n*gridsize, 0))
		-- table.insert(params.bigbag.widget.slotpos, Vector3(2*gridsize - mis+4, 462 - mis - n*gridsize, 0))
		-- table.insert(params.bigbag.widget.slotpos, Vector3(3*gridsize - mis+4, 462 - mis - n*gridsize, 0))
		-- table.insert(params.bigbag.widget.slotpos, Vector3(4*gridsize - mis+4, 462 - mis - n*gridsize, 0))
	-- end

-- elseif TUNING.ROOMCAR_BIGBAG_BAGSIZE == 3 then
	-- params.bigbag = {
		-- widget =
		-- {
			-- slotpos = {},
			-- animbank = "ui_krampusbag_2x8",
			-- animbuild = "bigbag_ui_8x8",
			-- --bgatlas = "images/bigbagbg_8x8.xml",
			-- --bgimage = "bigbagbg_8x8.tex",
			-- --side_align_tip = 160,
			-- pos = default_pos_bigbag.bigbag,
			-- dragtyp="bigbag",--拖拽标签，有则可拖拽
			-- buttoninfo =
			-- {
				-- text = STRINGS.bigbag_BUTTON,
				-- position = Vector3(-128,-290, 0),
				-- --fn = slotsSortFn_bigbag,
				-- --validfn = slotsSortValidFn_bigbag,
			-- }
		-- },
		-- issidewidget = true,
		-- type = "pack",
		-- openlimit = 1,
	-- }
	-- -- 格子设定	
	-- for n = 0, 7 do
		-- table.insert(params.bigbag.widget.slotpos, Vector3(-2*gridsize - mis+4, 462 - mis - n*gridsize, 0))
		-- table.insert(params.bigbag.widget.slotpos, Vector3(-1*gridsize - mis+4, 462 - mis - n*gridsize, 0))
		-- table.insert(params.bigbag.widget.slotpos, Vector3(0*gridsize - mis+4, 462 - mis - n*gridsize, 0))  --(-3.5*66,7*66-3.5*66)
		-- table.insert(params.bigbag.widget.slotpos, Vector3(1*gridsize - mis+4, 462 - mis - n*gridsize, 0))
		-- table.insert(params.bigbag.widget.slotpos, Vector3(2*gridsize - mis+4, 462 - mis - n*gridsize, 0))
		-- table.insert(params.bigbag.widget.slotpos, Vector3(3*gridsize - mis+4, 462 - mis - n*gridsize, 0))
		-- table.insert(params.bigbag.widget.slotpos, Vector3(4*gridsize - mis+4, 462 - mis - n*gridsize, 0))
		-- table.insert(params.bigbag.widget.slotpos, Vector3(5*gridsize - mis+4, 462 - mis - n*gridsize, 0))
	-- end
--end
elseif TUNING.ROOMCAR_BIGBAG_BAGSIZE == 2 then
	params.bigbag = {
		widget =
		{
			slotpos = {},
			animbank = nil,
			animbuild = nil,
			bgatlas = "images/bigbagbg_8x6.xml",
			bgimage = "bigbagbg_8x6.tex",
			pos = default_pos_bigbag.bigbag,
			dragtyp="bigbag",--拖拽标签，有则可拖拽
			-- buttoninfo =
			-- {
				-- text = STRINGS.bigbag_BUTTON,
				-- position = Vector3(0, 285, 0),
				-- --fn = slotsSortFn_bigbag,
				-- --validfn = slotsSortValidFn_bigbag,
			-- }
		},
		issidewidget = true,
		type = "pack",
		openlimit = 1,
	}
	-- 格子设定	
	for n = 0, 7 do
		table.insert(params.bigbag.widget.slotpos, Vector3(1*gridsize - mis, 462 - mis - n*gridsize, 0))
		table.insert(params.bigbag.widget.slotpos, Vector3(2*gridsize - mis, 462 - mis - n*gridsize, 0))  --(-3.5*66,7*66-3.5*66)
		table.insert(params.bigbag.widget.slotpos, Vector3(3*gridsize - mis, 462 - mis - n*gridsize, 0))
		table.insert(params.bigbag.widget.slotpos, Vector3(4*gridsize - mis, 462 - mis - n*gridsize, 0))
		table.insert(params.bigbag.widget.slotpos, Vector3(5*gridsize - mis, 462 - mis - n*gridsize, 0))
		table.insert(params.bigbag.widget.slotpos, Vector3(6*gridsize - mis, 462 - mis - n*gridsize, 0))
	end

elseif TUNING.ROOMCAR_BIGBAG_BAGSIZE == 3 then
	params.bigbag = {
		widget =
		{
			slotpos = {},
			animbank = nil,
			animbuild = nil,
			bgatlas = "images/bigbagbg_8x8.xml",
			bgimage = "bigbagbg_8x8.tex",
			pos = default_pos_bigbag.bigbag,
			dragtyp="bigbag",--拖拽标签，有则可拖拽
			-- buttoninfo =
			-- {
				-- text = STRINGS.bigbag_BUTTON,
				-- position = Vector3(0, 285, 0),
				-- --fn = slotsSortFn_bigbag,
				-- --validfn = slotsSortValidFn_bigbag,
			-- }
		},
		issidewidget = true,
		type = "pack",
		openlimit = 1,
	}
	-- 格子设定	
	for n = 0, 7 do
		table.insert(params.bigbag.widget.slotpos, Vector3(0*gridsize - mis, 462 - mis - n*gridsize, 0))
		table.insert(params.bigbag.widget.slotpos, Vector3(1*gridsize - mis, 462 - mis - n*gridsize, 0))
		table.insert(params.bigbag.widget.slotpos, Vector3(2*gridsize - mis, 462 - mis - n*gridsize, 0))  --(-3.5*66,7*66-3.5*66)
		table.insert(params.bigbag.widget.slotpos, Vector3(3*gridsize - mis, 462 - mis - n*gridsize, 0))
		table.insert(params.bigbag.widget.slotpos, Vector3(4*gridsize - mis, 462 - mis - n*gridsize, 0))
		table.insert(params.bigbag.widget.slotpos, Vector3(5*gridsize - mis, 462 - mis - n*gridsize, 0))
		table.insert(params.bigbag.widget.slotpos, Vector3(6*gridsize - mis, 462 - mis - n*gridsize, 0))
		table.insert(params.bigbag.widget.slotpos, Vector3(7*gridsize - mis, 462 - mis - n*gridsize, 0))
	end
end
-- function params.bigbag.widget.buttoninfo.fn(inst)
	-- if inst.components.container ~= nil then
		-- if inst.components.container and not inst.components.container:IsEmpty() then
			-- for i = 1, inst.components.container:GetNumSlots() do
				-- local item = inst.components.container.slots[i]
				-- if item and item.components.stackable and TUNING.ROOMCAR_BIGBAG_STACK then
					-- item.components.stackable:SetStackSize(item.components.stackable.maxsize)
				-- end
			-- end
		-- end
	-- elseif inst.replica.container ~= nil and not inst.replica.container:IsBusy() then
        -- SendRPCToServer(RPC.DoWidgetButtonAction, nil, inst, nil)
    -- end
-- end

-- function params.bigbag.widget.buttoninfo.validfn(inst)
    -- return inst.replica.container ~= nil and not inst.replica.container:IsEmpty()--容器不为空
-- end
---代码抄自能力勋章
---------------------------------------------容器整理功能-------------------------------------------------
---------------------------------------------------------------------------------------------------------
--按字母排序
local function cmp_bigbag(a,b)
   if a and b then
	   a = tostring(a.prefab)
	   b = tostring(b.prefab)
	   local patt = '^(.-)%s*(%d+)$'
	   local _,_,col1,num1 = a:find(patt)
	   local _,col2,num2 = b:find(patt)
	   if (col1 and col2) and col1 == col2 then
		  return tonumber(num1) < tonumber(num2)
	   end
	   return a < b
   end
end

--容器排序
local function slotsSort_bigbag(inst)
	if inst and inst.components.container then
		local keys=table.getkeys(inst.components.container.slots)
		if #keys>0 then
			table.sort(keys)
			for k,v in ipairs(keys) do
				if k~=v then
					local item=inst.components.container:RemoveItemBySlot(v)
					if item then
						inst.components.container:GiveItem(item,k)
					end
				end
			end
		end
		table.sort(inst.components.container.slots,cmp_bigbag)
		for k,v in ipairs(inst.components.container.slots) do
			local item=inst.components.container:RemoveItemBySlot(k)
			if item then
				inst.components.container:GiveItem(item)
			end
		end
	end
end
-- local function params.bigbag.widget.buttoninfo.fn(inst)
	-- if inst.components.container ~= nil then
		-- slotsSort_bigbag(inst)
	-- elseif inst.replica.container ~= nil and not inst.replica.container:IsBusy() then
		-- SendRPCToServer(RPC.DoWidgetButtonAction, nil, inst, nil)
	-- end
-- end
-- --整理按钮亮起规则
-- local function params.bigbag.widget.buttoninfo.validfn(inst)
	-- return inst.replica.container ~= nil and not inst.replica.container:IsEmpty()--容器不为空
-- end

-- function params.bigbag.widget.buttoninfo.fn(inst)
	-- if inst.components.container ~= nil then
		-- if inst.components.container and not inst.components.container:IsEmpty() then
			-- slotsSort_bigbag(inst)
		-- end
	-- elseif inst.replica.container ~= nil and not inst.replica.container:IsBusy() then
        -- SendRPCToServer(RPC.DoWidgetButtonAction, nil, inst, nil)
    -- end
-- end

-- function params.bigbag.widget.buttoninfo.validfn(inst)
    -- return inst.replica.container ~= nil and not inst.replica.container:IsEmpty()--容器不为空
-- end

-- 放入时检测设定
function params.bigbag.itemtestfn(container, item, slot)
		if item.prefab == "nicebigbag" then
			return false
		elseif item:HasTag("bigbag") then
			if TUNING.ROOMCAR_BIGBAG_BAGINBAG then
				return true
			else
				return false
			end
		else
			return true
		end
end

--------
if TUNING.NICE_BIGBAGSIZE == 1 then
	params.nicebigbag = {
		widget =
		{
			slotpos = {},
			animbank = "ui_krampusbag_2x8",
			animbuild = "ui_bigbag_3x8",
			--bgatlas = "images/bigbagbg.xml",
			--bgimage = "bigbagbg.tex",
			--side_align_tip = 160,
			pos = default_pos_bigbag.nicebigbag,
			dragtyp = "nicebigbag",--拖拽标签，有则可拖拽
			-- buttoninfo =
			-- {
				-- text = STRINGS.bigbag_BUTTON,
				-- position = Vector3(-130, -320, 0),
			-- }
		},
		issidewidget = true,
		type = "pack",
		openlimit = 1,
	}
	-- 格子设定	
	for y = 0, 7 do
		table.insert(params.nicebigbag.widget.slotpos, Vector3(-131 - 75, -75 * y + 264, 0)) 
		table.insert(params.nicebigbag.widget.slotpos, Vector3(-131, -75 * y + 264, 0))  
		table.insert(params.nicebigbag.widget.slotpos, Vector3(-131 + 75, -75 * y + 264, 0)) 
	end
elseif TUNING.NICE_BIGBAGSIZE == 2 then
	params.nicebigbag = {
		widget =
		{
			slotpos = {},
			animbank = "ui_krampusbag_2x8",
			animbuild = "ui_bigbag_4x8",
			--bgatlas = "images/bigbagbg.xml",
			--bgimage = "bigbagbg.tex",
			--side_align_tip = 160,
			pos = default_pos_bigbag.nicebigbag,
			dragtyp = "nicebigbag",--拖拽标签，有则可拖拽
			-- buttoninfo =
			-- {
				-- text = STRINGS.bigbag_BUTTON,
				-- position = Vector3(-130, -320, 0),
			-- }
		},
		issidewidget = true,
		type = "pack",
		openlimit = 1,
	}
	-- 格子设定	
	for y = 0, 7 do
		table.insert(params.nicebigbag.widget.slotpos, Vector3(-168 - 75, -75 * y + 266, 0)) 
		table.insert(params.nicebigbag.widget.slotpos, Vector3(-168, -75 * y + 266, 0))  
		table.insert(params.nicebigbag.widget.slotpos, Vector3(-168 + 75, -75 * y + 266, 0)) 
		table.insert(params.nicebigbag.widget.slotpos, Vector3(-168 + 150, -75 * y + 266, 0)) 
	end
	
end

-- function params.nicebigbag.widget.buttoninfo.fn(inst)
	-- if inst.components.container ~= nil then
		-- if inst.components.container and not inst.components.container:IsEmpty() then
			-- slotsSort_bigbag(inst)
		-- end
	-- elseif inst.replica.container ~= nil and not inst.replica.container:IsBusy() then
        -- SendRPCToServer(RPC.DoWidgetButtonAction, nil, inst, nil)
    -- end
-- end

-- function params.nicebigbag.widget.buttoninfo.validfn(inst)
    -- return inst.replica.container ~= nil and not inst.replica.container:IsEmpty()--容器不为空
-- end

-- 放入时检测设定
function params.nicebigbag.itemtestfn(container, item, slot)
	if item.prefab == "nicebigbag" then
		return false
	else
		return true
	end
end
------------------------------------
---------redbigbag------------------
------------------------------------
if TUNING.ROOMCAR_BIGBAG_BAGSIZE == 4 then
	params.redbigbag = {
		widget =
		{
			slotpos = {},
			animbank = "ui_krampusbag_2x8",
			animbuild = "ui_bigbag_3x8",
			pos = default_pos_bigbag.redbigbag,
			dragtyp="redbigbag",--拖拽标签，有则可拖拽
			-- buttoninfo =
			-- {
				-- text = STRINGS.bigbag_BUTTON,
				-- position = Vector3(-130, -320, 0),

			-- }
		},
		issidewidget = true,
		type = "pack",
		openlimit = 1,
	}
	-- 格子设定	
	for y = 0, 7 do
		table.insert(params.redbigbag.widget.slotpos, Vector3(-131 - 75, -75 * y + 264, 0)) 
		table.insert(params.redbigbag.widget.slotpos, Vector3(-131, -75 * y + 264, 0))  
		table.insert(params.redbigbag.widget.slotpos, Vector3(-131 + 75, -75 * y + 264, 0)) 
	end
elseif TUNING.ROOMCAR_BIGBAG_BAGSIZE == 1 then
	params.redbigbag = {
		widget =
		{
			slotpos = {},
			animbank = "ui_krampusbag_2x8",
			animbuild = "ui_bigbag_4x8",
			pos = default_pos_bigbag.redbigbag,
			dragtyp="redbigbag",--拖拽标签，有则可拖拽
			-- buttoninfo =
			-- {
				-- text = STRINGS.bigbag_BUTTON,
				-- position = Vector3(-130, -320, 0),
			-- }
		},
		issidewidget = true,
		type = "pack",
		openlimit = 1,
	}
	-- 格子设定	
	for y = 0, 7 do
		table.insert(params.redbigbag.widget.slotpos, Vector3(-168 - 75, -75 * y + 266, 0)) 
		table.insert(params.redbigbag.widget.slotpos, Vector3(-168, -75 * y + 266, 0))  
		table.insert(params.redbigbag.widget.slotpos, Vector3(-168 + 75, -75 * y + 266, 0)) 
		table.insert(params.redbigbag.widget.slotpos, Vector3(-168 + 150, -75 * y + 266, 0)) 
	end
elseif TUNING.ROOMCAR_BIGBAG_BAGSIZE == 2 then
	params.redbigbag = {
		widget =
		{
			slotpos = {},
			animbank = nil,
			animbuild = nil,
			bgatlas = "images/bigbagbg_8x6.xml",
			bgimage = "bigbagbg_8x6.tex",
			pos = default_pos_bigbag.redbigbag,
			dragtyp="redbigbag",--拖拽标签，有则可拖拽
			-- buttoninfo =
			-- {
				-- text = STRINGS.bigbag_BUTTON,
				-- position = Vector3(0, 285, 0),
			-- }
		},
		issidewidget = true,
		type = "pack",
		openlimit = 1,
	}
	-- 格子设定	
	for n = 0, 7 do
		table.insert(params.redbigbag.widget.slotpos, Vector3(1*gridsize - mis, 462 - mis - n*gridsize, 0))
		table.insert(params.redbigbag.widget.slotpos, Vector3(2*gridsize - mis, 462 - mis - n*gridsize, 0))  --(-3.5*66,7*66-3.5*66)
		table.insert(params.redbigbag.widget.slotpos, Vector3(3*gridsize - mis, 462 - mis - n*gridsize, 0))
		table.insert(params.redbigbag.widget.slotpos, Vector3(4*gridsize - mis, 462 - mis - n*gridsize, 0))
		table.insert(params.redbigbag.widget.slotpos, Vector3(5*gridsize - mis, 462 - mis - n*gridsize, 0))
		table.insert(params.redbigbag.widget.slotpos, Vector3(6*gridsize - mis, 462 - mis - n*gridsize, 0))
	end

elseif TUNING.ROOMCAR_BIGBAG_BAGSIZE == 3 then
	params.redbigbag = {
		widget =
		{
			slotpos = {},
			animbank = nil,
			animbuild = nil,
			bgatlas = "images/bigbagbg_8x8.xml",
			bgimage = "bigbagbg_8x8.tex",
			pos = default_pos_bigbag.redbigbag,
			dragtyp="redbigbag",--拖拽标签，有则可拖拽
			-- buttoninfo =
			-- {
				-- text = STRINGS.bigbag_BUTTON,
				-- position = Vector3(0, 285, 0),
			-- }
		},
		issidewidget = true,
		type = "pack",
		openlimit = 1,
	}
	-- 格子设定	
	for n = 0, 7 do
		table.insert(params.redbigbag.widget.slotpos, Vector3(0*gridsize - mis, 462 - mis - n*gridsize, 0))
		table.insert(params.redbigbag.widget.slotpos, Vector3(1*gridsize - mis, 462 - mis - n*gridsize, 0))
		table.insert(params.redbigbag.widget.slotpos, Vector3(2*gridsize - mis, 462 - mis - n*gridsize, 0))  --(-3.5*66,7*66-3.5*66)
		table.insert(params.redbigbag.widget.slotpos, Vector3(3*gridsize - mis, 462 - mis - n*gridsize, 0))
		table.insert(params.redbigbag.widget.slotpos, Vector3(4*gridsize - mis, 462 - mis - n*gridsize, 0))
		table.insert(params.redbigbag.widget.slotpos, Vector3(5*gridsize - mis, 462 - mis - n*gridsize, 0))
		table.insert(params.redbigbag.widget.slotpos, Vector3(6*gridsize - mis, 462 - mis - n*gridsize, 0))
		table.insert(params.redbigbag.widget.slotpos, Vector3(7*gridsize - mis, 462 - mis - n*gridsize, 0))
	end
end

-- function params.redbigbag.widget.buttoninfo.fn(inst)
	-- if inst.components.container ~= nil then
		-- if inst.components.container and not inst.components.container:IsEmpty() then
			-- slotsSort_bigbag(inst)
		-- end
	-- elseif inst.replica.container ~= nil and not inst.replica.container:IsBusy() then
        -- SendRPCToServer(RPC.DoWidgetButtonAction, nil, inst, nil)
    -- end
-- end

-- function params.redbigbag.widget.buttoninfo.validfn(inst)
    -- return inst.replica.container ~= nil and not inst.replica.container:IsEmpty()--容器不为空
-- end

-- 放入时检测设定
function params.redbigbag.itemtestfn(container, item, slot)
		if item.prefab == "nicebigbag" then
			return false
		elseif item:HasTag("bigbag") then
			if TUNING.ROOMCAR_BIGBAG_BAGINBAG then
				return true
			else
				return false
			end
		else
			return true
		end
end
------------------------------------
---------bluebigbag------------------
------------------------------------
if TUNING.ROOMCAR_BIGBAG_BAGSIZE == 4 then
	params.bluebigbag = {
		widget =
		{
			slotpos = {},
			animbank = "ui_krampusbag_2x8",
			animbuild = "ui_bigbag_3x8",
			pos = default_pos_bigbag.bluebigbag,
			dragtyp="bluebigbag",--拖拽标签，有则可拖拽
			-- buttoninfo =
			-- {
				-- text = STRINGS.bigbag_BUTTON,
				-- position = Vector3(-130, -320, 0),

			-- }
		},
		issidewidget = true,
		type = "pack",
		openlimit = 1,
	}
	-- 格子设定	
	for y = 0, 7 do
		table.insert(params.bluebigbag.widget.slotpos, Vector3(-131 - 75, -75 * y + 264, 0)) 
		table.insert(params.bluebigbag.widget.slotpos, Vector3(-131, -75 * y + 264, 0))  
		table.insert(params.bluebigbag.widget.slotpos, Vector3(-131 + 75, -75 * y + 264, 0)) 
	end
elseif TUNING.ROOMCAR_BIGBAG_BAGSIZE == 1 then
	params.bluebigbag = {
		widget =
		{
			slotpos = {},
			animbank = "ui_krampusbag_2x8",
			animbuild = "ui_bigbag_4x8",
			pos = default_pos_bigbag.bluebigbag,
			dragtyp="bluebigbag",--拖拽标签，有则可拖拽
			-- buttoninfo =
			-- {
				-- text = STRINGS.bigbag_BUTTON,
				-- position = Vector3(-130, -320, 0),
			-- }
		},
		issidewidget = true,
		type = "pack",
		openlimit = 1,
	}
	-- 格子设定	
	for y = 0, 7 do
		table.insert(params.bluebigbag.widget.slotpos, Vector3(-168 - 75, -75 * y + 266, 0)) 
		table.insert(params.bluebigbag.widget.slotpos, Vector3(-168, -75 * y + 266, 0))  
		table.insert(params.bluebigbag.widget.slotpos, Vector3(-168 + 75, -75 * y + 266, 0)) 
		table.insert(params.bluebigbag.widget.slotpos, Vector3(-168 + 150, -75 * y + 266, 0)) 
	end
elseif TUNING.ROOMCAR_BIGBAG_BAGSIZE == 2 then
	params.bluebigbag = {
		widget =
		{
			slotpos = {},
			animbank = nil,
			animbuild = nil,
			bgatlas = "images/bigbagbg_8x6.xml",
			bgimage = "bigbagbg_8x6.tex",
			pos = default_pos_bigbag.bluebigbag,
			dragtyp="bluebigbag",--拖拽标签，有则可拖拽
			-- buttoninfo =
			-- {
				-- text = STRINGS.bigbag_BUTTON,
				-- position = Vector3(0, 285, 0),
			-- }
		},
		issidewidget = true,
		type = "pack",
		openlimit = 1,
	}
	-- 格子设定	
	for n = 0, 7 do
		table.insert(params.bluebigbag.widget.slotpos, Vector3(1*gridsize - mis, 462 - mis - n*gridsize, 0))
		table.insert(params.bluebigbag.widget.slotpos, Vector3(2*gridsize - mis, 462 - mis - n*gridsize, 0))  --(-3.5*66,7*66-3.5*66)
		table.insert(params.bluebigbag.widget.slotpos, Vector3(3*gridsize - mis, 462 - mis - n*gridsize, 0))
		table.insert(params.bluebigbag.widget.slotpos, Vector3(4*gridsize - mis, 462 - mis - n*gridsize, 0))
		table.insert(params.bluebigbag.widget.slotpos, Vector3(5*gridsize - mis, 462 - mis - n*gridsize, 0))
		table.insert(params.bluebigbag.widget.slotpos, Vector3(6*gridsize - mis, 462 - mis - n*gridsize, 0))
	end

elseif TUNING.ROOMCAR_BIGBAG_BAGSIZE == 3 then
	params.bluebigbag = {
		widget =
		{
			slotpos = {},
			animbank = nil,
			animbuild = nil,
			bgatlas = "images/bigbagbg_8x8.xml",
			bgimage = "bigbagbg_8x8.tex",
			pos = default_pos_bigbag.bluebigbag,
			dragtyp="bluebigbag",--拖拽标签，有则可拖拽
			-- buttoninfo =
			-- {
				-- text = STRINGS.bigbag_BUTTON,
				-- position = Vector3(0, 285, 0),
			-- }
		},
		issidewidget = true,
		type = "pack",
		openlimit = 1,
	}
	-- 格子设定	
	for n = 0, 7 do
		table.insert(params.bluebigbag.widget.slotpos, Vector3(0*gridsize - mis, 462 - mis - n*gridsize, 0))
		table.insert(params.bluebigbag.widget.slotpos, Vector3(1*gridsize - mis, 462 - mis - n*gridsize, 0))
		table.insert(params.bluebigbag.widget.slotpos, Vector3(2*gridsize - mis, 462 - mis - n*gridsize, 0))  --(-3.5*66,7*66-3.5*66)
		table.insert(params.bluebigbag.widget.slotpos, Vector3(3*gridsize - mis, 462 - mis - n*gridsize, 0))
		table.insert(params.bluebigbag.widget.slotpos, Vector3(4*gridsize - mis, 462 - mis - n*gridsize, 0))
		table.insert(params.bluebigbag.widget.slotpos, Vector3(5*gridsize - mis, 462 - mis - n*gridsize, 0))
		table.insert(params.bluebigbag.widget.slotpos, Vector3(6*gridsize - mis, 462 - mis - n*gridsize, 0))
		table.insert(params.bluebigbag.widget.slotpos, Vector3(7*gridsize - mis, 462 - mis - n*gridsize, 0))
	end
end

-- function params.bluebigbag.widget.buttoninfo.fn(inst)
	-- if inst.components.container ~= nil then
		-- if inst.components.container and not inst.components.container:IsEmpty() then
			-- slotsSort_bigbag(inst)
		-- end
	-- elseif inst.replica.container ~= nil and not inst.replica.container:IsBusy() then
        -- SendRPCToServer(RPC.DoWidgetButtonAction, nil, inst, nil)
    -- end
-- end

-- function params.bluebigbag.widget.buttoninfo.validfn(inst)
    -- return inst.replica.container ~= nil and not inst.replica.container:IsEmpty()--容器不为空
-- end

-- 放入时检测设定
function params.bluebigbag.itemtestfn(container, item, slot)
		if item.prefab == "nicebigbag" then
			return false
		elseif item:HasTag("bigbag") then
			if TUNING.ROOMCAR_BIGBAG_BAGINBAG then
				return true
			else
				return false
			end
		else
			return true
		end
end


--加入容器
local containers = require("containers") 
local needdraglist={}--需要拖拽的容器列表
for k, v in pairs(params) do
    containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, v.widget.slotpos ~= nil and #v.widget.slotpos or 0)
	if v.widget.dragtyp then
		table.insert(needdraglist,v.widget.dragtyp)
	end
end


local oldwidgetsetup = containers.widgetsetup
function containers.widgetsetup(container, prefab, data, ...)
    local name = data or params[prefab or container.inst.prefab]
    if name ~= nil then
        for k, v in pairs(name) do
            container[k] = v
        end
        container:SetNumSlots(container.widget.slotpos ~= nil and #container.widget.slotpos or 0)
    else
        return oldwidgetsetup(container, prefab, data, ...)
    end
end


---------------------------------------------------------------------------------------------------------
----------------------------------------------容器拖拽---------------------------------------------------
---------------------------------------------------------------------------------------------------------
--获取拖拽坐标
local function GetDragTypePos_bigbag(dargtyp)
	local bigbagdargpos = nil
	if ThePlayer and ThePlayer.bigbag_drag_pos then
		bigbagdargpos=ThePlayer.bigbag_drag_pos:value()
	end
	if bigbagdargpos == nil then
		return
	end
	local i = string.find(bigbagdargpos,dargtyp,1,true)
	if i == nil then
		return
	end
	local allpos_bigbag = string.split(bigbagdargpos, ";")--所有坐标
	for _,v in ipairs(allpos_bigbag) do
		if string.find(v,dargtyp,1,true) then
			local posinfo_bigbag = string.split(v, ",")--坐标信息
			return Vector3(posinfo_bigbag[2], posinfo_bigbag[3], posinfo_bigbag[4])
		end
	end
	return 
end
--拖拽坐标，局部变量存储，减少主客交互
local dragpos_bigbag={}
--更新同步拖拽坐标
local function RefreshDragPos_bigbag()
	local bigbagdargpos = nil
	if ThePlayer and ThePlayer.bigbag_drag_pos then
		bigbagdargpos=ThePlayer.bigbag_drag_pos:value()
	end
	if bigbagdargpos and bigbagdargpos~="" then
		local allpos = string.split(bigbagdargpos, ";")--所有坐标
		for _,v in ipairs(allpos) do
			local posinfo_bigbag = string.split(v, ",")--坐标信息
			if posinfo_bigbag[1] and dragpos_bigbag[posinfo_bigbag[1]]==nil then
				dragpos_bigbag[posinfo_bigbag[1]]=Vector3(posinfo_bigbag[2], posinfo_bigbag[3], posinfo_bigbag[4])
			end
		end
	end
	-- if #needdraglist > 0 then
		-- for _,v in ipairs(needdraglist) do
			-- if dragpos_bigbag[v]==nil then
				-- dragpos_bigbag[v]=GetDragTypePos_bigbag(v)
			-- end
		-- end
	-- end
end
--记录拖拽坐标
local function SetDragTypePos_bigbag()
	RefreshDragPos_bigbag()
	local bigbag_drag_pos=""
	if next(dragpos_bigbag) then
		for k,v in pairs(dragpos_bigbag) do
			bigbag_drag_pos = bigbag_drag_pos..k..","..v.x..","..v.y..","..v.z..";"
		end
	end
	if bigbag_drag_pos~="" then
		bigbag_drag_pos= string.sub(bigbag_drag_pos,1,-2)
		SendModRPCToServer(MOD_RPC.bigbag.Bigbag_SetDragPos, bigbag_drag_pos)
		--SendModRPCToServer(MOD_RPC["Bigbag"]["Bigbag_SetDragPos"], bigbag_drag_pos)
	end
end

--设置UI可拖拽
local function MakebigbagDragableUI(self,dragtyp)
	--添加拖拽提示
	if TUNING.ROOMCAR_BIGBAG_CONTAINERDRAG_SWITCH and self.bgimage and (TUNING.ROOMCAR_BIGBAG_BAGSIZE == 2 or TUNING.ROOMCAR_BIGBAG_BAGSIZE == 3) then
		self.bgimage:SetTooltip(STRINGS.bigbag_UI.DRAGABLETIPS1..string.sub(TUNING.ROOMCAR_BIGBAG_CONTAINERDRAG_SWITCH,-2)..STRINGS.bigbag_UI.DRAGABLETIPS2)
	elseif TUNING.ROOMCAR_BIGBAG_CONTAINERDRAG_SWITCH and self.bganim and (TUNING.ROOMCAR_BIGBAG_BAGSIZE == 4 or TUNING.ROOMCAR_BIGBAG_BAGSIZE == 1) then
		self.bganim:SetTooltip(STRINGS.bigbag_UI.DRAGABLETIPS1..string.sub(TUNING.ROOMCAR_BIGBAG_CONTAINERDRAG_SWITCH,-2)..STRINGS.bigbag_UI.DRAGABLETIPS2)
	end
	if TUNING.ROOMCAR_BIGBAG_CONTAINERDRAG_SWITCH and self.bganim and (TUNING.NICE_BIGBAGSIZE ==1 or TUNING.NICE_BIGBAGSIZE ==2) then --
		self.bganim:SetTooltip(STRINGS.bigbag_UI.DRAGABLETIPS1..string.sub(TUNING.ROOMCAR_BIGBAG_CONTAINERDRAG_SWITCH,-2)..STRINGS.bigbag_UI.DRAGABLETIPS2)
	end
	--修改鼠标控制
	local oldOnControl_bigbag=self.OnControl
	self.OnControl = function (self,control_bigbag, down_bigbag)
		-- 按下热键可拖动
		if TheInput:IsKeyDown(GLOBAL[TUNING.ROOMCAR_BIGBAG_CONTAINERDRAG_SWITCH or "KEY_F1"]) then 
			self:Passive_OnControl_bigbag(control_bigbag, down_bigbag)
		-- elseif oldOnControl_bigbag~=nil then
			-- oldOnControl_bigbag(self,control_bigbag,down_bigbag)
		end
		return oldOnControl_bigbag(self,control_bigbag,down_bigbag)
	end
	
	self:MoveToBack()
	--被控制(控制状态，是否按下)
	function self:Passive_OnControl_bigbag(control_bigbag, down_bigbag)
		if control_bigbag == CONTROL_ACCEPT then
			if down_bigbag then
				self:StartDrag_bigbag()
			else
				self:EndDrag_bigbag()
			end
		end
	end
	--设置拖拽坐标
	function self:SetDragPosition_bigbag(x, y, z)
		local pos_bigbag
		if type(x) == "number" then
			pos_bigbag = Vector3(x, y, z)
		else
			pos_bigbag = x
		end
		self:SetPosition(pos_bigbag + self.dragPosDiff)
		if dragtyp then
			dragpos_bigbag[dragtyp]=pos_bigbag + self.dragPosDiff--记录记录拖拽后坐标
			-- SetDragTypePos()--保存坐标
		end
	end
	
	--开始拖动
	function self:StartDrag_bigbag()
		if not self.followhandler then
			local mousepos_bigbag = TheInput:GetScreenPosition()
			self.dragPosDiff = self:GetPosition() - mousepos_bigbag
			self.followhandler = TheInput:AddMoveHandler(function(x,y)
				self:SetDragPosition_bigbag(x,y,0)
				--松开按键停止拖拽
				if not TheInput:IsKeyDown(GLOBAL[TUNING.ROOMCAR_BIGBAG_CONTAINERDRAG_SWITCH or "KEY_F1"]) then 
					self:EndDrag_bigbag()
				end 
			end)
			self:SetDragPosition_bigbag(mousepos_bigbag)
		end
	end
	--停止拖动
	function self:EndDrag_bigbag()
		if self.followhandler then
			self.followhandler:Remove()
		end
		self.followhandler = nil
		self.dragPosDiff = nil
		self:MoveToBack()
		SetDragTypePos_bigbag()--保存坐标
	end

	function self:Scale_DoDelta(delta)
		self.scale = math.max(self.scale+delta,0.1)
		self:SetScale(self.scale,self.scale,self.scale)
		self:MoveToBack()
	end
end

GLOBAL.MakebigbagDragableUI=MakebigbagDragableUI

--给容器添加拖拽功能
local function newcontainerwidget_bigbag(self)
	local oldOpen_bigbag = self.Open
	self.Open = function(self,...)
		oldOpen_bigbag(self,...)
		if self.container and self.container.replica.container then
			local widget = self.container.replica.container:GetWidget()
			-- if widget and widget.dragtyp~=nil then 
				-- -- self:SetPosition(default_pos[widget.dragtyp])
				-- --设置容器坐标
				-- if dragpos_bigbag[widget.dragtyp]==nil then
					-- dragpos_bigbag[widget.dragtyp]=GetDragTypePos_bigbag(widget.dragtyp)
				-- end
				-- self:SetPosition(dragpos_bigbag[widget.dragtyp] or default_pos_bigbag[widget.dragtyp])
				-- --设置可拖拽
				-- MakebigbagDragableUI(self,widget.dragtyp)
			-- end
			if widget and widget.dragtyp~=nil then 
			--设置容器坐标(可装备的容器第一次打开做个延迟，不然加载游戏进来位置读不到)
				if self.container:HasTag("_equippable") and not self.container.isopended then
					self.container:DoTaskInTime(0, function()
					if dragpos_bigbag[widget.dragtyp]==nil then
						dragpos_bigbag[widget.dragtyp]=GetDragTypePos_bigbag(widget.dragtyp)
					end
					self:SetPosition(dragpos_bigbag[widget.dragtyp] or default_pos_bigbag[widget.dragtyp])
					end)
					self.container.isopended=true
				else
					if dragpos_bigbag[widget.dragtyp]==nil then
						dragpos_bigbag[widget.dragtyp]=GetDragTypePos_bigbag(widget.dragtyp)
					end
					self:SetPosition(dragpos_bigbag[widget.dragtyp] or default_pos_bigbag[widget.dragtyp])
				end
				--设置可拖拽
				MakebigbagDragableUI(self,widget.dragtyp)
			end
		end
	end
end
if TUNING.ROOMCAR_BIGBAG_CONTAINERDRAG_SWITCH then
	AddClassPostConstruct("widgets/containerwidget", newcontainerwidget_bigbag)
end

--重置拖拽坐标
function ResetBigbagUIPos()
	dragpos_bigbag={}
	SendModRPCToServer(MOD_RPC.bigbag.Bigbag_SetDragPos, "")
end
GLOBAL.ResetBigbagUIPos=ResetBigbagUIPos