--possibly run this on generated to spawn mobs in newly loaded chunks


--this is debug to spawn mobs
open_ai.spawn_step = 0
open_ai.spawn_timer = 10 --spawn every x seconds
open_ai.spawn_table = {}

function get_suitable_spawn(pos1, pos2, def)
	local blocks = {}
	local vm = minetest.get_voxel_manip()
	local emin, emax = vm:read_from_map(pos1, pos2)
	local data = vm:get_data()
	local area = VoxelArea:new{MinEdge = emin, MaxEdge = emax}
	local block_id = minetest.get_content_id(def.spawn_node)
	for i_here in area:iter(pos1.x, pos1.y + 1, pos1.z, pos2.x, pos2.y - 1, pos2.z) do
		if data[i_here] == block_id then
			local pos = area:position(i_here)
			local i_above = area:index(pos.x, pos.y + 1, pos.z)
			minetest.log(minetest.get_name_from_content_id(i_above))
			local walkable = minetest.registered_nodes[minetest.get_name_from_content_id(i_above)].walkable
			if not walkable then
				table.insert(blocks, pos)
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
