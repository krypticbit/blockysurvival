-- extra mod
-- by dhausmig
-- consisting of many different things
---------------------------------------------------------------

minetest.log("action", "[MOD] Extra Mod - Version 1.1")

-- Support for localized strings if intllib mod is installed.
if minetest.get_modpath("intllib") then
	S = intllib.Getter()
else
	S = function ( s ) return s end
end

extra = {}
extra.version = "1.1"
extra.sand_mod     = true
extra.oil_mod      = true
extra.marinara_mod = true
extra.pasta_mod    = true
extra.pizza_mod    = true
extra.ore_recovery = true
extra.condensed    = true
extra.liquor       = true

local path = minetest.get_modpath("extra")

-- Load new settings if found
local input = io.open(path.."/settings.conf", "r")
if input then
	dofile(path .. "/settings.conf")
	input:close()
	input = nil
end

-- Detect which items are present so we can adjust which crafts get defined

extra.alloy = (minetest.registered_items["technic:lv_alloy_furnace"] ~= nil)
extra.cantrifuge = (minetest.registered_items["technic:mv_centrifuge"] ~= nil)
extra.extractor = (minetest.registered_items['technic:lv_extractor'] ~= nil)
extra.grinder = (minetest.registered_items["technic:grinder"] ~= nil)
extra.technic = (minetest.get_modpath("technic") ~= nil)
extra.tech_corn = (minetest.registered_items["technic:cornmeal"] ~= nil)
extra.comp = (minetest.registered_items["moreblocks:cobble_compressed"] ~= nil)
extra.cond = (minetest.registered_items["moreblocks:cobble_condensed"] == nil)

dofile(path .. "/nodes.lua")

---------------------------------------------------------------
if  minetest.registered_items["cottages:table"] ~= nil then
minetest.override_item("cottages:table", {
   node_box = {
      type = "fixed",
      fixed = {
         { -0.1, -0.5, -0.1,  0.1, 0.48,  0.1},
         { -0.5,  0.48, -0.5,  0.5, 0.4,  0.5},
      },
   },
})
end

---------------------------------------------------------------
-- this allows conversion of glass panes back to sand
-- does not increase or decrease resources
-- with the sand type given by example
-- also allows sand type to be changed by
-- sand -> glass -> panes -> different sand
if extra.sand_mod then
	dofile(path .. "/glass_sand.lua")
end

---------------------------------------------------------------
-- so many mods can be the source of materials
-- I try to work with as many mods as I can find
local cheese_list = {}
local corn_list = {}
local fish_list = {}
local garlic_list = {}
local meat_list = {}
local onion_list = {}
local potato_list = {}
local tomato_list = {}

for item, val in pairs(minetest.registered_items) do
   local colon = item:find(":")
   if colon then
      local name = item:sub(colon + 1)
      if name == "cheese" or
         name == "goatcheese" then
         table.insert(cheese_list, {item})
      end
      if name == "corn" then
         table.insert(corn_list, {item})
      end
      if name == "fish_raw" or
         name == "clownfish_raw" or
         name == "bluefish_raw" or
         name == "shark" or
         name == "shark_sm" or
         name == "shark_md" or
         name == "shark_lg" or
         name == "pike" or
         name == "pike_raw" then
         table.insert(fish_list, {item})
      end
      if name == "garlic_clove" then
         table.insert(garlic_list, {item})
      end
      if name == "meat_raw" or
         name == "chicken_raw" or
         name == "pork_raw" or
         name == "mutton_raw" or
         name == "rabbit_raw" or
         name == "meat_pork" or
         name == "meat_beef" or
         name == "meat_chicken" or
         name == "meat_lamb" or
         name == "meat_venison" or
         name == "meat_ostrich" or
         name == "meat" or
         name == "chicken_cooked" or
         name == "pork_cooked" or
         name == "mutton_cooked" or
         name == "rabbit_cooked" then
         table.insert(meat_list, {item})
      end
      if name == "potato" then
         table.insert(potato_list, {item})
      end
      if name == "onion" or
         name == "wild_onion_plant" then
         table.insert(onion_list, {item})
      end
      if name == "tomato" then
         table.insert(tomato_list, {item})
      end
   end
