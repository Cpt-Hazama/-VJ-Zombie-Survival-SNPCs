AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2019 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/player/kleiner.mdl"} -- The game will pick a random model from the table when the SNPC is spawned | Add as many as you want
local testList = player_manager.AllValidModels()
for _,v in pairs(testList) do
	table.insert(ENT.Model,v)
end
ENT.StartHealth = 100
ENT.HullType = HULL_HUMAN
ENT.BloodColor = "Red"
ENT.VJ_NPC_Class = {"CLASS_PLAYER_ALLY"} -- NPCs with the same class with be allied to each other
ENT.PlayerFriendly = true
ENT.FriendsWithAllPlayerAllies = true
ENT.HasMeleeAttack = false -- Should the SNPC have a melee attack?
ENT.PoseParameterLooking_Names = {pitch={"aim_pitch"},yaw={"aim_yaw"},roll={}}
ENT.FootStepTimeRun = 0.3
ENT.FootStepTimeWalk = 0.5

ENT.BecomeEnemyToPlayer = tobool(GetConVarNumber("vj_zs_botanger"))
ENT.BecomeEnemyToPlayerLevel = 5

ENT.HasCallForHelpAnimation = false
ENT.AnimTbl_CallForHelp = {0}
ENT.CallForBackUpOnDamageAnimation = {0}

ENT.SoundTbl_FootStep = {
	"player/footsteps/concrete1.wav",
	"player/footsteps/concrete2.wav",
	"player/footsteps/concrete3.wav",
	"player/footsteps/concrete4.wav"
}
ENT.SoundTbl_Pain = {
	"player/pl_pain5.wav",
	"player/pl_pain6.wav",
	"player/pl_pain7.wav",
}
ENT.SoundTbl_Death = {
	"hl1/fvox/flatline.wav"
}

ENT.tbl_ChatTalk = {
	"Hey, [VJID] is really gay",
	"bruh [VJID] sucks at this",
	"watch out [VJID], im coming for your ugly ass",
	"spare a medkit [VJID]?",
	"1v1 me [VJID]",
	"hey [VJID], wanna trade some steam cards?",
	"do you know de wae? [VJID]?",
	"how do I move [VJID]?",
	"need some ammo [VJID]? sike bisch go get your own loser",
	"go join zombies [VJID], you suck ass as humans",
	-- "youre a fucking ugly ass nigger [VJID], you suck ass",
	"Good, [VJID] good. Kill him, kill him now...",
	"Guys I think [VJID] is hacking...",
	"25 cents is all it takes, [VJID]",
}

ENT.tbl_ChatIdle = {
	"Guys this is really boring",
	"Let's do something already",
	"I wanna kill someone",
	"lol",
	"GMod 11 ZS is waaaay better than GMod 13 ZS",
	"<$ was the best ZS server, rip",
	"fag",
	"S&box is gonna be so gay",
	"Spongebob ice cream bars are pretty rad",
	"Can I get a mic check?",
	"Half-Life 3 when?",
	"THIS CHAT IS TOXIC AF",
	"h",
	"Why is everything errors and missing textures?",
	"My spouts of anger usually lead me to mass murdering a bunch of people, especially children!",
}

ENT.tbl_ChatCombat = {
	"UR DEAD",
	"GONNA KILL U!",
	"LOL REKT",
	"NAME THE BULLY",
	"Waste of Space",
	"Is this all you had to offer?",
	"Expected more from you...",
	"WOW! You're not as good as I had thought.",
	"Jump and kill, can't even touch me.",
	"I'm flying over here, nerd.",
	"Bam you're dead.",
	"Times up chuckle-nuts, you're dead.",
	"Mad? Salty? I can smell it.",
	"I'm about to vapitate all over you!",
	"i'm gonna call the bully hunters on you",
}

ENT.tbl_ChatDeath = {
	"ARE YOU FUCKIN KIDDING ME!!??",
	"seriously..",
	"fuck this shit!",
	"im going invisible.",
	"I'm so done.",
	"ur fucking hacking!",
	"xD",
	"Well, that was idiotic. Off to hang myself!",
}

