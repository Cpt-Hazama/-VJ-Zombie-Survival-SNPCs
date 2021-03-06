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
	self:VJ_ZSSkin("models/headcrab_classic/headcrabsheet")
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
	*** Copyright (c) 2012-2017 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/