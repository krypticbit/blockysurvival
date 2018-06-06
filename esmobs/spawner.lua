--esmobs v1.3
--maikerumine
--made for Extreme Survival game
--License for code WTFPL
--Andrey created mob spawner for his world needs

--minetest.register_alias("lagsmobs:cursed_stone", "esmmobs:cursed_stone")
--minetest.register_alias("mobs:cursed_stone", "esmmobs:cursed_stone")
--[[
minetest.register_node("esmobs:cursed_stone", {
	description = "Cursed stone",
	tiles = {
		"bones_front.png",
		"default_obsidian.png^mobs_cobweb.png",
		"default_obsidian.png^mobs_cobweb.png",
		"default_obsidian.png^mobs_cobweb.png",
		"default_obsidian.png^mobs_cobweb.png",
		"default_obsidian.png^mobs_cobweb.png"
	},
	is_ground_content = false,
	groups = {cracky=1, level=2},
	drop = 'default:goldblock',
	sounds = default.node_sound_stone_defaults(),
})
minetest.register_craft({
	output = 'esmobs:cursed_stone',
	recipe = {
		{'default:obsidian', 'default:obsidian', 'default:obsidian'},
		{'default:obsidian', 'default:goldblock', 'default:obsidian'},
		{'default:obsidian', 'default:obsidian', 'default:obsidian'},
	}
})

--NPC SPAWNER
minetest.register_node("esmobs:blessed_stone", {
	description = "Blessed Stone",
	tiles = {
		"default_diamond_block.png^tnt_smoke.png",
		"default_diamond_block.png^tnt_smoke.png",
		"default_diamond_block.png^tnt_smoke.png",
		"default_diamond_block.png^tnt_smoke.png",
		"default_diamond_block.png^tnt_smoke.png",
		"default_diamond_block.png^tnt_smoke.png"
	},
	is_ground_content = false,
	groups = {cracky=1, level=2},
	drop = 'default:diamondblock',
	sounds = default.node_sound_stone_defaults(),
})
minetest.register_craft({
	output = 'esmobs:blessed_stone',
	recipe = {
		{'default:obsidian', 'default:obsidian', 'default:obsidian'},
		{'default:obsidian', 'default:diamondblock', 'default:obsidian'},
		{'default:obsidian', 'default:obsidian', 'default:obsidian'},
	}
})

--mobs:register_spawn("esmobs:badplayer23", "esmobs:cursed_stone", 5, -1, 2, 2, 500, -500)  --comment out to disable
mobs:register_spawn("esmobs:stone_monster2", "esmobs:cursed_stone", 5, -1, 3, 8, 500, -500)  --comment out to disable
--mobs:register_spawn("esmobs:Jasmine", {"esmobs:cursed_stone"}, 5, -1, 2, 1, 500, -500)  --comment out to disable
mobs:register_spawn("esmobs:oerkki", "esmobs:cursed_stone", 4, -1,3,7, 500, -500)  --comment out to disable
--mobs:register_spawn("esmobs:herobrines_bloody_ghost", "esmobs:cursed_stone", 4, -1, 2, 1, 500, -500)

--mobs:register_spawn("esmobs:SepiaSam", "esmobs:blessed_stone", 6, -1, 2, 20, 500, -500)  --comment out to disable
--mobs:register_spawn("esmobs:Maikerumine", "esmobs:blessed_stone", 4, -1, 2, 40, 500, -500)  --comment out to disable
mobs:register_spawn("esmobs:Candy", "esmobs:blessed_stone",  5, -1, 3,4, 500, -500)  --comment out to disable
mobs:register_spawn("esmobs:John", "esmobs:blessed_stone",  5, -1, 3,14, 500, -500)  --comment out to disable

]]

-- mob spawner

local spawner_default = "esmobs:pumba 10 15 0 0"

