/datum/card_table_session/proc/poker_player_in_hand(datum/card_table_player/player)
	return player_is_active(player) && !player.poker_folded

/datum/card_table_session/proc/poker_active_players_count()
	var/count = 0
	for(var/datum/card_table_player/player in players)
		if(poker_player_in_hand(player))
			count++
	return count

/datum/card_table_session/proc/poker_next_player_index(start_index)
	if(!players.len)
		return 0
	if(start_index < 1 || start_index > players.len)
		start_index = 1
	for(var/offset = 0, offset < players.len, offset++)
		var/check_index = start_index + offset
		while(check_index > players.len)
			check_index -= players.len
		var/datum/card_table_player/player = players[check_index]
		if(poker_player_in_hand(player) && !player.poker_all_in && !player.ready)
			return check_index
	return 0

/datum/card_table_session/proc/poker_current_player() as /datum/card_table_player
	if(poker_turn_index < 1 || poker_turn_index > players.len)
		return null
	var/datum/card_table_player/player = players[poker_turn_index]
	if(!poker_player_in_hand(player) || player.ready || player.poker_all_in)
		return null
	return player

/datum/card_table_session/proc/poker_start_draw_phase()
	poker_draw_phase = TRUE
	poker_turn_index = 0
	for(var/datum/card_table_player/player in players)
		player.ready = !poker_player_in_hand(player) || player.draws_used >= 1
	poker_process_spirit_draws()

/datum/card_table_session/proc/poker_draw_phase_done()
	for(var/datum/card_table_player/player in players)
		if(poker_player_in_hand(player) && !player.ready)
			return FALSE
	return TRUE

/datum/card_table_session/proc/poker_after_draw_action()
	if(!poker_draw_phase_done())
		poker_process_spirit_draws()
		return
	poker_draw_phase = FALSE
	message = "Замена завершена. Начинается круг ставок."
	poker_start_betting_round()

/datum/card_table_session/proc/poker_process_spirit_draws()
	if(stage != CARD_TABLE_STAGE_PLAYING || game_type != CARD_TABLE_GAME_POKER || !poker_draw_phase)
		return
	for(var/datum/card_table_player/player in players)
		if(!player.is_spirit || player.ready || !poker_player_in_hand(player))
			continue
		var/discard_index = poker_spirit_discard_index(player)
		if(discard_index)
			discard += list(player.hand[discard_index])
			player.hand.Cut(discard_index, discard_index + 1)
			var/list/new_card = draw_one()
			if(new_card)
				player.hand += list(new_card)
			player.draws_used = 1
			message = "[player.name] меняет карту."
		else
			message = "[player.name] оставляет руку."
		player.ready = TRUE
	if(poker_draw_phase_done())
		poker_draw_phase = FALSE
		message = "Замена завершена. Начинается круг ставок."
		poker_start_betting_round()

/datum/card_table_session/proc/poker_start_betting_round()
	if(poker_active_players_count() <= 1)
		poker_finish()
		return
	poker_round++
	poker_draw_phase = FALSE
	poker_current_bet = 0
	for(var/datum/card_table_player/player in players)
		player.ready = !poker_player_in_hand(player) || player.poker_all_in
		player.poker_bet = 0
	poker_turn_index = poker_next_player_index(dealer_index + 1)
	if(!poker_turn_index)
		if(poker_community_stock.len)
			poker_reveal_next_community()
			message = "На стол открывается новая общая карта."
			poker_start_betting_round()
			return
		poker_finish()
		return
	poker_process_spirit_turn()

/datum/card_table_session/proc/poker_reveal_next_community()
	if(!poker_community_stock.len)
		return FALSE
	var/list/card = poker_community_stock[1]
	poker_community_stock.Cut(1, 2)
	community_cards += list(card)
	return TRUE

/datum/card_table_session/proc/poker_betting_round_done()
	for(var/datum/card_table_player/player in players)
		if(poker_player_in_hand(player) && !player.ready && !player.poker_all_in)
			return FALSE
	return TRUE

/datum/card_table_session/proc/poker_after_action()
	if(poker_active_players_count() <= 1)
		poker_finish()
		return
	if(!poker_betting_round_done())
		poker_turn_index = poker_next_player_index(poker_turn_index + 1)
		poker_process_spirit_turn()
		return
	if(poker_community_stock.len)
		poker_reveal_next_community()
		message = "На стол открывается новая общая карта."
		poker_start_betting_round()
		return
	poker_finish()