end

if #meat_list == 0 then
-- if no other meat is available we define our own
   minetest.register_craftitem("extra:meat_raw", {
      description = S("Raw Meat"),
      inventory_image = "extra_raw_meat.png",
      on_use = minetest.item_eat(2),
   })
   minetest.register_craft({
      output = "extra:meat_raw",
      type = "shapeless",
      recipe = {'farming:flour', 'default:apple', "farming:wheat"},
   })
   minetest.register_craftitem("extra:meat_cooked", {
      description = S("Cooked Meat"),
      inventory_image = "extra_cooked_meat.png",
      on_use = minetest.item_eat(6),
   })
   minetest.register_craft({
   	type = "cooking",
   	output = "extra:meat_cooked",
   	recipe = "extra:meat_raw",
   	cooktime = 4,
   })
   table.insert(meat_list, {"extra:meat_raw"})
   table.insert(meat_list, {"extra:meat_cooked"})
end

dofile(path .. "/craftitems.lua")

-- PASTA
if extra.pasta_mod then
   minetest.register_craft({
      output = 'extra:pasta 5',
      type = "shapeless",
      recipe = {'farming:flour', 'bucket:bucket_water'},
      replacements = {{ "bucket:bucket_water", "bucket:bucket_empty"}}
   })
end

local grinder_recipes = {}
for _, data in pairs(meat_list) do

-- PEPPERONI
   minetest.register_craft({
      type = "shapeless",
      output = 'extra:pepperoni',
      recipe = {data[1], 'farming:chili_pepper'},
   })

-- GROUND MEAT
   if extra.grinder then
      table.insert(grinder_recipes, {data[1], "extra:ground_meat"})
   else
      minetest.register_craft({
         type = "shapeless",
            output = "extra:ground_meat 4",
            recipe = {data[1], data[1], data[1], data[1]}
      })
   end
end

minetest.register_craft({
   type = "shapeless",
   output = "extra:meat_patty 2",
   recipe = {"extra:ground_meat"},
})

minetest.register_craft({
   type = "cooking",
   output = "extra:grilled_patty",
   recipe = "extra:meat_patty",
})

for _, tomato in pairs(tomato_list) do
   minetest.register_craft({
      type = "shapeless",
      output = "extra:tomato_slice 8",
      recipe = {tomato[1]},
   })
end

for _, onion in pairs(onion_list) do
   minetest.register_craft({
      type = "shapeless",
      output = "extra:onion_slice 8",
      recipe = {onion[1]},
   })

   minetest.register_craft({
      type = "shapeless",
      output = "extra:meatloaf_raw",
      recipe = {"extra:ground_meat", "extra:ground_meat", "farming:bread",
                onion[1]},
   })
end

for _, potato in pairs(potato_list) do
   minetest.register_craft({
      type = "shapeless",
      output = "extra:potato_slice 8",
      recipe = {potato[1]},
   })
end

minetest.register_craft({
   type = "shapeless",
   output = "extra:corn_dog_raw 3",
   recipe = {"extra:ground_meat", "extra:cornmeal", "default:stick",
      "default:stick", "default:stick"},
})

minetest.register_craft({
   type = "cooking",
   output = "extra:corn_dog",
   recipe = "extra:corn_dog_raw",
})

minetest.register_craft({
   type = "cooking",
   output = "extra:meatloaf 6",
   recipe = "extra:meatloaf_raw",
})

minetest.register_craft({
   type = "shapeless",
   output = "extra:hamburger",
   recipe = {"farming:bread", "extra:grilled_patty", "extra:tomato_slice",
             "extra:onion_slice"},
})

