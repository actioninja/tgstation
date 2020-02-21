/atom/movable/light_shadow_mask
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	appearance_flags = KEEP_TOGETHER
	icon_state = "blank"
	glide_size = 256

/atom/movable/light_shadow_mask/Initialize(mapload)
	. = ..()
	render_target = "*[ref(src)]"

/atom/movable/light_shadow_mask/proc/cast_shadows(a_turfs, atom/movable/light_wall_mask/wall_mask)
	//Local var for UNCONTROLLABLE SPEEEEED
	var/list/affecting_turfs = a_turfs

	var/list/temp_wall_overlays = list()

	vis_contents = list()
	for(var/turf/target_turf in affecting_turfs)
		var/occluded
		CHECK_OCCLUSION(occluded, target_turf)
		if(!occluded)
			continue

		//get the x and y offsets for how far the target turf is from the light
		var/x_offset = target_turf.x - x
		var/y_offset = target_turf.y - y

		var/shadowkey = "[x_offset]:[y_offset]:[light_range]"
		var/obj/effect/overlay/light_shadow/currentLS = GLOB.lighting_shadow_cache[shadowkey]
		if(!currentLS)
			var/num = 1
			if((abs(x_offset) > 0 && !y_offset) || (abs(y_offset) > 0 && !x_offset))
				num = 2


			//due to only having one set of shadow templates, we need to rotate and flip them for up to 8 different directions
			//first check is to see if we will need to "rotate" the shadow template
			var/xy_swap = 0
			if(abs(x_offset) > abs(y_offset))
				xy_swap = 1

			var/shadowoffset = 16 + 32 * light_range


			//due to the way the offsets are named, we can just swap the x and y offsets to "rotate" the icon state

			var/shadowicon
			switch(light_range)
				if(2)
					if(num == 1)
						shadowicon = 'icons/lighting/light_range_2_shadows1.dmi'
					else
						shadowicon = 'icons/lighting/light_range_2_shadows2.dmi'
				if(3)
					if(num == 1)
						shadowicon = 'icons/lighting/light_range_3_shadows1.dmi'
					else
						shadowicon = 'icons/lighting/light_range_3_shadows2.dmi'
				if(4)
					if(num == 1)
						shadowicon = 'icons/lighting/light_range_4_shadows1.dmi'
					else
						shadowicon = 'icons/lighting/light_range_4_shadows2.dmi'
				if(5)
					if(num == 1)
						shadowicon = 'icons/lighting/light_range_5_shadows1.dmi'
					else
						shadowicon = 'icons/lighting/light_range_5_shadows2.dmi'
				if(6)
					if(num == 1)
						shadowicon = 'icons/lighting/light_range_6_shadows1.dmi'
					else
						shadowicon = 'icons/lighting/light_range_6_shadows2.dmi'
				if(7)
					if(num == 1)
						shadowicon = 'icons/lighting/light_range_7_shadows1.dmi'
					else
						shadowicon = 'icons/lighting/light_range_7_shadows2.dmi'

			currentLS = new(null)
			currentLS.icon = shadowicon
			//I = GLOB.lighting_shadow_icon_cache[shadowicon]
			//if (!I)
				//I = image(shadowicon)
				//I.layer = 2
				//GLOB.lighting_shadow_icon_cache[shadowicon] = new /mutable_appearance(I)

			if(xy_swap)
				currentLS.icon_state = "[abs(y_offset)]_[abs(x_offset)]"
			else
				currentLS.icon_state = "[abs(x_offset)]_[abs(y_offset)]"


			var/matrix/M = matrix()

			//TODO: rewrite this comment:
			//using scale to flip the shadow template if needed
			//horizontal (x) flip is easy, we just check if the offset is negative
			//vertical (y) flip is a little harder, if the shadow will be rotated we need to flip if the offset is positive,
			// but if it wont be rotated then we just check if its negative to flip (like the x flip)
			var/x_flip
			var/y_flip
			if(xy_swap)
				x_flip = y_offset > 0 ? -1 : 1
				y_flip = x_offset < 0 ? -1 : 1
			else
				x_flip = x_offset < 0 ? -1 : 1
				y_flip = y_offset < 0 ? -1 : 1

			M.Scale(x_flip, y_flip)

			//here we do the actual rotate if needed
			if(xy_swap)
				M.Turn(90)

			//warning: you are approaching shitcode (this is where we move the shadow to the correct quadrant based on its rotation and flipping)
			//shadows are only as big as a quarter or half of the light for optimization

			//please for the love of god change this if there's a better way

			if(num == 1)
				if((x_flip == 1 && y_flip == 1 && xy_swap == 0) || (x_flip == -1 && y_flip == 1 && xy_swap == 1))
					M.Translate(shadowoffset, shadowoffset)
				else if((x_flip == 1 && y_flip == -1 && xy_swap == 0) || (x_flip == 1 && y_flip == 1 && xy_swap == 1))
					M.Translate(shadowoffset, 0)
				else if((xy_swap == 0 && x_flip == -y_flip) || (xy_swap == 1 && x_flip == -1 && y_flip == -1))
					M.Translate(0, shadowoffset)
			else
				if(x_flip == 1 && y_flip == 1 && xy_swap == 0)
					M.Translate(0, shadowoffset)
				else if(x_flip == 1 && y_flip == 1 && xy_swap == 1)
					M.Translate(shadowoffset / 2, shadowoffset / 2)
				else if(x_flip == 1 && y_flip == -1 && xy_swap == 1)
					M.Translate(-shadowoffset / 2, shadowoffset / 2)

			//apply the transform matrix
			currentLS.transform = M

			//and add it to the lights overlays
			GLOB.lighting_shadow_cache[shadowkey] = currentLS
		vis_contents += currentLS

		var/targ_dir = get_dir(target_turf, src)

		var/blocking_dirs = 0
		for(var/d in GLOB.cardinals)
			var/turf/T = get_step(target_turf, d)
			occluded= FALSE
			CHECK_OCCLUSION(occluded, T)
			if(occluded)
				blocking_dirs |= d

		var/lwc_key = "[blocking_dirs]-[targ_dir]"
		var/mutable_appearance/I = GLOB.lighting_wall_cache[lwc_key]
		if (!I)
			I = image('icons/lighting/wall_lighting.dmi')
			I.layer = 3
			I.icon_state = lwc_key
			GLOB.lighting_wall_cache[lwc_key] = new /mutable_appearance(I)

		I.pixel_x = (world.icon_size * light_range) + (x_offset * world.icon_size)
		I.pixel_y = (world.icon_size * light_range) + (y_offset * world.icon_size)
		temp_wall_overlays += I.appearance
	wall_mask.overlays = temp_wall_overlays

/atom/movable/light_shadow_mask/ex_act(severity)
	return 0

/atom/movable/light_shadow_mask/singularity_act()
	return

/atom/movable/light_shadow_mask/singularity_pull()
	return

/atom/movable/light_shadow_mask/blob_act()
	return

/atom/movable/light_shadow_mask/onTransitZ()
	return

/atom/movable/light_wall_mask
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	appearance_flags = KEEP_TOGETHER
	icon_state = "blank"
	glide_size = 256

/atom/movable/light_wall_mask/Initialize(mapload)
	. = ..()
	render_target = "*[ref(src)]"


/atom/movable/light_wall_mask/ex_act(severity)
	return 0

/atom/movable/light_wall_mask/singularity_act()
	return

/atom/movable/light_wall_mask/singularity_pull()
	return

/atom/movable/light_wall_mask/blob_act()
	return

/atom/movable/light_wall_mask/onTransitZ()
	return

/obj/effect/overlay/light_shadow
	name = "light_shadow"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
