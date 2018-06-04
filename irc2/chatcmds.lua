-- This file is licensed under the terms of the BSD 2-clause license.
-- See LICENSE.txt for details.

-- Note: This file does NOT conatin every chat command, only general ones.
-- Feature-specific commands (like /join) are in their own files.


minetest.register_chatcommand("irc2_msg", {
	params = "<name> <message>",
	description = "Send a private message to a freenode IRC user",
	privs = {shout=true},
	func = function(name, param)
		if not irc2.connected then
			return false, "Not connected to freenode IRC. Use /irc2_connect to connect."
		end
		local found, _, toname, message = param:find("^([^%s]+)%s(.+)")
		if not found then
			return false, "Invalid usage, see /help irc2_msg."
		end
		local toname_l = toname:lower()
		local validNick = false
		local hint = "They have to be in the channel"
		for nick in pairs(irc2.conn.channels[irc2.config.channel].users) do
			if nick:lower() == toname_l then
				validNick = true
				break
			end
		end
		if toname_l:find("serv$") or toname_l:find("bot$") then
			hint = "it looks like a bot or service"
			validNick = false
		end
		if not validNick then
			return false, "You can not message that user. ("..hint..")"
		end
		irc2.say(toname, irc2.playerMessage(name, message))
		return true, "Message sent!"
	end
})


minetest.register_chatcommand("irc2_names", {
	params = "",
	description = "List the users in freenode IRC.",
	func = function()
		if not irc2.connected then
			return false, "Not connected to freenode IRC. Use /irc2_connect to connect."
		end
		local users = { }
		for nick in pairs(irc2.conn.channels[irc2.config.channel].users) do
			table.insert(users, nick)
		end
		return true, "Users in freenode IRC: "..table.concat(users, ", ")
	end
})


minetest.register_chatcommand("irc2_connect", {
	description = "Connect to the freenode IRC server.",
	privs = {irc2_admin=true},
	func = function(name)
		if irc2.connected then
			return false, "You are already connected to freenode IRC."
		end
		minetest.chat_send_player(name, "IRC: Connecting...")
		irc2.connect()
	end
})


minetest.register_chatcommand("irc2_disconnect", {
	params = "[message]",
	description = "Disconnect from freenode IRC.",
	privs = {irc2_admin=true},
	func = function(name, param)
		if not irc2.connected then
			return false, "Not connected to freenode IRC. Use /irc2_connect to connect."
		end
		if param == "" then
			param = "Manual disconnect by "..name
		end
		irc2.disconnect(param)
	end
})


minetest.register_chatcommand("irc2_reconnect", {
	description = "Reconnect to freenode IRC.",
	privs = {irc2_admin=true},
	func = function(name)
		if not irc2.connected then
			return false, "Not connected to freenode IRC. Use /irc2_connect to connect."
		end
		minetest.chat_send_player(name, "IRC: Reconnecting...")
		irc2.disconnect("Reconnecting...")
		irc2.connect()
	end
})


minetest.register_chatcommand("irc2_quote", {
	params = "<command>",
	description = "Send a raw command freenode IRC.",
	privs = {irc2_admin=true},
	func = function(name, param)
		if not irc2.connected then
			return false, "Not connected to freenode IRC. Use /irc2_connect to connect."
		end
		irc2.queue(param)
		minetest.chat_send_player(name, "Command sent!")
	end
})


local oldme = minetest.chatcommands["me"].func
-- luacheck: ignore
minetest.chatcommands["me"].func = function(name, param, ...)
	irc2.say(("* %s %s"):format(name, param))
	return oldme(name, param, ...)
end

if irc2.config.send_kicks and minetest.chatcommands["kick"] then
	local oldkick = minetest.chatcommands["kick"].func
	-- luacheck: ignore
	minetest.chatcommands["kick"].func = function(name, param, ...)
		local plname, reason = param:match("^(%S+)%s*(.*)$")
		if not plname then
			return false, "Usage: /kick player [reason]"
		end
		irc2.say(("*** Kicked %s.%s"):format(name,
				reason~="" and " Reason: "..reason or ""))
		return oldkick(name, param, ...)
	end
end
