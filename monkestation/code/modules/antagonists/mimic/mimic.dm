#define MIMIC_HEALTH_FLEE_AMOUNT 30
#define MIMIC_JITTER_CHANCE 0.8

/mob/living/simple_animal/hostile/alien_mimic
	name = "mimic"
	real_name = "mimic"
	desc = "A morphing mass of black gooey tendrils."
	speak_emote = list("warbles")
	emote_hear = list("warbles")
	faction = list("aliens") //don't wanna have them attack eachother
	icon = 'monkestation/icons/mob/animal.dmi'
	icon_state = "mimic"
	icon_living = "mimic"
	icon_dead = "mimic_dead"
	move_to_delay = 2
	a_intent = INTENT_HARM
	stop_automated_movement = 1
	status_flags = CANPUSH
	stat_attack = UNCONSCIOUS
	pass_flags = PASSTABLE | PASSMOB
	unsuitable_atmos_damage = 0 //They won't die in Space!
	minbodytemp = TCMB
	maxbodytemp = T0C + 40
	maxHealth = 75
	health = 75
	melee_damage = 10 //For some reason it does double damage so leave it at half of what you want it. I'll try to figure out hopefully before this is out.
	obj_damage = 20
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	wander = FALSE
	attacktext = "consumes"
	attack_sound = 'sound/effects/tableslam.ogg'

	var/disguised = FALSE
	var/atom/movable/form = null
	var/people_absorbed = 0
	//The target npc mimic's try to disguise as.
	var/atom/movable/ai_disg_target = null
	//attempts to reach a disguise target
	var/ai_disg_reach_attempts = 0
	var/fleeing = FALSE
	mobchatspan = "blob"
	discovery_points = 2000
	var/playstyle_string = "<span class='big bold'>You are a mimic,</span></b> an alien that made it's way on to the station. \
							You may take the form of any item nearby by clicking on it. You can latch onto people by clicking on them, \
							which is instant when you're disguised. When you latch onto someone, they can't hurt you, but other people\
							can. After someone dies, you can absorb their body and reproduce to make more mimics.</b>"

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

/mob/living/simple_animal/hostile/alien_mimic/ClickOn(atom/target_item)
	if(allowed(target_item)) //Become Items
		if(disguised)
			restore()
		var/obj/item/item = target_item
		if(!item.anchored)
			disguise(item)
			return
	. = ..()

/mob/living/simple_animal/hostile/alien_mimic/proc/allowed(atom/movable/target_item) // make it into property/proc ? not sure if worth it
	return isitem(target_item) & !istype(target_item, /obj/item/radio/intercom)

/mob/living/simple_animal/hostile/alien_mimic/proc/is_table(atom/possible_table)
	return istype(possible_table, /obj/structure/table) || istype(possible_table, /obj/structure/rack)

/mob/living/simple_animal/hostile/alien_mimic/proc/should_heal()
	return health <= MIMIC_HEALTH_FLEE_AMOUNT

/mob/living/simple_animal/hostile/alien_mimic/proc/latch(mob/living/target)
	if(target)
		if(target.buckle_mob(src, TRUE))
			target.Knockdown(10 SECONDS)
			layer = target.layer+0.01
			visible_message("<span class='warning'>[src] latches onto [target]!</span>")
			return TRUE
		else
			to_chat("<span class='warning'>You failed to latch onto the target!</span>")
	return FALSE

/mob/living/simple_animal/hostile/alien_mimic/proc/attempt_reproduce()
	if(people_absorbed > 0)
		if(do_mob(src, src, 5 SECONDS))
			var/mob/living/simple_animal/hostile/alien_mimic/split_mimic = new(src.loc)
			split_mimic.ping_ghosts()
			people_absorbed--
			return
		return
	to_chat(src,"<span class='warning'>You haven't absorbed enough people!</span>")

/mob/living/simple_animal/hostile/alien_mimic/attack_ghost(mob/user)
	if(QDELETED(src))
		return
	if(key)
		return
	var/possess_ask = alert("Become a [name]? (Warning, You can no longer be cloned, and all past lives will be forgotten!)","Are you positive?","Yes","No")
	if(possess_ask == "No" || QDELETED(src))
		return
	if(suiciding) //clear suicide status if the old occupant suicided.
		set_suicide(FALSE)
	transfer_personality(user)

