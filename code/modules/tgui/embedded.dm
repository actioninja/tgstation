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

	if(!winexists(owner, EMBED_WINDOW_NAME))
		set waitfor = FALSE
		broken = TRUE
		message_admins("Couldn't start chat for [key_name_admin(owner)]!")
		alert(owner.mob, "Updated chat window does not exist. If you are using a custom skin file please allow the game to update.")
		return FALSE

	if(winget(owner, EMBED_WINDOW_NAME, "is-visible") == "true") //Already setup
		//done_loading()
		return TRUE

	var/datum/asset/stuff = get_asset_datum(/datum/asset/group/tgui)
	stuff.send(owner)
	SStgui_embed.updating_clients += src

	var/html = replacetext(SStgui.basehtml, "\[ref]", EMBED_SRC_NAME)
	html = replacetext(html, "\[embedded]", "true")
	owner << browse(html, "window=[EMBED_WINDOW_NAME]")


/datum/tgui_embedded/proc/show_ui()
	winset(owner, EMBED_LEGACY_NAME, "is-visible=false")
	winset(owner, EMBED_WINDOW_NAME, "is-disabled=false;is-visible=true")

/datum/tgui_embedded/proc/get_json(list/data, list/static_data)
	var/list/json_data = list()

	json_data["config"] = list(
		"embedded" = TRUE,
		"screen" = "home",
		"window" = EMBED_WINDOW_NAME,
		"ref" = EMBED_SRC_NAME
	)

	if(!isnull(data))
		json_data["data"] = data
	if(!isnull(static_data))
		json_data["static_data"] = static_data

	// Generate the JSON.
	var/json = json_encode(json_data)
	// Strip #255/improper.
	json = replacetext(json, "\proper", "")
	json = replacetext(json, "\improper", "")
	return json

/datum/tgui_embedded/proc/send_data(list/data, list/static_data)
	owner << output(url_encode(get_json(data, static_data)), "[EMBED_WINDOW_NAME]:update")

/datum/tgui_embedded/Topic(href, list/href_list)
	//Make sure that the only person tampering with an interface is the user in question
	if(owner != usr.client)
		return

	var/action = href_list["action"]
	var/params = href_list
	params -= "action"

	switch(action)
		if("tgui:initialize")
			show_ui()
			owner << output(url_encode(get_json()), "[EMBED_WINDOW_NAME]:initialize")
			initialized = TRUE
		if("tgui:log")
			// Force window to show frills on fatal errors
			if(params["fatal"])
				winset(owner, EMBED_WINDOW_NAME, "titlebar=1;can-resize=1;size=600x600")
			//log_message(params["log"])
		if("tgui:link")
			owner << link(params["url"])
		//else
			//update_status(push = FALSE) // Update the window state.
			//if(src_object.ui_act(action, params, src, state)) // Call ui_act() on the src_object.
				//SStgui.update_uis(src_object) // Update if the object requested it.
