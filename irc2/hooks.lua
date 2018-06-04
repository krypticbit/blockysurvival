-- This file is licensed under the terms of the BSD 2-clause license.
-- See LICENSE.txt for details.

local ie = ...

-- MIME is part of LuaSocket
local b64e = ie.require("mime").b64

irc2.hooks = {}
irc2.registered_hooks = {}


local stripped_chars = "[\2\31]"

local function normalize(text)
	-- Strip colors
	text = text:gsub("\3[0-9][0-9,]*", "")

	return text:gsub(stripped_chars, "")
end


function irc2.doHook(conn)
	for name, hook in pairs(irc2.registered_hooks) do
		for _, func in pairs(hook) do
			conn:hook(name, func)
		end
	end
end


function irc2.register_hook(name, func)
	irc2.registered_hooks[name] = irc2.registered_hooks[name] or {}
	table.insert(irc2.registered_hooks[name], func)
end


function irc2.hooks.raw(line)
	if irc2.config.debug then
		print("RECV: "..line)
	end
end


function irc2.hooks.send(line)
	if irc2.config.debug then
		print("SEND: "..line)
	end
end


function irc2.hooks.chat(msg)
	local channel, text = msg.args[1], msg.args[2]
	if text:sub(1, 1) == string.char(1) then
		irc2.conn:invoke("OnCTCP", msg)
		return
	end

	if channel == irc2.conn.nick then
		irc2.last_from = msg.user.nick
		irc2.conn:invoke("PrivateMessage", msg)
	else
		irc2.last_from = channel
		irc2.conn:invoke("OnChannelChat", msg)
	end
end


local function get_core_version()
	local status = minetest.get_server_status()
	local start_pos = select(2, status:find("version=", 1, true))
	local end_pos = status:find(",", start_pos, true)
	return status:sub(start_pos + 1, end_pos - 1)
end


function irc2.hooks.ctcp(msg)
	local text = msg.args[2]:sub(2, -2)  -- Remove ^C
	local args = text:split(' ')
	local command = args[1]:upper()

	local function reply(s)
		irc2.queue(irc2.msgs.notice(msg.user.nick,
				("\1%s %s\1"):format(command, s)))
	end

	if command == "ACTION" and msg.args[1] == irc2.config.channel then
		local action = text:sub(8, -1)
		irc2.sendLocal(("* %s@freenode %s"):format(msg.user.nick, action))
	elseif command == "VERSION" then
		reply(("Minetest version %s, IRC mod version %s.")
			:format(get_core_version(), irc2.version))
	elseif command == "PING" then
		reply(args[2])
	elseif command == "TIME" then
		reply(os.date())
	end
end


function irc2.hooks.channelChat(msg)
	local text = normalize(msg.args[2])

	irc2.check_botcmd(msg)

	-- Don't let a user impersonate someone else by using the nick "IRC"
	local fake = msg.user.nick:lower():match("^[il|]rc$")
	if fake then
		irc2.sendLocal("<"..msg.user.nick.."@freenode> "..text)
		return
	elseif msg.user.nick == "BlockyRelay" then
		return
	end

	-- Support multiple servers in a channel better by converting:
	-- "<server@IRC> <player> message" into "<player@server> message"
	-- "<server@IRC> *** player joined/left the game" into "*** player joined/left server"
	-- and "<server@IRC> * player orders a pizza" into "* player@server orders a pizza"
	local foundchat, _, chatnick, chatmessage =
		text:find("^<([^>]+)> (.*)$")
	local foundjoin, _, joinnick =
		text:find("^%*%*%* ([^%s]+) joined the game$")
	local foundleave, _, leavenick =
		text:find("^%*%*%* ([^%s]+) left the game$")
	local foundaction, _, actionnick, actionmessage =
		text:find("^%* ([^%s]+) (.*)$")

	if text:sub(1, 5) == "[off]" then
		return
	elseif foundchat then
		irc2.sendLocal(("<%s@%s> %s")
				:format(chatnick, msg.user.nick, chatmessage))
	elseif foundjoin then
		irc2.sendLocal(("*** %s joined %s")
				:format(joinnick, msg.user.nick))
	elseif foundleave then
		irc2.sendLocal(("*** %s left %s")
				:format(leavenick, msg.user.nick))
	elseif foundaction then
		irc2.sendLocal(("* %s@%s %s")
				:format(actionnick, msg.user.nick, actionmessage))
	else
		irc2.sendLocal(("<%s@freenode> %s"):format(msg.user.nick, text))
	end
