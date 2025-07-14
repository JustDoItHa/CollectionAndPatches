local require = GLOBAL.require
local Vector3 = GLOBAL.Vector3
local containers = require("containers")

local params = {}

local containers_widgetsetup_base = containers.widgetsetup
function containers.widgetsetup(container, prefab, data, ...)
    local t = params[prefab or container.inst.prefab]
    if t ~= nil then
        for k, v in pairs(t) do
            container[k] = v
        end
        container:SetNumSlots(container.widget.slotpos ~= nil and #container.widget.slotpos or 0)
    else
        containers_widgetsetup_base(container, prefab, data, ...)
    end
end

local function eliminatingBox()
    local container = {
        widget = {
            slotpos = {
                Vector3(0, 64 + 32 + 8 + 4, 0),
                Vector3(0, 32 + 4, 0),
                Vector3(0, -(32 + 4), 0),
                Vector3(0, -(64 + 32 + 8 + 4), 0),
            },
            animbank = "ui_cookpot_1x4",
            animbuild = "ui_cookpot_1x4",
            pos = Vector3(150, 0, 0),
            side_align_tip = 100,
            buttoninfo = {
                text = "毁灭吧!",
                position = Vector3(0, -165, 0),
            }
        },
        type = "eliminate",
    }

    return container
end

params.eliminate = eliminatingBox()

for k, v in pairs(params) do
    containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, v.widget.slotpos ~= nil and #v.widget.slotpos or 0)
end

local function eliminatingFn(player, inst)
    local container = inst.components.container
    local eliminated = false
    for i = 1, container:GetNumSlots() do
        local item = container:GetItemInSlot(i)
        if item then
            if not item:HasTag("nonpotatable") and not item:HasTag("irreplaceable") then
                eliminated = true
                container:RemoveItemBySlot(i)
                item:Remove()
            end
        end
    end
    if player then
        if eliminated then
            player.components.talker:Say("真爽鸭！")
        else
            player.components.talker:Say("你在干神魔？")
        end
    end
end

function params.eliminate.widget.buttoninfo.fn(inst)
    if GLOBAL.TheWorld.ismastersim then
        eliminatingFn(inst.components.container.opener, inst)
    else
        SendModRPCToServer(GLOBAL.MOD_RPC["eliminate"]["eliminate"], inst)
    end
end
AddModRPCHandler("eliminate", "eliminate", eliminatingFn)

local function trashWidget(inst)
    if not GLOBAL.TheWorld.ismastersim then
        inst:DoTaskInTime(0, function()
            if inst.replica then
                if inst.replica.container then
                    inst.replica.container:WidgetSetup("eliminate")
                end
            end
        end)
        return inst
    end
    if GLOBAL.TheWorld.ismastersim then
        if not inst.components.container then
            inst:AddComponent("container")
            inst.components.container:WidgetSetup("eliminate")
        end
    end
end

AddPrefabPostInit("researchlab2", trashWidget)