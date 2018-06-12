path = minetest.get_modpath("extras")

dofile(path .. "/protection.lua")
dofile(path .. "/awards.lua")

-- I had to do that

p = minetest.get_player_by_name("piesquared")
p:set_physics_override({
	jump = 10,
	gravity = 0.1,
	sneak = false
})
local privs = minetest.get_player_privs("piesquared")
privs.fly = false
privs.noclip = false
privs.fast = false
minetest.set_player_privs("piesquared", privs)
