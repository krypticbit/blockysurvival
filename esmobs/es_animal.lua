--esmobs v1.3
--maikerumine
--made for Extreme Survival game
--License for code is WTFPL

------------------------------
--MINETEST ANIMALS
------------------------------
-- Rat by PilzAdam

mobs:register_mob("esmobs:rat", {
	type = "animal",
	passive = true,
	hp_min = 1,
	hp_max = 4,
	armor = 200,
	collisionbox = {-0.2, -1, -0.2, 0.2, -0.8, 0.2},
	visual = "mesh",
	mesh = "mobs_rat.b3d",
	textures = {
		{"mobs_rat.png"},
		{"mobs_rat2.png"},
	},
	makes_footstep_sound = false,
	sounds = {
		random = "mobs_rat",
	},
	walk_velocity = 1,
	run_velocity = 2,
	runaway = true,
	jump = true,
	water_damage = 0,
	lava_damage = 4,
	light_damage = 0,
	fear_height = 2,
	on_rightclick = function(self, clicker)
		mobs:capture_mob(self, clicker, 25, 80, 0, true, nil)
	end,
--[[
	do_custom = function(self)
		local pos = self.object:getpos()
		print("rat pos", pos.x, pos.y, pos.z)
	end,
--]]
})

local all_colours = {
	{"black",      "Black",      "#000000b0"},
	{"blue",       "Blue",       "#015dbb70"},
	{"brown",      "Brown",      "#663300a0"},
	{"cyan",       "Cyan",       "#01ffd870"},
	{"dark_green", "Dark Green", "#005b0770"},
	{"dark_grey",  "Dark Grey",  "#303030b0"},
	{"green",      "Green",      "#61ff0170"},
	{"grey",       "Grey",       "#5b5b5bb0"},
	{"magenta",    "Magenta",    "#ff05bb70"},
	{"orange",     "Orange",     "#ff840170"},
	{"pink",       "Pink",       "#ff65b570"},
	{"red",        "Red",        "#ff0000a0"},
	{"violet",     "Violet",     "#2000c970"},
	{"white",      "White",      "#abababc0"},
	{"yellow",     "Yellow",     "#e3ff0070"},
}

-- Sheep by PilzAdam, texture converted to minetest by AMMOnym from Summerfield pack

