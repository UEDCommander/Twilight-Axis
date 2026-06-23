// Common and neutral cards.

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
	art = "cci_cards/militia.png"

/datum/cci_card/base_mangonel
	id = "base_mangonel"
	name = "Mangonel"
	desc = "Basic siege engine."
	row = CCI_ROW_SIEGE
	power = 3
	art = "cci_cards/mangonel.png"

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
	art = "cci_cards/decoy.png"

/datum/cci_card/base_horn_infantry
	id = "base_horn_infantry"
	name = "Infantry Horn"
	desc = "Doubles all units in your infantry row."
	row = CCI_ROW_INFANTRY
	power = 0
	effect = CCI_EFFECT_HORN
	target_row = CCI_ROW_INFANTRY
	art = "cci_cards/infantry_horn.png"

/datum/cci_card/base_horn_archers
	id = "base_horn_archers"
	name = "Archers Horn"
	desc = "Doubles all units in your archers row."
	row = CCI_ROW_ARCHERS
	power = 0
	effect = CCI_EFFECT_HORN
	target_row = CCI_ROW_ARCHERS
	art = "cci_cards/archers_horn.png"

/datum/cci_card/base_horn_siege
	id = "base_horn_siege"
	name = "Siege Horn"
	desc = "Doubles all units in your siege row."
	row = CCI_ROW_SIEGE
	power = 0
	effect = CCI_EFFECT_HORN
	target_row = CCI_ROW_SIEGE
	art = "cci_cards/siege_horn.png"

/datum/cci_card/base_scorch
	id = "base_scorch"
	name = "Scorch"
	desc = "Destroys the strongest unit or units on the battlefield."
	row = CCI_ROW_WEATHER
	power = 0
	effect = CCI_EFFECT_SCORCH_GLOBAL
	art = "cci_cards/scorch.png"

/datum/cci_card/base_mardroeme
	id = "base_mardroeme"
	name = "Mardroeme"
	desc = "Turns Berserkers in your infantry row into bears."
	row = CCI_ROW_INFANTRY
	power = 0
	effect = CCI_EFFECT_MARDROEME
	target_row = CCI_ROW_INFANTRY
	art = "cci_cards/mardroeme.png"

/datum/cci_card/rare_neutral_hedge_knight
	id = "rare_neutral_hedge_knight"
	name = "Hedge Knight"
	desc = "Neutral adventurer. A wandering blade for any deck."
	row = CCI_ROW_INFANTRY
	power = 5
	rarity = CCI_RARITY_RARE
	effect = CCI_EFFECT_MORALE
	art = "cci_cards/hedge_knight.png"

/datum/cci_card/rare_neutral_witch
	id = "rare_neutral_witch"
	name = "Witch"
	desc = "Neutral adventurer. Strange rites clear unnatural weather."
	row = CCI_ROW_ARCHERS
	power = 3
	rarity = CCI_RARITY_RARE
	effect = CCI_EFFECT_CLEAR_WEATHER
	art = "cci_cards/witch.png"

/datum/cci_card/rare_neutral_treasure_hunter
	id = "rare_neutral_treasure_hunter"
	name = "Treasure Hunter"
	desc = "Neutral adventurer. A spy who pays for risk with cards."
	row = CCI_ROW_ARCHERS
	power = 1
	rarity = CCI_RARITY_RARE
	effect = CCI_EFFECT_SPY
	art = "cci_cards/treasure_hunter.png"

/datum/cci_card/rare_neutral_barber_surgeon
	id = "rare_neutral_barber_surgeon"
	name = "Barber Surgeon"
	desc = "Neutral adventurer. Brings one fallen unit back to the fight."
	row = CCI_ROW_INFANTRY
	power = 4
	rarity = CCI_RARITY_RARE
	effect = CCI_EFFECT_MEDIC
	art = "cci_cards/barber_surgeon.png"

/datum/cci_card/rare_neutral_battlemaster
	id = "rare_neutral_battlemaster"
	name = "Battlemaster"
	desc = "Neutral adventurer. A seasoned weapon specialist who steadies the infantry line."
	row = CCI_ROW_INFANTRY
	power = 5
	rarity = CCI_RARITY_RARE
	effect = CCI_EFFECT_MORALE
	art = "cci_cards/battlemaster.png"

/datum/cci_card/rare_neutral_duelist
	id = "rare_neutral_duelist"
	name = "Duelist"
	desc = "Neutral adventurer. A nimble swordsman who can answer either front."
	row = CCI_ROW_INFANTRY
	power = 4
	rarity = CCI_RARITY_RARE
	effect = CCI_EFFECT_AGILE
	art = "cci_cards/duelist.png"

