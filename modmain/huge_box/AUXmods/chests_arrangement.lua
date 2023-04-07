---
--- @author zsh in 2023/1/10 20:01
---

local API = require("chang_mone.dsts.API");

for _, p in ipairs({ "treasurechest", "dragonflychest", "icebox", "saltbox" }) do
    env.AddPrefabPostInit(p, function(inst)
        if not TheWorld.ismastersim then
            return inst;
        end

        if inst.components.container then
            local old_onclosefn = inst.components.container.onclosefn;
            inst.components.container.onclosefn = function(inst, data)
                if old_onclosefn then
                    old_onclosefn(inst, data);
                end

                API.arrangeContainer(inst);
            end
        end
    end)
end