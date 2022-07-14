#define MIMIC_HEALTH_FLEE_AMOUNT 30

/mob/living/simple_animal/hostile/alien_mimic
	name = "mimic"
	real_name = "mimic"
	desc = "A morphing mass of black gooey tendrils."
	speak_emote = list("gurgles")
	emote_hear = list("gurgles")
	faction = list("aliens") //don't wanna have them attack eachother
	icon = 'monkestation/icons/mob/animal.dmi'
	icon_state = "mimic"
	icon_living = "mimic"
	icon_dead = "morph_dead"
	speed = 2
	a_intent = INTENT_HARM
	stop_automated_movement = 1
	status_flags = CANPUSH
	stat_attack = UNCONSCIOUS
	pass_flags = PASSTABLE | PASSMOB
	ventcrawler = VENTCRAWLER_ALWAYS
	unsuitable_atmos_damage = 0 //They won't die in Space!
	minbodytemp = TCMB
	maxbodytemp = T0C + 40
	maxHealth = 75
	health = 75
	melee_damage = 10
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	wander = FALSE
	attacktext = "absorbs"

	var/disguised = FALSE
	var/atom/movable/form = null

	var/people_absorbed = 0

	var/list/blacklist_typecache = list(
		/obj/item/radio/intercom
	)

	//The target npc mimic's go for.
	var/atom/movable/ai_disg_target = null
	//attempts to reach a disguise target
	var/ai_disg_reach_attempts = 0

	var/playstyle_string = "<span class='big bold'>You are a mimic,</span></b> an alien that made it's way on to the station. \
							You may take the form of anything nearby by shift-clicking it.</b>"

	mobchatspan = "blob"
	discovery_points = 2000

/mob/living/simple_animal/hostile/alien_mimic/Initialize(mapload)
	var/datum/action/innate/mimic_reproduce/ability = new
	ability.Grant(src)
	. = ..()

/mob/living/simple_animal/hostile/alien_mimic/examine(mob/user)
	if(disguised)
		. = form.examine(user)
		. += "<span class='warning'>It jitters a little bit...</span>"
	else
		. = ..()

/mob/living/simple_animal/hostile/alien_mimic/med_hud_set_health()
	if(disguised && !isliving(form))
		var/image/holder = hud_list[HEALTH_HUD]
		holder.icon_state = null
		return //we hide medical hud while disguised
	..()

/mob/living/simple_animal/hostile/alien_mimic/med_hud_set_status()
	if(disguised && !isliving(form))
		var/image/holder = hud_list[STATUS_HUD]
		holder.icon_state = null
		return //we hide medical hud while disguised
	..()

/mob/living/simple_animal/hostile/alien_mimic/proc/allowed(atom/movable/target) // make it into property/proc ? not sure if worth it
	return !is_type_in_typecache(target, blacklist_typecache) && isitem(target)

/mob/living/simple_animal/hostile/alien_mimic/proc/should_heal()
	return health <= MIMIC_HEALTH_FLEE_AMOUNT

/mob/living/simple_animal/hostile/alien_mimic/proc/latch(mob/living/target)
	if(target)
		if(target.buckle_mob(src, TRUE))
			target.Knockdown(10 SECONDS) //Really get em down
			layer = target.layer+0.01
			visible_message("<span class='warning'>[src] latches onto [target]!</span>")
			return TRUE
		else
			to_chat("<span class='warning'>You failed to latch onto the target!</span>")
	return FALSE

/mob/living/simple_animal/hostile/alien_mimic/proc/attempt_reproduce()
	// if(people_absorbed > 0)

	to_chat(src,"<span class='warning'>You haven't absorbed enough people!</span>")


/mob/living/simple_animal/hostile/alien_mimic/proc/disguise(atom/movable/target)
	ai_disg_target = null
	disguised = TRUE
	form = target

	visible_message("<span class='warning'>[src] changes shape, becoming a copy of [target]!</span>", \
					"<span class='notice'>You assume the form of [target].</span>")
	appearance = target.appearance
	if(length(target.vis_contents))
		add_overlay(target.vis_contents)
	alpha = max(alpha, 150)
	transform = initial(transform)
	pixel_y = initial(pixel_y)
	pixel_x = initial(pixel_x)
	density = target.density

	if(isliving(target))
		var/mob/living/L = target
		mobchatspan = L.mobchatspan
	else
		mobchatspan = initial(mobchatspan)

	set_varspeed(speed*2)

	med_hud_set_health()
	med_hud_set_status() //we're an object honest
	return

