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
#define CCI_EFFECT_SPY "spy"
#define CCI_EFFECT_CLEAR_WEATHER "clear_weather"
#define CCI_EFFECT_FROST "frost"
#define CCI_EFFECT_FOG "fog"
#define CCI_EFFECT_RAIN "rain"

#define CCI_COMBO_NONE "none"
#define CCI_COMBO_BOND "bond"

GLOBAL_LIST_EMPTY(cci_cards_by_id)
GLOBAL_LIST_EMPTY(cci_base_card_ids)

/proc/cci_build_card_registry()
	GLOB.cci_cards_by_id = list()
	GLOB.cci_base_card_ids = list()
	for(var/path in subtypesof(/datum/cci_card))
		var/datum/cci_card/card = new path()
		if(!card.id)
			continue
		GLOB.cci_cards_by_id[card.id] = card
		if(card.rarity == CCI_RARITY_BASE)
			GLOB.cci_base_card_ids += card.id

/proc/cci_card(card_id)
	if(!length(GLOB.cci_cards_by_id))
		cci_build_card_registry()
	return GLOB.cci_cards_by_id[card_id]

/datum/cci_card
	var/id
	var/name = "Unnamed Card"
	var/desc = ""
	var/row = CCI_ROW_INFANTRY
	var/power = 1
	var/rarity = CCI_RARITY_BASE
	var/effect = CCI_EFFECT_NONE
	var/combo = CCI_COMBO_NONE
	var/art = ""

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
		"art" = art,
		"known" = known,
		"selected" = selected
	)

// Add new cards by making another /datum/cci_card subtype with a unique id.
/datum/cci_card/base_swordsman
	id = "base_swordsman"
	name = "Swordsman"
	desc = "Reliable infantry."
	row = CCI_ROW_INFANTRY
	power = 4
	art = "cci_cards/swordsman.png"

/datum/cci_card/base_spearman
	id = "base_spearman"
	name = "Spearman"
	desc = "Doubles with other Spearmen."
	row = CCI_ROW_INFANTRY
	power = 3
	combo = CCI_COMBO_BOND
	art = "cci_cards/spearman.png"

/datum/cci_card/base_archer
	id = "base_archer"
	name = "Archer"
	desc = "Reliable ranged card."
	row = CCI_ROW_ARCHERS
	power = 4
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
	combo = CCI_COMBO_BOND
	art = "cci_cards/trebuchet.png"

/datum/cci_card/base_ballista
	id = "base_ballista"
	name = "Ballista"
	desc = "Siege engine."
	row = CCI_ROW_SIEGE
	power = 6
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
	art = "cci_cards/shield_guard.png"

/datum/cci_card/base_longbowman
	id = "base_longbowman"
	name = "Longbowman"
	desc = "Doubles with other Longbowmen."
	row = CCI_ROW_ARCHERS
	power = 3
	combo = CCI_COMBO_BOND
	art = "cci_cards/hood_archer.png"

/datum/cci_card/base_blacksmith
	id = "base_blacksmith"
	name = "Blacksmith"
	desc = "Morale support for siege."
	row = CCI_ROW_SIEGE
	power = 2
	effect = CCI_EFFECT_MORALE
	art = "cci_cards/blacksmith.png"

/datum/cci_card/base_supply_cart
	id = "base_supply_cart"
	name = "Supply Cart"
	desc = "Siege support."
	row = CCI_ROW_SIEGE
	power = 4
	art = "cci_cards/supply_cart.png"

/datum/cci_card/base_field_medic
	id = "base_field_medic"
	name = "Field Medic"
	desc = "Keeps the line together."
	row = CCI_ROW_INFANTRY
	power = 3
	effect = CCI_EFFECT_MORALE
	art = "cci_cards/field_medic.png"

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
	effect = CCI_EFFECT_SCORCH
	art = "cci_cards/siege_engineer.png"

/datum/cci_card/unique_spy
	id = "unique_spy"
	name = "Court Spy"
	desc = "Played on the enemy side; draws two cards."
	row = CCI_ROW_INFANTRY
	power = 1
	rarity = CCI_RARITY_UNIQUE
	effect = CCI_EFFECT_SPY
	art = "cci_cards/scout.png"
