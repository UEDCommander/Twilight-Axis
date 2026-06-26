#define CCG_DECK_SIZE 30
#define CCG_STASH_DECK_KEY "ccg_deck_cards"
#define CCG_STASH_FACTION_KEY "ccg_deck_faction"
#define CCG_STASH_LEADER_KEY "ccg_deck_leader"

/datum/mind
	var/ccg_deck_requested = FALSE

/datum/preferences
	var/list/ccg_known_rare_cards = list()
	var/list/ccg_selected_deck = list()
	var/list/ccg_saved_deck_cards = list()
	var/ccg_saved_deck_faction = CCG_FACTION_AZURIA
	var/ccg_saved_deck_leader = "azuria_ducal_marshal"

/datum/preferences/proc/ccg_known_cards()
	var/list/cards = list()
	for(var/card_id in GLOB.ccg_base_card_ids)
		var/datum/ccg_card/card = ccg_card(card_id)
		if(card && !card.limited)
			cards |= card_id
	if(islist(ccg_known_rare_cards))
		for(var/card_id in ccg_known_rare_cards)
			var/count = ccg_known_rare_cards[card_id]
			if((isnum(count) && count > 0) || (!isnum(count) && (card_id in ccg_known_rare_cards)))
				cards |= card_id
	return cards

/proc/ccg_card_is_limited(datum/ccg_card/card)
	return card && (card.rarity != CCG_RARITY_BASE || card.limited)

/datum/preferences/proc/ccg_card_pool_count(card_id)
	var/datum/ccg_card/card = ccg_card(card_id)
	if(!card)
		return 0
	if(!ccg_card_is_limited(card))
		return CCG_DECK_SIZE
	if(!islist(ccg_known_rare_cards))
		return 0
	return max(0, ccg_known_rare_cards[card_id])

/proc/ccg_card_count_in_list(list/card_ids, card_id)
	var/count = 0
	if(!islist(card_ids))
		return 0
	for(var/selected_id in card_ids)
		if(selected_id == card_id)
			count++
	return count

/datum/preferences/proc/ccg_selected_count(card_id)
	return ccg_card_count_in_list(ccg_selected_deck, card_id)

/datum/preferences/proc/ccg_can_select_card(card_id)
	var/datum/ccg_card/card = ccg_card(card_id)
	if(!card)
		return FALSE
	if(!ccg_card_is_limited(card))
		return TRUE
	return ccg_selected_count(card_id) < ccg_card_pool_count(card_id)

/datum/preferences/proc/ccg_available_for_deck(list/deck_cards, card_id)
	var/datum/ccg_card/card = ccg_card(card_id)
	if(!card)
		return 0
	if(!ccg_card_is_limited(card))
		return CCG_DECK_SIZE
	return ccg_card_pool_count(card_id) + ccg_card_count_in_list(deck_cards, card_id)

/datum/preferences/proc/ccg_clean_cards()
	if(!islist(ccg_known_rare_cards))
		ccg_known_rare_cards = list()
	if(!islist(ccg_selected_deck))
		ccg_selected_deck = list()
	if(!islist(ccg_saved_deck_cards))
		ccg_saved_deck_cards = list()
	if(!ccg_faction(ccg_saved_deck_faction))
		ccg_saved_deck_faction = CCG_FACTION_AZURIA
	var/datum/ccg_leader/saved_leader = ccg_leader(ccg_saved_deck_leader)
	var/datum/ccg_faction/saved_faction = ccg_faction(ccg_saved_deck_faction)
	if(!saved_faction)
		saved_faction = ccg_faction(CCG_FACTION_AZURIA)
		ccg_saved_deck_faction = saved_faction.id
	if(!saved_leader || saved_leader.faction != ccg_saved_deck_faction)
		ccg_saved_deck_leader = saved_faction.default_leader

	var/list/valid_rare = list()
	for(var/card_id in ccg_known_rare_cards)
		var/datum/ccg_card/card = ccg_card(card_id)
		if(ccg_card_is_limited(card))
			var/count = ccg_known_rare_cards[card_id]
			if(!isnum(count))
				count = 1
			count = max(0, round(count))
			if(count > 0)
				valid_rare[card_id] = count
	ccg_known_rare_cards = valid_rare

	var/list/selected_counts = list()
	var/list/valid_deck = list()
	for(var/card_id in ccg_selected_deck)
		var/datum/ccg_card/card = ccg_card(card_id)
		if(!card || valid_deck.len >= CCG_DECK_SIZE)
			continue
		if(ccg_card_is_limited(card))
			var/selected_count = selected_counts[card_id]
			if(!selected_count)
				selected_count = 0
			if(selected_count >= ccg_card_pool_count(card_id))
				continue
			selected_counts[card_id] = selected_count + 1
		valid_deck += card_id
	ccg_selected_deck = valid_deck

	var/list/valid_saved_deck = list()
	for(var/card_id in ccg_saved_deck_cards)
		if(ccg_card_allowed_for_faction(card_id, ccg_saved_deck_faction) && valid_saved_deck.len < CCG_DECK_SIZE)
			valid_saved_deck += card_id
	ccg_saved_deck_cards = valid_saved_deck

