#define CCI_DECK_SIZE 30
#define CCI_STASH_DECK_KEY "cci_deck_cards"

/datum/preferences
	var/list/cci_known_rare_cards = list()
	var/list/cci_selected_deck = list()

/datum/preferences/proc/cci_known_cards()
	var/list/cards = list()
	for(var/card_id in GLOB.cci_base_card_ids)
		cards |= card_id
	if(islist(cci_known_rare_cards))
		for(var/card_id in cci_known_rare_cards)
			cards |= card_id
	return cards

/datum/preferences/proc/cci_clean_cards()
	if(!islist(cci_known_rare_cards))
		cci_known_rare_cards = list()
	if(!islist(cci_selected_deck))
		cci_selected_deck = list()

	var/list/valid_rare = list()
	for(var/card_id in cci_known_rare_cards)
		var/datum/cci_card/card = cci_card(card_id)
		if(card && card.rarity != CCI_RARITY_BASE)
			valid_rare |= card_id
	cci_known_rare_cards = valid_rare

	var/list/known = cci_known_cards()
	var/list/valid_deck = list()
	for(var/card_id in cci_selected_deck)
		if((card_id in known) && cci_card(card_id) && valid_deck.len < CCI_DECK_SIZE)
			valid_deck += card_id
	cci_selected_deck = valid_deck

/datum/preferences/proc/cci_add_known_card(card_id)
	var/datum/cci_card/card = cci_card(card_id)
	if(!card || card.rarity == CCI_RARITY_BASE)
		return FALSE
	cci_clean_cards()
	if(card_id in cci_known_rare_cards)
		return FALSE
	cci_known_rare_cards += card_id
	save_character()
	return TRUE

/datum/preferences/proc/cci_remove_known_cards_from_deck(list/card_ids)
	if(!islist(card_ids) || !length(card_ids))
		return
	cci_clean_cards()
	for(var/card_id in card_ids)
		var/datum/cci_card/card = cci_card(card_id)
		if(card?.rarity != CCI_RARITY_BASE)
			cci_known_rare_cards -= card_id
	cci_clean_cards()
	save_character()

/datum/preferences/proc/cci_sync_cards_from_inventory(mob/living/carbon/human/H)
	if(!H)
		return
	var/changed = FALSE
	for(var/atom/movable/thing in H.get_all_contents())
		if(istype(thing, /obj/item/cci_card_single))
			var/obj/item/cci_card_single/single = thing
			if(cci_add_known_card(single.card_id))
				changed = TRUE
		else if(istype(thing, /obj/item/cci_deck))
			var/obj/item/cci_deck/deck = thing
			for(var/card_id in deck.card_ids)
				if(cci_add_known_card(card_id))
					changed = TRUE
	if(changed)
		save_character()

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
	var/item = input(user, "What will I take?", "STASH") as null|anything in user.mind.special_items
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
		user.client?.prefs?.cci_remove_known_cards_from_deck(deck.card_ids)
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
	user.mind.special_items["Card Battle Deck"] = cci_stash_deck_spec(deck.card_ids)
	if(istype(user, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		user.client?.prefs?.cci_sync_cards_from_inventory(H)
	to_chat(user, span_notice("You return the card battle deck to your stash."))
	qdel(deck)
	return TRUE

/datum/preferences/proc/cci_create_deck_item(mob/user)
	cci_clean_cards()
	if(!cci_selected_deck.len)
		to_chat(user, span_warning("The card deck must contain at least one card."))
		return FALSE
	var/list/deck_cards = cci_selected_deck.Copy()
	if(user?.mind)
		if(cci_mind_has_stashed_deck(user.mind))
			to_chat(user, span_warning("Retrieve your stashed card deck before preparing another one."))
			return FALSE
		var/name = "Card Battle Deck"
		user.mind.special_items[name] = cci_stash_deck_spec(deck_cards)
		save_character()
		to_chat(user, span_notice("A prepared card battle deck is added to your stash. Rare cards leave your collection when you retrieve the physical deck."))
		return TRUE
	var/obj/item/cci_deck/deck = new(get_turf(user))
	deck.set_cards(deck_cards)
	cci_remove_known_cards_from_deck(deck_cards)
	cci_clean_cards()
	save_character()
	user?.put_in_hands(deck)
	return TRUE

/datum/cci_deckbuilder_panel

/datum/cci_deckbuilder_panel/ui_state(mob/user)
	return GLOB.always_state

/datum/cci_deckbuilder_panel/ui_assets(mob/user)
	return list(get_asset_datum(/datum/asset/simple/cci_cards))

/datum/cci_deckbuilder_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CardDeckBuilder", "Card Deck Builder")
		ui.open()

/datum/cci_deckbuilder_panel/ui_data(mob/user)
	var/list/data = list()
	var/datum/preferences/P = user?.client?.prefs
	if(!P)
		return data
	P.cci_clean_cards()

	var/list/cards = list()
	var/list/known = P.cci_known_cards()
	for(var/card_id in GLOB.cci_cards_by_id)
		var/datum/cci_card/card = cci_card(card_id)
		if(!card)
			continue
		cards += list(card.as_ui_data(card_id in known, card_id in P.cci_selected_deck))

	data["cards"] = cards
	data["selected"] = P.cci_selected_deck
	data["selectedCount"] = P.cci_selected_deck.len
	data["deckSize"] = CCI_DECK_SIZE
	data["knownRareCount"] = P.cci_known_rare_cards.len
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
			if(P.cci_selected_deck.len >= CCI_DECK_SIZE)
				return TRUE
			if(!(card_id in P.cci_known_cards()) || !cci_card(card_id))
				return TRUE
			P.cci_selected_deck += card_id
			P.save_character()
			return TRUE
		if("remove")
			P.cci_selected_deck -= card_id
			P.save_character()
			return TRUE
		if("remove_one")
			var/index = P.cci_selected_deck.Find(card_id)
			if(index)
				P.cci_selected_deck.Cut(index, index + 1)
				P.save_character()
			return TRUE
		if("clear")
			P.cci_selected_deck = list()
			P.save_character()
			return TRUE
		if("create_deck")
			P.cci_create_deck_item(user)
			return TRUE
	return FALSE

/client/proc/cci_open_deckbuilder(mob/user = mob)
	if(!user)
		return
	var/datum/cci_deckbuilder_panel/panel = new()
	panel.ui_interact(user)

#undef CCI_STASH_DECK_KEY
