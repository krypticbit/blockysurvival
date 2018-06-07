--possibly run this on generated to spawn mobs in newly loaded chunks


--this is debug to spawn mobs
open_ai.spawn_step = 0
open_ai.spawn_timer = 70 --spawn every x seconds
open_ai.spawn_table = {}

function get_suitable_spawn(pos1, pos2, def)
	blocks = {}
	local vm = minetest.get_voxel_manip()
	local emin, emax = vm:read_from_map(pos1, pos2)
	local data = vm:get_data()
	local area = VoxelArea:new{MinEdge = emin, MaxEdge = emax}
	local block_id = minetest.get_content_id(def.spawn_node)
	local air_id = minetest.get_content_id("air")
	for z = pos1.z, pos2.z do
		for y = pos1.y + 1, pos2.y - 1 do -- Needs to be able to check if the node above is air, and sometimes if the node below is water
			for x = pos1.x, pos2.x do
				local voxel_ind = area:index(x, y, z)
				if data[voxel_ind] == block_id then -- Mob spawns on block
					minetest.log(minetest.get_name_from_content_id(data[voxel_ind]))
					local above_voxel_ind = area:index(x, y + 1, z)
					local is_walkable = minetest.registered_nodes[minetest.get_name_from_content_id(data[above_voxel_ind])].walkable -- Determine if node above is walkable
					if not is_walkable then -- Non-obstructing node above; air, grass, flowers, etc. (NOTE: Water souce walkable = false, fish can spawn underwater)
						if def.liquid_mob then -- If the mob swims
							local below_voxel_ind = area:index(x, y - 1, z) -- Make sure the liquid is at least 2 nodes deep
							if data[below_voxel_ind] == block_id then -- Liquid is at least two nodes deep
								table.insert(blocks, {x = x, y = y, z = z})
							end
						else
							table.insert(blocks, {x = x, y = y, z = z})
						end
					end
				end
			end
		end
	end
	return blocks
end

minetest.register_globalstep(function(dtime)
	open_ai.spawn_step = open_ai.spawn_step + dtime
	
	if open_ai.spawn_step > open_ai.spawn_timer then
		minetest.log("spawning")
		for _,player in ipairs(minetest.get_connected_players()) do
			if player:get_hp() > 0 then
				local pos = player:getpos()
				for mob,def_table in pairs(open_ai.spawn_table) do
					if math.random() < def_table.chance then
						--minetest.log(mob,dump(def_table))
						
						--test for nodes to spawn mobs in
						local test_for_node = get_suitable_spawn({x=pos.x-20,y=pos.y-20,z=pos.z-20}, {x=pos.x+20,y=pos.y+20,z=pos.z+20}, def_table)
						--if the table has a node position then spawn the mob
						local positions = table.getn(test_for_node)
						--if position is above 0 then spawn node was found successfully 
						if positions > def_table.min_percent * 4 then
							--get a random node out of the table and add 1 y to it to spawn mob above it
							--use the mob height eventually to spawn on the node exactly
							local pos2 = test_for_node[math.random(1,positions)]
							if def_table.liquid_mob ~= true then
								pos2.y = pos2.y - open_ai.defaults[mob]["collisionbox"][2]
							end
							minetest.log(mob .. "spawned at" .. minetest.serialize(pos2))
							minetest.add_entity(pos2, mob)
						end
					end
					
				end
			end
		end
		open_ai.spawn_step = 0
	end
end)
