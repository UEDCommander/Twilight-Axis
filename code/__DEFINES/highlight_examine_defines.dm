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

// Dreamwalker items
#define HERESYDESC_DREAMWALKER_WEAPON "Оружие загадочного и жестокого культа Кошмара"
#define HERESYDESC_DREAMWALKER_ARMOR "Доспехи загадочного и жестокого культа Кошмара"

// Misc items
#define HERESYDESC_GRONN "Символ странных верований Севера"


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

// Heresy severity colors
#define COLOR_HERESYSEVERITY_ALARMING "#c43535"
#define COLOR_HERESYSEVERITY_SUSPICIOUS "#c49337"
#define COLOR_HERESYSEVERITY_ODD "#c564c5"

// Heresy severity descriptions
#define EXAMINEHIGHLIGHT_TOOLTIP_HERESYSEVERITY_ALARMING "<font color=[COLOR_HERESYSEVERITY_ALARMING]><b>ЕРЕСЬ!</b></font><br>Этот зловещий дизайн используется еретиками, скрывающимися в темных уголках Гримории. Встреча с владельцем такого предмета не сулит ничего хорошего для последователей Десяти и Одного."
#define EXAMINEHIGHLIGHT_TOOLTIP_HERESYSEVERITY_SUSPICIOUS "<font color=[COLOR_HERESYSEVERITY_SUSPICIOUS]><b>Вероятно, еретический дизайн!</b></font><br>Такие предметы часто обнаруживаются у схваченных ересиархов, и, предположительно, являются символами их веры."
#define EXAMINEHIGHLIGHT_TOOLTIP_HERESYSEVERITY_ODD "<font color=[COLOR_HERESYSEVERITY_ODD]><b>Странное проявление веры... </b></font><br>Хоть этот предмет и не несет на себе явного символа еретической веры, он явно указывает на принадлежность к необычным, возможно, языческим верованиям. За владельцем такого предмета следует установить слежку."

// Heresy severity symbols
#define EXAMINEHIGHLIGHT_SYMBOL_HERESYSEVERITY_SUSPICIOUS "!"
/// Zcross unicode in HTML form
#define EXAMINEHIGHLIGHT_SYMBOL_HERESYSEVERITY_ALARMING "&#x16E3;"
#define EXAMINEHIGHLIGHT_SYMBOL_HERESYSEVERITY_ODD "?"
