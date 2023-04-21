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
--new derived from id=2188103687
local show_buddle_item = tonumber(GetModConfigData("show_buddle_item",true)) or 1
if show_buddle_item == 1 then
	show_buddle_item = tonumber(GetModConfigData("show_buddle_item")) or 1
end
local item_info_mod = tonumber(GetModConfigData("item_info_mod",true)) or 0
if item_info_mod == 0 then
	item_info_mod = tonumber(GetModConfigData("item_info_mod")) or 0
end
--Название на английском, краткая сетевая строка-алиас (для пересылки).
--Если алиас начинается с маленькой буквы, то он обязан быть длиной в 1 букву. Если с большой, то 2 (вторая буква может быть любого регистра).



----------------------------傳說覺悟 翻译，请勿搬运WeGame，为避免出现多个相同模组----------------------------
------------------------------------------- HOST & CLIENT AGAIN ---------------------------------------------

local FindUpvalue = function(fn, upvalue_name, member_check, no_print, newval)
	local info = _G.debug.getinfo(fn, "u")
	local nups = info and info.nups
	if not nups then return end
	local getupvalue = _G.debug.getupvalue
	local s = ''
	--print("FIND "..upvalue_name.."; nups = "..nups)
	for i = 1, nups do
		local name, val = getupvalue(fn, i)
		s = s .. "\t" .. name .. ": " .. type(val) .. "\n"
		if (name == upvalue_name)
				and ((not member_check) or (type(val)=="table" and val[member_check] ~= nil)) --Надежная проверка
		then
			--print(s.."FOUND "..tostring(val))
			if newval ~= nil then
				_G.debug.setupvalue(fn, i, newval)
			end
			return val, true
		end
	end
	if no_print == nil then
		print("CRITICAL ERROR: Can't find variable "..tostring(upvalue_name).."!")
		print(s)
	end
end


