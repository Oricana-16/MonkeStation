/mob/living/simple_animal/pet/dog/bullterrier/walter/saulter
	name = "Saulter Goodman"
	real_name = "Saulter Goodman"
	desc = "Seccies and wardens are nothing compared to the might of this consititutional right loving lawyer."
	icon = 'monkestation/icons/mob/walterverse.dmi'
	icon_state = "saulter"
	icon_living = "saulter"
	icon_dead = "saulter_dead"
	gold_core_spawnable = FRIENDLY_SPAWN
	speak = list("barks!", "Hi, i'm Saul Goodman.", "Did you know you have rights?", "Based!")

/mob/living/simple_animal/pet/dog/bullterrier/walter/negative
	name = "Negative Walter"
	real_name = "Negative Walter"
	desc = "Nar'sie and rat'var are a lot compared to the might of this skcurtretsnom despising god."
	icon = 'monkestation/icons/mob/walterverse.dmi'
	icon_state = "negative"
	icon_living = "negative"
	icon_dead = "negative_dead"
	gold_core_spawnable = FRIENDLY_SPAWN
	deathmessage = "starts moving"
	speak = list("skrab!", "sfoow!", "retlaW", "skcurterif", "skcurtretsnom")

/mob/living/simple_animal/pet/dog/bullterrier/walter/syndicate
	name = "Syndicate Walter"
	real_name = "Syndicate Walter"
	desc = "Nanotrasen and Centcom are nothing compared to the might of this nuke loving dog."
	icon = 'monkestation/icons/mob/walterverse.dmi'
	icon_state = "syndie"
	icon_living = "syndie"
	icon_dead = "syndie_dead"
	gold_core_spawnable = FRIENDLY_SPAWN
	speak = list("barks!", "woofs!", "Walter", "Down with Nanotrasen!", "For the Syndicate!")

/mob/living/simple_animal/pet/dog/bullterrier/walter/doom
	name = "Doom Walter"
	real_name = "Doom Walter"
	desc = "Devils and Gods are nothing compared to the might of this gun loving soldier."
	icon = 'monkestation/icons/mob/walterverse.dmi'
	icon_state = "doom"
	icon_living = "doom"
	icon_dead = "doom_dead"
	gold_core_spawnable = FRIENDLY_SPAWN
	speak = list("...")

/mob/living/simple_animal/pet/dog/bullterrier/walter/space
	name = "Space Walter"
	real_name = "Space Walter"
	desc = "Exploring the galaxies is nothing for this star loving dog."
	icon = 'monkestation/icons/mob/walterverse.dmi'
	icon_state = "space"
	icon_living = "space"
	icon_dead = "space_dead"
	unsuitable_atmos_damage = 0
	minbodytemp = TCMB
	maxbodytemp = T0C + 40
	gold_core_spawnable = FRIENDLY_SPAWN
	speak = list("barks!", "woofs!", "spess!", "Walter", "firetrucks", "monstertrucks", "spaceships")

/mob/living/simple_animal/pet/dog/bullterrier/walter/sus
	name = "Suspicious Walter"
	real_name = "Suspicious Walter"
	desc = "This vent loving dog is a little suspicious..."
	icon = 'monkestation/icons/mob/walterverse.dmi'
	icon_state = "sus"
	icon_living = "sus"
	icon_dead = "sus_dead"
	gold_core_spawnable = FRIENDLY_SPAWN
	ventcrawler = VENTCRAWLER_ALWAYS
	deathmessage = "gets ejected"
	speak = list("barks!", "woofs!", "sus!", "Walter", "firetrucks", "monstertrucks", "tasks")

/mob/living/simple_animal/pet/dog/bullterrier/walter/wallter
	name = "Wallter"
	real_name = "Wallter"
	desc = "Keeping people out is nothing for this wall-shaped dog."
	icon = 'monkestation/icons/mob/walterverse.dmi'
	icon_state = "wallter"
	icon_living = "wallter"
	icon_dead = "wallter_dead"
	gold_core_spawnable = FRIENDLY_SPAWN
	move_force = MOVE_FORCE_VERY_STRONG
	move_resist = MOVE_FORCE_VERY_STRONG
	mob_size = MOB_SIZE_LARGE
	a_intent = INTENT_HARM
	status_flags = NONE
	deathmessage = "crumbles"
	speak = list("barks!", "woofs!", "Wallter", "firetrucks", "monstertrucks", "walls")

/mob/living/simple_animal/pet/dog/bullterrier/walter/clown
	name = "Clown Walter"
	real_name = "Clown Walter"
	desc = "Seccies and staff members are nothing compared to the might of this banana loving loving dog."
	icon = 'monkestation/icons/mob/walterverse.dmi'
	icon_state = "clown"
	icon_living = "clown"
	icon_dead = "clown_dead"
	gold_core_spawnable = FRIENDLY_SPAWN
	speak = list("barks!", "woofs!", "honks!", "Walter", "firetrucks", "monstertrucks")

/mob/living/simple_animal/pet/dog/bullterrier/walter/ookter
	name = "Ookter"
	real_name = "Ookter"
	desc = "Security is nothing compared to the might of this banana loving dog!"
	icon = 'monkestation/icons/mob/walterverse.dmi'
	icon_state = "ookter"
	icon_living = "ookter"
	icon_dead = "ookter_dead"
	gold_core_spawnable = FRIENDLY_SPAWN
	speak = list("OOK!", "EEP!", "OOP!", "AHH OOP!")

//Special Walters