minetest.register_node("esmobs:spawner", {
	tiles = {"mob_spawner.png"},
	drawtype = "glasslike",
	paramtype = "light",
	walkable = true,
	description = "Mob Spawner",
	groups = {cracky = 1},

	on_construct = function(pos)

		local meta = minetest.get_meta(pos)

		-- text entry formspec
		meta:set_string("formspec", "field[text;Mob MinLight MaxLight Amount PlayerDist;${command}]")
		meta:set_string("infotext", "Spawner Not Active (enter settings)")
		meta:set_string("command", spawner_default)
	end,

	on_right_click = function(pos, placer)

		if minetest.is_protected(pos, placer:get_player_name()) then
			return
		end

--		local meta = minetest.get_meta(pos)
	end,

	on_receive_fields = function(pos, formname, fields, sender)

		if not fields.text or fields.text == "" then
			return
		end

		local meta = minetest.get_meta(pos)
		local comm = fields.text:split(" ")
		local name = sender:get_player_name()

		if minetest.is_protected(pos, name) then
			minetest.record_protection_violation(pos, name)
			return
		end

		local mob = comm[1] -- mob to spawn
		local mlig = tonumber(comm[2]) -- min light
		local xlig = tonumber(comm[3]) -- max light
		local num = tonumber(comm[4]) -- total mobs in area
		local pla = tonumber(comm[5])-- player distance (0 to disable)

		if mob and mob ~= "" and mobs.spawning_mobs[mob] == true
		and num and num >= 0 and num <= 10
		and mlig and mlig >= 0 and mlig <= 15
		and xlig and xlig >= 0 and xlig <= 15
		and pla and pla >=0 and pla <= 20 then

			meta:set_string("command", fields.text)
			meta:set_string("infotext", "Spawner Active (" .. mob .. ")")

		else
			minetest.chat_send_player(name, "Mob Spawner settings failed!")
		end
	end,
})

