// Zizo items
#define HERESYDESC_ZIZO_WEAPON "Мрачное оружие воинов Зизо"
#define HERESYDESC_ZIZO_ARMOR "Проклятый доспех воинов Зизо"
#define HERESYDESC_ZIZO_RELIC "Реликвия мрачного творения Зизо"
#define HERESYDESC_ZIZO_ICON "На нём изображён мрачный крест Зизо"
#define HERESYDESC_ZIZO_MISC "Известный дизайн Зизо"
#define HERESYDESC_ZIZO_AVANTYNE "Оно выковано из мерзкого авантина Зизо"
#define HERESYDESC_ZIZO_ARTIFICE "Искусно созданный образец Зизо, воссозданный с пугающей точностью"
#define HERESYDESC_ZIZO_ARTIFICE_RECLAIMED "Загадочный дизайн из древних времен"

// Matthios items
#define HERESYDESC_MATTHIOS_WEAPON "Оружие алчных воинов Маттиоса"
#define HERESYDESC_MATTHIOS_ARMOR "Доспех алчных воинов Маттиоса"
#define HERESYDESC_MATTHIOS_RELIC "Реликвия алчного дизайна Маттиоса"
#define HERESYDESC_MATTHIOS_ICON "На нём изображён символ Маттиоса"
#define HERESYDESC_MATTHIOS_MISC "Известный образец Маттиоса"

// Graggar items
#define HERESYDESC_GRAGGAR_WEAPON "Оружие кровожадных воинов Граггара"
#define HERESYDESC_GRAGGAR_ARMOR "Зловещий доспех воинов Граггара"
#define HERESYDESC_GRAGGAR_RELIC "Реликвия жестокого замысла Граггара"
#define HERESYDESC_GRAGGAR_ICON "На нём изображён символ жестокого Граггара"
#define HERESYDESC_GRAGGAR_MISC "Известный образец, созданный Граггаром"

// Baotha items
#define HERESYDESC_BAOTHA_WEAPON "Оружие гнустных воинов Баоты"
#define HERESYDESC_BAOTHA_ARMOR "Доспех гнустных воинов Баоты"
#define HERESYDESC_BAOTHA_RELIC "Реликвия, созданная по развратным замыслам Баоты"
#define HERESYDESC_BAOTHA_ICON "На нём изображён символ развратной Баоты"
#define HERESYDESC_BAOTHA_MISC "Известный образец творчества Баоты"

// Abyssor dream items
#define HERESYDESC_DREAM_ITEM "A weapon from Abyssor's dream. It is dangerous, and shouldn't be seen outside of capable, sanctified hands"
// Dreamwalker items
#define HERESYDESC_DREAMWALKER_WEAPON "Оружие загадочного и жестокого культа Кошмара"
#define HERESYDESC_DREAMWALKER_ARMOR "Доспехи загадочного и жестокого культа Кошмара"

// Misc items
#define HERESYDESC_GRONN "Символ странных верований Севера"
#define HERESYDESC_WEEPING_CROSS "Он сделан из странного металла, который словно бы кровоточит"

// Vampire Lord Items - General theme is mysterious but a bad omen
#define HERESYDESC_VAMPIRE "An unnatural enchanted armor piece of solid gilbranze that crackles with strange energies"
#define HERESYDESC_VAMPIRE_CROWN "An unnatural enchanted crown that crackles with strange energies" 
#define HERESYDESC_VAMPIRE_SWORD "An unnatural sword of some unknown alloy that crackles with strange energies"

// Inquisitional gear
#define HERESYDESC_INQUIS_WHISPERER "A blatently unusual design of ring...? that seems to whisper" //Only shows while not equipped on ring slot
#define HERESYDESC_INQUIS_CHURNER "I CAN HEAR SCREAMS COMING FROM WITHIN, WHAT THE HELL IS THAT THING?!!" //Only shows while active

#define VIBEDESC_FRIEND "A loyal ally of Azure Peak."
#define VIBEDESC_FOE "A disloyal enemy of Azure Peak."
#define VIBEDESC_CROWN "A relic anointed by Astrata."
#define VIBEDESC_GOLGATHA "A relic of Psydon's creation."

/**
* -========= HERESY ITEM SEVERITY LEVELS =========-
*
* The more "Severely" heretical an item is, the more
* alarmingly the item will be presented on examine.
*
* -===============================================-*/
/** For items that are both blatantly heretical AND actively dangerous.
* Items should be marked with this if the expected response to seeing someone
* carrying them is to quickly escalate to violence.
* 
* i.e. heretic armor, avantyne weapons
*/
#define EXAMINEHIGHLIGHT_HERESYSEVERITY_ALARMING 1
/** For items that are heretical and will get you in trouble if you're caught with them,
* but not enough for people to jump straight to violence on sight without probable cause.
* 
* i.e. Ascendant amulets
*/
#define EXAMINEHIGHLIGHT_HERESYSEVERITY_SUSPICIOUS 2
/** For items that are unusual displays of faith that are either not commonly known expressions
* of heretical beliefs, or are simply inoffensive enough that the common Tennite / Psydonite probably won't
* get in someone's hair about it, but will likely give the wielders funny looks and odd squints.
*
* i.e. Gronn/Fjall carving amulets
*/
#define EXAMINEHIGHLIGHT_HERESYSEVERITY_ODD 3

