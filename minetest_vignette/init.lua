function add_vignette(name)
    local player = minetest.get_player_by_name(name)
    if not player then return end
    player:hud_add({
        hud_elem_type = "image",
        position = {x = 0.5, y = 0.5},
        scale = {
            x = -100,
            y = -100
        },
        text = "vignette.png"
    })
end

minetest.register_chatcommand("add_vignette", {
    params = "",
    description = "Enables vignette to the player",
    func = add_vignette,
})
