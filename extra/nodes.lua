-- extra mod
-- by dhausmig
-- consisting of many different things
---------------------------------------------------------------
if extra.condensed and extra.comp and extra.cond then
   minetest.register_node("extra:cobble_condensed", {
	   description = S("Condensed Cobblestone"),
   	tiles = {"moreblocks_cobble_compressed.png^[colorize:black:255]"},
	   is_ground_content = false,
   	groups = {cracky = 1, stone = 2},
      stack_max = 999,
   	sounds = default.node_sound_stone_defaults(),
   })
end
if extra.liquor then
   minetest.register_node("extra:tequila", {
	   description = S("Bottle of Tequila"),
   	drawtype = "plantlike",
	   tiles = {"extra_tequila.png"},
   	inventory_image = "extra_tequila.png",
	   wield_image = "extra_tequila.png",
   	paramtype = "light",
	   is_ground_content = false,
   	walkable = false,
	   selection_box = {
		   type = "fixed",
   		fixed = {-0.25, -0.5, -0.25, 0.25, 0.3, 0.25}
	   },
   	groups = {vessel = 1, dig_immediate = 3, attached_node = 1},
	   sounds = default.node_sound_glass_defaults(),
      on_use = minetest.item_eat(10, "vessels:glass_bottle"),
   })

   minetest.register_node("extra:rum", {
	   description = S("Bottle of Rum"),
   	drawtype = "plantlike",
	   tiles = {"extra_rum.png"},
   	inventory_image = "extra_rum.png",
	   wield_image = "extra_rum.png",
   	paramtype = "light",
	   is_ground_content = false,
   	walkable = false,
	   selection_box = {
		   type = "fixed",
   		fixed = {-0.25, -0.5, -0.25, 0.25, 0.3, 0.25}
	   },
   	groups = {vessel = 1, dig_immediate = 3, attached_node = 1},
	   sounds = default.node_sound_glass_defaults(),
      on_use = minetest.item_eat(10, "vessels:glass_bottle"),
   })
end
