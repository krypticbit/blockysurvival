local invalid_player = "Invalid player"
local invalid_punishment = "Invalid punishment"

local function ownsAreaAt(name, pos)
	local owners = areas:getNodeOwners(pos)
	for _, p in pairs(owners) do
		if p == name then
			return true
		end
	end
	return false
end

main.punishments = {
	hotfoot = {
		func = function(pname)
			local p = minetest.get_player_by_name(pname)
			if p then
				local pos = p:get_pos()
				if minetest.is_protected(name) then
					minetest.set_node(pos, {name = "fire:basic_flame"})
				end
			end
		end,
		every = 0
	},
	tnt_rain = {
		func = function(pname)
			local p = minetest.get_player_by_name(pname)
			if p then
				local pos = p:get_pos()
				local above = {x = pos.x, y = pos.y + 10, z = pos.z}
				if ownsAreaAt(pname, pos) then
					minetest.set_node(above, {name = "tnt:tnt_burning"})
				end
			end
		end,
		every = 5
	},
	butterfingers = {
		func = function(pname)
			local p = minetest.get_player_by_name(pname)
			if p then
				local inv = p:get_inventory()
				local stacks = inv:get_list("main")
				local stackIndex = math.random(#stacks)
				local take = stacks[stackIndex]
				inv:remove_item("main", take)
				minetest.add_item(p:get_pos(), take)
			end
		end,
		every = 3
	}
}

main.punished = {}

minetest.register_globalstep(function(dtime)
	for name, punishment in pairs(main.punished) do
		punishment.time = punishment.time - dtime
		punishment.timer = punishment.timer + dtime
		if punishment.time < 0 then
			main.punished[name] = nil
			return
		end
		if punishment.timer >= punishment.every then
			punishment.timer = 0
			punishment.func(name)
		end
	end
end)

minetest.register_privilege("punish", "Allows a player to invoke creative punishments on other players")

function main.punish(name, p_name, punishment, tStr)
	-- Verify input
	if minetest.get_player_by_name(p_name) == nil then
		return false, invalid_player
	end
	if main.punishments[punishment] == nil then
		return false, invalid_punishment
	end
	-- Is there a letter on the end of tStr?
	local mult = 1
	local multStr = tStr:sub(-1)
	local tInt
	if multStr:lower() ~= multStr:upper() then -- Not a number
		multStr = multStr:lower()
		if multStr == "s" then mult = 1
		elseif multStr == "m" then mult = 60
		elseif multStr == "h" then mult = 3600
		elseif multStr == "d" then mult = 86400
		else minetest.chat_send_player(name, "Invaild time multiplier, assuming seconds") end
		tInt = tonumber(tStr:sub(1, -2))
	else
		tInt = tonumber(tStr)
	end
	if tInt then
		tInt = tInt * mult
	else
		return false, "Invalid time"
	end
	main.punished[p_name] = {
							["time"] = tInt,
							["timer"] = 0,
							["func"] = main.punishments[punishment].func,
							["every"] = main.punishments[punishment].every
							}
	return true, "Done!"
end

ChatCmdBuilder.new("punish", function(cmd)
	cmd:sub(":pname :punishment :time", function(name, p_name, punishment, tStr)
		return main.punish(name, p_name, punishment, tStr)
	end)
	cmd:sub(":pname :punishment", function(name, p_name, punishment, tStr)
		return main.punish(name, p_name, punishment, "5m")
	end)
end, {
	description = "Invokes creative punishments on a player",
	privs = {punish = true},
})
