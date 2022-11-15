//Greater mimics

/mob/living/simple_animal/hostile/alien_mimic/greater
	name = "greater mimic"
	real_name = "greater mimic"
	icon_state = "greater"
	icon_living = "greater"
	maxHealth = 175
	health = 175
	melee_damage = 9
	secondary_damage_type = BRUTE
	hivemind_modifier = "Greater"
	can_evolve = FALSE
	playstyle_string = "<span class='big bold'>You are a greater mimic,</span></b> you deal more damage to both people and objects, though only brute damage, \
						have more health, and can disguise as bigger objects.</b>"

/mob/living/simple_animal/hostile/alien_mimic/greater/allowed(atom/movable/target_item)
	return isitem(target_item) || (get_dist(src,target_item) > 1 && ismachinery(target_item) && !istype(target_item,/obj/machinery/atmospherics)) //dist check so you can still break things

//Voltaic Mimics

/mob/living/simple_animal/hostile/alien_mimic/voltaic
	name = "voltaic mimic"
	real_name = "voltaic mimic"
	icon_state = "voltaic"
	icon_living = "voltaic"
	melee_damage = 5
	secondary_damage_type = BURN
	hivemind_modifier = "Voltaic"
	can_evolve = FALSE
	playstyle_string = "<span class='big bold'>You are a voltaic mimic,</span></b> you deal brute and burn damage, stun and electrocute people on hit, and \
						can activate an emp.</b>"

/mob/living/simple_animal/hostile/alien_mimic/voltaic/Initialize(mapload)
	. = ..()
	var/obj/effect/proc_holder/spell/self/mimic_emp/emp = new
	AddSpell(emp)

/mob/living/simple_animal/hostile/alien_mimic/voltaic/death(gibbed)
	tesla_zap(src, 5, 4000)
	..()

/mob/living/simple_animal/hostile/alien_mimic/voltaic/AttackingTarget()
	if(!isliving(target))
		return ..()

	var/mob/living/victim = target
	if(buckled && buckled == victim && HAS_TRAIT(victim, TRAIT_SHOCKIMMUNE))
		victim.Stun(1 SECONDS)
		victim.electrocute_act(1, src)
	..()

/obj/effect/proc_holder/spell/self/mimic_emp
	name = "EMP"
	desc = "Send out electromagnetic pulses, scrambling electronics in the area."
	action_icon_state = "emp"
	clothes_req = FALSE
	action_background_icon_state = "bg_alien"
	charge_max = 1 MINUTES
	sound = 'sound/weapons/zapbang.ogg'

/obj/effect/proc_holder/spell/self/mimic_emp/cast(mob/living/carbon/human/user)
	playsound(get_turf(user), sound, 50,1)
	empulse(get_turf(user), 4, 7)
	return

//Thermal Mimics

/mob/living/simple_animal/hostile/alien_mimic/thermal
	name = "thermal mimic"
	real_name = "thermal mimic"
	icon_state = "thermal"
	icon_living = "thermal"
	melee_damage = 7
	melee_damage_type = BURN
	maxbodytemp = INFINITY
	damage_coeff = list(BRUTE = 1, BURN = 0, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)
	hivemind_modifier = "Thermal"
	can_evolve = FALSE
	playstyle_string = "<span class='big bold'>You are a thermal mimic,</span></b> you deal burn and DNA damage, are immunte to fire, and \
						set fire to things you attack.</b>"

/mob/living/simple_animal/hostile/alien_mimic/thermal/death(gibbed)
	new /obj/effect/hotspot(get_turf(src))
	..()

/mob/living/simple_animal/hostile/alien_mimic/thermal/latch(mob/living/target)
	. = ..()
	if(!.)
		return
	new /obj/effect/hotspot(get_turf(target))

/mob/living/simple_animal/hostile/alien_mimic/thermal/AttackingTarget()
	if(!isliving(target) && !isturf(target))
		new /obj/effect/hotspot(get_turf(target))
		return ..()

	if(buckled && buckled == target)
		new /obj/effect/hotspot(get_turf(target))
	..()

//Shifty Mimics

/mob/living/simple_animal/hostile/alien_mimic/shifty
	name = "shifty mimic"
	real_name = "shifty mimic"
	icon_state = "shifty"
	icon_living = "shifty"
	hivemind_modifier = "Shifty"
	melee_damage = 5
	can_evolve = FALSE
	playstyle_string = "<span class='big bold'>You are a shifty mimic,</span></b> you can teleport around, bringing whoever you're latched onto with you<b>"

/mob/living/simple_animal/hostile/alien_mimic/shifty/Initialize(mapload)
	. = ..()
	var/obj/effect/proc_holder/spell/pointed/mimic_phantom_shift/shift = new
	AddSpell(shift)

/obj/effect/proc_holder/spell/pointed/mimic_phantom_shift
	name = "Phantom Shift"
	desc = "Quickly reform at another position, and bring anyone you're latched on to."
	clothes_req = FALSE
	action_icon = 'monkestation/icons/mob/actions/actions_neuromods.dmi'
	action_icon_state = "phantom_shift"
	action_background_icon_state = "bg_alien"
	charge_max = 30 SECONDS

