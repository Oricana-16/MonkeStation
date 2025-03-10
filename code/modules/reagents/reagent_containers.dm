/obj/item/reagent_containers
	name = "Container"
	desc = "..."
	icon = 'icons/obj/chemical.dmi'
	icon_state = null
	w_class = WEIGHT_CLASS_TINY
	var/amount_per_transfer_from_this = 5
	var/list/possible_transfer_amounts = list(5,10,15,20,25,30)
	var/volume = 30
	var/reagent_flags
	var/list/list_reagents = null
	var/spawned_disease = null
	var/disease_amount = 20
	var/spillable = FALSE
	var/list/fill_icon_thresholds = null
	var/fill_icon_state = null // Optional custom name for reagent fill icon_state prefix
	var/prevent_grinding = FALSE //used for ungrindable stuff

/obj/item/reagent_containers/Initialize(mapload, vol)
	. = ..()
	if(isnum_safe(vol) && vol > 0)
		volume = vol
	create_reagents(volume, reagent_flags)
	if(spawned_disease)
		var/datum/disease/F = new spawned_disease()
		var/list/data = list("viruses"= list(F))
		reagents.add_reagent(/datum/reagent/blood, disease_amount, data)

	add_initial_reagents()
//MONKESTATION EDIT ADDITION
	AddElement(/datum/element/liquids_interaction, on_interaction_callback = /obj/item/reagent_containers/glass/beaker/.proc/attack_on_liquids_turf)

/obj/item/reagent_containers/Destroy()
	. = ..()
	RemoveElement(/datum/element/liquids_interaction, on_interaction_callback = /obj/item/reagent_containers/glass/beaker/.proc/attack_on_liquids_turf)

/obj/item/reagent_containers/proc/attack_on_liquids_turf(obj/item/reagent_containers/my_beaker, turf/T, mob/living/user, obj/effect/abstract/liquid_turf/liquids)
	if(!user.Adjacent(T))
		return FALSE
	if(!my_beaker.spillable)
		return FALSE
	if(!user.Adjacent(T))
		return FALSE
	if(!(user.a_intent == INTENT_HELP))
		return FALSE
	if(liquids.fire_state) //Use an extinguisher first
		to_chat(user, "<span class='warning'>You can't scoop up anything while it's on fire!</span>")
		return TRUE
	if(liquids.liquid_group.expected_turf_height == 1)
		to_chat(user, "<span class='warning'>The puddle is too shallow to scoop anything up!</span>")
		return TRUE
	var/free_space = my_beaker.reagents.maximum_volume - my_beaker.reagents.total_volume
	if(free_space <= 0)
		to_chat(user, "<span class='warning'>You can't fit any more liquids inside [my_beaker]!</span>")
		return TRUE
	var/desired_transfer = my_beaker.amount_per_transfer_from_this
	if(desired_transfer > free_space)
		desired_transfer = free_space
	if(desired_transfer > liquids.liquid_group.reagents_per_turf)
		desired_transfer = liquids.liquid_group.reagents_per_turf
	liquids.liquid_group.trans_to_seperate_group(my_beaker.reagents, desired_transfer, liquids)
	to_chat(user, "<span class='notice'>You scoop up around [round(desired_transfer)] units of liquids with [my_beaker].</span>")
	user.changeNext_move(CLICK_CD_MELEE)
	return TRUE
	//MONKESTATION EDIT END

/obj/item/reagent_containers/proc/add_initial_reagents()
	if(list_reagents)
		reagents.add_reagent_list(list_reagents)

/obj/item/reagent_containers/attack_self(mob/user)
	if(possible_transfer_amounts.len)
		var/i=0
		for(var/A in possible_transfer_amounts)
			i++
			if(A == amount_per_transfer_from_this)
				if(i<possible_transfer_amounts.len)
					amount_per_transfer_from_this = possible_transfer_amounts[i+1]
				else
					amount_per_transfer_from_this = possible_transfer_amounts[1]
				balloon_alert(user, "Transferring [amount_per_transfer_from_this]u")
				return

/obj/item/reagent_containers/attack(mob/M, mob/user, def_zone)
	if(user.a_intent == INTENT_HARM)
		return ..()

/obj/item/reagent_containers/proc/canconsume(mob/eater, mob/user)
	if(!iscarbon(eater))
		return FALSE
	var/mob/living/carbon/C = eater
	var/covered = ""
	if(C.is_mouth_covered(head_only = 1))
		covered = "headgear"
	else if(C.is_mouth_covered(mask_only = 1))
		covered = "mask"
	if(covered && user.a_intent != INTENT_HARM)
		var/who = (isnull(user) || eater == user) ? "your" : "[eater.p_their()]"
		balloon_alert(user, "Remove [who] [covered] first")
		return FALSE
	if(!eater.has_mouth())
		if(eater == user)
			balloon_alert(eater, "You have no mouth")
		else
			balloon_alert(user, "[eater] has no mouth")
		return FALSE
	return TRUE

