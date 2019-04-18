/mob/living/carbon/human/proc/handle_emote_vr(var/act,var/m_type=1,var/message = null)

	var/muzzled = is_muzzled()		//Eclipse Edit: Can't awoo while muzzled.

	switch(act)
		if ("vwag")
			if(toggle_tail_vr(message = 1))
				m_type = 1
				message = "[wagging ? "starts" : "stops"] wagging their tail."
			else
				return 1
		if ("vflap")
			if(toggle_wing_vr(message = 1))
				m_type = 1
				message = "[flapping ? "starts" : "stops"] flapping their wings."
			else
				return 1
		if ("mlem")
			if(!muzzled)		//Eclipse Edit: can't mlem if your nose is blocked.
				message = "mlems [get_visible_gender() == MALE ? "his" : get_visible_gender() == FEMALE ? "her" : "their"] tongue up over [get_visible_gender() == MALE ? "his" : get_visible_gender() == FEMALE ? "her" : "their"] nose. Mlem."
				m_type = 1
			else
				return 1
		if ("awoo")
			if(!muzzled)		//Eclipse Edit: can't awoo if you're gagged.
				message = "lets out an awoo."
				m_type = 2
				playsound(loc, 'modular_citadel/sound/voice/awoo.ogg', 50, 1, -1)
			else
				message = "makes a strange noise."
				m_type = 2
		if ("nya")
			if(!muzzled)		//Eclipse Edit: can't make cat noises if you're gagged.
				message = "lets out a nya."
				m_type = 2
				playsound(loc, 'modular_citadel/sound/voice/nya.ogg', 50, 1, -1)
			else
				message = "makes a noise."
				m_type = 2
		if ("peep")
			if(!muzzled)		//Eclipse Edit: can't make bird noises if you're gagged.
				message = "peeps like a bird."
				m_type = 2
				playsound(loc, 'modular_citadel/sound/voice/peep.ogg', 50, 1, -1)
			else
				message = "makes a noise."
				m_type = 2
		if ("weh")
			if(!muzzled)		//Eclipse Edit: Can't make weh noises if you're gagged (okay, you probably could, but for consistency's sake you can't here).
				message = "lets out a weh."
				m_type = 2
				playsound(loc, 'modular_citadel/sound/voice/weh.ogg', 50, 1, -1)
			else
				message = "makes a weak noise."
				m_type = 2
		if ("nsay")
			nsay()
			return TRUE
		if ("nme")
			nme()
			return TRUE
		if ("flip")
///////////////////////// CITADEL STATION ADDITIONS START
			emoteDanger =  min(1 + (emoteDanger*2), 100)
			var/danger = emoteDanger //Base chance to break something.
///////////////////////// CITADEL STATION ADDITIONS END
			var/list/involved_parts = list(BP_L_LEG, BP_R_LEG, BP_L_FOOT, BP_R_FOOT)
			for(var/organ_name in involved_parts)
				var/obj/item/organ/external/E = get_organ(organ_name)
				if(!E || E.is_stump() || E.splinted || (E.status & ORGAN_BROKEN))
					involved_parts -= organ_name
					danger += 5 //Add 5% to the chance for each problem limb

			//Taurs are harder to flip
			if(istype(tail_style, /datum/sprite_accessory/tail/taur))
				danger += 1

			//Check if they are physically capable
			if(src.sleeping || src.resting || src.buckled || src.weakened || src.restrained() || involved_parts.len < 2)
				src << "<span class='warning'>You can't *flip in your current state!</span>"
				return 1
			else
				src.SpinAnimation(7,1)
				message = "does a flip!"
				m_type = 1

				if(prob(danger))
					spawn(10) //Stick the landing.
						var/breaking = pick(involved_parts)
						var/obj/item/organ/external/E = get_organ(breaking)
						if(isSynthetic())
							src.Weaken(5)
							E.droplimb(1,DROPLIMB_EDGE)
							message += " <span class='danger'>And loses a limb!</span>"
							log_and_message_admins("lost their [breaking] with *flip, ahahah.", src)
						else
							src.Weaken(5)
							if(E.cannot_break) //Prometheans go splat
								E.droplimb(0,DROPLIMB_BLUNT)
							else
								E.fracture()
							message += " <span class='danger'>And breaks something!</span>"
							log_and_message_admins("broke their [breaking] with *flip, ahahah.", src)

	if (message)
		custom_emote(m_type,message)
		return 1

	return 0

/mob/living/carbon/human/proc/toggle_tail_vr(var/setting,var/message = 0)
	if(!tail_style || !tail_style.ani_state)
		if(message)
			src << "<span class='warning'>You don't have a tail that supports this.</span>"
		return 0

	var/new_wagging = isnull(setting) ? !wagging : setting
	if(new_wagging != wagging)
		wagging = new_wagging
		update_tail_showing()
	return 1

/mob/living/carbon/human/proc/toggle_wing_vr(var/setting,var/message = 0)
	if(!wing_style || !wing_style.ani_state)
		if(message)
			src << "<span class='warning'>You don't have a tail that supports this.</span>"
		return 0

	var/new_flapping = isnull(setting) ? !flapping : setting
	if(new_flapping != flapping)
		flapping = setting
		update_wing_showing()
	return 1

/mob/living/carbon/human/verb/toggle_gender_identity_vr()
	set name = "Set Gender Identity"
	set desc = "Sets the pronouns when examined and performing an emote."
	set category = "IC"
	var/new_gender_identity = input("Please select a gender Identity.") as null|anything in list(FEMALE, MALE, NEUTER, PLURAL, HERM)
	if(!new_gender_identity)
		return 0
	change_gender_identity(new_gender_identity)
	return 1

/mob/living/carbon/human/verb/switch_tail_layer()
	set name = "Switch tail layer"
	set category = "IC"
	set desc = "Switch tail layer on top."
	tail_alt = !tail_alt
	update_tail_showing()
