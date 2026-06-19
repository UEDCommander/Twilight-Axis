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

#define CCI_COMBO_NONE "none"

GLOBAL_LIST_EMPTY(cci_cards_by_id)
GLOBAL_LIST_EMPTY(cci_base_card_ids)
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
	var/effect = CCI_EFFECT_NONE
	var/target_row = ""

/datum/cci_leader/proc/as_ui_data(used = FALSE)
	return list(
		"id" = id,
		"name" = name,
		"desc" = desc,
		"effect" = effect,
		"targetRow" = target_row,
		"used" = used
	)

/datum/cci_leader/clear_weather
	id = "leader_clear_weather"
	name = "Weathered Commander"
	desc = "Clears all weather once per match."
	effect = CCI_EFFECT_CLEAR_WEATHER

/datum/cci_leader/infantry_horn
	id = "leader_infantry_horn"
	name = "Infantry Marshal"
	desc = "Places a commander horn on your infantry row once per match."
	effect = CCI_EFFECT_HORN
	target_row = CCI_ROW_INFANTRY

/datum/cci_leader/scorch
	id = "leader_scorch"
	name = "Executioner"
	desc = "Destroys the strongest unit or units once per match."
	effect = CCI_EFFECT_SCORCH_GLOBAL

/datum/cci_leader/draw
	id = "leader_draw"
	name = "Quartermaster"
	desc = "Draws one card once per match."
	effect = "draw"

// Add new cards by making another /datum/cci_card subtype with a unique id.
/datum/cci_card/base_swordsman
	id = "base_swordsman"
	name = "Swordsman"
	desc = "Reliable infantry."
	row = CCI_ROW_INFANTRY
	power = 4
	combo_with = list("base_shieldman")
	combo_effect = CCI_EFFECT_MORALE
	art = "cci_cards/swordsman.png"

/datum/cci_card/base_spearman
	id = "base_spearman"
	name = "Spearman"
	desc = "Doubles with other Spearmen."
	row = CCI_ROW_INFANTRY
	power = 3
	effect = CCI_EFFECT_BOND
	art = "cci_cards/spearman.png"

/datum/cci_card/base_archer
	id = "base_archer"
	name = "Archer"
	desc = "Reliable ranged card."
	row = CCI_ROW_ARCHERS
	power = 4
	effect = CCI_EFFECT_AGILE
	combo_with = list("base_longbowman")
	combo_effect = CCI_EFFECT_SCORCH
	art = "cci_cards/young_archer.png"

/datum/cci_card/base_crossbow
	id = "base_crossbow"
	name = "Crossbowman"
	desc = "Ranged morale support."
	row = CCI_ROW_ARCHERS
	power = 3
	effect = CCI_EFFECT_MORALE
	art = "cci_cards/crossbowman.png"

/datum/cci_card/base_catapult
	id = "base_catapult"
	name = "Catapult"
	desc = "Doubles with other Catapults."
	row = CCI_ROW_SIEGE
	power = 5
	effect = CCI_EFFECT_BOND
	combo_with = list("base_ballista")
	combo_effect = CCI_EFFECT_SCORCH
	art = "cci_cards/trebuchet.png"

/datum/cci_card/base_ballista
	id = "base_ballista"
	name = "Ballista"
	desc = "Siege engine."
	row = CCI_ROW_SIEGE
	power = 6
	effect = CCI_EFFECT_SCORCH_INFANTRY
	combo_with = list("base_catapult")
	combo_effect = CCI_EFFECT_SCORCH
	art = "cci_cards/ballista.png"

/datum/cci_card/base_frost
	id = "base_frost"
	name = "Biting Frost"
	desc = "Sets infantry strength to 1."
	row = CCI_ROW_WEATHER
	power = 0
	effect = CCI_EFFECT_FROST
	art = "cci_cards/frost.png"

/datum/cci_card/base_fog
	id = "base_fog"
	name = "Impenetrable Fog"
	desc = "Sets archers strength to 1."
	row = CCI_ROW_WEATHER
	power = 0
	effect = CCI_EFFECT_FOG
	art = "cci_cards/fog.png"

