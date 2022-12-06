/obj/item/armament
	name = "armament"
	desc = "a daemon weapon."
	force = 30
	throwforce = 10
	w_class = WEIGHT_CLASS_BULKY
	hitsound = 'sound/weapons/bladeslice.ogg'
	icon = 'monkestation/icons/obj/items_and_weapons.dmi'
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "tore", "ripped", "diced", "cut")
	slot_flags = ITEM_SLOT_BACK|ITEM_SLOT_BELT
	sharpness = IS_SHARP
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF | INDESTRUCTIBLE
	var/last_ability_use = 0 // time the last ability was used
	var/ability_cooldown = 5 SECONDS

/obj/item/armament/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(last_ability_use + ability_cooldown > world.time )
		return TRUE
	last_ability_use = world.time

/obj/item/armament/daemon_blade
	name = "daemon blade"
	desc = "A blade formed out of demonic energy. Activate in hand to throw flames."
	icon_state = "daemon_blade"
	item_state = "daemon_blade"
	lefthand_file = 'monkestation/icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'monkestation/icons/mob/inhands/weapons/swords_righthand.dmi'
	force = 20
	ability_cooldown = 20 SECONDS
	var/flame_toggle = FALSE

/obj/item/armament/daemon_blade/Initialize(mapload)
	. = ..()

/obj/item/armament/daemon_blade/attack_self(mob/user)
	. = ..()
	if(last_ability_use + ability_cooldown > world.time ) //Can't turn it on if its on cooldown
		flame_toggle = FALSE
		return
	flame_toggle = !flame_toggle
	if (flame_toggle)
		icon_state = "daemon_blade_fire"
		to_chat(user, "<span class='warning'>[src] glows bright with mysterious runes. Click a target to burn it</span>")
	else
		icon_state = "daemon_blade"
		to_chat(user, "<span class='warning'>[src] stops glowing.</span>")
	return

/obj/item/armament/daemon_blade/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(flame_toggle)
		. = ..()
		var/turflist = get_line(user, get_turf(target))
		flame_turf(turflist)
		flame_toggle = FALSE
		icon_state = "daemon_blade"
		to_chat(user, "<span class='warning'>[src] stops glowing.</span>")

/obj/item/armament/daemon_blade/proc/flame_turf(turflist)
	var/turf/previous_turf = get_turf(src)
	for(var/turf/current_turf in turflist)
		if(current_turf == get_turf(src))
			continue
		if(previous_turf == get_turf(src))
			previous_turf = current_turf
			continue
		new /obj/effect/hotspot(previous_turf)
		for(var/mob/living/hit_creature in previous_turf)
			hit_creature.adjustFireLoss(6)
			hit_creature.throw_at(current_turf, 1, 2)
			hit_creature.Stun(0.5 SECONDS)
		previous_turf = current_turf
		sleep(1)

/obj/item/armament/blood_scythe
	name = "blood scythe"
	desc = "A scythe created from the blood of demons. Click on a distant target to bring them closer."
	icon_state = "blood_scythe"
	item_state = "blood_scythe"
	lefthand_file = 'monkestation/icons/mob/inhands/polearms_lefthand.dmi'
	righthand_file = 'monkestation/icons/mob/inhands/polearms_righthand.dmi'
	force = 15
	ability_cooldown = 15 SECONDS

/obj/item/armament/blood_scythe/Initialize(mapload)
	. = ..()

/obj/item/armament/blood_scythe/attack_self(mob/user)
	. = ..()

/obj/item/armament/blood_scythe/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(.)
		return
	if(!proximity_flag)
		if(!isliving(target))
			return
		var/target_turf = get_step(user, user.dir)
		var/mob/living/living_target = target
		if(isopenturf(target_turf))
			do_teleport(living_target, target_turf, channel = TELEPORT_CHANNEL_FREE, no_effects = TRUE, teleport_mode = TELEPORT_MODE_DEFAULT)
			living_target.Stun(3 SECONDS)

/obj/item/armament/hell_hammer
	name = "hell hammer"
	desc = "A hammer forged from the rocks of hell. Activate in hand to trigger a shockwave."
	icon_state = "hell_hammer"
	item_state = "hell_hammer"
	lefthand_file = 'monkestation/icons/mob/inhands/weapons/hammers_lefthand.dmi'
	righthand_file = 'monkestation/icons/mob/inhands/weapons/hammers_lefthand.dmi'
	sharpness = IS_BLUNT
	hitsound = "swing_hit"
	attack_weight = 2
	force = 20
	ability_cooldown = 25 SECONDS

/obj/item/armament/hell_hammer/Initialize(mapload)
	. = ..()

/obj/item/armament/hell_hammer/attack_self(mob/user)
	. = ..()
	if(last_ability_use + ability_cooldown > world.time )
		return TRUE
	last_ability_use = world.time
	user.visible_message("<span class='danger'>[user] slams [src] onto the ground, creating a shockwave.</span>", "<span class='notice'>You slam [src] into the ground, creating a shockwave.</span>")
	playsound(src, 'sound/effects/grillehit.ogg', 100)
	for(var/atom/movable/shockwave_target as mob|obj in oview(5,user))
		if(shockwave_target.anchored)
			continue
		var/throwtarget = get_edge_target_turf(user, get_dir(user, get_step_away(shockwave_target, user)))
		shockwave_target.throw_at(throwtarget, 5, 2)
		if(isliving(shockwave_target))
			var/mob/living/living_target = shockwave_target
			living_target.Knockdown(5 SECONDS)

/obj/item/armament/hell_hammer/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	return
