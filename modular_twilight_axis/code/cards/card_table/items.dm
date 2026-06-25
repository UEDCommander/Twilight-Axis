/obj/item/cci_deck
	name = "card battle deck"
	desc = "A prepared deck for a round-based card battle."
	icon = 'modular_twilight_axis/icons/obj/gwynt_objs.dmi'
	icon_state = "gwint_deck"
	w_class = WEIGHT_CLASS_SMALL
	var/list/card_ids = list()
	var/faction_id = CCI_FACTION_AZURIA
	var/leader_id = "azuria_ducal_marshal"
	var/datum/cci_match/match
	var/obj/item/cci_deck/match_host
	var/owner_ckey
	var/inviter_ckey
	var/inviter_name

/obj/item/cci_deck/Initialize(mapload)
	. = ..()
	if(!length(GLOB.cci_base_card_ids))
		cci_build_card_registry()
	if(!length(card_ids))
		var/list/default_cards = cci_base_cards_for_faction(faction_id)
		card_ids = default_cards.Copy()
		while(card_ids.len > CCI_DECK_SIZE)
			card_ids.Cut(card_ids.len, card_ids.len + 1)
		var/index = 1
		while(card_ids.len < CCI_DECK_SIZE && length(default_cards))
			card_ids += default_cards[index]
			index++
			if(index > default_cards.len)
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
		if(cci_card_allowed_for_faction(card_id, faction_id) && card_ids.len < CCI_DECK_SIZE)
			card_ids += card_id

/obj/item/cci_deck/proc/set_faction(new_faction_id, new_leader_id)
	var/datum/cci_faction/faction = cci_faction(new_faction_id)
	if(!faction)
		return FALSE
	faction_id = faction.id
	var/datum/cci_leader/leader = cci_leader(new_leader_id)
	if(!leader || leader.faction != faction_id)
		leader_id = faction.default_leader
	else
		leader_id = leader.id
	return TRUE

/obj/item/cci_deck/proc/remove_cards_not_in_faction()
	var/list/removed = list()
	var/list/kept = list()
	for(var/card_id in card_ids)
		if(cci_card_allowed_for_faction(card_id, faction_id))
			kept += card_id
		else
			removed += card_id
	card_ids = kept
	return removed

/obj/item/cci_deck/attack_self(mob/user)
	if(!user)
		return
	if(get_active_match())
		ui_interact(user)
		return TRUE
	if(user.is_holding(src))
		user.client?.cci_open_deckbuilder(src, user)
	else if(inviter_ckey && inviter_ckey != user.ckey)
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
	if(!cci_card_allowed_for_faction(single.card_id, faction_id))
		to_chat(user, span_warning("This card belongs to another deck faction."))
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
			if(active_match.play_card(user, params["card"], src, params))
				active_match.update_deck_uis()
				return TRUE
		if("mulligan")
			if(active_match.mulligan_card(user, params["card"], src))
				active_match.update_deck_uis()
				return TRUE
		if("ready_mulligan")
			if(active_match.ready_mulligan(user, src))
				active_match.update_deck_uis()
				return TRUE
		if("leader")
			if(active_match.use_leader(user, src))
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
	if(!user.is_holding(src))
		return FALSE
	if(get_active_match())
		ui_interact(user)
		return TRUE
	return_to_stash(user)
	return TRUE

/obj/item/cci_deck/proc/return_to_stash(mob/user)
	if(!user?.mind || !isliving(user))
		return FALSE
	if(!user.is_holding(src))
		return FALSE
	if(!owner_ckey || owner_ckey != user.ckey)
		to_chat(user, span_warning("This card battle deck is not bound to your stash."))
		return TRUE
	if(!length(card_ids))
		to_chat(user, span_warning("This card battle deck has no cards to stash."))
		return TRUE
	if(cci_mind_has_stashed_deck(user.mind))
		to_chat(user, span_warning("You already have a card battle deck in your stash."))
		return TRUE
	if(istype(user, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		user.client?.prefs?.cci_sync_cards_from_inventory(H)
	if(!user.mind.special_items)
		user.mind.special_items = list()
	user.mind.special_items["Card Battle Deck"] = cci_stash_deck_spec(card_ids, faction_id, leader_id)
	if(!user.client?.prefs?.cci_save_deck_snapshot(card_ids, faction_id, leader_id))
		user.mind.special_items -= "Card Battle Deck"
		to_chat(user, span_warning("The card battle deck failed to save. It stays in your hands."))
		return TRUE
	to_chat(user, span_notice("You return the card battle deck to your stash."))
	qdel(src)
	return TRUE

/obj/item/cci_card_single
	name = "collectible card"
	desc = "A single collectible card."
	icon = 'modular_twilight_axis/icons/obj/gwynt_objs.dmi'
	icon_state = "gwint_card"
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
		SStgui.update_user_uis(user)
		qdel(src)
	else
		to_chat(user, span_warning("The card could not be added to your collection. Try again."))

/obj/item/cci_card_generator
	name = "sealed card packet"
	desc = "A sealed packet containing a random collectible card."
	icon = 'modular_twilight_axis/icons/obj/gwynt_objs.dmi'
	icon_state = "gwint_card"
	w_class = WEIGHT_CLASS_TINY
	var/card_rarity = CCI_RARITY_RARE

/obj/item/cci_card_generator/Initialize(mapload)
	. = ..()
	var/card_id = pick_random_card()
	if(!card_id)
		return
	var/obj/item/cci_card_single/single = new(loc)
	single.set_card(card_id)
	return INITIALIZE_HINT_QDEL

/obj/item/cci_card_generator/proc/pick_random_card()
	if(!length(GLOB.cci_cards_by_id))
		cci_build_card_registry()
	var/list/candidates = list()
	for(var/card_id in GLOB.cci_cards_by_id)
		var/datum/cci_card/card = cci_card(card_id)
		if(card?.rarity == card_rarity)
			candidates += card_id
	if(!length(candidates))
		return null
	return pick(candidates)

/obj/item/cci_card_generator/rare
	name = "sealed rare card packet"
	desc = "A sealed packet containing a random rare collectible card."
	card_rarity = CCI_RARITY_RARE

/obj/item/cci_card_generator/unique
	name = "sealed unique card packet"
	desc = "A sealed packet containing a random unique collectible card."
	card_rarity = CCI_RARITY_UNIQUE

/obj/item/cci_card_single/rare_captain
	card_id = "rare_captain"

/obj/item/cci_card_single/rare_saboteur
	card_id = "rare_saboteur"

/obj/item/cci_card_single/unique_spy
	card_id = "unique_spy"

/proc/cci_find_mob_by_ckey(ckey)
	if(!ckey)
		return null
	for(var/client/C)
		if(C.ckey == ckey)
			return C.mob
	return null
