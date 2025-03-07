
///Default override for echo
/sound
	echo = list(
		0, // Direct
		0, // DirectHF
		-10000, // Room, -10000 means no low frequency sound reverb
		-10000, // RoomHF, -10000 means no high frequency sound reverb
		0, // Obstruction
		0, // ObstructionLFRatio
		0, // Occlusion
		0.25, // OcclusionLFRatio
		1.5, // OcclusionRoomRatio
		1.0, // OcclusionDirectRatio
		0, // Exclusion
		1.0, // ExclusionLFRatio
		0, // OutsideVolumeHF
		0, // DopplerFactor
		0, // RolloffFactor
		0, // RoomRolloffFactor
		1.0, // AirAbsorptionFactor
		0, // Flags (1 = Auto Direct, 2 = Auto Room, 4 = Auto RoomHF)
	)
	environment = SOUND_ENVIRONMENT_NONE //Default to none so sounds without overrides dont get reverb

/*! playsound

playsound is a proc used to play a 3D sound in a specific range. This uses SOUND_RANGE + extra_range to determine that.

source - Origin of sound
soundin - Either a file, or a string that can be used to get an SFX
vol - The volume of the sound, excluding falloff and pressure affection.
vary - bool that determines if the sound changes pitch every time it plays
extrarange - modifier for sound range. This gets added on top of SOUND_RANGE
falloff_exponent - Rate of falloff for the audio. Higher means quicker drop to low volume. Should generally be over 1 to indicate a quick dive to 0 rather than a slow dive.
frequency - playback speed of audio
channel - The channel the sound is played at
pressure_affected - Whether or not difference in pressure affects the sound (E.g. if you can hear in space)
ignore_walls - Whether or not the sound can pass through walls.
falloff_distance - Distance at which falloff begins. Sound is at peak volume (in regards to falloff) aslong as it is in this range.

*/
GLOBAL_LIST_INIT(used_sound_channels, list(
	CHANNEL_LOBBYMUSIC,
	CHANNEL_ADMIN,
	CHANNEL_VOX,
	CHANNEL_JUKEBOX,
	CHANNEL_HEARTBEAT,
	CHANNEL_AMBIENT_EFFECTS,
	CHANNEL_AMBIENT_MUSIC,
	CHANNEL_BUZZ,
	CHANNEL_ENGINE_ALERT,
	CHANNEL_SOUND_EFFECTS,
	CHANNEL_SOUND_FOOTSTEPS,
	CHANNEL_WEATHER,
	CHANNEL_MACHINERY,
	CHANNEL_INSTRUMENTS,
	CHANNEL_INSTRUMENTS_ROBOT,
	CHANNEL_MOB_SOUNDS,
))

GLOBAL_LIST_INIT(proxy_sound_channels, list(
	CHANNEL_SOUND_EFFECTS,
	CHANNEL_SOUND_FOOTSTEPS,
	CHANNEL_WEATHER,
	CHANNEL_MACHINERY,
	CHANNEL_INSTRUMENTS,
	CHANNEL_INSTRUMENTS_ROBOT,
	CHANNEL_MOB_SOUNDS,
))

/proc/guess_mixer_channel(soundin)
	var/sound_text_string = "[soundin]"
	if(findtext(sound_text_string, "effects/"))
		return CHANNEL_SOUND_EFFECTS
	if(findtext(sound_text_string, "machines/"))
		return CHANNEL_MACHINERY
	if(findtext(sound_text_string, "creatures/"))
		return CHANNEL_MOB_SOUNDS
	if(findtext(sound_text_string, "/ai/"))
		return CHANNEL_VOX
	if(findtext(sound_text_string, "chatter/"))
		return CHANNEL_MOB_SOUNDS
	if(findtext(sound_text_string, "items/"))
		return CHANNEL_SOUND_EFFECTS
	if(findtext(sound_text_string, "weapons/"))
		return CHANNEL_SOUND_EFFECTS
	return FALSE
