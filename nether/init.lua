-- Parameters

local NETHER_DEPTH = -25000
local BEDROCK_THICKNESS = 3
local TCAVE = 0.6
local BLEND = 128
local DEBUG = false


-- Load extra files

local mpath = minetest.get_modpath("nether")
dofile(mpath .. "/items.lua")

-- 3D noise

local np_cave = {
	offset = 0,
	scale = 1,
	spread = {x = 384, y = 64, z = 384}, -- squashed 6:1
	seed = 59033,
	octaves = 5,
	persist = 0.7,
	lacunarity = 2.0,
	--flags = ""
}


-- Stuff

local yblmax = NETHER_DEPTH - BLEND * 2


-- Functions

local function build_portal(pos, target)
	local p1 = {x = pos.x - 1, y = pos.y - 1, z = pos.z}
	local p2 = {x = p1.x + 3, y = p1.y + 4, z = p1.z}

	local path = mpath .. "/schematics/nether_portal.mts"
	minetest.place_schematic({x = p1.x, y = p1.y, z = p1.z - 2}, path, 0, nil, true)

	for y = p1.y, p2.y do
	for x = p1.x, p2.x do
		local meta = minetest.get_meta({x = x, y = y, z = p1.z})
		meta:set_string("p1", minetest.pos_to_string(p1))
		meta:set_string("p2", minetest.pos_to_string(p2))
		meta:set_string("target", minetest.pos_to_string(target))
	end
	end
end


local function volume_is_natural(minp, maxp)
	local c_air = minetest.get_content_id("air")
	local c_ignore = minetest.get_content_id("ignore")

	local vm = minetest.get_voxel_manip()
	local pos1 = {x = minp.x, y = minp.y, z = minp.z}
	local pos2 = {x = maxp.x, y = maxp.y, z = maxp.z}
	local emin, emax = vm:read_from_map(pos1, pos2)
	local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
	local data = vm:get_data()

	for z = pos1.z, pos2.z do
	for y = pos1.y, pos2.y do
		local vi = area:index(pos1.x, y, z)
		for x = pos1.x, pos2.x do
			local id = data[vi] -- Existing node
			if id ~= c_air and id ~= c_ignore then -- These are natural
				local name = minetest.get_name_from_content_id(id)
				if not minetest.registered_nodes[name].is_ground_content then
					return false
				end
			end
			vi = vi + 1
		end
	end
	end

	return true
end


local function find_nether_target_y(target_x, target_z, start_y)
	local nobj_cave_point = minetest.get_perlin(np_cave)
	local air = 0 -- Consecutive air nodes found

	for y = start_y, start_y - 4096, -1 do
		local nval_cave = nobj_cave_point:get3d({x = target_x, y = y, z = target_z})

		if nval_cave > TCAVE then -- Cavern
			air = air + 1
		else -- Not cavern, check if 4 nodes of space above
			if air >= 4 then
				-- Check volume for non-natural nodes
				local minp = {x = target_x - 1, y = y - 1, z = target_z - 2}
				local maxp = {x = target_x + 2, y = y + 3, z = target_z + 2}
				if volume_is_natural(minp, maxp) then
					return y + 2
				else -- Restart search a little lower
					find_nether_target_y(target_x, target_z, y - 16)
				end
			else -- Not enough space, reset air to zero
				air = 0
			end
		end
	end

	return start_y -- Fallback
end


local function find_surface_target_y(target_x, target_z, start_y)
	for y = start_y, start_y - 256, -16 do
		-- Check volume for non-natural nodes
		local minp = {x = target_x - 1, y = y - 1, z = target_z - 2}
		local maxp = {x = target_x + 2, y = y + 3, z = target_z + 2}
		if volume_is_natural(minp, maxp) then
			return y
		end
	end

	return y -- Fallback
end


local function move_check(p1, max, dir)
	local p = {x = p1.x, y = p1.y, z = p1.z}
	local d = math.abs(max - p1[dir]) / (max - p1[dir])

	while p[dir] ~= max do
		p[dir] = p[dir] + d
		if minetest.get_node(p).name ~= "default:obsidian" then
			return false
		end
	end

	return true
end


