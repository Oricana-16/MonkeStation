//Daemon Mask
/obj/item/clothing/mask/daemon_mask
	name = "daemon mask"
	desc = "A cursed mask scavenged from a now defunct cult, said to house spirits and manifest them through a wearer's body."
	icon = 'monkestation/icons/obj/clothing/masks.dmi'
	worn_icon = 'monkestation/icons/mob/mask.dmi'
	icon_state = "daemon_mask"
	item_state = "daemon_mask"
	clothing_flags = SHOWEROKAY
	var/new_role = "Daemon Mask"
	//Whether a spirit is in the mask or not
	var/possessed = FALSE
	var/welcome_message = "<span class='warning'>ALL PAST LIVES ARE FORGOTTEN.</span>\n\
	<b>You are a spirit inhabiting the daemon mask.\n\
	You're on your own side, do whatever it takes to survive.\n\
	You can choose to help the crew, or you can betray them as you see fit.</b>"
	//spells only while you possess someone
	var/list/possession_spells = list(
		/obj/effect/proc_holder/spell/targeted/mask_lunge)
	//spells only while youre a mask
	var/list/mask_spells = list(/obj/effect/proc_holder/spell/self/mask_commune)
	//spells that you always have
	var/list/constant_spells = list(/obj/effect/proc_holder/spell/self/mask_possession)
	var/mob/living/simple_animal/shade/spirit = null

/obj/item/clothing/mask/daemon_mask/attack_self(mob/user)
	if(possessed)
		return
	if(!(GLOB.ghost_role_flags & GHOSTROLE_STATION_SENTIENCE))
		to_chat(user, "<span class='notice'>The mask doesn't react, it must be broken!</span>")
		return

	to_chat(user, "[src] starts glowing...")

	possessed = TRUE

	var/list/mob/dead/observer/candidates = pollGhostCandidates("Do you want to play as the spirit of the daemon mask?", ROLE_PAI, null, FALSE, 100, POLL_IGNORE_POSSESSED_BLADE)

	if(LAZYLEN(candidates))
		var/mob/dead/observer/candidate = pick(candidates)
		var/mob/living/simple_animal/shade/new_spirit = new(src)
		spirit = new_spirit
		new_spirit.key = candidate.key
		new_spirit.fully_replace_character_name(null, "The spirit of [src]")
		new_spirit.status_flags |= GODMODE
		new_spirit.update_atom_languages()
		new_spirit.mind.assigned_role = new_role
		new_spirit.set_stat(CONSCIOUS)
		new_spirit.remove_from_dead_mob_list()
		new_spirit.add_to_alive_mob_list()
		grant_all_languages()

		to_chat(new_spirit, welcome_message)

		for(var/ability in constant_spells) //Mask Spells too since you start as a mask
			var/obj/effect/proc_holder/spell/spell = new ability
			new_spirit.mind.AddSpell(spell)

		enter_mask_mode()

		to_chat(user, "<span class='notice'>[src] shines brighter before dimming down, a spirit has been summoned</span>")
		icon_state = "daemon_mask_on"
		item_state = "daemon_mask_on"
	else
		to_chat(user, "<span class='notice'>[src] stops glowing. Maybe you can try again later.</span>")
		possessed = FALSE

/obj/item/clothing/mask/daemon_mask/proc/enter_mask_mode()
	REMOVE_TRAIT(src, TRAIT_NODROP, CURSED_MASK_TRAIT)
	for(var/ability in possession_spells)
		spirit.mind.RemoveSpell(ability)
	for(var/ability in mask_spells)
		var/obj/effect/proc_holder/spell/spell = new ability
		spirit.mind.AddSpell(spell)

/obj/item/clothing/mask/daemon_mask/proc/enter_possession_mode()
	ADD_TRAIT(src, TRAIT_NODROP, CURSED_MASK_TRAIT) //Can't take the mask off while you are in control
	for(var/ability in mask_spells)
		spirit.mind.RemoveSpell(ability)
	for(var/ability in possession_spells)
		var/obj/effect/proc_holder/spell/spell = new ability
		spirit.mind.AddSpell(spell)

