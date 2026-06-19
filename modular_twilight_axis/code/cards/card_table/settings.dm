#define CCI_DECK_SIZE 30
#define CCI_STASH_DECK_KEY "cci_deck_cards"

/datum/mind
	var/cci_deck_requested = FALSE

/datum/preferences
	var/list/cci_known_rare_cards = list()
	var/list/cci_selected_deck = list()
	var/list/cci_saved_deck_cards = list()

/datum/preferences/proc/cci_known_cards()
	var/list/cards = list()
	for(var/card_id in GLOB.cci_base_card_ids)
		cards |= card_id
	if(islist(cci_known_rare_cards))
		for(var/card_id in cci_known_rare_cards)
			var/count = cci_known_rare_cards[card_id]
			if((isnum(count) && count > 0) || (!isnum(count) && (card_id in cci_known_rare_cards)))
				cards |= card_id
	return cards

/datum/preferences/proc/cci_card_pool_count(card_id)
	var/datum/cci_card/card = cci_card(card_id)
	if(!card)
		return 0
	if(card.rarity == CCI_RARITY_BASE)
		return CCI_DECK_SIZE
	if(!islist(cci_known_rare_cards))
		return 0
	return max(0, cci_known_rare_cards[card_id])

/proc/cci_card_count_in_list(list/card_ids, card_id)
	var/count = 0
	if(!islist(card_ids))
		return 0
	for(var/selected_id in card_ids)
		if(selected_id == card_id)
			count++
	return count

/datum/preferences/proc/cci_selected_count(card_id)
	return cci_card_count_in_list(cci_selected_deck, card_id)

/datum/preferences/proc/cci_can_select_card(card_id)
	var/datum/cci_card/card = cci_card(card_id)
	if(!card)
		return FALSE
	if(card.rarity == CCI_RARITY_BASE)
		return TRUE
	return cci_selected_count(card_id) < cci_card_pool_count(card_id)

/datum/preferences/proc/cci_available_for_deck(list/deck_cards, card_id)
	var/datum/cci_card/card = cci_card(card_id)
	if(!card)
		return 0
	if(card.rarity == CCI_RARITY_BASE)
		return CCI_DECK_SIZE
	return cci_card_pool_count(card_id) + cci_card_count_in_list(deck_cards, card_id)

/datum/preferences/proc/cci_clean_cards()
	if(!islist(cci_known_rare_cards))
		cci_known_rare_cards = list()
	if(!islist(cci_selected_deck))
		cci_selected_deck = list()
	if(!islist(cci_saved_deck_cards))
		cci_saved_deck_cards = list()

	var/list/valid_rare = list()
	for(var/card_id in cci_known_rare_cards)
		var/datum/cci_card/card = cci_card(card_id)
		if(card && card.rarity != CCI_RARITY_BASE)
			var/count = cci_known_rare_cards[card_id]
			if(!isnum(count))
				count = 1
			count = max(0, round(count))
			if(count > 0)
				valid_rare[card_id] = count
	cci_known_rare_cards = valid_rare

	var/list/selected_counts = list()
	var/list/valid_deck = list()
	for(var/card_id in cci_selected_deck)
		var/datum/cci_card/card = cci_card(card_id)
		if(!card || valid_deck.len >= CCI_DECK_SIZE)
			continue
		if(card.rarity != CCI_RARITY_BASE)
			var/selected_count = selected_counts[card_id]
			if(!selected_count)
				selected_count = 0
			if(selected_count >= cci_card_pool_count(card_id))
				continue
			selected_counts[card_id] = selected_count + 1
		valid_deck += card_id
	cci_selected_deck = valid_deck

	var/list/valid_saved_deck = list()
	for(var/card_id in cci_saved_deck_cards)
		if(cci_card(card_id) && valid_saved_deck.len < CCI_DECK_SIZE)
			valid_saved_deck += card_id
	cci_saved_deck_cards = valid_saved_deck

/datum/preferences/proc/cci_add_known_card(card_id)
	var/datum/cci_card/card = cci_card(card_id)
	if(!card || card.rarity == CCI_RARITY_BASE)
		return FALSE
	cci_clean_cards()
	var/count = cci_known_rare_cards[card_id]
	if(!count)
		count = 0
	cci_known_rare_cards[card_id] = count + 1
	save_character()
	return TRUE

/datum/preferences/proc/cci_remove_known_cards_from_deck(list/card_ids)
	if(!islist(card_ids) || !length(card_ids))
		return
	cci_clean_cards()
	for(var/card_id in card_ids)
		var/datum/cci_card/card = cci_card(card_id)
		if(card?.rarity != CCI_RARITY_BASE)
			var/count = cci_known_rare_cards[card_id]
			if(!count)
				count = 0
			count--
			if(count > 0)
				cci_known_rare_cards[card_id] = count
			else
				cci_known_rare_cards -= card_id
	cci_clean_cards()
	save_character()

