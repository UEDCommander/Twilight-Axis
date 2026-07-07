/*
 * Blood starvation rebalance adapted from Scarlet-Reach/Scarlet-Reach#1840.
 *
 * Thresholds scale off maxbloodpool (percentage) with an absolute floor and
 * cap, so low-cap vampires (vagabond/converted, 1000 max) are not permanently
 * starved, while high-cap vampires (lords) keep the original 1000/750/300 tiers.
 */

#define TA_VITAE_FED_PERCENT 0.30
#define TA_VITAE_FED_MIN 250
#define TA_VITAE_FED_CAP 1000
#define TA_VITAE_HUNGRY_RATIO 0.75
#define TA_VITAE_STARVING_RATIO 0.30
#define TA_VITAE_FRENZY_FLOOR 100

/datum/status_effect/debuff/ta_bloodstarved
	id = "ta_bloodstarved"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/ta_bloodstarved
	effectedstats = list(STATKEY_STR = -1, STATKEY_SPD = -1)
	duration = -1
	needs_processing = FALSE

/atom/movable/screen/alert/status_effect/debuff/ta_bloodstarved
	name = "Кровавый голод"
	desc = "Голод пульсирует внутри меня."
	icon_state = "bleed1"

/datum/status_effect/debuff/ta_bloodstarved/worse
	id = "ta_bloodstarved_worse"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/ta_bloodstarved/worse
	effectedstats = list(STATKEY_STR = -2, STATKEY_SPD = -2, STATKEY_CON = -1)

/atom/movable/screen/alert/status_effect/debuff/ta_bloodstarved/worse
	name = "Кровавый голод"
	desc = "Голод внутри меня неистово кричит."
	icon_state = "bleed2"

/datum/status_effect/debuff/ta_bloodstarved/worst
	id = "ta_bloodstarved_worst"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/ta_bloodstarved/worst
	effectedstats = list(STATKEY_STR = -3, STATKEY_SPD = -3, STATKEY_CON = -2)

/atom/movable/screen/alert/status_effect/debuff/ta_bloodstarved/worst
	name = "Кровавый голод"
	desc = "Я едва могу двигаться. Этот голод бесконечен."
	icon_state = "bleed3"

/mob/living/carbon/human/handle_bloodpool_effects()
	// Clear the old hydration statuses in case this mob was processed by the
	// upstream implementation before the modular override became active.
	remove_status_effect(/datum/status_effect/debuff/thirstyt1)
	remove_status_effect(/datum/status_effect/debuff/thirstyt2)
	remove_status_effect(/datum/status_effect/debuff/thirstyt3)

	var/max_vitae = max(maxbloodpool, 1)
	var/fed_level = clamp(round(max_vitae * TA_VITAE_FED_PERCENT), TA_VITAE_FED_MIN, TA_VITAE_FED_CAP)
	var/hungry_level = round(fed_level * TA_VITAE_HUNGRY_RATIO)
	var/starving_level = round(fed_level * TA_VITAE_STARVING_RATIO)

	if(bloodpool >= fed_level)
		remove_status_effect(/datum/status_effect/debuff/ta_bloodstarved)
		remove_status_effect(/datum/status_effect/debuff/ta_bloodstarved/worse)
		remove_status_effect(/datum/status_effect/debuff/ta_bloodstarved/worst)
	else if(bloodpool >= hungry_level)
		apply_status_effect(/datum/status_effect/debuff/ta_bloodstarved)
		remove_status_effect(/datum/status_effect/debuff/ta_bloodstarved/worse)
		remove_status_effect(/datum/status_effect/debuff/ta_bloodstarved/worst)
	else if(bloodpool >= starving_level)
		apply_status_effect(/datum/status_effect/debuff/ta_bloodstarved/worse)
		remove_status_effect(/datum/status_effect/debuff/ta_bloodstarved)
		remove_status_effect(/datum/status_effect/debuff/ta_bloodstarved/worst)
	else
		apply_status_effect(/datum/status_effect/debuff/ta_bloodstarved/worst)
		remove_status_effect(/datum/status_effect/debuff/ta_bloodstarved)
		remove_status_effect(/datum/status_effect/debuff/ta_bloodstarved/worse)
		if(prob(3))
			playsound(get_turf(src), pick('sound/vo/hungry1.ogg', 'sound/vo/hungry2.ogg', 'sound/vo/hungry3.ogg'), 100, TRUE, -1)

	if(bloodpool < TA_VITAE_FRENZY_FLOOR && prob(9))
		if(last_frenzy_check + 5 MINUTES < world.time)
			rollfrenzy()

#undef TA_VITAE_FED_PERCENT
#undef TA_VITAE_FED_MIN
#undef TA_VITAE_FED_CAP
#undef TA_VITAE_HUNGRY_RATIO
#undef TA_VITAE_STARVING_RATIO
#undef TA_VITAE_FRENZY_FLOOR
