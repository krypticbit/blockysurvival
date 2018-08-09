schemlib = {}
local modpath = minetest.get_modpath(minetest.get_current_modname())
schemlib.modpath = modpath

schemlib.mapping = dofile(modpath.."/mapping.lua")
schemlib.node = dofile(modpath.."/node.lua")
schemlib.worldedit_file = dofile(modpath.."/worldedit_file.lua")
schemlib.plan = dofile(modpath.."/plan.lua")
schemlib.plan_manager = dofile(modpath.."/plan_manager.lua")
schemlib.npc_ai = dofile(modpath.."/npc_ai.lua")

-- log that we started
minetest.log("action", "[MOD]"..minetest.get_current_modname().." -- loaded from "..modpath)
