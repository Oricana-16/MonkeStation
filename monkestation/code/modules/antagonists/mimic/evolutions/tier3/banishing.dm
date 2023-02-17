/mob/living/simple_animal/hostile/alien_mimic/tier3/banishing
	name = "banishing mimic"
	real_name = "banishing mimic"
	// icon_state = "shifty"
	// icon_living = "shifty"
	hivemind_modifier = "banishing"
	melee_damage = 8
	playstyle_string = "<span class='big bold'>You are a banishing mimic,</span></b> you can send enemies to random places on the station.<b>"

/mob/living/simple_animal/hostile/alien_mimic/tier3/banishing/Initialize(mapload)
	. = ..()
	var/obj/effect/proc_holder/spell/pointed/mimic_phantom_shift/shift = new
	var/obj/effect/proc_holder/spell/targeted/mimic_banish/banish = new
	AddSpell(shift)
	AddSpell(banish)

//Abilities
/obj/effect/proc_holder/spell/targeted/mimic_banish
	name = "Banish"
	desc = "Force a target to a random place on the station."
	charge_max = 1 MINUTES
	clothes_req = FALSE
	invocation_type = "none"
	action_icon = 'monkestation/icons/mob/actions/actions_neuromods.dmi'
	action_icon_state = "phantom_shift"
	action_background_icon_state = "bg_alien"

/obj/effect/proc_holder/spell/targeted/mimic_banish/cast(list/targets, mob/user = usr)
	if(!ismimic(user))
		return

	if(movement_type & VENTCRAWLING)
		return

	var/mob/living/simple_animal/hostile/alien_mimic/mimic_user = user

	if(mimic_user.disguised)
		to_chat(user, "<span class='danger'>You can't use this while disguised!</span>")
		revert_cast(mimic_user)
		return

	for(var/mob/living/target in targets)
		if(!(get_turf(target) in view(7, get_turf(user))))
			revert_cast(user)
			return

		do_teleport(target,find_safe_turf())
		to_chat(target,"<span class='warning'>You're vision briefly goes black as you appear somewhere else!</span>")
		target.Stun(3 SECONDS)

		return

	revert_cast(user)
