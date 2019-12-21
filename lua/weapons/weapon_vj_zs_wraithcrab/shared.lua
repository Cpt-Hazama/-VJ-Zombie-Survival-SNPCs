if (!file.Exists("autorun/vj_base_autorun.lua","LUA")) then return end
---------------------------------------------------------------------------------------------------------------------------------------------
	-- ZS Settings --
SWEP.PrintName					= "Wraithcrab"
SWEP.ViewModel					= "models/error.mdl"
SWEP.ZombieModel				= "models/cpthazama/zombiesurvival/headcrab.mdl"
SWEP.ZHealth					= 10
SWEP.ZSpeed						= 150
SWEP.ViewModelFOV				= 70
SWEP.BobScale 					= 0.4
SWEP.SwayScale 					= 0.2
SWEP.Damage 					= 4
local attackSpeed 				= 1
local animDelay 				= 1.5
SWEP.Primary.Sound				= {"npc/headcrab/attack1.wav","npc/headcrab/attack2.wav","npc/headcrab/attack3.wav"}
SWEP.PainSounds 				= {"npc/headcrab/pain1.wav","npc/headcrab/pain2.wav","npc/headcrab/pain3.wav"}
SWEP.AnimTbl_PrimaryFire		= {}
---------------------------------------------------------------------------------------------------------------------------------------------
SWEP.Base 						= "weapon_vj_base"
SWEP.WorldModel_Invisible		= true
SWEP.Author 					= "Cpt. Hazama"
SWEP.Contact					= "http://steamcommunity.com/groups/vrejgaming"
SWEP.Purpose					= "This weapon is made for Players and NPCs"
SWEP.Instructions				= "Controls are like a regular weapon."
-- SWEP.Category					= "VJ Base - Zombie Survival"
	-- Client Settings ---------------------------------------------------------------------------------------------------------------------------------------------
if (CLIENT) then
SWEP.Slot						= 1 -- Which weapon slot you want your SWEP to be in? (1 2 3 4 5 6) 
SWEP.SlotPos					= 4 -- Which part of that slot do you want the SWEP to be in? (1 2 3 4 5 6)
end
	-- Main Settings ---------------------------------------------------------------------------------------------------------------------------------------------
SWEP.WorldModel					= "models/weapons/w_knife_t.mdl" 
SWEP.HoldType 					= "knife"
SWEP.Spawnable					= false
SWEP.AdminSpawnable				= false
SWEP.Primary.ClipSize			= 30 -- Max amount of bullets per clip
SWEP.Primary.TakeAmmo = 0
SWEP.Primary.Recoil = 0
SWEP.Primary.Automatic			= true -- Is it automatic?
SWEP.Primary.Ammo				= "none" -- Ammo type
SWEP.Primary.DisableBulletCode	= true -- The bullet won't spawn, this can be used when creating a projectile-based weapon
SWEP.PrimaryEffects_MuzzleFlash = false
SWEP.PrimaryEffects_SpawnShells = false
SWEP.PrimaryEffects_SpawnDynamicLight = false
SWEP.Primary.Delay				= animDelay
SWEP.NextIdle_PrimaryAttack 	= animDelay
	-- Deployment Settings ---------------------------------------------------------------------------------------------------------------------------------------------
SWEP.DelayOnDeploy 				= 1 -- Time until it can shoot again after deploying the weapon
	-- Idle Settings ---------------------------------------------------------------------------------------------------------------------------------------------
SWEP.HasIdleAnimation			= true -- Does it have a idle animation?
SWEP.AnimTbl_Idle				= {ACT_VM_IDLE}
SWEP.NextIdle_Deploy			= 0.5 -- How much time until it plays the idle animation after the weapon gets deployed
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:Reload()
	return false
