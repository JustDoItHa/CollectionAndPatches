if not (GLOBAL.TheNet and GLOBAL.TheNet:GetIsServer()) then
    return
end

AllPlayers = AllPlayers or GLOBAL.AllPlayers
AllRecipes = AllRecipes or GLOBAL.AllRecipes

function blueprintDrop(inst, min, max)
    --蓝图掉落函数
    if inst.components.lootdropper == nil then
        return
    end
    inst.components.lootdropper:AddRandomLoot("blueprint", 1)
    inst.components.lootdropper.numrandomloot = math.random(min, max)
end

local drop_multiplying_f = GetModConfigData("drop_multiplying") --蓝图掉落倍率

local function CanBlueprintRandomRecipe(recipe)
    if recipe.nounlock or recipe.builder_tag ~= nil then
        --Exclude crafting station and character specific
        return false
    end
    local hastech = false
    for k, v in pairs(recipe.level) do
        if v >= 10 then
            --Exclude TECH.LOST
            return false
        elseif v > 0 then
            hastech = true
        end
    end
    --Exclude TECH.NONE
    return hastech
end

local function generate_random_blueprint(inst)
    local unknownrecipes = {}
    local knownrecipes = {}
    local allplayers = AllPlayers
    for k, v in pairs(AllRecipes) do
        if IsRecipeValid(v.name) and CanBlueprintRandomRecipe(v) then
            local known = false
            for i, player_inner in ipairs(allplayers) do
                if player_inner.components.builder:KnowsRecipe(v) or
                        not player_inner.components.builder:CanLearn(v.name) then
                    known = true
                    break
                end
            end
            table.insert(known and knownrecipes or unknownrecipes, v)
        end
    end
    local random_recipetouse = (#unknownrecipes > 0 and unknownrecipes[math.random(#unknownrecipes)].name) or
            (#knownrecipes > 0 and knownrecipes[math.random(#knownrecipes)].name)

    local blueprint_name = string.lower(random_recipetouse) .. "_" .. "blueprint"
    local name_test = STRINGS.NAMES[string.upper(random_recipetouse)]

    if name_test ~= nil then
        local item_tmp = GLOBAL.SpawnPrefab(random_recipetouse)  --生成商品
        if item_tmp ~= nil and item_tmp.name ~= nil then
            local item = GLOBAL.SpawnPrefab(blueprint_name)  --生成商品蓝图
            local px, py, pz = inst.Transform:GetWorldPosition()
            if item ~= nil and item.name ~= nil then
                item.Transform:SetPosition(px, 0, pz)
                GLOBAL.SpawnPrefab("small_puff").Transform:SetPosition(px, 0, pz)
            end
        end
    end
end
if GetModConfigData("random_blueprint_drop") then
    local List_blueprint_TINY = {
        "lightflier", --光虫
        "mosquito", --蚊子
        "spider", --蜘蛛
        "frog", --青蛙
        "hound*", --普通猎犬
        "rabbit", --兔子
        "mole", --鼹鼠
        "bee", --蜜蜂
        "killerbee", --杀人蜂
        "fruitfly", --果蝇
        "nightmarebeak", --影怪
        "crawlingnightmare", --影怪
        "crawlinghorror", --影怪
        "terrorbeak", --影怪
        "beeguard", --蜜蜂守卫
        "rock_petrified_tree", --石化树
        "rock_petrified_tree_tall", --石化树
        "rock_petrified_tree_short", --石化树
        "rock_petrified_tree_old", --石化树
        "butterfly", --蝴蝶
        "moonbutterfly", --蝴蝶
        "robin", --鸟
        "robin_winter", --鸟
        "crow", --鸟
        "puffin", --鸟
        "canary", --鸟
        "lordfruitfly", --果蝇
        "birchnutdrake", --小桦树精
    }

    local List_blueprint_SMALL = {
        "krampus", --坎普斯
        "bat", --蝙蝠
        "monkey", --猴子
        "spider_hider", --洞穴蜘蛛
        "spider_dropper", --白蜘蛛
        "firehound", --红色獵犬
        "icehound", --藍色獵犬
        "mutatedhound", --恐怖獵犬
        "spider_warrior", --蜘蛛戰士
        "spider_spitter", --吐網蜘蛛
        "spider_healer", --护士蜘蛛
        "spider_moon", --月蜘蛛
        "slurper", --啜食獸
        "pigman", --猪人
        "mermguard", --鱼人守卫
        "carrat", --胡萝卜鼠
        "bunnyman", --兔人
        "rock1", --矿石
        "rock2", --矿石
        "rock_flintless", --矿石
        "rock_flintless_med", --矿石
        "rock_flintless_low", --矿石
        "stalagmite", --矿石
        "stalagmite_tall", --矿石
        "rock_moon", --矿石
        "rock_moon_shell", --矿石
        "grassgekko", --草蜥蜴
        "moonglass_rock", --矿石
        "seastack", --矿石
        "saltstack", --盐
    }

    local List_blueprint_MEDSMALL = {
        "penguin", --企鹅
        "mutated_penguin", --企鹅
        "merm", --鱼人
        "dustmoth", --尘蛾
        "molebat", --蝙蝠猪
        "mushgnome", --蘑菇地精
        "worm", --洞穴蠕虫
        "slurtle", --蜗牛
        "snurtle", --蜗牛
        "perd", --火鸡
        "buzzard", --秃鹫
        "squid", --鱿鱼
        "babybeefalo", --小牛
        "fruitdragon", --沙拉蝾螈
        "deer", --无眼鹿
        "tentacle_pillar", --巨型觸手
        "tentacle", --觸手
        "tallbird", --高鸟
        "teenbird", --高鸟
        "smallbird", --高鸟
        "waterplant", --藤壶
        "dead_sea_bones", --骨头
        "bone", --骨头
        "cookiecutter", --饼干
        "ruins_plate", --远古家具
        "ruins_chipbowl", --远古家具
        "ruins_bowl", --远古家具
    }

    local List_blueprint_MED = {
        "beefalo", --牛
        "catcoon", --浣熊
        "lightninggoat", --电羊
        "rocky", --石虾
        "knight", --发条骑士
        "bishop", --发条主教
        "rook", --发条战车
        "walrus", --海象
        "mossling", --小鸭子
        "walrus_wee_loot", --小海象
        "ruins_statue_head", --远古雕像
        "ruins_statue_mage", --远古雕像
        "ruins_plate", --远古雕像
        "ruins_statue_head_nogem", --远古雕像
        "ruins_statue_mage_nogem", --远古雕像
        "archive_moon_statue", --远古雕像
        "rook_nightmare", --远古战车
        "knight_nightmare", --远古主教
        "bishop_nightmare", --远古骑士
    }

    local List_blueprint_MEDLARGE = {
        "koalefant_summer", --夏天大象
        "koalefant_winter", --冬天大象
        "glommer", --格罗姆
        "shark", --白鲨
        "gnarwail", --一角鲸
        "spat", --刚羊
        "warg", --座狼
        "shell_cluster", --贝壳
    }

    local List_blueprint_LARGE = {
        "leif", --树精
        "alterguardian_phase1", --天体英雄1
        "moose", --鸭子
        "leif_sparse", --树精
        "spiderqueen", --蜘蛛女王
        "deciduoustree", --桦树精
        "sunkenchest", --沉底宝箱
    }

    local List_blueprint_HUGE = {
        "alterguardian_phase2", --天体英雄2
        "alterguardian_phase3", --天体英雄3
        "klaus", --克劳斯
        "bearger", --熊大
        "antlion", --蚁狮
        "deerclops", --巨鹿
        "minotaur", --远古守护者

    }

    local List_blueprint_SUPERHUGE = {
        "dragonfly", --龙蝇
        "beequeen", --蜂后
        "malbatross", --谢天翁
        "crabking", --帝王蟹
        "toadstool", --蛤蟆
        "toadstool_dark", --黑暗蛤蟆
    }

    for i, v in ipairs(List_blueprint_TINY) do
        AddPrefabPostInit(v, function(inst)
            if math.random() < .01 * drop_multiplying_f then
                blueprintDrop(inst, 1, 1)
            end
        end)
    end

    for i, v in ipairs(List_blueprint_SMALL) do
        AddPrefabPostInit(v, function(inst)
            if math.random() < .03 * drop_multiplying_f then
                blueprintDrop(inst, 1, 1)
            end
        end)
    end

    for i, v in ipairs(List_blueprint_MEDSMALL) do
        AddPrefabPostInit(v, function(inst)
            if math.random() < .07 * drop_multiplying_f then
                blueprintDrop(inst, 1, 1)
            end
        end)
    end

    for i, v in ipairs(List_blueprint_MED) do
        AddPrefabPostInit(v, function(inst)
            if math.random() < .18 * drop_multiplying_f then
                blueprintDrop(inst, 1, 1)
            end
        end)
    end

    for i, v in ipairs(List_blueprint_MEDLARGE) do
        AddPrefabPostInit(v, function(inst)
            blueprintDrop(inst, 1, 1)
        end)
    end

    for i, v in ipairs(List_blueprint_LARGE) do
        AddPrefabPostInit(v, function(inst)
            blueprintDrop(inst, 1, 3)
        end)
    end

    for i, v in ipairs(List_blueprint_HUGE) do
        AddPrefabPostInit(v, function(inst)
            blueprintDrop(inst, 2, 4)
        end)
    end

    for i, v in ipairs(List_blueprint_SUPERHUGE) do
        AddPrefabPostInit(v, function(inst)
            blueprintDrop(inst, 3, 5)
        end)
    end

    AddComponentPostInit("fishable", function(self)
        --池塘钓鱼
        local oldHookFish = self.HookFish
        self.HookFish = function(self, fisherman)
            if math.random() < .15 * drop_multiplying_f then
                generate_random_blueprint(fisherman)
            end
            return oldHookFish and oldHookFish(self, fisherman) or nil
        end
    end)

    AddComponentPostInit("oceanfishingrod", function(self)
        --海钓
        local oldCatchFish = self.CatchFish
        self.CatchFish = function(self)
            if self.target and self.target.components.oceanfishable then
                if math.random() < .15 * drop_multiplying_f then
                    generate_random_blueprint(self.fisher)
                end
            end
            return oldCatchFish and oldCatchFish(self) or nil
        end
    end)

    AddComponentPostInit("stewer", function(self)
        --烹饪料理
        local oldStartCooking = self.StartCooking
        self.StartCooking = function(self, doer)
            oldStartCooking(self, doer)
            if doer ~= nil and self.product ~= nil then
                if math.random() < 0.03 * drop_multiplying_f then
                    generate_random_blueprint(doer)
                end
            end
        end
    end)

    AddComponentPostInit("cooker", function(self)
        --普通烹饪
        local oldCookItem = self.CookItem
        self.CookItem = function(self, item, chef)
            if item and chef and chef:HasTag("player") then
                if math.random() < .005 * drop_multiplying_f then
                    generate_random_blueprint(chef)
                end
            end
            return oldCookItem and oldCookItem(self, item, chef) or nil
        end
    end)

    AddComponentPostInit("pickable", function(self)
        --采集
        local oldPick = self.Pick
        self.Pick = function(self, picker)
            if picker and picker:HasTag("player") and self.inst then
                if math.random() < .005 * drop_multiplying_f then
                    generate_random_blueprint(picker)
                end
            end
            return oldPick and oldPick(self, picker) or nil
        end
    end)

    AddComponentPostInit("farmplantable", function(self)
        --种植作物
        local oldPlant = self.Plant
        self.Plant = function(self, target, planter)
            if planter and planter:HasTag("player") and target and self.inst then
                if math.random() < .03 * drop_multiplying_f then
                    generate_random_blueprint(planter)
                end
            end
            return oldPlant and oldPlant(self, target, planter) or nil
        end
    end)

    AddComponentPostInit("eater", function(self)
        --吃食物
        local oldEat = self.Eat
        self.Eat = function(self, food, feeder)
            if feeder and feeder:HasTag("player") and food and self.inst then
                if math.random() < .005 * drop_multiplying_f then
                    generate_random_blueprint(feeder)
                end
            end
            return oldEat and oldEat(self, food, feeder) or nil
        end
    end)

    AddComponentPostInit("age", function(self, inst)
        --生存
        inst:DoPeriodicTask(480, function(inst)
            if inst ~= nil and inst:HasTag("player") and not inst:HasTag("playerghost") and inst.components.age then
                if math.random() < .05 * drop_multiplying_f then
                    local playerday = inst.components.age:GetAgeInDays() + 1
                    generate_random_blueprint(inst)
                end
            end
        end)
    end)

    --蓝图不能作祟
    AddPrefabPostInit("blueprint", function(inst)
        if inst.components.hauntable ~= nil then
            inst.components.hauntable.onhaunt = nil
        end
    end)
end
