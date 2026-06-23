// Faction cards: enigma.

/datum/cci_card/rare_saboteur
	id = "rare_saboteur"
	name = "Saboteur"
	desc = "Destroys the strongest enemy unit."
	row = CCI_ROW_ARCHERS
	power = 2
	rarity = CCI_RARITY_RARE
	faction = CCI_FACTION_ENIGMA
	effect = CCI_EFFECT_SCORCH_GLOBAL
	art = "cci_cards/enigma_saboteur.png"

/datum/cci_card/unique_avenger
	id = "unique_avenger"
	name = "Avenger"
	desc = "When the round ends, calls a stronger warrior before leaving."
	row = CCI_ROW_INFANTRY
	power = 6
	rarity = CCI_RARITY_UNIQUE
	faction = CCI_FACTION_ENIGMA
	effect = CCI_EFFECT_AVENGER
	avenger_card = "unique_enigma_revenant"
	art = "cci_cards/enigma_avenger.png"
	hero = TRUE

/datum/cci_card/unique_enigma_revenant
	id = "unique_enigma_revenant"
	name = "Avenger Revenant"
	desc = "A called Enigma champion."
	row = CCI_ROW_INFANTRY
	power = 10
	rarity = CCI_RARITY_UNIQUE
	faction = CCI_FACTION_ENIGMA
	art = "cci_cards/enigma_revenant.png"
	hero = TRUE

/datum/cci_card/rare_enigma_royal_guard
	id = "rare_enigma_royal_guard"
	name = "Royal Guard"
	desc = "Disciplined Enigma retinue infantry. Bonds with other Royal Guards."
	row = CCI_ROW_INFANTRY
	power = 5
	rarity = CCI_RARITY_BASE
	faction = CCI_FACTION_ENIGMA
	effect = CCI_EFFECT_BOND
	art = "cci_cards/enigma_royal_guard.png"

/datum/cci_card/rare_enigma_vanguard_archer
	id = "rare_enigma_vanguard_archer"
	name = "Vanguard Archer"
	desc = "Frontier archer trained to break enemy pushes."
	row = CCI_ROW_ARCHERS
	power = 4
	rarity = CCI_RARITY_RARE
	faction = CCI_FACTION_ENIGMA
	effect = CCI_EFFECT_SCORCH_INFANTRY
	art = "cci_cards/enigma_vanguard_archer.png"

/datum/cci_card/rare_enigma_standard_bearer
	id = "rare_enigma_standard_bearer"
	name = "Vanguard Standard Bearer"
	desc = "A standard-bearer that doubles the infantry row."
	row = CCI_ROW_INFANTRY
	power = 0
	rarity = CCI_RARITY_RARE
	faction = CCI_FACTION_ENIGMA
	effect = CCI_EFFECT_HORN
	target_row = CCI_ROW_INFANTRY
	art = "cci_cards/enigma_standard_bearer.png"

/datum/cci_card/unique_enigma_overseer
	id = "unique_enigma_overseer"
	name = "Overseer"
	desc = "Hero. An Enigma field commander who preserves order with iron discipline."
	row = CCI_ROW_INFANTRY
	power = 7
	rarity = CCI_RARITY_UNIQUE
	faction = CCI_FACTION_ENIGMA
	effect = CCI_EFFECT_MORALE
	art = "cci_cards/enigma_overseer.png"
	hero = TRUE

/datum/cci_card/unique_enigma_court_physician
	id = "unique_enigma_court_physician"
	name = "Court Physician"
	desc = "Hero. Restores a fallen unit from the discard."
	row = CCI_ROW_INFANTRY
	power = 5
	rarity = CCI_RARITY_UNIQUE
	faction = CCI_FACTION_ENIGMA
	effect = CCI_EFFECT_MEDIC
	art = "cci_cards/enigma_court_physician.png"
	hero = TRUE
