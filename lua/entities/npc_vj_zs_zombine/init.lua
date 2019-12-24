AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2019 by Cpt. Hazama, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/cpthazama/zombiesurvival/zombine.mdl"} -- Leave empty if using more than one model
ENT.StartHealth = 400
ENT.MoveType = MOVETYPE_STEP
ENT.HullType = HULL_HUMAN
ENT.tbl_Collision = {x=18,y=18,z=65}
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_ZOMBIE"}
ENT.BloodColor = "Red"
ENT.HasBloodPool = false
ENT.PropAP_MaxSize = 30

ENT.HasMeleeAttack = true -- Should the SNPC have a melee attack?
ENT.AnimTbl_MeleeAttack = {"vjges_FastAttack"} -- Melee Attack Animations
ENT.MeleeAttackDamage = 18
ENT.MeleeAttackDistance = 60
ENT.MeleeAttackDamageDistance = 72
ENT.TimeUntilMeleeAttackDamage = 0.3
ENT.NextAnyAttackTime_Melee = 1.2

ENT.MeleeAttackDamageType = DMG_SLASH -- Type of Damage
ENT.MeleeAttackAnimationAllowOtherTasks = true
-- ====== Sound File Paths ====== --
-- Leave blank if you don't want any sounds to play
ENT.SoundTbl_BeforeMeleeAttack = {"npc/zombine/zombine_charge1.wav","npc/zombine/zombine_charge2.wav"}
ENT.SoundTbl_Pain = {"npc/zombine/zombine_pain1.wav","npc/zombine/zombine_pain2.wav","npc/zombine/zombine_pain3.wav","npc/zombine/zombine_pain4.wav"}
ENT.SoundTbl_Death = {"npc/zombine/zombine_die1.wav","npc/zombine/zombine_die2.wav"}
ENT.SoundTbl_FootStep = {"npc/zombine/gear1.wav","npc/zombine/gear2.wav","npc/zombine/gear3.wav"}

ENT.GeneralSoundPitch1 = 100
ENT.GeneralSoundPitch2 = 100
ENT.FootStepTimeRun = 0.5
ENT.FootStepTimeWalk = 0.5
ENT.HasExtraMeleeAttackSounds = true