/mob/living/simple_animal/hostile/alien_mimic/proc/transfer_personality(mob/candidate)
	if(QDELETED(src))
		return
	if(key) //Prevents hostile takeover if two ghosts get the prompt or link for the same mimic.
		to_chat(candidate, "<span class='warning'>This [name] was taken over before you could get to it!</span>")
		return FALSE
	ckey = candidate.ckey
	to_chat(src, playstyle_string)
	mind.assigned_role = "Mimic"
	set_stat(CONSCIOUS)
	remove_from_dead_mob_list()
	add_to_alive_mob_list()
	toggle_ai(AI_OFF) //Turns the AI off so it doesn't move without player input

	return TRUE

/mob/living/simple_animal/hostile/alien_mimic/proc/ping_ghosts()
	notify_ghosts("[name] created in [get_area(src)]!", enter_link = "<a href=?src=[REF(src)];activate=1>(Click to enter)</a>", source = src, action = NOTIFY_ATTACK, flashwindow = FALSE, notify_suiciders = FALSE)

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
		var/mob/living/living_target = target
		mobchatspan = living_target.mobchatspan
	else
		mobchatspan = initial(mobchatspan)

	set_varspeed(move_to_delay*4) //4x slower when disguised
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

	set_varspeed(initial(move_to_delay))
	med_hud_set_health()
	med_hud_set_status() //we are not an object

/mob/living/simple_animal/hostile/alien_mimic/Initialize(mapload)
	var/datum/action/innate/mimic_reproduce/ability = new
	ability.Grant(src)
	. = ..()

/mob/living/simple_animal/hostile/alien_mimic/Life()
	if(isliving(buckled))
		var/mob/living/living_food = buckled
		if(living_food.stat == DEAD)
			resist_buckle()
	if(disguised * prob(MIMIC_JITTER_CHANCE))
		visible_message("<span class='danger'>[src] jitters a bit...</span>",\
				"<span class='userdanger'>You jitter a bit!</span>", null)
	. = ..()


/mob/living/simple_animal/hostile/alien_mimic/MoveToTarget(list/possible_targets)
	if(fleeing)
		SSmove_manager.move_away(src, target, 15, move_to_delay)
		stop_automated_movement = 1
		if(!target || !CanAttack(target))
			LoseTarget()
			return FALSE
	else
		..()

/mob/living/simple_animal/hostile/alien_mimic/LoseTarget()
	if(fleeing)
		fleeing = FALSE
	..()

/mob/living/simple_animal/hostile/alien_mimic/handle_automated_action()
	if(AIStatus == AI_OFF)
		return FALSE
	var/list/possible_targets = ListTargets() //we look around for potential targets and make it a list for later use.

	if(environment_smash)
		EscapeConfinement()

	if(AICanContinue(possible_targets))
		var/atom/target_from = GET_TARGETS_FROM(src)
		if(!QDELETED(target) && !target_from.Adjacent(target))
			DestroyPathToTarget()
		if(!MoveToTarget(possible_targets))     //if we lose our target
			if(AIShouldSleep(possible_targets))	// we try to acquire a new one
				toggle_ai(AI_IDLE)			// otherwise we go idle
	return TRUE


/mob/living/simple_animal/hostile/alien_mimic/attacked_by(obj/item/item, mob/living/target)
	if(src in target.buckled_mobs) //Can't attack if its Got ya
		return FALSE
	..()

/mob/living/simple_animal/hostile/alien_mimic/attack_hand(mob/living/target)
	if(src in target.buckled_mobs)
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

/mob/living/simple_animal/hostile/alien_mimic/CanAttack(atom/the_target)
	if(the_target == buckled)
		return TRUE //fixes it jumping off of people immediately
	if(iscarbon(the_target))
		var/mob/living/carbon/carbon_target = the_target
		if(carbon_target.stat == DEAD & should_heal() & !HAS_TRAIT(carbon_target, TRAIT_HUSK))
			return TRUE
	if(isliving(the_target))
		var/mob/living/living_target = the_target
		var/mob/living/simple_animal/hostile/alien_mimic/attacking_friend = locate() in living_target.buckled_mobs
		if(attacking_friend & attacking_friend != src)
			return FALSE
		var/faction_check = faction_check_mob(living_target)
		if((faction_check && !attack_same) || living_target.stat)
			return FALSE
	return TRUE

