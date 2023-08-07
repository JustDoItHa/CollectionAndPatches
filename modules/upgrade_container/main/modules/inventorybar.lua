--[[
the game update the cursor sooooo frequently
I dont think it is something that needs to be upd in every unit of time
this module is writen for cutting down that part
]]

local updcur = function(inst)
    inst.widget:UpdateCursor()
end

----------------------------
AddClassPostConstruct("widgets/inventorybar", function(self)
    local oldRefreshRepeatDelay = self.RefreshRepeatDelay
    function self:RefreshRepeatDelay(...)
        self.inst:DoTaskInTime(0, updcur)
        return oldRefreshRepeatDelay(self, ...)
    end

    local oldUpdateCursor = self.UpdateCursor
    function self:UpdateCursor(...)
        if self.skipcursorupd then
            self.skipcursorupd = false
            return
        end
        return oldUpdateCursor(self, ...)
    end

    local oldOnUpdate = self.OnUpdate
    function self:OnUpdate(...)
        if not self.skipcursorupd then
            self.skipcursorupd = true
        end
        return oldOnUpdate(self, ...)
    end
end)