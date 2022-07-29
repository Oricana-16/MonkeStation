/datum/antagonist/mimic
	name = "mimic"
	show_name_in_check_antagonists = TRUE
	show_in_antagpanel = FALSE

/datum/antagonist/mimic/greet()
	var/mob/living/simple_animal/hostile/alien_mimic/spawned_mimic = owner.current
	to_chat(spawned_mimic, spawned_mimic.playstyle_string)
