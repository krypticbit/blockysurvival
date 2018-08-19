local i = {}

local miniboom = function(pos)
	bPos = {x = pos.x + math.random(-9, 9), y = pos.y + math.random(-3, -1), z = pos.z + math.random(-9, 9)}
	tnt.boom(bPos, {radius = 4})
end

local strike_pos = function(pos, radius, kill_players)
	tnt.boom(pos, {radius=radius})
	-- Add "mini-booms" as the laser strikes for effect + more devistation
	minetest.after(0.1, miniboom, pos)
	minetest.after(0.25, miniboom, pos)
	minetest.after(0.2, miniboom, pos)
	minetest.after(0.3, miniboom, pos)
	minetest.after(0.1, miniboom, pos)
	-- Add strike visual via particles
	minetest.add_particlespawner({
		amount = 400,
		time = 0.01,
		minpos = pos,
		maxpos = {x = pos.x, y = pos.y + 125, z = pos.z},
		minvel = {x = 0, y = -100, z = 0},
		maxvel = {x = 0, y = -100, z = 0},
		minacc = {x=0, y=0, z=0},
		maxacc = {x=0, y=0, z=0},
		maxsize = 20,
		minsize = 15,
		minexptime = 0.3,
		maxexptime = 0.3,
		collisiondetection = false,
		vertical = true,
		glow = 14,
		texture = "lazer_particle.png",
	})
	-- Play strike sound
	minetest.sound_play("lazerstrike_strike", {pos = pos,
			    			   gain = 30,
						   max_hear_distance = 128})
	-- lethal core range: outright kills entities.
	-- players are zapped by setting their HP to zero in minetest.after.
	local objects = minetest.get_objects_inside_radius(pos, radius/2)
	local players = {}
	for _, ent in ipairs(objects) do
		if ent:is_player() then
			players[ent] = true
		else
			ent:remove()
		end
	end
	-- uses minetest.after, because :set_hp() can only be called in globalstep...
	if kill_players then
		minetest.after(0, function()
			for player, _ in pairs(players) do
				player:set_hp(0)
			end
		end)
	end
end

-- vaporises a player and empties their inventory.
-- does this by forcing them to run /clearinv.
-- returns true if the player existed, false if not.
local strike_player = function(name, radius, kill_players)
	local ref = minetest.get_player_by_name(name)
	if not ref then return false end
	minetest.registered_chatcommands["clearinv"].func(name)
	strike_pos(ref:get_pos(), radius, kill_players)
	-- Kill the target because they just got hit by a massive laser for crying out loud
	if not kill_players then
		minetest.after(0, function() ref:set_hp(0) end)
	end
end

minetest.register_privilege("vaporize", "Allows use of the /vaporzie command")

minetest.register_chatcommand("vaporize_tame", {
	params = "<victim>",
	description = "Eliminates <victim> but does not hurt any other players",
	privs = {vaporize = true},
	func = function(name, param)
                p = minetest.get_player_by_name(param)
                if p then
                        pInts = {}
                        for i,n in pairs(p:getpos()) do pInts[i] = math.floor(n) end
                        minetest.chat_send_all("[WARNING] Incoming Lazer Satellite Strike at " .. minetest.pos_to_string(pInts) .. " (lock: " .. param .. ")")
                        strike_player(param, 7)
                else
                        return false, "No such player is online"
                end
        end
})

minetest.register_chatcommand("vaporize", {
	params = "<victim>",
	description = "Eliminates <victim> with a laser of immense power (May destroy surrounding area, use with caution)",
	privs = {vaporize = true},
	func = function(name, param)
		p = minetest.get_player_by_name(param)
		if p then
			pInts = {}
			for i,n in pairs(p:getpos()) do pInts[i] = math.floor(n) end
			minetest.chat_send_all("[WARNING] Incoming Lazer Satellite Strike at " .. minetest.pos_to_string(pInts) .. " (lock: " .. param .. ")")
			strike_player(param, 7, true)
		else
			return false, "No such player is online"
		end
	end
})
