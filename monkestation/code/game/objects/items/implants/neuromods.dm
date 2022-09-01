//TODO: Make the mimic organ work with the Experimentor
//TODO: Make the mimic organ able to be surgeried out of the mimics

/obj/item/mimic_organ
	name = "mimic organ"
	desc = "A mass of black goo. The E.X.P.E.R.I-MENTOR could probably do something with this."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "stamp-clown"
	item_state = "stamp-clown"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/autosurgeon/neuromod
	name = "neuromod"
	desc = "A device that rebuilds your brain to give you abilities latent in the mimic's dna."
	icon = 'icons/obj/device.dmi'
	icon_state = "autoimplanter"
	item_state = "nothing"
	w_class = WEIGHT_CLASS_SMALL
	uses = 1
	starting_organ = list(/obj/item/organ/cyberimp/neuromod)

/obj/item/autosurgeon/neuromod/Initialize(mapload)
	. = ..()
	for(var/implant in starting_organ)
		if(istype(implant,/obj/item/organ/cyberimp/neuromod))
			var/obj/item/organ/cyberimp/neuromod/neuro_implant
			name = "[neuro_implant.name] [name]"
			desc = "[desc] [neuro_implant.desc]"

/obj/item/autosurgeon/neuromod/attack_self(mob/user)
	if(user.getorganslot(ORGAN_SLOT_BRAIN_NEUROMOD))
		to_chat(user,"<span class='warning'>You already have a neuromod, any more would ruin your brain!</span>")
		return
	..()

/obj/item/autosurgeon/attackby(obj/item/implant, mob/user, params)
	if(istype(implant, organ_type))
		to_chat(user, "<span class='notice'>You can't fit the [implant] into [src].</span>")
	else
		return ..()

/obj/item/autosurgeon/neuromod/screwdriver_act(mob/user,obj/item/screwdriver)
	return FALSE

/obj/item/organ/cyberimp/neuromod
	name = "Neuromod"
	desc = "This is a neuromod."
	implant_color = "#c41ae6"
	var/cooldown = 0 SECONDS
	slot = ORGAN_SLOT_BRAIN_NEUROMOD
	COOLDOWN_DECLARE(neuromod_cooldown)

/obj/item/organ/cyberimp/neuromod/ui_action_click()
	if(!COOLDOWN_FINISHED(src, neuromod_cooldown))
		to_chat(owner, "<span class='warning'>You must wait [COOLDOWN_TIMELEFT(src, neuromod_cooldown)*0.1] seconds to use [src] again!</span>")
		return TRUE
	COOLDOWN_START(src, neuromod_cooldown, cooldown)

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
	owner.visible_message("[owner] vanishes in a puff of black smoke!","You step into nothing and silently appear where you wanted to.")
	do_teleport(owner, target_turf, no_effects = TRUE)

//Kinetic Blast

/obj/item/autosurgeon/neuromod/kinetic_blast
	name = "kinetic blast neuromod"
	starting_organ = list(/obj/item/organ/cyberimp/neuromod/kinetic_blast)

/obj/item/organ/cyberimp/neuromod/kinetic_blast
	name = "Kinetic Blast"
	desc = "This neuromod blasts nearby people and objects away."
	cooldown = 40 SECONDS
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
