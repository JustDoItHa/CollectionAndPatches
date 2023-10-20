GLOBAL.setmetatable(env, { __index = function(t, k)
    return GLOBAL.rawget(GLOBAL, k)
end })
if not TheNet:GetIsServer()  then
    return
end
if GetModConfigData("medal_book_read_only_once") then

    for k,v in pairs({"medal_plant_book","unsolved_book","monster_book","immortal_book"}) do
        AddPrefabPostInit(v,function(inst)
            local old = inst.components.book.onread
            inst.components.book.onread = function(inst_inner,...)
                inst_inner:DoTaskInTime(0, inst_inner.Remove)
                return old(inst_inner,...)
            end
        end)
    end
end