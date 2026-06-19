#define CCI_SIDE_ONE "one"
#define CCI_SIDE_TWO "two"
#define CCI_HAND_SIZE 10

/datum/cci_played_card
	var/card_id
	var/owner_side
	var/current_power = 0

/datum/cci_played_card/New(new_card_id, new_owner_side)
	card_id = new_card_id
	owner_side = new_owner_side
	var/datum/cci_card/card = cci_card(card_id)
	current_power = card ? card.power : 0

/datum/cci_match
	var/obj/item/cci_deck/owner
	var/obj/item/cci_deck/challenger
	var/list/player_ckeys = list()
	var/list/player_names = list()
	var/list/decks = list()
	var/list/hands = list()
	var/list/discarded = list()
	var/list/board = list()
	var/list/round_wins = list()
	var/list/passed = list()
	var/list/weather = list()
	var/list/weather_board = list()
	var/list/row_effects = list()
	var/list/combo_morale = list()
	var/turn = CCI_SIDE_ONE
	var/round_number = 1
	var/result_text
	var/last_message

/datum/cci_match/New(obj/item/cci_deck/new_owner, mob/p1, obj/item/cci_deck/d1, mob/p2, obj/item/cci_deck/d2)
	owner = new_owner
	challenger = d2
	player_ckeys[CCI_SIDE_ONE] = p1.ckey
	player_ckeys[CCI_SIDE_TWO] = p2.ckey
	player_names[CCI_SIDE_ONE] = p1.real_name ? p1.real_name : p1.name
	player_names[CCI_SIDE_TWO] = p2.real_name ? p2.real_name : p2.name
	decks[CCI_SIDE_ONE] = shuffle(d1.card_ids.Copy())
	decks[CCI_SIDE_TWO] = shuffle(d2.card_ids.Copy())
	hands[CCI_SIDE_ONE] = list()
	hands[CCI_SIDE_TWO] = list()
	discarded[CCI_SIDE_ONE] = list()
	discarded[CCI_SIDE_TWO] = list()
	round_wins[CCI_SIDE_ONE] = 0
	round_wins[CCI_SIDE_TWO] = 0
	start_round(TRUE)

/datum/cci_match/Destroy()
	if(owner)
		if(owner.match == src)
			owner.match = null
		if(owner.match_host)
			owner.match_host = null
	if(challenger)
		if(challenger.match == src)
			challenger.match = null
		if(challenger.match_host == owner)
			challenger.match_host = null
	owner = null
	challenger = null
	player_ckeys = null
	player_names = null
	decks = null
	hands = null
	discarded = null
	board = null
	round_wins = null
	passed = null
	weather = null
	weather_board = null
	row_effects = null
	combo_morale = null
	return ..()

/datum/cci_match/proc/update_deck_uis()
	if(owner)
		SStgui.update_uis(owner)
	if(challenger)
		SStgui.update_uis(challenger)

/datum/cci_match/proc/start_round(first_round = FALSE)
	board = list(
		CCI_SIDE_ONE = list(CCI_ROW_INFANTRY = list(), CCI_ROW_ARCHERS = list(), CCI_ROW_SIEGE = list()),
		CCI_SIDE_TWO = list(CCI_ROW_INFANTRY = list(), CCI_ROW_ARCHERS = list(), CCI_ROW_SIEGE = list())
	)
	passed[CCI_SIDE_ONE] = FALSE
	passed[CCI_SIDE_TWO] = FALSE
	weather = list()
	weather_board = list()
	row_effects = list(
		CCI_SIDE_ONE = list(CCI_ROW_INFANTRY = list(), CCI_ROW_ARCHERS = list(), CCI_ROW_SIEGE = list()),
		CCI_SIDE_TWO = list(CCI_ROW_INFANTRY = list(), CCI_ROW_ARCHERS = list(), CCI_ROW_SIEGE = list())
	)
	combo_morale = list(
		CCI_SIDE_ONE = list(CCI_ROW_INFANTRY = 0, CCI_ROW_ARCHERS = 0, CCI_ROW_SIEGE = 0),
		CCI_SIDE_TWO = list(CCI_ROW_INFANTRY = 0, CCI_ROW_ARCHERS = 0, CCI_ROW_SIEGE = 0)
	)
	if(first_round)
		draw_cards(CCI_SIDE_ONE, CCI_HAND_SIZE)
		draw_cards(CCI_SIDE_TWO, CCI_HAND_SIZE)
	else
		draw_to_hand_size(CCI_SIDE_ONE)
		draw_to_hand_size(CCI_SIDE_TWO)
	turn = (round_number % 2) ? CCI_SIDE_ONE : CCI_SIDE_TWO
	last_message = "Round [round_number] begins."

