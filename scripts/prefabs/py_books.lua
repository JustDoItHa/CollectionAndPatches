local assets_fx =
{
    Asset("ANIM", "anim/fx_books.zip"),
}

local book_defs =
{
    {
        name = "book_moon_new",
        uses = TUNING.BOOK_USES_SMALL,
        read_sanity = -TUNING.SANITY_HUGE,
        peruse_sanity = -TUNING.SANITY_LARGE,
        fx = "fx_book_moon",
        fxmount = "fx_book_moon_mount",
        fn = function(inst, reader)

            if TheWorld:HasTag("cave") then
                return false, "NOMOONINCAVES"
            elseif TheWorld.state.moonphase == "new" then
                return false, "ALREADYFULLMOON"
            end

            TheWorld:PushEvent("ms_setmoonphase", {moonphase = "new", iswaxing = true})

            if not TheWorld.state.isnight then
                reader.components.talker:Say(GetString(reader, "ANNOUNCE_BOOK_MOON_DAYTIME"))
            end

            return true
        end,
        perusefn = function(inst,reader)
            if reader.peruse_moon then
                reader.peruse_moon(reader)
            end
            reader.components.talker:Say(GetString(reader, "ANNOUNCE_READ_BOOK","BOOK_MOON"))
            return true
        end,
    },
    {
        name = "book_moon_half",
        uses = TUNING.BOOK_USES_SMALL,
        read_sanity = -TUNING.SANITY_HUGE,
        peruse_sanity = -TUNING.SANITY_LARGE,
        fx = "fx_book_moon",
        fxmount = "fx_book_moon_mount",
        fn = function(inst, reader)

            if TheWorld:HasTag("cave") then
                return false, "NOMOONINCAVES"
            elseif TheWorld.state.moonphase == "new" then
                return false, "ALREADYFULLMOON"
            end

            TheWorld:PushEvent("ms_setmoonphase", {moonphase = "half", iswaxing = true})

            if not TheWorld.state.isnight then
                reader.components.talker:Say(GetString(reader, "ANNOUNCE_BOOK_MOON_DAYTIME"))
            end

            return true
        end,
        perusefn = function(inst,reader)
            if reader.peruse_moon then
                reader.peruse_moon(reader)
            end
            reader.components.talker:Say(GetString(reader, "ANNOUNCE_READ_BOOK","BOOK_MOON"))
            return true
        end,
    },
}

local function MakeBook(def)
    local assets =
    {
        Asset("ANIM", "anim/py_books.zip"),
        --Asset("SOUND", "sound/common.fsb"),
        Asset("IMAGE", "images/"..def.name..".tex"),
        Asset("ATLAS", "images/"..def.name..".xml"),
        Asset("ATLAS_BUILD", "images/"..def.name..".xml", 256),
    }
    local prefabs
    if def.deps ~= nil then
        prefabs = {}
        for i, v in ipairs(def.deps) do
            table.insert(prefabs, v)
        end
    end
    if def.fx ~= nil then
        prefabs = prefabs or {}
        table.insert(prefabs, def.fx)
    end
    if def.fxmount ~= nil then
        prefabs = prefabs or {}
        table.insert(prefabs, def.fxmount)
    end
    if def.fx_over ~= nil then
        prefabs = prefabs or {}
        local fx_over_prefab = "fx_"..def.fx_over.."_over_book"
        table.insert(prefabs, fx_over_prefab)
        table.insert(prefabs, fx_over_prefab.."_mount")
    end
    if def.fx_under ~= nil then
        prefabs = prefabs or {}
        local fx_under_prefab = "fx_"..def.fx_under.."_under_book"
        table.insert(prefabs, fx_under_prefab)
        table.insert(prefabs, fx_under_prefab.."_mount")
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank("books")
        inst.AnimState:SetBuild("py_books")
        inst.AnimState:PlayAnimation(def.name)

        MakeInventoryFloatable(inst, "med", nil, 0.75)

        inst:AddTag("book")
        inst:AddTag("bookcabinet_item")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        -----------------------------------

        inst.def = def
        inst.swap_build = "swap_books"
        inst.swap_prefix = def.name

        inst:AddComponent("inspectable")
        inst:AddComponent("book")
        inst.components.book:SetOnRead(def.fn)
        inst.components.book:SetOnPeruse(def.perusefn)
        inst.components.book:SetReadSanity(def.read_sanity)
        inst.components.book:SetPeruseSanity(def.peruse_sanity)
        inst.components.book:SetFx(def.fx, def.fxmount)

        inst:AddComponent("inventoryitem")
        inst.components.inventoryitem.atlasname = "images/"..def.name..".xml"

        inst:AddComponent("finiteuses")
        inst.components.finiteuses:SetMaxUses(def.uses)
        inst.components.finiteuses:SetUses(def.uses)
        inst.components.finiteuses:SetOnFinished(inst.Remove)

        inst:AddComponent("fuel")
        inst.components.fuel.fuelvalue = TUNING.MED_FUEL

        MakeSmallBurnable(inst, TUNING.MED_BURNTIME)
        MakeSmallPropagator(inst)

        --MakeHauntableLaunchOrChangePrefab(inst, TUNING.HAUNT_CHANCE_OFTEN, TUNING.HAUNT_CHANCE_OCCASIONAL, nil, nil, morphlist)
        MakeHauntableLaunch(inst)

        return inst
    end

    return Prefab(def.name, fn, assets, prefabs)
end

local function MakeFX(name, anim, ismount)
    if ismount then
        name = name.."_mount"
        anim = anim.."_mount"
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddFollower()
        inst.entity:AddNetwork()

        inst:AddTag("FX")

        if ismount then
            inst.Transform:SetSixFaced() --match mounted player
        else
            inst.Transform:SetFourFaced() --match player
        end

        inst.AnimState:SetBank("fx_books")
        inst.AnimState:SetBuild("fx_books")
        inst.AnimState:PlayAnimation(anim)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:ListenForEvent("animover", inst.Remove)
        inst.persists = false

        return inst
    end

    return Prefab(name, fn, assets_fx)
end

local ret = { }
for i, v in ipairs(book_defs) do
    table.insert(ret, MakeBook(v))
    if v.fx_over ~= nil then
        v.fx_over_prefab = "fx_"..v.fx_over.."_over_book"
        table.insert(ret, MakeFX(v.fx_over_prefab, v.fx_over, false))
        table.insert(ret, MakeFX(v.fx_over_prefab, v.fx_over, true))
    end
    if v.fx_under ~= nil then
        v.fx_under_prefab = "fx_"..v.fx_under.."_under_book"
        table.insert(ret, MakeFX(v.fx_under_prefab, v.fx_under, false))
        table.insert(ret, MakeFX(v.fx_under_prefab, v.fx_under, true))
    end
end
book_defs = nil
return unpack(ret)
