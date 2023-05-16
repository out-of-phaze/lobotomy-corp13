//This abnormality does more things now! It should be enjoyable enough to play as.
/mob/living/simple_animal/hostile/abnormality/greed_king
	name = "King of Greed"
	desc = "A girl trapped in a magical crystal."
	icon = 'ModularTegustation/Teguicons/64x64.dmi'
	icon_state = "kog"
	icon_living = "kog"
	pixel_x = -16
	base_pixel_x = -16
	maxHealth = 3200
	health = 3200
	ranged = TRUE
	attack_verb_continuous = "chomps"
	attack_verb_simple = "chomps"
	damage_coeff = list(BRUTE = 1, RED_DAMAGE = 0, WHITE_DAMAGE = 0.5, BLACK_DAMAGE = 1.2, PALE_DAMAGE = 1.5)
	speak_emote = list("states")
	speed = 4
	vision_range = 14
	aggro_vision_range = 20
	attack_action_types = list(/datum/action/innate/abnormality_attack/kog_dash, /datum/action/innate/abnormality_attack/kog_teleport)
	stat_attack = HARD_CRIT
	melee_damage_lower = 60	//Shouldn't really attack unless a player in controlling it, I guess.
	melee_damage_upper = 80
	can_breach = TRUE
	threat_level = WAW_LEVEL
	start_qliphoth = 1
	work_chances = list(
						ABNORMALITY_WORK_INSTINCT = list(25, 25, 50, 50, 55),
						ABNORMALITY_WORK_INSIGHT = 0,
						ABNORMALITY_WORK_ATTACHMENT = list(0, 0, 50, 50, 55),
						ABNORMALITY_WORK_REPRESSION = list(0, 0, 40, 40, 40)
						)
	work_damage_amount = 10
	work_damage_type = RED_DAMAGE
	//Some Variables cannibalized from helper
	var/charge_check_time = 2 SECONDS
	var/teleport_cooldown
	var/dash_num = 50	//Mostly a safeguard
	var/list/been_hit = list()
	var/busy = FALSE

	ego_list = list(
		/datum/ego_datum/weapon/goldrush,
		/datum/ego_datum/armor/goldrush
		)
	gift_type =  /datum/ego_gifts/goldrush
	abnormality_origin = ABNORMALITY_ORIGIN_LOBOTOMY

/datum/action/innate/abnormality_attack/kog_dash
	name = "Ravenous Charge"
	icon_icon = 'ModularTegustation/Teguicons/64x48.dmi'
	button_icon_state = "kog"
	chosen_message = "<span class='colossus'>You will now dash in that direction.</span>"
	chosen_attack_num = 1

/datum/action/innate/abnormality_attack/kog_teleport
	name = "Teleport"
	icon_icon = 'icons/effects/effects.dmi'
	button_icon_state = "sparks"
	chosen_message = "<span class='warning'>You will now teleport to a random area in the facility's halls.</span>"
	chosen_attack_num = 2

/datum/action/innate/abnormality_attack/kog_teleport/Activate()
	addtimer(CALLBACK(A, .mob/living/simple_animal/hostile/abnormality/greed_king/proc/startTeleport), 1)
	to_chat(A, chosen_message)

/mob/living/simple_animal/hostile/abnormality/greed_king/Life()
	. = ..()
	if(!.) // Dead
		return FALSE
	if(!(status_flags & GODMODE))
		if(!(busy || client))
			charge_check()

/mob/living/simple_animal/hostile/abnormality/greed_king/AttackingTarget()
	if(busy)
		return
	return ..()

/mob/living/simple_animal/hostile/abnormality/greed_king/Move()
	if(busy || !client)
		return FALSE
	return ..()

/mob/living/simple_animal/hostile/abnormality/greed_king/BreachEffect(mob/living/carbon/human/user)
	..()
	icon = 'ModularTegustation/Teguicons/64x48.dmi'
	//Center it on a hallway
	pixel_y = -8
	base_pixel_y = -8

	startTeleport()	//Let's Spaghettioodle out of here

/mob/living/simple_animal/hostile/abnormality/greed_king/proc/startTeleport()
	if(busy || teleport_cooldown > world.time || (status_flags & GODMODE))
		return
	teleport_cooldown = world.time + 4.9 SECONDS
	//set busy, animate and call the proc that actually teleports.
	busy = TRUE
	animate(src, alpha = 0, time = 5)
	addtimer(CALLBACK(src, .proc/endTeleport), 5)

