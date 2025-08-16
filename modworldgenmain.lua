local _G = GLOBAL
local require = _G.require
--local TheSim = _G.TheSim
local tasks_ = require("map/tasks")
require "constants" 
--local WorldSim=_G.WorldSim

--获取风滚草刷新数量设置
local interesting_tumbleweed_switch_l = GetModConfigData("interesting_tumbleweed_switch") or false
local interesting_tumbleweed_refresh_switch_l = GetModConfigData("interesting_tumbleweed_refresh_switch") or false
local orders = GetModConfigData("tumbleweed_refresh_orders") or 0
local pattern = GetModConfigData("tumbleweed_refresh_pattern") or 0
local spacing = GetModConfigData("tumbleweed_refresh_spacing") or 0
local offset = GetModConfigData("tumbleweed_refresh_offset") or 0  --moonbase
local prefab = GetModConfigData("tumbleweed_prefab_test") or "tumbleweedspawner"  --moonbase
local cave = GetModConfigData("tumbleweed_refresh_cave") or true

if not (interesting_tumbleweed_switch_l and interesting_tumbleweed_refresh_switch_l) then
	return
end
if pattern == 1 then
	AddTaskSetPreInitAny(function (tasks)
		if tasks~=nil and tasks.location =="forest" or (tasks.location =="cave" and cave) then
			print("名字",tasks.name)
			print("地形集",tasks.tasks)
			for k,v in pairs(tasks.tasks) do
				print("-----------------------------")
				print("地形编号",k)
				print("地形名称",v)
				local task = tasks_.GetTaskByName(v)
				local rooms = task.room_choices 
				for k1, room in pairs(rooms) do
					print("房间 ",k1)	
					local newroom = _G.terrain.rooms[k1] or nil
					if newroom ~=nil and newroom.contents ~= nil then 			
						if newroom.contents.countprefabs == nil  then 
							newroom.contents["countprefabs"]={}
						end
						newroom.contents.countprefabs.tumbleweedspawner = orders
						print("风滚草刷新点添加成功")
					end
				end
			end
		end
	end)
elseif pattern==2 then
	--借鉴了 2483388271
	local forest_map = require("map/forest_map")
	local Generate_old = forest_map.Generate
	require("map/forest_map").Generate = function(prefab, map_width, map_height, tasks, level, level_type)
		--level.set_pieces.ResurrectionStone.count=2--复活石数量，可以修改到更多
		local savedata = Generate_old(prefab, map_width, map_height, tasks, level, level_type) --生成好的世界数据
		if savedata==nil then
			return nil
		end
		if prefab=="cave" and not cave then return savedata end
		print("地图高",savedata.map.height) 
		print("地图宽",savedata.map.width)
		--1024	(世界小)334  --1024	425(世界大) --指334(不完全固定的样子啊)块地皮，坐标是-334*2~334*2
		function deviation(i,offset)  --偏移offset块地皮
			local x=i
			x = x + (math.random(0,1)==0 and -1 or 1)*math.random()*2 + (offset and (math.random(0,1)==0 and -1 or 1)*offset*4 or 0) --原来的位置是地皮中心
			return x
		end

		local target = prefab-- "tumbleweedspawner" --moonbase
		savedata.ents[target]={} --清空
		local tum_i=1
		local x_,y_=savedata.map.height,savedata.map.width 
		for i=1,x_,spacing do  --隔tum_n块地皮
			for j=1,y_,spacing do
				local x = deviation(i*4-x_*2,math.random(0,offset))
	            local z = deviation(j*4-y_*2,math.random(0,offset))
	            --local tiletype = GLOBAL.WorldSim:GetVisualTileAtPosition(x,y)
	            --print("坐标["..x..","..y.."] ")--" 地皮id",tiletype)
	            savedata.ents[target][tum_i]={x=x,z=z}  --x=,y=要是世界坐标
	        	tum_i=tum_i+1
			end
		end
		return savedata
	end
end