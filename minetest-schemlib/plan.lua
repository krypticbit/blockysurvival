-- debug-print
--local dprint = print
local dprint = function(mg) return end

local save_restore = schemlib.save_restore
local modpath = schemlib.modpath
local node = schemlib.node
local mapping = schemlib.mapping

--------------------------------------
-- Plan class
--------------------------------------
local plan_class = {}
local plan_class_mt = {__index = plan_class}
--------------------------------------
-- Plan class-methods and attributes
--------------------------------------
local plan = {
	mapgen_process = {},
	plan_class = plan_class
}
local mapgen_process = plan.mapgen_process

--------------------------------------
-- Create new plan object
--------------------------------------
function plan.new(plan_id , anchor_pos)
	local self = setmetatable({}, plan_class_mt)
	self.plan_id = plan_id
	self.scm_data_cache = {}
	self.mapping_cache = {}
	self.data = {
			status = "new",
			min_pos = {},
			max_pos = {},
			groundnode_count = 0,
			nodeinfos = {},
			nodecount = 0,
			ground_y = -1, --if nothing defined, it is under the building

			facedir = 0,
			mirrored = false,
			anchor_pos = anchor_pos,
		}
	return self -- the plan object
end

--------------------------------------
-- Add node to plan
--------------------------------------
function plan_class:add_node(plan_pos, node)
	-- check if any old node is replaced
	local replaced_node = self:get_node(plan_pos)
	if replaced_node then
		self.data.nodeinfos[replaced_node.name].count = self.data.nodeinfos[replaced_node.name].count - 1
	else
		self.data.nodecount = self.data.nodecount + 1
		self.scm_data_cache[plan_pos.y] = self.scm_data_cache[plan_pos.y] or {}
		self.scm_data_cache[plan_pos.y][plan_pos.x] = self.scm_data_cache[plan_pos.y][plan_pos.x] or {}
	end

	-- Parse input data
	local node_name, node_data, node_meta
	if type(node) == "string" then
		node_name = node
		node_data = node
	else
		node_name = node.name
		if node.meta then
			if (node.meta.fields and next(node.meta.fields)) or
					(node.meta.inventory and next(node.meta.inventory)) then
				node_meta = node.meta
			end
		end
	end

	-- Adjust nodeinfo and prepare mapping cache
	local nodeinfo = self.data.nodeinfos[node_name]
	if not nodeinfo then
		nodeinfo = {name = node_name, count = 1}
		self.data.nodeinfos[node_name] = nodeinfo
	else
		nodeinfo.count = nodeinfo.count + 1
	end

	-- Check if storage could be stripped to name only
	if not node_data and not node_meta and not node.prob then
		local def = minetest.registered_nodes[node_name]
		if def and (not def.paramtype2 or def.paramtype2 == "none") then
			node_data = node.name
		end
	end

	if not node_data then
		node_data = { name = node_name, meta = node_meta, prob = node.prob, param2 = node.param2 }
	end
	self.scm_data_cache[plan_pos.y][plan_pos.x][plan_pos.z] = node_data
	self.modified = true
end

--------------------------------------
-- Adjust building size and ground info
--------------------------------------
function plan_class:adjust_building_info(plan_pos, node)
	dprint("Meep : " .. dump(plan_pos))
	-- adjust min/max position information
	if not self.data.max_pos.y or plan_pos.y > self.data.max_pos.y then
		self.data.max_pos.y = plan_pos.y
	end
	if not self.data.min_pos.y or plan_pos.y < self.data.min_pos.y then
		self.data.min_pos.y = plan_pos.y
	end
	if not self.data.max_pos.x or plan_pos.x > self.data.max_pos.x then
		self.data.max_pos.x = plan_pos.x
	end
	if not self.data.min_pos.x or plan_pos.x < self.data.min_pos.x then
		self.data.min_pos.x = plan_pos.x
	end
	if not self.data.max_pos.z or plan_pos.z > self.data.max_pos.z then
		self.data.max_pos.z = plan_pos.z
	end
	if not self.data.min_pos.z or plan_pos.z < self.data.min_pos.z then
		self.data.min_pos.z = plan_pos.z
	end

	if string.sub(node.name, 1, 18) == "default:dirt_with_" or
			node.name == "farming:soil_wet" then
		self.data.groundnode_count = self.data.groundnode_count + 1
		if self.data.groundnode_count == 1 then
			self.data.ground_y = plan_pos.y
		else
			self.data.ground_y = self.data.ground_y + (plan_pos.y - self.data.ground_y) / self.data.groundnode_count
		end
	end
