/obj/item/clothing/head
	name = BODY_ZONE_HEAD
	icon = 'icons/obj/clothing/hats.dmi'
	item_state = "that"
	body_parts_covered = HEAD
	slot_flags = ITEM_SLOT_HEAD
	var/blockTracking = 0 //For AI tracking
	var/can_toggle = null
	dynamic_hair_suffix = "+generic"

/obj/item/clothing/head/Initialize(mapload)
	. = ..()
	if(ishuman(loc) && dynamic_hair_suffix)
		var/mob/living/carbon/human/H = loc
		H.update_hair()
	remove_verb(/obj/item/clothing/head/verb/detach_stacked_hat)//MonkeStation Edit: Hat Stacking


///Special throw_impact for hats to frisbee hats at people to place them on their heads/attempt to de-hat them.
/obj/item/clothing/head/throw_impact(atom/hit_atom, datum/thrownthing/thrownthing)
	///if the thrown object is caught
	if(..())
		return
	///if the thrown object's target zone isn't the head
	if(thrownthing.target_zone != BODY_ZONE_HEAD)
		return
	///ignore any hats with special effects that prevent removal ie tinfoil hats
	if(clothing_flags & EFFECT_HAT)
		return
	///if the hat happens to be capable of holding contents and has something in it. mostly to prevent super cheesy stuff like stuffing a mini-bomb in a hat and throwing it
	if(LAZYLEN(contents))
		return
	if(iscarbon(hit_atom))
		var/mob/living/carbon/H = hit_atom
		if(isclothing(H.head))
			var/obj/item/clothing/WH = H.head
			///check if the item has NODROP
			if(HAS_TRAIT(WH, TRAIT_NODROP))
				H.visible_message("<span class='warning'>[src] bounces off [H]'s [WH.name]!</span>", "<span class='warning'>[src] bounces off your [WH.name], falling to the floor.</span>")
				return
			///check if the item is an actual clothing head item, since some non-clothing items can be worn
			if(istype(WH, /obj/item/clothing/head))
				var/obj/item/clothing/head/WHH = WH
				///SNUG_FIT hats are immune to being knocked off
				if(WHH.clothing_flags & SNUG_FIT)
					H.visible_message("<span class='warning'>[src] bounces off [H]'s [WHH.name]!</span>", "<span class='warning'>[src] bounces off your [WHH.name], falling to the floor.</span>")
					return
			///if the hat manages to knock something off
			if(H.dropItemToGround(WH))
				H.visible_message("<span class='warning'>[src] knocks [WH] off [H]'s head!</span>", "<span class='warning'>[WH] is suddenly knocked off your head by [src]!</span>")
		if(H.equip_to_slot_if_possible(src, ITEM_SLOT_HEAD, 0, 1, 1))
			H.visible_message("<span class='notice'>[src] lands neatly on [H]'s head!</span>", "<span class='notice'>[src] lands perfectly onto your head!</span>")
		return
	if(iscyborg(hit_atom))
		var/mob/living/silicon/robot/R = hit_atom
		///hats in the borg's blacklist bounce off
		if(is_type_in_typecache(src, R.blacklisted_hats))
			R.visible_message("<span class='warning'>[src] bounces off [R]!</span>", "<span class='warning'>[src] bounces off you, falling to the floor.</span>")
			return
		else
			R.visible_message("<span class='notice'>[src] lands neatly on top of [R]</span>", "<span class='notice'>[src] lands perfectly on top of you.</span>")
			R.place_on_head(src) //hats aren't designed to snugly fit borg heads or w/e so they'll always manage to knock eachother off

/obj/item/clothing/head/worn_overlays(mutable_appearance/standing, isinhands = FALSE)
	. = ..()
	if(isinhands)
		return

	if(damaged_clothes)
		. += mutable_appearance('icons/effects/item_damage.dmi', "damagedhelmet")
	if(HAS_BLOOD_DNA(src))
		. += mutable_appearance('icons/effects/blood.dmi', "helmetblood")
	//MonkeStation Edit: Hat Stacking
	//This section handles the worn icon itself, not the item icon.
		if(contents)
			var/current_hat = 1
			for(var/obj/item/clothing/head/selected_hat in contents)
				var/head_icon = 'icons/mob/clothing/head.dmi'
				if(selected_hat.worn_icon)
					head_icon = selected_hat.icon
				var/mutable_appearance/hat_adding = selected_hat.build_worn_icon(HEAD_LAYER, head_icon, FALSE, FALSE)
				hat_adding.pixel_y = ((current_hat * 4) - 1)
				hat_adding.pixel_x = (rand(-1, 1))
				current_hat++
				. += hat_adding
	//MonkeStation Edit End

/obj/item/clothing/head/update_clothes_damaged_state(damaging = TRUE)
	..()
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_head()
