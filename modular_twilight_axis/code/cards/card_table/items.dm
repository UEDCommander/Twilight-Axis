/obj/item/cci_deck
	name = "card battle deck"
	desc = "A prepared deck for a round-based card battle."
	icon = 'icons/obj/playing_cards.dmi'
	icon_state = "deck"
	w_class = WEIGHT_CLASS_SMALL
	var/list/card_ids = list()
	var/datum/cci_match/match
	var/obj/item/cci_deck/match_host
	var/inviter_ckey
	var/inviter_name

/obj/item/cci_deck/Initialize(mapload)
	. = ..()
	if(!length(GLOB.cci_base_card_ids))
		cci_build_card_registry()
	if(!length(card_ids))
		card_ids = GLOB.cci_base_card_ids.Copy()
		while(card_ids.len > CCI_DECK_SIZE)
			card_ids.Cut(card_ids.len, card_ids.len + 1)
		var/index = 1
		while(card_ids.len < CCI_DECK_SIZE && length(GLOB.cci_base_card_ids))
			card_ids += GLOB.cci_base_card_ids[index]
			index++
			if(index > GLOB.cci_base_card_ids.len)
				index = 1

/obj/item/cci_deck/Destroy()
	var/datum/cci_match/active_match = get_active_match()
	if(active_match?.owner == src)
		qdel(active_match)
	else if(active_match?.challenger == src)
		active_match.challenger = null
	match = null
	match_host = null
	return ..()

/obj/item/cci_deck/proc/set_cards(list/new_cards)
	card_ids = list()
	for(var/card_id in new_cards)
		if(cci_card(card_id) && card_ids.len < CCI_DECK_SIZE)
			card_ids += card_id

/obj/item/cci_deck/attack_self(mob/user)
	if(!user)
		return
	if(get_active_match())
		ui_interact(user)
		return TRUE
	if(inviter_ckey && inviter_ckey != user.ckey)
		to_chat(user, span_notice("Strike this deck with your own card battle deck to begin."))
	else
		user.client?.cci_open_deckbuilder(src, user)
	return TRUE

/obj/item/cci_deck/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/cci_deck))
		var/obj/item/cci_deck/other = I
		try_start_match(user, other)
		return TRUE
	if(istype(I, /obj/item/cci_card_single))
		var/obj/item/cci_card_single/single = I
		add_single_card(user, single)
		return TRUE
	return ..()

/obj/item/cci_deck/dropped(mob/user, silent = FALSE)
	. = ..()
	if(match)
		return
	var/turf/T = get_turf(src)
	if(T && locate(/obj/structure/table) in T)
		inviter_ckey = user?.ckey
		inviter_name = user?.real_name ? user.real_name : user?.name
		if(user)
			to_chat(user, span_notice("You place the deck as a card battle invitation."))
	else
		clear_invitation()

/obj/item/cci_deck/proc/clear_invitation()
	inviter_ckey = null
	inviter_name = null

/obj/item/cci_deck/proc/get_active_match()
	if(match)
		return match
	if(match_host?.match)
		return match_host.match
	return null

/obj/item/cci_deck/proc/collect_finished_match()
	var/datum/cci_match/active_match = get_active_match()
	if(!active_match?.result_text)
		return FALSE
	var/obj/item/cci_deck/host = active_match.owner
	var/obj/item/cci_deck/guest = active_match.challenger
	if(host)
		host.match = null
		host.match_host = null
		host.clear_invitation()
	if(guest)
		guest.match = null
		guest.match_host = null
		guest.clear_invitation()
	qdel(active_match)
	return TRUE

/obj/item/cci_deck/proc/add_single_card(mob/user, obj/item/cci_card_single/single)
	if(!user || !single)
		return FALSE
	if(get_active_match())
		to_chat(user, span_warning("Finish the card match before changing this deck."))
		return FALSE
	if(card_ids.len >= CCI_DECK_SIZE)
		to_chat(user, span_warning("This card battle deck already has [CCI_DECK_SIZE] cards."))
		return FALSE
	if(!cci_card(single.card_id))
		to_chat(user, span_warning("This card cannot be added to the deck."))
		return FALSE
	card_ids += single.card_id
	var/datum/cci_card/card = cci_card(single.card_id)
	to_chat(user, span_notice("You add [card.name] to the card battle deck."))
	qdel(single)
	return TRUE

