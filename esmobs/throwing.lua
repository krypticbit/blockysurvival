--esmobs v1.3
--maikerumine
--made for Extreme Survival game
--Borrowed code from throwing:
--https://github.com/PilzAdam/throwing
--License: WTFPL






-- fireball (weapon)
mobs:register_arrow("esmobs:fireball", {
	visual = "sprite",
	visual_size = {x = 1, y = 1},
	textures = {"mobs_fireball.png"},
	velocity = 10,

	-- direct hit, no fire... just plenty of pain
	hit_player = function(self, player)
		player:punch(self.object, 1.0, {
			full_punch_interval = 1.0,
			damage_groups = {fleshy = 8},
		}, nil)
	end,

	hit_mob = function(self, player)
		player:punch(self.object, 1.0, {
			full_punch_interval = 1.0,
			damage_groups = {fleshy = 8},
		}, nil)
	end,

	-- node hit, bursts into flame
	hit_node = function(self, pos, node)
		mobs:explosion(pos, 1, 1, 0)  --this deletes nodes
	end
})


--arrow (weapon)
minetest.register_craftitem("esmobs:arrow", {
	description = "ESM Arrow",
	inventory_image = "arrow.png",
})

minetest.register_craftitem("esmobs:arrow_diamond", {
	description = "ESM Diamond Arrow",
	inventory_image = "arrow.png",
})

minetest.register_node("esmobs:arrow_box", {
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			-- Shaft
			{-6.5/17, -1.5/17, -1.5/17, 6.5/17, 1.5/17, 1.5/17},
			--Spitze
			{-4.5/17, 2.5/17, 2.5/17, -3.5/17, -2.5/17, -2.5/17},
			{-8.5/17, 0.5/17, 0.5/17, -6.5/17, -0.5/17, -0.5/17},
			--Federn
			{6.5/17, 1.5/17, 1.5/17, 7.5/17, 2.5/17, 2.5/17},
			{7.5/17, -2.5/17, 2.5/17, 6.5/17, -1.5/17, 1.5/17},
			{7.5/17, 2.5/17, -2.5/17, 6.5/17, 1.5/17, -1.5/17},
			{6.5/17, -1.5/17, -1.5/17, 7.5/17, -2.5/17, -2.5/17},

			{7.5/17, 2.5/17, 2.5/17, 8.5/17, 3.5/17, 3.5/17},
			{8.5/17, -3.5/17, 3.5/17, 7.5/17, -2.5/17, 2.5/17},
			{8.5/17, 3.5/17, -3.5/17, 7.5/17, 2.5/17, -2.5/17},
			{7.5/17, -2.5/17, -2.5/17, 8.5/17, -3.5/17, -3.5/17},
		}
	},
	tiles = {"throwing_arrow.png", "throwing_arrow.png", "throwing_arrow_back.png", "throwing_arrow_front.png", "throwing_arrow_2.png", "throwing_arrow.png"},
	groups = {not_in_creative_inventory=1},
})

minetest.register_node("esmobs:arrow_diamond_box", {
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			-- Shaft
			{-6.5/17, -1.5/17, -1.5/17, 6.5/17, 1.5/17, 1.5/17},
			--Spitze
			{-4.5/17, 2.5/17, 2.5/17, -3.5/17, -2.5/17, -2.5/17},
			{-8.5/17, 0.5/17, 0.5/17, -6.5/17, -0.5/17, -0.5/17},
			--Federn
			{6.5/17, 1.5/17, 1.5/17, 7.5/17, 2.5/17, 2.5/17},
			{7.5/17, -2.5/17, 2.5/17, 6.5/17, -1.5/17, 1.5/17},
			{7.5/17, 2.5/17, -2.5/17, 6.5/17, 1.5/17, -1.5/17},
			{6.5/17, -1.5/17, -1.5/17, 7.5/17, -2.5/17, -2.5/17},

			{7.5/17, 2.5/17, 2.5/17, 8.5/17, 3.5/17, 3.5/17},
			{8.5/17, -3.5/17, 3.5/17, 7.5/17, -2.5/17, 2.5/17},
			{8.5/17, 3.5/17, -3.5/17, 7.5/17, 2.5/17, -2.5/17},
			{7.5/17, -2.5/17, -2.5/17, 8.5/17, -3.5/17, -3.5/17},
		}
	},
	tiles = {"throwing_arrow.png", "throwing_arrow.png", "throwing_arrow_back.png", "throwing_arrow_front.png", "throwing_arrow_2.png", "throwing_arrow.png"},
	groups = {not_in_creative_inventory=1},
})