/datum/preferences/proc/cci_take_pool_card(card_id)
	var/datum/cci_card/card = cci_card(card_id)
	if(!card || card.rarity == CCI_RARITY_BASE)
		return TRUE
	cci_clean_cards()
	var/count = cci_known_rare_cards[card_id]
	if(!count)
		return FALSE
	count--
	if(count > 0)
		cci_known_rare_cards[card_id] = count
	else
		cci_known_rare_cards -= card_id
	save_character()
	return TRUE

/datum/preferences/proc/cci_return_pool_card(card_id)
	var/datum/cci_card/card = cci_card(card_id)
	if(!card || card.rarity == CCI_RARITY_BASE)
		return FALSE
	cci_clean_cards()
	var/count = cci_known_rare_cards[card_id]
	if(!count)
		count = 0
	cci_known_rare_cards[card_id] = count + 1
	save_character()
	return TRUE

/datum/preferences/proc/cci_sync_cards_from_inventory(mob/living/carbon/human/H)
	if(!H)
		return
	var/changed = FALSE
	for(var/atom/movable/thing in H.get_all_contents())
		if(istype(thing, /obj/item/cci_card_single))
			var/obj/item/cci_card_single/single = thing
			if(cci_add_known_card(single.card_id))
				changed = TRUE
				qdel(single)
		else if(istype(thing, /obj/item/cci_deck))
			var/obj/item/cci_deck/deck = thing
			cci_saved_deck_cards = deck.card_ids.Copy()
			changed = TRUE
	if(changed)
		save_character()

/datum/preferences/proc/cci_save_deck_snapshot(list/card_ids)
	if(!islist(card_ids))
		return FALSE
	cci_saved_deck_cards = list()
	for(var/card_id in card_ids)
		if(cci_card(card_id) && cci_saved_deck_cards.len < CCI_DECK_SIZE)
			cci_saved_deck_cards += card_id
	save_character()
	return TRUE

/proc/cci_sync_all_player_collections()
	for(var/client/C in GLOB.clients)
		var/mob/M = C.mob
		if(!istype(M, /mob/living/carbon/human) || !C.prefs)
			continue
		var/mob/living/carbon/human/H = M
		C.prefs.cci_sync_cards_from_inventory(H)

/proc/cci_stash_deck_spec(list/card_ids)
	return list(CCI_STASH_DECK_KEY = card_ids.Copy())

/proc/cci_is_stashed_deck(value)
	return islist(value) && islist(value[CCI_STASH_DECK_KEY])

/proc/cci_mind_has_stashed_deck(datum/mind/mind)
	if(!mind?.special_items)
		return FALSE
	for(var/item_name in mind.special_items)
		if(cci_is_stashed_deck(mind.special_items[item_name]))
			return TRUE
	return FALSE

/proc/handle_special_items_retrieval(mob/user, atom/host_object)
	if(!user?.mind || !isliving(user))
		return FALSE
	if(!user.mind.special_items || !user.mind.special_items.len)
		return FALSE
	var/item = tgui_input_list(user, "What will I take?", "STASH", user.mind.special_items)
	if(!item)
		return TRUE
	if(!user.Adjacent(host_object) || !user.mind.special_items[item])
		return TRUE
	var/stash_value = user.mind.special_items[item]
	user.mind.special_items -= item
	var/obj/item/I
	if(cci_is_stashed_deck(stash_value))
		var/obj/item/cci_deck/deck = new(user.loc)
		deck.set_cards(stash_value[CCI_STASH_DECK_KEY])
		I = deck
	else
		var/path2item = stash_value
		I = new path2item(user.loc)
	user.put_in_hands(I)
	return TRUE