/mob/living/simple_animal/hostile/alien_mimic/proc/restore()
	if(!disguised)
		return
	disguised = FALSE
	form = null
	alpha = initial(alpha)
	color = initial(color)
	animate_movement = SLIDE_STEPS
	maptext = null
	density = initial(density)
	visible_message("<span class='warning'>A mimic jumps out of \the [src]!</span>", \
					"<span class='notice'>You reform to your normal body.</span>")
	name = initial(name)
	icon = initial(icon)
	icon_state = initial(icon_state)
	cut_overlays()

	//Baseline stats
	melee_damage = initial(melee_damage)
	set_varspeed(initial(speed))

	med_hud_set_health()
	med_hud_set_status() //we are not an object

/mob/living/simple_animal/hostile/alien_mimic/death(gibbed)
	if(disguised)
		visible_message("<span class='warning'>[src] explodes in a pile of black goo!</span>", \
						"<span class='userdanger'>You feel weak as your tendrils start to dissolve.</span>")
		restore()
	..()

/mob/living/simple_animal/hostile/alien_mimic/AttackingTarget()
	if(target == src)
		restore()
		return
	if(isliving(target) & !buckled) //Latch onto people
		to_chat(world,"Attacking Someone")
		var/mob/living/victim = target
		if(iscarbon(victim) & victim.stat == DEAD)
			visible_message("<span class='warning'>[src] starts absorbing [victim]!</span>", \
						"<span class='userdanger'>You start absorbing [victim].</span>")
			if(do_mob(src, victim, 10 SECONDS) & !HAS_TRAIT(victim, TRAIT_HUSK))
				victim.become_husk(MIMIC_ABSORB)
				people_absorbed++
				adjustHealth(-30) //Heal for 30
		if(disguised)
			to_chat(world,"Latched!")
			latch(victim)
			restore()
			return
		else if(do_mob(src, target, 3 SECONDS))
			to_chat(world,"Latching...")
			latch(victim)
			return
	return ..()

/mob/living/simple_animal/hostile/alien_mimic/ClickOn(atom/A)
	. = ..()
	if(isitem(target)) //Become Items
		var/obj/item/item = target
		if(!item.anchored)
			disguise(item)
			return

//AI Related procs
/mob/living/simple_animal/hostile/alien_mimic/Aggro()
	to_chat(world,"ANGRY")
	if(disguised & get_dist(src,target)<=1) //Instantly latch onto them
		latch(target)
		restore()
	..()
	// restore()

/mob/living/simple_animal/hostile/alien_mimic/LoseAggro()
	to_chat(world,"Lost ya")
	vision_range = initial(vision_range)

/mob/living/simple_animal/hostile/alien_mimic/AIShouldSleep(var/list/possible_targets)
	var/should_sleep = !FindTarget(possible_targets, 1)

	if(should_sleep) //Attempt to disguise
		to_chat(world,"Going to hide")
		if(!ai_disg_target)
			to_chat(world,"Finding Disg Targ")
			var/list/things = list()
			for(var/atom/thing as() in view(src))
				if(allowed(thing))
					things += thing
			var/atom/movable/picked_thing = pick(things)
			ai_disg_target = picked_thing
		if(Adjacent(ai_disg_target) || ai_disg_reach_attempts >= 10) //give it 10 tries before just turning into it
			to_chat(world,"Found the Disg Targ")
			ai_disg_reach_attempts = 0
			disguise(ai_disg_target)
		else
			if(buckled)
				resist_buckle()
			ai_disg_reach_attempts++
			Goto(ai_disg_target, speed, 1) //Go right next to it
			return FALSE
		return TRUE
	return FALSE

