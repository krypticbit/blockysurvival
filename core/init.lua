-- Ties many of the mods together
-- Written by BillyS

local modp = minetest.get_modpath("core")
dofile(modp .. "/sunlight.lua")

-- Honey bottle
minetest.register_node("core:honey_bottle", {
	description = "Bottle of Honey",
	drawtype = "plantlike",
	tiles = {"core_honey_bottle.png"},
	inventory_image = "core_honey_bottle.png",
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
	output = "core:honey_bottle",
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
minetest.override_item("default:chest", {allow_metadata_inventory_take = allowWithProtection, allow_metadata_inventory_put = allowWithProtection, allow_metadata_inventory_move = allowMoveWithProtection})

-- Trap stone
minetest.register_node("core:fake_stone", {
	description = "Fake Stone",
	tiles = {"default_stone.png"},
	walkable = false,
	groups = {cracky = 3, stone = 1},
})

-- Marble
local marble = {
	description = "Marble",
	tiles = {"core_marble.png"},
	groups = {cracky = 3}
}

local marble = {
	description = "Marble",
	tiles = {"core_marble.png"},
	groups = {cracky = 3}
}

local marble_block = {
	description = "Marble Block",
	tiles = {"core_marble_block.png"},
	groups = {cracky = 3}
}

minetest.register_node("core:marble", marble)
stairsplus:register_all("core", "marble", "core:marble", marble)

minetest.register_node("core:marble_block", marble_block)
stairsplus:register_all("core", "marble_block", "core:marble_block", marble_block)

minetest.register_craft({
	output = "core:marble_block 9",
	recipe = {{"core:marble", "core:marble", "core:marble"},
			  {"core:marble", "core:marble", "core:marble"},
			  {"core:marble", "core:marble", "core:marble"}}
})

minetest.register_craft({
	type = "cooking",
	output = "core:marble",
	recipe = "default:stone",
	cooktime = 5
})

-- Compressed gravel
minetest.register_craft({
	type = "shapeless",
	output = "gravelsieve:compressed_gravel",
	recipe = {"default:gravel", "default:gravel", "default:gravel", "default:gravel"}
})