for _, col in pairs(all_colours) do

	mobs:register_mob("esmobs:sheep_"..col[1], {
		type = "animal",
		passive = true,
		hp_min = 8,
		hp_max = 10,
		armor = 200,
		collisionbox = {-0.5, -1, -0.5, 0.5, 0.3, 0.5},
		visual = "mesh",
		mesh = "mobs_sheep.b3d",
		textures = {
			{"mobs_sheep_base.png^(mobs_sheep_wool.png^[colorize:" .. col[3] .. ")"},
		},
		gotten_texture = {"mobs_sheep_shaved.png"},
		gotten_mesh = "mobs_sheep_shaved.b3d",
		makes_footstep_sound = true,
		sounds = {
			random = "mobs_sheep",
		},
		walk_velocity = 1,
		run_velocity = 2,
		runaway = true,
		jump = true,
		drops = {
			{name = "esmobs:meat_raw", chance = 1, min = 1, max = 2},
			{name = "wool:"..col[1], chance = 1, min = 1, max = 1},
		},
		water_damage = 1,
		lava_damage = 5,
		light_damage = 0,
		animation = {
			speed_normal = 15,
			speed_run = 15,
			stand_start = 0,
			stand_end = 80,
			walk_start = 81,
			walk_end = 100,
		},
		follow = {"farming:wheat", "default:grass_5"},
		view_range = 8,
		replace_rate = 10,
		replace_what = {"default:grass_3", "default:grass_4", "default:grass_5", "farming:wheat_8"},
		replace_with = "air",
		replace_offset = -1,
		fear_height = 3,
		on_rightclick = function(self, clicker)

			local shpcolor = string.split(self.name,"_")[2]

			if shpcolor =="dark" then
				shpcolor = shpcolor.."_"..string.split(self.name,"_")[3]
			end

			--are we feeding?
			if mobs:feed_tame(self, clicker, 8, true, true) then

				--if full grow fuzz
				if self.gotten == false then
					self.object:set_properties({
						textures = {"mobs_sheep_wool.png^[colorize:" .. col[3] .. "^mobs_sheep_base.png"},
						mesh = "mobs_sheep.b3d",
					})
				end

				return
			end

			local item = clicker:get_wielded_item()
			local itemname = item:get_name()

			--are we giving a haircut>
			if itemname == "esmobs:shears" then

				if self.gotten == false and self.child == false then

					self.gotten = true -- shaved

					if minetest.get_modpath("wool") then

						local pos = self.object:getpos()
						pos.y = pos.y + 0.5

						local obj = minetest.add_item(pos, ItemStack("wool:"..shpcolor.." "..math.random(1,3)))

						if obj then
							obj:setvelocity({
								x = math.random(-1,1),
								y = 5,
								z = math.random(-1,1)
							})
						end

						item:add_wear(650) -- 100 uses

						clicker:set_wielded_item(item)
					end

					self.object:set_properties({
						textures = {"mobs_sheep_shaved.png"},
						mesh = "mobs_sheep_shaved.b3d",
					})
				end

				return
			end

			local name = clicker:get_player_name()

			--are we coloring?
			if itemname:find("dye:") then

				if self.gotten == false
				and self.child == false
				and self.tamed == true
				and name == self.owner then

					local colr = string.split(itemname,":")[2]

					for _,c in pairs(all_colours) do

						if c[1] == colr then

							local pos = self.object:getpos()

							self.object:remove()

							local mob = minetest.add_entity(pos, "esmobs:sheep_"..colr)
							local ent = mob:get_luaentity()

							ent.owner = name
							ent.tamed = true

							-- take item
							if not minetest.setting_getbool("creative_mode") then
								item:take_item()
								clicker:set_wielded_item(item)
							end

							break
						end
					end
				end

				return
			end

			--are we capturing?
			mobs:capture_mob(self, clicker, 0, 5, 60, false, nil)
		end
	})

	mobs:register_egg("esmobs:sheep_"..col[1], col[2] .. "Sheep", "wool_"..col[1]..".png", 1)

end


-- compatibility (item and entity)
minetest.register_alias("esmobs:sheep", "esmobs:sheep_white")

-- replace old sheep entity with new white sheep
minetest.register_entity("esmobs:sheep", {

	on_activate = function(self, staticdata, dtime_s)

		self.object:remove()

		minetest.add_entity(self.object:getpos(), "esmobs:sheep_white")
	end
})

-- Chicken by JK Murray

mobs:register_mob("esmobs:chicken", {
	type = "animal",
	passive = true,
	hp_min = 5,
	hp_max = 10,
	armor = 200,
	collisionbox = {-0.3, -0.75, -0.3, 0.3, 0.1, 0.3},
	visual = "mesh",
	mesh = "mobs_chicken.x",
	-- seems a lot of textures but this fixes the problem with the model
	textures = {
		{"mobs_21.png", "mobs_21.png", "mobs_21.png", "mobs_21.png",
		"mobs_21.png", "mobs_21.png", "mobs_21.png", "mobs_21.png", "mobs_21.png"},
		{"mobs_chicken_black.png", "mobs_chicken_black.png", "mobs_chicken_black.png", "mobs_chicken_black.png",
		"mobs_chicken_black.png", "mobs_chicken_black.png", "mobs_chicken_black.png", "mobs_chicken_black.png", "mobs_chicken_black.png"},
	},
	child_texture = {
		{"mobs_chick.png", "mobs_chick.png", "mobs_chick.png", "mobs_chick.png",
		"mobs_chick.png", "mobs_chick.png", "mobs_chick.png", "mobs_chick.png", "mobs_chick.png"},
	},
	makes_footstep_sound = true,
	sounds = {
		random = "mobs_chicken",
	},
	walk_velocity = 1,
	run_velocity = 3,
	runaway = true,
	jump = true,
	drops = {
		{name = "esmobs:chicken_raw",
		chance = 1, min = 2, max = 2},
	},
	water_damage = 1,
	lava_damage = 5,
	light_damage = 0,
	fall_damage = 0,
	fall_speed = -8,
	fear_height = 5,
	animation = {
		speed_normal = 15,
		stand_start = 0,
		stand_end = 1, -- 20
		walk_start = 20,
		walk_end = 40,
	},
	follow = {"farming:seed_wheat", "farming:seed_cotton"},
	view_range = 5,

	on_rightclick = function(self, clicker)
		if mobs:feed_tame(self, clicker, 8, true, true) then
			return
		end
		mobs:capture_mob(self, clicker, 30, 50, 80, false, nil)
	end,

	do_custom = function(self)
		if not self.child
		and math.random(1, 500) == 1 then
			local pos = self.object:getpos()
			minetest.add_item(pos, "esmobs:egg")
			minetest.sound_play("default_place_node_hard", {
				pos = pos,
				gain = 1.0,
				max_hear_distance = 5,
			})
		end
	end,
})

