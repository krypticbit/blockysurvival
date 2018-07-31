minetest.register_craft({
	output = "goldtools:goldpick",
	recipe = {
		{"default:gold_ingot", "default:gold_ingot", "default:gold_ingot"},
		{"", "group:stick", ""},
		{"", "group:stick", ""}
	}
})
minetest.register_craft({
	output = "goldtools:goldshovel",
	recipe = {
		{"", "default:gold_ingot", ""},
		{"", "group:stick", ""},
		{"", "group:stick", ""}
	}
})
minetest.register_craft({
	output = "goldtools:goldaxe",
	recipe = {
		{"", "default:gold_ingot", "default:gold_ingot"},
		{"", "default:gold_ingot", ""},
		{"", "group:stick", ""}
	}
})
minetest.register_craft({
	output = "goldtools:goldsword",
	recipe = {
		{"", "default:gold_ingot", ""},
		{"", "default:gold_ingot", ""},
		{"", "group:stick", ""}
	}
})
-- Tools
minetest.register_tool("goldtools:goldpick", {
	description = "Gold Pickaxe",
	inventory_image = "gold_pick.png",
	tool_capabilities = {
		full_punch_interval = 1,
		max_drop_level=3,
		groupcaps={
			cracky = {times={[1]=2.5, [2]=1.3, [3]=0.70}, uses=10, maxlevel=3},
		},
		damage_groups = {fleshy=5},
	},
	sound = {breaks = "default_tool_breaks"},
})
minetest.register_tool("goldtools:goldshovel", {
	description = "Gold Shovel",
	inventory_image = "gold_shovel.png",
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level=3,
		groupcaps={
			crumbly = {times={[1]=1.10, [2]=0.50, [3]=0.20}, uses=10, maxlevel=3},
		},
		damage_groups = {fleshy=4},
	},
	sound = {breaks = "default_tool_breaks"},
})
minetest.register_tool("goldtools:goldaxe", {
	description = "Gold Axe",
	inventory_image = "gold_axe.png",
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level=1,
		groupcaps={
			choppy={times={[1]=2.10, [2]=0.90, [3]=0.50}, uses=10, maxlevel=3},
		},
		damage_groups = {fleshy=6},
	},
	sound = {breaks = "default_tool_breaks"},
})
minetest.register_tool("goldtools:goldsword", {
	description = "Gold Sword",
	inventory_image = "gold_sword.png",
	tool_capabilities = {
		full_punch_interval = 0.9,
		max_drop_level=1,
		groupcaps={
			snappy={times={[1]=1.9, [2]=0.90, [3]=0.25}, uses=15, maxlevel=3},
		},
		damage_groups = {fleshy=8},
	},
	sound = {breaks = "default_tool_breaks"},
})
