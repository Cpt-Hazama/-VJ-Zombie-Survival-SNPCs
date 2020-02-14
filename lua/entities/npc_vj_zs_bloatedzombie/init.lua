AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2019 by Cpt. Hazama, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/cpthazama/zombiesurvival/bloated.mdl"} -- Leave empty if using more than one model
ENT.StartHealth = 325
ENT.MoveType = MOVETYPE_STEP
ENT.HullType = HULL_HUMAN
ENT.tbl_Collision = {x=18,y=18,z=65}
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_ZOMBIE"}
ENT.BloodColor = "Red"
ENT.HasBloodPool = false
ENT.Z_Speed = 0.7
ENT.PropAP_MaxSize = 30

ENT.HasMeleeAttack = true -- Should the SNPC have a melee attack?
ENT.AnimTbl_MeleeAttack = {
	"vjges_zombie_attack_01",
	"vjges_zombie_attack_02",
	"vjges_zombie_attack_03",
	"vjges_zombie_attack_04",
	"vjges_zombie_attack_05",
	"vjges_zombie_attack_06"
} -- Melee Attack Animations
ENT.MeleeAttackDamage = 20
ENT.MeleeAttackDistance = 60
ENT.MeleeAttackDamageDistance = 72
ENT.TimeUntilMeleeAttackDamage = 0.6
ENT.NextAnyAttackTime_Melee = 0.9

ENT.MeleeAttackDamageType = DMG_SLASH -- Type of Damage
ENT.MeleeAttackAnimationAllowOtherTasks = true
-- ====== Sound File Paths ====== --
-- Leave blank if you don't want any sounds to play
ENT.SoundTbl_BeforeMeleeAttack = {"npc/zombie/zo_attack1.wav","npc/zombie/zo_attack2.wav"}
ENT.SoundTbl_Pain = {"npc/zombie/zombie_pain1.wav","npc/zombie/zombie_pain2.wav","npc/zombie/zombie_pain3.wav","npc/zombie/zombie_pain4.wav","npc/zombie/zombie_pain5.wav","npc/zombie/zombie_pain6.wav"}
ENT.SoundTbl_Death = {"npc/zombie/zombie_die1.wav","npc/zombie/zombie_die2.wav","npc/zombie/zombie_die3.wav"}
ENT.SoundTbl_FootStep = {"npc/zombie/foot1.wav","npc/zombie/foot2.wav","npc/zombie/foot3.wav"}

ENT.GeneralSoundPitch1 = 85
ENT.GeneralSoundPitch2 = 85
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
	self.AnimTbl_IdleStand = {"zombie_run"}
	self.AnimTbl_Walk = {self:GetSequenceActivity(self:LookupSequence("zombie_run"))}
	self.AnimTbl_Run = {self:GetSequenceActivity(self:LookupSequence("zombie_run"))}
	self:VJ_ZSSkin("models/cpthazama/zombiesurvival/bloated/bloated_noglow")
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SpawnBloodParticles(dmginfo,hitgroup)
	local dmg_pos = dmginfo:GetDamagePosition()
	self:CreateZSBlood(1,dmginfo)

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
	
	self:CreateZSBlood(30,dmginfo)

	self.HasDeathRagdoll = false
	self:EmitSound("physics/body/body_medium_break4.wav",80,100)
	for i = 1,8 do
		local spit = ents.Create("obj_vj_zs_flesh")
		spit:SetPos(self:GetPos() +self:OBBCenter())
		spit:SetAngles(Angle(math.random(0,360),math.random(0,360),math.random(0,360)))
		spit:SetOwner(self)
		spit:Spawn()
		spit:Activate()
		spit.DirectDamage = 8
		spit:SetMaterial("models/flesh")
		spit:SetModel("models/gibs/strider_gib4.mdl")
		spit:SetModelScale(0.75,0)
		spit:SetNoDraw(false)
		spit:DrawShadow(true)
		local phys = spit:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetVelocity(Vector(math.Rand(-100,100),math.Rand(-100,100),math.Rand(-100,100)) *2 +self:GetUp() *200)
		end
		local effectdata = EffectData()
		effectdata:SetOrigin(self:GetPos() +self:OBBCenter())
		effectdata:SetScale(dmginfo:GetDamageForce().z /3)
		effectdata:SetEntity(self)
		effectdata:SetMagnitude(5)
		util.Effect("zs_blood",effectdata)
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
	if self:IsMoving() then self:SetPoseParameter("move_x",self.Z_Speed) else self:SetPoseParameter("move_x",0) end
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