for _, cheese in pairs(cheese_list) do
   minetest.register_craft({
      type = "shapeless",
      output = "extra:cheeseburger",
      recipe = {"farming:bread", "extra:grilled_patty", cheese[1],
                "extra:grilled_patty", cheese[1]},
   })
end

-- MARINARA
if extra.marinara_mod then
   for _, tomato in pairs(tomato_list) do
      for _, onion in pairs(onion_list) do
         for _, garlic in pairs(garlic_list) do
            minetest.register_craft({
               type = "shapeless",
                  output = "extra:marinara",
                  recipe = {tomato[1], tomato[1], onion[1], garlic[1]}
            })
         end
      end
   end
end

-- SALSA

for _, tomato in pairs(tomato_list) do
   for _, onion in pairs(onion_list) do
      minetest.register_craft({
         type = "shapeless",
         output = "extra:salsa",
         recipe = {"farming:chili_pepper", onion[1], tomato[1]},
      })
   end
end

-- COTTONSEED OIL
if extra.oil_mod then
   minetest.register_craft({
      output = 'extra:cottonseed_oil',
      recipe = {
         {'farming:seed_cotton', 'farming:seed_cotton', 'farming:seed_cotton'},
         {'farming:seed_cotton', 'farming:seed_cotton', 'farming:seed_cotton'},
         {'farming:seed_cotton', 'farming:seed_cotton', 'farming:seed_cotton'},
      }
   })

   if extra.extractor then
		technic.register_extractor_recipe({input = {"farming:seed_cotton 3"},
         output = "extra:cottonseed_oil"})
   end

   minetest.register_craft({
      type = "fuel",
      recipe = "extra:cottonseed_oil",
      burntime = 40,
   })

-- ONION RINGS, POTATO CRISPS, FRENCH FRIES, BLOOMING ONION, and FISH STICKS
   if extra.alloy then
      local alloy_recipes = {
         {"extra:onion_slice 4",  "extra:cottonseed_oil",
            "extra:onion_rings 4"},
         {"extra:potato_slice 8", "extra:cottonseed_oil",
            "extra:potato_crisps 8"}
      }
      for _, potato in pairs(potato_list) do
         table.insert(alloy_recipes,
            {potato[1], "extra:cottonseed_oil", "extra:french_fries 4"})
      end
      for _, onion in pairs(onion_list) do
         table.insert(alloy_recipes,
            {onion[1], "extra:cottonseed_oil", "extra:blooming_onion"})
      end
      if #(fish_list) ~= 0 then
         for _, fish in pairs(fish_list) do
            table.insert(alloy_recipes,
               {fish[1], "extra:cottonseed_oil", "extra:fish_sticks 3"})
         end
      end
      for _, data in pairs(alloy_recipes) do
         technic.register_alloy_recipe({input = {data[1], data[2]},
            output = data[3], time = data[4]})
      end
   end
end

-- GARLIC BREAD
for _, garlic in pairs(garlic_list) do
   minetest.register_craft({
      type = "shapeless",
      output = "extra:garlic_dough",
      recipe = {"farming:flour", garlic[1]}
   })
end

minetest.register_craft({
   type = "cooking",
   output = "extra:garlic_bread",
   recipe = "extra:garlic_dough"
})

-- TACOS AND QUESADILLA
minetest.register_craft({
   type = "shapeless",
   output = 'extra:flour_tortilla 10',
   recipe = {'farming:flour', 'extra:cottonseed_oil'},
})

for _, cheese in pairs(cheese_list) do
   minetest.register_craft({
      type = "shapeless",
      output = 'extra:taco 5',
      recipe = {'extra:ground_meat', cheese[1], 'extra:flour_tortilla',
         'extra:flour_tortilla', 'extra:flour_tortilla',
         'extra:flour_tortilla', 'extra:flour_tortilla'},
   })

   minetest.register_craft({
      output = "extra:quesadilla 3",
      recipe = {
         {'extra:flour_tortilla', 'extra:flour_tortilla', 'extra:flour_tortilla'},
         {"extra:salsa", cheese[1],""},
         {'extra:flour_tortilla', 'extra:flour_tortilla', 'extra:flour_tortilla'},
      },
   })
