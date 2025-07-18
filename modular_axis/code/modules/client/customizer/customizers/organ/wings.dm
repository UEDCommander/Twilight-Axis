/datum/customizer/organ/wings/aasimar
	customizer_choices = list(/datum/customizer_choice/organ/wings/aasimar)
	allows_disabling = TRUE
	default_disabled = TRUE

/datum/customizer_choice/organ/wings/aasimar
	name = "Angel Wings"
	organ_type = /obj/item/organ/wings/angel
	sprite_accessories = list(
		/datum/sprite_accessory/wings/feathery,
		/datum/sprite_accessory/wings/wide/featheralt1,
		/datum/sprite_accessory/wings/wide/featheralt2,
		/datum/sprite_accessory/wings/huge/angel
		)

/datum/sprite_accessory/wings/wide/featheralt1
	name = "Feathery Alt"
	icon_state = "featheryalt1"

/datum/sprite_accessory/wings/wide/featheralt2
	name = "Feathery Alt 2"
	icon_state = "featheryalt2"
