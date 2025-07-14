local _G = GLOBAL

local function showme_nhact(player)
	local smstr = _G.TheWorld.components.kramped:GetDebugString()
	local tonumber = _G.tonumber

	local i = string.find(smstr, "Player " .. player.GUID)
	if not i or i <= 0 then return end
	local s = string.find(smstr,"Actions: ", i + 7)
	if not s or s <= 0 then return end
	local e = string.find(smstr,",", s + 8)
	if not e or e <= 0 or e + 1 > #smstr then return end
	local v = string.sub(smstr, s+9, e-1)
	if not v or v == "" then return end
	local ary = string.split(string.gsub(v," ",""),"/")
	if #ary ~= 2 or tostring(tonumber(ary[1])) ~= ary[1] or tostring(tonumber(ary[2])) ~= ary[2] then return end

	local cur = tonumber(ary[1])
	if player.actions_cur < cur then 
		local str = string.format(" 淘气值：%d / %d ",cur, tonumber(ary[2]))
		-- 淘气值增加
		player.components.talker:Say(str)
	end

	player.actions_max = tonumber(ary[2])
	player.actions_cur = cur
end

AddPrefabPostInit("world", function(self)
    self:ListenForEvent("ms_playerjoined", function(inst, player)
        player.actions_cur = 0
        player.actions_max = 0
        inst:ListenForEvent("killed", showme_nhact, player)
    end)
end)

