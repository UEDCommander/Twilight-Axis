/datum/spawners_menu
	var/mob/dead/observer/owner

/datum/spawners_menu/New(mob/dead/observer/new_owner)
	if(!istype(new_owner))
		qdel(src)
	owner = new_owner

/datum/spawners_menu/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SpawnersMenu", "Spawners Menu", 700, 600)
		ui.set_state(GLOB.observer_state)
		ui.open()

/datum/spawners_menu/ui_data(mob/user)
	var/list/data = list()
	data["spawners"] = list()
	for(var/spawner in GLOB.mob_spawners)
		var/list/this = list()
		this["name"] = spawner
		this["desc"] = ""
		this["refs"] = list()
		for(var/spawner_obj in GLOB.mob_spawners[spawner])
			this["refs"] += "[REF(spawner_obj)]"
			if(!this["desc"])
				if(istype(spawner_obj, /obj/effect/mob_spawn))
					var/obj/effect/mob_spawn/MS = spawner_obj
					this["desc"] = MS.flavour_text
				else
					var/obj/O = spawner_obj
					this["desc"] = O.desc
		this["amount_left"] = LAZYLEN(GLOB.mob_spawners[spawner])
		data["spawners"] += list(this)

	return data

/datum/spawners_menu/ui_act(action, params)
	if(..())
		return

	var/group_name = params["name"]
	if(!group_name || !(group_name in GLOB.mob_spawners))
		return
	var/list/spawnerlist = GLOB.mob_spawners[group_name]
	if(!spawnerlist.len)
		return
	var/obj/effect/mob_spawn/MS = pick(spawnerlist)
	if(!istype(MS) || !(MS in GLOB.poi_list))
		return
	switch(action)
		if("jump")
			if(MS)
				owner.forceMove(get_turf(MS))
				. = TRUE
		if("spawn")
			if(MS)
				MS.attack_ghost(owner)
				. = TRUE
