--The code comes from the Sleeping Buff of Uncompromising Mode
GLOBAL.setmetatable(env, { __index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end })
local uses = GetModConfigData("sleeping_buff_uses")
local uses2 = GetModConfigData("sleeping_buff_uses2")
local uses3 = GetModConfigData("sleeping_buff_uses3")
local uses4 = GetModConfigData("sleeping_buff_uses4")
local t_smup = GetModConfigData("sleeping_buff_t_smup")
local t_smhf = GetModConfigData("sleeping_buff_t_smhf")

local tent_list = {
	"tent",
	"siestahut",
	"portabletent_item",
	"portabletent",
	"bedroll_furry",
}
for i, n in pairs(tent_list) do
	AddPrefabPostInit(n, function(inst)
		if not TheWorld.ismastersim then
			return
		end
		
		local t_wp = n == "tent" and (uses) or n == "siestahut" and (uses2) or (n == "portabletent_item" or n == "portabletent") and (uses3) or (uses4)
		local t_u = n == "tent" and (TUNING.TENT_USES) or n == "siestahut" and (TUNING.SIESTA_CANOPY_USES) or (n == "portabletent_item" or n == "portabletent") and (TUNING.PORTABLE_TENT_USES) or (TUNING.BEDROLL_FURRY_USES)
		local tf = inst.components.finiteuses
		local ts = inst.components.sleepingbag
		
		if t_wp then
			if t_wp == "Infinite" or t_wp >= 2000 then
				tf:SetOnFinished(function(inst)
					tf:SetUses(t_u)
				end)
				if n == "bedroll_furry" or n == "portabletent_item" then
					inst:AddTag("hide_percentage")
				end
			else
				tf:SetMaxUses(math.floor(t_u * t_wp))
				tf:SetUses(math.floor(t_u * t_wp))
			end
		end
		
		if n == "bedroll_furry" then
			ts.health_tick = TUNING.SLEEP_HEALTH_PER_TICK * 2
		elseif n == "siestahut" then
			ts.hunger_tick = TUNING.SLEEP_HUNGER_PER_TICK / 2
		end
	end)
end

if t_smhf ~= false then
	TUNING.SLEEP_TICK_PERIOD = TUNING.SLEEP_TICK_PERIOD / t_smhf
end

local SleepingBU = require("components/sleepingbaguser")
AddComponentPostInit("sleepingbaguser", function(SleepingBU)
	if t_smup == true then
		local _DoSleep = SleepingBU.DoSleep
		local _DoWakeUp = SleepingBU.DoWakeUp

		SleepingBU.DoSleep = function(self, bed)
			_DoSleep(self, bed)
			self.healthtask = self.inst:DoPeriodicTask(self.bed.components.sleepingbag.tick_period, function()
				local health_tick = self.bed.components.sleepingbag.health_tick * self.health_bonus_mult
				if self.inst.components.health ~= nil and not self.inst:HasTag("TiddleVirus") then
					self.inst.components.health:DeltaPenalty(-health_tick / 200)
				end
			end)
		end

		SleepingBU.DoWakeUp = function(self, nostatechange)
			if self.healthtask ~= nil then
				self.healthtask:Cancel()
				self.healthtask = nil
			end
			_DoWakeUp(self, nostatechange)
		end
	end
end)