-- Faregates
-- Copyright (c) 2017 Gabriel Pérez-Cerezo, see LICENSE file for more details.
-- Nodeboxes generated with NodeBoxEditor.

minetest.register_node("farebox:faregate", {
	tiles = {
	   "default_steel_block.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	description = "Faregate",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.4375, -0.4375, 0.5, 0.4375}, -- NodeBox3
			{0.4375, -0.5, -0.4375, 0.5, 0.5, 0.4375}, -- NodeBox5
			{-0.4375, -0.5, -0.0625, -0.0625, 0.6875, 0}, -- NodeBox6
			{0.0625, -0.5, -0.0625, 0.4375, 0.6875, 0}, -- NodeBox7
		}
	},
	mesecons = {
	   effector = {
	      rules = mesecon.rules.default,
	      action_on = function (pos, node)
		 farebox.open_faregate(pos)
		 minetest.after(1, farebox.close_faregate, pos)
	      end,
	}},
	can_dig = can_dig,
	after_place_node = function(pos, player, _)
	   local meta = minetest.get_meta(pos)
	   local player_name = player:get_player_name()
	   
	   meta:set_string("owner", player_name)
	   meta:set_string("infotext", "Owned by "..player_name)
	   
	   local inv = meta:get_inventory()
	   inv:set_size("request", 1)
	   inv:set_size("main", 32)
	end,
	groups = {cracky=3},
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
	   farebox.show_formspec(pos, player)
	end,
	
})

minetest.register_node("farebox:faregate_open", {			  
	tiles = {
	   "default_steel_block.png"
	},
	paramtype2 = "facedir",
	description = "Open Faregate",
	mesecons = {
	   effector = {
	      rules = mesecon.rules.default,
	      action_on = function (pos, node)
		 farebox.close_faregate(pos)
	      end,
	}},
	groups = {not_in_creative_inventory = 1, cracky=3},
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.4375, -0.4375, 0.5, 0.4375}, -- NodeBox3
			{0.4375, -0.5, -0.4375, 0.5, 0.5, 0.4375}, -- NodeBox5
			{-0.4375, -0.5, -0.0625, -0.375, 0.6875, 0.3125}, -- NodeBox6
			{0.375, -0.5, -0.0625, 0.4375, 0.6875, 0.3125}, -- NodeBox7
		}
	},
	drop = "farebox:faregate"
})

minetest.register_craft({output = "farebox:faregate",
			 recipe = {


			    {"farebox:farebox", "doors:door_steel"},
			 }
})