/datum/card_table_session/proc/poker_spirit_discard_index(datum/card_table_player/player)
	if(!player || poker_variant != CARD_TABLE_POKER_DRAW || player.draws_used >= 1)
		return 0
	var/lowest_index = 0
	var/lowest_value = 15
	for(var/i = 1, i <= player.hand.len, i++)
		var/list/card = player.hand[i]
		var/value = card_table_card_rank_value(card)
		if(value < lowest_value)
			lowest_value = value
			lowest_index = i
	return (lowest_value <= 10) ? lowest_index : 0

/datum/card_table_session/proc/poker_process_spirit_turn()
	if(stage != CARD_TABLE_STAGE_PLAYING || game_type != CARD_TABLE_GAME_POKER)
		return
	for(var/guard = 1, guard <= 20, guard++)
		var/datum/card_table_player/player = poker_current_player()
		if(!player || !player.is_spirit)
			return
		var/delta = max(0, poker_current_bet - player.poker_bet)
		poker_pot += delta
		player.poker_total_bet += delta
		player.poker_bet = poker_current_bet
		player.ready = TRUE
		message = poker_current_bet ? "[player.name] уравнивает ставку." : "[player.name] делает чек."
		poker_after_action()
		if(stage != CARD_TABLE_STAGE_PLAYING)
			return

/datum/card_table_session/proc/poker_check(mob/user)
	var/datum/card_table_player/player = player_for_user(user)
	if(stage != CARD_TABLE_STAGE_PLAYING || game_type != CARD_TABLE_GAME_POKER || player != poker_current_player())
		return FALSE
	var/delta = max(0, poker_current_bet - player.poker_bet)
	poker_pot += delta
	player.poker_total_bet += delta
	player.poker_bet = poker_current_bet
	player.ready = TRUE
	message = poker_current_bet ? "[player.name] уравнивает ставку." : "[player.name] делает чек."
	poker_after_action()
	return TRUE

/datum/card_table_session/proc/poker_raise(mob/user, amount, all_in = FALSE)
	var/datum/card_table_player/player = player_for_user(user)
	if(stage != CARD_TABLE_STAGE_PLAYING || game_type != CARD_TABLE_GAME_POKER || player != poker_current_player())
		return FALSE
	amount = max(1, text2num("[amount]"))
	if(all_in)
		amount = 100
	var/new_bet = poker_current_bet + amount
	var/delta = max(0, new_bet - player.poker_bet)
	poker_current_bet = new_bet
	poker_pot += delta
	player.poker_total_bet += delta
	for(var/datum/card_table_player/other in players)
		if(poker_player_in_hand(other) && !other.poker_all_in)
			other.ready = FALSE
	player.poker_bet = poker_current_bet
	player.poker_all_in = all_in ? TRUE : FALSE
	player.ready = TRUE
	message = all_in ? "[player.name] идет ва-банк." : "[player.name] повышает ставку на [amount]."
	poker_after_action()
	return TRUE

/datum/card_table_session/proc/poker_fold(mob/user)
	var/datum/card_table_player/player = player_for_user(user)
	if(stage != CARD_TABLE_STAGE_PLAYING || game_type != CARD_TABLE_GAME_POKER || player != poker_current_player())
		return FALSE
	player.poker_folded = TRUE
	player.ready = TRUE
	message = "[player.name] пасует."
	poker_after_action()
	return TRUE

/datum/card_table_session/proc/poker_straight_high(list/ranks)
	var/list/seen = list()
	for(var/value in ranks)
		seen["[text2num("[value]")]"] = TRUE
	if(seen["14"])
		seen["1"] = TRUE
	for(var/high = 14, high >= 5, high--)
		var/found = TRUE
		for(var/offset = 0, offset < 5, offset++)
			if(!seen["[high - offset]"])
				found = FALSE
				break
		if(found)
			return high
	return 0

