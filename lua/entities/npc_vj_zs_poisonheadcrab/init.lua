AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2017 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/cpthazama/zombiesurvival/poisonheadcrab.mdl"} -- The game will pick a random model from the table when the SNPC is spawned | Add as many as you want
ENT.StartHealth = 30
ENT.HullType = HULL_TINY
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_ZOMBIE"} -- NPCs with the same class with be allied to each other
ENT.BloodColor = "Yellow" -- The blood type, this will determine what it should use (decal, particle, etc.)
ENT.CustomBlood_Particle = {"blood_impact_yellow_01"}
ENT.HasMeleeAttack = false
ENT.HasBloodPool = false
ENT.HasLeapAttack = true -- Should the SNPC have a leap attack?
ENT.AnimTbl_LeapAttack = {ACT_RANGE_ATTACK1} -- Melee Attack Animations
ENT.LeapDistance = 250 -- The distance of the leap, for example if it is set to 500, when the SNPC is 500 Unit away, it will jump
ENT.LeapToMeleeDistance = 0 -- How close does it have to be until it uses melee?
ENT.TimeUntilLeapAttackDamage = 1.5 -- How much time until it runs the leap damage code?
ENT.NextLeapAttackTime = 1.8 -- How much time until it can use a leap attack?
ENT.NextAnyAttackTime_Leap = 1.8 -- How much time until it can use any attack again? | Counted in Seconds
ENT.TimeUntilLeapAttackVelocity = 1.48 -- How much time until it runs the velocity code?
ENT.LeapAttackVelocityForward = 50 -- How much forward force should it apply?
ENT.LeapAttackVelocityUp = 250 -- How much upward force should it apply?
ENT.LeapAttackDamage = 30
ENT.LeapAttackDamageType = DMG_POISON
ENT.LeapAttackExtraTimers = {1.6,1.8,2} -- Extra leap attack timers | it will run the damage code after the given amount of seconds
ENT.StopLeapAttackAfterFirstHit = true
ENT.LeapAttackDamageDistance = 40 -- How far does the damage go?
ENT.LeapAttackAnimationFaceEnemy = true
ENT.FootStepTimeRun = 0.5 -- Next foot step sound when it is running
ENT.FootStepTimeWalk = 0.5 -- Next foot step sound when it is walking
ENT.HasExtraMeleeAttackSounds = true -- Set to true to use the extra melee attack sounds
ENT.GeneralSoundPitch1 = 100

ENT.HasRangeAttack = true -- Should the SNPC have a range attack?
ENT.AnimTbl_RangeAttack = {ACT_RANGE_ATTACK2} -- Range Attack Animations
ENT.RangeAttackEntityToSpawn = "obj_vj_zs_headcrabspit" -- The entity that is spawned when range attacking
ENT.TimeUntilRangeAttackProjectileRelease = 0.725
ENT.NextRangeAttackTime = 2 -- How much time until it can use a range attack?
ENT.RangeDistance = 800 -- This is how far away it can shoot
ENT.RangeToMeleeDistance = ENT.LeapDistance +1 -- How close does it have to be until it uses melee?
ENT.RangeUseAttachmentForPos = false -- Should the projectile spawn on a attachment?
ENT.RangeAttackPos_Up = 15
ENT.RangeAttackPos_Forward = 10
	-- ====== Flinching Code ====== --
ENT.CanFlinch = 1 -- 0 = Don't flinch | 1 = Flinch at any damage | 2 = Flinch only from certain damages
ENT.AnimTbl_Flinch = {ACT_SMALL_FLINCH} -- If it uses normal based animation, use this
	-- ====== Sound File Paths ====== --
-- Leave blank if you don't want any sounds to play
ENT.SoundTbl_BeforeRangeAttack = {"npc/headcrab_poison/ph_scream1.wav","npc/headcrab_poison/ph_scream2.wav","npc/headcrab_poison/ph_scream3.wav"}
ENT.SoundTbl_BeforeLeapAttack = {"npc/headcrab_poison/ph_scream1.wav","npc/headcrab_poison/ph_scream2.wav","npc/headcrab_poison/ph_scream3.wav"}
ENT.SoundTbl_LeapAttackDamage = {"npc/headcrab_poison/ph_poisonbite1.wav","npc/headcrab_poison/ph_poisonbite2.wav","npc/headcrab_poison/ph_poisonbite3.wav"}
ENT.SoundTbl_LeapAttackJump = {"npc/headcrab_poison/ph_jump1.wav","npc/headcrab_poison/ph_jump2.wav","npc/headcrab_poison/ph_jump3.wav"}
ENT.SoundTbl_Pain = {"npc/headcrab_poison/ph_pain1.wav","npc/headcrab_poison/ph_pain2.wav","npc/headcrab_poison/ph_pain3.wav","npc/headcrab_poison/ph_wallpain1.wav","npc/headcrab_poison/ph_wallpain2.wav","npc/headcrab_poison/ph_wallpain3.wav"}
ENT.SoundTbl_Death = {"npc/headcrab_poison/ph_rattle1.wav","npc/headcrab_poison/ph_rattle2.wav","npc/headcrab_poison/ph_rattle3.wav"}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	self:SetCollisionBounds(Vector(14,14,15), Vector(-14,-14,0))
	self.AnimTbl_Walk = {VJ_SequenceToActivity(self,"Scurry")}
	self.AnimTbl_Run = {VJ_SequenceToActivity(self,"Scurry")}
	self:CapabilitiesAdd(bit.bor(CAP_MOVE_JUMP))
	self:CapabilitiesAdd(bit.bor(CAP_USE))
	self:CapabilitiesAdd(bit.bor(CAP_OPEN_DOORS))
	-- self:VJ_ZSSkin("models/cpthazama/zombiesurvival/poisonheadcrab/Blackcrab_noglow")
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:RangeAttackCode_GetShootPos(TheProjectile)
	return self:CalculateProjectile("Curve", self:GetPos(), self:GetEnemy():GetPos() + self:GetEnemy():OBBCenter(), 1200)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnLeapAttackVelocityCode()
	self:SetGroundEntity(NULL)
end
/*-----------------------------------------------
	*** Copyright (c) 2012-2017 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/