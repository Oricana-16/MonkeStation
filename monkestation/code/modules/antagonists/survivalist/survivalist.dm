/datum/antagonist/survivalist/daemon_mask
	name = "Daemon Mask Spirit"

/datum/antagonist/survivalist/daemon_mask/greet()
	to_chat(owner, "<span class='notice'>You are a spirit inhabiting the daemon mask. Do whatever it takes to survive, help or betray the crew as you see fit.</span>")
	owner.announce_objectives()