local function check_portal(p1, p2)
	if p1.x ~= p2.x then
		if not move_check(p1, p2.x, "x") then
			return false
		end
		if not move_check(p2, p1.x, "x") then
			return false
		end
	elseif p1.z ~= p2.z then
		if not move_check(p1, p2.z, "z") then
			return false
		end
		if not move_check(p2, p1.z, "z") then
			return false
		end
	else
		return false
	end

	if not move_check(p1, p2.y, "y") then
		return false
	end
	if not move_check(p2, p1.y, "y") then
		return false
	end

	return true
end


local function is_portal(pos)
	for d = -3, 3 do
		for y = -4, 4 do
			local px = {x = pos.x + d, y = pos.y + y, z = pos.z}
			local pz = {x = pos.x, y = pos.y + y, z = pos.z + d}

			if check_portal(px, {x = px.x + 3, y = px.y + 4, z = px.z}) then
				return px, {x = px.x + 3, y = px.y + 4, z = px.z}
			end
			if check_portal(pz, {x = pz.x, y = pz.y + 4, z = pz.z + 3}) then
				return pz, {x = pz.x, y = pz.y + 4, z = pz.z + 3}
			end
		end
	end
end


local function make_portal(pos)
	local p1, p2 = is_portal(pos)
	if not p1 or not p2 then
		return false
	end

	for d = 1, 2 do
	for y = p1.y + 1, p2.y - 1 do
		local p
		if p1.z == p2.z then
			p = {x = p1.x + d, y = y, z = p1.z}
		else
			p = {x = p1.x, y = y, z = p1.z + d}
		end
		if minetest.get_node(p).name ~= "air" then
			return false
		end
	end
	end

	local param2
	if p1.z == p2.z then
		param2 = 0
	else
		param2 = 1
	end

	local target = {x = p1.x, y = p1.y, z = p1.z}
	target.x = target.x + 1
	if target.y < NETHER_DEPTH then
		target.y = find_surface_target_y(target.x, target.z, -16)
	else
		local start_y = NETHER_DEPTH - math.random(500, 1500) -- Search start
		target.y = find_nether_target_y(target.x, target.z, start_y)
	end

	for d = 0, 3 do
	for y = p1.y, p2.y do
		local p = {}
		if param2 == 0 then
			p = {x = p1.x + d, y = y, z = p1.z}
		else
			p = {x = p1.x, y = y, z = p1.z + d}
		end
		if minetest.get_node(p).name == "air" then
			minetest.set_node(p, {name = "nether:portal", param2 = param2})
		end
		local meta = minetest.get_meta(p)
		meta:set_string("p1", minetest.pos_to_string(p1))
		meta:set_string("p2", minetest.pos_to_string(p2))
		meta:set_string("target", minetest.pos_to_string(target))
	end
	end

	return true
end


-- Mobs

mobs:register_mob("nether:nether_monster", {
	type = "monster",
	passive = false,
	attack_type = "dogfight",
	pathfinding = true,
	reach = 2,
	damage = 3,
	hp_min = 50,
	hp_max = 70,
	armor = 80,
	collisionbox = {-0.4, -1, -0.4, 0.4, 0.9, 0.4},
	visual = "mesh",
	mesh = "nether_monster.x",
	textures = {
		{"nether_monster.png"},
	},
	makes_footstep_sound = true,
	sounds = {
		random = "mobs_stonemonster",
	},
	walk_velocity = 2,
	run_velocity = 3,
	jump_height = 2,
	stepheight = 1.1,
	floats = 0,
	view_range = 10,
	drops = {
		{name = "default:torch", chance = 2, min = 3, max = 5},
		{name = "default:iron_lump", chance = 5, min = 1, max = 2},
		{name = "default:coal_lump", chance = 3, min = 1, max = 3},
	},
	water_damage = 0,
	lava_damage = 1,
	light_damage = 0,
	animation = {
		speed_normal = 15,
		speed_run = 15,
		stand_start = 0,
		stand_end = 14,
		walk_start = 15,
		walk_end = 38,
		run_start = 40,
		run_end = 63,
		punch_start = 40,
		punch_end = 63,
	},
})
	
-- ABMs

