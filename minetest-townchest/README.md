# TownChest

A minetest mod contains a chest with building definitions. The chest can spawn a NPC that does build the building for you.
The mod uses the schemlib framework to handle the buildings

![Screenshot](https://raw.github.com/bell07/minetest-townchest/master/screenshot.png)

## Features

- Building target from file
  - A Chest that allow you to choose a building and manage the building options
  - The most ".we", ".wem" or ".mts" files are supported. just put the file to the buildings directory
  - Flatting and cleanup the building place, remove all cruft-nodes from building inside
  - Cleanup unknown nodes
  - Ground level detection trough dirt_with_* nodes
  - Optimized for realy big buildings. Try the AMMOnym_coloseum.we as a showcase

- Building target configured
  - Some simple tasks implemented:
    - Fill with air
    - Fill with stone
    - Build a box
    - Build a plate

- Survival mode
  - TODO

- Creative mode
  - Instant build allow you to get the result instantly
  - Creative build by NPC without providing needed nodes

- Builder-NPC's
  - Multiple NPC's per building can be used (to get Clolseum in time you need ~50 NPC's oO)
  - NPC can change the assigned building if chest is stopped and an other active chest nearly

## Roadmap (not implemented yet)
- Survival mode
  - each NPC gets own inventory
  - build a node only if there is place in inventory for the old one and the new one is avialable in inventory
  - Use all nearly default:chest to store removed nodes (flatting) and to get nodes for building

- Node mapping support
  - a way to change the needed nodes (like in building defined default:wood but I like to use something from moretrees mod)
  - the mapping should be able to map the unknown nodes


## Vision / Ideas / maybe
- other chests that generates a plan. The generated plan can be the daily work of a lumberjack as example
- Architect-NPC instead of the chest to coordinate the build
- Interface (API) to allow other mods create own "Plan coordinator"'s

## Credits

# Code
- cornernote - towntest mod was used as template for townchest
- rubenwardy - take my smartfs enhancements upstream ready
               npcf_ng builder ousted the original towntest builder
- Sokomine   - handle_schematics is the base of hsl (=handle_schematics library)

# Buildings
- VanessaE - contributed buildings (towntest)
- kddekadenz - contributed buildings (towntest)
- ACDC - contributed buildings (towntest)
- Nanuk - contributed buildings (towntest) 
- irksomeduck - contributed buildings (towntest)
- AMMOnym_coloseum.we https://forum.minetest.net/viewtopic.php?p=121294#p121294
- PEAK_BremerHaus.we  https://forum.minetest.net/viewtopic.php?p=207103#p207103

- All contributions welcome!


## License 
BSD-3-Clause
