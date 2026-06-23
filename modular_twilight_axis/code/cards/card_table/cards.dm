#define CCI_ROW_INFANTRY "infantry"
#define CCI_ROW_ARCHERS "archers"
#define CCI_ROW_SIEGE "siege"
#define CCI_ROW_WEATHER "weather"

#define CCI_RARITY_BASE "base"
#define CCI_RARITY_RARE "rare"
#define CCI_RARITY_UNIQUE "unique"

#define CCI_EFFECT_NONE "none"
#define CCI_EFFECT_MORALE "morale"
#define CCI_EFFECT_SCORCH "scorch"
#define CCI_EFFECT_SCORCH_INFANTRY "scorch_infantry"
#define CCI_EFFECT_SCORCH_GLOBAL "scorch_global"
#define CCI_EFFECT_SPY "spy"
#define CCI_EFFECT_MEDIC "medic"
#define CCI_EFFECT_BOND "bond"
#define CCI_EFFECT_AGILE "agile"
#define CCI_EFFECT_MUSTER "muster"
#define CCI_EFFECT_HORN "horn"
#define CCI_EFFECT_DECOY "decoy"
#define CCI_EFFECT_BERSERK "berserk"
#define CCI_EFFECT_MARDROEME "mardroeme"
#define CCI_EFFECT_AVENGER "avenger"
#define CCI_EFFECT_CLEAR_WEATHER "clear_weather"
#define CCI_EFFECT_FROST "frost"
#define CCI_EFFECT_FOG "fog"
#define CCI_EFFECT_RAIN "rain"

#define CCI_FACTION_NEUTRAL "neutral"
#define CCI_FACTION_AZURIA "azuria"
#define CCI_FACTION_ENIGMA "enigma"
#define CCI_FACTION_NALEDI "naledi"
#define CCI_FACTION_GRENZELHOFT "grenzelhoft"
#define CCI_FACTION_RANESHI "raneshi"
#define CCI_FACTION_GRONN "gronn"
#define CCI_FACTION_KAZENGUN "kazengun"

#define CCI_FACTION_EFFECT_ROUND_WIN_DRAW "round_win_draw"
#define CCI_FACTION_EFFECT_KEEP_UNIT "keep_unit"
#define CCI_FACTION_EFFECT_WIN_DRAWS "win_draws"
#define CCI_FACTION_EFFECT_ROUND_LOSS_DRAW "round_loss_draw"
#define CCI_FACTION_EFFECT_REVIVE_UNIT "revive_unit"
#define CCI_FACTION_EFFECT_EXTRA_MULLIGAN "extra_mulligan"
#define CCI_FACTION_EFFECT_OPENING_DRAW "opening_draw"

#define CCI_LEADER_EFFECT_DRAW "draw"

#define CCI_COMBO_NONE "none"

GLOBAL_LIST_EMPTY(cci_cards_by_id)
GLOBAL_LIST_EMPTY(cci_base_card_ids)
GLOBAL_LIST_EMPTY(cci_factions_by_id)
GLOBAL_LIST_EMPTY(cci_leaders_by_id)

/proc/cci_build_card_registry()
	GLOB.cci_cards_by_id = list()
	GLOB.cci_base_card_ids = list()
	for(var/path in subtypesof(/datum/cci_card))
		var/datum/cci_card/card = new path()
		if(!card.id)
			qdel(card)
			continue
		if(GLOB.cci_cards_by_id[card.id])
			qdel(card)
			continue
		GLOB.cci_cards_by_id[card.id] = card
		if(card.rarity == CCI_RARITY_BASE)
			GLOB.cci_base_card_ids += card.id

/proc/cci_card(card_id)
	if(!length(GLOB.cci_cards_by_id))
		cci_build_card_registry()
	return GLOB.cci_cards_by_id[card_id]

/proc/cci_card_allowed_for_faction(card_id, faction_id)
	var/datum/cci_card/card = cci_card(card_id)
	if(!card)
		return FALSE
	return card.faction == CCI_FACTION_NEUTRAL || card.faction == faction_id

/proc/cci_base_cards_for_faction(faction_id)
	if(!length(GLOB.cci_base_card_ids))
		cci_build_card_registry()
	var/list/card_ids = list()
	for(var/card_id in GLOB.cci_base_card_ids)
		if(cci_card_allowed_for_faction(card_id, faction_id))
			card_ids += card_id
	return card_ids

/proc/cci_build_faction_registry()
	GLOB.cci_factions_by_id = list()
	for(var/path in subtypesof(/datum/cci_faction))
		var/datum/cci_faction/faction = new path()
		if(!faction.id)
			qdel(faction)
			continue
		if(GLOB.cci_factions_by_id[faction.id])
			qdel(faction)
			continue
		GLOB.cci_factions_by_id[faction.id] = faction

