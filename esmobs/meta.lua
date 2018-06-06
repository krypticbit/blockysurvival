--esmobs v0.1.0
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

esmobs.meta = {}
for _, i in ipairs(esmobs.list) do
	esmobs.meta[i] = {}
	local f = io.open(esmobs.modpath.."/meta/"..i..".txt")
	local data = nil
	if f then
		data = minetest.deserialize("return {"..f:read('*all').."}")
		f:close()
	end
	data = data or {}
	esmobs.meta[i].name = data.name or ""
	esmobs.meta[i].type = data.type or ""
	esmobs.meta[i].hp = data.hp or ""
	esmobs.meta[i].drops = data.drops or ""
	esmobs.meta[i].info = data.info or ""
end