end

minetest.register_craft({
   type = "shapeless",
   output = "extra:super_taco 5",
   recipe = {"extra:salsa", "extra:taco", "extra:taco",
             "extra:taco", "extra:taco","extra:taco"},
 })

-- SPAGHETTI AND LASAGNA
if extra.marinara_mod then
   if extra.pasta_mod then
      minetest.register_craft({
         type = "shapeless",
         output = 'extra:spaghetti 5',
         recipe = {"extra:marinara", "extra:pasta", "extra:pasta",
                   "extra:pasta", "extra:pasta", "extra:pasta"},
      })
   end

   for _, cheese in pairs(cheese_list) do
      if extra.pasta_mod then
         minetest.register_craft({
            type = "shapeless",
            output = 'extra:lasagna 5',
            recipe = {"extra:marinara", "extra:pasta", "extra:pasta",
                      "extra:pasta", "extra:pasta", "extra:pasta", cheese[1]},
         })
      end
-- PIZZA
      if extra.pizza_mod then
         minetest.register_craft({
            type = "shapeless",
            output = 'extra:cheese_pizza 8',
            recipe = {"farming:flour", "extra:marinara", cheese[1]},
         })

         minetest.register_craft({
            type = "shapeless",
            output = "extra:pepperoni_pizza 8",
            recipe = {"farming:flour", "extra:marinara", cheese[1],
                      "extra:pepperoni"},
         })

         minetest.register_craft({
            type = "shapeless",
            output = "extra:deluxe_pizza 8",
            recipe = {"farming:flour", "extra:marinara", cheese[1],
                      "extra:pepperoni", "extra:onion_slice",
                      "extra:tomato_slice", "flowers:mushroom_brown"}
         })

         minetest.register_craft({
            type = "shapeless",
            output = "extra:pineapple_pizza 8",
            recipe = {"farming:flour", "extra:marinara", cheese[1],
                      "extra:ground_meat", "farming:pineapple_ring"},
         })
      end
   end
end

-- CORNMEAL AND CORNBREAD
if not extra.tech_corn then
   for _, corn in pairs(corn_list) do
      minetest.register_craft({
         type = "shapeless",
         output = 'extra:cornmeal 4',
         recipe = {corn[1], corn[1],corn[1], corn[1]},
      })

      if extra.grinder then
         table.insert(grinder_recipes, {corn[1],   "extra:cornmeal 2"})
      end
   end
   minetest.register_craft({
      type = "cooking",
      cooktime = 10,
      output = "extra:cornbread",
      recipe = "extra:cornmeal"
   })
else
   minetest.register_alias("technic:cornmeal", "extra:cornmeal")
end

if extra.grinder then
   for _, data in pairs(grinder_recipes) do
      technic.register_grinder_recipe({input = {data[1]}, output = data[2]})
   end
