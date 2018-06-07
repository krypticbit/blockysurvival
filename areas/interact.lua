
local old_is_protected = minetest.is_protected
function minetest.is_protected(pos, name)
	if not areas:canInteract(pos, name) then
		return true
	end
	return old_is_protected(pos, name)
end

minetest.register_on_protection_violation(function(pos, name)
	if not areas:canInteract(pos, name) then
		local owners = areas:getNodeOwners(pos)
		minetest.chat_send_player(name,
			("%s is protected by %s."):format(
				minetest.pos_to_string(pos),
				table.concat(owners, ", ")))
		player = minetest.get_player_by_name(name)
		if not player then return end
		player_pos = player:getpos()
		player_pos = vector.round(player_pos)
		if player_pos.y - 1 == pos then
			if minetest.get_node(player_pos).name ~= "air" then
				player_pos.y = player_pos.y - 0.2
			end
			player:set_pos(player_pos)
		end
		player:set_look_horizontal((player:get_look_horizontal() + math.pi) % (math.pi * 2))
		player:set_hp(1)
	end
end)

