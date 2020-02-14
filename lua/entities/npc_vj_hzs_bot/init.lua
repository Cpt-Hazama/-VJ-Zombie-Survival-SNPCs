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
ENT.AnimTbl_TakingCover = {0}
ENT.AnimTbl_MoveToCover = {0}
ENT.AnimTbl_MoveOrHideOnDamageByEnemy = {0}
ENT.AnimTbl_AlertFriendsOnDeath = {0}
ENT.AnimTbl_WeaponAttackCrouch = {0}
ENT.AnimTbl_WeaponReloadBehindCover = {0}
ENT.AnimTbl_ScaredBehaviorStand = {ACT_IDLE}
ENT.AnimTbl_ScaredBehaviorMovement = {ACT_RUN}

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
	PrintMessage(HUD_PRINTTALK,self:GetName() .. " has connected")
	timer.Simple(0.1,function()
		if IsValid(self) && IsValid(self:GetActiveWeapon()) then
			self:SetupHoldtypes(self:GetActiveWeapon(),self:GetActiveWeapon().HoldType)
		end
	end)
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
function ENT:SetupHoldtypes(wep,ht)
	if ht == "ar2" then
		self:BotAnim(ACT_HL2MP_IDLE_AR2,ACT_HL2MP_WALK_AR2,ACT_HL2MP_RUN_AR2,"range_ar2","reload_ar2")
	elseif ht == "smg" then
		self:BotAnim(ACT_HL2MP_IDLE_SMG1,ACT_HL2MP_WALK_SMG1,ACT_HL2MP_RUN_SMG1,"range_smg1","reload_smg1")
	elseif ht == "shotgun" then
		self:BotAnim(ACT_HL2MP_IDLE_SHOTGUN,ACT_HL2MP_WALK_SHOTGUN,ACT_HL2MP_RUN_SHOTGUN,"range_shotgun","reload_shotgun")
	elseif ht == "rpg" then
		self:BotAnim(ACT_HL2MP_IDLE_RPG,ACT_HL2MP_WALK_RPG,ACT_HL2MP_RUN_RPG,"range_rpg","reload_ar2")
	elseif ht == "pistol" then
		self:BotAnim(ACT_HL2MP_IDLE_PISTOL,ACT_HL2MP_WALK_PISTOL,ACT_HL2MP_RUN_PISTOL,"range_pistol","reload_pistol")
	elseif ht == "revolver" then
		self:BotAnim("idle_revolver","walk_revolver","run_revolver","range_revolver","reload_pistol")
	elseif ht == "crossbow" then
		self:BotAnim(ACT_HL2MP_IDLE_CROSSBOW,ACT_HL2MP_WALK_CROSSBOW,ACT_HL2MP_RUN_CROSSBOW,"range_ar2","reload_ar2")
	end
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
function ENT:BotAnim(idle,walk,run,fire,reload)
	if type(idle) == "string" then
		idle = VJ_SequenceToActivity(self,idle)
	end
	if type(walk) == "string" then
		walk = VJ_SequenceToActivity(self,walk)
	end
	if type(run) == "string" then
		run = VJ_SequenceToActivity(self,run)
	end
	self.AnimTbl_IdleStand = {idle}
	self.AnimTbl_Walk = {walk}
	self.AnimTbl_Run = {run}
	self.AnimTbl_ShootWhileMovingRun = self.AnimTbl_Run
	self.AnimTbl_ShootWhileMovingWalk = self.AnimTbl_Walk
	self.AnimTbl_WeaponAttack = self.AnimTbl_IdleStand
	self.AnimTbl_WeaponAttackFiringGesture = {fire}
	self.AnimTbl_WeaponReload = {"vjges_" .. reload}
	self.AnimTbl_AlertFriendsOnDeath = self.AnimTbl_IdleStand
	self.AnimTbl_CustomWaitForEnemyToComeOut = self.AnimTbl_IdleStand
	self.AnimTbl_LostWeaponSight = self.AnimTbl_IdleStand
	self.CustomWalkActivites = self.AnimTbl_Walk
	self.CustomRunActivites = self.AnimTbl_Run
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnThink()
	self:SetPoseParameter("move_x",1)
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