// Faction cards: azuria.

/datum/cci_card/rare_captain
	id = "rare_captain"
	name = "Field Captain"
	desc = "Morale boost for the row."
	row = CCI_ROW_INFANTRY
	power = 5
	rarity = CCI_RARITY_RARE
	faction = CCI_FACTION_AZURIA
	effect = CCI_EFFECT_MORALE
	art = "cci_cards/azuria_field_captain.png"

/datum/cci_card/unique_spy
	id = "unique_spy"
	name = "Court Spy"
	desc = "Played on the enemy side; draws two cards."
	row = CCI_ROW_INFANTRY
	power = 1
	rarity = CCI_RARITY_UNIQUE
	faction = CCI_FACTION_AZURIA
	effect = CCI_EFFECT_SPY
	art = "cci_cards/azuria_court_spy.png"

/datum/cci_card/rare_azuria_knight
	id = "rare_azuria_knight"
	name = "Ducal Knight"
	desc = "High-fantasy Gwent-style Azurian heavy cavalry. Bonds with other Ducal Knights."
	row = CCI_ROW_INFANTRY
	power = 6
	rarity = CCI_RARITY_RARE
	faction = CCI_FACTION_AZURIA
	effect = CCI_EFFECT_BOND
	art = "cci_cards/azuria_knight.png"

/datum/cci_card/rare_azuria_squire
	id = "rare_azuria_squire"
	name = "Squire at Arms"
	desc = "A young retinue fighter holding the line for the court."
	row = CCI_ROW_INFANTRY
	power = 4
	rarity = CCI_RARITY_BASE
	faction = CCI_FACTION_AZURIA
	effect = CCI_EFFECT_MORALE
	art = "cci_cards/azuria_squire.png"

/datum/cci_card/rare_azuria_court_magician
	id = "rare_azuria_court_magician"
	name = "Court Magician"
	desc = "Azurian arcyne support that clears the skies for the host."
	row = CCI_ROW_ARCHERS
	power = 3
	rarity = CCI_RARITY_RARE
	faction = CCI_FACTION_AZURIA
	effect = CCI_EFFECT_CLEAR_WEATHER
	art = "cci_cards/azuria_court_magician.png"

/datum/cci_card/rare_azuria_azurcaephan
	id = "rare_azuria_azurcaephan"
	name = "Azurcaephan"
	desc = "Azurean spellblade tradition, channeling arcyne momentum through the melee."
	row = CCI_ROW_INFANTRY
	power = 6
	rarity = CCI_RARITY_RARE
	faction = CCI_FACTION_AZURIA
	effect = CCI_EFFECT_AGILE
	art = "cci_cards/azuria_azurcaephan.png"

/datum/cci_card/rare_azuria_grovewalker
	id = "rare_azuria_grovewalker"
	name = "Azurian Grovewalker"
	desc = "Black Oak guardian-errant moving with autumn grace through the wilds."
	row = CCI_ROW_ARCHERS
	power = 4
	rarity = CCI_RARITY_RARE
	faction = CCI_FACTION_AZURIA
	effect = CCI_EFFECT_CLEAR_WEATHER
	art = "cci_cards/azuria_grovewalker.png"

/datum/cci_card/unique_azuria_grand_duke
	id = "unique_azuria_grand_duke"
	name = "Grand Duke"
	desc = "Hero. The ducal banner gathers the infantry line."
	row = CCI_ROW_INFANTRY
	power = 8
	rarity = CCI_RARITY_UNIQUE
	faction = CCI_FACTION_AZURIA
	effect = CCI_EFFECT_MORALE
	art = "cci_cards/azuria_grand_duke.png"
	hero = TRUE

/datum/cci_card/unique_azuria_imperial_spellblade
	id = "unique_azuria_imperial_spellblade"
	name = "Imperial Spellblade"
	desc = "Hero. A high-fantasy bladecaster from the Azure tradition."
	row = CCI_ROW_INFANTRY
	power = 7
	rarity = CCI_RARITY_UNIQUE
	faction = CCI_FACTION_AZURIA
	effect = CCI_EFFECT_AGILE
	art = "cci_cards/azuria_imperial_spellblade.png"
	hero = TRUE
