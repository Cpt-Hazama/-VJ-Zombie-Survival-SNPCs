if (!file.Exists("autorun/vj_base_autorun.lua","LUA")) then return end
---------------------------------------------------------------------------------------------------------------------------------------------
	-- ZS Settings --
SWEP.PrintName					= "Drifter"
SWEP.ViewModel					= "models/chunky.mdl"
SWEP.ZombieModel				= "models/cpthazama/zombiesurvival/drifter.mdl"
SWEP.ZHealth					= 60
SWEP.ZSpeed						= 100
SWEP.ZSteps 					= false
SWEP.ZStepTime 					= false
SWEP.ViewModelFOV				= 10
SWEP.BobScale 					= 0.4
SWEP.SwayScale 					= 0.2
SWEP.Damage 					= 4
SWEP.DamageTime 				= 0.1
SWEP.PhysForce 					= 0
local attackSpeed 				= 0
local animDelay 				= 1
SWEP.Primary.Sound				= {"ambient/voices/squeal1.wav"}
SWEP.MoanSound 					= {"npc/barnacle/barnacle_digesting1.wav","npc/barnacle/barnacle_digesting2.wav"}
SWEP.PainSounds 				= {
	"npc/barnacle/barnacle_pull1.wav",
	"npc/barnacle/barnacle_pull2.wav",
	"npc/barnacle/barnacle_pull3.wav",
	"npc/barnacle/barnacle_pull4.wav"
}
SWEP.AnimTbl_PrimaryFire		= {ACT_VM_HITCENTER}
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
		self:EmitSound(VJ_PICK(self.MoanSound),80,100)
		self.NextMoanT = CurTime() +10
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:ZS_Animations(ply,w,a,s,d,lmb,rmb)
	local act = ACT_IDLE
	if (!w && !a && !s && !d) then
		act = ACT_IDLE
	else
		if lmb then
			act = ACT_MELEE_ATTACK1
		else
			act = ACT_WALK
		end
	end
	return act
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:SecondaryAttack()
	if (!self:CanSecondaryAttack()) then return end
	for _,v in pairs(ents.FindByClass("npc_vj_*")) do
		if VJ_HasValue(v.VJ_NPC_Class,"CLASS_ZOMBIE") && v:GetPos():Distance(self:GetPos()) <= 500 && v:Visible(self.Owner) then
			if v:Health() < v:GetMaxHealth() then
				v:SetHealth(math.Clamp(v:Health(),v:Health() +20,v:GetMaxHealth()))
				v:EmitSound("npc/vort/health_charge.wav",70,120)

				local spawnparticle = ents.Create("info_particle_system")
				spawnparticle:SetKeyValue("effect_name","vortigaunt_hand_glow")
				spawnparticle:SetPos(v:GetPos() +v:OBBCenter())
				spawnparticle:Spawn()
				spawnparticle:Activate()
				spawnparticle:SetParent(v)
				spawnparticle:Fire("Start","",0)
				spawnparticle:Fire("Kill","",0.6)
			end
		end
	end
	for _,v in pairs(player.GetAll()) do
		if v.VJ_ZS_IsZombie && v:GetPos():Distance(self:GetPos()) <= 500 && v:Visible(self.Owner) then
			if v:Health() < v:GetActiveWeapon().ZHealth then
				v:SetHealth(math.Clamp(v:Health(),v:Health() +20,v:GetActiveWeapon().ZHealth))
				v:EmitSound("npc/vort/health_charge.wav",70,120)

				local spawnparticle = ents.Create("info_particle_system")
				spawnparticle:SetKeyValue("effect_name","vortigaunt_hand_glow")
				spawnparticle:SetPos(v:GetPos() +v:OBBCenter())
				spawnparticle:Spawn()
				spawnparticle:Activate()
				spawnparticle:SetParent(v)
				spawnparticle:Fire("Start","",0)
				spawnparticle:Fire("Kill","",0.6)
			end
		end
	end
	if CLIENT then
		self.Owner:ChatPrint("45 second cooldown!")
	end
	self.Owner:EmitSound("npc/antlion_guard/angry2.wav",95,85)
	self.Weapon:SetNextSecondaryFire(CurTime() +45)
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
				sound.Play("npc/barnacle/neck_snap"..math.random(1,2)..".wav",tr.HitPos,70,100)
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
SWEP.NextCryT = 0
function SWEP:CustomOnThink()
	self.Owner:SetRunSpeed(self.ZSpeed)
	self.Owner:SetWalkSpeed(self.ZSpeed)
	if SERVER then self:GetOwner():SetModel(self.ZombieModel) end
	if IsValid(self.Owner) && self.Owner:GetActiveWeapon() != self then
		self.Owner.VJ_NPC_Class = {"CLASS_PLAYER_ALLY"}
		table.Empty(self.Owner.VJ_NPC_Class)
		self.Owner:Kill()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:CustomOnPrimaryAttack_AfterShoot()
	self.Weapon:SetNextSecondaryFire(CurTime() +self.Primary.Delay)
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
		-- ply.VJ_ZS_IsZombie = true
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
	self.Weapon:SetNextSecondaryFire(CurTime() +1)
	timer.Simple(0.03,function()
		if IsValid(self) then
			self.Owner:SetHealth(self.ZHealth)
			self.Owner:SetModel(self.ZombieModel); self.Owner:AllowFlashlight(false)
			self:VJ_ZSSkin("models/charple/charple4_sheet")
			-- self.Loop = CreateSound(self.Owner,"ambient/voices/crying_loop1.wav")
			-- self.Loop:SetSoundLevel(65)
			-- self.Loop:Play()
			-- self.Owner:SetViewOffset(Vector(0,0,self.ViewOffset))
		end
	end)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:Equip() end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:ZRemove()
	-- self.Loop:Stop()
	if SERVER then
		local ply = self.Owner
		ply:SetViewOffset(Vector(0,0,60))
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
	-- self:ZRemove()
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:Holster(wep)
	-- self:ZRemove()
	return false
end