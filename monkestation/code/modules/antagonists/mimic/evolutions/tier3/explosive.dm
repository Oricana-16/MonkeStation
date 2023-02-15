/mob/living/simple_animal/hostile/alien_mimic/tier3/explosive
	name = "explosive mimic"
	real_name = "explosive mimic"
	// icon_state = "thermal"
	// icon_living = "thermal"
	melee_damage = 9
	melee_damage_type = BURN
	maxbodytemp = INFINITY
	damage_coeff = list(BRUTE = 1, BURN = 0, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)
	hivemind_modifier = "Explosive"
	playstyle_string = "<span class='big bold'>You are a explosive mimic,</span></b> you can explode, dealing massive damage nearby.</b>"
	absorption_heal = 80

/mob/living/simple_animal/hostile/alien_mimic/tier3/explosive/Initialize(mapload)
	. = ..()
	var/obj/effect/proc_holder/spell/self/mimic_explosion/explode = new
	AddSpell(explode)

/mob/living/simple_animal/hostile/alien_mimic/tier3/explosive/death(gibbed)
	explosion(get_turf(src),-1,2,5, flame_range = 5)
	..()

/mob/living/simple_animal/hostile/alien_mimic/tier3/explosive/latch(mob/living/target)
	. = ..()
	if(!.)
		return

//Abilities
/obj/effect/proc_holder/spell/self/mimic_explosion
	name = "Explosion"
	desc = "Explode. <b>Warning:</b> Deals 40% of health to the user."
	clothes_req = FALSE
	action_icon = 'monkestation/icons/mob/actions/actions_neuromods.dmi'
	action_icon_state = "phantom_shift"
	action_background_icon_state = "bg_alien"
	charge_max = 3 MINUTES

/obj/effect/proc_holder/spell/self/mimic_explosion/cast(mob/user = usr)
	if(!ismimic(user))
		return

	if(movement_type & VENTCRAWLING)
		return

	var/mob/living/simple_animal/hostile/alien_mimic/mimic_user = user

	if(mimic_user.disguised)
		to_chat(user, "<span class='danger'>You can't use this while disguised!</span>")
		revert_cast(mimic_user)
		return

	for(var/mob/living/victim in oview(7))
	explosion(get_turf(user),-1,1,4, flame_range = 3)
	mimic_user.visible_message("<span class='userdanger'>[mimic_user] explodes!</span>")
