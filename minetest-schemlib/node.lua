local mapping = schemlib.mapping

--------------------------------------
--	Node class
--------------------------------------
local node_class = {}
local node_class_mt = {__index = node_class}
local node = {}
node.node_class = node_class
-------------------------------------
--	Create new node
--------------------------------------
function node.new(data)
	local self = setmetatable({}, node_class_mt)

	self.name = data.name
	assert(self.name, "No name given for node object")

	self.data = {}
	-- compat: param2
	self.data.param2 = data.param2 or 0
	self.data.prob = data.prob

		-- metadata is only of intrest if it is not empty
	if data.meta then
		if (data.meta.fields and next(data.meta.fields)) or
				(data.meta.inventory and next(data.meta.inventory)) then
			self.data.meta = data.meta
		end
	end

	return self
end

-------------------------------------
--	Get node position in the world
--------------------------------------
function node_class:get_world_pos()
	if not self._world_pos then
		self._world_pos = self.plan:get_world_pos(self._plan_pos)
	end
	return self._world_pos
end

-------------------------------------
--	Handle rotation
--------------------------------------
function node_class:rotate_facedir(facedir)
	-- rotate wallmounted
	local mapped = self.mapped
	mapped.param2_plan_rotation = mapped.param2
	if mapped.node_def.paramtype2 == "wallmounted" then
		local param2_dir = mapped.param2 % 8
		local param2_color = mapped.param2 - param2_dir
		if self.plan.data.mirrored then
			param2_dir = node.rotation_wallmounted_mirrored_map[param2_dir]
		end
		mapped.param2 = node.rotation_wallmounted_map[facedir][param2_dir] + param2_color
	elseif mapped.node_def.paramtype2 == "facedir" then
		-- rotate facedir
		local param2_dir = mapped.param2 % 32
		local param2_color = mapped.param2 - param2_dir
		if self.plan.data.mirrored then
			param2_dir =  node.rotation_facedir_mirrored_map[param2_dir]
		end
		mapped.param2 = node.rotation_facedir_map[facedir][param2_dir] + param2_color
	end
end


-------------------------------------
--	Get all information to build the node
--------------------------------------
function node_class:get_mapped()
	if self.mapped == 'unknown' then
		return
	end
	local mappedinfo = self.plan.mapping_cache[self.name]
	if not mappedinfo then
		mappedinfo = mapping.map(self.name, self.plan)
		self.plan.mapping_cache[self.name] = mappedinfo
		self.mapped = nil
	end

	if not mappedinfo or mappedinfo == 'unknown' then
		self.plan.mapping_cache[self.name] = 'unknown'
		self.mapped = 'unknown'
		return
	end

	if self.mapped then
		return self.mapped
	end

	local mapped = table.copy(mappedinfo)
	mapped.name = mapped.name or self.data.name
	mapped.param2 = mapped.param2 or self.data.param2
	mapped.meta = mapped.meta or self.data.meta
	mapped.prob = mapped.prob or self.data.prob

	if mapped.custom_function then
		mapped.custom_function(mapped, self)
		mapped.custom_function = nil
	end

	mapped.content_id = minetest.get_content_id(mapped.name)
	self.mapped = mapped
	self.cost_item = mapped.cost_item -- workaround / backwards compatibility to npcf_builder

	self:rotate_facedir(self.plan.data.facedir)
	return mapped
end


--------------------------------------
-- get node under this one if exists
--------------------------------------
function node_class:get_under()
	return self.plan:get_node({x=self._plan_pos.x, y=self._plan_pos.y-1, z=self._plan_pos.z})
end

--------------------------------------
-- get node above this one if exists
--------------------------------------
function node_class:get_above()
	return self.plan:get_node({x=self._plan_pos.x, y=self._plan_pos.y+1, z=self._plan_pos.z})
end

--------------------------------------
-- get plan_pos of attached node, or nil if not attached
--------------------------------------
function node_class:get_attached_to()
	local mapped = self:get_mapped()
	local attached_wallmounted
	if mapped.name == "doors:hidden" then
		attached_wallmounted = 1 --bellow
	elseif mapped.node_def.groups.attached_node then
		if mapped.node_def.paramtype2 == "wallmounted" then
			attached_wallmounted = mapped.param2_plan_rotation
		else
			attached_wallmounted = 1 --bellow
		end
	end
	if attached_wallmounted then
		local dir = node.wallmounted_to_dir[attached_wallmounted]
		return vector.add(self._plan_pos, dir)
	end
end

