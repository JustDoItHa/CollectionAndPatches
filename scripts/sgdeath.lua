--抄自夜雨空心 noe开服脚本 无敌sg进入死亡崩溃 (多出现于通过代码强制杀死玩家，例如 影天体 在夜雨r的过程中 击杀夜雨)
AddStategraphPostInit("wilson",function(self)
    self.states.death.onexit = function(inst)
        --You should never leave this state once you enter it!
        if inst.components.revivablecorpse == nil then
            -- assert(false, "Left death state.") -- 官方报错直接崩溃
            if inst.components.health and not inst.components.health:IsDead() then -- 再次进入死亡
                TheNet:Announce(inst.name.."触发了(Left death state)，尝试再次进入死亡，如果出现奇怪问题，建议重进游戏")
                -- inst.components.health:Kill()
                inst:PushEvent("death")
                print("再次进入死亡")
            end
        end
    end
end)
