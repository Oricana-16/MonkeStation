//Organ and Experimentor stuff

#define NEUROMOD_SUPER_RARE 1
#define NEUROMOD_RARE 4
#define NEUROMOD_UNCOMMON 7
#define NEUROMOD_COMMON 12

/obj/item/mimic_organ
	name = "mimic organ"
	desc = "A mass of black goo. The E.X.P.E.R.I-MENTOR could probably do something with this."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "stamp-clown"
	item_state = "stamp-clown"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/mimic_organ/proc/roll_neuromod()
	var/static/list/neuromod_list = list(
		/obj/item/autosurgeon/neuromod/electrostatic = NEUROMOD_RARE,
		/obj/item/autosurgeon/neuromod/phantom_shift = NEUROMOD_RARE,
		/obj/item/autosurgeon/neuromod/smuggle = NEUROMOD_RARE,
		/obj/item/autosurgeon/neuromod/stalk = NEUROMOD_SUPER_RARE,
		/obj/item/autosurgeon/neuromod/kinetic_blast = NEUROMOD_UNCOMMON,
		/obj/item/autosurgeon/neuromod/mimic_composition = NEUROMOD_UNCOMMON,
		/obj/item/autosurgeon/neuromod/scramble = NEUROMOD_COMMON,
	)
	var/obj/item/autosurgeon/neuromod/new_neuromod = pickweight(neuromod_list)
	new new_neuromod(get_turf(src))
	qdel(src)

//Autosurgeon

/obj/item/autosurgeon/neuromod
	name = "neuromod"
	desc = "A device that rebuilds your brain to give you abilities latent in the mimic's dna."
	icon = 'icons/obj/device.dmi'
	icon_state = "autoimplanter"
	item_state = "nothing"
	w_class = WEIGHT_CLASS_SMALL
	uses = 1
	starting_organ = list(/obj/item/organ/cyberimp/neuromod)

/obj/item/autosurgeon/neuromod/examine(mob/user)
	. = ..()
	for(var/obj/item/organ in storedorgan)
		. += organ.desc

/obj/item/autosurgeon/neuromod/attack_self(mob/user)
	if(user.getorganslot(ORGAN_SLOT_BRAIN_NEUROMOD))
		to_chat(user,"<span class='warning'>You already have a neuromod, any more would ruin your brain!</span>")
		return
	..()
	if(!uses)
		name = "used [name]"

/obj/item/autosurgeon/neuromod/attackby(obj/item/implant, mob/user, params)
	if(istype(implant, organ_type))
		to_chat(user, "<span class='notice'>You can't fit the [implant] into [src].</span>")
	else
		return ..()

/obj/item/autosurgeon/neuromod/screwdriver_act(mob/user,obj/item/screwdriver)
	return FALSE

//Implant Status Effect

/datum/status_effect/neuromod
	id = "Neuromod"
	examine_text = "<span class='danger'>SUBJECTPRONOUN has a eye that is red and swollen.</span>"
	alert_type = null

//Neuromod Implant

/obj/item/organ/cyberimp/neuromod
	desc = "This is a neuromod."
	name = "Neuromod"
	implant_color = "#c41ae6"
	var/cooldown = 0 SECONDS
	slot = ORGAN_SLOT_BRAIN_NEUROMOD
	COOLDOWN_DECLARE(neuromod_cooldown)

/obj/item/organ/cyberimp/neuromod/ui_action_click()
	if(!COOLDOWN_FINISHED(src, neuromod_cooldown))
		to_chat(owner, "<span class='warning'>You must wait [COOLDOWN_TIMELEFT(src, neuromod_cooldown)*0.1] seconds to use [src] again!</span>")
		return TRUE
	COOLDOWN_START(src, neuromod_cooldown, cooldown)

/obj/item/organ/cyberimp/neuromod/Insert(mob/living/carbon/user, special, drop_if_replaced)
	. = ..()
	user.apply_status_effect(/datum/status_effect/neuromod)

/obj/item/organ/cyberimp/neuromod/Remove(mob/living/carbon/user, special)
	. = ..()
	user.remove_status_effect(/datum/status_effect/neuromod)

//Neuromod Implant - Targeted

/obj/item/organ/cyberimp/neuromod/targeted
	var/active = FALSE
	var/cast_message = "<span class='notice'>You start using the neuromod. Click on a target.</span>"
	var/cancel_message = "<span class='notice'>You stop using the neuromod.</span>"
	var/max_distance = 9

/obj/item/organ/cyberimp/neuromod/targeted/ui_action_click()
	if(!COOLDOWN_FINISHED(src, neuromod_cooldown))
		to_chat(owner, "<span class='warning'>You must wait [COOLDOWN_TIMELEFT(src, neuromod_cooldown)*0.1] seconds to use [src] again!</span>")
		return TRUE
	if(!active)
		active = TRUE
		owner.click_intercept = src
		to_chat(owner, cast_message)
	else
		active = FALSE
		owner.click_intercept = null
		to_chat(owner, cancel_message)

/obj/item/organ/cyberimp/neuromod/targeted/proc/activate(target)
	COOLDOWN_START(src, neuromod_cooldown, cooldown)
	return

/obj/item/organ/cyberimp/neuromod/targeted/proc/InterceptClickOn(mob/living/carbon/caller, params, atom/target)
	if(get_dist(caller,target) <= max_distance)
		activate(target)
	else
		to_chat(owner, "<span class='warning'>That place is out of your reach.</span>")
	active = FALSE
	caller.click_intercept = null


///////////////////////////////
//	Actual Neuromods Here	///
///////////////////////////////

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
	cooldown = 20 SECONDS
	actions_types = list(/datum/action/item_action/organ_action/use)

/obj/item/organ/cyberimp/neuromod/kinetic_blast/ui_action_click()
	. = ..()
	if(.)
		return
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
	desc = "This neuromod allows to ventcrawl."

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