end
-- ORE RECOVERY
if extra.ore_recovery then
   minetest.register_craft({
      output = 'default:stone_with_coal 4',
      recipe = {
         {'default:coal_lump', 'default:coal_lump'},
         {'default:coal_lump', 'default:coal_lump'},
      }
   })

   minetest.register_craft({
      output = 'default:stone_with_iron 4',
      recipe = {
         {'default:iron_lump', 'default:iron_lump'},
         {'default:iron_lump', 'default:iron_lump'},
      }
   })

   minetest.register_craft({
      output = 'default:stone_with_copper 4',
      recipe = {
         {'default:copper_lump', 'default:copper_lump'},
         {'default:copper_lump', 'default:copper_lump'},
      }
   })

   minetest.register_craft({
      output = 'default:stone_with_tin 4',
      recipe = {
         {'default:tin_lump', 'default:tin_lump'},
         {'default:tin_lump', 'default:tin_lump'},
      }
   })

   minetest.register_craft({
      output = 'default:stone_with_gold 4',
      recipe = {
         {'default:gold_lump', 'default:gold_lump'},
         {'default:gold_lump', 'default:gold_lump'},
      }
   })

   minetest.register_craft({
      output = 'default:stone_with_mese 4',
      recipe = {
         {'default:mese_crystal', 'default:mese_crystal'},
         {'default:mese_crystal', 'default:mese_crystal'},
      }
   })

   minetest.register_craft({
      output = 'default:stone_with_diamond 4',
      recipe = {
         {'default:diamond', 'default:diamond'},
         {'default:diamond', 'default:diamond'},
      }
   })

   minetest.register_craft({
      output = 'technic:mineral_zinc 4',
      recipe = {
         {'technic:zinc_lump', 'technic:zinc_lump'},
         {'technic:zinc_lump', 'technic:zinc_lump'},
      }
   })

   minetest.register_craft({
      output = 'technic:mineral_lead 4',
      recipe = {
         {'technic:lead_lump', 'technic:lead_lump'},
         {'technic:lead_lump', 'technic:lead_lump'},
      }
   })

   minetest.register_craft({
      output = 'moreores:mineral_silver 4',
      recipe = {
         {'moreores:silver_lump', 'moreores:silver_lump'},
         {'moreores:silver_lump', 'moreores:silver_lump'},
      }
   })

   minetest.register_craft({
      output = 'moreores:mineral_mithril 4',
      recipe = {
         {'moreores:mithril_lump', 'moreores:mithril_lump'},
         {'moreores:mithril_lump', 'moreores:mithril_lump'},
      }
   })

   minetest.register_craft({
      output = 'orichalcum:orichalcum_ore 4',
      recipe = {
         {'orichalcum:orichalcum_shard', 'orichalcum:orichalcum_shard'},
         {'orichalcum:orichalcum_shard', 'orichalcum:orichalcum_shard'},
      }
   })

-- quartz and titanium are different because they arleady use the pattern

   minetest.register_craft({
      output = 'quartz:quartz_ore 5',
      recipe = {
         {'quartz:quartz_crystal', '', 'quartz:quartz_crystal'},
         {'', 'quartz:quartz_crystal', ''},
         {'quartz:quartz_crystal', '', 'quartz:quartz_crystal'},
      }
   })

   minetest.register_craft({
      output = 'titanium:titanium_in_ground 5',
      recipe = {
         {'titanium:titanium', '', 'titanium:titanium'},
         {'', 'titanium:titanium', ''},
         {'titanium:titanium', '', 'titanium:titanium'},
      }
   })
end

if extra.condensed and extra.comp and extra.cond then
   minetest.register_craft({
   	output = "extra:cobble_condensed",
   	recipe = {
   		{"moreblocks:cobble_compressed", "moreblocks:cobble_compressed",
          "moreblocks:cobble_compressed"},
   		{"moreblocks:cobble_compressed", "moreblocks:cobble_compressed",
          "moreblocks:cobble_compressed"},
   		{"moreblocks:cobble_compressed", "moreblocks:cobble_compressed",
          "moreblocks:cobble_compressed"},
   	}
   })

   minetest.register_craft({
   	output = "moreblocks:cobble_compressed 9",
   	recipe = {
   		{"extra:cobble_condensed"},
   	}
   })
end

if extra.liquor then
   minetest.register_craft( {
      type = "shapeless",
   	output = "extra:tequila",
	   recipe = {"vessels:glass_bottle", "default:cactus", "default:cactus",
         "default:cactus", "default:cactus", "default:cactus",
         "default:cactus", "default:cactus", "default:cactus"}
   })

   minetest.register_craft( {
      type = "shapeless",
   	output = "extra:rum",
	   recipe = {"vessels:glass_bottle", "default:papyrus", "default:papyrus",
         "default:papyrus", "default:papyrus", "default:papyrus",
         "default:papyrus", "default:papyrus", "default:papyrus"}
   })
end
