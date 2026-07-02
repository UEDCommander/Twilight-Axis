#define CCG_DECK_SIZE 30
#define CCG_MAX_SAVED_DECKS 10
#define CCG_VIEW_SETUP "setup"
#define CCG_VIEW_DECK "deck"
#define CCG_VIEW_POOL "pool"
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
	var/list/ccg_saved_decks = list()
	var/ccg_active_deck_index = 1
	var/ccg_deckbuilder_view_mode = CCG_VIEW_SETUP
	var/ccg_soundtrack_enabled = FALSE

/datum/preferences/proc/ccg_known_cards()
	var/list/cards = list()
	if(islist(ccg_known_rare_cards))
		for(var/card_id in ccg_known_rare_cards)
			var/count = ccg_known_rare_cards[card_id]
			if((isnum(count) && count > 0) || (!isnum(count) && (card_id in ccg_known_rare_cards)))
				cards |= card_id
	return cards

/proc/ccg_card_is_limited(datum/ccg_card/card)
	return card ? TRUE : FALSE

/proc/ccg_card_deck_limit(datum/ccg_card/card)
	if(!card)
		return 0
	if(card.rarity == CCG_RARITY_UNIQUE)
		return 1
	if(card.rarity == CCG_RARITY_RARE)
		return 2
	if(card.row == CCG_ROW_WEATHER || card.row == CCG_ROW_SPECIAL)
		return 2
	if(card.limited)
		return 3
	return 5

/datum/preferences/proc/ccg_card_pool_count(card_id)
	var/datum/ccg_card/card = ccg_card(card_id)
	if(!card)
		return 0
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
	var/deck_limit = ccg_card_deck_limit(card)
	if(ccg_selected_count(card_id) >= deck_limit)
		return FALSE
	return ccg_selected_count(card_id) < ccg_card_pool_count(card_id)

/datum/preferences/proc/ccg_available_for_deck(list/deck_cards, card_id)
	var/datum/ccg_card/card = ccg_card(card_id)
	if(!card)
		return 0
	var/deck_limit = ccg_card_deck_limit(card)
	return min(deck_limit, ccg_card_pool_count(card_id) + ccg_card_count_in_list(deck_cards, card_id))

/datum/preferences/proc/ccg_default_deck_spec(index = 1)
	var/datum/ccg_faction/faction = ccg_faction(CCG_FACTION_AZURIA)
	return list(
		"name" = "Deck [index]",
		"cards" = list(),
		"faction" = faction ? faction.id : CCG_FACTION_AZURIA,
		"leader" = faction ? faction.default_leader : "azuria_ducal_marshal",
	)

/datum/preferences/proc/ccg_normalize_deck_spec(list/spec, index = 1)
	if(!islist(spec))
		spec = ccg_default_deck_spec(index)
	var/name = spec["name"]
	if(!istext(name) || !length(name))
		name = "Deck [index]"
	var/faction_id = spec["faction"]
	var/datum/ccg_faction/faction = ccg_faction(faction_id)
	if(!faction)
		faction = ccg_faction(CCG_FACTION_AZURIA)
	var/leader_id = spec["leader"]
	var/datum/ccg_leader/leader = ccg_leader(leader_id)
	if(!leader || leader.faction != faction.id)
		leader_id = faction.default_leader
	var/list/cards = islist(spec["cards"]) ? spec["cards"] : list()
	var/list/valid_cards = list()
	var/list/card_counts = list()
	for(var/card_id in cards)
		var/datum/ccg_card/card = ccg_card(card_id)
		if(!card || !ccg_card_allowed_for_faction(card_id, faction.id) || valid_cards.len >= CCG_DECK_SIZE)
			continue
		var/card_count = card_counts[card_id]
		if(!card_count)
			card_count = 0
		if(card_count >= ccg_card_deck_limit(card))
			continue
		card_counts[card_id] = card_count + 1
		valid_cards += card_id
	return list(
		"name" = name,
		"cards" = valid_cards,
		"faction" = faction.id,
		"leader" = leader_id,
	)

