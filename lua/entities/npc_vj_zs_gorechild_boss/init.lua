AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2019 by Cpt. Hazama, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.StartHealth = 2000
ENT.tbl_Collision = {x=18,y=18,z=65}
ENT.ZS_BossBaby = true
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.Z_Speed = 0.6

ENT.MeleeAttackDamage = 35
ENT.MeleeAttackDistance = 80
ENT.MeleeAttackDamageDistance = 90

ENT.GeneralSoundPitch1 = 100
ENT.GeneralSoundPitch2 = 100
ENT.FootStepTimeRun = 0.5
ENT.FootStepTimeWalk = 0.5
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	local c = self.tbl_Collision
	self:SetModelScale(1.6,0)
	self:SetCollisionBounds(Vector(c.x,c.y,c.z),Vector(-c.x,-c.y,0))
	self:CapabilitiesAdd(bit.bor(CAP_MOVE_JUMP))
	self:CapabilitiesAdd(bit.bor(CAP_USE))
	self:CapabilitiesAdd(bit.bor(CAP_OPEN_DOORS))
	self.AnimTbl_IdleStand = {"zombie_run"}
	self.AnimTbl_Walk = {self:GetSequenceActivity(self:LookupSequence("zombie_run"))}
	self.AnimTbl_Run = {self:GetSequenceActivity(self:LookupSequence("zombie_run"))}
	self:VJ_ZSSkin("models/props_c17/doll01")
end
/*-----------------------------------------------
	*** Copyright (c) 2019 by Cpt. Hazama, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/