/datum/cci_card/rare_neutral_barbarian
	id = "rare_neutral_barbarian"
	name = "Barbarian"
	desc = "Neutral adventurer. A brutal fighter who can be driven into a berserk charge."
	row = CCI_ROW_INFANTRY
	power = 6
	rarity = CCI_RARITY_RARE
	effect = CCI_EFFECT_BERSERK
	art = "cci_cards/barbarian.png"

/datum/cci_card/rare_neutral_ironclad
	id = "rare_neutral_ironclad"
	name = "Ironclad"
	desc = "Neutral adventurer. Heavy armor and discipline form a hard front."
	row = CCI_ROW_INFANTRY
	power = 6
	rarity = CCI_RARITY_RARE
	effect = CCI_EFFECT_BOND
	art = "cci_cards/ironclad.png"

/datum/cci_card/rare_neutral_exorcist
	id = "rare_neutral_exorcist"
	name = "Exorcist"
	desc = "Neutral adventurer. A monster hunter whose silver work cuts down the strongest threat."
	row = CCI_ROW_INFANTRY
	power = 5
	rarity = CCI_RARITY_RARE
	effect = CCI_EFFECT_SCORCH_GLOBAL
	art = "cci_cards/exorcist.png"

/datum/cci_card/rare_neutral_deprived
	id = "rare_neutral_deprived"
	name = "Deprived"
	desc = "Neutral adventurer. A stripped survivor who calls more desperate bodies to the field."
	row = CCI_ROW_INFANTRY
	power = 2
	rarity = CCI_RARITY_RARE
	effect = CCI_EFFECT_MUSTER
	art = "cci_cards/deprived.png"

/datum/cci_card/rare_neutral_sentinel
	id = "rare_neutral_sentinel"
	name = "Sentinel"
	desc = "Neutral adventurer. A ranger bodyguard watching the dangerous paths."
	row = CCI_ROW_ARCHERS
	power = 4
	rarity = CCI_RARITY_RARE
	effect = CCI_EFFECT_MORALE
	art = "cci_cards/sentinel.png"

/datum/cci_card/rare_neutral_wayfarer
	id = "rare_neutral_wayfarer"
	name = "Wayfarer"
	desc = "Neutral adventurer. A tracker and man-hunter played forward as a spy."
	row = CCI_ROW_ARCHERS
	power = 2
	rarity = CCI_RARITY_RARE
	effect = CCI_EFFECT_SPY
	art = "cci_cards/wayfarer.png"

/datum/cci_card/rare_neutral_bombadier
	id = "rare_neutral_bombadier"
	name = "Bombadier"
	desc = "Neutral adventurer. Bombs and alchemy break the strongest packed rank."
	row = CCI_ROW_SIEGE
	power = 4
	rarity = CCI_RARITY_RARE
	effect = CCI_EFFECT_SCORCH_GLOBAL
	art = "cci_cards/bombardier.png"

/datum/cci_card/rare_neutral_biome_wanderer
	id = "rare_neutral_biome_wanderer"
	name = "Biome Wanderer"
	desc = "Neutral adventurer. A wildlands expert who clears hostile weather."
	row = CCI_ROW_ARCHERS
	power = 3
	rarity = CCI_RARITY_RARE
	effect = CCI_EFFECT_CLEAR_WEATHER
	art = "cci_cards/biome_wanderer.png"

/datum/cci_card/rare_neutral_aristocrat
	id = "rare_neutral_aristocrat"
	name = "Aristocrat"
	desc = "Neutral adventurer. Coin, rumor, and courtly contacts buy two cards."
	row = CCI_ROW_INFANTRY
	power = 2
	rarity = CCI_RARITY_RARE
	effect = CCI_EFFECT_SPY
	art = "cci_cards/aristocrat.png"

/datum/cci_card/rare_neutral_knight_errant
	id = "rare_neutral_knight_errant"
	name = "Knight Errant"
	desc = "Neutral adventurer. A traveling knight whose banner lifts the line."
	row = CCI_ROW_INFANTRY
	power = 6
	rarity = CCI_RARITY_RARE
	effect = CCI_EFFECT_MORALE
	art = "cci_cards/knight_errant.png"

