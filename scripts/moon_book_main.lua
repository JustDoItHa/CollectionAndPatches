GLOBAL.setmetatable(env, {__index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end})


table.insert(PrefabFiles, "py_books")

---------------------------------------------------------------------------------------------------------
local language = GetModConfigData("moon_book_language") or "zhs"

if language == "zhs" then
    STRINGS.NAMES.BOOK_MOON_NEW = "新月之魔典"
    STRINGS.RECIPE_DESC.BOOK_MOON_NEW = "驱逐月亮的力量。"
    STRINGS.CHARACTERS.GENERIC.DESCRIBE.BOOK_MOON_NEW = "月亮暂时回避吧。"
    STRINGS.NAMES.BOOK_MOON_HALF = "半月之魔典"
    STRINGS.RECIPE_DESC.BOOK_MOON_HALF = "月亮的魔法。"
    STRINGS.CHARACTERS.GENERIC.DESCRIBE.BOOK_MOON_HALF = "月亮的被咬了一口。"
else
    STRINGS.NAMES.BOOK_MOON_NEW = "Crescent Grimoire"
    STRINGS.RECIPE_DESC.BOOK_MOON_NEW = "Drive out the power of the moon."
    STRINGS.CHARACTERS.GENERIC.DESCRIBE.BOOK_MOON_NEW = "Let the moon avoid for a while."
    STRINGS.NAMES.BOOK_MOON_HALF = "Demilune Grimoire"
    STRINGS.RECIPE_DESC.BOOK_MOON_HALF = "Moon magic."
    STRINGS.CHARACTERS.GENERIC.DESCRIBE.BOOK_MOON_HALF = "Moon has been bite."
end
if GetModConfigData("add_moon_book_new") then
    AddRecipe2("book_moon_new", {Ingredient("papyrus", 2), Ingredient("opalpreciousgem", 1), Ingredient("butterflywings", 2) }, TECH.BOOKCRAFT_ONE, {builder_tag="bookbuilder", atlas="images/book_moon_new.xml", image="book_moon_new.tex",}, {"CHARACTER"})
end
if GetModConfigData("add_moon_book_half") then
    AddRecipe2("book_moon_half", {Ingredient("papyrus", 2), Ingredient("opalpreciousgem", 1), Ingredient("butterflywings", 2) }, TECH.BOOKCRAFT_ONE, {builder_tag="bookbuilder", atlas="images/book_moon_half.xml", image="book_moon_half.tex",}, {"CHARACTER"})
end

---------------------------------------------------------------------------------------------------------
local sign_items = {
    "book_moon_new",
}

local function draw(inst)
    if not TheWorld.ismastersim then
        return inst
    end

	if inst.components.drawable then
		local oldondrawnfn = inst.components.drawable.ondrawnfn or nil
		inst.components.drawable.ondrawnfn = function(inst, image, src, atlas, bgimage, bgatlas)
            if oldondrawnfn ~= nil then
                oldondrawnfn(inst, image, src, atlas, bgimage, bgatlas)
            end
            if image ~= nil and table.contains(sign_items, image) then
                inst.AnimState:OverrideSymbol("SWAP_SIGN", resolvefilepath(atlas), image..".tex")
            end
        end
	end
end
AddPrefabPostInit("minisign", draw)
AddPrefabPostInit("minisign_drawn", draw)