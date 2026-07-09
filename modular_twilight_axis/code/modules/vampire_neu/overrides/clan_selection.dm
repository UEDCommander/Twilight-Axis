/*
 * Masquerade vampires should never be forced to reveal themselves just to pick
 * a clan. Closing the clan menu without choosing no longer force-assigns a
 * default clan; a big glowing bat-icon button (granted the moment the menu is
 * first shown, removed once a clan is actually picked) lets them retreat
 * somewhere private and reopen it whenever they're ready. Once a clan IS
 * chosen, the vampire's default appearance is disguised (mortal) rather than
 * revealed.
 */
#define VAMPIRE_CHOOSE_CLAN_ALERT_CATEGORY "vampire_choose_clan"

/atom/movable/screen/alert/vampire_choose_clan
	name = "Выбор клана"
	desc = "Выберите клан вампиров, когда будете готовы. Нажмите, чтобы открыть меню."
	icon = 'icons/mob/actions/roguespells.dmi'
	icon_state = "bat_transform"
	alert_group = ALERT_BUFF
	plane = ABOVE_HUD_PLANE
	layer = ABOVE_HUD_LAYER

/atom/movable/screen/alert/vampire_choose_clan/Click(location, control, params)
	var/mob/living/carbon/human/user = usr
	if(!istype(user) || !user.client)
		return
	if(user.alerts[VAMPIRE_CHOOSE_CLAN_ALERT_CATEGORY] != src)
		return
	user.vampire_choose_clan_verb()

/mob/living/carbon/human/proc/vampire_show_choose_clan_button()
	if(!client || !hud_used)
		return FALSE
	var/atom/movable/screen/alert/vampire_choose_clan/alert = throw_alert(VAMPIRE_CHOOSE_CLAN_ALERT_CATEGORY, /atom/movable/screen/alert/vampire_choose_clan)
	if(!istype(alert))
		return FALSE
	alert.transform = alert.transform.Scale(1.8, 1.8)
	alert.add_filter("vampire_clan_glow", 2, list("type" = "outline", "size" = 1, "color" = "#8b1a3a"))
	animate(alert, alpha = 150, time = 8 SECONDS, loop = -1, flags = ANIMATION_PARALLEL, easing = SINE_EASING)
	animate(alpha = 255, time = 8 SECONDS, easing = SINE_EASING)
	return TRUE

/mob/living/carbon/human/proc/vampire_clear_choose_clan_button()
	if(alerts && alerts[VAMPIRE_CHOOSE_CLAN_ALERT_CATEGORY])
		clear_alert(VAMPIRE_CHOOSE_CLAN_ALERT_CATEGORY)

/datum/vampire_clan_selection_menu/ui_close(mob/user)
	qdel(src)

/datum/vampire_clan_selection_menu/ui_act(action, list/params)
	if(action == "close")
		SStgui.close_uis(src)
		qdel(src)
		return TRUE
	return ..()

/datum/antagonist/vampire/show_clan_selection(mob/living/carbon/human/vampdude)
	. = ..()
	if(!vampdude)
		return
	add_verb(vampdude, /mob/living/carbon/human/proc/vampire_choose_clan_verb)
	vampdude.vampire_show_choose_clan_button()

/datum/antagonist/vampire/after_gain()
	. = ..()
	var/mob/living/carbon/human/vampdude = owner?.current
	if(!istype(vampdude))
		return
	remove_verb(vampdude, /mob/living/carbon/human/proc/vampire_choose_clan_verb)
	vampdude.vampire_clear_choose_clan_button()
	var/datum/component/vampire_disguise/disguise_comp = vampdude.GetComponent(/datum/component/vampire_disguise)
	disguise_comp?.apply_disguise(vampdude)

/mob/living/carbon/human/proc/vampire_choose_clan_verb()
	set name = "Choose Clan"
	set category = "RoleUnique.Vampire"

	var/datum/antagonist/vampire/vamp_antag = mind?.has_antag_datum(/datum/antagonist/vampire)
	if(!vamp_antag)
		to_chat(src, span_warning("I have no clan to choose."))
		return
	if(vamp_antag.clan_selected)
		to_chat(src, span_warning("I have already sworn myself to a clan."))
		return
	vamp_antag.show_clan_selection(src)

#undef VAMPIRE_CHOOSE_CLAN_ALERT_CATEGORY
