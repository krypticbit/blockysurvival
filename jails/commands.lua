
local posMatch =
		"(-?%d+)[%s%,]+"..
		"(-?%d+)[%s%,]+"..
		"(-?%d+)"
local jailNameMatch = "[%*A-Za-z0-9_%-%.][A-Za-z0-9_%-%.]*"

local function normalizeJailName(jailName)
	return jailName ~= "*" and jailName or jails.default
end


minetest.register_chatcommand("jail", {
	params = "[Player] [Jail]",
	description = "Jail a player.",
	privs = {jailer=true},
	func = function(name, param)
		if param == "" then
			return jails:jail(name)
		end
		local playerName, jailName = param:match("^(%S+)%s("..jailNameMatch..")$")
		if playerName then
			return jails:jail(playerName, normalizeJailName(jailName))
		elseif jails:playerExists(param) then
			return jails:jail(param)
		end
		local jailName = normalizeJailName(param)
		if jails.jails[jailName] then
			return jails:jail(name, jailName)
		end
		return false, "That jail/player does not exist."
	end
})


minetest.register_chatcommand("unjail", {
	params = "[Player]",
	description = "Unjail a player or yourself",
	privs = {jailer=true},
	func = function(name, param)
		if param == "" then
			if jails:getJail(name) then
				jails:unjail(name)
				return true, "You are no longer jailed."
			else
				return false, "You are not jailed."
			end
		end
		local ok, message = jails:unjail(param)
		if not ok then return ok, message end
		message = ("Player %q let free."):format(param)
		if not minetest.get_player_by_name(param) then
			message = message .. "  The unjailed player is not "..
				"online now, they will be removed from the "..
				"jail roster but not moved out of the jail."
		end
		return true, message
	end,
})


minetest.register_chatcommand("add_jail", {
	params = "[jail] [X Y Z|X,Y,Z]",
	description = "Adds a new jail at your coordinates or the ones specified.",
	privs = {jailer=true},
	func = function(name, param)
		local errMustBeConnected = "You must be connected to use this command without a position."
		if param == "" then
			local player = minetest.get_player_by_name(name)
			if not player then return false, errMustBeConnected end
			if jails.jails[jails.default] then
				return false, "The default jail already exists."
			end
			local pos = vector.round(player:getpos())
			jails:add(jails.default, pos)
			return true, ("Default jail added at %s.")
				:format(minetest.pos_to_string(pos))
		end
		local jailName, x, y, z = param:match(
				"^("..jailNameMatch..")%s"..posMatch.."$")
		if not jailName then
			x, y, z = param:match("^"..posMatch.."$")
		else
			jailName = normalizeJailName(jailName)
		end
		x, y, z = tonumber(x), tonumber(y), tonumber(z)
		local pos = vector.new(x, y, z)

		-- If they typed the name and coordinates
		if jailName then
			if jails.jails[jailName] then
				return false, "Jail already exists."
			end
			jails:add(jailName, pos)
			return true, ("Jail added at %s.")
					:format(minetest.pos_to_string(pos))
		-- If they just typed the jail name
		elseif param:find("^"..jailNameMatch.."$") then
			jailName = normalizeJailName(param)
			if jails.jails[jailName] then
				return false, "Jail already exists!"
			end
			local player = minetest.get_player_by_name(name)
			if not player then return false, errMustBeConnected end
			pos = vector.round(player:getpos())
			jails:add(jailName, pos)
			return true, ("Jail added at %s.")
					:format(minetest.pos_to_string(pos))
		-- If they just typed the coordinates
		elseif x then
			if jails.jails[jails.default] then
				return false, "The default jail already exists!"
			end
			local ok, err = jails:add(jails.default, pos)
			if not ok then return false, err end
			return true, ("Default jail added at %s.")
					:format(minetest.pos_to_string(pos))
		end
		return false, ("Invalid jail name (%s allowed).")
				:format(jailNameMatch)
	end
})


