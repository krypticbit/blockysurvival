minetest.register_on_prejoinplayer(function(name, ip)
	if name:find("%u.*%d%d$") then
		return "Please change your name to not end in numbers"
	end
end)
