if (!file.Exists("autorun/vj_base_autorun.lua","LUA")) then return end
---------------------------------------------------------------------------------------------------------------------------------------------
	-- ZS Settings --
SWEP.PrintName					= "Wraith"
-- SWEP.ViewModel					= "models/cpthazama/zombiesurvival/weapons/poisonzombie.mdl" -- Original hands 2011
SWEP.ViewModel					= "models/cpthazama/zombiesurvival/weapons/wraithbeta.mdl"
SWEP.ZombieModel				= "models/cpthazama/zombiesurvival/wraith_beta.mdl"
SWEP.ZHealth					= 175
SWEP.ZSpeed						= 200
-- SWEP.ViewModelFOV				= 70
SWEP.ViewModelFOV				= 54
SWEP.BobScale 					= 0.4
SWEP.SwayScale 					= 0.2
SWEP.Damage 					= 20
SWEP.DamageTime 				= 0.6
SWEP.PhysForce 					= 2
local attackSpeed 				= 1.4
local animDelay 				= 1.2
SWEP.Primary.Sound				= {"cpt_zs/wraith/attack1.wav","cpt_zs/wraith/attack2.wav","cpt_zs/wraith/attack3.wav"}
SWEP.MoanSound 					= {"cpt_zs/wraith/idle1.wav","cpt_zs/wraith/idle2.wav","cpt_zs/wraith/idle3.wav","cpt_zs/wraith/idle4.wav"}
SWEP.PainSounds 				= {"cpt_zs/wraith/pain1.wav","cpt_zs/wraith/pain2.wav","cpt_zs/wraith/pain3.wav","cpt_zs/wraith/pain4.wav"}
SWEP.AnimTbl_PrimaryFire		= {ACT_VM_HITCENTER,ACT_VM_SECONDARYATTACK}
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
function SWEP:VJ_TranslateActivities()
	local idle = ACT_IDLE
	local walk = ACT_RUN
	local run = ACT_RUN
	local attack = ACT_MELEE_ATTACK1
	self.ActivityTranslate = {}
	self.ActivityTranslate[ACT_MP_STAND_IDLE]					= idle
	self.ActivityTranslate[ACT_MP_WALK]							= walk
	self.ActivityTranslate[ACT_MP_RUN]							= run
	self.ActivityTranslate[ACT_MP_CROUCH_IDLE]					= idle
	self.ActivityTranslate[ACT_MP_CROUCHWALK]					= walk
	self.ActivityTranslate[ACT_MP_ATTACK_STAND_PRIMARYFIRE]		= attack
	self.ActivityTranslate[ACT_MP_ATTACK_CROUCH_PRIMARYFIRE]	= attack
	self.ActivityTranslate[ACT_MP_JUMP]							= run
	self.ActivityTranslate[ACT_RANGE_ATTACK1]					= attack
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:TranslateActivity(act)
	if self.ActivityTranslate[act] != nil then
		return self.ActivityTranslate[act]
	end
	return -1
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:CustomOnInitialize()
   timer.Simple(0,function() self:VJ_TranslateActivities() end)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:CustomOnPrimaryAttack_BeforeShoot()
	if (CLIENT) then return end
	timer.Simple(self.DamageTime,function()
		if IsValid(self) then
			local tr = util.TraceHull({
				start = self.Owner:GetShootPos(),
				endpos = self.Owner:GetShootPos() +(self.Owner:GetAimVector() *150),
				filter = self.Owner,
				mins = Vector(-10,-10,-10),
				maxs = Vector(10,10,10)
			})
			if tr.Hit then
				sound.Play("npc/zombie/claw_strike"..math.random(1,3)..".wav",tr.HitPos,70,100)
			else
				sound.Play("npc/zombie/claw_miss"..math.random(1,2)..".wav",self:GetPos(),60,100)
			end
			if IsValid(tr.Entity) then
				local ent = tr.Entity

				local phys = ent:GetPhysicsObject()
				if phys:IsValid() && !ent:IsNPC() then
					local vel = self.Damage *512 *self.Owner:GetAimVector()
					phys:ApplyForceOffset(vel,(ent:NearestPoint(self.Owner:GetShootPos()) +ent:GetPos() *self.PhysForce) /3)
					ent:SetPhysicsAttacker(self.Owner)
				end

				local dmginfo = DamageInfo()
				dmginfo:SetDamage(self.Damage)
				dmginfo:SetAttacker(self.Owner)
				dmginfo:SetInflictor(self.Owner)
				dmginfo:SetDamageType(DMG_SLASH)
				dmginfo:SetDamagePosition(ent:NearestPoint(self.Owner:GetPos() +self.Owner:OBBCenter()))
				ent:TakeDamageInfo(dmginfo)
			end
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
function SWEP:CustomOnThink()
	if SERVER then
		self.NextMoanT = self.NextMoanT or CurTime()
		if CurTime() > self.NextMoanT then
			self:EmitSound(VJ_PICK(self.MoanSound),75,100)
			self.NextMoanT = CurTime() +math.Rand(5,8)
		end
	end
	self.Owner:DrawShadow(false)
	self.Owner:SetRunSpeed(self.ZSpeed)
	self.Owner:SetWalkSpeed(self.ZSpeed)
	if SERVER then
		if CurTime() < self:GetNextPrimaryFire() then
			self:WraithDraw(220,self.Owner)
		elseif self.Owner:GetVelocity():Length() > 1 then
			self:WraithDraw(50,self.Owner)
		else
			self:WraithDraw(1,self.Owner)
		end
	else
		if IsValid(self:GetOwner():GetViewModel()) then
			local vm = self:GetOwner():GetViewModel()
			if CurTime() < self:GetNextPrimaryFire() then
				self:WraithDraw(220,vm)
			elseif self.Owner:GetVelocity():Length() > 1 then
				self:WraithDraw(50,vm)
			else
				self:WraithDraw(1,vm)
			end
		end
	end
	if SERVER then self:GetOwner():SetModel(self.ZombieModel); self.Owner.VJ_NPC_Class = {"CLASS_ZOMBIE"} end
	if IsValid(self.Owner) && self.Owner:GetActiveWeapon() != self then
		self.Owner.VJ_NPC_Class = {"CLASS_PLAYER_ALLY"}
		table.Empty(self.Owner.VJ_NPC_Class)
		self.Owner:Kill()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:CustomOnPrimaryAttack_AfterShoot()
	self:SendWeaponAnim(VJ_PICK(self.AnimTbl_PrimaryFire))
	if IsValid(self:GetOwner():GetViewModel()) then
		local vm = self:GetOwner():GetViewModel()
		vm:SetPlaybackRate(attackSpeed)
		timer.Simple(animDelay,function()
			if IsValid(self) then
				vm:SetPlaybackRate(1)
			end
		end)
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
		end
	end)
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
		-- self:ZRemove()
	else
		if IsValid(self:GetOwner():GetViewModel()) then
			local vm = self:GetOwner():GetViewModel()
			vm:SetRenderMode(RENDERMODE_NORMAL)
			vm:SetColor(Color(255,255,255,255))
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:Holster(wep)
	if SERVER then
		-- self:ZRemove()
	end
	return false
end
---------------------------------------------------------------------------------------------------------------------------------------------
-- function SWEP:ViewModelDrawn()
	-- render.ModelMaterialOverride(0)
-- end
---------------------------------------------------------------------------------------------------------------------------------------------
-- local matSheet = Material("models/cpthazama/zombiesurvival/wraithbeta/s_chest2dull")
-- function SWEP:PreDrawViewModel(vm)
	-- render.ModelMaterialOverride(matSheet)
-- end