minetest.register_abm({
	nodenames = {"nether:portal"},
	interval = 1,
	chance = 2,
	action = function(pos, node)
		minetest.add_particlespawner(
			32, --amount
			4, --time
			{x = pos.x - 0.25, y = pos.y - 0.25, z = pos.z - 0.25}, --minpos
			{x = pos.x + 0.25, y = pos.y + 0.25, z = pos.z + 0.25}, --maxpos
			{x = -0.8, y = -0.8, z = -0.8}, --minvel
			{x = 0.8, y = 0.8, z = 0.8}, --maxvel
			{x = 0, y = 0, z = 0}, --minacc
			{x = 0, y = 0, z = 0}, --maxacc
			0.5, --minexptime
			1, --maxexptime
			1, --minsize
			2, --maxsize
			false, --collisiondetection
			"nether_particle.png" --texture
		)
		for _, obj in ipairs(minetest.get_objects_inside_radius(pos, 1)) do
			if obj:is_player() then
				local meta = minetest.get_meta(pos)
				local target = minetest.string_to_pos(meta:get_string("target"))
				if target then
					-- force emerge of target area
					minetest.get_voxel_manip():read_from_map(target, target)
					if not minetest.get_node_or_nil(target) then
						minetest.emerge_area(
							vector.subtract(target, 4), vector.add(target, 4))
					end
					-- teleport the player
					minetest.after(3, function(obj, pos, target)
						local objpos = obj:getpos()
						objpos.y = objpos.y + 0.1 -- Fix some glitches at -8000
						if minetest.get_node(objpos).name ~= "nether:portal" then
							return
						end

						obj:setpos(target)

						local function check_and_build_portal(pos, target)
							local n = minetest.get_node_or_nil(target)
							if n and n.name ~= "nether:portal" then
								build_portal(target, pos)
								minetest.after(2, check_and_build_portal, pos, target)
								minetest.after(4, check_and_build_portal, pos, target)
							elseif not n then
								minetest.after(1, check_and_build_portal, pos, target)
							end
						end

						minetest.after(1, check_and_build_portal, pos, target)

					end, obj, pos, target)
				end
			end
		end
	end,
})

-- Nodes

minetest.register_node("nether:portal", {
	description = "Nether Portal",
	tiles = {
		"nether_transparent.png",
		"nether_transparent.png",
		"nether_transparent.png",
		"nether_transparent.png",
		{
			name = "nether_portal.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 0.5,
			},
		},
		{
			name = "nether_portal.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 0.5,
			},
		},
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	use_texture_alpha = true,
	walkable = false,
	diggable = false,
	pointable = false,
	buildable_to = false,
	is_ground_content = false,
	drop = "",
	light_source = 5,
	post_effect_color = {a = 180, r = 128, g = 0, b = 128},
	alpha = 192,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.1,  0.5, 0.5, 0.1},
		},
	},
	groups = {not_in_creative_inventory = 1}
})

minetest.register_node(":default:obsidian", {
	description = "Obsidian",
	tiles = {"default_obsidian.png"},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
	groups = {cracky = 1, level = 2},

	on_destruct = function(pos)
		local meta = minetest.get_meta(pos)
		local p1 = minetest.string_to_pos(meta:get_string("p1"))
		local p2 = minetest.string_to_pos(meta:get_string("p2"))
		local target = minetest.string_to_pos(meta:get_string("target"))
		if not p1 or not p2 then
			return
		end

		for x = p1.x, p2.x do
		for y = p1.y, p2.y do
		for z = p1.z, p2.z do
			local nn = minetest.get_node({x = x, y = y, z = z}).name
			if nn == "default:obsidian" or nn == "nether:portal" then
				if nn == "nether:portal" then
					minetest.remove_node({x = x, y = y, z = z})
				end
				local m = minetest.get_meta({x = x, y = y, z = z})
				m:set_string("p1", "")
				m:set_string("p2", "")
				m:set_string("target", "")
			end
		end
		end
		end

		meta = minetest.get_meta(target)
		if not meta then
			return
		end
		p1 = minetest.string_to_pos(meta:get_string("p1"))
		p2 = minetest.string_to_pos(meta:get_string("p2"))
		if not p1 or not p2 then
			return
		end

		for x = p1.x, p2.x do
		for y = p1.y, p2.y do
		for z = p1.z, p2.z do
			local nn = minetest.get_node({x = x, y = y, z = z}).name
			if nn == "default:obsidian" or nn == "nether:portal" then
				if nn == "nether:portal" then
					minetest.remove_node({x = x, y = y, z = z})
				end
				local m = minetest.get_meta({x = x, y = y, z = z})
				m:set_string("p1", "")
				m:set_string("p2", "")
				m:set_string("target", "")
			end
		end
		end
		end
	end,
	on_blast = function (pos, intensity) end
})

