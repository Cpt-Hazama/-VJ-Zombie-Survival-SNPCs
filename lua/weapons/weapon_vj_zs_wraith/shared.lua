if (!file.Exists("autorun/vj_base_autorun.lua","LUA")) then return end
---------------------------------------------------------------------------------------------------------------------------------------------
	-- ZS Settings --
SWEP.PrintName					= "Wraith (Stalker)"
SWEP.ViewModel					= "models/cpthazama/zombiesurvival/weapons/wraith.mdl"
SWEP.ZombieModel				= "models/cpthazama/zombiesurvival/wraith.mdl"
SWEP.ZHealth					= 175
SWEP.ZSpeed						= 200
SWEP.ViewModelFOV				= 70
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
function SWEP:ZS_Animations(vel,maxSeqGroundSpeed)
	local animIdle = ACT_IDLE
	local animMove = ACT_WALK
	local animAttack = ACT_MELEE_ATTACK1

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
SWEP.NextTP = CurTime()
function SWEP:SecondaryAttack()
	if CurTime() > self.NextTP then
		sound.Play("ambient/fire/mtov_flame2.wav",self:GetPos(),80,180)
		self.Owner:SetPos(self.Owner:GetEyeTrace().HitPos +Vector(0,0,5))
		self:EmitSound("npc/stalker/go_alert2a.wav",80,100)
		util.ScreenShake(self.Owner:GetPos(),16,100,3,50)
		local effectdata = EffectData()
		effectdata:SetOrigin(self:GetPos())
		effectdata:SetScale(50)
		util.Effect("ThumperDust",effectdata)
		self.NextTP = CurTime() +5
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
			self:VJ_ZSSkin("models/stalker/stalker_sheet")
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