/datum/brain_trauma/special/obsessed
	name = "Psychotic Schizophrenia"
	desc = "Patient has a subtype of delusional disorder, becoming irrationally attached to someone."
	scan_desc = "psychotic schizophrenic delusions"
	gain_text = "If you see this message, make a github issue report. The trauma initialized wrong."
	lose_text = "<span class='warning'>The voices in your head fall silent.</span>"
	can_gain = TRUE
	random_gain = FALSE
	resilience = TRAUMA_RESILIENCE_SURGERY
	var/mob/living/obsession
	var/datum/objective/watch/watching_objective
	var/datum/antagonist/obsessed/antagonist
	var/viewing = FALSE //it's a lot better to store if the owner is watching the obsession than checking it twice between two procs

	var/total_time_creeping = 0 //just for roundend fun
	var/time_spent_away = 0
	var/obsession_hug_count = 0

/datum/brain_trauma/special/obsessed/on_gain()

	//setup, linking, etc//
	if(!obsession)//admins didn't set one
		obsession = find_obsession()
		if(!obsession)//we didn't find one
			lose_text = ""
			qdel(src)
			return

	RegisterSignal(obsession.mind, COMSIG_MIND_CRYOED, .proc/on_obsession_cryoed)
	gain_text = "<span class='warning'>You hear a sickening, raspy voice in your head. It wants one small task of you...</span>"
	owner.mind.add_antag_datum(/datum/antagonist/obsessed)
	antagonist = owner.mind.has_antag_datum(/datum/antagonist/obsessed)
	antagonist.trauma = src
	..()
	//antag stuff//
	antagonist.forge_objectives(obsession.mind)
	antagonist.greet()

/datum/brain_trauma/special/obsessed/on_life()
	if(!obsession)
		viewing = FALSE
		return
	if(get_dist(get_turf(owner), get_turf(obsession)) > 7)
		viewing = FALSE //they are further than our viewrange they are not viewing us
		out_of_view()
		return//so we're not searching everything in view every tick
	if(obsession in viewers(7, owner))
		viewing = TRUE
	else
		viewing = FALSE

	if(!viewing)
		out_of_view()
		return

	total_time_creeping += 2 SECONDS
	time_spent_away = 0
	if(watching_objective)//if an objective needs to tick down, we can do that since traumas coexist with the antagonist datum
		watching_objective.timer -= 2 SECONDS //mob subsystem ticks every 2 seconds(?), remove 20 deciseconds from the timer. sure, that makes sense.

	//When you see your obsession dead + when you're around them while they're alive
	if(obsession.stat == DEAD)
		if(rand(1,5) == 1)
			switch(rand(1,5))
				if(1)
					owner.blur_eyes(10)
					shake_camera(owner, 5, 1)
					owner.emote("cry")
					to_chat(owner,"<span class='warning'>This can't be happening!</span>")
				if(2)
					owner.emote("twitch")
				if(3)
					owner.emote("gasp")
					owner.adjustStaminaLoss(rand(15,30))
					to_chat(owner,"<span class='warning'>It hurts to breath</span>")
				if(4)
					owner.Immobilize(3 SECONDS)
					owner.drop_all_held_items()
					to_chat(owner,"<span class='warning'>You lock up.</span>")
				if(5)
					owner.vomit()
	else
		SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "creeping", /datum/mood_event/creeping, obsession.name)

		if(rand(1,20) == 1)
			switch(rand(1,5))
				if(1)
					owner.emote("blush")
				if(2)
					owner.emote("giggle")
				if(3)
					owner.blur_eyes(5)
					to_chat(owner,"<span class='notice'>They're right there...</span>")
				if(4)
					owner.Immobilize(5 SECONDS)
					to_chat(owner,"<span class='warning'>You're too nervous around them, you lock up!</span>")
				if(5)
					//TODO: STUTTER

/datum/brain_trauma/special/obsessed/proc/out_of_view()
	time_spent_away += 2 SECONDS
	if(time_spent_away > 5 MINUTES)
		SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "creeping", /datum/mood_event/notcreepingsevere, obsession.name)
	else if (time_spent_away > 2 MINUTES)
		SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "creeping", /datum/mood_event/notcreeping, obsession.name)

/datum/brain_trauma/special/obsessed/on_lose()
	..()

	UnregisterSignal(obsession.mind, COMSIG_MIND_CRYOED)
	antagonist?.trauma = null
	owner.mind.remove_antag_datum(/datum/antagonist/obsessed)

// /datum/brain_trauma/special/obsessed/handle_speech(datum/source, list/speech_args)
// 	if(!viewing)
// 		return
// 	var/datum/component/mood/mood = owner.GetComponent(/datum/component/mood)
// 	if(mood && mood.sanity >= SANITY_GREAT && social_interaction())
// 		speech_args[SPEECH_MESSAGE] = ""

/datum/brain_trauma/special/obsessed/on_hug(mob/living/hugger, mob/living/hugged)
	if(hugged == obsession)
		obsession_hug_count++

/datum/brain_trauma/special/obsessed/proc/on_obsession_cryoed()
	SIGNAL_HANDLER

	UnregisterSignal(obsession.mind, COMSIG_MIND_CRYOED)
	var/message = "You get the feeling [obsession] is no longer within reach."
	obsession = find_obsession()
	if(!obsession)//we didn't find one
		lose_text = "<span class='warning'>[message] The voices in your head fall silent.</span>"
		qdel(src)
		return
	RegisterSignal(obsession.mind, COMSIG_MIND_CRYOED, .proc/on_obsession_cryoed)
	to_chat(owner, "<span class='warning'>[message] The voices have a new task for you...</span>")
	antagonist.objectives = list()
	antagonist.forge_objectives(obsession.mind)
	to_chat(owner, "<B>You don't know their connection, but The Voices compel you to stalk [obsession], forcing them into a state of constant paranoia.</B>")
	owner.mind.announce_objectives()

// /datum/brain_trauma/special/obsessed/proc/social_interaction()
// 	var/fail = FALSE //whether you can finish a sentence while doing it
// 	owner.stuttering = max(3, owner.stuttering)
// 	owner.blur_eyes(10)
// 	switch(rand(1,4))
// 		if(1)
// 			shake_camera(owner, 15, 1)
// 			owner.vomit()
// 			fail = TRUE
// 		if(2)
// 			INVOKE_ASYNC(owner, /mob.proc/emote, "cough")
// 			owner.dizziness += 10
// 			fail = TRUE
// 		if(3)
// 			to_chat(owner, "<span class='userdanger'>You feel your heart lurching in your chest...</span>")
// 			owner.Stun(20)
// 			shake_camera(owner, 15, 1)
// 		if(4)
// 			to_chat(owner, "<span class='warning'>You faint.</span>")
// 			owner.Unconscious(80)
// 			fail = TRUE
// 	return fail


/datum/brain_trauma/special/obsessed/proc/find_obsession()
	var/chosen_victim
	var/list/possible_targets = list()
	var/list/viable_minds = list()
	for(var/mob/Player in GLOB.player_list)//prevents crewmembers falling in love with nuke ops they never met, and other annoying hijinks
		if(Player.mind && Player.stat != DEAD && !isnewplayer(Player) && !isbrain(Player) && Player.client && Player != owner && SSjob.GetJob(Player.mind.assigned_role))
			viable_minds += Player.mind
	for(var/datum/mind/possible_target in viable_minds)
		if(possible_target != owner && ishuman(possible_target.current))
			possible_targets += possible_target.current
	if(possible_targets.len > 0)
		chosen_victim = pick(possible_targets)
	return chosen_victim