/proc/playsound(atom/source, soundin, vol as num, vary, extrarange as num, falloff_exponent = SOUND_FALLOFF_EXPONENT, frequency = null, channel = 0, pressure_affected = TRUE, ignore_walls = TRUE, falloff_distance = SOUND_DEFAULT_FALLOFF_DISTANCE, use_reverb = TRUE, mixer_channel)
	if(isarea(source))
		CRASH("playsound(): source is an area")

	var/turf/turf_source = get_turf(source)

	if (!turf_source)
		return

	if(!mixer_channel)
		mixer_channel = guess_mixer_channel(soundin)

	var/maxdistance = (SOUND_RANGE + extrarange)
	var/max_z_range = maxdistance / (MULTI_Z_DISTANCE + 1)

	var/list/z_list = get_zs_in_range(turf_source.z, max_z_range)

	//allocate a channel if necessary now so its the same for everyone
	channel = channel || SSsounds.random_available_channel()

 	// Looping through the player list has the added bonus of working for mobs inside containers
	var/sound/S = sound(get_sfx(soundin))
	var/list/listeners = list()
	var/list/dead_listeners = list()
	for(var/z in z_list)
		listeners += SSmobs.clients_by_zlevel[z]
		dead_listeners += SSmobs.dead_players_by_zlevel[z]
	if(!ignore_walls) //these sounds don't carry through walls
		listeners = listeners & hearers(maxdistance,turf_source)
	for(var/mob/M as() in listeners)
		if(get_dist(M, turf_source) <= maxdistance)
			M.playsound_local(turf_source, soundin, vol, vary, frequency, falloff_exponent, channel, pressure_affected, S, maxdistance, falloff_distance, 1, use_reverb, mixer_channel)
	for(var/mob/M as() in dead_listeners)
		if(get_dist(M, turf_source) <= maxdistance)
			M.playsound_local(turf_source, soundin, vol, vary, frequency, falloff_exponent, channel, pressure_affected, S, maxdistance, falloff_distance, 1, use_reverb, mixer_channel)
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_SOUND_PLAYED, source, soundin)