end
---------------------------------------------------------------------------------------------------------------------------------------------
SWEP.HasHit = false
SWEP.LastAttackT = 0
function SWEP:CustomOnPrimaryAttack_BeforeShoot()
	if (CLIENT) then return end
	self.Owner:ViewPunch(Angle(8,0,0))
	self.Owner:SetGroundEntity(NULL)
	self.Owner:SetVelocity(self.Owner:GetForward() *500 +self.Owner:GetUp() *200)
	self.Owner:Fire("IgnoreFallDamage","",0)
	self.LastAttackT = CurTime() +2.5
	self.HasHit = false
	self:EmitSound(VJ_PICK(self.Primary.Sound),80,100)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:CustomOnThink()
	if IsValid(self.Owner:GetViewModel()) then
		local vm = self.Owner:GetViewModel()
		vm:SetNoDraw(true)
	end
	if self.Owner:GetViewOffset().z != 8 then
		self.Owner:SetViewOffset(Vector(0,0,8))
		self.Owner:SetViewOffsetDucked(Vector(0,0,8))
	end
	self.Owner:SetRunSpeed(self.ZSpeed)
	self.Owner:SetWalkSpeed(self.ZSpeed)
	self.Owner:DrawShadow(false)
	if SERVER then
		if CurTime() < self:GetNextPrimaryFire() then
			self:WraithDraw(220,self.Owner)
		elseif self.Owner:GetVelocity():Length() > 1 then
			self:WraithDraw(50,self.Owner)
		else
			self:WraithDraw(1,self.Owner)
		end
	end
	if SERVER then self:GetOwner():SetModel(self.ZombieModel) end
	if self:GetVelocity().z > 5 && CurTime() < self.LastAttackT then
		if !self.HasHit then
			local tr = util.TraceHull({
				start = self.Owner:GetShootPos(),
				endpos = self.Owner:GetShootPos() +(self.Owner:GetAimVector() *150),
				filter = self.Owner,
				mins = Vector(-10,-10,-10),
				maxs = Vector(10,10,10)
			})
			if IsValid(tr.Entity) then
				local ent = tr.Entity
				sound.Play("npc/headcrab/headbite.wav",tr.HitPos,70,100)
				self.HasHit = true

				local dmginfo = DamageInfo()
				dmginfo:SetDamage(self.Damage)
				dmginfo:SetAttacker(self.Owner)
				dmginfo:SetInflictor(self.Owner)
				dmginfo:SetDamageType(DMG_SLASH)
				dmginfo:SetDamagePosition(ent:NearestPoint(self.Owner:GetPos() +self.Owner:OBBCenter()))
				ent:TakeDamageInfo(dmginfo)
			end
		end
	end
	if IsValid(self.Owner) && self.Owner:GetActiveWeapon() != self then
		self.Owner.VJ_NPC_Class = {"CLASS_PLAYER_ALLY"}
		table.Empty(self.Owner.VJ_NPC_Class)
		self.Owner:Kill()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:PainSound()
	self:EmitSound(VJ_PICK(self.PainSounds),80,100)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:CustomOnDeploy()
	self:SetClip1(1)
	util.PrecacheModel(self.ZombieModel)
	-- if SERVER then
		-- local ply = self.Owner
		-- ply.VJ_NPC_Class = {}
		-- table.insert(ply.VJ_NPC_Class,"CLASS_ZOMBIE")
		-- for _,v in pairs(ents.FindByClass("npc_vj_*")) do
			-- if VJ_HasValue(v.VJ_NPC_Class,"CLASS_ZOMBIE") then
				-- v:AddEntityRelationship(ply,D_LI,99)
				-- table.insert(v.VJ_AddCertainEntityAsFriendly,ply)
			-- else
				-- v:AddEntityRelationship(ply,D_HT,99)
				-- table.insert(v.VJ_AddCertainEntityAsEnemy,ply)
			-- end
		-- end
	-- end
	timer.Simple(0.03,function()
		if IsValid(self) then
			self.Owner:SetHealth(self.ZHealth)
			self.Owner:SetModel(self.ZombieModel); self.Owner:AllowFlashlight(false)
			self.Owner:SetViewOffset(Vector(0,0,8))
			self.Owner:SetViewOffsetDucked(Vector(0,0,8))
		end
	end)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:WraithDraw(trans,ent)
	ent:SetRenderMode(RENDERMODE_TRANSADD)
	ent:SetColor(Color(65,65,65,trans))
	if ent:IsPlayer() then
		if trans < 50 then
			self.Owner.VJ_NoTarget = true
			self.Owner:SetNoTarget(true)
		else
			self.Owner.VJ_NoTarget = false
			self.Owner:SetNoTarget(false)
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:Equip() end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:ZRemove()
	if SERVER then
		local ply = self.Owner
		ply.VJ_NPC_Class = nil
		for _,v in pairs(ents.FindByClass("npc_vj_*")) do
			if VJ_HasValue(v.VJ_NPC_Class,"CLASS_ZOMBIE") then
				v:AddEntityRelationship(ply,D_HT,99)
				v:SetEnemy(ply)
				table.insert(v.VJ_AddCertainEntityAsEnemy,ply)
			elseif VJ_HasValue(v.VJ_NPC_Class,"CLASS_PLAYER_ALLY") or v.PlayerFriendly then
				v:AddEntityRelationship(ply,D_LI,99)
				table.insert(v.VJ_AddCertainEntityAsFriendly,ply)
			end
		end
		ply.VJ_NPC_Class = nil
		timer.Simple(0.1,function()
			if IsValid(ply) then
				if istable(ply.VJ_NPC_Class) then
					table.Empty(ply.VJ_NPC_Class)
				end
				ply.VJ_NPC_Class = nil
			end
		end)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:CustomOnRemove()
	self.Owner:AllowFlashlight(true)
	if SERVER then
		self.Owner:DrawShadow(true)
		self.Owner.VJ_NoTarget = false
		self.Owner:SetNoTarget(false)
		self.Owner:SetRenderMode(RENDERMODE_NORMAL)
		self.Owner:SetColor(Color(255,255,255,255))
		self.Owner:SetViewOffset(Vector(0,0,60))
		self.Owner:SetViewOffsetDucked(Vector(0,0,28))
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:Holster(wep)
	if SERVER then
		-- self:ZRemove()
	end
	return false
end