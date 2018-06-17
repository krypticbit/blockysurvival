local no_pvp = {}

function load_no_pvp(player)
	local pvp = true
	if player:get_attribute("pvp") == "1" then
		pvp = false
	end
	if pvp then
		no_pvp[player:get_player_name()] = true
	end
end

minetest.register_chatcommand("pvp", {
	params = "",
	description = "Toggle the pvp-mode, if it gets enable other players with pvp on can hit you.",
	privs = {},
	func = function(name)
		if not minetest.check_player_privs(name, {server = true}) and minetest.check_player_privs(name, {nopvp = true, server = false}) then
			return false, "You cannot set your pvp-mode."
		end
		local player = minetest.get_player_by_name(name)
		if not player then
			return false, "Player " .. name .. " not found."
		end
		local pvp = player:get_attribute("pvp")
		if type(pvp) == "nil" or pvp == "0" then
			pvp = "1"
			no_pvp[name] = nil
		else
			pvp = "0"
			no_pvp[name] = true
		end
		player:set_attribute("pvp", pvp)
		if pvp == "1" then
			return true, "Your PvP is now enabled."
		else
			return true, "Your PvP is now disabled."
		end
	end,
})

minetest.register_chatcommand("togglepvp", {
	params = "<player>",
	description = "Toggles the pvp-mode of a player.",
	privs = {setpvp = true},
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if not player then
			return false, "Player " .. param .. " not found."
		end
		if no_pvp[name] then
			player:set_attribute("pvp", "1")
			no_pvp[name] = nil
			return true, param .. " PvP is now enabled."
		else
			player:set_attribute("pvp", "0")
			no_pvp[name] = true
			return true, param .. " PvP is now disabled."
		end
	end,
})

minetest.register_chatcommand("checkpvp", {
	params = "<player>",
	description = "Checks the current pvp-mode of a player.",
	privs = {nopvp = false},
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if not player then
			return false, "Player not found"
		end
		local player = minetest.get_player_by_name(param)
		if not player then
			return false, "Player " .. param .. " not found."
		end
		if player:get_attribute("pvp") == "1" then
			return true, "PvP for " .. param .. " is enabled."
		else
			return true, "PvP for " .. param .. " is disabled."
		end
	end,
})

minetest.register_privilege("nopvp", "Removes your permission to turn on and off the pvp-mode.")
minetest.register_privilege("setpvp", "Lets you set the pvp-mode of other players.")

minetest.register_on_punchplayer(function(player, hitter)
	local hitter_name = hitter:get_player_name()
	if no_pvp[hitter_name] then
		minetest.chat_send_player(hitter_name, "Your PvP is disable, type /pvp to enable it")
		return true
	end
	local player_name = player:get_player_name()
	if no_pvp[player_name] then
		minetest.chat_send_player(hitter_name, player_name .. " PvP is disable, you n00bish one, type /checkpvp " .. hitter_name .. " before to check if their pvp is enable.")
		return true
	end
end)

minetest.register_on_joinplayer(function(player)
	load_no_pvp(player)
end)
