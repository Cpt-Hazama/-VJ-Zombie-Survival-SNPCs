AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2019 by Cpt. Hazama, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/cpthazama/zombiesurvival/wraith_beta.mdl"} -- Leave empty if using more than one model
ENT.StartHealth = 175
ENT.MoveType = MOVETYPE_STEP
ENT.HullType = HULL_HUMAN
ENT.tbl_Collision = {x=18,y=18,z=65}
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_ZOMBIE"}
ENT.BloodColor = "Red"
ENT.HasBloodPool = false
ENT.PropAP_MaxSize = 30

ENT.HasMeleeAttack = true -- Should the SNPC have a melee attack?
ENT.AnimTbl_MeleeAttack = {"vjges_attack1"} -- Melee Attack Animations
ENT.MeleeAttackDamage = 20
ENT.MeleeAttackDistance = 50
ENT.MeleeAttackDamageDistance = 60
ENT.TimeUntilMeleeAttackDamage = 0.5
ENT.NextAnyAttackTime_Melee = false

ENT.HasDeathRagdoll = false

ENT.MeleeAttackDamageType = DMG_SLASH -- Type of Damage
ENT.MeleeAttackAnimationAllowOtherTasks = true
-- ====== Sound File Paths ====== --
-- Leave blank if you don't want any sounds to play
ENT.SoundTbl_Idle = {"cpt_zs/wraith/idle1.wav","cpt_zs/wraith/idle2.wav","cpt_zs/wraith/idle3.wav","cpt_zs/wraith/idle4.wav"}
ENT.SoundTbl_BeforeMeleeAttack = {"cpt_zs/wraith/attack1.wav","cpt_zs/wraith/attack2.wav","cpt_zs/wraith/attack3.wav"}
ENT.SoundTbl_Pain = {"cpt_zs/wraith/pain1.wav","cpt_zs/wraith/pain2.wav","cpt_zs/wraith/pain3.wav","cpt_zs/wraith/pain4.wav"}
ENT.SoundTbl_Death = {"npc/stalker/go_alert2a.wav"}
ENT.SoundTbl_MeleeAttackExtra = {"ambient/machines/slicer1.wav","ambient/machines/slicer2.wav","ambient/machines/slicer3.wav","ambient/machines/slicer4.wav"}

ENT.GeneralSoundPitch1 = 100
ENT.GeneralSoundPitch2 = 100
ENT.HasExtraMeleeAttackSounds = true
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	local c = self.tbl_Collision
	self:SetCollisionBounds(Vector(c.x,c.y,c.z),Vector(-c.x,-c.y,0))
	self:CapabilitiesAdd(bit.bor(CAP_MOVE_JUMP))
	self:CapabilitiesAdd(bit.bor(CAP_USE))
	self:CapabilitiesAdd(bit.bor(CAP_OPEN_DOORS))
	self:DrawShadow(false)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:WraithDraw(trans)
	self:SetRenderMode(RENDERMODE_TRANSADD)
	self:SetColor(Color(65,65,65,trans))
	if trans < 50 then
		self.VJ_NoTarget = true
	else
		self.VJ_NoTarget = false
	end
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
	self:RemoveAllDecals()
	if self.MeleeAttacking then
		self:WraithDraw(220)
	elseif self:IsMoving() then
		self:WraithDraw(50)
	elseif !self:IsMoving() then
		self:WraithDraw(1)
	end
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