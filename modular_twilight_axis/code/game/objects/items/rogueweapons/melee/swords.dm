/obj/item/rogueweapon/sword/rapier/psyrapier
	name = "psydonian rapier"
	desc = "An ornate rapier, plated in a ceremonial veneer of silver. The barbs pierce your palm, and - for just a moment - you see red. Never forget that you are why Psydon wept."
	icon = 'modular_axis/icons/roguetown/weapons/64.dmi'
	icon_state = "psyrapier"
	item_state = "psyrapier"
	resistance_flags = FIRE_PROOF

/obj/item/rogueweapon/sword/rapier/psyrapier/ComponentInitialize()
	. = ..()								//+3 force, +50 blade int, +50 int, +1 def, make silver
	AddComponent(/datum/component/psyblessed, FALSE, 3, 50, 50, 1, TRUE)