/datum/cci_match/proc/draw_to_hand_size(side)
	var/list/hand = hands[side]
	var/needed = CCI_HAND_SIZE - length(hand)
	if(needed > 0)
		draw_cards(side, needed)

/datum/cci_match/proc/draw_cards(side, amount)
	var/list/deck = decks[side]
	var/list/hand = hands[side]
	for(var/i = 1, i <= amount, i++)
		if(!length(deck))
			return
		hand += deck[1]
		deck.Cut(1, 2)

/datum/cci_match/proc/side_for_user(mob/user, obj/item/cci_deck/deck_context)
	if(!user?.ckey)
		return null
	if(player_ckeys[CCI_SIDE_ONE] == player_ckeys[CCI_SIDE_TWO] && deck_context)
		if(deck_context == owner)
			return CCI_SIDE_ONE
		if(deck_context == challenger)
			return CCI_SIDE_TWO
	if(user.ckey == player_ckeys[CCI_SIDE_ONE])
		return CCI_SIDE_ONE
	if(user.ckey == player_ckeys[CCI_SIDE_TWO])
		return CCI_SIDE_TWO
	return null

/datum/cci_match/proc/opposite(side)
	return side == CCI_SIDE_ONE ? CCI_SIDE_TWO : CCI_SIDE_ONE

/datum/cci_match/proc/play_card(mob/user, card_id, obj/item/cci_deck/deck_context)
	var/side = side_for_user(user, deck_context)
	if(!side || side != turn || passed[side] || result_text)
		return FALSE
	var/list/hand = hands[side]
	if(!(card_id in hand))
		return FALSE
	var/datum/cci_card/card = cci_card(card_id)
	if(!card)
		return FALSE
	var/card_index = hand.Find(card_id)
	if(!card_index)
		return FALSE
	hand.Cut(card_index, card_index + 1)
	if(is_special_action_card(card))
		apply_special_action_card(card, side)
	else if(is_weather_card(card))
		apply_weather_card(card, side)
	else
		var/play_side = side
		if(card.effect == CCI_EFFECT_SPY)
			play_side = opposite(side)
			draw_cards(side, 2)
		board[play_side][card.row] += new /datum/cci_played_card(card_id, side)
		if(card.effect == CCI_EFFECT_MUSTER)
			muster_copies(card, side, play_side)
		if(card.effect == CCI_EFFECT_MEDIC)
			revive_strongest_discard(side)
		apply_card_effect(card, side, play_side)
		if(apply_combo_effect(card, side, play_side))
			last_message = "[player_names[side]] plays [card.name]. A combo triggers."
		else
			last_message = "[player_names[side]] plays [card.name]."
	recalculate_board()
	if(is_weather_card(card))
		last_message = "[player_names[side]] plays [card.name]."
	advance_turn()
	return TRUE

/datum/cci_match/proc/pass(mob/user, obj/item/cci_deck/deck_context)
	var/side = side_for_user(user, deck_context)
	if(!side || side != turn || result_text)
		return FALSE
	passed[side] = TRUE
	last_message = "[player_names[side]] passes."
	advance_turn()
	return TRUE

