/*
 * Presence intelligence scaling adapted from Scarlet-Reach/Scarlet-Reach#1616.
 *
 * Keeps the current upstream effects, but scales whether they fully land by
 * the intelligence gap instead of rejecting strong targets outright.
 */

/datum/coven_power/presence/proc/ta_intelligence_difference(mob/living/carbon/human/target)
	return owner.STAINT - target.STAINT

/datum/coven_power/presence/proc/ta_apply_presence_overlay(mob/living/carbon/human/target)
	target.remove_overlay(MUTATIONS_LAYER)
	var/mutable_appearance/presence_overlay = mutable_appearance('icons/effects/clan.dmi', "presence", -MUTATIONS_LAYER)
	presence_overlay.pixel_z = 1
	target.overlays_standing[MUTATIONS_LAYER] = presence_overlay
	target.apply_overlay(MUTATIONS_LAYER)

/datum/coven_power/presence/proc/ta_apply_resisted_effect(mob/living/carbon/human/target, difference)
	switch(difference)
		if(-INFINITY to -3)
			to_chat(target, span_love("<b>Я на мгновение замираю.</b>"))
			target.visible_message(span_warning("[target] на мгновение замирает."))
			target.Immobilize(2 SECONDS)
		if(-2)
			to_chat(target, span_love("<b>Я сопротивляюсь приказу.</b>"))
			target.visible_message(span_warning("[target] сопротивляется незримому приказу."))
			target.Immobilize(3 SECONDS)
		if(-1)
			to_chat(target, span_love("<b>Мир на мгновение застилает туман.</b>"))
			target.visible_message(span_warning("[target] на мгновение выглядит ошеломлённо."))
			target.Immobilize(4 SECONDS)
		else
			return FALSE
	return TRUE

/datum/coven_power/presence/awe
	cooldown_length = 30 SECONDS

/datum/coven_power/presence/awe/pre_activation_checks(mob/living/target)
	if(!can_affect_target(target))
		return FALSE
	if(HAS_TRAIT(target, TRAIT_DETACHED))
		to_chat(owner, span_warning("Разум [target] — пустая бездна, в которой нет чувств, подвластных моему Присутствию."))
		return FALSE
	return TRUE

/datum/coven_power/presence/awe/activate(mob/living/carbon/human/target)
	. = ..()
	ta_apply_presence_overlay(target)

	var/difference = ta_intelligence_difference(target)
	if(ta_apply_resisted_effect(target, difference))
		return

	playsound(target, 'sound/villain/wonder.ogg', 40)
	target.apply_status_effect(/datum/status_effect/awestruck, owner)
	if(!owner.cmode)
		to_chat(target, span_love("<b>Подойди ближе и взгляни на меня.</b>"))
		owner.say("Взгляни на меня.")
	else
		to_chat(target, span_love("<b>ВЗГЛЯНИ НА МЕНЯ!!</b>"))
		owner.say("ВЗГЛЯНИ НА МЕНЯ!!")

/datum/coven_power/presence/dread_gaze
	cooldown_length = 30 SECONDS

/datum/coven_power/presence/dread_gaze/activate(mob/living/carbon/human/target)
	. = ..()
	ta_apply_presence_overlay(target)

	var/difference = ta_intelligence_difference(target)
	if(ta_apply_resisted_effect(target, difference))
		return

	to_chat(target, span_love("<b>БОЙСЯ МЕНЯ</b>"))
	owner.say("БОЙСЯ МЕНЯ!!")
	var/datum/cb = CALLBACK(target, TYPE_PROC_REF(/mob/living/carbon/human, step_away_caster), owner)
	for(var/i in 1 to 30)
		addtimer(cb, (i - 1) * target.total_multiplicative_slowdown())
	target.freak_out()
	to_chat(target, span_love("<b>БОГИ, СПАСИТЕ МЕНЯ!</b>"))
	playsound(target, 'sound/villain/wonder.ogg', 40)

