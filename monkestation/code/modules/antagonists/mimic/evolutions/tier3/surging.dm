/mob/living/simple_animal/hostile/alien_mimic/tier3/surging
	name = "surging mimic"
	real_name = "surging mimic"
	icon_state = "voltaic"
	icon_living = "voltaic"
	hivemind_modifier = "surging"
	melee_damage = 7
	playstyle_string = "<span class='big bold'>You are a surging mimic,</span></b> you can teleport, shocking everyone in your path.<b>"

/mob/living/simple_animal/hostile/alien_mimic/tier3/surging/Initialize(mapload)
	. = ..()
	var/obj/effect/proc_holder/spell/pointed/mimic_launch/launch = new
	AddSpell(launch)

//Abilities
/obj/effect/proc_holder/spell/pointed/mimic_launch
	name = "Surge"
	desc = "Launch yourself in a direction, dealing massive damage to wherever you hit"
	clothes_req = FALSE
	action_icon = 'monkestation/icons/mob/actions/actions_neuromods.dmi'
	action_icon_state = "phantom_shift"
	action_background_icon_state = "bg_alien"
	charge_max = 30 SECONDS
	var/shock_damage = 15

/obj/effect/proc_holder/spell/pointed/mimic_launch/cast(list/targets,mob/user = usr)
	if(!ismimic(user))
		return

	var/mob/living/simple_animal/hostile/alien_mimic/mimic_user = user

	if(mimic_user.disguised)
		to_chat(user, "<span class='danger'>You can't use this while disguised!</span>")
		revert_cast(mimic_user)
		return

	for(var/target in targets)
		var/turflist = get_line(user, get_turf(target))
		surge(user, turflist)
		user.Beam(target, icon_state="lightning[rand(1,12)]", time = 5)
		do_teleport(user,target)
		return
	revert_cast(user)

/obj/effect/proc_holder/spell/pointed/mimic_launch/can_cast(mob/living/simple_animal/hostile/alien_mimic/tier3/surging/user = usr)
	if(istype(user) && user.disguised)
		to_chat(user, "<span class='danger'>You cannot use this while disguised!</span>")
		return FALSE
	return ..()

/obj/effect/proc_holder/spell/pointed/mimic_launch/proc/surge(mob/user, turflist)
	for(var/turf/current_turf in turflist)
		var/mob/living/victim = locate() in current_turf
		victim.Stun(1 SECONDS)
		victim.electrocute_act(shock_damage, user)



