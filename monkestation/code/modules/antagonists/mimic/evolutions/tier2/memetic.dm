/mob/living/simple_animal/hostile/alien_mimic/tier2/memetic
	name = "memetic mimic"
	real_name = "memetic mimic"
	// icon_state = "memetic"
	// icon_living = "memetic"
	melee_damage = 5
	secondary_damage_type = BURN
	hivemind_modifier = "memetic"
	playstyle_string = "<span class='big bold'>You are a memetic mimic,</span></b> you deal brute damage, and can control people you latch onto.</b>"
	var/mob/living/mimic_mezmerized/mind_holder

/mob/living/simple_animal/hostile/alien_mimic/tier2/memetic/Initialize(mapload)
	. = ..()
	var/obj/effect/proc_holder/spell/self/mimic_control/mezmerize = new
	AddSpell(mezmerize)

	mind_holder = new(src)

/mob/living/simple_animal/hostile/alien_mimic/tier2/memetic/AttackingTarget()
	if(!isliving(target))
		return ..()

	var/mob/living/victim = target
	if(buckled && buckled == victim && HAS_TRAIT(victim, TRAIT_SHOCKIMMUNE))
		victim.Stun(1 SECONDS)
		victim.electrocute_act(1, src)
	..()

/obj/effect/proc_holder/spell/self/mimic_control
	name = "Mezmerize"
	desc = "Take control of a person you're latched onto temporarily."
	action_icon = 'icons/mob/actions/actions_hive.dmi'
	action_icon_state = "warp"
	clothes_req = FALSE
	action_background_icon_state = "bg_alien"
	charge_max = 2 MINUTES

/obj/effect/proc_holder/spell/self/mimic_control/cast(mob/living/simple_animal/hostile/alien_mimic/tier2/memetic/user)
	if(isliving(user.buckled))
		var/mob/living/control_target = user.buckled

		to_chat(control_target,"<span class='userdanger'>[user] takes control!</span>")
		control_target.visible_message("<span class='warning'>[user] melts into [control_target]'s body.</span>","<span class'notice'>You melt into [control_target] and gain control of their body.</span>")

		control_target.mind.transfer_to(user.mind_holder)
		user.mind.transfer_to(control_target)

		addtimer(CALLBACK(src, .proc/undo_control, user, control_target, user.mind_holder), 60 SECONDS)

/obj/effect/proc_holder/spell/self/mimic_control/proc/undo_control(mob/living/mimic_body, mob/living/controlled_body, mob/living/mind_holder)
	controlled_body.visible_message("<span class='warning'>[mimic_body] melts out of [controlled_body]'s body.</span>","<span class'notice'>You come out of [controlled_body]'s body.</span>")

	controlled_body.mind.transfer_to(mimic_body)
	mind_holder.mind.transfer_to(controlled_body)

//Back Seat for the mezmerize ability
/mob/living/mimic_mezmerized
	name = "mezmerized conscience"
	real_name = "mezmerized conscience"

/mob/living/mimic_mezmerized/say(message, bubble_type, var/list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	to_chat(src, "<span class='warning'>You are not in control of your body!</span>")
	return FALSE

/mob/living/mimic_mezmerized/emote(act, m_type = null, message = null, intentional = FALSE)
	return FALSE
