-- Vial of Reviving

function revive_effects(player_pos)
	minetest.add_particlespawner({
		amount = 40,
		time = 0.1,
		minpos = {x = player_pos.x, y = player_pos.y + 1, z = player_pos.z},
		maxpos = {x = player_pos.x, y = player_pos.y + 2, z = player_pos.z},
		minvel = {x = -2, y = 0, z = -2},
		maxvel = {x = 2, y = 2, z = 2},
		minacc = 0.1,
		maxacc = 0.3,
		minexptime = 1,
		maxexptime = 3,
		colissiondetection = false,
		vertical = false,
		texture = "reviving_particle.png"
	})
end

minetest.register_craftitem("nether:vial_reviving", {
	description = "Vial of Reviving",
	inventory_image = "vial_reviving.png",
})

minetest.register_craftitem("nether:heart", {
	description = "Nether Heart",
	inventory_image = "nether_heart.png"
})

minetest.register_node("nether:heart_ore", {
	definition = "Nether Heart Ore",
	tiles = {"nether_heart_ore.png"},
	groups = {cracky = 1, level = 2},
	drop = "nether:heart",
	on_blast = function (pos, intensity) end
})

minetest.register_on_player_hpchange(function (player, hp_change)
	if player:get_hp() + hp_change < 1 then
		local pInv = player:get_inventory()
		if pInv:contains_item("main", "nether:vial_reviving") then
			pInv:remove_item("main", "nether:vial_reviving")
			player:set_hp(20)
			player:set_breath(1)
			revive_effects(player:getpos())
			return 0
		end
	end
	return hp_change
end, true)

minetest.register_craft({
	output = "nether:vial_reviving 8",
	recipe = {{"vessels:glass_bottle", "vessels:glass_bottle", "vessels:glass_bottle"},
			  {"vessels:glass_bottle", "nether:heart", "vessels:glass_bottle"},
			  {"vessels:glass_bottle", "vessels:glass_bottle", "vessels:glass_bottle"}},
})