/datum/cci_match/proc/advance_turn()
	if(passed[CCI_SIDE_ONE] && passed[CCI_SIDE_TWO])
		end_round()
		return
	var/other = opposite(turn)
	if(!passed[other])
		turn = other

/datum/cci_match/proc/apply_weather_card(datum/cci_card/card, side)
	if(card.effect == CCI_EFFECT_CLEAR_WEATHER)
		for(var/datum/cci_played_card/played in weather_board)
			discarded[played.owner_side] += played.card_id
		weather_board = list()
		weather = list()
		discarded[side] += card.id
	else if(card.effect == CCI_EFFECT_FROST)
		weather |= CCI_ROW_INFANTRY
		weather_board += new /datum/cci_played_card(card.id, side)
	else if(card.effect == CCI_EFFECT_FOG)
		weather |= CCI_ROW_ARCHERS
		weather_board += new /datum/cci_played_card(card.id, side)
	else if(card.effect == CCI_EFFECT_RAIN)
		weather |= CCI_ROW_SIEGE
		weather_board += new /datum/cci_played_card(card.id, side)

/datum/cci_match/proc/is_weather_card(datum/cci_card/card)
	return card.effect in list(CCI_EFFECT_CLEAR_WEATHER, CCI_EFFECT_FROST, CCI_EFFECT_FOG, CCI_EFFECT_RAIN)

/datum/cci_match/proc/is_special_action_card(datum/cci_card/card)
	return card.effect in list(CCI_EFFECT_DECOY, CCI_EFFECT_HORN, CCI_EFFECT_SCORCH_GLOBAL, CCI_EFFECT_MARDROEME)

/datum/cci_match/proc/apply_special_action_card(datum/cci_card/card, side)
	if(card.effect == CCI_EFFECT_DECOY)
		return_strongest_own_unit_to_hand(side)
		discarded[side] += card.id
		last_message = "[player_names[side]] plays [card.name]."
		return
	if(card.effect == CCI_EFFECT_SCORCH_GLOBAL)
		recalculate_board()
		scorch_strongest_global()
		discarded[side] += card.id
		last_message = "[player_names[side]] plays [card.name]."
		return
	if(card.effect == CCI_EFFECT_HORN || card.effect == CCI_EFFECT_MARDROEME)
		var/target_row = card.target_row
		if(!target_row)
			target_row = card.row
		if(card.effect == CCI_EFFECT_HORN && row_has_effect(side, target_row, CCI_EFFECT_HORN))
			discarded[side] += card.id
			last_message = "[player_names[side]] plays [card.name], but that row already has a horn."
			return
		row_effects[side][target_row] += new /datum/cci_played_card(card.id, side)
		last_message = "[player_names[side]] plays [card.name]."

/datum/cci_match/proc/row_has_effect(side, row, effect)
	for(var/datum/cci_played_card/played in row_effects[side][row])
		var/datum/cci_card/card = cci_card(played.card_id)
		if(card?.effect == effect)
			return TRUE
	return FALSE

/datum/cci_match/proc/apply_card_effect(datum/cci_card/card, owner_side, play_side)
	if(card.effect == CCI_EFFECT_SCORCH)
		scorch_strongest_enemy(owner_side)
	else if(card.effect == CCI_EFFECT_SCORCH_INFANTRY)
		scorch_enemy_infantry(owner_side)

/datum/cci_match/proc/apply_combo_effect(datum/cci_card/card, owner_side, play_side)
	if(card.combo_effect == CCI_EFFECT_NONE || !length(card.combo_with))
		return FALSE
	if(!combo_partner_present(card, play_side))
		return FALSE
	if(card.combo_effect == CCI_EFFECT_SCORCH)
		scorch_strongest_enemy(owner_side)
	else if(card.combo_effect == CCI_EFFECT_MORALE)
		combo_morale[play_side][card.row]++
		recalculate_board()
	return TRUE

