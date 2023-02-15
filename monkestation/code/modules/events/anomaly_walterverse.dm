/datum/round_event_control/anomaly/anomaly_walterverse
	name = "Anomaly: Walterverse"
	typepath = /datum/round_event/anomaly/anomaly_walterverse

	max_occurrences = 1
	weight = 5

/datum/round_event/anomaly/anomaly_walterverse
	startWhen = 1
	anomaly_path = /obj/effect/anomaly/walterverse
	var/sentience = FALSE
	var/sentience_candidates = FALSE

/datum/round_event/anomaly/anomaly_walterverse/setup()
	if(prob(50))
		sentience = TRUE
		sentience_candidates = pollGhostCandidates("Would you like to become a Walterverse Walter?", poll_time = 15 SECONDS)
	..()


/datum/round_event/anomaly/anomaly_walterverse/start()
	var/turf/safe_turf = safepick(get_area_turfs(impact_area))
	var/obj/effect/anomaly/walterverse/newAnomaly
	if(safe_turf)
		newAnomaly = new anomaly_path(safe_turf)
		newAnomaly.sentience = sentience
		newAnomaly.sentience_candidates = sentience_candidates
	if(newAnomaly)
		announce_to_ghosts(newAnomaly)

/datum/round_event/anomaly/anomaly_walterverse/announce(fake)
	priority_announce("The Walterverse has been opened. Expected location: [impact_area.name].", "Anomaly Alert", SSstation.announcer.get_rand_alert_sound())
