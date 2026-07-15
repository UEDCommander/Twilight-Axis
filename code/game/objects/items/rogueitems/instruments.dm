/datum/looping_sound/instrument
	mid_length = 2400 // 4 minutes for some reason. better would be each song having a specific length
	volume = 100
	extra_range = 5
	persistent_loop = TRUE
	var/stress2give = /datum/stressevent/music
	sound_group = /datum/sound_group/instruments //reserves sound channels for up to 10 instruments at a time
	filter_pref = SOUND_INSTRUMENTS

#define BARD_TRACK_MAX_LYRICS 6000
#define BARD_TRACK_MAX_PHRASES 200
#define BARD_TRACK_DEFAULT_LOOP_TICKS 2400
#define BARD_TRACK_DEFAULT_DURATION_SECONDS 240
#define BARD_TRACK_DEFAULT_SPACING_SECONDS 2

/datum/bard_timed_phrase
	var/time = 0
	var/text = ""

/datum/bard_timed_phrase/proc/export_data()
	return list("time" = time, "text" = text)

/mob/living
	var/tmp/bard_music_playing = FALSE
	var/tmp/bard_auto_singing = FALSE
	var/tmp/bard_auto_song_token = 0

/mob/living/proc/is_blocked_by_music_consumption()
	return bard_music_playing || has_status_effect(/datum/status_effect/buff/playing_music)

/mob/living/proc/is_blocked_by_auto_song()
	return bard_auto_singing

/datum/bard_timed_track
	var/title = ""
	var/file_path = null
	var/duration_seconds = 0
	var/lyrics = ""
	var/custom = FALSE
	var/analyzed_duration = FALSE
	var/phrase_spacing_seconds = BARD_TRACK_DEFAULT_SPACING_SECONDS
	var/list/phrases = list()

/datum/bard_timed_track/proc/set_song(song_title, song_file, custom_track = FALSE)
	title = song_title
	file_path = song_file
	duration_seconds = bard_track_file_duration_seconds(song_file)
	analyzed_duration = (duration_seconds != BARD_TRACK_DEFAULT_DURATION_SECONDS)
	custom = custom_track

/datum/bard_timed_track/proc/rebuild_from_lyrics(raw_lyrics)
	lyrics = copytext(raw_lyrics ? raw_lyrics : "", 1, BARD_TRACK_MAX_LYRICS)
	phrases = bard_track_build_phrases(lyrics, phrase_spacing_seconds)

/datum/bard_timed_track/proc/set_spacing(new_spacing)
	phrase_spacing_seconds = clamp(round(text2num("[new_spacing]"), 0.1), 0.1, 120)
	rebuild_from_lyrics(lyrics)

/datum/bard_timed_track/proc/set_phrase_time(index, new_time)
	index = round(text2num("[index]"))
	if(index < 1 || index > phrases.len)
		return FALSE
	var/datum/bard_timed_phrase/base_phrase = phrases[index]
	var/old_time = base_phrase.time
	var/target_time = max(round(text2num("[new_time]"), 0.1), 0)
	var/delta = target_time - old_time
	for(var/i in index to phrases.len)
		var/datum/bard_timed_phrase/phrase = phrases[i]
		phrase.time = max(round(phrase.time + delta, 0.1), 0)
	return TRUE

/datum/bard_timed_track/proc/set_phrase_text(index, new_text)
	index = round(text2num("[index]"))
	if(index < 1 || index > phrases.len)
		return FALSE
	var/datum/bard_timed_phrase/phrase = phrases[index]
	phrase.text = trimtext(copytext("[new_text]", 1, MAX_MESSAGE_LEN))
	return TRUE

/datum/bard_timed_track/proc/export_data()
	var/list/out_phrases = list()
	for(var/datum/bard_timed_phrase/phrase as anything in phrases)
		out_phrases += list(phrase.export_data())
	return list(
		"title" = title,
		"file" = "[file_path]",
		"duration_seconds" = duration_seconds,
		"spacing_seconds" = phrase_spacing_seconds,
		"phrases" = out_phrases
	)

/datum/bard_timed_track/proc/export_json()
	return json_encode(export_data())