/datum/preferences/proc/ccg_save()
	ccg_clean_cards()
	var/character_saved = save_character()
	var/preferences_saved = save_preferences()
	return character_saved || preferences_saved

/datum/preferences/proc/ccg_add_known_card(card_id)
	var/datum/ccg_card/card = ccg_card(card_id)
	if(!ccg_card_is_limited(card))
		return FALSE
	ccg_clean_cards()
	var/count = ccg_known_rare_cards[card_id]
	if(!count)
		count = 0
	ccg_known_rare_cards[card_id] = count + 1
	if(!ccg_save())
		if(count > 0)
			ccg_known_rare_cards[card_id] = count
		else
			ccg_known_rare_cards -= card_id
		return FALSE
	return TRUE

/datum/preferences/proc/ccg_remove_known_cards_from_deck(list/card_ids)
	if(!islist(card_ids) || !length(card_ids))
		return FALSE
	ccg_clean_cards()
	var/list/old_known_cards = ccg_known_rare_cards.Copy()
	for(var/card_id in card_ids)
		var/datum/ccg_card/card = ccg_card(card_id)
		if(ccg_card_is_limited(card))
			var/count = ccg_known_rare_cards[card_id]
			if(!count)
				count = 0
			count--
			if(count > 0)
				ccg_known_rare_cards[card_id] = count
			else
				ccg_known_rare_cards -= card_id
	ccg_clean_cards()
	if(!ccg_save())
		ccg_known_rare_cards = old_known_cards
		ccg_clean_cards()
		return FALSE
	return TRUE

/datum/preferences/proc/ccg_take_pool_card(card_id)
	var/datum/ccg_card/card = ccg_card(card_id)
	if(!ccg_card_is_limited(card))
		return TRUE
	ccg_clean_cards()
	var/count = ccg_known_rare_cards[card_id]
	if(!count)
		return FALSE
	count--
	if(count > 0)
		ccg_known_rare_cards[card_id] = count
	else
		ccg_known_rare_cards -= card_id
	if(!ccg_save())
		ccg_known_rare_cards[card_id] = count + 1
		ccg_clean_cards()
		return FALSE
	return TRUE

/datum/preferences/proc/ccg_return_pool_card(card_id)
	var/datum/ccg_card/card = ccg_card(card_id)
	if(!ccg_card_is_limited(card))
		return TRUE
	ccg_clean_cards()
	var/count = ccg_known_rare_cards[card_id]
	if(!count)
		count = 0
	ccg_known_rare_cards[card_id] = count + 1
	if(!ccg_save())
		if(count > 0)
			ccg_known_rare_cards[card_id] = count
		else
			ccg_known_rare_cards -= card_id
		return FALSE
	return TRUE

/datum/preferences/proc/ccg_sync_cards_from_inventory(mob/living/carbon/human/H)
	if(!H)
		return
	var/changed = FALSE
	for(var/atom/movable/thing in H.get_all_contents())
		if(istype(thing, /obj/item/ccg_card_single))
			var/obj/item/ccg_card_single/single = thing
			if(ccg_add_known_card(single.card_id))
				changed = TRUE
				qdel(single)
		else if(istype(thing, /obj/item/ccg_deck))
			var/obj/item/ccg_deck/deck = thing
			var/datum/ccg_faction/faction = ccg_faction(deck.faction_id)
			if(!faction)
				faction = ccg_faction(CCG_FACTION_AZURIA)
			ccg_saved_deck_cards = list()
			for(var/card_id in deck.card_ids)
				if(ccg_card_allowed_for_faction(card_id, faction.id) && ccg_saved_deck_cards.len < CCG_DECK_SIZE)
					ccg_saved_deck_cards += card_id
			ccg_saved_deck_faction = faction.id
			var/datum/ccg_leader/leader = ccg_leader(deck.leader_id)
			ccg_saved_deck_leader = (leader && leader.faction == faction.id) ? leader.id : faction.default_leader
			changed = TRUE
	if(changed)
		ccg_save()

