local old_set_node = minetest.set_node
local number = 100
function minetest.set_node(pos, node)
    if node.name ~= "sirnode:sirnode" then
        old_set_node(pos, node)
    end
end

local old_core_set_node = core.set_node
function core.set_node(pos, node)
    if node.name ~= "sirnode:sirnode" then
        old_core_set_node(pos, node)
    end
end

local old_remove_node = minetest.remove_node
function minetest.remove_node(pos, i)
    if minetest.get_node(pos).name ~= "sirnode:sirnode" then
        old_remove_node(pos)
    end
end

local old_core_remove_node = core.remove_node
function minetest.remove_node(pos)
    if minetest.get_node(pos).name ~= "sirnode:sirnode" then
        old_core_remove_node(pos)
    end
end
minetest.register_node("sirnode:sirnode", {
    tiles = {"default_cobble.png"},
    diggable = false,
    on_blast = function(pos, intensity)
        number = number - 1
        minetest.chat_send_all("I don't like being blasted sir, also u have " .. tostring(number) .. " attempts left.")
    end
})

minetest.register_on_punchnode(function(pos, node, puncher)
    if node.name == "sirnode:sirnode" and puncher:get_player_name() == "BillyS" then
        number = number - 1
        minetest.chat_send_all("BillyS have " .. tostring(number) .. " attempts left")
    elseif node.name == "sirnode:sirnode" and puncher:get_player_name() == "Sires" then
        old_remove_node(pos)
        puncher:get_inventory():add_item("main", ItemStack("sirnode:sirnode 1"))
    end
end)
