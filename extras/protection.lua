minetest.register_on_protection_violation(function(name, pos)
	player = minetest.get_player_by_name(name)
	if not player then return end
	player_pos = player:getpos()
	player_pos = vector.round(player_pos)
	if player_pos.y - 1 == pos then
		if minetest.get_node(player_pos).name ~= "air" then
			player_pos.y = player_pos.y + 0.5
		end
		player:set_pos(player_pos)
	end
	player:set_look_horizontal((player:get_look_horizontal() + math.pi) % (math.pi * 2))
	player:set_look_vertical((player:get_look_vertical() + math.pi) % (math.pi * 2))
	player:set_hp(player:get_hp() - 1)
end
