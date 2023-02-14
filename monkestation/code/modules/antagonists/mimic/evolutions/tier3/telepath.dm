/mob/living/simple_animal/hostile/alien_mimic/tier3/telepathic
	name = "telepathic mimic"
	real_name = "telepathic mimic"
	melee_damage = 7
	secondary_damage_type = BRUTE
	hivemind_modifier = "telepathic"
	playstyle_string = "<span class='big bold'>You are a telepathic mimic,</span></b> you can now make new minds to control people.</b>"
	var/mob/living/mimic_telepath_mind/held_mind
	// var/mob/living/mimic_mezmerized/mind_holder

/mob/living/simple_animal/hostile/alien_mimic/tier3/telepathic/Initialize(mapload)
	. = ..()
	held_mind = new(src)

/mob/living/mimic_telepath_mind
	name = "telepath mind"
	real_name = "telepath mind"
	var/mob/living/owner

/mob/living/mimic_telepath_mind/Life()
	if(!owner)
		return

	if(owner.stat == DEAD)
		qdel(src)


/mob/living/mimic_telepath_mind/say(message, bubble_type, var/list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	to_chat(src, "<span class='warning'>You are not in control of your body!</span>")
	return FALSE

/mob/living/mimic_telepath_mind/emote(act, m_type = null, message = null, intentional = FALSE)
	return FALSE