/datum/bard_timed_track/proc/import_json(raw_json)
	var/list/data = safe_json_decode(raw_json)
	if(!islist(data))
		return FALSE
	var/list/imported_phrases = data["phrases"]
	if(!islist(imported_phrases))
		return FALSE
	if(data["spacing_seconds"])
		phrase_spacing_seconds = clamp(round(text2num("[data["spacing_seconds"]]"), 0.1), 0.1, 120)
	phrases = list()
	for(var/list/entry as anything in imported_phrases)
		if(!islist(entry))
			continue
		var/text = trimtext("[entry["text"]]")
		if(!text)
			continue
		var/datum/bard_timed_phrase/phrase = new
		phrase.time = max(text2num("[entry["time"]]"), 0)
		phrase.text = text
		phrases += phrase
		if(phrases.len >= BARD_TRACK_MAX_PHRASES)
			break
	return TRUE

/proc/bard_track_file_duration_seconds(song_file)
	. = BARD_TRACK_DEFAULT_DURATION_SECONDS
	if(!song_file)
		return
	var/length_ticks = rustg_sound_length("[song_file]")
	if(length_ticks)
		. = max(round(length_ticks / 10), 1)

/proc/bard_track_format_duration(total_seconds)
	total_seconds = max(round(text2num("[total_seconds]")), 0)
	var/minutes = round(total_seconds / 60)
	var/seconds = total_seconds % 60
	return "[minutes]:[seconds < 10 ? "0[seconds]" : seconds]"

/proc/bard_track_strip_tags(raw_text)
	var/static/regex/tag_regex = regex(@"\[[^\]]*\]", "g")
	return trimtext(tag_regex.Replace(raw_text ? raw_text : "", ""))

/proc/bard_track_build_phrases(raw_lyrics, spacing_seconds)
	var/list/out = list()
	var/clean = bard_track_strip_tags(raw_lyrics)
	clean = replacetext(clean, ascii2text(13), "")
	clean = replacetext(clean, "\t", " ")
	var/list/source_lines = splittext(clean, "\n")
	var/list/final_lines = list()

	for(var/line in source_lines)
		var/trimmed = trimtext(line)
		if(!trimmed)
			continue
		final_lines += trimmed

	if(!final_lines.len && clean)
		var/list/words = splittext(clean, " ")
		var/list/chunk = list()
		for(var/word in words)
			var/trimmed_word = trimtext(word)
			if(!trimmed_word)
				continue
			chunk += trimmed_word
			if(chunk.len >= 8)
				final_lines += jointext(chunk, " ")
				chunk = list()
		if(chunk.len)
			final_lines += jointext(chunk, " ")

	if(final_lines.len > BARD_TRACK_MAX_PHRASES)
		final_lines.Cut(BARD_TRACK_MAX_PHRASES + 1)

	if(!final_lines.len)
		return out

	var/step = max(spacing_seconds, 0.1)
	for(var/i in 1 to final_lines.len)
		var/datum/bard_timed_phrase/phrase = new
		phrase.time = round((i - 1) * step, 0.1)
		phrase.text = final_lines[i]
		out += phrase

	return out

/obj/item/rogue/instrument
	name = ""
	desc = ""
	icon = 'icons/roguetown/items/music.dmi'
	icon_state = ""
	slot_flags = ITEM_SLOT_HIP|ITEM_SLOT_BACK_R|ITEM_SLOT_BACK_L
	can_parry = TRUE
	force = 23
	throwforce = 7
	throw_range = 4
	var/lastfilechange = 0
	var/curvol = 100
	var/datum/looping_sound/instrument/soundloop
	var/list/song_list = list()
	var/note_color = "#7f7f7f"
	var/groupplaying = FALSE
	var/curfile = ""
	var/playing = FALSE
	var/repeat_enabled = FALSE
	var/mob/living/current_player = null
	var/auto_singing_title = null
	var/list/timed_tracks = list()
	var/music_panel_selected = null
	grid_height = 64
	grid_width = 32

/obj/item/rogue/instrument/equipped(mob/living/user, slot)
	. = ..()
	if(playing && user.get_active_held_item() != src)
		stop_music(user)

