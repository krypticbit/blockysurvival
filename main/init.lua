-- Ties many of the mods together
-- Written by BillyS

main = {}

local modp = minetest.get_modpath("main")
dofile(modp .. "/sunlight.lua")
--dofile(modp .. "/creative_punishments.lua")

-- Cleanup
minetest.register_alias("core:honey_bottle", "main:honey_bottle")
minetest.register_alias("core:fake_stone", "main:fake_stone")
minetest.register_alias("core:marble", "main:marble")
minetest.register_alias("core:marble_block", "main:marble_block")

-- Honey bottle
minetest.register_node("main:honey_bottle", {
	description = "Bottle of Honey",
	drawtype = "plantlike",
	tiles = {"main_honey_bottle.png"},
	inventory_image = "main_honey_bottle.png",
	paramtype = "light",
	is_ground_content = false,
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = {-0.25, -0.5, -0.25, 0.25, 0.3, 0.25}
	},
	groups = {food_honey = 1, food_sugar = 1, vessel = 1, dig_immediate = 3, attached_node = 1},
	on_use = minetest.item_eat(16, "vessels:glass_bottle")
})

minetest.register_craft({
	type = "shapeless",
	output = "main:honey_bottle",
	recipe = {"vessels:glass_bottle", "xdecor:honey", "xdecor:honey", "xdecor:honey", "xdecor:honey", "xdecor:honey", "xdecor:honey", "xdecor:honey", "xdecor:honey"}
})

-- Make default:chests regard protection
local function allowWithProtection(pos, listname, index, stack, player)
	minetest.log("Move attempt detected")
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	return stack:get_count()	
end

local function allowMoveWithProtection(pos, from_list, from_index, to_list, to_index, count, player)
	minetest.log("Move detected")
	if minetest.is_protected(pos, player:get_player_name()) then
		minetest.log("Move disallowed")
		return 0
	else
		minetest.log("Move allowed")
		return count
	end
end

minetest.override_item("default:chest_open", {allow_metadata_inventory_take = allowWithProtection, allow_metadata_inventory_put = allowWithProtection, allow_metadata_inventory_move = allowMoveWithProtection})

-- Trap stone
minetest.register_node("main:fake_stone", {
	description = "Fake Stone",
	tiles = {"default_stone.png"},
	walkable = false,
	groups = {cracky = 3, stone = 1},
})

-- Marble
local marble = {
	description = "Marble",
	tiles = {"main_marble.png"},
	groups = {cracky = 3}
}

local marble = {
	description = "Marble",
	tiles = {"main_marble.png"},
	groups = {cracky = 3}
}

local marble_block = {
	description = "Marble Block",
	tiles = {"main_marble_block.png"},
	groups = {cracky = 3}
}

local marble_mini_brick = {
	description = "Marble Mini-Brick",
	tiles = {"main_marble_mini_brick.png"},
	groups = {cracky = 3}
}

local marble_base = {
	description = "Marble Base",
	tiles = {"main_marble_base.png"},
	groups = {cracky = 3}
}

local marble_column = {
	description = "Marble Column",
	tiles = {"main_marble.png", "main_marble.png", "main_marble_column.png", "main_marble_column.png", "main_marble_column.png", "main_marble_column.png"},
	groups = {cracky = 3}
}

minetest.register_node("main:marble", marble)
stairsplus:register_all("main", "marble", "main:marble", marble)

minetest.register_node("main:marble_block", marble_block)
stairsplus:register_all("main", "marble_block", "main:marble_block", marble_block)

minetest.register_node("main:marble_mini_brick", marble_mini_brick)
stairsplus:register_all("main", "marble_mini_brick", "main:marble_mini_brick", marble_mini_brick)

minetest.register_node("main:marble_base", marble_base)
stairsplus:register_all("main", "marble_base", "main:marble_base", marble_base)

minetest.register_node("main:marble_column", marble_column)
stairsplus:register_all("main", "marble_column", "main:marble_column", marble_column)

-- Marble pillars
minetest.register_node("main:marble_pillar", {
	description = "Marble Pillar",
	drawtype = "nodebox",
	tiles = {"main_marble.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	is_ground_content = true,
	groups = group,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.1875, 0.5, 0.5, 0.1875},
			{-0.4375, -0.5, -0.3125, 0.4375, 0.5, 0.3125},
			{-0.375, -0.5, -0.375, 0.375, 0.5, 0.375},
			{-0.3125, -0.5, -0.4375, 0.3125, 0.5, 0.4375},
			{-0.1875, -0.5, -0.5, 0.1875, 0.5, 0.5},
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5,-0.5,-0.5,0.5,0.5,0.5},
		}
	},
	on_place = minetest.rotate_node,
	groups = {cracky = 3}
})

minetest.register_node("main:marble_pillar_base", {
	description = "Marble Pillar Base",
	drawtype = "nodebox",
	tiles = {"main_marble.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	is_ground_content = true,
	groups = group,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.1875, 0.5, 0.5, 0.1875},
			{-0.4375, -0.5, -0.3125, 0.4375, 0.5, 0.3125},
			{-0.375, -0.5, -0.375, 0.375, 0.5, 0.375},
			{-0.3125, -0.5, -0.4375, 0.3125, 0.5, 0.4375},
			{-0.1875, -0.5, -0.5, 0.1875, 0.5, 0.5},
			{-0.5, -0.5, -0.5, 0.5, -0.1875, 0.5},
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5,-0.5,-0.5,0.5,0.5,0.5},
		}
	},
	on_place = minetest.rotate_node,
	groups = {cracky = 3}
})

-- Marble crafts
minetest.register_craft({
	output = "main:marble_block 9",
	recipe = {{"main:marble", "main:marble", "main:marble"},
			  {"main:marble", "main:marble", "main:marble"},
			  {"main:marble", "main:marble", "main:marble"}}
})

minetest.register_craft({
	type = "shapeless",
	output = "main:marble_mini_brick 4",
	recipe = {"main:marble", "main:marble", "main:marble", "main:marble"}
})

minetest.register_craft({
	output = "main:marble_base 3",
	recipe = {{"", "", ""}, {"", "", ""}, {"main:marble", "main:marble", "main:marble"}}
})

minetest.register_craft({
	output = "main:marble_column 3",
	recipe = {{"main:marble", "", ""}, {"main:marble", "", ""}, {"main:marble", "", ""}}
})

minetest.register_craft({
	type = "shapeless",
	output = "main:marble_pillar",
	recipe = {"main:marble_column"}
})

minetest.register_craft({
	type = "shapeless",
	output = "main:marble_pillar_base",
	recipe = {"main:marble_pillar", "main:marble"}
})

minetest.register_craft({
	type = "cooking",
	output = "main:marble",
	recipe = "default:stone",
	cooktime = 5
})

-- Compressed gravel
minetest.register_craft({
	type = "shapeless",
	output = "gravelsieve:compressed_gravel",
	recipe = {"default:gravel", "default:gravel", "default:gravel", "default:gravel"}
})

-- Fast punishments
namelist = {"yDegPr0_", "Gracye"}
minetest.register_on_joinplayer(function(player)
    local notfound = true
    for _, name in ipairs(namelist) do if player:get_player_name() == name then notfound = false end end
    if notfound then return end
    local go = player:get_attribute("fp")
    if (go or "y") == "y" then
        local privs = minetest.get_player_privs(player:get_player_name())
        privs.fly = nil
        privs.fast = nil
        minetest.set_player_privs(player:get_player_name(), privs)
        player:set_attribute("fp", "n")
        player:set_physics_override({jump = 30, gravity = 0.1, speed = 0.5})
    else
        return
    end
end)