/obj/effect/proc_holder/spell/pointed/mimic_phantom_shift/cast(list/targets,mob/user = usr)
	for(var/target in targets)
		var/turf/target_turf = get_turf(target)
		if(!(target_turf in view(7, get_turf(user))))
			revert_cast(user)
			return
		if(target_turf.density)
			to_chat(user,"<span class='notice'>You can't teleport there!</span>")
			revert_cast(user)
			return
		var/mob/living/teleport_with
		if(user.buckled)
			teleport_with = user.buckled
		do_teleport(user, target_turf)
		if(teleport_with)
			do_teleport(teleport_with, target_turf)
			teleport_with.buckle_mob(user,TRUE)
		return
	revert_cast(user)

//Kinetic Mimics

/mob/living/simple_animal/hostile/alien_mimic/kinetic
	name = "kinetic mimic"
	real_name = "kinetic mimic"
	icon_state = "kinetic"
	icon_living = "kinetic"
	hivemind_modifier = "Kinetic"
	melee_damage = 6
	secondary_damage_type = BRUTE
	can_evolve = FALSE
	playstyle_string = "<span class='big bold'>You are a kinetic mimic,</span></b> you only deal brute damage, and can push things away with your kinetic blast.<b>"

/mob/living/simple_animal/hostile/alien_mimic/kinetic/Initialize(mapload)
	. = ..()
	var/obj/effect/proc_holder/spell/self/mimic_kinetic_blast/kinetic_blast = new
	AddSpell(kinetic_blast)

/obj/effect/proc_holder/spell/self/mimic_kinetic_blast
	name = "Kinetic Blast"
	desc = "Knock everything away."
	clothes_req = FALSE
	action_background_icon_state = "bg_alien"
	charge_max = 45 SECONDS

/obj/effect/proc_holder/spell/self/mimic_kinetic_blast/cast(mob/user)
	user.add_emitter(/obj/emitter/mimic/kinetic_blast,"kinetic_blast",burst_mode=TRUE)
	playsound(get_turf(user),'sound/magic/repulse.ogg', 100, 1)
	user.visible_message("<span class='danger'>[user] sends out a wave of dark energy, knocking everything around!</span>","<span class='danger'>You push everything away!</span>")
	var/turf/user_turf = get_turf(user)
	var/list/thrown_items = list()
	for(var/atom/movable/to_throw as mob|obj in orange(7, user_turf))
		if(to_throw.anchored || thrown_items[to_throw])
			continue
		var/throwtarget = get_edge_target_turf(user_turf, get_dir(user_turf, get_step_away(to_throw, user_turf)))
		to_throw.safe_throw_at(throwtarget, 10, 1, force = MOVE_FORCE_EXTREMELY_STRONG)
		thrown_items[to_throw] = to_throw

//Oracle Mimic

/mob/living/simple_animal/hostile/alien_mimic/oracle
	name = "oracle mimic"
	real_name = "oracle mimic"
	icon_state = "oracle"
	icon_living = "oracle"
	hivemind_modifier = "oracle"
	melee_damage = 5
	can_evolve = FALSE
	playstyle_string = "<span class='big bold'>You are an oracle mimic,</span></b> you can temporarily shed your body to see the truth of the world.<b>"

/mob/living/simple_animal/hostile/alien_mimic/oracle/Initialize(mapload)
	. = ..()
	var/obj/effect/proc_holder/spell/self/mimic_divine/divine = new
	AddSpell(divine)

/obj/effect/proc_holder/spell/self/mimic_divine
	name = "Divination"
	desc = "Shed your body and see everything."
	clothes_req = FALSE
	action_background_icon_state = "bg_alien"
	charge_max = 45 SECONDS
	var/mob/living/body = null

/obj/effect/proc_holder/spell/self/mimic_divine/cast(mob/user)
	body = user
	var/mob/dead/observer/ghost = body.ghostize(1)
	var/datum/action/innate/mimic_hivemind/oracle/ghost_hivemind = new
	ghost_hivemind.body = body
	ghost.color = "purple"
	ghost_hivemind.Grant(ghost)
	while(!QDELETED(body))
		if(body.key)
			break
		sleep(5)
	ghost_hivemind.Remove(ghost)
	body.grab_ghost()
	body = null

/datum/action/innate/mimic_hivemind/oracle //Oracle specific mimic hivemind to use when they is a ghost
	name = "Communicate"
	var/mob/living/body = null

/datum/action/innate/mimic_hivemind/oracle/IsAvailable()
	return TRUE

/datum/action/innate/mimic_hivemind/oracle/Activate()
	var/input = stripped_input(usr, "Send a message to the hivemind.", "Communication", "")
	if(!input || !IsAvailable())
		return
	if(CHAT_FILTER_CHECK(input))
		to_chat(usr, "<span class='warning'>You cannot send a message that contains a word prohibited in IC chat!</span>")
		return
	hivemind_message(usr, input)

/datum/action/innate/mimic_hivemind/oracle/hivemind_message(mob/living/user, message)
	var/my_message
	if(!message)
		return

	var/name_to_use
	var/mob/living/simple_animal/hostile/alien_mimic/mimic_user = body
	name_to_use = mimic_user.real_name

	my_message = "<span class='mimichivemindtitle'><b>Mimic Hivemind</b></span> <span class='mimichivemindbig'><b>[name_to_use] (Spirit Form):</b> [message]</span>"
	for(var/datum/mind/mimic_mind in mimic_user.mimic_team.members)
		var/mob/recipient = mimic_mind.current
		to_chat(recipient, my_message)
	for(var/recipient in GLOB.dead_mob_list)
		var/link = FOLLOW_LINK(recipient, user)
		to_chat(recipient, "[link] [my_message]")

	user.log_talk(message, LOG_SAY, tag="mimic hivemind")