#define EXAMINEHIGHLIGHT_VIBE_FRIEND 4
#define EXAMINEHIGHLIGHT_VIBE_FOE 5
#define EXAMINEHIGHLIGHT_VIBE_CROWN 6
#define EXAMINEHIGHLIGHT_VIBE_GOLGATHA 7

/** For items that are unnautral or clearly cursed, I.E ancient ceremonial armor, the vlord sword
* not defined enough that the average Tennite / Psydonite would always attack on sight but definitely it will
* get you probably taken captive/questioned by the Inqusition or pulled over by the Clergy/Garrison if you were just openly showing it.
*
* i.e. The Ichor Fang, Weeping Psycross, Blacksite Items like Listeners in their Obvious Form
*/
#define EXAMINEHIGHLIGHT_HERESYSEVERITY_VERYODD 8

// Heresy severity colors
#define COLOR_HERESYSEVERITY_ALARMING "#c43535"
#define COLOR_HERESYSEVERITY_SUSPICIOUS "#c49337"
#define COLOR_HERESYSEVERITY_ODD "#c564c5"
#define COLOR_HERESYSEVERITY_VERYODD "#c564c5"

//Other Colors
#define COLOR_VIBE_FRIEND "#6476c5"
#define COLOR_VIBE_FOE "#c43535"
#define COLOR_VIBE_CROWN "#ffdc7c"
#define COLOR_VIBE_GOLGATHA "#94f8ff"

// Heresy severity descriptions
#define EXAMINEHIGHLIGHT_TOOLTIP_HERESYSEVERITY_ALARMING "<font color=[COLOR_HERESYSEVERITY_ALARMING]><b>ЕРЕСЬ!</b></font><br>Этот зловещий дизайн используется еретиками, скрывающимися в темных уголках Гримории. Встреча с владельцем такого предмета не сулит ничего хорошего для последователей Десяти и Одного."
#define EXAMINEHIGHLIGHT_TOOLTIP_HERESYSEVERITY_SUSPICIOUS "<font color=[COLOR_HERESYSEVERITY_SUSPICIOUS]><b>Вероятно, еретический дизайн!</b></font><br>Такие предметы часто обнаруживаются у схваченных ересиархов, и, предположительно, являются символами их веры."
#define EXAMINEHIGHLIGHT_TOOLTIP_HERESYSEVERITY_ODD "<font color=[COLOR_HERESYSEVERITY_ODD]><b>Странное проявление веры... </b></font><br>Хоть этот предмет и не несет на себе явного символа еретической веры, он явно указывает на принадлежность к необычным, возможно, языческим верованиям. За владельцем такого предмета следует установить слежку."
#define EXAMINEHIGHLIGHT_TOOLTIP_HERESYSEVERITY_VERYODD "<font color=[COLOR_HERESYSEVERITY_ALARMING]><b>Вероятно, еретический дизайн!</b></font><br>Такие предметы часто обнаруживаются у схваченных ересиархов, и, предположительно, являются символами их веры."

#define EXAMINEHIGHLIGHT_TOOLTIP_VIBE_FRIEND "<font color=[COLOR_VIBE_FRIEND]><b>A loyal bearing.</b></font><br>This carries the look of one who stands with the Crown and its laws. Many subjects may view its bearer as a friend, servant, or ally of the realm."
#define EXAMINEHIGHLIGHT_TOOLTIP_VIBE_FOE "<font color=[COLOR_VIBE_FOE]><b>A disloyal bearing.</b></font><br>This carries the look of one who stands apart from the Crown and its laws. Many subjects may view its bearer with suspicion, seeing a potential rebel, outlaw, or enemy of the realm."
#define EXAMINEHIGHLIGHT_TOOLTIP_VIBE_CROWN "<font color=[COLOR_VIBE_CROWN]><b>Heavy the Crown is, and ever shall it be.</b></font><br>Such symbols are not lightly bestowed, for they signify authority exercised beneath Astrata's eternal light. This is a recognized mark of divine sovereignty, symbolizing the sacred right to rule granted by the Sun-Tyrant to a chosen bloodline. Most subjects should regard its bearer with reverence, recognizing a station and authority very few can claim."
#define EXAMINEHIGHLIGHT_TOOLTIP_VIBE_GOLGATHA "<font color=[COLOR_VIBE_GOLGATHA]><b>`Oh, how graceful His power was! And His sacrifice, ever so noble!`</b></font><br>It is said to contain a volatile fragment of the <font color=[COLOR_VIBE_GOLGATHA]><b>Comet Syon</b></font>, a sacred artifact to those of Psydonite Faith, such a relic is only entrusted within the capable hands of the Otavian Orthodoxy, Those who serve the Orthodoxy or others of Psydonite Faith are <b>very likely respond with violence</b> if I am not supposed to have it."

// Heresy severity symbols
#define EXAMINEHIGHLIGHT_SYMBOL_HERESYSEVERITY_SUSPICIOUS "!"
#define EXAMINEHIGHLIGHT_SYMBOL_HERESYSEVERITY_VERYODD "!"
/// Zcross unicode in HTML form
#define EXAMINEHIGHLIGHT_SYMBOL_HERESYSEVERITY_ALARMING "&#x16E3;"
#define EXAMINEHIGHLIGHT_SYMBOL_HERESYSEVERITY_ODD "?"

#define SYMBOL_VIBE_FRIEND "&#x26E8;"
#define SYMBOL_VIBE_FOE "&#x2694;"
#define SYMBOL_VIBE_CROWN "&#x2654;"
#define SYMBOL_VIBE_GOLGATHA "&#5833;"
