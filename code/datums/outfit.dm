/**
  * # Outfit datums
  *
  * This is a clean system of applying outfits to mobs, if you need to equip someone in a uniform
  * this is the way to do it cleanly and properly.
  *
  * You can also specify an outfit datum on a job to have it auto equipped to the mob on join
  *
  * /mob/living/carbon/human/proc/equipOutfit(outfit) is the mob level proc to equip an outfit
  * and you pass it the relevant datum outfit
  *
  * outfits can also be saved as json blobs downloadable by a client and then can be uploaded
  * by that user to recreate the outfit, this is used by admins to allow for custom event outfits
  * that can be restored at a later date
  */
/datum/outfit
	///Name of the outfit (shows up in the equip admin verb)
	var/name = "Naked"

	/// Type path of item to go in uniform slot
	var/uniform = null

	/// Type path of item to go in suit slot
	var/suit = null

	/// Type path of item to go in back slot
	var/back = null

	/// Type path of item to go in belt slot
	var/belt = null

	/// Type path of item to go in gloves slot
	var/gloves = null

	/// Type path of item to go in shoes slot
	var/shoes = null

	/// Type path of item to go in head slot
	var/head = null

	/// Type path of item to go in mask slot
	var/mask = null

	/// Type path of item to go in neck slot
	var/neck = null

	/// Type path of item to go in ears slot
	var/ears = null

	/// Type path of item to go in the glasses slot
	var/glasses = null

	/// Type path of item to go in the idcard slot
	var/id = null

	/// Type path of item to go in the idcard slot
	var/wrists = null

	/// Type path of item for left pocket slot
	var/l_pocket = null

	/// Type path of item for right pocket slot
	var/r_pocket = null

	var/beltr = null

	var/beltl = null

	var/backr = null

	var/backl = null

	var/cloak = null

	var/shirt = null

	var/mouth = null

	var/pants = null

	var/armor = null

	/**
	  * Type path of item to go in suit storage slot
	  *
	  * (make sure it's valid for that suit)
	  */
	var/suit_store = null

	///Type path of item to go in the right hand
	var/r_hand = null

	//Type path of item to go in left hand
	var/l_hand = null

	/// Should the toggle helmet proc be called on the helmet during equip
	var/toggle_helmet = TRUE

	///ID of the slot containing a gas tank
	var/internals_slot = null

	/**
	  * list of items that should go in the backpack of the user
	  *
	  * Format of this list should be: list(path=count,otherpath=count)
	  */
	var/list/backpack_contents = null

	/// Internals box. Will be inserted at the start of backpack_contents
	var/box

	/**
	  * Any implants the mob should start implanted with
	  *
	  * Format of this list is (typepath, typepath, typepath)
	  */
	var/list/implants = null

  /// Any undershirt. While on humans it is a string, here we use paths to stay consistent with the rest of the equips.
	var/datum/sprite_accessory/undershirt = null

	/// Any clothing accessory item
	var/accessory = null

	/// Set to FALSE if your outfit requires runtime parameters
	var/can_be_admin_equipped = TRUE

	/**
	  * extra types for chameleon outfit changes, mostly guns
	  *
	  * Format of this list is (typepath, typepath, typepath)
	  *
	  * These are all added and returns in the list for get_chamelon_diguise_info proc
	  */
	var/list/chameleon_extras


/**
  * Called at the start of the equip proc
  *
  * Override to change the value of the slots depending on client prefs, species and
  * other such sources of change
  *
  * Extra Arguments
  * * visualsOnly true if this is only for display (in the character setup screen)
  *
  * If visualsOnly is true, you can omit any work that doesn't visually appear on the character sprite
  */
/datum/outfit/proc/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	//to be overridden for customization depending on client prefs,species etc
	return

/**
  * Called after the equip proc has finished
  *
  * All items are on the mob at this point, use this proc to toggle internals
  * fiddle with id bindings and accesses etc
  *
  * Extra Arguments
  * * visualsOnly true if this is only for display (in the character setup screen)
  *
  * If visualsOnly is true, you can omit any work that doesn't visually appear on the character sprite
  */
/datum/outfit/proc/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	//to be overridden for toggling internals, id binding, access etc
	return

/**
  * Equips all defined types and paths to the mob passed in
  *
  * Extra Arguments
  * * visualsOnly true if this is only for display (in the character setup screen)
  *
  * If visualsOnly is true, you can omit any work that doesn't visually appear on the character sprite
  */