// Small
/mob/living/simple_animal/pet/dog/bullterrier/walter/smallter
	name = "Smallter"
	real_name = "Smallter"
	desc = "Nar'sie and rat'var are nothing compared to the might of this tiny dog."
	gold_core_spawnable = FRIENDLY_SPAWN
	mob_size = MOB_SIZE_TINY
	ventcrawler = VENTCRAWLER_ALWAYS //little guy fits in the vents
	speak = list("barks", "woofs", "walter", "firetrucks", "monstertrucks")

/mob/living/simple_animal/pet/dog/bullterrier/walter/smallter/Initialize(mapload)
	. = ..()
	resize = 0.5
	update_transform()

/mob/living/simple_animal/pet/dog/bullterrier/walter/big_walter
	name = "Big Walter"
	real_name = "Big Walter"
	desc = "Nar'sie and rat'var are nothing compared to the might of this massive dog."
	gold_core_spawnable = FRIENDLY_SPAWN
	speak = list("BARKS", "WOOFS", "WALTER", "FIRETRUCKS", "MONSTERTRUCKS")

/mob/living/simple_animal/pet/dog/bullterrier/walter/big_walter/Initialize(mapload)
	. = ..()
	resize = 2
	update_transform()

// French
/mob/living/simple_animal/pet/dog/bullterrier/walter/french
	name = "French Walter"
	real_name = "French Walter"
	desc = "Nar'sie et rat'var ne sont rien comparés à la puissance de ce chien qui aime les monstertrucks."
	icon = 'monkestation/icons/mob/walterverse.dmi'
	icon_state = "french"
	icon_living = "french"
	icon_dead = "french_dead"
	gold_core_spawnable = FRIENDLY_SPAWN
	speak = list("aboiement!", "aboyer!", "Walter", "camions de pompiers", "camions monstres")

/mob/living/simple_animal/pet/dog/bullterrier/walter/french/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_MOB_SAY, .proc/handle_speech)

/mob/living/simple_animal/pet/dog/bullterrier/walter/french/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

	var/message = speech_args[SPEECH_MESSAGE]
	if(message[1] != "*")
		message = " [message]"
		var/list/french_words = strings(FRENCH_TALK_FILE, "french")

		for(var/key in french_words)
			var/value = french_words[key]
			if(islist(value))
				value = pick(value)

			message = replacetextEx(message, " [uppertext(key)]", " [uppertext(value)]")
			message = replacetextEx(message, " [capitalize(key)]", " [capitalize(value)]")
			message = replacetextEx(message, " [key]", " [value]")

		if(prob(3))
			message += pick(" Honh honh honh!"," Honh!"," Zut Alors!")
	speech_args[SPEECH_MESSAGE] = trim(message)

// British
/mob/living/simple_animal/pet/dog/bullterrier/walter/british
	name = "Bri'ish Wal'ah"
	real_name = "Bri'ish Wal'ah"
	desc = "Nar'sie and like ra''var are naw'hin' compared 'o 'he migh' of 'hiz mons'er'ruck lovin' dog."
	gold_core_spawnable = FRIENDLY_SPAWN
	speak = list("barks!", "woofs!", "Wal'ah", "fire'rucks", "mons'er'rucks")

/mob/living/simple_animal/pet/dog/bullterrier/walter/british/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_MOB_SAY, .proc/handle_speech)

/mob/living/simple_animal/pet/dog/bullterrier/walter/british/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

	var/message = speech_args[SPEECH_MESSAGE]
	if(message[1] != "*")
		message = " [message]"
		var/list/whole_words = strings(BRIISH_TALK_FILE, "words")
		var/list/british_sounds = strings(BRIISH_TALK_FILE, "sounds")
		var/list/british_appends = strings(BRIISH_TALK_FILE, "appends")

		for(var/key in whole_words)
			var/value = whole_words[key]
			if(islist(value))
				value = pick(value)

			message = replacetextEx(message, " [uppertext(key)]", " [uppertext(value)]")
			message = replacetextEx(message, " [capitalize(key)]", " [capitalize(value)]")
			message = replacetextEx(message, " [key]", " [value]")

		for(var/key in british_sounds)
			var/value = british_sounds[key]
			if(islist(value))
				value = pick(value)

			message = replacetextEx(message, "[uppertext(key)]", "[uppertext(value)]")
			message = replacetextEx(message, "[capitalize(key)]", "[capitalize(value)]")
			message = replacetextEx(message, "[key]", "[value]")

		if(prob(8))
			message += pick(british_appends)
	speech_args[SPEECH_MESSAGE] = trim(message)

// Wizard
/mob/living/simple_animal/pet/dog/bullterrier/walter/wizard
	name = "Magic Walter"
	real_name = "Magic Walter"
	desc = "Assistants and secoffs are nothing compared to the might of this magic loving dog."
	icon = 'monkestation/icons/mob/walterverse.dmi'
	icon_state = "wizard"
	icon_living = "wizard"
	icon_dead = "wizard_dead"
	speak = list("ONI SOMA", "CLANG!", "UN'LTD P'WAH", "AULIE OXIN FIERA", "GIN'YU`CAPAN")

/mob/living/simple_animal/pet/dog/bullterrier/walter/wizard/Initialize(mapload)
	// Gambling with spells :) (We can change it if it becomes a problem but this sounded funny)
	for(var/i in 1 to 3)
		var/picked_spell = pick(subtypesof(/obj/effect/proc_holder/spell))
		var/obj/effect/proc_holder/spell/cur_spell = new picked_spell
		cur_spell.clothes_req = FALSE

		if(istype(cur_spell, /obj/effect/proc_holder/spell/targeted/eminence))
			var/obj/effect/proc_holder/spell/targeted/eminence/cur_eminence_spell = cur_spell
			cur_eminence_spell.cog_cost = 0
			AddSpell(cur_eminence_spell)
		else
			AddSpell(cur_spell)

	. = ..()
