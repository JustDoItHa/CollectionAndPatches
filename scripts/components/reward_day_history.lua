-- 用于记录它是否已经获取过奖励了
local reward = Class(function(self, inst)
    self.inst = inst
    self.lastRewardDay = 0

end)

function reward:GetLastRewardDay() return self.lastRewardDay end

function reward:UpdateLastRewardDay(lastRewardDay)
    self.lastRewardDay = lastRewardDay
end

function reward:OnSave()

    return {lastRewardDay = self.lastRewardDay} or {lastRewardDay = 0}
end
function reward:OnLoad(data)
    if data then self.lastRewardDay = data.lastRewardDay or 0 end
end

return reward