/datum/outfit/proc/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	pre_equip(H, visualsOnly)

	//Start with uniform,suit,backpack for additional slots
	if(uniform)
		H.equip_to_slot_or_del(new pants(H),SLOT_PANTS, TRUE)
	if(suit)
		H.equip_to_slot_or_del(new suit(H),SLOT_ARMOR, TRUE)
	if(back)
		H.equip_to_slot_or_del(new back(H),SLOT_BACK, TRUE)
	if(belt)
		H.equip_to_slot_or_del(new belt(H),SLOT_BELT, TRUE)
	if(gloves)
		H.equip_to_slot_or_del(new gloves(H),SLOT_GLOVES, TRUE)
	if(shoes)
		H.equip_to_slot_or_del(new shoes(H),SLOT_SHOES, TRUE)
	if(head)
		H.equip_to_slot_or_del(new head(H),SLOT_HEAD, TRUE)
	if(mask)
		H.equip_to_slot_or_del(new mask(H),SLOT_WEAR_MASK, TRUE)
	if(neck)
		H.equip_to_slot_or_del(new neck(H),SLOT_NECK, TRUE)
	if(ears)
		H.equip_to_slot_or_del(new ears(H),SLOT_WEAR_MASK, TRUE)
	if(glasses)
		H.equip_to_slot_or_del(new glasses(H),SLOT_GLASSES, TRUE)
	if(id)
		H.equip_to_slot_or_del(new id(H),SLOT_RING, TRUE)
	if(wrists)
		H.equip_to_slot_or_del(new wrists(H),SLOT_WRISTS, TRUE)
	if(suit_store)
		H.equip_to_slot_or_del(new suit_store(H),SLOT_S_STORE, TRUE)
	if(cloak)
		H.equip_to_slot_or_del(new cloak(H),SLOT_CLOAK, TRUE)
	if(beltl)
		H.equip_to_slot_or_del(new beltl(H),SLOT_BELT_L, TRUE)
	if(beltr)
		H.equip_to_slot_or_del(new beltr(H),SLOT_BELT_R, TRUE)
	if(backr)
		H.equip_to_slot_or_del(new backr(H),SLOT_BACK_R, TRUE)
	if(backl)
		H.equip_to_slot_or_del(new backl(H),SLOT_BACK_L, TRUE)
	if(mouth)
		H.equip_to_slot_or_del(new mouth(H),SLOT_MOUTH, TRUE)
	if(pants)
		H.equip_to_slot_or_del(new pants(H),SLOT_PANTS, TRUE)
	if(armor)
		H.equip_to_slot_or_del(new armor(H),SLOT_ARMOR, TRUE)
	if(shirt)
		H.equip_to_slot_or_del(new shirt(H),SLOT_SHIRT, TRUE)
	if(accessory)
		var/obj/item/clothing/under/U = H.wear_pants
		if(U)
			U.attach_accessory(new accessory(H))
		else
			WARNING("Unable to equip accessory [accessory] in outfit [name]. No uniform present!")

	if(!visualsOnly)
		if(l_hand)
			H.put_in_hands(new l_hand(get_turf(H)), FALSE, forced = TRUE)
		if(r_hand)
			testing("PIH")
			H.put_in_hands(new r_hand(get_turf(H)), FALSE, forced = TRUE)

	if(!visualsOnly) // Items in pockets or backpack don't show up on mob's icon.
		if(l_pocket)
			H.equip_to_slot_or_del(new l_pocket(H),SLOT_L_STORE, TRUE)
		if(r_pocket)
			H.equip_to_slot_or_del(new r_pocket(H),SLOT_R_STORE, TRUE)

//		if(box)
//			if(!backpack_contents)
//				backpack_contents = list()
//			backpack_contents.Insert(1, box)
//			backpack_contents[box] = 1

		if(backpack_contents)
			for(var/path in backpack_contents)
				var/number = backpack_contents[path]
				if(!isnum(number))//Default to 1
					number = 1
				for(var/i in 1 to number)
					var/obj/item/new_item = new path(H)
					var/obj/item/item = H.get_item_by_slot(SLOT_BACK_L)
					if(!item)
						item = H.get_item_by_slot(SLOT_BACK_R)
					if(!item || !SEND_SIGNAL(item, COMSIG_TRY_STORAGE_INSERT, new_item, null, TRUE, TRUE))
						item = H.get_item_by_slot(SLOT_BACK_R)
						if(!item || !SEND_SIGNAL(item, COMSIG_TRY_STORAGE_INSERT, new_item, null, TRUE, TRUE))
							item = H.get_item_by_slot(SLOT_BELT)
							if(!item || !SEND_SIGNAL(item, COMSIG_TRY_STORAGE_INSERT, new_item, null, TRUE, TRUE))
								addtimer(CALLBACK(PROC_REF(move_storage), new_item, H.loc), 3 SECONDS)

	post_equip(H, visualsOnly)

	if(!visualsOnly)
		apply_fingerprints(H)

	H.update_body()
	return TRUE

/datum/outfit/proc/move_storage(obj/item/new_item, turf/T)
	if(new_item.forceMove(T))
		return TRUE
	return FALSE

/client/proc/test_spawn_outfits()
	for(var/path in subtypesof(/datum/outfit/job/roguetown))
		var/mob/living/carbon/human/new_human = new(mob.loc)
		var/datum/outfit/new_outfit = new path()
		new_outfit.equip(new_human)
/**
  * Apply a fingerprint from the passed in human to all items in the outfit
  *
  * Used for forensics setup when the mob is first equipped at roundstart
  * essentially calls add_fingerprint to every defined item on the human
  *
  */