/datum/cci_card/rare_neutral_squire_errant
	id = "rare_neutral_squire_errant"
	name = "Squire Errant"
	desc = "Neutral adventurer. A young retainer who bonds with another squire."
	row = CCI_ROW_INFANTRY
	power = 3
	rarity = CCI_RARITY_RARE
	effect = CCI_EFFECT_BOND
	art = "cci_cards/squire_errant.png"

/datum/cci_card/rare_neutral_monk
	id = "rare_neutral_monk"
	name = "Monk"
	desc = "Neutral adventurer. A wandering acolyte trained in miracles and bare-handed discipline."
	row = CCI_ROW_INFANTRY
	power = 3
	rarity = CCI_RARITY_RARE
	effect = CCI_EFFECT_MEDIC
	art = "cci_cards/monk.png"

/datum/cci_card/rare_neutral_paladin
	id = "rare_neutral_paladin"
	name = "Paladin"
	desc = "Neutral adventurer. A holy knight who anchors the infantry row."
	row = CCI_ROW_INFANTRY
	power = 6
	rarity = CCI_RARITY_RARE
	effect = CCI_EFFECT_MORALE
	art = "cci_cards/paladin.png"

/datum/cci_card/rare_neutral_cantor
	id = "rare_neutral_cantor"
	name = "Cantor"
	desc = "Neutral adventurer. A sacred singer who doubles the archers row."
	row = CCI_ROW_ARCHERS
	power = 2
	rarity = CCI_RARITY_RARE
	effect = CCI_EFFECT_HORN
	target_row = CCI_ROW_ARCHERS
	art = "cci_cards/cantor.png"

/datum/cci_card/rare_neutral_missionary
	id = "rare_neutral_missionary"
	name = "Missionary"
	desc = "Neutral adventurer. A wandering preacher who clears foul weather."
	row = CCI_ROW_ARCHERS
	power = 2
	rarity = CCI_RARITY_RARE
	effect = CCI_EFFECT_CLEAR_WEATHER
	art = "cci_cards/missionary.png"

/datum/cci_card/rare_neutral_nightblade
	id = "rare_neutral_nightblade"
	name = "Nightblade"
	desc = "Neutral adventurer. A devout knife in the dark, placed forward as a spy."
	row = CCI_ROW_INFANTRY
	power = 2
	rarity = CCI_RARITY_RARE
	effect = CCI_EFFECT_SPY
	art = "cci_cards/nightblade.png"

/datum/cci_card/rare_neutral_aavnic_hussar
	id = "rare_neutral_aavnic_hussar"
	name = "Aavnic Hussar"
	desc = "Neutral mercenary. A disgraced winged rider still chasing honor."
	row = CCI_ROW_INFANTRY
	power = 6
	rarity = CCI_RARITY_RARE
	effect = CCI_EFFECT_AGILE
	art = "cci_cards/aavnic_hussar.png"

/datum/cci_card/rare_neutral_twilight_gunslinger
	id = "rare_neutral_twilight_gunslinger"
	name = "Twilight Gunslinger"
	desc = "Neutral mercenary. A strange duelist with thunder in the hand."
	row = CCI_ROW_ARCHERS
	power = 4
	rarity = CCI_RARITY_RARE
	effect = CCI_EFFECT_SCORCH_INFANTRY
	art = "cci_cards/twilight_gunslinger.png"

/datum/cci_card/rare_neutral_vaquero
	id = "rare_neutral_vaquero"
	name = "Vaquero"
	desc = "Neutral mercenary rider from the far ranges."
	row = CCI_ROW_ARCHERS
	power = 3
	rarity = CCI_RARITY_RARE
	effect = CCI_EFFECT_AGILE
	art = "cci_cards/vaquero.png"

/datum/cci_card/rare_neutral_thief
	id = "rare_neutral_thief"
	name = "Thief"
	desc = "Neutral adventurer. A scoundrel played as a spy for two cards."
	row = CCI_ROW_INFANTRY
	power = 1
	rarity = CCI_RARITY_RARE
	effect = CCI_EFFECT_SPY
	art = "cci_cards/thief.png"

/datum/cci_card/rare_neutral_bard
	id = "rare_neutral_bard"
	name = "Bard"
	desc = "Neutral adventurer. Songs and lies lift the whole line."
	row = CCI_ROW_ARCHERS
	power = 3
	rarity = CCI_RARITY_RARE
	effect = CCI_EFFECT_MORALE
	art = "cci_cards/bard.png"

