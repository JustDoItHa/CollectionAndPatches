local SpawnPrefab = GLOBAL.SpawnPrefab
local TheNet = GLOBAL.TheNet
-- local spawn_chest= false

local function dospawnchest(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/ghost_spawn")

    local chest =SpawnPrefab("minotaurchest")
    local x, y, z = inst.Transform:GetWorldPosition()
    chest.Transform:SetPosition(x, 0, z)

    local fx = SpawnPrefab("statue_transition_2")
    if fx ~= nil then
        fx.Transform:SetPosition(x, y, z)
        fx.Transform:SetScale(1, 2, 1)
    end

    fx = SpawnPrefab("statue_transition")
    if fx ~= nil then
        fx.Transform:SetPosition(x, y, z)
        fx.Transform:SetScale(1, 1.5, 1)
    end

    chest:AddComponent("scenariorunner")
    chest.components.scenariorunner:SetScript("chest_minotaur")
    chest.components.scenariorunner:Run()
end
local function spawnchest(inst)
    inst:DoTaskInTime(3, dospawnchest)
end
local function announce(inst, data)
	if data and data.attacker then
		TheNet:Announce(""..inst:GetDisplayName().." 被 "..data.attacker:GetDisplayName().." 击杀")
	end
end

local function death(inst)
    inst:ListenForEvent("attacked", announce)
end

local bosschest = {"dragonfly","deerclops","bearger","moose"}
for k,v in pairs(bosschest) do
	AddPrefabPostInit(v, function (inst)
		inst:ListenForEvent("death", death)
		inst:ListenForEvent("death", function()
			local radomNum = math.random()
			if radomNum<0.05 then
				inst.components.lootdropper:DropLoot(GLOBAL.Vector3(inst.Transform:GetWorldPosition()))
				inst.components.lootdropper:DropLoot(GLOBAL.Vector3(inst.Transform:GetWorldPosition()))
				inst.components.lootdropper:DropLoot(GLOBAL.Vector3(inst.Transform:GetWorldPosition()))
			elseif radomNum<0.2 then
				inst.components.lootdropper:DropLoot(GLOBAL.Vector3(inst.Transform:GetWorldPosition()))
				inst.components.lootdropper:DropLoot(GLOBAL.Vector3(inst.Transform:GetWorldPosition()))
			elseif radomNum<0.5 then
				inst.components.lootdropper:DropLoot(GLOBAL.Vector3(inst.Transform:GetWorldPosition()))
			end
		end)
		-- if spawn_chest then
		-- 	inst:ListenForEvent("death", spawnchest)
		-- end
	end)
end

AddPrefabPostInit("leif", function (inst)
	inst:ListenForEvent("death", death)
	inst:ListenForEvent("death", function()
		if math.random()<0.5 then
			inst.components.lootdropper:DropLoot(GLOBAL.Vector3(inst.Transform:GetWorldPosition()))
		end
	end)
end)

AddPrefabPostInit("spiderqueen", function (inst)
	inst:ListenForEvent("death", death)
	inst:ListenForEvent("death", function()	
		if math.random()<0.5 then
		    inst.components.lootdropper:DropLoot(GLOBAL.Vector3(inst.Transform:GetWorldPosition()))
		end
	end)
end)

AddPrefabPostInit("minotaurchest",function(inst)
	if not GLOBAL.TheWorld:HasTag("cave") then
		inst:DoPeriodicTask(60,function()
			if inst.components.container then
				local was_open = inst.components.container:IsOpen()
				if not inst:IsAsleep() then
					if not was_open then
						inst.components.container:Close()
						inst.components.container:DropEverything()
						inst:Remove()
					end
				end
			end
		end)
	end
end)