/*! playsound

playsound_local is a proc used to play a sound directly on a mob from a specific turf.
This is called by playsound to send sounds to players, in which case it also gets the max_distance of that sound.

turf_source - Origin of sound
soundin - Either a file, or a string that can be used to get an SFX
vol - The volume of the sound, excluding falloff
vary - bool that determines if the sound changes pitch every time it plays
frequency - playback speed of audio
falloff_exponent - Rate of falloff for the audio. Higher means quicker drop to low volume. Should generally be over 1 to indicate a quick dive to 0 rather than a slow dive.
channel - The channel the sound is played at
pressure_affected - Whether or not difference in pressure affects the sound (E.g. if you can hear in space)
max_distance - The peak distance of the sound, if this is a 3D sound
falloff_distance - Distance at which falloff begins, if this is a 3D sound
distance_multiplier - Can be used to multiply the distance at which the sound is heard

*/
/mob/proc/playsound_local(turf/turf_source, soundin, vol as num, vary, frequency, falloff_exponent = SOUND_FALLOFF_EXPONENT, channel = 0, pressure_affected = TRUE, sound/S, max_distance, falloff_distance = SOUND_DEFAULT_FALLOFF_DISTANCE, distance_multiplier = 1, use_reverb = TRUE, mixer_channel = 0)
	if(!client || !can_hear())
		return

	if(!S)
		S = sound(get_sfx(soundin))

	S.wait = 0 //No queue
	S.channel = channel || SSsounds.random_available_channel()
	S.volume = vol

	if(vary)
		if(frequency)
			S.frequency = frequency
		else
			S.frequency = get_rand_frequency()

	if(isturf(turf_source))
		var/turf/T = get_turf(src)

		//sound volume falloff with distance
		var/distance = get_dist(T, turf_source)

		var/z_change = turf_source.z - T.z
		var/z_dist = abs(z_change) * MULTI_Z_DISTANCE

		distance *= distance_multiplier
		z_dist *= distance_multiplier

		distance += z_dist

		if(max_distance && distance > max_distance)
			return

		if(max_distance) //If theres no max_distance we're not a 3D sound, so no falloff.
			S.volume -= (max(distance - falloff_distance, 0) ** (1 / falloff_exponent)) / ((max(max_distance, distance) - falloff_distance) ** (1 / falloff_exponent)) * S.volume
			//https://www.desmos.com/calculator/sqdfl8ipgf

		if(pressure_affected)
			//Atmosphere affects sound
			var/pressure_factor = 1
			var/datum/gas_mixture/hearer_env = T.return_air()
			var/datum/gas_mixture/source_env = turf_source.return_air()

			if(hearer_env && source_env)
				var/pressure = min(hearer_env.return_pressure(), source_env.return_pressure())
				if(pressure < ONE_ATMOSPHERE)
					pressure_factor = max((pressure - SOUND_MINIMUM_PRESSURE)/(ONE_ATMOSPHERE - SOUND_MINIMUM_PRESSURE), 0)
			else //space
				pressure_factor = 0

			if(distance <= 1)
				pressure_factor = max(pressure_factor, 0.15) //touching the source of the sound

			S.volume *= pressure_factor
			//End Atmosphere affecting sound

		if((channel in GLOB.used_sound_channels) || (mixer_channel in GLOB.used_sound_channels))
			var/used_channel = 0
			if(channel in GLOB.used_sound_channels)
				used_channel = channel
			else
				used_channel = mixer_channel
			if(client.prefs.channel_volume["[used_channel]"])
				S.volume *= (client.prefs.channel_volume["[used_channel]"] * 0.01)
			else
				S.volume = 0

		if(S.volume <= 0)
			return //No sound

		var/dx = turf_source.x - T.x // Hearing from the right/left
		S.x = dx * distance_multiplier
		var/dz = turf_source.y - T.y // Hearing from infront/behind
		S.z = dz * distance_multiplier
		// The y value is for above your head, but there is no ceiling in 2d spessmens.
		S.y = z_change + 1
		S.falloff = max_distance || 1 //use max_distance, else just use 1 as we are a direct sound so falloff isnt relevant.

		// Sounds can't have their own environment. A sound's environment will be:
		// 1. the mob's
		// 2. the area's (defaults to SOUND_ENVRIONMENT_NONE)
		if(sound_environment_override != SOUND_ENVIRONMENT_NONE)
			S.environment = sound_environment_override
		else
			var/area/A = get_area(src)
			S.environment = A.sound_environment

		if(use_reverb && S.environment != SOUND_ENVIRONMENT_NONE) //We have reverb, reset our echo setting
			S.echo[3] = 0 //Room setting, 0 means normal reverb
			S.echo[4] = 0 //RoomHF setting, 0 means normal reverb.

	SEND_SOUND(src, S)

/proc/sound_to_playing_players(soundin, volume = 100, vary = FALSE, frequency = 0, channel = 0, pressure_affected = FALSE, sound/S)
	if(!S)
		S = sound(get_sfx(soundin))
	for(var/m in GLOB.player_list)
		if(ismob(m) && !isnewplayer(m))
			var/mob/M = m
			M.playsound_local(M, null, volume, vary, frequency, null, channel, pressure_affected, S)

/proc/play_soundtrack_music(var/datum/soundtrack_song/song, list/hearers = null, volume = 80, ignore_prefs = FALSE, play_to_lobby = FALSE, allow_deaf = TRUE, only_station = FALSE)
	var/sound/S = sound(initial(song.file), volume=volume, wait=0, channel=CHANNEL_AMBIENT_MUSIC)
	. = S

	if(!hearers)
		hearers = GLOB.player_list

	for(var/mob/M as() in hearers)
		if (!ismob(M))
			continue

		if (!ignore_prefs && !(M.client?.prefs?.toggles & SOUND_AMBIENCE))
			continue

		if (!play_to_lobby && isnewplayer(M))
			continue

		if (!allow_deaf && !M.can_hear())
			continue

		if (only_station && !is_station_level(M.z))
			continue

		SEND_SOUND(M, S)

	GLOB.soundtrack_this_round |= song

/proc/stop_soundtrack_music()
	for(var/mob/M as() in GLOB.player_list)
		M?.stop_sound_channel(CHANNEL_AMBIENT_MUSIC)

/mob/proc/stop_sound_channel(chan)
	SEND_SOUND(src, sound(null, repeat = 0, wait = 0, channel = chan))

