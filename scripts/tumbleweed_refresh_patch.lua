

_G = GLOBAL
local TheWorld = _G.TheWorld

--print("地图大小",TheWorld.Map:GetTileAtPoint(0,0,0))
local prefab_test = GetModConfigData("tumbleweed_prefab_test") or "tumbleweedspawner"  --moonbase
local worldwind = GetModConfigData("tumbleweed_refresh_worldwind") or true
local cave = GetModConfigData("tumbleweed_refresh_cave") or true
local pattern = GetModConfigData("tumbleweed_refresh_pattern") or 3
local spacing = GetModConfigData("tumbleweed_refresh_spacing") or 0
local offset = GetModConfigData("tumbleweed_refresh_offset") or 0

--清理非陆地上的
AddPrefabPostInit(prefab_test,function(inst)
    inst:DoTaskInTime(1, function(inst) --初始化时坐标(0,0,0)，延迟1 赋值成功后 再判断
        local x,y,z =inst.Transform:GetWorldPosition()
        if not GLOBAL.TheWorld.Map:IsAboveGroundAtPoint(x, y, z) then --非陆地上的
            inst:Remove()
            return
        end
    end)
end)


AddPrefabPostInit("world",function(inst)
    if inst:HasTag("cave") and worldwind then
        inst:AddComponent("worldwind")
    end

    local function SpawnPrefabs()
        local w, h = GLOBAL.TheWorld.Map:GetSize()
        local function deviation(i,offset_)  --偏移offset块地皮
            local x=i
            x = x + (math.random(0,1)==0 and -1 or 1)*math.random()*2 + (offset_ and (math.random(0,1)==0 and -1 or 1)*offset_*4 or 0) --原来的位置是地皮中心
            return x
        end
        local tum_i=1
        for i=1,w,spacing do  --隔tum_n块地皮
            for j=1,h,spacing do
                local x = deviation(i*4-w*2,math.random(0,offset))
                local z = deviation(j*4-h*2,math.random(0,offset))
                local moom = GLOBAL.SpawnPrefab(prefab)
                moom.Transform:SetPosition(x,0,z)
                --moom.persists=false
            end
        end
    end

    if not cave and inst:HasTag("cave") then
        print("关闭洞穴生成风滚草刷新点")
    else
        inst:AddComponent("loadmodtum")
        if pattern==3 then
            inst:DoTaskInTime(0, function(inst)
                if not inst.components.loadmodtum.load then return end ----第一次时，生成一次就好
                inst.components.loadmodtum.load = false
                for _, v in pairs(GLOBAL.Ents) do   --清理掉原本的,指龙蝇沙漠的风滚草刷新点，或者世界生成时的
                    if v.prefab ~= nil and v.prefab == prefab then
                        v:Remove()
                    end
                end

                SpawnPrefabs() --网格添加
            end)
        end
    end
end)


--[[ 测试统计数量
AddPrefabPostInit("world",function(inst)
	inst:DoTaskInTime(5, function(inst) --显示有多少个
		local js_i=0
		for _, v in pairs(_G.Ents) do
			--print("类型",type(v),type(v.prefab),v.prefab)
			if v.prefab == "tumbleweedspawner" then
				js_i=js_i+1
			end
		end
		print("存在数量 "..js_i)
	end)
end)
]]

