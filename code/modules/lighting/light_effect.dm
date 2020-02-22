/atom/movable/light
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	plane = LIGHTING_PLANE

	layer = 1
	//layer 1 = base plane layer
	//layer 2 = base shadow templates
	//layer 3 = wall lighting overlays
	//layer 4 = light falloff overlay
	//layer 5 = subtractive light layer

	icon_state = null

	alpha = 180

	appearance_flags = KEEP_TOGETHER
	invisibility = INVISIBILITY_LIGHTING
	pixel_x = -WORLD_ICON_SIZE*2
	pixel_y = -WORLD_ICON_SIZE*2
	glide_size = WORLD_ICON_SIZE
	blend_mode = BLEND_ADD
	anchored = TRUE

	var/current_power = 1
	var/atom/movable/holder
	var/point_angle
	var/list/affecting_turfs = list()
	var/list/temp_appearance

/atom/movable/light/New(newholder)
	holder = newholder
	if(istype(holder, /atom))
		var/atom/A = holder
		light_range = A.light_range
		light_color = A.light_color
		light_power = A.light_power
		light_type	= A.light_type
		color = light_color
	..(get_turf(holder))

/atom/movable/light/Destroy()
	transform = null
	appearance = null
	overlays = null
	temp_appearance = null

	if(light_range > 1)
		var/area/A = get_area(src)
		A.change_area_backlight(-(light_range - 1))

	if(holder)
		if(holder.light_obj == src)
			holder.light_obj = null
		holder = null
	for(var/turf/T in affecting_turfs)
		T.lumcount = -1
		T.affecting_lights -= src
	affecting_turfs.Cut()
	. = ..()

/atom/movable/light/Initialize()
	. = ..()
	RegisterSignal(src, COMSIG_ENTER_AREA, .proc/add_light_to_area)
	RegisterSignal(src, COMSIG_EXIT_AREA, .proc/remove_light_from_area)
	if(light_range > 1)
		var/area/A = get_area(src)
		A.change_area_backlight(light_range - 1)
	if(holder)
		follow_holder()

/atom/movable/light/proc/add_light_to_area(datum/source, area/A)
	if(light_range > 1)
		A.change_area_backlight(light_range - 1)

/atom/movable/light/proc/remove_light_from_area(datum/source, area/A)
	if(light_range > 1)
		A.change_area_backlight(-(light_range - 1))

// Applies power value to size (via Scale()) and updates the current rotation (via Turn())
// angle for directional lights. This is only ever called before cast_light() so affected turfs
// are updated elsewhere.
/atom/movable/light/proc/update_transform(newrange)
	if(!isnull(newrange) && current_power != newrange)
		current_power = newrange

// Orients the light to the holder's (or the holder's holder) current dir.
// Also updates rotation for directional lights when appropriate.
/atom/movable/light/proc/follow_holder_dir()
	if(holder.loc.loc && ismob(holder.loc))
		set_dir(holder.loc.dir)
	else
		set_dir(holder.dir)

// Moves the light overlay to the holder's turf and updates bleeding values accordingly.
/atom/movable/light/proc/follow_holder()
	if(GLOB.lighting_update_lights)
		if(holder && holder.loc)
			follow_holder_dir()

			if(isturf(holder))
				forceMove(holder, harderforce = TRUE)
			else if(holder.loc.loc && ismob(holder.loc))
				forceMove(holder.loc.loc, harderforce = TRUE)
			else
				forceMove(holder.loc, harderforce = TRUE)

			cast_light() // We don't use the subsystem queue for this since it's too slow to prevent shadows not being updated quickly enough
	else
		GLOB.init_lights |= src

/atom/movable/light/proc/set_dir(new_dir)
	if(dir != new_dir)
		dir = new_dir

	if(light_type == LIGHT_DIRECTIONAL)
		switch(dir)
			if(NORTH)
				pixel_x = -(world.icon_size * light_range) + world.icon_size / 2
				pixel_y = 0
			if(SOUTH)
				pixel_x = -(world.icon_size * light_range) + world.icon_size / 2
				pixel_y = -(world.icon_size * light_range) - world.icon_size * light_range + world.icon_size
			if(EAST)
				pixel_x = 0
				pixel_y = -(world.icon_size * light_range) + world.icon_size / 2
			if(WEST)
				pixel_x = -(world.icon_size * light_range) - (world.icon_size * light_range) + world.icon_size
				pixel_y = -(world.icon_size * light_range) + (world.icon_size / 2)

/atom/movable/light/proc/light_off()
	alpha = 0

/atom/movable/light/ex_act(severity)
	return 0

/atom/movable/light/singularity_act()
	return

/atom/movable/light/singularity_pull()
	return

/atom/movable/light/blob_act()
	return

/atom/movable/light/onTransitZ()
	return

// Override here to prevent things accidentally moving around overlays.
/atom/movable/light/forceMove(atom/destination, var/no_tp=FALSE, var/harderforce = FALSE)
	if(harderforce)
		. = ..()
