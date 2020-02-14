AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2019 by Cpt. Hazama, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/cpthazama/zombiesurvival/ghoul.mdl"} -- Leave empty if using more than one model
ENT.StartHealth = 100
ENT.MoveType = MOVETYPE_STEP
ENT.HullType = HULL_HUMAN
ENT.tbl_Collision = {x=18,y=18,z=65}
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_ZOMBIE"}
ENT.BloodColor = "Red"
ENT.HasBloodPool = false
ENT.PropAP_MaxSize = 30

ENT.HasMeleeAttack = true -- Should the SNPC have a melee attack?
ENT.AnimTbl_MeleeAttack = {
	"vjges_attackA",
	"vjges_attackB",
	"vjges_attackC",
	"vjges_attackD",
	"vjges_attackE",
	"vjges_attackF"
} -- Melee Attack Animations
ENT.MeleeAttackDamage = 14
ENT.MeleeAttackDistance = 60
ENT.MeleeAttackDamageDistance = 72
ENT.TimeUntilMeleeAttackDamage = 0.5
ENT.NextAnyAttackTime_Melee = 0.9

ENT.MeleeAttackDamageType = DMG_SLASH -- Type of Damage
ENT.MeleeAttackAnimationAllowOtherTasks = true

ENT.HasRangeAttack = true -- Should the SNPC have a range attack?
ENT.AnimTbl_RangeAttack = {"vjges_throwpoisonA","vjges_throwpoisonB"} -- Range Attack Animations
ENT.RangeAttackEntityToSpawn = "obj_vj_zs_flesh" -- The entity that is spawned when range attacking
ENT.TimeUntilRangeAttackProjectileRelease = 0.5
ENT.NextRangeAttackTime = 6 -- How much time until it can use a range attack?
ENT.RangeDistance = 170 -- This is how far away it can shoot
ENT.RangeToMeleeDistance = 100 -- How close does it have to be until it uses melee?
ENT.RangeUseAttachmentForPos = false -- Should the projectile spawn on a attachment?
ENT.RangeAttackAnimationStopMovement = false
ENT.RangeAttackPos_Up = 45
ENT.RangeAttackPos_Forward = 10
ENT.RangeAttackPos_Right = 0
ENT.RangeAttackExtraTimers = {0.51,0.52}
-- ====== Sound File Paths ====== --
-- Leave blank if you don't want any sounds to play
ENT.SoundTbl_BeforeMeleeAttack = {"npc/fast_zombie/leap1.wav"}
ENT.SoundTbl_BeforeRangeAttack = {"npc/fast_zombie/wake1.wav"}
ENT.SoundTbl_Pain = {"npc/zombie_poison/pz_pain1.wav","npc/zombie_poison/pz_pain2.wav","npc/zombie_poison/pz_pain3.wav"}
ENT.SoundTbl_Death = {"npc/zombie_poison/pz_die2.wav"}
ENT.SoundTbl_FootStep = {"npc/zombie/foot1.wav","npc/zombie/foot2.wav","npc/zombie/foot3.wav"}

ENT.GeneralSoundPitch1 = 120
ENT.GeneralSoundPitch2 = 120
ENT.FootStepTimeRun = 0.5
ENT.FootStepTimeWalk = 0.5
ENT.HasExtraMeleeAttackSounds = true
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	local c = self.tbl_Collision
	self:SetCollisionBounds(Vector(c.x,c.y,c.z),Vector(-c.x,-c.y,0))
	self:CapabilitiesAdd(bit.bor(CAP_MOVE_JUMP))
	self:CapabilitiesAdd(bit.bor(CAP_USE))
	self:CapabilitiesAdd(bit.bor(CAP_OPEN_DOORS))
	self:VJ_ZSSkin("models/humans/corpse/corpse1")
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:RangeAttackCode_GetShootPos(TheProjectile)
	self:EmitSound("physics/body/body_medium_break2.wav",75,100)
	local b = math.random(2,3)
	return ((self:GetPos() +self:GetForward() *200) -self:GetPos()) *1 +self:GetForward() *250 +self:GetUp() *150 +self:GetUp() *math.random(-b *35,b *35) +self:GetRight() *math.random(-b *50,b *50)
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