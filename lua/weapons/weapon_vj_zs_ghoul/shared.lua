if (!file.Exists("autorun/vj_base_autorun.lua","LUA")) then return end
---------------------------------------------------------------------------------------------------------------------------------------------
	-- ZS Settings --
SWEP.PrintName					= "Ghoul"
SWEP.ViewModel					= "models/cpthazama/zombiesurvival/weapons/zombie.mdl"
SWEP.ZombieModel				= "models/cpthazama/zombiesurvival/ghoul.mdl"
SWEP.ZHealth					= 100
SWEP.ZSpeed						= 130
SWEP.ZSteps 					= {"npc/zombie/foot1.wav","npc/zombie/foot2.wav","npc/zombie/foot3.wav"}
SWEP.ZStepTime 					= 520
SWEP.ViewModelFOV				= 70
SWEP.BobScale 					= 0.4
SWEP.SwayScale 					= 0.2
SWEP.Damage 					= 14
SWEP.DamageTime 				= 0.6
SWEP.PhysForce 					= 2
local attackSpeed 				= 1.4
local animDelay 				= 1.2
SWEP.Primary.Sound				= {"npc/fast_zombie/leap1.wav"}
SWEP.MoanSound 					= {}
SWEP.PainSounds 				= {"npc/zombie_poison/pz_pain1.wav","npc/zombie_poison/pz_pain2.wav","npc/zombie_poison/pz_pain3.wav"}
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
	self.NextMoanT = self.NextMoanT or CurTime()
	if CurTime() > self.NextMoanT then
		-- self:EmitSound("npc/zombie/zombie_voice_idle"..math.random(1,14)..".wav",80,100)
		self.NextMoanT = CurTime() +5
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:VJ_TranslateActivities()
	local idle = ACT_IDLE
	local walk = ACT_WALK
	local run = ACT_WALK
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
		local doingAttack = (act == ACT_MP_ATTACK_STAND_PRIMARYFIRE or act == ACT_MP_ATTACK_CROUCH_PRIMARYFIRE or act == ACT_RANGE_ATTACK1)
		if self:GetNW2Bool("Range") && doingAttack then
			return ACT_MELEE_ATTACK1
		end
		return self.ActivityTranslate[act]
	end
	return -1
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:CustomOnInitialize()
	timer.Simple(0,function() self:VJ_TranslateActivities() end)
	self:SetNW2Bool("Range",false)
end
---------------------------------------------------------------------------------------------------------------------------------------------
SWEP.NextRangeT = CurTime()
function SWEP:SecondaryAttack()
	if CurTime() > self.NextRangeT then
		if (CLIENT) then return end
		self:SetNW2Bool("Range",true)
		self:AttackAnim(self.AnimTbl_PrimaryFire)
		self.Owner:SetAnimation(PLAYER_ATTACK1)
		self:EmitSound("npc/fast_zombie/wake1.wav",75,100)
		timer.Simple(0.6,function()
			if IsValid(self) then
				self:SetNW2Bool("Range",false)
				for i = 1,3 do
					local spit = ents.Create("obj_vj_zs_flesh")
					spit:SetPos(self.Owner:GetShootPos())
					spit:SetAngles(self.Owner:GetAngles())
					spit:Spawn()
					spit:SetOwner(self.Owner)
					spit:SetPhysicsAttacker(self.Owner)
					local phys = spit:GetPhysicsObject()
					if IsValid(phys) then
						phys:Wake()
						phys:SetVelocity(self:ThrowCode())
					end
				end
			end
		end)
		timer.Simple(self.NextIdle_PrimaryAttack,function() if self:IsValid() then self:DoIdleAnimation() end end)
		self.NextRangeT = CurTime() +5
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:ThrowCode(TheProjectile)
	self:EmitSound("physics/body/body_medium_break2.wav",75,100)
	local b = math.random(2,3)
	return ((self.Owner:GetPos() +self.Owner:GetForward() *200) -self.Owner:GetPos()) *1 +self.Owner:GetForward() *250 +self.Owner:GetUp() *150 +self.Owner:GetUp() *math.random(-b *35,b *35) +self.Owner:GetRight() *math.random(-b *50,b *50)
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
function SWEP:CustomOnThink()
	self.Owner:SetRunSpeed(self.ZSpeed)
	self.Owner:SetWalkSpeed(self.ZSpeed)
	if SERVER then self:GetOwner():SetModel(self.ZombieModel); self.Owner.VJ_NPC_Class = {"CLASS_ZOMBIE"} end
	if IsValid(self.Owner) && self.Owner:GetActiveWeapon() != self then
		self.Owner.VJ_NPC_Class = {"CLASS_PLAYER_ALLY"}
		table.Empty(self.Owner.VJ_NPC_Class)
		self.Owner:Kill()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:AttackAnim(tbl)
	self:SendWeaponAnim(VJ_PICK(tbl))
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
function SWEP:CustomOnPrimaryAttack_AfterShoot()
	self:AttackAnim(self.AnimTbl_PrimaryFire)
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
			self:VJ_ZSSkin("models/humans/corpse/corpse1")
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
		-- self:ZRemove()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:ViewModelDrawn()
	render.ModelMaterialOverride(0)
end
---------------------------------------------------------------------------------------------------------------------------------------------
local matSheet = Material("models/cpthazama/zombiesurvival/ghoulsheet")
function SWEP:PreDrawViewModel(vm)
	render.ModelMaterialOverride(matSheet)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:Holster(wep)
	if SERVER then
		-- self:ZRemove()
	end
	return false
end