/datum/preferences/proc/ccg_save_deck_snapshot(list/card_ids, faction_id = CCG_FACTION_AZURIA, leader_id = null)
	if(!islist(card_ids))
		return FALSE
	var/list/old_saved_deck_cards = islist(ccg_saved_deck_cards) ? ccg_saved_deck_cards.Copy() : list()
	var/old_saved_deck_faction = ccg_saved_deck_faction
	var/old_saved_deck_leader = ccg_saved_deck_leader
	var/datum/ccg_faction/faction = ccg_faction(faction_id)
	if(!faction)
		faction = ccg_faction(CCG_FACTION_AZURIA)
	ccg_saved_deck_cards = list()
	for(var/card_id in card_ids)
		if(ccg_card_allowed_for_faction(card_id, faction.id) && ccg_saved_deck_cards.len < CCG_DECK_SIZE)
			ccg_saved_deck_cards += card_id
	ccg_saved_deck_faction = faction.id
	var/datum/ccg_leader/leader = ccg_leader(leader_id)
	ccg_saved_deck_leader = (leader && leader.faction == faction.id) ? leader.id : faction.default_leader
	if(!ccg_save())
		ccg_saved_deck_cards = old_saved_deck_cards
		ccg_saved_deck_faction = old_saved_deck_faction
		ccg_saved_deck_leader = old_saved_deck_leader
		ccg_clean_cards()
		return FALSE
	return TRUE

/proc/ccg_sync_all_player_collections()
	for(var/client/C in GLOB.clients)
		var/mob/M = C.mob
		if(!istype(M, /mob/living/carbon/human) || !C.prefs)
			continue
		var/mob/living/carbon/human/H = M
		C.prefs.ccg_sync_cards_from_inventory(H)

/proc/ccg_is_stashed_deck(value)
	return value == /obj/item/ccg_deck/stashed || (islist(value) && islist(value[CCG_STASH_DECK_KEY]))

/proc/ccg_migrate_stashed_deck_specs(mob/user)
	if(!user?.mind?.special_items)
		return FALSE
	var/changed = FALSE
	for(var/item_name in user.mind.special_items)
		var/stash_value = user.mind.special_items[item_name]
		if(!islist(stash_value) || !islist(stash_value[CCG_STASH_DECK_KEY]))
			continue
		user.client?.prefs?.ccg_save_deck_snapshot(stash_value[CCG_STASH_DECK_KEY], stash_value[CCG_STASH_FACTION_KEY], stash_value[CCG_STASH_LEADER_KEY])
		user.mind.special_items[item_name] = /obj/item/ccg_deck/stashed
		changed = TRUE
	return changed

/proc/ccg_mind_has_stashed_deck(datum/mind/mind)
	if(!mind?.special_items)
		return FALSE
	for(var/item_name in mind.special_items)
		if(ccg_is_stashed_deck(mind.special_items[item_name]))
			return TRUE
	return FALSE

/datum/preferences/proc/ccg_request_deck_item(mob/user)
	ccg_clean_cards()
	if(!user?.mind)
		return FALSE
	ccg_migrate_stashed_deck_specs(user)
	if(user.mind.ccg_deck_requested)
		to_chat(user, span_warning("You have already requested a card battle deck this round."))
		return FALSE
	if(ccg_mind_has_stashed_deck(user.mind))
		to_chat(user, span_warning("You already have a card battle deck in your stash."))
		return FALSE
	var/list/deck_cards = length(ccg_saved_deck_cards) ? ccg_saved_deck_cards.Copy() : ccg_base_cards_for_faction(ccg_saved_deck_faction)
	while(deck_cards.len > CCG_DECK_SIZE)
		deck_cards.Cut(deck_cards.len, deck_cards.len + 1)
	if(!ccg_save_deck_snapshot(deck_cards, ccg_saved_deck_faction, ccg_saved_deck_leader))
		to_chat(user, span_warning("The card battle deck request failed to save. Try again."))
		return FALSE
	if(!user.mind.special_items)
		user.mind.special_items = list()
	user.mind.special_items["Card Battle Deck"] = /obj/item/ccg_deck/stashed
	user.mind.ccg_deck_requested = TRUE
	to_chat(user, span_notice("A card battle deck is added to your stash."))
	return TRUE

/datum/ccg_deckbuilder_panel
	var/obj/item/ccg_deck/deck

