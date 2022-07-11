/obj/item/clothing/mask/daemon_mask
	name = "daemon mask"
	desc = "A traditional mask scavenged from a now defunct cult, said to house spirits inside and manifest them through a wearer's body."
	clothing_flags = SHOWEROKAY
	var/new_role = "Daemon Mask"
	var/possessed = FALSE
	var/in_control = FALSE //Whether the mask is in control or not
	var/welcome_message = "<span class='warning'>ALL PAST LIVES ARE FORGOTTEN.</span>\n\
	<b>You are a spirit inhabiting the daemon mask.\n\
	You're on your own side, do whatever it takes to survive.\n\
	You can choose to help the crew, or you can betray them as you wish.</b>"

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
		var/mob/dead/observer/candidate = pick(candidates)
		var/mob/living/simple_animal/shade/new_spirit = new(src)
		new_spirit.ckey = candidate.ckey
		new_spirit.fully_replace_character_name(null, "The spirit of [name]")
		new_spirit.status_flags |= GODMODE
		new_spirit.copy_languages(user, LANGUAGE_MASTER)
		new_spirit.update_atom_languages()
		candidate.mind.transfer_to(new_spirit)
		new_spirit.mind.assigned_role = new_role
		new_spirit.set_stat(CONSCIOUS)
		new_spirit.remove_from_dead_mob_list()
		new_spirit.add_to_alive_mob_list()
		grant_all_languages(FALSE, FALSE, TRUE)

		to_chat(new_spirit, welcome_message)

		var/list/abilities = list()
		for(var/ability in abilities)
			var/obj/effect/proc_holder/spell/spell = new ability
			new_spirit.mind.AddSpell(spell)

	else
		to_chat(user, "[src] stops glowing. Maybe you can try again later.")
		possessed = FALSE

// /obj/effect/proc_holder/spell/self/mask_possession
// 	name = "Mask Possession"
// 	desc = "Tank control of your wearer for a short time."
// 	human_req = TRUE
// 	clothes_req = FALSE
// 	charge_max = 1200
// 	cooldown_min = 150
// 	invocation = "none"
// 	invocation_type = "none"
// 	school = "transmutation"
// 	sound = 'sound/magic/staff_healing.ogg'

// /obj/effect/proc_holder/spell/self/mask_possession/cast(mob/living/user)
// 	var/mob/living/victim = target
// 	var/mob/living/caster = user

// 	//MIND TRANSFER BEGIN
// 	var/mob/dead/observer/ghost = victim.ghostize(0)
// 	caster.mind.transfer_to(victim)

// 	ghost.mind.transfer_to(caster)
// 	if(ghost.key)
// 		caster.key = ghost.key	//have to transfer the key since the mind was not active
// 	qdel(ghost)
// 	user.visible_message("<span class='warning'>A wreath of gentle light passes over [user]!</span>", "<span class='notice'>You wreath yourself in healing light!</span>")

// 	//TODO Tomorrow::: Check Mindswap to see how it swaps, and do that, and also make the cooldown proportional to how long it lasts