/datum/cci_card/base_rain
	id = "base_rain"
	name = "Torrential Rain"
	desc = "Sets siege strength to 1."
	row = CCI_ROW_WEATHER
	power = 0
	effect = CCI_EFFECT_RAIN
	art = "cci_cards/rain.png"

/datum/cci_card/base_clear
	id = "base_clear"
	name = "Clear Weather"
	desc = "Removes all weather."
	row = CCI_ROW_WEATHER
	power = 0
	effect = CCI_EFFECT_CLEAR_WEATHER
	art = "cci_cards/clear_weather.png"

/datum/cci_card/base_shieldman
	id = "base_shieldman"
	name = "Shieldman"
	desc = "Steady frontline infantry."
	row = CCI_ROW_INFANTRY
	power = 5
	combo_with = list("base_swordsman")
	combo_effect = CCI_EFFECT_MORALE
	art = "cci_cards/shield_swordsman.png"

/datum/cci_card/base_banner_bearer
	id = "base_banner_bearer"
	name = "Banner Bearer"
	desc = "Morale boost for infantry."
	row = CCI_ROW_INFANTRY
	power = 2
	effect = CCI_EFFECT_MORALE
	art = "cci_cards/banner_bearer.png"

/datum/cci_card/base_guard
	id = "base_guard"
	name = "Guard"
	desc = "Armored infantry."
	row = CCI_ROW_INFANTRY
	power = 4
	effect = CCI_EFFECT_MUSTER
	art = "cci_cards/shield_guard.png"

/datum/cci_card/base_longbowman
	id = "base_longbowman"
	name = "Longbowman"
	desc = "Doubles with other Longbowmen."
	row = CCI_ROW_ARCHERS
	power = 3
	effect = CCI_EFFECT_BOND
	combo_with = list("base_archer")
	combo_effect = CCI_EFFECT_SCORCH
	art = "cci_cards/hood_archer.png"

/datum/cci_card/base_blacksmith
	id = "base_blacksmith"
	name = "Blacksmith"
	desc = "Morale support for siege."
	row = CCI_ROW_SIEGE
	power = 2
	effect = CCI_EFFECT_MORALE
	combo_with = list("base_supply_cart")
	combo_effect = CCI_EFFECT_MORALE
	art = "cci_cards/blacksmith.png"

/datum/cci_card/base_supply_cart
	id = "base_supply_cart"
	name = "Supply Cart"
	desc = "Siege support."
	row = CCI_ROW_SIEGE
	power = 4
	combo_with = list("base_blacksmith")
	combo_effect = CCI_EFFECT_MORALE
	art = "cci_cards/supply_cart.png"

/datum/cci_card/base_scout
	id = "base_scout"
	name = "Scout"
	desc = "Light ranged unit."
	row = CCI_ROW_ARCHERS
	power = 2
	art = "cci_cards/scout.png"

/datum/cci_card/base_militia
	id = "base_militia"
	name = "Militia"
	desc = "Cheap infantry."
	row = CCI_ROW_INFANTRY
	power = 2
	art = "cci_cards/swordsman.png"

/datum/cci_card/base_mangonel
	id = "base_mangonel"
	name = "Mangonel"
	desc = "Basic siege engine."
	row = CCI_ROW_SIEGE
	power = 3
	art = "cci_cards/trebuchet.png"

/datum/cci_card/base_field_medic
	id = "base_field_medic"
	name = "Field Medic"
	desc = "Keeps the line together."
	row = CCI_ROW_INFANTRY
	power = 3
	effect = CCI_EFFECT_MEDIC
	art = "cci_cards/field_medic.png"

/datum/cci_card/base_decoy
	id = "base_decoy"
	name = "Decoy"
	desc = "Returns your strongest unit to hand."
	row = CCI_ROW_WEATHER
	power = 0
	effect = CCI_EFFECT_DECOY
	art = "cci_cards/fog.png"

/datum/cci_card/base_horn_infantry
	id = "base_horn_infantry"
	name = "Infantry Horn"
	desc = "Doubles all units in your infantry row."
	row = CCI_ROW_INFANTRY
	power = 0
	effect = CCI_EFFECT_HORN
	target_row = CCI_ROW_INFANTRY
	art = "cci_cards/banner_bearer.png"

