
function jails:jail(playerName, jailName)
	jailName = jailName or self.default
	local jail = self.jails[jailName]
	if not jail then
		return false, "Jail does not exist."
	end
	if self:getJail(playerName) then
		return false, "Already jailed."
	end
	if not self:playerExists(playerName) then
		return false, "Player does not exist."
	end
	local pos, message
	local player = minetest.get_player_by_name(playerName)
	if player then
		pos = player:getpos()
		player:setpos(jail.pos)
		if jails.announce then
			minetest.chat_send_all(playerName.." has been jailed!")
		else
			minetest.chat_send_player(playerName, "You have been jailed.")
		end
	else
		message = "That player is not online right now."
				.."  They will be jailed when they next connect."
	end
	jail.captives[playerName] = {
		privs = minetest.get_player_privs(playerName),
		pos = pos,
	}
	minetest.set_player_privs(playerName, {})
	local ok, msg = self:save()
	if not ok then return ok, msg end
	return true, message
end


function jails:unjail(playerName)
	for name, jail in pairs(self.jails) do
		local playerData = jail.captives[playerName]
		if playerData then
			self:release(playerName, playerData)
			jail.captives[playerName] = nil
			return self:save()
		end
	end
	return false, "Player not jailed."
end


function jails:getJail(playerName)
	for jailName, jail in pairs(self.jails) do
		if jail.captives[playerName] then
			return jailName, jail
		end
	end
end


function jails:add(jailName, pos)
	self.jails[jailName] = {
		pos = pos,
		captives = {},
	}
	return self:save()
end


function jails:remove(jailName, newJailName)
	jailName = jailName or self.default
	local jail = self.jails[jailName]
	if not jail then
		return false, "Jail does not exist."
	end
	local newJail
	if newJailName then
		if newJailName == jailName then
			return false, "Cannot replace a jail with itself."
		end
		newJail = self.jails[newJailName]
		if not newJail then
			return false, "Jail to transfer to does not exist."
		end
		for playerName, playerData in pairs(jail.captives) do
			newJail.captives[playerName] = playerData
			local player = minetest.get_player_by_name(playerName)
			if player then
				player:setpos(newJail.pos)
			end
		end
	else
		for playerName, playerData in pairs(jail.captives) do
			self:release(playerName, playerData)
		end
	end
	self.jails[jailName] = nil
	return self:save()
end


local fallbackSpawn = {x=0, y=8, z=0}
function jails:getSpawnPos(oldCaptivePos)
	return oldCaptivePos or minetest.setting_get_pos("static_spawnpoint") or fallbackSpawn
end


function jails:save()
	local dataStr = minetest.serialize(self.jails)
	if not dataStr then
		minetest.log("error", "[jails] Failed to serialize jail data!")
		return false, "Serialization failed!"
	end
	local file, err = io.open(self.filename, "w")
	if err then
		minetest.log("error", "[jails] Failed to open jail file for saving!")
		return false, err
	end
	file:write(dataStr)
	file:close()
	return true
end


function jails:load()
	local file, err = io.open(self.filename, "r")
	if err then return false, err end
	local str = file:read("*a")
	file:close()
	if str == "" then return false, "Jail file is empty!" end
	local jails = minetest.deserialize(str)
	if not jails then return false, "Failed to deserialize jail data!" end
	self.jails = jails
	return true
end

--------------
-- Internal --
--------------

function jails:playerExists(playerName)
	return (minetest.builtin_auth_handler or minetest.auth_handler)
		.get_auth(playerName) and true or false
end

function jails:release(playerName, playerData)
	local player = minetest.get_player_by_name(playerName)
	if player then
		player:setpos(self:getSpawnPos(playerData.pos))
	end
	minetest.set_player_privs(playerName, playerData.privs)
	if self.announce then
		minetest.chat_send_all(playerName.." has been freed from jail!")
	else
		minetest.chat_send_player(playerName, "You have been freed from jail.")
	end
end