ENT.HasPulledGrenade = false
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	local c = self.tbl_Collision
	self:SetCollisionBounds(Vector(c.x,c.y,c.z),Vector(-c.x,-c.y,0))
	self:CapabilitiesAdd(bit.bor(CAP_MOVE_JUMP))
	self:CapabilitiesAdd(bit.bor(CAP_USE))
	self:CapabilitiesAdd(bit.bor(CAP_OPEN_DOORS))
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SpawnBloodParticles(dmginfo,hitgroup)
	local dmg_pos = dmginfo:GetDamagePosition()
	if dmg_pos == Vector(0,0,0) then dmg_pos = self:GetPos() + self:OBBCenter() end
	local effectdata = EffectData()
	effectdata:SetOrigin(dmg_pos)
	effectdata:SetScale(dmginfo:GetDamageForce().z /3)
	effectdata:SetEntity(self)
	effectdata:SetMagnitude(3)
	util.Effect("zs_blood",effectdata)

	local p_name = VJ_PICKRANDOMTABLE(self.CurrentChoosenBlood_Particle)
	if p_name == false then return end	
	local spawnparticle = ents.Create("info_particle_system")
	spawnparticle:SetKeyValue("effect_name",p_name)
	spawnparticle:SetPos(dmg_pos)
	spawnparticle:Spawn()
	spawnparticle:Activate()
	spawnparticle:Fire("Start","",0)
	spawnparticle:Fire("Kill","",0.1)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnKilled(dmginfo,hitgroup)
	local effectdata = EffectData()
	effectdata:SetOrigin(self:GetPos() +self:OBBCenter())
	effectdata:SetEntity(self)
	util.Effect("zs_flesh_death",effectdata)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnDeath_AfterCorpseSpawned(dmginfo,hitgroup,GetCorpse)
	if self.HasPulledGrenade && IsValid(self.Grenade) then
		local grenent = ents.Create("npc_grenade_frag")
		grenent:SetModel("models/Items/grenadeAmmo.mdl")
		grenent:SetPos(GetCorpse:GetAttachment(GetCorpse:LookupAttachment("grenade_attachment")).Pos)
		grenent:SetAngles(GetCorpse:GetAttachment(GetCorpse:LookupAttachment("grenade_attachment")).Ang)
		grenent:SetOwner(self)
		grenent:SetParent(GetCorpse)
		grenent:Fire("SetParentAttachment","grenade_attachment")
		grenent:Spawn()
		grenent:Activate()
		local eTime = self.GrenadeTimer -CurTime()
		grenent:Input("SetTimer",self:GetOwner(),self:GetOwner(),eTime)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:BeforeMeleeAttackSoundCode(CustomTbl,Type)
	if self.HasSounds == false or self.HasMeleeAttackSounds == false then return end
	Type = Type or VJ_CreateSound
	local ctbl = VJ_PICKRANDOMTABLE(CustomTbl)
	local sdtbl = VJ_PICKRANDOMTABLE(self.SoundTbl_BeforeMeleeAttack)
	if (math.random(1,self.BeforeMeleeAttackSoundChance) == 1 && sdtbl != false) or (ctbl != false) then
		if ctbl != false then sdtbl = ctbl end
		if self.IdleSounds_PlayOnAttacks == false then VJ_STOPSOUND(self.CurrentIdleSound) end
		self.NextIdleSoundT_RegularChange = CurTime() + 1
		self.CurrentBeforeMeleeAttackSound = Type(self,sdtbl,self.BeforeMeleeAttackSoundLevel,self:VJ_DecideSoundPitch(self.BeforeMeleeAttackSoundPitch1,self.BeforeMeleeAttackSoundPitch2),true)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnThink()
	if GetConVarNumber("ai_disabled") == 1 then return end
	local enemy = NULL
	local dist = 0
	if IsValid(self:GetEnemy()) then
		enemy = self:GetEnemy()
		dist = self:VJ_GetNearestPointToEntityDistance(enemy)
		if dist <= 300 && enemy:Visible(self) && self:Health() <= 60 && math.random(1,20) == 1 && self.HasPulledGrenade == false then
			self.HasPulledGrenade = true
			self:VJ_ACT_PLAYACTIVITY("vjges_pullGrenade",true,false,false)
			self:EmitSound("npc/zombine/zombine_readygrenade" .. math.random(1,2) .. ".wav",75,100)
			self.AnimTbl_IdleStand = {"Idle_Grenade"}
			self.AnimTbl_Walk = {VJ_SequenceToActivity(self,"Run_All_grenade")}
			self.AnimTbl_Run = {VJ_SequenceToActivity(self,"Run_All_grenade")}
			timer.Simple(0.6,function()
				if self:IsValid() then
					local grenent = ents.Create("npc_grenade_frag")
					grenent:SetModel("models/Items/grenadeAmmo.mdl")
					grenent:SetPos(self:GetAttachment(self:LookupAttachment("grenade_attachment")).Pos)
					grenent:SetAngles(self:GetAttachment(self:LookupAttachment("grenade_attachment")).Ang)
					grenent:SetOwner(self)
					grenent:SetParent(self)
					grenent:Fire("SetParentAttachment","grenade_attachment")
					grenent:Spawn()
					grenent:Activate()
					grenent:Input("SetTimer",self:GetOwner(),self:GetOwner(),3.5)
					self.Grenade = grenent
					self.GrenadeTimer = CurTime() +3.5
				end
			end)
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnDoKilledEnemy(argent,attacker,inflictor)
	if !IsValid(argent) then return end
	if attacker == self && argent:IsPlayer() || IsValid(argent) && attacker == self && argent:IsNPC() && argent:GetClass() == "npc_vj_hzs_bot" then
		argent:EmitSound("music/stingers/hl1_stinger_song28.mp3",42,100)
		local z = ents.Create("npc_vj_zs_freshdead")
		z:SetModel(argent:GetModel())
		z:SetPos(argent:GetPos())
		z:SetAngles(argent:GetAngles())
		z:Spawn(); z.Z_Model = argent:GetModel()
		if IsValid(argent:GetRagdollEntity()) then
			argent:GetRagdollEntity():Remove()
		end
		timer.Simple(0.02,function()
			if IsValid(z) then
				z:VJ_ACT_PLAYACTIVITY("vjseq_zombie_slump_rise_01",true,false,false)
			end
		end)
	end
end
/*-----------------------------------------------
	*** Copyright (c) 2019 by Cpt. Hazama, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/