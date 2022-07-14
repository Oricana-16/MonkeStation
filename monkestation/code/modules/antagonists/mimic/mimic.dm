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
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxHealth = 75
	health = 75
	melee_damage = 10
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	wander = FALSE
	attacktext = "absorbs"
	butcher_results = list(/obj/item/food/meat/slab = 2)

	var/disguised = FALSE
	var/atom/movable/form = null

	var/people_absorbed = 0

	//The target npc mimic's go for.
	var/atom/movable/ai_disg_target = null
	//attempts to reach a disguise target
	var/ai_disg_reach_attempts = 0

	//will have a lower chance to use the same disguise multiple times
	var/list/used_disguises = list()

	var/playstyle_string = "<span class='big bold'>You are a mimic,</span></b> an alien that made it's way on to the station. \
							You may take the form of anything nearby by shift-clicking it.</b>"

	mobchatspan = "blob"
	discovery_points = 2000

/mob/living/simple_animal/hostile/alien_mimic/Initialize(mapload)
	var/datum/action/innate/mimic_reproduce/ability = new
	ability.Grant(src)
	. = ..()

/mob/living/simple_animal/hostile/alien_mimic/ClickOn(atom/A)
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
	return isitem(target)

/mob/living/simple_animal/hostile/alien_mimic/proc/latch(mob/living/target)
	if(target)
		if(target.buckle_mob(src, TRUE))
			target.Knockdown(10 SECONDS) //Really get em if they're down
			layer = target.layer+0.01
			visible_message("<span class='warning'>[src] latches onto [target]!</span>")
			return TRUE
		else
			to_chat("<span class='warning'>You failed to latch onto the target!</span>")
	return FALSE

/mob/living/simple_animal/hostile/alien_mimic/proc/attempt_reproduce()
	if(people_absorbed > 0)

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
		var/mob/living/victim = target
		if(iscarbon(target) & victim.stat == DEAD)
			visible_message("<span class='warning'>[src] starts absorbing [target]!</span>", \
						"<span class='userdanger'>You start absorbing [target].</span>")
			if(do_mob(src, target, 10 SECONDS))
				target.become_husk(MIMIC_ABSORB)
				people_absorbed++
		if(disguised)
			latch(victim)
			restore()
			return
		else if(do_mob(src, target, 3 SECONDS))
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
	if(disguised & get_dist(src,target)<=1) //Instantly latch onto them
		latch(target)
		restore()
	..()
	// restore()

/mob/living/simple_animal/hostile/alien_mimic/LoseAggro()
	vision_range = initial(vision_range)

/mob/living/simple_animal/hostile/alien_mimic/AIShouldSleep(var/list/possible_targets)
	var/should_sleep = !FindTarget(possible_targets, 1)
	if(should_sleep)
		if(!ai_disg_target)
			var/list/things = list()
			for(var/atom/thing as() in view(src))
				if(allowed(thing))
					things += thing
			var/atom/movable/picked_thing = pick(things)
			ai_disg_target = picked_thing
		if(Adjacent(ai_disg_target) || ai_disg_reach_attempts >= 10) //give it 10 tries before just turning into it
			ai_disg_reach_attempts = 0
			used_disguises += ai_disg_target
			disguise(ai_disg_target)
		else
			if(buckled)
				resist_buckle()
			ai_disg_reach_attempts++
			Goto(ai_disg_target, speed, 1) //Go right next to it
			return FALSE
		return TRUE
	return FALSE

/mob/living/simple_animal/hostile/consider_wakeup()
	var/list/target_list

	target_list = ListTargets()

	if(target_list.len>1) //Wait until they're alone
		return
	FindTarget(target_list, 1)
	if(get_dist(src,target)>1) //Only attack when they get close
		return
	..()

/mob/living/simple_animal/hostile/CanAttack(atom/the_target)
	if(locate(/mob/living/simple_animal/slime) in the_target.buckled_mobs)
	..()

//If the AI can track the mob.
/mob/living/simple_animal/hostile/alien_mimic/can_track(mob/living/user)
	if(disguised)
		return FALSE
	return ..()

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