/obj/item/rogue/instrument/getonmobprop(tag)
	. = ..()
	if(tag)
		switch(tag)
			if("gen")
				return list("shrink" = 0.4,"sx" = 0,"sy" = 2,"nx" = 1,"ny" = -4,"wx" = -1,"wy" = 2,"ex" = 7,"ey" = 1,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0,"nturn" = 0,"sturn" = 0,"wturn" = -2,"eturn" = -2,"nflip" = 8,"sflip" = 8,"wflip" = 8,"eflip" = 0)
			if("onbelt")
				return list("shrink" = 0.3,"sx" = -2,"sy" = -5,"nx" = 4,"ny" = -5,"wx" = 0,"wy" = -5,"ex" = 2,"ey" = -5,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 0,"sflip" = 0,"wflip" = 0,"eflip" = 0,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0)

/obj/item/rogue/instrument/Initialize()
	soundloop = new(src, FALSE)
	ensure_timed_tracks()
	. = ..()

/obj/item/rogue/instrument/Destroy()
	qdel(soundloop)
	. = ..()

/obj/item/rogue/instrument/dropped(mob/living/user, silent)
	..()
	stop_music(user)

/obj/item/rogue/instrument/proc/check_file(infile, filename, user)
	var/file_ext = lowertext(copytext(filename, -4))
	var/file_size = length(infile)

	if(file_ext != ".ogg")
		return "SONG MUST BE AN OGG."
	if(file_size > 4 * 1024 * 1024)
		return "TOO BIG. 4 MEGS OR LESS."

	message_admins("[ADMIN_LOOKUPFLW(user)] uploaded a song [filename] of size [file_size / 1000000] (~MB).")
	return null

/obj/item/rogue/instrument/proc/ensure_timed_tracks()
	if(!timed_tracks)
		timed_tracks = list()
	for(var/song_title in song_list)
		if(timed_tracks[song_title])
			continue
		var/datum/bard_timed_track/track = new
		track.set_song(song_title, song_list[song_title])
		timed_tracks[song_title] = track
	if(!music_panel_selected && song_list.len)
		for(var/song_title in song_list)
			music_panel_selected = song_title
			break

/obj/item/rogue/instrument/proc/get_selected_track()
	ensure_timed_tracks()
	if(!music_panel_selected || !timed_tracks[music_panel_selected])
		if(song_list.len)
			for(var/song_title in song_list)
				music_panel_selected = song_title
				break
	return timed_tracks[music_panel_selected]

/obj/item/rogue/instrument/proc/music_skill_event(mob/living/user)
	var/stressevent = /datum/stressevent/music
	note_color = "#7f7f7f"
	if(user?.mind)
		switch(user.get_skill_level(/datum/skill/misc/music))
			if(1)
				stressevent = /datum/stressevent/music
			if(2)
				note_color = "#ffffff"
				stressevent = /datum/stressevent/music/two
			if(3)
				note_color = "#1eff00"
				stressevent = /datum/stressevent/music/three
			if(4)
				note_color = "#0070dd"
				stressevent = /datum/stressevent/music/four
			if(5)
				note_color = "#a335ee"
				stressevent = /datum/stressevent/music/five
			if(6)
				note_color = "#ff8000"
				stressevent = /datum/stressevent/music/six
	soundloop.stress2give = stressevent
	return stressevent

/obj/item/rogue/instrument/proc/stop_music(mob/living/user)
	playing = FALSE
	groupplaying = FALSE
	if(soundloop)
		soundloop.stop()
	var/mob/living/player = user || current_player
	if(player)
		player.bard_music_playing = FALSE
		player.bard_auto_singing = FALSE
		player.bard_auto_song_token++
		player.remove_status_effect(/datum/status_effect/buff/playing_music)
	current_player = null
	auto_singing_title = null

/obj/item/rogue/instrument/proc/play_track(mob/living/user, datum/bard_timed_track/track)
	if(!user || !track || playing || !(src in user.held_items) || user.get_inactive_held_item())
		return
	var/stressevent = music_skill_event(user)
	curfile = track.file_path
	if(!curfile)
		stop_music(user)
		return
	playing = TRUE
	soundloop.set_mid_sounds(list(curfile))
	soundloop.mid_length = max(track.duration_seconds * 10, 1)
	soundloop.start()
	user.apply_status_effect(/datum/status_effect/buff/playing_music, stressevent, note_color)
	user.bard_music_playing = TRUE
	current_player = user
	record_round_statistic(STATS_SONGS_PLAYED)