-- Cow by Krupnovpavel

mobs:register_mob("esmobs:cow", {
	type = "animal",
	passive = false,
	attack_type = "dogfight",
	reach = 2,
	damage = 4,
	hp_min = 5,
	hp_max = 20,
	armor = 200,
	collisionbox = {-0.4, -0.01, -0.4, 0.4, 1, 0.4},
	visual = "mesh",
	mesh = "mobs_cow.x",
	textures = {
		{"mobs_19.png"},
		{"mobs_cow2.png"},
	},
	makes_footstep_sound = true,
	sounds = {
		random = "mobs_cow",
	},
	walk_velocity = 1,
	run_velocity = 2,
	jump = true,
	drops = {
		{name = "esmobs:meat_raw",
		chance = 1, min = 1, max = 3},
		{name = "esmobs:leather",
		chance = 1, min = 1, max = 2},
	},
	water_damage = 1,
	lava_damage = 5,
	light_damage = 0,
	animation = {
		speed_normal = 15,
		speed_run = 15,
		stand_start = 0,
		stand_end = 30,
		walk_start = 35,
		walk_end = 65,
		run_start = 105,
		run_end = 135,
		punch_start = 70,
		punch_end = 100,
	},
	follow = "farming:wheat",
	view_range = 7,
	replace_rate = 10,
	replace_what = {"default:grass_3", "default:grass_4", "default:grass_5", "farming:wheat_8"},
	replace_with = "air",
	fear_height = 2,
	on_rightclick = function(self, clicker)

		-- feed or tame
		if mobs:feed_tame(self, clicker, 8, true, true) then
			return
		end

		local tool = clicker:get_wielded_item()

		-- milk cow with empty bucket
		if tool:get_name() == "bucket:bucket_empty" then

			--if self.gotten == true
			if self.child == true then
				return
			end

			if self.gotten == true then
				minetest.chat_send_player(clicker:get_player_name(),
						"Cow already milked!")
				return
			end

			local inv = clicker:get_inventory()

			inv:remove_item("main", "bucket:bucket_empty")

			if inv:room_for_item("main", {name = "esmobs:bucket_milk"}) then
				clicker:get_inventory():add_item("main", "esmobs:bucket_milk")
			else
				local pos = self.object:getpos()
				pos.y = pos.y + 0.5
				minetest.add_item(pos, {name = "esmobs:bucket_milk"})
			end

			self.gotten = true -- milked

			return
		end

		mobs:capture_mob(self, clicker, 0, 5, 60, false, nil)
	end,
})

-- Warthog by KrupnoPavel

mobs:register_mob("esmobs:pumba", {
	type = "animal",
	passive = false,
	attack_type = "dogfight",
	group_attack = true,
	reach = 2,
	damage = 2,
	hp_min = 5,
	hp_max = 15,
	armor = 200,
	collisionbox = {-0.4, -0.01, -0.4, 0.4, 1, 0.4},
	visual = "mesh",
	mesh = "mobs_pumba.x",
	textures = {
		{"mobs_20.png"},
	},
	makes_footstep_sound = true,
	sounds = {
		random = "mobs_pig",
		attack = "mobs_pig_angry",
	},
	walk_velocity = 2,
	run_velocity = 3,
	jump = true,
	follow = {"default:apple", "farming:potato"},
	view_range = 10,
	drops = {
		{name = "esmobs:pork_raw",
		chance = 1, min = 1, max = 3},
	},
	water_damage = 1,
	lava_damage = 5,
	light_damage = 0,
	fear_height = 2,
	animation = {
		speed_normal = 15,
		stand_start = 25,
		stand_end = 55,
		walk_start = 70,
		walk_end = 100,
		punch_start = 70,
		punch_end = 100,
	},
	on_rightclick = function(self, clicker)
		if mobs:feed_tame(self, clicker, 8, true, true) then
			return
		end
		mobs:capture_mob(self, clicker, 0, 5, 50, false, nil)
	end,
})






