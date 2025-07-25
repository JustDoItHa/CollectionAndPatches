local _G = GLOBAL
local TheSim = _G.TheSim
local TheNet = _G.TheNet

local IsServer = TheNet:GetIsServer() or TheNet:IsDedicated()
local GetTaskRemaining = _G.GetTaskRemaining

local cant_destroyby_monster = GetModConfigData("cant_destroyby_monster")
local remove_owner_time = GetModConfigData("remove_owner_time")
--TheShard:StartMigration(migrationdata.player.userid, migrationdata.worldid)
-- 掉落物品自动
local auto_stack = GetModConfigData("auto_stack")

--local AllPlayers = _G.AllPlayers
--所有玩家的缓存
local AllPlayersForKeyUserID = {}
--保存所有玩家的集合
local AllPlayers = {}
--保存当前获取到的玩家列表_非player集合
local AllClientPlayers = {}
--保存离开玩家的集合
local LeavedPlayers = {}

-- 牛的控制指令
local MSG_CHOOSE = {
	["#牛跟"] = 1,
	["#牛停"] = 2,
	["#ng"] = 1,
	["#nt"] = 2,
}

if IsServer then
	--通过id来获取到玩家(当前在线的玩家) 
	function GetPlayerById(id) 
		if id ~= nil then 
			return AllPlayersForKeyUserID[id]
		end
		return nil
	end

	--通过id获取当前世界玩家
	-- _G.LookupPlayerInstByUserID
	function GetTheWorldPlayerById(id)
		for _,p in pairs(_G.AllPlayers) do
			if p.userid == id then 
				return p
			end
		end
		return nil
	end

	--刷新玩家列表
	function RefreshPlayers()
		AllPlayers = {}
		AllClientPlayers = {}
		local isStandalone = TheNet:GetServerIsClientHosted()
		local clientObjs = TheNet:GetClientTable()
		if type(clientObjs) == "table" then
			local index = 1
			for i, v in ipairs(clientObjs) do
				if isStandalone or v.performance == nil then
					if test_mode then
						print(string.format("%s[%d] (%s) %s <%s>", v.admin and "*" or " ", index, v.userid, v.name, v.prefab))
					end
					-- if _G.TheWorld.guard_authorization[v.userid] == nil then
					-- 	_G.TheWorld.guard_authorization[v.userid] = {}
					-- end
					-- _G.TheWorld.guard_authorization[v.userid].name = v.name

					AllPlayers[index] = AllPlayersForKeyUserID[v.userid]
					AllClientPlayers[index] = v
					index = index + 1
				end
			end
		end
	end

	-- 通过ownerlist来获取玩家名字
	function GetPlayerNameByOwnerlist(ownerlist)
		return ownerlist and ownerlist.master and _G.TheWorld.guard_authorization[ownerlist.master] and _G.TheWorld.guard_authorization[ownerlist.master].name
	end

	--通过id获取玩家索引
	function GetPlayerIndex(userid)
		RefreshPlayers()
		for n,p in pairs(AllPlayers) do
			if userid == p.userid then 
				return n
			end
		end

		return ""
	end

	-- 共享网络状态
	AddPrefabPostInit("shard_network", function(inst)
		inst:AddComponent("gd_shard_playerchange")
	end)

	--命令处理 9种情况
	AddPrefabPostInit("world", function(inst)
		inst.guard_authorization = {
			custom_prefabs = {},
			minotaur = {
				isSpawnPrefab = true,
				generateDay = 99999999,
			},
		}
		
		local OldOnSave=inst.OnSave
		inst.OnSave = function(inst,data)
			if OldOnSave~=nil then
				OldOnSave(inst,data)
			end
			if inst.guard_authorization ~= nil then
				-- 保存权限失效时间
				for k, v in pairs(LeavedPlayers) do
					if inst.guard_authorization[k] ~= nil then
						inst.guard_authorization[k].timetoleave = math.ceil(GetTaskRemaining(v))
					end
				end

				data.guard_authorization = inst.guard_authorization
			end
		end
		
		local OldOnLoad=inst.OnLoad
		inst.OnLoad = function(inst,data)
			if OldOnLoad~=nil then
				OldOnLoad(inst,data)
			end
			if data.guard_authorization ~= nil then
				inst.guard_authorization = data.guard_authorization

				-- 加载清除权限定时器
				for k, v in pairs(inst.guard_authorization) do
					if type(v) == "table" and v.timetoleave ~= nil and LeavedPlayers[k] == nil then
						LeavedPlayers[k] = inst:DoTaskInTime(v.timetoleave, function()
							LeavedPlayers[k] = nil
							v.timetoleave = nil
							local ents = TheSim:FindEntities(0,0,0,1000)
							for i,v in ipairs(ents) do
								if v.persists and v.ownerlist and v.ownerlist.master == k and v:IsValid() then
									-- v.ownerlist = nil
									-- SetOwnerName(v)
									SetItemPermission(v, nil)
								end
							end
						end)
					end
				end
			end
		end

		--监听玩家进入游戏(join_game)
		inst:ListenForEvent("ms_gd_playerjoined", function (inst, data)
			if data and data.userid then
				if LeavedPlayers[data.userid] ~= nil then
					LeavedPlayers[data.userid]:Cancel()
					LeavedPlayers[data.userid] = nil
					if inst.guard_authorization[data.userid] ~= nil then
						inst.guard_authorization[data.userid].timetoleave = nil
					end
				end
			end
		end)

		--监听玩家离开游戏(leave_game)
		inst:ListenForEvent("ms_gd_playerleft", function (inst, data)
			if data and data.userid then
				if remove_owner_time ~= "never" and inst.guard_authorization[data.userid] ~= nil and LeavedPlayers[data.userid] == nil then
					LeavedPlayers[data.userid] = inst:DoTaskInTime(remove_owner_time, function()
						LeavedPlayers[data.userid] = nil
						inst.guard_authorization[data.userid].timetoleave = nil
						local ents = TheSim:FindEntities(0,0,0,1000)
						for i,v in ipairs(ents) do
							if v.persists and v.ownerlist and v.ownerlist.master == data.userid and v:IsValid() then
								-- v.ownerlist = nil
								-- SetOwnerName(v)
								SetItemPermission(v, nil)
							end
						end
					end)
				end
			end
		end)

		--监听玩家安置，给初始物品
		-- if give_start_item then 
		-- 	inst:ListenForEvent("ms_playerspawn", StartingInventory, inst)
		-- end

		-- 监听玩家进入游戏
		-- local OldNetworking_JoinAnnouncement = _G.Networking_JoinAnnouncement
		-- _G.Networking_JoinAnnouncement = function(...)
		-- 	local ret = OldNetworking_JoinAnnouncement(...)
		-- 	RefreshPlayers()
		-- 	return ret
		-- end

		-- 监听玩家离开游戏
		-- local OldNetworking_LeaveAnnouncement = _G.Networking_LeaveAnnouncement
		-- _G.Networking_LeaveAnnouncement = function(...)
		-- 	local ret = OldNetworking_LeaveAnnouncement(...)
		-- 	RefreshPlayers()
		-- 	return ret
		-- end

		-- 监听玩家被踢出游戏
		-- local OldNetworking_KickAnnouncement = _G.Networking_KickAnnouncement
		-- _G.Networking_KickAnnouncement = function(...)
		-- 	local ret = OldNetworking_KickAnnouncement(...)
		-- 	RefreshPlayers()
		-- 	return ret
		-- end

		-- 监听玩家被封禁
		-- local OldNetworking_BanAnnouncement = _G.Networking_BanAnnouncement
		-- _G.Networking_BanAnnouncement = function(...)
		-- 	local ret = OldNetworking_BanAnnouncement(...)
		-- 	RefreshPlayers()
		-- 	return ret
		-- end
		
		--根据玩家说的话来对命令进行处理
		local OldNetworking_Say = _G.Networking_Say
		_G.Networking_Say = function(guid, userid, name, prefab, message, colour, whisper, isemote)
			local r = OldNetworking_Say(guid, userid, name, prefab, message, colour, whisper, isemote)

			local talker = GetPlayerById(userid)
			-- if talker == nil then
			-- 	return r
			-- end
			
			--获取到玩家说的话
			local words = {}
			for word in string.gmatch(message, "%S+") do
				table.insert(words, word) --分词
			end

			local recipient = nil
			--local content = string.gsub(message, "\s+", "") --去掉所有空格
			
			if string.sub(message,1,1) == "#" then
				local sayAction = nil
				local sayToNum = nil
				if tablelength(words) == 2 then
					sayAction = words[1]
					sayToNum = _G.tonumber(words[2])
				elseif tablelength(words) == 1 then					
					if string.lower( string.sub(message,5,string.len(message)) ) == "all" then
						sayAction = string.sub(message,1,7)
					elseif string.lower( string.sub(message,1,string.len(message)) ) == "#stack" then 
						sayAction = string.sub(message,1,6) 
					elseif string.lower( string.sub(message,1,string.len(message)) ) == "#switch" then 
						sayAction = string.sub(message,1,7) 
					else
						sayAction = string.sub(message,1,4) 
					end
					sayToNum = _G.tonumber(string.sub(message,5,string.len(message))) 
				end

				if sayToNum ~= nil and (string.lower(sayAction) == "#add" or string.lower(sayAction) == "#del" or string.lower(sayAction) == "#delall") then
					RefreshPlayers()
					recipient = AllPlayers[sayToNum]
					recipient_client = AllClientPlayers[sayToNum]
					if recipient_client ~= nil then
						if inst.guard_authorization[userid] == nil then
							inst.guard_authorization[userid] = {}
							inst.guard_authorization[userid].name = name
						end

						--给权限
						if sayAction == "#add" then 
							if recipient_client.userid ~= userid then
								if inst.guard_authorization[userid].friends == nil then 
									inst.guard_authorization[userid].friends = {}
								end
								inst.guard_authorization[userid].friends[recipient_client.userid] = true

								PlayerSay(talker, GetSayMsg("permission_give", recipient_client.name))
								PlayerSay(recipient, GetSayMsg("permission_get", name))
								PlayerSay(talker, GetSayMsg("permission_del_tip"), 2.5)
							else --把权限给了自己
								PlayerSay(talker, GetSayMsg("permission_give_me"))
							end
						end

						--收回单个权限
						if sayAction == "#del" then
							if recipient_client.userid ~= userid then
								if inst.guard_authorization[userid].friends ~= nil and inst.guard_authorization[userid].friends[recipient_client.userid] then
									inst.guard_authorization[userid].friends[recipient_client.userid] = false

									PlayerSay(talker, GetSayMsg("permission_remove", recipient_client.name))
									PlayerSay(recipient, GetSayMsg("permission_lose", name))
								else
									PlayerSay(talker, GetSayMsg("permission_remove_no", recipient_client.name))
								end
							else --收自己的权限
								PlayerSay(talker, GetSayMsg("permission_remove_me"))
							end
						end			
					else
						PlayerSay(talker, GetSayMsg("permission_remove_num_err"))
					end
				elseif sayToNum == nil and sayAction ~= nil and string.lower(sayAction) == "#delall" then 
					--收回所有权限
					if sayAction == "#delall" then
						PlayerSay(talker, "全部收回!")
						--_G.TheWorld:DoTaskInTime( 0, function() 
						--	_G.c_announce("("..name ..")收回了所有人的权限")
						--end)

						if inst.guard_authorization[userid].friends ~= nil then
							inst.guard_authorization[userid].friends = nil 
						end	
					end
				elseif sayAction == "#add" or sayAction == "#del" then
					--命令输入有误
					PlayerSay(talker, GetSayMsg("command_error"))
					PlayerSay(talker, GetSayMsg("command_help"), 2.5, 4) 
				elseif talker ~= nil and sayAction ~= nil and (sayAction == "#stack" or string.lower(sayAction) == "#stack") then 
					-- 输入堆叠指令 
					if auto_stack then 
						PlayerSay(talker, "堆叠!") 
						local pos = talker:GetPosition() 
						auto_stack_fn(pos) 
					else
						PlayerSay(talker, "宝宝哭了,没开自动堆叠") 
					end 	
				elseif talker ~= nil and sayAction ~= nil and (sayAction == "#switch" or string.lower(sayAction) == "#switch") then 
					-- 输入切换指令
					if inst.guard_authorization[userid].permission_state == nil or inst.guard_authorization[userid].permission_state then -- 关闭玩家的权限模式 
						inst.guard_authorization[userid].permission_state = false
						PlayerSay(talker, "已关闭权限模式，再次输入指令可开启") 
					elseif inst.guard_authorization[userid].permission_state == false then  -- 开启玩家的权限模式
						inst.guard_authorization[userid].permission_state = true
						PlayerSay(talker, "已开启权限模式，再次输入指令可关闭") 
					end
				elseif talker ~= nil and _G.LookupPlayerInstByUserID(userid) then
					--获取到玩家说的话
					local choose = MSG_CHOOSE[string.lower(message)]
					if choose == 1 and not talker.beefalo_follow then -- #牛跟
						talker.beefalo_follow = true
						if talker.beefalo ~= nil and talker.beefalo:IsValid() and talker.beefalo.ownerlist ~= nil and talker.beefalo.ownerlist.master == userid then
							-- 距离主人超过30码
							if not talker.beefalo:IsNear(talker, 30) then
								local inst_pos = talker:GetPosition()
								local x, y, z = inst_pos:Get()
								ItemAnimSetPosition(talker.beefalo, x, y, z, false, true)
							end
						end
					elseif choose == 2 and talker.beefalo_follow then -- #牛停
						talker.beefalo_follow = false
					end				
				end
			end

			return r
		end
	end)

	-- local Vector3 = _G.Vector3
	local function SetPlayerPosition(player, x, y, z)
		if _G.TheWorld.Map:IsAboveGroundAtPoint(x, y, z) then
			player:Show()
			player:ScreenFade(true, 0)
			player:DoTaskInTime(1, function()
				ItemAnimSetPosition(player, x, y, z, false, true)

				if player.components.inventory ~= nil then
					for k, item in pairs(player.components.inventory.itemslots) do
						ItemAnimSetPosition(item, x, y, z, true, false)
					end
					for k, equipped in pairs(player.components.inventory.equipslots) do
						if equipped.components.container ~= nil then
							for j, item in pairs(equipped.components.container.slots) do
								ItemAnimSetPosition(item, x, y, z, true, false)
							end
						end
					end
				end

				player:SnapCamera()
			end)
			return true
		end
	end

	AddComponentPostInit("playerspawner", function(OnPlayerSpawn, inst)
		-- 检查玩家位置,玩家位置错误时重置玩家位置
		local function CheckPlayerAndResetPosition(player)
				-- 检测玩家位置
				local x, y, z = player.Transform:GetWorldPosition()
				-- 玩家在错误的地形
				if x ~= nil and not _G.TheWorld.Map:IsPassableAtPoint(x, y, z) then
					
					-- 搜寻并尝试将玩家放置到可站立的地形
					for i = 1, 25 do
						if SetPlayerPosition(player, x + i * 4, y, z) or SetPlayerPosition(player, x - i * 4, y, z) or SetPlayerPosition(player, x, y, z + i * 4) or SetPlayerPosition(player, x, y, z - i * 4) or SetPlayerPosition(player, x + i * 2, y, z + i * 2) or SetPlayerPosition(player, x + i * 2, y, z - i * 2) or SetPlayerPosition(player, x - i * 2, y, z + i * 2) or SetPlayerPosition(player, x - i * 2, y, z - i * 2) then return end
					end

					local multiplayer_portal_pos = _G.TheWorld.multiplayer_portal_pos or {x=0, y=0, z=0}
					ItemAnimSetPosition(player, multiplayer_portal_pos.x, multiplayer_portal_pos.y, multiplayer_portal_pos.z, false, true)
				end
		end

		--监听玩家进入游戏
		inst:ListenForEvent("ms_playerjoined", function(inst, player)
			if player and player.components then
				AllPlayersForKeyUserID[player.userid] = player
				RefreshPlayers()
				player.beefalo_follow = true

				if _G.TheWorld.guard_authorization[player.userid] == nil then
					_G.TheWorld.guard_authorization[player.userid] = {}
				end

				_G.TheWorld.guard_authorization[player.userid].name = player.name 
				_G.TheWorld.guard_authorization[player.userid].permission_state = true 
				CheckPlayerAndResetPosition(player)
			end
		end)

	end)

end
