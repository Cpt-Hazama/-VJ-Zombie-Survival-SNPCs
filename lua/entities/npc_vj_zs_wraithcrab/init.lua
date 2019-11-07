AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2017 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
function ENT:CustomOnInitialize()
	self:SetModel("models/cpthazama/zombiesurvival/wraithcrab.mdl")
	self:SetCollisionBounds(Vector(8,10,15), Vector(-8,-10,0))
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
function ENT:CustomOnThink()
	self:RemoveAllDecals()
	if self.LeapAttacking then
		self:WraithDraw(220)
	elseif self:IsMoving() then
		self:WraithDraw(50)
	elseif !self:IsMoving() then
		self:WraithDraw(1)
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
	*** Copyright (c) 2012-2017 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/