/datum/cci_card/rare_neutral_soundbreaker
	id = "rare_neutral_soundbreaker"
	name = "Soundbreaker"
	desc = "Neutral adventurer. A brawling bard whose rhythm breaks morale."
	row = CCI_ROW_INFANTRY
	power = 4
	rarity = CCI_RARITY_RARE
	effect = CCI_EFFECT_SCORCH_INFANTRY
	art = "cci_cards/soundbreaker.png"

/datum/cci_card/rare_neutral_swashbuckler
	id = "rare_neutral_swashbuckler"
	name = "Swashbuckler"
	desc = "Neutral adventurer. Agile swordplay and dirty tricks."
	row = CCI_ROW_INFANTRY
	power = 4
	rarity = CCI_RARITY_RARE
	effect = CCI_EFFECT_AGILE
	art = "cci_cards/swashbuckler.png"

/datum/cci_card/rare_neutral_mystic
	id = "rare_neutral_mystic"
	name = "Mystic"
	desc = "Neutral adventurer. A faith-touched arcyne student who clears the skies."
	row = CCI_ROW_ARCHERS
	power = 3
	rarity = CCI_RARITY_RARE
	effect = CCI_EFFECT_CLEAR_WEATHER
	art = "cci_cards/mystic.png"

/datum/cci_card/rare_neutral_sage
	id = "rare_neutral_sage"
	name = "Sage"
	desc = "Neutral adventurer. A shielded healer who restores one fallen unit."
	row = CCI_ROW_ARCHERS
	power = 4
	rarity = CCI_RARITY_RARE
	effect = CCI_EFFECT_MEDIC
	art = "cci_cards/sage.png"

/datum/cci_card/rare_neutral_luminary
	id = "rare_neutral_luminary"
	name = "Luminary"
	desc = "Neutral adventurer. A holy blade whose presence strengthens the line."
	row = CCI_ROW_INFANTRY
	power = 5
	rarity = CCI_RARITY_RARE
	effect = CCI_EFFECT_MORALE
	art = "cci_cards/luminary.png"

/datum/cci_card/rare_neutral_sorcerer
	id = "rare_neutral_sorcerer"
	name = "Sorcerer"
	desc = "Neutral adventurer. Learned arcyne fire breaks the strongest battlefield piece."
	row = CCI_ROW_ARCHERS
	power = 5
	rarity = CCI_RARITY_RARE
	effect = CCI_EFFECT_SCORCH_GLOBAL
	art = "cci_cards/sorcerer.png"

/datum/cci_card/rare_neutral_spellsinger
	id = "rare_neutral_spellsinger"
	name = "Spellsinger"
	desc = "Neutral adventurer. Arcane song doubles the archers row."
	row = CCI_ROW_ARCHERS
	power = 3
	rarity = CCI_RARITY_RARE
	effect = CCI_EFFECT_HORN
	target_row = CCI_ROW_ARCHERS
	art = "cci_cards/spellsinger.png"

/datum/cci_card/rare_neutral_spellfist
	id = "rare_neutral_spellfist"
	name = "Spellfist"
	desc = "Neutral adventurer. An arcyne martial artist flexible enough for either front."
	row = CCI_ROW_INFANTRY
	power = 5
	rarity = CCI_RARITY_RARE
	effect = CCI_EFFECT_AGILE
	art = "cci_cards/spellfist.png"

/datum/cci_card/rare_neutral_arcyne_trickster
	id = "rare_neutral_arcyne_trickster"
	name = "Arcyne Trickster"
	desc = "Neutral adventurer. A spell-thief whose misdirection draws two cards."
	row = CCI_ROW_ARCHERS
	power = 2
	rarity = CCI_RARITY_RARE
	effect = CCI_EFFECT_SPY
	art = "cci_cards/arcyne_trickster.png"

/datum/cci_card/rare_neutral_antiquarian
	id = "rare_neutral_antiquarian"
	name = "Antiquarian"
	desc = "Neutral adventurer. Scholarship and contacts recover one fallen unit."
	row = CCI_ROW_ARCHERS
	power = 2
	rarity = CCI_RARITY_RARE
	effect = CCI_EFFECT_MEDIC
	art = "cci_cards/antiquarian.png"

/datum/cci_card/rare_neutral_forlorn_hope
	id = "rare_neutral_forlorn_hope"
	name = "Forlorn Hope Mercenary"
	desc = "Neutral mercenary. A desperate vanguard card with battlefield bite."
	row = CCI_ROW_INFANTRY
	power = 4
	rarity = CCI_RARITY_RARE
	effect = CCI_EFFECT_SCORCH_INFANTRY
	art = "cci_cards/forlorn_hope.png"