end


function irc2.hooks.pm(msg)
	-- Trim prefix if it is found
	local text = msg.args[2]
	local prefix = irc2.config.command_prefix
	if prefix and text:sub(1, #prefix) == prefix then
		text = text:sub(#prefix + 1)
	end
	irc2.bot_command(msg, text)
end


function irc2.hooks.kick(channel, target, prefix, reason)
	if target == irc2.conn.nick then
		minetest.chat_send_all("IRC: kicked from "..channel.." (freenode) by "..prefix.nick..".")
		irc2.disconnect("Kicked")
	else
		irc2.sendLocal(("-!- %s was kicked from %s (freenode) by %s [%s]")
				:format(target, channel, prefix.nick, reason))
	end
end


function irc2.hooks.notice(user, target, message)
	if user.nick and target == irc2.config.channel then
		irc2.sendLocal("-"..user.nick.."@freenode- "..message)
	end
end


function irc2.hooks.mode(user, target, modes, ...)
	local by = ""
	if user.nick then
		by = " by "..user.nick
	end
	local options = ""
	if select("#", ...) > 0 then
		options = " "
	end
	options = options .. table.concat({...}, " ")
	minetest.chat_send_all(("-!- mode/%s [%s%s]%s")
			:format(target, modes, options, by))
end


function irc2.hooks.nick(user, newNick)
	irc2.sendLocal(("-!- %s is now known as %s")
			:format(user.nick, newNick))
end


function irc2.hooks.join(user, channel)
	irc2.sendLocal(("-!- %s joined %s (freenode)")
			:format(user.nick, channel))
end


function irc2.hooks.part(user, channel, reason)
	reason = reason or ""
	irc2.sendLocal(("-!- %s has left %s (freenode) [%s]")
			:format(user.nick, channel, reason))
end


function irc2.hooks.quit(user, reason)
	irc2.sendLocal(("-!- %s has quit freenode [%s]")
			:format(user.nick, reason))
end


function irc2.hooks.disconnect(_, isError)
	irc2.connected = false
	if isError then
		minetest.log("error",  "IRC: Error: Disconnected, reconnecting in one minute.")
		minetest.chat_send_all("IRC: Error: Disconnected, reconnecting in one minute.")
		minetest.after(60, irc2.connect, irc2)
	else
		minetest.log("action", "IRC: Disconnected.")
		minetest.chat_send_all("IRC: Disconnected.")
	end
end


function irc2.hooks.preregister(conn)
	if not (irc2.config["sasl.user"] and irc2.config["sasl.pass"]) then return end
	local authString = b64e(
		("%s\x00%s\x00%s"):format(
		irc2.config["sasl.user"],
		irc2.config["sasl.user"],
		irc2.config["sasl.pass"])
	)
	conn:send("CAP REQ sasl")
	conn:send("AUTHENTICATE PLAIN")
	conn:send("AUTHENTICATE "..authString)
	conn:send("CAP END")
end


irc2.register_hook("PreRegister",     irc2.hooks.preregister)
irc2.register_hook("OnRaw",           irc2.hooks.raw)
irc2.register_hook("OnSend",          irc2.hooks.send)
irc2.register_hook("DoPrivmsg",       irc2.hooks.chat)
irc2.register_hook("OnPart",          irc2.hooks.part)
irc2.register_hook("OnKick",          irc2.hooks.kick)
irc2.register_hook("OnJoin",          irc2.hooks.join)
irc2.register_hook("OnQuit",          irc2.hooks.quit)
irc2.register_hook("NickChange",      irc2.hooks.nick)
irc2.register_hook("OnCTCP",          irc2.hooks.ctcp)
irc2.register_hook("PrivateMessage",  irc2.hooks.pm)
irc2.register_hook("OnNotice",        irc2.hooks.notice)
irc2.register_hook("OnChannelChat",   irc2.hooks.channelChat)
irc2.register_hook("OnModeChange",    irc2.hooks.mode)
irc2.register_hook("OnDisconnect",    irc2.hooks.disconnect)

