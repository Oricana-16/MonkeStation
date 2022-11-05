/obj/item/daemon_blade
	name = "daemon blade"
	desc = "A blade forged out of daemonic energy."
	icon_state = "daemon_blade"
	item_state = "daemon_blade"
	worn_icon_state = "daemon_blade"
	lefthand_file = 'monkestation/icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'monkestation/icons/mob/inhands/weapons/swords_righthand.dmi'
	force = 30
	throwforce = 10
	w_class = WEIGHT_CLASS_BULKY
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "tore", "ripped", "diced", "cut")
	slot_flags = ITEM_SLOT_BACK|ITEM_SLOT_BELT
	sharpness = IS_SHARP
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF | INDESTRUCTIBLE

/obj/item/daemon_blade/Initialize(mapload)
	. = ..()

/obj/item/daemon_blade/attack_self(mob/user)

/obj/item/daemon_blade/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()

