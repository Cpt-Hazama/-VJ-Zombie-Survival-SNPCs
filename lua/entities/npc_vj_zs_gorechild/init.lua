AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2019 by Cpt. Hazama, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/cpthazama/zombiesurvival/baby.mdl"} -- Leave empty if using more than one model
ENT.StartHealth = 20
ENT.MoveType = MOVETYPE_STEP
ENT.HullType = HULL_HUMAN
ENT.tbl_Collision = {x=18,y=18,z=65}
ENT.ZS_BossBaby = false
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_ZOMBIE"}
ENT.BloodColor = "Red"
ENT.HasBloodPool = false
ENT.HasDeathRagdoll = false
ENT.Z_Speed = 1

ENT.HasMeleeAttack = true -- Should the SNPC have a melee attack?
ENT.AnimTbl_MeleeAttack = {
	"vjges_zombie_attack_01",
	"vjges_zombie_attack_02",
	"vjges_zombie_attack_03",
	"vjges_zombie_attack_04",
	"vjges_zombie_attack_05",
	"vjges_zombie_attack_06"
} -- Melee Attack Animations
ENT.MeleeAttackDamage = 2
ENT.MeleeAttackDistance = 60
ENT.MeleeAttackDamageDistance = 72
ENT.TimeUntilMeleeAttackDamage = 0.6
ENT.NextAnyAttackTime_Melee = 1.3

ENT.MeleeAttackDamageType = DMG_SLASH -- Type of Damage
ENT.MeleeAttackAnimationAllowOtherTasks = true
-- ====== Sound File Paths ====== --
-- Leave blank if you don't want any sounds to play
ENT.SoundTbl_Pain = {"ambient/voices/citizen_beaten1.wav","ambient/voices/citizen_beaten2.wav","ambient/voices/citizen_beaten3.wav"}
ENT.SoundTbl_Death = {"ambient/creatures/town_child_scream1.wav"}
ENT.SoundTbl_FootStep = {"npc/zombie/foot1.wav","npc/zombie/foot2.wav","npc/zombie/foot3.wav"}

ENT.GeneralSoundPitch1 = 65
ENT.GeneralSoundPitch2 = 65
ENT.FootStepTimeRun = 0.5
ENT.FootStepTimeWalk = 0.5
ENT.HasExtraMeleeAttackSounds = true

ENT.NextBabyThrowT = CurTime() +3
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	local c = self.tbl_Collision
	self:SetHullType(HULL_TINY)
	self:SetModelScale(0.4,0)
	self:SetCollisionBounds(Vector(c.x,c.y,c.z),Vector(-c.x,-c.y,0))
	self:CapabilitiesAdd(bit.bor(CAP_MOVE_JUMP))
	self:CapabilitiesAdd(bit.bor(CAP_USE))
	self:CapabilitiesAdd(bit.bor(CAP_OPEN_DOORS))
	self.AnimTbl_IdleStand = {"zombie_run"}
	self.AnimTbl_Walk = {self:GetSequenceActivity(self:LookupSequence("zombie_run"))}
	self.AnimTbl_Run = {self:GetSequenceActivity(self:LookupSequence("zombie_run"))}
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
	if self:IsMoving() then self:SetPoseParameter("move_x",self.Z_Speed) else self:SetPoseParameter("move_x",0) end
	local enemy = NULL
	local dist = 0
	if IsValid(self:GetEnemy()) then
		enemy = self:GetEnemy()
		dist = self:VJ_GetNearestPointToEntityDistance(enemy)
		if self.ZS_BossBaby then
			if self:Visible(enemy) && dist <= 500 && dist > 200 && CurTime() > self.NextBabyThrowT then
				self:VJ_ACT_PLAYACTIVITY("vjges_zombie_attack_0" .. math.random(1,6),true,false,true)
				timer.Simple(0.9,function()
					if self:IsValid() then
						local spit = ents.Create("prop_physics")
						spit:SetModel("models/props_c17/doll01.mdl")
						spit:SetPos(self:GetPos() +self:OBBCenter() +self:GetForward() *90)
						spit:SetAngles(self:GetAngles())
						spit:SetOwner(self)
						spit:Spawn()
						spit:Activate()
						local phys = spit:GetPhysicsObject()
						if IsValid(phys) then
							phys:SetVelocity(((self:GetPos() +self:GetForward() *600) -self:GetPos()) *1 +self:GetForward() *900 +self:GetUp() *200)
						end
						timer.Simple(3,function()
							if IsValid(spit) then
								local baby = ents.Create("npc_vj_zs_gorechild")
								baby:SetPos(spit:GetPos() +Vector(0,0,4))
								baby:SetOwner(self)
								baby:Spawn()
								baby:Activate()
								spit:Remove()
							end
						end)
					end
				end)
				self.NextBabyThrowT = CurTime() +math.Rand(5,15)
			end
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnDoKilledEnemy(argent,attacker,inflictor)
	if attacker == self && argent:IsPlayer() then
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