/datum/cci_match/proc/combo_partner_present(datum/cci_card/card, play_side)
	for(var/row in list(CCI_ROW_INFANTRY, CCI_ROW_ARCHERS, CCI_ROW_SIEGE))
		for(var/datum/cci_played_card/played in board[play_side][row])
			if(played.card_id != card.id && (played.card_id in card.combo_with))
				return TRUE
	return FALSE

/datum/cci_match/proc/scorch_strongest_enemy(owner_side)
	var/enemy = opposite(owner_side)
	var/datum/cci_played_card/strongest
	var/strongest_row
	for(var/row in list(CCI_ROW_INFANTRY, CCI_ROW_ARCHERS, CCI_ROW_SIEGE))
		for(var/datum/cci_played_card/played in board[enemy][row])
			if(!strongest || played.current_power > strongest.current_power)
				strongest = played
				strongest_row = row
	if(strongest)
		destroy_played_card(enemy, strongest_row, strongest)

/datum/cci_match/proc/scorch_enemy_infantry(owner_side)
	recalculate_board()
	var/enemy = opposite(owner_side)
	var/row_total = 0
	var/highest = 0
	for(var/datum/cci_played_card/played in board[enemy][CCI_ROW_INFANTRY])
		row_total += played.current_power
		highest = max(highest, played.current_power)
	if(row_total < 10 || highest <= 0)
		return
	var/list/infantry_row = board[enemy][CCI_ROW_INFANTRY]
	var/list/infantry_copy = infantry_row.Copy()
	for(var/datum/cci_played_card/played in infantry_copy)
		if(played.current_power == highest)
			destroy_played_card(enemy, CCI_ROW_INFANTRY, played)

/datum/cci_match/proc/scorch_strongest_global()
	var/highest = 0
	for(var/side in list(CCI_SIDE_ONE, CCI_SIDE_TWO))
		for(var/row in list(CCI_ROW_INFANTRY, CCI_ROW_ARCHERS, CCI_ROW_SIEGE))
			for(var/datum/cci_played_card/played in board[side][row])
				highest = max(highest, played.current_power)
	if(highest <= 0)
		return
	for(var/side in list(CCI_SIDE_ONE, CCI_SIDE_TWO))
		for(var/row in list(CCI_ROW_INFANTRY, CCI_ROW_ARCHERS, CCI_ROW_SIEGE))
			var/list/board_row = board[side][row]
			var/list/row_copy = board_row.Copy()
			for(var/datum/cci_played_card/played in row_copy)
				if(played.current_power == highest)
					destroy_played_card(side, row, played)

/datum/cci_match/proc/destroy_played_card(side, row, datum/cci_played_card/played)
	board[side][row] -= played
	discarded[played.owner_side] += played.card_id
	var/datum/cci_card/card = cci_card(played.card_id)
	if(card?.effect == CCI_EFFECT_AVENGER && card.avenger_card && cci_card(card.avenger_card))
		board[side][row] += new /datum/cci_played_card(card.avenger_card, played.owner_side)

/datum/cci_match/proc/return_strongest_own_unit_to_hand(side)
	recalculate_board()
	var/datum/cci_played_card/strongest
	var/strongest_row
	for(var/row in list(CCI_ROW_INFANTRY, CCI_ROW_ARCHERS, CCI_ROW_SIEGE))
		for(var/datum/cci_played_card/played in board[side][row])
			if(!strongest || played.current_power > strongest.current_power)
				strongest = played
				strongest_row = row
	if(strongest)
		board[side][strongest_row] -= strongest
		hands[side] += strongest.card_id

