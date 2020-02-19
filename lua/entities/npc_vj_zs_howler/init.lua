AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2019 by Cpt. Hazama, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/cpthazama/zombiesurvival/howler.mdl"} -- Leave empty if using more than one model
ENT.StartHealth = 190
ENT.MoveType = MOVETYPE_STEP
ENT.HullType = HULL_HUMAN
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_ZOMBIE"}
ENT.BloodColor = "Red"
ENT.HasBloodPool = false

ENT.HasMeleeAttack = true -- Should the SNPC have a melee attack?
ENT.AnimTbl_MeleeAttack = {
	"vjges_attackA",
	"vjges_attackB",
	"vjges_attackC",
	"vjges_attackD",
	"vjges_attackE",
	"vjges_attackF"
} -- Melee Attack Animations
ENT.MeleeAttackDamage = 17
ENT.MeleeAttackDistance = 60
ENT.MeleeAttackDamageDistance = 72
ENT.TimeUntilMeleeAttackDamage = 0.6
ENT.NextAnyAttackTime_Melee = 0.9

ENT.MeleeAttackDamageType = DMG_SLASH -- Type of Damage
ENT.MeleeAttackAnimationAllowOtherTasks = true
-- ====== Sound File Paths ====== --
-- Leave blank if you don't want any sounds to play
ENT.SoundTbl_BeforeMeleeAttack = {"cpt_zs/howler/howler_mad_04.wav"}
ENT.SoundTbl_Pain = {
	"cpt_zs/howler/howler_mad_01.wav",
	"cpt_zs/howler/howler_mad_02.wav",
	"cpt_zs/howler/howler_mad_03.wav",
}
ENT.SoundTbl_Death = {"cpt_zs/howler/howler_death_01.wav"}
ENT.SoundTbl_FootStep = {"npc/zombie/foot1.wav","npc/zombie/foot2.wav","npc/zombie/foot3.wav"}

ENT.GeneralSoundPitch1 = 100
ENT.GeneralSoundPitch2 = 100
ENT.FootStepTimeRun = 0.4
ENT.FootStepTimeWalk = 0.4
ENT.HasExtraMeleeAttackSounds = true
ENT.AnimTbl_IdleStand = {ACT_IDLE_ANGRY}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	self:CapabilitiesAdd(bit.bor(CAP_MOVE_JUMP))
	self:CapabilitiesAdd(bit.bor(CAP_USE))
	self:CapabilitiesAdd(bit.bor(CAP_OPEN_DOORS))
	self.NextScreamT = 0
	self:VJ_ZSSkin("models/cpthazama/zombiesurvival/howler/zombie_jailbait_noglow")
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
function ENT:Scream()
	VJ_EmitSound(self,"cpt_zs/howler/howler_scream_0" .. math.random(1,2) .. ".wav",100,math.random(95,135))
	for _,v in ipairs(ents.FindInSphere(self:GetPos(),330)) do
		if (v:IsPlayer() && v:Alive() && !v:GetNWBool("VJ_ZS_IsZombie")) or (v:IsNPC() && !VJ_HasValue(v.VJ_NPC_Class,"CLASS_ZOMBIE")) then
			local fHitPercentage = math.Clamp(1 -(v:GetPos():Distance(self:GetPos()) /330),0,1)						
			local fDamage = math.Round(22 *fHitPercentage,0,10)
			if fDamage > 0 && v:GetPos():Distance(self:GetPos()) < (330 *0.5) then
				v:TakeDamage(fDamage,self,self)
			end

			if v.VJ_ZS_LastHowlerScream && v.VJ_ZS_LastHowlerScream >= CurTime() -4 then
				continue
			end

			v.VJ_ZS_LastHowlerScream = CurTime()
			local fFuckIntensity = fHitPercentage *5.5

			if v:IsPlayer() then v:VJ_ZS_Howled(fFuckIntensity) end
		end
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
		if enemy.VJ_ZS_IsZombie then
			self:AddEntityRelationship(enemy,D_LI,99)
			table.insert(self.VJ_AddCertainEntityAsFriendly,enemy)
			self:AddEntityRelationship(enemy,D_LI,99)
			self:SetEnemy(NULL)
		end
		if dist <= 250 && CurTime() > self.NextScreamT then
			self:Scream()
			self.NextScreamT = CurTime() +4.5
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