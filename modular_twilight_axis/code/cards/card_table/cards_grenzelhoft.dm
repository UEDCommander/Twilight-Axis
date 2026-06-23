// Faction cards: grenzelhoft.

/datum/cci_card/rare_grenzelhoft_doppelsoldner
	id = "rare_grenzelhoft_doppelsoldner"
	name = "Doppelsoldner"
	desc = "A Grenzelhoft shock infantryman paid to break the line."
	row = CCI_ROW_INFANTRY
	power = 6
	rarity = CCI_RARITY_RARE
	faction = CCI_FACTION_GRENZELHOFT
	effect = CCI_EFFECT_BOND
	art = "cci_cards/grenzelhoft_doppelsoldner.png"

/datum/cci_card/rare_grenzelhoft_halberdier
	id = "rare_grenzelhoft_halberdier"
	name = "Halberdier"
	desc = "Polearm infantry from the mercenary guild's core."
	row = CCI_ROW_INFANTRY
	power = 5
	rarity = CCI_RARITY_BASE
	faction = CCI_FACTION_GRENZELHOFT
	effect = CCI_EFFECT_MORALE
	art = "cci_cards/grenzelhoft_halberdier.png"

/datum/cci_card/rare_grenzelhoft_crossbowman
	id = "rare_grenzelhoft_crossbowman"
	name = "Grenzelhoft Crossbowman"
	desc = "A disciplined crossbow line. Bonds with other Grenzelhoft Crossbowmen."
	row = CCI_ROW_ARCHERS
	power = 4
	rarity = CCI_RARITY_RARE
	faction = CCI_FACTION_GRENZELHOFT
	effect = CCI_EFFECT_BOND
	art = "cci_cards/grenzelhoft_crossbowman.png"

/datum/cci_card/rare_grenzelhoft_jager
	id = "rare_grenzelhoft_jager"
	name = "Grenzelhoft Jager"
	desc = "Imperial woodsman and marksman attached to a black company."
	row = CCI_ROW_ARCHERS
	power = 4
	rarity = CCI_RARITY_RARE
	faction = CCI_FACTION_GRENZELHOFT
	effect = CCI_EFFECT_SCORCH_INFANTRY
	art = "cci_cards/grenzelhoft_jager.png"

/datum/cci_card/rare_grenzelhoft_freifechter
	id = "rare_grenzelhoft_freifechter"
	name = "Freifechter Fencer"
	desc = "Free fencer from the Grenzelhoft border schools."
	row = CCI_ROW_INFANTRY
	power = 4
	rarity = CCI_RARITY_RARE
	faction = CCI_FACTION_GRENZELHOFT
	effect = CCI_EFFECT_AGILE
	art = "cci_cards/grenzelhoft_freifechter.png"

/datum/cci_card/rare_grenzelhoft_foreign_fencer
	id = "rare_grenzelhoft_foreign_fencer"
	name = "Foreign Fencer"
	desc = "Itinerant weapons expert trained in a Grenzelhoftian fencing school."
	row = CCI_ROW_INFANTRY
	power = 5
	rarity = CCI_RARITY_RARE
	faction = CCI_FACTION_GRENZELHOFT
	effect = CCI_EFFECT_AGILE
	art = "cci_cards/grenzelhoft_foreign_fencer.png"

/datum/cci_card/rare_grenzelhoft_condottiero
	id = "rare_grenzelhoft_condottiero"
	name = "Condottiero Ringleader"
	desc = "Contract captain whose coin binds crossbows and pikes."
	row = CCI_ROW_INFANTRY
	power = 5
	rarity = CCI_RARITY_RARE
	faction = CCI_FACTION_GRENZELHOFT
	effect = CCI_EFFECT_MORALE
	art = "cci_cards/grenzelhoft_condottiero.png"

/datum/cci_card/rare_grenzelhoft_siege_mage
	id = "rare_grenzelhoft_siege_mage"
	name = "Gefechtsgelehrter"
	desc = "A Grenzelhoft battle-scholar attached to siege works."
	row = CCI_ROW_SIEGE
	power = 3
	rarity = CCI_RARITY_RARE
	faction = CCI_FACTION_GRENZELHOFT
	effect = CCI_EFFECT_HORN
	target_row = CCI_ROW_SIEGE
	art = "cci_cards/grenzelhoft_siege_mage.png"

/datum/cci_card/unique_grenzelhoft_iron_captain
	id = "unique_grenzelhoft_iron_captain"
	name = "Iron Captain"
	desc = "Hero. A mercenary commander who knows when to burn the strongest piece."
	row = CCI_ROW_INFANTRY
	power = 7
	rarity = CCI_RARITY_UNIQUE
	faction = CCI_FACTION_GRENZELHOFT
	effect = CCI_EFFECT_SCORCH_GLOBAL
	art = "cci_cards/grenzelhoft_iron_captain.png"
	hero = TRUE