/proc/cci_faction(faction_id)
	if(!length(GLOB.cci_factions_by_id))
		cci_build_faction_registry()
	return GLOB.cci_factions_by_id[faction_id]

/proc/cci_build_leader_registry()
	GLOB.cci_leaders_by_id = list()
	for(var/path in subtypesof(/datum/cci_leader))
		var/datum/cci_leader/leader = new path()
		if(!leader.id)
			qdel(leader)
			continue
		if(GLOB.cci_leaders_by_id[leader.id])
			qdel(leader)
			continue
		GLOB.cci_leaders_by_id[leader.id] = leader

/proc/cci_leader(leader_id)
	if(!length(GLOB.cci_leaders_by_id))
		cci_build_leader_registry()
	return GLOB.cci_leaders_by_id[leader_id]

/datum/cci_card
	var/id
	var/name = "Unnamed Card"
	var/desc = ""
	var/row = CCI_ROW_INFANTRY
	var/power = 1
	var/rarity = CCI_RARITY_BASE
	var/faction = CCI_FACTION_NEUTRAL
	var/effect = CCI_EFFECT_NONE
	var/combo = CCI_COMBO_NONE
	var/list/combo_with = list()
	var/combo_effect = CCI_EFFECT_NONE
	var/target_row = ""
	var/bear_power = 8
	var/avenger_card = ""
	var/art = ""
	var/hero = FALSE

/datum/cci_card/proc/as_ui_data(known = TRUE, selected = FALSE)
	return list(
		"id" = id,
		"name" = name,
		"desc" = desc,
		"row" = row,
		"power" = power,
		"rarity" = rarity,
		"faction" = faction,
		"effect" = effect,
		"combo" = combo,
		"comboEffect" = combo_effect,
		"comboWith" = combo_with,
		"targetRow" = target_row,
		"art" = art,
		"hero" = hero,
		"known" = known,
		"selected" = selected
	)

/datum/cci_leader
	var/id
	var/name = "Unnamed Leader"
	var/desc = ""
	var/faction = CCI_FACTION_AZURIA
	var/effect = CCI_EFFECT_NONE
	var/target_row = ""

/datum/cci_leader/proc/as_ui_data(used = FALSE)
	return list(
		"id" = id,
		"name" = name,
		"desc" = desc,
		"faction" = faction,
		"effect" = effect,
		"targetRow" = target_row,
		"used" = used
	)

/datum/cci_faction
	var/id
	var/name = "Unnamed Faction"
	var/desc = ""
	var/effect = CCI_EFFECT_NONE
	var/default_leader = ""

/datum/cci_faction/proc/as_ui_data()
	return list(
		"id" = id,
		"name" = name,
		"desc" = desc,
		"effect" = effect,
		"defaultLeader" = default_leader
	)

/datum/cci_faction/azuria
	id = CCI_FACTION_AZURIA
	name = "Azuria"
	desc = "Orderly feudal ranks. Draws one card after winning a round."
	effect = CCI_FACTION_EFFECT_ROUND_WIN_DRAW
	default_leader = "azuria_ducal_marshal"

/datum/cci_faction/enigma
	id = CCI_FACTION_ENIGMA
	name = "Enigma"
	desc = "Hidden hands and prepared reserves. Starts the match with one extra card."
	effect = CCI_FACTION_EFFECT_OPENING_DRAW
	default_leader = "enigma_vanguard_overseer"

/datum/cci_faction/naledi
	id = CCI_FACTION_NALEDI
	name = "Naledi"
	desc = "Zibantian rites and desert scholarship. Revives one non-hero unit at the start of each later round."
	effect = CCI_FACTION_EFFECT_REVIVE_UNIT
	default_leader = "naledi_star_emir"

/datum/cci_faction/grenzelhoft
	id = CCI_FACTION_GRENZELHOFT
	name = "Grenzelhoft"
	desc = "Black imperial discipline. Wins drawn rounds unless the opponent has the same claim."
	effect = CCI_FACTION_EFFECT_WIN_DRAWS
	default_leader = "grenzelhoft_line_breaker"

/datum/cci_faction/raneshi
	id = CCI_FACTION_RANESHI
	name = "Raneshi"
	desc = "Zibantian sands, caravans, and ambushes. Draws one card after losing a round."
	effect = CCI_FACTION_EFFECT_ROUND_LOSS_DRAW
	default_leader = "raneshi_court_veil"

/datum/cci_faction/gronn
	id = CCI_FACTION_GRONN
	name = "Gronn"
	desc = "Northern berserkers and raiders. Keeps one random non-hero unit on the field after each round."
	effect = CCI_FACTION_EFFECT_KEEP_UNIT
	default_leader = "gronn_war_chief"

