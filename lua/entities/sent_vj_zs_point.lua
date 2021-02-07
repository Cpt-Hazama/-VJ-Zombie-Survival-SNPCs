/*--------------------------------------------------
	*** Copyright (c) 2012-2019 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
--------------------------------------------------*/
AddCSLuaFile()
if (!file.Exists("autorun/vj_base_autorun.lua","LUA")) then return end

ENT.Base 			= "base_gmodentity"
ENT.Type 			= "anim"
ENT.PrintName 		= "Objective Point"
ENT.Author 			= "Cpt. Hazama"
ENT.Contact 		= "http://steamcommunity.com/groups/vrejgaming"
ENT.Purpose 		= ""
ENT.Instructions 	= "Holdout at this designated point until the next wave (depending on how many points there are)!"
-- ENT.Category		= "VJ Base"

ENT.Spawnable = false
ENT.AdminOnly = false
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetupDataTables()
	self:NetworkVar("Bool",0,"Activated")
end
---------------------------------------------------------------------------------------------------------------------------------------------
if (CLIENT) then
	local t = 0
	local lT = 0
	local sizeMin = 100
	local sizeMax = 150
	local size = sizeMin
	local offset = 50
	local alpha = 255
	function ENT:Draw()
		-- self:DrawModel()
		local ply = LocalPlayer()
		local dist = ply:GetPos():Distance(self:GetPos())

		if self:GetActivated() then
			local pos = self:GetPos()
			local posOffset = pos +Vector(0,0,40)
			if dist <= 1275 then
				alpha = (dist /10)
			end
			cam.Start2D(pos,self:GetAngles(),0)
				local entPos = (posOffset):ToScreen()
				surface.SetMaterial(Material("HUD/hud_warning2"))
				surface.SetDrawColor(Color(255,255,255,alpha))
				surface.DrawTexturedRect(entPos.x -offset,entPos.y -offset,size,size)
			cam.End2D()
		end
	end
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
if !(SERVER) then return end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Initialize()
	self:SetModel("models/props_borealis/bluebarrel001.mdl")
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_NONE)
	self:DrawShadow(false)
	
	self:SetActivated(false)
	timer.Simple(0,function()
		local p = Entity(1)
		local cont = true
		for _,v in pairs(ents.FindByClass("sent_vj_zs_gamemode")) do
			if IsValid(p) then
				p:ChatPrint("Game already in session! Removing entity...")
			end
			cont = false
			self:Remove()
		end
		local count = 0
		for _,v in pairs(ents.FindByClass("sent_vj_zs_point")) do
			if v != self then
				count = count +1
			end
		end
		if count >= 8 then
			if IsValid(p) then
				p:ChatPrint("Maximum Objective Points placed (max. 8)! Removing entity...")
			end
			cont = false
			self:Remove()
		end
		if cont then
			local me = count +1
			if IsValid(p) then
				p:ChatPrint("Successfully created Objective Point " .. me .. "/8!")
			end
		end
	end)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnActivated()
	self:SetActivated(true)
	for _,v in pairs(player.GetAll()) do
		self.MasterEntity:PlayerNWSound(v,"cpt_zs/mrgreen/beep22.wav")
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnRemove()
	self:StopParticles()
end
/*--------------------------------------------------
	*** Copyright (c) 2012-2019 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
--------------------------------------------------*/