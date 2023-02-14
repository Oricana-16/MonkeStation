// TODO: Effects on presence

/mob/living/simple_animal/hostile/alien_mimic/tier3/present
	name = "present mimic"
	real_name = "present mimic"
	// icon_state = "kinetic"
	// icon_living = "kinetic"
	hivemind_modifier = "present"
	melee_damage = 8
	secondary_damage_type = BRUTE
	playstyle_string = "<span class='big bold'>You are a present mimic,</span></b> you can force nearby people down and pull them towards you.<b>"

/mob/living/simple_animal/hostile/alien_mimic/tier3/present/Initialize(mapload)
	. = ..()
	var/obj/effect/proc_holder/spell/self/mimic_presence/presence = new
	var/obj/effect/proc_holder/spell/self/mimic_kinetic_blast/kinetic_blast = new
	AddSpell(presence)
	AddSpell(kinetic_blast)

//Abilities
/obj/effect/proc_holder/spell/self/mimic_presence
	name = "Presence"
	desc = "Force nearby beings down."
	clothes_req = FALSE
	action_icon = 'monkestation/icons/mob/actions/actions_neuromods.dmi'
	action_icon_state = "phantom_shift"
	action_background_icon_state = "bg_alien"
	charge_max = 60 SECONDS

/obj/effect/proc_holder/spell/self/mimic_presence/cast(mob/user = usr)
	if(!ismimic(user))
		return

	var/mob/living/simple_animal/hostile/alien_mimic/mimic_user = user

	if(mimic_user.disguised)
		to_chat(user, "<span class='danger'>You can't use this while disguised!</span>")
		revert_cast(mimic_user)
		return

	for(var/mob/living/carbon/victim in oview(7))
		victim.Knockdown(5 SECONDS)
		victim.Stun(5 SECONDS)
		to_chat("<span class='userdanger'>A wave of pressure flowing from [mimic_user] forces you down.</span>")