local THROWING_ARROW_ENTITY={
	physical = false,
	timer=0,
	visual = "wielditem",
	visual_size = {x=0.1, y=0.1},
	textures = {"esmobs:arrow_box"},
	--textures = {"esmobs:arrow.png"},
	lastpos={},
	collisionbox = {0,0,0,0,0,0},
}

local THROWING_ARROW_DIAMOND_ENTITY={
	physical = false,
	timer=0,
	visual = "wielditem",
	visual_size = {x=0.1, y=0.1},
	textures = {"esmobs:arrow_diamond_box"},
	--textures = {"esmobs:arrow.png"},
	lastpos={},
	collisionbox = {0,0,0,0,0,0},
}


--ARROW CODE
THROWING_ARROW_ENTITY.on_step = function(self, dtime)
	self.timer=self.timer+dtime
	local pos = self.object:getpos()
	local node = minetest.get_node(pos)

minetest.add_particle({
    pos = pos,
    vel = {x=0, y=0, z=0},
    acc = {x=0, y=0, z=0},
    expirationtime = .3,
    size = 1,
    collisiondetection = false,
    vertical = false,
    texture = "arrow_particle.png",
})

	if self.timer>0.2 then
		local objs = minetest.get_objects_inside_radius({x=pos.x,y=pos.y,z=pos.z}, 1.5)
		for k, obj in pairs(objs) do
			if obj:get_luaentity() ~= nil then
				if obj:get_luaentity().name ~= "esmobs:arrow_entity" and obj:get_luaentity().name ~= "__builtin:item" then
					local damage = 3
					minetest.sound_play("damage", {pos = pos})
					obj:punch(self.object, 1.0, {
						full_punch_interval=1.0,
						damage_groups={fleshy=damage},
					}, nil)
					self.object:remove()
				end
			else
				local damage = 3
				minetest.sound_play("damage", {pos = pos})
				obj:punch(self.object, 1.0, {
					full_punch_interval=1.0,
					damage_groups={fleshy=damage},
				}, nil)
				self.object:remove()
			end
		end
	end

	if self.lastpos.x~=nil then
		if node.name ~= "air" then
			minetest.sound_play("bowhit1", {pos = pos})
			--minetest.punch_node(pos)  --this crash game when bones for mobs used
			minetest.add_item(self.lastpos, 'esmobs:arrow')
			self.object:remove()
		end
	end
	self.lastpos={x=pos.x, y=pos.y, z=pos.z}
end


THROWING_ARROW_DIAMOND_ENTITY.on_step = function(self, dtime)
	self.timer=self.timer+dtime
	local pos = self.object:getpos()
	local node = minetest.get_node(pos)

minetest.add_particle({
    pos = pos,
    vel = {x=0, y=0, z=0},
    acc = {x=0, y=0, z=0},
    expirationtime = .3,
    size = 1,
    collisiondetection = false,
    vertical = false,
    texture = "arrow_particle.png",
})

	if self.timer>0.2 then
		local objs = minetest.get_objects_inside_radius({x=pos.x,y=pos.y,z=pos.z}, 1.5)
		for k, obj in pairs(objs) do
			if obj:get_luaentity() ~= nil then
				if obj:get_luaentity().name ~= "esmobs:arrow_diamond_entity" and obj:get_luaentity().name ~= "__builtin:item" then
					local damage = 9
					minetest.sound_play("damage", {pos = pos})
					obj:punch(self.object, 1.0, {
						full_punch_interval=0.25,
						damage_groups={fleshy=damage},
					}, nil)
					self.object:remove()
				end
			else
				local damage = 9
				minetest.sound_play("damage", {pos = pos})
				obj:punch(self.object, 1.0, {
					full_punch_interval=0.25,
					damage_groups={fleshy=damage},
				}, nil)
				self.object:remove()
			end
		end
	end

	if self.lastpos.x~=nil then
		if node.name ~= "air" then
			minetest.sound_play("bowhit1", {pos = pos})
			--minetest.punch_node(pos)  --this crash game when bones for mobs used
			minetest.add_item(self.lastpos, 'esmobs:arrow_diamond')
			self.object:remove()
		end
	end
	self.lastpos={x=pos.x, y=pos.y, z=pos.z}
end




minetest.register_entity("esmobs:arrow_entity", THROWING_ARROW_ENTITY)
minetest.register_entity("esmobs:arrow_diamond_entity", THROWING_ARROW_DIAMOND_ENTITY)

minetest.register_craft({
	output = 'esmobs:arrow 4',
	recipe = {
		{'default:steel_ingot'},
		{'default:stick'},
		{'esmobs:feather'},
	}
})