minetest.register_node("nether:rack", {
	description = "Netherrack",
	tiles = {"nether_rack.png"},
	is_ground_content = true,
	groups = {cracky = 3, level = 2},
	sounds = default.node_sound_stone_defaults(),
	on_blast = function (pos, intensity) end
})

minetest.register_node("nether:sand", {
	description = "Nethersand",
	tiles = {"nether_sand.png"},
	is_ground_content = true,
	groups = {crumbly = 3, level = 2, falling_node = 1},
	sounds = default.node_sound_gravel_defaults({
		footstep = {name = "default_gravel_footstep", gain = 0.45},
	}),
})

minetest.register_node("nether:glowstone", {
	description = "Glowstone",
	tiles = {"nether_glowstone.png"},
	is_ground_content = true,
	light_source = 14,
	paramtype = "light",
	groups = {cracky = 3, oddly_breakable_by_hand = 3},
	sounds = default.node_sound_glass_defaults(),
	on_blast = function (pos, intensity) end
})

minetest.register_node("nether:brick", {
	description = "Nether Brick",
	tiles = {"nether_brick.png"},
	is_ground_content = false,
	groups = {cracky = 2, level = 2},
	sounds = default.node_sound_stone_defaults(),
	on_blast = function (pos, intensity) end
})

local fence_texture =
	"default_fence_overlay.png^nether_brick.png^default_fence_overlay.png^[makealpha:255,126,126"

minetest.register_node("nether:fence_nether_brick", {
	description = "Nether Brick Fence",
	drawtype = "fencelike",
	tiles = {"nether_brick.png"},
	inventory_image = fence_texture,
	wield_image = fence_texture,
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	selection_box = {
		type = "fixed",
		fixed = {-1/7, -1/2, -1/7, 1/7, 1/2, 1/7},
	},
	groups = {cracky = 2, level = 2},
	sounds = default.node_sound_stone_defaults(),
	on_blast = function (pos, intensity) end
})

minetest.register_node("nether:bedrock", {
	description = "Bedrock",
	tiles = {"bedrock.png"},
	is_ground_content = false,
	diggable = false,
	damage_per_second = 500, -- Keep hackers from glitching through
	drop = "",
	on_blast = function (pos, intensity) end -- Nothing happens with TNT
})

-- Register stair and slab

stairs.register_stair_and_slab(
	"nether_brick",
	"nether:brick",
	{cracky = 2, level = 2},
	{"nether_brick.png"},
	"nether stair",
	"nether slab",
	default.node_sound_stone_defaults()
)

-- StairsPlus

if minetest.get_modpath("moreblocks") then
	stairsplus:register_all(
		"nether", "brick", "nether:brick", {
			description = "Nether Brick",
			groups = {cracky = 2, level = 2},
			tiles = {"nether_brick.png"},
			sounds = default.node_sound_stone_defaults(),
	})
end

-- Nether mob spawners

minetest.register_node("nether:monster_spawner_inactive", {
	description = "Inactive Spawner",
	tiles = {"nether_monster_spawner.png"},
	is_ground_content = false,
	groups = {cracky = 1, level = 3, explody = 1}
})

minetest.register_node("nether:monster_spawner", {
	description = "Spawner",
	tiles = {"nether_monster_spawner.png"},
	is_ground_content = false,
	groups = {cracky = 1, level = 3, explody = 1},
	on_construct = function(pos)
		local timer = minetest.get_node_timer(pos)
		local meta = minetest.get_meta(pos)
		meta:set_int("spawned", 0)
		timer:start(3)
	end,
	on_timer = function(pos, elapsed)
		local objs = minetest.get_objects_inside_radius(pos, 12)
		local timer = minetest.get_node_timer(pos)
		for _, obj in pairs(objs) do
			if obj:is_player() then
				local meta = minetest.get_meta(pos)
				local spawned = meta:get_int("spawned")
				meta:set_int("spawned", spawned + 1)
				minetest.add_entity({x = pos.x, y = pos.y + 2, z = pos.z}, "nether:nether_monster")
				if spawned < 2 then
					timer:start(3)
				end
				return
			end
		end
		timer:start(3)
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		if tnt.boom then
			tnt.boom(pos, {radius = 5})
		end
	end
})

