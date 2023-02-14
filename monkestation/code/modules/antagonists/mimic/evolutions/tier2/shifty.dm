/mob/living/simple_animal/hostile/alien_mimic/tier2/shifty
	name = "shifty mimic"
	real_name = "shifty mimic"
	// icon_state = "shifty"
	// icon_living = "shifty"
	hivemind_modifier = "Shifty"
	melee_damage = 5
	playstyle_string = "<span class='big bold'>You are a shifty mimic,</span></b> you can teleport around, bringing whoever you're latched onto with you<b>"
	possible_evolutions = list(
		"transportive" = /mob/living/simple_animal/hostile/alien_mimic/tier3/transportive
	)

/mob/living/simple_animal/hostile/alien_mimic/tier2/shifty/Initialize(mapload)
	. = ..()
	var/obj/effect/proc_holder/spell/pointed/mimic_phantom_shift/shift = new
	AddSpell(shift)

/obj/effect/proc_holder/spell/pointed/mimic_phantom_shift
	name = "Phantom Shift"
	desc = "Quickly reform at another position, and bring anyone you're latched on to."
	clothes_req = FALSE
	action_icon = 'monkestation/icons/mob/actions/actions_neuromods.dmi'
	action_icon_state = "phantom_shift"
	action_background_icon_state = "bg_alien"
	charge_max = 30 SECONDS

/obj/effect/proc_holder/spell/pointed/mimic_phantom_shift/cast(list/targets,mob/user = usr)
	for(var/target in targets)
		var/turf/target_turf = get_turf(target)
		if(!(target_turf in view(7, get_turf(user))))
			revert_cast(user)
			return
		if(target_turf.density)
			to_chat(user,"<span class='notice'>You can't teleport there!</span>")
			revert_cast(user)
			return
		var/mob/living/teleport_with
		if(user.buckled)
			teleport_with = user.buckled
		user.add_emitter(/obj/emitter/mimic/phantom_shift,"phantom_shift",burst_mode=TRUE)
		do_teleport(user, target_turf)
		if(teleport_with)
			do_teleport(teleport_with, target_turf)
			teleport_with.buckle_mob(user,TRUE)
		return
	revert_cast(user)