minetest.register_craft({
	output = 'esmobs:arrow_diamond 2',
	recipe = {
		{'default:diamond'},
		{'default:copper_ingot'},
		{'esmobs:feather'},
	}
})


arrows = {
	{"esmobs:arrow", "esmobs:arrow_entity" },
	{"esmobs:arrow_diamond","esmobs:arrow_diamond_entity"},
}

local throwing_shoot_arrow = function(itemstack, player)
	for _,arrow in ipairs(arrows) do
		if player:get_inventory():get_stack("main", player:get_wield_index()+1):get_name() == arrow[1] then
			if not minetest.setting_getbool("creative_mode") then
				player:get_inventory():remove_item("main", arrow[1])
			end
			local playerpos = player:getpos()
			--local obj = minetest.env:add_entity({x=playerpos.x,y=playerpos.y+1.5,z=playerpos.z}, arrow[2]) --current
			local obj = minetest.add_entity({x=playerpos.x,y=playerpos.y+1.5,z=playerpos.z}, arrow[2])  --mc
			local dir = player:get_look_dir()
			obj:setvelocity({x=dir.x*22, y=dir.y*22, z=dir.z*22})
			obj:setacceleration({x=dir.x*-3, y=-10, z=dir.z*-3})
			obj:setyaw(player:get_look_yaw()+math.pi)
			minetest.sound_play("throwing_sound", {pos=playerpos})
			if obj:get_luaentity().player == "" then
				obj:get_luaentity().player = player
			end
			obj:get_luaentity().node = player:get_inventory():get_stack("main", 1):get_name()
			return true
		end
	end
	return false
end

minetest.register_tool("esmobs:bow_wood", {
	description = "ESM Wood Bow",
	inventory_image = "bow_standby.png",
    stack_max = 1,
	on_use = function(itemstack, user, pointed_thing)
		if throwing_shoot_arrow(itemstack, user, pointed_thing) then
			if not minetest.setting_getbool("creative_mode") then
				itemstack:add_wear(65535/50)
			end
		end
		return itemstack
	end,
})

minetest.register_craft({
	output = 'esmobs:bow_wood',
	recipe = {
		{'farming:cotton', 'default:stick', ''},
		{'farming:cotton', '',              'default:stick'},
		{'farming:cotton', 'default:stick', ''},
	}
})


-- bone (weapon)
mobs:register_arrow("esmobs:bonebullet", {
	visual = "sprite",
	visual_size = {x = 0.3, y = 0.3},
	textures = {"bones_front.png"},
	velocity = 3,

	-- direct hit, no fire... just plenty of pain
	hit_player = function(self, player)
		player:punch(self.object, 1.0, {
			full_punch_interval = 1.0,
			damage_groups = {fleshy = 2},
		}, nil)
	end,

	hit_mob = function(self, player)
		player:punch(self.object, 1.0, {
			full_punch_interval = 1.0,
			damage_groups = {fleshy = 1},
		}, nil)
	end,

	-- node hit, bursts into flame
	hit_node = function(self, pos, node)
		--mobs:explosion(pos, 1, 1, 0)  --this deletes nodes
	end
})

-- book (weapon)
mobs:register_arrow("esmobs:bookbullet", {
	visual = "sprite",
	visual_size = {x = 0.3, y = 0.3},
	textures = {"default_book.png"},
	velocity = 7,

	-- direct hit, no fire... just plenty of pain
	hit_player = function(self, player)
		player:punch(self.object, 1.0, {
			full_punch_interval = 1.0,
			damage_groups = {fleshy = 4},
		}, nil)
	end,

	hit_mob = function(self, player)
		player:punch(self.object, 1.0, {
			full_punch_interval = 1.0,
			damage_groups = {fleshy = 7},
		}, nil)
	end,

	-- node hit, bursts into flame
	hit_node = function(self, pos, node)
		--mobs:explosion(pos, 1, 1, 0)  --this deletes nodes
	end
})

-- axe (weapon)
mobs:register_arrow("esmobs:axebullet", {
	visual = "sprite",
	visual_size = {x = 0.3, y = 0.3},
	textures = {"default_tool_meseaxe.png"},
	velocity = 7,

	-- direct hit, no fire... just plenty of pain
	hit_player = function(self, player)
		player:punch(self.object, 1.0, {
			full_punch_interval = 1.0,
			damage_groups = {fleshy = 4},
		}, nil)
	end,

	hit_mob = function(self, player)
		player:punch(self.object, 1.0, {
			full_punch_interval = 1.0,
			damage_groups = {fleshy = 7},
		}, nil)
	end,

	-- node hit, bursts into flame
	hit_node = function(self, pos, node)
		--mobs:explosion(pos, 1, 1, 0)  --this deletes nodes
	end
})