/mob/living/simple_animal/hostile/alien_mimic/adjustHealth(amount, updating_health, forced)
	if(amount > 0) //if you take damage, run
		if(buckled)
			resist_buckle()
		if(!target)
			FindTarget()
		fleeing = TRUE
	..()

/mob/living/simple_animal/hostile/alien_mimic/AttackingTarget()
	if(target == src) //Remove your disguise
		restore()
		return
	if(isliving(target) & !buckled) //Latch onto people
		var/mob/living/victim = target
		if(iscarbon(victim) & victim.stat == DEAD & !HAS_TRAIT(victim, TRAIT_HUSK)) //Absorb someone to heal
			visible_message("<span class='warning'>[src] starts absorbing [victim]!</span>", \
						"<span class='userdanger'>You start absorbing [victim].</span>")
			if(do_mob(src, victim, 10 SECONDS))
				victim.become_husk(MIMIC_ABSORB)
				people_absorbed++
				adjustHealth(-30)
		if(disguised) //Insta latch if youre disguised
			latch(victim)
			restore()
			return
		else if(do_mob(src, target, 3 SECONDS)) //Latch after a bit if you arent
			latch(victim)
			return
	return ..() //If you're buckled, just attack normally

/mob/living/simple_animal/hostile/alien_mimic/Aggro()
	if(disguised & get_dist(src,target)<=1) //Instantly latch onto them
		latch(target)
		restore()
		toggle_ai(AI_ON)

/mob/living/simple_animal/hostile/alien_mimic/death(gibbed)
	if(disguised)
		visible_message("<span class='warning'>[src] explodes in a pile of black goo!</span>", \
						"<span class='userdanger'>You feel weak as your disguise start to dissolve.</span>")
		restore()
	..()

/mob/living/simple_animal/hostile/alien_mimic/AIShouldSleep(var/list/possible_targets)
	var/should_sleep = !FindTarget(possible_targets, 1)
	if(should_sleep) //Attempt to disguise
		if(!ai_disg_target)
			var/list/things = list()
			for(var/atom/thing as() in view(src))
				if(allowed(thing))
					things += thing
			if(things.len)
				var/atom/movable/picked_thing = pick(things)
				ai_disg_target = picked_thing
			else
				return TRUE //just give up if there's nothin
		if(Adjacent(ai_disg_target) || ai_disg_reach_attempts >= 10) //give it 10 tries before just turning into it
			//Get on any nearby tables after disguising
			var/list/tables = list()
			for(var/atom/possible_table as() in view(1,src))
				if(is_table(possible_table))
					tables += possible_table
			if(tables.len)
				var/atom/movable/chosen_table = pick(tables)
				Move(get_turf(chosen_table))
			ai_disg_reach_attempts = 0
			disguise(ai_disg_target)
		else
			if(buckled)
				resist_buckle()
			ai_disg_reach_attempts++
			Goto(ai_disg_target, move_to_delay, 1) //Go right next to it
			return FALSE
		return TRUE
	return FALSE

/mob/living/simple_animal/hostile/alien_mimic/consider_wakeup()
	var/list/target_list

	target_list = ListTargets()
	//Wait until they're alone
	if(target_list.len>1)
		return

	FindTarget(target_list, 1)
	if(iscarbon(target))
		var/mob/living/carbon/victim = target

		if(victim.stat == DEAD & should_heal() & !HAS_TRAIT(victim, TRAIT_HUSK)) //Heal if you're supposed to
			toggle_ai(AI_ON)
			restore()
			return

	var/target_dist = get_dist(target,src)
	//Only attack when they get close
	if(target_dist>1)
		return
	..()

//AI can't track mimics
/mob/living/simple_animal/hostile/alien_mimic/can_track(mob/living/user)
	if(disguised)
		return FALSE
	return ..()

/datum/action/innate/mimic_reproduce
	name = "Reproduce"
	icon_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "separate"
	background_icon_state = "bg_alien"

/datum/action/innate/mimic_reproduce/Activate()
	var/mob/living/simple_animal/hostile/alien_mimic/mimic = owner
	mimic.attempt_reproduce()
