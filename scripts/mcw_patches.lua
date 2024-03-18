
local mcwPackLimit = GetModConfigData("mcw_packer_limit_switch") or false;

---冰川镜华打包限制
if mcwPackLimit then
    for k,v in pairs(TUNING.CANT_PACK_ITEMS) do
        if v then
            AddPrefabPostInit(k, function(inst)
                inst:AddTag("cantpack")
                --inst:AddTag("soracantpack")
            end)
        end
    end
end
