--You have to learn to draw by yourself


GLOBAL.TUNING.HUAMINISIGN_BUNDLE = GetModConfigData("BundleItems")
GLOBAL.TUNING.HUAMINISIGN_DIG = GetModConfigData("Digornot")
GLOBAL.TUNING.HUAMINISIGN_SKIN = GetModConfigData("ChangeSkin")

---inventoryitem
local inventoryItemAtlasLookup = {}

local function GetAtlas(imagename)
	local atlas = inventoryItemAtlasLookup[imagename]
	if atlas then
		return atlas
	end
	local base_atlas = "images/inventoryimages1.xml"
	atlas = GLOBAL.TheSim:AtlasContains(base_atlas, imagename) and base_atlas or "images/inventoryimages2.xml"
	inventoryItemAtlasLookup[imagename] = atlas
	return atlas
end
AddClassPostConstruct( "components/inventoryitem_replica", function(self, inst)
	local old_SetAtlas = self.SetAtlas
	function self:SetAtlas(atlasname)
		if old_SetAtlas	~= nil then
			old_SetAtlas(self,atlasname)
		end
		self._huastrings = atlasname ~= nil and GLOBAL.resolvefilepath(atlasname) or ""
	end

	function self:GetHuaAtlas()
		return self._huastrings ~= nil and
			self._huastrings ~= "" and
			self._huastrings or
			self:GetAtlas()
	end
end)

----================为了删掉上个旧版本写错的木牌===
local function onloadpostpass(inst, newents, savedata)
    if savedata ~= nil then
        if savedata.huachest ~= nil and newents[savedata.huachest] ~= nil then
			inst:DoTaskInTime(0, inst.Remove)
        end
    end
end
AddPrefabPostInit("minisign", function(inst)
    if not GLOBAL.TheWorld.ismastersim then
        return inst
    end
	local oldOnLoadPostPass = inst.OnLoadPostPass
	inst.OnLoadPostPass = function(inst, newents, savedata)
		if oldOnLoadPostPass ~= nil then
			oldOnLoadPostPass(inst, newents, savedata)
		end
		onloadpostpass(inst, newents, savedata)
	end
end)
-----------------修复垃圾代码完成=============================


local function draw(inst)

	if not GLOBAL.TheWorld.ismastersim then
		return inst
	end
	inst:AddComponent("smart_minisign")
end

AddPrefabPostInit("treasurechest", draw)

if GetModConfigData("DragonflyChest") == true then
	AddPrefabPostInit("dragonflychest", draw)
end
if GetModConfigData("Icebox") == true then
	AddPrefabPostInit("icebox", draw)
end
if GetModConfigData("SaltBox") == true then
	AddPrefabPostInit("saltbox", draw)
end

--读取所有已加载的mod
local enabledmods = GLOBAL.ModManager.enabledmods

local thisname = env.modname
--hook一下加载prefabs 加载完prefabs在检索数据
local oldRegisterPrefabs = GLOBAL.ModManager.RegisterPrefabs

GLOBAL.ModManager.RegisterPrefabs = function(self)
	oldRegisterPrefabs(self)

	for i,modname in ipairs(enabledmods) do
		local mod = GLOBAL.ModManager:GetMod(modname)

		--检索 modmain里注册的资源
		if mod.Assets then
			local modatlas = {}
			local modatlas_build = {}
			--检索所有的贴图
			for k,v in ipairs (mod.Assets) do
				if v.type == "ATLAS" then
					table.insert(modatlas,v.file)
				elseif v.type == "ATLAS_BUILD" then
					table.insert(modatlas_build,v.file)
				end

			end
			--判断是否有对应的ATLAS_BUILD
			for k,v in ipairs(modatlas) do
				local notfind = true
				for x,y in ipairs(modatlas_build) do
					if v == y then
						notfind = false
						break
					end
				end
				if notfind then
				--没有就插入
				--因为注册的时候会自动搜索路径，所以自己注册的时候要还原回原来的路径
				v = string.gsub(v,"%.%./mods/[^/]+/","",1)
				table.insert(Assets,Asset("ATLAS_BUILD",v,256))
				end
			end
		end

		--检索 prefabs 里注册的资源
		if mod.Prefabs then
			for n,prefab in pairs(mod.Prefabs) do
				local modatlas = {}
				local modatlas_build = {}
				--检索所有的贴图
				if prefab.assets then
					for k,v in pairs (prefab.assets) do
						if v.type == "ATLAS" then
							table.insert(modatlas,v.file)
						elseif v.type == "ATLAS_BUILD" then
							table.insert(modatlas_build,v.file)
						end
					end
				end
				--判断是否有对应的ATLAS_BUILD
				for k,v in ipairs(modatlas) do
					local notfind = true
					for x,y in ipairs(modatlas_build) do
						if v == y then
							notfind = false
							break
						end
					end
					if notfind then
					--没有就插入
					v = string.gsub(v,"%.%./mods/[^/]+/","",1)
					table.insert(Assets,Asset("ATLAS_BUILD",v,256))
					end
				end
			end
		end
	end
	--注册资源
	GLOBAL.RegisterPrefabs(GLOBAL.Prefab("MOD_SMARTSIGNOTHER",nil,Assets,nil,true))
	GLOBAL.TheSim:LoadPrefabs({"MOD_SMARTSIGNOTHER"})
	table.insert(self.loadedprefabs,"MOD_SMARTSIGNOTHER")

end

GLOBAL.TUNING.SMART_SIGN_DRAW_ENABLE = true
GLOBAL.SMART_SIGN_DRAW = draw
--示例代码  
--[[
if TUNING.SMART_SIGN_DRAW_ENABLE then
		SMART_SIGN_DRAW(inst)
	end
	]]--