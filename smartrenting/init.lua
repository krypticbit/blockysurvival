smartrenting={user={},rentchar={"smartrenting:panel","smartrenting:panel_able","smartrenting:panel_rented","smartrenting:panel_ending","smartrenting:panel_error"}}
--rentable 0=none, 1=prepared, 2=able for renting, 3=renting by someone, 4=ending renting, 5=1

dofile(minetest.get_modpath("smartrenting") .. "/override_items.lua")

minetest.register_craft({
	output = "smartrenting:panel",
	recipe = {
		{"default:steel_ingot", "default:mese_crystal", "default:steel_ingot"},
		{"default:steel_ingot", "default:chest_locked", "default:steel_ingot"},
		{"default:steel_ingot", "default:sign_wall_steel", "default:steel_ingot"},
	}
})

minetest.register_craft({
	output = "smartrenting:card",
	recipe = {
		{"default:stick", "default:mese_crystal_fragment", "default:stick"},
		{"default:stick", "default:stick", "default:stick"},
	}
})

minetest.register_craft({
	output = "smartrenting:card",
	recipe = {
		{"smartrenting:card"},
	}
})

minetest.register_craft({
	type = "fuel",
	recipe = "smartrenting:card",
	burntime = 3,
})



smartrenting.setchange=function(pos,n,node_only)
	local meta=minetest.get_meta(pos)
	minetest.swap_node(pos,{name=smartrenting.rentchar[n],param2=minetest.get_node(pos).param2})
	if n==5 then n=1 end
	if not node_only then meta:set_int("rentable",n)
		if mesecon then
			if n==3 or n==4 then
				mesecon.receptor_on(pos)
			else
				mesecon.receptor_off(pos)
			end
		end
		local def=minetest.registered_nodes[minetest.get_node(pos).name]
		if n==1 and def and def.renting then
			def.renting(pos,meta:get_string("owner"),meta:get_string("renter"))
		elseif n==1 and def and def.renting_reset then
			def.renting_reset(pos,meta:get_string("owner"),meta:get_string("renter"))
		end
	end
end

smartrenting.setdate=function(meta)
	local d=os.date("*t")
	meta:set_int("sec",d.sec)
	meta:set_int("min",d.min)
	meta:set_int("hour",d.hour)
	meta:set_int("day",d.day)
	meta:set_int("month",d.month)
	meta:set_int("year",d.year)
end

smartrenting.diff=function(e,d)
	local v=61
	if e==1 then -- day
		local t=os.time{hour=d.hour,day=d.day, year=d.year, month=d.month}
		v = os.difftime(os.time(), t) / (24 * 60 * 60)
	elseif e==2 then -- hour
		local t=os.time{min=d.min,hour=d.hour,day=d.day, year=d.year, month=d.month}
		v = os.difftime(os.time(), t) / (60 * 60)
	elseif e==3 then -- min
		local t=os.time{sec=d.sec,min=d.min,hour=d.hour,day=d.day, year=d.year, month=d.month}
		v = os.difftime(os.time(), t) / 60 
	elseif e==4 then -- sec
		local t=os.time{sec=d.sec,min=d.min,hour=d.hour,day=d.day, year=d.year, month=d.month}
		v = os.difftime(os.time(), t)
	end
	return math.floor(v)
end


smartrenting.num=function(a,min,max)
	a=tonumber(a)
	if not a or a<0 then a=0 end
	if min and a<min then a=min end
	if max and a>max then a=max end
	return a
end

smartrenting.fee=function(pos,name)
	local meta=minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local cost=inv:get_stack("pay",1):get_count()
	local stack=inv:get_stack("paying",1):get_name()
	local owner=meta:get_string("owner")

	if inv:get_stack("paying",1):get_count()<cost then
		minetest.chat_send_player(name, "Not enouth to cover the fee")
		return false
	end
	if meta:get_int("keep")~=2 then
		if inv:get_stack("main",28):get_count()>0 then
			minetest.chat_send_player(name, "The owner (" .. owner .. ") need to empty")
			smartrenting.setchange(pos,5)
			return false
		end
		inv:add_item("main", stack .. " " .. cost)
	end
	inv:remove_item("paying",stack .. " " .. cost)
	return true
