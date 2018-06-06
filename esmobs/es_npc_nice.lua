--esmobs v1.3
--maikerumine
--made for Extreme Survival game
--License for code is WTFPL

--friendly npc drops when right click with gold lump.
mobs.npc_drops = { "default:pick_steel", "esmobs:meat", "default:sword_steel", "default:shovel_steel", "farming:bread", "default:wood" }--Added 20151121
mobs.npc2_drops = { "default:pick_mese", "esmobs:meat", "default:sword_diamond", "default:pick_diamond", "farming:bread", "default:wood" }--Added 20151121

-------------------------
--GOOD NPC'S
-------------------------
mobs:register_mob("esmobs:Sam", {
	type = "npc",
	hp_min = 25,
	hp_max = 35,
	collisionbox = {-0.3, -1.0, -0.3, 0.3, 0.8, 0.3},
	visual = "mesh",
	mesh = "3d_armor_character.b3d",
	textures = {"badplayer_1.png",
			"3d_armor_trans.png",
				minetest.registered_items["default:sword_steel"].inventory_image,
			},
	visual_size = {x=1, y=1.0},
	makes_footstep_sound = true,
	view_range = 15,
	walk_velocity = 1,
	run_velocity = 4,
	damage = 2,
	drops = {
		{name = "default:apple",
		chance = 1,
		min = 1,
		max = 2,},
		{name = "default:sword_steel",
		chance = 2,
		min = 0,
		max = 1,},
		{name = "default:stick",
			chance = 2,
			min = 13,
			max=30,},

	},
	armor = 80,
	drawtype = "front",
	owner = "",
	water_damage = 0,
	lava_damage = 50,
	light_damage = 0,
	fear_height = 5,
		on_rightclick = function(self, clicker)
		local item = clicker:get_wielded_item()
		local_chat(clicker:getpos(),"Sam: Let's go kick some Mob butt!",3)
		if item:get_name() == "esmobs:meat" or item:get_name() == "farming:bread" then
			local hp = self.object:get_hp()
			if hp + 4 > self.hp_max then return end
			if not minetest.setting_getbool("creative_mode") then
				item:take_item()
				clicker:set_wielded_item(item)
			end
			self.object:set_hp(hp+4)


		-- right clicking with gold lump drops random item from mobs.npc_drops
		elseif item:get_name() == "default:gold_lump" then
			if not minetest.setting_getbool("creative_mode") then
				item:take_item()
				clicker:set_wielded_item(item)
			end
			local pos = self.object:getpos()
			pos.y = pos.y + 0.5
			minetest.add_item(pos, {name = mobs.npc_drops[math.random(1,#mobs.npc_drops)]})
		else
			if self.owner == "" then
				self.owner = clicker:get_player_name()
			else
				local formspec = "size[8,4]"
				formspec = formspec .. "textlist[2.85,0;2.1,0.5;dialog;What can I do for you?]"
				formspec = formspec .. "button_exit[1,1;2,2;gfollow;follow]"
				formspec = formspec .. "button_exit[5,1;2,2;gstand;stand]"
				formspec = formspec .. "button_exit[0,2;4,4;gfandp;follow and protect]"
				formspec = formspec .. "button_exit[4,2;4,4;gsandp;stand and protect]"
				--formspec = formspec .. "button_exit[1,2;2,2;ggohome; go home]"
				--formspec = formspec .. "button_exit[5,2;2,2;gsethome; sethome]"
				minetest.show_formspec(clicker:get_player_name(), "order", formspec)
				minetest.register_on_player_receive_fields(function(clicker, formname, fields)
					if fields.gfollow then
						self.order = "follow"
						self.attacks_monsters = false
					end
					if fields.gstand then
						self.order = "stand"
						self.attacks_monsters = false
					end
					if fields.gfandp then
						self.order = "follow"
						self.attacks_monsters = true
					end
					if fields.gsandp then
						self.order = "stand"
						self.attacks_monsters = true
					end
					if fields.gsethome then
						self.floats = self.object:getpos()
					end
					if fields.ggohome then
						if self.floats then
							self.order = "stand"
							self.object:setpos(self.floats)
						end
					end
				end)

			end
		end
	end,

	attack_type = "dogfight",
	pathfinding = true,
	animation = {
		speed_normal = 30,		speed_run = 30,
		stand_start = 0,		stand_end = 79,
		walk_start = 168,		walk_end = 187,
		run_start = 168,		run_end = 187,
		punch_start = 200,		punch_end = 219,
	},
	sounds = {
		war_cry = "mobs_die_yell",
		death = "mobs_death1",
		attack = "default_punch",
		},
	attacks_monsters = true,
	peaceful = true,
	group_attack = true,
	step = 1,
})

mobs:register_mob("esmobs:John", {
	type = "npc",
	hp_min = 27,
	hp_max = 34,
	collisionbox = {-0.3, -1.0, -0.3, 0.3, 0.8, 0.3},
	visual = "mesh",
	mesh = "3d_armor_character.b3d",
	textures = {"badplayer_5.png",
			"3d_armor_trans.png",
				minetest.registered_items["default:sword_wood"].inventory_image,
			},
	visual_size = {x=1, y=1},
	makes_footstep_sound = true,
	view_range = 15,
	walk_velocity = 1,
	run_velocity = 4,
	damage = 3,
	drops = {
		{name = "default:apple",
		chance = 1,
		min = 1,
		max = 5,},
		{name = "default:sword_wood",
		chance = 1,
		min = 0,
		max = 1,},
		{name = "default:stick",
			chance = 2,
			min = 13,
			max=30,},

	},
	armor = 85,
	drawtype = "front",
	owner = "",
	water_damage = 0,
	lava_damage = 50,
	light_damage = 0,
	fear_height = 5,
		on_rightclick = function(self, clicker)
		local item = clicker:get_wielded_item()
		local_chat(clicker:getpos(),"John: Let's go grief some monsters!",3)
		if item:get_name() == "esmobs:meat" or item:get_name() == "farming:bread" then
			local hp = self.object:get_hp()
			if hp + 4 > self.hp_max then return end
			if not minetest.setting_getbool("creative_mode") then
				item:take_item()
				clicker:set_wielded_item(item)
			end
			self.object:set_hp(hp+4)


		-- right clicking with gold lump drops random item from mobs.npc_drops
		elseif item:get_name() == "default:gold_lump" then
			if not minetest.setting_getbool("creative_mode") then
				item:take_item()
				clicker:set_wielded_item(item)
			end
			local pos = self.object:getpos()
			pos.y = pos.y + 0.5
			minetest.add_item(pos, {name = mobs.npc_drops[math.random(1,#mobs.npc_drops)]})
		else
			if self.owner == "" then
				self.owner = clicker:get_player_name()
			else
				local formspec = "size[8,4]"
				formspec = formspec .. "textlist[2.85,0;2.1,0.5;dialog;What can I do for you?]"
				formspec = formspec .. "button_exit[1,1;2,2;gfollow;follow]"
				formspec = formspec .. "button_exit[5,1;2,2;gstand;stand]"
				formspec = formspec .. "button_exit[0,2;4,4;gfandp;follow and protect]"
				formspec = formspec .. "button_exit[4,2;4,4;gsandp;stand and protect]"
				--formspec = formspec .. "button_exit[1,2;2,2;ggohome; go home]"
				--formspec = formspec .. "button_exit[5,2;2,2;gsethome; sethome]"
				minetest.show_formspec(clicker:get_player_name(), "order", formspec)
				minetest.register_on_player_receive_fields(function(clicker, formname, fields)
					if fields.gfollow then
						self.order = "follow"
						self.attacks_monsters = false
					end
					if fields.gstand then
						self.order = "stand"
						self.attacks_monsters = false
					end
					if fields.gfandp then
						self.order = "follow"
						self.attacks_monsters = true
					end
					if fields.gsandp then
						self.order = "stand"
						self.attacks_monsters = true
					end
					if fields.gsethome then
						self.floats = self.object:getpos()
					end
					if fields.ggohome then
						if self.floats then
							self.order = "stand"
							self.object:setpos(self.floats)
						end
					end
				end)

			end
		end
	end,

	attack_type = "dogfight",
	pathfinding = true,
	animation = {
		speed_normal = 30,		speed_run = 30,
		stand_start = 0,		stand_end = 79,
		walk_start = 168,		walk_end = 187,
		run_start = 168,		run_end = 187,
		punch_start = 200,		punch_end = 219,
	},
	sounds = {
		war_cry = "mobs_die_yell",
		death = "mobs_death2",
		attack = "default_punch2",
		},
	attacks_monsters = true,
	peaceful = true,
	group_attack = true,
	step = 1,
})

mobs:register_mob("esmobs:Janette", {
	type = "npc",
	hp_min = 13,
	hp_max = 15,
	collisionbox = {-0.3, -0.8, -0.3, 0.3, 0.8, 0.3},
	visual = "mesh",
	mesh = "3d_armor_character.b3d",
	textures = {"badplayer_13.png",
			"3d_armor_trans.png",
				minetest.registered_items["default:stick"].inventory_image,
			},
	visual_size = {x=1, y=.8},
	makes_footstep_sound = true,
	view_range = 19,
	walk_velocity = 1.6,
	run_velocity = 4,
	damage = 2.5,
	drops = {
		{name = "default:leaves",
		chance = 1,
		min = 3,
		max = 5,},
		{name = "default:sword_steel",
		chance = 2,
		min = 0,
		max = 1,},
		{name = "default:stick",
			chance = 2,
			min = 13,
			max=30,},

	},
	armor = 40,
	drawtype = "front",
	owner = "",
	water_damage = 0,
	lava_damage = 50,
	light_damage = 0,
	fear_height = 5,
	follow = "default:apple",
		on_rightclick = function(self, clicker)
		local item = clicker:get_wielded_item()
		local_chat(clicker:getpos(),"Jannette: Stop flirting with me!",3)
		if item:get_name() == "esmobs:meat" or item:get_name() == "farming:bread" then
			local hp = self.object:get_hp()
			if hp + 4 > self.hp_max then return end
			if not minetest.setting_getbool("creative_mode") then
				item:take_item()
				clicker:set_wielded_item(item)
			end
			self.object:set_hp(hp+4)


		-- right clicking with gold lump drops random item from mobs.npc_drops
		elseif item:get_name() == "default:gold_lump" then
			if not minetest.setting_getbool("creative_mode") then
				item:take_item()
				clicker:set_wielded_item(item)
			end
			local pos = self.object:getpos()
			pos.y = pos.y + 0.5
			minetest.add_item(pos, {name = mobs.npc_drops[math.random(1,#mobs.npc_drops)]})
		else
			if self.owner == "" then
				self.owner = clicker:get_player_name()
			else
				local formspec = "size[8,4]"
				formspec = formspec .. "textlist[2.85,0;2.1,0.5;dialog;What can I do for you?]"
				formspec = formspec .. "button_exit[1,1;2,2;gfollow;follow]"
				formspec = formspec .. "button_exit[5,1;2,2;gstand;stand]"
				formspec = formspec .. "button_exit[0,2;4,4;gfandp;follow and protect]"
				formspec = formspec .. "button_exit[4,2;4,4;gsandp;stand and protect]"
				--formspec = formspec .. "button_exit[1,2;2,2;ggohome; go home]"
				--formspec = formspec .. "button_exit[5,2;2,2;gsethome; sethome]"
				minetest.show_formspec(clicker:get_player_name(), "order", formspec)
				minetest.register_on_player_receive_fields(function(clicker, formname, fields)
					if fields.gfollow then
						self.order = "follow"
						self.attacks_monsters = false
					end
					if fields.gstand then
						self.order = "stand"
						self.attacks_monsters = false
					end
					if fields.gfandp then
						self.order = "follow"
						self.attacks_monsters = true
					end
					if fields.gsandp then
						self.order = "stand"
						self.attacks_monsters = true
					end
					if fields.gsethome then
						self.floats = self.object:getpos()
					end
					if fields.ggohome then
						if self.floats then
							self.order = "stand"
							self.object:setpos(self.floats)
						end
					end
				end)

			end
		end
	end,

	attack_type = "dogfight",
	pathfinding = true,
	animation = {
		speed_normal = 30,		speed_run = 30,
		stand_start = 0,		stand_end = 79,
		walk_start = 168,		walk_end = 187,
		run_start = 168,		run_end = 187,
		punch_start = 200,		punch_end = 219,
	},
	sounds = {
		war_cry = "mobs_oerkki_attack",
		death = "mobs_death1",
		attack = "default_punch",
		},

	attacks_monsters = true,
	peaceful = true,
	group_attack = true,
	step = 1,
})

mobs:register_mob("esmobs:Crybaby", {
	type = "npc",
	hp_min = 27,
	hp_max = 45,
	collisionbox = {-0.3, -1.0, -0.3, 0.3, 0.8, 0.3},
	visual = "mesh",
	mesh = "3d_armor_character.b3d",
	textures = {"badplayer_14.png",
			"3d_armor_trans.png",
				minetest.registered_items["default:sword_wood"].inventory_image,
			},
	visual_size = {x=1, y=1},
	makes_footstep_sound = true,
	view_range = 15,
	walk_velocity = 1,
	run_velocity = 4,
	damage = 3,
	drops = {
		{name = "default:papyrus",
		chance = 1,
		min = 3,
		max = 5,},
		{name = "default:sword_steel",
		chance = 2,
		min = 0,
		max = 1,},
		{name = "default:stick",
			chance = 2,
			min = 1,
			max=3,},

	},
	armor = 90,
	drawtype = "front",
	owner = "",
	water_damage = 0,
	lava_damage = 50,
	light_damage = 0,
	fear_height = 5,
		on_rightclick = function(self, clicker)
		local item = clicker:get_wielded_item()
		local_chat(clicker:getpos(),"Crybaby: I am too whimpy to fight mobs, but I can do my best!",3)
		if item:get_name() == "esmobs:meat" or item:get_name() == "farming:bread" then
			local hp = self.object:get_hp()
			if hp + 4 > self.hp_max then return end
			if not minetest.setting_getbool("creative_mode") then
				item:take_item()
				clicker:set_wielded_item(item)
			end
			self.object:set_hp(hp+4)


		-- right clicking with gold lump drops random item from mobs.npc_drops
		elseif item:get_name() == "default:gold_lump" then
			if not minetest.setting_getbool("creative_mode") then
				item:take_item()
				clicker:set_wielded_item(item)
			end
			local pos = self.object:getpos()
			pos.y = pos.y + 0.5
			minetest.add_item(pos, {name = mobs.npc_drops[math.random(1,#mobs.npc_drops)]})
		else
			if self.owner == "" then
				self.owner = clicker:get_player_name()
			else
				local formspec = "size[8,4]"
				formspec = formspec .. "textlist[2.85,0;2.1,0.5;dialog;What can I do for you?]"
				formspec = formspec .. "button_exit[1,1;2,2;gfollow;follow]"
				formspec = formspec .. "button_exit[5,1;2,2;gstand;stand]"
				formspec = formspec .. "button_exit[0,2;4,4;gfandp;follow and protect]"
				formspec = formspec .. "button_exit[4,2;4,4;gsandp;stand and protect]"
				--formspec = formspec .. "button_exit[1,2;2,2;ggohome; go home]"
				--formspec = formspec .. "button_exit[5,2;2,2;gsethome; sethome]"
				minetest.show_formspec(clicker:get_player_name(), "order", formspec)
				minetest.register_on_player_receive_fields(function(clicker, formname, fields)
					if fields.gfollow then
						self.order = "follow"
						self.attacks_monsters = false
					end
					if fields.gstand then
						self.order = "stand"
						self.attacks_monsters = false
					end
					if fields.gfandp then
						self.order = "follow"
						self.attacks_monsters = true
					end
					if fields.gsandp then
						self.order = "stand"
						self.attacks_monsters = true
					end
					if fields.gsethome then
						self.floats = self.object:getpos()
					end
					if fields.ggohome then
						if self.floats then
							self.order = "stand"
							self.object:setpos(self.floats)
						end
					end
				end)

			end
		end
	end,


	attack_type = "dogfight",
	pathfinding = true,
	animation = {
		speed_normal = 30,		speed_run = 30,
		stand_start = 0,		stand_end = 79,
		walk_start = 168,		walk_end = 187,
		run_start = 168,		run_end = 187,
		punch_start = 200,		punch_end = 219,
	},
	sounds = {
		war_cry = "mobs_barbarian_yell1",
		death = "mobs_death1",
		attack = "default_punch2",
		},
	attacks_monsters = true,
	peaceful = true,
	group_attack = true,
	step = 1,

})

mobs:register_mob("esmobs:SepiaSam", {
	type = "npc",
	hp_min = 47,
	hp_max = 55,
	collisionbox = {-0.3, -1.0, -0.3, 0.3, 0.8, 0.3},
	visual = "mesh",
	mesh = "3d_armor_character.b3d",
	textures = {"badplayer_15.png",
			"3d_armor_trans.png",
				minetest.registered_items["default:sword_mese"].inventory_image,
			},
	visual_size = {x=1, y=1},
	makes_footstep_sound = true,
	view_range = 17,
	walk_velocity = 1.3,
	run_velocity = 3.9,
	damage = 3,
	drops = {
		{name = "default:sword_mese",
		chance = 2,
		min = 0,
		max = 1,},
		{name = "default:sword_steel",
		chance = 1,
		min = 0,
		max = 1,},
		{name = "default:apple",
			chance = 2,
			min = 1,
			max=3,},

	},
	armor = 80,
	drawtype = "front",
	owner = "",
	water_damage = 0,
	lava_damage = 50,
	light_damage = 0,
	fear_height = 5,
		on_rightclick = function(self, clicker)
		local item = clicker:get_wielded_item()
		local_chat(clicker:getpos(),"Sepia Sam: MESE sword + Monster = My pleasure!",3)
		if item:get_name() == "esmobs:meat" or item:get_name() == "farming:bread" then
			local hp = self.object:get_hp()
			if hp + 4 > self.hp_max then return end
			if not minetest.setting_getbool("creative_mode") then
				item:take_item()
				clicker:set_wielded_item(item)
			end
			self.object:set_hp(hp+4)


		-- right clicking with gold lump drops random item from mobs.npc_drops
		elseif item:get_name() == "default:gold_lump" then
			if not minetest.setting_getbool("creative_mode") then
				item:take_item()
				clicker:set_wielded_item(item)
			end
			local pos = self.object:getpos()
			pos.y = pos.y + 0.5
			minetest.add_item(pos, {name = mobs.npc_drops[math.random(1,#mobs.npc_drops)]})
		else
			if self.owner == "" then
				self.owner = clicker:get_player_name()
			else
				local formspec = "size[8,4]"
				formspec = formspec .. "textlist[2.85,0;2.1,0.5;dialog;What can I do for you?]"
				formspec = formspec .. "button_exit[1,1;2,2;gfollow;follow]"
				formspec = formspec .. "button_exit[5,1;2,2;gstand;stand]"
				formspec = formspec .. "button_exit[0,2;4,4;gfandp;follow and protect]"
				formspec = formspec .. "button_exit[4,2;4,4;gsandp;stand and protect]"
				--formspec = formspec .. "button_exit[1,2;2,2;ggohome; go home]"
				--formspec = formspec .. "button_exit[5,2;2,2;gsethome; sethome]"
				minetest.show_formspec(clicker:get_player_name(), "order", formspec)
				minetest.register_on_player_receive_fields(function(clicker, formname, fields)
					if fields.gfollow then
						self.order = "follow"
						self.attacks_monsters = false
					end
					if fields.gstand then
						self.order = "stand"
						self.attacks_monsters = false
					end
					if fields.gfandp then
						self.order = "follow"
						self.attacks_monsters = true
					end
					if fields.gsandp then
						self.order = "stand"
						self.attacks_monsters = true
					end
					if fields.gsethome then
						self.floats = self.object:getpos()
					end
					if fields.ggohome then
						if self.floats then
							self.order = "stand"
							self.object:setpos(self.floats)
						end
					end
				end)

			end
		end
	end,

	attack_type = "dogfight",
	pathfinding = true,
	animation = {
		speed_normal = 30,		speed_run = 30,
		stand_start = 0,		stand_end = 79,
		walk_start = 168,		walk_end = 187,
		run_start = 168,		run_end = 187,
		punch_start = 200,		punch_end = 219,
	},
	sounds = {
		war_cry = "mobs_die_yell",
		death = "mobs_death2",
		attack = "default_punch3",
		},
	attacks_monsters = true,
	peaceful = true,
	group_attack = true,
	step = 1,
})

mobs:register_mob("esmobs:OGSam", {
	type = "npc",
	hp_min = 37,
	hp_max = 45,
	collisionbox = {-0.3, -1.0, -0.3, 0.3, 0.8, 0.3},
	visual = "mesh",
	mesh = "3d_armor_character.b3d",
	textures = {"badplayer_17.png",
			"3d_armor_trans.png",
				minetest.registered_items["default:sword_wood"].inventory_image,
			},
	visual_size = {x=1, y=1},
	makes_footstep_sound = true,
	view_range = 15,
	walk_velocity = 1,
	run_velocity = 3.3,
	damage = 4,
	drops = {
		{name = "default:apple",
		chance = 1,
		min = 0,
		max = 5,},
		{name = "default:sword_wood",
		chance = 1,
		min = 1,
		max = 1,},
		{name = "default:stick",
			chance = 2,
			min = 4,
			max=12,},

	},
	armor = 90,
	drawtype = "front",
	owner = "",
	water_damage = 0,
	lava_damage = 50,
	light_damage = 0,
	fear_height = 5,
		on_rightclick = function(self, clicker)
		local item = clicker:get_wielded_item()
		local_chat(clicker:getpos(),"O.G. Sam: Mobs, let me at 'em, I'll splat 'em!!!",3)
		if item:get_name() == "esmobs:meat" or item:get_name() == "farming:bread" then
			local hp = self.object:get_hp()
			if hp + 4 > self.hp_max then return end
			if not minetest.setting_getbool("creative_mode") then
				item:take_item()
				clicker:set_wielded_item(item)
			end
			self.object:set_hp(hp+4)


		-- right clicking with gold lump drops random item from mobs.npc_drops
		elseif item:get_name() == "default:gold_lump" then
			if not minetest.setting_getbool("creative_mode") then
				item:take_item()
				clicker:set_wielded_item(item)
			end
			local pos = self.object:getpos()
			pos.y = pos.y + 0.5
			minetest.add_item(pos, {name = mobs.npc_drops[math.random(1,#mobs.npc_drops)]})
		else
			if self.owner == "" then
				self.owner = clicker:get_player_name()
			else
				local formspec = "size[8,4]"
				formspec = formspec .. "textlist[2.85,0;2.1,0.5;dialog;What can I do for you?]"
				formspec = formspec .. "button_exit[1,1;2,2;gfollow;follow]"
				formspec = formspec .. "button_exit[5,1;2,2;gstand;stand]"
				formspec = formspec .. "button_exit[0,2;4,4;gfandp;follow and protect]"
				formspec = formspec .. "button_exit[4,2;4,4;gsandp;stand and protect]"
				--formspec = formspec .. "button_exit[1,2;2,2;ggohome; go home]"
				--formspec = formspec .. "button_exit[5,2;2,2;gsethome; sethome]"
				minetest.show_formspec(clicker:get_player_name(), "order", formspec)
				minetest.register_on_player_receive_fields(function(clicker, formname, fields)
					if fields.gfollow then
						self.order = "follow"
						self.attacks_monsters = false
					end
					if fields.gstand then
						self.order = "stand"
						self.attacks_monsters = false
					end
					if fields.gfandp then
						self.order = "follow"
						self.attacks_monsters = true
					end
					if fields.gsandp then
						self.order = "stand"
						self.attacks_monsters = true
					end
					if fields.gsethome then
						self.floats = self.object:getpos()
					end
					if fields.ggohome then
						if self.floats then
							self.order = "stand"
							self.object:setpos(self.floats)
						end
					end
				end)

			end
		end
	end,

	attack_type = "dogfight",
	pathfinding = true,
	animation = {
		speed_normal = 30,		speed_run = 30,
		stand_start = 0,		stand_end = 79,
		walk_start = 168,		walk_end = 187,
		run_start = 168,		run_end = 187,
		punch_start = 200,		punch_end = 219,
	},
	sounds = {
		war_cry = "mobs_die_yell",
		death = "mobs_death1",
		attack = "default_punch2",
		},
	attacks_monsters = true,
	peaceful = true,
	group_attack = true,
	step = 1,
	attacks_monsters = true,
	peaceful = true,
	group_attack = true,
	step = 1,
})

mobs:register_mob("esmobs:Vanessa", {
	type = "npc",
	hp_min = 28,
	hp_max = 35,
	collisionbox = {-0.3, -1.0, -0.3, 0.3, 0.8, 0.3},
	visual = "mesh",
	mesh = "3d_armor_character.b3d",
	textures = {"badplayer_19.png",
			"3d_armor_trans.png",
				minetest.registered_items["default:axe_mese"].inventory_image,
			},
	visual_size = {x=1, y=1},
	makes_footstep_sound = true,
	view_range = 25,
	walk_velocity = 1.6,
	run_velocity = 3.8,
	drops = {
		{name = "default:torch",
		chance = 1,
		min = 3,
		max = 5,},
		{name = "default:sword_steel",
		chance = 1,
		min = 0,
		max = 1,},
		{name = "default:stick",
			chance = 2,
			min = 13,
			max=30,},

	},
	armor = 80,
	drawtype = "front",
	owner = "",
	water_damage = 0,
	lava_damage = 50,
	light_damage = 0,
	fear_height = 5,
		on_rightclick = function(self, clicker)
		local item = clicker:get_wielded_item()
		local_chat(clicker:getpos(),"Vanessa: I'll code out the very instance of those mobs!",3)
		if item:get_name() == "esmobs:meat" or item:get_name() == "farming:bread" then
			local hp = self.object:get_hp()
			if hp + 4 > self.hp_max then return end
			if not minetest.setting_getbool("creative_mode") then
				item:take_item()
				clicker:set_wielded_item(item)
			end
			self.object:set_hp(hp+4)


		-- right clicking with gold lump drops random item from mobs.npc_drops
		elseif item:get_name() == "default:gold_lump" then
			if not minetest.setting_getbool("creative_mode") then
				item:take_item()
				clicker:set_wielded_item(item)
			end
			local pos = self.object:getpos()
			pos.y = pos.y + 0.5
			minetest.add_item(pos, {name = mobs.npc_drops[math.random(1,#mobs.npc_drops)]})
		else
			if self.owner == "" then
				self.owner = clicker:get_player_name()
			else
				local formspec = "size[8,4]"
				formspec = formspec .. "textlist[2.85,0;2.1,0.5;dialog;What can I do for you?]"
				formspec = formspec .. "button_exit[1,1;2,2;gfollow;follow]"
				formspec = formspec .. "button_exit[5,1;2,2;gstand;stand]"
				formspec = formspec .. "button_exit[0,2;4,4;gfandp;follow and protect]"
				formspec = formspec .. "button_exit[4,2;4,4;gsandp;stand and protect]"
				--formspec = formspec .. "button_exit[1,2;2,2;ggohome; go home]"
				--formspec = formspec .. "button_exit[5,2;2,2;gsethome; sethome]"
				minetest.show_formspec(clicker:get_player_name(), "order", formspec)
				minetest.register_on_player_receive_fields(function(clicker, formname, fields)
					if fields.gfollow then
						self.order = "follow"
						self.attacks_monsters = false
					end
					if fields.gstand then
						self.order = "stand"
						self.attacks_monsters = false
					end
					if fields.gfandp then
						self.order = "follow"
						self.attacks_monsters = true
					end
					if fields.gsandp then
						self.order = "stand"
						self.attacks_monsters = true
					end
					if fields.gsethome then
						self.floats = self.object:getpos()
					end
					if fields.ggohome then
						if self.floats then
							self.order = "stand"
							self.object:setpos(self.floats)
						end
					end
				end)

			end
		end
	end,

	attack_type = "dogfight",
	pathfinding = true,
	--attack_type = "dogshoot",
	shoot_interval = 0.7,
	arrow = "esmobs:axebullet",
	shoot_offset = 2,
	animation = {
		speed_normal = 30,		speed_run = 30,
		stand_start = 0,		stand_end = 79,
		walk_start = 168,		walk_end = 187,
		run_start = 168,		run_end = 187,
		punch_start = 200,		punch_end = 219,
	},
	sounds = {
		war_cry = "default_punch",
		death = "mobs_slash_attack",
		attack = "default_punch",
		},
	attacks_monsters = true,
	peaceful = true,
	group_attack = true,
	step = 1,
})

mobs:register_mob("esmobs:FemaleSam", {
	type = "npc",
	hp_min = 92,
	hp_max = 125,
	collisionbox = {-0.3, -1.0, -0.3, 0.3, 0.8, 0.3},
	visual = "mesh",
	mesh = "3d_armor_character.b3d",
	textures = {"badplayer_20.png",
			"3d_armor_trans.png",
				minetest.registered_items["default:pick_steel"].inventory_image,
			},
	visual_size = {x=1, y=1},
	makes_footstep_sound = true,
	view_range = 15,
	walk_velocity = 1.7,
	run_velocity = 3.5,
	damage = 4,
	drops = {
		{name = "default:pick_steel",
		chance = 4,
		min = 0,
		max = 2,},
		{name = "default:sword_steel",
		chance = 7,
		min = 0,
		max = 1,},
		{name = "default:stick",
			chance = 2,
			min = 1,
			max=3,},

	},
	armor = 80,
	drawtype = "front",
	owner = "",
	water_damage = 0,
	lava_damage = 50,
	light_damage = 0,
	fear_height = 5,
		on_rightclick = function(self, clicker)
		local item = clicker:get_wielded_item()
		local_chat(clicker:getpos(),"Female Sam: Minetest is the greatest voxel game ever created!",3)
		if item:get_name() == "esmobs:meat" or item:get_name() == "farming:bread" then
			local hp = self.object:get_hp()
			if hp + 4 > self.hp_max then return end
			if not minetest.setting_getbool("creative_mode") then
				item:take_item()
				clicker:set_wielded_item(item)
			end
			self.object:set_hp(hp+4)


		-- right clicking with gold lump drops random item from mobs.npc_drops
		elseif item:get_name() == "default:gold_lump" then
			if not minetest.setting_getbool("creative_mode") then
				item:take_item()
				clicker:set_wielded_item(item)
			end
			local pos = self.object:getpos()
			pos.y = pos.y + 0.5
			minetest.add_item(pos, {name = mobs.npc_drops[math.random(1,#mobs.npc_drops)]})
		else
			if self.owner == "" then
				self.owner = clicker:get_player_name()
			else
				local formspec = "size[8,4]"
				formspec = formspec .. "textlist[2.85,0;2.1,0.5;dialog;What can I do for you?]"
				formspec = formspec .. "button_exit[1,1;2,2;gfollow;follow]"
				formspec = formspec .. "button_exit[5,1;2,2;gstand;stand]"
				formspec = formspec .. "button_exit[0,2;4,4;gfandp;follow and protect]"
				formspec = formspec .. "button_exit[4,2;4,4;gsandp;stand and protect]"
				--formspec = formspec .. "button_exit[1,2;2,2;ggohome; go home]"
				--formspec = formspec .. "button_exit[5,2;2,2;gsethome; sethome]"
				minetest.show_formspec(clicker:get_player_name(), "order", formspec)
				minetest.register_on_player_receive_fields(function(clicker, formname, fields)
					if fields.gfollow then
						self.order = "follow"
						self.attacks_monsters = false
					end
					if fields.gstand then
						self.order = "stand"
						self.attacks_monsters = false
					end
					if fields.gfandp then
						self.order = "follow"
						self.attacks_monsters = true
					end
					if fields.gsandp then
						self.order = "stand"
						self.attacks_monsters = true
					end
					if fields.gsethome then
						self.floats = self.object:getpos()
					end
					if fields.ggohome then
						if self.floats then
							self.order = "stand"
							self.object:setpos(self.floats)
						end
					end
				end)

			end
		end
	end,

	attack_type = "dogfight",
	pathfinding = true,
	animation = {
		speed_normal = 30,		speed_run = 30,
		stand_start = 0,		stand_end = 79,
		walk_start = 168,		walk_end = 187,
		run_start = 168,		run_end = 187,
		punch_start = 200,		punch_end = 219,
	},
	sounds = {
		war_cry = "mobs_stone",
		death = "mobs_slash_attack",
		attack = "default_punch2",
		},
	attacks_monsters = true,
	peaceful = true,
	group_attack = true,
	step = 1,
})

mobs:register_mob("esmobs:Battleboy", {
	type = "npc",
	hp_min = 157,
	hp_max = 180,
	collisionbox = {-0.3, -1.0, -0.3, 0.3, 0.8, 0.3},
	visual = "mesh",
	mesh = "3d_armor_character.b3d",
	textures = {"badplayer_21.png",
			"3d_armor_trans.png",
				minetest.registered_items["default:pick_mese"].inventory_image,
			},
	visual_size = {x=1, y=1},
	makes_footstep_sound = true,
	view_range = 14,
	walk_velocity = 2.5,
	run_velocity = 7,
	damage = 4,
	drops = {
		{name = "default:pick_mese",
		chance = 2,
		min = 0,
		max = 1,},
		{name = "default:sword_steel",
		chance = 1,
		min = 0,
		max = 1,},
		{name = "default:apple",
			chance = 1,
			min = 1,
			max=3,},

	},
	armor = 80,
	drawtype = "front",
	owner = "",
	water_damage = 0,
	lava_damage = 50,
	light_damage = 0,
	fear_height = 5,
		on_rightclick = function(self, clicker)
		local item = clicker:get_wielded_item()
		local_chat(clicker:getpos(),"Battlefield 3 Soldier: All suited up, let's roll out and destroy those creatures!",3)
		if item:get_name() == "esmobs:meat" or item:get_name() == "farming:bread" then
			local hp = self.object:get_hp()
			if hp + 4 > self.hp_max then return end
			if not minetest.setting_getbool("creative_mode") then
				item:take_item()
				clicker:set_wielded_item(item)
			end
			self.object:set_hp(hp+4)


		-- right clicking with gold lump drops random item from mobs.npc_drops
		elseif item:get_name() == "default:gold_lump" then
			if not minetest.setting_getbool("creative_mode") then
				item:take_item()
				clicker:set_wielded_item(item)
			end
			local pos = self.object:getpos()
			pos.y = pos.y + 0.5
			minetest.add_item(pos, {name = mobs.npc_drops[math.random(1,#mobs.npc_drops)]})
		else
			if self.owner == "" then
				self.owner = clicker:get_player_name()
			else
				local formspec = "size[8,4]"
				formspec = formspec .. "textlist[2.85,0;2.1,0.5;dialog;What can I do for you?]"
				formspec = formspec .. "button_exit[1,1;2,2;gfollow;follow]"
				formspec = formspec .. "button_exit[5,1;2,2;gstand;stand]"
				formspec = formspec .. "button_exit[0,2;4,4;gfandp;follow and protect]"
				formspec = formspec .. "button_exit[4,2;4,4;gsandp;stand and protect]"
				--formspec = formspec .. "button_exit[1,2;2,2;ggohome; go home]"
				--formspec = formspec .. "button_exit[5,2;2,2;gsethome; sethome]"
				minetest.show_formspec(clicker:get_player_name(), "order", formspec)
				minetest.register_on_player_receive_fields(function(clicker, formname, fields)
					if fields.gfollow then
						self.order = "follow"
						self.attacks_monsters = false
					end
					if fields.gstand then
						self.order = "stand"
						self.attacks_monsters = false
					end
					if fields.gfandp then
						self.order = "follow"
						self.attacks_monsters = true
					end
					if fields.gsandp then
						self.order = "stand"
						self.attacks_monsters = true
					end
					if fields.gsethome then
						self.floats = self.object:getpos()
					end
					if fields.ggohome then
						if self.floats then
							self.order = "stand"
							self.object:setpos(self.floats)
						end
					end
				end)

			end
		end
	end,

	attack_type = "dogfight",
	pathfinding = true,
	animation = {
		speed_normal = 30,		speed_run = 30,
		stand_start = 0,		stand_end = 79,
		walk_start = 168,		walk_end = 187,
		run_start = 168,		run_end = 187,
		punch_start = 200,		punch_end = 219,
	},
	sounds = {
		war_cry = "mobs_barbarian_yell1",
		death = "mobs_barbarian_death",
		attack = "default_punch3",
		},
	attacks_monsters = true,
	peaceful = true,
	group_attack = true,
	step = 1,
})

mobs:register_mob("esmobs:Wilbert", {
	type = "npc",
	hp_max = 115,
	collisionbox = {-0.3, -1.0, -0.3, 0.3, 0.8, 0.3},
	visual = "mesh",
	mesh = "3d_armor_character.b3d",
	textures = {"badplayer_35.png",
			"3d_armor_trans.png",
				minetest.registered_items["default:sword_steel"].inventory_image,
			},
	visual_size = {x=1, y=1},
	makes_footstep_sound = true,
	view_range = 15,
	walk_velocity = 1,
	run_velocity = 3.5,
	damage = 5,
		sounds = {
		war_cry = "mobs_die_yell",
		death = "mobs_death1",
		attack = "default_punch",
		},
	drops = {
		{name = "default:apple",
		chance = 1,
		min = 10,
		max = 28,},
		{name = "default:sword_steel",
		chance = 2,
		min = 1,
		max = 1,},
		{name = "default:stick",
			chance = 2,
			min = 13,
			max=30,
		},
	},
	armor = 75,
	drawtype = "front",
	owner = "",
	water_damage = 0,
	lava_damage = 50,
	light_damage = 0,
	fear_height = 5,
		on_rightclick = function(self, clicker)
		local item = clicker:get_wielded_item()
		local_chat(clicker:getpos(),"Old man: I am getting too old for this...  Okay, I'll help ya!",3)
		if item:get_name() == "esmobs:meat" or item:get_name() == "farming:bread" then
			local hp = self.object:get_hp()
			if hp + 4 > self.hp_max then return end
			if not minetest.setting_getbool("creative_mode") then
				item:take_item()
				clicker:set_wielded_item(item)
			end
			self.object:set_hp(hp+4)


		-- right clicking with gold lump drops random item from mobs.npc_drops
		elseif item:get_name() == "default:gold_lump" then
			if not minetest.setting_getbool("creative_mode") then
				item:take_item()
				clicker:set_wielded_item(item)
			end
			local pos = self.object:getpos()
			pos.y = pos.y + 0.5
			minetest.add_item(pos, {name = mobs.npc_drops[math.random(1,#mobs.npc_drops)]})
		else
			if self.owner == "" then
				self.owner = clicker:get_player_name()
			else
				local formspec = "size[8,4]"
				formspec = formspec .. "textlist[2.85,0;2.1,0.5;dialog;What can I do for you?]"
				formspec = formspec .. "button_exit[1,1;2,2;gfollow;follow]"
				formspec = formspec .. "button_exit[5,1;2,2;gstand;stand]"
				formspec = formspec .. "button_exit[0,2;4,4;gfandp;follow and protect]"
				formspec = formspec .. "button_exit[4,2;4,4;gsandp;stand and protect]"
				--formspec = formspec .. "button_exit[1,2;2,2;ggohome; go home]"
				--formspec = formspec .. "button_exit[5,2;2,2;gsethome; sethome]"
				minetest.show_formspec(clicker:get_player_name(), "order", formspec)
				minetest.register_on_player_receive_fields(function(clicker, formname, fields)
					if fields.gfollow then
						self.order = "follow"
						self.attacks_monsters = false
					end
					if fields.gstand then
						self.order = "stand"
						self.attacks_monsters = false
					end
					if fields.gfandp then
						self.order = "follow"
						self.attacks_monsters = true
					end
					if fields.gsandp then
						self.order = "stand"
						self.attacks_monsters = true
					end
					if fields.gsethome then
						self.floats = self.object:getpos()
					end
					if fields.ggohome then
						if self.floats then
							self.order = "stand"
							self.object:setpos(self.floats)
						end
					end
				end)

			end
		end
	end,

	attack_type = "dogfight",
	pathfinding = true,
	animation = {
		speed_normal = 17,
		speed_run = 25,
		stand_start = 0,
		stand_end = 40,
		walk_start = 168,
		walk_end = 187,
		run_start = 168,
		run_end = 187,
		punch_start = 189,
		punch_end = 191,
	},
	attacks_monsters = true,
	peaceful = true,
	group_attack = true,
	step = 1,
})

mobs:register_mob("esmobs:Thelma", {
	type = "npc",
	hp_max = 115,
	collisionbox = {-0.3, -1.0, -0.3, 0.3, 0.8, 0.3},
	visual = "mesh",
	mesh = "3d_armor_character.b3d",
	textures = {"badplayer_34.png",
			"3d_armor_trans.png",
				minetest.registered_items["default:sword_steel"].inventory_image,
			},
	visual_size = {x=1, y=1},
	makes_footstep_sound = true,
	view_range = 15,
	walk_velocity = 1,
	run_velocity = 3,
	damage = 5,
		sounds = {
		war_cry = "mobs_oerkki_attack",
		death = "mobs_death1",
		attack = "default_punch",
		},
	drops = {
		{name = "default:jungletree",
		chance = 1,
		min = 5,
		max = 23,},
		{name = "default:sword_steel",
		chance = 2,
		min = 1,
		max = 1,},
		{name = "default:stick",
			chance = 2,
			min = 13,
			max=30,
		},
	},
	armor = 75,
	drawtype = "front",
	owner = "",
	water_damage = 0,
	lava_damage = 50,
	light_damage = 0,
	fear_height = 5,
		on_rightclick = function(self, clicker)
		local item = clicker:get_wielded_item()
		local_chat(clicker:getpos(),"Old woman: I may walk slow, but I can fight like a champ!",3)
		if item:get_name() == "esmobs:meat" or item:get_name() == "farming:bread" then
			local hp = self.object:get_hp()
			if hp + 4 > self.hp_max then return end
			if not minetest.setting_getbool("creative_mode") then
				item:take_item()
				clicker:set_wielded_item(item)
			end
			self.object:set_hp(hp+4)


		-- right clicking with gold lump drops random item from mobs.npc_drops
		elseif item:get_name() == "default:gold_lump" then
			if not minetest.setting_getbool("creative_mode") then
				item:take_item()
				clicker:set_wielded_item(item)
			end
			local pos = self.object:getpos()
			pos.y = pos.y + 0.5
			minetest.add_item(pos, {name = mobs.npc_drops[math.random(1,#mobs.npc_drops)]})
		else
			if self.owner == "" then
				self.owner = clicker:get_player_name()
			else
				local formspec = "size[8,4]"
				formspec = formspec .. "textlist[2.85,0;2.1,0.5;dialog;What can I do for you?]"
				formspec = formspec .. "button_exit[1,1;2,2;gfollow;follow]"
				formspec = formspec .. "button_exit[5,1;2,2;gstand;stand]"
				formspec = formspec .. "button_exit[0,2;4,4;gfandp;follow and protect]"
				formspec = formspec .. "button_exit[4,2;4,4;gsandp;stand and protect]"
				--formspec = formspec .. "button_exit[1,2;2,2;ggohome; go home]"
				--formspec = formspec .. "button_exit[5,2;2,2;gsethome; sethome]"
				minetest.show_formspec(clicker:get_player_name(), "order", formspec)
				minetest.register_on_player_receive_fields(function(clicker, formname, fields)
					if fields.gfollow then
						self.order = "follow"
						self.attacks_monsters = false
					end
					if fields.gstand then
						self.order = "stand"
						self.attacks_monsters = false
					end
					if fields.gfandp then
						self.order = "follow"
						self.attacks_monsters = true
					end
					if fields.gsandp then
						self.order = "stand"
						self.attacks_monsters = true
					end
					if fields.gsethome then
						self.floats = self.object:getpos()
					end
					if fields.ggohome then
						if self.floats then
							self.order = "stand"
							self.object:setpos(self.floats)
						end
					end
				end)

			end
		end
	end,

	attack_type = "dogfight",
	pathfinding = true,
	animation = {
		speed_normal = 17,
		speed_run = 25,
		stand_start = 0,
		stand_end = 40,
		walk_start = 168,
		walk_end = 187,
		run_start = 168,
		run_end = 187,
		punch_start = 189,
		punch_end = 191,
	},

	attacks_monsters = true,
	peaceful = true,
	group_attack = true,
	step = 1,
})

mobs:register_mob("esmobs:DrifterDan", {
	type = "npc",
	hp_min = 117,
	hp_max = 129,
	collisionbox = {-0.3, -1.0, -0.3, 0.3, 0.8, 0.3},
	visual = "mesh",
	mesh = "3d_armor_character.b3d",
	textures = {"badplayer_36.png",
			"3d_armor_trans.png",
				minetest.registered_items["default:pick_mese"].inventory_image,
			},
	visual_size = {x=1, y=1},
	makes_footstep_sound = true,
	view_range = 14,
	walk_velocity = 2.5,
	run_velocity = 7,
	damage = 4,
	drops = {
		{name = "default:pick_mese",
		chance = 2,
		min = 0,
		max = 1,},
		{name = "default:steel_ingot",
		chance = 1,
		min = 3,
		max = 19,},
		{name = "default:apple",
			chance = 1,
			min = 1,
			max=3,},

	},
	armor = 80,
	drawtype = "front",
	owner = "",
	water_damage = 0,
	lava_damage = 50,
	light_damage = 0,
	fear_height = 5,
		on_rightclick = function(self, clicker)
		local item = clicker:get_wielded_item()
		local_chat(clicker:getpos(),"Drifter Dan: Let's roll out and destroy those creatures!",3)
		if item:get_name() == "esmobs:meat" or item:get_name() == "farming:bread" then
			local hp = self.object:get_hp()
			if hp + 4 > self.hp_max then return end
			if not minetest.setting_getbool("creative_mode") then
				item:take_item()
				clicker:set_wielded_item(item)
			end
			self.object:set_hp(hp+4)


		-- right clicking with gold lump drops random item from mobs.npc_drops
		elseif item:get_name() == "default:gold_lump" then
			if not minetest.setting_getbool("creative_mode") then
				item:take_item()
				clicker:set_wielded_item(item)
			end
			local pos = self.object:getpos()
			pos.y = pos.y + 0.5
			minetest.add_item(pos, {name = mobs.npc_drops[math.random(1,#mobs.npc_drops)]})
		else
			if self.owner == "" then
				self.owner = clicker:get_player_name()
			else
				local formspec = "size[8,4]"
				formspec = formspec .. "textlist[2.85,0;2.1,0.5;dialog;What can I do for you?]"
				formspec = formspec .. "button_exit[1,1;2,2;gfollow;follow]"
				formspec = formspec .. "button_exit[5,1;2,2;gstand;stand]"
				formspec = formspec .. "button_exit[0,2;4,4;gfandp;follow and protect]"
				formspec = formspec .. "button_exit[4,2;4,4;gsandp;stand and protect]"
				--formspec = formspec .. "button_exit[1,2;2,2;ggohome; go home]"
				--formspec = formspec .. "button_exit[5,2;2,2;gsethome; sethome]"
				minetest.show_formspec(clicker:get_player_name(), "order", formspec)
				minetest.register_on_player_receive_fields(function(clicker, formname, fields)
					if fields.gfollow then
						self.order = "follow"
						self.attacks_monsters = false
					end
					if fields.gstand then
						self.order = "stand"
						self.attacks_monsters = false
					end
					if fields.gfandp then
						self.order = "follow"
						self.attacks_monsters = true
					end
					if fields.gsandp then
						self.order = "stand"
						self.attacks_monsters = true
					end
					if fields.gsethome then
						self.floats = self.object:getpos()
					end
					if fields.ggohome then
						if self.floats then
							self.order = "stand"
							self.object:setpos(self.floats)
						end
					end
				end)

			end
		end
	end,

	attack_type = "dogfight",
	pathfinding = true,
	animation = {
		speed_normal = 30,		speed_run = 30,
		stand_start = 0,		stand_end = 79,
		walk_start = 168,		walk_end = 187,
		run_start = 168,		run_end = 187,
		punch_start = 200,		punch_end = 219,
	},
	sounds = {
		war_cry = "mobs_barbarian_yell1",
		death = "mobs_barbarian_death",
		attack = "default_punch3",
		},
	attacks_monsters = true,
	peaceful = true,
	group_attack = true,
	step = 1,
})

mobs:register_mob("esmobs:Mr_White", {
	type = "npc",
	hp_min = 35,
	hp_max = 65,
	collisionbox = {-0.3, -1.0, -0.3, 0.3, 0.8, 0.3},
	visual = "mesh",
	mesh = "3d_armor_character.b3d",
	textures = {"badplayer_38.png",
			"3d_armor_trans.png",
				minetest.registered_items["default:sword_wood"].inventory_image,
			},
	visual_size = {x=1, y=1},
	makes_footstep_sound = true,
	view_range = 15,
	walk_velocity = 3,
	run_velocity = 4,
	damage = 2,
	sounds = {
		war_cry = "mobs_die_yell",
		death = "mobs_death1",
		attack = "default_punch",
		},
	drops = {
		{name = "default:apple",
		chance = 1,
		min = 0,
		max = 2,},
		{name = "default:sword_steel",
		chance = 2,
		min = 0,
		max = 1,},

	},
	armor = 75,
	drawtype = "front",
	owner = "",
	water_damage = 0,
	lava_damage = 50,
	light_damage = 0,
	fear_height = 5,
	sounds = {
		attack = "default_punch1",
	},
		on_rightclick = function(self, clicker)
		local item = clicker:get_wielded_item()
		local_chat(clicker:getpos(),"Mr. White: Let's go kick some Mob butt!",3)
		if item:get_name() == "esmobs:meat" or item:get_name() == "farming:bread" then
			local hp = self.object:get_hp()
			if hp + 4 > self.hp_max then return end
			if not minetest.setting_getbool("creative_mode") then
				item:take_item()
				clicker:set_wielded_item(item)
			end
			self.object:set_hp(hp+4)


		-- right clicking with gold lump drops random item from mobs.npc_drops
		elseif item:get_name() == "default:gold_lump" then
			if not minetest.setting_getbool("creative_mode") then
				item:take_item()
				clicker:set_wielded_item(item)
			end
			local pos = self.object:getpos()
			pos.y = pos.y + 0.5
			minetest.add_item(pos, {name = mobs.npc_drops[math.random(1,#mobs.npc_drops)]})
		else
			if self.owner == "" then
				self.owner = clicker:get_player_name()
			else
				local formspec = "size[8,4]"
				formspec = formspec .. "textlist[2.85,0;2.1,0.5;dialog;What can I do for you?]"
				formspec = formspec .. "button_exit[1,1;2,2;gfollow;follow]"
				formspec = formspec .. "button_exit[5,1;2,2;gstand;stand]"
				formspec = formspec .. "button_exit[0,2;4,4;gfandp;follow and protect]"
				formspec = formspec .. "button_exit[4,2;4,4;gsandp;stand and protect]"
				--formspec = formspec .. "button_exit[1,2;2,2;ggohome; go home]"
				--formspec = formspec .. "button_exit[5,2;2,2;gsethome; sethome]"
				minetest.show_formspec(clicker:get_player_name(), "order", formspec)
				minetest.register_on_player_receive_fields(function(clicker, formname, fields)
					if fields.gfollow then
						self.order = "follow"
						self.attacks_monsters = false
					end
					if fields.gstand then
						self.order = "stand"
						self.attacks_monsters = false
					end
					if fields.gfandp then
						self.order = "follow"
						self.attacks_monsters = true
					end
					if fields.gsandp then
						self.order = "stand"
						self.attacks_monsters = true
					end
					if fields.gsethome then
						self.floats = self.object:getpos()
					end
					if fields.ggohome then
						if self.floats then
							self.order = "stand"
							self.object:setpos(self.floats)
						end
					end
				end)

			end
		end
	end,


	attack_type = "dogfight",
	pathfinding = true,
	animation = {
		speed_normal = 30,		speed_run = 30,
		stand_start = 0,		stand_end = 79,
		walk_start = 168,		walk_end = 187,
		run_start = 168,		run_end = 187,
		punch_start = 200,		punch_end = 219,
	},
	attacks_monsters = true,
	peaceful = true,
	group_attack = true,
	--step = 1,
})

mobs:register_mob("esmobs:Mr_Pink", {
	type = "npc",
	hp_min = 35,
	hp_max = 65,
	collisionbox = {-0.3, -1.0, -0.3, 0.3, 0.8, 0.3},
	visual = "mesh",
	mesh = "3d_armor_character.b3d",
	textures = {"badplayer_37.png",
			"3d_armor_trans.png",
				minetest.registered_items["default:sword_stone"].inventory_image,
			},
	visual_size = {x=1, y=1},
	makes_footstep_sound = true,
	view_range = 15,
	walk_velocity = 1,
	run_velocity = 3,
	damage = 2,
		sounds = {
		war_cry = "mobs_barbarian_yell1",
		death = "mobs_barbarian_death",
		attack = "default_punch1",
		},
	drops = {
		{name = "default:apple",
		chance = 1,
		min = 1,
		max = 2,},
		{name = "default:sword_steel",
		chance = 2,
		min = 0,
		max = 1,},

	},
	armor = 75,
	drawtype = "front",
	owner = "",
	water_damage = 0,
	lava_damage = 50,
	light_damage = 0,
	fear_height = 5,
	attack_type = "dogfight",
	pathfinding = true,
	sounds = {
		attack = "default_punch3",
	},
--TENPLUS1 and CProgrammerRU AWESOME CODES.
	-- right clicking with cooked meat will give npc more health
	on_rightclick = function(self, clicker)
		local item = clicker:get_wielded_item()
		local_chat(clicker:getpos(),"Mr. Pink: My name is Norman, how may I assist?",3)
		if item:get_name() == "esmobs:meat" or item:get_name() == "farming:bread" then
			local hp = self.object:get_hp()
			if hp + 4 > self.hp_max then return end
			if not minetest.setting_getbool("creative_mode") then
				item:take_item()
				clicker:set_wielded_item(item)
			end
			self.object:set_hp(hp+4)


		-- right clicking with gold lump drops random item from mobs.npc_drops
		elseif item:get_name() == "default:gold_lump" then
			if not minetest.setting_getbool("creative_mode") then
				item:take_item()
				clicker:set_wielded_item(item)
			end
			local pos = self.object:getpos()
			pos.y = pos.y + 0.5
			minetest.add_item(pos, {name = mobs.npc_drops[math.random(1,#mobs.npc_drops)]})
		else
			if self.owner == "" then
				self.owner = clicker:get_player_name()
			else
				local formspec = "size[8,4]"
				formspec = formspec .. "textlist[2.85,0;2.1,0.5;dialog;What can I do for you?]"
				formspec = formspec .. "button_exit[1,1;2,2;gfollow;follow]"
				formspec = formspec .. "button_exit[5,1;2,2;gstand;stand]"
				formspec = formspec .. "button_exit[0,2;4,4;gfandp;follow and protect]"
				formspec = formspec .. "button_exit[4,2;4,4;gsandp;stand and protect]"
				--formspec = formspec .. "button_exit[1,2;2,2;ggohome; go home]"
				--formspec = formspec .. "button_exit[5,2;2,2;gsethome; sethome]"
				minetest.show_formspec(clicker:get_player_name(), "order", formspec)
				minetest.register_on_player_receive_fields(function(clicker, formname, fields)
					if fields.gfollow then
						self.order = "follow"
						self.attacks_monsters = false
					end
					if fields.gstand then
						self.order = "stand"
						self.attacks_monsters = false
					end
					if fields.gfandp then
						self.order = "follow"
						self.attacks_monsters = true
					end
					if fields.gsandp then
						self.order = "stand"
						self.attacks_monsters = true
					end
					if fields.gsethome then
						self.floats = self.object:getpos()
					end
					if fields.ggohome then
						if self.floats then
							self.order = "stand"
							self.object:setpos(self.floats)
						end
					end
				end)

			end
		end
	end,

	animation = {
		speed_normal = 30,		speed_run = 30,
		stand_start = 0,		stand_end = 79,
		walk_start = 168,		walk_end = 187,
		run_start = 168,		run_end = 187,
		punch_start = 200,		punch_end = 219,
	},
	attacks_monsters = true,
	peaceful = true,
	group_attack = true,
	--step = 1,
})


-------------------------
--GOOD NPC'S
-------------------------
if es then
mobs:register_mob("esmobs:Candy", {
	type = "npc",
	hp_min = 125,
	hp_max = 135,
	collisionbox = {-0.3, -1.0, -0.3, 0.3, 0.8, 0.3},
	visual = "mesh",
	mesh = "3d_armor_character.b3d",
	textures = {"badplayer_41.png",
			"3d_armor_trans.png",
				--minetest.registered_items["default:diamond"].inventory_image,
				minetest.registered_items["es:sword_ruby"].inventory_image,
			},
	visual_size = {x=1, y=1.0},
	makes_footstep_sound = true,
	view_range = 25,
	walk_velocity = 1.9,
	run_velocity = 3.9,
	damage = 9,
	drops = {
		{name = "default:apple",
		chance = 1,
		min = 1,
		max = 5,},
		{name = "es:sword_ruby",
		chance = 5,
		min = 0,
		max = 1,},
		{name = "default:stick",
			chance = 2,
			min = 1,
			max=4,},

	},
	armor = 80,
	drawtype = "front",
	owner = "",
	water_damage = 0,
	lava_damage = 50,
	light_damage = 1,
	fear_height = 5,
		on_rightclick = function(self, clicker)
		local item = clicker:get_wielded_item()
		local_chat(clicker:getpos(),"Candy Raver: My Ruby Sword will cut through anything, let's do it!",3)
		if item:get_name() == "esmobs:meat" or item:get_name() == "farming:bread" then
			local hp = self.object:get_hp()
			if hp + 4 > self.hp_max then return end
			if not minetest.setting_getbool("creative_mode") then
				item:take_item()
				clicker:set_wielded_item(item)
			end
			self.object:set_hp(hp+4)


		-- right clicking with gold lump drops random item from mobs.npc_drops
		elseif item:get_name() == "default:gold_lump" then
			if not minetest.setting_getbool("creative_mode") then
				item:take_item()
				clicker:set_wielded_item(item)
			end
			local pos = self.object:getpos()
			pos.y = pos.y + 0.5
			minetest.add_item(pos, {name = mobs.npc_drops[math.random(1,#mobs.npc2_drops)]})
		else
			if self.owner == "" then
				self.owner = clicker:get_player_name()
			else
				local formspec = "size[8,4]"
				formspec = formspec .. "textlist[2.85,0;2.1,0.5;dialog;What can I do for you?]"
				formspec = formspec .. "button_exit[1,1;2,2;gfollow;follow]"
				formspec = formspec .. "button_exit[5,1;2,2;gstand;stand]"
				formspec = formspec .. "button_exit[0,2;4,4;gfandp;follow and protect]"
				formspec = formspec .. "button_exit[4,2;4,4;gsandp;stand and protect]"
				--formspec = formspec .. "button_exit[1,2;2,2;ggohome; go home]"
				--formspec = formspec .. "button_exit[5,2;2,2;gsethome; sethome]"
				minetest.show_formspec(clicker:get_player_name(), "order", formspec)
				minetest.register_on_player_receive_fields(function(clicker, formname, fields)
					if fields.gfollow then
						self.order = "follow"
						self.attacks_monsters = false
					end
					if fields.gstand then
						self.order = "stand"
						self.attacks_monsters = false
					end
					if fields.gfandp then
						self.order = "follow"
						self.attacks_monsters = true
					end
					if fields.gsandp then
						self.order = "stand"
						self.attacks_monsters = true
					end
					if fields.gsethome then
						self.floats = self.object:getpos()
					end
					if fields.ggohome then
						if self.floats then
							self.order = "stand"
							self.object:setpos(self.floats)
						end
					end
				end)

			end
		end
	end,

	attack_type = "dogfight",
	pathfinding = true,
	animation = {
		speed_normal = 30,		speed_run = 30,
		stand_start = 0,		stand_end = 79,
		walk_start = 168,		walk_end = 187,
		run_start = 168,		run_end = 187,
		punch_start = 200,		punch_end = 219,
	},
	sounds = {
		war_cry = "mobs_die_yell",
		death = "mobs_death1",
		attack = "default_punch",
		},
	attacks_monsters = true,
	peaceful = true,
	group_attack = true,
	step = 1,
})
end

mobs:register_mob("esmobs:Infiniumman", {
	type = "npc",
	hp_min = 25,
	hp_max = 35,
	collisionbox = {-0.3, -1.0, -0.3, 0.3, 0.8, 0.3},
	visual = "mesh",
	mesh = "3d_armor_character.b3d",
	textures = {"badplayer_40.png",
			"3d_armor_trans.png",
				minetest.registered_items["default:sword_diamond"].inventory_image,
			},
	visual_size = {x=1, y=1.0},
	makes_footstep_sound = true,
	view_range = 15,
	walk_velocity = 3,
	run_velocity = 5,
	damage = 3,
	drops = {
		{name = "default:apple",
		chance = 1,
		min = 1,
		max = 2,},
		{name = "default:sword_diamond",
		chance = 3,
		min = 0,
		max = 1,},
		{name = "default:meselamp",
			chance = 2,
			min = 1,
			max=3,},

	},
	armor = 80,
	drawtype = "front",
	owner = "",
	water_damage = 0,
	lava_damage = 50,
	light_damage = 0,
	fear_height = 5,
		on_rightclick = function(self, clicker)
		local item = clicker:get_wielded_item()
		local_chat(clicker:getpos(),"Infinium Man: I'll give those monsters a good whack on the head with this Infinium ingot!",3)
		if item:get_name() == "esmobs:meat" or item:get_name() == "farming:bread" then
			local hp = self.object:get_hp()
			if hp + 4 > self.hp_max then return end
			if not minetest.setting_getbool("creative_mode") then
				item:take_item()
				clicker:set_wielded_item(item)
			end
			self.object:set_hp(hp+4)


		-- right clicking with gold lump drops random item from mobs.npc_drops
		elseif item:get_name() == "default:gold_lump" then
			if not minetest.setting_getbool("creative_mode") then
				item:take_item()
				clicker:set_wielded_item(item)
			end
			local pos = self.object:getpos()
			pos.y = pos.y + 0.5
			minetest.add_item(pos, {name = mobs.npc_drops[math.random(1,#mobs.npc2_drops)]})
		else
			if self.owner == "" then
				self.owner = clicker:get_player_name()
			else
				local formspec = "size[8,4]"
				formspec = formspec .. "textlist[2.85,0;2.1,0.5;dialog;What can I do for you?]"
				formspec = formspec .. "button_exit[1,1;2,2;gfollow;follow]"
				formspec = formspec .. "button_exit[5,1;2,2;gstand;stand]"
				formspec = formspec .. "button_exit[0,2;4,4;gfandp;follow and protect]"
				formspec = formspec .. "button_exit[4,2;4,4;gsandp;stand and protect]"
				--formspec = formspec .. "button_exit[1,2;2,2;ggohome; go home]"
				--formspec = formspec .. "button_exit[5,2;2,2;gsethome; sethome]"
				minetest.show_formspec(clicker:get_player_name(), "order", formspec)
				minetest.register_on_player_receive_fields(function(clicker, formname, fields)
					if fields.gfollow then
						self.order = "follow"
						self.attacks_monsters = false
					end
					if fields.gstand then
						self.order = "stand"
						self.attacks_monsters = false
					end
					if fields.gfandp then
						self.order = "follow"
						self.attacks_monsters = true
					end
					if fields.gsandp then
						self.order = "stand"
						self.attacks_monsters = true
					end
					if fields.gsethome then
						self.floats = self.object:getpos()
					end
					if fields.ggohome then
						if self.floats then
							self.order = "stand"
							self.object:setpos(self.floats)
						end
					end
				end)

			end
		end
	end,

	attack_type = "dogfight",
	pathfinding = true,
	animation = {
		speed_normal = 30,		speed_run = 30,
		stand_start = 0,		stand_end = 79,
		walk_start = 168,		walk_end = 187,
		run_start = 168,		run_end = 187,
		punch_start = 200,		punch_end = 219,
	},
	sounds = {
		war_cry = "mobs_die_yell",
		death = "mobs_death1",
		attack = "default_punch",
		},
	attacks_monsters = true,
	peaceful = true,
	group_attack = true,
	step = 1,
})
--TEXTURE BY: http://minetest.fensta.mobslaced.net/#author=bajanhgk

mobs:register_mob("esmobs:Maikerumine", {
	type = "npc",
	hp_min = 95,
	hp_max = 175,
	collisionbox = {-0.3, -1.0, -0.3, 0.3, 0.8, 0.3},
	visual = "mesh",
	mesh = "3d_armor_character.b3d",
	textures = {"badplayer_39.png",
			"3d_armor_trans.png",
				minetest.registered_items["default:book"].inventory_image,
				--minetest.registered_items["throwing:bow_steel"].inventory_image,
				--minetest.registered_items["esmobs:bow_wood"].inventory_image,
			},
	visual_size = {x=1, y=1.0},
	makes_footstep_sound = true,
	view_range = 15,
	walk_velocity = 3,
	run_velocity = 5,
	damage = 9,
	attack_type = "dogfight",
	pathfinding = true,
	--attack_type = "shoot",
	shoot_interval = 0.5,
	arrow = "esmobs:bookbullet",
	shoot_offset = 2,
	drops = {
		{name = "default:apple",
		chance = 1,
		min = 1,
		max = 2,},
		{name = "default:book",
		chance = 3,
		min = 0,
		max = 1,},
		{name = "farming:bread",
			chance = 2,
			min = 23,
			max=90,},

	},
	armor = 80,
	drawtype = "front",
	owner = "",
	water_damage = 0,
	lava_damage = 50,
	light_damage = 0,
	fear_height = 4,
		on_rightclick = function(self, clicker)
		local item = clicker:get_wielded_item()
		local_chat(clicker:getpos(),"Maikerumine: Maybe a new game is in the works...  Hmmm...",3)
		if item:get_name() == "esmobs:meat" or item:get_name() == "farming:bread" then
			local hp = self.object:get_hp()
			if hp + 4 > self.hp_max then return end
			if not minetest.setting_getbool("creative_mode") then
				item:take_item()
				clicker:set_wielded_item(item)
			end
			self.object:set_hp(hp+4)


		-- right clicking with gold lump drops random item from mobs.npc_drops
		elseif item:get_name() == "default:gold_lump" then
			if not minetest.setting_getbool("creative_mode") then
				item:take_item()
				clicker:set_wielded_item(item)
			end
			local pos = self.object:getpos()
			pos.y = pos.y + 0.5
			minetest.add_item(pos, {name = mobs.npc_drops[math.random(1,#mobs.npc2_drops)]})
		else
			if self.owner == "" then
				self.owner = clicker:get_player_name()
			else
				local formspec = "size[8,4]"
				formspec = formspec .. "textlist[2.85,0;2.1,0.5;dialog;What can I do for you?]"
				formspec = formspec .. "button_exit[1,1;2,2;gfollow;follow]"
				formspec = formspec .. "button_exit[5,1;2,2;gstand;stand]"
				formspec = formspec .. "button_exit[0,2;4,4;gfandp;follow and protect]"
				formspec = formspec .. "button_exit[4,2;4,4;gsandp;stand and protect]"
				--formspec = formspec .. "button_exit[1,2;2,2;ggohome; go home]"
				--formspec = formspec .. "button_exit[5,2;2,2;gsethome; sethome]"
				minetest.show_formspec(clicker:get_player_name(), "order", formspec)
				minetest.register_on_player_receive_fields(function(clicker, formname, fields)
					if fields.gfollow then
						self.order = "follow"
						self.attacks_monsters = false
					end
					if fields.gstand then
						self.order = "stand"
						self.attacks_monsters = false
					end
					if fields.gfandp then
						self.order = "follow"
						self.attacks_monsters = true
					end
					if fields.gsandp then
						self.order = "stand"
						self.attacks_monsters = true
					end
					if fields.gsethome then
						self.floats = self.object:getpos()
					end
					if fields.ggohome then
						if self.floats then
							self.order = "stand"
							self.object:setpos(self.floats)
						end
					end
				end)

			end
		end
	end,

	animation = {
		speed_normal = 30,		speed_run = 30,
		stand_start = 0,		stand_end = 79,
		walk_start = 168,		walk_end = 187,
		run_start = 168,		run_end = 187,
		punch_start = 200,		punch_end = 219,
	},
	sounds = {
		war_cry = "mobs_die_yell",
		death = "mobs_death1",
		attack = "default_punch",
		},
	attacks_monsters = true,
	peaceful = true,
	group_attack = true,
	step = 1,
})


--REFERENCE
--function mobs:spawn_specific(name, nodes, neighbors, min_light, max_light, interval, chance, active_object_count, min_height, max_height)
--mobs:register_spawn("mobs:dirt_monster", {"default:dirt_with_grass", "ethereal:gray_dirt"}, 7, 0, 7000, 2, 31000)

--NOTE: ALWAYS PUT THE REGISTER_SPAWN BELOW THE REGISTER_ENTITY!!!!!



--mobs:register_spawn("esmobs:Sam", {"default:dirt_with_grass","default:stone", "default:stonebrick","default:cobble","default:dirt_with_dry_grass","es:strange_grass","es:aiden_grass"}, 12, 7, 18000, 1, 31000)
--mobs:register_spawn("esmobs:John", {"default:dirt_with_grass","default:stone", "default:stonebrick","default:cobble","default:dirt_with_dry_grass","es:strange_grass","es:aiden_grass"}, 12, 7, 18000, 1, 31000)
--mobs:register_spawn("esmobs:John", {"default:dirt_with_grass","default:stone", "default:stonebrick","default:cobble","default:dirt_with_dry_grass","es:strange_grass","es:aiden_grass"}, 5, -1, 18000, 1, 31000)
--mobs:register_spawn("esmobs:Janette", {"default:dirt_with_grass","default:stone", "default:stonebrick","default:cobble","default:dirt_with_dry_grass","es:strange_grass","es:aiden_grass"}, 12, 7, 18000, 1, 31000)
--mobs:register_spawn("esmobs:Crybaby", {"default:dirt_with_grass","default:stone", "default:stonebrick","default:cobble","default:dirt_with_dry_grass","es:strange_grass","es:aiden_grass"}, 12, 7, 18000, 1, 31000)
--mobs:register_spawn("esmobs:SepiaSam", {"default:dirt_with_grass","default:stone", "default:stonebrick","default:cobble","default:dirt_with_dry_grass","es:strange_grass","es:aiden_grass"}, 12, 7, 18000, 1, 31000)
--mobs:register_spawn("esmobs:OGSam", {"default:dirt_with_grass","default:stone", "default:stonebrick","default:cobble","default:dirt_with_dry_grass","es:strange_grass","es:aiden_grass"}, 12, 7, 18000, 1, 31000)
--mobs:register_spawn("esmobs:Vanessa", {"default:dirt_with_grass","default:stone", "default:stonebrick","default:cobble","default:dirt_with_dry_grass","es:strange_grass","es:aiden_grass"}, 12, 7, 18000, 1, 31000)
--mobs:register_spawn("esmobs:FemaleSam", {"default:dirt_with_grass","default:stone", "default:stonebrick","default:cobble","default:dirt_with_dry_grass","es:strange_grass","es:aiden_grass"}, 12, 7, 18000, 1, 31000)
--mobs:register_spawn("esmobs:Battleboy", {"default:dirt_with_grass","default:stone", "default:stonebrick","default:cobble","default:dirt_with_dry_grass","es:strange_grass","es:aiden_grass"}, 12, 7,18000, 1, 31000)
--mobs:register_spawn("esmobs:Wilbert", {"default:dirt_with_grass","default:snowblock","default:snow_block","default:stone", "default:stonebrick","default:cobble","es:strange_grass","es:aiden_grass"}, 12, 7, 18000, 1, 31000)
--mobs:register_spawn("esmobs:Thelma", {"default:dirt_with_grass","default:snowblock","default:snow_block","default:stone", "default:stonebrick","default:cobble","es:strange_grass","es:aiden_grass"}, 12, 7, 18000, 1, 31000)
--mobs:register_spawn("esmobs:DrifterDan", {"default:dirt_with_grass","default:stone", "default:stonebrick","default:cobble","default:dirt_with_dry_grass","es:strange_grass","es:aiden_grass"}, 12, 7,18000, 1, 31000)
--mobs:register_spawn("esmobs:Mr_White", {"default:dirt_with_grass", "ethereal:green_dirt","default:grass","default:stonebrick","default:cobble","default:dirt_with_dry_grass","es:strange_grass","es:aiden_grass"}, 12, 7, 18000, 1, 31000)
--mobs:register_spawn("esmobs:Mr_Pink", {"default:dirt_with_grass","default:desert_sand","default:sand","default:stonebrick","default:cobble","default:dirt_with_dry_grass","es:strange_grass","es:aiden_grass"}, 12, 7, 18000, 1, 31000)
--mobs:register_spawn("esmobs:Candy", {"default:dirt_with_grass","default:stone", "default:stonebrick","default:cobble","es:strange_grass","es:aiden_grass"},5, -1, 18000, 1, 31000)
--mobs:register_spawn("esmobs:Infiniumman", {"default:dirt_with_grass","default:stone", "default:stonebrick","default:cobble","default:dirt_with_dry_grass","es:strange_grass","es:aiden_grass"}, 12, 7, 18000, 1, 31000)
--mobs:register_spawn("esmobs:Maikerumine", {"default:dirt_with_grass","default:stone", "default:stonebrick","default:cobble","default:dirt_with_dry_grass","es:strange_grass","es:aiden_grass"}, 12, 7, 18000, 1, 31000)




