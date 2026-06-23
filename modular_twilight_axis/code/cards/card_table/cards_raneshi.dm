// Faction cards: raneshi.

/datum/cci_card/rare_raneshi_desert_janissary
	id = "rare_raneshi_desert_janissary"
	name = "Desert Rider Janissary"
	desc = "Raneshi Desert Town cavalry in high-fantasy Gwent styling."
	row = CCI_ROW_INFANTRY
	power = 5
	rarity = CCI_RARITY_RARE
	faction = CCI_FACTION_RANESHI
	effect = CCI_EFFECT_AGILE
	art = "cci_cards/raneshi_desert_janissary.png"

/datum/cci_card/rare_raneshi_zeybek
	id = "rare_raneshi_zeybek"
	name = "Desert Rider Zeybek"
	desc = "A swift Raneshi skirmisher who can join either line."
	row = CCI_ROW_ARCHERS
	power = 4
	rarity = CCI_RARITY_RARE
	faction = CCI_FACTION_RANESHI
	effect = CCI_EFFECT_AGILE
	art = "cci_cards/raneshi_zeybek.png"

/datum/cci_card/rare_raneshi_sahir
	id = "rare_raneshi_sahir"
	name = "Desert Rider Sahir"
	desc = "A mirage-caster who strips weather from the field."
	row = CCI_ROW_ARCHERS
	power = 3
	rarity = CCI_RARITY_RARE
	faction = CCI_FACTION_RANESHI
	effect = CCI_EFFECT_CLEAR_WEATHER
	art = "cci_cards/raneshi_sahir.png"

/datum/cci_card/rare_raneshi_miragefen_rogue
	id = "rare_raneshi_miragefen_rogue"
	name = "Miragefen Rogue"
	desc = "A masked Raneshi rogue; played as a spy for two cards."
	row = CCI_ROW_INFANTRY
	power = 2
	rarity = CCI_RARITY_RARE
	faction = CCI_FACTION_RANESHI
	effect = CCI_EFFECT_SPY
	art = "cci_cards/raneshi_miragefen_rogue.png"

/datum/cci_card/rare_raneshi_azeb_guard
	id = "rare_raneshi_azeb_guard"
	name = "Raneshi Azeb Guard"
	desc = "Provincial desert infantry holding the line for the Sultanate."
	row = CCI_ROW_INFANTRY
	power = 4
	rarity = CCI_RARITY_BASE
	faction = CCI_FACTION_RANESHI
	effect = CCI_EFFECT_BOND
	art = "cci_cards/raneshi_azeb_guard.png"

/datum/cci_card/rare_raneshi_slaver
	id = "rare_raneshi_slaver"
	name = "Ranesheni Slaver"
	desc = "A brutal catcher who removes the strongest unit on the field."
	row = CCI_ROW_INFANTRY
	power = 3
	rarity = CCI_RARITY_RARE
	faction = CCI_FACTION_RANESHI
	effect = CCI_EFFECT_SCORCH_GLOBAL
	art = "cci_cards/raneshi_slaver.png"

/datum/cci_card/rare_raneshi_forlorn_hope
	id = "rare_raneshi_forlorn_hope"
	name = "Forlorn Hope"
	desc = "Ranesheni slave-revolt mercenaries who trade pain for freedom."
	row = CCI_ROW_INFANTRY
	power = 5
	rarity = CCI_RARITY_RARE
	faction = CCI_FACTION_RANESHI
	effect = CCI_EFFECT_SCORCH_INFANTRY
	art = "cci_cards/raneshi_forlorn_hope.png"

/datum/cci_card/rare_raneshi_bronzeclad
	id = "rare_raneshi_bronzeclad"
	name = "Raneshen Bronzeclad"
	desc = "Arena-born bronze warrior from the curtain courts."
	row = CCI_ROW_INFANTRY
	power = 5
	rarity = CCI_RARITY_RARE
	faction = CCI_FACTION_RANESHI
	effect = CCI_EFFECT_MORALE
	art = "cci_cards/raneshi_bronzeclad.png"

/datum/cci_card/rare_raneshi_thespian_errant
	id = "rare_raneshi_thespian_errant"
	name = "Thespian-Errant"
	desc = "Arena reenactor and curtain-court wanderer from the Raneshen circuit."
	row = CCI_ROW_INFANTRY
	power = 5
	rarity = CCI_RARITY_RARE
	faction = CCI_FACTION_RANESHI
	effect = CCI_EFFECT_MORALE
	art = "cci_cards/raneshi_thespian_errant.png"

/datum/cci_card/rare_raneshi_mushir
	id = "rare_raneshi_mushir"
	name = "Mushir"
	desc = "Desert Town marshal title. Doubles the siege row with command discipline."
	row = CCI_ROW_SIEGE
	power = 3
	rarity = CCI_RARITY_RARE
	faction = CCI_FACTION_RANESHI
	effect = CCI_EFFECT_HORN
	target_row = CCI_ROW_SIEGE
	art = "cci_cards/raneshi_mushir.png"

/datum/cci_card/unique_raneshi_almah
	id = "unique_raneshi_almah"
	name = "Desert Rider Almah"
	desc = "Hero. A Raneshi elite rider from the Desert Town legends."
	row = CCI_ROW_INFANTRY
	power = 8
	rarity = CCI_RARITY_UNIQUE
	faction = CCI_FACTION_RANESHI
	effect = CCI_EFFECT_MORALE
	art = "cci_cards/raneshi_almah.png"
	hero = TRUE

/datum/cci_card/unique_raneshi_amir
	id = "unique_raneshi_amir"
	name = "Amir of Desert Town"
	desc = "Hero. The desert court's sovereign hand and banner."
	row = CCI_ROW_INFANTRY
	power = 8
	rarity = CCI_RARITY_UNIQUE
	faction = CCI_FACTION_RANESHI
	effect = CCI_EFFECT_MORALE
	art = "cci_cards/raneshi_amir.png"
	hero = TRUE

/datum/cci_card/unique_raneshi_spice_prince
	id = "unique_raneshi_spice_prince"
	name = "Spice Prince"
	desc = "Hero. A silk-veiled patron whose coin moves armies."
	row = CCI_ROW_ARCHERS
	power = 7
	rarity = CCI_RARITY_UNIQUE
	faction = CCI_FACTION_RANESHI
	effect = CCI_EFFECT_MEDIC
	art = "cci_cards/raneshi_spice_prince.png"
	hero = TRUE
