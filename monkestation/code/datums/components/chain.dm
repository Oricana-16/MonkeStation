
/*
This component attaches to things that'll follow another object
Like connecting a person to a wheelchair so they get dragged behind it
*/
/datum/component/chain
	//The thing the parent will follow
	var/atom/movable/attachment_point

	var/atom/movable/owner
	var/max_dist

	var/datum/beam/tether_beam

/datum/component/chain/Initialize(target, max_dist=3)
	if(!ismovableatom(parent) || !ismovableatom(target))
		return COMPONENT_INCOMPATIBLE

	owner = parent
	attachment_point = target
	src.max_dist = max_dist

	tether_beam = owner.Beam(target, "usb_cable_beam", 'icons/obj/wiremod.dmi')

	RegisterSignal(target, COMSIG_MOVABLE_PRE_MOVE, .proc/on_attachment_move)
	RegisterSignal(owner, COMSIG_MOVABLE_PRE_MOVE, .proc/on_parent_move)
	RegisterSignal(owner, COMSIG_ATOM_ATTACK_HAND, .proc/on_parent_touched)

/datum/component/chain/Destroy(force, silent)
	. = ..()
	qdel(tether_beam)

/datum/component/chain/proc/on_attachment_move(atom/movable/mover, newloc)
	SIGNAL_HANDLER

	if(!owner)
		qdel(src)
		return

	if(owner.anchored)
		return COMPONENT_MOVABLE_BLOCK_PRE_MOVE

	var/dist = get_dist(owner,newloc)
	if(dist < max_dist)
		return

	owner.Move(get_step_towards(parent,mover))

	if(isliving(owner))
		var/mob/living/living_owner = owner
		living_owner.Knockdown(1 SECONDS)

	if(dist > max_dist)
		owner.visible_message("<span class='notice'>The tether snaps!</span>")
		qdel(src)

/datum/component/chain/proc/on_parent_move(atom/movable/mover, newloc)
	SIGNAL_HANDLER

	if(!attachment_point)
		qdel(src)
		return

	if(attachment_point.anchored)
		return COMPONENT_MOVABLE_BLOCK_PRE_MOVE

	var/dist = get_dist(attachment_point,newloc)
	if(dist < max_dist)
		return

	if(dist >= max_dist)
		var/mob/living/living_owner = owner
		living_owner.Knockdown(1 SECONDS)
		to_chat(owner,"<span class='notice'>You trip on the tether!</span>")
		return COMPONENT_MOVABLE_BLOCK_PRE_MOVE

/datum/component/chain/proc/on_parent_touched(datum/source, mob/user)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, .proc/untie_parent, user)

/datum/component/chain/proc/untie_parent(mob/user)
	if(user == owner)
		user.visible_message("<span class='notice'>[user] begins untying the cable from \himself.</span>","<span class='notice'>You begin untying the cable from yourself.</span>")
	else
		user.visible_message("<span class='notice'>[user] begins untying the cable from [owner].</span>","<span class='notice'>You begin untying the cable from [owner].</span>")
	if(do_mob(user, owner, 10 SECONDS))
		qdel(src)

