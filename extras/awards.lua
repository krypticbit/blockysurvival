awards.register_award("first_terumet", {
	title = "First terumetal",
	icon = "default_stone.png^terumet_ore_raw.png",
	trigger = {
		type = "dig",
		node = "terumet:ore_raw",
		target = 1,
	}
})

awards.register_award("first_terumet", {
	title = "Things are starting to get hot",
	icon = "terumet_asmelt_front_lit.png",
	trigger = {
		type = "craft",
		item = "terumet:mach_asmelt",
		target = 1,
	}
})

