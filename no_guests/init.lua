minetest.register_on_prejoinplayer(function(name, ip)
	if name:find("%u.*%d%d%d$") then
		minetest.log("Player with name " .. name .. " was blocked by no_guests")
		return "Please change your name to not end in numbers"
	end
end)
