hacktool={}

hacktool.gui=function(itemstack, user, pointed_thing)
	if pointed_thing.type~="object" then return end
	local player=pointed_thing.ref
	if player:is_player()==false then return end
	hacktool.tmp={}
	hacktool.tmp=player
	local inv=player:get_inventory()
	local gui="size[8,4]"
	local x=0
	local y=0

	for i=1,32,1 do
		gui=gui .."item_image_button[" .. x ..",".. y.. ";1,1;".. inv:get_stack("main",i):get_name() ..";inv" .. i ..";\n\n\b\b\b" .. inv:get_stack("main",i):get_count() .."]"
		x=x+1
		if x>=8 then
			x=0
			y=y+1
		end
	end
	minetest.after((0.1), function(gui)
		return minetest.show_formspec(user:get_player_name(), "invhack.form",gui)
	end, gui)
end

minetest.register_privilege("invhack", {
	description = "Let you hack players inventory",
	give_to_singleplayer= true,
})



minetest.register_on_player_receive_fields(function(player, form, pressed)
	if form=="invhack.form" then
		local name=player:get_player_name()
		local n=0

		if pressed.quit then
			if hacktool.tmp then hacktool.tmp=nil end
			return
		end

		if not minetest.check_player_privs(name, {invhack=true}) then
			minetest.chat_send_player(name, "Missing privilege: invhack")
			return
		end

		if hacktool.tmp==nil or hacktool.tmp:is_player()~=true then
			hacktool.tmp=nil
			minetest.chat_send_player(name, "The tempoary variable is empty or the player offline")
			return
		end

		for i=1,32,1 do
			n=i
			if pressed["inv" .. i] then break end
		end
		if pressed["inv" .. n] then 
			local pinv=hacktool.tmp:get_inventory()
			local uinv=player:get_inventory()
			local stack=pinv:get_stack("main",n)
			local n2=0
			local f=true
			for i=1,32,1 do
				n2=i
				if uinv:get_stack("main",i):get_count()==0 then f=false break end
			end
			if f then minetest.chat_send_player(name, "Error: Your inventory is full") return end
			uinv:set_stack("main",n2,stack)
			pinv:set_stack("main",n,nil)
		end
	end
end)



minetest.register_tool("invhack:tool", {
	description = "Inventory hack tool",
	range = 15,
	inventory_image = "hacktool_inv.png",
	groups = {not_in_creative_inventory=1},
	on_use = function(itemstack, user, pointed_thing)
		hacktool.gui(itemstack, user, pointed_thing)
	return itemstack
	end,
})