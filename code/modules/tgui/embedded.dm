#define TGUI_EMBED_NAME "browserinfo"
#define LEGACY_INFO_NAME "info"

/datum/tgui_embedded
	var/client/owner
	var/initialized = FALSE
	var/broken = TRUE

/datum/tgui_embedded/New(client/C)
	owner = C

/datum/tgui_embedded/proc/initialize()
	//If there's no owner something is very wrong, abort
	if(!owner)
		return FALSE

	if(!winexists(owner, TGUI_EMBED_NAME))
		set waitfor = FALSE
		broken = TRUE
		message_admins("Couldn't start chat for [key_name_admin(owner)]!")
		alert(owner.mob, "Updated chat window does not exist. If you are using a custom skin file please allow the game to update.")
		return FALSE

	if(winget(owner, TGUI_EMBED_NAME, "is-visible") == "true") //Already setup
		done_loading()
		return TRUE

	var/datum/asset/stuff = get_asset_datum(/datum/asset/group/tgui)
	stuff.send(owner)

	owner << browse(SStgui.basehtml, "window=[TGUI_EMBED_NAME]")
	done_loading()

/datum/tgui_embedded/proc/done_loading()
	if(initialized)
		return TRUE

	initialized = TRUE
	show_ui()

/datum/tgui_embedded/proc/show_ui()
	winset(owner, LEGACY_INFO_NAME, "is-visible=false")
	winset(owner, TGUI_EMBED_NAME, "is-disabled=false;is-visible=true")
