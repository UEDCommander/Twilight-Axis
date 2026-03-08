/mob/living/proc/attempt_concealment(datum/intent/intenty, mob/living/user)
	var/mob/living/H = src
	if(!HAS_TRAIT(H, TRAIT_CONCEALMENT_EXPERT))
		return FALSE
	if(pulledby || pulling)
		return FALSE
	if(world.time < last_dodge + dodgetime)
		if(!istype(rmb_intent, /datum/rmb_intent/riposte))
			return FALSE
	if(has_status_effect(/datum/status_effect/debuff/riposted))
		return FALSE
	if(has_status_effect(/datum/status_effect/debuff/exposed) || has_status_effect(/datum/status_effect/debuff/vulnerable))
		return FALSE
	last_dodge = world.time
	if(src.loc == user.loc)
		return FALSE
	if(intenty)
		if(!intenty.candodge)
			return FALSE
	if(HAS_TRAIT(src, TRAIT_NODEF))
		return FALSE
	if(pulledby)
		return FALSE
	if(do_concealment(user))
		flash_fullscreen("blackflash2")
		user.aftermiss()
		return TRUE
	else
		return FALSE

/mob/proc/do_concealment(mob/user)
	if(dodgecd)
		return FALSE
	var/mob/living/L = src
	var/mob/living/U = user
	var/mob/living/carbon/human/H
	var/mob/living/carbon/human/UH
	var/obj/item/I
	if(ishuman(src))
		H = src
	if(ishuman(user))
		UH = user
		I = UH.used_intent.masteritem

	var/chance2hit = 80

	if(U)
		if(I)
			chance2hit += (U.get_skill_level(I.associated_skill) * 8)
			if(I.wlength == WLENGTH_SHORT)
				chance2hit += 10
		
		if(U.STAPER > 10)
			chance2hit += (min((U.STAPER-10)*8, 40))

		if(U.STAPER < 10)
			chance2hit -= ((10-U.STAPER)*10)

		if(istype(U.rmb_intent, /datum/rmb_intent/aimed))
			chance2hit += 20
		if(istype(U.rmb_intent, /datum/rmb_intent/swift))
			chance2hit -= 20
		
		if(HAS_TRAIT(U, TRAIT_CURSE_RAVOX))
			chance2hit -= 40

	if(UH.used_intent)
		if(UH.used_intent.blade_class == BCLASS_STAB)
			chance2hit += 10
		if(UH.used_intent.blade_class == BCLASS_PEEL)
			chance2hit += 25
		if(UH.used_intent.blade_class == BCLASS_HALFSWORD)
			chance2hit += 20	//Double that of stab
		if(UH.used_intent.blade_class == BCLASS_CUT)
			chance2hit += 6
		if(UH.used_intent.blade_class == BCLASS_BLUNT || UH.used_intent.blade_class == BCLASS_SMASH)
			chance2hit -= 10
		if(UH.used_intent.accuracy_modifier)
			chance2hit += UH.used_intent.accuracy_modifier

	if(U && L)
		chance2hit += (U.STAPER - L.STAPER) * 5
	if(H)
		chance2hit -= H.get_skill_level(/datum/skill/misc/sneaking) * 8

	chance2hit = CLAMP(chance2hit, 45, 93)

	if(client?.prefs.showrolls)
		to_chat(src, span_info("Roll for concealment... [100 - chance2hit]%"))
	if(prob(chance2hit))
		return FALSE
	playsound(src, 'sound/combat/dodge.ogg', 100, FALSE)
	src.visible_message(span_warning("<b>[src]</b> is protected by their concealment!"))
	return TRUE