/datum/preferences/proc/ccg_normalize_saved_decks()
	if(!islist(ccg_saved_decks))
		ccg_saved_decks = list()
	if(!length(ccg_saved_decks))
		ccg_saved_decks += list(list(
			"name" = "Deck 1",
			"cards" = islist(ccg_saved_deck_cards) ? ccg_saved_deck_cards.Copy() : list(),
			"faction" = ccg_saved_deck_faction,
			"leader" = ccg_saved_deck_leader,
		))
	var/list/normalized = list()
	var/index = 1
	for(var/spec in ccg_saved_decks)
		if(index > CCG_MAX_SAVED_DECKS)
			break
		normalized += list(ccg_normalize_deck_spec(spec, index))
		index++
	while(!length(normalized))
		normalized += list(ccg_default_deck_spec(1))
	ccg_saved_decks = normalized
	ccg_active_deck_index = clamp(round(text2num("[ccg_active_deck_index]") || 1), 1, length(ccg_saved_decks))
	if(!(ccg_deckbuilder_view_mode in list(CCG_VIEW_SETUP, CCG_VIEW_DECK, CCG_VIEW_POOL)))
		ccg_deckbuilder_view_mode = CCG_VIEW_SETUP
	ccg_load_active_deck()

/datum/preferences/proc/ccg_active_deck_spec()
	ccg_normalize_saved_decks()
	return ccg_saved_decks[ccg_active_deck_index]

/datum/preferences/proc/ccg_load_active_deck()
	if(!islist(ccg_saved_decks) || !length(ccg_saved_decks))
		return FALSE
	var/list/spec = ccg_saved_decks[clamp(ccg_active_deck_index, 1, length(ccg_saved_decks))]
	ccg_saved_deck_cards = islist(spec["cards"]) ? spec["cards"].Copy() : list()
	ccg_saved_deck_faction = spec["faction"]
	ccg_saved_deck_leader = spec["leader"]
	return TRUE

/datum/preferences/proc/ccg_store_active_deck(list/cards, faction_id, leader_id, name = null)
	ccg_normalize_saved_decks()
	var/list/spec = ccg_saved_decks[ccg_active_deck_index]
	if(name)
		spec["name"] = name
	spec["cards"] = islist(cards) ? cards.Copy() : list()
	spec["faction"] = faction_id
	spec["leader"] = leader_id
	ccg_saved_decks[ccg_active_deck_index] = ccg_normalize_deck_spec(spec, ccg_active_deck_index)
	ccg_load_active_deck()
	return TRUE

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
	ccg_normalize_saved_decks()

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
		var/selected_count = selected_counts[card_id]
		if(!selected_count)
			selected_count = 0
		if(selected_count >= ccg_card_deck_limit(card))
			continue
		selected_counts[card_id] = selected_count + 1
		valid_deck += card_id
	ccg_selected_deck = valid_deck

	var/list/valid_saved_deck = list()
	var/list/saved_counts = list()
	for(var/card_id in ccg_saved_deck_cards)
		var/datum/ccg_card/saved_card = ccg_card(card_id)
		if(!saved_card || !ccg_card_allowed_for_faction(card_id, ccg_saved_deck_faction) || valid_saved_deck.len >= CCG_DECK_SIZE)
			continue
		var/saved_count = saved_counts[card_id]
		if(!saved_count)
			saved_count = 0
		if(saved_count >= ccg_card_deck_limit(saved_card))
			continue
		saved_counts[card_id] = saved_count + 1
		valid_saved_deck += card_id
	ccg_saved_deck_cards = valid_saved_deck
	ccg_store_active_deck(ccg_saved_deck_cards, ccg_saved_deck_faction, ccg_saved_deck_leader)

/datum/preferences/proc/ccg_save()
	ccg_clean_cards()
	var/character_saved = save_character()
	var/preferences_saved = save_preferences()
	return character_saved || preferences_saved