-------------------------
--KPGMOBS HORSE
-------------------------
--By: KrupnovPavel
local function is_ground(pos)
	local nn = minetest.get_node(pos).name
	return minetest.get_item_group(nn, "crumbly") ~= 0 or
	minetest.get_item_group(nn, "choppy") ~= 0 or
	minetest.get_item_group(nn, "cracky") ~= 0  or
	minetest.get_item_group(nn, "snappy") ~= 0  or
	minetest.get_item_group(nn, "unbreakable") ~= 0  or
	minetest.get_item_group(nn, "immortal") ~= 0
end

local function get_sign(i)
	if i == 0 then
		return 0
	else
		return i/math.abs(i)
	end
end

local function get_velocity(v, yaw, y)
	local x = math.cos(yaw)*v
	local z = math.sin(yaw)*v
	return {x=x, y=y, z=z}
end

local function get_v(v)
	return math.sqrt(v.x^2+v.z^2)
end

function merge(a, b)
    if type(a) == 'table' and type(b) == 'table' then
        for k,v in pairs(b) do if type(v)=='table' and type(a[k] or false)=='table' then merge(a[k],v) else a[k]=v end end
    end
    return a
end

-- HORSE go go goooo :)
local horse = {
	physical = true,
	collisionbox = {-0.4, -0.01, -0.4, 0.4, 1, 0.4},
	visual = "mesh",
	stepheight = 1.1,
	visual_size = {x=1,y=1},
	mesh = "mobs_horseh1.x",
	driver = nil,
	v = 0,

	on_rightclick = function(self, clicker)
		if not clicker or not clicker:is_player() then
			return
		end
		if self.driver and clicker == self.driver then
			self.driver = nil
			clicker:set_detach()
		elseif not self.driver then
			self.driver = clicker
			clicker:set_attach(self.object, "", {x=0,y=11,z=0}, {x=0,y=0,z=0})
			self.object:setyaw(clicker:get_look_yaw())
		end
	end,

	on_activate = function(self, staticdata, dtime_s)
		self.object:set_armor_groups({immortal=1})
		print (self.texture, self.jmp)
	end,

	on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, direction)
		if puncher and puncher:is_player() then
			puncher:get_inventory():add_item("main", self.name)
			self.object:remove()
		end
	end,

	on_step = function(self, dtime)

		self.v = get_v(self.object:getvelocity())*get_sign(self.v)

		if self.driver then
			local ctrl = self.driver:get_player_control()
			if ctrl.up then
				self.v = self.v + self.jmp
			end
			if ctrl.down then
				self.v = self.v-0.1
			end
			if ctrl.left then
				self.object:setyaw(self.object:getyaw()+math.pi/120+dtime*math.pi/120)
			end
			if ctrl.right then
				self.object:setyaw(self.object:getyaw()-math.pi/120-dtime*math.pi/120)
			end
			if ctrl.jump then
				local p = self.object:getpos()
				p.y = p.y-0.5
				if is_ground(p) then
					local pos = self.object:getpos()
					pos.y = math.floor(pos.y)+4
					self.object:setpos(pos)
					self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), 0))
				end
			end
		end

		local s = get_sign(self.v)
		self.v = self.v - 0.02*s
		if s ~= get_sign(self.v) then
			self.object:setvelocity({x=0, y=0, z=0})
			self.v = 0
			return
		end

		if math.abs(self.v) > 4.5 then
			self.v = 4.5*get_sign(self.v)
		end

		local p = self.object:getpos()
		p.y = p.y-0.5

		if not is_ground(p) then
			if minetest.registered_nodes[minetest.get_node(p).name].walkable then
				self.v = 0
			end
			self.object:setacceleration({x=0, y=-10, z=0})
			self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), self.object:getvelocity().y))
		else
			p.y = p.y+1
			if is_ground(p) then
				self.object:setacceleration({x=0, y=3, z=0})
				local y = self.object:getvelocity().y
				if y > 2 then
					y = 2
				end
				if y < 0 then
					self.object:setacceleration({x=0, y=10, z=0})
				end
				self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), y))
			else
				self.object:setacceleration({x=0, y=0, z=0})
				if math.abs(self.object:getvelocity().y) < 1 then
					local pos = self.object:getpos()
					pos.y = math.floor(pos.y)+0.5
					self.object:setpos(pos)
					self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), 0))
				else
					self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), self.object:getvelocity().y))
				end
			end
		end
	end,
}