/datum/cci_faction/kazengun
	id = CCI_FACTION_KAZENGUN
	name = "Kazengun"
	desc = "Ronin, shinobi, and disciplined sword schools. Gains one extra mulligan."
	effect = CCI_FACTION_EFFECT_EXTRA_MULLIGAN
	default_leader = "kazengun_shadow_daimyo"

/datum/cci_leader/azuria/ducal_marshal
	id = "azuria_ducal_marshal"
	name = "Ducal Marshal"
	desc = "Clears all weather once per match."
	faction = CCI_FACTION_AZURIA
	effect = CCI_EFFECT_CLEAR_WEATHER

/datum/cci_leader/azuria/kingsfield_captain
	id = "azuria_kingsfield_captain"
	name = "Captain of Kingsfield"
	desc = "Places a commander horn on your infantry row once per match."
	faction = CCI_FACTION_AZURIA
	effect = CCI_EFFECT_HORN
	target_row = CCI_ROW_INFANTRY

/datum/cci_leader/enigma/vanguard_overseer
	id = "enigma_vanguard_overseer"
	name = "Vanguard Overseer"
	desc = "Destroys the strongest unit or units once per match."
	faction = CCI_FACTION_ENIGMA
	effect = CCI_EFFECT_SCORCH_GLOBAL

/datum/cci_leader/enigma/redoubt_keeper
	id = "enigma_redoubt_keeper"
	name = "Keeper of the Redoubt"
	desc = "Clears all weather once per match."
	faction = CCI_FACTION_ENIGMA
	effect = CCI_EFFECT_CLEAR_WEATHER

/datum/cci_leader/naledi/star_emir
	id = "naledi_star_emir"
	name = "Star Emir"
	desc = "Draws one card once per match."
	faction = CCI_FACTION_NALEDI
	effect = CCI_LEADER_EFFECT_DRAW

/datum/cci_leader/naledi/sand_oracle
	id = "naledi_sand_oracle"
	name = "Sand Oracle"
	desc = "Clears all weather once per match."
	faction = CCI_FACTION_NALEDI
	effect = CCI_EFFECT_CLEAR_WEATHER

/datum/cci_leader/grenzelhoft/line_breaker
	id = "grenzelhoft_line_breaker"
	name = "Line Breaker"
	desc = "Places a commander horn on your siege row once per match."
	faction = CCI_FACTION_GRENZELHOFT
	effect = CCI_EFFECT_HORN
	target_row = CCI_ROW_SIEGE

/datum/cci_leader/grenzelhoft/iron_commissar
	id = "grenzelhoft_iron_commissar"
	name = "Iron Commissar"
	desc = "Destroys the strongest unit or units once per match."
	faction = CCI_FACTION_GRENZELHOFT
	effect = CCI_EFFECT_SCORCH_GLOBAL

/datum/cci_leader/raneshi/court_veil
	id = "raneshi_court_veil"
	name = "Court Veil"
	desc = "Clears all weather once per match."
	faction = CCI_FACTION_RANESHI
	effect = CCI_EFFECT_CLEAR_WEATHER

/datum/cci_leader/raneshi/spice_broker
	id = "raneshi_spice_broker"
	name = "Spice Broker"
	desc = "Draws one card once per match."
	faction = CCI_FACTION_RANESHI
	effect = CCI_LEADER_EFFECT_DRAW

/datum/cci_leader/gronn/war_chief
	id = "gronn_war_chief"
	name = "War Chief"
	desc = "Places a commander horn on your infantry row once per match."
	faction = CCI_FACTION_GRONN
	effect = CCI_EFFECT_HORN
	target_row = CCI_ROW_INFANTRY

/datum/cci_leader/gronn/bone_reader
	id = "gronn_bone_reader"
	name = "Bone Reader"
	desc = "Clears all weather once per match."
	faction = CCI_FACTION_GRONN
	effect = CCI_EFFECT_CLEAR_WEATHER

/datum/cci_leader/kazengun/shadow_daimyo
	id = "kazengun_shadow_daimyo"
	name = "Shadow Daimyo"
	desc = "Draws one card once per match."
	faction = CCI_FACTION_KAZENGUN
	effect = CCI_LEADER_EFFECT_DRAW

/datum/cci_leader/kazengun/ronin_master
	id = "kazengun_ronin_master"
	name = "Ronin Master"
	desc = "Destroys the strongest unit or units once per match."
	faction = CCI_FACTION_KAZENGUN
	effect = CCI_EFFECT_SCORCH_GLOBAL

// Card definitions live in cards_common.dm and cards_<faction>.dm.
