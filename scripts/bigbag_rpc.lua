--代码来自恒子大佬的能力勋章
--存储容器坐标RPC
AddModRPCHandler(
	"Bigbag",
	"Bigbag_SetDragPos",
	function(player, bigbag_drag_pos)
		player.bigbag_drag_pos:set(bigbag_drag_pos)
		--重置容器位置
		if bigbag_drag_pos=="" and player.components.inventory and player.components.inventory.opencontainers then
			for k, v in pairs(player.components.inventory.opencontainers) do
				if k.components.container then
					k.components.container:Close()
					k.components.container:Open(player)
				end
			end
		end
	end
)

-- --特有容器列表(封装在表里方便做兼容)
local special_bigbag_box={
	bigbag=true,--大背包
	nicebigbag=true,--便携箱
	redbigbag=true,
	bluebigbag=true,
}

--代码来自恒子大佬的能力勋章
--修改容器界面，兼容融合模式
AddClassPostConstruct("screens/playerhud", function(self)
    local ContainerWidget = require("widgets/containerwidget")
	local oldOpenContainer=self.OpenContainer
	local oldCloseContainer=self.CloseContainer
	
	--容器
	local function OpenBigbagWidget(self, container,side)
		local containerwidget = ContainerWidget(self.owner)
		local parent = side and self.controls.containerroot_side 
						or self.controls.containerroot

		parent:AddChild(containerwidget)
		
		containerwidget:MoveToBack()
		containerwidget:Open(container, self.owner)
		self.controls.containers[container] = containerwidget
	end
	--打开容器
    self.OpenContainer = function(self,container, side)
		if container == nil then
			return
		end
		--print(container.prefab)
		--走自己的容器逻辑
		if special_bigbag_box[container.prefab] then
			OpenBigbagWidget(self,container,side)
			--print("true")
			return
		end
		oldOpenContainer(self,container, side)
    end
	--关闭容器
    self.CloseContainer = function(self,container, side)
		if container == nil then
			return
		end
		--把side参数设为false，让盒子正常关闭
		if side and special_bigbag_box[container.prefab] then
			side=false
		end
		oldCloseContainer(self,container, side)
    end
end)