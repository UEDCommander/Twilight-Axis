/obj/item/ammo_holder/twilight_bullet
	name = "кошель с патронами"
	desc = "Небольшой мешочек, в котором можно хранить пули для огнестрельного оружия."
	icon_state = "pouch0"
	item_state = "pouch"
	slot_flags = ITEM_SLOT_HIP|ITEM_SLOT_NECK
	max_storage = 30
	ammo_type = list(/obj/item/ammo_casing/caseless/twilight_lead, /obj/item/ammo_casing/caseless/twilight_runelock)

/obj/item/ammo_holder/twilight_bullet/runed/Initialize()
	. = ..()
	for(var/i in 1 to max_storage)
		var/obj/item/ammo_casing/caseless/twilight_runelock/R = new()
		ammo += R
	update_icon()

/obj/item/ammo_holder/twilight_bullet/lead/Initialize()
	. = ..()
	for(var/i in 1 to max_storage)
		var/obj/item/ammo_casing/caseless/twilight_lead/B = new()
		ammo += B
	update_icon()

/obj/item/ammo_holder/twilight_bullet/cannonball
	name = "кошель с ядрами"
	desc = "Небольшой мешочек, в котором можно хранить выстрелы для кулеврины."
	max_storage = 20
	ammo_type = list(/obj/item/ammo_casing/caseless/twilight_cannonball, /obj/item/ammo_casing/caseless/twilight_grapeshot)

/obj/item/ammo_holder/twilight_bullet/cannonball/lead/Initialize()
	. = ..()
	for(var/i in 1 to max_storage)
		var/obj/item/ammo_casing/caseless/twilight_cannonball/B = new()
		ammo += B
	update_icon()

/obj/item/ammo_holder/twilight_bullet/cannonball/grapeshot/Initialize()
	. = ..()
	for(var/i in 1 to max_storage)
		var/obj/item/ammo_casing/caseless/twilight_grapeshot/B = new()
		ammo += B
	update_icon()