/datum/coven_power/presence/fall/activate(mob/living/carbon/human/target)
	. = ..()
	ta_apply_presence_overlay(target)

	var/difference = ta_intelligence_difference(target)
	if(ta_apply_resisted_effect(target, difference))
		return

	target.Immobilize(4 SECONDS)
	to_chat(target, span_love("<b>НА КОЛЕНИ</b>"))
	to_chat(target, span_love("<b>МОЙ НОВЫЙ БОГ!</b>"))
	playsound(target, 'sound/villain/wonder_secret_known.ogg', 40)
	owner.say("НА КОЛЕНИ!!")
	target.set_resting(TRUE, TRUE)

/datum/coven_power/presence/majesty
	vitae_cost = 125

/datum/coven_power/presence/majesty/apply_majesty_effect(mob/living/target)
	if(!can_affect_target(target))
		return

	affected_mobs |= target
	target.apply_status_effect(/datum/status_effect/majesty_compulsion, owner)

	if(prob(70))
		if(target.get_active_held_item())
			target.visible_message(span_warning("[target] не выдерживает Присутствия [owner]!"))
			target.dropItemToGround(target.get_active_held_item())

		target.stop_pulling()
		if(target.cmode)
			target.toggle_cmode()

/*
 * Majesty's item hooks do not cover unarmed attacks or kicks.
 * Keep both protections on the modular status effects.
 */

/datum/status_effect/majesty_active/on_apply()
	. = ..()
	RegisterSignal(owner, COMSIG_PARENT_ATTACKBY, PROC_REF(on_attackby))
	RegisterSignal(owner, COMSIG_MOB_ATTACKED_BY_HAND, PROC_REF(ta_on_unarmed_attack))

/datum/status_effect/majesty_active/on_remove()
	. = ..()
	UnregisterSignal(owner, list(COMSIG_PARENT_ATTACKBY, COMSIG_MOB_ATTACKED_BY_HAND))

/datum/status_effect/majesty_active/proc/ta_on_unarmed_attack(mob/living/source, mob/living/carbon/human/attacker, mob/living/carbon/human/defender, datum/martial_art/attacker_style)
	SIGNAL_HANDLER
	if(!attacker || attacker == source || !istype(attacker.used_intent, INTENT_HARM))
		return
	if(!attacker.has_status_effect(/datum/status_effect/majesty_compulsion))
		return
	if(!prob(80))
		return

	to_chat(attacker, span_warning("Я не могу заставить себя ударить [source]! Его величие подавляет мою волю!"))
	to_chat(source, span_notice("[attacker] замирает перед ударом, подавленный моим величием."))
	return COMPONENT_HAND_NO_ATTACK

/datum/status_effect/majesty_compulsion/on_apply()
	. = ..()
	RegisterSignal(owner, COMSIG_ITEM_PRE_ATTACK, PROC_REF(on_pre_attack))
	RegisterSignal(owner, COMSIG_MOB_ON_KICK, PROC_REF(ta_on_kick))
	RegisterSignal(owner, COMSIG_MOB_SAY, PROC_REF(on_say))

	if(owner.mind)
		owner.add_stress(/datum/stressevent/majesty_compelled)

/datum/status_effect/majesty_compulsion/on_remove()
	. = ..()
	UnregisterSignal(owner, list(
		COMSIG_ITEM_PRE_ATTACK,
		COMSIG_MOB_ON_KICK,
		COMSIG_MOB_SAY
	))

	if(owner.mind)
		owner.remove_stress(/datum/stressevent/majesty_compelled)

/datum/status_effect/majesty_compulsion/proc/ta_on_kick(mob/living/source)
	SIGNAL_HANDLER
	if(!majesty_user || QDELETED(majesty_user) || get_dist(source, majesty_user) > 1)
		return

	var/direction_to_majesty = get_dir(source, majesty_user)
	if(direction_to_majesty && source.dir != direction_to_majesty)
		return
	if(!prob(80))
		return

	to_chat(source, span_warning("Я не могу заставить себя ударить [majesty_user]! Его величие подавляет мою волю!"))
	to_chat(majesty_user, span_notice("[source] замирает перед ударом, подавленный моим величием."))
	source.Stun(1 SECONDS, ignore_canstun = TRUE)