/mob/proc/set_sound_channel_volume(channel, volume)
	var/sound/S = sound(null, FALSE, FALSE, channel, volume)
	S.status = SOUND_UPDATE
	SEND_SOUND(src, S)

/client/proc/playtitlemusic(vol = 85)
	set waitfor = FALSE
	UNTIL(SSticker.login_music) //wait for SSticker init to set the login music
	if(prefs.channel_volume["[CHANNEL_LOBBYMUSIC]"])
		vol *= prefs.channel_volume["[CHANNEL_LOBBYMUSIC]"] * 0.01
	else
		return
	if(prefs && (prefs.toggles & SOUND_LOBBY))
		SEND_SOUND(src, sound(SSticker.login_music, repeat = 0, wait = 0, volume = vol, channel = CHANNEL_LOBBYMUSIC)) // MAD JAMS

/proc/get_rand_frequency()
	return rand(32000, 55000) //Frequency stuff only works with 45kbps oggs.

/proc/get_sfx(soundin)
	if(istext(soundin))
		switch(soundin)
			if ("shatter")
				soundin = pick('sound/effects/glassbr1.ogg','sound/effects/glassbr2.ogg','sound/effects/glassbr3.ogg')
			if ("explosion")
				soundin = pick('sound/effects/explosion1.ogg','sound/effects/explosion2.ogg')
			if ("explosion_creaking")
				soundin = pick('sound/effects/explosioncreak1.ogg', 'sound/effects/explosioncreak2.ogg')
			if ("hull_creaking")
				soundin = pick('sound/effects/creak1.ogg', 'sound/effects/creak2.ogg', 'sound/effects/creak3.ogg')
			if ("sparks")
				soundin = pick('sound/effects/sparks1.ogg','sound/effects/sparks2.ogg','sound/effects/sparks3.ogg','sound/effects/sparks4.ogg')
			if ("rustle")
				soundin = pick('sound/effects/rustle1.ogg','sound/effects/rustle2.ogg','sound/effects/rustle3.ogg','sound/effects/rustle4.ogg','sound/effects/rustle5.ogg')
			if ("bodyfall")
				soundin = pick('sound/effects/bodyfall1.ogg','sound/effects/bodyfall2.ogg','sound/effects/bodyfall3.ogg','sound/effects/bodyfall4.ogg')
			if ("punch")
				soundin = pick('sound/weapons/punch1.ogg','sound/weapons/punch2.ogg','sound/weapons/punch3.ogg','sound/weapons/punch4.ogg')
			if ("clownstep")
				soundin = pick('sound/effects/clownstep1.ogg','sound/effects/clownstep2.ogg')
			if ("suitstep")
				soundin = pick('sound/effects/suitstep1.ogg','sound/effects/suitstep2.ogg')
			if ("swing_hit")
				soundin = pick('sound/weapons/genhit1.ogg', 'sound/weapons/genhit2.ogg', 'sound/weapons/genhit3.ogg')
			if ("hiss")
				soundin = pick('sound/voice/hiss1.ogg','sound/voice/hiss2.ogg','sound/voice/hiss3.ogg','sound/voice/hiss4.ogg')
			if ("pageturn")
				soundin = pick('sound/effects/pageturn1.ogg', 'sound/effects/pageturn2.ogg','sound/effects/pageturn3.ogg')
			if ("ricochet")
				soundin = pick(	'sound/weapons/effects/ric1.ogg', 'sound/weapons/effects/ric2.ogg','sound/weapons/effects/ric3.ogg','sound/weapons/effects/ric4.ogg','sound/weapons/effects/ric5.ogg')
			if ("terminal_type")
				soundin = pick('sound/machines/terminal_button01.ogg', 'sound/machines/terminal_button02.ogg', 'sound/machines/terminal_button03.ogg', \
								'sound/machines/terminal_button04.ogg', 'sound/machines/terminal_button05.ogg', 'sound/machines/terminal_button06.ogg', \
								'sound/machines/terminal_button07.ogg', 'sound/machines/terminal_button08.ogg')
			if ("desecration")
				soundin = pick('sound/misc/desecration-01.ogg', 'sound/misc/desecration-02.ogg', 'sound/misc/desecration-03.ogg')
			if ("im_here")
				soundin = pick('sound/hallucinations/im_here1.ogg', 'sound/hallucinations/im_here2.ogg')
			if ("can_open")
				soundin = pick('sound/effects/can_open1.ogg', 'sound/effects/can_open2.ogg', 'sound/effects/can_open3.ogg')
			if("bullet_miss")
				soundin = pick('sound/weapons/bulletflyby.ogg', 'sound/weapons/bulletflyby2.ogg', 'sound/weapons/bulletflyby3.ogg')
			if("gun_insert_empty_magazine")
				soundin = pick('sound/weapons/gun_magazine_insert_empty_1.ogg', 'sound/weapons/gun_magazine_insert_empty_2.ogg', 'sound/weapons/gun_magazine_insert_empty_3.ogg', 'sound/weapons/gun_magazine_insert_empty_4.ogg')
			if("gun_insert_full_magazine")
				soundin = pick('sound/weapons/gun_magazine_insert_full_1.ogg', 'sound/weapons/gun_magazine_insert_full_2.ogg', 'sound/weapons/gun_magazine_insert_full_3.ogg', 'sound/weapons/gun_magazine_insert_full_4.ogg', 'sound/weapons/gun_magazine_insert_full_5.ogg')
			if("gun_remove_empty_magazine")
				soundin = pick('sound/weapons/gun_magazine_remove_empty_1.ogg', 'sound/weapons/gun_magazine_remove_empty_2.ogg', 'sound/weapons/gun_magazine_remove_empty_3.ogg', 'sound/weapons/gun_magazine_remove_empty_4.ogg')
			if("gun_slide_lock")
				soundin = pick('sound/weapons/gun_slide_lock_1.ogg', 'sound/weapons/gun_slide_lock_2.ogg', 'sound/weapons/gun_slide_lock_3.ogg', 'sound/weapons/gun_slide_lock_4.ogg', 'sound/weapons/gun_slide_lock_5.ogg')
			if("revolver_spin")
				soundin = pick('sound/weapons/revolverspin1.ogg', 'sound/weapons/revolverspin2.ogg', 'sound/weapons/revolverspin3.ogg')
			if("law")
				soundin = pick('sound/voice/beepsky/god.ogg', 'sound/voice/beepsky/iamthelaw.ogg', 'sound/voice/beepsky/secureday.ogg', 'sound/voice/beepsky/radio.ogg', 'sound/voice/beepsky/creep.ogg')
			//Monkestation edit begin
			if("pizzky")
				soundin = pick('monkestation/sound/voice/pizzky/criminal.ogg','monkestation/sound/voice/pizzky/god.ogg','monkestation/sound/voice/pizzky/lmaoing.ogg','monkestation/sound/voice/pizzky/justice.ogg','monkestation/sound/voice/pizzky/secureday.ogg','monkestation/sound/voice/pizzky/radio.ogg','monkestation/sound/voice/pizzky/insult.ogg')
			if("sec_emag")
				soundin = pick('monkestation/sound/voice/pizzky/lmaoing.ogg','monkestation/sound/voice/pizzky/getowned.ogg','monkestation/sound/voice/pizzky/creep.ogg','monkestation/sound/voice/pizzky/secureday.ogg')
			//Monkestation edit end
			if("honkbot_e")
				soundin = pick('sound/items/bikehorn.ogg', 'sound/items/AirHorn2.ogg', 'sound/misc/sadtrombone.ogg', 'sound/items/AirHorn.ogg', 'sound/effects/reee.ogg',  'sound/items/WEEOO1.ogg', 'sound/voice/beepsky/iamthelaw.ogg', 'sound/voice/beepsky/creep.ogg','sound/magic/Fireball.ogg' ,'sound/effects/pray.ogg', 'sound/voice/hiss1.ogg','sound/machines/buzz-sigh.ogg', 'sound/machines/ping.ogg', 'sound/weapons/flashbang.ogg', 'sound/weapons/bladeslice.ogg')
			if("goose")
				soundin = pick('sound/creatures/goose1.ogg', 'sound/creatures/goose2.ogg', 'sound/creatures/goose3.ogg', 'sound/creatures/goose4.ogg')
			if("smcalm")
				soundin = pick('sound/machines/sm/accent/normal/1.ogg', 'sound/machines/sm/accent/normal/2.ogg', 'sound/machines/sm/accent/normal/3.ogg', 'sound/machines/sm/accent/normal/4.ogg', 'sound/machines/sm/accent/normal/5.ogg', 'sound/machines/sm/accent/normal/6.ogg', 'sound/machines/sm/accent/normal/7.ogg', 'sound/machines/sm/accent/normal/8.ogg', 'sound/machines/sm/accent/normal/9.ogg', 'sound/machines/sm/accent/normal/10.ogg', 'sound/machines/sm/accent/normal/11.ogg', 'sound/machines/sm/accent/normal/12.ogg', 'sound/machines/sm/accent/normal/13.ogg', 'sound/machines/sm/accent/normal/14.ogg', 'sound/machines/sm/accent/normal/15.ogg', 'sound/machines/sm/accent/normal/16.ogg', 'sound/machines/sm/accent/normal/17.ogg', 'sound/machines/sm/accent/normal/18.ogg', 'sound/machines/sm/accent/normal/19.ogg', 'sound/machines/sm/accent/normal/20.ogg', 'sound/machines/sm/accent/normal/21.ogg', 'sound/machines/sm/accent/normal/22.ogg', 'sound/machines/sm/accent/normal/23.ogg', 'sound/machines/sm/accent/normal/24.ogg', 'sound/machines/sm/accent/normal/25.ogg', 'sound/machines/sm/accent/normal/26.ogg', 'sound/machines/sm/accent/normal/27.ogg', 'sound/machines/sm/accent/normal/28.ogg', 'sound/machines/sm/accent/normal/29.ogg', 'sound/machines/sm/accent/normal/30.ogg', 'sound/machines/sm/accent/normal/31.ogg', 'sound/machines/sm/accent/normal/32.ogg', 'sound/machines/sm/accent/normal/33.ogg')
			if("smdelam")
				soundin = pick('sound/machines/sm/accent/delam/1.ogg', 'sound/machines/sm/accent/normal/2.ogg', 'sound/machines/sm/accent/normal/3.ogg', 'sound/machines/sm/accent/normal/4.ogg', 'sound/machines/sm/accent/normal/5.ogg', 'sound/machines/sm/accent/normal/6.ogg', 'sound/machines/sm/accent/normal/7.ogg', 'sound/machines/sm/accent/normal/8.ogg', 'sound/machines/sm/accent/normal/9.ogg', 'sound/machines/sm/accent/normal/10.ogg', 'sound/machines/sm/accent/normal/11.ogg', 'sound/machines/sm/accent/normal/12.ogg', 'sound/machines/sm/accent/normal/13.ogg', 'sound/machines/sm/accent/normal/14.ogg', 'sound/machines/sm/accent/normal/15.ogg', 'sound/machines/sm/accent/normal/16.ogg', 'sound/machines/sm/accent/normal/17.ogg', 'sound/machines/sm/accent/normal/18.ogg', 'sound/machines/sm/accent/normal/19.ogg', 'sound/machines/sm/accent/normal/20.ogg', 'sound/machines/sm/accent/normal/21.ogg', 'sound/machines/sm/accent/normal/22.ogg', 'sound/machines/sm/accent/normal/23.ogg', 'sound/machines/sm/accent/normal/24.ogg', 'sound/machines/sm/accent/normal/25.ogg', 'sound/machines/sm/accent/normal/26.ogg', 'sound/machines/sm/accent/normal/27.ogg', 'sound/machines/sm/accent/normal/28.ogg', 'sound/machines/sm/accent/normal/29.ogg', 'sound/machines/sm/accent/normal/30.ogg', 'sound/machines/sm/accent/normal/31.ogg', 'sound/machines/sm/accent/normal/32.ogg', 'sound/machines/sm/accent/normal/33.ogg')
	return soundin