end

--------------------------------------
-- Get node from plan
--------------------------------------
function plan_class:get_node(plan_pos)
	local cached_node = self.scm_data_cache[plan_pos.y] and
			self.scm_data_cache[plan_pos.y][plan_pos.x] and
			self.scm_data_cache[plan_pos.y][plan_pos.x][plan_pos.z]
	if not cached_node then
		return
	end
	local ret_node
	if type(cached_node) == "string" then
		ret_node = node.new({name = cached_node})
	else
		ret_node = node.new(cached_node)
	end
	ret_node.nodeinfo = self.data.nodeinfos[ret_node.name]
	ret_node.plan = self
	ret_node._plan_pos = plan_pos
	return ret_node
end

--------------------------------------
-- Delete node from plan
--------------------------------------
function plan_class:del_node(pos)
	if self.scm_data_cache[pos.y] then
		if self.scm_data_cache[pos.y][pos.x] then
			if self.scm_data_cache[pos.y][pos.x][pos.z] then
				local oldnode = self.scm_data_cache[pos.y][pos.x][pos.z]
				if type(oldnode) == "table" then
					oldnode = oldnode.name
				end
				self.data.nodeinfos[oldnode].count = self.data.nodeinfos[oldnode].count - 1
				self.data.nodecount = self.data.nodecount - 1
				self.scm_data_cache[pos.y][pos.x][pos.z] = nil
			end
			if not next(self.scm_data_cache[pos.y][pos.x]) then
				self.scm_data_cache[pos.y][pos.x] = nil
			end
		end
		if not next(self.scm_data_cache[pos.y]) then
			self.scm_data_cache[pos.y] = nil
		end
	end
	self.modified = true
end

