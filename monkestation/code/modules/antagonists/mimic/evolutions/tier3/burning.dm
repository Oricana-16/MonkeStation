/mob/living/simple_animal/hostile/alien_mimic/tier3/burning
	name = "burning mimic"
	real_name = "burning mimic"
	// icon_state = "burning"
	// icon_living = "burning"
	melee_damage = 9
	melee_damage_type = BURN
	maxbodytemp = INFINITY
	damage_coeff = list(BRUTE = 1, BURN = 0, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)
	hivemind_modifier = "burning"
	playstyle_string = "<span class='big bold'>You are a burning mimic,</span></b> can launch fire out.</b>"

/mob/living/simple_animal/hostile/alien_mimic/tier3/burning/Initialize(mapload)
	. = ..()
	var/obj/effect/proc_holder/spell/pointed/mimic_firestrike/fire = new
	AddSpell(fire)

//Abilities
/obj/effect/proc_holder/spell/pointed/mimic_firestrike
	name = "Fire Strike"
	desc = "Shoot fire at a target."
	clothes_req = FALSE
	action_icon = 'monkestation/icons/mob/actions/actions_neuromods.dmi'
	action_icon_state = "phantom_shift"
	action_background_icon_state = "bg_alien"
	charge_max = 1 MINUTES

/obj/effect/proc_holder/spell/pointed/mimic_firestrike/cast(list/targets, mob/user = usr)
	if(!ismimic(user))
		return

	if(movement_type & VENTCRAWLING)
		return

	var/mob/living/simple_animal/hostile/alien_mimic/mimic_user = user

	if(mimic_user.disguised)
		to_chat(user, "<span class='danger'>You can't use this while disguised!</span>")
		revert_cast(mimic_user)
		return

	for(var/target in targets)
		var/turf/target_turf = get_turf(target)
		var/turf/user_turf = get_turf(user)
		if(!(target_turf in view(7, user_turf)))
			revert_cast(user)
			return

		var/list/turfs = get_line(user_turf,target_turf)

		firestrike(turfs)
		return
	revert_cast(user)

/obj/effect/proc_holder/spell/pointed/mimic_firestrike/proc/firestrike(list/turf_list)
	for(var/turf/cur_turf in turf_list)
		new /obj/effect/hotspot(cur_turf)
		for(var/mob/living/victim in cur_turf)
			victim.adjustFireLoss(15)
			victim.IgniteMob()
		sleep(0.2)