end

smartrenting.param2dir=function(pos)
	local meta=minetest.get_meta(pos)
	local right=meta:get_int("right")
	local front=meta:get_int("front")
	local left=meta:get_int("left")
	local back=meta:get_int("back")
	local up=meta:get_int("up")
	local down=meta:get_int("down")

	local d={}
	local p=minetest.get_node(pos).param2
	if p==0 then
		d={xp=right,xm=left,zp=front,zm=back}
	elseif p==1 then
		d={xp=front,xm=back,zp=left,zm=right}
	elseif p==3 then
		d={xp=back,xm=front,zp=right,zm=left}	
	else
		d={xp=left,xm=right,zp=back,zm=front}
	end
	d.yp=up
	d.ym=down

	return d
end

smartrenting.test=function(pos)
	local d=smartrenting.param2dir(pos)
	for x=-d.xm,d.xp,1 do
	for y=-d.ym,d.yp,1 do
	for z=-d.zm,d.zp,1 do
		minetest.add_entity({x=pos.x+x,y=pos.y+y,z=pos.z+z}, "smartrenting:point")
	end
	end
	end

end

smartrenting.rent=function(pos,name)
	local d=smartrenting.param2dir(pos)
	local theowner=minetest.get_meta(pos):get_string("owner")
	local pos2
	local nods={}
	for x=-d.xm,d.xp,1 do
	for y=-d.ym,d.yp,1 do
	for z=-d.zm,d.zp,1 do
		pos2={x=pos.x+x,y=pos.y+y,z=pos.z+z}
		if minetest.is_protected(pos2,theowner) then
			minetest.chat_send_player(name, pos2.x .." " .. pos2.y .." " .. pos2.z .." is protected, tell the owner about the error")
			return
		end
		local meta=minetest.get_meta(pos2)
		local nam=meta:get_string("owner")
		if meta:get_int("renting_rantable_" .. theowner)==1 then
			table.insert(nods,pos2)
		end
	end
	end
	end
	local meta3=minetest.get_meta(pos)
	smartrenting.setchange(pos,3)
	for i, v in ipairs(nods) do
		local meta2=minetest.get_meta(v)
		if meta2:get_string("infotext")~="" then
			meta2:set_string("infotext","Owned by " .. name )
			meta2:set_string("owner",name)
		end
	end
end


smartrenting.prepare=function(pos,name,stat)
	local d=smartrenting.param2dir(pos)
	local meta5=minetest.get_meta(pos)
	local owner=meta5:get_string("owner")
	local renter=meta5:get_string("renter")
	local pos2
	local nods={}
	for x=-d.xm,d.xp,1 do
	for y=-d.ym,d.yp,1 do
	for z=-d.zm,d.zp,1 do
		pos2={x=pos.x+x,y=pos.y+y,z=pos.z+z}
		if minetest.is_protected(pos2,owner) then
			minetest.chat_send_player(name, pos2.x .." " .. pos2.y .." " .. pos2.z .." is protected")
			return
		end
		local meta=minetest.get_meta(pos2)
		local nam=meta:get_string("owner")
		local n=minetest.get_item_group(minetest.get_node(pos2).name,"not_rentable")==0
		local n2=minetest.get_item_group(minetest.get_node(pos2).name,"renting_rentable")==1

		if (nam==owner or nam==renter or n2) and n then
			table.insert(nods,pos2)
		elseif nam~="" and n then
			minetest.chat_send_player(owner, pos2.x .." " .. pos2.y .." " .. pos2.z .. " " .. minetest.get_node(pos2).name .." is not owned by you")
			return
		end
	end
	end
	end
	local meta3=minetest.get_meta(pos)
	smartrenting.setchange(pos,stat)
	local category=meta3:get_string("category")
	for i, v in ipairs(nods) do
		local meta2=minetest.get_meta(v)
		if meta2:get_string("infotext")~="" then
			meta2:set_string("infotext","Able for renting (" .. category ..")")
			meta2:set_string("owner",owner)
			meta2:set_int("renting_rantable_" .. owner,1)
		end
	end
end




