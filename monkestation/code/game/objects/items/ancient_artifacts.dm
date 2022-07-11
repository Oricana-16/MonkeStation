//Daemon Mask

/obj/item/clothing/mask/daemon_mask
	name = "daemon mask"
	desc = "A cursed mask scavenged from a now defunct cult, said to house spirits inside and manifest them through a wearer's body."
	clothing_flags = SHOWEROKAY
	var/new_role = "Daemon Mask"
	var/possessed = FALSE
	var/welcome_message = "<span class='warning'>ALL PAST LIVES ARE FORGOTTEN.</span>\n\
	<b>You are a spirit inhabiting the daemon mask.\n\
	You're on your own side, do whatever it takes to survive.\n\
	You can choose to help the crew, or you can betray them as you wish.</b>"
	var/list/possession_spells = list(
		/obj/effect/proc_holder/spell/targeted/blind/mask,
		/obj/effect/proc_holder/spell/voice_of_god) //spells only while you possess someone
	var/list/mask_spells = list(/obj/effect/proc_holder/spell/self/mask_commune) //spells only while youre a mask
	var/list/constant_spells = list(/obj/effect/proc_holder/spell/self/mask_possession) //spells that you always have
	var/mob/living/simple_animal/shade/spirit = null

/obj/item/clothing/mask/daemon_mask/attack_self(mob/user)
	if(possessed)
		return
	if(!(GLOB.ghost_role_flags & GHOSTROLE_STATION_SENTIENCE))
		to_chat(user, "<span class='notice'>The mask doesn't respond, it must be broken!</span>")
		return

	to_chat(user, "[src] starts glowing...")

	possessed = TRUE

	var/list/mob/dead/observer/candidates = pollGhostCandidates("Do you want to play as the spirit of the daemon mask?", ROLE_PAI, null, FALSE, 100, POLL_IGNORE_POSSESSED_BLADE)

	if(LAZYLEN(candidates))
		to_chat(user, "<span class='notice'>[src] glows bright before fading back, a spirit has been summoned</span>")
		var/mob/dead/observer/candidate = pick(candidates)
		var/mob/living/simple_animal/shade/new_spirit = new(src)
		spirit = new_spirit
		new_spirit.key = candidate.key
		new_spirit.fully_replace_character_name(null, "The spirit of [src]")
		new_spirit.status_flags |= GODMODE
		new_spirit.copy_languages(user, LANGUAGE_MASTER)
		new_spirit.update_atom_languages()
		new_spirit.mind.assigned_role = new_role
		new_spirit.set_stat(CONSCIOUS)
		new_spirit.remove_from_dead_mob_list()
		new_spirit.add_to_alive_mob_list()
		grant_all_languages(FALSE, FALSE, TRUE)

		to_chat(new_spirit, welcome_message)

		for(var/ability in constant_spells) //Mask Spells too since you start as a mask
			var/obj/effect/proc_holder/spell/spell = new ability
			new_spirit.mind.AddSpell(spell)

		enter_mask_mode()
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
	desc = "Take control of your wearer for a short time."
	clothes_req = FALSE
	charge_max = 1200 //1 minute for possession + 1 minute for the cooldown after
	invocation = "none"
	invocation_type = "none"
	school = "transmutation"

/obj/effect/proc_holder/spell/self/mask_possession/cast(mob/living/user)
	var/obj/item/clothing/mask/daemon_mask/mask = user.loc

	if(!ishuman(mask.loc))
		to_chat(user,"<span class='warning'>No one is wearing you!</span>")
		revert_cast()
		return

	var/mob/living/wearer = mask.loc

	if(!(mask == wearer.get_item_by_slot(ITEM_SLOT_MASK)))
		to_chat(user,"<span class='warning'>No one is wearing you!</span>")
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

	addtimer(CALLBACK(src, .proc/undo_possession, user, wearer, mask), 60 SECONDS)

/obj/effect/proc_holder/spell/self/mask_possession/proc/undo_possession(mob/living/swapper, mob/living/victim, obj/item/clothing/mask/daemon_mask/mask)
	to_chat(swapper,"<span class='notice'>Your control wears off.<span>")
	to_chat(victim,"<span class='notice'>You gain control of your body once again.<span>")


	var/mob/dead/observer/ghost = swapper.ghostize(0)
	victim.mind.transfer_to(swapper)

	ghost.mind.transfer_to(victim)
	if(ghost.key)
		victim.key = ghost.key
	qdel(ghost)
	mask.enter_mask_mode()

/obj/effect/proc_holder/spell/targeted/blind/mask
	desc = "Gaze into the eyes of a creature and consume their vision."
	invocation = "none"
	invocation_type = "none"
	duration = 15 SECONDS

/obj/effect/proc_holder/spell/self/mask_commune
	name = "Commune"
	desc = "Send a message to your wearer."
	overlay_icon = 'icons/mob/actions/actions_changeling.dmi'
	overlay_icon_state = "hivemind_link"
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

	var/input = stripped_input(usr, "Talk to your wearer.", "Voice of the mask", "")
	if(!input)
		return
	if(CHAT_FILTER_CHECK(input))
		to_chat(usr, "<span class='warning'>You cannot send a message that contains a word prohibited in IC chat!</span>")
		return


	var/mob/living/wearer = mask.loc

	to_chat(wearer, "<span class='notice'><b>The mask whispers to you:</b> [message]</span>")
	to_chat(user, "<span class='notice'><b>You whisper to your wearer:</b> [message]</span>")

	user.log_talk(message, LOG_SAY, tag="daemon mask")
