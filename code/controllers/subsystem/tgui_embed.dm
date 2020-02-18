SUBSYSTEM_DEF(tgui_embed)
	name = "TGUI Embedded"
	wait = 10
	priority = FIRE_PRIORITY_TGUI_EMBED
	flags = SS_NO_INIT
	runlevels = RUNLEVEL_LOBBY | RUNLEVEL_SETUP | RUNLEVEL_GAME | RUNLEVEL_POSTGAME

	var/list/updating_clients = list()
	var/list/mc_data = list()

/datum/controller/subsystem/tgui_embed/proc/update_mc_info()
	//TODO: put this in per thing whatever idk
	//mc_data["Location"] =
	mc_data["CPU"] = world.cpu
	mc_data["Instances"] = num2text(world.contents.len, 10)
	mc_data["World Time"] = world.time


/datum/controller/subsystem/tgui_embed/fire(resumed = FALSE)
	update_mc_info()
	for(var/c in updating_clients)
		var/datum/tgui_embedded/embed = c
		var/client/owner = embed.owner

		var/list/data = list()
		data["tabs"] = list()
		if(owner.holder)
			data["tabs"] += list(list(
				"name" = "MC",
				"contents" = mc_data
			))
		embed.send_data(data)