/obj/item/reagent_containers/ex_act()
	if(reagents)
		for(var/datum/reagent/R in reagents.reagent_list)
			R.on_ex_act()
	if(!QDELETED(src))
		..()

/obj/item/reagent_containers/fire_act(exposed_temperature, exposed_volume)
	reagents.expose_temperature(exposed_temperature)
	..()

/obj/item/reagent_containers/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	SplashReagents(hit_atom, TRUE)

/obj/item/reagent_containers/proc/bartender_check(atom/target)
	. = FALSE
	var/mob/thrown_by = thrownby?.resolve()
	if(target.CanPass(src, get_turf(src)) && thrown_by && HAS_TRAIT(thrown_by, TRAIT_BOOZE_SLIDER))
		. = TRUE

/obj/item/reagent_containers/proc/SplashReagents(atom/target, thrown = FALSE)
	if(!reagents || !reagents.total_volume || !spillable)
		return
	var/mob/thrown_by = thrownby?.resolve()

	if(ismob(target) && target.reagents)
		if(thrown)
			reagents.total_volume *= rand(5,10) * 0.1 //Not all of it makes contact with the target
		var/mob/M = target
		var/R
		target.visible_message("<span class='danger'>[M] has been splashed with something!</span>", \
						"<span class='userdanger'>[M] has been splashed with something!</span>")
		for(var/datum/reagent/A in reagents.reagent_list)
			R += "[A.type]  ([num2text(A.volume)]),"

		if(thrownby)
			log_combat(thrown_by, M, "splashed", R)
		reagents.reaction(target, TOUCH)

	else if(bartender_check(target) && thrown)
		visible_message("<span class='notice'>[src] lands onto the [target.name] without spilling a single drop.</span>")
		return

	else
		var/turf/target_turf = target
		if(isturf(target))
			if(istype(target_turf, /turf/open))
				target_turf.add_liquid_from_reagents(reagents)
			if(reagents.reagent_list.len && thrown_by)
				log_combat(thrown_by, target, "splashed (thrown) [english_list(reagents.reagent_list)]", "in [AREACOORD(target)]")
				log_game("[key_name(thrown_by)] splashed (thrown) [english_list(reagents.reagent_list)] on [target] in [AREACOORD(target)].")
				message_admins("[ADMIN_LOOKUPFLW(thrown_by)] splashed (thrown) [english_list(reagents.reagent_list)] on [target] in [ADMIN_VERBOSEJMP(target)].")
		else
			reagents.reaction(target, TOUCH)
			var/turf/targets_loc = target.loc
			if(istype(targets_loc, /turf/open))
				targets_loc.add_liquid_from_reagents(reagents)
			else
				targets_loc = get_step_towards(targets_loc, thrown_by)
				targets_loc.add_liquid_from_reagents(reagents) //not perfect but i can't figure out how to move something to the nearest visible turf from throw_target
		//MONKESTATION EDIT END
		visible_message("<span class='notice'>[src] spills its contents all over [target].</span>")
		if(QDELETED(src))
			return

	reagents.clear_reagents()

/obj/item/reagent_containers/microwave_act(obj/machinery/microwave/M)
	reagents.expose_temperature(1000)
	..()

/obj/item/reagent_containers/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	reagents.expose_temperature(exposed_temperature)

/obj/item/reagent_containers/on_reagent_change(changetype)
	update_icon()

/obj/item/reagent_containers/update_icon(dont_fill=FALSE)
	if(!fill_icon_thresholds || dont_fill)
		return ..()

	cut_overlays()

	if(reagents.total_volume)
		var/fill_name = fill_icon_state? fill_icon_state : icon_state
		var/mutable_appearance/filling = mutable_appearance('icons/obj/reagentfillings.dmi', "[fill_name][fill_icon_thresholds[1]]")

		var/percent = round((reagents.total_volume / volume) * 100)
		for(var/i in 1 to fill_icon_thresholds.len)
			var/threshold = fill_icon_thresholds[i]
			var/threshold_end = (i == fill_icon_thresholds.len)? INFINITY : fill_icon_thresholds[i+1]
			if(threshold <= percent && percent < threshold_end)
				filling.icon_state = "[fill_name][fill_icon_thresholds[i]]"

		filling.color = mix_color_from_reagents(reagents.reagent_list)
		add_overlay(filling)
	. = ..()

/obj/item/reagent_containers/extrapolator_act(mob/user, var/obj/item/extrapolator/E, scan = FALSE)
	var/datum/reagent/blood/B = locate() in reagents.reagent_list
	if(!B)
		return FALSE
	if(scan)
		E.scan(src, B.get_diseases(), user)
		return TRUE
	else
		E.extrapolate(src, B.get_diseases(), user, TRUE)
		return TRUE
