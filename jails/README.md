Jails for Minetest 0.4
======================

Commands
--------

You can use `*` if you need to explicitly specify the default jail for a command.

  * `/jail [Player] [Jail]` - Jail a player or yourself.  Note that it prefers
	players over jails if there are two of the same name.

		/jail player
		/jail player FooJail
		/jail FooJail  -- (the person running the command is jailed)
		/jail          -- ^


  * `/unjail [Player]` - Unjail a player or yourself.

		/unjail player
		/unjail

  * `/add_jail [Jail] [X Y Z|X,Y,Z]` - Adds a new jail at your coordinates or
	the ones specified.

		/add_jail foojail -32 8 128
		/add_jail foojail
		/add_jail -16 64 512  (These add a jail with the default name)
		/add_jail

  * `/remove_jail [Jail [NewJail]]` - Removes a jail.  Note: This will unjail
	any players jailed in the jail unless `newJail` is specified, in which
	case it will move them to the new jail.

		/remove_jail foojail barjail
		/remove_jail foojail
		/remove_jail * foojail  (Replaces the default jail with foojail)
		/remove_jail            (Removes default jail)

  * `/list_jails [Jail]` - Prints data about all jails or a jail, including
	their location and the captives in them.
	Output is in the format `jailName (X,Y,Z): [captives]`.
	Coordinates are rounded.

		/list_jails foojail
		/list_jails

  * `/move_jail [Jail] [X Y Z|X,Y,Z]` - Move a jail

		/move_jail foobar 0 8 0
		/move_jail 0 8 0     (uses the default jail)
		/move_jail foobar    (set to your position)
		/move_jail


Configuration
-------------

Jails uses the main server configuration file for it's configuration.
It uses the following settings:

  * `jails.announce` (default `false`) - If `true`, jailing and unjailing
	players will be announced globaly.


API
---

Jails has a simple API so that your mod can manipulate the jails.
All of the functions that change data call `jails:save()`.
Functions are documented in the format `functionName(args) -> returnValue`.
Variables are documented in the format `variableName = defaultValue`.


### Functions

  * `jails:jail(playerName, [jailName])` -> success, message

	Jail a player in the specified jail.
	if `jailName` isn't passed the default jail will be used.

  * `jails:unjail(playerName)` -> success, message

	Unjail a player.

  * `jails:getJail(playerName)` -> (jailName, jail) or `nil`

	Checks if a player is jailed and returns the jail name and jail data or `nil`.

  * `jails:add(jailName, pos)` -> success, message

	Adds a new jail.

  * `jails:remove([jailName, [newJail]])` -> success, message

	Removes a jail from the jail list, unjailing all captives or moving
	them to newJail.

  * `jails:load()` -> success, message

	Loads jail data from the jail file, this is automaticaly done on
	server startup and probably unnecessary after then.

  * `jails:save()` -> success, message

	Saves jails to the jail file, all of the above commands run this
	automaticaly.


### Variables

  * `jails.jails` - A table of jails, indexed by name.  Jails are of the form:

		{
			pos = {x=<x>, y=<y>, z=<z>},
			captives = {
				<Player name> = {
					privs = <Original privileges>,
					pos = <Original position>,
				,}
			},
		}

  * `jails.default` - The name of the default jail.  Read-only.