/datum/cci_match/proc/revive_strongest_discard(side)
	var/list/discard = discarded[side]
	var/card_id
	var/card_power = -1
	for(var/id in discard)
		var/datum/cci_card/card = cci_card(id)
		if(!card || card.row == CCI_ROW_WEATHER || card.effect == CCI_EFFECT_HORN || card.effect == CCI_EFFECT_DECOY)
			continue
		if(card.power > card_power)
			card_id = id
			card_power = card.power
	if(!card_id)
		return
	var/index = discard.Find(card_id)
	if(index)
		discard.Cut(index, index + 1)
		var/datum/cci_card/card = cci_card(card_id)
		board[side][card.row] += new /datum/cci_played_card(card_id, side)

/datum/cci_match/proc/muster_copies(datum/cci_card/card, owner_side, play_side)
	var/list/hand = hands[owner_side]
	var/index = hand.Find(card.id)
	while(index)
		hand.Cut(index, index + 1)
		board[play_side][card.row] += new /datum/cci_played_card(card.id, owner_side)
		index = hand.Find(card.id)
	var/list/deck = decks[owner_side]
	index = deck.Find(card.id)
	while(index)
		deck.Cut(index, index + 1)
		board[play_side][card.row] += new /datum/cci_played_card(card.id, owner_side)
		index = deck.Find(card.id)

/datum/cci_match/proc/recalculate_board()
	for(var/side in list(CCI_SIDE_ONE, CCI_SIDE_TWO))
		for(var/row in list(CCI_ROW_INFANTRY, CCI_ROW_ARCHERS, CCI_ROW_SIEGE))
			var/morale = 0
			var/list/bond_counts = list()
			for(var/datum/cci_played_card/played in board[side][row])
				var/datum/cci_card/card = cci_card(played.card_id)
				if(card?.effect == CCI_EFFECT_MORALE)
					morale++
				if(card?.effect == CCI_EFFECT_BOND)
					var/current_bond_count = bond_counts[played.card_id]
					if(!current_bond_count)
						current_bond_count = 0
					bond_counts[played.card_id] = current_bond_count + 1
			morale += combo_morale[side][row]
			var/horn = row_has_effect(side, row, CCI_EFFECT_HORN)
			var/mardroeme = row_has_effect(side, row, CCI_EFFECT_MARDROEME)
			for(var/datum/cci_played_card/played in board[side][row])
				var/datum/cci_card/card = cci_card(played.card_id)
				if(!card)
					continue
				var/value = card.power
				if(card.effect == CCI_EFFECT_BERSERK && mardroeme)
					value = max(value, card.bear_power)
				if(row in weather)
					value = min(value, 1)
				var/final_bond_count = bond_counts[played.card_id]
				if(card.effect == CCI_EFFECT_BOND && final_bond_count > 1)
					value *= final_bond_count
				if(card.effect != CCI_EFFECT_MORALE)
					value += morale
				if(horn)
					value *= 2
				played.current_power = value

/datum/cci_match/proc/score(side)
	recalculate_board()
	var/total = 0
	for(var/row in list(CCI_ROW_INFANTRY, CCI_ROW_ARCHERS, CCI_ROW_SIEGE))
		for(var/datum/cci_played_card/played in board[side][row])
			total += played.current_power
	return total

