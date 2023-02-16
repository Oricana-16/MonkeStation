/mob/living/simple_animal/hostile/alien_mimic/tier3/necromantic
	name = "necromantic mimic"
	real_name = "necromantic mimic"
	melee_damage = 7
	secondary_damage_type = BRUTE
	hivemind_modifier = "necromantic"
	playstyle_string = "<span class='big bold'>You are a necromantic mimic,</span></b> you can make minds control corpses.</b>"

/mob/living/simple_animal/hostile/alien_mimic/tier3/necromantic/Initialize(mapload)
	. = ..()
	var/obj/effect/proc_holder/spell/pointed/mimic_necromancy/shift = new
	AddSpell(shift)

/obj/effect/proc_holder/spell/pointed/mimic_necromancy
	name = "Raise Dead"
	desc = "Raise a corpse as a minion. <b>WARNING:</b> if you move too far from a raised corpse, it will die."
	clothes_req = FALSE
	action_icon = 'monkestation/icons/mob/actions/actions_neuromods.dmi'
	action_icon_state = "phantom_shift"
	action_background_icon_state = "bg_alien"
	charge_max = 45 SECONDS

/obj/effect/proc_holder/spell/pointed/mimic_necromancy/cast(list/targets,mob/user = usr)
	if(movement_type & VENTCRAWLING)
		return

	// TODO: add husk check
	// TODO: set corpse's language

	for(var/target in targets)
		if(!isliving(target))
			return
		var/mob/living/living_target = target

		if(living_target.stat != DEAD)
			to_chat(user,"<span class='notice'>They aren't dead!</span>")
			return

		to_chat(user,"<span class='notice'>You start summoning a ghost to overtake the corpse!</span>")
		var/list/candidates = list()
		candidates = pollGhostCandidates("Would you like to become [target] (raised by necromantic mimic).", poll_time = 10 SECONDS)

		if(!LAZYLEN(candidates))
			to_chat(user,"<span class='notice'>No ghosts took control of the corpse!</span>")
			revert_cast(user)
			return

		to_chat(user,"<span class='notice'>A ghost has taken control of the corpse!</span>")

		var/mob/dead/observer/chosen_candidate = pick(candidates)
		living_target.key = chosen_candidate.key

		to_chat(living_target,"<span class='notice big'>You have been summoned by a necromantic mimic</span><span class='notice'> if you stray too far from your summoner, you will die!</span>")

		living_target.revive(TRUE)
		living_target.AddComponent(/datum/component/distance_bound, user, 15, TRUE)
		living_target.add_emitter(/obj/emitter/mimic/necro_summon,"necro_summon")
		RegisterSignal(living_target,COMSIG_MOB_DEATH, .proc/unsummon)
		return
	revert_cast(user)

/obj/effect/proc_holder/spell/pointed/mimic_necromancy/proc/unsummon(mob/target)
	SIGNAL_HANDLER

	target.remove_emitter("necro_summon")

/obj/emitter/mimic/necro_summon
	particles = new/particles/mimic/necro_summon

/particles/mimic/necro_summon
	width = 124
	height = 124
	count = 128
	spawning = 10
	lifespan = 0.5 SECONDS
	fade = 0.2 SECONDS
	position = generator("box", list(-10,10), list(10,20), UNIFORM_RAND)
	velocity = generator("box", -5, 5, NORMAL_RAND)
	friction = 0.15
	color = "#9b319b"
