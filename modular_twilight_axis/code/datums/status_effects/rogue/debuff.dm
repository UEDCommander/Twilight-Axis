/atom/movable/screen/alert/status_effect/emberwine
	name = "Aphrodisiac"
	desc = "The warmth is spreading through my body..."
	icon = 'modular_axis/icons/mob/screen_alert.dmi'
	icon_state = "emberwine"

/datum/status_effect/debuff/emberwine
	id = "emberwine"
	effectedstats = list("strength" = -1, "endurance" = -2, "speed" = -2, "intelligence" = -3)
	duration = 1 MINUTES
	alert_type = /atom/movable/screen/alert/status_effect/emberwine