/datum/preferences/proc/ccg_seed_base_pool()
	if(!length(GLOB.ccg_base_card_ids))
		ccg_build_card_registry()
	for(var/card_id in GLOB.ccg_base_card_ids)
		var/datum/ccg_card/card = ccg_card(card_id)
		if(!card)
			continue
		if(ccg_known_rare_cards[card_id])
			continue
		ccg_known_rare_cards[card_id] = ccg_card_deck_limit(card)

/datum/preferences/proc/ccg_reset_collection(seed_base_pool = TRUE)
	ccg_known_rare_cards = list()
	ccg_selected_deck = list()
	ccg_saved_deck_cards = list()
	ccg_saved_deck_faction = CCG_FACTION_AZURIA
	ccg_saved_deck_leader = "azuria_ducal_marshal"
	ccg_saved_decks = list()
	ccg_active_deck_index = 1
	if(seed_base_pool)
		ccg_seed_base_pool()
	ccg_normalize_saved_decks()
	return ccg_save()

/datum/preferences/proc/ccg_add_known_card(card_id)
	var/datum/ccg_card/card = ccg_card(card_id)
	if(!card)
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
			var/list/card_counts = list()
			for(var/card_id in deck.card_ids)
				var/datum/ccg_card/card = ccg_card(card_id)
				if(!card || !ccg_card_allowed_for_faction(card_id, faction.id) || ccg_saved_deck_cards.len >= CCG_DECK_SIZE)
					continue
				var/card_count = card_counts[card_id]
				if(!card_count)
					card_count = 0
				if(card_count >= ccg_card_deck_limit(card))
					continue
				card_counts[card_id] = card_count + 1
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
	var/list/old_saved_decks = islist(ccg_saved_decks) ? deepCopyList(ccg_saved_decks) : list()
	var/datum/ccg_faction/faction = ccg_faction(faction_id)
	if(!faction)
		faction = ccg_faction(CCG_FACTION_AZURIA)
	ccg_saved_deck_cards = list()
	var/list/saved_counts = list()
	for(var/card_id in card_ids)
		var/datum/ccg_card/card = ccg_card(card_id)
		if(!card || !ccg_card_allowed_for_faction(card_id, faction.id) || ccg_saved_deck_cards.len >= CCG_DECK_SIZE)
			continue
		var/saved_count = saved_counts[card_id]
		if(!saved_count)
			saved_count = 0
		if(saved_count >= ccg_card_deck_limit(card))
			continue
		saved_counts[card_id] = saved_count + 1
		ccg_saved_deck_cards += card_id
	ccg_saved_deck_faction = faction.id
	var/datum/ccg_leader/leader = ccg_leader(leader_id)
	ccg_saved_deck_leader = (leader && leader.faction == faction.id) ? leader.id : faction.default_leader
	ccg_store_active_deck(ccg_saved_deck_cards, ccg_saved_deck_faction, ccg_saved_deck_leader)
	if(!ccg_save())
		ccg_saved_deck_cards = old_saved_deck_cards
		ccg_saved_deck_faction = old_saved_deck_faction
		ccg_saved_deck_leader = old_saved_deck_leader
		ccg_saved_decks = old_saved_decks
		ccg_clean_cards()
		return FALSE
	return TRUE

