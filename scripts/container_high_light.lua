---提取自show me
---
local _G = GLOBAL

local GetGlobal=function(gname,default)
	local res=_G.rawget(_G,gname)
	if res == nil and default ~= nil then
		_G.rawset(_G,gname,default)
		return default
	end
	return res
end

--nice round function
local round2=function(num, idp)
	return _G.tonumber(string.format("%." .. (idp or 0) .. "f", num))
end


--Locals (Add compatibility with any other mineable mods).
local mods = GetGlobal("mods",{})

local GetTime = _G.GetTime
local TheNet = _G.TheNet
local is_PvP = TheNet:GetDefaultPvpSetting()
local SERVER_SIDE = TheNet:GetIsServer()
local CLIENT_SIDE =	 TheNet:GetIsClient() or (SERVER_SIDE and not TheNet:IsDedicated())

local tonumber = _G.tonumber

local chestR = tonumber(GetModConfigData('chestR',true)) or -1
if chestR == -1 then
	chestR = tonumber(GetModConfigData('chestR')) or 0.3
	if (chestR == -1) then chestR = 0.3 end
end
local chestG = tonumber(GetModConfigData('chestG',true)) or -1
if chestG == -1 then
	chestG = tonumber(GetModConfigData('chestG')) or 1
	if (chestG == -1) then chestG = 1 end
end
local chestB = tonumber(GetModConfigData('chestB',true)) or -1
if chestB == -1 then
	chestB = tonumber(GetModConfigData('chestB')) or 1
	if (chestB == -1) then chestB = 1 end
end
--print('RGB CHEST',chestR,chestG,chestB)

----------------------------傳說覺悟 翻译，请勿搬运WeGame，为避免出现多个相同模组----------------------------
------------------------------------------- HOST & CLIENT AGAIN ---------------------------------------------