//Daemon Mask - Spells
/obj/effect/proc_holder/spell/self/mask_possession
	name = "Mask Possession"
	desc = "Take control of your wearer for a short time. Possessing your wearer gives them a boost against any active stuns."
	clothes_req = FALSE
	charge_max = 1500 //1 minute for possession + 1 minute 30 seconds for the cooldown after
	action_icon = 'monkestation/icons/mob/actions/actions_spells.dmi'
	action_icon_state = "mask_possession"
	invocation = "none"
	invocation_type = "none"
	school = "transmutation"

/obj/effect/proc_holder/spell/self/mask_possession/cast(mob/living/user)
	var/obj/item/clothing/mask/daemon_mask/mask = user.loc

	if(!ishuman(mask.loc))
		to_chat(user,"<span class='warning'>No one is wearing you!</span>")
		revert_cast()
		return

	var/mob/living/carbon/wearer = mask.loc

	if(!(mask == wearer.wear_mask))
		to_chat(user,"<span class='warning'>No one is wearing you!</span>")
		revert_cast()
		return

	if(!wearer.ckey)
		to_chat(user,"<span class='warning'>There's no mind to possess!</span>")
		revert_cast()
		return

	to_chat(wearer,"<span class='warning'>[mask] takes control!/span>")

	var/mob/living/spirit = user

	mask.enter_possession_mode()
	//MIND TRANSFER BEGIN
	var/mob/dead/observer/ghost = wearer.ghostize(0)
	spirit.mind.transfer_to(wearer)

	ghost.mind.transfer_to(spirit)
	if(ghost.key)
		spirit.key = ghost.key
	qdel(ghost)

	//Ends stuns and stuff so the mask can help the user a little more
	wearer.SetAllImmobility(0)
	wearer.adjustStaminaLoss(-100)
	wearer.set_resting(FALSE)
	wearer.update_mobility()

	addtimer(CALLBACK(src, .proc/undo_possession, user, wearer, mask), 60 SECONDS)

/obj/effect/proc_holder/spell/self/mask_possession/proc/undo_possession(mob/living/swapper, mob/living/carbon/victim, obj/item/clothing/mask/daemon_mask/mask)
	to_chat(swapper,"<span class='notice'>Your control wears off.<span>")
	to_chat(victim,"<span class='notice'>You gain control of your body once again.<span>")


	var/mob/dead/observer/ghost = swapper.ghostize(0)
	victim.mind.transfer_to(swapper)

	ghost.mind.transfer_to(victim)
	if(ghost.key)
		victim.key = ghost.key
	qdel(ghost)
	mask.enter_mask_mode()

/obj/effect/proc_holder/spell/targeted/mask_lunge
	name = "Daemon Lunge"
	desc = "Use daemonic power to appear on a person nearby, knocking them down."
	school = "abjuration"
	charge_max = 250 //about twice per possession
	clothes_req = FALSE
	invocation = "none"
	invocation_type = "none"
	ranged_mousepointer = 'icons/mob/actions/actions_spells.dmi'
	action_icon_state = "teleport"
	range = 6
	selection_type = "range"

/obj/effect/proc_holder/spell/targeted/mask_lunge/cast(list/targets, mob/user = usr)
	if(!length(targets))
		to_chat(user, "<span class='notice'>No target found in range.</span>")
		revert_cast()
		return

	var/mob/living/carbon/target = targets[1]

	if(!istype(target))
		return

	if(!(target in oview(range)))
		to_chat(user, "<span class='notice'>[target.p_theyre(TRUE)] too far away!</span>")
		revert_cast()
		return

	playsound(get_turf(user), 'sound/magic/blink.ogg', 50, 1)
	target.Knockdown(3 SECONDS)
	target.visible_message("<span class='danger'>[user] appears above [target], knocking them down!</span>", \
						   "<span class='danger'>You fall violently as [user] appears above you!</span>")
	do_teleport(user, target, channel = TELEPORT_CHANNEL_FREE, no_effects = TRUE, teleport_mode = TELEPORT_MODE_DEFAULT)

/obj/effect/proc_holder/spell/self/mask_commune
	name = "Commune"
	desc = "Send a message to your wearer."
	action_icon = 'icons/mob/actions/actions_changeling.dmi'
	action_icon_state = "hivemind_link"
	clothes_req = FALSE
	charge_max = 10
	invocation = "none"
	invocation_type = "none"
	school = "transmutation"