/datum/preferences/proc/ccg_replace_active_deck_from_pool(list/card_ids, faction_id = CCG_FACTION_AZURIA, leader_id = null, deck_name = null)
	if(!islist(card_ids))
		return FALSE
	ccg_clean_cards()
	var/list/old_known_cards = islist(ccg_known_rare_cards) ? ccg_known_rare_cards.Copy() : list()
	var/list/old_saved_deck_cards = islist(ccg_saved_deck_cards) ? ccg_saved_deck_cards.Copy() : list()
	var/old_saved_deck_faction = ccg_saved_deck_faction
	var/old_saved_deck_leader = ccg_saved_deck_leader
	var/list/old_saved_decks = islist(ccg_saved_decks) ? deepCopyList(ccg_saved_decks) : list()
	var/list/old_active_spec = ccg_saved_decks[ccg_active_deck_index]
	if(!istext(deck_name) || !length(deck_name))
		deck_name = islist(old_active_spec) ? old_active_spec["name"] : "Deck [ccg_active_deck_index]"
	for(var/old_card_id in old_saved_deck_cards)
		ccg_known_rare_cards[old_card_id] = (ccg_known_rare_cards[old_card_id] || 0) + 1
	var/list/spec = ccg_normalize_deck_spec(list(
		"name" = deck_name,
		"cards" = card_ids,
		"faction" = faction_id,
		"leader" = leader_id,
	), ccg_active_deck_index)
	var/list/import_cards = spec["cards"]
	var/list/needed_counts = list()
	for(var/card_id in import_cards)
		needed_counts[card_id] = (needed_counts[card_id] || 0) + 1
	for(var/card_id in needed_counts)
		if(needed_counts[card_id] > ccg_card_pool_count(card_id))
			ccg_known_rare_cards = old_known_cards
			ccg_saved_deck_cards = old_saved_deck_cards
			ccg_saved_deck_faction = old_saved_deck_faction
			ccg_saved_deck_leader = old_saved_deck_leader
			ccg_saved_decks = old_saved_decks
			return FALSE
	for(var/card_id in import_cards)
		var/count = ccg_known_rare_cards[card_id]
		if(!count)
			ccg_known_rare_cards = old_known_cards
			ccg_saved_deck_cards = old_saved_deck_cards
			ccg_saved_deck_faction = old_saved_deck_faction
			ccg_saved_deck_leader = old_saved_deck_leader
			ccg_saved_decks = old_saved_decks
			return FALSE
		count--
		if(count > 0)
			ccg_known_rare_cards[card_id] = count
		else
			ccg_known_rare_cards -= card_id
	ccg_store_active_deck(import_cards, spec["faction"], spec["leader"], spec["name"])
	if(!ccg_save())
		ccg_known_rare_cards = old_known_cards
		ccg_saved_deck_cards = old_saved_deck_cards
		ccg_saved_deck_faction = old_saved_deck_faction
		ccg_saved_deck_leader = old_saved_deck_leader
		ccg_saved_decks = old_saved_decks
		ccg_clean_cards()
		return FALSE
	return TRUE

/datum/preferences/proc/ccg_set_active_deck(index)
	ccg_clean_cards()
	index = clamp(round(text2num("[index]") || 1), 1, length(ccg_saved_decks))
	ccg_active_deck_index = index
	ccg_load_active_deck()
	return ccg_save()

/datum/preferences/proc/ccg_create_deck()
	ccg_clean_cards()
	if(length(ccg_saved_decks) >= CCG_MAX_SAVED_DECKS)
		return FALSE
	ccg_saved_decks += list(ccg_default_deck_spec(length(ccg_saved_decks) + 1))
	ccg_active_deck_index = length(ccg_saved_decks)
	ccg_load_active_deck()
	return ccg_save()

/datum/preferences/proc/ccg_rename_active_deck(new_name)
	if(!istext(new_name))
		return FALSE
	new_name = trim(copytext(new_name, 1, 33))
	if(!length(new_name))
		return FALSE
	ccg_clean_cards()
	var/list/spec = ccg_saved_decks[ccg_active_deck_index]
	spec["name"] = new_name
	ccg_saved_decks[ccg_active_deck_index] = spec
	return ccg_save()

/datum/preferences/proc/ccg_set_view_mode(mode)
	if(!(mode in list(CCG_VIEW_SETUP, CCG_VIEW_DECK, CCG_VIEW_POOL)))
		return FALSE
	ccg_deckbuilder_view_mode = mode
	return ccg_save()

