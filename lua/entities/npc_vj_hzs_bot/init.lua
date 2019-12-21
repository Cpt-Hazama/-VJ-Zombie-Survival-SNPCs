AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2019 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/player/kleiner.mdl"} -- The game will pick a random model from the table when the SNPC is spawned | Add as many as you want
ENT.StartHealth = 100 //GetConVarNumber("vj_dum_dummy_h")
ENT.HullType = HULL_HUMAN
ENT.VJ_NPC_Class = {"CLASS_PLAYER_ALLY"} -- NPCs with the same class with be allied to each other
ENT.PlayerFriendly = true
ENT.HasMeleeAttack = false -- Should the SNPC have a melee attack?
ENT.AnimTbl_WeaponAttackFiringGesture = {ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2}
ENT.PoseParameterLooking_Names = {pitch={"aim_rifle_pitch"},yaw={"aim_rifle_yaw"},roll={}}
ENT.AnimTbl_TakingCover = {}

ENT.SoundTbl_FootStep = {}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	local ply = player_manager.AllValidModels()
	local tbl = {}
	for _,v in pairs(ply) do
		table.insert(tbl,v)
	end
	self:SetModel(VJ_PICK(tbl))
	self:CapabilitiesAdd(bit.bor(CAP_MOVE_JUMP))
	self:CapabilitiesAdd(bit.bor(CAP_USE))
	self:CapabilitiesAdd(bit.bor(CAP_OPEN_DOORS))
	-- self:VJ_GetAllPoseParameters(true)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnThink()
	self.AnimTbl_IdleStand = {ACT_IDLE}
	self.AnimTbl_Walk = {VJ_SequenceToActivity(self,"rifle_walk")}
	self.AnimTbl_Run = {ACT_RUN}
	self.AnimTbl_ShootWhileMovingRun = {VJ_SequenceToActivity(self,"rifle_run")}
	self.AnimTbl_ShootWhileMovingWalk = {VJ_SequenceToActivity(self,"rifle_walk")}
	self.AnimTbl_WeaponAttack = {VJ_SequenceToActivity(self,"rifle_idle")}
	self.AnimTbl_WeaponReload = {"rifle_reload"}
	self.AnimTbl_MeleeAttack = {"rifle_melee"}
end
/*-----------------------------------------------
	*** Copyright (c) 2012-2019 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/