/obj/effect/proc_holder/spell/self/mask_commune/cast(mob/living/user)
	var/obj/item/clothing/mask/daemon_mask/mask = user.loc

	if(!ishuman(mask.loc))
		to_chat(user,"<span class='warning'>No one is wearing you!</span>")
		return

	var/input = stripped_input(usr, "Talk to your wielder.", "Voice of the mask", "")
	if(!input)
		return
	if(CHAT_FILTER_CHECK(input))
		to_chat(usr, "<span class='warning'>You cannot send a message that contains a word prohibited in IC chat!</span>")
		return


	var/mob/living/wearer = mask.loc

	to_chat(wearer, "<span class='notice'><b>The Daemon Mask whispers to you:</b> [input]</span>")
	to_chat(user, "<span class='notice'><b>You whisper to your wielder:</b> [input]</span>")

	user.log_talk(input, LOG_SAY, tag="daemon mask")

//Busted Invisibility Matrix
/obj/item/invisibility_matrix
	name = "Busted Invisibility Matrix"
	desc = "One of the Spider Clan's first attempts at invisibility, it was scrapped for always ending too early."
	icon = 'monkestation/icons/obj/device.dmi'
	icon_state = "invisibility_matrix"
	drop_sound = 'sound/items/handling/multitool_drop.ogg'
	pickup_sound = 'sound/items/handling/multitool_pickup.ogg'
	COOLDOWN_DECLARE(invis_matrix_cooldown)

/obj/item/invisibility_matrix/attack_self(mob/user)
	if(!COOLDOWN_FINISHED(src, invis_matrix_cooldown))
		to_chat(user, "<span class='warning'>the [src] isn't ready yet!</span>")
		return


	user.visible_message("<span class='warning'>[user.name] starts to turn transparent!</span>", \
						"<span class='notice'>Your skin turns transparent.</span>")

	animate(user, alpha = 25,time = 3 SECONDS)

	var/invisibility_time = rand(15 SECONDS, 100 SECONDS)
	addtimer(CALLBACK(src, .proc/end_invis, user), invisibility_time)
	COOLDOWN_START(src, invis_matrix_cooldown, invisibility_time + 30 SECONDS)


/obj/item/invisibility_matrix/proc/end_invis(mob/user)

	user.visible_message("<span class='warning'>[user.name] starts to appear out of nowhere!</span>", \
						"<span class='notice'>Your skin turns opaque.</span>")


	animate(user, alpha = 255,time = 1 SECONDS)

//Damage Thief
/obj/item/damage_thief
	name = "Damage Thief"
	desc = "A healing device that follows equivalent exchange."
	icon = 'monkestation/icons/obj/device.dmi'
	icon_state = "dmg_thief"
	var/damage_type = null

/obj/item/damage_thief/attack_self(mob/living/carbon/user)
	var/damage_type_list = list("Brute","Burn","Toxin","Suffocation")
	var/chosen_damage_type = input(user, "Choose an Damage Type:", "Damage Thief") in damage_type_list
	switch(chosen_damage_type)
		if("Brute")
			icon_state = "dmg_thief_brute"
			damage_type = BRUTE
		if("Burn")
			icon_state = "dmg_thief_burn"
			damage_type = BURN
		if("Toxin")
			icon_state = "dmg_thief_toxin"
			damage_type = TOX
		if("Suffocation")
			icon_state = "dmg_thief_oxy"
			damage_type = OXY

	to_chat(user, "<span class=danger>The device's display changes colors!</span>")

