local _G = GLOBAL
local TheNet = _G.TheNet
local IsServer = TheNet:GetIsServer() or TheNet:IsDedicated()

if IsServer then
    -- 防止怪物摧毁建筑
    local cant_destroyby_monster = GetModConfigData("cant_destroyby_monster")
    -- 防止玩家破坏野外猪人房兔人房
    local house_plain_nodestroy = GetModConfigData("house_plain_nodestroy")
    --完整远古祭坛防拆毁
    local ancient_altar_no_destroy = GetModConfigData("ancient_altar_no_destroy")
	--完整蜘蛛巢穴拆毁
    local zhizhu_cuihui = GetModConfigData("zhizhu_cuihui")
    --------------------------------------- 防止摧毁野外猪人房/兔人房/完整远古祭坛 ---------------------------------------
    shelterTable = {
        "rabbithouse", -- 兔人房
        "pighouse", -- 猪人房 
        "mermhouse", -- 鱼人房
        "ancient_altar", -- 完整的远古祭坛
		"spiderhole",    --蜘蛛
		"moonspiderden"
    }

    -- 检查野外房屋的权限 2020.02.14
    function CheckShelterPermission(inst, worker) 
        if inst.ownerlist == nil then 
            if house_plain_nodestroy or ancient_altar_no_destroy or zhizhu_cuihui then 
                -- 管理员直接返回true
                if admin_option and player.Network and player.Network:IsServerAdmin() and test_mode == false then 
                    return true 
					--兔窝                             ---锤子砸 
                elseif house_plain_nodestroy and (inst.prefab == "rabbithouse" or inst.prefab == "pighouse" or inst.prefab == "mermhouse") then 
                    if worker:HasTag("player") then 
                        PlayerSay(worker, GetSayMsg("noadmin_hammer_cant", GetItemOldName(inst)))
                    end
                    return false 
				--限制远古不可摧毁                     ---锤子砸
                elseif ancient_altar_no_destroy and inst.prefab == "ancient_altar" then 
                    if worker:HasTag("player") then 
                        PlayerSay(worker, GetSayMsg("noadmin_hammer_cant", GetItemOldName(inst))) 
                    end
					return false
				--新加限制了蜘蛛巢穴(地下）的摧毁       ---铁镐挖
                elseif zhizhu_cuihui and (inst.prefab =="spiderhole" or inst.prefab =="moonspiderden") then 
                    if worker:HasTag("player") then 
                        PlayerSay(worker, GetSayMsg("noadmin_mine_cant", GetItemOldName(inst))) 
                    end	
                    return false 
                end           
            end 
            return true 
        end 
        return true 
    end 

    -- 移除可燃属性 2020.02.14
    for k, name in pairs(shelterTable) do
        AddPrefabPostInit(
            name, 
            function(inst) 
                if cant_destroyby_monster or house_plain_nodestroy then
                    RemoveBurnable(inst)
                end
            end            
        )
    end
end

