GLOBAL_LIST_EMPTY(lighting_update_lights)
GLOBAL_LIST_EMPTY(init_lights)

SUBSYSTEM_DEF(lighting)
	name = "Lighting"
	wait = 1
	init_order = INIT_ORDER_LIGHTING
	flags = SS_TICKER

	var/resuming = FALSE
	var/list/currentrun_lights

/datum/controller/subsystem/lighting/stat_entry()
	..("L:[length(GLOB.lighting_update_lights)] queued")


/datum/controller/subsystem/lighting/Initialize(timeofday)
	for(var/atom/movable/light/L in GLOB.init_lights)
		if(L && !QDELETED(L))
			L.cast_light(TRUE)
	GLOB.init_lights = null
	initialized = TRUE

	return ..()

/datum/controller/subsystem/lighting/fire(resumed=FALSE)
	if(!resuming)
		currentrun_lights = GLOB.lighting_update_lights
		GLOB.lighting_update_lights = list()
	resuming = TRUE

	while (currentrun_lights.len)
		var/atom/movable/light/L = currentrun_lights[currentrun_lights.len]
		currentrun_lights.len--

		if(L && !QDELETED(L))
			L.cast_light(TRUE)

		if (MC_TICK_CHECK)
			return

	resuming = FALSE

/datum/controller/subsystem/lighting/Recover()
	initialized = SSlighting.initialized
	..()
