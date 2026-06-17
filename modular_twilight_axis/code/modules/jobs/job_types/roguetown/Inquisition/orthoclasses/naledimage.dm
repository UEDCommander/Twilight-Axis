/datum/advclass/naledimage
	name = "Warscholar"
	tutorial = "A devotee of Naledi, Psydonite mage, tempered in both scripture and spell. From youth you were taught that the Arcyne is not merely a tool, but a covenant - a force to be shaped with discipline and purpose. \
	Where others see raw power, you see design. Where chaos takes form, you impose will. \
	Through flame, through force, through unseen currents of mana — Psydon's enemies shall be unmade. \
	His will be done."
	allowed_sexes = list(MALE, FEMALE)
	outfit = /datum/outfit/job/roguetown/naledimage
	subclass_languages = list(/datum/language/otavan, /datum/language/raneshi)
	cmode_music = 'sound/music/warscholar.ogg'
	category_tags = list(CTAG_ORTHODOXIST)
	traits_applied = list(
		TRAIT_PSYDONITE,
		TRAIT_ARCYNE,
		TRAIT_NALEDI,
		TRAIT_ALCHEMY_EXPERT,
	)
	subclass_stats = list(
		STATKEY_INT = 4,
		STATKEY_WIL = 2,
		STATKEY_SPD = 1,
		STATKEY_PER = 1,
		STATKEY_CON = 1,
		STATKEY_STR = -1,
	)
	age_mod = /datum/class_age_mod/war_scholar
	subclass_mage_aspects = list("mastery" = FALSE, "major" = 1, "minor" = 2, "utilities" = 6, "post_aspect_spells" = list(/datum/action/cooldown/spell/mindlink, /datum/action/cooldown/spell/mending), "ward" = TRUE)
	subclass_skills = list(
		/datum/skill/combat/staves = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/polearms = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/knives = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/swimming = SKILL_LEVEL_NOVICE,
		/datum/skill/misc/climbing = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/athletics = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/craft/crafting = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/medicine = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/reading = SKILL_LEVEL_EXPERT,
		/datum/skill/craft/alchemy = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/magic/arcane = SKILL_LEVEL_EXPERT,
		/datum/skill/craft/sewing = SKILL_LEVEL_APPRENTICE,
	)
	subclass_stashed_items = list(
		"Tome of Psydon" = /obj/item/book/rogue/bibble/psy,
		"Psydon Gift" = /obj/item/hourglass/temporal
	)

	extra_context = "As one of the best magicians, you managed to take your favorite watch with you."

/datum/outfit/job/roguetown/naledimage
	job_bitflag = BITFLAG_HOLY_WARRIOR

/datum/outfit/job/roguetown/naledimage/pre_equip(mob/living/carbon/human/H, visualsOnly)
	..()
	r_hand = /obj/item/rogueweapon/woodstaff/implement/grand/naledi
	head = /obj/item/clothing/head/roguetown/roguehood/psydon
	gloves = /obj/item/clothing/gloves/roguetown/otavan/psygloves
	cloak = /obj/item/clothing/cloak/tabard/psydontabard
	armor = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/hierophant/warscholar
	shirt = /obj/item/clothing/suit/roguetown/shirt/robe/hierophant/warscholar
	pants = /obj/item/clothing/under/roguetown/heavy_leather_pants
	mask = /obj/item/clothing/mask/rogue/lordmask/naledi
	wrists = /obj/item/clothing/neck/roguetown/psicross/g
	belt = /obj/item/storage/belt/rogue/leather/black
	beltl = /obj/item/storage/belt/rogue/pouch/coins/mid
	shoes = /obj/item/clothing/shoes/roguetown/boots/psydonboots
	backr = /obj/item/storage/backpack/rogue/satchel/black
	var/naledi_book = pick(/obj/item/book/rogue/naledi1, /obj/item/book/rogue/naledi2, /obj/item/book/rogue/naledi3, /obj/item/book/rogue/naledi4)
	id = /obj/item/clothing/ring/signet/psy/g
	backl = /obj/item/rogueweapon/woodstaff/implement/grand/naledi
	backpack_contents = list(
		/obj/item/roguekey/inquisitionmanor,
		/obj/item/paper/inqslip/arrival/ortho,
		/obj/item/book/spellbook,
		(naledi_book) = 1
	)

/obj/item/clothing/suit/roguetown/shirt/robe/hierophant/warscholar
	name = "warscholar's kandys"
	desc = "A thin piece of fabric worn under a robe to stop chafing and keep ones dignity if a harsh blow of wind comes through. Despite the light fabric, it offers decent protection."
	icon = 'modular_twilight_axis/icons/roguetown/clothing/armor.dmi'
	mob_overlay_icon = 'modular_twilight_axis/icons/roguetown/clothing/onmob/armor.dmi'
	icon_state = "psydongown"
	item_state = "psydongown"

/obj/item/clothing/suit/roguetown/armor/gambeson/heavy/hierophant/warscholar
	name = "warscholar's shawl"
	desc = "Thick and protective while remaining light and breezy; the perfect garb for protecting one from the hot sun and the harsh sands of Naledi."
	color = "#48443b"