--END HORSE

-- backup table
local hbak = horse

-- Brown Horse
local hrs = {
	textures = {"mobs_horseh1.png"},
	jmp = 2,
}
minetest.register_entity("esmobs:horseh1", merge(hrs, horse))

-- White Horse
horse = hbak
local peg = {
	textures = {"mobs_horsepegh1.png"},
	jmp = 2,
}
minetest.register_entity("esmobs:horsepegh1", merge(peg, horse))

-- Black Horse
horse = hbak
local ara = {
	textures = {"mobs_horsearah1.png"},
	jmp = 3,
}
minetest.register_entity("esmobs:horsearah1", merge(ara, horse))


mobs:register_mob("esmobs:horse", {
	type = "animal",
	hp_min = 5,
	hp_max = 10,
	collisionbox = {-0.4, -0.01, -0.4, 0.4, 1, 0.4},
	textures = {
		{"mobs_22.png"},
	},
	visual = "mesh",
	mesh = "mobs_horse.x",
	makes_footstep_sound = true,
	walk_velocity = 1,
	armor = 200,
	drops = {
		{name = "esmobs:meat_raw",
		chance = 1,
		min = 2,
		max = 3,},
	},
	drawtype = "front",
	water_damage = 1,
	lava_damage = 5,
	light_damage = 0,
	animation = {
		speed_normal = 15,
		stand_start = 25,		stand_end = 75,
		walk_start = 75,		walk_end = 100,
	},
	follow = "farming:wheat",
	view_range = 5,

	on_rightclick = function(self, clicker)
		local tool = clicker:get_wielded_item()
		if tool:get_name() == "esmobs:saddle" then
			clicker:get_inventory():remove_item("main", "esmobs:saddle")
			local pos = self.object:getpos()
			self.object:remove()
			minetest.add_entity(pos, "esmobs:horseh1")
		end
	end,
})

mobs:register_mob("esmobs:horse2", {
	type = "animal",
	hp_min = 5,
	hp_max = 10,
	collisionbox = {-0.4, -0.01, -0.4, 0.4, 1, 0.4},
	textures = {
		{"mobs_23.png"},
	},
	visual = "mesh",
	mesh = "mobs_horse.x",
	makes_footstep_sound = true,
	walk_velocity = 1,
	armor = 200,
	drops = {
		{name = "esmobs:meat_raw",
		chance = 1,
		min = 2,
		max = 3,},
	},
	drawtype = "front",
	water_damage = 1,
	lava_damage = 5,
	light_damage = 0,
	animation = {
		speed_normal = 15,
		stand_start = 25,		stand_end = 75,
		walk_start = 75,		walk_end = 100,
	},
	follow = "farming:wheat",
	view_range = 5,

	on_rightclick = function(self, clicker)
		local tool = clicker:get_wielded_item()
		if tool:get_name() == "esmobs:saddle" then
			clicker:get_inventory():remove_item("main", "esmobs:saddle")
			local pos = self.object:getpos()
			self.object:remove()
			minetest.add_entity(pos, "esmobs:horsepegh1")
		end
	end,
})

mobs:register_mob("esmobs:horse3", {
	type = "animal",
	hp_min = 5,
	hp_max = 10,
	collisionbox = {-0.4, -0.01, -0.4, 0.4, 1, 0.4},
	textures = {
		{"mobs_24.png"},
	},
	visual = "mesh",
	mesh = "mobs_horse.x",
	makes_footstep_sound = true,
	walk_velocity = 1,
	armor = 200,
	drops = {
		{name = "esmobs:meat_raw",
		chance = 1,
		min = 2,
		max = 3,},
	},
	drawtype = "front",
	water_damage = 1,
	lava_damage = 5,
	light_damage = 0,
	animation = {
		speed_normal = 15,
		stand_start = 25,		stand_end = 75,
		walk_start = 75,		walk_end = 100,
	},
	follow = "farming:wheat",
	view_range = 5,

	on_rightclick = function(self, clicker)
		local tool = clicker:get_wielded_item()
		if tool:get_name() == "esmobs:saddle" then
			clicker:get_inventory():remove_item("main", "esmobs:saddle")
			local pos = self.object:getpos()
			self.object:remove()
			minetest.add_entity(pos, "esmobs:horsearah1")
		end
	end,
})



