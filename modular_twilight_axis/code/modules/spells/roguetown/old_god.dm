/obj/effect/proc_holder/spell/invoked/psydonvicariate
	name = "VICARIATE"
	overlay_state = "VICARIATE"
	desc = "A lesser form of the mighty art of ABSOLUTION. You take upon yourself the wounds, sickness, and frailty of another. Use carefully."
	releasedrain = 25
	chargedrain = 0
	chargetime = 0
	range = 1
	warnie = "sydwarning"
	movement_interrupt = FALSE
	sound = 'modular_twilight_axis/sound/magic/psyvicariate.ogg'
	invocations = list("Let it be mine...")
	invocation_type = "none"
	associated_skill = /datum/skill/magic/holy
	antimagic_allowed = FALSE
	recharge_time = 30 SECONDS // 60 seconds cooldown
	miracle = TRUE
	devotion_cost = 100
	action_icon = 'modular_twilight_axis/icons/mob/actions/roguespells.dmi'

/obj/effect/proc_holder/spell/invoked/psydonvicariate/cast(list/targets, mob/living/user)

	if(!ishuman(targets[1]))
		to_chat(user, span_warning("VICARIATE is for those who walk in HIS image!"))
		revert_cast()
		return FALSE
	
	var/mob/living/carbon/human/H = targets[1]
	
	if(H == user)
		to_chat(user, span_warning("You cannot bear your own burden through VICARIATE!"))
		revert_cast()
		return FALSE

	if(H.stat >= DEAD)
		to_chat(user, span_warning("The still and silent cannot be borne through VICARIATE."))
		revert_cast()
		return FALSE

	var/brute_transfer = H.getBruteLoss()
	var/burn_transfer = H.getFireLoss()
	var/tox_transfer = H.getToxLoss()
	var/oxy_transfer = H.getOxyLoss()
	var/clone_transfer = H.getCloneLoss()

	if(oxy_transfer >= 150)
		if(alert(user, "THEIR BREATH IS NEARLY GONE. THIS BURDEN MAY SLAY YOU. PROCEED?", "SELF-PRESERVATION", "YES", "NO") != "YES")
			revert_cast()
			return
	
	// Heal the target
	H.adjustBruteLoss(-brute_transfer)
	H.adjustFireLoss(-burn_transfer)
	H.adjustToxLoss(-tox_transfer)
	H.adjustOxyLoss(-oxy_transfer)
	H.adjustCloneLoss(-clone_transfer)
	
	// Apply damage to the caster
	user.adjustBruteLoss(brute_transfer)
	user.adjustFireLoss(burn_transfer)
	user.adjustToxLoss(tox_transfer)
	user.adjustOxyLoss(oxy_transfer)
	user.adjustCloneLoss(clone_transfer)

	// Visual effects
	user.visible_message(span_danger("[user] assumes [H]'s suffering through VICARIATE!"))
	new /obj/effect/temp_visual/psyheal_rogue(get_turf(H), "#5e1d1d") 
	new /obj/effect/temp_visual/psyheal_rogue(get_turf(H), "#5e1d1d") 
	new /obj/effect/temp_visual/psyheal_rogue(get_turf(H), "#5e1d1d") 

	new /obj/effect/temp_visual/psyheal_rogue(get_turf(user), "#5e1d1d") 
	new /obj/effect/temp_visual/psyheal_rogue(get_turf(user), "#5e1d1d") 
	new /obj/effect/temp_visual/psyheal_rogue(get_turf(user), "#5e1d1d") 
	
	// Notify the user and target
	to_chat(user, span_warning("You take [H]'s suffering into your own flesh."))
	to_chat(H, span_notice("[user] bears your wounds as their own."))
	
	return TRUE