smartrenting.form1=function(pos,player)
	local meta=minetest.get_meta(pos)
	local rentable=meta:get_int("rentable")

	local owner=meta:get_string("owner")
	local name=player:get_player_name()

	local inv = meta:get_inventory()
	local spos=pos.x .. "," .. pos.y .. "," .. pos.z
	local key=player:get_player_control().aux1
	local gui=""

	local right=meta:get_int("right")
	local front=meta:get_int("front")
	local left=meta:get_int("left")
	local back=meta:get_int("back")
	local up=meta:get_int("up")
	local down=meta:get_int("down")
	local every=meta:get_int("every")
	local count=meta:get_int("count")
	local category=meta:get_string("category")
	local keep=meta:get_int("keep")

	if (owner==name or minetest.check_player_privs(name, {protection_bypass=true})) and not key then
		gui=""
		.."size[11,8]"
		if rentable<3 then gui=gui .."button[0,0;1.5,1;save;Save]" end
		if rentable<3 then gui=gui .."button_exit[1.5,0;1.5,1;prepare;Prepare]" end

		if rentable==0 then
			gui=gui .."label[0,1;Prepare]"
		elseif rentable==1 then
			gui=gui .. "button_exit[0,1;1.5,1;rentout;Rent out]"
		elseif rentable==2 then
			gui=gui .."label[0,1;Able for renting]"
		elseif rentable==3 then
			gui=gui .."label[0,1;Rented]"
		end

		if (rentable==3 or rentable==4) and minetest.check_player_privs(name, {protection_bypass=true}) then gui=gui .."button_exit[1.5,1;1.5,1;throwout;Throw out]" end
		if rentable==3 then gui=gui .. "button_exit[0,2;2,1;endrenting;End renting]" end

		if rentable==3 or rentable==4 then
			gui=gui .."item_image_button[0,0;1,1;" .. inv:get_stack("paying",1):get_name() .. ";show;\n\n\b\b\b\b" .. inv:get_stack("paying",1):get_count() .."]"
			gui=gui .."label[0,-0.4;Rented by: " .. meta:get_string("renter") .."]"
		end

		gui=gui
		.."textarea[0,3;1,1;left;Left;" .. left .. "]"
		.."textarea[1.25,3;1,1;front;Front;" .. front .. "]"
		.."textarea[2.5,3;1,1;right;Right;" .. right .. "]"
		.."textarea[1.25,4;1,1;back;Back;" .. back .. "]"
		.."textarea[2.5,4;1,1;up;Up;" .. up .. "]"
		.."textarea[0,4;1,1;down;Down;" .. down .. "]"

		.."label[-0.2,7.7;Hold aux1 / use and click\nto see the customer view]"

		.."label[-0.25,5;Pay]"
		.."list[nodemeta:" .. spos .. ";pay;-0.25,5.5;1,1;]"
		.."dropdown[1,5.5;2,1;every;Day,Hour,Minute,Second;" .. every .."]"
		.."textarea[0,7;1,1;count;Count;" ..count .. "]"
		.."textarea[1,7;2.5,1;category;Category;" .. category .. "]"

		.."list[current_player;main;3,4.5;8,4;]"
		.."listring[nodemeta:" .. spos .. ";main]"
		.."listring[current_player;main]"

		if keep==0 or keep==1 then
			gui=gui
			.."list[nodemeta:" .. spos .. ";main;3,-0.3;8,4;]"
		end

		if keep==1 then
			gui=gui .. "button_exit[3,3.7;3,1;keep;Keep stuff]"
		elseif keep==2 then
			gui=gui .. "button_exit[3,3.7;3,1;keep;Unlimited inventory]"
		end
		smartrenting.user[name]=pos
		minetest.after((0.1), function(gui)
			return minetest.show_formspec(name, "smartrenting.form1",gui)
		end, gui)
	elseif (owner~=name or key) or not ((rentable==2 or rentable==4) and name~=meta:get_string("renter")) then
		gui=""
		.."size[8,7]"

		.."label[3,0;" .. category .. "]"

		.."item_image_button[3.1,0.7;1,1;" .. inv:get_stack("pay",1):get_name() .. ";show;\n\n\b\b\b\b" .. inv:get_stack("pay",1):get_count() .."]"
		.."label[2.5,1;Pay\b\b\b\b\b\b\b\b" .. count .. "'th " .. meta:get_string("payper") .. "]"

		.."list[nodemeta:" .. spos .. ";paying;3,2;1,1;]"

		.."list[current_player;main;0,3.5;8,4;]"
		.."listring[nodemeta:" .. spos .. ";pay]"

		if rentable==2 then
			gui=gui .. "button_exit[4,2;1,1;rent;Rent]"
		elseif rentable==3 or rentable==4 then
			gui=gui .. "button_exit[4,2;2,1;moveout;Move out]"
		else
			gui=gui .. "label[4,2;Not able]"
		end
		smartrenting.user[name]=pos
		minetest.after((0.1), function(gui)
			return minetest.show_formspec(name, "smartrenting.form1",gui)
		end, gui)
	end


