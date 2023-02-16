/mob/living/simple_animal/hostile/alien_mimic/tier2/etheric
	name = "etheric mimic"
	real_name = "etheric mimic"
	// icon_state = "etheric"
	// icon_living = "etheric"
	melee_damage = 7
	secondary_damage_type = TOX
	hivemind_modifier = "etheric"
	playstyle_string = "<span class='big bold'>You are an etheric mimic,</span></b> you deal poison damage and can temporarily summon another mimic.</b>"
	possible_evolutions = list(
		"plentiful - 2 clones" = /mob/living/simple_animal/hostile/alien_mimic/tier3/plentiful
	)

/mob/living/simple_animal/hostile/alien_mimic/tier2/etheric/Initialize(mapload)
	. = ..()
	var/obj/effect/proc_holder/spell/self/mimic_clone_request/request_clone = new
	AddSpell(request_clone)

// Mimic Clone
/mob/living/simple_animal/hostile/alien_mimic/etheric_clone
	name = "etheric mimic"
	real_name = "etheric mimic"
	can_evolve = FALSE
	// icon_state = "etheric"
	// icon_living = "etheric"
	melee_damage = 7
	secondary_damage_type = TOX
	hivemind_modifier = "etheric"
	playstyle_string = "<span class='big bold'>You are an etheric mimic clone,</span></b> you can summon yourself or be summoned temporarily.</b>"
	var/mob/living/simple_animal/hostile/alien_mimic/tier2/etheric/origin_mimic

/mob/living/simple_animal/hostile/alien_mimic/etheric_clone/Life()
	if(origin_mimic.stat == DEAD)
		qdel(src)

// Abilities
/obj/effect/proc_holder/spell/self/mimic_clone
	name = "Clone"
	desc = "Temporarily split into two mimics."
	action_icon = 'icons/mob/actions/actions_hive.dmi'
	action_icon_state = "warp"
	clothes_req = FALSE
	action_background_icon_state = "bg_alien"
	charge_max = 90 SECONDS
	var/mob/living/simple_animal/hostile/alien_mimic/etheric_clone/clone_mimic

/obj/effect/proc_holder/spell/self/mimic_clone/cast(mob/living/simple_animal/hostile/alien_mimic/tier2/etheric/user)
	if(!istype(user))
		revert_cast(user)
		return

	if(user.disguised)
		to_chat(user,"<span class='notice'>You can't clone yourself while disguised!</span>")
		revert_cast(user)
		return

	clone_mimic.forceMove(get_turf(user))
	user.visible_message("<span class='danger'>A second mimic falls out of [user]</span>")

	addtimer(CALLBACK(src, .proc/unsummon_mimic, user), 45 SECONDS)

/obj/effect/proc_holder/spell/self/mimic_clone/proc/unsummon_mimic(mob/living/simple_animal/hostile/alien_mimic/tier2/etheric/user)
	clone_mimic.forceMove(user)
	clone_mimic.visible_message("<span class='danger'>[clone_mimic] disappears into thin air!</span>")


/obj/effect/proc_holder/spell/self/mimic_clone_request
	name = "Request Clone"
	desc = "Request a ghost to become your clone."
	action_icon = 'icons/mob/actions/actions_hive.dmi'
	action_icon_state = "warp"
	clothes_req = FALSE
	action_background_icon_state = "bg_alien"
	charge_max = 30 SECONDS
	var/mob/living/simple_animal/hostile/alien_mimic/etheric_clone/clone_mimic

/obj/effect/proc_holder/spell/self/mimic_clone_request/cast(mob/living/simple_animal/hostile/alien_mimic/tier2/etheric/user)
	if(!istype(user))
		revert_cast(user)
		return

	var/list/possible_clones = list()
	possible_clones = pollGhostCandidates("An etheric mimic ([user.real_name]) is looking for a player to become their clone.")

	if(LAZYLEN(possible_clones))
		var/mob/dead/observer/picked_clone = pick(possible_clones)

		clone_mimic = new(user)
		clone_mimic.origin_mimic = user
		clone_mimic.name = "etheric mimic"
		clone_mimic.real_name = user.real_name + "'s clone"
		clone_mimic.toggle_ai(AI_OFF)
		clone_mimic.mimic_team = user.mimic_team

		clone_mimic.key = picked_clone.key
		to_chat(user, "<span class='notice'>You created a clone!</span>")

		var/obj/effect/proc_holder/spell/self/mimic_clone/clone = new
		user.AddSpell(clone)
		clone.clone_mimic = clone_mimic
	else
		to_chat(user, "<span class='notice'>You were unable to summon a clone, try again later!</span>")

	qdel(src)
