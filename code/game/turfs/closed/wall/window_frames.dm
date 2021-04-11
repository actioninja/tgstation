/turf/closed/wall/window_frame
	name = "window frame"
	desc = "A frame section to place a window on top.."
	icon = 'icons/turf/walls/windowframe_normal.dmi'
	icon_state = "windowframe_normal-0"
	base_icon_state = "windowframe_normal"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_WINDOWS)
	canSmoothWith = list(SMOOTH_GROUP_WINDOWS)
	opacity = FALSE
	density = TRUE
	blocks_air = FALSE
	flags_1 = RAD_NO_CONTAMINATE_1
	rad_insulation = null
	frill_icon = null
	var/has_grilles


/turf/closed/wall/window_frame/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/climbable)
	update_icon()

/turf/closed/wall/window_frame/update_overlays()
	. = ..()
	if(has_grilles)
		. += mutable_appearance('icons/turf/walls/windowframe_normal.dmi', "window_grille-0")


/turf/closed/wall/window_frame/grille
	has_grilles = TRUE
