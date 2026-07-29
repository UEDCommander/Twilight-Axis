////////////
//MATTHIOS//
////////////
// /obj/item/impact_grenade/pocketsand
/obj/item/pocketsand
	name = "pocket sand"
	desc = "A fistful of fine, irritating sand. Guaranteed to be clawing at the eyes of the unwise."
	icon = 'icons/roguetown/items/natural.dmi'
	icon_state = "clod1"
	w_class = WEIGHT_CLASS_SMALL
	dropshrink = 0
	throwforce = 0
	throw_speed = 1
	grid_width = 32
	grid_height = 32

/obj/item/pocketsand/throw_impact(atom/hit_atom)
	var/turf/T = get_turf(hit_atom)
	if(isliving(hit_atom))
		var/mob/living/target = hit_atom
		if(!target.mind || istype(target, /mob/living/simple_animal))
			target.adjustBruteLoss(5)
		if(iscarbon(target))
			target.blur_eyes(5)
			target.adjust_blurriness(10)
			target.blind_eyes(1.5)
		target.visible_message(
			span_warning("[target] is blasted with a cloud of sand!"),
			span_warning("Sand gets into my eyes! I can't see!")
		)
		target.emote("pain")
		target.apply_status_effect(/datum/status_effect/debuff/clickcd, 3 SECONDS)
	playsound(T, 'sound/items/firesnuff.ogg', 100)
	qdel(src)