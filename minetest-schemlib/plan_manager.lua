local save_interval = minetest.settings:get("schemlib.save_interval") or 10
local save_maxnodes = minetest.settings:get("schemlib.save_maxnodes") or 10000

local storage = minetest.get_mod_storage()

local plan_manager = {}
local plan_list = {}
local plan_meta_list = minetest.deserialize(storage:get_string("$PLAN_META_LIST$")) or {}

-- light methods without access to scm_data_cache
local plan_meta_class = {
	adjust_building_info = schemlib.plan.plan_class.adjust_building_info,
	get_world_pos = schemlib.plan.plan_class.get_world_pos,
	get_plan_pos = schemlib.plan.plan_class.get_plan_pos,
	get_world_minp = schemlib.plan.plan_class.get_world_minp,
	get_world_maxp = schemlib.plan.plan_class.get_world_maxp,
	contains = schemlib.plan.plan_class.contains,
	check_overlap = schemlib.plan.plan_class.check_overlap,
}
local plan_meta_class_mt = {__index = plan_meta_class}

plan_manager.plan_meta_list = plan_meta_list

-----------------------------------------------
-- Get separate stored plan metadata for plan
-----------------------------------------------
function plan_manager.get_plan_meta(plan_id)
	if plan_meta_list[plan_id] then
		local plan_meta = setmetatable({}, plan_meta_class_mt)
		plan_meta.plan_id = plan_id
		plan_meta.data = plan_meta_list[plan_id]
		return plan_meta
	end
end

-----------------------------------------------
-- Get persistant plan
-----------------------------------------------
function plan_manager.get_plan(plan_id)
	if plan_list[plan_id] then
		return plan_list[plan_id]
	end

	if not plan_meta_list[plan_id] then
		return
	end

	local plan = schemlib.plan.new(plan_id)
	plan.data = plan_meta_list[plan_id]

	if not plan.data.save_chunk_count then
		plan.scm_data_cache = minetest.deserialize(storage:get_string(plan_id))
	else
		plan.scm_data_cache = {}
		for i = 1, plan.data.save_chunk_count do
			local chunk = minetest.deserialize(storage:get_string(plan_id.."$"..i))
			for y, ydata in pairs(chunk) do
				plan.scm_data_cache[y] = ydata
			end
		end
	end

	local nodecount = 0
	for y, ydata in pairs(plan.scm_data_cache) do
		for x, xdata in pairs(ydata) do
			for z, node in pairs(xdata) do
				nodecount = nodecount + 1
			end
		end
	end
	plan.data.nodecount = nodecount
	plan_list[plan_id] = plan
	return plan
end

--------------------------------------
-- Set/Save plan in plan manager
--------------------------------------
function plan_manager.set_plan(plan)
	plan_manager.delete_plan(plan.plan_id)

	plan_list[plan.plan_id] = plan
	plan_meta_list[plan.plan_id] = plan.data

	if plan.data.nodecount <= 50000 then
		plan.data.save_chunk_count = nil
		storage:set_string(plan.plan_id, minetest.serialize(plan.scm_data_cache))
	else
	-- Split data to avoid error main function has more than 65536 constants
		local chunk = {}
		local chunk_size = 0
		local chunk_count = 0
		for y, ydata in pairs(plan.scm_data_cache) do
			chunk[y] = ydata
			for x, xdata in pairs(ydata) do
				for z, node in pairs(xdata) do
					chunk_size = chunk_size + 1
				end
			end
			if chunk_size > 50000 then
				chunk_count = chunk_count + 1
				storage:set_string(plan.plan_id.."$"..chunk_count, minetest.serialize(chunk))
				chunk = {}
				chunk_size = 0
			end
		end
		if chunk_size > 0 then
			chunk_count = chunk_count + 1
			storage:set_string(plan.plan_id.."$"..chunk_count, minetest.serialize(chunk))
		end
		plan.data.save_chunk_count = chunk_count
	end
	plan.modified = false
	storage:set_string("$PLAN_META_LIST$", minetest.serialize(plan_meta_list))
end

--------------------------------------
--  Remove plan from manager
--------------------------------------
function plan_manager.delete_plan(plan_id)
	local plan_meta = plan_manager.get_plan_meta(plan_id)
	if not plan_meta then
		return
	end
	storage:set_string(plan_id, "")
	if plan_meta.data.save_chunk_count then
		for i = 1, plan_meta.data.save_chunk_count do
			storage:set_string(plan_id.."$"..i,"")
		end
	end
	plan_list[plan_id] = nil
	plan_meta_list[plan_id] = nil
	storage:set_string("$PLAN_META_LIST$", minetest.serialize(plan_meta_list))
end

--------------------------------------
--  Do trigger processing
--------------------------------------
for plan_id, data in pairs(plan_meta_list) do
	if data.status == "build" then
		local plan = plan_manager.get_plan(plan_id)
		minetest.after(0, plan.do_add_all_voxel_async, plan)
	end
end

--------------------------------------
--  Save all on shutdown
--------------------------------------
minetest.register_on_shutdown(function()
	for plan_id, plan in pairs(plan_list) do
		if plan.modified then
			plan_manager.set_plan(plan)
		end
	end
end)

--------------------------------------
--  Save in intervals
--------------------------------------
local function save_chain()
	for plan_id, plan in pairs(plan_list) do
		if plan.modified and
				(save_maxnodes == 0 or plan.data.nodecount <= save_maxnodes) then
			plan_manager.set_plan(plan)
		end
	end
	minetest.after(save_interval, save_chain)
end

if save_interval > 0 then
	minetest.after(save_interval, save_chain)
end


return plan_manager