/datum/cci_match/proc/end_round()
	var/score_one = score(CCI_SIDE_ONE)
	var/score_two = score(CCI_SIDE_TWO)
	if(score_one > score_two)
		round_wins[CCI_SIDE_ONE]++
		last_message = "[player_names[CCI_SIDE_ONE]] wins the round [score_one] to [score_two]."
	else if(score_two > score_one)
		round_wins[CCI_SIDE_TWO]++
		last_message = "[player_names[CCI_SIDE_TWO]] wins the round [score_two] to [score_one]."
	else
		round_wins[CCI_SIDE_ONE]++
		round_wins[CCI_SIDE_TWO]++
		last_message = "The round is a draw."
	for(var/side in list(CCI_SIDE_ONE, CCI_SIDE_TWO))
		for(var/row in list(CCI_ROW_INFANTRY, CCI_ROW_ARCHERS, CCI_ROW_SIEGE))
			for(var/datum/cci_played_card/played in board[side][row])
				discarded[side] += played.card_id
	for(var/datum/cci_played_card/played in weather_board)
		discarded[played.owner_side] += played.card_id
	for(var/side in list(CCI_SIDE_ONE, CCI_SIDE_TWO))
		for(var/row in list(CCI_ROW_INFANTRY, CCI_ROW_ARCHERS, CCI_ROW_SIEGE))
			for(var/datum/cci_played_card/played in row_effects[side][row])
				discarded[played.owner_side] += played.card_id
	if(round_wins[CCI_SIDE_ONE] >= 2 || round_wins[CCI_SIDE_TWO] >= 2)
		var/winner = round_wins[CCI_SIDE_ONE] >= 2 ? CCI_SIDE_ONE : CCI_SIDE_TWO
		result_text = "[player_names[winner]] wins the match."
		return
	round_number++
	start_round(FALSE)

/datum/cci_match/proc/ui_data_for(mob/user, obj/item/cci_deck/deck_context)
	var/list/data = list()
	var/my_side = side_for_user(user, deck_context)
	data["mySide"] = my_side
	data["turn"] = turn
	data["players"] = player_names
	data["wins"] = round_wins
	data["passed"] = passed
	data["scores"] = list(CCI_SIDE_ONE = score(CCI_SIDE_ONE), CCI_SIDE_TWO = score(CCI_SIDE_TWO))
	data["round"] = round_number
	data["result"] = result_text
	data["message"] = last_message
	data["weather"] = weather
	data["weatherCards"] = build_weather_data()
	data["rowEffects"] = build_row_effect_data()
	data["hand"] = build_hand_data(my_side)
	data["opponentHandCount"] = my_side ? length(hands[opposite(my_side)]) : 0
	data["board"] = build_board_data()
	return data

/datum/cci_match/proc/build_hand_data(side)
	var/list/out = list()
	if(!side)
		return out
	for(var/card_id in hands[side])
		var/datum/cci_card/card = cci_card(card_id)
		if(card)
			out += list(card.as_ui_data(TRUE, FALSE))
	return out

/datum/cci_match/proc/build_board_data()
	var/list/out = list()
	for(var/side in list(CCI_SIDE_ONE, CCI_SIDE_TWO))
		out[side] = list()
		for(var/row in list(CCI_ROW_INFANTRY, CCI_ROW_ARCHERS, CCI_ROW_SIEGE))
			out[side][row] = list()
			for(var/datum/cci_played_card/played in board[side][row])
				var/datum/cci_card/card = cci_card(played.card_id)
				if(card)
					var/list/card_data = card.as_ui_data(TRUE, FALSE)
					card_data["currentPower"] = played.current_power
					out[side][row] += list(card_data)
	return out

/datum/cci_match/proc/build_weather_data()
	var/list/out = list()
	for(var/datum/cci_played_card/played in weather_board)
		var/datum/cci_card/card = cci_card(played.card_id)
		if(card)
			out += list(card.as_ui_data(TRUE, FALSE))
	return out

/datum/cci_match/proc/build_row_effect_data()
	var/list/out = list()
	for(var/side in list(CCI_SIDE_ONE, CCI_SIDE_TWO))
		out[side] = list()
		for(var/row in list(CCI_ROW_INFANTRY, CCI_ROW_ARCHERS, CCI_ROW_SIEGE))
			out[side][row] = list()
			for(var/datum/cci_played_card/played in row_effects[side][row])
				var/datum/cci_card/card = cci_card(played.card_id)
				if(card)
					out[side][row] += list(card.as_ui_data(TRUE, FALSE))
	return out

#undef CCI_SIDE_ONE
#undef CCI_SIDE_TWO
#undef CCI_HAND_SIZE
