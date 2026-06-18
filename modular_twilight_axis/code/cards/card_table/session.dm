#define CCI_SIDE_ONE "one"
#define CCI_SIDE_TWO "two"

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
	combo_morale = list(
		CCI_SIDE_ONE = list(CCI_ROW_INFANTRY = 0, CCI_ROW_ARCHERS = 0, CCI_ROW_SIEGE = 0),
		CCI_SIDE_TWO = list(CCI_ROW_INFANTRY = 0, CCI_ROW_ARCHERS = 0, CCI_ROW_SIEGE = 0)
	)
	if(first_round)
		draw_cards(CCI_SIDE_ONE, 10)
		draw_cards(CCI_SIDE_TWO, 10)
	turn = (round_number % 2) ? CCI_SIDE_ONE : CCI_SIDE_TWO
	last_message = "Round [round_number] begins."

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
	if(card.row == CCI_ROW_WEATHER)
		apply_weather_card(card, side)
	else
		var/play_side = side
		if(card.effect == CCI_EFFECT_SPY)
			play_side = opposite(side)
			draw_cards(side, 2)
		board[play_side][card.row] += new /datum/cci_played_card(card_id, side)
		apply_card_effect(card, side, play_side)
		if(apply_combo_effect(card, side, play_side))
			last_message = "[player_names[side]] plays [card.name]. A combo triggers."
		else
			last_message = "[player_names[side]] plays [card.name]."
	recalculate_board()
	if(card.row == CCI_ROW_WEATHER)
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

/datum/cci_match/proc/apply_card_effect(datum/cci_card/card, owner_side, play_side)
	if(card.effect != CCI_EFFECT_SCORCH)
		return
	scorch_strongest_enemy(owner_side)

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
		board[enemy][strongest_row] -= strongest
		discarded[enemy] += strongest.card_id

/datum/cci_match/proc/recalculate_board()
	for(var/side in list(CCI_SIDE_ONE, CCI_SIDE_TWO))
		for(var/row in list(CCI_ROW_INFANTRY, CCI_ROW_ARCHERS, CCI_ROW_SIEGE))
			var/morale = 0
			for(var/datum/cci_played_card/played in board[side][row])
				var/datum/cci_card/card = cci_card(played.card_id)
				if(card?.effect == CCI_EFFECT_MORALE)
					morale++
			morale += text2num("[combo_morale[side][row]]")
			for(var/datum/cci_played_card/played in board[side][row])
				var/datum/cci_card/card = cci_card(played.card_id)
				if(!card)
					continue
				var/value = card.power
				if(row in weather)
					value = min(value, 1)
				if(card.effect != CCI_EFFECT_MORALE)
					value += morale
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

#undef CCI_SIDE_ONE
#undef CCI_SIDE_TWO
