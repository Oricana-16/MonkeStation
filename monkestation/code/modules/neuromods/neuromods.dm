//Phantom Shift Neuromod

/obj/item/autosurgeon/neuromod/phantom_shift
	name = "phantom shift neuromod"
	starting_organ = list(/obj/item/organ/cyberimp/neuromod/targeted/phantom_shift)

/obj/item/organ/cyberimp/neuromod/targeted/phantom_shift
	name = "Phantom Shift"
	desc = "This neuromod allows you teleport to a nearby area."
	cast_message = "<span class='notice'>You feel nothingness open infront of you. Click on a target area.</span>"
	cancel_message = "<span class='notice'>You feel the gap in space close before you.</span>"
	max_distance = 4
	cooldown = 30 SECONDS
	actions_types = list(/datum/action/item_action/organ_action/use)

/obj/item/organ/cyberimp/neuromod/targeted/phantom_shift/activate(target)
	..()
	var/turf/target_turf = get_turf(target)
	owner.visible_message("[owner] vanishes in a puff of black smoke!","You step into nothing and silently appear in a new area.")
	do_teleport(owner, target_turf, no_effects = TRUE)

//Kinetic Blast

/obj/item/autosurgeon/neuromod/kinetic_blast
	name = "kinetic blast neuromod"
	starting_organ = list(/obj/item/organ/cyberimp/neuromod/kinetic_blast)

/obj/item/organ/cyberimp/neuromod/kinetic_blast
	name = "Kinetic Blast"
	desc = "This neuromod blasts nearby people and objects away."
	cooldown = 30 SECONDS
	actions_types = list(/datum/action/item_action/organ_action/use)

/obj/item/organ/cyberimp/neuromod/kinetic_blast/ui_action_click()
	. = ..()
	if(.)
		return
	owner.add_emitter(/obj/emitter/kinetic_blast,"kinetic_blast",burst_mode=TRUE)
	playsound(get_turf(owner),'sound/magic/repulse.ogg', 100, 1)
	owner.visible_message("<span class='danger'>[owner] sends out a wave of dark energy, knocking everything around!</span>","<span class='danger'>You activate the neuromod, pushing everything away!</span>")
	var/turf/owner_turf = get_turf(owner)
	var/list/thrown_items = list()
	for(var/atom/movable/atom as mob|obj in orange(7, owner_turf))
		if(atom.anchored || thrown_items[atom])
			continue
		var/throwtarget = get_edge_target_turf(owner_turf, get_dir(owner_turf, get_step_away(atom, owner_turf)))
		atom.safe_throw_at(throwtarget, 10, 1, force = MOVE_FORCE_EXTREMELY_STRONG)
		thrown_items[atom] = atom

//Stalk

/obj/item/autosurgeon/neuromod/stalk
	name = "stalk neuromod"
	starting_organ = list(/obj/item/organ/cyberimp/neuromod/targeted/stalk)

/obj/item/organ/cyberimp/neuromod/targeted/stalk
	name = "Stalk"
	desc = "This neuromod lets you hide in a person's shadows."
	cooldown = 10 SECONDS
	max_distance = 1
	cast_message = "<span class='notice'>You get ready to fall into the shadows.</span>"
	cancel_message = "<span class='notice'>You ease up.</span>"
	var/stalking = FALSE
	actions_types = list(/datum/action/item_action/organ_action/use)

/obj/item/organ/cyberimp/neuromod/targeted/stalk/ui_action_click()
	if(!COOLDOWN_FINISHED(src, neuromod_cooldown))
		to_chat(owner, "<span class='warning'>You must wait [COOLDOWN_TIMELEFT(src, neuromod_cooldown)*0.1] seconds to use [src] again!</span>")
		return TRUE
	if(stalking)
		stalking = FALSE
		owner.visible_message("<span class='danger'>[owner] emerges from a shadow!</span>","<span class='notice'>You leave the shadow.</span>")
		REMOVE_TRAIT(owner, TRAIT_NOBREATH, "neuromod")
		var/turf/target_turf = get_turf(owner)
		owner.forceMove(target_turf)
		return
	if(!active)
		active = TRUE
		owner.click_intercept = src
		to_chat(owner, cast_message)
	else
		active = FALSE
		owner.click_intercept = null
		to_chat(owner, cancel_message)

