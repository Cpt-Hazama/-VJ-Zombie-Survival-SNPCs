AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2019 by Cpt. Hazama, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/cpthazama/zombiesurvival/events/hw/skeleton.mdl"} -- Leave empty if using more than one model
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnKilled(dmginfo,hitgroup)
	local effectdata = EffectData()
	effectdata:SetOrigin(self:GetPos() +self:OBBCenter())
	effectdata:SetEntity(self)
	util.Effect("zs_flesh_death",effectdata)

	local effectdata = EffectData()
	effectdata:SetOrigin(self:GetPos() +self:OBBCenter())
	util.Effect("zs_hw_soul",effectdata)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:ZSInit()
	local eyeglow = ents.Create("env_sprite")
	eyeglow:SetKeyValue("model","sprites/redglow2.vmt")
	eyeglow:SetKeyValue("scale","0.6")
	eyeglow:SetKeyValue("rendermode","9")
	eyeglow:SetKeyValue("rendercolor","255 0 150 0")
	eyeglow:SetKeyValue("spawnflags","1")
	eyeglow:SetParent(self)
	eyeglow:Fire("SetParentAttachment","chest",0)
	eyeglow:Spawn()
	eyeglow:Activate()
	self:DeleteOnRemove(eyeglow)
	
	self.SoundTbl_BeforeMeleeAttack = {"cpt_zs/events/hw/skeleton_attack1.wav","cpt_zs/events/hw/skeleton_attack3.wav"}
	self.SoundTbl_Idle = {"cpt_zs/events/hw/skeleton_idle1.wav","cpt_zs/events/hw/skeleton_idle2.wav"}
	self.SoundTbl_Pain = {
		"cpt_zs/events/hw/skeleton_pain1.wav",
		"cpt_zs/events/hw/skeleton_pain2.wav",
		"cpt_zs/events/hw/skeleton_pain3.wav",
		"cpt_zs/events/hw/skeleton_pain4.wav",
	}
	self.SoundTbl_Death = {"cpt_zs/events/hw/skeleton_death1.wav","cpt_zs/events/hw/skeleton_death2.wav"}

	self.AnimTbl_IdleStand = {ACT_IDLE_ANGRY}
	self.AnimTbl_Walk = {ACT_WALK_STIMULATED}
	self.AnimTbl_Run = {ACT_WALK_STIMULATED}
end
/*-----------------------------------------------
	*** Copyright (c) 2019 by Cpt. Hazama, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/