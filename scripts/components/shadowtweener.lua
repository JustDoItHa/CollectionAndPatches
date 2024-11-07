local easing = require "easing"

local ShadowTweener = Class(function(self, inst)
	self.inst = inst

	self.size = nil
	self.start = nil
	self.dest = nil
	self.callback = nil
	self.time = nil
	self.duration = nil
	self.tweening = false
end)

function ShadowTweener:SetSize(width, height)
	self.size = Vector3(width, height)
end

function ShadowTweener:IsTweening()
	return self.tweening
end

function ShadowTweener:EndTween()
	if self.tweening then
		self.tweening = false

		self.start = nil
		self.time = nil
		self.duration = nil

		if self.dest ~= nil then
			self.inst.DynamicShadow:SetSize(self.dest:Get())
			self.dest = nil
		end

		self.inst:StopWallUpdatingComponent(self)
		self.inst:PushEvent("shadowtweener_end")

		if self.callback ~= nil then
			self.callback(self.inst)
		end
		if not self.tweening then
			self.callback = nil
		end
	end
end

function ShadowTweener:ClearTween()
	self.callback = nil
	self:EndTween()
	if self.size ~= nil then
		self.inst.DynamicShadow:SetSize(self.size:Get())
	end
end

function ShadowTweener:StartTween(start, dest, time, delay, callback)
	self.start = start
	self.dest = dest
	self.callback = callback
	self.time = -math.abs(delay or 0)
	self.duration = time

	self.inst:PushEvent("shadowtweener_start")

	self.tweening = true

	if self.duration > 0 then
		self.inst:StartWallUpdatingComponent(self)
		self:OnWallUpdate(0)
	else
		self:EndTween()
	end
end

function ShadowTweener:OnWallUpdate(dt)
	if not TheNet:IsServerPaused() then
		self.time = self.time + dt
	end
	if self.time < self.duration then
		if self.time < 0 then
			self.inst.DynamicShadow:SetSize(self.start.x, self.start.y)
		else
			local width = easing.outCubic(self.time, self.start.x, self.dest.x - self.start.x, self.duration)
			local height = easing.outCubic(self.time, self.start.y, self.dest.y - self.start.y, self.duration)
			self.inst.DynamicShadow:SetSize(width, height)
		end
	else
		self:EndTween()
	end
end

return ShadowTweener