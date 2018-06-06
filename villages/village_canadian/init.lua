
village_canadian = {}

village_canadian.replacements_canadian = function( housetype, pr, replacements )

      table.insert( replacements, {'4seasons:slimtree_wood', 'default:fence_wood'});
      if( true) then return replacements; end -- TODO
      -- remove inner corners, wallpapers etc.
      local to_air = { 38, 36, 68, 66, 69, 67, 77, 47, 44, 43, 37, 75, 45, 65, 71, 76, 46 };
      for _,v in ipairs( to_air ) do
         table.insert( replacements, {'hdb:'..tostring( v )..'_ic',  'air' });
      end
 
      to_air = { 49, 50, 52, 72, 73, 74 };
      for _,v in ipairs( to_air ) do
         table.insert( replacements, {'hdb:'..tostring( v )..'_edge',  'air' });
      end
 
      to_air = { 49, 50, 52, 72, 73, 74 };
      for _,v in ipairs( to_air ) do
         table.insert( replacements, {'hdb:'..tostring( v )..'_edgeic',  'air' });
      end

      -- thin slabs for covering walls
      to_air = { 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 65, 66, 67, 68, 69, 71, 72, 73, 74, 75, 76, 77 };
      for _,v in ipairs( to_air ) do
         table.insert( replacements, {'hdb:'..tostring( v ),  'air' });
      end

     -- these contain the majority of nodes used (junglewood is too dark)
      local materials = {'default:wood', 'default:pinewood', 'mg:pinewood', 'mg:savannawood',
		'default:clay', 'default:brick', 'default:sandstone', 
		'default:stonebrick', 'default:desert_stonebrick','default:sandstonebrick', 'default:sandstone','default:stone','default:desert_stone',
		'default:coalblock','default:steelblock'};

--      local change_groups = { {49, 16, 29, 33, 82, 8}, {19,  4, 83,  2}, { 5, 80, 35, 36, 3}, {10, 31}, {28, 78}, { 6, 52, 1}, {7}};
      local change_groups = { {16, 29, 33, 82, 8}, {19,  4, 83,  2}, { 5, 80, 35, 3}, {10, 31}, {28, 78, 27}, { 6, 1}, {7}, {30,25,81,79},{64}};
      for _,cg in ipairs( change_groups ) do

         local m1 = materials[ pr:next( 1, #materials )];
         for j,v in ipairs( cg ) do
            table.insert( replacements, {'hdb:'..tostring( v ), m1 });
         end
      end

      -- hdb:9_lh and hdb:86_lh are slabs
      local materials_slab = {'stonebrick', 'stone', 'sandstone', 'cobble' };
      local slab_group = {33,58};
      for _, c in ipairs( slab_group ) do 
         local ms = materials_slab[ pr:next( 1, #materials_slab )];
         table.insert( replacements, { 'hdb:'..tostring(c)..'_lh',     'stairs:slab_'..ms });
         table.insert( replacements, { 'hdb:'..tostring(c),            'default:'..ms });
      end

      return replacements;
end

-- add a new village type for all those buildings
mg_villages.add_village_type( 'canadian', { min = 40, max = 110,  space_between_buildings=1, mods={'hdb','nbu'}, texture = 'wool_grey.png',
                            replacement_function = village_canadian.replacements_canadian});

local path = minetest.get_modpath( 'village_canadian' )..'/schems/';

-- include houses from LadyMacBeth, originally created for Mauvebics mm2 modpack; the houses seem to be in canadian village style (thus the name for this village type)
mg_villages.add_building( {scm="c_bank",        mts_path=path, yoff=  1, orients={2}, farming_plus=0, avoid='',     typ='shop',    weight={canadian=1}, inh=-2});
mg_villages.add_building( {scm="c_bank2",       mts_path=path, yoff=  1, orients={0}, farming_plus=0, avoid='',     typ='shop',    weight={canadian=1}, inh=-2});
mg_villages.add_building( {scm="c_bar",         mts_path=path, yoff=  1, orients={0}, farming_plus=0, avoid='',     typ='tavern',  weight={canadian=1}, inh=-2});
mg_villages.add_building( {scm="c_hotel",       mts_path=path, yoff=  1, orients={0}, farming_plus=0, avoid='',     typ='tavern',  weight={canadian=1}, inh=-2});
mg_villages.add_building( {scm="c_postoffice",  mts_path=path, yoff=  1, orients={0}, farming_plus=0, avoid='',     typ='shop',    weight={canadian=1}, pervillage=1, inh=-2});
mg_villages.add_building( {scm="c_bordello",    mts_path=path, yoff=  1, orients={0}, farming_plus=0, avoid='',     typ='tavern',  weight={canadian=1}, pervillage=1, inh=-2});
mg_villages.add_building( {scm="c_library",     mts_path=path, yoff=  1, orients={0}, farming_plus=0, avoid='',     typ='secular', weight={canadian=1}, pervillage=1, inh=-2});

mg_villages.add_building( {scm="g_observatory", mts_path=path, yoff=  1, orients={0}, farming_plus=0, avoid='',     typ='secular', weight={canadian=1}, pervillage=1, inh=-2});
mg_villages.add_building( {scm="g_court",       mts_path=path, yoff=  1, orients={0}, farming_plus=0, avoid='',     typ='secular', weight={canadian=1}, pervillage=1, inh=-2});
mg_villages.add_building( {scm="g_prefecture",  mts_path=path, yoff=  1, orients={0}, farming_plus=0, avoid='',     typ='secular', weight={canadian=1}, pervillage=1, inh=-2});
mg_villages.add_building( {scm="g_townhall",    mts_path=path, yoff=  1, orients={0}, farming_plus=0, avoid='',     typ='secular', weight={canadian=1}, pervillage=1, inh=-2});
mg_villages.add_building( {scm="g_park2",       mts_path=path, yoff= -1, orients={0}, farming_plus=0, avoid='',     typ='secular', weight={canadian=2},});

mg_villages.add_building( {scm="r_apartments",  mts_path=path, yoff=  1, orients={0}, farming_plus=0, avoid='',     typ='house_large',  weight={canadian=4}, inh=20});
mg_villages.add_building( {scm="r_rowhouses",   mts_path=path, yoff=  1, orients={2}, farming_plus=0, avoid='',     typ='house_large',  weight={canadian=4}, inh=16});
mg_villages.add_building( {scm="r_manorhouse",  mts_path=path, yoff=  1, orients={0}, farming_plus=0, avoid='',     typ='house_large',  weight={canadian=3}, inh=4});
mg_villages.add_building( {scm="r_triplex",     mts_path=path, yoff=  1, orients={0}, farming_plus=0, avoid='',     typ='house_large',  weight={canadian=3}, inh=10});