/datum/cci_card/base_horn_archers
	id = "base_horn_archers"
	name = "Archers Horn"
	desc = "Doubles all units in your archers row."
	row = CCI_ROW_ARCHERS
	power = 0
	effect = CCI_EFFECT_HORN
	target_row = CCI_ROW_ARCHERS
	art = "cci_cards/field_captain.png"

/datum/cci_card/base_horn_siege
	id = "base_horn_siege"
	name = "Siege Horn"
	desc = "Doubles all units in your siege row."
	row = CCI_ROW_SIEGE
	power = 0
	effect = CCI_EFFECT_HORN
	target_row = CCI_ROW_SIEGE
	art = "cci_cards/supply_cart.png"

/datum/cci_card/base_scorch
	id = "base_scorch"
	name = "Scorch"
	desc = "Destroys the strongest unit or units on the battlefield."
	row = CCI_ROW_WEATHER
	power = 0
	effect = CCI_EFFECT_SCORCH_GLOBAL
	art = "cci_cards/rain.png"

/datum/cci_card/base_mardroeme
	id = "base_mardroeme"
	name = "Mardroeme"
	desc = "Turns Berserkers in your infantry row into bears."
	row = CCI_ROW_INFANTRY
	power = 0
	effect = CCI_EFFECT_MARDROEME
	target_row = CCI_ROW_INFANTRY
	art = "cci_cards/clear_weather.png"

/datum/cci_card/rare_captain
	id = "rare_captain"
	name = "Field Captain"
	desc = "Morale boost for the row."
	row = CCI_ROW_INFANTRY
	power = 5
	rarity = CCI_RARITY_RARE
	effect = CCI_EFFECT_MORALE
	art = "cci_cards/field_captain.png"

/datum/cci_card/rare_saboteur
	id = "rare_saboteur"
	name = "Saboteur"
	desc = "Destroys the strongest enemy unit."
	row = CCI_ROW_ARCHERS
	power = 2
	rarity = CCI_RARITY_RARE
	effect = CCI_EFFECT_SCORCH_GLOBAL
	art = "cci_cards/siege_engineer.png"

/datum/cci_card/rare_berserker
	id = "rare_berserker"
	name = "Berserker"
	desc = "Turns into a bear under Mardroeme."
	row = CCI_ROW_INFANTRY
	power = 4
	rarity = CCI_RARITY_RARE
	effect = CCI_EFFECT_BERSERK
	art = "cci_cards/shield_guard.png"

/datum/cci_card/unique_avenger
	id = "unique_avenger"
	name = "Avenger"
	desc = "When the round ends, calls a stronger warrior before leaving."
	row = CCI_ROW_INFANTRY
	power = 6
	rarity = CCI_RARITY_UNIQUE
	effect = CCI_EFFECT_AVENGER
	avenger_card = "unique_avenger_bear"
	art = "cci_cards/shield_swordsman.png"
	hero = TRUE

/datum/cci_card/unique_avenger_bear
	id = "unique_avenger_bear"
	name = "Avenger Bear"
	desc = "A called avenger form."
	row = CCI_ROW_INFANTRY
	power = 10
	rarity = CCI_RARITY_UNIQUE
	art = "cci_cards/shield_guard.png"
	hero = TRUE

/datum/cci_card/unique_spy
	id = "unique_spy"
	name = "Court Spy"
	desc = "Played on the enemy side; draws two cards."
	row = CCI_ROW_INFANTRY
	power = 1
	rarity = CCI_RARITY_UNIQUE
	effect = CCI_EFFECT_SPY
	art = "cci_cards/scout.png"

/datum/cci_card/unique_svinoglazka
	id = "unique_svinoglazka"
	name = "Svinoglazka"
	desc = "Unique card: Svinoglazka. A grim noble warrior in blue."
	row = CCI_ROW_INFANTRY
	power = 7
	rarity = CCI_RARITY_UNIQUE
	effect = CCI_EFFECT_MORALE
	art = "cci_cards/svinoglazka.png"
	hero = TRUE
