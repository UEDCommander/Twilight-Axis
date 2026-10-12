/datum/unit_test/bard_invitation_cleanup/Run()
	var/mob/living/carbon/human/leader = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/participant = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/unrelated = allocate(/mob/living/carbon/human)
	var/obj/item/rogue/instrument/lute/lead_instrument = allocate(/obj/item/rogue/instrument/lute)
	var/obj/item/rogue/instrument/lute/other_instrument = allocate(/obj/item/rogue/instrument/lute)
	var/datum/bard_band_member/member = new
	member.player = participant
	member.instrument = other_instrument
	lead_instrument.band_invite_active = TRUE
	lead_instrument.band_accepting = TRUE
	lead_instrument.band_invite_leader = leader
	lead_instrument.band_reserved_members = list(member)
	lead_instrument.band_reserved_instruments = list(other_instrument)
	leader.bard_band_owner = lead_instrument
	participant.bard_band_owner = lead_instrument
	other_instrument.band_owner = lead_instrument
	unrelated.bard_band_owner = other_instrument
	var/preload_channel = SSsounds.reserve_sound_channel(lead_instrument)
	lead_instrument.band_preloads["test"] = list("channel" = preload_channel, "listeners" = list())
	var/token = lead_instrument.band_invite_token
	lead_instrument.cancel_band_invite()
	TEST_ASSERT_NULL(leader.bard_band_owner, "Cancellation must release the leader")
	TEST_ASSERT_NULL(participant.bard_band_owner, "Cancellation must release unanswered invitations")
	TEST_ASSERT_NULL(other_instrument.band_owner, "Cancellation must release the reserved instrument")
	TEST_ASSERT_NULL(SSsounds.using_channels_by_datum[lead_instrument], "Cancellation must release preload channels")
	TEST_ASSERT_EQUAL(unrelated.bard_band_owner, other_instrument, "Cancellation must not touch another band")
	TEST_ASSERT(lead_instrument.band_invite_token != token, "Old dialog responses must be invalidated")
	unrelated.bard_band_owner = null
	qdel(member)

/datum/unit_test/bard_stop_actual_player/Run()
	var/mob/living/carbon/human/player = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/viewer = allocate(/mob/living/carbon/human)
	var/obj/item/rogue/instrument/lute/instrument = allocate(/obj/item/rogue/instrument/lute)
	instrument.current_player = player
	player.bard_music_playing = TRUE
	player.bard_auto_singing = TRUE
	viewer.bard_music_playing = TRUE
	instrument.stop_music(viewer)
	TEST_ASSERT(!player.bard_music_playing && !player.bard_auto_singing, "Stop must clear the actual performer")
	TEST_ASSERT(viewer.bard_music_playing, "Stop must not clear an unrelated viewer")
	viewer.bard_music_playing = FALSE