/obj/item/cci_deck/proc/try_start_match(mob/user, obj/item/cci_deck/challenger_deck)
	if(!user || !challenger_deck || challenger_deck == src)
		return FALSE
	if(get_active_match() || challenger_deck.get_active_match())
		to_chat(user, span_warning("One of these decks is already in a match."))
		return FALSE
	if(!inviter_ckey)
		to_chat(user, span_warning("This deck is not offering a match."))
		return FALSE
	if(inviter_ckey == user.ckey)
		to_chat(user, span_warning("You need another player for this match."))
		return FALSE
	var/mob/player_one = cci_find_mob_by_ckey(inviter_ckey)
	if(!player_one)
		to_chat(user, span_warning("The player who offered this match is not here."))
		return FALSE
	if(!user.dropItemToGround(challenger_deck))
		return FALSE
	challenger_deck.forceMove(get_turf(src))
	clear_invitation()
	challenger_deck.clear_invitation()
	match = new(src, player_one, src, user, challenger_deck)
	challenger_deck.match_host = src
	challenger_deck.match = match
	ui_interact(player_one)
	challenger_deck.ui_interact(user)
	return TRUE

/obj/item/cci_deck/ui_state(mob/user)
	return GLOB.always_state

/obj/item/cci_deck/ui_assets(mob/user)
	return list(get_asset_datum(/datum/asset/simple/cci_cards))

/obj/item/cci_deck/ui_interact(mob/user, datum/tgui/ui)
	var/datum/cci_match/active_match = get_active_match()
	if(!active_match)
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CardTable", name)
		ui.open()

/obj/item/cci_deck/ui_data(mob/user)
	var/datum/cci_match/active_match = get_active_match()
	if(!active_match)
		return list("waiting" = !!inviter_ckey, "offeredName" = inviter_name)
	return active_match.ui_data_for(user, src)

/obj/item/cci_deck/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/datum/cci_match/active_match = get_active_match()
	if(!active_match)
		return FALSE
	var/mob/user = ui.user
	switch(action)
		if("play")
			if(active_match.play_card(user, params["card"], src))
				active_match.update_deck_uis()
				return TRUE
		if("pass")
			if(active_match.pass(user, src))
				active_match.update_deck_uis()
				return TRUE
		if("collect")
			if(collect_finished_match())
				return TRUE
	return FALSE

/obj/item/cci_deck/attack_right(mob/user)
	if(!user)
		return
	if(get_active_match())
		ui_interact(user)
		return TRUE
	user.client?.cci_open_deckbuilder(src, user)
	return TRUE

/obj/item/cci_card_single
	name = "collectible card"
	desc = "A single collectible card."
	icon = 'icons/obj/playing_cards.dmi'
	icon_state = "singlecard_down"
	w_class = WEIGHT_CLASS_TINY
	var/card_id

/obj/item/cci_card_single/proc/set_card(new_card_id)
	card_id = new_card_id
	var/datum/cci_card/card = cci_card(card_id)
	if(card)
		name = card.name
		desc = card.desc

/obj/item/cci_card_single/Initialize(mapload)
	. = ..()
	if(card_id)
		set_card(card_id)

/obj/item/cci_card_single/attack_self(mob/user)
	var/datum/preferences/P = user?.client?.prefs
	if(P && P.cci_add_known_card(card_id))
		to_chat(user, span_notice("The card is added to your known collection."))
		qdel(src)
	else
		to_chat(user, span_notice("You already know this card, or it is a basic card."))

/obj/item/cci_card_single/rare_captain
	card_id = "rare_captain"

/obj/item/cci_card_single/rare_saboteur
	card_id = "rare_saboteur"

/obj/item/cci_card_single/unique_spy
	card_id = "unique_spy"

/obj/item/cci_card_single/unique_svinoglazka
	card_id = "unique_svinoglazka"

/proc/cci_find_mob_by_ckey(ckey)
	if(!ckey)
		return null
	for(var/client/C)
		if(C.ckey == ckey)
			return C.mob
	return null