/client/proc/channel_in_use(channel)
	for (var/sound/S in src.SoundQuery())
		if (S.channel == channel)
			return TRUE

	return FALSE

/mob/proc/can_hear_ambience()
	if (!src.can_hear()) // If they can't hear they can't hear
		return FALSE

	var/turf/T = get_turf(src)
	var/datum/gas_mixture/hearer_env = T.return_air()

	if (!hearer_env || hearer_env.return_pressure() < SOUND_MINIMUM_PRESSURE) // They can't hear ambience if there isn't enough pressure
		return FALSE

	return TRUE

///sound volume handling here

/client/verb/open_volume_mixer()
	set category = "Preferences"
	set name = "Volume Mixer"
	set desc = "Opens the volume mixer UI"

	if(!prefs.pref_mixer)
		prefs.pref_mixer = new
	prefs.pref_mixer.open_ui(src.mob)

/datum/ui_module/volume_mixer/proc/open_ui(mob/user)
	ui_interact(user)

/datum/ui_module/volume_mixer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "VolumeMixer", "Volume Mixer")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/ui_module/volume_mixer/ui_data(mob/user)
	var/list/data = list()

	var/list/channels = list()
	for(var/channel in GLOB.used_sound_channels)
		if(!user.client.prefs.channel_volume["[channel]"])
			user.client.prefs.channel_volume["[channel]"] = 100
			user.client.prefs.save_preferences()
		channels += list(list(
			"num" = channel,
			"name" = get_channel_name(channel),
			"volume" = user.client.prefs.channel_volume["[channel]"]
		))
	data["channels"] = channels

	return data