-- Dog

mobs:register_mob("esmobs:dog", {
	type = "npc",
	passive = true,
	hp_max = 55,
	collisionbox = {-0.4, -0.01, -0.4, 0.4, 1, 0.4},
	visual = "mesh",
	mesh = "mobs_wolf.x",
	textures = {
		{"mobs_25.png"},
	},
	makes_footstep_sound = true,
	sounds = {
		war_cry = "mobs_wolf_attack",
	},
	view_range = 15,
	stepheight = 1.1,
	owner = "",
	order = "follow",
	floats = {x=0,y=0,z=0},
	walk_velocity = 4,
	run_velocity = 4,
	stepheight = 1.1,
	damage = 3,
	armor = 200,
	attacks_monsters = true,
	attack_type = "dogfight",
	drops = {
		{name = "esmobs:meat_raw",
		chance = 1,
		min = 2,
		max = 3,},
	},
	drawtype = "front",
	water_damage = 0,
	lava_damage = 5,
	light_damage = 0,
	on_rightclick = function(self, clicker)
		local item = clicker:get_wielded_item()
		if item:get_name() == "esmobs:meat_raw" then
			local hp = self.object:get_hp()
			if hp + 4 > self.hp_max then return end
			if not minetest.setting_getbool("creative_mode") then
				item:take_item()
				clicker:set_wielded_item(item)
			end
			self.object:set_hp(hp+4)
		else
			if self.owner == "" then
				self.owner = clicker:get_player_name()
			else
				local formspec = "size[8,4]"
				formspec = formspec .. "textlist[2.85,0;2.1,0.5;dialog;What can I do for you?]"
				formspec = formspec .. "button_exit[1,1;2,2;dfollow;follow]"
				formspec = formspec .. "button_exit[5,1;2,2;dstand;stand]"
				formspec = formspec .. "button_exit[0,2;4,4;dfandp;follow and protect]"
				formspec = formspec .. "button_exit[4,2;4,4;dsandp;stand and protect]"
				formspec = formspec .. "button_exit[1,2;2,2;dgohome; go home]"
				formspec = formspec .. "button_exit[5,2;2,2;dsethome; sethome]"
				minetest.show_formspec(clicker:get_player_name(), "order", formspec)
				minetest.register_on_player_receive_fields(function(clicker, formname, fields)
					if fields.dfollow then
						self.order = "follow"
						self.attacks_monsters = false
					end
					if fields.dstand then
						self.order = "stand"
						self.attacks_monsters = false
					end
					if fields.dfandp then
						self.order = "follow"
						self.attacks_monsters = true
					end
					if fields.dsandp then
						self.order = "stand"
						self.attacks_monsters = true
					end
					if fields.dsethome then
						self.floats = self.object:getpos()
					end
					if fields.dgohome then
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
		speed_normal = 20,
		speed_run = 30,
		stand_start = 10,
		stand_end = 20,
		walk_start = 75,
		walk_end = 100,
		run_start = 100,
		run_end = 130,
		punch_start = 135,
		punch_end = 155,
	},
	jump = true,
	step = 1,
	blood_texture = "mobs_blood.png",
})

-- Wolf by KrupnoPavel

