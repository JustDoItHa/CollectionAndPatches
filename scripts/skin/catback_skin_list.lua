GLOBAL.setmetatable(env,{__index = function(t, k)return GLOBAL.rawget(GLOBAL,k)end,})

modimport("scripts/skin/skinsapi.lua")--调用皮肤api  来自穹

local item_list =            --有皮肤的物品代码
{
"catback"
}

local catback_skin_list =            --对应的皮肤
{
	--{"catback","catback","猫猫","idle"},
	{"catback","cbdz0","恶魔之翼","anim"},
	{"catback","cbdz1","信仰之翼","anim"},
	{"catback","cbdz2","炎热之火","anim"},
	{"catback","cbdz3","电光飞驰","anim"},
	{"catback","cbdz4","湛蓝天空","anim"},
	{"catback","cbdz5","炎魔之翼","anim"},
	{"catback","cbdz6","魅惑之光","anim"},
	{"catback","cbdz7","阿波罗","anim"},
	{"catback","cbdz8","紫蝶","anim"}
}



--开始注册:
for k,v in pairs (item_list) do  --注册默认皮肤
	MakeItemSkinDefaultData(v,{atlas="images/inventoryimages/"..v..".xml",image=v},{bank=v,build=v,anim="idle",animloop=false})
end

for k,v in pairs (catback_skin_list) do
	MakeItemSkin( v[1], v[2],--原名和皮肤名
    {
		basebuild = v[1],    --原物品scml文件名字
		basebank = v[1],
		rarity = v[3], --珍惜度:没有什么意义,是啥都行,可以随便编一个
		type = "item",       --类别
		name = v[3],         --填皮肤的名称:经典,小熊,小猫,小狗什么的
		atlas = "images/inventoryimages/"..v[2]..".xml",  --制作栏的图片
		image = v[2],
		build = v[2],
		bank = v[2],
		anim = v[4],
    })
end