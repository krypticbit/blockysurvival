
Extreme Survival Mobs MOD by Maikerumine, TenPlus1, And RND

Adds 40 "players" and creatures to your world that all have unique attributes, strengths, and rewards.  Quite fun!
Added weapons in hand so you can see your potential reward, as well as random items that might help you fight better.
There are some easy going NPC that will not attack you unless they are attacked.  They help with fighting monsters.
Mobs now drop bones like players, you will need to wait to grab your loot!

Good Luck!

Borrowed simpleskins for textures and the player model for player object.
Used a modified version of Mobs Redo code both api and init files, the mobs now wont get stuck and actually chase you now.

===========SIMPLE SKINS:============================

            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
                    Version 2, December 2004

 Copyright (C) 2004 Sam Hocevar <sam@hocevar.net>

 Everyone is permitted to copy and distribute verbatim or modified
 copies of this license document, and changing it is allowed as long
 as the name is changed.

            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION

  0. You just DO WHAT THE FUCK YOU WANT TO.

======================================

====MINETEST PATHFINDING====
RND created some clever pathfinding code and forked it in TenPlus1's mobs redo 1.26, which I have merged into ESMOBS.
https://forum.minetest.net/viewtopic.php?f=9&t=14030
and GIT:
https://github.com/ac-minetest/smart_mobs




===========MOBS REDO=============================
-= MOBS-MOD for MINETEST =-
by PilzAdam, KrupnovPavel, Zeg9 and TenPlus1


https://forum.minetest.net/viewtopic.php?f=9&t=9917

This mod contains the following additions:

- Giant Spiders (found in desert caves, drop string when killed)
- Bee's (found around flowers, drop honey when killed, right-click to pick up, also Beehives)
- Chicken (lays eggs, added fried egg, raw & cooked chicken, right-click to pick up)
- Cow (right-click with empty bucket to get bucket of milk, feed 8 wheat to replenish milk)
- Sheep (right-click for wool, feed 8 wheat to replenish wool)
- Warthog (the local pig that gives raw and cooked port)
- Rats (right-click to pick up and place, cook for a tasty treat)
- Sand, Dirt, Stone, Tree Monsters, Oerkki and Dungeon Masters as standard
- Lava Flan, Mese Monsters added to spice things up a bit
- Cook milk in furnace to get cheese wedge, 9 wedges make 1 cheese block

..with the following new features:

- Hitting a mob has knock-back effect like in minecraft, and with blood effect
- Mobs float in water, so monsters can still chase you
- Mobs can die from falling from a height
- Mobs have better health and drops
- Hitting a mob also puts them into fight mode (apart from animals)
- Compatible with Ethereal mod, mobs now spawn on ethereal worlds

Changelog:

0.8 - Added sounds to monster mobs (thanks Cyberpangolin for the sfx) and also chicken sound
0.7 - mobs.protected switch added to api.lua, when set to 1 mobs no longer spawn in protected areas, also bug fixes
0.6 - Api now supports multi-textured mobs, e.g oerkki, dungeon master, rats and chickens have random skins when spawning (sheep fix TODO), also new Honey block
0.5 - Mobs now float in water, die from falling, and some code improvements
0.4 - Dungeon Masters and Mese Monsters have much better aim due to shoot_offset, also they can both shoot through nodes that aren't walkable (flowers, grass etc) plus new sheep sound :)
0.3 - Added LOTT's Spider mob, made Cobwebs, added KPavel's Bee with Honey and Beehives (made texture), Warthogs now have sound and can be tamed, taming of shaved sheep or milked cow with 8 wheat so it will not despawn, many bug fixes :)
0.2 - Cooking bucket of milk into cheese now returns empty bucket
0.1 - Initial Release
========================================

===MC-LIKE MOBS===
Notes
-----

cows: right-click with empty bucket gets milk
sheep: right-click gets wool
chicken: right-click to get an egg

Milk and eggs need a food mod to be installed.

