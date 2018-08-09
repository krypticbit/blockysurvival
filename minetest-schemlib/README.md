# Schemlib - A Schematics library for Minetest mods

The goal of this library is to help manage buildings and other node-placement related tasks in other mods.
The Mod is a consolidation of TownChest and handle_schematics at the time

Current status: Hacking

Reference implementations: WIP / nothing shiny
  - The NPCF-Builder use some basics: https://github.com/stujones11/minetest-npcf/ 
  - My NPCF-Builder (slightly other focus): https://github.com/bell07/minetest-schemlib_builder_npcf

License: LGPLv2

# API
----

## data types (and usual names):
  - node_obj  - object representing a node in plan
  - plan_obj  - object representing a whole plan
  - plan_meta_obj - Simplified plan object that does not contain nodes data
  - plan_pos  - a relative position vector used in plan. Note: the relative
  - world_pos  - a absolute ("real") position vector in the world
  - anchor_pos - World position assigned to plan for plan_pos<=>world_pos calculations

## Plan object
The plan is the building draft that can be readed from file or be generated.
The plan manages the nodes and some attributes how the target building should be placed.
The plan does have two stages, the first is the preparation stage the plan does not have
an anchor to the "real world". In this stage no world interactions are possible.
The second stage is after the plan get the anchor attribute set.
In this stage the world interaction methods like place node are possible.

### class-methods
  - plan_obj = schemlib.plan.new([plan_id][,anchor_pos])    - Constructor - create a new plan object

### class-attributes/tables
  - plan.mapgen_process  - registered mapgen processing
```
  local chunk_key = minetest.hash_node_position(minp)
  plan.mapgen_process[chunk_key] = plan_obj
```

### object methods
#### Methods in draft mode (without anchor)
  - plan_obj:add_node(plan_pos, node)       - add a node to plan - if adjustment is given, the min/max and ground_y is calculated
  - plan_obj:adjust_building_info(plan_pos, node) - adjust bilding size and ground information
  - plan_obj:get_node(plan_pos)             - get a node from plan
  - plan_obj:del_node(plan_pos)             - delete a node from plan
  - plan_obj:get_random_plan_pos()          - get a random existing plan_pos from plan
  - plan_obj:read_from_schem_file(file)     - read from WorldEdit or mts file
  - plan_obj:apply_flood_with_air
       (add_max, add_min, add_top) - Fill a building with air
  - plan_obj:propose_anchor(world_pos, bool, add_xz)
                                   - propose anchor pos nearly given world_pos to be placed.
                                     if bool is given true a check will be done to prevent overbuilding of existing structures
                                     additional space to check for all sites can be given by add_xz (default 3)
                                   - returns "false, world_pos" in case of error. The world_pos is the issued not buildable position in this case

#### Methods interferring with the real world (anchor_pos exists or needs to be given optional)
  - plan_obj:get_world_pos(plan_pos[,anchor_pos]) - get a world position for a plan position
  - plan_obj:get_plan_pos(world_pos[,anchor_pos]) - get a plan position for a world position
  - plan_obj:get_world_minp([anchor_pos])   - get lowest world position
  - plan_obj:get_world_maxp([anchor_pos])   - get highest world position
  - plan_obj:contains(world_pos[,anchor_pos]) - check if the given world position is in the plan
  - plan_obj:check_overlap(pos1, pos2[,add_distance][,anchor_pos]) - check if the plan overlap the area in pos1/pos2
  - plan_obj:get_chunk_nodes(plan_pos[,anchor_pos]) - get a list of all nodes from chunk of a pos
  - plan_obj:do_add_chunk_place(plan_pos) - Place all nodes for chunk in real world using add_node()
  - plan_obj:load_region(min_world_pos[, max_world_pos]) - Load a Voxel-Manip for faster lookups to the real world
  - plan_obj:do_add_chunk_voxel(plan_pos)  - Place all nodes for chunk in real world using voxelmanip after emerge area
  - plan_obj:do_add_chunk_mapgen()  - Place all nodes for current chunk in on_mapgen. Used internally for registered chunks in plan.mapgen_process
  - plan_obj:do_add_all_voxel_async() - Place all plan nodes in multiple async calls of do_add_chunk_voxel()
  - plan_obj:do_add_all_mapgen_async() - Register all nodes for mapgen processing

#### Processing related
  - plan_obj:get_status()          - get the plan status. Returns values are "new", "build", "finished" or custom value like "pause"
  - plan_obj:set_status(status)    - set the plan status. Created plan is new, allowed new stati are "build" and "finished"
    - status = "new"      - Plan is in design mode
    - status = "build"    - do_add_all_voxel_async is running
    - status = "finished" - Processing is done

### Attributes
  - plan_obj.plan_id    - a id of the plan
  - plan_obj.data.status         - plan status
  - plan_obj.data.min_pos        - minimal {x,y,z} vector
  - plan_obj.data.max_pos        - maximal {x,y,z} vector
  - plan_obj.data.groundnode_count - count of nodes found for ground_y determination (internal)
  - plan_obj.data.nodecount      - count of the nodes in plan
  - plan_obj.data.nodeinfos      - a list of node information for name_id with counter (list={pos_hash,...}, count=1})
  - plan_obj.data.ground_y       - explicit ground adjustment for anchor_pos
  - plan_obj.data.facedir        - Plan rotation - x+ axis supported only (values 0-3)
  - plan_obj.data.mirrored       - (bool) Mirrored build - mirror to z-axis. Note: if you need x-axis mirror - just rotate the building by 2 in addition
  - plan_obj.data.anchor_pos     - position vector in world
  - plan_obj.data.npc_build      - <schemlib_npc>: if true, the building is allowed to be build by schemlib_npc

