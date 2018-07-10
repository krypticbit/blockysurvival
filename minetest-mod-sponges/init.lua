local tex = function(n) return "sponge_"..n..".png" end

local node_wet = "sponge:wet"
local node_dry = "sponge:dry"





-- configuration setup
local drain_radius
local msg = "bad configuration: "
local s = minetest.settings:get("ds2.minetest.sponge.drain_radius")
if s == nil then
	-- default value
	drain_radius = 2
else
	local v = tonumber(s)
	assert(v ~= nil, msg.."drain_radius was not a valid numerical value: "..s)
	-- allow it to be zero to disable the node
	assert(v >= 0, msg.."drain_radius must be positive: "..v)
	assert((v % 1.0) == 0, msg.."drain_radius must be an integer: "..v)
	drain_radius = v
end
local r = drain_radius
local rw = function(v) return (v * 2) + 1 end
local cube = function(v) return v*v*v end
-- sanity checking to ensure water value can fit inside 8-bit param2.
-- we store it as (water - 1) as we have a separate block for dry.
-- additionally, the center of the area (the sponge itself) can never be water.
assert((cube(rw(r)) - 2) <= 255, "selected radius total volume doesn't fit into param2")





-- ways to get water out of a wet sponge.
local wetsponge_on_rightclick
-- check if buckets is enabled by looking at their item defs
local empty = "bucket:bucket_empty"
local full = "bucket:bucket_water"
local defs = minetest.registered_items
local buckets_enabled = defs[empty] and defs[full]

-- take a bucket from a player and give them back the wet one.
-- returns the left-over itemstack, if any.
local player_give_bucket = function(player, original)
	local list = player:get_wield_list()
	local inv = player:get_inventory()
	local count = original:get_count()

	local bucket = ItemStack(full)
	if inv:room_for_item(list, bucket) then
		count = count - 1
		original:set_count(count)
		inv:add_item(list, bucket)
	end

	return original
end

local wet_replace = { name = node_wet }
local dry_replace = { name = node_dry }
local dry_replace_notrigger = { name = node_dry, param2 = 1 }
if buckets_enabled then
	wetsponge_on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		if clicker:is_player() and itemstack:get_name() == empty then
			-- do the necessary fiddling with the item stack
			itemstack = player_give_bucket(clicker, itemstack)

			-- decrement the count and revert to dry if necessary.
			local count = node.param2
			count = count - 1
			local node
			if count < 0 then
				node = dry_replace_notrigger
			else
				wet_replace.param2 = count
				node = wet_replace
			end
			minetest.set_node(pos, node)
		end

		return itemstack
	end
else
	wetsponge_on_rightclick = function() end
end





-- placement logic for drainage
local p = {}
local air = { name = "air" }
local try_drain = function(x, y, z)
	p.x = x
	p.y = y
	p.z = z
	local node = minetest.get_node(p)
	local is_water = (node.name == "default:water_source")
	if is_water then
		minetest.set_node(p, air)
	end
	return is_water
end

local on_construct = function(pos)
	-- we have to check our param2 to know whether it was placed by a player.
	local node = minetest.get_node(pos)
	if node.param2 > 0 then return end

	local xc, yc, zc = pos.x, pos.y, pos.z
	local count = 0
	-- rip indentation
	for z = zc - r, zc + r, 1 do
	for y = yc - r, yc + r, 1 do
	for x = xc - r, xc + r, 1 do
		-- oh look, a convienient table
		if try_drain(x, y, z) then
			count = count + 1
		end
	end
	end
	end

	-- shouldn't be possible here, but guard anyway
	assert(count < 256)
	if count > 0 then
		wet_replace.param2 = count - 1
		minetest.set_node(pos, wet_replace)
	end
end





-- registration of nodes

-- I don't really know what groups would be appropriate for a spongy block
-- (that would be compatible with existing tools).
local groups = {
	oddly_breakable_by_hand = 3,
}

-- explicitly disable water absorption behaviour if drain_radius is zero.
local enable = (drain_radius ~= 0)
local ifdrain = function(v)
	return enable and v or nil
end

minetest.register_node(node_dry, {
	description = "Dry sponge",
	tiles = { tex("dry") },
	groups = groups,
	on_construct = ifdrain(on_construct),
})
minetest.register_node(node_wet, {
	description = "Wet sponge block (HACKERRRRR)",
	tiles = { tex("wet") },
	groups = groups,
	on_rightclick = wetsponge_on_rightclick,
})

-- dry out sponges via furnace.
-- in future this may need balancing - sponges can hold a fair amount of water,
-- and water is relatively hard to boil.
minetest.register_craft({
	type = "cooking",
	output = node_dry,
	recipe = node_wet,
	cooktime = 10,
})

-- mapgen: generate under water (TODO: biomes? like ocean)
minetest.register_decoration({
	deco_type = "simple",
	decoration = node_wet,
	place_on = "default:sand",
	sidelen = 16,
	fill_ratio = 0.00005,
	y_max = -16,
	y_min = -31000,
	spawn_by = "default:water_source",
	num_spawn_by = 4,
	param2 = 255,
	flags = "force_placement",
	height = 5,
})

