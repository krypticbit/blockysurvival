--esmobs v1.3
--maikerumine
--made for Extreme Survival game
--borrowed code from skins mod:
--https://github.com/Zeg9/minetest-skins/
--[[
License code is WTFPL

From minetest_game (CC BY-SA 3.0):
player_1.png
MirceaKitsune (WTFPL) + bundled script by Zeg9 (WTFPL too):
skin_previews.blend
Jordach (CC BY-SA 3.0):
character_1.png
Zeg9 (CC BY-SA 3.0):
character_2.png
jmf (WTFPL):
player_2.png
character_3.png
character_4.png
character_5.png
character_6.png
character_7.png
character_8.png
character_9.png
character_10.png
character_11.png
Chinchow (WTFPL):
character_12.png
character_13.png
character_14.png
HybridDog (CC BY-SA 3.0):
character_15.png
character_16.png
character_17.png
character_18.png
HybridDog (WTFPL):
player_10.png
Jordach (CC BY-NC-SA):
character_19.png
character_20.png
character_21.png
character_22.png
character_23.png
character_24.png
character_25.png
character_26.png
Stuart Jones (WTFPL):
character_27.png
klunk (WTFPL):
player_3.png
InfinityProject:
player_4.png
player_5.png
player_6.png
player_7.png
player_8.png
player_9.png
prof_turbo (WTFPL):
player_11.png
character_28.png
character_29.png
jojoa1997 (CC BY-SA 3.0):
character_30.png
cisoun (WTFPL):
player_12.png
]]


--MOB SPECS
esmobs = {}
esmobs.type = { SPRITE=0, MODEL=1 }

esmobs.esmobs = {}
esmobs.default = function()
	return "badplayer_1"
end

esmobs.get_type = function(texture)
	if not texture then return end
	if string.sub(texture,0,string.len("character")) == "character" then
		return esmobs.type.MODEL
	end
	if string.sub(texture,0,string.len("badplayer")) == "badplayer" then
		return esmobs.type.SPRITE
	end
	if string.sub(texture,0,string.len("mobs")) == "mobs" then
		return esmobs.type.SPRITE
	end
	if string.sub(texture,0,string.len("player")) == "player" then
		return esmobs.type.SPRITE
	end
	if string.sub(texture,0,string.len("mcmobs")) == "mcmobs" then
		return esmobs.type.SPRITE
	end
end

esmobs.modpath = minetest.get_modpath("esmobs")
dofile(esmobs.modpath.."/skinlist.lua")
dofile(esmobs.modpath.."/meta.lua")

esmobs.formspec = {}
esmobs.formspec.main = function(name)
	--minetest.sound_play("default_punch3", {pos = pos, gain = 1.0, max_hear_distance = 16})
	local page = esmobs.pages[name]
	if page == nil then page = 0 end
	local formspec = "size[8,7.5]"
		.. "button[0,0;2,.5;main;Back]"
	if esmobs.get_type(esmobs.esmobs[name]) == esmobs.type.SPRITE then
		formspec = formspec
--			.. "image[0,.75;1,2;"..esmobs.esmobs[name].."_preview.png]"
--			.. "image[1,.75;1,2;"..esmobs.esmobs[name].."_preview_back.png]"
			.. "label[6,.5;Raw texture:]"
			.. "image[6,1;2,1;"..esmobs.esmobs[name]..".png]"

	else
		formspec = formspec
--			.. "image[0,.75;1,2;"..esmobs.esmobs[name]..".png]"
--			.. "image[1,.75;1,2;"..esmobs.esmobs[name].."_back.png]"
--			.. "image[0,.75;1,2;"..esmobs.esmobs[name].."_preview.png]"
--			.. "image[1,.75;1,2;"..esmobs.esmobs[name].."_preview_back.png]"
	end
	local meta = esmobs.meta[esmobs.esmobs[name]]
	if meta then
		if meta.name then
			formspec = formspec .. "label[0,.5;name: "..meta.name.."]"
		end
		if meta.type then
			formspec = formspec .. "label[0,1;type: "..meta.type.."]"
		end
		if meta.hp then
			formspec = formspec .. "label[0,1.5;hp:"..meta.hp.."]"
		end
		if meta.drops then
			formspec = formspec .. "label[0,2;drops:"..meta.drops.."]"
		end
		if meta.info then
			formspec = formspec .. "label[0,2.5;info:"..meta.info.."]"
		end
	end
	local index = 0
	local skip = 0 -- Skip esmobs, used for pages
	for i, skin in ipairs(esmobs.list) do
		if skip < page*16 then skip = skip + 1 else
			if index < 16 then
				formspec = formspec .. "image_button["..(index%8)..","..((math.floor(index/8))*2+3)..";1,2;"..skin
				if esmobs.get_type(skin) == esmobs.type.MODEL then
					formspec = formspec .. "_preview"
				end
				formspec = formspec .. ".png;esmobs_set_"..i..";]"
			end
			index = index +1
		end
	end
	if page > 0 then
		formspec = formspec .. "button[0,7;1,.5;esmobs_page_"..(page-1)..";<<]"
	else
		formspec = formspec .. "button[0,7;1,.5;esmobs_page_"..page..";<<]"
	end
	formspec = formspec .. "button[.75,7;6.5,.5;esmobs_page_"..page..";Page "..(page+1).."/"..math.floor(#esmobs.list/16+1).."]" -- a button is used so text is centered
	if index > 16 then
		formspec = formspec .. "button[7,7;1,.5;esmobs_page_"..(page+1)..";>>]"
	else
		formspec = formspec .. "button[7,7;1,.5;esmobs_page_"..page..";>>]"
	end
	return formspec
end

esmobs.pages = {}


minetest.register_on_joinplayer(function(player)
	if not esmobs.esmobs[player:get_player_name()] then
		esmobs.esmobs[player:get_player_name()] = esmobs.default()
	end

	inventory_plus.register_button(player,"esmobs","E.S. Mobs")
end)

minetest.register_on_player_receive_fields(function(player,formname,fields)
	if fields.esmobs then
		inventory_plus.set_inventory_formspec(player,esmobs.formspec.main(player:get_player_name()))
	end
	for field, _ in pairs(fields) do
		if string.sub(field,0,string.len("esmobs_set_")) == "esmobs_set_" then
			esmobs.esmobs[player:get_player_name()] = esmobs.list[tonumber(string.sub(field,string.len("esmobs_set_")+1))]
			--minetest.sound_play("mobs_stonemonster", {pos = pos, gain = 1.0, max_hear_distance = 16})
			inventory_plus.set_inventory_formspec(player,esmobs.formspec.main(player:get_player_name()))
		end
		if string.sub(field,0,string.len("esmobs_page_")) == "esmobs_page_" then
			esmobs.pages[player:get_player_name()] = tonumber(string.sub(field,string.len("esmobs_page_")+1))
			--minetest.sound_play("Fuse", {pos = pos, gain = 1.0, max_hear_distance = 16})
			inventory_plus.set_inventory_formspec(player,esmobs.formspec.main(player:get_player_name()))
		end
	end
end)