/mob/living/simple_animal/hostile/abnormality/greed_king/proc/endTeleport()
	var/turf/T = pick(GLOB.xeno_spawn)
	animate(src, alpha = 255, time = 5)
	forceMove(T)
	busy = FALSE
	if(!client)
		addtimer(CALLBACK(src, .proc/startTeleport), 5 SECONDS)

/mob/living/simple_animal/hostile/abnormality/greed_king/proc/charge_check()
	//targeting
	var/mob/living/carbon/human/target
	if(busy)
		return
	var/list/possible_targets = list()
	for(var/mob/living/carbon/human/H in view(20, src))
		possible_targets += H
	if(LAZYLEN(possible_targets))
		target = pick(possible_targets)
		//Start charge
		var/dir_to_target = get_cardinal_dir(get_turf(src), get_turf(target))
		if(dir_to_target)
			busy = TRUE
			addtimer(CALLBACK(src, .proc/charge, dir_to_target, 0, target), charge_check_time)
			return
	return


/mob/living/simple_animal/hostile/abnormality/greed_king/OpenFire() // This exists so players can manually charge during playable abnormalities.
	if(busy || !client)
		return
	switch(chosen_attack)
		if(1)
			var/dir_to_target = get_cardinal_dir(get_turf(src), get_turf(target))
			busy = TRUE
			charge(dir_to_target, 0, target)
	return

/mob/living/simple_animal/hostile/abnormality/greed_king/proc/charge(move_dir, times_ran, target)
	setDir(move_dir)
	var/stop_charge = FALSE
	if(times_ran >= dash_num)
		stop_charge = TRUE
	var/turf/T = get_step(get_turf(src), move_dir)
	if(!T)
		been_hit = list()
		stop_charge = TRUE
		return
	if(T.density)
		stop_charge = TRUE
	for(var/obj/structure/window/W in T.contents)
		W.obj_destruction()
	for(var/obj/machinery/door/D in T.contents)
		if(D.density)
			stop_charge = TRUE
	for(var/mob/living/simple_animal/hostile/abnormality/D in T.contents)	//This caused issues earlier
		if(D.density)
			stop_charge = TRUE

	//Stop charging
	if(stop_charge)
		busy = TRUE
		addtimer(CALLBACK(src, .proc/endCharge), 7 SECONDS)
		been_hit = list()
		return
	forceMove(T)

	//Hiteffect stuff
	for(var/mob/living/L in range(1, T))
		if(L in been_hit || L == src)
			continue
		been_hit+=L
		visible_message("<span class='boldwarning'>[src] crunches [L]!</span>")
		to_chat(L, "<span class='userdanger'>[src] rends you with its teeth!</span>")
		playsound(L, attack_sound, 75, 1)
		var/turf/LT = get_turf(L)
		new /obj/effect/temp_visual/kinetic_blast(LT)
		if(ishuman(L))
			var/mob/living/carbon/human/H = L
			H.apply_damage(800, RED_DAMAGE, null, L.run_armor_check(null, RED_DAMAGE), spread_damage = TRUE)
		else
			L.adjustRedLoss(80)
		if(L.stat >= HARD_CRIT)
			L.gib()
			continue

	playsound(src,'sound/effects/bamf.ogg', 70, TRUE, 20)
	for(var/turf/open/R in range(1, src))
		new /obj/effect/temp_visual/small_smoke/halfsecond(R)
	addtimer(CALLBACK(src, .proc/charge, move_dir, (times_ran + 1)), 2)

/mob/living/simple_animal/hostile/abnormality/greed_king/proc/endCharge()
	busy = FALSE
	if(!client)
		startTeleport()

/* Work effects */
/mob/living/simple_animal/hostile/abnormality/greed_king/NeutralEffect(mob/living/carbon/human/user, work_type, pe)
	if(prob(15))
		datum_reference.qliphoth_change(-1)
	return

/mob/living/simple_animal/hostile/abnormality/greed_king/FailureEffect(mob/living/carbon/human/user, work_type, pe)
	if(prob(80))
		datum_reference.qliphoth_change(-1)
	return