/datum/cci_card/rare_neutral_confessor
	id = "rare_neutral_confessor"
	name = "Confessor"
	desc = "Neutral inquisitorial hunter. Subterfuge exposes a weakness in the enemy infantry."
	row = CCI_ROW_ARCHERS
	power = 4
	rarity = CCI_RARITY_RARE
	effect = CCI_EFFECT_SCORCH_INFANTRY
	art = "cci_cards/confessor.png"

/datum/cci_card/rare_neutral_disciple
	id = "rare_neutral_disciple"
	name = "Disciple"
	desc = "Neutral inquisitorial monk. A hard lesson that keeps the line steady."
	row = CCI_ROW_INFANTRY
	power = 4
	rarity = CCI_RARITY_RARE
	effect = CCI_EFFECT_MORALE
	art = "cci_cards/disciple.png"

/datum/cci_card/rare_neutral_absolver
	id = "rare_neutral_absolver"
	name = "Absolver"
	desc = "Neutral inquisitorial agent. A hard rite clears foul weather from the field."
	row = CCI_ROW_INFANTRY
	power = 5
	rarity = CCI_RARITY_RARE
	effect = CCI_EFFECT_CLEAR_WEATHER
	art = "cci_cards/absolver.png"

/datum/cci_card/rare_neutral_inquisitor
	id = "rare_neutral_inquisitor"
	name = "Inquisitor"
	desc = "Neutral inquisitorial hunter. Judgment destroys the strongest enemy front."
	row = CCI_ROW_INFANTRY
	power = 6
	rarity = CCI_RARITY_RARE
	effect = CCI_EFFECT_SCORCH_INFANTRY
	art = "cci_cards/inquisitor.png"

/datum/cci_card/rare_neutral_psyaltrist
	id = "rare_neutral_psyaltrist"
	name = "Psyaltrist"
	desc = "Neutral inquisitorial cantor. Practical songcraft doubles the infantry row."
	row = CCI_ROW_INFANTRY
	power = 2
	rarity = CCI_RARITY_RARE
	effect = CCI_EFFECT_HORN
	target_row = CCI_ROW_INFANTRY
	art = "cci_cards/psyaltrist.png"

/datum/cci_card/unique_neutral_adjudicator
	id = "unique_neutral_adjudicator"
	name = "Adjudicator"
	desc = "Neutral hero. Psydonite knight entrusted with lesser invocations."
	row = CCI_ROW_INFANTRY
	power = 7
	rarity = CCI_RARITY_UNIQUE
	effect = CCI_EFFECT_MORALE
	art = "cci_cards/adjudicator.png"
	hero = TRUE

/datum/cci_card/unique_neutral_ordinator
	id = "unique_neutral_ordinator"
	name = "Ordinator"
	desc = "Neutral hero. A heavy inquisitorial judge who breaks the strongest piece."
	row = CCI_ROW_INFANTRY
	power = 8
	rarity = CCI_RARITY_UNIQUE
	effect = CCI_EFFECT_SCORCH_GLOBAL
	art = "cci_cards/ordinator.png"
	hero = TRUE

/datum/cci_card/unique_neutral_hag
	id = "unique_neutral_hag"
	name = "Hag"
	desc = "Neutral hero. A high-fantasy curse-worker from the wild margins."
	row = CCI_ROW_WEATHER
	power = 0
	rarity = CCI_RARITY_UNIQUE
	effect = CCI_EFFECT_SCORCH_GLOBAL
	art = "cci_cards/hag.png"
	hero = TRUE

/datum/cci_card/unique_neutral_otavan_repentant
	id = "unique_neutral_otavan_repentant"
	name = "Otavan Repentant"
	desc = "Neutral hero. An exiled penitent whose heresy hunts the strongest piece."
	row = CCI_ROW_ARCHERS
	power = 7
	rarity = CCI_RARITY_UNIQUE
	effect = CCI_EFFECT_SCORCH_GLOBAL
	art = "cci_cards/otavan_repentant.png"
	hero = TRUE

/datum/cci_card/rare_neutral_szorendnizine_shepherd
	id = "rare_neutral_szorendnizine_shepherd"
	name = "Szorendnizine Shepherd"
	desc = "Neutral adventurer. A Free City shepherd hardened by wilderness and axe."
	row = CCI_ROW_INFANTRY
	power = 4
	rarity = CCI_RARITY_RARE
	effect = CCI_EFFECT_AGILE
	art = "cci_cards/szorendnizine_shepherd.png"
