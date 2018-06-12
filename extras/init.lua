path = minetest.get_modpath("extras")

dofile(path .. "/protection.lua")
dofile(path .. "/awards.lua")

-- I had to do that
minetest.register_on_joinplayer(function(player)
	if not player.get_player_name == "piesquared" then return end
	local p = minetest.get_player_by_name("piesquared")
	p:set_physics_override({
		jump = 10,
		gravity = 0.1,
		sneak = false
	})
	local privs = minetest.get_player_privs("piesquared")
	privs.fly = false
	privs.noclip = false
	privs.fast = false
	minetest.chat_send_all(minetest.serialize(privs))
	minetest.set_player_privs("piesquared", privs)
end)
