

local params = {}

local function vaild_check_button_icefurnace(inst)
	return inst.replica.container ~= nil
end

	--3x1

params.icefurnace_container_3x1 = 
{
	widget =
	{
		slotpos = 
		{
			Vector3(-(64 + 12), 0), 
			Vector3(0, 0),
			Vector3(64 + 12, 0), 
		},
		animbank = "ui_chest_3x1",
		animbuild = "ui_chest_3x1",
		pos = Vector3(200, 0, 0),
		side_align_tip = 160,

		buttoninfo =
		{
			text = is_english_icefurnace and "Close" or "关闭",
			position = Vector3(0, -65, 0),
			fn = function(inst, doer)
				if inst.components.container ~= nil then
					inst.components.container:Close()
				elseif inst.replica.container ~= nil and not inst.replica.container:IsBusy() then
					SendRPCToServer(RPC.DoWidgetButtonAction, nil, inst)
				end
			end,
			validfn = vaild_check_button_icefurnace,
		},
	},
	
	type = "furnace",

    itemtestfn = function(container, item, slot)
		if item:HasTag("smallcreature") then
			return false
		end
		if item:HasTag("icebox_valid") or item:HasTag("fresh") or item:HasTag("stale") or item:HasTag("spoiled") then
			return true
		end
		return false
    end,
}

	--3x2

params.icefurnace_container_3x2 = 
{
	widget =
	{
		slotpos = {},
		animbank = "ui_chest_3x2",
		animbuild = "ui_chest_3x2",
		pos = Vector3(200, 0, 0),
		side_align_tip = 160,

		buttoninfo =
		{
			text = is_english_icefurnace and "Close" or "关闭",
			position = Vector3(0, -96, 0),
			fn = function(inst, doer)
				if inst.components.container ~= nil then
					inst.components.container:Close()
				elseif inst.replica.container ~= nil and not inst.replica.container:IsBusy() then
					SendRPCToServer(RPC.DoWidgetButtonAction, nil, inst)
				end
			end,
			validfn = vaild_check_button_icefurnace,
		},
	},
	
	type = "furnace",

    itemtestfn = function(container, item, slot)
		if item:HasTag("smallcreature") then
			return false
		end
		if item:HasTag("icebox_valid") or item:HasTag("fresh") or item:HasTag("stale") or item:HasTag("spoiled") then
			return true
		end
		return false
    end,
}

for y = 1, 0, -1 do
	for x = 0, 2 do
		table.insert(params.icefurnace_container_3x2.widget.slotpos, Vector3(80 * x - 80 * 2 + 80, 80 * y - 80 * 2 + 120, 0))
	end
end

	--3x3
	
params.icefurnace_container_3x3 = 
{
	widget =
	{
		slotpos = {},
		animbank = "ui_chest_3x3",
		animbuild = "ui_chest_3x3",
		pos = Vector3(200, 0, 0),
		side_align_tip = 160,
		
		buttoninfo =
		{
			text = is_english_icefurnace and "Close" or "关闭",
			position = Vector3(0, -132.5, 0),
			fn = function(inst, doer)
				if inst.components.container ~= nil then
					inst.components.container:Close()
				elseif inst.replica.container ~= nil and not inst.replica.container:IsBusy() then
					SendRPCToServer(RPC.DoWidgetButtonAction, nil, inst)
				end
			end,
			validfn = vaild_check_button_icefurnace,
		},
	},
	
	type = "furnace",

    itemtestfn = function(container, item, slot)
		if item:HasTag("smallcreature") then
			return false
		end
		if item:HasTag("icebox_valid") or item:HasTag("fresh") or item:HasTag("stale") or item:HasTag("spoiled") then
			return true
		end
		return false
    end,
}

for y = 2, 0, -1 do
	for x = 0, 2 do
		table.insert(params.icefurnace_container_3x3.widget.slotpos, Vector3(80 * x - 80 * 2 + 80, 80 * y - 80 * 2 + 80, 0))
	end
end

	--3x4
	
params.icefurnace_container_3x4 = 
{
	widget =
	{
		slotpos = {},
		animbank = "ui_chester_shadow_3x4",
		animbuild = "ui_chester_shadow_3x4",
		pos = Vector3(200, 0, 0),
		side_align_tip = 160,
		
		buttoninfo =
		{
			text = is_english_icefurnace and "Close" or "关闭",
			position = Vector3(0, -166, 0),
			fn = function(inst, doer)
				if inst.components.container ~= nil then
					inst.components.container:Close()
				elseif inst.replica.container ~= nil and not inst.replica.container:IsBusy() then
					SendRPCToServer(RPC.DoWidgetButtonAction, nil, inst)
				end
			end,
			validfn = vaild_check_button_icefurnace,
		},
	},
	
	type = "furnace",
	
    itemtestfn = function(container, item, slot)
		if item:HasTag("smallcreature") then
			return false
		end
		if item:HasTag("icebox_valid") or item:HasTag("fresh") or item:HasTag("stale") or item:HasTag("spoiled") then
			return true
		end
		return false
    end,	
}

for y = 2.5, -0.5, -1 do
	for x = 0, 2 do
		table.insert(params.icefurnace_container_3x4.widget.slotpos, Vector3(75 * x - 75 * 2 + 75, 75 * y - 75 * 2 + 75, 0))
	end
end

	--3x5
	
params.icefurnace_container_3x5 = 
{
	widget =
	{
		slotpos = {},
		animbank = "ui_tacklecontainer_3x5",
		animbuild = "ui_tacklecontainer_3x5",
		pos = Vector3(200, 65, 0),
		side_align_tip = 160,
		
		buttoninfo =
		{
			text = is_english_icefurnace and "Close" or "关闭",
			position = Vector3(0, -348, 0),
			fn = function(inst, doer)
				if inst.components.container ~= nil then
					inst.components.container:Close()
				elseif inst.replica.container ~= nil and not inst.replica.container:IsBusy() then
					SendRPCToServer(RPC.DoWidgetButtonAction, nil, inst)
				end
			end,
			validfn = vaild_check_button_icefurnace,
		},
	},
	
	type = "furnace",
	
    itemtestfn = function(container, item, slot)
		if item:HasTag("smallcreature") then
			return false
		end
		if item:HasTag("icebox_valid") or item:HasTag("fresh") or item:HasTag("stale") or item:HasTag("spoiled") then
			return true
		end
		return false
    end,	
}

for y = 1, -3, -1 do
    for x = 0, 2 do
        table.insert(params.icefurnace_container_3x5.widget.slotpos, Vector3(80 * x - 80 * 2 + 80, 80 * y - 45, 0))
    end
end

	--Widgetsetup
	
local containers_icefurnace = require("containers")

for k, v in pairs(params) do
    containers_icefurnace.MAXITEMSLOTS = math.max(containers_icefurnace.MAXITEMSLOTS, v.widget.slotpos ~= nil and #v.widget.slotpos or 0)
end

local containers_widgetsetup_icefurnace = containers_icefurnace.widgetsetup

function containers_icefurnace.widgetsetup(container, prefab, data)
    local t = data or params[prefab or container.inst.prefab]
    if t ~= nil then
        for k, v in pairs(t) do
			container[k] = v
		end
		container:SetNumSlots(container.widget.slotpos ~= nil and #container.widget.slotpos or 0)
    else
        return containers_widgetsetup_icefurnace(container, prefab, data)
    end
end

