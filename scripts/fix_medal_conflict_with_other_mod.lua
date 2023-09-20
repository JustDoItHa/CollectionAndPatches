GLOBAL.setmetatable(env, { __index = function(t, k)
    return GLOBAL.rawget(GLOBAL, k)
end })
----------------------------------------------------------------------------------------
--local enabled_wixie = TUNING.DSTU and TUNING.DSTU.WIXIE
--if enabled_wixie == nil then
--    print("fix_slingshot_um_fm warning: Uncompromising Mode not found.")
--    return
--elseif not enabled_wixie then
--    print("fix_slingshot_um_fm: Uncompromising Mode configuation 'wixie_walter' disabled.")
--    return
--end
--

AddGlobalClassPostConstruct("bufferedaction", "BufferedAction", function(self)
    if self.GetDynamicActionPoint ~= nil then
        local um_altered_dynamic_action_point = self.GetDynamicActionPoint
        self.GetDynamicActionPoint = function(self, ...)
            if self.doer ~= nil and self.doer:HasTag("slingshot_sharpshooter") and not self.doer:HasTag("troublemaker") then
                -- add temporary tag for medal equipper
                self.doer:AddTag("troublemaker")
                local result = um_altered_dynamic_action_point(self)
                -- remove temporary tag
                self.doer:RemoveTag("troublemaker")
                return result
            else
                return um_altered_dynamic_action_point(self)
            end
        end
    else
        local um_altered_action_point = self.GetActionPoint
        self.GetActionPoint = function(self, ...)
            if self.doer ~= nil and self.doer:HasTag("slingshot_sharpshooter") and not self.doer:HasTag("troublemaker") then
                -- add temporary tag for medal equipper
                self.doer:AddTag("troublemaker")
                local result = um_altered_action_point(self)
                -- remove temporary tag
                self.doer:RemoveTag("troublemaker")
                return result
            else
                return um_altered_action_point(self)
            end
        end
    end
end)