--处理箱子模块
do
	local MAIN_VAR_NAME = 'net_ShowMe_chest';
	local NETVAR_NAME = 'ShowMe_chestlq_.'; -- hash value: 983115,  Ratio: 0.000983115
	local EVENT_NAME = 'ShowMe_chest_dirty';
	--[[
	--致模组开发者: 你的模组容器可使用以下代码，实现与ShowMe联动容器高亮。	--源开发者 Star 留
		TUNING.MONITOR_CHESTS = TUNING.MONITOR_CHESTS or {}
		TUNING.MONITOR_CHESTS.chestprefab = true	-- chestprefab 即你的容器代码名称

	--多容器模式, 优先级高低判断可同时加上
	--优先级高于 ShowMe
		TUNING.MONITOR_CHESTS = TUNING.MONITOR_CHESTS or {}
		for _, v in ipairs(容器列表) do
			TUNING.MONITOR_CHESTS[v] = true
		end

	--优先级低于 ShowMe
		for k, m in pairs(ModManager.mods) do
			if m and _G.rawget(m, "SHOWME_STRINGS") then
				if m.postinitfns and m.postinitfns.PrefabPostInit and m.postinitfns.PrefabPostInit.treasurechest then
					for _,v in ipairs(容器列表) do
						m.postinitfns.PrefabPostInit[v] = m.postinitfns.PrefabPostInit.treasurechest
					end
				end
				break
			end
		end
	--]]
	--拿起物品箱子颜色显示的容器列表
	local MONITOR_CHESTS = { treasurechest=1, dragonflychest=1, pandoraschest=1, minotaurchest=1, --skullchest=1,
		--bundle=1, --No container component. =\
							 icebox=1, cookpot=1, -- 冰箱、烹饪锅.
							 chester=1, hutch=1, beargerfur_sack=1,  --小妾、哈奇、极地熊灌桶
							 largechest=1, largeicebox=1, bookstation=1, wardrobe=1, --暗妾(已失效)、冰妾、书架、衣柜.
							 safebox=1, safechest=1, safeicebox=1, --Safe mod.
							 red_treasure_chest=1, purple_treasure_chest=1, green_treasure_chest=1, blue_treasure_chest=1, --Treasure Chests mod.
							 backpack=1, candybag=1, icepack=1, piggyback=1, krampus_sack=1, seedpouch=1, spicepack=1,
							 venus_icebox=1, chesterchest=1, --SL mod
							 saltbox=1, wobybig=1, wobysmall=1, mushroom_light=1, mushroom_light2=1, fish_box=1, supertacklecontainer=1, tacklecontainer=1, archive_cookpot=1,
							 portablecookpot=1, portablespicer=1, sacred_chest=1, boat_ancient_container=1, --便携锅, 香料站, 远古箱, 古董船
							 storeroom=1, alchmy_fur=1, myth_granary=1, hiddenmoonlight=1, coffin=1, grave=1, musha_rpice=1, musha_tallrrrrrice=1, musha_tallrrrrice=1, musha_tallrrrice=1, hiddenmoonlight_inf=1, chest_whitewood_inf=1, chest_whitewood_big_inf=1, --pill_bottle_gourd=1, --丹药葫芦会崩 神话代码加密 无解
							 ro_bin=1, roottrunk_child=1, corkchest=1, smelter=1, --Hamlet
							 thatchpack=1, packim=1, cargoboat=1, piratepack=1, --SW
	}
	if TUNING.MONITOR_CHESTS then
		for k in pairs(TUNING.MONITOR_CHESTS) do
			MONITOR_CHESTS[k] = 1
		end
	end
	local _active --光标中的当前项目（在客户端上）。
	local _ing_prefab --成分，5 秒后将其移除。
	local net_string = _G.net_string
	local chests_around = {} --客户端可见范围内的所有箱子的数组。 对于主机来说——都是箱子，但这很正常。

	--[[
	_G.showme_count_chests = function() --debug function
		local cnt = 0
		for k,v in pairs(chests_around) do
			cnt = cnt + 1
		end
		print('Chests around:',cnt)
	end
	--]]

	local function OnClose(inst) --,err) --关闭箱子时，我们会向客户端发送有关其内容的新数据。
		local c = inst.components.container
		if not c then
			--[[if type(err) ~= "number" then err=nil end
			print('ERROR ShowMe: in ',inst.prefab,err)
			if not err then
				if inst.components then
					print("\tComponents:")
					for k in pairs(inst.components) do
						print("\t\t"..tostring(k))
					end
				else
					print("\tNo components at all!")
				end
			end
			if not err or err < 2000 then
				inst:DoTaskInTime(0,function(inst)
					OnClose(inst,err and (err+1) or 1)
				end)
			end--]]
			return
		end
		--if err then
		--	print("Found!!!!! Problem solved",err)
		--end
		if c:IsEmpty() then
			inst[MAIN_VAR_NAME]:set('')
			return
		end
		local arr = {} -- [预制件]=true
		--[[ Отрывок из предыдущего сочинения (чтобы знать, что там происходит):
		if c.unwrappable and c.unwrappable.itemdata and type(c.unwrappable.itemdata) == 'table' then
			--По одной строке на каждый предмет.
			for i,v in ipairs(c.unwrappable.itemdata) do
				if v.prefab then
					--Пересылаем название префаба и количество дней.
					local delta = v.data and v.data.perishable and v.data.perishable.time
					local count = v.data and v.data.stackable and v.data.stackable.stack
					cn('perish_product', v.prefab, count or 0, delta and round2(delta/TUNING.TOTAL_DAY_TIME,1))
				end
			end
		end--]]
		for k,v in pairs(c.slots) do
			arr[tostring(v.prefab)] = true
			local u = v.components and v.components.unwrappable
			if u and u.itemdata then
				for i,v in ipairs(u.itemdata) do
					arr[v.prefab] = true --将预制件添加到包中。
				end
			end
		end
		local s
		for k in pairs(arr) do
			if s then
				s = s .. ' ' .. k --只有空白字符才可以继续工作。
			else
				s = k
			end
		end
		inst[MAIN_VAR_NAME]:set(s) --发送数据
	end
	--更新箱子高亮，该功能本身必须识别玩家手中的东西。
	local function UpdateChestColor(inst)
		local in_container = inst.ShowMe_chest_table and (
				(_active and inst.ShowMe_chest_table[_active.prefab])
						or (_ing_prefab and inst.ShowMe_chest_table[_ing_prefab])
		)
		if inst.b_ShowMe_changed_color then
			if not in_container then
				if inst.ShowMeColor then
					inst.ShowMeColor(true)
				else
					if inst.AnimState ~= nil then
						inst.AnimState:SetMultColour(1,1,1,1) --默认颜色RGBA
						inst.AnimState:SetLightOverride(0)
					end
					inst.b_ShowMe_changed_color = nil
				end
			end
		else
			if in_container then
				if inst.ShowMeColor then
					inst.ShowMeColor(false)
				else
					if inst.AnimState ~= nil then
						inst.AnimState:SetMultColour(chestR,chestG,chestB,1)
						inst.AnimState:SetLightOverride(.5)		--给箱子添加光覆盖，让夜间也能看清，50%亮度可以在月圆或去色夜空中还能有显示
					end
					inst.b_ShowMe_changed_color = true
				end
			end
		end
	end

	local function OnShowMeChestDirty(inst)
		--inst.components.HuntGameLogic.hunt_kills = inst.components.HuntGameLogic.net_hunt_kills:value()
		local str = inst[MAIN_VAR_NAME]:value()
		--inst.test_str = str --test
		--print('Test Chest:',str)
		local t = inst.ShowMe_chest_table
		for k in pairs(t) do
			t[k] = nil
		end
		for w in string.gmatch(str, "%S+") do
			t[w] = true
		end
		UpdateChestColor(inst) --如果其内容发生变化，则重新绘制该特定箱子。
	end

	local function InitChest(inst)
		inst[MAIN_VAR_NAME] = net_string(inst.GUID, NETVAR_NAME, EVENT_NAME )
		if CLIENT_SIDE then
			inst:ListenForEvent(EVENT_NAME, OnShowMeChestDirty)
			chests_around[inst] = true
			inst.ShowMe_chest_table = {}
			--inst.ShowTable = function() for k in pairs(inst.ShowMe_chest_table) do print(k) end end --debug
			inst:ListenForEvent('onremove', function(inst)
				chests_around[inst] = nil
			end)
		end
		if not SERVER_SIDE then
			return
		end
		inst:ListenForEvent("onclose", OnClose)
		inst:ListenForEvent("itemget", OnClose) --用于背包
		--There is inject in SmarterCrockPot!! : ContainerWidget.old_on_item_lose = ContainerWidget.OnItemLose
		inst:ListenForEvent("itemlose", OnClose)
		inst:DoTaskInTime(0,function(inst)
			OnClose(inst) --不仅仅只在关闭时发送数据，毕竟箱子本来可以装东西的。
		end)
	end

	for k in pairs(MONITOR_CHESTS) do	--添加API
		AddPrefabPostInit(k,InitChest)
	end
	--Фиксим игрока, чтобы мониторить действия курсора.
	if CLIENT_SIDE then
		local function UpdateAllChestsAround()
			for k in pairs(chests_around) do
				UpdateChestColor(k)
			end
		end
		AddPrefabPostInit("inventory_classified",function(inst)
			inst:ListenForEvent("activedirty", function(inst)
				--print("ACTIVE:",inst._active:value())
				_active = inst._active:value()
				_ing_prefab = nil --Если взят предмет, то рецепт сразу же забываем.
				UpdateAllChestsAround() --Перерисовываем ВСЕ сундуки при каждом активном предмете или его отмене.
			end)
		end)

		local _ing_task
		local function UpdateIngredientView(player, prefab)
			_ing_prefab = prefab
			UpdateAllChestsAround()
			if _ing_task then
				_ing_task:Cancel()
			end
			_ing_task = player:DoTaskInTime(15,function(inst)
				_ing_prefab = nil
				_ing_task = nil
				UpdateAllChestsAround()
			end)
		end

		local ingredientui = _G.require 'widgets/ingredientui'
		local old_OnGainFocus = ingredientui.OnGainFocus

		function ingredientui:OnGainFocus(...)
			--print("self.ing.texture:", self.ing.texture, type(self.ing.texture))
			--从 self.ing.texture 中提取文件名，并去掉 .tex 扩展名
			--'[^/]+$' 是一个正则表达式，它的含义是：
			--[^/]: 匹配除了 / 之外的任意字符。
			--+: 匹配前面的模式（[^/]）一次或多次。
			--$: 匹配字符串的末尾，就是文件名（包括扩展名）。
			--'%.tex$' 是一个正则表达式，它的含义是：
			--%.: 匹配一个点（.），因为 . 在正则表达式中有特殊含义，所以需要用 % 转义。
			--tex: 匹配字符串 tex。
			--$: 匹配字符串的末尾，gsub('%.tex$', '')是将匹配的.tex转换为空字符串''
			local prefab
			if self.ing and self.ing.texture and type(self.ing.texture) == "string" then
				prefab = self.ing.texture:match('[^/]+$'):gsub('%.tex$', '')
			end
			--处理多层parent
			local function gfpar(obj, visited)
				visited = visited or {}  -- 初始化访问记录表
				if not obj then
					return nil	--如果 obj 是 nil，表示已经到达链的末尾，返回 nil
				end
				if visited[obj] then
					return nil  -- 如果已经访问过该对象，避免循环
				end
				visited[obj] = true  -- 标记当前对象为已访问
				if obj.owner then
					return obj.owner	--如果 obj.owner 存在，直接返回 owner
				end
				return gfpar(obj.parent, visited)  -- 如果没找到owner，则继续递归查找
			end

			-- 使用递归函数, 通过 gfpar(self) 从当前对象 self 开始查找 owner
			local player = gfpar(self)

			if prefab and player then
				--print("INGREDIENT:",prefab)
				UpdateIngredientView(player,prefab)
			end
			if old_OnGainFocus then
				return old_OnGainFocus(self, ...)
			end
		end
	end
end
----------------------------------------