/datum/preferences/proc/ccg_first_deck_cards(faction_id = CCG_FACTION_AZURIA)
	ccg_clean_cards()
	var/datum/ccg_faction/faction = ccg_faction(faction_id)
	if(!faction)
		faction = ccg_faction(CCG_FACTION_AZURIA)
	var/list/deck_cards = list()
	var/list/pool_counts = islist(ccg_known_rare_cards) ? ccg_known_rare_cards.Copy() : list()
	for(var/card_id in GLOB.ccg_cards_by_id)
		if(deck_cards.len >= CCG_DECK_SIZE)
			break
		var/datum/ccg_card/card = ccg_card(card_id)
		if(!card || !ccg_card_allowed_for_faction(card_id, faction.id))
			continue
		var/available = min(ccg_card_deck_limit(card), max(0, pool_counts[card_id]))
		while(available > 0 && deck_cards.len < CCG_DECK_SIZE)
			deck_cards += card_id
			available--
	return deck_cards

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

/datum/preferences/proc/ccg_give_deck_item(mob/user)
	ccg_clean_cards()
	if(!user?.mind)
		return FALSE
	if(user.mind.ccg_deck_requested)
		to_chat(user, span_warning("You have already taken a card battle deck this round."))
		return FALSE
	var/list/deck_cards = length(ccg_saved_deck_cards) ? ccg_saved_deck_cards.Copy() : ccg_first_deck_cards(ccg_saved_deck_faction)
	while(deck_cards.len > CCG_DECK_SIZE)
		deck_cards.Cut(deck_cards.len, deck_cards.len + 1)
	if(!ccg_save_deck_snapshot(deck_cards, ccg_saved_deck_faction, ccg_saved_deck_leader))
		to_chat(user, span_warning("The card battle deck failed to save. Try again."))
		return FALSE
	var/obj/item/ccg_deck/new_deck = new(get_turf(user))
	new_deck.set_faction(ccg_saved_deck_faction, ccg_saved_deck_leader)
	new_deck.set_cards(deck_cards)
	new_deck.owner_ckey = user.ckey
	var/owner_name = user.real_name || user.name
	if(owner_name)
		new_deck.name = "Card Deck of [owner_name]"
	new_deck.loaded_from_preferences = TRUE
	user.put_in_hands(new_deck)
	user.mind.ccg_deck_requested = TRUE
	to_chat(user, span_notice("You take a card battle deck."))
	return TRUE

/datum/preferences/proc/ccg_export_active_deck(mob/user)
	ccg_clean_cards()
	var/list/spec = ccg_active_deck_spec()
	var/export_json = json_encode(spec)
	var/export_text = input(user, "Copy this deck export.", "Gwynt Deck Export", export_json) as null|message
	return !!export_text

/datum/preferences/proc/ccg_import_active_deck(mob/user)
	if(!user)
		return FALSE
	var/import_text = input(user, "Paste a Gwynt deck export.", "Gwynt Deck Import") as null|message
	if(!istext(import_text) || !length(import_text))
		return FALSE
	var/list/spec = safe_json_decode(import_text)
	if(!islist(spec))
		to_chat(user, span_warning("This is not a valid Gwynt deck export."))
		return FALSE
	ccg_clean_cards()
	var/list/normalized = ccg_normalize_deck_spec(spec, ccg_active_deck_index)
	if(ccg_replace_active_deck_from_pool(normalized["cards"], normalized["faction"], normalized["leader"], normalized["name"]))
		to_chat(user, span_notice("The imported deck is saved into the active deck slot."))
		return TRUE
	to_chat(user, span_warning("Your pool is missing cards for this deck, or the imported deck failed to save."))
	return FALSE

