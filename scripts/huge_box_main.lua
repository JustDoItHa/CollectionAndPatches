---
--- @author zsh in 2023/1/11 3:27
---


GLOBAL.setmetatable(env, { __index = function(_, k)
    return GLOBAL.rawget(GLOBAL, k);
end });

local API = require("huge_box.API");

-- --[[ Show Me ]]
for _, mod in pairs(ModManager.mods) do
    if mod and mod.SHOWME_STRINGS then
        mod.postinitfns.PrefabPostInit._big_box = mod.postinitfns.PrefabPostInit.treasurechest
        mod.postinitfns.PrefabPostInit._big_box_chest = mod.postinitfns.PrefabPostInit.treasurechest
    end
end

--TUNING.MONITOR_CHESTS = TUNING.MONITOR_CHESTS or {}
--TUNING.MONITOR_CHESTS._big_box = true
--TUNING.MONITOR_CHESTS._big_box_chest = true

--PrefabFiles = {
--    "huge_box"
--}
table.insert(PrefabFiles, "huge_box")


--Assets = {
--    Asset("ANIM", "anim/big_box_ui_120.zip"),
--
--    Asset("IMAGE", "images/DLC0002/inventoryimages.tex"),
--    Asset("ATLAS", "images/DLC0002/inventoryimages.xml"),
--
--    Asset("IMAGE", "images/inventoryitems/huge_box/open.tex"),
--    Asset("ATLAS", "images/inventoryitems/huge_box/open.xml"),
--
--    Asset("IMAGE", "images/inventoryitems/huge_box/close.tex"),
--    Asset("ATLAS", "images/inventoryitems/huge_box/close.xml")
--}

table.insert(Assets, Asset("ANIM", "anim/big_box_ui_120.zip"))

table.insert(Assets, Asset("IMAGE", "images/DLC0002/inventoryimages.tex"))
table.insert(Assets, Asset("ATLAS", "images/DLC0002/inventoryimages.xml"))

table.insert(Assets, Asset("IMAGE", "images/inventoryimages/huge_box/open.tex"))
table.insert(Assets, Asset("ATLAS", "images/inventoryimages/huge_box/open.xml"))

table.insert(Assets, Asset("IMAGE", "images/inventoryimages/huge_box/close.tex"))
table.insert(Assets, Asset("ATLAS", "images/inventoryimages/huge_box/close.xml"))

local minimap = {
    -- DLC0002
    "images/DLC0002/inventoryimages.xml"
}

for _, v in ipairs(minimap) do
    AddMinimapAtlas(v);
    table.insert(Assets, Asset("ATLAS", v));
end

TUNING.HUGE_BOX = {
    SET_HUGE_BOX_PRESERVER_VALUE = env.GetModConfigData("SET_HUGE_BOX_PRESERVER_VALUE");
};

local locale = LOC.GetLocaleCode();
local L = (locale == "zh" or locale == "zht" or locale == "zhr") and true or false;

-----------------------------------------------------------------------------------------
STRINGS.NAMES._BIG_BOX = L and "海上箱子·建筑" or "Sea box · Building";
STRINGS.CHARACTERS.GENERIC.DESCRIBE._BIG_BOX = "你家呢？哦，有我在你不需要家。";
STRINGS.RECIPE_DESC._BIG_BOX = L and "把家带在身上！" or "Take home with you!";

STRINGS.NAMES._BIG_BOX_CHEST = L and "海上箱子·便携" or "Sea case · Portable";
STRINGS.CHARACTERS.GENERIC.DESCRIBE._BIG_BOX_CHEST = "你家呢？哦，有我在你不需要家。";
STRINGS.RECIPE_DESC._BIG_BOX_CHEST = L and "把家带在身上！" or "Take home with you!";

-----------------------------------------------------------------------------------------
local Recipes = {};

Recipes[#Recipes + 1] = {
    CanMake = true,
    name = "_big_box_chest",
    ingredients = {
        Ingredient("opalpreciousgem", 1),
        Ingredient("goldnugget", 80),
        Ingredient("pigskin", 40),
        Ingredient("nightmarefuel", 80),
        Ingredient("silk", 80),
        Ingredient("bearger_fur", 5),
        Ingredient("dragon_scales", 5),
        Ingredient("goose_feather", 20),
        Ingredient("minotaurhorn", 2)
    },
    tech = TECH.NONE,
    config = {
        --placer = "huge_box_placer",
        --min_spacing = 2.5,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "images/DLC0002/inventoryimages.xml",
        image = "waterchest.tex"
    },
    filters = {
        "CONTAINERS"
    }
};