/obj/item/organ/cyberimp/neuromod/targeted/stalk/activate(target)
	if(target == owner)
		to_chat(owner,"<span class='notice'>You can't enter your own shadow!</span>")
		return
	if(!ismob(target))
		to_chat(owner,"<span class='notice'>You can't enter an object's shadow!</span>")
		return
	..()
	stalking = TRUE
	ADD_TRAIT(owner, TRAIT_NOBREATH, "neuromod")
	owner.visible_message("<span class='danger'>[owner] falls into [target]'s shadow!</span>","<span class='notice'>You enter [target]'s shadow.</span>")
	owner.forceMove(target)

//Smuggle

/obj/item/autosurgeon/neuromod/smuggle
	name = "smuggle neuromod"
	starting_organ = list(/obj/item/organ/cyberimp/neuromod/smuggle)

/obj/item/organ/cyberimp/neuromod/smuggle
	name = "Smuggle"
	desc = "This neuromod lets you store an item inside your body."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "implant"
	cooldown = 3 SECONDS
	var/obj/item/stored_item
	actions_types = list(/datum/action/item_action/organ_action/use)

/obj/item/organ/cyberimp/neuromod/smuggle/Insert(mob/living/carbon/M, special, drop_if_replaced)
	. = ..()
	RegisterSignal(owner, COMSIG_MOB_DEATH, .proc/owner_death)

/obj/item/organ/cyberimp/neuromod/smuggle/Remove(mob/living/carbon/M, special)
	. = ..()
	UnregisterSignal(owner, COMSIG_MOB_DEATH)

/obj/item/organ/cyberimp/neuromod/smuggle/ui_action_click()
	. = ..()
	if(.)
		return
	if(stored_item)
		icon_state = initial(icon_state)
		icon = initial(icon)
		owner.put_in_hands(stored_item)
		owner.visible_message("<span class='notice'>\The [stored_item] falls out of [owner]'s skin and into \his hand.</span>","<span class='notice'>\The [stored_item] phases out of your skin and into your hand.</span>")
		stored_item = null
	else
		var/list/hand_items = list(owner.get_active_held_item(),owner.get_inactive_held_item())
		for(var/obj/item/item in hand_items) //Put the item away
			if(item.item_flags & ABSTRACT)
				continue
			stored_item = item
			owner.visible_message("<span class='notice'>\The [item] disappears into [owner]'s into \his hand.</span>","<span class='notice'>The [item] sinks into your skin.</span>")
			icon_state = item.icon_state
			icon = item.icon
			item.forceMove(owner)
			break
	owner.update_action_buttons()

/obj/item/organ/cyberimp/neuromod/smuggle/proc/owner_death()
	icon_state = initial(icon_state)
	icon = initial(icon)
	stored_item.forceMove(get_turf(owner))
	owner.visible_message("<span class='notice'>\The [stored_item] falls out of [owner]'s corpse</span>")
	stored_item = null

//Scramble Electronics

/obj/item/autosurgeon/neuromod/scramble
	name = "scramble electronics neuromod"
	starting_organ = list(/obj/item/organ/cyberimp/neuromod/targeted/scramble)

/obj/item/organ/cyberimp/neuromod/targeted/scramble
	name = "Scramble Electronics"
	desc = "This neuromod allows to mess with nearby electronics."
	cast_message = "<span class='notice'>You feel electricity spark behind your eyes. Click on a target area.</span>"
	cancel_message = "<span class='notice'>The electricity calms.</span>"
	max_distance = 3
	cooldown = 30 SECONDS
	actions_types = list(/datum/action/item_action/organ_action/use)

/obj/item/organ/cyberimp/neuromod/targeted/scramble/activate(target)
	..()
	var/atom/movable/movable_target = target
	to_chat(owner,"<span class='notice'>You focus on \the [movable_target], messing with [movable_target.p_their()] electronics.</span")
	movable_target.emp_act(EMP_HEAVY)

//Mimic Composition

/obj/item/autosurgeon/neuromod/mimic_composition
	name = "mimic composition neuromod"
	starting_organ = list(/obj/item/organ/cyberimp/neuromod/mimic_composition)

