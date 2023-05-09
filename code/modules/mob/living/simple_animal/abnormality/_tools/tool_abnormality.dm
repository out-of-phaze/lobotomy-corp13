/obj/structure/toolabnormality
	name = "tool abnormality"
	desc = "This is weird. Please inform a coder that you have this. Thanks!"
	icon = 'ModularTegustation/Teguicons/toolabnormalities.dmi'
	icon_state = "mirror"
	anchored = TRUE
	density = TRUE
	resistance_flags = INDESTRUCTIBLE

GLOBAL_LIST_INIT(unspawned_tools, list(
	/obj/structure/toolabnormality/fateloom,
	/obj/structure/toolabnormality/theonite_slab,
	/obj/structure/toolabnormality/treesap,
	/obj/structure/toolabnormality/vivavoce,
	/obj/structure/toolabnormality/behaviour,
	/obj/structure/toolabnormality/bracelet,
	/obj/structure/toolabnormality/dr_jekyll,
	/obj/structure/toolabnormality/aspiration,
	/obj/structure/toolabnormality/skin,
	/obj/structure/toolabnormality/theresia,
	/obj/structure/toolabnormality/mirror,
	/obj/structure/toolabnormality/wishwell
))

/obj/effect/landmark/toolspawn
	name = "tool spawner"
	desc = "This is weird. Please inform a coder that you have this. Thanks!"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "x4"

/obj/effect/landmark/toolspawn/Initialize()
	..()
	if(!LAZYLEN(GLOB.unspawned_tools)) // You shouldn't ever need this but I mean go on I guess
		return INITIALIZE_HINT_QDEL
	var/spawning = pick_n_take(GLOB.unspawned_tools)
	new spawning(get_turf(src))
	return INITIALIZE_HINT_QDEL