ENT.tbl_Names = {
	"Cpt. Hazama",
	"DrVrej",
	"Mayhem",
	"Vp Snipes",
	"RAWCH",
	"Peanut",
	"Headcrab",
	"GabeN",
	"Mawskeeto",
	"BULLY_HUNTER_77",
	"urmomgaylol",
	"Pyrocynical",
	"FAT",
	"Spy",
	"PirateCatty",
	"Hugh Welsh",
	"big gay",
	"CrispiestOhio42",
	"A Professional With Standards",
	"AimBot",
	"AmNot",
	"Aperture Science Prototype XR7",
	"Archimedes!",
	"BeepBeepBoop",
	"Chell",
	"Cannon Fodder",
	"Herr Doktor",
	"H@XX0RZ",
	"LOS LOS LOS",
	"Nom Nom Nom",
	"SMELLY UNFORTUNATE",
	"10001011101",
	"0xDEADBEEF",
	"Numnutz",
	"GENTLE MANNE of LEISURE",
	"Delicious Cake",
	"C++",
	"LUA",
	"Crowbar",
	"The Freeman",
	"roger7",
}

ENT.GeneralSoundPitch1 = 100
ENT.GeneralSoundPitch2 = 100
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	self:CapabilitiesAdd(bit.bor(CAP_MOVE_JUMP))
	self:CapabilitiesAdd(bit.bor(CAP_USE))
	self:CapabilitiesAdd(bit.bor(CAP_OPEN_DOORS))
	self:CapabilitiesAdd(bit.bor(CAP_ANIMATEDFACE))
	self:DecideName()
	self.NextIdleChatT = CurTime() +10
	self.NextCombatChatT = CurTime() +2
	self.CurrentHoldType = "none"
	self.CurrentFireType = 1
	PrintMessage(HUD_PRINTTALK,self:GetName() .. " has connected")
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetAnimData(idle,crouch,crouch_move,walk,run,fire,reload,jump)
	if type(idle) == "string" then idle = VJ_SequenceToActivity(self,idle) end
	if type(crouch) == "string" then crouch = VJ_SequenceToActivity(self,crouch) end
	if type(crouch_move) == "string" then crouch_move = VJ_SequenceToActivity(self,crouch_move) end
	if type(walk) == "string" then walk = VJ_SequenceToActivity(self,walk) end
	if type(run) == "string" then run = VJ_SequenceToActivity(self,run) end
	if type(fire) == "string" then fire = VJ_SequenceToActivity(self,fire) end
	if type(reload) == "string" then reload = VJ_SequenceToActivity(self,reload) end
	if type(jump) == "string" then jump = VJ_SequenceToActivity(self,jump) end

	self.WeaponAnimTranslations[ACT_IDLE] 							= idle
	self.WeaponAnimTranslations[ACT_WALK] 							= walk
	self.WeaponAnimTranslations[ACT_RUN] 							= run
	self.WeaponAnimTranslations[ACT_IDLE_ANGRY] 					= idle
	self.WeaponAnimTranslations[ACT_WALK_AIM] 						= walk
	self.WeaponAnimTranslations[ACT_WALK_CROUCH] 					= crouch_move
	self.WeaponAnimTranslations[ACT_WALK_CROUCH_AIM] 				= crouch_move
	self.WeaponAnimTranslations[ACT_RUN_AIM] 						= run
	self.WeaponAnimTranslations[ACT_RUN_CROUCH] 					= crouch_move
	self.WeaponAnimTranslations[ACT_RUN_CROUCH_AIM] 				= crouch_move
	self.WeaponAnimTranslations[ACT_RANGE_ATTACK1] 					= idle
	self.WeaponAnimTranslations[ACT_GESTURE_RANGE_ATTACK1] 			= fire
	self.WeaponAnimTranslations[ACT_RANGE_ATTACK1_LOW] 				= crouch
	self.WeaponAnimTranslations[ACT_RELOAD]							= "vjges_" .. VJ_GetSequenceName(self,reload)
	self.WeaponAnimTranslations[ACT_COVER_LOW] 						= crouch
	self.WeaponAnimTranslations[ACT_RELOAD_LOW] 					= "vjges_" .. VJ_GetSequenceName(self,reload)
	self.WeaponAnimTranslations[ACT_JUMP] 							= jump
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnSetupWeaponHoldTypeAnims(htype)
	self.CurrentHoldType = htype
	local idle = ACT_HL2MP_IDLE
	local walk = ACT_HL2MP_WALK
	local crouch_move = ACT_HL2MP_WALK_CROUCH
	local run = ACT_HL2MP_RUN
	local fire = ACT_HL2MP_GESTURE_RANGE_ATTACK_FIST
	local crouch = ACT_HL2MP_IDLE_CROUCH
	local reload = ACT_HL2MP_GESTURE_RELOAD_PISTOL
	if htype == "ar2" && self:GetActiveWeapon().CS_HType != "mach" then
		idle = ACT_HL2MP_IDLE_AR2
		walk = ACT_HL2MP_WALK_AR2
		crouch_move = ACT_HL2MP_WALK_CROUCH_AR2
		run = ACT_HL2MP_RUN_AR2
		fire = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2
		crouch = ACT_HL2MP_IDLE_CROUCH_AR2
		reload = ACT_HL2MP_GESTURE_RELOAD_AR2
		jump = ACT_HL2MP_JUMP_AR2
	elseif htype == "smg" && self:GetActiveWeapon().CS_HType != "mac" then
		idle = ACT_HL2MP_IDLE_SMG1
		walk = ACT_HL2MP_WALK_SMG1
		crouch_move = ACT_HL2MP_WALK_CROUCH_SMG1
		run = ACT_HL2MP_RUN_SMG1
		fire = ACT_HL2MP_GESTURE_RANGE_ATTACK_SMG1
		crouch = ACT_HL2MP_IDLE_CROUCH_SMG1
		reload = ACT_HL2MP_GESTURE_RELOAD_SMG1
		jump = ACT_HL2MP_JUMP_SMG1
	elseif htype == "shotgun" then
		idle = ACT_HL2MP_IDLE_SHOTGUN
		walk = ACT_HL2MP_WALK_SHOTGUN
		crouch_move = ACT_HL2MP_WALK_CROUCH_SHOTGUN
		run = ACT_HL2MP_RUN_SHOTGUN
		fire = ACT_HL2MP_GESTURE_RANGE_ATTACK_SHOTGUN
		crouch = ACT_HL2MP_IDLE_CROUCH_SHOTGUN
		reload = ACT_HL2MP_GESTURE_RELOAD_SHOTGUN
		jump = ACT_HL2MP_JUMP_SHOTGUN
	elseif htype == "rpg" then
		idle = ACT_HL2MP_IDLE_RPG
		walk = ACT_HL2MP_WALK_RPG
		crouch_move = ACT_HL2MP_WALK_CROUCH_RPG
		run = ACT_HL2MP_RUN_RPG
		fire = ACT_HL2MP_GESTURE_RANGE_ATTACK_RPG
		crouch = ACT_HL2MP_IDLE_CROUCH_RPG
		reload = ACT_HL2MP_GESTURE_RELOAD_RPG
		jump = ACT_HL2MP_JUMP_RPG
	elseif htype == "pistol" then
		idle = ACT_HL2MP_IDLE_REVOLVER
		walk = ACT_HL2MP_WALK_REVOLVER
		crouch_move = ACT_HL2MP_WALK_CROUCH_PISTOL
		run = ACT_HL2MP_RUN_REVOLVER
		fire = ACT_HL2MP_GESTURE_RANGE_ATTACK_PISTOL
		crouch = ACT_HL2MP_IDLE_CROUCH_PISTOL
		reload = ACT_HL2MP_GESTURE_RELOAD_PISTOL
		jump = ACT_HL2MP_JUMP_REVOLVER
	elseif htype == "dual" then
		idle = "idle_dual"
		walk = "walk_dual"
		crouch_move = "cwalk_dual"
		run = "run_dual"
		fire = "range_dual_r"
		crouch = "cidle_dual"
		reload = "reload_dual"
		jump = "jump_dual"
	elseif htype == "revolver" then
		idle = ACT_HL2MP_IDLE_REVOLVER
		walk = ACT_HL2MP_WALK_REVOLVER
		crouch_move = ACT_HL2MP_WALK_CROUCH_REVOLVER
		run = ACT_HL2MP_RUN_REVOLVER
		fire = ACT_HL2MP_GESTURE_RANGE_ATTACK_REVOLVER
		crouch = ACT_HL2MP_IDLE_CROUCH_REVOLVER
		reload = ACT_HL2MP_GESTURE_RELOAD_REVOLVER
		jump = ACT_HL2MP_JUMP_REVOLVER
	elseif htype == "crossbow" then
		idle = ACT_HL2MP_IDLE_CROSSBOW
		walk = ACT_HL2MP_WALK_CROSSBOW
		crouch_move = ACT_HL2MP_WALK_CROUCH_CROSSBOW
		run = ACT_HL2MP_RUN_CROSSBOW
		fire = ACT_HL2MP_GESTURE_RANGE_ATTACK_CROSSBOW
		crouch = ACT_HL2MP_IDLE_CROUCH_CROSSBOW
		reload = ACT_HL2MP_GESTURE_RELOAD_CROSSBOW
		jump = ACT_HL2MP_JUMP_CROSSBOW
	elseif htype == "knife" then
		idle = ACT_HL2MP_IDLE_KNIFE
		walk = ACT_HL2MP_WALK_KNIFE
		crouch_move = ACT_HL2MP_WALK_CROUCH_KNIFE
		run = ACT_HL2MP_RUN_KNIFE
		fire = ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE
		crouch = ACT_HL2MP_IDLE_CROUCH_KNIFE
		reload = ACT_HL2MP_GESTURE_RELOAD_KNIFE
		jump = ACT_HL2MP_JUMP_KNIFE
	elseif htype == "grenade" then
		idle = ACT_HL2MP_IDLE_GRENADE
		walk = ACT_HL2MP_WALK_GRENADE
		crouch_move = ACT_HL2MP_WALK_CROUCH_GRENADE
		run = ACT_HL2MP_RUN_GRENADE
		fire = ACT_HL2MP_GESTURE_RANGE_ATTACK_GRENADE
		crouch = ACT_HL2MP_IDLE_CROUCH_GRENADE
		reload = ACT_HL2MP_GESTURE_RELOAD_GRENADE
		jump = ACT_HL2MP_JUMP_GRENADE
	elseif htype == "melee" then
		idle = ACT_HL2MP_IDLE_MELEE
		walk = ACT_HL2MP_WALK_MELEE
		crouch_move = ACT_HL2MP_WALK_CROUCH_MELEE
		run = ACT_HL2MP_RUN_MELEE
		fire = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE
		crouch = ACT_HL2MP_IDLE_CROUCH_MELEE
		reload = ACT_HL2MP_GESTURE_RELOAD_MELEE
		jump = ACT_HL2MP_JUMP_MELEE
	elseif htype == "melee_angry" then
		idle = "idle_melee_angry"
		walk = ACT_HL2MP_WALK_MELEE
		crouch_move = ACT_HL2MP_WALK_CROUCH_MELEE
		run = ACT_HL2MP_RUN_MELEE
		fire = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE
		crouch = ACT_HL2MP_IDLE_CROUCH_MELEE
		reload = ACT_HL2MP_GESTURE_RELOAD_MELEE
		jump = ACT_HL2MP_JUMP_MELEE
	elseif htype == "melee2" then
		idle = ACT_HL2MP_IDLE_MELEE2
		walk = ACT_HL2MP_WALK_MELEE2
		crouch_move = ACT_HL2MP_WALK_CROUCH_MELEE2
		run = ACT_HL2MP_RUN_MELEE2
		fire = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE2
		crouch = ACT_HL2MP_IDLE_CROUCH_MELEE2
		reload = ACT_HL2MP_GESTURE_RELOAD_MELEE2
		jump = ACT_HL2MP_JUMP_MELEE2
	elseif htype == "physgun" then
		idle = ACT_HL2MP_IDLE_PHYSGUN
		walk = ACT_HL2MP_WALK_PHYSGUN
		crouch_move = ACT_HL2MP_WALK_CROUCH_PHYSGUN
		run = ACT_HL2MP_RUN_PHYSGUN
		fire = ACT_HL2MP_GESTURE_RANGE_ATTACK_PHYSGUN
		crouch = ACT_HL2MP_IDLE_CROUCH_PHYSGUN
		reload = ACT_HL2MP_GESTURE_RELOAD_PHYSGUN
		jump = ACT_HL2MP_JUMP_PHYSGUN
	elseif htype == "ar2" && self:GetActiveWeapon().CS_HType == "mach" then
		idle = ACT_HL2MP_IDLE_SHOTGUN
		walk = ACT_HL2MP_WALK_SHOTGUN
		crouch_move = ACT_HL2MP_WALK_CROUCH_SHOTGUN
		run = ACT_HL2MP_RUN_SHOTGUN
		fire = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2
		crouch = ACT_HL2MP_IDLE_CROUCH_SHOTGUN
		reload = ACT_HL2MP_GESTURE_RELOAD_SMG1
		jump = ACT_HL2MP_JUMP_SHOTGUN
	elseif htype == "smg" && self:GetActiveWeapon().CS_HType == "mac" then
		idle = ACT_HL2MP_IDLE_REVOLVER
		walk = ACT_HL2MP_WALK_REVOLVER
		crouch_move = ACT_HL2MP_WALK_CROUCH_REVOLVER
		run = ACT_HL2MP_RUN_REVOLVER
		fire = ACT_HL2MP_GESTURE_RANGE_ATTACK_PISTOL
		crouch = ACT_HL2MP_IDLE_CROUCH_REVOLVER
		reload = ACT_HL2MP_GESTURE_RELOAD_REVOLVER
		jump = ACT_HL2MP_JUMP_REVOLVER
	end
	self:SetAnimData(idle,crouch,crouch_move,walk,run,fire,reload,jump)
	return true
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnFireBullet(ent,data)
	if self.CurrentHoldType == "dual" then
		local seq = nil
		if self.CurrentFireType == 1 then
			self.CurrentFireType = 2
			seq = "range_dual_l"
		else
			self.CurrentFireType = 1
			seq = "range_dual_r"
		end
		self.WeaponAnimTranslations[ACT_GESTURE_RANGE_ATTACK1] = VJ_SequenceToActivity(self,seq)
		self:GetActiveWeapon().PrimaryEffects_MuzzleAttachment = self.CurrentFireType
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:DecideName()
	local name = VJ_PICK(self.tbl_Names)
	local num = 0
	for _,v in pairs(player.GetAll()) do
		if string.find(v:Nick(),name) then
			num = num +1
		end
	end
	for _,v in pairs(ents.FindByClass(self:GetClass())) do
		if string.find(v:GetName(),name) then
			num = num +1
		end
	end
	if num > 0 then
		name = name .. " [" .. num +1 .. "]"
	end
	self:SetName(name)
	self.PrintName = name
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:PlayerName()
	local tb = {}
	for _,v in ipairs(player.GetAll()) do
		table.insert(tb,v:Nick())
	end
	for _,v in ipairs(ents.GetAll()) do
		if v:IsNPC() && v:GetClass() == "npc_vj_hzs_bot" && v != self then
			table.insert(tb,v:GetName())
		end
	end
	return VJ_PICK(tb)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:BotChat(text,ply)
	if GetConVarNumber("vj_zs_botchat") == 0 then return end
	if ply then
		local text = VJ_PICK(self.tbl_ChatTalk)
		local replace
		if string.find(text,"[VJID]") then
			replace = string.Replace(text,"[VJID]",self:PlayerName())
		end
		-- for _,v in pairs(player.GetAll()) do v:ChatPrint(self:GetName() .. ": " .. tostring(replace)) end
		PrintMessage(HUD_PRINTTALK,self:GetName() .. ": " .. tostring(replace))
	else
		-- for _,v in pairs(player.GetAll()) do v:ChatPrint(self:GetName() .. ": " .. tostring(text)) end
		PrintMessage(HUD_PRINTTALK,self:GetName() .. ": " .. tostring(text))
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Between(a,b)
	local waypoint = self:GetCurWaypointPos()
	local ang = (waypoint -self:GetPos()):Angle()
	local dif = math.AngleDifference(self:GetAngles().y,ang.y)
	return dif < a && dif > b
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:DecideXY()
	local x = 0
	local y = 0
	if self:Between(30,-30) then
		x = 1
		y = 0
	elseif self:Between(70,30) then
		x = 1
		y = 1
	elseif self:Between(120,70) then
		x = 0
		y = 1
	elseif self:Between(150,120) then
		x = -1
		y = 1
	elseif !self:Between(150,-150) then
		x = -1
		y = 0
	elseif self:Between(-110,-150) then
		x = -1
		y = -1
	elseif self:Between(-70,-110) then
		x = 0
		y = -1
	elseif self:Between(-30,-70) then
		x = 1
		y = -1
	end
	
	self:SetPoseParameter("move_x",x)
	self:SetPoseParameter("move_y",y)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnThink()
	self:DecideXY()
	if self:IsMoving() then
		if !self.DoingWeaponAttack && self:GetPos():Distance(self:GetCurWaypointPos()) > 75 then
			self:FaceCertainPosition(self:GetCurWaypointPos())
		end
	end
	if IsValid(self:GetEnemy()) then
		if CurTime() > self.NextCombatChatT then
			self:BotChat(VJ_PICK(self.tbl_ChatCombat))
			self.NextCombatChatT = CurTime() +math.Rand(30,60)
		end
	else
		if CurTime() > self.NextIdleChatT then
			self:BotChat(VJ_PICK(self.tbl_ChatIdle),math.random(1,3) == 1)
			self.NextIdleChatT = CurTime() +math.Rand(25,60)
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnKilled(dmginfo,hitgroup)
	self:BotChat(VJ_PICK(self.tbl_ChatDeath))
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnDeath_AfterCorpseSpawned(dmginfo,hitgroup,GetCorpse)
	timer.Simple(3,function()
		if IsValid(GetCorpse) then
			GetCorpse:Remove()
		end
	end)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnRemove()
	if self:Health() > 0 then
		-- for _,v in pairs(player.GetAll()) do v:ChatPrint(self:GetName() .. " has disconnected") end
		PrintMessage(HUD_PRINTTALK,self:GetName() .. " has disconnected")
	end
end
/*-----------------------------------------------
	*** Copyright (c) 2012-2019 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/