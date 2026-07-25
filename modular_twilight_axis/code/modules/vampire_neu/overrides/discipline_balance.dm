/datum/coven_power/potence/activate(atom/target)
	. = ..()
	if(level >= 4)
		ADD_TRAIT(owner, TRAIT_ARMOR_NOSPDCAP, TA_POTENCE_TRAIT_SOURCE)

/datum/coven_power/potence/deactivate(atom/target, direct)
	. = ..()
	if(level >= 4)
		REMOVE_TRAIT(owner, TRAIT_ARMOR_NOSPDCAP, TA_POTENCE_TRAIT_SOURCE)

	do_deactivation_notification()

/datum/coven_power/celerity/activate(atom/target)
	. = ..()
	if(. && (level < 4))
		qdel(owner.GetComponent(/datum/component/after_image))