/obj/item/damage_thief/attack(mob/living/target, mob/living/user)
	if(target==user)
		to_chat(user,"<spawn class='warning'>You can't use this on yourself!</span>")
		return
	if(!istype(target))
		return
	if(target.stat == DEAD)
		to_chat(user,"<spawn class='warning'>[target] is dead!</span>")
		return

	var/damage = 0

	switch(damage_type)
		if(BRUTE)
			damage = target.getBruteLoss()
			target.adjustBruteLoss(-damage)
		if(BURN)
			damage = target.getFireLoss()
			target.adjustFireLoss(-damage)
		if(TOX)
			if(HAS_TRAIT(user,TRAIT_TOXIMMUNE)) //Can't have players immune to this just get rid of the damage.
				to_chat(user,"<span class='warning'>You can't take this damage type!</span>")
				return
			damage = target.getToxLoss()
			target.adjustToxLoss(-damage)
		if(OXY)
			if(HAS_TRAIT(user,TRAIT_NOBREATH))
				to_chat(user,"<span class='warning'>You can't take this damage type!</span>")
				return
			damage = target.getOxyLoss()
			target.adjustOxyLoss(-damage)
		else
			to_chat(user,"<span class='warning'>You must select a damage type first!</span>")
			return

	user.apply_damage(damage,damage_type)
	if(damage >= 1)
		user.visible_message("<span class='notice'>[target]'s wounds disappear, as [user] looks more damaged.</span>", \
							"<span class='notice'>[target] starts to look better, while you feel a little more hurt.</span>")
	else
		to_chat(user,"<span class='notice'>Nothing happened, [target] must not've been hurt.</span>")

//Organics Smuggling Bag
/obj/item/organics_smuggling_bag
	name = "Organics Smuggling Bag"
	desc = "A bag made with bluespace tech scientists made while on tons of space drugs. Can fit a lot of people inside."
	slot_flags = ITEM_SLOT_BACK //Its totally a normal backpack :)
	icon = 'icons/obj/storage.dmi'
	icon_state = "backpack"
	item_state = "backpack"

/obj/item/organics_smuggling_bag/attack_self(mob/living/carbon/user)
	if(src.contents.len >= 1)
		user.visible_message("<span class='warning'>Everyone inside \the [src] tumbles out!</span>")
		var/turf/tumble_tile = get_turf(user)
		for(var/mob/living/inhabitant in contents)
			inhabitant.forceMove(tumble_tile)
			inhabitant.Knockdown(3 SECONDS)
	else
		to_chat(user,"<span class='warning'>There's no one inside!</span>")

/obj/item/organics_smuggling_bag/afterattack(mob/living/target, mob/living/user, proximity)
	if(!proximity || !isliving(target))
		return
	if(target == user)
		to_chat(user, "<span class='notice'>You can't get yourself inside!</span>")
		return

	target.visible_message("<span class='warning'>[user] is trying to stuff [target]\s body into \the [src]!</span>", \
							"<span class='danger'>[user] is trying to stuff you into \the [src]!</span>")
	if(do_mob(user, target, 15 SECONDS))
		target.forceMove(src)
	..()

/obj/item/organics_smuggling_bag/examine(mob/user)
	. = ..()
	var/number_of_people = src.contents.len
	if(number_of_people >= 1)
		. +=  "It currently has [number_of_people] people inside."
	else
		. += "There's no one inside."

//Soul Binding Contract
/obj/item/soul_link_contract
	name = "Soul Binding Contract"
	desc = "A contract from Hell itself. If you get a corpse to sign it, it binds your souls together and brings them back from beyond the grave."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paper_onfire"
	item_state = "paper"

/obj/item/soul_link_contract/afterattack(mob/living/target, mob/living/user)
	if(target.stat != DEAD)
		to_chat(user, "<span class='warning'>[target] isn't dead!</span>")
		return

	if(!(target.key || target.client) || isanimal(target)) //No SSD's but Ian and such are allowed
		to_chat(user, "<span class='warning'>[target]'s body doesn't respond.!</span>")
		return

	if(target.ishellbound())
		to_chat(user, "<span class='warning'>[target] has no soul!</span>")
		return

	user.visible_message("<span class='warning'>[user] helps [target] sign \the [src].</span>",
						"<span class='warning'>you start to use [target]'s hand to sign \the [src].</span>")

	if(do_mob(user, target, 30 SECONDS))
		target.revive(TRUE)
		soullink(/datum/soullink/sharedfate, user, target)
		user.visible_message("<span class='warning'>[target] finished 'signing' \the [src].</span>",
						"<span class='warning'>The contract is complete, your souls are now linked.</span>")
		to_chat(target, "<span class='warning'>You're soul is now linked to [user]'s. If one of you dies for any reason, so does the other.</span>")
		qdel(src)
