AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2019 by Cpt. Hazama, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/cpthazama/zombiesurvival/drifter.mdl"} -- Leave empty if using more than one model
ENT.StartHealth = 60
ENT.MoveType = MOVETYPE_STEP
ENT.HullType = HULL_HUMAN
ENT.tbl_Collision = {x=18,y=18,z=65}
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_ZOMBIE"}
ENT.BloodColor = "Red"
ENT.HasBloodPool = false
ENT.PropAP_MaxSize = 0

ENT.HasMeleeAttack = true -- Should the SNPC have a melee attack?
ENT.MeleeAttackDamage = 4
ENT.MeleeAttackDistance = 25
ENT.MeleeAttackDamageDistance = 110
ENT.TimeUntilMeleeAttackDamage = 0.1
ENT.NextAnyAttackTime_Melee = 1

ENT.MeleeAttackDamageType = DMG_SLASH -- Type of Damage
ENT.MeleeAttackAnimationAllowOtherTasks = true
-- ====== Sound File Paths ====== --
-- Leave blank if you don't want any sounds to play
ENT.SoundTbl_BeforeMeleeAttack = {"ambient/voices/squeal1.wav"}
ENT.SoundTbl_Pain = {
	"npc/barnacle/barnacle_pull1.wav",
	"npc/barnacle/barnacle_pull2.wav",
	"npc/barnacle/barnacle_pull3.wav",
	"npc/barnacle/barnacle_pull4.wav"
}

ENT.GeneralSoundPitch1 = 100
ENT.GeneralSoundPitch2 = 100
ENT.DisableFootStepTimer = true
ENT.HasExtraMeleeAttackSounds = true
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	local c = self.tbl_Collision
	self:SetCollisionBounds(Vector(c.x,c.y,c.z),Vector(-c.x,-c.y,0))
	self:CapabilitiesAdd(bit.bor(CAP_MOVE_JUMP))
	self:CapabilitiesAdd(bit.bor(CAP_USE))
	self:CapabilitiesAdd(bit.bor(CAP_OPEN_DOORS))
	self:VJ_ZSSkin("models/charple/charple4_sheet")
	self.NextRandomHealT = CurTime() +8
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
		if enemy.VJ_ZS_IsZombie then
			self:AddEntityRelationship(enemy,D_LI,99)
			table.insert(self.VJ_AddCertainEntityAsFriendly,enemy)
			self:AddEntityRelationship(enemy,D_LI,99)
			self:SetEnemy(NULL)
		end
	end
	if CurTime() > self.NextRandomHealT && math.random(1,1) == 1 then
		for _,v in pairs(ents.FindByClass("npc_vj_*")) do
			if VJ_HasValue(v.VJ_NPC_Class,"CLASS_ZOMBIE") && v:GetPos():Distance(self:GetPos()) <= 500 && v:Visible(self) then
				if v:Health() < v:GetMaxHealth() then
					v:SetHealth(math.Clamp(v:Health(),v:Health() +20,v:GetMaxHealth()))
					v:EmitSound("npc/vort/health_charge.wav",70,120)

					local spawnparticle = ents.Create("info_particle_system")
					spawnparticle:SetKeyValue("effect_name","vortigaunt_hand_glow")
					spawnparticle:SetPos(v:GetPos() +v:OBBCenter())
					spawnparticle:Spawn()
					spawnparticle:Activate()
					spawnparticle:SetParent(v)
					spawnparticle:Fire("Start","",0)
					spawnparticle:Fire("Kill","",0.6)
				end
			end
		end
		for _,v in pairs(player.GetAll()) do
			if v.VJ_ZS_IsZombie && v:GetPos():Distance(self:GetPos()) <= 500 && v:Visible(self) then
				if v:Health() < v:GetActiveWeapon().ZHealth then
					v:SetHealth(math.Clamp(v:Health(),v:Health() +20,v:GetActiveWeapon().ZHealth))
					v:EmitSound("npc/vort/health_charge.wav",70,120)

					local spawnparticle = ents.Create("info_particle_system")
					spawnparticle:SetKeyValue("effect_name","vortigaunt_hand_glow")
					spawnparticle:SetPos(v:GetPos() +v:OBBCenter())
					spawnparticle:Spawn()
					spawnparticle:Activate()
					spawnparticle:SetParent(v)
					spawnparticle:Fire("Start","",0)
					spawnparticle:Fire("Kill","",0.6)
				end
			end
		end
		VJ_EmitSound(self,"npc/antlion_guard/angry2.wav",95,85)
		self.NextRandomHealT = CurTime() +45
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