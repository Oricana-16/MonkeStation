/datum/round_event_control/alien_mimic
	name = "Spawn Alien Mimic"
	typepath = /datum/round_event/ghost_role/alien_mimic
	weight = 2
	max_occurrences = 1

/datum/round_event/ghost_role/alien_mimic
	minimum_required = 1
	role_name = "alien mimic"

/datum/round_event/ghost_role/alien_mimic/spawn_role()
	var/list/candidates = get_candidates()

	if(!candidates.len)
		return NOT_ENOUGH_PLAYERS

	var/mob/dead/selected = pick(candidates)

	if(!GLOB.xeno_spawn)
		return MAP_ERROR

	var/mob/living/simple_animal/hostile/alien_mimic/spawned_mimic = new(pick(GLOB.xeno_spawn))

	var/datum/mind/player_mind = new(selected.key)
	player_mind.assigned_role = "Mimic"
	player_mind.special_role = "Mimic"
	player_mind.active = TRUE
	player_mind.transfer_to(spawned_mimic)
	player_mind.add_antag_datum(/datum/antagonist/mimic)

	message_admins("[ADMIN_LOOKUPFLW(spawned_mimic)] has been made into a mimic by an event.")
	log_game("[key_name(spawned_mimic)] was spawned as a mimic by an event.")

	spawned_mobs += spawned_mimic

	return SUCCESSFUL_SPAWN
