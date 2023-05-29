-- GLOBAL.setmetatable(env, { __index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end } )

local _G = GLOBAL
local TUNING = _G.TUNING

local TheNet = _G.TheNet
local TheWorld = _G.TheWorld
local ThePlayer = _G.ThePlayer

local Ingredient = _G.Ingredient
local AddClassPostConstruct = env.AddClassPostConstruct
local Vector3 = _G.Vector3
local SendModRPCToServer = _G.SendModRPCToServer
local SendModRPCToClient = _G.SendModRPCToClient
local GetModRPC = _G.GetModRPC
local AddModRPCHandler = _G.AddModRPCHandler
local SpawnPrefab = _G.SpawnPrefab
local AllRecipes = _G.AllRecipes
local BUTTONFONT = _G.BUTTONFONT
local NEWFONT = _G.NEWFONT
local ANCHOR_LEFT = _G.ANCHOR_LEFT
local ANCHOR_MIDDLE = _G.ANCHOR_MIDDLE
local TheInput = _G.TheInput
local STRINGS = _G.STRINGS
local RECIPETABS = _G.RECIPETABS
local TECH = _G.TECH
local json = _G.json
local net_string = _G.net_string
local pcall = _G.pcall
local RPC = _G.RPC
local ACTIONS = _G.ACTIONS
local SendRPCToServer = _G.SendRPCToServer
local BufferedAction = _G.BufferedAction
-- local AddNewTechTree = _G.AddNewTechTree
-- local AddRecipeTab = _G.AddRecipeTab

local EQUIPSLOTS = _G.EQUIPSLOTS

local IsServer = TheNet:GetIsServer() or TheNet:IsDedicated()

local TEMPLATES = require "widgets/templates"
local Image = require("widgets/image")
local ImageButton = require("widgets/imagebutton")
local Text = require("widgets/text")
local Widget = require("widgets/widget")
local ItemSlot = require("widgets/itemslot")

local wb_strengthen_weapon_base = GetModConfigData("wb_strengthen_weapon_base") or 5 -- 强化伤害基数
local wb_strengthen_increase = GetModConfigData("wb_strengthen_increase") or 5 -- 强化伤害基数


--PrefabFiles = {
--  'wb_strengthenstove',
--  'wb_strengthen_levelpaper',
--  'wb_strengthen_bindpaper',
--  'wb_strengthen_protectpaper',
--  'wb_strengthen_food',
--  'wb_handsskill_paper',
--  'ly_magical_shadow',
--  'ly_magical_weaponsparks',
--  'poisonbubble',
--}
table.insert(PrefabFiles, "wb_strengthenstove")
table.insert(PrefabFiles, "wb_strengthen_levelpaper")
table.insert(PrefabFiles, "wb_strengthen_bindpaper")
table.insert(PrefabFiles, "wb_strengthen_protectpaper")
table.insert(PrefabFiles, "wb_strengthen_food")
table.insert(PrefabFiles, "wb_handsskill_paper")
table.insert(PrefabFiles, "ly_magical_shadow")
table.insert(PrefabFiles, "ly_magical_weaponsparks")
table.insert(PrefabFiles, "poisonbubble")

local _ = require('utils/wb_util')


local WbStrengthen = require('components/wb_strengthen')
WbStrengthen.BUFFS_CONFIG["damage"].weapon_base = wb_strengthen_weapon_base

TUNING.WB_STRENGTHEN_BLACKLIST = TUNING.WB_STRENGTHEN_BLACKLIST or {
  -- 黑名单
  "fxyq", -- 一拳
  "philosopherstone", -- 贤者
  "nz_damask", -- 混天绫
	"monster_book",-- 怪物图鉴
	"unsolved_book",-- 未解之谜
	"oldfish_mymod_weapon_thirty", -- 突突枪
}
TUNING.WB_STRENGTHEN_WHITELIST = TUNING.WB_STRENGTHEN_WHITELIST or {
  -- 白名单
}

function CheckCanStrengthen(inst)
  if _.Includes(TUNING.WB_STRENGTHEN_BLACKLIST, inst.prefab) then
    return false
  end
  if  _.Includes(TUNING.WB_STRENGTHEN_WHITELIST, inst.prefab) then
    return true
  end
  local tags = { "armor", "weapon", "tool", "equippable" --[[ "finiteuses" --]] }
  for index, tag in ipairs(tags) do
    if inst:HasTag(tag) then
      return true
    end
  end
end

