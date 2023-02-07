/mob/living/simple_animal/hostile/alien_mimic/tier3/tesla
	name = "tesla mimic"
	real_name = "tesla mimic"
	icon_state = "voltaic"
	icon_living = "voltaic"
	hivemind_modifier = "tesla"
	melee_damage = 7
	playstyle_string = "<span class='big bold'>You are a tesla mimic,</span></b> shock everyone nearby.<b>"

/mob/living/simple_animal/hostile/alien_mimic/tier3/tesla/Initialize(mapload)
	. = ..()
	var/obj/effect/proc_holder/spell/self/mimic_tesla/tesla = new
	AddSpell(tesla)
	var/obj/effect/proc_holder/spell/self/mimic_emp/emp = new
	AddSpell(emp)

//Abilities
/obj/effect/proc_holder/spell/self/mimic_tesla
	name = "Tesla"
	desc = "Zap everyone nearby"
	clothes_req = FALSE
	action_icon = 'monkestation/icons/mob/actions/actions_neuromods.dmi'
	action_icon_state = "phantom_shift"
	action_background_icon_state = "bg_alien"
	charge_max = 30 SECONDS

/obj/effect/proc_holder/spell/self/mimic_tesla/cast(mob/user = usr)
	if(!ismimic(user))
		revert_cast(user)
		return

	var/mob/living/simple_animal/hostile/alien_mimic/mimic_user = user

	if(mimic_user.disguised)
		to_chat(user, "<span class='danger'>You can't use this while disguised!</span>")
		revert_cast(mimic_user)
		return

	tesla_zap(user, 5, 4000)



