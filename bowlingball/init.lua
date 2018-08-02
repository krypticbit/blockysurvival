--[[
Bowling ball entity:
moves across surfaces without friction,
rebounds if a sudden stop is detected.
]]

-- returns true if the vector was modified
local dampening = -0.7
local rebound_if_zero = function(oldv, newv, k)
	local v = newv[k]
	--print("# current velocity", k, v)
	local change = v == 0
	if change then
		local r = oldv[k] * dampening
		--print("# changed velocity", k, r)
		newv[k] = r
		return true
	end
	return change
end

local step = function(self, dtime)
	-- if this is the first tick,
	-- we won't have a previous velocity yet, so skip the processing
	local oldv = self.previous
	local newv = self.object:get_velocity()
	if not oldv then
		self.previous = newv
		return
	end

	-- look at the components of the vector to see if any are zero.
	-- if so, set to the negation of the previous component's value.
	local x = rebound_if_zero(oldv, newv, "x")
	local y = rebound_if_zero(oldv, newv, "y")
	local z = rebound_if_zero(oldv, newv, "z")
	local modified = x or y or z
	-- update engine velocity on change
	if modified then
		--print("# updating velocity")
		self.object:set_velocity(newv)
	end
	self.previous = newv
end

-- object is fairly dense.
-- also make entity punch operable
local gravity = {x=0,y=-20,z=0}
local groups = { punch_operable = 1 }
local on_activate = function(self)
	-- gravity... is there something better for this
	self.object:set_acceleration(gravity)
	self.object:set_armor_groups(groups)
end



-- let the player retrieve the item by right clicking.
local n = "bowlingball:ball"
local on_rightclick = function(self, clicker)
	-- check if the player has room in their inventory and add item if so.
	-- if it did fit, then remove the entity.
	local pickup = ItemStack(n)
	local remainder = clicker:get_inventory():add_item("main", pickup)
	local c = remainder:get_count()
	--print("# pickup: remainder count "..c)
	if c == 0 then
		self.object:remove()
	end
end

-- the player can punch the entity to make it roll if stopped
local throw_mult = 5
local on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
	local cvel = self.object:get_velocity()
	local avel = vector.multiply(dir, throw_mult)
	--print(dump(avel))
	local rvel = vector.add(cvel, avel)
	self.object:set_velocity(rvel)
end




local tex = "bowlingball_ball.png"
local r = 0.3
minetest.register_entity(n, {
	visual = "sprite",
	visual_size = {x=0.75,y=0.75},
	textures = { tex },
	on_activate = on_activate,
	on_step = step,
	physical = true,
	collide_with_objects = true,
	collisionbox = {-r, -r, -r, r, r, r},
	on_rightclick = on_rightclick,
	on_punch = on_punch,
})



-- a throwable ball item.
local take_one = function(stack)
	stack:set_count(stack:get_count() - 1)
end

local head = 1.6
local use = function(itemstack, user, pointed)
	local look = user:get_look_dir()
	local vel = vector.multiply(look, 5)
	local spos = user:get_pos()
	-- damned feet position
	spos.y = spos.y + head
	local ent = minetest.add_entity(spos, n)
	ent:set_velocity(vel)
	return take_one(itemstack)
end



minetest.register_craftitem(n, {
	description = "Throwable bowling ball (punch to toss, RMB to pick up)",
	on_use = use,
	inventory_image = tex,
})

