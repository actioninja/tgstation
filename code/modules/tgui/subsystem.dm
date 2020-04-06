/datum/controller/subsystem/tgui/proc/register_input(datum/source, mob/user, type, title, list/entries = list())
	if(!source || !user)
		return


	var/datum/tgui/ui = new(user, source, "input", "Input[type]", title, 300, 300, null, GLOB.always_state)

	var/list/options_list = list()

	for(var/entry in entries)
		if(istype(entry, /datum))
			options_list["[REF(entry)]"] = entry
		else
			options_list["[entry]"] = entry

	input_options_storage[ui.window_id] = options_list

	var/list/initial_data = list()
	if(length(options_list))
		initial_data["items"] = options_list
	ui.initial_data = initial_data
	ui.set_autoupdate(FALSE)
	ui.open()
	return ui

/datum/controller/subsystem/tgui/proc/receive_input_callback(datum/tgui/ui, result)
	input_results[ui.window_id] = result


/proc/tgui_input(datum/source, mob/user, title, type = TGUI_INPUT_TEXT, list/entries = list())
	if(!source || !user)
		return

	var/datum/tgui/ui = SStgui.register_input(source, user, type, title, entries)
	var/input_id = ui.window_id
	var/input_key = ui.ui_key
	var/source_ref = "[REF(source)]"

	//Safety because this proc is going to be sleeping
	//Likely uneeded but just in case
	ui = null

	UNTIL(SStgui.input_results[input_id] || (isnull(SStgui.open_uis[source_ref]) || isnull(SStgui.open_uis[source_ref][input_key])))

	var/result = SStgui.input_results[input_id]

	SStgui.input_results -= input_id
	ui = SStgui.get_open_ui(user, source, input_key)
	if(ui)
		ui.close()

	var/actual_thing = SStgui.input_options_storage[input_id][result]
	SStgui.input_options_storage -= input_id

	return actual_thing

