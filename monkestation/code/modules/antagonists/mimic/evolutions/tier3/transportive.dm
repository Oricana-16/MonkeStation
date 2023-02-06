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
	if(ismimic(user))
		var/mob/living/simple_animal/hostile/alien_mimic/mimic_user = user
		var/list/possible_targets = mimic_user.mimic_team.members
		possible_targets -= list(user) //Don't wanna teleport to yourself
		var/mob/target = input(user, "Choose a target to teleport to.", "Dimensional Walk") as null|anything in possible_targets
		if(!target)
			revert_cast(user)
			return
		user.add_emitter(/obj/emitter/mimic/phantom_shift,"phantom_shift",burst_mode=TRUE)
		do_teleport(user,target)

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
		possible_targets -= list(user) //Don't wanna summon yourself
		var/mob/target = input(user, "Choose a target to summon.", "Dimensional Walk") as null|anything in possible_targets
		if(!target)
			revert_cast(user)
			return
		target.add_emitter(/obj/emitter/mimic/phantom_shift,"phantom_shift",burst_mode=TRUE)
		do_teleport(target,user)
