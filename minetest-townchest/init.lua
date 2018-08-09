-- expose api
townchest = {}
townchest.modpath = minetest.get_modpath(minetest.get_current_modname())


-- debug. Used for debug messages. In production the function should be empty
local dprint = print
local dprint_off = function()end
townchest.dprint = dprint
townchest.dprint_off = dprint_off

-- UI tools/ formspec
local smartfs = dofile(townchest.modpath.."/smartfs.lua")
townchest.smartfs = smartfs
dofile(townchest.modpath.."/smartfs-forms.lua")

-- The Chest
dofile(townchest.modpath.."/chest.lua")

-- NPC's
dofile(townchest.modpath.."/npcf-worker.lua")


-- Read the townchest building files
function townchest.files_get()
	local files = minetest.get_dir_list(townchest.modpath..'/buildings/', false) or {}
	local i, t = 0, {}
	for _,filename in ipairs(files) do
		table.insert(t, filename)
	end
	table.sort(t,function(a,b) return a<b end)
	return t
end

-----------------------------------------------
-- on_construct - if the chest is placed
-----------------------------------------------
local __on_construct = function(pos)
	dprint("on_construct")
	local chest = townchest.chest.create(pos) --create new chest utils instance
	chest:set_plan_form()
end

-----------------------------------------------
-- on_destruct - if the chest destroyed
-----------------------------------------------
local __on_destruct = function(pos)
	dprint("on_destruct")
	local key = "townchest:"..minetest.pos_to_string(pos)
	local plan = schemlib.plan_manager.get_plan(key)
	if plan then
		plan:set_status("pause")
		schemlib.plan_manager.delete_plan(key)
	end
end

local __on_timer = function(pos, elapsed)
	local chest = townchest.chest.get(pos)
	return chest:update_info()
end
-----------------------------------------------
-- on_punch
-----------------------------------------------
local __on_punch = function(pos)
	dprint("on_punch")
end

-----------------------------------------------
-- on_metadata_inventory_put
-----------------------------------------------
local __on_metadata_inventory_put = function(pos)
	return 0
end

-----------------------------------------------
-- allow_metadata_inventory_move
-----------------------------------------------
local __allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
	return 0
end

-----------------------------------------------
-- allow_metadata_inventory_put
-----------------------------------------------
local __allow_metadata_inventory_put = function(pos, listname, index, stack, player)
	return 0
end

-----------------------------------------------
-- allow_metadata_inventory_take
-----------------------------------------------
local __allow_metadata_inventory_take = function(pos, listname, index, stack, player)
	return 0
end

-----------------------------------------------
-- register_node - the chest where you put the items
-----------------------------------------------
minetest.register_node("townchest:chest", {
	description = "Building Chest",
	tiles = {"default_chest_top.png", "default_chest_top.png", "default_chest_side.png",
		"default_chest_side.png", "default_chest_side.png", "default_chest_front.png"},
	paramtype2 = "facedir",
	groups = {snappy=2,choppy=2,oddly_breakable_by_hand=2},
	legacy_facedir_simple = true,
	sounds = default.node_sound_wood_defaults(),
	on_construct = __on_construct,
	on_receive_fields = function(pos, formname, fields, sender)
		smartfs.nodemeta_on_receive_fields(pos, formname, fields, sender)
	end,
	after_dig_node = __on_destruct,
	on_punch = __on_punch,
	on_timer = __on_timer,
	on_metadata_inventory_put = __on_metadata_inventory_put,
	allow_metadata_inventory_move = __allow_metadata_inventory_move,
	allow_metadata_inventory_put = __allow_metadata_inventory_put,
	allow_metadata_inventory_take = __allow_metadata_inventory_take,
})

-----------------------------------------------
-- register craft recipe for the chest
-----------------------------------------------
minetest.register_craft({
	output = 'townchest:chest',
	recipe = {
		{'default:mese_crystal', 'default:chest_locked', 'default:mese_crystal'},
		{'default:book', 'default:diamond', 'default:book'},
		{'default:mese_crystal', 'default:chest_locked', 'default:mese_crystal'},
	}
})

-- log that we started
minetest.log("action", "[MOD]"..minetest.get_current_modname().." -- loaded from "..townchest.modpath)
