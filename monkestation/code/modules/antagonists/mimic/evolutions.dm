//Voltaic Mimics

/mob/living/simple_animal/hostile/alien_mimic/voltaic
	name = "voltaic mimic"
	real_name = "voltaic mimic"
	melee_damage = 5
	secondary_damage_type = BURN
	hivemind_modifier = "Voltaic"
	can_evolve = FALSE

/mob/living/simple_animal/hostile/alien_mimic/voltaic/Initialize(mapload)
	. = ..()
	var/datum/action/innate/mimic_emp/emp = new
	emp.Grant(src)

/mob/living/simple_animal/hostile/alien_mimic/voltaic/death(gibbed)
	tesla_zap(src, 5, 4000)
	..()

/mob/living/simple_animal/hostile/alien_mimic/voltaic/AttackingTarget()
	if(!isliving(target))
		return ..()

	var/mob/living/victim = target

	victim.Stun(1 SECONDS)
	victim.electrocute_act(1, src)
	..()

/datum/action/innate/mimic_emp
	name = "EMP"
	icon_icon = 'icons/mob/actions/actions_clockcult.dmi'
	button_icon_state = "Abscond"
	background_icon_state = "bg_alien"

/datum/action/innate/mimic_emp/Activate()
	empulse(owner, 7, 4)