## Node object
The node object represents one node on plan. This object does manage node rotations,
mapping to costs item and compatibility mapping for older worldedit files.
A node is usually assigned to a plan, the most methods require the plan assignment.

### class-methods
  - node_obj = schemlib.plan.new([plan_id], [anchor_pos]) - Constructor - create a new node object. plan_id and anchor_pos is optional

### object-methods
  - node_obj:get_world_pos() - nodes assigned to plan only
  - node_obj:rotate_facedir(facedir) - rotate the node - is internally used for plan rotation in get_mapped() - supported 0-3 (x+ axis) only
  - node_obj:get_mapped()    - get mapped data for this node as it should be placed - returns a table {name=, param2=, meta=, content_id=, node_def=, final_nod_name=}
    - name, param2, meta   - data used to place node
    - content_id, node_def - game references, VoxelMap ID and registered_nodes definition
    - final_node_name      - if set, the node is not deleted from plan by place(). Contains the node name to be placed at the end. used for replacing by air before build the node
    - world_node_name      - contains the node name currently placed to the world
    - param2_plan_rotation - param2 value before rotation
  - node_obj:get_under()     - returns the node under this one if exists in plan
  - node_obj:get_above()     - returns the node above this one if exists in plan
  - node_obj:get_attached_to() - returns the position the node is attached to
  - node_obj:place()         - place node to world using "add_node" and remove them from plan
  - node_obj:remove_from_plan() - remove this node from plan

### object-attributes
  - node_obj.name         - original node name without mapping
  - node_obj.data         - table with original param2 / meta / prob
  - node_obj.plan         - assigned plan
  - node_obj.nodeinfo     - assigned nodeinfo in plan

Node mapping functions
  - schemlib.mapping.is_equal_meta(data,data) - Recursivelly compare data. Primary developed to check node metadata for changes
  - schemlib.mapping.map_unknown(item_name)   - Internally used to map unknown nodes
  - schemlib.mapping.map(name, plan)          - Get mapping informations without any callback calls


## Plan Manager object
The plan manager does manage the persistance for WIP plans. Also the manager allow to check overlaps to other buildings.
Usually the manager does not store the full plan but the parameters including file how to load or
generate the plan again. The work can be resumed by starting new because
already placed nodes / chunks are passed
The plan manager is a singleton that means you have only one instance in game. Therefore implemented as functions

### Functions
  - schemlib.plan_manager.get_plan_meta(plan_id) - Get Meta-Plan-Object
  - schemlib.plan_manager.get_plan(plan_id)      - Get Plan Object from persistance manager
  - schemlib.plan_manager.set_plan(plan_obj)     - Add plan to persistance manager. Note, the definitely plan_obj.plan_id must be set.
  - schemlib.plan_manager.delete_plan(plan_id)   - Remove plan from persistance manager

### plan_meta_class
Simplified plan class that works on metadata only, without nodes operations. Next methods are available:
adjust_building_info, get_world_pos, get_plan_pos, get_world_minp, get_world_maxp, contains, check_overlap

### Plan manager settings
Note: all modified plans will be saved on shutdown independing on this parameters

#### schemlib.save_interval (Plan manager save interval) int 10 0
Save interval in seconds for plan changes in manager. 0 disables the interval saving.

#### schemlib.save_maxnodes (Maximum building size for autosave) int 10000 0
Maximum building size in nodes that are handled in interval save to avoid performance issue. 0 enables saving for all sizes.
Note: all (including big) modified plans will be saved on shutdown


## Builder NPC AI object
The builder NPC AI provides the logic how to build a building by NPC.
Basically an NPC get the next nearly buildable node from plan, and the method how to place,
but the navigation needs to be done in NPC Framework

### class-methods
  - npc_ai_obj = schemlib.npc_ai.new(plan_obj, build_distance)    - Constructor - create a new NPC AI handler for this plan. Build distance is the  lenght of npc

### object-methods
  - npc_ai_obj:plan_target_get(npcpos) - search for the next node to build near npcpos
  - npc_ai_obj:place_node(node_obj) - Place the node and remove from plan

    next methods internally used in plan_target_get
  - npc_ai_obj:get_if_buildable(node_obj)  - Check the node_obj if it can be built in the world. Compares if similar node already at the place
  - npc_ai_obj:get_node_rating(node, npcpos) - internally used - rate a node for importance to build at the next step
  - npc_ai_obj:prefer_target(npcpos, nodeslist) - Does rating of all nodes in nodeslist and returns the highest rated node

### object-attributes
  - npc_ai_obj.plan            - assigned plan
  - npc_ai_obj.lasttarget_name - name of the last placed node
  - npc_ai_obj.lasttarget_pos  - position of the last placed node