if IsServer then
  AddPrefabPostInitAny(function(inst)
    if (inst.components.tool and not inst:HasTag("tool")) then inst:AddTag("tool") end
    if (inst.components.weapon and not inst:HasTag("weapon")) then inst:AddTag("weapon") end
    if (inst.components.armor and not inst:HasTag("armor")) then inst:AddTag("armor") end
    if (inst.components.finiteuses and not inst:HasTag("finiteuses")) then inst:AddTag("finiteuses") end
    if (inst.components.equippable and not inst:HasTag("equippable")) then inst:AddTag("equippable") end
    if (inst.components.equippable) then
      if inst.components.equippable.equipslot == EQUIPSLOTS.HANDS then inst:AddTag("equippable-hands") end
      if inst.components.equippable.equipslot == EQUIPSLOTS.HEAD then inst:AddTag("equippable-head") end
      if inst.components.equippable.equipslot == EQUIPSLOTS.BODY then inst:AddTag("equippable-body") end
      if inst.components.equippable.equipslot == EQUIPSLOTS.NECK then inst:AddTag("equippable-neck") end
    end

    if inst.components.inventoryitem ~= nil and CheckCanStrengthen(inst) then
      inst:AddComponent("wb_strengthen")
    end
  end)

  local wetpouch_hitlist = {
    { "wb_strengthen_strengthen_7_levelpaper", 0.02 },
    { "wb_strengthen_strengthen_8_levelpaper", 0.01 },
    { "wb_strengthen_strengthen_9_levelpaper", 0.005 },
    { "wb_strengthen_strengthen_10_levelpaper", 0.001 },
    { "wb_strengthen_strengthen_11_levelpaper", 0.0001 },
    { "wb_strengthen_strengthen_12_levelpaper", 0.00001 },
    { "wb_strengthen_increase_next_levelpaper", 0.0000001 },
    { "wb_strengthen_increase_7_levelpaper", 0.02 },
    { "wb_strengthen_increase_8_levelpaper", 0.01 },
    { "wb_strengthen_increase_9_levelpaper", 0.005 },
    { "wb_strengthen_increase_10_levelpaper", 0.001 },
    { "wb_strengthen_increase_11_levelpaper", 0.0001 },
    { "wb_strengthen_increase_12_levelpaper", 0.00001 },
    { "wb_strengthen_clearpaper", 0.05 },
    { "wb_strengthen_bindpaper", 0.05 },
    { "wb_strengthen_strengthen_protectpaper", 0.05 },
    { "wb_strengthen_increase_protectpaper", 0.05 },
    { "wb_strengthen_strengthen_food", 0.05 },
    { "wb_strengthen_increase_food", 0.05 },
    -- { "wb_handsskill_paper", 0.001 }, -- 测试(bug这么多要你有何用)
  }
  AddPrefabPostInit("wetpouch", function(inst)
    if not inst.components.unwrappable then return end
    if not inst.components.unwrappable.onunwrappedfn then return end
    inst.components.unwrappable:SetOnUnwrappedFn(_.Wrap(inst.components.unwrappable.onunwrappedfn, function (fn, inst, pos, doer, ...)
      local index = math.random(1, #wetpouch_hitlist)
      local hit = wetpouch_hitlist[index]
      if math.random() < (#wetpouch_hitlist * hit[2]) then
        local moisture = inst.components.inventoryitem:GetMoisture()
        local iswet = inst.components.inventoryitem:IsWet()
        local item = SpawnPrefab(hit[1])
        if item ~= nil then
          if item.Physics ~= nil then
            item.Physics:Teleport(pos:Get())
          else
            item.Transform:SetPosition(pos:Get())
          end
          if item.components.inventoryitem ~= nil then
            item.components.inventoryitem:InheritMoisture(moisture, iswet)
          end
        end
        if doer ~= nil and doer.SoundEmitter ~= nil then
          doer.SoundEmitter:PlaySound("dontstarve/common/together/packaged")
        end
        inst:Remove()
        return
      end
      return fn(inst, pos, doer, ...)
    end))
  end)

  AddClassPostConstruct("components/wb_strengthen", function(self)
    -- 失败了概率给一个等级卷
    self.DoFail = _.Wrap(self.DoFail, function (fn, wbs, player, do_mode, level, ...)
      fn(wbs, player, do_mode, level, ...)
      local random = math.random()
      if level >= 11 then
        local levelpaper = nil
        if random < 0.00001 then
          levelpaper = SpawnPrefab('wb_strengthen_' .. do_mode .. '_'  .. 12 .."_levelpaper")
        elseif random < 0.0001 then
          levelpaper = SpawnPrefab('wb_strengthen_' .. do_mode .. '_'  .. 11 .."_levelpaper")
        elseif random < 0.001 then
          levelpaper = SpawnPrefab('wb_strengthen_' .. do_mode .. '_'  .. 10 .."_levelpaper")
        elseif random < 0.01 then
          levelpaper = SpawnPrefab('wb_strengthen_' .. do_mode .. '_'  .. 9 .."_levelpaper")
        elseif random < 0.1 then
          levelpaper = SpawnPrefab('wb_strengthen_' .. do_mode .. '_'  .. 8 .."_levelpaper")
        elseif random < 0.2 then
          levelpaper = SpawnPrefab('wb_strengthen_' .. do_mode .. '_'  .. 7 .."_levelpaper")
        end
        if levelpaper then
          player.components.inventory:GiveItem(levelpaper)
        end
      end
    end)

    -- =================================================
    -- 保护卷
    -- =================================================

    local function dofail_sayfn(wbs, player, do_mode, do_level, is_success)
      local sayfn = wbs.__protectpaper_dofailsayfn
      local isprotect = wbs.__protectpaper_isprotect
      if isprotect == true then
        return player.components.talker:Say('哎呀，还好有保护卷，差点装备就莫得了！', 2.5, false, true, false, { 0, 0, 0, 1 })
      elseif sayfn then
        return sayfn(wbs, player, do_mode, do_level, is_success)
      else
        wbs:DoSay(player, do_mode, do_level, is_success)
      end
    end
    self.DoFail = _.Wrap(self.DoFail, function (fn, wbs, player, do_mode, do_level, sayfn, ...)
      wbs.__protectpaper_dofailplayer = player
      wbs.__protectpaper_dofailmode = do_mode
      wbs.__protectpaper_dofailsayfn = sayfn
      wbs.__protectpaper_infail = true
      fn(wbs, player, do_mode, do_level, dofail_sayfn, ...)
      wbs.__protectpaper_dofailplayer = nil
      wbs.__protectpaper_dofailmode = nil
      wbs.__protectpaper_dofailsayfn = nil
      wbs.__protectpaper_isprotect = nil
      wbs.__protectpaper_infail = nil
    end)
    self.inst.Remove = _.Wrap(self.inst.Remove, function (fn, ...)
      if self.__protectpaper_infail == true then
        local player = self.__protectpaper_dofailplayer
        local do_mode = self.__protectpaper_dofailmode
        if player.components.inventory:Has('wb_strengthen_' .. do_mode .. '_protectpaper', 1) then
          player.components.inventory:ConsumeByName('wb_strengthen_' .. do_mode .. '_protectpaper', 1)
          self.__protectpaper_isprotect = true
          return
        end
      end
      return fn(...)
    end)

    -- =================================================
    -- 强化/附魔秘药
    -- =================================================
    self.GetProbability = _.Wrap(self.GetProbability, function (fn, wbs, player, do_mode, level, ...)
      local buffvalue = 0
      if player and player.components.debuffable then
        local strengthenbuff = player.components.debuffable:GetDebuff("wb_strengthen_strengthen_food_buff")
        local increasebuff = player.components.debuffable:GetDebuff("wb_strengthen_increase_food_buff")
        if strengthenbuff and do_mode == "strengthen" then
          buffvalue = buffvalue + (strengthenbuff.wb_strengthen_probability or 0)
        elseif increasebuff and do_mode == "increase" then
          buffvalue = buffvalue + (increasebuff.wb_strengthen_probability or 0)
        end
      end
      return fn(wbs, player, do_mode, level, ...) + buffvalue
    end)
  end)
end

-- 创建容器 ==============================================
local containers = require('containers')
AddClassPostConstruct('widgets/containerwidget', function(self)
  self.Open = _.Wrap(self.Open, function (fn, self, container, ...)
    local param = containers.params[container.prefab]
    if param and param.onbeforeopen ~= nil then
      param.onbeforeopen(self, container, ...)
    end
    fn(self, container, ...)
    if param and param.onopen ~= nil then
      param.onopen(self, container, ...)
    end
  end)
  self.Close = _.Wrap(self.Close, function (fn, self, ...)
    if self.isopen then
      local param = self.inst and self.inst.container and containers.params[self.inst.container.prefab]
      if param and param.onbeforeclose ~= nil then
        param.onbeforeclose(self, ...)
      end
      fn(self, ...)
      if param and param.onclose ~= nil then
        param.onclose(self, ...)
      end
    end
  end)
end)
local function CreateContainer(prefab, param)
  containers.params[prefab] = param
  containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, param.widget.slotpos ~= nil and #param.widget.slotpos or 0)
end
-- ======================================================

CreateContainer('wb_strengthenstove', {
  widget = {
    slotpos = { Vector3(0, 220, 0) },
    pos = Vector3(300, 0, 0),
    top_align_tip = 50,
  },
  openlimit = 1,
  usespecificslotsforitems = true,
  type = 'cooker',
  itemtestfn = function (container, item, slot)
    if item == nil then return false end
    return CheckCanStrengthen(item)
  end,
  onbeforeopen = function (self, container, doer)
    if self.isopen then return end

    -- 主面板
    self.root_frame = self:AddChild(TEMPLATES.CurlyWindow(130, 540, .6, .6, 39, -25))
    self.root_frame:SetPosition(0, 0, 0)
    self.root_frame_bg = self.root_frame:AddChild(Image("images/fepanel_fills.xml", "panel_fill_tall.tex"))
    self.root_frame_bg:SetScale(.51, .74)
    self.root_frame_bg:SetPosition(5, 7, 0)
    self.root = self.root_frame:AddChild(Widget("wb_strengthenstove_root"))
    self.root:SetPosition(5, 7, 0)

    -- 空面板
    self.empty_panel = self.root:AddChild(Widget("wb_strengthenstove_empty_panel"))
    self.empty_panel:SetPosition(0, 0, 0)
    self.empty_text = self.empty_panel:AddChild(Text(NEWFONT, 48, '请放入装备\n进行【强化】或者【附魔】', { 0, 0, 0, 1 }))
    self.empty_text:SetPosition(0, 0, 0)
    self.empty_text:SetHAlign(ANCHOR_MIDDLE)

    -- 制作面板
    self.make_panel = self.root:AddChild(Widget("wb_strengthenstove_make_panel"))
    self.make_panel:SetPosition(0, 0, 0)
    self.name_text = self.make_panel:AddChild(Text(NEWFONT, 48, '装备名称', { 0, 0, 0, 1 }))
    self.name_text:SetPosition(0, 140, 0)
    self.name_text:SetRegionSize(140, 320)
    -- self.name_text:SetTruncatedString("装备名称", 320, 11, '...')
    self.name_text:SetHAlign(ANCHOR_MIDDLE)

    -- 选择容器
    self.select_block = self.make_panel:AddChild(Widget("wb_strengthenstove_select_block"))
    local strengthen_ingredient = Ingredient("redgem", 1)
    self.select_strengthen_button = self.select_block:AddChild(ImageButton(strengthen_ingredient:GetAtlas(), strengthen_ingredient.type..".tex"))
    self.select_strengthen_button:SetPosition(-80, 70, 0)
    self.select_strengthen_button:SetTooltip("点击消耗红宝石进行强化")
    self.select_strengthen_text = self.select_strengthen_button:AddChild(Text(NEWFONT, 38, '点击强化', { 0, 0, 0, 0.6 }))
    self.select_strengthen_text:SetPosition(0, -50, 0)
    self.select_strengthen_text:SetHAlign(ANCHOR_MIDDLE)
    local increase_ingredient = Ingredient("purplegem", 1)
    self.select_increase_button = self.select_block:AddChild(ImageButton(increase_ingredient:GetAtlas(), increase_ingredient.type..".tex"))
    self.select_increase_button:SetPosition(80, 70, 0)
    self.select_increase_button:SetTooltip("点击消耗紫宝石进行附魔")
    self.select_increase_text = self.select_increase_button:AddChild(Text(NEWFONT, 38, '点击附魔', { 0, 0, 0, 0.6 }))
    self.select_increase_text:SetPosition(0, -50, 0)
    self.select_increase_text:SetHAlign(ANCHOR_MIDDLE)
    self.select_increase_tip = self.select_block:AddChild(Text(NEWFONT, 38, '强化：增加基础属性；\n　　　强化后不可以附魔；\n　　　成功概率较高。\n附魔：增加基础属性；\n　　　每升2级随机加技能；\n　　　11级后获得永恒BUFF；\n　　　附魔后不可以强化；\n　　　需要验证欧皇血统！', { 0, 0, 0, 0.6 }))
    self.select_increase_tip:SetPosition(-10, -145, 0)
    self.select_increase_tip:SetRegionSize(290, 280)
    self.select_increase_tip:SetHAlign(ANCHOR_LEFT)

    -- 属性容器
    self.attr_block = self.make_panel:AddChild(Widget("wb_strengthenstove_attr_block"))
    self.attr_arrow = self.attr_block:AddChild(Image("images/ui.xml", "arrow2_right.tex"))
    self.attr_arrow:SetScale(0.5, 0.7)
    self.attr_arrow:SetPosition(0, 12, 0)
    for i = 1, 4, 1 do
      local c_attr_text = self.attr_block:AddChild(Text(NEWFONT, 38, "属性：属性属性属性属性属性属性属性属性属性", { 0, 0, 0, 0.8 }))
      local n_attr_text = self.attr_block:AddChild(Text(NEWFONT, 38, "属性：属性属性属性属性属性属性属性属性属性", { 0, 0, 0, 0.8 }))
      c_attr_text:SetPosition(-100, 80 - ((i - 1) * 50), 0)
      c_attr_text:SetRegionSize(150, 50)
      c_attr_text:SetHAlign(ANCHOR_LEFT)
      n_attr_text:SetPosition(100, 80 - ((i - 1) * 50), 0)
      n_attr_text:SetRegionSize(150, 50)
      n_attr_text:SetHAlign(ANCHOR_LEFT)
      self["c_attr" .. i .. "_text"] = c_attr_text
      self["n_attr" .. i .. "_text"] = n_attr_text
    end

    -- 提交容器
    self.submit_block = self.make_panel:AddChild(Widget("wb_strengthenstove_submit_block"))
    self.submit_material = self.submit_block:AddChild(ItemSlot("images/hud.xml", "inv_slot.tex"))
    self.submit_material.highlight_scale = 1
    self.submit_material:SetPosition(-100, -190, 0)
    self.submit_material:SetBGImage2(strengthen_ingredient:GetAtlas(), strengthen_ingredient.type..".tex")
    self.submit_material:SetLabel('0/1', { .7, .7, .7, 1 }) -- .25, .75, .25
    self.submit_button = self.submit_block:AddChild(ImageButton("images/ui.xml", "button_small.tex", "button_small_over.tex", "button_small_disabled.tex", nil, nil, {1,1}, {0,0}))
    self.submit_button.image:SetScale(1.9, 1.9)
    self.submit_button:SetPosition(50, -190, 0)
    self.submit_button:SetText("强化")

    
    self.probability = self.make_panel:AddChild(Text(NEWFONT, 28, "成功率：100%", { 0, 0, 0, 0.8 }))
    self.probability:SetPosition(0, -250, 0)
    self.probability:SetRegionSize(150, 30)

    self.empty_panel:Hide()

    self.make_panel:Hide()
    self.select_block:Hide()
    self.attr_block:Hide()
    self.submit_block:Hide()
    self.probability:Hide()

    function self:SubmitStrengthen(isincrease)
      if self.issubmitstrengthening == true then return end
      self.issubmitstrengthening = true
      local items = container.replica.container:GetItems()
      local item = items[1]
      if item then
        SendModRPCToServer(GetModRPC('wb_strengthenstove', 'strengthen'), container, item, isincrease)
      end
      self.inst:DoTaskInTime(.4, function() self.issubmitstrengthening = false end)
    end

    self.select_strengthen_button:SetOnClick(function ()
      return self:SubmitStrengthen(false)
    end)
    self.select_increase_button:SetOnClick(function ()
      return self:SubmitStrengthen(true)
    end)
    self.submit_button:SetOnClick(function ()
      return self:SubmitStrengthen()
    end)
  end,
  onopen = function (self, container, doer)
    if not self.isopen then return end
    if doer ~= nil and doer.components.playeractionpicker ~= nil then
      doer.components.playeractionpicker:RegisterContainer(container)
    end
    self.inv[1].bgimage:SetTexture('images/hud.xml', 'inv_slot_construction.tex')
    self.inv[1]:ConvertToConstructionSlot()

    -- 监听更新
    self.DoUpdateRender = function ()
      local json_str = container._container_data:value()

      local suc, data = pcall(json.decode, json_str)
      if suc ~= true or not data then return end

      self.empty_panel:Hide()
      self.make_panel:Hide()
      self.select_block:Hide()
      self.attr_block:Hide()
      self.submit_block:Hide()
      self.probability:Hide()
 
      if data.do_mode == "strengthen" and data and data.c_level >= 13 then
        self.empty_panel:Show()
        self.empty_text:SetString("已达到强化最高级")
        return self.select_block:Hide()
      else
      end
      
      if data.name == nil then
        self.empty_text:SetString("请放入装备\n进行【强化】或者【附魔】")
        return self.empty_panel:Show()
      end

      self.make_panel:Show()
      self.name_text:SetString(data.name)
      -- self.name_text:SetTruncatedString(data.name, 320, 11, '...')

      if data.do_mode == nil then
        return self.select_block:Show()
      end

      self.attr_block:Show()
      self.submit_block:Show()
      self.probability:Show()

      local c_attrtexts = {}
      local n_attrtexts = {}
      table.insert(c_attrtexts, "等级：" .. data.c_level)
      table.insert(n_attrtexts, "等级：" .. data.n_level)
      if data.isweapon then
        table.insert(c_attrtexts, "攻击：" .. data.c_damage)
        table.insert(n_attrtexts, "攻击：" .. data.n_damage)
      elseif data.isarmor then
        table.insert(c_attrtexts, "防御：" .. (data.c_absorb_percent * 100) .. '%')
        table.insert(n_attrtexts, "防御：" .. (data.n_absorb_percent * 100) .. '%')
      end
      if data.c_prizebuff_count and data.c_prizebuff_count > 0 then
        table.insert(c_attrtexts, "被动：" .. data.c_prizebuff_count .. "技能")
      end
      if data.n_prizebuff_count and data.n_prizebuff_count > 0 then
        table.insert(n_attrtexts, "被动：" .. data.n_prizebuff_count .. "技能")
      end
      for i = 1, 4, 1 do
        self["c_attr" .. i .. "_text"]:SetString((c_attrtexts[i] and c_attrtexts[i]) or '')
        self["n_attr" .. i .. "_text"]:SetString((n_attrtexts[i] and n_attrtexts[i]) or '')
      end


      local submit_material_ingredient = (data.do_mode == "increase" and Ingredient("purplegem", 1)) or Ingredient("redgem", 1)
      self.submit_material:SetBGImage2(submit_material_ingredient:GetAtlas(), submit_material_ingredient.type..".tex")

      local count = (data.do_mode == "increase" and data.purplegem_count) or data.redgem_count
      if count ~= nil then
        local label = count .. '/' .. data.n_level
        local color = (count >= data.n_level and { .25, .75, .25, 1 }) or { .7, .7, .7, 1 }
        self.submit_material:SetLabel(label, color)
      end

      self.submit_button:SetText((data.do_mode == "increase" and "附魔") or "强化")
      self.probability:SetString((data.probability and '成功率：' .. _.Floor(data.probability * 100, 2) .. '%') or '')
    end

    self.DoUpdateRender()
    container:ListenForEvent("watch_container_data", self.DoUpdateRender)
  end,
  onbeforeclose = function (self)
    if self.isopen then
      if self.root_frame then
        self.root_frame:Kill()
      end
      if self.DoUpdateRender then
        self.container:RemoveEventCallback("watch_container_data", self.DoUpdateRender)
        self.DoUpdateRender = nil
      end
    end
  end
})

CreateContainer('wb_strengthen_levelpaper_container', {
  widget = {
    slotpos = {
      Vector3(0, 20, 0)
    },
    animbank = "ui_bundle_2x2",
    animbuild = "ui_bundle_2x2",
    pos = Vector3(200, 0, 0),
    side_align_tip = 120,
    buttoninfo = {
      text = "使用",
      position = Vector3(0, -100, 0),
      validfn = function (inst)
        return inst.replica.container ~= nil and not inst.replica.container:IsEmpty()
      end,
      fn = function (inst, doer)
        if inst.components.container ~= nil then
          BufferedAction(doer, inst, ACTIONS.WRAPBUNDLE):Do()
        elseif inst.replica.container ~= nil and not inst.replica.container:IsBusy() then
          SendRPCToServer(RPC.DoWidgetButtonAction, ACTIONS.WRAPBUNDLE.code, inst, ACTIONS.WRAPBUNDLE.mod_name)
        end
      end
    },
  },
  openlimit = 1,
  type = 'cooker',
  itemtestfn = function (container, item, slot)
    if item == nil then return false end
    return CheckCanStrengthen(item)
  end,
  onbeforeopen = function (self, container, doer)
    if self.isopen then return end
    self.label = self:AddChild(Text(NEWFONT, 48, '放入装备', { 0, 0, 0, 1 }))
    self.label:SetPosition(0, -50, 0)
    self.label:SetHAlign(ANCHOR_MIDDLE)
  end,
  onbeforeclose = function (self)
    if self.isopen and self.label then
      self.label:Kill()
    end
  end
})

CreateContainer('wb_strengthen_bindpaper_container', containers.params["wb_strengthen_levelpaper_container"])
CreateContainer('wb_handsskill_paper_container', containers.params["wb_strengthen_levelpaper_container"])


AddModRPCHandler('wb_strengthenstove', 'strengthen', function(player, inst, item, isincrease)
  if item == nil then return end

  if not item.components.wb_strengthen then return end

  local item_wbs = item.components.wb_strengthen

  local do_mode = item_wbs.do_mode

  if do_mode == nil then
    do_mode = isincrease == true and "increase" or "strengthen"
  end

  -- 禁用了附魔
  if do_mode == "increase" and wb_strengthen_increase ~= true then
    return player.components.talker:Say('好像啥事都没发生！')
  end

  local consume_prefab = "redgem"
  local consume_amount = item_wbs.level + 1

  if do_mode == "strengthen" then
    consume_prefab = "redgem"
  elseif do_mode == "increase" then
    consume_prefab = "purplegem"
  end

  local hasredgem = player.components.inventory:Has(consume_prefab, consume_amount)
  if hasredgem then
    player.components.inventory:ConsumeByName(consume_prefab, consume_amount)

    if do_mode == "strengthen" then
      if item_wbs.level + 1 > 13 then
        return player.components.talker:Say('最高只能强化+13哦！')
      end
      item.components.wb_strengthen:DoStrengthen(player)
    elseif do_mode == "increase" then
      item.components.wb_strengthen:DoIncrease(player)
    end
    inst:UpdateContainerData()
  end

end)

STRINGS.NAMES.WB_STRENGTHENSTOVE = "神秘的强化炉"
STRINGS.NAMES.WB_STRENGTHENSTOVE_BUILD = STRINGS.NAMES.WB_STRENGTHENSTOVE
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WB_STRENGTHENSTOVE = "神秘的强化炉"
STRINGS.RECIPE_DESC.WB_STRENGTHENSTOVE = "神秘的强化炉"


--AddRecipe(
--        'wb_strengthenstove',
--        {Ingredient('marble', 20), Ingredient('nightmarefuel', 20), Ingredient('redgem', 20), Ingredient('purplegem', 20),},
--        RECIPETABS.SCIENCE,
--        TECH.SCIENCE_TWO,
--        'wb_strengthenstove_placer',
--        1,
--        nil,
--        nil,
--        nil,
--        "images/inventoryimages2.xml",
--        'wintersfeastoven.tex'
--)
AddRecipe2("wb_strengthenstove", -- name
        {Ingredient('marble', 20), Ingredient('nightmarefuel', 20), Ingredient('redgem', 20), Ingredient('purplegem', 20),},
        GLOBAL.TECH.SCIENCE_TWO,
        { placer = "wb_strengthenstove_placer", min_spacing = 3, atlas = "images/inventoryimages3.xml", image = "wintersfeastoven.tex" },
        { "MAGIC", "STRUCTURES" })


-- 科技栏===============================================================================

local TechTree = require("techtree")
table.insert(TechTree.AVAILABLE_TECH, "WB_STRENGTHENSTOVE")
TechTree.Create = function(t)
	t = t or {}
	for i, v in ipairs(TechTree.AVAILABLE_TECH) do t[v] = t[v] or 0 end
	return t
end
TECH.NONE.WB_STRENGTHENSTOVE = 0
TECH.WB_STRENGTHENSTOVE_ONE = { WB_STRENGTHENSTOVE = 1 }

for k,v in pairs(TUNING.PROTOTYPER_TREES) do v.WB_STRENGTHENSTOVE = 0 end
TUNING.PROTOTYPER_TREES.WB_STRENGTHENSTOVE_ONE = TechTree.Create({ WB_STRENGTHENSTOVE = 1 })

for i, v in pairs(AllRecipes) do
	if v.level.WB_STRENGTHENSTOVE == nil then
		v.level.WB_STRENGTHENSTOVE = 0
	end
end


local STRINGS_CONFIGS = {
  ["wb_strengthen_strengthen_7_levelpaper"] = { "+7强化卷轴", "莫得灵魂的强化", "非酋福利" },
  ["wb_strengthen_strengthen_8_levelpaper"] = { "+8强化卷轴", "莫得灵魂的强化", "非酋福利" },
  ["wb_strengthen_strengthen_9_levelpaper"] = { "+9强化卷轴", "莫得灵魂的强化", "非酋福利" },
  ["wb_strengthen_strengthen_10_levelpaper"] = { "+10强化卷轴", "莫得灵魂的强化", "非酋福利" },
  ["wb_strengthen_strengthen_11_levelpaper"] = { "+11强化卷轴", "莫得灵魂的强化", "非酋福利" },
  ["wb_strengthen_strengthen_12_levelpaper"] = { "+12强化卷轴", "莫得灵魂的强化", "非酋福利" },
  ["wb_strengthen_increase_7_levelpaper"] = { "+7附魔卷轴", "莫得灵魂的附魔", "非酋福利" },
  ["wb_strengthen_increase_8_levelpaper"] = { "+8附魔卷轴", "莫得灵魂的附魔", "非酋福利" },
  ["wb_strengthen_increase_9_levelpaper"] = { "+9附魔卷轴", "莫得灵魂的附魔", "非酋福利" },
  ["wb_strengthen_increase_10_levelpaper"] = { "+10附魔卷轴", "莫得灵魂的附魔", "非酋福利" },
  ["wb_strengthen_increase_11_levelpaper"] = { "+11附魔卷轴", "莫得灵魂的附魔", "非酋福利" },
  ["wb_strengthen_increase_12_levelpaper"] = { "+12附魔卷轴", "莫得灵魂的附魔", "非酋福利" },
  ["wb_strengthen_increase_next_levelpaper"] = { "++1附魔卷轴", "挂批" },
  ["wb_strengthen_clearpaper"] = { "净化卷轴", "真的有人会用这玩意嘛", "忘掉一切" },
  ["wb_strengthen_bindpaper"] = { "契约卷轴", "契约卷轴", "一起来签订签约吧" },
  ["wb_strengthen_strengthen_protectpaper"] = { "强化保护卷", "没它我可不敢强化", "不慌！装备还在！" },
  ["wb_strengthen_increase_protectpaper"] = { "附魔保护卷", "没它我可不敢附魔", "不慌！装备还在！" },
  ["wb_strengthen_strengthen_food"] = { "强化秘药", "有了它我觉得我又行了！", "提升强化成功率" },
  ["wb_strengthen_increase_food"] = { "附魔秘药", "有了它我觉得我又行了！", "提升附魔成功率" },
  ["wb_handsskill_paper"] = { "魔法卷轴（???）", "拾之无味，弃之可惜", "赋予装备技能" },
}

for name, config in pairs(STRINGS_CONFIGS) do
  STRINGS.NAMES[string.upper(name)] = config[1]
  STRINGS.NAMES[string.upper(name) .. '_BUILD'] = STRINGS.NAMES[string.upper(name)]
  STRINGS.CHARACTERS.GENERIC.DESCRIBE[string.upper(name)] = config[2]
  STRINGS.RECIPE_DESC[string.upper(name)] = config[3]
end

--local WB_STRENGTHENSTOVE_TAB = AddRecipeTab('神秘的强化炉', 200, "images/inventoryimages2.xml", 'wintersfeastoven.tex', nil, true)
local WB_STRENGTHENSTOVE_TAB = AddRecipeTab('神秘的强化炉' or "", 200, "images/inventoryimages2.xml", "wintersfeastoven.tex", nil, true)

AddRecipe("wb_strengthen_clearpaper", { Ingredient('papyrus', 1), Ingredient('nightmarefuel', 10) }, WB_STRENGTHENSTOVE_TAB, TECH.WB_STRENGTHENSTOVE_ONE, nil, 1, true, nil, nil, "images/inventoryimages2.xml", "sketch.tex")
AddRecipe("wb_strengthen_bindpaper", { Ingredient('papyrus', 1), Ingredient('nightmarefuel', 10), Ingredient('atrium_key', 1) }, WB_STRENGTHENSTOVE_TAB, TECH.WB_STRENGTHENSTOVE_ONE, nil, 1, true, nil, nil, "images/inventoryimages2.xml", "sketch.tex")
AddRecipe("wb_strengthen_strengthen_protectpaper", { Ingredient('papyrus', 1), Ingredient('nightmarefuel', 10), Ingredient('redgem', 1) }, WB_STRENGTHENSTOVE_TAB, TECH.WB_STRENGTHENSTOVE_ONE, nil, 1, true, nil, nil, "images/inventoryimages2.xml", "sketch.tex")
AddRecipe("wb_strengthen_increase_protectpaper", { Ingredient('papyrus', 1), Ingredient('nightmarefuel', 10), Ingredient('purplegem', 1) }, WB_STRENGTHENSTOVE_TAB,TECH.WB_STRENGTHENSTOVE_ONE, nil, 1, true, nil, nil, "images/inventoryimages2.xml", "sketch.tex")
AddRecipe("wb_strengthen_strengthen_food",{ Ingredient('gazpacho', 1), Ingredient('wb_strengthen_strengthen_protectpaper', 2, "images/inventoryimages2.xml", nil, "sketch.tex"), Ingredient('redmooneye', 1) }, WB_STRENGTHENSTOVE_TAB,TECH.WB_STRENGTHENSTOVE_ONE,nil,4,true,nil,nil,"images/inventoryimages1.xml","halloweenpotion_bravery_large.tex")
AddRecipe("wb_strengthen_increase_food",{ Ingredient('gazpacho', 1), Ingredient('wb_strengthen_increase_protectpaper', 2, "images/inventoryimages2.xml", nil, "sketch.tex"), Ingredient('purplemooneye', 1) }, WB_STRENGTHENSTOVE_TAB,TECH.WB_STRENGTHENSTOVE_ONE,nil,4,true,nil,nil,"images/inventoryimages1.xml","halloweenpotion_bravery_large.tex")

-- lavae_cocoon
