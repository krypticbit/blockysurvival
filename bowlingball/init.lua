--[[
Bowling ball entity:
moves across surfaces without friction,
rebounds if a sudden stop is detected.
]]

-- returns true if the vector was modified
local dampening = -0.4
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

-- ball radius - used for some checking around the ball
local r = 0.3
-- forward declaration of names used in varios functions below.
local ballreturn = "bowlingball:return"
local n = "bowlingball:ball"



-- registration of the bowling ball return block.
-- this node is passive, having no logic of it's own;
-- it serves only as a marker for the entity.
-- see the handle_return() function below to see this behaviour.
local side = "bowlingball_return_side.png"
local hole = "bowlingball_return_hole.png"
minetest.register_node(ballreturn, {
	description = "Bowling ball capture block (roll ball over this)",
	tiles = { hole, hole, side, side, side, side },
	groups = { oddly_breakable_by_hand = 3 },
})



-- handle the ball return node being beneath us.
local offset = r + 0.0001	-- avoid node boundary issues
-- boundary check
local b = function(v)
	return (v % 1.0) == 0.5
end
local round = function(v)
	return math.floor(v + 0.5)
end
local rp_mut = function(p)
	p.x = round(p.x)
	p.y = round(p.y)
	p.z = round(p.z)
	return p
end
local handle_return = function(object)
	local pos = object:get_pos()
	pos.y = pos.y - offset
	-- I've had enough of boundary rounding issues...
	if b(pos.x) or b(pos.y) or b(pos.z) then
		return false
	end

	local node = minetest.get_node(pos)
	local act = (node.name == ballreturn)

	if act then
		-- spawn an item just below that block.
		pos = rp_mut(pos)
		pos.y = pos.y - 0.501
		minetest.add_item(pos, n)
	end

	return act
end



local step = function(self, dtime)
	-- first and foremost: check if the block below us is ball return node.
	-- if this indicates that it did anything,
	-- perform no further action and delete ourselves.
	if (handle_return(self.object)) then
		self.object:remove()
		return
	end

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
-- fix a complaint about itemstacks from on_use despite clearly returning one...
-- give it an itemstring instead to keep it happy.
local take_one = function(stack)
	stack:set_count(stack:get_count() - 1)
	return stack:to_string()
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
-- optional crafts to follow
local mp = minetest.get_modpath(minetest.get_current_modname()).."/"
dofile(mp.."crafting.lua")


