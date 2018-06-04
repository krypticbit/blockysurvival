-- This file is licensed under the terms of the BSD 2-clause license.
-- See LICENSE.txt for details.

irc2.msgs = irc2.lib.msgs

function irc2.logChat(message)
	minetest.log("action", "IRC CHAT: "..message)
end

function irc2.sendLocal(message)
	minetest.chat_send_all(message)
	irc2.logChat(message)
end

function irc2.playerMessage(name, message)
	return ("<%s> %s"):format(name, message)
end