end


minetest.register_on_player_receive_fields(function(player, form, pressed)
	if form=="smartrenting.form1" then
		local name=player:get_player_name()
		local pos=smartrenting.user[name]
		local meta=minetest.get_meta(pos)
		local owner=meta:get_string("owner")

		if pressed.keep then
			if meta:get_int("keep")==1 then
				meta:set_int("keep",2)
			else
				meta:set_int("keep",1)
			end
		end

		if pressed.endrenting then
			smartrenting.setchange(pos,4)
		end

		if pressed.rent then
			if not smartrenting.fee(pos,name) then return end
			smartrenting.rent(pos,name)
			meta:set_string("renter",name)
			local t=1
			if meta:get_int("every")~=4 then t=10 end
			minetest.get_node_timer(pos):start(t)
			smartrenting.setdate(meta)
		end

		if pressed.rentout then
			smartrenting.setchange(pos,2)
		end

		if pressed.throwout or
		(pressed.moveout
		and meta:get_int("rentable")>=3
		and meta:get_string("renter")==name) then
			if meta:get_int("rentable")==4 then
				smartrenting.prepare(pos,name,1)
			else
				smartrenting.prepare(pos,name,2)
			end
			minetest.get_node_timer(pos):stop()
		end

		if pressed.prepare then
			smartrenting.prepare(pos,name,1)
		end

		if pressed.quit then
			smartrenting.user[name]=nil
			return
		end

		if pressed.save then
			meta:set_int("right",smartrenting.num(pressed.right,0,20))
			meta:set_int("front",smartrenting.num(pressed.front,0,20))
			meta:set_int("left",smartrenting.num(pressed.left,0,20))
			meta:set_int("back",smartrenting.num(pressed.back,0,20))
			meta:set_int("up",smartrenting.num(pressed.up,0,20))
			meta:set_int("down",smartrenting.num(pressed.down,0,20))
			meta:set_string("category",pressed.category)
			meta:set_string("payper",pressed.every)
			if pressed.every=="Day" then
				pressed.every=1
				meta:set_int("count",smartrenting.num(pressed.count),1,32)
			elseif pressed.every=="Hour" then
				pressed.every=2
				meta:set_int("count",smartrenting.num(pressed.count),1,24)
			elseif pressed.every=="Minute" then
				pressed.every=3
				meta:set_int("count",smartrenting.num(pressed.count),1,60)
			elseif pressed.every=="Second" then
				pressed.every=4
				meta:set_int("count",smartrenting.num(pressed.count),1,60)
			end
			meta:set_int("every",pressed.every)
			smartrenting.test(pos)
			return
		end
	end
end)