/datum/card_table_session/proc/poker_score(list/hand)
	if(!hand)
		return 0
	var/list/counts = list()
	var/list/ranks = list()
	var/list/suits = list()
	var/list/suit_ranks = list()
	for(var/list/card in hand)
		var/rank = "[card["rank_value"]]"
		var/suit = "[card["suit"]]"
		counts[rank] = text2num("[counts[rank]]") + 1
		suits[suit] = text2num("[suits[suit]]") + 1
		var/list/ranks_for_suit = suit_ranks[suit]
		if(!ranks_for_suit)
			ranks_for_suit = list()
			suit_ranks[suit] = ranks_for_suit
		var/rank_value = card_table_card_rank_value(card)
		ranks += rank_value
		ranks_for_suit += rank_value
	var/list/groups = list()
	for(var/rank_key in counts)
		groups += text2num("[counts[rank_key]]")
	groups = sortList(groups)
	var/pairs = 0
	var/triples = 0
	var/high = 0
	for(var/group_count in groups)
		var/group_value = text2num("[group_count]")
		if(group_value == 2)
			pairs++
		else if(group_value == 3)
			triples++
	for(var/value in ranks)
		high = max(high, text2num("[value]"))
	var/straight_high = poker_straight_high(ranks)
	var/flush_high = 0
	var/straight_flush_high = 0
	for(var/suit_key in suits)
		if(text2num("[suits[suit_key]]") < 5)
			continue
		var/list/flush_ranks = suit_ranks[suit_key]
		for(var/flush_value in flush_ranks)
			flush_high = max(flush_high, text2num("[flush_value]"))
		straight_flush_high = max(straight_flush_high, poker_straight_high(flush_ranks))
	var/category = 1
	if(straight_flush_high == 14)
		category = 10
		high = 14
	else if(straight_flush_high)
		category = 9
		high = straight_flush_high
	else if(4 in groups)
		category = 8
	else if(triples >= 2 || (triples >= 1 && pairs >= 1))
		category = 7
	else if(flush_high)
		category = 6
		high = flush_high
	else if(straight_high)
		category = 5
		high = straight_high
	else if(3 in groups)
		category = 4
	else
		if(pairs >= 2)
			category = 3
		else if(pairs == 1)
			category = 2
	return category * 100 + high

/datum/card_table_session/proc/poker_combo_label(score)
	var/category = round((score - (score % 100)) / 100)
	switch(category)
		if(10)
			return "роял-флеш"
		if(9)
			return "стрит-флеш"
		if(8)
			return "каре"
		if(7)
			return "фулл-хаус"
		if(6)
			return "флеш"
		if(5)
			return "стрит"
		if(4)
			return "сет"
		if(3)
			return "две пары"
		if(2)
			return "пара"
	return "старшая карта"

/datum/card_table_session/proc/poker_score_for_player(datum/card_table_player/player)
	if(!player || player.poker_folded)
		return 0
	var/list/scored_hand = list()
	for(var/list/card in player.hand)
		scored_hand += list(card)
	for(var/list/table_card in community_cards)
		scored_hand += list(table_card)
	return poker_score(scored_hand)

/datum/card_table_session/proc/poker_finish()
	var/best_score = -1
	var/datum/card_table_player/winner = null
	for(var/datum/card_table_player/player in players)
		if(!poker_player_in_hand(player))
			continue
		var/score = poker_score_for_player(player)
		player.poker_combo = poker_combo_label(score)
		if(score > best_score)
			best_score = score
			winner = player
	for(var/datum/card_table_player/P in players)
		if(P.left)
			if(!P.result)
				P.result = "Left"
		else if(P.poker_folded)
			P.poker_combo = "пас"
			P.result = "Fold"
		else
			if(!P.poker_combo)
				P.poker_combo = poker_combo_label(poker_score_for_player(P))
			P.result = (P == winner) ? "Winner" : "Lost"
	stage = CARD_TABLE_STAGE_FINISHED
	var/winner_name = winner ? winner.name : "Никто"
	var/winner_combo = winner ? winner.poker_combo : "-"
	message = "[winner_name] выигрывает раздачу: [winner_combo]."

/datum/card_table_session/proc/poker_discard(mob/user, card_index)
	var/datum/card_table_player/player = player_for_user(user)
	card_index = text2num("[card_index]")
	if(stage != CARD_TABLE_STAGE_PLAYING || game_type != CARD_TABLE_GAME_POKER || poker_variant != CARD_TABLE_POKER_DRAW || !poker_draw_phase || !player || player.ready || player.draws_used >= 1)
		return FALSE
	if(card_index < 1 || card_index > player.hand.len)
		return FALSE
	discard += list(player.hand[card_index])
	player.hand.Cut(card_index, card_index + 1)
	var/list/new_card = draw_one()
	if(new_card)
		player.hand += list(new_card)
	player.draws_used = 1
	player.ready = TRUE
	message = "[player.name] меняет карту."
	poker_after_draw_action()
	return TRUE

/datum/card_table_session/proc/poker_ready(mob/user)
	var/datum/card_table_player/player = player_for_user(user)
	if(stage != CARD_TABLE_STAGE_PLAYING || game_type != CARD_TABLE_GAME_POKER || !player)
		return FALSE
	if(poker_draw_phase)
		if(player.ready)
			return FALSE
		player.ready = TRUE
		message = "[player.name] оставляет руку."
		poker_after_draw_action()
		return TRUE
	return poker_check(user)

/datum/card_table_session/proc/poker_finish_turn(mob/user, card_index)
	if(poker_draw_phase && text2num("[card_index]") > 0)
		return poker_discard(user, card_index)
	return poker_ready(user)
