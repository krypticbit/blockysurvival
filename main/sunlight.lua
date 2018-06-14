-- Give players with "settime" priv the ability to override their day-night ratio
minetest.register_chatcommand("sunlight", {
	params = "<ratio>",
	description = "Override one's day night ratio. (1 = always day, 0 = always night)",
	privs = {settime = true},
	func = function(name, param)
		local ratio = tonumber(param)
		minetest.get_player_by_name(name):override_day_night_ratio(ratio)
	end
})