for _, v in pairs(Recipes) do
    if v.CanMake ~= false then
        env.AddRecipe2(v.name, v.ingredients, v.tech, v.config, v.filters);
    end
end

-----------------------------------------------------------------------------------------

local custom_actions = {
    ["HUGE_BOX_HAMMER"] = {
        execute = true,
        id = "HUGE_BOX_HAMMER",
        str = "徒手拆卸",
        fn = function(act)
            local target, doer = act.target, act.doer;
            if target and doer and target.onhammered then
                target.onhammered(target, doer);
                return true;
            end
        end,
        state = "domediumaction"
    }
}

local component_actions = {
    {
        actiontype = "SCENE",
        component = "huge_box_cmp",
        tests = {
            {
                execute = custom_actions["HUGE_BOX_HAMMER"].execute,
                id = "HUGE_BOX_HAMMER",
                testfn = function(inst, doer, actions, right)
                    return inst and inst:HasTag("huge_box") and right;
                end
            }
        }
    }
}

local old_actions = {}

API.addCustomActions(env, custom_actions, component_actions);
API.modifyOldActions(env, old_actions);

-----------------------------------------------------------------------------------------

if env.GetModConfigData("container_removable") then
    modimport("modmain/huge_box/AUXmods/container_removable.lua");
end

-----------------------------------------------------------------------------------------采集

local PICKUP_MUST_TAGS = { "_inventoryitem" }
local PICKUP_CANT_TAGS = { "INLIMBO", "NOCLICK", "knockbackdelayinteraction", "catchable", "fire", "minesprung", "mineactive" }
local function pick(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 20, PICKUP_MUST_TAGS, PICKUP_CANT_TAGS)
    for i, v in ipairs(ents) do
        if v.components.inventoryitem.owner then
            return
        end
        if v.components.inventoryitem ~= nil and v.components.inventoryitem.canbepickedup and v.components.inventoryitem.cangoincontainer
                and not v.components.inventoryitem:IsHeld() and not v.components.inventoryitem.canonlygoinpocket then
            SpawnPrefab("sand_puff").Transform:SetPosition(v.Transform:GetWorldPosition())
            local v_pos = v:GetPosition()
            inst.components.container:GiveItem(v, nil, v_pos)
        end
    end
end

local function ptask(inst)
    if inst and inst.prefab == "_big_box" then
        if not inst.picktask then
            inst.picktask = inst:DoPeriodicTask(1, pick)
        else
            inst.picktask:Cancel()
            inst.picktask = nil
        end
        -- pick(inst)
        -- API.AutoSorter.pickObjectOnFloor(inst)
    end
end
AddModRPCHandler("CAP_BUTTON", "pick", function(player, inst)
    ptask(inst)
    -- pick(inst)
    -- API.AutoSorter.pickObjectOnFloor(inst)
end)

local function huge_box_pick(inst, doer)
    if not inst.cap_pick then
        inst.cap_pick = true
        if inst.components.container ~= nil then
            if inst.components.container ~= nil and not inst.components.container:IsEmpty() then
                ptask(inst)
                -- pick(inst)
                -- API.AutoSorter.pickObjectOnFloor(inst)
            end
        elseif inst.replica.container ~= nil and not inst.replica.container:IsBusy() then
            if inst.replica.container ~= nil and not inst.replica.container:IsEmpty() then
                SendModRPCToServer(MOD_RPC["CAP_BUTTON"]["pick"], inst)
            end
        end
        inst:DoTaskInTime(0.5, function()
            inst.cap_pick = false
        end)
    end
end