/mob/living/simple_animal/hostile/alien_mimic/consider_wakeup()
	var/list/target_list

	target_list = ListTargets()

	if(target_list.len>1) //Wait until they're alone
		to_chat(world,"They aren't alone...")
		return
	FindTarget(target_list, 1)
	// if(iscarbon(target))
	// 	var/mob/living/carbon/victim = target
	// 	if(victim.stat == DEAD & should_heal() & !HAS_TRAIT(victim, TRAIT_HUSK)) //Heal if you're supposed to
	// 		toggle_ai(AI_ON)
	// 		restore()
	// 		to_chat(world,"Dead person Spotted.")
	// 		return
	var/target_dist = get_dist(target,src)
	if(target_dist>1) //Only attack when they get close
		to_chat(world,"Get closer... ([target_dist], [target], [src])")
		return
	..()

/mob/living/simple_animal/hostile/alien_mimic/CanAttack(atom/the_target)
	to_chat(world,"Can I Attack?")
	if(isliving(the_target))
		var/mob/living/living_target = the_target
		var/mob/living/simple_animal/hostile/alien_mimic/attacking_friend = locate() in living_target.buckled_mobs
		if(attacking_friend & attacking_friend != src)
			to_chat(world,"Occupied")
			return FALSE
	if(iscarbon(the_target))
		var/mob/living/carbon/carbon_target = the_target
		if(carbon_target.stat == DEAD & should_heal() & !HAS_TRAIT(carbon_target, TRAIT_HUSK)) //Heal when you're health is low enough
			to_chat(world,"Going to heal")
			return TRUE
	..()

//If the AI can track the mob.
/mob/living/simple_animal/hostile/alien_mimic/can_track(mob/living/user)
	if(disguised)
		return FALSE
	return ..()

/mob/living/simple_animal/hostile/alien_mimic/adjustHealth(amount, updating_health, forced)
	if(amount>0) //if you take damage run
		to_chat(world,"YOWCH!")
		SSmove_manager.move_away(src, target, 15, speed)
	. = ..()

//Ambush attack
/mob/living/simple_animal/hostile/alien_mimic/attack_hand(mob/living/carbon/human/target)
	if(src in target.buckled_mobs) //Can't attack if its Got ya
		return FALSE
	if(disguised)
		to_chat(target, "<span class='userdanger'>[src] latches onto you!</span>")
		visible_message("<span class='danger'>[src] latches onto [target]!</span>",\
				"<span class='userdanger'>You latch onto [target]!</span>", null, COMBAT_MESSAGE_RANGE)
		latch(target)
		restore()
		toggle_ai(AI_ON)
	else
		..()

//Spawn Event
/datum/round_event_control/alien_mimic
	name = "Spawn Alien Mimic"
	typepath = /datum/round_event/ghost_role/alien_mimic
	weight = 2
	max_occurrences = 1

/datum/round_event/ghost_role/alien_mimic
	minimum_required = 1
	role_name = "alien mimic"

/datum/round_event/ghost_role/mimic/spawn_role()
	var/list/candidates = get_candidates(ROLE_ALIEN, null, ROLE_ALIEN)
	if(!candidates.len)
		return NOT_ENOUGH_PLAYERS

	var/mob/dead/selected = pick_n_take(candidates)

	var/datum/mind/player_mind = new /datum/mind(selected.key)
	player_mind.active = 1
	if(!GLOB.xeno_spawn)
		return MAP_ERROR
	var/mob/living/simple_animal/hostile/alien_mimic/spawned_mimic = new /mob/living/simple_animal/hostile/alien_mimic(pick(GLOB.xeno_spawn))
	player_mind.transfer_to(spawned_mimic)
	player_mind.assigned_role = "Mimic"
	player_mind.special_role = "Mimic"
	player_mind.add_antag_datum(/datum/antagonist/mimic)
	to_chat(spawned_mimic, spawned_mimic.playstyle_string)
	message_admins("[ADMIN_LOOKUPFLW(spawned_mimic)] has been made into a mimic by an event.")
	log_game("[key_name(spawned_mimic)] was spawned as a mimic by an event.")
	spawned_mobs += spawned_mimic
	return SUCCESSFUL_SPAWN

/datum/action/innate/mimic_reproduce
	name = "Reproduce"
	icon_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "separate"
	background_icon_state = "bg_alien"


/datum/action/innate/mimic_reproduce/Activate()
	var/mob/living/simple_animal/hostile/alien_mimic/mimic = owner
	mimic.attempt_reproduce()
