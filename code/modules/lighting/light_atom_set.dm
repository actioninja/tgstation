// Destroys and removes a light; replaces previous system's kill_light().
/atom/proc/kill_light()
	if(light_obj)
		qdel(light_obj)
		light_obj = null
	return

// Updates all appropriate lighting values and then applies all changed values
// to the objects light_obj overlay atom.
/atom/proc/set_light(l_range, l_power, l_color, l_type, fadeout)

	var/old_range = l_range

	if(!loc)
		if(light_obj)
			qdel(light_obj)
			light_obj = null
		return

	// Update or retrieve our variable data.
	if(isnull(l_range))
		l_range = light_range
	else
		light_range = l_range
	if(isnull(l_power))
		l_power = light_power
	else
		light_power = l_power
	if(isnull(l_color))
		l_color = light_color
	else
		light_color = l_color
	if(isnull(l_type))
		l_type = light_type
	else
		light_type = l_type

	var/diff = light_range - old_range
	var/area/A = get_area(src)
	A.change_area_backlight(diff)

	// Apply data and update light casting/bleed masking.
	var/update_cast
	if(!light_obj)
		update_cast = TRUE
		light_obj = new(src)

	if(light_obj.light_range != l_range)
		update_cast = TRUE
		light_obj.light_range = l_range

	if(light_obj.light_power != l_power)
		update_cast = TRUE
		light_obj.light_power = l_power

	if(light_obj.light_color != l_color)
		update_cast = TRUE
		light_obj.light_color = l_color
		light_obj.color = l_color

	if(light_obj.current_power != l_range)
		update_cast = TRUE
		light_obj.update_transform(l_range)

	if(light_obj.light_type != l_type)
		update_cast = TRUE
		light_obj.light_type = l_type

	if(!light_obj.alpha)
		update_cast = TRUE

	// Makes sure the obj isn't somewhere weird (like inside the holder). Also calls bleed masking.
	if(update_cast)
		light_obj.follow_holder()

	// Rare enough that we can probably get away with calling animate().
	if(fadeout)
		animate(light_obj, alpha = 0, time = fadeout)





/atom/movable/light/set_light()
	return