/datum/outfit/proc/apply_fingerprints(mob/living/carbon/human/H)
	if(!istype(H))
		return
	if(H.back)
		H.back.add_fingerprint(H,1)	//The 1 sets a flag to ignore gloves
		for(var/obj/item/I in H.back.contents)
			I.add_fingerprint(H,1)
	if(H.wear_ring)
		H.wear_ring.add_fingerprint(H,1)
	if(H.wear_pants)
		H.wear_pants.add_fingerprint(H,1)
	if(H.wear_armor)
		H.wear_armor.add_fingerprint(H,1)
	if(H.wear_mask)
		H.wear_mask.add_fingerprint(H,1)
	if(H.wear_neck)
		H.wear_neck.add_fingerprint(H,1)
	if(H.head)
		H.head.add_fingerprint(H,1)
	if(H.shoes)
		H.shoes.add_fingerprint(H,1)
	if(H.gloves)
		H.gloves.add_fingerprint(H,1)
	if(H.ears)
		H.ears.add_fingerprint(H,1)
	if(H.glasses)
		H.glasses.add_fingerprint(H,1)
	if(H.belt)
		H.belt.add_fingerprint(H,1)
		for(var/obj/item/I in H.belt.contents)
			I.add_fingerprint(H,1)
	if(H.s_store)
		H.s_store.add_fingerprint(H,1)
	if(H.l_store)
		H.l_store.add_fingerprint(H,1)
	if(H.r_store)
		H.r_store.add_fingerprint(H,1)
	for(var/obj/item/I in H.held_items)
		I.add_fingerprint(H,1)
	return 1

/// Return a list of all the types that are required to disguise as this outfit type
/datum/outfit/proc/get_chameleon_disguise_info()
	var/list/types = list(uniform, suit, back, belt, gloves, shoes, head, mask, neck, ears, glasses, id, l_pocket, r_pocket, suit_store, r_hand, l_hand)
	types += chameleon_extras
	listclearnulls(types)
	return types

/// Return a json list of this outfit
/datum/outfit/proc/get_json_data()
	. = list()
	.["outfit_type"] = type
	.["name"] = name
	.["uniform"] = uniform
	.["suit"] = suit
	.["toggle_helmet"] = toggle_helmet
	.["back"] = back
	.["belt"] = belt
	.["gloves"] = gloves
	.["shoes"] = shoes
	.["head"] = head
	.["mask"] = mask
	.["neck"] = neck
	.["ears"] = ears
	.["glasses"] = glasses
	.["id"] = id
	.["l_pocket"] = l_pocket
	.["r_pocket"] = r_pocket
	.["suit_store"] = suit_store
	.["r_hand"] = r_hand
	.["l_hand"] = l_hand
	.["internals_slot"] = internals_slot
	.["backpack_contents"] = backpack_contents
	.["box"] = box
	.["implants"] = implants
	.["accessory"] = accessory

/// Prompt the passed in mob client to download this outfit as a json blob
/datum/outfit/proc/save_to_file(mob/admin)
	var/stored_data = get_json_data()
	var/json = json_encode(stored_data)
	//Kinda annoying but as far as i can tell you need to make actual file.
	var/f = file("data/TempOutfitUpload")
	fdel(f)
	WRITE_FILE(f,json)
	admin << ftp(f,"[name].json")

/// Create an outfit datum from a list of json data
/datum/outfit/proc/load_from(list/outfit_data)
	//This could probably use more strict validation
	name = outfit_data["name"]
	uniform = text2path(outfit_data["uniform"])
	suit = text2path(outfit_data["suit"])
	toggle_helmet = outfit_data["toggle_helmet"]
	back = text2path(outfit_data["back"])
	belt = text2path(outfit_data["belt"])
	gloves = text2path(outfit_data["gloves"])
	shoes = text2path(outfit_data["shoes"])
	head = text2path(outfit_data["head"])
	mask = text2path(outfit_data["mask"])
	neck = text2path(outfit_data["neck"])
	ears = text2path(outfit_data["ears"])
	glasses = text2path(outfit_data["glasses"])
	id = text2path(outfit_data["id"])
	l_pocket = text2path(outfit_data["l_pocket"])
	r_pocket = text2path(outfit_data["r_pocket"])
	suit_store = text2path(outfit_data["suit_store"])
	r_hand = text2path(outfit_data["r_hand"])
	l_hand = text2path(outfit_data["l_hand"])
	internals_slot = outfit_data["internals_slot"]
	var/list/backpack = outfit_data["backpack_contents"]
	backpack_contents = list()
	for(var/item in backpack)
		var/itype = text2path(item)
		if(itype)
			backpack_contents[itype] = backpack[item]
	box = text2path(outfit_data["box"])
	var/list/impl = outfit_data["implants"]
	implants = list()
	for(var/I in impl)
		var/imptype = text2path(I)
		if(imptype)
			implants += imptype
	accessory = text2path(outfit_data["accessory"])
	return TRUE
