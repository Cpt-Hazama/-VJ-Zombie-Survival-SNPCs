if (!file.Exists("autorun/vj_base_autorun.lua","LUA")) then return end
---------------------------------------------------------------------------------------------------------------------------------------------
	-- ZS Settings --
SWEP.PrintName					= "Zombine"
SWEP.ViewModel					= "models/cpthazama/zombiesurvival/weapons/zombine.mdl"
SWEP.ZombieModel				= "models/cpthazama/zombiesurvival/zombine.mdl"
SWEP.ZHealth					= 400
SWEP.ZSpeed						= 140
SWEP.ZSpeedRage					= 280
SWEP.ZSteps 					= {"npc/zombine/gear1.wav","npc/zombine/gear2.wav","npc/zombine/gear3.wav"}
SWEP.ZStepTime 					= 500
SWEP.ViewModelFOV				= 60
SWEP.BobScale 					= 0.4
SWEP.SwayScale 					= 0.2
SWEP.Damage 					= 18
SWEP.DamageTime 				= 0.4
SWEP.PhysForce 					= 2
local attackSpeed 				= 1.4
local animDelay 				= 1.2
SWEP.Primary.Sound				= {"npc/zombine/zombine_charge1.wav","npc/zombine/zombine_charge2.wav"}
SWEP.MoanSound 					= {
"npc/zombine/zombine_alert1.wav","npc/zombine/zombine_alert7.wav","npc/zombine/zombine_alert2.wav","npc/zombine/zombine_alert3.wav","npc/zombine/zombine_alert4.wav",
"npc/zombine/zombine_idle1.wav","npc/zombine/zombine_idle2.wav","npc/zombine/zombine_idle3.wav","npc/zombine/zombine_idle4.wav"}
SWEP.PainSounds 				= {"npc/zombine/zombine_pain1.wav","npc/zombine/zombine_pain2.wav","npc/zombine/zombine_pain3.wav","npc/zombine/zombine_pain4.wav"}
SWEP.AnimTbl_PrimaryFire		= {ACT_VM_PRIMARYATTACK}
SWEP.AnimTbl_Grenade			= {ACT_VM_THROW}
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
SWEP.HasPulledGrenade = false
SWEP.NextGrenPull = CurTime()
SWEP.Grenade = NULL
SWEP.GrenadeTimer = CurTime()
SWEP.RageState = false
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:Reload()
	return false
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:ZS_Animations(vel,maxSeqGroundSpeed)
	local animIdle = ACT_IDLE
	local animMove = ACT_WALK
	local animAttack = ACT_MELEE_ATTACK1
	
	if self.RageState then
		-- animMove = ACT_RUN_STIMULATED
	end

	local ply = self.Owner
	local keys = {w=ply:KeyDown(IN_FORWARD),a=ply:KeyDown(IN_MOVELEFT),s=ply:KeyDown(IN_BACK),d=ply:KeyDown(IN_MOVERIGHT),lmb=ply:KeyDown(IN_ATTACK),rmb=ply:KeyDown(IN_ATTACK2)}
	local data = {}
	local act = animIdle
	local ppx = 0
	local ppy = 0
	local noPresses = false
	if (!keys.w && !keys.a && !keys.s && !keys.d && !keys.lmb && !keys.rmb) then
		act = animIdle
	else
		if lmb then
			act = animAttack
		elseif keys.w or keys.a or keys.s or keys.d then
			act = animMove
		end
	end

	if keys.w then
		ppy = 1
	elseif keys.a then
		ppx = -1
	elseif keys.s then
		ppy = -1
	elseif keys.d then
		ppx = 1
	else
		ppx = 0
		ppy = 0
	end

	data.sequence = act
	data.movex = ppx
	data.movey = ppy
	return data
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
function SWEP:SecondaryAttack()
	if CLIENT then return end
	if CurTime() > self.NextGrenPull && !self.HasPulledGrenade /*&& self.Owner:Health() <= 60*/ then
		self.HasPulledGrenade = true
		self:SetNextPrimaryFire(CurTime() +30)
		self.NextIdle_PrimaryAttack = CurTime() +30
		self:EmitSound("npc/zombine/zombine_readygrenade" .. math.random(1,2) .. ".wav",75,100)
		self:AttackAnim(self.AnimTbl_Grenade)
		timer.Simple(0.6,function()
			if IsValid(self) then
				local grenent = ents.Create("npc_grenade_frag")
				local att = self.Owner:GetAttachment(self.Owner:LookupAttachment("grenade_attachment"))
				local pos = nil
				local ang = nil
				if att == nil then
					pos = self.Owner:GetPos()
					ang = self.Owner:GetAngles()
				else
					pos = att.Pos
					ang = att.Ang
				end
				grenent:SetModel("models/Items/grenadeAmmo.mdl")
				grenent:SetPos(pos)
				grenent:SetAngles(ang)
				grenent:SetOwner(self.Owner)
				grenent:SetParent(self.Owner)
				grenent:Fire("SetParentAttachment","grenade_attachment")
				grenent:Spawn()
				grenent:Activate()
				grenent:Input("SetTimer",self.Owner,self.Owner,3.5)
				self.Grenade = grenent
				self.GrenadeTimer = CurTime() +3.5
			end
		end)
		self.NextGrenPull = CurTime() +1
	end
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
function SWEP:CustomOnPrimaryAttack_AfterShoot()
	self:AttackAnim(self.AnimTbl_PrimaryFire)