--Добавляем подсказку для игрока, через которую будем пересылать данные (всплывающий текст с инфой под именем предмета)
do
	--Функция возвращает подсказку, если она в точности совпадает с присланной информацией (в player_classified).
	--И возвращает подсказку, либо "".
	local function CheckUserHint(inst)
		local c = _G.ThePlayer and _G.ThePlayer.player_classified
		if c == nil then --Нет локального игрока или classified
			return ""
		end
		--c.showme_hint
		local i = string.find(c.showme_hint2,';',1,true)
		if i == nil then --Строка имеет неправильный формат.
			return ""
		end
		local guid = _G.tonumber(c.showme_hint2:sub(1,i-1))
		if guid ~= inst.GUID then --guid не совпадает (либо вообще nil)
			return ""
		end
		return c.showme_hint2:sub(i+1)
	end
	if CLIENT_SIDE then
		--patching Get Display Name. Нужно только клиенту.
		--[[local old_GetDisplayName = _G.EntityScript.GetDisplayName
		_G.EntityScript.GetDisplayName = function(self)
			local old_name = old_GetDisplayName(self)
			if type(old_name) ~= "string" then
				return old_name
			end
			local str2 = CheckUserHint(self)
			return old_name .. str2
		end--]]

		--Разбираем случаи, когда нужно отправить guid об объекте под мышью.
		local old_inst --Запоминаем, чтобы не спамить один и тот же inst по несколько раз.
		--[[AddWorldPostInit(function(w)
			w:DoPeriodicTask(0.1,function(w)
				if _G.ThePlayer == nil then
					return
				end
				local inst = _G.TheInput:GetWorldEntityUnderMouse()
				if inst ~= nil then
					if inst == old_inst then
						return
					end
					old_inst = inst
					--Посылаем желаемую подсказку.
					SendModRPCToServer(MOD_RPC.ShowMeSHint.Hint, inst.GUID, inst)
				end
			end)
		end)--]]

		local function UnpackData(str,div)
			local pos,arr = 0,{}
			-- for each divider found
			for st,sp in function() return string.find(str,div,pos,true) end do
				table.insert(arr,string.sub(str,pos,st-1)) -- Attach chars left of current divider
				pos = sp + 1 -- Jump past current divider
			end
			table.insert(arr,string.sub(str,pos)) -- Attach chars right of last divider
			return arr
		end

		local save_target
		local last_check_time = 0 --последнее время проверки. Будет устаревать каждые 2 сек.
		local LOCAL_STRING_CACHE = {} --База данных строк, чтобы не обсчитывать замены каждый раз (правда, будет потихоньку пожирать память)
		AddClassPostConstruct("widgets/hoverer",function(hoverer) --hoverer=self
			local old_SetString = hoverer.text.SetString
			local _debug_info = ''
			local NEWLINES_SHIFT = {
				'', --без инфы
				'', -- 1 инфо строка
				'', -- 2 инфо строки
				'\n ',
			}
			local function InitNewLinesShift(idx)
				local str = NEWLINES_SHIFT[idx]
				if str then
					return str
				end
				str = '\n' .. InitNewLinesShift(idx-1)
				NEWLINES_SHIFT[idx] = str
				return str
			end
			hoverer.text.SetString = function(text,str) --text=self
				--print(tostring(str))
				text.cnt_lines = nil
				local target = _G.TheInput:GetHUDEntityUnderMouse()
				if target ~= nil then
					--target.widget.parent - это ItemTile
					target = target.widget ~= nil and target.widget.parent ~= nil and target.widget.parent.item --реальный итем (на клиенте)
				else
					target = _G.TheInput:GetWorldEntityUnderMouse()
				end
				--local lmb = hoverer.owner.components.playercontroller:GetLeftMouseAction()
				if target ~= nil then
					--print(tostring(target))
					--Проверяем совпадение с данными.
					local str2 = CheckUserHint(target)
					if str2 ~= "" then
						--Так, сначала чистим старую строку от переходов на новую строку. Мало ли какие там моды чего добавили.
						local cnt_newlines, _ = 0 --Считаем переходы строк в конце строки (совместимость с DFV)
						while cnt_newlines < #str do
							local ch = str:sub(#str-cnt_newlines,#str-cnt_newlines)
							if ch ~= "\n" and ch ~= " " then
								break
							end
							cnt_newlines = cnt_newlines + 1
						end
						--Очищаем строку от этого мусора
						if cnt_newlines > 0 then
							str = str:sub(1,#str-cnt_newlines)
						end
						--print(#str,"clear")
						--Очищаем строку от промежуточного мусора
						if string.find(str,"\n\n",1,true) ~= nil then
							str = str:gsub("[\n]+","\n")
						end

						if string.find(str,"\n",1,true) ~= nil then
							_,cnt_newlines = str:gsub("\n","\n") --Подсчитываем количество переходов внутри (если есть).
						else
							cnt_newlines = 0
						end


						--Извлекаем данные из полученной упакованной строки.
						str2 = UnpackData(str2,"\2")
						local arr2 = {} --Формируем массив данных в удобоваримом виде.
						for i,v in ipairs(str2) do
							if v ~= "" then
								local param_str = v:sub(2)
								local data = { param = UnpackData(param_str,","), param_str=param_str }
								local my_s = MY_STRINGS[decodeFirstSymbol(v:sub(1,1))]; -- if "@", must pass nil
								if my_s ~= nil then
									data.data = MY_DATA[my_s.key]
								end
								table.insert(arr2,data)
							end
						end
						arr2.str2= str2
						--_G.rawset(_G,"arr2",arr2) --Для теста.
						--Формируем строку
						for i=#arr2,1,-1 do
							local v = arr2[i]
							if v.data ~= nil then
								if v.data.hidden == nil then
									if v.data.fn ~= nil then
										arr2[i] = v.data.fn(v)
									else
										arr2[i] = DefaultDisplayFn(v)
									end
								else
									table.remove(arr2,i)
								end
							else
								arr2[i] = DefaultDisplayFn(v)
							end
						end
						--table.insert(arr2,"xxxxx")
						--table.insert(arr2,"xyz")
						--table.insert(arr2,"aaabbbccc")
						--table.insert(arr2,"dddddd123")
						str2 = table.concat(arr2,'\n')

						--_G.arr({inst=text.inst,hover=text.parent},5)
						--print("-----"..str.."-----")
						--local sss=""
						--for i=#str,#str-10,-1 do
						--	sss=sss..string.byte(str:sub(i,i))..", "
						--end
						--print("Chars: "..sss)
						--[[print(#str,"cut str")
						--В конце тоже убираем переход, если есть.
						if str:sub(#str,#str) == "\n" then
							str = str:sub(1,#str-1)
						end--]]
						--print(#str,"test cache")
						--print("count new cache")
						--print("newlines",#str2)

						--str2 = str2 .. _debug_info
						--local scale = text:GetScale()
						--str2 = str2 .. 'scale = ' .. scale.x .. ';' .. scale.y .. '\n'
						--local scr_w, scr_h = TheSim:GetScreenSize()
						--str2 = str2 .. scr_w .. 'x' .. scr_h .. '\n'

						text.cnt_lines = cnt_newlines + #arr2 + 1


						str = str .. '\n' .. str2 .. (NEWLINES_SHIFT[text.cnt_lines] or InitNewLinesShift(text.cnt_lines))
					end
					--print("Check User Hint: "..str2)
					--Если первый раз, то отправляем запрос.
					if target ~= save_target or last_check_time + 1 < GetTime() then
						save_target = target
						last_check_time = GetTime()
						SendModRPCToServer(MOD_RPC.ShowMeSHint.Hint, save_target.GUID, save_target)
					end
				else
					--print("target nil")
				end
				return old_SetString(text,str)
			end
			--FindUpvalue(hoverer.UpdatePosition, "YOFFSETUP", 150)
			--FindUpvalue(hoverer.UpdatePosition, "YOFFSETDOWN", 120)

			local XOFFSET = 10

			hoverer.UpdatePosition = function(self,x,y)
				local YOFFSETDOWN = 10
				local cnt_lines = self.text and self.text.cnt_lines
				if cnt_lines then
					local extra = cnt_lines - 3
					if extra > 0 then
						YOFFSETDOWN = YOFFSETDOWN - extra * 30
					end
				end


				local scale = self:GetScale()
				local scr_w, scr_h = _G.TheSim:GetScreenSize()
				local w = 0
				local h = 0

				--_debug_info='x='..x..'; y='..y..'\n' .. 'YOFFSETDOWN = ' .. YOFFSETDOWN .. ';' ..tostring(self.text.cnt_lines) .. '\n';

				if self.text ~= nil and self.str ~= nil then
					local w0, h0 = self.text:GetRegionSize()
					w = math.max(w, w0)
					h = math.max(h, h0)
					--_debug_info=_debug_info..'w0='..w0..'; h0='..h0..'\n'
				end
				if self.secondarytext ~= nil and self.secondarystr ~= nil then
					local w1, h1 = self.secondarytext:GetRegionSize()
					w = math.max(w, w1)
					h = math.max(h, h1)
					--_debug_info=_debug_info..'w1='..w1..'; h1='..h1..'\n'
				end

				w = w * scale.x * .5
				h = h * scale.y * .5
				--_debug_info=_debug_info..'w='..w..'; h='..h..'\n'
				--y=y+h

				--_debug_info=_debug_info..'cx='..math.clamp(x, w + XOFFSET, scr_w - w - XOFFSET)..'; cy='..math.clamp(y, h + YOFFSETDOWN * scale.y, scr_h - h - (-80) * scale.y)..'\n'
				self:SetPosition(
						math.clamp(x, XOFFSET + w, scr_w - w - XOFFSET),
						math.clamp(y, YOFFSETDOWN + h, scr_h + 9999),
						0)
			end


		end)
	end

	--Обработчик на сервере
	AddModRPCHandler("ShowMeSHint", "Hint", function(player, guid, item)
		if player.player_classified == nil then
			print("ERROR: player_classified not found!")
			return
		end
		if item ~= nil and item.components ~= nil then
			local s = GetTestString(item,player) --Формируем строку на сервере.
			if s ~= "" then
				player.player_classified.net_showme_hint2:set(guid..";"..s) --Пакуем в строку и отсылаем обратно тому же игроку.
			end
		end
	end)

	--networking
	-- showme_hint2 => "showme_hintbua." -- hash value: 78865, Ratio: 0.000078865
	AddPrefabPostInit("player_classified",function(inst)
		inst.showme_hint2 = ""
		inst.net_showme_hint2 = _G.net_string(inst.GUID, "showme_hintbua.", "showme_hint_dirty2")
		if CLIENT_SIDE then
			inst:ListenForEvent("showme_hint_dirty2",function(inst)
				inst.showme_hint2 = inst.net_showme_hint2:value()
			end)
		end
	end)
end

--Обработка сундуков
do
	local MAIN_VAR_NAME = 'net_ShowMe_chest';
	local NETVAR_NAME = 'ShowMe_chestlq_.'; -- hash value: 983115,  Ratio: 0.000983115
	local EVENT_NAME = 'ShowMe_chest_dirty';
	--[[
	If you want add your custom chest, use this code:
		TUNING.MONITOR_CHESTS = TUNING.MONITOR_CHESTS or {}
		TUNING.MONITOR_CHESTS.chestprefab = true
	--]]
	local MONITOR_CHESTS = { treasurechest=1, dragonflychest=1, skullchest=1, pandoraschest=1, minotaurchest=1,
		--bundle=1, --No container component. =\
							 icebox=1, cookpot=1, -- No cookpot because it may be changed.
							 chester=1, hutch=1,
							 largechest=1, largeicebox=1, --Large Chest mod.
							 safebox=1, safechest=1, safeicebox=1, --Safe mod.
							 red_treasure_chest=1, purple_treasure_chest=1, green_treasure_chest=1, blue_treasure_chest=1, --Treasure Chests mod.
							 backpack=1, candybag=1, icepack=1, piggyback=1, krampus_sack=1, seedpouch=1,
							 venus_icebox=1, chesterchest=1, --SL mod
							 saltbox=1, wobybig=1, wobysmall=1, mushroom_light=1, mushroom_light2=1, fish_box=1, supertacklecontainer=1, tacklecontainer=1, archive_cookpot=1,
							 portablecookpot=1, sacred_chest=1,  --new
							 storeroom=1, alchmy_fur=1, myth_granary=1, hiddenmoonlight=1,--myth mod -- pill_bottle_gourd=1丹药葫芦,
							 ro_bin=1, roottrunk_child=1, corkchest=1, smelter=1, --Hamlet
							 thatchpack=1, packim=1, cargoboat=1, piratepack=1, --SW
	}
	if TUNING.MONITOR_CHESTS then
		for k in pairs(TUNING.MONITOR_CHESTS) do
			MONITOR_CHESTS[k] = 1
		end
	end
	local _active --Текущий предмет в курсоре (на клиенте).
	local _ing_prefab --Ингредиент. Через 5 секунд убирается.
	local net_string = _G.net_string
	local chests_around = {} --Массив всех сундуков в радиусе видимости клиента. Для хоста - все сундуки, но это норм.

	--[[
	_G.showme_count_chests = function() --debug function
		local cnt = 0
		for k,v in pairs(chests_around) do
			cnt = cnt + 1
		end
		print('Chests around:',cnt)
	end
	--]]

	local function OnClose(inst) --,err) --При закрытии сундука посылаем новые данные клиенту о его содержимом.
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
		local arr = {} -- [префаб]=true
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
					arr[v.prefab] = true --Добавляем префаб в упаковке.
				end
			end
		end
		local s
		for k in pairs(arr) do
			if s then
				s = s .. ' ' .. k --Только пробельные символы будут далее работать.
			else
				s = k
			end
		end
		inst[MAIN_VAR_NAME]:set(s) --Посылаем данные.
	end

	--Обновляет подсветку сундука. Функция должна сама узнавать, что в руке игрока.
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
					inst.AnimState:SetMultColour(1,1,1,1) --По умолчанию.
					inst.b_ShowMe_changed_color = nil
				end
			end
		else
			if in_container then
				if inst.ShowMeColor then
					inst.ShowMeColor(false)
				else
					inst.AnimState:SetMultColour(chestR,chestG,chestB,1)
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
		UpdateChestColor(inst) --Перерисовывает данный конкретный сундук, если изменилось его содержимое.
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
		inst:ListenForEvent("itemget", OnClose) --Для рюкзаков.
		--There is inject in SmarterCrockPot!! : ContainerWidget.old_on_item_lose = ContainerWidget.OnItemLose
		inst:ListenForEvent("itemlose", OnClose)
		inst:DoTaskInTime(0,function(inst)
			OnClose(inst) --Изначально тоже посылаем данные, а не только при закрытии. Ведь сундук мог быть загружен.
		end)
	end

	for k in pairs(MONITOR_CHESTS) do
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
			local prefab = self.ing and self.ing.texture and self.ing.texture:match('[^/]+$'):gsub('%.tex$', '')
			local player = self.parent and self.parent.parent and self.parent.parent.owner

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