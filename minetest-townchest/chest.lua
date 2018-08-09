--local dprint = townchest.dprint
local dprint = townchest.dprint_off --debug

local smartfs = townchest.smartfs

--------------------------------------
-- Chest class and interface
--------------------------------------
local chest = {}
townchest.chest = chest
local chest_class = {}
local chest_class_mt = {__index = chest_class}

--------------------------------------
-- object constructor
--------------------------------------
function chest.new()
	return setmetatable({}, chest_class_mt)
end

--------------------------------------
-- Get or create new chest object for position
--------------------------------------
function chest.get(pos)
	local key = "townchest:"..minetest.pos_to_string(pos)
	local self = chest.new()
	self.pos = pos
	self.meta = minetest.get_meta(pos)
	self.plan = schemlib.plan_manager.get_plan(key)
	if not self.plan then
		self.plan = schemlib.plan.new(key, pos)
		schemlib.plan_manager.set_plan(self.plan)
	end
	self.info = self.plan.data
	self.info.facedir =  minetest.get_node(pos).param2
	return self
end

--------------------------------------
-- Initialize new chest object
--------------------------------------
function chest.create(pos)
	local key = "townchest:"..minetest.pos_to_string(pos)
	schemlib.plan_manager.delete_plan(key)
	local self = chest.get(pos)
	return self
end

--------------------------------------
-- set_plan_form - set formspec to specific widget in plan processing chain
--------------------------------------
function chest_class:set_plan_form()
	local status = self.plan:get_status()
	if status == "finished" then -- no updates if finished
		smartfs.get("townchest:build_finished"):attach_to_node(self.pos)
		self.meta:set_string("infotext", "Building finished")
	elseif status == "build" or status == "pause" then
		smartfs.get("townchest:build_status"):attach_to_node(self.pos)
		self.meta:set_string("infotext", "Plan size:"..self.info.nodecount)
	elseif self.info.nodecount > 0 then
		smartfs.get("townchest:configure"):attach_to_node(self.pos)
		self.meta:set_string("infotext", "Configure - Plan size:"..self.info.nodecount)
	else
		smartfs.get("townchest:plan"):attach_to_node(self.pos)
		self.meta:set_string("infotext", "please select a building plan")
	end
end

--------------------------------------
-- Show message - set formspec to specific widget for 2 seconds
--------------------------------------
function chest_class:show_message(message, stop)
	self.meta:set_string("infotext", message)
	smartfs.get("townchest:status"):attach_to_node(self.pos)

	if stop == false then
		self:run_async(function(chest)
			chest:set_plan_form()
		end, 2)
	end
end

--------------------------------------
-- update informations on formspecs during build process (called by nodetimer)
--------------------------------------
function chest_class:update_info()
	local status = self.plan:get_status()
	if status == "pause" and self.info.npc_build and self.info.nodecount == 0 then
		self.info.npc_build = false
		self.plan:set_status("finished")
	end
	if status == "build" or self.info.npc_build then
		minetest.get_node_timer(self.pos):start(2)
	end
	if self.info.ui_updates then
		self:set_plan_form()
	end
end

--------------------------------------
-- Run chest method async
--------------------------------------
function chest_class:run_async(func, delay)
	local function async_call(pos)
		local key = "townchest:"..minetest.pos_to_string(pos)
		local plan = schemlib.plan_manager.get_plan(key)
		if not plan then
			return
		end
		local chest = townchest.chest.get(pos)
		if func(chest) then
			chest:run_async(func, delay or 0.2)
		end
	end

	minetest.after(delay or 0.2, async_call, self.pos)
end

--------------------------------------
-- Generate simple form
--------------------------------------
function chest_class:generate_simple_form()
	local genblock = self.info.genblock
	-- set directly instead of counting each step
	self.info.min_pos = { x=1, y=1, z=1 }
	self.info.max_pos = { x=genblock.x, y=genblock.y, z=genblock.z}
	self.info.ground_y = 0
	local filler_node = "default:cobble"
	if genblock.variant == 1 then
		for x = 1, genblock.x do
			for y = 1, genblock.y do
				for z = 1, genblock.z do
					if x == 1 or x == genblock.x or
							y == 1 or y == genblock.y or
							z == 1 or z == genblock.z then
						self.plan:add_node({x=x,y=y,z=z}, "air")
					end
				end
			end
		end

	elseif genblock.variant == 2 then
		-- Fill with stone
		for x = 1, genblock.x do
			for y = 1, genblock.y do
				for z = 1, genblock.z do
					self.plan:add_node({x=x,y=y,z=z}, filler_node)
				end
			end
		end

	elseif genblock.variant == 3 then
		-- Build a box
		for x = 1, genblock.x do
			for y = 1, genblock.y do
				for z = 1, genblock.z do
					if x == 1 or x == genblock.x or
							y == 1 or y == genblock.y or
							z == 1 or z == genblock.z then
						self.plan:add_node({x=x,y=y,z=z}, filler_node)
					end
				end
			end
		end

		-- build ground level under chest
		self.info.ground_y = 1

	-- Build a plate
	elseif genblock.variant == 4 then
		local y = self.info.min_pos.y
		self.info.max_pos.y = self.info.min_pos.y
		for x = 1, genblock.x do
			for z = 1, genblock.z do
				self.plan:add_node({x=x,y=y,z=z}, filler_node)
			end
		end
		-- build ground level under chest
		self.info.ground_y = 1
	end
end