end
---------------------------------------------------------------------------------------------------------------------------------------------
SWEP.Existed = false
function SWEP:CustomOnThink()
	if self.HasPulledGrenade then
		if IsValid(self.Grenade) && !self.Existed then
			self.Existed = true
		end
		if !IsValid(self.Grenade) && self.Existed && self.Owner:Alive() then
			self.Owner:Kill()
		end
	end
	if SERVER then
		self.NextMoanT = self.NextMoanT or CurTime()
		if CurTime() > self.NextMoanT then
			local snd = VJ_PICK(self.MoanSound)
			self:EmitSound(snd,75,100)
			self.NextMoanT = CurTime() +SoundDuration(snd) +math.Rand(0,1)
		end
	end
	if self.RageState then
		self.Owner:VJ_ZS_Howled(0.1)
		self.Owner:SetRunSpeed(self.ZSpeedRage)
		self.Owner:SetWalkSpeed(self.ZSpeedRage)
		self.ZStepTime = 350
	else
		self.Owner:SetRunSpeed(self.ZSpeed)
		self.Owner:SetWalkSpeed(self.ZSpeed)
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
	self.NextMoanT = CurTime() +2.75
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:PainSound()
	local snd = VJ_PICK(self.PainSounds)
	self:EmitSound(snd,80,100)
	if self.Owner:Health() <= 100 && !self.RageState then
		self.RageState = true
		snd = "npc/zombine/zombine_alert6.wav"
		self.Owner:EmitSound(snd,95,100)
		self.Owner:VJ_ZS_Howled(3)
	end
	self.NextMoanT = CurTime() +SoundDuration(snd) +math.Rand(0.5,1)
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
			self:VJ_ZSSkin("models/zombie_classic/combinesoldiersheet_zombie")
		end
	end)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:Equip() end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:ZRemove()
	self:GetOwner().VJ_NPC_Class = {nil}
	if IsValid(self.Owner) then
		for _,v in pairs(ents.FindByClass("npc_vj_*")) do
			if v.VJ_NPC_Class["CLASS_ZOMBIE"] then
				v:AddEntityRelationship(self.Owner,D_HT,99)
				table.insert(v.VJ_AddCertainEntityAsEnemy,self:GetOwner())
			else
				v:AddEntityRelationship(self.Owner,D_LI,99)
				table.insert(v.VJ_AddCertainEntityAsFriendly,self:GetOwner())
			end
		end
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
function SWEP:Holster(wep)
	if SERVER then
		-- self:ZRemove()
	end
	return false
end