AddClassPostConstruct("widgets/containerwidget", function(self, owner)
    local ImageButton = require "widgets/imagebutton"
    local old_Open = self.Open

    self.Open = function(self, container, doer, ...)

        if old_Open then
            old_Open(self, container, doer, ...)
        end

        if container.prefab == "_big_box" then

            local pos = Vector3(100, 193, 0)

            if doer ~= nil and doer.components.playeractionpicker ~= nil then
                doer.components.playeractionpicker:RegisterContainer(container)
            end

            self.cap_pick = self:AddChild(ImageButton("images/ui.xml", "button_small.tex", "button_small_over.tex", "button_small_disabled.tex", nil, nil, { 1, 1 }, { 0, 0 }))
            self.cap_pick.image:SetScale(1.07)
            self.cap_pick.text:SetPosition(2, -2)
            self.cap_pick:SetPosition(pos)
            self.cap_pick:SetText("拾取")

            self.cap_pick:SetOnClick(function()
                if doer ~= nil then
                    if doer:HasTag("busy") then
                        --Ignore button click when doer is busy
                        return
                    elseif doer.components.playercontroller ~= nil then
                        local iscontrolsenabled, ishudblocking = doer.components.playercontroller:IsEnabled()
                        if not (iscontrolsenabled or ishudblocking) then
                            --Ignore button click when controls are disabled
                            --but not just because of the HUD blocking input
                            return
                        end
                    end
                end
                huge_box_pick(container, doer)
            end)

            self.cap_pick:SetFont(BUTTONFONT)
            self.cap_pick:SetDisabledFont(BUTTONFONT)
            self.cap_pick:SetTextSize(33)
            self.cap_pick.text:SetVAlign(ANCHOR_MIDDLE)
            self.cap_pick.text:SetColour(0, 0, 0, 1)

            -- if widget.buttoninfo.validfn ~= nil then
            --     if widget.buttoninfo.validfn(container) then
            --         self.button:Enable()
            --     else
            --         self.button:Disable()
            --     end
            -- end

            -- if TheInput:ControllerAttached() then
            --     self.cap_sort:Hide()
            -- end

            -- self.cap_sort.inst:ListenForEvent("continuefrompause", function()
            --     if TheInput:ControllerAttached() then
            --         self.cap_sort:Hide()
            --     else
            --         self.cap_sort:Show()
            --     end
            -- end, TheWorld)
        end

    end

    local old_Close = self.Close
    self.Close = function(self, ...)
        if self.isopen then
            if self.cap_pick ~= nil then
                self.cap_pick:Kill()
                self.cap_pick = nil
            end
        end
        if old_Close then
            old_Close(self, ...)
        end
    end
end)

local tumbleweed_item_rates_l = GetModConfigData("tumbleweed_item_rates")
if GetModConfigData("interesting_tumbleweed_switch") and type(tumbleweed_item_rates_l) == "number" and tumbleweed_item_rates_l > 0 and TUNING.INTERESTING_TUMBLEWEED_ENABLE then
    TUNING.TUMBLEWEED_RESOURCES_EXPAND = TUNING.TUMBLEWEED_RESOURCES_EXPAND or {}
    TUNING.TUMBLEWEED_RESOURCES_EXPAND.huge_box_resources = {--xxx_resources由你自己命名，尽量不要和别人的重复，可加多条不同类型资源
        resourcesList = {
            --资源列表，可加多条，每条之间用英文逗号隔开
            { chance = tumbleweed_item_rates_l, --权重(必填)
              item = "_big_box", --掉落物(选填，item和pickfn最好至少填一个)
              aggro = false, --是否仇视玩家(选填，一般是生成生物的时候用)
              announce = true, --开出道具是否发公告(选填，默认false)
              season = 15, --是否属于季节性掉落(选填，填了后在相应的季节会有概率加成，春1夏2秋4冬8，可填季节数字之和表示多个季节，比如：春夏=3,夏秋=6,春夏秋冬=15)
                --specialtag="featherhat",--装备特殊加成(选填，填装备名或者该装备拥有的某一个标签，填了后玩家穿戴相应的装备开这个道具会有概率加成)
                --pickfn=function(inst,picker) end--开到后触发的函数(选填，请务必保证函数能正常执行，优先级大于item，有了pickfn就不会生成item了)
            },
            { chance = 1, item = "cutgrass" }
        },
        multiple = 1, --倍率(选填，不填默认为1)
        weightClass = "goodMax", --权重等级(选填，填了后掉率会随玩家幸运值变化,不填掉率不会随幸运值浮动)
    }
end