/obj/item/rogue/instrument/proc/start_auto_song(mob/living/user, datum/bard_timed_track/track)
	if(!track || !track.custom)
		return
	if(!playing)
		play_track(user, track)
	if(!playing || !track.phrases.len)
		return
	user.bard_auto_singing = TRUE
	user.bard_auto_song_token++
	auto_singing_title = track.title
	var/token = user.bard_auto_song_token
	INVOKE_ASYNC(src, PROC_REF(auto_song_loop), user, track, token)

/obj/item/rogue/instrument/proc/stop_auto_song(mob/living/user)
	if(user)
		user.bard_auto_singing = FALSE
		user.bard_auto_song_token++
	auto_singing_title = null

/obj/item/rogue/instrument/proc/auto_song_loop(mob/living/user, datum/bard_timed_track/track, token)
	set waitfor = FALSE
	while(playing && current_player == user && user?.bard_auto_singing && user.bard_auto_song_token == token && track?.phrases?.len)
		var/last_time = 0
		for(var/datum/bard_timed_phrase/phrase as anything in track.phrases)
			if(!playing || current_player != user || !user.bard_auto_singing || user.bard_auto_song_token != token)
				return
			var/delay = max(round((phrase.time - last_time) * 10), 0)
			if(delay)
				sleep(delay)
			if(!playing || current_player != user || !user.bard_auto_singing || user.bard_auto_song_token != token)
				return
			if(phrase.text)
				user.say(phrase.text, forced = "bard auto song")
			last_time = phrase.time
		if(!repeat_enabled)
			stop_auto_song(user)
			return
		var/remainder = max(round((track.duration_seconds - last_time) * 10), 0)
		if(remainder)
			sleep(remainder)

/obj/item/rogue/instrument/ui_state(mob/user)
	return GLOB.hold_or_view_state

/obj/item/rogue/instrument/ui_interact(mob/user, datum/tgui/ui)
	ensure_timed_tracks()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BardMusicLibrary", "Music")
		ui.open()

/obj/item/rogue/instrument/ui_data(mob/user)
	ensure_timed_tracks()
	var/datum/bard_timed_track/selected = get_selected_track()
	var/list/tracks = list()
	for(var/song_title in song_list)
		var/datum/bard_timed_track/track = timed_tracks[song_title]
		tracks += list(list(
			"title" = song_title,
			"selected" = (song_title == music_panel_selected),
			"duration_seconds" = track?.duration_seconds || 0,
			"duration_label" = bard_track_format_duration(track?.duration_seconds || 0),
			"phrase_count" = track?.phrases?.len || 0,
			"custom" = track?.custom || FALSE,
			"analyzed_duration" = track?.analyzed_duration || FALSE
		))

	var/list/selected_data = null
	if(selected)
		var/list/phrase_data = list()
		for(var/datum/bard_timed_phrase/phrase as anything in selected.phrases)
			phrase_data += list(list("time" = phrase.time, "text" = phrase.text))
		selected_data = list(
			"title" = selected.title,
			"custom" = selected.custom,
			"duration_seconds" = selected.duration_seconds,
			"duration_label" = bard_track_format_duration(selected.duration_seconds),
			"analyzed_duration" = selected.analyzed_duration,
			"spacing_seconds" = selected.phrase_spacing_seconds,
			"lyrics" = selected.lyrics,
			"json" = selected.export_json(),
			"phrases" = phrase_data
		)

	return list(
		"tracks" = tracks,
		"selected" = selected_data,
		"is_expert" = user?.mind && user.get_skill_level(/datum/skill/misc/music) >= SKILL_LEVEL_EXPERT,
		"playing" = playing
		,"repeat_enabled" = repeat_enabled
		,"auto_singing_title" = auto_singing_title
	)