/datum/preferences/proc/ccg_start_solo_match(mob/user)
	ccg_clean_cards()
	if(!user)
		return FALSE
	var/list/deck_cards = length(ccg_saved_deck_cards) ? ccg_saved_deck_cards.Copy() : ccg_first_deck_cards(ccg_saved_deck_faction)
	if(deck_cards.len <= 1)
		to_chat(user, span_warning("The active Gwynt deck needs more than one card before a solo match can start."))
		return FALSE
	var/turf/start_turf = get_turf(user)
	var/obj/item/ccg_deck/player_deck = new(start_turf)
	player_deck.name = "solo Gwynt deck"
	player_deck.set_faction(ccg_saved_deck_faction, ccg_saved_deck_leader)
	player_deck.set_cards(deck_cards)
	player_deck.owner_ckey = user.ckey
	player_deck.loaded_from_preferences = TRUE
	var/obj/item/ccg_deck/opponent_deck = new(start_turf)
	opponent_deck.name = "solo opponent Gwynt deck"
	opponent_deck.set_faction(ccg_saved_deck_faction, ccg_saved_deck_leader)
	opponent_deck.set_cards(deck_cards)
	opponent_deck.owner_ckey = user.ckey
	opponent_deck.loaded_from_preferences = TRUE
	player_deck.match = new(player_deck, user, player_deck, user, opponent_deck)
	opponent_deck.match_host = player_deck
	opponent_deck.match = player_deck.match
	user.put_in_hands(player_deck)
	opponent_deck.ui_interact(user)
	player_deck.ui_interact(user)
	to_chat(user, span_notice("A solo Gwynt match starts. Use both opened deck windows to play both sides."))
	return TRUE

/datum/ccg_deckbuilder_panel
	var/obj/item/ccg_deck/deck

/datum/ccg_deckbuilder_panel/ui_state(mob/user)
	return GLOB.always_state

/datum/ccg_deckbuilder_panel/ui_assets(mob/user)
	return list(get_asset_datum(/datum/asset/simple/ccg_cards))

/client/proc/ccg_migrate_saved_card_deck()
	ccg_migrate_stashed_deck_specs(mob)

