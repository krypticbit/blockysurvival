--esmobs v01.0
--maikerumine
--made for Extreme Survival game
--License for code WTFPL

-- Mobs Api (26th April 2015) By TenPlus1
--REVISED 20160111 maikerumine for esmobs
bp = {}
bp.mod = "esmobs"

-- Do mobs spawn in protected areas (0=yes, 1=no)
bp.protected = 0

-- Initial settings check
local damage_enabled = minetest.setting_getbool("enable_damage")
local peaceful_only = minetest.setting_getbool("only_peaceful_mobs")
local enable_blood = minetest.setting_getbool("mobs_enable_blood") or true
bp.remove = minetest.setting_getbool("remove_far_mobs") or true
bp.protected = tonumber(minetest.setting_get("mobs_spawn_protected")) or 0


function bp:register_mob(name, def)
	minetest.register_entity(name, {
		name = name,
		owner = def.owner,
		order = def.order or "",
		on_die = def.on_die,
		jump_height = def.jump_height or 6,
		jump_chance = def.jump_chance or 0,
		rotate = def.rotate or 0, -- 0=front, 1.5=side, 3.0=back, 4.5=side2
		lifetimer = def.lifetimer or 180,
		hp_min = def.hp_min or 9,
		hp_max = def.hp_max or 90,
		physical = true,
		collisionbox = def.collisionbox,
		visual = def.visual,
		visual_size = def.visual_size or {x=1, y=1},
		mesh = def.mesh,
		textures = def.textures,
		makes_footstep_sound = def.makes_footstep_sound or true,
		view_range = def.view_range or 5,
		walk_velocity = def.walk_velocity or 1,
		run_velocity = def.run_velocity or 2,
		damage = def.damage,
		light_damage = def.light_damage,
		water_damage = def.water_damage,
		lava_damage = def.lava_damage,
		fall_damage = def.fall_damage or 1,
		fall_speed = def.fall_speed or -10, -- must be lower than -2
		drops = def.drops or {},
		armor = def.armor,
		drawtype = def.drawtype,
		on_rightclick = def.on_rightclick,
		type = def.type,
		fly = def.fly,
		fly_in = def.fly_in or "air",
		attack_type = def.attack_type,
		arrow = def.arrow,-- or "esmobs:bonebullet",
		velocity = def.velocity or  3,
		bombtimer = def.bombtimer or 0,
		shoot_interval = def.shoot_interval,
		sounds = def.sounds or {},
		animation = def.animation,
		follow = def.follow or "",
		team_player = def.team_player or {},
		jump = def.jump or true,
		walk_chance = def.walk_chance or 50,
		attacks_monsters = def.attacks_monsters--[[or false]],
		group_attack = def.group_attack or true,
		--fov = def.fov or 120,
		passive = def.passive or false,
		recovery_time = def.recovery_time or 0.5,
		knock_back = def.knock_back or 3,
		blood_amount = def.blood_amount or 15,
		blood_texture = def.blood_texture or "mobs_blood.png",
		shoot_offset = def.shoot_offset or 0,
		floats = def.floats or 1, -- floats in water by default
		replace_rate = def.replace_rate,
		replace_what = def.replace_what,
		replace_with = def.replace_with,
		replace_offset = def.replace_offset or 0,
		timer = 0,
		env_damage_timer = 0, -- only if state = "attack"
		attack = {player=nil, dist=nil},
		state = "stand",
		tamed = false,
		pause_timer = 0,
		horny = false,
		hornytimer = 0,
		child = false,
		gotten = false,
		health = 0,
		reach = def.reach or 3,
		htimer = 0,
		child_texture = def.child_texture,
		docile_by_day = def.docile_by_day or false,
		time_of_day = 0.5,
		fear_height = def.fear_height or 0,

		get_staticdata = function(self)

		-- remove mob when out of range unless tamed
		if bp.remove
		and self.remove_ok
		and not self.tamed then
			--print ("REMOVED", self.remove_ok, self.name)
			self.object:remove()
			return nil
		end

		self.remove_ok = true
		self.attack = nil
		self.following = nil
		self.state = "stand"

		local tmp = {}

		for _,stat in pairs(self) do
			local t = type(stat)
			if  t ~= 'function'
			and t ~= 'nil'
			and t ~= 'userdata' then
				tmp[_] = self[_]
			end
		end
		-- print('===== '..self.name..'\n'.. dump(tmp)..'\n=====\n')
		return minetest.serialize(tmp)
		end,

		do_attack = function(self, player, dist)
			if self.state ~= "attack" then
					if math.random(0,100) < 90  and self.sounds.war_cry then
						minetest.sound_play(self.sounds.war_cry,{object = self.object})
					end
				self.state = "attack"
				self.attack.player = player
				self.attack.dist = dist
			end
		end,

		set_velocity = function(self, v)
			if not v then v = 0 end
			if def.drawtype and def.drawtype == "side" then self.rotate = 1.5 end
			local yaw = self.object:getyaw() + self.rotate
			local x = math.sin(yaw) * -v
			local z = math.cos(yaw) * v
			self.object:setvelocity({x=x, y=self.object:getvelocity().y, z=z})
		end,

		get_velocity = function(self)
			local v = self.object:getvelocity()
			return (v.x^2 + v.z^2)^(0.5)
		end,

		--ANIMATIONS
		set_animation = function(self, type)
			if not self.animation then
				return
			end
			if not self.animation.current then
				self.animation.current = ""
			end
			if type == "stand" and self.animation.current ~= "stand" then
				if self.animation.stand_start and self.animation.stand_end and self.animation.speed_normal then
					self.object:set_animation({x=self.animation.stand_start,
						y=self.animation.stand_end},self.animation.speed_normal, 0)
					self.animation.current = "stand"
				end
			elseif type == "walk" and self.animation.current ~= "walk"  then
				if self.animation.walk_start and self.animation.walk_end and self.animation.speed_normal then
					self.object:set_animation({x=self.animation.walk_start,y=self.animation.walk_end},
						self.animation.speed_normal, 0)
					self.animation.current = "walk"
				end
			elseif type == "run" and self.animation.current ~= "run"  then
				if self.animation.run_start and self.animation.run_end and self.animation.speed_run then
					self.object:set_animation({x=self.animation.run_start,y=self.animation.run_end},
						self.animation.speed_run, 0)
					self.animation.current = "run"
				end
			elseif type == "punch" and self.animation.current ~= "punch"  then
				if self.animation.punch_start and self.animation.punch_end and self.animation.speed_normal then
					self.object:set_animation({x=self.animation.punch_start,y=self.animation.punch_end},
						self.animation.speed_normal, 0)
					self.animation.current = "punch"
				end
			--THE HURT
			elseif type == "hurt" and self.animation.current ~= "hurt"  then
				self.animation.hurtdur = .5
				if
					self.animation.hurt_start
					and self.animation.hurt_end
					and self.animation.speed_normal
				then
					self.object:set_animation(
						{x=self.animation.hurt_start,y=self.animation.hurt_end},
						self.animation.speed_normal, 0
					)
					self.animation.current = "hurt"
					self.animation.hurtdur = (self.animation.hurt_end - self.animation.hurt_start)/self.animation.speed_normal - 1
				end
			--THE DEATH
			elseif type == "death" and self.animation.current ~= "death"  then
				self.animation.deathdur = 1
				if
					self.animation.death_start
					and self.animation.death_end
					and self.animation.speed_normal
				then
					self.object:set_animation(
						{x=self.animation.death_start,y=self.animation.death_end},
						self.animation.speed_normal, 0
					)
					self.animation.current = "death"
					self.animation.deathdur = (self.animation.death_end - self.animation.death_start)/self.animation.speed_normal - .5
				end
			elseif type == "shoot" and self.animation.current ~= "shoot" then
				if
					self.animation.shoot_start
					and self.animation.shoot_end
					and self.animation.speed_normal
				then
					self.object:set_animation(
						{x=self.animation.shoot_start,y=self.animation.shoot_end},
						self.animation.speed_normal, 0
					)
					self.animation.shootdur = (self.animation.shoot_end - self.animation.shoot_start)/self.animation.speed_normal - .5
					self.animation.current = "shoot"
				end
			elseif type == "fly" and self.animation.current ~= "fly" then
				if
					self.animation.fly_start
					and self.animation.fly_end
					and self.animation.speed_normal
				then
					self.object:set_animation(
						{x=self.animation.fly_start,y=self.animation.fly_end},
						self.animation.speed_normal, 0
					)
					self.animation.current = "fly"
				end
			end
		end,

		--STEP
		on_step = function(self, dtime)

			local yaw = 0

			-- RIDEABLE PIGGIES
			if self.name == "esmobs:pig" and self.saddle == "yes" and self.driver then
				local item = self.driver:get_wielded_item()
				if item:get_name() == "esmobs:carrotstick" then
					local yaw = self.driver:get_look_yaw() - math.pi / 2
					local velo = self.object:getvelocity()
					local v = 1.5
					if math.abs(velo.x) + math.abs(velo.z) < .6 then velo.y = 5 end
					self.state = "walk"
					self:set_animation("walk")
					self.object:setyaw(yaw)
					self.object:setvelocity({x = -math.sin(yaw) * v, y = velo.y, z = math.cos(yaw) * v})

					local inv = self.driver:get_inventory()
					local stack = inv:get_stack("main", self.driver:get_wield_index())
					stack:add_wear(100)
					if stack:get_wear() > 65400 then
						stack = {name = "fishing:pole", count = 1}
					end
					inv:set_stack("main", self.driver:get_wield_index(), stack)
					return
				end
			end

			if self.type == "monster" and peaceful_only then
				self.object:remove()
				return
			end

			-- if lifetimer run out and not npc, tamed or attacking then remove mob
			if self.type ~= "npc" and not self.tamed then
				self.lifetimer = self.lifetimer - dtime
				if self.lifetimer <= 0 and self.state ~= "attack" then
					for _,obj in ipairs(minetest.get_objects_inside_radius(self.object:getpos(), 10)) do
						if obj:is_player() then
							minetest.log("action","lifetimer expired, removed mob "..self.name)
							self.object:remove()
							return
						end
					end
				end
			end

			-- check for mob drop/replace (used for chicken egg and sheep eating grass/wheat)
			if self.replace_rate
			and math.random(1,self.replace_rate) == 1
			and self.child == false then
				local pos = self.object:getpos()
				pos.y = pos.y + self.replace_offset
				if #minetest.find_nodes_in_area(pos,pos,self.replace_what) > 0
				and self.object:getvelocity().y == 0
				and self.replace_what then
				--and self.state == "stand" then
					minetest.set_node(pos, {name = self.replace_with})
				end
			end

			-- jump direction (adapted from Carbone mobs), gravity, falling or floating in water
			if self.object:getvelocity().y > 0.1 then
				local yaw = self.object:getyaw() + self.rotate
				local x = math.sin(yaw) * -2
				local z = math.cos(yaw) * 2

				if minetest.get_item_group(minetest.get_node(self.object:getpos()).name, "water") ~= 0 then
					if self.floats == 1 then self.object:setacceleration({x = x, y = 1.5, z = z}) end
				else
					self.object:setacceleration({x = x, y = self.fall_speed, z = z})
				end
			else
				if minetest.get_item_group(minetest.get_node(self.object:getpos()).name, "water") ~= 0 then
					if self.floats == 1 then self.object:setacceleration({x = 0, y = 1.5, z = 0}) end
				else
					self.object:setacceleration({x = 0, y = self.fall_speed, z = 0})
				end
			end

			-- fall damage
			if self.fall_damage == 1 and self.object:getvelocity().y == 0 then
				local d = self.old_y - self.object:getpos().y
				if d > 5 then
					self.object:set_hp(self.object:get_hp() - math.floor(d - 5))
					check_for_death(self)
				end
				self.old_y = self.object:getpos().y
			end

			-- knockback timer
			if self.pause_timer > 0 then
				self.pause_timer = self.pause_timer - dtime
				if self.pause_timer < 1 then
					self.pause_timer = 0
				end
				return
			end

			-- attack timer
			self.timer = self.timer + dtime
			if self.state ~= "attack" then
				if self.timer < 1 then
					return
				end
				self.timer = 0
			end

			if self.sounds.random and math.random(1, 100) <= 1 then
				minetest.sound_play(self.sounds.random, {object = self.object})
			end

			local do_env_damage = function(self)

				local pos = self.object:getpos()
				local n = minetest.get_node(pos)
				local tod = minetest.get_timeofday()
				pos.y = pos.y + (self.collisionbox[2] + self.collisionbox[5]) / 2

				if self.light_damage and self.light_damage ~= 0
				and pos.y > 0
				and (minetest.get_node_light(pos) or 0) > 10 -- direct sunlight (was 4)
				and tod > 0.2 and tod < 0.8 then
					self.object:set_hp(self.object:get_hp()-self.light_damage)
					effect(pos, 5, "tnt_smoke.png")
				end

				if self.water_damage and self.water_damage ~= 0
				and minetest.get_item_group(n.name, "water") ~= 0 then
					self.object:set_hp(self.object:get_hp()-self.water_damage)
					effect(pos, 5, "bubble.png")
				end

				if self.lava_damage and self.lava_damage ~= 0
				and minetest.get_item_group(n.name, "lava") ~= 0 then
					self.object:set_hp(self.object:get_hp()-self.lava_damage)
					effect(pos, 5, "fire_basic_flame.png")
				end

				check_for_death(self)
			end

			local do_jump = function(self)
				local pos = self.object:getpos()
				pos.y = pos.y - (-self.collisionbox[2] + self.collisionbox[5])
				local nod = minetest.get_node(pos)
				if not nod or not minetest.registered_nodes[nod.name]
				or minetest.registered_nodes[nod.name].walkable == false then return end

				if self.direction then
					local nod = minetest.get_node_or_nil({x=pos.x + self.direction.x,y=pos.y+1,z=pos.z + self.direction.z})
					if nod and nod.name and (nod.name ~= "air"  or self.walk_chance == 0) then
						local def = minetest.registered_items[nod.name]
						if (def and def.walkable and not nod.name:find("fence")) or self.walk_chance == 0 then
							local v = self.object:getvelocity()
							v.y = self.jump_height + 1
							v.x = v.x * 2.2
							v.z = v.z * 2.2
							self.object:setvelocity(v)
							if self.sounds.jump then
								minetest.sound_play(self.sounds.jump, {object = self.object})
							end
						end
					end
				end
			end

			-- environmental damage timer
			self.env_damage_timer = self.env_damage_timer + dtime
			if self.state == "attack" and self.env_damage_timer > 1 then
				self.env_damage_timer = 0
				do_env_damage(self)
			elseif self.state ~= "attack" then
				do_env_damage(self)
			end

			-- find someone to attack
			if self.type == "monster" and damage_enabled and self.state ~= "attack" then

				local s = self.object:getpos()
				local p, sp, dist
				local player = nil
				local type = nil
				local obj = nil
				local min_dist = self.view_range + 1
				local min_player = nil

				for _,oir in ipairs(minetest.get_objects_inside_radius(s,self.view_range)) do

					if oir:is_player() then
						player = oir
						type = "player"
					else
						obj = oir:get_luaentity()
						if obj then
							player = obj.object
							type = obj.type
						end
					end

					if type == "player" or type == "npc" then
						s = self.object:getpos()
						p = player:getpos()
						sp = s
						p.y = p.y + 1
						sp.y = sp.y + 1		-- aim higher to make looking up hills more realistic
						dist = ((p.x-s.x)^2 + (p.y-s.y)^2 + (p.z-s.z)^2)^0.5
						if dist < self.view_range then -- and self.in_fov(self,p) then
							-- choose closest player to attack
							if minetest.line_of_sight(sp,p,2) == true
							and dist < min_dist then
								min_dist = dist
								min_player = player
							end
						end
					end
				end
				-- attack player
				if min_player then
					self.do_attack(self, min_player, min_dist)
				end
			end

			-- npc, find closest monster to attack
			local min_dist = self.view_range + 1
			local min_player = nil

			if self.type == "npc" and self.attacks_monsters and self.state ~= "attack" then
				local s = self.object:getpos()	----?
				local obj = nil					----?seemed to fix error
				for _, oir in pairs(minetest.get_objects_inside_radius(s,self.view_range)) do
					obj = oir:get_luaentity()
					if obj and obj.type == "monster" then
						-- attack monster
						local p = obj.object:getpos()   ---?
						local dist = ((p.x-s.x)^2 + (p.y-s.y)^2 + (p.z-s.z)^2)^0.5		---?
						if dist < min_dist then
							min_dist = dist
							min_player = obj.object
						end
					end
				end
				if min_player then
					self.do_attack(self, min_player, min_dist)
				end
			end

			-- horny animal can mate for 40 seconds, afterwards horny animal cannot mate again for 200 seconds
			if self.horny == true and self.hornytimer < 240 and self.child == false then
				self.hornytimer = self.hornytimer + 1
				if self.hornytimer >= 240 then
					self.hornytimer = 0
					self.horny = false
				end
			end

			-- if animal is child take 240 seconds before growing into adult
			if self.child == true then
				self.hornytimer = self.hornytimer + 1
				if self.hornytimer > 240 then
					self.child = false
					self.hornytimer = 0
					self.object:set_properties({
						textures = self.base_texture,
						mesh = self.base_mesh,
						visual_size = {x=self.visual_size.x,y=self.visual_size.y},
						collisionbox = self.collisionbox,
					})
				end
			end

			-- if animal is horny, find another same animal who is horny and mate
			if self.horny == true and self.hornytimer <= 40 then
				local pos = self.object:getpos() ; pos.y = pos.y + 1
				effect(pos, 4, "heart.png") ; pos.y = pos.y - 1
				local ents = minetest.get_objects_inside_radius(pos, self.view_range)
				local num = 0
				local ent = nil
				for i,obj in ipairs(ents) do
					ent = obj:get_luaentity()
					if ent and ent.name == self.name and ent.horny == true and ent.hornytimer <= 40 then num = num + 1 end
					if num > 1 then
						self.hornytimer = 41
						ent.hornytimer = 41
						minetest.after(7, function(dtime)
							local mob = minetest.add_entity(pos, self.name)
							local ent2 = mob:get_luaentity()
							local textures = self.base_texture
							if def.child_texture then
								textures = def.child_texture[1]
							end
							mob:set_properties({
								textures = textures,
								visual_size = {x=self.visual_size.x/2,y=self.visual_size.y/2},
								collisionbox = {self.collisionbox[1]/2, self.collisionbox[2]/2, self.collisionbox[3]/2,
												self.collisionbox[4]/2, self.collisionbox[5]/2, self.collisionbox[6]/2},
							})
							ent2.child = true
							ent2.tamed = true
							ent2.following = ent -- follow mother
						end)
						num = 0
						break
					end
				end
			end

			-- find player to follow
			if (self.follow ~= "" or self.order == "follow") and not self.following and self.state ~= "attack" then
				local s, p, dist
				for _,player in pairs(minetest.get_connected_players()) do
					s = self.object:getpos()
					p = player:getpos()
					dist = ((p.x-s.x)^2 + (p.y-s.y)^2 + (p.z-s.z)^2)^0.5
					if dist < self.view_range then
						self.following = player
						break
					end
				end
			end

			if self.type == "npc" and self.order == "follow" and self.state ~= "attack" then
				-- npc stop following player if not owner
				if self.following and self.type == "npc" and self.owner and self.owner ~= self.following:get_player_name() then
					self.following = nil
				end
			else
				-- stop following player if not holding specific item
				if self.following and self.following.is_player and self.following:get_wielded_item():get_name() ~= self.follow then
					self.following = nil
				end
			end

			-- follow player or mob
			if self.following then
				local s = self.object:getpos()
				local p

				if self.following.is_player and self.following:is_player() then
					p = self.following:getpos()
				elseif self.following.object then
					p = self.following.object:getpos()
				end

				if p then
					local dist = ((p.x-s.x)^2 + (p.y-s.y)^2 + (p.z-s.z)^2)^0.5
					if dist > self.view_range then
						self.following = nil
					else
						local vec = {x=p.x-s.x, y=p.y-s.y, z=p.z-s.z}
						local yaw = (math.atan(vec.z/vec.x)+math.pi/2) + self.rotate
						if p.x > s.x then
							yaw = yaw+math.pi
						end
						self.object:setyaw(yaw)

						-- anyone but standing npc's can move along
						if dist > 2 and self.order ~= "stand" then
							if (self.jump and self.get_velocity(self) <= 0.5 and self.object:getvelocity().y == 0)
							or (self.object:getvelocity().y == 0 and self.jump_chance > 0) then
								self.direction = {x = math.sin(yaw)*-1, y = -20, z = math.cos(yaw)}
								do_jump(self)
							end
							self.set_velocity(self, self.walk_velocity)
							if self.walk_chance ~= 0 then
								self:set_animation("walk")
							end
						else
							self.set_velocity(self, 0)
							self:set_animation("stand")
						end
						return
					end
				end
			end

			if self.state == "stand" then
				-- randomly turn
				if math.random(1, 4) == 1 then
					-- if there is a player nearby look at them
					local lp = nil
					local s = self.object:getpos()

					if self.type == "npc" then
						local o = minetest.get_objects_inside_radius(self.object:getpos(), 3)

						local yaw = 0
						for _,o in ipairs(o) do
							if o:is_player() then
								lp = o:getpos()
								break
							end
						end
					end

					if lp ~= nil then
						local vec = {x=lp.x-s.x, y=lp.y-s.y, z=lp.z-s.z}
						yaw = (math.atan(vec.z/vec.x)+math.pi/2) + self.rotate
						if lp.x > s.x then
							yaw = yaw+math.pi
						end
					else
						yaw = self.object:getyaw()+((math.random(0,360)-180)/180*math.pi)
					end
					self.object:setyaw(yaw)
				end

				self.set_velocity(self, 0)
				self.set_animation(self, "stand")

				-- npc's ordered to stand stay standing
				if self.type == "npc" and self.order == "stand" then
					self.set_velocity(self, 0)
					self.state = "stand"
					self:set_animation("stand")
				else
					if self.walk_chance ~= 0 and math.random(1, 100) <= self.walk_chance then
						self.set_velocity(self, self.walk_velocity)
						self.state = "walk"
						self.set_animation(self, "walk")
					end

					-- jumping mobs only
					if self.jump_chance ~= 0 and math.random(1, 100) <= self.jump_chance then
						self.direction = {x=0, y=0, z=0}
						do_jump(self)
						self.set_velocity(self, self.walk_velocity)
					end
				end

			elseif self.state == "walk" then
				local s = self.object:getpos()
				-- if there is water nearby, try to avoid it
				local lp = minetest.find_node_near(s, 2, {"group:water"})

				if lp ~= nil then
					local vec = {x=lp.x-s.x, y=lp.y-s.y, z=lp.z-s.z}
					yaw = math.atan(vec.z/vec.x) + 3*math.pi / 2 + self.rotate
					if lp.x > s.x then
						yaw = yaw+math.pi
					end
					self.object:setyaw(yaw)

				-- no water near, so randomly turn
				elseif math.random(1, 100) <= 30 then
					self.object:setyaw(self.object:getyaw()+((math.random(0,360)-180)/180*math.pi))
				end
				if self.jump and self.get_velocity(self) <= 0.5 and self.object:getvelocity().y == 0 then
					self.direction = {x = math.sin(yaw)*-1, y = -20, z = math.cos(yaw)}
					do_jump(self)
				end

				self:set_animation("walk")
				self.set_velocity(self, self.walk_velocity)
				if math.random(1, 100) <= 30 then
					self.set_velocity(self, 0)
					self.state = "stand"
					self:set_animation("stand")
				end

			-- exploding mobs
			elseif self.state == "attack" and self.attack_type == "explode" then
				if not self.attack.player or not self.attack.player:is_player() then
					self.state = "stand"
					self:set_animation("stand")
					self.timer = self.timer+dtime
					--self.timer = 0
					self.blinktimer = 0
					self.bombtimer = self.bombtimer+dtime
					return
				end
				local s = self.object:getpos()
				local p = self.attack.player:getpos()
				local dist = ((p.x - s.x) ^ 2 + (p.y - s.y) ^ 2 + (p.z - s.z) ^ 2) ^ 0.5
				if dist > self.view_range or self.attack.player:get_hp() <= 0 then
					self.state = "stand"
					self.v_start = false
					self.set_velocity(self, 0)
					self.timer = 0
					self.blinktimer = 0
					self.attack = {player = nil, dist = nil}
					self:set_animation("stand")
					return
				elseif dist < 2 and self.attack_type == "explode" and self.bombmode ~= "armed" then
					if self.sounds and self.sounds.approach then
						minetest.sound_play(self.sounds.approach, {object = self.object})
					end
					self.bombmode = "armed"
					self.bombtimer = 0
					self:set_animation("walk")
					self.attack.dist = dist
				end

				local vec = {x = p.x -s.x, y = p.y -s.y, z = p.z -s.z}
				local yaw = math.atan(vec.z/vec.x)+math.pi/2 + self.rotate
				if p.x > s.x then
					yaw = yaw+math.pi
				end
				self.object:setyaw(yaw)
				if self.attack.dist > 3 then
					if not self.v_start then
						self.v_start = true
						self.set_velocity(self, self.run_velocity)
						self.timer = 0
						self.blinktimer = 0
					else
					     self.timer = 0
						 self.blinktimer = 0
						if self.get_velocity(self) <= 0.5 and self.object:getvelocity().y == 0 then
							local v = self.object:getvelocity()
							v.y = 5
							self.object:setvelocity(v)
						end
						self.set_velocity(self, self.run_velocity)
					end
					self:set_animation("run")
				else
					self.set_velocity(self, 0)
					self.timer = self.timer + dtime
					self.blinktimer = (self.blinktimer or 0) + dtime
					if self.blinktimer > 0.2 then
						self.blinktimer = 0
						if self.blinkstatus then
							self.object:settexturemod("")
						else
							self.object:settexturemod("^[brighten")
						end
						self.blinkstatus = not self.blinkstatus
					end
					if self.timer > 3 then
						local pos = vector.round(self.object:getpos())
						entity_physics(pos, 3) -- hurt player/mobs caught in blast area
						if minetest.find_node_near(pos, 1, {"group:water"})
						or minetest.find_node_near(pos, 1 , {"group:immortal"}) or minetest.is_protected(pos, "") then
							self.object:remove()
							if self.sounds.explode ~= "" then
								minetest.sound_play(self.sounds.explode, {pos = pos, gain = 1.0, max_hear_distance = 16})
							end
							pos.y = pos.y + 1
							effect(pos, 15, "tnt_smoke.png", 5)
							return
						end
						self.object:remove()
						--bp:explosion(pos, 2, 0, 1, "tnt_explode", self.sounds.explode)  --removed fugly
						--bp:explode(pos, 2, 0, 1, "tnt_explode", self.sounds.explode)
						minetest.sound_play("tnt_explode", {pos=pos, gain=1.5, max_hear_distance=2*64})
					end
				end

			--dogfight attack
			elseif self.state == "attack" and self.attack_type == "dogfight" then
				if not self.attack.player or not self.attack.player:getpos() then
					print("stop attacking")
					self.state = "stand"
					self:set_animation("stand")
					return
				end
				local s = self.object:getpos()
				local p = self.attack.player:getpos()
				local dist = ((p.x-s.x)^2 + (p.y-s.y)^2 + (p.z-s.z)^2)^0.5
				if dist > self.view_range or self.attack.player:get_hp() <= 0 then
					self.state = "stand"
					self.set_velocity(self, 0)
					self.attack = {player=nil, dist=nil}
					self:set_animation("stand")
					return
				else
					self.attack.dist = dist
				end

				local vec = {x=p.x-s.x, y=p.y-s.y, z=p.z-s.z}
				local yaw = (math.atan(vec.z/vec.x)+math.pi/2) + self.rotate
				if p.x > s.x then
					yaw = yaw+math.pi
				end
				self.object:setyaw(yaw)
				-- attack distance is 2 + half of mob width so the bigger mobs can attack (like slimes)
				if self.attack.dist > ((-self.collisionbox[1]+self.collisionbox[4])/2)+2 then
					-- jump attack
					if (self.jump and self.get_velocity(self) <= 0.5 and self.object:getvelocity().y == 0)
					or (self.object:getvelocity().y == 0 and self.jump_chance > 0) then
						self.direction = {x = math.sin(yaw)*-1, y = -20, z = math.cos(yaw)}
						do_jump(self)
					end
					self.set_velocity(self, self.run_velocity)
					self:set_animation("run")
				else
					self.set_velocity(self, 0)
					self:set_animation("punch")
					if self.timer > 1 then
						self.timer = 0
						local p2 = p
						local s2 = s
						p2.y = p2.y + 1.5
						s2.y = s2.y + 1.5
						if minetest.line_of_sight(p2,s2) == true then
							if self.sounds.attack then
								minetest.sound_play(self.sounds.attack, {object = self.object})
							end
							self.attack.player:punch(self.object, 1.0,  {
								full_punch_interval=1.0,
								damage_groups = {fleshy=self.damage}
							}, vec)
							if self.attack.player:get_hp() <= 0 then
								self.state = "stand"
								self:set_animation("stand")
							end
						end
					end
				end

		--FROM MCMOBS API  HACK WORKS
		elseif self.state == "attack" and self.attack_type == "shoot" then
			if not self.attack.player or not self.attack.player:is_player() then
				self.state = "stand"
				self:set_animation("stand")
				self.attack = {player=nil, dist=nil}
				return
			end
			local s = self.object:getpos()
			local p = self.attack.player:getpos()
			local dist = ((p.x-s.x)^2 + (p.y-s.y)^2 + (p.z-s.z)^2)^0.5
			if dist > self.view_range or self.attack.player:get_hp() <= 0 then
				self.state = "stand"
				self.v_start = false
				self.set_velocity(self, 0)
				self.attack = {player=nil, dist=nil}
				self:set_animation("stand")
				return
			else
				self.attack.dist = dist
				self.shoot_interval = (dist + self.view_range) / self.view_range
			end

			local vec = {x=p.x-s.x, y=p.y-s.y, z=p.z-s.z}
			local yaw = math.atan(vec.z/vec.x)+math.pi/2
			if self.drawtype == "side" then
				yaw = yaw+(math.pi/2)
			end
			if p.x > s.x then
				yaw = yaw+math.pi
			end
			self.object:setyaw(yaw)
			if self.attack.dist < 4 then
				self.set_velocity(self, -self.run_velocity)
			elseif self.attack.dist > 8 then
				self.set_velocity(self, self.run_velocity)
			else
				self.set_velocity(self, 0)
			end
			if self.timer > self.shoot_interval and math.random(1, 100) <= 60 then
				self.timer = 0

				self:set_animation("shoot")
				--minetest.after(self.animation.shootdur, function()
				self:set_animation("walk")
				--end)
				if self.sounds and self.sounds.attack then
					minetest.sound_play(self.sounds.attack, {object = self.object})
				end

				local p = self.object:getpos()
				p.y = p.y + (self.collisionbox[2]+self.collisionbox[5])/2
				local obj = minetest.add_entity(p, self.arrow)
				local amount = (vec.x^2+vec.y^2+vec.z^2)^0.5
				local v = 15
				vec.y = vec.y+1
				vec.x = vec.x*v/amount
				vec.y = vec.y*v/amount
				vec.z = vec.z*v/amount
				obj:setvelocity(vec)
			end
		end

	end,

		--BEGIN ON_ACTIVATE
		on_activate = function(self, staticdata, dtime_s)
			local pos = self.object:getpos()
			self.object:set_hp( math.random(self.hp_min, self.hp_max) ) -- set HP
			self.oldhp = self.object:get_hp(self)
			self.object:set_armor_groups({fleshy=self.armor})
			self.object:setacceleration({x=0, y= self.fall_speed, z=0})
			self.state = "stand"
			self.object:setvelocity({x=0, y=self.object:getvelocity().y, z=0}) ; self.old_y = self.object:getpos().y
			self.object:setyaw(math.random(1, 360)/180*math.pi)
			if self.type == "monster" and peaceful_only then
				self.object:remove()
			end

			if staticdata then
				local tmp = minetest.deserialize(staticdata)
				if tmp then
					if tmp.lifetimer then
						self.lifetimer = tmp.lifetimer
					end
					if tmp.tamed then
						self.tamed = tmp.tamed
					end
					if tmp.gotten then
						self.gotten = tmp.gotten
					end
					if tmp.child then
						self.child = tmp.child
					end
					if tmp.horny then
						self.horny = tmp.horny
					end
					if tmp.hornytimer then
						self.hornytimer = tmp.hornytimer
					end
					if tmp.textures then
						self.textures = tmp.textures
					end
					if tmp.mesh then
						self.mesh = tmp.mesh
					end
					if tmp.base_texture then
						self.base_texture = tmp.base_texture
					end
					if tmp.base_mesh then
						self.base_mesh = tmp.base_mesh
					end
				end
			end
			-- quick fix for dog so it doesn't revert back to wolf
			if self.type == "monster" and self.tamed == true then
				self.type = "npc"
			end

		end,

		get_staticdata = function(self)
			-- select random texture, set model
			if not self.base_texture then
				self.base_texture = def.textures[math.random(1,#def.textures)]
				self.base_mesh = def.mesh
			end
			-- set texture, model and size
			local textures = self.base_texture
			local mesh = self.base_mesh
			local vis_size = self.visual_size
			local colbox = self.collisionbox
			-- specific texture if gotten
			if self.gotten == true and def.gotten_texture then
				textures = def.gotten_texture
			end
			-- specific mesh if gotten
			if self.gotten == true and def.gotten_mesh then
				mesh = def.gotten_mesh
			end
			-- if object is child then set half size
			if self.child == true then
				vis_size = {x=self.visual_size.x/2,y=self.visual_size.y/2}
				if def.child_texture then
					textures = def.child_texture[1]
				end
				colbox = {self.collisionbox[1]/2, self.collisionbox[2]/2, self.collisionbox[3]/2,
						self.collisionbox[4]/2, self.collisionbox[5]/2, self.collisionbox[6]/2}
			end
			-- remember settings
			local tmp = {
				lifetimer = self.lifetimer,
				tamed = self.tamed,
				gotten = self.gotten,
				child = self.child,
				horny = self.horny,
				hornytimer = self.hornytimer,
				mesh = mesh,
				textures = textures,
				visual_size = vis_size,
				base_texture = self.base_texture,
				collisionbox = colbox,
			}
			self.object:set_properties(tmp)
			return minetest.serialize(tmp)
		end,

		--BEGIN ON PUNCH CODE
					on_punch = function(self, hitter, tflp, tool_capabilities, dir)

						process_weapon(hitter,tflp,tool_capabilities)
						check_for_death(self)

						--blood_particles
						local pos = self.object:getpos()
						pos.y = pos.y + (-self.collisionbox[2] + self.collisionbox[5]) / 2
						if self.blood_amount > 0 and pos and enable_blood == true then
							effect(pos, self.blood_amount, self.blood_texture)
						end

						-- knock back effect, adapted from blockmen's pyramids mod
						-- https://github.com/BlockMen/pyramids
						local kb = self.knock_back
						local r = self.recovery_time
						local ykb = 2
						local v = self.object:getvelocity()
						if tflp < tool_capabilities.full_punch_interval then
							kb = kb * ( tflp / tool_capabilities.full_punch_interval )
							r = r * ( tflp / tool_capabilities.full_punch_interval )
						end
						if v.y ~= 0 then ykb = 0 end
						self.object:setvelocity({x=dir.x*kb,y=ykb,z=dir.z*kb})
						self.pause_timer = r

						-- attack puncher and call other mobs for help
						if self.passive == false and not self.tamed then
							if self.state ~= "attack" then
								self.do_attack(self,hitter,1)
							end
							-- alert others to the attack
							local obj = nil
							for _, oir in pairs(minetest.get_objects_inside_radius(hitter:getpos(),5)) do
								obj = oir:get_luaentity()
								if obj then
									if obj.group_attack == true and obj.state ~= "attack" then
										obj.do_attack(obj,hitter,1)
									end
								end
							end
						end

			--deathanimation WIP
			--	on_punch = function(self, hitter)
				-- death happens at 20 hp so we can play the death animation:
					if self.object:get_hp() <= 20 then
						local pos = self.object:getpos()
						minetest.add_particlespawner({
							amount = 20,
							time = .2,
							minpos = {x=pos.x-1, y=pos.y-.5, z=pos.z-1},
							maxpos = {x=pos.x+1, y=pos.y+.5, z=pos.z+1},
							minvel = {x=0, y=.3, z=0},
							maxvel = {x=0, y=2, z=0},
							minacc = {x=-.2, y=-.2, z=-.2},
							maxacc = {x=.2, y=.2, z=.2},
							minexptime = 1,
							maxexptime = 5,
							minsize = 1,
							maxsize = 1,
							collisiondetection = false,
							vertical = false,
							texture = "bettertnt_smoke.png",
						})
						--self:set_animation("death")
						--self.object:set_hp(1000)
						if self.name == "esmobs:pig" and self.driver then
							local name = self.driver:get_player_name()
							self.driver:set_detach()
							default.player_attached[name] = false
							default.player_set_animation(self.driver, "stand" , 30)
							self.driver = nil
						end
						--minetest.after(self.animation.deathdur, function()
							--self.object:remove()
						--end)
						if self.sounds and self.sounds.death then
							minetest.sound_play(self.sounds.death, {object = self.object})
							--self:set_animation("death")
						end
						pos.y = pos.y + 0.5
						local obj = nil
					else
						if self.sounds and self.sounds.hurt then
							minetest.sound_play(self.sounds.hurt, {object = self.object})
						end
						self:set_animation("hurt")
						minetest.after(self.animation.hurtdur, function()
							self:set_animation("walk")
						end)
					end
			--	end
			--deathanimation WIP

			--END ORIG ON PUNCH CODE

			--ADDING LAGS MOBS BONES HERE
			    --on_punch = function(self, hitter)
				    --mob killed
				 if self.object:get_hp() <= 0 then

				    if hitter and hitter:is_player() and hitter:get_inventory() then
				       for _,drop in ipairs(self.drops) do

			--THIS CODE GIVES YOU THE DROP INSTANT ON DEATH
			--removed to place drops in bones.
			--              	 if math.random(1, drop.chance) == 1 then
			--                  	hitter:get_inventory():add_item("main", ItemStack(drop.name.." "..math.random(drop.min, drop.max)))
			--               	end

				       end

					    --mob bones, like player bones added by Andrei modified by maikerumine
					 if math.random(1, 1) == 1  then
						local pos = self.object:getpos()
						local nn = minetest.get_node(pos).name
						local spaceforbones=nil
						if nn=="air" or nn=="default:water_flowing" or nn=="default:water_source" or nn=="default:lava_source" or nn=="default:lava_flowing" or nn=="default:snow" then
						    spaceforbones=pos
								--minetest.add_node(spaceforbones, {name="bones:bones"} )
								minetest.add_node(spaceforbones, {name="esmobs:bones"} )
						    local meta = minetest.get_meta(spaceforbones)
						    local inv = meta:get_inventory()
						    inv:set_size("main", 8*4)
							--DROPS FILL BONE
						    for _,drop in ipairs(self.drops) do
							if math.random(1, drop.chance) == 1 then
							    local stack = ItemStack(drop.name.." "..math.random(drop.min, drop.max))
							    if inv:room_for_item("main", stack) then
								inv:add_item("main", stack)
							    end
							end
						    end

						    meta:set_string("formspec", "size[8,9;]"..
							    "list[current_name;main;0,0;8,4;]"..
							    "list[current_player;main;0,5;8,4;]")
			--BEGIN TIME STRING
							local time = os.date("*t");--this keeps the bones meta to turn old

			--CHOOSE OPTION BELOW:
							meta:set_string("infotext", self.name.." was slain".." at ".. time.year .. "/".. time.month .. "/" .. time.day .. ", " ..time.hour.. ":".. time.min .." by: ("..hitter:get_player_name()..")");	--SHOW TIME AT DEATH AND WHO KILLED
			--				meta:set_string("infotext", self.name.."'s fresh bones")	--SHOW NO TIME AT BONE EXPIRE
			--CHOOSE OPTION BELOW:
			--				meta:set_string( "owner", "Extreme Survival Mob R.I.P.")	--SET OWNER FOR TIMER
							meta:set_string("owner")						--SET NO OWNER NO TIMER

						    meta:set_int("bonetime_counter", 0)
						    local timer  = minetest.get_node_timer(spaceforbones)
						    timer:start(10)
						end
					 end
				       minetest.log("action", "Killed mob "..name.." by "..hitter:get_player_name())
				    end
				    self.object:remove()
				    return
				 elseif self.object:get_hp() == 1 or self.object:get_hp() == 1 or self.object:get_hp() == 2 then
				    self.state="run"
				    self:set_animation("death")
				 else
				    self.v_start=true
				    if hitter and hitter:is_player() and hitter:get_wielded_item() then
				       local tool=hitter:get_wielded_item()
				       tool:add_wear(100)
				       hitter:set_wielded_item( tool )
				    end
				 end
			--end,			--use if using original punch code.
				end,

			--END ON PUNCH FULL CODE
				})
			end

			--SPAWNING
			bp.spawning_mobs = {}
			function bp:spawn_specific(name, nodes, neighbors, min_light, max_light, interval, chance, active_object_count, min_height, max_height)
				bp.spawning_mobs[name] = true
				minetest.register_abm({
					nodenames = nodes,
					neighbors = neighbors,
					interval = interval,
					chance = chance,
					action = function(pos, node, _, active_object_count_wider)
						-- do not spawn if too many active in area
						if active_object_count_wider > active_object_count
						or not bp.spawning_mobs[name]
						or not pos then
							return
						end

						-- spawn above node
						pos.y = pos.y + 1
						--pos.x = pos.x + 2  --ADDED TO FIX TUNNEL SPAWN
						--pos.z = pos.z + 2  --ADDED TO FIX TUNNEL SPAWN
						-- mobs cannot spawn inside protected areas if enabled

						if bp.protected == 1 and minetest.is_protected(pos, "") then
							return
						end

						-- check if light and height levels are ok to spawn
						local light = minetest.get_node_light(pos)
						if not light or light > max_light or light < min_light
						or pos.y > max_height or pos.y < min_height then
							return
						end

						-- are we spawning inside a solid node?
						local nod = minetest.get_node_or_nil(pos)
						if not nod or not nod.name or not minetest.registered_nodes[nod.name]
						or minetest.registered_nodes[nod.name].walkable == true then return end
						pos.y = pos.y + 3 --test to see if prevent mineshaft spawn
			--			--pos.y = pos.y + 1--original
						nod = minetest.get_node_or_nil(pos)
						if not nod or not nod.name or not minetest.registered_nodes[nod.name]
						or minetest.registered_nodes[nod.name].walkable == true then return end

						if minetest.setting_getbool("display_mob_spawn") then
							minetest.chat_send_all("[bp] Add "..name.." at "..minetest.pos_to_string(pos))
						end

						-- spawn mob half block higher
						pos.y = pos.y - 0.5
						--pos.x = pos.x - 1  --ADDED TO FIX TUNNEL SPAWN
						--pos.z = pos.z - 1  --ADDED TO FIX TUNNEL SPAWN
						minetest.add_entity(pos, name)
						--print ("Spawned "..name.." at "..minetest.pos_to_string(pos).." on "..node.name.." near "..neighbors[1])
					end
				})
			end

			-- compatibility with older mob registration
			function bp:register_spawn(name, nodes, max_light, min_light, chance, active_object_count, max_height)
				bp:spawn_specific(name, nodes, {"air"}, min_light, max_light, 30, chance, active_object_count, -31000, max_height)
			end

			-- particle effects
			function effect(pos, amount, texture, max_size)
				minetest.add_particlespawner({
					amount = amount,
					time = 0.25,
					minpos = pos,
					maxpos = pos,
					minvel = {x=-0, y=-2, z=-0},
					maxvel = {x=2,  y=2,  z=2},
					minacc = {x=-4, y=-4, z=-4},
					maxacc = {x=4, y=4, z=4},
					minexptime = 0.1,
					maxexptime = 1,
					minsize = 0.5,
					maxsize = (max_size or 1),
					texture = texture,
				})
			end
			-- check if within map limits (-30911 to 30927)
			function within_limits(pos, radius)

				if  (pos.x - radius) > -30913
				and (pos.x + radius) <  30928
				and (pos.y - radius) > -6001  --hack for esm world
				and (pos.y + radius) <  30928
				and (pos.z - radius) > -30913
				and (pos.z + radius) <  30928 then
					return true -- within limits
				end

				return false -- beyond limits
			end

			--BEGIN DROPS GO TO BONES
			-- on mob death drop items
			function check_for_death(self)
				local hp = self.object:get_hp()
				if hp > 0 then
					if self.sounds.damage ~= nil and hp < self.oldhp then
						minetest.sound_play(self.sounds.damage,{object = self.object})
						self.oldhp = hp
					end
					return
				end

			--USE THIS CODE TO HAVE VISIBLE DROPS AND COMMENT OUT THE MOBS BONES
			--[[
				local pos = self.object:getpos()
				pos.y = pos.y + 1.5 -- drop items half a block higher
				self.object:remove()
				local obj = nil
				for _,drop in ipairs(self.drops) do
					if math.random(1, drop.chance) == 1 then
						obj = minetest.add_item(pos, ItemStack(drop.name.." "..math.random(drop.min, drop.max)))
						if obj then
							obj:setvelocity({x=math.random(-1,1), y=5, z=math.random(-1,1)})
						end
					end
				end

			]]

			--MOBS BONES ON DIE--COMMENTED OUT DUE TO SERVER GRIEF.  MANY BONES
				 if self.object:get_hp() <= 0 then
			 --[[                       local pos = self.object:getpos()
						local nn = minetest.get_node(pos).name
						local spaceforbones=nil
						if nn=="air" or nn=="default:water_flowing" or nn=="default:water_source" or nn=="default:lava_source" or nn=="default:lava_flowing" then
						    spaceforbones=pos
								minetest.add_node(spaceforbones, {name="bones:bones"} )
						    local meta = minetest.get_meta(spaceforbones)
						    local inv = meta:get_inventory()
						    inv:set_size("main", 8*4)
						    for _,drop in ipairs(self.drops) do
							if math.random(1, drop.chance) == 1 then
							    local stack = ItemStack(drop.name.." "..math.random(drop.min, drop.max))
							    if inv:room_for_item("main", stack) then
								inv:add_item("main", stack)
							    end
							end
						    end
						    meta:set_string("formspec", "size[8,9;]"..
							    "list[current_name;main;0,0;8,4;]"..
							    "list[current_player;main;0,5;8,4;]")
							local time = os.date("*t");--this keeps the bones meta to turn old
							meta:set_string("infotext", self.name.." slain".. meta:get_string("owner").." at ".. time.year .. "/".. time.month .. "/" .. time.day .. ", " ..time.hour.. ":".. time.min ..")");		--SHOW TIME AT DEATH
							meta:set_string( "owner", "Extreme Survival Mob R.I.P.")			--SET OWNER FOR TIMER
						    meta:set_int("bonetime_counter", 0)
						    local timer  = minetest.get_node_timer(spaceforbones)
						    timer:start(10)
						end]]
							self.object:remove()
						return
					 end

					 --end	--UNCOMMENT IF RE-ADDING VISIBLE DROPS

				if self.sounds.death ~= nil then
					minetest.sound_play(self.sounds.death,{object = self.object})
				end
				if self.on_die then
					pos.y = pos.y - 0.5
					self.on_die(self, pos)

				end
			end

			-- from TNT mod
			function calc_velocity(pos1, pos2, old_vel, power)
				local vel = vector.direction(pos1, pos2)
				vel = vector.normalize(vel)
				vel = vector.multiply(vel, power)
				local dist = vector.distance(pos1, pos2)
				dist = math.max(dist, 1)
				vel = vector.divide(vel, dist)
				vel = vector.add(vel, old_vel)
				return vel
			end

			-- modified from TNT mod
			function entity_physics(pos, radius)
				radius = radius * 2
				local objs = minetest.get_objects_inside_radius(pos, radius)
				local obj_pos, obj_vel, dist
				for _, obj in pairs(objs) do
					obj_pos = obj:getpos()
					obj_vel = obj:getvelocity()
					dist = math.max(1, vector.distance(pos, obj_pos))
					if obj_vel ~= nil then
						obj:setvelocity(calc_velocity(pos, obj_pos,
								obj_vel, radius * 10))
					end
					local damage = (4 / dist) * radius
					obj:set_hp(obj:get_hp() - damage)
				end
			end

			--OLDARROW  DM SHOOTS
			-- register arrow for shoot attack
			function bp:register_arrow(name, def)
				if not name or not def then return end -- errorcheck
				minetest.register_entity(name, {
					physical = false,
					visual = def.visual,
					textures = def.textures,
					visual_size = def.visual_size,
					velocity = def.velocity,
					hit_player = def.hit_player,
					hit_node = def.hit_node,
					hit_mob = def.hit_mob,
					drop = def.drop or false,
					collisionbox = {0,0,0,0,0,0}, -- remove box around arrows

					on_step = function(self, dtime)
						self.timer = (self.timer or 0) + 1
						if self.timer > 150 then self.object:remove() return end
						local engage = 10 - (self.velocity / 2) -- clear entity before arrow becomes active
						local pos = self.object:getpos()
						local node = minetest.get_node(self.object:getpos()).name
						-- hit node you can walk on
									if self.hit_node then

							local node = node_ok(pos).name

							if minetest.registered_nodes[node].walkable then

								self.hit_node(self, pos, node)

								if self.drop == true then

									pos.y = pos.y + 1

									self.lastpos = (self.lastpos or pos)

									minetest.add_item(self.lastpos, self.object:get_luaentity().name)
								end

								self.object:remove() ; -- print ("hit node")

								return
							end
						end
						if self.hit_player or self.hit_mob then
							for _,player in pairs(minetest.get_objects_inside_radius(pos, 1.5)) do
								-- hit player
								if self.hit_player and self.timer > engage and player:is_player() then
									self.hit_player(self, player)
									self.object:remove()
									return
								end
								-- hit mob
								if self.hit_mob and self.timer > engage and player:get_luaentity().name ~= self.object:get_luaentity().name
								and player:get_luaentity().name ~= "__builtin:item" then
									self.hit_mob(self, player)
									self.object:remove()
									return
								end
							end
							self.lastpos = pos
						end
					end
				})
			end
			--ENDOLDARROW

			--NODE OK
			function node_ok(pos, fallback)

				fallback = fallback or "default:dirt"

				local node = minetest.get_node_or_nil(pos)

				if not node then
					return minetest.registered_nodes[fallback]
				end

				local nodef = minetest.registered_nodes[node.name]

				if nodef then
					return node
				end

				return minetest.registered_nodes[fallback]
			end

			--Brandon Reese code to face pos
			function bp:face_pos(self,pos)
				local s = self.object:getpos()
				local vec = {x=pos.x-s.x, y=pos.y-s.y, z=pos.z-s.z}
				local yaw = math.atan(vec.z/vec.x)+math.pi/2
				if self.drawtype == "side" then
					yaw = yaw+(math.pi/2)
				end
				if pos.x > s.x then
					yaw = yaw+math.pi
				end
				self.object:setyaw(yaw)
				return yaw
			end

			--Reese chat
			local_chat = function(pos,text,radius)
				if radius == nil then
					radius = 25
				end
				if pos ~= nil then
					local oir = minetest.get_objects_inside_radius(pos, radius)
					for _,p in pairs(oir) do
						if p:is_player() then
							minetest.chat_send_player(p:get_player_name(),text)
						end
					end
				end
			end

			--maikeruminefollow
			function bp:team_player(self,pos)
				if tamed == true or
					self.tamed == true then
					self.order = "follow"
				end
			end

			--TODO TWEAK CODE, AS TOOLS WEAR OUT TOO FAST
			function process_weapon(player, time_from_last_punch, tool_capabilities)
			local weapon = player:get_wielded_item()
				if tool_capabilities ~= nil then
					local wear = ( tool_capabilities.full_punch_interval / 85 ) * 65535
					--local wear = ( tool_capabilities.full_punch_interval / 75 ) * 65535  --REF
					weapon:add_wear(wear)
					player:set_wielded_item(weapon)
				end
			end

			-- Spawn Egg
			function bp:register_egg(mob, desc, background, addegg)
			local invimg = background
			if addegg == 1 then
				invimg = invimg.."^mobs_chicken_egg.png"
			end
			minetest.register_craftitem(mob, {
				description = desc,
				inventory_image = invimg,
				on_place = function(itemstack, placer, pointed_thing)
					local pos = pointed_thing.above
					if pointed_thing.above and not minetest.is_protected(pos, placer:get_player_name()) then
						pos.y = pos.y + 0.5
						minetest.add_entity(pos, mob)
						itemstack:take_item()
					end
					return itemstack
				end,
			})
end
