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
	desc = "A blade forged out of daemonic energy."
	icon_state = "daemon_blade"
	item_state = "daemon_blade"
	lefthand_file = 'monkestation/icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'monkestation/icons/mob/inhands/weapons/swords_righthand.dmi'
	force = 30
	throwforce = 10

/obj/item/armament/daemon_blade/Initialize(mapload)
	. = ..()

/obj/item/armament/daemon_blade/attack_self(mob/user)
	. = ..()

/obj/item/armament/daemon_blade/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()


/obj/item/armament/blood_scythe
	name = "blood scythe"
	desc = "A scythe created from magic infused blood."
	icon_state = "blood_scythe"
	item_state = "blood_scythe"
	lefthand_file = 'monkestation/icons/mob/inhands/polearms_lefthand.dmi'
	righthand_file = 'monkestation/icons/mob/inhands/polearms_righthand.dmi'
	force = 25
	throwforce = 10
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