/datum/ui_module/volume_mixer/ui_act(action, list/params)
	if(..())
		return

	. = TRUE
	switch(action)
		if("volume")
			var/channel = text2num(params["channel"])
			var/volume = text2num(params["volume"])
			if(isnull(channel))
				return FALSE
			usr.client.prefs.channel_volume["[channel]"] = volume
			usr.client.prefs.save_preferences()
			var/list/instrument_channels = list(
				CHANNEL_INSTRUMENTS,
				CHANNEL_INSTRUMENTS_ROBOT,)
			if(!(channel in GLOB.proxy_sound_channels)) //if its a proxy we are just wasting time
				set_channel_volume(channel, volume, usr)

			else if((channel in instrument_channels))
				var/datum/song/holder_song = new
				for(var/used_channel in holder_song.channels_playing)
					set_channel_volume(used_channel, volume, usr)
		else
			return FALSE

/datum/ui_module/volume_mixer/ui_state()
	return GLOB.always_state

/datum/ui_module/volume_mixer/proc/set_channel_volume(channel, vol, mob/user)
	var/sound/S = sound(null, channel = channel, volume = vol)
	S.status = SOUND_UPDATE
	SEND_SOUND(usr, S)

/proc/get_channel_name(channel)
	switch(channel)
		if(CHANNEL_LOBBYMUSIC)
			return "Lobby Music"
		if(CHANNEL_ADMIN)
			return "Admin MIDIs"
		if(CHANNEL_VOX)
			return "Announcements / AI Noise"
		if(CHANNEL_JUKEBOX)
			return "Dance Machines"
		if(CHANNEL_HEARTBEAT)
			return "Heartbeat"
		if(CHANNEL_BUZZ)
			return "White Noise"
		if(CHANNEL_AMBIENT_EFFECTS)
			return "Ambient Effects"
		if(CHANNEL_AMBIENT_MUSIC)
			return "Ambient Music"
		if(CHANNEL_ENGINE_ALERT)
			return "Engine Alerts"
		if(CHANNEL_SOUND_EFFECTS)
			return "Sound Effects"
		if(CHANNEL_SOUND_FOOTSTEPS)
			return "Footsteps"
		if(CHANNEL_WEATHER)
			return "Weather"
		if(CHANNEL_MACHINERY)
			return "Machinery"
		if(CHANNEL_INSTRUMENTS)
			return "Player Instruments"
		if(CHANNEL_INSTRUMENTS_ROBOT)
			return "Robot Instruments" //you caused this DONGLE
		if(CHANNEL_MOB_SOUNDS)
			return "Mob Sounds"