/datum/ccg_deckbuilder_panel/ui_state(mob/user)
	return GLOB.always_state

/datum/ccg_deckbuilder_panel/ui_assets(mob/user)
	return list(get_asset_datum(/datum/asset/simple/ccg_cards))

/client/proc/ccg_preload_card_assets()
	ccg_migrate_stashed_deck_specs(mob)
	var/datum/asset/simple/card_assets = get_asset_datum(/datum/asset/simple/ccg_cards)
	SSassets.transport.send_assets_slow(src, card_assets.assets)

/datum/ccg_deckbuilder_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CardDeckBuilder", deck ? "Card Deck Builder" : "Card Deck Pool")
		ui.open()

/datum/ccg_deckbuilder_panel/ui_data(mob/user)
	var/list/data = list()
	var/datum/preferences/P = user?.client?.prefs
	if(!P)
		return data
	if(!length(GLOB.ccg_cards_by_id))
		ccg_build_card_registry()
	P.ccg_clean_cards()
	if(!length(GLOB.ccg_factions_by_id))
		ccg_build_faction_registry()
	if(!length(GLOB.ccg_leaders_by_id))
		ccg_build_leader_registry()
	ccg_migrate_stashed_deck_specs(user)
	var/list/selected = deck ? deck.card_ids : P.ccg_saved_deck_cards
	var/current_faction_id = deck ? deck.faction_id : P.ccg_saved_deck_faction

	var/list/cards = list()
	var/list/known = P.ccg_known_cards()
	for(var/card_id in GLOB.ccg_cards_by_id)
		var/datum/ccg_card/card = ccg_card(card_id)
		if(!card)
			continue
		var/list/card_data = card.as_ui_data(card_id in known, card_id in selected)
		card_data["ownedCount"] = deck ? P.ccg_available_for_deck(selected, card_id) : P.ccg_card_pool_count(card_id)
		card_data["factionAllowed"] = ccg_card_allowed_for_faction(card_id, current_faction_id)
		var/faction_name = "Common"
		var/datum/ccg_faction/card_faction
		if(card.faction == CCG_FACTION_NEUTRAL)
			faction_name = "Common"
		else
			card_faction = ccg_faction(card.faction)
			faction_name = card_faction ? card_faction.name : card.faction
		card_data["factionName"] = faction_name
		cards += list(card_data)

	data["mode"] = deck ? "build" : "pool"
	data["cards"] = cards
	data["selected"] = selected
	data["selectedCount"] = selected.len
	data["deckSize"] = CCG_DECK_SIZE
	data["canRequestDeck"] = !user?.mind?.ccg_deck_requested
	data["faction"] = current_faction_id
	data["leader"] = deck ? deck.leader_id : P.ccg_saved_deck_leader
	var/list/factions = list()
	for(var/faction_id in GLOB.ccg_factions_by_id)
		var/datum/ccg_faction/faction = ccg_faction(faction_id)
		if(faction)
			factions += list(faction.as_ui_data())
	data["factions"] = factions
	var/list/leaders = list()
	for(var/leader_id in GLOB.ccg_leaders_by_id)
		var/datum/ccg_leader/leader = ccg_leader(leader_id)
		if(leader)
			leaders += list(leader.as_ui_data(FALSE))
	data["leaders"] = leaders
	var/known_rare_count = 0
	for(var/card_id in P.ccg_known_rare_cards)
		known_rare_count += P.ccg_known_rare_cards[card_id]
	data["knownRareCount"] = known_rare_count
	return data

