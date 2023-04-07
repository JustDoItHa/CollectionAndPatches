local _G = GLOBAL
local debug = _G.debug
local rooms={
	"hua_player_house",
	"hua_player_house1",
	"hua_player_house_pvz",
	"hua_player_house_tardis"
}

AddPrefabPostInit("world",function(inst)
	local _CanPlantAtPoint=_G.Map.CanPlantAtPoint
	function _G.Map:CanPlantAtPoint(x,y,z)
		return _G.TileGroupManager:IsInvalidTile(self:GetTileAtPoint(x,y,z)) and debug.getinfo(2).source ~= "scripts/prefabs/farm_plow.lua" or _CanPlantAtPoint(self,x,y,z)
	end
end)

local function invincible(inst)
	inst:AddTag("structure")
	if inst.components.workable and inst:HasTag("structure") then
		function inst.components.workable:Destroy(destroyer)
			if destroyer.components.playercontroller == nil then
				return
			end
			if self:CanBeWorked() then
				self:WorkedBy(destroyer, self.workleft)
			end
		end
		function inst.components.workable:WorkedBy(worker)
			if worker.components.playercontroller == nil then
				return
			end
			numworks = numworks or 1
			self.workleft = self.workleft - numworks
			self.lastworktime = GLOBAL.GetTime()

			worker:PushEvent("working", { target = self.inst })
			self.inst:PushEvent("worked", { worker = worker, workleft = self.workleft })

			if self.onwork ~= nil then
				self.onwork(self.inst, worker, self.workleft, numworks)
			end

			if self.workleft <= 0 then
				if self.onfinish ~= nil then
					self.onfinish(self.inst, worker)
				end
				self.inst:PushEvent("workfinished", { worker = worker })

				worker:PushEvent("finishedwork", { target = self.inst, action = self.action })
			end
		end
	end
end

for i,v in ipairs(rooms) do
	AddPrefabPostInit(v,invincible)
end