/obj/item/rogue/instrument/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(!usr || !usr.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return FALSE
	var/mob/living/user = usr
	add_fingerprint(user)
	ensure_timed_tracks()

	switch(action)
		if("select")
			var/song_title = params["title"]
			if(song_list[song_title])
				music_panel_selected = song_title
			return TRUE
		if("set_lyrics")
			var/datum/bard_timed_track/track = get_selected_track()
			if(track?.custom)
				if(params["spacing"])
					track.phrase_spacing_seconds = clamp(round(text2num("[params["spacing"]]"), 0.1), 0.1, 120)
				track.rebuild_from_lyrics(params["lyrics"])
			return TRUE
		if("set_spacing")
			var/datum/bard_timed_track/track = get_selected_track()
			if(track?.custom)
				track.set_spacing(params["spacing"])
			return TRUE
		if("set_phrase_time")
			var/datum/bard_timed_track/track = get_selected_track()
			if(track?.custom)
				track.set_phrase_time(params["index"], params["time"])
			return TRUE
		if("set_phrase_text")
			var/datum/bard_timed_track/track = get_selected_track()
			if(track?.custom)
				track.set_phrase_text(params["index"], params["text"])
			return TRUE
		if("clear_lyrics")
			var/datum/bard_timed_track/track = get_selected_track()
			if(track?.custom)
				track.rebuild_from_lyrics("")
			return TRUE
		if("import_json")
			var/datum/bard_timed_track/track = get_selected_track()
			if(track?.custom && !track.import_json(params["json"]))
				to_chat(user, span_warning("Invalid track JSON."))
			return TRUE
		if("upload")
			if(!(user.mind && user.get_skill_level(/datum/skill/misc/music) >= SKILL_LEVEL_EXPERT))
				to_chat(user, span_warning("You need expert music skill to add tracks."))
				return TRUE
			if(lastfilechange && world.time < lastfilechange + 3 MINUTES)
				to_chat(user, span_warning("NOT YET!"))
				return TRUE
			playsound(loc, 'sound/misc/beep.ogg', 100, FALSE, -1)
			var/infile = input(user, "CHOOSE A NEW SONG", src) as null|file
			if(!infile || !user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
				return TRUE
			var/filename = "[infile]"
			var/file_error = check_file(infile, filename, user)
			if(file_error)
				to_chat(user, span_warning(file_error))
				return TRUE
			lastfilechange = world.time
			fcopy(infile, "data/jukeboxuploads/[user.ckey]/[filename]")
			var/song_file = file("data/jukeboxuploads/[user.ckey]/[filename]")
			var/songname = input(user, "Name your song:", "Song Name") as text|null
			if(!songname || !user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
				return TRUE
			songname = trimtext(songname)
			if(!songname)
				return TRUE
			song_list[songname] = song_file
			var/datum/bard_timed_track/new_track = new
			new_track.set_song(songname, song_file, TRUE)
			if(params["spacing"])
				new_track.phrase_spacing_seconds = clamp(round(text2num("[params["spacing"]]"), 0.1), 0.1, 120)
			new_track.rebuild_from_lyrics(params["lyrics"])
			timed_tracks[songname] = new_track
			music_panel_selected = songname
			return TRUE
		if("play")
			if(playing)
				stop_music(user)
			else
				play_track(user, get_selected_track())
			return TRUE
		if("toggle_repeat")
			repeat_enabled = !repeat_enabled
			return TRUE
		if("sing_track")
			var/song_title = params["title"]
			if(song_list[song_title])
				music_panel_selected = song_title
			var/datum/bard_timed_track/track = get_selected_track()
			if(track?.custom)
				if(user.bard_auto_singing && auto_singing_title == track.title)
					stop_auto_song(user)
					return TRUE
				if(playing && curfile != track.file_path)
					stop_music(user)
				start_auto_song(user, track)
			return TRUE
	return FALSE

/obj/item/rogue/instrument/attack_self(mob/living/user)
	. = ..()
	if(.)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	if(playing)
		stop_music(user)
		return
	ui_interact(user)

/obj/item/rogue/instrument/lute
	name = "lute"
	desc = "Its graceful curves were designed to weave joyful melodies."
	icon_state = "lute"
	song_list = list("A Knight's Return" = 'sound/music/instruments/lute (1).ogg',
	"Amongst Fare Friends" = 'sound/music/instruments/lute (2).ogg',
	"The Road Traveled by Few" = 'sound/music/instruments/lute (3).ogg',
	"Tip Thine Tankard" = 'sound/music/instruments/lute (4).ogg',
	"A Reed On the Wind" = 'sound/music/instruments/lute (5).ogg',
	"Jests On Steel Ears" = 'sound/music/instruments/lute (6).ogg',
	"Merchant in the Mire" = 'sound/music/instruments/lute (7).ogg',
	"The Power" = 'sound/music/instruments/lute (8).ogg', //Baldur's Gate 3 Song
	"Bard Dance" = 'sound/music/instruments/lute (9).ogg', //Baldur's Gate 3 Song
	"Old Time Battles" = 'sound/music/instruments/lute (10).ogg') //Baldur's Gate 3 Song

/obj/item/rogue/instrument/accord
	name = "accordion"
	desc = "A harmonious vessel of nostalgia and celebration."
	icon_state = "accordion"
	song_list = list("Her Healing Tears" = 'sound/music/instruments/accord (1).ogg',
	"Peddler's Tale" = 'sound/music/instruments/accord (2).ogg',
	"We Toil Together" = 'sound/music/instruments/accord (3).ogg',
	"Just One More, Tavern Wench" = 'sound/music/instruments/accord (4).ogg',
	"Moonlight Carnival" = 'sound/music/instruments/accord (5).ogg',
	"'Ye Best Be Goin'" = 'sound/music/instruments/accord (6).ogg',
	"Beloved Blue" = 'sound/music/instruments/accord (7).ogg')

/obj/item/rogue/instrument/guitar
	name = "guitar"
	desc = "This is a guitar, chosen instrument of wanderers and the heartbroken." // YIPPEE I LOVE GUITAR
	icon_state = "guitar"
	song_list = list("Fire-Cast Shadows" = 'sound/music/instruments/guitar (1).ogg',
	"The Forced Hand" = 'sound/music/instruments/guitar (2).ogg',
	"Regrets Unpaid" = 'sound/music/instruments/guitar (3).ogg',
	"'Took the Mammon and Ran'" = 'sound/music/instruments/guitar (4).ogg',
	"Poor Man's Tithe" = 'sound/music/instruments/guitar (5).ogg',
	"In His Arms Ye'll Find Me" = 'sound/music/instruments/guitar (6).ogg',
	"El Odio" = 'sound/music/instruments/guitar (7).ogg',
	"Danza De Las Lanzas" = 'sound/music/instruments/guitar (8).ogg',
	"The Feline, Forever Returning" = 'sound/music/instruments/guitar (9).ogg',
	"El Beso Carmesí" = 'sound/music/instruments/guitar (10).ogg',
	"The Queen's High Seas" = 'sound/music/instruments/guitar (11).ogg',
	"Harsh Testimony" = 'sound/music/instruments/guitar (12).ogg',
	"Someone Fair" = 'sound/music/instruments/guitar (13).ogg',
	"Daisies in Bloom" = 'sound/music/instruments/guitar (14).ogg')

/obj/item/rogue/instrument/harp
	name = "harp"
	desc = "A harp of elven craftsmanship."
	icon_state = "harp"
	song_list = list("Through Thine Window, He Glanced" = 'sound/music/instruments/harb (1).ogg',
	"The Lady of Red Silks" = 'sound/music/instruments/harb (2).ogg',
	"Eora Doth Watches" = 'sound/music/instruments/harb (3).ogg',
	"On the Breeze" = 'sound/music/instruments/harb (4).ogg',
	"Never Enough" = 'sound/music/instruments/harb (5).ogg',
	"Sundered Heart" = 'sound/music/instruments/harb (6).ogg',
	"Corridors of Time" = 'sound/music/instruments/harb (7).ogg',
	"Determination" = 'sound/music/instruments/harb (8).ogg')

/obj/item/rogue/instrument/flute
	name = "flute"
	desc = "A row of slender hollow tubes of varying lengths that produce a light airy sound when blown across."
	icon_state = "flute"
	song_list = list("Half-Dragon's Ten Mammon" = 'sound/music/instruments/flute (1).ogg',
	"'The Local Favorite'" = 'sound/music/instruments/flute (2).ogg',
	"Rous in the Cellar" = 'sound/music/instruments/flute (3).ogg',
	"Her Boots, So Incandescent" = 'sound/music/instruments/flute (4).ogg',
	"Moondust Minx" = 'sound/music/instruments/flute (5).ogg',
	"Quest to the Ends" = 'sound/music/instruments/flute (6).ogg',
	"Spit Shine" = 'sound/music/instruments/flute (7).ogg',
	"The Power" = 'sound/music/instruments/flute (8).ogg', //Baldur's Gate 3 Song
	"Bard Dance" = 'sound/music/instruments/flute (9).ogg', //Baldur's Gate 3 Song
	"Old Time Battles" = 'sound/music/instruments/flute (10).ogg') //Baldur's Gate 3 Song

/obj/item/rogue/instrument/drum
	name = "drum"
	desc = "Fashioned from taut skins across a sturdy frame, pulses like a giant heartbeat."
	icon_state = "drum"
	song_list = list("Barbarian's Moot" = 'sound/music/instruments/drum (1).ogg',
	"Muster the Wardens" = 'sound/music/instruments/drum (2).ogg',
	"The Earth That Quakes" = 'sound/music/instruments/drum (3).ogg',
	"The Power" = 'sound/music/instruments/drum (4).ogg', //BG3 Song
	"Bard Dance" = 'sound/music/instruments/drum (5).ogg', // BG3 Song
	"Old Time Battles" = 'sound/music/instruments/drum (6).ogg') // BG3 Song

/obj/item/rogue/instrument/hurdygurdy
	name = "hurdy-gurdy"
	desc = "A knob-driven, wooden string instrument that reminds you of the oceans far."
	icon_state = "hurdygurdy"
	song_list = list("Ruler's One Ring" = 'sound/music/instruments/hurdy (1).ogg',
	"Tangled Trod" = 'sound/music/instruments/hurdy (2).ogg',
	"Motus" = 'sound/music/instruments/hurdy (3).ogg',
	"Becalmed" = 'sound/music/instruments/hurdy (4).ogg',
	"The Bloody Throne" = 'sound/music/instruments/hurdy (5).ogg',
	"We Shall Sail Together" = 'sound/music/instruments/hurdy (6).ogg')

/obj/item/rogue/instrument/viola
	name = "viola"
	desc = "The prim and proper Viola, every prince's first instrument taught."
	icon_state = "viola"
	song_list = list("Far Flung Tale" = 'sound/music/instruments/viola (1).ogg',
	"G Major Cello Suite No. 1" = 'sound/music/instruments/viola (2).ogg',
	"Ursine's Home" = 'sound/music/instruments/viola (3).ogg',
	"Mead, Gold and Blood" = 'sound/music/instruments/viola (4).ogg',
	"Gasgow's Reel" = 'sound/music/instruments/viola (5).ogg',
	"The Power" = 'sound/music/instruments/viola (6).ogg', //BG3 Song, I KNOW THIS ISNT A VIOLIN, LEAVE ME ALONE
	"Bard Dance" = 'sound/music/instruments/viola (7).ogg', // BG3 Song
	"Old Time Battles" = 'sound/music/instruments/viola (8).ogg') // BG3 Song

/obj/item/rogue/instrument/vocals
	name = "vocalist's talisman"
	desc = "This talisman emanates a soft shimmer of light. When held, it can amplify and even change a bard's voice."
	icon_state = "vtalisman"
	song_list = list("Harpy's Call (Feminine)" = 'sound/music/instruments/vocalsf (1).ogg',
	"Necra's Lullaby (Feminine)" = 'sound/music/instruments/vocalsf (2).ogg',
	"Death Touched Aasimar (Feminine)" = 'sound/music/instruments/vocalsf (3).ogg',
	"Our Mother, Our Divine (Feminine)" = 'sound/music/instruments/vocalsf (4).ogg',
	"Wed, Forever More (Feminine)" = 'sound/music/instruments/vocalsf (5).ogg',
	"Paper Boats (Feminine + Vocals)" = 'sound/music/instruments/vocalsf (6).ogg',
	"The Dragon's Blood Surges (Masculine)" = 'sound/music/instruments/vocalsm (1).ogg',
	"Timeless Temple (Masculine)" = 'sound/music/instruments/vocalsm (2).ogg',
	"Angel's Earnt Halo (Masculine)" = 'sound/music/instruments/vocalsm (3).ogg',
	"A Fabled Choir (Masculine)" = 'sound/music/instruments/vocalsm (4).ogg',
	"A Pained Farewell (Masculine + Feminine)" = 'sound/music/instruments/vocalsx (1).ogg',
	"The Power (Whistling)" = 'sound/music/instruments/vocalsx (2).ogg',
	"Bard Dance (Whistling)" = 'sound/music/instruments/vocalsx (3).ogg',
	"Old Time Battles (Whistling)" = 'sound/music/instruments/vocalsx (4).ogg')

/obj/item/rogue/instrument/shamisen
	name = "shamisen"
	desc = "The shamisen, or simply «three strings», is an kazengunese stringed instrument with a washer, which is usually played with the help of a bachi."
	icon_state = "shamisen"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	song_list = list(
	"A Rambling Tongue" = 'sound/music/instruments/shamisen A Rambling Tongue.ogg',
	"Ashitaka" = 'sound/music/instruments/shamisen The Legend of Ashitaka.ogg',
	"Daimyo Dreamwalker" = 'sound/music/instruments/shamisen Daimyo Dreamwalker.ogg',
	"Fire Phoenix" = 'sound/music/instruments/shamisen Fire Phoenix.ogg',
	"Kaiju Islands" = 'sound/music/instruments/shamisen Kaiju Islands.ogg',
	"Lavender Village" = 'sound/music/instruments/shamisen Lavender Village.ogg',
	"Morning Is Coming" = 'sound/music/instruments/shamisen Morning Is Coming.ogg',
	"Pouncing Shadow" = 'sound/music/instruments/shamisen Pouncing Shadow.ogg',
	"Rising Sun" = 'sound/music/instruments/shamisen Rising Sun.ogg',
	"Those Who Fight" = 'sound/music/instruments/shamisen Those Who Fight.ogg',
	"Village in the Mountains" = 'sound/music/instruments/shamisen Village in the Mountains.ogg',
	"Winning the Soul" = 'sound/music/instruments/shamisen Winning the Soul.ogg',
	"Cursed Apple" = 'sound/music/instruments/shamisen (1).ogg',
	"Fire Dance" = 'sound/music/instruments/shamisen (2).ogg',
	"Lute" = 'sound/music/instruments/shamisen (3).ogg',
	"Tsugaru Ripple" = 'sound/music/instruments/shamisen (4).ogg',
	"Tsugaru" = 'sound/music/instruments/shamisen (5).ogg',
	"Season" = 'sound/music/instruments/shamisen (6).ogg',
	"Parade" = 'sound/music/instruments/shamisen (7).ogg',
	"Koshiro" = 'sound/music/instruments/shamisen (8).ogg')

/obj/item/rogue/instrument/psyaltery
	name = "psyaltery"
	desc = "A traditional form of boxed zither or box-harp that may be played plucked, with a plectrum or with hammers. They are particularly associated with divine beings, aasimars and liturgies."
	icon_state = "psyaltery"
	song_list = list(
	"Disciples Tower" = 'sound/music/instruments/psyaltery (1).ogg',
	"Green Sleeves" = 'sound/music/instruments/psyaltery (2).ogg',
	"Midyear Melancholy" = 'sound/music/instruments/psyaltery (3).ogg',
	"Santa Psydonia" = 'sound/music/instruments/psyaltery (4).ogg',
	"Le Venardine" = 'sound/music/instruments/psyaltery (5).ogg',
	"Azurea Fair" = 'sound/music/instruments/psyaltery (6).ogg',
	"Amoroso" = 'sound/music/instruments/psyaltery (7).ogg',
	"Lupian's Lullaby" = 'sound/music/instruments/psyaltery (8).ogg',
	"White Wine Before Breakfast" = 'sound/music/instruments/psyaltery (9).ogg',
	"Chevalier de Naledi" = 'sound/music/instruments/psyaltery (10).ogg')
