
village_sandcity = {}

village_sandcity.replacements_sandcity = function( housetype, pr, replacements )
	-- those guys are poor - all they have is sandstone

	-- but at least they've got suitable trees growing (either acacia or a palm type)
	local wood_type = mg_villages.replace_materials( replacements, pr,
		{'default:wood'},
		{''},
		{ 'default:acacia_wood', 'moretrees:palm_planks', 'ethereal:palm_wood' },
		'default:acacia_wood');
	mg_villages.replace_tree_trunk( replacements, wood_type );
	mg_villages.replace_saplings(   replacements, wood_type );

	mg_villages.replace_materials( replacements, pr,
			{'default:sandstonebrick'},
			{''},
			{'default:sandstonebrick', 'default:sandstonebrick',
			'default:clay', 'default:desert_stonebrick', 'default:desert_stone',
			'default:stonebrick', 'default:obsidianbrick'},
			'default:sandstonebrick');
	-- adds stairs and slabs for clay and loam
	if( minetest.get_modpath( 'cottages' )) then
		local mat = mg_villages.replace_materials( replacements, pr,
			{'default:sandstone'},
			{''},
			{'default:sandstone', 'default:clay', 'cottages:loam'},
			'default:sandstone');
		if(     mat == 'default:clay' ) then
			table.insert( replacements, {'stairs:stair_sandstone', 'stairs:stair_clay'});
			table.insert( replacements, {'stairs:slab_sandstone',  'stairs:slab_clay'});
		elseif( mat == 'cottages:loam') then
			table.insert( replacements, {'stairs:stair_sandstone', 'stairs:stair_loam'});
			table.insert( replacements, {'stairs:slab_sandstone',  'stairs:slab_loam'});
		end
	end
	return replacements;
end

-- add a new village type for all those buildings
mg_villages.add_village_type( 'sandcity', { min = 5, max = 60,  space_between_buildings=-1, mods={}, texture = 'default_sandstone.png',
		sapling_divisor = 10,
		-- the villages are sourrounded by some cacti which form some form of defense
		plant_type = 'default:cactus',
		-- there are not too many cacti
		plant_frequency = 30,
		-- the roads are a bit diffrent
		roadsize_list = {2,3,4,5,6},
		road_materials = {"default:desert_sand","default:desert_sand","default:desert_sand","default:desert_sand",
				"default:desert_sand","default:desert_sand","default:desert_sand","default:desert_sand"},
		-- we want desert sand as ground - so that the sandmobs can be happy
		force_ground = "default:desert_sand",
		-- below that, there's desert stone
		force_underground = "default:desert_stone",
		-- snow would look odd in such a desert village
		no_snow = true,
		replacement_function = village_sandcity.replacements_sandcity});

local path = minetest.get_modpath( 'village_sandcity' )..'/schems/';


mg_villages.add_building( { scm="sandcity_tiny_1_1_270", mts_path=path, weight={sandcity=1, single=1}, inh=nil,  typ='house'});
mg_villages.add_building( { scm="sandcity_tiny_2_1_270", mts_path=path, weight={sandcity=1, single=1}, inh=nil,  typ='house'});
mg_villages.add_building( { scm="sandcity_tiny_3_1_270", mts_path=path, weight={sandcity=1, single=1}, inh=nil,  typ='house'});
mg_villages.add_building( { scm="sandcity_tiny_4_1_270", mts_path=path, weight={sandcity=1, single=1}, inh=nil,  typ='house'});
mg_villages.add_building( { scm="sandcity_small_1_1_270", mts_path=path, weight={sandcity=1, single=1}, inh=nil,  typ='house'});
mg_villages.add_building( { scm="sandcity_small_2_1_270", mts_path=path, weight={sandcity=1, single=1}, inh=nil,  typ='house'});
mg_villages.add_building( { scm="sandcity_small_3_1_270", mts_path=path, weight={sandcity=1, single=1}, inh=nil,  typ='house'});
mg_villages.add_building( { scm="sandcity_small_4_1_270", mts_path=path, weight={sandcity=1, single=1}, inh=nil,  typ='house'});
mg_villages.add_building( { scm="sandcity_small_5_1_270", mts_path=path, weight={sandcity=1, single=1}, inh=nil,  typ='house'});
mg_villages.add_building( { scm="sandcity_meeting_small_1_1_270", mts_path=path, weight={sandcity=1, single=1}, inh=nil,  typ='house'});
mg_villages.add_building( { scm="sandcity_ap_tower_1_1_270", mts_path=path, weight={sandcity=1, single=1}, inh=nil,  typ='house'});
mg_villages.add_building( { scm="sandcity_ap_tower_2_1_270", mts_path=path, weight={sandcity=1, single=1}, inh=nil,  typ='house'});
mg_villages.add_building( { scm="sandcity_ap_tower_3_1_270", mts_path=path, weight={sandcity=1, single=1}, inh=nil,  typ='house'});
mg_villages.add_building( { scm="sandcity_ap_tower_4_1_270", mts_path=path, weight={sandcity=1, single=1}, inh=nil,  typ='house'});
mg_villages.add_building( { scm="sandcity_ap_tower_5_1_270", mts_path=path, weight={sandcity=1, single=1}, inh=nil,  typ='house'});
mg_villages.add_building( { scm="sandcity_ap_tower_6_1_270", mts_path=path, weight={sandcity=1, single=1}, inh=nil,  typ='house'});
mg_villages.add_building( { scm="sandcity_ap_tower_7_1_270", mts_path=path, weight={sandcity=1, single=1}, inh=nil,  typ='house'});
mg_villages.add_building( { scm="sandcity_ap_mixed_1_1_270", mts_path=path, weight={sandcity=1, single=1}, inh=nil,  typ='house'});
mg_villages.add_building( { scm="sandcity_ap_mixed_2_1_270", mts_path=path, weight={sandcity=1, single=1}, inh=nil,  typ='house'});
mg_villages.add_building( { scm="sandcity_ap_tiny_3_1_270", mts_path=path, weight={sandcity=1, single=1}, inh=nil,  typ='house'});
mg_villages.add_building( { scm="sandcity_ap_tiny_3b_1_270", mts_path=path, weight={sandcity=1, single=1}, inh=nil,  typ='house'});
mg_villages.add_building( { scm="sandcity_small_2_1_270", mts_path=path, weight={sandcity=1, single=1}, inh=nil,  typ='house'});
mg_villages.add_building( { scm="sandcity_small_3_1_270", mts_path=path, weight={sandcity=1, single=1}, inh=nil,  typ='house'});