Textures are from Faithful 32x32 pack (http://www.minecraftforum.net/topic/72747-faithful-32x32-pack-updateocelot-two-cats-new-saplings-ctm-17/)

Sounds are from the Minecraft Wiki (Freesound license)

=====Pig=====(at layer 1)
=====Cow=====(at layer 2)
=====Sheep=====(at layer 3)

Ver.0.3
Mesh by Morn76
Animation by Pavel_S

===Chicken===
Mesh and animation by Pavel_S

Meshes : Pig, Cow, Sheep
Armatures : Pig_Rig, Cow_Rig, Sheep_Rig

==Animation==
Optimized for 24fps.
(the last frame equal to first in each animation)
The first frame of each animation is default pose.
=List of animations :
	standing (head bobbing slightly up and down) : 1-24
	walking : 24-50
	eating (head goes to the ground) : 50-79
		eating cycle : 58-73
	look around
		right : 79-99
		looking left pose : 89
		left : 99-119
		looking right pose : 109
	hurt (quick half jump with legs slightly crossed) : 119-155
	death (falls on left side) : 155-180

There is no delays for looking around and repeats for eating!

==Rig==
See Pig_Rig.png

==ChangeLog==
0.3
Added Cow, Sheep
Added Cow and Sheep animations
Fixed UVunwraps
Extended hurt and death animation

0.2
Added Pig animation
Fixed UVunwrap

=====Creeper=====
Ver.0.3
Mesh by Morn76
Animation by Pavel_S

Meshes : Creeper
Armatures : Creeper_Rig

==Animation==
Optimized for 24fps.
(the last frame equal to first in each animation)
The first frame of each animation is default pose.
=List of animations :
	standing : 1-25
	walking : 25-50
	look around
		right : 50-80
		looking left pose : 65
		left : 80-110
		looking right pose : 95
	hurt : 110-140
	death : 140-190

=====Skeleton=====
Ver.0.3
Mesh by Morn76
Animation by Pavel_S

Meshes : Skeleton
Armatures : Skeleton_Rig

==Animation==
Optimized for 30fps.
(the last frame equal to first in each animation)
The first frame of each animation is default pose.
=List of animations :
	standing (head bobbing slightly up and down) : 1-25
	walking : 25-50
	hurt (quick half jump with legs slightly crossed) : 85-117
	death (falls on left side) : 117-146

=====Zombie=====
Mesh by Morn76
Animation by Pavel_S

 1 - 24   - standing
24 - 48   - walking
48 - 64   - running
64 - 88   - hurm
88 - 120 - death

*******************************************************************************

Original "simple mobs" README follows

=== MOBS-MOD for MINETEST-C55 ===
by PilzAdam

Inroduction:
This mod adds some basic hostile and friendly mobs to the game.

How to install:
Unzip the archive an place it in minetest-base-directory/mods/minetest/
if you have a windows client or a linux run-in-place client. If you have
a linux system-wide instalation place it in ~/.minetest/mods/minetest/.
If you want to install this mod only in one world create the folder
worldmods/ in your worlddirectory.
For further information or help see:
http://wiki.minetest.com/wiki/Installing_Mods

How to use the mod:
See https://github.com/PilzAdam/mobs/wiki

For developers:
The API documentation is moved to https://github.com/PilzAdam/mobs/wiki/API

License:
Sourcecode: WTFPL (see below)
Grahpics: WTFPL (see below)
Models: WTFPL (by Pavel_S, see below)

See also:
http://minetest.net/

         DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
                    Version 2, December 2004

 Copyright (C) 2004 Sam Hocevar <sam@hocevar.net>

 Everyone is permitted to copy and distribute verbatim or modified
 copies of this license document, and changing it is allowed as long
 as the name is changed.

            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION

  0. You just DO WHAT THE FUCK YOU WANT TO.



=== MOBS-MOD for MINETEST-C55 ===
by PilzAdam

Inroduction:
This mod adds some basic hostile and friendly mobs to the game.

How to install:
Unzip the archive an place it in minetest-base-directory/mods/minetest/
if you have a windows client or a linux run-in-place client. If you have
a linux system-wide instalation place it in ~/.minetest/mods/minetest/.
If you want to install this mod only in one world create the folder
worldmods/ in your worlddirectory.
For further information or help see:
http://wiki.minetest.com/wiki/Installing_Mods

How to use the mod:
See https://github.com/PilzAdam/mobs/wiki

For developers:
The API documentation is moved to https://github.com/PilzAdam/mobs/wiki/API

License:
Sourcecode: WTFPL (see below)
Grahpics: WTFPL (see below)
Models: WTFPL (by Pavel_S, see below)

See also:
http://minetest.net/

         DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
                    Version 2, December 2004

 Copyright (C) 2004 Sam Hocevar <sam@hocevar.net>

 Everyone is permitted to copy and distribute verbatim or modified
 copies of this license document, and changing it is allowed as long
 as the name is changed.

            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION

  0. You just DO WHAT THE FUCK YOU WANT TO.
