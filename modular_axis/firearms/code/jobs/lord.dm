/datum/outfit/job/roguetown/lord/pre_equip(mob/living/carbon/human/H)
	. = ..()
	H.adjust_skillrank(/datum/skill/combat/twilight_firearms, 3, TRUE)
	backpack_contents += /obj/item/storage/keyring/lord
	backpack_contents += /obj/item/twilight_powderflask
	beltl = /obj/item/gun/ballistic/twilight_firearm/arquebus_pistol
	beltr = /obj/item/ammo_holder/twilight_bullet/lead
