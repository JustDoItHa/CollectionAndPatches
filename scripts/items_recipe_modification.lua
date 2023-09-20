----神话：傲来仙境
if TUNING.AOLAI_MYTH and GetModConfigData("aolai_myth_patches_switch") then
    local four_seasons_chest_place_interval = GetModConfigData("four_seasons_chest_place_interval")
    if four_seasons_chest_place_interval and type(four_seasons_chest_place_interval) == "number" then
        if four_seasons_chest_place_interval <= 0 then
            four_seasons_chest_place_interval = 1
        end
    else
        four_seasons_chest_place_interval = false
    end

    ---春季箱子
    AddRecipePostInit("chest_spring_myth", function(recipe)
        if GetModConfigData("chest_spring_myth_make_recipe_change") then
            local recTmp = recipe.ingredients
            if recTmp then
                table.insert(recTmp, Ingredient("boards", 11))
                recipe.ingredients = recTmp
            else
                recipe.ingredients = { Ingredient("boards", 11), Ingredient("greengem", 1) }
            end
        end
        if four_seasons_chest_place_interval then
            recipe.min_spacing = math.ceil(four_seasons_chest_place_interval)
        end
    end)

    ----夏季箱子
    AddRecipePostInit("chest_summer_myth", function(recipe)
        if GetModConfigData("chest_summer_myth_make_recipe_change") then
            local recTmp = recipe.ingredients
            if recTmp then
                table.insert(recTmp, Ingredient("boards", 11))
                recipe.ingredients = recTmp
            else
                recipe.ingredients = { Ingredient("boards", 11), Ingredient("yellowgem", 1) }
            end
        end
        if four_seasons_chest_place_interval then
            recipe.min_spacing = math.ceil(four_seasons_chest_place_interval)
        end
    end)

    ---秋季箱子
    AddRecipePostInit("chest_autumn_myth", function(recipe)
        if GetModConfigData("chest_autumn_myth_make_recipe_change") then
            local recTmp = recipe.ingredients
            if recTmp then
                table.insert(recTmp, Ingredient("boards", 11))
                recipe.ingredients = recTmp
            else
                recipe.ingredients = { Ingredient("boards", 11), Ingredient("orangegem", 1) }
            end
        end
        if four_seasons_chest_place_interval then
            recipe.min_spacing = math.ceil(four_seasons_chest_place_interval)
        end
    end)

    ---冬季箱子
    AddRecipePostInit("chest_winter_myth", function(recipe)
        if GetModConfigData("chest_winter_myth_make_recipe_change") then
            local recTmp = recipe.ingredients
            if recTmp then
                table.insert(recTmp, Ingredient("boards", 11))
                recipe.ingredients = recTmp
            else
                recipe.ingredients = { Ingredient("boards", 11), Ingredient("bluegem", 1), Ingredient("purplegem", 1) }
            end
        end
        if four_seasons_chest_place_interval then
            recipe.min_spacing = math.ceil(four_seasons_chest_place_interval)
        end
    end)
end
