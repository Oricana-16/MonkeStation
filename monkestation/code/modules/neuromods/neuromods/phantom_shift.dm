/obj/item/autosurgeon/neuromod/phantom_shift
	name = "phantom shift neuromod"
	starting_organ = list(/obj/item/organ/cyberimp/neuromod/targeted/phantom_shift)

/obj/item/organ/cyberimp/neuromod/targeted/phantom_shift
	name = "Phantom Shift"
	desc = "This neuromod allows you teleport to a nearby area."
	icon_state = "phantom_shift"
	cast_message = "<span class='notice'>You feel nothingness open infront of you. Click on a target area.</span>"
	cancel_message = "<span class='notice'>You feel the gap in space close before you.</span>"
	max_distance = 4
	cooldown = 30 SECONDS
	actions_types = list(/datum/action/item_action/organ_action/use)

/obj/item/organ/cyberimp/neuromod/targeted/phantom_shift/activate(target)
	var/turf/target_turf = get_turf(target)
	if(target_turf.density)
		to_chat(owner,"<span class='notice'>You can't teleport there!</span>")
	..()
	owner.visible_message("<span class='danger'>[owner] vanishes in a puff of black smoke!</span>","<span class='notice'>You step into nothing and silently appear in a new area.</span>")
	do_teleport(owner, target_turf, no_effects = TRUE)