-- spawner abm
minetest.register_abm({
	nodenames = {"esmobs:spawner"},
	interval = 10,
	chance = 4,
	catch_up = false,

	action = function(pos, node, active_object_count, active_object_count_wider)

		-- check objects inside 9x9 area around spawner
		local objs = minetest.get_objects_inside_radius(pos, 9)

		-- get meta and command
		local meta = minetest.get_meta(pos)
		local comm = meta:get_string("command"):split(" ")

		-- get settings from command
		local mob = comm[1]
		local mlig = tonumber(comm[2])
		local xlig = tonumber(comm[3])
		local num = tonumber(comm[4])
		local pla = tonumber(comm[5]) or 0

		-- if amount is 0 then do nothing
		if num == 0 then
			return
		end

		local count = 0
		local ent = nil

		-- count mob objects of same type in area
		for k, obj in pairs(objs) do

			ent = obj:get_luaentity()

			if ent and ent.name == mob then
				count = count + 1
			end
		end

		-- is there too many of same type?
		if count >= num then
			return
		end

		-- spawn mob if player detected and in range
		if pla > 0 then

			local in_range = 0
			local objs = minetest.get_objects_inside_radius(pos, pla)

			for _,oir in pairs(objs) do

				if oir:is_player() then

					in_range = 1

					break
				end
			end

			-- player not found
			if in_range == 0 then
				return
			end
		end

		-- find air blocks within 5 nodes of spawner
		local air = minetest.find_nodes_in_area(
			{x = pos.x - 5, y = pos.y, z = pos.z - 5},
			{x = pos.x + 5, y = pos.y, z = pos.z + 5},
			{"air"})

		-- spawn in random air block
		if air and #air > 0 then

			local pos2 = air[math.random(#air)]
			local lig = minetest.get_node_light(pos2) or 0

			pos2.y = pos2.y + 0.5

			-- only if light levels are within range
			if lig >= mlig and lig <= xlig then
				minetest.add_entity(pos2, mob)
			end
		end

	end
})


-- SPAWN EGGS

--MT Animal spawn eggs
mobs:register_egg("esmobs:sheep", "Sheep", "wool_white.png", 1)
mobs:register_egg("esmobs:chickoboo", "Chickoboo", "mobs_chicken_inv.png", 0)
mobs:register_egg("esmobs:chicken", "Chicken", "mobs_chicken_inv.png", 0)
mobs:register_egg("esmobs:cow", "Cow", "default_grass.png", 1)
mobs:register_egg("esmobs:pumba", "Warthog", "wool_pink.png", 1)
mobs:register_egg("esmobs:rat", "Rat", "mobs_rat_inventory.png", 0)
-- KPV wild horse spawn eggs
mobs:register_egg("esmobs:horse", "Brown Horse", "mobs_horse_inv.png", 0)
mobs:register_egg("esmobs:horse2", "White Horse", "mobs_horse_peg_inv.png", 0)
mobs:register_egg("esmobs:horse3", "Arabic Horse", "mobs_horse_ara_inv.png", 0)
-- KPV tamed horse spawn eggs
mobs:register_egg("esmobs:horseh1", "Tamed Brown Horse", "mobs_horse_inv.png", 0)
mobs:register_egg("esmobs:horsepegh1", "Tamed White Horse", "mobs_horse_peg_inv.png", 0)
mobs:register_egg("esmobs:horsearah1", "Tamed Arabic Horse", "mobs_horse_ara_inv.png", 0)
mobs:register_egg("esmobs:wolf", "Wolf", "wool_grey.png", 1)
mobs:register_egg("esmobs:dog", "Dog", "wool_brown.png", 1)

--MT monster spawn eggs
mobs:register_egg("esmobs:tree_monster", "Tree Monster", "default_tree_top.png", 1)
mobs:register_egg("esmobs:stone_monster", "Stone Mons", "default_stone.png", 1)
mobs:register_egg("esmobs:stone_monster2", "Stone Mons II", "default_stone.png^[colorize:#FF0000:100", 1)
mobs:register_egg("esmobs:dirt", "Dirt Mons", "default_dirt.png", 1)
mobs:register_egg("esmobs:dirt2", "Dirt Mons II", "default_dirt.png^[colorize:#0000FF:100", 1)
mobs:register_egg("esmobs:spider", "Spider", "mobs_cobweb.png", 1)
mobs:register_egg("esmobs:oerkki", "Oerkki", "default_obsidian.png", 1)
mobs:register_egg("esmobs:dungeon_master", "Dungeon Master", "fire_basic_flame.png", 1)
mobs:register_egg("esmobs:applmons", "Apple Mons", "mobs_7.png", 1)
mobs:register_egg("esmobs:herobrines_bloody_ghost", "Herobrines Bloody Ghost", "mobs_8.png", 1)
mobs:register_egg("esmobs:paniki", "Paniki", "mobs_9.png", 1)
mobs:register_egg("esmobs:phoenix", "Phoenix", "mobs_9.png^fire_basic_flame.png", 1)
mobs:register_egg("esmobs:bomber", "Bomber", "mobs_10.png", 1)
mobs:register_egg("esmobs:bone_monster", "Bone Mons", "mobs_11.png", 1)
mobs:register_egg("esmobs:icemon", "Ice Mons", "mobs_12.png", 1)
mobs:register_egg("esmobs:snowmon", "Snow Mons", "mobs_13.png", 1)
mobs:register_egg("esmobs:watermon", "Water Mons", "mobs_14.png", 1)


--Badplayer spawn eggs
mobs:register_egg("esmobs:badplayer2", "BP Angry Sam", "badplayer_2.png", 1)
mobs:register_egg("esmobs:badplayer3", "BP Alien", "badplayer_3.png", 1)
mobs:register_egg("esmobs:badplayer4", "BP Army Guy", "badplayer_4.png", 1)
mobs:register_egg("esmobs:badplayer6", "BP Ninja", "badplayer_6.png", 1)
mobs:register_egg("esmobs:badplayer7", "BP Oerkki", "badplayer_7.png", 1)
mobs:register_egg("esmobs:badplayer8", "BP Tux", "badplayer_8.png", 1)
mobs:register_egg("esmobs:badplayer9", "BP Karate Kid", "badplayer_9.png", 1)
mobs:register_egg("esmobs:badplayer10", "BP Ruthless Attacker", "badplayer_10.png", 1)
mobs:register_egg("esmobs:badplayer11", "BP Nerd", "badplayer_11.png", 1)
mobs:register_egg("esmobs:badplayer12", "BP Bob", "badplayer_12.png", 1)
mobs:register_egg("esmobs:badplayer16", "BP Zombie Sam", "badplayer_16.png", 1)
mobs:register_egg("esmobs:badplayer18", "BP Unknown Mob", "badplayer_18.png", 1)
mobs:register_egg("esmobs:badplayer22", "BP Plain Sam", "badplayer_22.png", 1)
mobs:register_egg("esmobs:badplayer23", "BP Celeron C-55", "badplayer_23.png", 1)
mobs:register_egg("esmobs:badplayer24", "BP Tux Sam", "badplayer_24.png", 1)
mobs:register_egg("esmobs:badplayer25", "BP Iron Man", "badplayer_25.png", 1)
mobs:register_egg("esmobs:badplayer26", "BP Phillip", "badplayer_26.png", 1)
mobs:register_egg("esmobs:badplayer27", "BP Zack", "badplayer_27.png", 1)
mobs:register_egg("esmobs:badplayer28", "BP Slenderman", "badplayer_28.png", 1)
mobs:register_egg("esmobs:badplayer29", "BP Snow Beast", "badplayer_29.png", 1)
mobs:register_egg("esmobs:badplayer30", "BP Jojoa", "badplayer_30.png", 1)
mobs:register_egg("esmobs:badplayer31", "BP Cactus man", "badplayer_31.png", 1)
mobs:register_egg("esmobs:badplayer35", "BP Cactus man ", "badplayer_21.png", 1)
mobs:register_egg("esmobs:Mr_Black", "BP Mr. Black", "badplayer_33.png", 1)
mobs:register_egg("esmobs:Jasmine", "BP Jasmine", "badplayer_42.png", 1)
mobs:register_egg("esmobs:Infinium_Monster", "BP Infinium Mons", "badplayer_32.png", 1)

--NPC spawn eggs
mobs:register_egg("esmobs:Sam", "NPC Sam", "badplayer_1.png", 1)
mobs:register_egg("esmobs:John", "NPC John", "badplayer_5.png", 1)
mobs:register_egg("esmobs:Janette", "NPC Janette", "badplayer_13.png", 1)
mobs:register_egg("esmobs:Crybaby", "NPC Crybaby", "badplayer_14.png", 1)
mobs:register_egg("esmobs:SepiaSam", "NPC Sepia Sam", "badplayer_15.png", 1)
mobs:register_egg("esmobs:OGSam", "NPC O.G. Sam", "badplayer_17.png", 1)
mobs:register_egg("esmobs:Vanessa", "NPC Vanessa", "badplayer_19.png", 1)
mobs:register_egg("esmobs:FemaleSam", "NPC Female Sam", "badplayer_20.png", 1)
mobs:register_egg("esmobs:Wilbert", "NPC Wilbert", "badplayer_35.png", 1)
mobs:register_egg("esmobs:Thelma", "NPC Thelma", "badplayer_34.png", 1)
mobs:register_egg("esmobs:DrifterDan", "NPC Drifter Dan", "badplayer_36.png", 1)
mobs:register_egg("esmobs:Mr_White", "NPC Mr. White", "badplayer_38.png", 1)
mobs:register_egg("esmobs:Mr_Pink", "NPC Mr. Pink", "badplayer_37.png", 1)
mobs:register_egg("esmobs:Candy", "NPC Candy", "badplayer_41.png", 1)
mobs:register_egg("esmobs:Infiniumman", "NPC Infinium Man", "badplayer_40.png", 1)
mobs:register_egg("esmobs:Maikerumine", "NPC Maikerumine", "badplayer_39.png", 1)
