/*--------------------------------------------------
	*** Copyright (c) 2012-2019 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
--------------------------------------------------*/
AddCSLuaFile()
if (!file.Exists("autorun/vj_base_autorun.lua","LUA")) then return end

ENT.Base 			= "base_gmodentity"
ENT.Type 			= "anim"
ENT.PrintName 		= "Ammo Crate"
ENT.Author 			= "Cpt. Hazama"
ENT.Contact 		= "http://steamcommunity.com/groups/vrejgaming"
ENT.Purpose 		= ""
ENT.Instructions 	= ""
-- ENT.Category		= "VJ Base"

ENT.Spawnable = false
ENT.AdminOnly = false
---------------------------------------------------------------------------------------------------------------------------------------------
if (CLIENT) then
	function ENT:Draw()
		self:DrawModel()

			-- Side 1 --
		local ledcolor = Color(50,255,0,255)
		local Position = self:GetPos() +self:GetForward() *2 +self:GetUp() *26 +self:GetRight() *10.5
		local Angles = self:GetAngles()
		Angles:RotateAroundAxis(Angles:Right(),Vector(0,0,0).x)
		Angles:RotateAroundAxis(Angles:Up(),Vector(90,90,90).y)
		Angles:RotateAroundAxis(Angles:Forward(),Vector(90,90,90).z)
		cam.Start3D2D(Position,Angles,0.3)
			draw.SimpleText("Your Kills - " .. LocalPlayer():GetNWInt("VJ_ZSKills"),"VJ_ZS",31,-22,ledcolor,1,1)
		cam.End3D2D()

		local ledcolor = Color(255,0,0,255)
		local Position = self:GetPos() +self:GetForward() *2 +self:GetUp() *30 +self:GetRight() *10.5
		local Angles = self:GetAngles()
		Angles:RotateAroundAxis(Angles:Right(),Vector(0,0,0).x)
		Angles:RotateAroundAxis(Angles:Up(),Vector(90,90,90).y)
		Angles:RotateAroundAxis(Angles:Forward(),Vector(90,90,90).z)
		cam.Start3D2D(Position,Angles,0.3)
			draw.SimpleText("Ammo - 50 Kills","VJ_ZS",31,-22,ledcolor,1,1)
		cam.End3D2D()

			-- Side 2 --
		local ledcolor = Color(50,255,0,255)
		local Position = self:GetPos() +self:GetForward() *2 +self:GetUp() *26 +self:GetRight() *-8
		local Angles = self:GetAngles()
		Angles:RotateAroundAxis(Angles:Right(),Vector(0,0,0).x)
		Angles:RotateAroundAxis(Angles:Up(),Vector(270,270,270).y)
		Angles:RotateAroundAxis(Angles:Forward(),Vector(90,90,90).z)
		cam.Start3D2D(Position,Angles,0.3)
			draw.SimpleText("Your Kills - " .. LocalPlayer():GetNWInt("VJ_ZSKills"),"VJ_ZS",31,-22,ledcolor,1,1)
		cam.End3D2D()

		local ledcolor = Color(255,0,0,255)
		local Position = self:GetPos() +self:GetForward() *2 +self:GetUp() *30 +self:GetRight() *-8
		local Angles = self:GetAngles()
		Angles:RotateAroundAxis(Angles:Right(),Vector(0,0,0).x)
		Angles:RotateAroundAxis(Angles:Up(),Vector(270,270,270).y)
		Angles:RotateAroundAxis(Angles:Forward(),Vector(90,90,90).z)
		cam.Start3D2D(Position,Angles,0.3)
			draw.SimpleText("Ammo - 50 Kills","VJ_ZS",31,-22,ledcolor,1,1)
		cam.End3D2D()
	end
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
if !(SERVER) then return end

ENT.VJ_AddEntityToSNPCAttackList = true
ENT.Model = {"models/Items/item_item_crate.mdl"}
ENT.StartHealth = 350
ENT.AmmoCost = 50
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Initialize()
	self:SetModel(Model(VJ_PICK(self.Model)))
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetHealth(self.StartHealth)

	local phys = self:GetPhysicsObject()
	if phys and phys:IsValid() then
		phys:Wake()
		phys:SetMass(950)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:PhysicsCollide(data,physobj)
	local vol = data.Speed
	self:EmitSound("physics/wood/wood_box_impact_hard"..math.random(1,3)..".wav",math.Clamp(vol,20,90),100)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Think()
	
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Use(activator,caller)
	if activator:IsPlayer() then
		if activator.ZS_Kills == nil then activator.ZS_Kills = 0 end
		if activator.ZS_Kills >= self.AmmoCost then
			self:EmitSound("items/ammocrate_open.wav",75,100)
			self:EmitSound("items/ammo_pickup.wav",70,100)
			activator.ZS_Kills = activator.ZS_Kills -self.AmmoCost
			activator:SetNWInt("VJ_ZSKills",activator.ZS_Kills)
			activator:VJ_RestoreAmmo(false,50,100)
			activator:EmitSound("weapons/physcannon/physcannon_charge.wav",50,100)
			activator:PrintMessage(HUD_PRINTTALK,"You have picked up ammo!")
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnTakeDamage(dmginfo)
	if IsValid(dmginfo:GetAttacker()) then
		local ent = dmginfo:GetAttacker()
		if ent:IsNPC() || ent:IsPlayer() && ent.VJ_ZS_IsZombie then
			self:SetHealth(self:Health() -dmginfo:GetDamage())
		end
	end
	if self:Health() <= 0 then self:DoDeath() end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:DoDeath()
	local effectdata = EffectData()
	effectdata:SetOrigin(self:GetPos())
	util.Effect("Explosion", effectdata)
	self:Remove()
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