minetest.register_tool("smartrenting:card", {
	description = "Copy and past settings to renting panels",
	inventory_image = "smartrenting_card.png",
	groups = {flammable = 2},
	on_use = function(itemstack, user, pointed_thing)
		if pointed_thing.type~="node" then return end
		local pos=pointed_thing.under
		if minetest.get_item_group(minetest.get_node(pos).name,"smartrenting_panel")==0 then return end
		local meta = minetest.get_meta(pos)
		local owner=meta:get_string("owner")
		if owner~=user:get_player_name() then return end

		local item=ItemStack(itemstack):to_table()

		if item.wear==0 then
			local right=meta:get_int("right")
			local front=meta:get_int("front")
			local left=meta:get_int("left")
			local back=meta:get_int("back")
			local up=meta:get_int("up")
			local down=meta:get_int("down")
			local every=meta:get_int("every")
			local count=meta:get_int("count")
			local category=meta:get_string("category")
			local keep=meta:get_int("keep")
			local inv = meta:get_inventory()
			local pay=inv:get_stack("pay",1):get_name() .." " .. inv:get_stack("pay",1):get_count()
			local data={right=right,front=front,left=left,back=back,up=up,down=down,every=every,count=count,category=category,keep=keep,pay=pay}
			item.meta={}
			item.wear=1
			item.meta.data=minetest.serialize(data)
			item.meta.description=category
			itemstack:replace(item)
			return itemstack
		else
		if meta:get_int("rentable")>2 then return end
			local d=minetest.deserialize(item.meta.data)
			meta:set_int("right",d.right)
			meta:set_int("front",d.front)
			meta:set_int("left",d.left)
			meta:set_int("back",d.back)
			meta:set_int("up",d.up)
			meta:set_int("down",d.down)
			meta:set_int("every",d.every)
			meta:set_int("count",d.count)
			meta:set_string("category",d.category)
			meta:set_int("keep",d.keep)
			meta:set_string("owner",owner)
			if d.keep~=0 then
				local inv = meta:get_inventory()
				inv:set_stack("pay",1,d.pay)
			end
			smartrenting.prepare(pos,owner,1)
			smartrenting.setchange(pos,1)
			smartrenting.test(pos)

		end
	end,
})






local rent_in_creative_inventory=0
for i=1,5,1 do
	if i==1 then
		rent_in_creative_inventory=0
	else
		rent_in_creative_inventory=1
	end

