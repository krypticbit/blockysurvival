-- Reboot mod for Minetest
-- Waits for the last player to leave then shuts the server down
-- 
-- Copyright © 2018 by luk3yx
--  
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--     
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--     
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

local reboot = false

local checkReboot

checkReboot = function()
    if reboot and next(minetest.get_connected_players()) == nil then
        -- Time to reboot
        if irc then irc.say("The server is empty! Rebooting...") end
        minetest.request_shutdown("Rebooting...", true, 1)
    end
end

minetest.register_on_leaveplayer(checkReboot)

minetest.register_chatcommand("reboot", {
    privs = {server = true},
    params = "",
    description = "Reboots the server next time it is empty.",
    func = function()
        if reboot then
            return false, "There is already a reboot pending!"
        end
        reboot = true
        checkReboot()
        return true, "Reboot scheduled!"
    end
})

minetest.register_chatcommand("cancelreboot", {
    privs = {server = true},
    params = "",
    description = "Cancels a pending reboot.",
    func = function()
        if not reboot then
            return false, "There is no reboot to cancel!"
        end
        reboot = false
        return true, "Reboot aborted!"
    end
})
