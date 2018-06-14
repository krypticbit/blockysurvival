local invalid_player = "Invalid player"
local invalid_punishment = "Invalid punishment"

main.punishments = {
	hotfoot = function(pname)
		local p = minetest.get_player_by_name(pname)
		if p then
			local pos = p:get_pos()
			if minetest.get_node(pos).name == "air" then
				minetest.set_node(pos, {name = "fire:basic_flame"})
			end
		end
	end
}

main.punished = {}

minetest.register_globalstep(function(dtime)
	for name, punishment in ipairs(core.punished) do
		punishment.time = punishment.time - dtime
		punishment.timer = punishment.timer + dtime
		if punishment.time < 0 then
			core.punished[name] = nil
			return
		end
		if punishment.timer >= punishment.every then
			punishment.timer = 0
			punishment.func(name)
		end
	end
end)

minetest.register_privilege("punish", "Allows a player to invoke creative punishments on other players")