minetest.register_abm({
	label = "Activate nether spawners",
	nodenames = {"nether:monster_spawner_inactive"},
	interval = 1,
	chance = 1,
	action = function(pos)
		minetest.set_node(pos, {name = "nether:monster_spawner"})
	end
})

-- Craftitems

minetest.register_craftitem(":default:mese_crystal_fragment", {
	description = "Mese Crystal Fragment",
	inventory_image = "default_mese_crystal_fragment.png",
	on_place = function(stack, _, pt)
		if pt.under and minetest.get_node(pt.under).name == "default:obsidian" then
			local done = make_portal(pt.under)
			if done and not minetest.setting_getbool("creative_mode") then
				stack:take_item()
			end
		end

		return stack
	end,
})


-- Crafting

minetest.register_craft({
	output = "nether:brick 4",
	recipe = {
		{"nether:rack", "nether:rack"},
		{"nether:rack", "nether:rack"},
	}
})

minetest.register_craft({
	output = "nether:fence_nether_brick 6",
	recipe = {
		{"nether:brick", "nether:brick", "nether:brick"},
		{"nether:brick", "nether:brick", "nether:brick"},
	},
})


-- Mapgen

-- Initialize noise object, localise noise and data buffers

local nobj_cave = nil
local nbuf_cave
local dbuf


-- Content ids

local c_air = minetest.get_content_id("air")

local c_stone_with_coal = minetest.get_content_id("default:stone_with_coal")
local c_stone_with_iron = minetest.get_content_id("default:stone_with_iron")
local c_stone_with_mese = minetest.get_content_id("default:stone_with_mese")
local c_stone_with_diamond = minetest.get_content_id("default:stone_with_diamond")
local c_stone_with_gold = minetest.get_content_id("default:stone_with_gold")
local c_stone_with_copper = minetest.get_content_id("default:stone_with_copper")
local c_mese = minetest.get_content_id("default:mese")

local c_gravel = minetest.get_content_id("default:gravel")
local c_dirt = minetest.get_content_id("default:dirt")
local c_sand = minetest.get_content_id("default:sand")

local c_cobble = minetest.get_content_id("default:cobble")
local c_mossycobble = minetest.get_content_id("default:mossycobble")
local c_stair_cobble = minetest.get_content_id("stairs:stair_cobble")

local c_lava_source = minetest.get_content_id("default:lava_source")
local c_lava_flowing = minetest.get_content_id("default:lava_flowing")
local c_water_source = minetest.get_content_id("default:water_source")
local c_water_flowing = minetest.get_content_id("default:water_flowing")

local c_glowstone = minetest.get_content_id("nether:glowstone")
local c_nethersand = minetest.get_content_id("nether:sand")
local c_netherbrick = minetest.get_content_id("nether:brick")
local c_netherrack = minetest.get_content_id("nether:rack")
local c_bedrock = minetest.get_content_id("nether:bedrock")

-- On-generated function

minetest.register_on_generated(function(minp, maxp, seed)
	if minp.y > NETHER_DEPTH then
		return
	end
	generate_nether(minp, maxp, seed)
end)