--------------------------------------
-- add/build a node
--------------------------------------
function node_class:place()
	local mapped = self:get_mapped()
	local world_pos = self:get_world_pos()
	if mapped then
		minetest.add_node(world_pos, mapped)
		if mapped.meta then
			minetest.get_meta(world_pos):from_table(mapped.meta)
		end
	end
	if not self.final_node_name then
		self:remove_from_plan()
	end
end

--------------------------------------
-- Delete node from plan
--------------------------------------
function node_class:remove_from_plan()
	self.plan:del_node(self._plan_pos)
end


--------------------------------------
-- Precalculated rotation mapping
--------------------------------------
node.rotation_wallmounted_map = {
	[0] = {1,2,3,4,5,[0] = 0},
	[1] = {1,5,4,2,3,[0] = 0},
	[2] = {1,3,2,5,4,[0] = 0},
	[3] = {1,4,5,3,2,[0] = 0},
}
node.rotation_wallmounted_mirrored_map = {1,3,2,4,5,[0] = 0}

node.rotation_facedir_map = {
	[0] = { 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,[0] = 0},
	[1] = { 2, 3, 0,13,14,15,12,17,18,19,16, 9,10,11, 8, 5, 6, 7, 4,23,20,21,22,[0] = 1},
	[2] = { 3, 0, 1,10,11, 8, 9, 6, 7, 4, 5,18,19,16,17,14,15,12,13,22,23,20,21,[0] = 2},
	[3] = { 0, 1, 2,19,16,17,18,15,12,13,14, 7, 4, 5, 6,11, 8, 9,10,21,22,23,20,[0] = 3},
}
node.rotation_facedir_mirrored_map = {3, 2, 1, 4, 7, 6, 5, 8, 11,10,9,16,19,18,17,12,15,14,13,20,23,22,21,[0] = 0}


node.wallmounted_to_dir = {
	[0] = {x=0,y=1,z=0},
	[1] = {x=0,y=-1,z=0},
	[2] = {x=1,y=0,z=0},
	[3] = {x=-1,y=0,z=0},
	[4] = {x=0,y=0,z=1},
	[5] = {x=0,y=0,z=-1},
}
--[[
--- Temporary code to calculate the wallmounted map
node.rotation_wallmounted_map = {}
for rotate = 0, 3 do -- facedir
	node.rotation_wallmounted_cache[rotate] = {}
	for wallmounted = 0, 5 do
		local facedir, new_wallmounted
		if wallmounted > 1 then
			if wallmounted == 2 then
				facedir = 1
			elseif wallmounted == 3 then
				facedir = 3
			elseif wallmounted == 4 then
				facedir = 0
			elseif wallmounted == 5 then
				facedir = 2
			end
			facedir = (facedir + rotate) % 4 --rotate
			if facedir == 1 then
				new_wallmounted = 2
			elseif facedir == 3 then
				new_wallmounted = 3
			elseif facedir == 0 then
				new_wallmounted = 4
			elseif facedir == 2 then
				new_wallmounted = 5
			end
		else
			new_wallmounted = wallmounted
		end
		node.rotation_wallmounted_cache[rotate][wallmounted] = new_wallmounted
	end
end
print(dump(node.rotation_wallmounted_cache))
]]

--[[
local direction_map = {1, 3, 2, 4}
local direction_map_mirror = {1, 4, 2, 3}

for rotate = 0, 3 do
	node.rotation_facedir_map[rotate] = {}
	for wal_direction = 0, 5 do
		for wal_rotate = 0, 3 do
			local oldwal = wal_direction*4+wal_rotate
			if wal_direction == 0 then -- y+
				new_wal_direction = 0
				new_wal_rotate = (wal_rotate + rotate) % 4
			elseif wal_direction == 5 then -- y-
				new_wal_direction = 5
				new_wal_rotate = (4+wal_rotate - rotate) % 4
			else
				new_wal_direction = direction_map[(direction_map[wal_direction] + rotate-1)%4+1]
				new_wal_rotate = (wal_rotate + rotate) % 4
				if rotate == 0 then
					local new_wal_rotate_mirror = new_wal_rotate
					if new_wal_rotate_mirror == 1 then
						new_wal_rotate_mirror = 3
					elseif new_wal_rotate_mirror == 3 then
						new_wal_rotate_mirror = 1
					end
					local new_wal_direction_mirror = direction_map_mirror[(direction_map[wal_direction] + rotate-1)%4+1]
					print(rotate, oldwal, (new_wal_direction_mirror*4+new_wal_rotate_mirror))
				end
			end
			node.rotation_facedir_map[rotate][oldwal] = new_wal_direction*4 + new_wal_rotate
		end
	end
end
print(dump(node.rotation_facedir_map))
-- ]]

-------------------
return node
