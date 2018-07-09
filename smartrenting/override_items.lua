--groups: renting_rentable, not_rentable
--node function: renting=function(pos,ownerrenter)
--node function: renting_reset=function(pos,owner,renter)

local furnace_take=function(pos, listname, index, stack, player)
	local meta = minetest.get_meta(pos)
	local owner=meta:get_string("owner")
	local name=player:get_player_name()
	if (owner~="" and owner~=name) or (owner=="" and minetest.is_protected(pos, name)) then
		return 0
	end
	return stack:get_count()
end
local furnace_put=function(pos, listname, index, stack, player)
	local meta = minetest.get_meta(pos)
	local owner=meta:get_string("owner")
	local name=player:get_player_name()
	if (owner~="" and owner~=name) or (owner=="" and minetest.is_protected(pos, name)) then
		return 0
	end
	local inv = meta:get_inventory()
	if listname=="fuel" then
		if minetest.get_craft_result({method="fuel", width=1, items={stack}}).time~=0 then
			return stack:get_count()
		else
			return 0
		end
	elseif listname=="src" then
		return stack:get_count()
	elseif listname=="dst" then
		return 0
	end
end

local furnace_after_place_node=function(pos)
		minetest.get_meta(pos):set_string("infotext", "furnace")
	end,
minetest.override_item("default:furnace_active", {
	allow_metadata_inventory_take=furnace_take,
	allow_metadata_inventory_put=furnace_put,
	after_place_node=furnace_after_place_node,
	groups = {cracky=2, not_in_creative_inventory=1,renting_rentable=1}
})
minetest.override_item("default:furnace", {
	allow_metadata_inventory_take=furnace_take,
	allow_metadata_inventory_put=furnace_put,
	after_place_node=furnace_after_place_node,
	groups = {cracky=2,enting_rentable=1}
})