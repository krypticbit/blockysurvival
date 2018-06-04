-- This file is licensed under the terms of the BSD 2-clause license.
-- See LICENSE.txt for details.

local modpath = minetest.get_modpath(minetest.get_current_modname())

-- Handle mod security if needed
local ie, req_ie = _G, minetest.request_insecure_environment
if req_ie then ie = req_ie() end
if not ie then
	error("The IRC mod requires access to insecure functions in order "..
		"to work.  Please add the irc mod to your secure.trusted_mods "..
		"setting or disable the irc mod.")
end

ie.package.path =
		-- To find LuaIRC's init.lua
		modpath.."/?/init.lua;"
		-- For LuaIRC to find its files
		..modpath.."/?.lua;"
		..ie.package.path

-- The build of Lua that Minetest comes with only looks for libraries under
-- /usr/local/share and /usr/local/lib but LuaSocket is often installed under
-- /usr/share and /usr/lib.
if not rawget(_G, "jit") and package.config:sub(1, 1) == "/" then
	ie.package.path = ie.package.path..
			";/usr/share/lua/5.1/?.lua"..
			";/usr/share/lua/5.1/?/init.lua"
	ie.package.cpath = ie.package.cpath..
			";/usr/lib/lua/5.1/?.so"
end

-- Temporarily set require so that LuaIRC can access it
local old_require = require
require = ie.require

-- Silence warnings about `module` in `ltn12`.
local old_module = rawget(_G, "module")
rawset(_G, "module", ie.module)

local lib = ie.require("irc")

irc2 = {
	version = "0.2.0",
	connected = false,
	cur_time = 0,
	message_buffer = {},
	recent_message_count = 0,
	joined_players = {},
	modpath = modpath,
	lib = lib,
}

-- Compatibility
rawset(_G, "mt_irc2", irc2)

local getinfo = debug.getinfo
local warned = { }

local function warn_deprecated(k)
	local info = getinfo(3)
	local loc = info.source..":"..info.currentline
	if warned[loc] then return end
	warned[loc] = true
	print("COLON: "..tostring(k))
	minetest.log("warning", "Deprecated use of colon notation when calling"
			.." method `"..tostring(k).."` at "..loc)
end

-- This is a hack.
setmetatable(irc2, {
	__newindex = function(t, k, v)
		if type(v) == "function" then
			local f = v
			v = function(me, ...)
				if rawequal(me, t) then
					warn_deprecated(k)
					return f(...)
				else
					return f(me, ...)
				end
			end
		end
		rawset(t, k, v)
	end,
})

dofile(modpath.."/config.lua")
dofile(modpath.."/messages.lua")
loadfile(modpath.."/hooks.lua")(ie)
dofile(modpath.."/callback.lua")
dofile(modpath.."/chatcmds.lua")
dofile(modpath.."/botcmds.lua")

-- Restore old (safe) functions
require = old_require
rawset(_G, "module", old_module)

if irc2.config.enable_player_part then
	dofile(modpath.."/player_part.lua")
else
	setmetatable(irc2.joined_players, {__index = function() return true end})
end

local stepnum = 0

minetest.register_globalstep(function(dtime) return irc2.step(dtime) end)

function irc2.step()
	if stepnum == 3 then
		if irc2.config.auto_connect then
			irc2.connect()
		end
	end
	stepnum = stepnum + 1

	if not irc2.connected then return end

	-- Hooks will manage incoming messages and errors
	local good, err = xpcall(function() irc2.conn:think() end, debug.traceback)
	if not good then
		print(err)
		return
	end
end


function irc2.connect()
	if irc2.connected then
		minetest.log("error", "IRC: Ignoring attempt to connect when already connected.")
		return
	end
	irc2.conn = irc2.lib.new({
		nick = irc2.config.nick,
		username = irc2.config.username,
		realname = irc2.config.realname,
	})
	irc2.doHook(irc2.conn)

	-- We need to swap the `require` function again since
	-- LuaIRC `require`s `ssl` if `irc.secure` is true.
	old_require = require
	require = ie.require

	local good, message = pcall(function()
		irc2.conn:connect({
			host = irc2.config.server,
			port = irc2.config.port,
			password = irc2.config.password,
			timeout = irc2.config.timeout,
			reconnect = irc2.config.reconnect,
			secure = irc2.config.secure
		})
	end)

	require = old_require

	if not good then
		minetest.log("error", ("IRC: Connection error: %s: %s -- Reconnecting in %d seconds...")
					:format(irc2.config.server, message, irc2.config.reconnect))
		minetest.after(irc2.config.reconnect, function() irc2.connect() end)
		return
	end

	if irc2.config.NSPass then
		irc2.conn:queue(irc2.msgs.privmsg(
				"NickServ", "IDENTIFY "..irc2.config.NSPass))
	end

	irc2.conn:join(irc2.config.channel, irc2.config.key)
	irc2.connected = true
	minetest.log("action", "IRC: Connected!")
	minetest.chat_send_all("IRC: Connected!")
end


function irc2.disconnect(message)
	if irc2.connected then
		--The OnDisconnect hook will clear irc.connected and print a disconnect message
		irc2.conn:disconnect(message)
	end
end


function irc2.say(to, message)
	if not message then
		message = to
		to = irc2.config.channel
	end
	to = to or irc2.config.channel

	irc2.queue(irc2.msgs.privmsg(to, message))
end


function irc2.reply(message)
	if not irc2.last_from then
		return
	end
	message = message:gsub("[\r\n%z]", " \\n ")
	irc2.say(irc2.last_from, message)
end

function irc2.send(msg)
	if not irc2.connected then return end
	irc2.conn:send(msg)
end

function irc2.queue(msg)
	if not irc2.connected then return end
	irc2.conn:queue(msg)
end