minetest.register_node(smartrenting.rentchar[i], {
	description = "Rent panel",
	tiles = {
		"smartrenting_wood.png",
		"smartrenting_wood.png",
		"smartrenting_wood.png",
		"smartrenting_wood.png",
		"smartrenting_wood.png",
		"smartrenting_" .. i ..".png"
	},
	groups = {choppy = 2, oddly_breakable_by_hand = 1,tubedevice = 1, tubedevice_receiver = 1,smartrenting_panel=1,not_rentable=1,not_in_creative_inventory=rent_in_creative_inventory},
	drawtype="nodebox",
	node_box = {type="fixed",fixed={-0.5,-0.5,0.45,0.5,0.5,0.5}},
	paramtype2="facedir",
	paramtype = "light",
	sunlight_propagates = true,
	light_source = 10,
	drop="smartrenting:panel",
	mesecons = {receptor = {state = "off"}},
	tube = {insert_object = function(pos, node, stack, direction)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			local added = inv:add_item("main", stack)
			return added
		end,
		can_insert = function(pos, node, stack, direction)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			return inv:room_for_item("main", stack)
		end,
		input_inventory = "main",
		connect_sides = {left = 1, right = 1, front = 1, back = 1, top = 1, bottom = 1}},
on_timer = function (pos, elapsed)
		local meta=minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local e=meta:get_int("every")
		local owner=meta:get_string("owner")
		local count=meta:get_int("count")
		local went_time=smartrenting.diff(e,{sec=meta:get_int("sec"),min=meta:get_int("min"),hour=meta:get_int("hour"),day=meta:get_int("day"),month=meta:get_int("month"),year=meta:get_int("year")})
		if not went_time then
			smartrenting.prepare(pos,owner,2)
			minetest.get_node_timer(pos):stop()
			return false
		elseif went_time>=count then
			local pay=inv:get_stack("pay",1):get_count()

			if pay==0 then
				smartrenting.prepare(pos,owner,2)
				minetest.get_node_timer(pos):stop()
				return
			end

			if pay==0 or meta:get_int("rentable")==4 then
				smartrenting.prepare(pos,owner,1)
				minetest.get_node_timer(pos):stop()
				return
			end

			local cost=math.floor(went_time/count)*pay
			local stack=inv:get_stack("paying",1):get_name()
			if inv:get_stack("paying",1):get_count()<cost then
				smartrenting.prepare(pos,owner,2)
				minetest.get_node_timer(pos):stop()
				return false
			end
			if meta:get_int("keep")~=2 then
				if inv:get_stack("main",28):get_count()>0 then
					local owner=meta:get_string("owner")
					minetest.chat_send_player(meta:get_string("renter"), "The owner (" .. owner .. ") need to empty")
					minetest.chat_send_player(owner,"Smartrenting: " .. pos.x .." " .. pos.y .." " .. pos.z .. " (" .. meta:get_string("category") .. ") need to be emptied")
					if not inv:room_for_item("main", stack .. " " .. cost) then
						smartrenting.prepare(pos,owner,4)
						smartrenting.setchange(pos,5,1)
					end
				end
				inv:add_item("main", stack .. " " .. cost)
			end
			inv:remove_item("paying",stack .. " " .. cost)
			smartrenting.setdate(meta)
		end
		return true
end,
after_place_node = function(pos, placer)
		local meta=minetest.get_meta(pos)
		local name=placer:get_player_name()
		if name=="0" then
			minetest.set_node(pos,{name="air"})
			minetest.add_item(pos,"smartrenting:panel")
			return
		end
		meta:set_string("owner",placer:get_player_name())
		meta:set_string("infotext", "Rent panel (" .. name ..")")
		if minetest.check_player_privs(name, {give=true})
		or minetest.check_player_privs(name, {creative=true}) then
			meta:set_int("keep",1)
		end
	end,
on_construct = function(pos)
		local meta=minetest.get_meta(pos)
		meta:set_int("every",2)
		meta:set_int("count",1)
		meta:set_string("category","category1")

		meta:get_inventory():set_size("main", 32)
		meta:get_inventory():set_size("pay", 1)
		meta:get_inventory():set_size("paying", 1)
	end,
on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		smartrenting.form1(pos,player)
	end,
allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		local meta=minetest.get_meta(pos)
		local name=player:get_player_name()
		local rentable=meta:get_int("rentable")
		if listname=="paying" and (rentable==2 or rentable==3) then
			if stack:get_name()~=meta:get_inventory():get_stack("pay",1):get_name() then return 0 end
			return stack:get_count()
		elseif listname=="pay" and (rentable==0 or rentable==1 or rentable==2 or rentable==4) then
			return stack:get_count()
		end
		return 0
	end,
allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		local meta=minetest.get_meta(pos)
		local name=player:get_player_name()
		local spos=pos.x .. "," .. pos.y .. "," .. pos.z
		local rentable=meta:get_int("rentable")
		if listname=="paying" and (name==meta:get_string("renter") or rentable==1 or rentable==2) then
			return stack:get_count()
		elseif listname=="main" and (name==meta:get_string("owner") or minetest.check_player_privs(name, {protection_bypass=true})) then
			return stack:get_count()
		elseif listname=="pay" and (rentable==0 or rentable==1 or rentable==2 or rentable==4) then
			return stack:get_count()
		end
		return 0
	end,
allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		return 0
	end,
can_dig = function(pos, player)
		local meta=minetest.get_meta(pos)
		local inv=meta:get_inventory()
		local name=player:get_player_name()
		local rentable=meta:get_int("rentable")
		local owner=meta:get_string("owner")
		if (owner==name or owner=="0" or owner=="" or minetest.check_player_privs(name, {protection_bypass=true}))
		and inv:is_empty("main") and inv:is_empty("pay") and entable~=3 and entable~=4 then
			if not inv:is_empty("paying") then
				minetest.add_item(pos, inv:get_stack("paying",1):get_name() .." ".. inv:get_stack("paying",1):get_count())
			end
			return true
		end
	end,
})

end


minetest.register_entity("smartrenting:point",{
	hp_max = 1,
	physical = false,
	visual = "sprite",
	visual_size = {x=0.2, y=0.2},
	pointable=false,
	textures = {"bubble.png^[colorize:#00ff00ff"}, 
	on_step = function(self, dtime)
		self.timer=self.timer+dtime
		if self.timer<5 then return self end
		self.object:remove()
	end,
	timer=0,
})