--------------------------------------
-- Get a random position of an existing node in plan
--------------------------------------
-- get nodes for selection which one should be build
-- skip parameter is randomized
function plan_class:get_random_plan_pos()
	dprint("get random plan position")

	-- get random existing y
	local keyset = {}
	for k in pairs(self.scm_data_cache) do table.insert(keyset, k) end
	if #keyset == 0 then --finished
		return
	end
	local y = keyset[math.random(#keyset)]

	-- get random existing x
	keyset = {}
	for k in pairs(self.scm_data_cache[y]) do table.insert(keyset, k) end
	local x = keyset[math.random(#keyset)]

	-- get random existing z
	keyset = {}
	for k in pairs(self.scm_data_cache[y][x]) do table.insert(keyset, k) end
	local z = keyset[math.random(#keyset)]

	if z then
		return {x=x,y=y,z=z}
	end
end

--------------------------------------
-- Generate a plan from schematics file
--------------------------------------
function plan_class:read_from_schem_file(filename)
	-- Minetest Schematics
	if string.find(filename, '.mts',  -4) then
		local str = minetest.serialize_schematic(filename, "lua", {})
		if not str then
			dprint("error: could not open file \"" .. filename .. "\"")
			return
		end
		local schematic = loadstring(str.." return(schematic)")()
			--[[	schematic.yslice_prob = {{ypos = 0,prob = 254},..}
					schematic.size = { y = 18,x = 10, z = 18},
					schematic.data = {{param2 = 2,name = "default:tree",prob = 254},..}
				]]

		-- analyze the file
		for i, ent in ipairs( schematic.data ) do
			if ent.name ~= "air" then
				local pos = {
						z = math.floor((i-1)/schematic.size.y/schematic.size.x),
						y = math.floor((i-1)/schematic.size.x) % schematic.size.y,
						x = (i-1) % schematic.size.x
					}
				self:add_node(pos, ent)
				self:adjust_building_info(pos, ent)
			end
		end
	-- WorldEdit files
	elseif string.find(filename, '.we',   -3) or string.find(filename, '.wem',  -4) then
		local file = io.open( filename, 'r' )
		if not file then
			dprint("error: could not open file \"" .. filename .. "\"")
			return
		end
		local nodes = schemlib.worldedit_file.load_schematic(file:read("*a"))
		-- analyze the file
		for i, ent in ipairs( nodes ) do
			local pos = {x=ent.x, y=ent.y, z=ent.z}
			self:add_node(pos, ent)
			self:adjust_building_info(pos, ent)
		end
	end
	dprint("Loaded")
end

--------------------------------------
-- Flood ta buildingplan with air
--------------------------------------
function plan_class:apply_flood_with_air(add_max, add_min, add_top)
	self.data.ground_y =  math.floor(self.data.ground_y)
	add_max = add_max or 3
	add_min = add_min or 0
	add_top = add_top or 5

	-- cache air_id
	local air_id

	dprint("create flatting plan")
	for y = self.data.min_pos.y, self.data.max_pos.y + add_top do
		--calculate additional grounding
		if y > self.data.ground_y then --only over ground
			local high = y-self.data.ground_y
			add_min = high + 1
			if add_min > add_max then --set to max
				add_min = add_max
			end
		end

		dprint("flat level:", y)
		for x = self.data.min_pos.x - add_min, self.data.max_pos.x + add_min do
			for z = self.data.min_pos.z - add_min, self.data.max_pos.z + add_min do
				local pos = {x=x, y=y, z=z}
				if not self:get_node(pos) then
					self:add_node(pos, "air")
				end
			end
		end
	end
	dprint("flatting plan done")
end

--------------------------------------
-- Propose anchor position for the plan
--------------------------------------
function plan_class:propose_anchor(world_pos, do_check, add_xz)
	add_xz = add_xz or 4 --distance to other buildings to check should be the same additional air filler + distance

	-- hard-coded at the first
	local max_error_rate = 0.1  -- 10%
	local search_range_y = 8
	local max_hanging = 3
	local max_bury = 5

	local minp = self:get_world_minp(world_pos)
	local maxp = self:get_world_maxp(world_pos)

	local max_error = (self.data.max_pos.x - self.data.min_pos.x + 1) * (self.data.max_pos.z - self.data.min_pos.z + 1) * max_error_rate

	dprint("check anchor proposal", minetest.pos_to_string(minp), minetest.pos_to_string(world_pos), minetest.pos_to_string(maxp), "check:", do_check)
	-- to get some randomization for error-node
	local minx, maxx, stx, miny, maxy, minz, maxz, stz
	if math.random(2) == 1 then
		minx = minp.x-add_xz
		maxx = maxp.x+add_xz
		stx = 1
	else
		maxx = minp.x-add_xz
		minx = maxp.x+add_xz
		stx = -1
	end
	if math.random(2) == 1 then
		minz = minp.z-add_xz
		maxz = maxp.z+add_xz
		stz = 1
	else
		maxz = minp.z-add_xz
		minz = maxp.z+add_xz
		stz = -1
	end
	miny = minp.y-search_range_y
	maxy = maxp.y+search_range_y

	local minp_regio = {x=minp.x-add_xz, y=miny, z=minp.z-add_xz}
	local maxp_regio = {x=maxp.x+add_xz, y=maxy, z=maxp.z+add_xz}
	self:load_region(minp_regio, maxp_regio) --full region because of processing in one step
	local ground_statistics = {}
	local ground_count = 0
	local error_count = 0
	local ground_min, ground_max

	for x = minx, maxx, stx do
		for z = minz, maxz, stz do
			local is_ground = ((x >= minp.x) or (x <= maxp.x)) and ((z >= minp.z) or (z <= maxp.z)) --ground check on the edges only
			for y = miny, maxy, 1 do
				local pos = {x=x, y=y, z=z}
				local node_index = self.vm_area:indexp(pos)
				local content_id = self.vm_data[node_index]
				--print(x,y,z,minetest.get_name_from_content_id(content_id))
				-- check if building allowed
				if do_check and mapping._protected_content_ids[content_id] then
					dprint("build denied because of not overridable", minetest.get_name_from_content_id(content_id), "at", x,y,z)
					return false, pos
				end

				-- check if surface found under the building edges
				if is_ground == true then
					if mapping._over_surface_content_ids[content_id] then
						is_ground = false --found
						if y == miny then
							error_count = error_count + 1
							if error_count > max_error then
								dprint("max error reached at bottom", x,y,z, error_count, max_error)
								return false, pos
							end
						else
							-- do not check additional nodes at the sites
							ground_count = ground_count + 1
							if not ground_min or ground_min > y then
								ground_min  = y
							end
							if not ground_max or ground_max < y then
								ground_max  = y
							end
							if not ground_statistics[y] then
								ground_statistics[y] = 1
							else
								ground_statistics[y] = ground_statistics[y] + 1
							end
						end
					end
				elseif do_check ~= true then
					break --y loop - found surface
				end
			end
			if is_ground == true then --nil is air only (no ground), true is ground only (no air)
				error_count = error_count + 1
				if error_count > max_error then
					dprint("max error reached above ", x,maxy, z, error_count, max_error)
					return false, {x=x, y=maxy, z=z}
				end
			end
		end
	end

	dprint("data:",  ground_min,  ground_max,  max_error,  error_count, ground_count, dump(ground_statistics))
	-- search for the best matched ground_y
	local ground_y
	while not ground_y do
		if ground_min == ground_max then -- really flat
			ground_y = ground_min
		else
			-- get min / max counters
			local min_count = ground_statistics[ground_min] or 0
			local min_count_newfaulty = ground_statistics[ground_min - max_hanging] or 0
			local max_count = ground_statistics[ground_max] or 0
			local max_count_newfaulty = ground_statistics[ground_max + max_bury] or 0
			-- compare adjustment under or above
				if min_count + min_count_newfaulty >= max_count + max_count_newfaulty then
				ground_max = ground_max - 1
				error_count = error_count + max_count_newfaulty
			else
				ground_min = ground_min + 1
				error_count = error_count + min_count_newfaulty
			end
			-- check the adjustment errors
			if error_count > max_error then
				dprint("max error reached in analysis ", error_count, max_error)
				return false
			end
			--print("debug", tostring(ground_y), ground_min, ground_max, error_count, min_count, max_count, min_count_newfaulty, max_count_newfaulty)
		end
	end

	-- only "y" needs to be proposed as usable ground
	if ground_y then
		dprint("proposed anchor high", ground_y)
		return {x=world_pos.x, y=ground_y, z=world_pos.z}
	end
end

--------------------------------------
-- Get world position relative to plan position
--------------------------------------
function plan_class:get_world_pos(plan_pos, anchor_pos)
	local apos = anchor_pos or self.data.anchor_pos
	local pos
	minetest.log(dump(plan_pos))
	if self.data.mirrored then
		pos = {x=plan_pos.x, y=plan_pos.y, z=plan_pos.z}
		pos.x = -pos.x
	else
		pos = plan_pos
	end
	local facedir_rotated = {
			[0] = function(pos,apos) return {
					x=pos.x+apos.x,
					y=pos.y+apos.y,
					z=pos.z+apos.z,
			}end,
			[1] = function(pos,apos) return {
					x=pos.z+apos.x,
					y=pos.y+apos.y,
					z=-pos.x+apos.z,
			} end,
			[2] = function(pos,apos) return {
					x=-pos.x+apos.x,
					y=pos.y+apos.y,
					z=-pos.z+apos.z,
			} end,
			[3] = function(pos,apos) return {
					x=-pos.z+apos.x,
					y=pos.y+apos.y,
					z=pos.x+apos.z,
			} end,
		}
	local ret = facedir_rotated[self.data.facedir](pos, apos)
	ret.y = ret.y - self.data.ground_y - 1
	return ret
end

--------------------------------------
-- Get plan position relative to world position
--------------------------------------
function plan_class:get_plan_pos(world_pos, anchor_pos)
	local apos = anchor_pos or self.data.anchor_pos
	local facedir_rotated = {
			[0] = function(pos,apos) return {
					x=pos.x-apos.x,
					y=pos.y-apos.y,
					z=pos.z-apos.z
				} end,
			[1] = function(pos,apos) return {
					x=-(pos.z-apos.z),
					y=pos.y-apos.y,
					z=(pos.x-apos.x),
			} end,
			[2] = function(pos,apos) return {
					x=-(pos.x-apos.x),
					y=pos.y-apos.y,
					z=-(pos.z-apos.z),
			} end,
			[3] = function(pos,apos) return {
					x=pos.z-apos.z,
					y=pos.y-apos.y,
					z=-(pos.x-apos.x),
			} end,
		}
	local ret = facedir_rotated[self.data.facedir](world_pos, apos)
	if self.data.mirrored then
		ret.x = -ret.x
	end
	ret.y = ret.y + self.data.ground_y + 1
	return ret
end

--------------------------------------
-- Get world minimum position relative to plan position
--------------------------------------
function plan_class:get_world_minp(anchor_pos)
	local pos = self:get_world_pos(self.data.min_pos, anchor_pos)
	local pos2 = self:get_world_pos(self.data.max_pos, anchor_pos)
	if pos2.x < pos.x then
		pos.x = pos2.x
	end
	if pos2.y < pos.y then
		pos.y = pos2.y
	end
	if pos2.z < pos.z then
		pos.z = pos2.z
	end
	return pos
end

--------------------------------------
-- Get world maximum relative to plan position
--------------------------------------
function plan_class:get_world_maxp(anchor_pos)
	local pos = self:get_world_pos(self.data.max_pos, anchor_pos)
	local pos2 = self:get_world_pos(self.data.min_pos, anchor_pos)
	if pos2.x > pos.x then
		pos.x = pos2.x
	end
	if pos2.y > pos.y then
		pos.y = pos2.y
	end
	if pos2.z > pos.z then
		pos.z = pos2.z
	end
	return pos
end

--------------------------------------
-- Check if world position is in plan
--------------------------------------
function plan_class:contains(chkpos, anchor_pos)
	local minp = self:get_world_minp(anchor_pos)
	local maxp = self:get_world_maxp(anchor_pos)

	return (chkpos.x >= minp.x) and (chkpos.x <= maxp.x) and
		(chkpos.y >= minp.y) and (chkpos.y <= maxp.y) and
		(chkpos.z >= minp.z) and (chkpos.z <= maxp.z)
end

--------------------------------------
-- Check if the plan overlaps with given area
--------------------------------------
function plan_class:check_overlap(minp, maxp, add_distance, anchor_pos)
	add_distance = add_distance or 0

	local minp_a = vector.subtract(minp, add_distance)
	local maxp_a = vector.add(maxp, add_distance)

	local minp_b = vector.subtract(self:get_world_minp(anchor_pos), add_distance)
	local maxp_b = vector.add(self:get_world_maxp(anchor_pos), add_distance)

	local overlap_pos = {}

	overlap_pos.x =
			(minp_a.x >= minp_b.x and minp_a.x <= maxp_b.x) and math.floor((minp_a.x+maxp_b.x)/2) or
			(maxp_a.x >= minp_b.x and maxp_a.x <= maxp_b.x) and math.floor((maxp_a.x+minp_b.x)/2) or
			(minp_b.x >= minp_a.x and minp_b.x <= maxp_a.x) and math.floor((minp_b.x+maxp_a.x)/2) or
			(maxp_b.x >= minp_a.x and maxp_b.x <= maxp_a.x) and math.floor((maxp_b.x+minp_a.x)/2)

	if not overlap_pos.x then
		return
	end

	overlap_pos.z =
			(minp_a.z >= minp_b.z and minp_a.z <= maxp_b.z) and math.floor((minp_a.z+maxp_b.z)/2) or
			(maxp_a.z >= minp_b.z and maxp_a.z <= maxp_b.z) and math.floor((maxp_a.z+minp_b.z)/2) or
			(minp_b.z >= minp_a.z and minp_b.z <= maxp_a.z) and math.floor((minp_b.z+maxp_a.z)/2) or
			(maxp_b.z >= minp_a.z and maxp_b.z <= maxp_a.z) and math.floor((maxp_b.z+minp_a.z)/2)
	if not overlap_pos.z then
		return
	end

	overlap_pos.y =
			(minp_a.y >= minp_b.y and minp_a.y <= maxp_b.y) and math.floor((minp_a.y+maxp_b.y)/2) or
			(maxp_a.y >= minp_b.y and maxp_a.y <= maxp_b.y) and math.floor((maxp_a.y+minp_b.y)/2) or
			(minp_b.y >= minp_a.y and minp_b.y <= maxp_a.y) and math.floor((minp_b.y+maxp_a.y)/2) or
			(maxp_b.y >= minp_a.y and maxp_b.y <= maxp_a.y) and math.floor((maxp_b.y+minp_a.y)/2)
	if not overlap_pos.y then
		return
	end

	dprint("Overlap",
			"minp_a:"..minetest.pos_to_string(minp_a),
			"maxp_a:"..minetest.pos_to_string(maxp_a),
			"minp_b:"..minetest.pos_to_string(minp_b),
			"maxp_b:"..minetest.pos_to_string(maxp_b),
			"=>"..minetest.pos_to_string(overlap_pos))
	return overlap_pos
end

--------------------------------------
-- Get a nodes list for a world chunk
--------------------------------------
function plan_class:get_chunk_nodes(plan_pos, anchor_pos)
-- calculate the begin of the chunk
	--local BLOCKSIZE = core.MAP_BLOCKSIZE
	local BLOCKSIZE = 16
	local wpos = self:get_world_pos(plan_pos, anchor_pos)
	local minp = {}
	minp.x = (math.floor(wpos.x/BLOCKSIZE))*BLOCKSIZE
	minp.y = (math.floor(wpos.y/BLOCKSIZE))*BLOCKSIZE
	minp.z = (math.floor(wpos.z/BLOCKSIZE))*BLOCKSIZE
	local maxp = vector.add(minp, 16)

	dprint("nodes for chunk (real-pos)", minetest.pos_to_string(minp), minetest.pos_to_string(maxp))

	local minv = self:get_plan_pos(minp)
	local maxv = self:get_plan_pos(maxp)
	dprint("nodes for chunk (plan-pos)", minetest.pos_to_string(minv), minetest.pos_to_string(maxv))

	local ret = {}
	for y = minv.y, maxv.y do
		if self.scm_data_cache[y] then
			for x = minv.x, maxv.x do
				if self.scm_data_cache[y][x] then
					for z = minv.z, maxv.z do
						if self.scm_data_cache[y][x][z] then
							table.insert(ret, self:get_node({x=x, y=y,z=z}))
						end
					end
				end
			end
		end
	end
	dprint("nodes in chunk to build", #ret)
	return ret, minp, maxp -- minp/maxp are worldpos
end

--------------------------------------
-- Add/build a chunk
--------------------------------------
function plan_class:do_add_chunk_place(plan_pos)
	dprint("---build chunk", minetest.pos_to_string(plan_pos))
	local chunk_nodes = self:get_chunk_nodes(plan_pos)
	dprint("Instant build of chunk: nodes:", #chunk_nodes)
	for idx, node in ipairs(chunk_nodes) do
		node:place()
	end
end

--------------------------------------
-- Load a region to the voxel
--------------------------------------
function plan_class:load_region(min_world_pos, max_world_pos)
	if not max_world_pos then
		max_world_pos = min_world_pos
	end
	self._vm = minetest.get_voxel_manip()
	self._vm_minp, self._vm_maxp = self._vm:read_from_map(min_world_pos, max_world_pos)
	self.vm_area = VoxelArea:new({MinEdge = self._vm_minp, MaxEdge = self._vm_maxp})
	self.vm_data = self._vm:get_data()
	self.vm_param2_data = self._vm:get_param2_data()
end

--------------------------------------
-- Add/build a chunk using VoxelArea (internal usage)
--------------------------------------
function plan_class:do_add_chunk_voxel_int()
	local meta_fix = {}
	local on_construct_fix = {}

	for idx, origdata in pairs(self.vm_data) do
		local wpos = self.vm_area:position(idx)
		local pos = self:get_plan_pos(wpos)
		local node = self:get_node(pos)
		if node then
			local mapped = node:get_mapped()
			if mapped and mapped.content_id then
				-- write to voxel
				self.vm_data[idx] = mapped.content_id
				self.vm_param2_data[idx] = mapped.param2

				-- Call the constructor
				if mapped.node_def.on_construct then
					on_construct_fix[wpos] = mapped.node_def.on_construct
				end

				-- Set again by node for meta
				if mapped.meta then
					meta_fix[wpos] = mapped
				end
			end
			self:del_node(pos)
		end
	end

	-- store the changed map data
	self._vm:set_data(self.vm_data)
	self._vm:set_param2_data(self.vm_param2_data)
	self._vm:calc_lighting()
	self._vm:update_liquids()
	self._vm:write_to_map()

	-- fix the nodes
	if next(meta_fix) or next(on_construct_fix) then
		minetest.after(0, function(meta_fix, on_construct_fix)

			for world_pos, func in pairs(on_construct_fix) do
				func(world_pos)
			end

			for world_pos, mapped in pairs(meta_fix) do
				minetest.get_meta(world_pos):from_table(mapped.meta)
			end
		end, meta_fix, on_construct_fix)
	end
end

--------------------------------------
-- Local function for emergeblocks callback
--------------------------------------
local function emergeblocks_callback(pos, action, num_calls_remaining, ctx)
	if not ctx.total_blocks then
		ctx.total_blocks   = num_calls_remaining + 1
		ctx.current_blocks = 0
	end
	ctx.current_blocks = ctx.current_blocks + 1

	if ctx.current_blocks == ctx.total_blocks then
		ctx.plan:load_region(ctx.pos, ctx.pos)
		ctx.plan:do_add_chunk_voxel_int()
		local pos_hash = minetest.hash_node_position(ctx.pos)
		mapgen_process[pos_hash] = nil
		if ctx.after_call_func then
			ctx.after_call_func(ctx.plan)
		end
	end
end

--------------------------------------
-- Add/build a chunk using VoxelArea
--------------------------------------
function plan_class:do_add_chunk_voxel(plan_pos, after_call_func)
	-- Register for on_generate build
	local chunk_pos = self:get_world_pos(plan_pos)
	local BLOCKSIZE = 16
	chunk_pos.x = (math.floor(chunk_pos.x/BLOCKSIZE))*BLOCKSIZE
	chunk_pos.y = (math.floor(chunk_pos.y/BLOCKSIZE))*BLOCKSIZE
	chunk_pos.z = (math.floor(chunk_pos.z/BLOCKSIZE))*BLOCKSIZE
	minetest.emerge_area(chunk_pos, chunk_pos, emergeblocks_callback, {
		plan = self,
		pos = chunk_pos,
		after_call_func = after_call_func
	})
end

--------------------------------------
-- Add/build a chunk using VoxelArea called from mapgen
--------------------------------------
function plan_class:do_add_chunk_mapgen()
	plan._vm, plan._vm_minp, plan._vm_maxp = minetest.get_mapgen_object("voxelmanip")
	plan.vm_area = VoxelArea:new({MinEdge = plan._vm_minp, MaxEdge = plan._vm_maxp})
	plan.vm_data = plan._vm:get_data()
	plan.vm_param2_data = plan._vm:get_param2_data()
	self:do_add_chunk_voxel_int()
	local pos_hash = minetest.hash_node_position(plan._vm_minp)
	mapgen_process[pos_hash] = nil
end


--------------------------------------
-- Add all chunks using VoxelArea asynchronous
--------------------------------------
function plan_class:do_add_all_voxel_async()
	if not self:get_status() == "build" then
		return
	end

	local random_pos = self:get_random_plan_pos()
	if not random_pos then
		return
	end

	dprint("---async build chunk", minetest.pos_to_string(random_pos))
	self:do_add_chunk_voxel(random_pos, function(self)
		dprint("async build nodes left:", self.data.nodecount)
		if self:get_status() == "build" then
			--start next plan chain
			minetest.after(0.1, self.do_add_all_voxel_async, self)
		end
	end)
end

--------------------------------------
-- Add/build a chunk using VoxelArea
--------------------------------------
function plan_class:do_add_all_mapgen_async()
	-- Register for on_generate build
	local BLOCKSIZE = 16
	local minp = self:get_world_minp()
	local maxp = self:get_world_maxp()
	minp.x = (math.floor(minp.x/BLOCKSIZE))*BLOCKSIZE
	minp.y = (math.floor(minp.y/BLOCKSIZE))*BLOCKSIZE
	minp.z = (math.floor(minp.z/BLOCKSIZE))*BLOCKSIZE
	maxp.x = (math.floor(maxp.x/BLOCKSIZE))*BLOCKSIZE
	maxp.y = (math.floor(maxp.y/BLOCKSIZE))*BLOCKSIZE
	maxp.z = (math.floor(maxp.z/BLOCKSIZE))*BLOCKSIZE
	for x = minp.x, maxp.y, BLOCKSIZE do
		for y = minp.y, maxp.y, BLOCKSIZE do
			for z = minp.z, maxp.z, BLOCKSIZE do
				local pos_hash = minetest.hash_node_position({x=x, y=y, z=z})
				mapgen_process[pos_hash] = self
			end
		end
	end
end

--------------------------------------
-- Get the building status. (new, build, pause, finished)
--------------------------------------
function plan_class:get_status()
	if self.data.status == "build" then
		if self.data.nodecount == 0 then
			dprint("finished by nodecount 0 in get_status")
			self.data.status = "finished"
		end
	end
	return self.data.status
end

--------------------------------------
-- Set the building status. (new, build, pause, finished)
--------------------------------------
function plan_class:set_status(status)
	self.data.status = status
	if status == "build" then
		minetest.after(0.1, self.do_add_all_voxel_async, self)
	end
end

--------------------------------------
-- Process registered on generated chunks
--------------------------------------
minetest.register_on_generated(function(minp, maxp, blockseed)
	local pos_hash = minetest.hash_node_position(minp)
	local plan = mapgen_process[pos_hash]
	if not plan then
		return
	end
	plan:do_add_chunk_mapgen()
end)

return plan