/datum/ccg_deckbuilder_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CardDeckBuilder", deck ? "Card Deck Builder" : "CCG Deck")
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
		card_data["ownedCount"] = P.ccg_available_for_deck(selected, card_id)
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
	data["displayMode"] = P.ccg_deckbuilder_view_mode
	data["cards"] = cards
	data["selected"] = selected
	data["selectedCount"] = selected.len
	data["deckSize"] = CCG_DECK_SIZE
	data["faction"] = current_faction_id
	data["leader"] = deck ? deck.leader_id : P.ccg_saved_deck_leader
	data["activeDeckIndex"] = P.ccg_active_deck_index
	data["maxDecks"] = CCG_MAX_SAVED_DECKS
	var/list/saved_decks = list()
	var/deck_index = 1
	for(var/spec in P.ccg_saved_decks)
		var/list/cards_in_deck = islist(spec["cards"]) ? spec["cards"] : list()
		saved_decks += list(list(
			"index" = deck_index,
			"name" = spec["name"],
			"count" = cards_in_deck.len,
			"faction" = spec["faction"],
			"leader" = spec["leader"],
		))
		deck_index++
	data["decks"] = saved_decks
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
	var/list/target_cards = deck ? deck.card_ids : P.ccg_saved_deck_cards
	var/target_faction_id = deck ? deck.faction_id : P.ccg_saved_deck_faction
	var/target_leader_id = deck ? deck.leader_id : P.ccg_saved_deck_leader
	switch(action)
		if("add")
			if(!islist(target_cards) || target_cards.len >= CCG_DECK_SIZE)
				return TRUE
			var/datum/ccg_card/add_card = ccg_card(card_id)
			if(!add_card)
				return TRUE
			if(!ccg_card_allowed_for_faction(card_id, target_faction_id))
				return TRUE
			if(ccg_card_count_in_list(target_cards, card_id) >= P.ccg_available_for_deck(target_cards, card_id))
				return TRUE
			if(ccg_card_is_limited(add_card) && !P.ccg_take_pool_card(card_id))
				return TRUE
			target_cards += card_id
			if(deck)
				deck.card_ids = target_cards
			if(!P.ccg_save_deck_snapshot(target_cards, target_faction_id, target_leader_id))
				target_cards.Cut(target_cards.len, target_cards.len + 1)
				if(deck)
					deck.card_ids = target_cards
				P.ccg_return_pool_card(card_id)
				to_chat(user, span_warning("The card deck failed to save. The card was not added."))
			return TRUE
		if("remove")
			if(!islist(target_cards))
				return TRUE
			while(card_id in target_cards)
				var/index = target_cards.Find(card_id)
				if(!index)
					break
				var/datum/ccg_card/remove_card = ccg_card(card_id)
				if(ccg_card_is_limited(remove_card) && !P.ccg_return_pool_card(card_id))
					to_chat(user, span_warning("The card pool failed to save. The card was not removed."))
					return TRUE
				target_cards.Cut(index, index + 1)
			if(deck)
				deck.card_ids = target_cards
			P.ccg_save_deck_snapshot(target_cards, target_faction_id, target_leader_id)
			return TRUE
		if("remove_one")
			if(!islist(target_cards))
				return TRUE
			var/index = target_cards.Find(card_id)
			if(index)
				var/datum/ccg_card/remove_one_card = ccg_card(card_id)
				if(ccg_card_is_limited(remove_one_card) && !P.ccg_return_pool_card(card_id))
					to_chat(user, span_warning("The card pool failed to save. The card was not removed."))
					return TRUE
				target_cards.Cut(index, index + 1)
				if(deck)
					deck.card_ids = target_cards
				P.ccg_save_deck_snapshot(target_cards, target_faction_id, target_leader_id)
			return TRUE
		if("clear")
			if(!islist(target_cards))
				return TRUE
			var/list/remaining_cards = list()
			for(var/removed_id in target_cards)
				var/datum/ccg_card/clear_card = ccg_card(removed_id)
				if(ccg_card_is_limited(clear_card) && !P.ccg_return_pool_card(removed_id))
					remaining_cards += removed_id
					continue
			target_cards = remaining_cards
			if(deck)
				deck.card_ids = target_cards
			P.ccg_save_deck_snapshot(target_cards, target_faction_id, target_leader_id)
			return TRUE
		if("set_faction")
			var/faction_id = params["faction"]
			var/datum/ccg_faction/faction = ccg_faction(faction_id)
			if(!faction)
				return TRUE
			var/old_faction_id = target_faction_id
			var/old_leader_id = target_leader_id
			var/list/old_card_ids = target_cards.Copy()
			var/list/removed_cards = list()
			var/list/kept_cards = list()
			for(var/checked_id in target_cards)
				if(ccg_card_allowed_for_faction(checked_id, faction.id))
					kept_cards += checked_id
				else
					removed_cards += checked_id
			for(var/removed_id in removed_cards)
				if(!P.ccg_return_pool_card(removed_id))
					if(deck)
						deck.set_faction(old_faction_id, old_leader_id)
						deck.card_ids = old_card_ids
					to_chat(user, span_warning("The card pool failed to save. The faction was not changed."))
					return TRUE
			if(deck)
				deck.set_faction(faction.id, faction.default_leader)
				deck.card_ids = kept_cards
			if(!P.ccg_save_deck_snapshot(kept_cards, faction.id, faction.default_leader))
				if(deck)
					deck.set_faction(old_faction_id, old_leader_id)
					deck.card_ids = old_card_ids
				to_chat(user, span_warning("The card deck failed to save. The faction was not changed."))
			return TRUE
		if("set_leader")
			var/leader_id = params["leader"]
			var/old_leader_id = target_leader_id
			var/datum/ccg_leader/new_leader = ccg_leader(leader_id)
			if(!new_leader || new_leader.faction != target_faction_id)
				return TRUE
			if(deck)
				deck.set_faction(target_faction_id, leader_id)
			if(!P.ccg_save_deck_snapshot(target_cards, target_faction_id, leader_id))
				if(deck)
					deck.set_faction(target_faction_id, old_leader_id)
				to_chat(user, span_warning("The card deck failed to save. The leader was not changed."))
			return TRUE
		if("set_view")
			P.ccg_set_view_mode(params["view"])
			return TRUE
		if("select_deck")
			P.ccg_set_active_deck(params["index"])
			if(deck)
				deck.set_faction(P.ccg_saved_deck_faction, P.ccg_saved_deck_leader)
				deck.set_cards(P.ccg_saved_deck_cards)
			return TRUE
		if("create_deck")
			if(!P.ccg_create_deck())
				to_chat(user, span_warning("You cannot create another card deck."))
			return TRUE
		if("rename_deck")
			P.ccg_rename_active_deck(params["name"])
			return TRUE
		if("import_held_deck")
			var/obj/item/held_item = user.get_active_held_item()
			if(!istype(held_item, /obj/item/ccg_deck))
				held_item = user.get_inactive_held_item()
			if(!istype(held_item, /obj/item/ccg_deck))
				to_chat(user, span_warning("Hold a card battle deck to import it."))
				return TRUE
			var/obj/item/ccg_deck/held_deck = held_item
			if(P.ccg_replace_active_deck_from_pool(held_deck.card_ids, held_deck.faction_id, held_deck.leader_id))
				to_chat(user, span_notice("The held card deck is imported into the active saved deck."))
			else
				to_chat(user, span_warning("The held card deck failed to import."))
			return TRUE
		if("export_deck")
			P.ccg_export_active_deck(user)
			return TRUE
		if("import_deck")
			P.ccg_import_active_deck(user)
			if(deck)
				deck.set_faction(P.ccg_saved_deck_faction, P.ccg_saved_deck_leader)
				deck.set_cards(P.ccg_saved_deck_cards)
			return TRUE
		if("start_solo")
			P.ccg_start_solo_match(user)
			return TRUE
		if("load_saved_deck")
			if(deck)
				deck.set_faction(P.ccg_saved_deck_faction, P.ccg_saved_deck_leader)
				deck.set_cards(P.ccg_saved_deck_cards)
				to_chat(user, span_notice("The saved card deck is loaded into this deck."))
			return TRUE
		if("save_physical_deck")
			if(deck)
				P.ccg_save_deck_snapshot(deck.card_ids, deck.faction_id, deck.leader_id)
				to_chat(user, span_notice("This card deck is saved."))
			return TRUE
		if("take_card")
			if(!deck)
				return TRUE
			var/card_index = deck.card_ids.Find(card_id)
			if(!card_index)
				return TRUE
			deck.card_ids.Cut(card_index, card_index + 1)
			if(!P.ccg_return_pool_card(card_id))
				deck.card_ids.Insert(card_index, card_id)
				to_chat(user, span_warning("The card pool failed to save. The card was not removed."))
				return TRUE
			if(!P.ccg_save_deck_snapshot(deck.card_ids, deck.faction_id, deck.leader_id))
				P.ccg_take_pool_card(card_id)
				deck.card_ids.Insert(card_index, card_id)
				to_chat(user, span_warning("The card deck failed to save. The card was not removed."))
				return TRUE
			var/obj/item/ccg_card_single/single = new(get_turf(user))
			single.set_card(card_id)
			single.pooled = TRUE
			user.put_in_hands(single)
			return TRUE
	return FALSE

/mob/living/verb/open_ccg_deck()
	set name = "CCG Deck"
	set category = "IC"
	if(!client)
		return
	client.prefs?.ccg_give_deck_item(src)

/client/proc/ccg_open_deckbuilder(obj/item/ccg_deck/deck, mob/user = mob)
	if(!user || !deck)
		return
	var/datum/ccg_deckbuilder_panel/panel = new()
	panel.deck = deck
	panel.ui_interact(user)

#undef CCG_STASH_DECK_KEY
#undef CCG_STASH_FACTION_KEY
#undef CCG_STASH_LEADER_KEY