minetest.register_chatcommand("remove_jail", {
	params = "[Jail [NewJail]]",
	description = "Remove a jail, unjailing all players in it or moving them to a new jail.",
	privs = {jailer=true},
	func = function(name, param)
		if param == "" then
			local ok, err = jails:remove()
			if not ok then return false, err end
			return true, "Default jail removed."
		end
		local oldJailName, newJailName = param:match("^("..jailNameMatch
				..")%s("..jailNameMatch..")$")
		if oldJailName then
			oldJailName, newJailName = normalizeJailName(oldJailName), normalizeJailName(newJailName)
			local ok, err = jails:remove(oldJailName, newJailName)
			if not ok then return false, err end
			return true, "Jail replaced."
		end
		oldJailName = normalizeJailName(param)
		if jails.jails[oldJailName] then
			local ok, err = jails:remove(oldJailName)
			if not ok then return false, err end
			return true, "Jail removed."
		end
		return false, ("Invalid jail name(s). (%s allowed).")
				:format(jailNameMatch)
	end
})


minetest.register_chatcommand("list_jails", {
	params = "[Jail]",
	description = "Prints information on all jails or a specific jail.",
	func = function(name, param)
		local function formatJail(name, data)
			local captiveNames = {}
			for captiveName in pairs(data.captives) do
				table.insert(captiveNames, captiveName)
			end
			return ("%s %s: %s"):format(
					name ~= jails.default and name or "<Default>",
					minetest.pos_to_string(data.pos),
					table.concat(captiveNames, ", ")
				)
		end
		if param == "" then
			local t = {"List of all jails:"}
			for jailName, data in pairs(jails.jails) do
				table.insert(t, formatJail(jailName, data))
			end
			return true, table.concat(t, "\n")
		end
		local jailName = normalizeJailName(param)
		if jails.jails[jailName] then
			return true, formatJail(jailName, jails.jails[jailName])
		end
		return false, "Jail does not exist."
	end
})


minetest.register_chatcommand("move_jail", {
	params = "[Jail] [X Y Z|X,Y,Z]",
	description = "Moves a jail.",
	privs = {jailer=true},
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if not player then return end
		local function doMove(jailName, pos)
			local jail = jails.jails[jailName]
			jail.pos = pos
			for name, data in pairs(jail.captives) do
				local player = minetest.get_player_by_name(data)
				if player then
					player:setpos(jails:getSpawnPos(data.pos))
				end
			end
			jails:save()
		end
		if param == "" then
			if not jails.jails[jails.default] then
				return false, "The default jail does not exist yet!"
			end
			local pos = vector.round(player:getpos())
			doMove(jails.default, pos)
			return true, ("Default jail moved to %s.")
					:format(minetest.pos_to_string(pos))
		end

		local jailName, x, y, z = param:match("^("..jailNameMatch
				..")%s"..posMatch.."$")
		if not jailName then
			x, y, z = param:match("^"..posMatch.."$")
		end
		x, y, z = tonumber(x), tonumber(y), tonumber(z)
		local pos = vector.new(x, y, z)

		-- If they typed the name and coordinates
		if jailName then
			jailName = normalizeJailName(jailName)
			if not jails.jails[jailName] then
				return false, "Jail does not exist."
			end
			doMove(jailName, pos)
			return true, ("Jail moved to %s.")
					:format(minetest.pos_to_string(pos))
		-- If they just typed the jail name
		end
		jailName = normalizeJailName(param)
		if jails.jails[jailName] then
			local pos = vector.round(player:getpos())
			doMove(jailName, pos)
			return true, ("Jail moved to %s")
				:format(minetest.pos_to_string(pos))
		-- If they just typed the coordinates
		elseif x then
			if not jails.jails[jails.default] then
				return false, "The default jail does not exist yet!"
			end
			doMove(jails.default, pos)
			return true, ("Default jail moved to %s.")
					:format(minetest.pos_to_string(pos))
		end
		return false, ("Invalid jail name (%s allowed).")
				:format(jailNameMatch)
	end
})