/datum/ccg_deckbuilder_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/user = ui.user
	var/datum/preferences/P = user?.client?.prefs
	if(!P)
		return FALSE
	P.ccg_clean_cards()

	var/card_id = params["card"]
	switch(action)
		if("add")
			if(!deck || deck.card_ids.len >= CCG_DECK_SIZE)
				return TRUE
			var/datum/ccg_card/add_card = ccg_card(card_id)
			if(!add_card)
				return TRUE
			if(!ccg_card_allowed_for_faction(card_id, deck.faction_id))
				return TRUE
			if(ccg_card_is_limited(add_card) && !P.ccg_take_pool_card(card_id))
				return TRUE
			deck.card_ids += card_id
			if(!P.ccg_save_deck_snapshot(deck.card_ids, deck.faction_id, deck.leader_id))
				deck.card_ids.Cut(deck.card_ids.len, deck.card_ids.len + 1)
				P.ccg_return_pool_card(card_id)
				to_chat(user, span_warning("The card deck failed to save. The card was not added."))
			return TRUE
		if("remove")
			if(!deck)
				return TRUE
			while(card_id in deck.card_ids)
				var/index = deck.card_ids.Find(card_id)
				if(!index)
					break
				var/datum/ccg_card/remove_card = ccg_card(card_id)
				if(ccg_card_is_limited(remove_card) && !P.ccg_return_pool_card(card_id))
					to_chat(user, span_warning("The card pool failed to save. The card was not removed."))
					return TRUE
				deck.card_ids.Cut(index, index + 1)
			P.ccg_save_deck_snapshot(deck.card_ids, deck.faction_id, deck.leader_id)
			return TRUE
		if("remove_one")
			if(!deck)
				return TRUE
			var/index = deck.card_ids.Find(card_id)
			if(index)
				var/datum/ccg_card/remove_one_card = ccg_card(card_id)
				if(ccg_card_is_limited(remove_one_card) && !P.ccg_return_pool_card(card_id))
					to_chat(user, span_warning("The card pool failed to save. The card was not removed."))
					return TRUE
				deck.card_ids.Cut(index, index + 1)
				P.ccg_save_deck_snapshot(deck.card_ids, deck.faction_id, deck.leader_id)
			return TRUE
		if("clear")
			if(!deck)
				return TRUE
			var/list/remaining_cards = list()
			for(var/removed_id in deck.card_ids)
				var/datum/ccg_card/clear_card = ccg_card(removed_id)
				if(ccg_card_is_limited(clear_card) && !P.ccg_return_pool_card(removed_id))
					remaining_cards += removed_id
					continue
			deck.card_ids = remaining_cards
			P.ccg_save_deck_snapshot(deck.card_ids, deck.faction_id, deck.leader_id)
			return TRUE
		if("set_faction")
			if(!deck)
				return TRUE
			var/faction_id = params["faction"]
			var/datum/ccg_faction/faction = ccg_faction(faction_id)
			if(!faction)
				return TRUE
			var/old_faction_id = deck.faction_id
			var/old_leader_id = deck.leader_id
			var/list/old_card_ids = deck.card_ids.Copy()
			deck.set_faction(faction.id, faction.default_leader)
			var/list/removed_cards = deck.remove_cards_not_in_faction()
			for(var/removed_id in removed_cards)
				if(!P.ccg_return_pool_card(removed_id))
					deck.set_faction(old_faction_id, old_leader_id)
					deck.card_ids = old_card_ids
					to_chat(user, span_warning("The card pool failed to save. The faction was not changed."))
					return TRUE
			if(!P.ccg_save_deck_snapshot(deck.card_ids, deck.faction_id, deck.leader_id))
				deck.set_faction(old_faction_id, old_leader_id)
				deck.card_ids = old_card_ids
				to_chat(user, span_warning("The card deck failed to save. The faction was not changed."))
			return TRUE
		if("set_leader")
			if(!deck)
				return TRUE
			var/leader_id = params["leader"]
			var/old_leader_id = deck.leader_id
			deck.set_faction(deck.faction_id, leader_id)
			if(!P.ccg_save_deck_snapshot(deck.card_ids, deck.faction_id, deck.leader_id))
				deck.set_faction(deck.faction_id, old_leader_id)
				to_chat(user, span_warning("The card deck failed to save. The leader was not changed."))
			return TRUE
		if("request_deck")
			if(!deck)
				P.ccg_request_deck_item(user)
			return TRUE
		if("take_card")
			if(!deck)
				return TRUE
			var/card_index = deck.card_ids.Find(card_id)
			if(!card_index)
				return TRUE
			deck.card_ids.Cut(card_index, card_index + 1)
			P.ccg_save_deck_snapshot(deck.card_ids, deck.faction_id, deck.leader_id)
			var/obj/item/ccg_card_single/single = new(get_turf(user))
			single.set_card(card_id)
			user.put_in_hands(single)
			return TRUE
	return FALSE

/client/proc/ccg_open_deckpool(mob/user = mob)
	if(!user)
		return
	var/datum/ccg_deckbuilder_panel/panel = new()
	panel.ui_interact(user)

/client/proc/ccg_open_deckbuilder(obj/item/ccg_deck/deck, mob/user = mob)
	if(!user || !deck)
		return
	var/datum/ccg_deckbuilder_panel/panel = new()
	panel.deck = deck
	panel.ui_interact(user)

#undef CCG_STASH_DECK_KEY
#undef CCG_STASH_FACTION_KEY
#undef CCG_STASH_LEADER_KEY