function generate_nether(minp, maxp, seed)
	local t1 = os.clock()

	local x1 = maxp.x
	local y1 = maxp.y
	local z1 = maxp.z
	local x0 = minp.x
	local y0 = minp.y
	local z0 = minp.z

	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new{MinEdge = emin, MaxEdge = emax}
	local data = vm:get_data(dbuf)

	local x11 = emax.x -- Limits of mapchunk plus mapblock shell
	local y11 = math.min(emax.y, NETHER_DEPTH)
	local z11 = emax.z
	local x00 = emin.x
	local y00 = emin.y
	local z00 = emin.z

	local ystride = x1 - x0 + 1
	local zstride = ystride * ystride
	local chulens = {x = ystride, y = ystride, z = ystride}
	local minposxyz = {x = x0, y = y0, z = z0}
	local rand = math.random

	nobj_cave = nobj_cave or minetest.get_perlin_map(np_cave, chulens)
	local nvals_cave = nobj_cave:get3dMap_flat(minposxyz, nbuf_cave)
	
	local base_side = 18
	local randX = math.random(minp.x, maxp.x)
	local randZ = math.random(minp.z, maxp.z)
	local layers = {}
	local numInLayer = 0
	local mapchunkArea = base_side * base_side
	
	local cMin = {x = randX - base_side / 2, z = randZ - base_side / 2}
	local cMax = {x = randX + base_side / 2, z = randZ + base_side / 2}

	for y = y00, y11 do -- Y loop first to minimise tcave calculations
		local tcave
		local in_chunk_y = false
		local diff = y - NETHER_DEPTH + BEDROCK_THICKNESS -- y - (NETHER_DEPTH - BEDROCK_THICKNESS)
		if y >= y0 and y <= y1 then
			if y > yblmax then
				tcave = TCAVE + ((y - yblmax) / BLEND) ^ 2
			else
				tcave = TCAVE
			end
			in_chunk_y = true
		end
		for z = z00, z11 do
			local vi = area:index(x00, y, z) -- Initial voxelmanip index
			local ni
			local in_chunk_yz = in_chunk_y and z >= z0 and z <= z1

			for x = x00, x11 do
				if diff > 0 then
					if math.random(1, diff) == 1 then
						data[vi] = c_bedrock
					end
				else
					if in_chunk_yz and x == x0 then
						-- Initial noisemap index
						ni = (z - z0) * zstride + (y - y0) * ystride + 1
					end
					local in_chunk_yzx = in_chunk_yz and x >= x0 and x <= x1 -- In mapchunk
	
					local id = data[vi] -- Existing node
					-- Cave air, cave liquids and dungeons are overgenerated,
					-- convert these throughout mapchunk plus shell
					if id == c_air or -- Air and liquids to air
							id == c_lava_source or
							id == c_lava_flowing or
							id == c_water_source or
							id == c_water_flowing then
						data[vi] = c_air
					-- Dungeons are preserved so we don't need
					-- to check for cavern in the shell
					elseif id == c_cobble or -- Dungeons (preserved) to netherbrick
							id == c_mossycobble or
							id == c_stair_cobble then
						data[vi] = c_netherbrick
					end
	
					if in_chunk_yzx then -- In mapchunk
						if nvals_cave[ni] > tcave then -- Only excavate cavern in mapchunk
							data[vi] = c_air
						elseif id == c_mese then -- Mese block to lava
							data[vi] = c_lava_source
						elseif id == c_stone_with_gold or -- Precious ores to glowstone
								id == c_stone_with_mese or
								id == c_stone_with_diamond then
							data[vi] = c_glowstone
						elseif id == c_gravel or -- Blob ore to nethersand
								id == c_dirt or
								id == c_sand then
							data[vi] = c_nethersand
						else -- All else to netherstone
							data[vi] = c_netherrack
							if x > cMin.x and x < cMax.x and z > cMin.z and z < cMax.z then
								numInLayer = numInLayer + 1
							end
						end
	
						ni = ni + 1 -- Only increment noise index in mapchunk
					end
				end
				vi = vi + 1
			end
		end
		layers[y] = numInLayer / mapchunkArea * 100
		numInLayer = 0
	end

	vm:set_data(data)
	vm:set_lighting({day = 0, night = 0})
	vm:calc_lighting()
	vm:update_liquids()
	vm:write_to_map()
		
	if DEBUG then
		local chugent = math.ceil((os.clock() - t1) * 1000)
		print ("[nether] generate chunk " .. chugent .. " ms")
	end
	-- Check for flat area to place nether base
	numInLayer = 0
	local prevY
	local nextY
	for yVal, percent in pairs(layers) do
		prevY = layers[yVal - 1]
		nextY = layers[yVal + 1]
		if nextY and prevY then
			if nextY < 20 and prevY > 80 then -- At nextY, mostly air, at prevY, mostly netherrack (Doesn't always work but still good enough)
				if math.random(1, 1) == 1 then
					local path = mpath .. "/schematics/nether_base.mts"
					minetest.place_schematic({x = randX, y = yVal - 4, z = randZ}, path, "random", nil, true)
				end
				return
			end
		end
	end
end
