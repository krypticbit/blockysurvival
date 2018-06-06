
village_towntest = {}

village_towntest.replacements_cornernote = function( housetype, pr, replacements )
      -- replace the wood - those are lumberjacks after all
      local wood_type = mg_villages.replace_materials( replacements, pr,
		{'default:wood'},
		{''},
		{ 'default:wood', 'default:junglewood', 'mg:savannawood', 'mg:pinewood' },
		'default:wood');
      mg_villages.replace_tree_trunk( replacements, wood_type );
      mg_villages.replace_saplings(   replacements, wood_type );

      mg_villages.replace_materials( replacements, pr,
		{'stairs:stair_cobble',  'stairs:slab_cobble', 'default:cobble'},
		{'stairs:stair_',         'stairs:slab_',      'default:'     },
		{'stonebrick', 'desert_stonebrick','sandstonebrick', 'sandstone','stone','desert_stone','stone_flat','desert_stone_flat','stone_bricks','desert_strone_bricks'},
		'stonebrick');

      return replacements;
end

-- add a new village type for all those buildings
mg_villages.add_village_type( 'cornernote', { min = 50, max = 60,  space_between_buildings=2, mods={}, texture = 'default_cobble.png',
			    replacement_function = village_towntest.replacements_cornernote});

local path = minetest.get_modpath( 'village_towntest' )..'/schems/';


mg_villages.add_building( { scm="towntest_ACDC_house_0_270",        mts_path=path, yoff=1, orients={1}, weight={cornernote=1, single=1}, inh=2,  typ='house'});

mg_villages.add_building( { scm="towntest_cornernote_hut1_1_0",     mts_path=path, weight={cornernote=1}, inh=1,  typ='hut'});
mg_villages.add_building( { scm="towntest_cornernote_hut2_1_90",    mts_path=path, weight={cornernote=1}, inh=1,  typ='hut'});
mg_villages.add_building( { scm="towntest_cornernote_hut3_1_180",   mts_path=path, weight={cornernote=1}, inh=1,  typ='hut'});
mg_villages.add_building( { scm="towntest_cornernote_fortress_4_0", mts_path=path, weight={cornernote=1/6, single=1}, inh=4,  typ='castle', avoid='castle'});
mg_villages.add_building( { scm="towntest_cornernote_tower_1_90",   mts_path=path, weight={cornernote=1/4}, inh=-1, typ='tower', avoid='tower'});
mg_villages.add_building( { scm="towntest_cornernote_turret_1_270", mts_path=path, weight={cornernote=1/4}, inh=-1, typ='tower', avoid='tower'});

mg_villages.add_building( { scm="towntest_irksomeduck_manor_0_180", mts_path=path, weight={cornernote=1, single=1}, inh=2,  typ='house'});

mg_villages.add_building( { scm="towntest_kddekadenz_barn1_1_270",  mts_path=path, weight={cornernote=1, single=1}, inh=-1, typ='shed'});
mg_villages.add_building( { scm="towntest_kddekadenz_barn2_1_270",  mts_path=path, weight={cornernote=1, single=1}, inh=-1, typ='shed'});
mg_villages.add_building( { scm="towntest_kddekadenz_castle_3_90",  mts_path=path, weight={cornernote=1, single=1}, inh=-1, typ='castle', avoid='castle'});
mg_villages.add_building( { scm="towntest_kddekadenz_factory_1_270",mts_path=path, weight={cornernote=1, single=1}, inh=-1, typ='shed'});
mg_villages.add_building( { scm="towntest_kddekadenz_gazebo_0_180", mts_path=path, weight={cornernote=1}, inh=-1, typ='park'});
mg_villages.add_building( { scm="towntest_kddekadenz_home1_1_270",  mts_path=path, weight={cornernote=1, single=1}, inh=-1, typ='house'});
mg_villages.add_building( { scm="towntest_kddekadenz_home2_1_270",  mts_path=path, weight={cornernote=1, single=1}, inh=-1, typ='house'});
mg_villages.add_building( { scm="towntest_kddekadenz_windmill_0_90",mts_path=path, weight={cornernote=1, single=1}, inh=-1, typ='mill',   pervillage = 1});

mg_villages.add_building( { scm="towntest_Nanuk_chapel_1_180",      mts_path=path, weight={cornernote=1, single=1}, inh=-1, typ='church', pervillage = 1});
mg_villages.add_building( { scm="towntest_Nanuk_lavabeacon_0_180",  mts_path=path, weight={cornernote=1, single=1}, inh=-1, typ='tower',  avoid='tower', pervillage = 1});
mg_villages.add_building( { scm="towntest_Nanuk_well_0_90",         mts_path=path, weight={cornernote=1, single=1}, inh=-1, typ='well'});

mg_villages.add_building( { scm="towntest_VanessaE_home1_1_270",    mts_path=path, weight={cornernote=1}, inh=-1, typ='house'});
mg_villages.add_building( { scm="towntest_VanessaE_home2_0_180",    mts_path=path, weight={cornernote=1}, inh=-1, typ='house'});

