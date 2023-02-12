/mob/living/simple_animal/hostile/alien_mimic/tier3/transportive
	name = "transportive mimic"
	real_name = "transportive mimic"
	icon_state = "shifty"
	icon_living = "shifty"
	hivemind_modifier = "Transportive"
	melee_damage = 6
	playstyle_string = "<span class='big bold'>You are a transportive mimic,</span></b> you can teleport around like before, but you can also use teleport to and summon any other mimic<b>"

/mob/living/simple_animal/hostile/alien_mimic/tier3/transportive/Initialize(mapload)
	. = ..()
	var/obj/effect/proc_holder/spell/pointed/mimic_phantom_shift/shift = new
	var/obj/effect/proc_holder/spell/self/mimic_dimensional_walk/team_teleport = new
	var/obj/effect/proc_holder/spell/self/mimic_summon/team_summon = new
	AddSpell(shift)
	AddSpell(team_teleport)
	AddSpell(team_summon)

//Abilities
/obj/effect/proc_holder/spell/self/mimic_dimensional_walk
	name = "Dimensional Walk"
	desc = "Teleport to any of the mimics in your hivemind."
	clothes_req = FALSE
	action_icon = 'monkestation/icons/mob/actions/actions_neuromods.dmi'
	action_icon_state = "phantom_shift"
	action_background_icon_state = "bg_alien"
	charge_max = 90 SECONDS

/obj/effect/proc_holder/spell/self/mimic_dimensional_walk/cast(mob/user = usr)
	if(!ismimic(user))
		return
	var/mob/living/simple_animal/hostile/alien_mimic/mimic_user = user
	var/list/possible_targets = mimic_user.mimic_team.members
	possible_targets -= mimic_user.mind //Don't wanna teleport to yourself
	if(!LAZYLEN(possible_targets))
		to_chat("<span class='notice'>There are no other mimics to teleport to.</span>")
		revert_cast(mimic_user)
		return


	var/datum/mind/target = input(mimic_user, "Choose a target to teleport to.", "Dimensional Walk") as null|anything in possible_targets
	if(!target)
		revert_cast(mimic_user)
		return
	var/turf/user_turf = get_turf(user)
	user_turf.add_emitter(/obj/emitter/mimic/phantom_shift,"phantom_shift",burst_mode=TRUE)
	do_teleport(mimic_user,get_turf(target.current))

/obj/effect/proc_holder/spell/self/mimic_summon
	name = "Summon Mimic"
	desc = "Summon a mimic from your hivemind."
	clothes_req = FALSE
	action_icon = 'monkestation/icons/mob/actions/actions_neuromods.dmi'
	action_icon_state = "phantom_shift"
	action_background_icon_state = "bg_alien"
	charge_max = 120 SECONDS

/obj/effect/proc_holder/spell/self/mimic_summon/cast(mob/user = usr)
	if(ismimic(user))
		var/mob/living/simple_animal/hostile/alien_mimic/mimic_user = user
		var/list/possible_targets = mimic_user.mimic_team.members
		possible_targets -= user.mind //Don't wanna summon yourself
		for(var/candidate in possible_targets)
			if(istype(candidate, /mob/living/simple_animal/hostile/alien_mimic/etheric_clone))
				possible_targets -= candidate

		var/datum/mind/target = input(user, "Choose a target to summon.", "Summon Mimic") as null|anything in possible_targets
		if(!target)
			to_chat("<span class='notice'>There are no other mimics to summon.</span>")
			revert_cast(user)
			return
		var/turf/target_turf = get_turf(target.current)
		target_turf.add_emitter(/obj/emitter/mimic/phantom_shift,"phantom_shift",burst_mode=TRUE)
		do_teleport(target.current,get_turf(user))
