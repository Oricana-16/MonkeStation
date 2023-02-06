/mob/living/simple_animal/hostile/alien_mimic/tier3/launching
	name = "launching mimic"
	real_name = "launching mimic"
	icon_state = "greater"
	icon_living = "greater"
	hivemind_modifier = "launching"
	melee_damage = 8
	playstyle_string = "<span class='big bold'>You are a launching mimic,</span></b> you can launch yourself in a direction, dealing damage based on the distance.<b>"

/mob/living/simple_animal/hostile/alien_mimic/tier3/launching/Initialize(mapload)
	. = ..()
	var/obj/effect/proc_holder/spell/pointed/mimic_launch/launch = new
	AddSpell(launch)

//Abilities
/obj/effect/proc_holder/spell/pointed/mimic_launch
	name = "Launch"
	desc = "Launch yourself in a direction, dealing massive damage to wherever you hit"
	clothes_req = FALSE
	action_icon = 'monkestation/icons/mob/actions/actions_neuromods.dmi'
	action_icon_state = "phantom_shift"
	action_background_icon_state = "bg_alien"
	charge_max = 30 SECONDS
	var/turf/start_turf
	var/damage_multiplier = 3 //Damage dealt per turf traveled

/obj/effect/proc_holder/spell/pointed/mimic_launch/cast(list/targets,mob/user = usr)
	if(!ismimic(user))
		return

	var/mob/living/simple_animal/hostile/alien_mimic/mimic_user = user

	if(mimic_user.disguised)
		to_chat(user, "<span class='danger'>You can't use this while disguised!</span>")
		revert_cast(mimic_user)
		return

	for(var/target in targets)
		start_turf = get_turf(user)
		var/turf/target_turf = get_turf(target)

		RegisterSignal(user, COMSIG_MOVABLE_IMPACT, .proc/launch_impact)
		var/launch_target = get_edge_target_turf(target_turf, get_dir(get_step_away(user, target_turf), target_turf))

		user.safe_throw_at(launch_target, 15, 2, force = MOVE_FORCE_EXTREMELY_STRONG, spin = FALSE)
		return
	revert_cast(user)

/obj/effect/proc_holder/spell/pointed/mimic_launch/can_cast(mob/living/simple_animal/hostile/alien_mimic/tier3/launching/user = usr)
	if(istype(user) && user.disguised) //Dashing while disguised would be a bit too much
		to_chat(user, "<span class='danger'>You cannot charge while disguised!</span>")
		return FALSE
	return ..()

/obj/effect/proc_holder/spell/pointed/mimic_launch/proc/launch_impact(datum/source, atom/movable/hit_atom)
	UnregisterSignal(source, COMSIG_MOVABLE_IMPACT)

	if(!isliving(source))
		return

	if(!istype(hit_atom))
		return

	var/mob/living/source_mob = source


	var/distance_traveled = get_dist(start_turf,get_turf(hit_atom))
	var/damage = distance_traveled * damage_multiplier

	if(isliving(hit_atom))
		var/mob/living/living_target = hit_atom
		living_target.adjustBruteLoss(damage)
		living_target.Knockdown(distance_traveled SECONDS)

	if(isstructure(hit_atom))
		var/obj/structure/hit_structure = hit_atom
		hit_structure.obj_integrity -= damage


	if(!hit_atom.anchored)
		var/knockback_target = get_edge_target_turf(hit_atom, source_mob.dir)
		hit_atom.safe_throw_at(knockback_target, distance_traveled, distance_traveled/2, force = MOVE_FORCE_EXTREMELY_STRONG)