/obj/item/organ/cyberimp/neuromod/mimic_composition
	name = "Mimic Composition"
	desc = "This neuromod allows you to ventcrawl."

/obj/item/organ/cyberimp/neuromod/mimic_composition/Insert(mob/living/carbon/user, special, drop_if_replaced)
	. = ..()
	to_chat(owner, "<span class='notice'>Your skin feels odd and slimy.</span>")
	user.ventcrawler = VENTCRAWLER_ALWAYS

/obj/item/organ/cyberimp/neuromod/mimic_composition/Remove(mob/living/carbon/user, special)
	. = ..()
	user.ventcrawler = VENTCRAWLER_NONE

//Mimic Composition

/obj/item/autosurgeon/neuromod/electrostatic
	name = "electrostatic burst neuromod"
	starting_organ = list(/obj/item/organ/cyberimp/neuromod/targeted/electrostatic)

/obj/item/organ/cyberimp/neuromod/targeted/electrostatic
	name = "Electrostatic Burst"
	desc = "This neuromod allows to emit a focused burst of electricity."
	cast_message = "<span class='notice'>You feel electricity under your skin. Click on a target area.</span>"
	cancel_message = "<span class='notice'>The electricity calms.</span>"
	max_distance = 9
	cooldown = 80 SECONDS
	actions_types = list(/datum/action/item_action/organ_action/use)

/obj/item/organ/cyberimp/neuromod/targeted/electrostatic/activate(target)
	..()
	var/turf/target_turf = get_turf(target)
	to_chat(owner,"<span class='notice'>Sparks appear in the air as you focus on an area.</span")
	zap(target_turf)

/obj/item/organ/cyberimp/neuromod/targeted/electrostatic/proc/zap(atom/target_turf)
	for(var/mob/living/possible_target in view(4,target_turf))
		if(!istype(possible_target) || possible_target == owner)
			return
		target_turf.Beam(possible_target, icon_state="lightning[rand(1,12)]", time=5, maxdistance = 32)
		if(possible_target.electrocute_act(15, owner, 1, SHOCK_NOSTUN))
			if(iscarbon(possible_target))
				var/mob/living/carbon/carbon_target = possible_target
				carbon_target.Stun(5 SECONDS)
				carbon_target.Knockdown(rand(6 SECONDS, 8 SECONDS))
		to_chat(possible_target,"<span class='danger'>A ball of energy appears from [owner.name] and zaps you!</span>")

//Mimic Composition

/obj/item/autosurgeon/neuromod/psychoshock
	name = "psychoshock neuromod"
	starting_organ = list(/obj/item/organ/cyberimp/neuromod/targeted/psychoshock)

/obj/item/organ/cyberimp/neuromod/targeted/psychoshock
	name = "Psychoshock"
	desc = "This neuromod allows to confuse targets."
	cast_message = "<span class='notice'>You ready yourself to shake up somebody's mind. Click on a target.</span>"
	cancel_message = "<span class='notice'>You ease up.</span>"
	max_distance = 9
	cooldown = 1 MINUTES
	actions_types = list(/datum/action/item_action/organ_action/use)

/obj/item/organ/cyberimp/neuromod/targeted/psychoshock/activate(target)
	if(!isliving(target))
		return
	..()
	var/mob/living/living_target = target
	to_chat(living_target,"<span class='userdanger'>Your brain feels scrambled!</span>")
	to_chat(owner,"<span class='notice'>You twist and turn [living_target.p_their()] mind.</span>")
	living_target.Stun(5 SECONDS)
	living_target.jitteriness += 15
	living_target.confused += 10
	living_target.drop_all_held_items()

/obj/emitter/kinetic_blast
	particles = new/particles/kinetic_blast

/particles/kinetic_blast
	width = 124
	height = 124
	count = 128
	spawning = SPAWN_ALL_PARTICLES_INSTANTLY
	lifespan = 1 SECONDS
	fade = 0.5 SECONDS
	position = generator("box", list(-20,-20), list(20,20), NORMAL_RAND)
	velocity = generator("circle", -25, 25, NORMAL_RAND)
	friction = 0.25
	color = generator("color", "#630a63", "#bd0aa5", NORMAL_RAND)