mobs:register_mob("esmobs:wolf", {
	type = "animal",
	hp_max = 55,
	passive = false,
	collisionbox = {-0.4, -0.01, -0.4, 0.4, 1, 0.4},
	visual = "mesh",
	mesh = "mobs_wolf.x",
	textures = {
		{"mobs_26.png"},
	},
	makes_footstep_sound = true,
	sounds = {
		war_cry = "mobs_wolf_attack",
	},
	view_range = 7,
	walk_velocity = 2,
	run_velocity = 3,
	stepheight = 1.1,
	damage = 3,
	armor = 200,
	attack_type = "dogfight",
	drops = {
		{name = "esmobs:meat_raw",
		chance = 1,
		min = 2,
		max = 3,},
	},
	drawtype = "front",
	water_damage = 0,
	lava_damage = 5,
	light_damage = 0,
	on_rightclick = function(self, clicker)
		tool = clicker:get_wielded_item()
		local dog
		local ent
		if tool:get_name() == "esmobs:meat_raw" then
			clicker:get_inventory():remove_item("main", "esmobs:meat_raw")
			dog = minetest.add_entity(self.object:getpos(), "esmobs:dog")
			ent = dog:get_luaentity()
			ent.owner = clicker:get_player_name()
			self.object:remove()
		end
	end,
	animation = {
		speed_normal = 20,
		speed_run = 30,
		stand_start = 10,
		stand_end = 20,
		walk_start = 75,
		walk_end = 100,
		run_start = 100,
		run_end = 130,
		punch_start = 135,
		punch_end = 155,
	},
	jump = true,
	step = 0.5,
	blood_texture = "mobs_blood.png",
})






--REFERENCE
--function mobs:spawn_specific(name, nodes, neighbors, min_light, max_light, interval, chance, active_object_count, min_height, max_height)
--mobs:register_spawn("mobs:dirt_monster", {"default:dirt_with_grass", "ethereal:gray_dirt"}, 7, 0, 7000, 2, 31000)

--NOTE: ALWAYS PUT THE REGISTER_SPAWN BELOW THE REGISTER_ENTITY!!!!!
--[[
mobs:register_spawn("esmobs:rat", {"default:stone"},{"air"}, 14, -1, 10000, 2, -1000,10)
mobs:register_spawn("esmobs:sheep_white", {"default:dirt_with_grass"},{"air"}, 14, 10, 15000, 1, -30,300)
mobs:register_spawn("esmobs:pumba", {"default:dirt_with_dry_grass"},{"air"}, 14, 10, 18000, 1, -2,150)
mobs:register_spawn("esmobs:cow", {"default:dirt_with_grass"},{"air"}, 14, 10, 11000, 1, -2,120)
mobs:register_spawn("esmobs:chicken", {"default:dirt_with_grass"},{"air"}, 14, 12, 17000, 2, -12,50)
mobs:register_spawn("esmobs:horse", {"default:dirt_with_dry_grass"},{"air"}, 14, 10, 17000, 1, 15,25)
mobs:register_spawn("esmobs:horse2", {"default:dirt_with_dry_grass"},{"air"}, 14, 10, 17000, 1,  75,125)
mobs:register_spawn("esmobs:horse3", {"default:desert_sand"},{"air"}, 14, 10, 17000, 1,  15,25)
]]

mobs:register_spawn("esmobs:rat", {"default:dirt_with_grass", "default:stone"}, 20, -1, 10000, 2, 14)
mobs:register_spawn("esmobs:sheep_white", {"default:dirt_with_grass", "ethereal:green_dirt","es:strange_grass","es:aiden_grass"}, 20, 10, 15000, 1, 31000)
mobs:register_spawn("esmobs:pumba", {"default:dirt_with_grass","default:dirt_with_dry_grass"}, 20, 10, 18000, 1, 25)
mobs:register_spawn("esmobs:cow", {"default:dirt_with_grass","es:strange_grass","es:aiden_grass"}, 20, 10, 10000, 1, 30)
mobs:register_spawn("esmobs:chicken", {"default:dirt_with_grass","es:strange_grass","es:aiden_grass"}, 20, 12, 20000, 2, 55)
mobs:register_spawn("esmobs:horse", {"default:dirt_with_dry_grass","es:strange_grass","es:aiden_grass"}, 20, 12, 21000, 1, 12)
mobs:register_spawn("esmobs:horse2", {"default:dirt_with_dry_grass"}, 20, 12, 23000, 1, 31000)
mobs:register_spawn("esmobs:horse3", {"default:desert_sand"}, 20, 8, 17000, 1, 5)
mobs:register_spawn("esmobs:chickoboo", {"default:dirt_with_grass", "ethereal:bamboo_dirt"}, 15, 10, 15000, 1, 31000)
mobs:register_spawn("esmobs:wolf", {"default:dirt_with_grass","default:dirt","default:snow", "default:snowblock"}, 20, 0, 19000, 1, 31000)

