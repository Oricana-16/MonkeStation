/obj/item/autosurgeon/neuromod/mimic_composition
	name = "mimic composition neuromod"
	starting_organ = list(/obj/item/organ/cyberimp/neuromod/mimic_composition)

/obj/item/organ/cyberimp/neuromod/mimic_composition
	name = "Mimic Composition"
	desc = "This neuromod allows you to ventcrawl."

/obj/item/organ/cyberimp/neuromod/mimic_composition/Insert(mob/living/carbon/user, special, drop_if_replaced)
	. = ..()
	to_chat(owner, "<span class='notice'>Your skin feels odd and slimy. You get the urge to scamper around in the vents.</span>")
	user.ventcrawler = VENTCRAWLER_ALWAYS

/obj/item/organ/cyberimp/neuromod/mimic_composition/Remove(mob/living/carbon/user, special)
	. = ..()
	user.ventcrawler = VENTCRAWLER_NONE
