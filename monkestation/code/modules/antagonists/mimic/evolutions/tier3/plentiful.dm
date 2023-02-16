/mob/living/simple_animal/hostile/alien_mimic/tier3/plentiful
	name = "plentiful mimic"
	real_name = "plentiful mimic"
	// icon_state = "plentiful"
	// icon_living = "plentiful"
	melee_damage = 9
	secondary_damage_type = TOX
	hivemind_modifier = "plentiful"
	playstyle_string = "<span class='big bold'>You are an plentiful mimic,</span></b> you can summon 2 mimics.</b>"


/mob/living/simple_animal/hostile/alien_mimic/tie32/plentiful/Initialize(mapload)
	. = ..()
	for(var/i in 1 to 2)
		var/obj/effect/proc_holder/spell/self/mimic_clone_request/request_clone = new
		AddSpell(request_clone)