/proc/handle_special_items_deposit(obj/item/I, mob/user, atom/host_object)
	if(!istype(I, /obj/item/cci_deck) || !user?.mind || !isliving(user))
		return FALSE
	if(!user.Adjacent(host_object))
		return FALSE
	var/obj/item/cci_deck/deck = I
	if(deck.get_active_match())
		to_chat(user, span_warning("Finish the card match before stashing this deck."))
		return TRUE
	if(!length(deck.card_ids))
		to_chat(user, span_warning("This card battle deck has no cards to stash."))
		return TRUE
	if(cci_mind_has_stashed_deck(user.mind))
		to_chat(user, span_warning("You already have a card battle deck in your stash."))
		return TRUE
	if(istype(user, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		user.client?.prefs?.cci_sync_cards_from_inventory(H)
	user.mind.special_items["Card Battle Deck"] = cci_stash_deck_spec(deck.card_ids)
	user.client?.prefs?.cci_save_deck_snapshot(deck.card_ids)
	to_chat(user, span_notice("You return the card battle deck to your stash."))
	qdel(deck)
	return TRUE

/datum/preferences/proc/cci_request_deck_item(mob/user)
	cci_clean_cards()
	if(!user?.mind)
		return FALSE
	if(user.mind.cci_deck_requested)
		to_chat(user, span_warning("You have already requested a card battle deck this round."))
		return FALSE
	if(cci_mind_has_stashed_deck(user.mind))
		to_chat(user, span_warning("You already have a card battle deck in your stash."))
		return FALSE
	var/list/deck_cards = length(cci_saved_deck_cards) ? cci_saved_deck_cards.Copy() : GLOB.cci_base_card_ids.Copy()
	while(deck_cards.len > CCI_DECK_SIZE)
		deck_cards.Cut(deck_cards.len, deck_cards.len + 1)
	if(!user.mind.special_items)
		user.mind.special_items = list()
	user.mind.special_items["Card Battle Deck"] = cci_stash_deck_spec(deck_cards)
	user.mind.cci_deck_requested = TRUE
	to_chat(user, span_notice("A card battle deck is added to your stash."))
	return TRUE

/datum/cci_deckbuilder_panel
	var/obj/item/cci_deck/deck

/datum/cci_deckbuilder_panel/ui_state(mob/user)
	return GLOB.always_state

/datum/cci_deckbuilder_panel/ui_assets(mob/user)
	return list(get_asset_datum(/datum/asset/simple/cci_cards))

/datum/cci_deckbuilder_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CardDeckBuilder", deck ? "Card Deck Builder" : "Card Deck Pool")
		ui.open()

/datum/cci_deckbuilder_panel/ui_data(mob/user)
	var/list/data = list()
	var/datum/preferences/P = user?.client?.prefs
	if(!P)
		return data
	P.cci_clean_cards()
	var/list/selected = deck ? deck.card_ids : P.cci_saved_deck_cards

	var/list/cards = list()
	var/list/known = P.cci_known_cards()
	for(var/card_id in GLOB.cci_cards_by_id)
		var/datum/cci_card/card = cci_card(card_id)
		if(!card)
			continue
		var/list/card_data = card.as_ui_data(card_id in known, card_id in selected)
		card_data["ownedCount"] = deck ? P.cci_available_for_deck(selected, card_id) : P.cci_card_pool_count(card_id)
		cards += list(card_data)

	data["mode"] = deck ? "build" : "pool"
	data["cards"] = cards
	data["selected"] = selected
	data["selectedCount"] = selected.len
	data["deckSize"] = CCI_DECK_SIZE
	data["canRequestDeck"] = !user?.mind?.cci_deck_requested
	var/known_rare_count = 0
	for(var/card_id in P.cci_known_rare_cards)
		known_rare_count += P.cci_known_rare_cards[card_id]
	data["knownRareCount"] = known_rare_count
	return data

/datum/cci_deckbuilder_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/user = ui.user
	var/datum/preferences/P = user?.client?.prefs
	if(!P)
		return FALSE
	P.cci_clean_cards()

	var/card_id = params["card"]
	switch(action)
		if("add")
			if(!deck || deck.card_ids.len >= CCI_DECK_SIZE)
				return TRUE
			var/datum/cci_card/card = cci_card(card_id)
			if(!card)
				return TRUE
			if(card.rarity != CCI_RARITY_BASE && !P.cci_take_pool_card(card_id))
				return TRUE
			deck.card_ids += card_id
			return TRUE
		if("remove")
			if(!deck)
				return TRUE
			while(card_id in deck.card_ids)
				var/index = deck.card_ids.Find(card_id)
				if(!index)
					break
				deck.card_ids.Cut(index, index + 1)
				P.cci_return_pool_card(card_id)
			return TRUE
		if("remove_one")
			if(!deck)
				return TRUE
			var/index = deck.card_ids.Find(card_id)
			if(index)
				deck.card_ids.Cut(index, index + 1)
				P.cci_return_pool_card(card_id)
			return TRUE
		if("clear")
			if(!deck)
				return TRUE
			for(var/removed_id in deck.card_ids)
				P.cci_return_pool_card(removed_id)
			deck.card_ids = list()
			return TRUE
		if("request_deck")
			if(!deck)
				P.cci_request_deck_item(user)
			return TRUE
		if("take_card")
			if(!deck)
				return TRUE
			var/card_index = deck.card_ids.Find(card_id)
			if(!card_index)
				return TRUE
			deck.card_ids.Cut(card_index, card_index + 1)
			var/obj/item/cci_card_single/single = new(get_turf(user))
			single.set_card(card_id)
			user.put_in_hands(single)
			return TRUE
	return FALSE

/client/proc/cci_open_deckpool(mob/user = mob)
	if(!user)
		return
	var/datum/cci_deckbuilder_panel/panel = new()
	panel.ui_interact(user)

/client/proc/cci_open_deckbuilder(obj/item/cci_deck/deck, mob/user = mob)
	if(!user || !deck)
		return
	var/datum/cci_deckbuilder_panel/panel = new()
	panel.deck = deck
	panel.ui_interact(user)

#undef CCI_STASH_DECK_KEY
